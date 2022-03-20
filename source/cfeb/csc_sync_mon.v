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
  input [7:0] cfeb5_kchar,
  input [7:0] cfeb6_kchar,

  input [3:0] cfeb_rxd_int_delay,
  input [3:0] cfeb_rxd_int_delay_me1a,
  input [6:0] cfeb_fiber_enable,
  input [6:0] link_good, 
  input [6:0] cfeb_sync_done, // ttc resync is done


  output reg cfebs_me1a_synced,  // fibers from CSC chambers are synched
  output reg cfebs_me1a_lostsync,
  output reg cfebs_synced,  // fibers from CSC chambers are synched
  output reg cfebs_lostsync
);

parameter MXCFEB = 7;
//----------------------------------------------------------------------------------------------------------------------
// state machine power-up reset + global reset
//----------------------------------------------------------------------------------------------------------------------

  wire [3:0] pdly   = 1;    // Power-up reset delay
  reg        ready  = 0;

  wire [3:0] cfebdly = cfeb_rxd_int_delay +1;
  wire cfebs_sync_done = &cfeb_sync_done[3:0];
  wire [3:0] cfebdly_me1a = cfeb_rxd_int_delay_me1a +1;
  wire cfebs_sync_done_me1a = &cfeb_sync_done[6:4];

  wire cfebs_sync_done_srl;
  wire cfebs_sync_done_me1a_srl;

  SRL16E upup (.CLK(clock),.CE(!power_up & clk_lock),.D(1'b1),.A0(pdly[0]),.A1(pdly[1]),.A2(pdly[2]),.A3(pdly[3]),.Q(power_up));
  
  srl16e_bbl #(1)  ucfebSyncdelay  (.clock(~clock), .ce(1'b1), .adr(cfebdly), .d(  cfebs_sync_done), .q( cfebs_sync_done_srl)); // JRG: comp data leaves module on FALLING LHC_CLOCK edge (~clock)
  srl16e_bbl #(1)  ucfebSyncdelaya (.clock(~clock), .ce(1'b1), .adr(cfebdly_me1a), .d(  cfebs_sync_done_me1a), .q( cfebs_sync_done_me1a_srl)); // JRG: comp data leaves module on FALLING LHC_CLOCK edge (~clock)

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
  assign cfeb_kchar[5] = cfeb5_kchar;
  assign cfeb_kchar[6] = cfeb6_kchar;

//----------------------------------------------------------------------------------------------------------------------
// CSC Sync Monitoring
//     //All 8 possible frame marker
//	   // 1C,3C,5C,7C,9C,BC,DC,FD are valid K-words available to represent 3 extra bits in the data stream. --Skip F7, FB, FC and FE. 
//	   // So we could identify that BC=0 (very common), 1C=1, 3C=2, 5C=3, 7C=4, 9C=5, DC=6, FD=7 (all less common). 
//	   // Also allows use of 8-bit "data" byte in the EOF frame! Thus we have "59 data bits" per link (i.e. 118) every BX.
//	   // Perhaps a bit could mark the BC0, or overflow/error condition, or QPLL lock was lost, etc.
//The DCFEBs send 48 bits of data and a frame separator, continuously.  The frame separator is a BC50 (idle).  Every 256 clock cycles (80 MHz) the frame separator changes to an FC50.
//----------------------------------------------------------------------------------------------------------------------

wire [MXCFEB-1:0] skip_sync_check;
wire [MXCFEB-1:0] kchar_in_table;

genvar icfeb;
generate
    for (icfeb=0; icfeb<MXCFEB; icfeb=icfeb+1) begin
        //ignore the sync check when links are not good, cfeb fibers are not enabled, overflow, bc0marker, resyncmarker
        assign skip_sync_check[icfeb] = ~link_good[icfeb] || ~link_good_r2[icfeb] || ~cfeb_fiber_enable[icfeb];
        assign kchar_in_table[icfeb]  = (cfeb_kchar[icfeb][7:0] == 8'hFC || cfeb_kchar[icfeb][7:0] == 8'hBC) || skip_sync_check[icfeb];
    end
endgenerate 

wire cfebs_sync_s0 = (cfeb_kchar[0] & {8{~skip_sync_check[0]}}) | 
                     (cfeb_kchar[1] & {8{~skip_sync_check[1]}}) |
                     (cfeb_kchar[2] & {8{~skip_sync_check[2]}}) |
                     (cfeb_kchar[3] & {8{~skip_sync_check[3]}});

wire cfebs_sync_s1 = (cfeb_kchar[0] | {8{skip_sync_check[0]}}) & 
                     (cfeb_kchar[1] | {8{skip_sync_check[1]}}) &
                     (cfeb_kchar[2] | {8{skip_sync_check[2]}}) &
                     (cfeb_kchar[3] | {8{skip_sync_check[3]}});
                 
wire cfebs_sync = ((cfebs_sync_s0 == cfebs_sync_s1) && (&kchar_in_table[3:0])) || (&skip_sync_check[3:0]);

wire cfebs_sync_s0_me1a = (cfeb_kchar[4] & {8{~skip_sync_check[4]}}) | 
                          (cfeb_kchar[5] & {8{~skip_sync_check[5]}}) |
                          (cfeb_kchar[6] & {8{~skip_sync_check[6]}});

wire cfebs_sync_s1_me1a = (cfeb_kchar[4] | {8{skip_sync_check[4]}}) & 
                          (cfeb_kchar[5] | {8{skip_sync_check[5]}}) &
                          (cfeb_kchar[6] | {8{skip_sync_check[6]}});
                 
wire cfebs_sync_me1a = ((cfebs_sync_s0_me1a == cfebs_sync_s1_me1a) && (&kchar_in_table[6:4])) || (&skip_sync_check[6:4]);

initial cfebs_synced = 1'b1;
initial cfebs_lostsync = 1'b0;
initial cfebs_me1a_synced = 1'b1;
initial cfebs_me1a_lostsync = 1'b0;

always @(posedge clock) begin
    cfebs_synced   <= (reset || !cfebs_sync_done_srl) ? 1'b1 : cfebs_sync;
    cfebs_lostsync <= (reset || !cfebs_sync_done_srl) ? 1'b0 : (cfebs_lostsync | ~cfebs_sync);
    cfebs_me1a_synced   <= (reset || !cfebs_sync_done_me1a_srl) ? 1'b1 : cfebs_sync_me1a;
    cfebs_me1a_lostsync <= (reset || !cfebs_sync_done_me1a_srl) ? 1'b0 : (cfebs_me1a_lostsync | ~cfebs_sync_me1a);
end


endmodule
