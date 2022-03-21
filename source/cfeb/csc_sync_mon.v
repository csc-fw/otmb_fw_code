module csc_sync_mon (

  input clock,

  input clk_lock,

  input global_reset,
  input ttc_resync,

  input [7:0] cfeb0_kchar,
  input [7:0] cfeb1_kchar,
  input [7:0] cfeb2_kchar,
  input [7:0] cfeb3_kchar,
  input [7:0] cfeb4_kchar,

  input [3:0] cfeb_rxd_int_delay,
  input [4:0] cfeb_fiber_enable,
  input [4:0] link_good, 
  input [4:0] cfeb_lt_trg_err,
  input [4:0] cfeb_sync_done, // ttc resync is done


  output reg cfebs_synced,  // fibers from CSC chambers are synched
  // latched copies that gems have lost sync in past
  output reg cfebs_lostsync
);

parameter MXCFEB = 5;
//----------------------------------------------------------------------------------------------------------------------
// state machine power-up reset + global reset
//----------------------------------------------------------------------------------------------------------------------

  wire [3:0] pdly   = 1;    // Power-up reset delay
  reg        ready  = 0;

  wire [3:0] cfebdly = cfeb_rxd_int_delay +1;

  wire cfebs_sync_done = &cfeb_sync_done;
  wire cfebs_sync_done_srl;

  wire lt_trg_err_any = |cfeb_lt_trg_err[4:0];
  wire lt_trg_err_any_srl;

  SRL16E upup (.CLK(clock),.CE(!power_up & clk_lock),.D(1'b1),.A0(pdly[0]),.A1(pdly[1]),.A2(pdly[2]),.A3(pdly[3]),.Q(power_up));
  
  srl16e_bbl #(1)  ucfebSyncdelay (.clock(~clock), .ce(1'b1), .adr(cfebdly), .d(  cfebs_sync_done), .q( cfebs_sync_done_srl)); // JRG: comp data leaves module on FALLING LHC_CLOCK edge (~clock)
  srl16e_bbl #(1)  ucfeblttrgdelay (.clock(~clock), .ce(1'b1), .adr(cfebdly), .d(  lt_trg_err_any), .q( lt_trg_err_any_srl)); // JRG: comp data leaves module on FALLING LHC_CLOCK edge (~clock)

  always @(posedge clock) begin
      ready  <= power_up && !(global_reset || ttc_resync);
  end

  wire reset  = !ready;  // reset

  reg [MXCFEB-1:0] link_good_r1 = 0;
  reg [MXCFEB-1:0] link_good_r2 = 0;

  always @(posedge clock) begin
      link_good_r1[MXCFEB-1:0] <= link_good   [MXCFEB-1:0];
      link_good_r2[MXCFEB-1:0] <= link_good_r1[MXCFEB-1:0];
  end 
  
  wire [7:0] cfeb_kchar [MXCFEB-1:0];
  assign cfeb_kchar[0] = cfeb0_kchar;
  assign cfeb_kchar[1] = cfeb1_kchar;
  assign cfeb_kchar[2] = cfeb2_kchar;
  assign cfeb_kchar[3] = cfeb3_kchar;
  assign cfeb_kchar[4] = cfeb4_kchar;

//----------------------------------------------------------------------------------------------------------------------
// CSC Sync Monitoring
//     //All 8 possible frame marker
//	   // 1C,3C,5C,7C,9C,BC,DC,FD are valid K-words available to represent 3 extra bits in the data stream. --Skip F7, FB, FC and FE. 
//	   // So we could identify that BC=0 (very common), 1C=1, 3C=2, 5C=3, 7C=4, 9C=5, DC=6, FD=7 (all less common). 
//	   // Also allows use of 8-bit "data" byte in the EOF frame! Thus we have "59 data bits" per link (i.e. 118) every BX.
//	   // Perhaps a bit could mark the BC0, or overflow/error condition, or QPLL lock was lost, etc.
// The DCFEBs send 48 bits of data and a frame separator, continuously.  The frame separator is a BC50 (idle).  Every 256 clock cycles (80 MHz) the frame separator changes to an FC50.

//----------------------------------------------------------------------------------------------------------------------

wire [MXCFEB-1:0] skip_sync_check;
wire [MXCFEB-1:0] kchar_in_table;

genvar icfeb;
generate
    for (icfeb=0; icfeb<MXCFEB; icfeb=icfeb+1) begin: cfebsync
        //ignore the sync check when links are not good, cfeb fibers are not enabled, overflow, bc0marker, resyncmarker
        assign skip_sync_check[icfeb] =  ~link_good[icfeb] || ~link_good_r2[icfeb] || ~cfeb_fiber_enable[icfeb] || reset;
        assign kchar_in_table[icfeb]  = (cfeb_kchar[icfeb][7:0] == 8'hBC || cfeb_kchar[icfeb][7:0] == 8'hFC) || skip_sync_check[icfeb];
    end
endgenerate 

wire cfebs_sync_s0 = (cfeb_kchar[0] & {8{~skip_sync_check[0]}}) | 
                     (cfeb_kchar[1] & {8{~skip_sync_check[1]}}) |
                     (cfeb_kchar[2] & {8{~skip_sync_check[2]}}) |
                     (cfeb_kchar[3] & {8{~skip_sync_check[3]}}) |
                     (cfeb_kchar[4] & {8{~skip_sync_check[4]}});

wire cfebs_sync_s1 = (cfeb_kchar[0] | {8{skip_sync_check[0]}}) & 
                     (cfeb_kchar[1] | {8{skip_sync_check[1]}}) &
                     (cfeb_kchar[2] | {8{skip_sync_check[2]}}) &
                     (cfeb_kchar[3] | {8{skip_sync_check[3]}}) &
                     (cfeb_kchar[4] | {8{skip_sync_check[4]}});
wire cfebs_sync = ((cfebs_sync_s0 == cfebs_sync_s1) && (&kchar_in_table) && ~lt_trg_err_any_srl) || (&skip_sync_check) ;

initial cfebs_synced = 1'b1;
initial cfebs_lostsync = 1'b0;

always @(posedge clock) begin
    cfebs_synced   <= (reset || !cfebs_sync_done_srl) ? 1'b1 : cfebs_sync;
    cfebs_lostsync <= (reset || !cfebs_sync_done_srl) ? 1'b0 : (cfebs_lostsync | ~cfebs_sync);
end


endmodule
