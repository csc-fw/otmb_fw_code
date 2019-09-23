module gem_sync_mon (

  input clock,

  input clk_lock,

  input global_reset,
  input ttc_resync,

  input [7:0] gem0_kchar,
  input [7:0] gem1_kchar,
  input [7:0] gem2_kchar,
  input [7:0] gem3_kchar,

  input [3:0] gem_fiber_enable,
  input [3:0] link_good, 

  input gemA_overflow,
  input gemB_overflow,

  input gemA_bc0marker,
  input gemB_bc0marker,

  input gemA_resyncmarker,
  input gemB_resyncmarker,

  input gemA_sync_done, // ttc resync is done
  input gemB_sync_done,

  input gemA_rxd_int_delay,
  input gemB_rxd_int_delay,

  output reg gemA_synced,  // fibers from same OH are desynced
  output reg gemB_synced,  // fibers from same OH are desynced
  output reg gems_synced,  // fibers from both GEM chambers are synched

  // latched copies that gems have lost sync in past
  output reg gemA_lostsync,
  output reg gemB_lostsync,
  output reg gems_lostsync
);

//----------------------------------------------------------------------------------------------------------------------
// state machine power-up reset + global reset
//----------------------------------------------------------------------------------------------------------------------

  wire [3:0] pdly   = 1;    // Power-up reset delay
  reg        ready  = 0;

  wire [3:0] gemAdly = gemA_rxd_int_delay +1;
  wire [3:0] gemBdly = gemB_rxd_int_delay +1;

  wire gemA_sync_done_srl;
  wire gemB_sync_done_srl;

  SRL16E upup (.CLK(clock),.CE(!power_up & clk_lock),.D(1'b1),.A0(pdly[0]),.A1(pdly[1]),.A2(pdly[2]),.A3(pdly[3]),.Q(power_up));
  
  srl16e_bbl #(1)  ugemASyncdelay (.clock(~clock), .ce(1'b1), .adr(gemAdly), .d(  gemA_sync_done), .q( gemA_sync_done_srl); // JRG: comp data leaves module on FALLING LHC_CLOCK edge (~clock)
  srl16e_bbl #(1)  ugemBSyncdelay (.clock(~clock), .ce(1'b1), .adr(gemBdly), .d(  gemB_sync_done), .q( gemB_sync_done_srl); // JRG: comp data leaves module on FALLING LHC_CLOCK edge (~clock)
  //SRL16E gemAsyncdone (.CLK(clock),.CE(1),.D(gemA_sync_done),.A0(gemAdly[0]),.A1(gemAdly[1]),.A2(gemAdly[2]),.A3(gemAdly[3]),.Q(gemA_sync_done_srl));
  //SRL16E gemBsyncdone (.CLK(clock),.CE(1),.D(gemB_sync_done),.A0(gemBdly[0]),.A1(gemBdly[1]),.A2(gemBdly[2]),.A3(gemBdly[3]),.Q(gemB_sync_done_srl));

  always @(posedge clock) begin
      ready  <= power_up && !(global_reset || ttc_resync);
  end

  wire reset  = !ready;  // reset

  reg [3:0] link_good_r1 = 0;
  reg [3:0] link_good_r2 = 0;

  always @(posedge clock) begin
      link_good_r1[3:0] <= link_good[3:0];
      link_good_r2[3:0] <= link_good_r1[3:0];
  end 
  

//----------------------------------------------------------------------------------------------------------------------
// GEM Sync Local Oscillators
//----------------------------------------------------------------------------------------------------------------------

// we should cycle through these four K-codes:  BC, F7, FB, FD to serve as
// bunch sequence indicators.when we have more than 8 clusters
// detected on an OH (an S-bit overflow)
// we should send the "FC" K-code instead of the usual choice.
// "1C" K-code for BC0 marker
// "3C" K-code for resync marker

wire [7:0] frame_sep      [3:0];
wire [7:0] gem_kchar      [3:0];
wire [3:0] frame_sep_in_table;
reg  [7:0] frame_sep_next [3:0];

wire [3:0] frame_sep_err  ;

assign gem_kchar[0] = gem0_kchar;
assign gem_kchar[1] = gem1_kchar;
assign gem_kchar[2] = gem2_kchar;
assign gem_kchar[3] = gem3_kchar;

assign frame_sep_in_table[0] = gem_kchar[0]==8'hBC || gem_kchar[0]==8'hF7 || gem_kchar[0]==8'hFB || gem_kchar[0]==8'hFD;
assign frame_sep_in_table[1] = gem_kchar[1]==8'hBC || gem_kchar[1]==8'hF7 || gem_kchar[1]==8'hFB || gem_kchar[1]==8'hFD;
assign frame_sep_in_table[2] = gem_kchar[2]==8'hBC || gem_kchar[2]==8'hF7 || gem_kchar[2]==8'hFB || gem_kchar[2]==8'hFD;
assign frame_sep_in_table[3] = gem_kchar[3]==8'hBC || gem_kchar[3]==8'hF7 || gem_kchar[3]==8'hFB || gem_kchar[3]==8'hFD;

// on overflow/BC0/Resync, just assume it was correct and increment to the next marker (bypass the actual value, and just use the expected)
// if the marker is not in the table, use the expected value but flag an error
// we do this to keep the cycle going in the case of an error (so a single frame error doesn't always multiply x4)
assign frame_sep [0] = (~frame_sep_in_table[0]) ? frame_sep_next[0] : gem_kchar[0];
assign frame_sep [1] = (~frame_sep_in_table[1]) ? frame_sep_next[1] : gem_kchar[1];
assign frame_sep [2] = (~frame_sep_in_table[2]) ? frame_sep_next[2] : gem_kchar[2];
assign frame_sep [3] = (~frame_sep_in_table[3]) ? frame_sep_next[3] : gem_kchar[3];

genvar ifiber;
generate
for (ifiber=0; ifiber<4; ifiber=ifiber+1) begin: linkloop

  //initial  frame_sep_err  [ifiber] = 0;

  //always @(posedge clock) begin
      //frame_sep_err[ifiber] <= (reset) ? 1'b0 : (~frame_sep_in_table[ifiber] || frame_sep[ifiber]!=frame_sep_next[ifiber]);//count err if single frame error happened
  //end
  assign frame_sep_err[ifiber] = (reset) ? 1'b0 : (~frame_sep_in_table[ifiber] || frame_sep[ifiber]!=frame_sep_next[ifiber]);//count err if single frame error happened

  always @(posedge clock) begin
    case (frame_sep[ifiber])
      8'hFD:   frame_sep_next[ifiber] <= 8'hBC;
      8'hBC:   frame_sep_next[ifiber] <= 8'hF7;
      8'hF7:   frame_sep_next[ifiber] <= 8'hFB;
      8'hFB:   frame_sep_next[ifiber] <= 8'hFD;
      default: frame_sep_next[ifiber] <= frame_sep_next[ifiber];
    endcase
  end

end
endgenerate

//----------------------------------------------------------------------------------------------------------------------
// GEM Sync Monitoring
//----------------------------------------------------------------------------------------------------------------------

wire [1:0] gem_sync;
wire       gems_sync;
wire [1:0] skip_sync_check;

//ignore the sync check when links are not good, gem fibers are not enabled, overflow, bc0marker, resyncmarker
assign skip_sync_check [0] =  gemA_overflow || gemA_bc0marker || gemA_resyncmarker || (~&link_good[1:0]) || (~&link_good_r2[1:0]) || (~&gem_fiber_enable[1:0]);
assign skip_sync_check [1] =  gemB_overflow || gemB_bc0marker || gemB_resyncmarker || (~&link_good[3:2]) || (~&link_good_r2[3:2]) || (~&gem_fiber_enable[3:2]);

assign gem_sync [0] = skip_sync_check[0] || (~|frame_sep_err[1:0] && gem0_kchar==gem1_kchar); // two fibers from gem chamber 1 are synced to eachother
assign gem_sync [1] = skip_sync_check[1] || (~|frame_sep_err[3:2] && gem2_kchar==gem3_kchar); // two fibers from gem chamber 2 are synced to eachother

//assign gems_sync    = ((gem0_kchar==gem2_kchar) && (&gem_sync[1:0])) || (|skip_sync_check) || gemA_overflow || gemB_overflow || gemA_bc0marker || gemB_bc0marker || gemA_resyncmarker || gemB_resyncmarker; // gem super chamber is synced
assign gems_sync    = ((gem0_kchar==gem2_kchar) && (&gem_sync[1:0])) || (|skip_sync_check); // gem super chamber is synced

initial gemA_synced = 1'b1;
initial gemB_synced = 1'b1;
initial gems_synced = 1'b1;

initial gemA_lostsync = 1'b0;
initial gemB_lostsync = 1'b0;
initial gems_lostsync = 1'b0;

always @(posedge clock) begin
    gemA_synced   <= (reset || !gemA_sync_done_srl                       ) ? 1'b1 : gem_sync [0];
    gemB_synced   <= (reset || !gemB_sync_done_srl                       ) ? 1'b1 : gem_sync [1];
    gems_synced   <= (reset || !gemA_sync_done_srl || !gemB_sync_done_srl) ? 1'b1 : gems_sync;

    gemA_lostsync <= (reset || !gemA_sync_done_srl                       ) ? 1'b0 : gemA_lostsync | ~gem_sync[0];
    gemB_lostsync <= (reset || !gemB_sync_done_srl                       ) ? 1'b0 : gemB_lostsync | ~gem_sync[1];
    gems_lostsync <= (reset || !gemA_sync_done_srl || !gemB_sync_done_srl) ? 1'b0 : gems_lostsync | ~gems_synced;
end


endmodule
