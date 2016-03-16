`timescale 1ns / 1ps

`include "../otmb_virtex6_fw_version.v"

//`define DEBUG_CFEB 1
//-------------------------------------- bufferless raw hits version ------------------------------------------------
// Process 1 CFEB:
//    Input  8 DiStrips x 6 CSC Layers
//    Output  6x32=192 triad decoder pulses
//------------------------------------------------------------------------------------------------------------------
//  01/29/2002  Initial
//  02/05/2002  Changed ladj and radj to cfeb n+1 cfeb n-1 in Plane OR
//  02/06/2002  Added inj_febsel and fifo_feb_sel for multiplexing with other CFEBs
//  02/26/2002  Added FF to raw hits RAM outputs
//  02/27/2002  Replaced library FFs and counters with behavioral code
//  02/28/2002  Added FF to injector RAM outputs
//  02/28/2002  Changed RAM INIT format to work with 2 lines
//  03/02/2002  Changed tri-state RAM mux outputs to normal drivers, mux is now in clct_fifo
//  03/07/2002  Changed x_demux reset to aclr, converted to behavioral version
//  03/15/2002  Tri-stated inj_rdata
//  03/26/2002  Set RAM pattern defaults to normal CLCT
//  04/02/2002  Added 2nd demux test point
//  09/11/2002  New triad decoder with distrip output and new CLCT patterns
//  09/20/2002  Put back old triad decoder, crate DiStrips with ORs to correct for layer stagger
//  09/26/2002  New algorithm finds pattern envelopes and priority enocodes only on number layers hit
//  09/30/2002  Added cell retention to pattern finder module
//  10/28/2002  XST mods
//  11/04/2002  Change to triad_decode_v7, programmable persistence, sm reset, no parameter list
//  11/04/2002  Triad decoder gets pgmlut to set all pattern lut inputs =1 for programming
//  11/05/2002  State machine resets now async with auto power-up SRL16
//  11/06/2002  Fnd4.2 mods
//  11/07/2002  Fix distrip OR
//  11/12/2002  2nd muon logic
//  11/13/2002  Add () to count1s, speeds it up 10%
//  11/19/2002  Convert pipeline delays from FF to SRL16
//  11/19/2002  Revert to best 1 muon, 2 muon logic won't fit in XCV1000E, OR key hits for pre-trigger
//  11/21/2002  Last stage selects between best distrip and 1/2-strip
//  11/22/2002  Add 1/2-strip id bit to pattern number, add adjacent cfeb hit flags
//  12/20/2002  Separated pattern width parameters for distrip bit
//  12/20/2002  Remove last FF stage for speed
//  12/26/2002  Change inj_rdata from tristate to mux
//  12/27/2002  Change to triad_decode, allows 1-clock persistence
//  01/02/2003  Remove pipe delay on pre-trigger outputs, speeds up pre-trig out by 1 clock
//  01/02/2003  Add programmable strip mask for adject cfeb hits
//  05/05/2003  Fix hs ds selection rule
//  05/06/2003  Use hs_thresh_ff in hs ds selection instead of hs_thresh
//  05/06/2003  FF final stage for speed, otherwise get only 38MHz
//  05/12/2003  Add hsds tag to pretrigger output
//  03/15/2004  Convert 80MHz inputs to ddr
//  04/20/2004  Revert all DDR to 80MHz
//  06/07/2004  Change to x_demux_v2 which has aset for mpc
//  05/19/2006  Add cfeb_en to block triggers for disabled cfebs
//  05/24/2006  Add ceb_en resets triad decoders to allow raw hits readout of disabled cfebs without triggering
//  08/02/2006  Add layer trigger
//  09/11/2006  Mods for xst compile
//  09/12/2006  Optimize for xst
//  09/14/2006  Local persist subtraction, convert to virtex2 rams
//  10/04/2006  Mod triad decoder instantiation to use generate
//  10/04/2006  Replace for-loops with while-loops to remove xst warnings re unused integers
//  10/10/2006  Replace 80mhz demux with 40mhz ddr
//  10/16/2006  Temporarily revert triad persistence to 6-1=5 for software compatibility
//  10/16/2006  Unrevert, so persitence is now 6=6
//  11/29/2006  Remove scope debug signals
//  04/27/2007  Remove rx sync stage, shifts rx clock 12.5ns
//  07/02/2007  Revert to key layer 2
//  07/30/2007  Convert to bufferless raw hits ram, add debug state machine ascii display
//  08/02/2007  Extend pattern injector to 1k tbins, add programmable firing length
//  02/01/2008  Add parity to raw hits rams for seu detection
//  02/05/2008  Replace inferred raw hits ram with instantiated ram, xst fails to build dual port parity block rams
//  04/22/2008  Add triad test point at raw hits RAM input
//  11/17/2008  Invert parity so all 0s data has parity=1
//  11/17/2008  Change raw hits ram access to read-first so parity output is always valid
//  11/18/2008  Add non-staggered injector pattern for ME1A/B
//  04/23/2009  Mod for ise 10.1i
//  06/18/2009  Add cfeb muonic timing
//  06/25/2009  Muonic timing now spans a full clock cycle
//  06/29/2009  Remove digital phase shifters for cfebs, certain cfeb IOBs can not have 2 clock domains
//  07/10/2009  Return digital phase shifters for cfebs, mod ucf to move 5 IOB DDRs to fabric
//  07/22/2009  Remove clock_vme global net to make room for cfeb digital phase shifter gbufs
//  08/05/2009  Remove posneg, push cfeb_rx delay through final sync ff
//  08/07/2009  Revert to 10mhz vme clock
//  08/11/2009  Replace clock_vme with clock
//  08/21/2009  Add posneg
//  09/03/2009  Change cfeb_delay_is to cfeb_rxd_int_delay
//  12/11/2009  Add bad cfeb bit checking
//  01/06/2009  Restructure bad bit masks into 1d arrays
//  01/11/2010  Move bad bits check downstream of pattern injector
//  01/13/2010  Add single bx bad bit detection mode
//  01/14/2010  Move bad bits check to triad_s1
//  03/05/2010  Move hot channel + bad bits blocking ahead of raw hits ram, a big mistake, but poobah insists
//  03/07/2010  Add masked cfebs to blocked list
//  06/30/2010  Mod injector RAM for alct and l1a bits
//  07/07/2010  Revert to discrete ren, wen
//  07/23/2010  Replace DDR sub-module
//  08/06/2010  Port to ise 12
//  08/09/2010  Add init to pass_ff to power up in pass state
//  08/19/2010  Replace * with &
//  08/25/2010  Replace async resets with reg init
//  10/18/2010  Add virtex 6 RAM option
//  09/10/2012  Add gtx_optical_rx
//  09/14/2012  For Virtex-6 copper SCSI is disabled if GTX is enabled
//  02/21/2013  Bypass DDR for optical-only cfebs
//  03/07/2013  Remove scope channels
//  03/18/2013  Remove copper CFEB inputs
//
//-------------------------------------------------------------------------------------------------------------------
  module cfeb
  (
// Clock
  clock,
  clk_lock,    // In  40MHz TMB system clock MMCM locked
  clock_4x,
  clock_cfeb_rxd,
  cfeb_rxd_posneg,
  cfeb_rxd_int_delay,

// Global Reset
  global_reset,
  ttc_resync,
  mask_all,

// Injector
  inj_febsel,
  inject,
  inj_last_tbin,
  inj_wen,
  inj_rwadr,
  inj_wdata,
  inj_ren,
  inj_rdata,
  inj_ramout,
  inj_ramout_pulse,

// Raw Hits FIFO RAM
  fifo_wen,
  fifo_wadr,
  fifo_radr,
  fifo_sel,
  fifo_rdata,

// Hot Channel Mask
  ly0_hcm,
  ly1_hcm,
  ly2_hcm,
  ly3_hcm,
  ly4_hcm,
  ly5_hcm,

// Bad CFEB rx bit detection
  cfeb_badbits_reset,
  cfeb_badbits_block,
  cfeb_badbits_nbx,
  cfeb_badbits_found,
  cfeb_blockedbits,

  ly0_badbits,
  ly1_badbits,
  ly2_badbits,
  ly3_badbits,
  ly4_badbits,
  ly5_badbits,

// Triad Decoder
  triad_persist,
  triad_clr,
  triad_skip,
  ly0hs,
  ly1hs,
  ly2hs,
  ly3hs,
  ly4hs,
  ly5hs,

// CFEB data received on optical link = OR of all bits for ALL CFEBs
  gtx_rx_data_bits_or,

// Status
  demux_tp_1st,
  demux_tp_2nd,
  triad_tp,
  parity_err_cfeb,
  cfeb_sump,

// SNAP12 optical receiver
  clock_160,
  qpll_lock,
  rxp,
  rxn,

// Optical receiver status
  gtx_rx_enable,
  gtx_rx_reset,
  gtx_rx_reset_err_cnt,
  gtx_rx_en_prbs_test,
  gtx_rx_start,
  gtx_rx_fc,
  gtx_rx_valid,
  gtx_rx_match,
  gtx_rx_rst_done,
  gtx_rx_sync_done,
  gtx_rx_pol_swap,
  gtx_rx_err,
  gtx_rx_err_count,
  link_had_err,
  link_good,
  link_bad,
  gtx_rx_sump

// Debug
`ifdef DEBUG_CFEB
  ,inj_sm_dsp
  ,parity_wr
  ,parity_rd
  ,parity_expect
  ,pass_ff

  ,fifo_rdata_lyr0
  ,fifo_rdata_lyr1
  ,fifo_rdata_lyr2
  ,fifo_rdata_lyr3
  ,fifo_rdata_lyr4
  ,fifo_rdata_lyr5
`endif
  );
//------------------------------------------------------------------------------------------------------------------
// Generic
//------------------------------------------------------------------------------------------------------------------
  parameter ICFEB      = 0;          // CFEB 0-6 passed per instance

//------------------------------------------------------------------------------------------------------------------
// Bus Widths
//------------------------------------------------------------------------------------------------------------------
  parameter MXLY      = 6;          // Number of Layers in CSC
  parameter MXMUX      = 24;          // Number of multiplexed CFEB bits
  parameter MXTR      = MXMUX*2;        // Number of Triad bits per CFEB
  parameter MXDS      = 8;          // Number of DiStrips per layer
  parameter MXHS      = 32;          // Number of 1/2-Strips per layer
  parameter MXKEY      = MXHS;          // Number of Key 1/2-strips
  parameter MXKEYB    = 5;          // Number of key bits

// Raw hits RAM parameters
  parameter RAM_DEPTH    = 2048;          // Storage bx depth
  parameter RAM_ADRB    = 11;          // Address width=log2(ram_depth)
  parameter RAM_WIDTH    = 8;          // Data width
  
//------------------------------------------------------------------------------------------------------------------
// CFEB Ports
//------------------------------------------------------------------------------------------------------------------
// Clock
  input          clock;       // 40MHz TMB system clock
  input 	 clk_lock;    // In  40MHz TMB system clock MMCM locked
  input          clock_4x;          // 4*40MHz TMB system clock
  input          clock_cfeb_rxd;      // 40MHz iob ddr clock
  input          cfeb_rxd_posneg;    // CFEB cfeb-to-tmb inter-stage clock select 0 or 180 degrees
  input  [3:0]      cfeb_rxd_int_delay;    // Interstage delay, integer bx

// Global reset
  input          global_reset;      // 1=Reset everything
  input          ttc_resync;        // 1=Reset everything
  input          mask_all;        // 1=Enable, 0=Turn off all inputs

// Injector
  input          inj_febsel;        // 1=Enable RAM write
  input          inject;          // 1=Start pattern injector
  input  [11:0]      inj_last_tbin;      // Last tbin, may wrap past 1024 ram adr
  input  [2:0]      inj_wen;        // 1=Write enable injector RAM
  input  [9:0]      inj_rwadr;        // Injector RAM read/write address
  input  [17:0]      inj_wdata;        // Injector RAM write data
  input  [2:0]      inj_ren;        // Injector RAM select
  output  [17:0]      inj_rdata;        // Injector RAM read data
  output  [5:0]      inj_ramout;        // Injector RAM read data for ALCT and L1A
  output          inj_ramout_pulse;    // Injector RAM is injecting

// Raw Hits FIFO RAM
  input          fifo_wen;        // 1=Write enable FIFO RAM
  input  [RAM_ADRB-1:0]  fifo_wadr;        // FIFO RAM write address
  input  [RAM_ADRB-1:0]  fifo_radr;        // FIFO RAM read tbin address
  input  [2:0]      fifo_sel;        // FIFO RAM read layer address 0-5
  output  [RAM_WIDTH-1:0]  fifo_rdata;        // FIFO RAM read data

// Hot Channel Mask
  input  [MXDS-1:0]    ly0_hcm;        // 1=enable DiStrip
  input  [MXDS-1:0]    ly1_hcm;        // 1=enable DiStrip
  input  [MXDS-1:0]    ly2_hcm;        // 1=enable DiStrip
  input  [MXDS-1:0]    ly3_hcm;        // 1=enable DiStrip
  input  [MXDS-1:0]    ly4_hcm;        // 1=enable DiStrip
  input  [MXDS-1:0]    ly5_hcm;        // 1=enable DiStrip

// Bad CFEB rx bit detection
  input          cfeb_badbits_reset;    // Reset bad cfeb bits FFs
  input          cfeb_badbits_block;    // Allow bad bits to block triads
  input  [15:0]      cfeb_badbits_nbx;    // Cycles a bad bit must be continuously high
  output          cfeb_badbits_found;    // This CFEB has at least 1 bad bit
  output  [MXDS*MXLY-1:0]  cfeb_blockedbits;    // 1=CFEB rx bit blocked by hcm or went bad, packed

  output  [MXDS-1:0]    ly0_badbits;      // 1=CFEB rx bit went bad
  output  [MXDS-1:0]    ly1_badbits;      // 1=CFEB rx bit went bad
  output  [MXDS-1:0]    ly2_badbits;      // 1=CFEB rx bit went bad
  output  [MXDS-1:0]    ly3_badbits;      // 1=CFEB rx bit went bad
  output  [MXDS-1:0]    ly4_badbits;      // 1=CFEB rx bit went bad
  output  [MXDS-1:0]    ly5_badbits;      // 1=CFEB rx bit went bad

// Triad Decoder
  input  [3:0]      triad_persist; // Triad 1/2-strip persistence
  input             triad_clr;     // Triad one-shot clear
  output            triad_skip;    // Triads skipped
  output [MXHS-1:0] ly0hs;
  output [MXHS-1:0] ly1hs;
  output [MXHS-1:0] ly2hs;
  output [MXHS-1:0] ly3hs;
  output [MXHS-1:0] ly4hs;
  output [MXHS-1:0] ly5hs;

// CFEB data received on optical link = OR of all 48 bits for a given CFEB
  output gtx_rx_data_bits_or;

// Status
  output          demux_tp_1st;      // Demultiplexer test point first-in-time
  output          demux_tp_2nd;      // Demultiplexer test point second-in-time
  output          triad_tp;        // Triad test point at raw hits RAM input
  output  [MXLY-1:0]    parity_err_cfeb;    // Raw hits RAM parity error detected
  output          cfeb_sump;        // Unused signals wot must be connected

// SNAP12 optical receiver
  input          clock_160;        // 160 MHz from QPLL for GTX reference clock
  input          qpll_lock;        // QPLL was locked
  input          rxp;          // SNAP12+ fiber input for GTX
  input          rxn;          // SNAP12- fiber input for GTX

// Optical receiver status
  input          gtx_rx_enable;   // Enable/Unreset GTX_RX optical input, disables copper SCSI
  input          gtx_rx_reset;    // Reset GTX receiver rx_sync module
  input          gtx_rx_reset_err_cnt; // Resets the PRBS test error counters
  input          gtx_rx_en_prbs_test;  // Select random input test data mode
  output          gtx_rx_start;   // Set when the DCFEB Start Pattern is present
  output          gtx_rx_fc;      // Flags when Rx sees "FC" code (sent by Tx) for latency measurement
  output          gtx_rx_valid;   // Valid data detected on link
  output          gtx_rx_match;   // PRBS test data match detected, for PRBS tests, a VALID = "should have a match" such that !MATCH is an error
  output          gtx_rx_rst_done;     // This has to complete before rxsync can start
  output          gtx_rx_sync_done;    // Use these to determine gtx_ready
  output          gtx_rx_pol_swap;     // GTX 5,6 [ie dcfeb 4,5] have swapped rx board routes
  output          gtx_rx_err;          // PRBS test detects an error
  output  [15:0]  gtx_rx_err_count;    // Error count on this fiber channel
  output          gtx_rx_sump;    // Unused signals

  output link_had_err; // link stability monitor: error happened at least once
  output link_good;    // link stability monitor: always good, no errors since last resync
  output link_bad;     // link stability monitor: errors happened over 100 times

// Debug
`ifdef DEBUG_CFEB
  output  [71:0]      inj_sm_dsp;        // Injector state machine ascii display
  output  [MXLY-1:0]    parity_wr;
  output  [MXLY-1:0]    parity_rd;
  output  [MXLY-1:0]    parity_expect;
  output          pass_ff;

  output  [MXDS-1+1:0]  fifo_rdata_lyr0;
  output  [MXDS-1+1:0]  fifo_rdata_lyr1;
  output  [MXDS-1+1:0]  fifo_rdata_lyr2;
  output  [MXDS-1+1:0]  fifo_rdata_lyr3;
  output  [MXDS-1+1:0]  fifo_rdata_lyr4;
  output  [MXDS-1+1:0]  fifo_rdata_lyr5;
`endif

//-------------------------------------------------------------------------------------------------------------------
// Load global definitions
//-------------------------------------------------------------------------------------------------------------------
  initial $display ("ICFEB=%H",ICFEB);

  `ifdef CSC_TYPE_C initial $display ("CSC_TYPE_C=%H",`CSC_TYPE_C); `endif  // Normal  ME1B reversed ME1A
  `ifdef CSC_TYPE_D initial $display ("CSC_TYPE_D=%H",`CSC_TYPE_D); `endif  // Reversed ME1B normal   ME1A

  `ifdef  CFEB_INJECT_STAGGER initial $display ("CFEB Pattern injector layer staggering is ON");  `endif
  `ifndef CFEB_INJECT_STAGGER initial $display ("CFEB Pattern injector layer staggering is OFF"); `endif

//-------------------------------------------------------------------------------------------------------------------
// State machine power-up reset + global reset
//-------------------------------------------------------------------------------------------------------------------
  wire [3:0]  pdly   = 1;    // Power-up reset delay
  reg      ready  = 0;
  reg      tready = 0;

  SRL16E upup (.CLK(clock),.CE(!power_up & clk_lock),.D(1'b1),.A0(pdly[0]),.A1(pdly[1]),.A2(pdly[2]),.A3(pdly[3]),.Q(power_up));

  always @(posedge clock) begin
     ready  <= power_up && !(global_reset || ttc_resync);
     tready <= power_up && !(global_reset || triad_clr  || ttc_resync);
  end

  wire reset  = !ready;  // injector state machine reset
  wire treset = !tready;  // triad decoder state machine reset

//-------------------------------------------------------------------------------------------------------------------
// Stage bx0: Read optical serial CFEB data stream into comparator triads.
//-------------------------------------------------------------------------------------------------------------------
// Virtex6 DCFEB optical receivers
  wire [47:0] gtx_rx_data;
  wire        gtx_rx_data_bits_or = (|gtx_rx_data); // CFEB data received on optical link
  wire gtx_rx_pol_swap = (ICFEB==4 || ICFEB==5);

  gtx_optical_rx ugtx_optical_rx
  (
// Clocks
  .clock       (clock),           // In  40  MHz fabric clock
  .clock_4x    (clock_4x),        // In  4*40  MHz fabric clock
  .clock_iob   (clock_cfeb_rxd),  // In  40  MHZ iob clock
  .clock_160   (clock_160),       // In  160 MHz from QPLL for GTX reference clock
  .ttc_resync  (ttc_resync),      // use this to clear the link status monitor

// Muonic
  .clear_sync  (~gtx_rx_enable),          // In  Clear sync stages, use this to put GTX_RX in Reset state
  .posneg      (cfeb_rxd_posneg),         // In  Select inter-stage clock 0 or 180 degrees
  .delay_is    (cfeb_rxd_int_delay[3:0]), // In  Interstage delay
  
// SNAP12 optical receiver
//  .clocks_rdy (qpll_lock), // In  QPLL & MMCM were locked after power-up... AND is done at top level in l_qpll_lock logic; was AND of real-time lock signals
  .clocks_rdy (qpll_lock & clk_lock), // In  QPLL & MMCM are locked
  .rxp          (rxp),                // In  SNAP12+ fiber input for GTX
  .rxn          (rxn),                // In  SNAP12- fiber input for GTX
  .gtx_rx_pol_swap (gtx_rx_pol_swap), // In  Inputs 5,6 [ie icfeb 4,5] have swapped rx board routes

// Optical receiver status
  .gtx_rx_reset         (gtx_rx_reset),           // In  Reset GTX rx & sync module... 
  .gtx_rx_reset_err_cnt (gtx_rx_reset_err_cnt),   // In  Resets the PRBS test error counters
  .gtx_rx_en_prbs_test  (gtx_rx_en_prbs_test),    // In  Select random input test data mode
  .gtx_rx_start         (gtx_rx_start),           // Out  Set when the DCFEB Start Pattern is present
  .gtx_rx_fc            (gtx_rx_fc),              // Out  Flags when Rx sees "FC" code (sent by Tx) for latency measurement
  .gtx_rx_valid         (gtx_rx_valid),           // Out  Valid data detected on link
  .gtx_rx_match         (gtx_rx_match),           // Out  PRBS test data match detected, for PRBS tests, a VALID = "should have a match" such that !MATCH is an error
  .gtx_rx_rst_done      (gtx_rx_rst_done),        // Out  These get set before rxsync
  .gtx_rx_sync_done     (gtx_rx_sync_done),       // Out  Use these to determine gtx_ready
  .gtx_rx_err           (gtx_rx_err),             // Out  PRBS test detects an error
  .gtx_rx_err_count     (gtx_rx_err_count[15:0]), // Out  Error count on this fiber channel
  .gtx_rx_data          (gtx_rx_data[47:0]),      // Out  DCFEB comparator data
  .link_had_err         (link_had_err),
  .link_good            (link_good),
  .link_bad             (link_bad),
  .gtx_rx_sump          (gtx_rx_sump)        // Unused signals
  );

// Map DCFEB Signal names into Triad names per BB email:{L2,L4,L6,L5,L1,L3} --> {L1,L3,L5,L4,L0,L2}in TMB convention
  wire [MXDS-1:0]  triad_s0 [MXLY-1:0];

  assign triad_s0[2][7:0]  = gtx_rx_data[7:0];   // Layer 2
  assign triad_s0[0][7:0]  = gtx_rx_data[15:8];  // Layer 0
  assign triad_s0[4][7:0]  = gtx_rx_data[23:16]; // Layer 4
  assign triad_s0[5][7:0]  = gtx_rx_data[31:24]; // Layer 5
  assign triad_s0[3][7:0]  = gtx_rx_data[39:32]; // Layer 3
  assign triad_s0[1][7:0]  = gtx_rx_data[47:40]; // Layer 1

// De-multiplexer test points: rx0 pins 1+2- Ly0Tr0  Ly3Tr0
  reg demux_tp_1st = 0;
  reg demux_tp_2nd = 0;

  always @(posedge clock) begin
     demux_tp_1st <= triad_s0[0][0];  // Layer 0 ds 0  1st in time
     demux_tp_2nd <= triad_s0[3][0];  // Layer 3 ds 0 2nd in time
  end

//-------------------------------------------------------------------------------------------------------------------
// Stage 1:  Pattern Injector
//      Injects an arbitrary test pattern into the Triad data stream.
//      Mask_all in the previous stage turns off CFEB inputs.
//      Stores raw hits in RAM
//
// Injector powers up with a preset pattern
//  Key on Ly2:  a05b06c05d06e05f06:  a straight 6-hit pattern on key 1/2-strip 05 starting in time bin 0
//        axxb27c26d27e26f27:  a straight 5-hit pattern on key 1/2-strip 26 starting in time bin 0
//
//  Key on Ly3:  a04b05c04d05e04f05:  a straight 6-hit pattern on key 1/2-strip 05 starting in time bin 0
//        axxb26c25d26e25f26:  a straight 5-hit pattern on key 1/2-strip 26 starting in time bin 0
//
//
//  DiStrip      0           1           2           3           4           5           6           7
//  Strip      0     1     0     1     0     1     0     1     0     1     0     1     0     1     0     1  
//  HStrip       0  1  2  3  0  1  2  3  0  1  2  3  0  1  2  3  0  1  2  3  0  1  2  3  0  1  2  3  0  1  2  3
//  1/2 Strip    00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31
//
//                a5 b6 c5 d6 e5 f6
//  DiStrip  1:    1  1  1  1  1  1
//  Strip  0,1:    0  1  0  1  0  1
//  HStrip 6,5:   1  0  1  0  1  0
//
// 10/08/2001  Initial
// 10/11/2001  Converted from CLB to RAM. CLB version used 198 Slices, 195 FFs, RAM version uses xx FFs and 3 BlockRAMs
// 01/29/2002  Ported to CFEB
// 11/07/2002  Converted to key layer 3, because I was forced to =:-(
// 07/02/2007  Reverted  to key layer 2, because I was forced to =:-)
//-------------------------------------------------------------------------------------------------------------------
// Injector State Machine Declarations
  reg [1:0] inj_sm;    // synthesis attribute safe_implementation of inj_sm is yes;
  parameter pass    = 0;
  parameter injecting  = 1;

// Injector State Machine
  wire inj_tbin_cnt_done;

  initial inj_sm = pass;

  always @(posedge clock) begin
     if   (reset)                     inj_sm <= pass;
     else begin
	case (inj_sm)
	  pass:    if (inject           ) inj_sm <= injecting;
	  injecting:  if (inj_tbin_cnt_done) inj_sm <= pass;
	  default                            inj_sm <= pass;
	endcase
     end
  end

// Injector Time Bin Counter
  reg  [11:0] inj_tbin_cnt=0;  // Counter runs 0-4095
  wire [9:0]  inj_tbin_adr;  // Injector adr runs 0-1023

  always @(posedge clock) begin
     if    (inj_sm==pass     ) inj_tbin_cnt <= 0;          // Sync  load
     else if  (inj_sm==injecting) inj_tbin_cnt <= inj_tbin_cnt+1'b1;  // Sync  count
  end

  assign inj_tbin_cnt_done = (inj_tbin_cnt==inj_last_tbin);    // Counter may wrap past 1024 ram adr limit
  assign inj_tbin_adr[9:0] = inj_tbin_cnt[9:0];          // injector ram address confined to 0-1023

// Pass state FF delays output mux 1 cycle
  reg pass_ff=1;

  always @(posedge clock) begin
     if (reset) pass_ff <= 1'b1;
     else       pass_ff <= (inj_sm == pass);
  end

// Injector RAM: 3 RAMs each 2 layers x 8 triads wide x 1024 tbins deep
// Port A: rw 18-bits via VME
// Port B: r  18-bits via injector SM
  wire [17:0]    inj_rdataa  [2:0];
  wire [1:0]    inj_ramoutb [2:0];
  wire [MXDS-1:0] triad_inj   [MXLY-1:0];

  initial $display("cfeb: generating Virtex6 RAMB18E1_S18_S18 ram.inj");

  genvar i;
  generate
  for (i=0; i<=2; i=i+1) begin: ram
  RAMB18E1 #(                        // Virtex6
  .INIT_00 (256'h0000000000000000000000000000000000000000000000000000400242400202),                          
  .INIT_01 (256'h0000000000000000000000000000000000000000000000000000000000000000),                          
  .RAM_MODE      ("TDP"),              // SDP or TDP
   .READ_WIDTH_A    (18),                // 0,1,2,4,9,18,36 Read/write width per port
  .WRITE_WIDTH_A    (18),                // 0,1,2,4,9,18
  .READ_WIDTH_B    (18),                // 0,1,2,4,9,18
  .WRITE_WIDTH_B    (0),                // 0,1,2,4,9,18,36
  .WRITE_MODE_A    ("READ_FIRST"),            // WRITE_FIRST, READ_FIRST, or NO_CHANGE
  .WRITE_MODE_B    ("READ_FIRST"),
  .SIM_COLLISION_CHECK("ALL")                // ALL, WARNING_ONLY, GENERATE_X_ONLY or NONE)
  ) inj (
  .WEA        ({2{inj_wen[i] & inj_febsel}}),    //  2-bit A port write enable input
  .ENARDEN      (1'b1),                //  1-bit A port enable/Read enable input
  .RSTRAMARSTRAM    (1'b0),                //  1-bit A port set/reset input
  .RSTREGARSTREG    (1'b0),                //  1-bit A port register set/reset input
  .REGCEAREGCE    (1'b0),                //  1-bit A port register enable/Register enable input
  .CLKARDCLK      (clock),              //  1-bit A port clock/Read clock input
  .ADDRARDADDR    ({inj_rwadr[9:0],4'hF}),      // 14-bit A port address/Read address input 18b->[13:4]
  .DIADI        (inj_wdata[15:0]),          // 16-bit A port data/LSB data input
  .DIPADIP      (inj_wdata[17:16]),          //  2-bit A port parity/LSB parity input
  .DOADO        (inj_rdataa[i][15:0]),        // 16-bit A port data/LSB data output
  .DOPADOP      (inj_rdataa[i][17:16]),        //  2-bit A port parity/LSB parity output

  .WEBWE        (),                  //  4-bit B port write enable/Write enable input
  .ENBWREN      (1'b1),                //  1-bit B port enable/Write enable input
  .REGCEB        (1'b0),                //  1-bit B port register enable input
  .RSTRAMB      (1'b0),                //  1-bit B port set/reset input
  .RSTREGB      (1'b0),                //  1-bit B port register set/reset input
  .CLKBWRCLK      (clock),              //  1-bit B port clock/Write clock input
  .ADDRBWRADDR    ({inj_tbin_adr[9:0],4'hF}),      // 14-bit B port address/Write address input 18b->[13:4]
  .DIBDI        (),                  // 16-bit B port data/MSB data input
  .DIPBDIP      (),                  //  2-bit B port parity/MSB parity input
  .DOBDO        ({triad_inj[2*i+1],triad_inj[2*i]}),// 16-bit B port data/MSB data output
  .DOPBDOP      (inj_ramoutb[i][1:0]));        //  2-bit B port parity/MSB parity output
  end
  endgenerate

// ME1A/B Non-Staggered CSC
// Initialize Injector RAMs, INIT values contain preset test pattern, 2 layers x 16 tbins per line
// Key layer 2: 6 hits on key 5 + 5 hits on key 26, 55555 non-staggered CSC
// Tbin                               FFFFEEEEDDDDCCCCBBBBAAAA9999888877776666555544443333222211110000;
   
  // defparam ram[0].inj.INIT_00 =256'h0000000000000000000000000000000000000000000000000000400242000202;
  // defparam ram[0].inj.INIT_01 =256'h0000000000000000000000000000000000000000000000000000000000000000;
  // defparam ram[1].inj.INIT_00 =256'h0000000000000000000000000000000000000000000000000000400242400202;
  // defparam ram[1].inj.INIT_01 =256'h0000000000000000000000000000000000000000000000000000000000000000;
  // defparam ram[2].inj.INIT_00 =256'h0000000000000000000000000000000000000000000000000000400242400202;
  // defparam ram[2].inj.INIT_01 =256'h0000000000000000000000000000000000000000000000000000000000000000;

// Multiplex Injector RAM output data, tri-state output if CFEB is not selected
  reg [17:0] inj_rdata;

  always @(inj_rdataa[0] or inj_ren) begin
     case (inj_ren[2:0])
       3'b001:  inj_rdata <= inj_rdataa[0];
       3'b010:  inj_rdata <= inj_rdataa[1];
       3'b100:  inj_rdata <= inj_rdataa[2];
       default  inj_rdata <= inj_rdataa[0];
     endcase
  end

  assign inj_ramout[1:0] = inj_ramoutb[0][1:0];
  assign inj_ramout[3:2] = inj_ramoutb[1][1:0];
  assign inj_ramout[5:4] = inj_ramoutb[2][1:0];

  assign inj_ramout_pulse  = !pass_ff;

// Multiplex Triads from previous stage with Injector RAM data, output to next stage
  wire [MXDS-1:0] triad_s1 [MXLY-1:0];

  assign triad_s1[0] = (pass_ff) ? triad_s0[0] : triad_inj[0];
  assign triad_s1[1] = (pass_ff) ? triad_s0[1] : triad_inj[1];
  assign triad_s1[2] = (pass_ff) ? triad_s0[2] : triad_inj[2];
  assign triad_s1[3] = (pass_ff) ? triad_s0[3] : triad_inj[3];
  assign triad_s1[4] = (pass_ff) ? triad_s0[4] : triad_inj[4];
  assign triad_s1[5] = (pass_ff) ? triad_s0[5] : triad_inj[5];

  assign triad_tp  = triad_s1[2][1];  // Triad 1 hs4567 layer 2 test point for internal scope

//-------------------------------------------------------------------------------------------------------------------
// Stage 2: Check for CFEB bits stuck at logic 1 for too long + Apply hot channel mask
//-------------------------------------------------------------------------------------------------------------------
// FF buffer control inputs
  reg [15:0]  cfeb_badbits_nbx_minus1 = 16'hFFFF;
  reg      cfeb_badbits_block_ena  = 0;
  reg      single_bx_mode = 0;

  always @(posedge clock) begin
     cfeb_badbits_block_ena  <= cfeb_badbits_block;
     cfeb_badbits_nbx_minus1  <= cfeb_badbits_nbx-1'b1;
     single_bx_mode      <= cfeb_badbits_nbx==1;
  end

// Periodic check pulse counter
  reg [15:0] check_cnt=16'h000F;

  wire check_cnt_ena = (check_cnt < cfeb_badbits_nbx_minus1);
  
  always @(posedge clock) begin
     if      (cfeb_badbits_reset) check_cnt <= 0;
     else if (check_cnt_ena     ) check_cnt <= check_cnt+1'b1;
     else                         check_cnt <= 0;
  end

  wire check_pulse = (check_cnt==0);

// Check CFEB bits with high-too-long state machine
  wire [MXDS-1:0] badbits [MXLY-1:0];

  genvar ids;
  genvar ily;
  generate
     for (ids=0; ids<MXDS; ids=ids+1) begin: ckbitds
	for (ily=0; ily<MXLY; ily=ily+1) begin: ckbitly
	   cfeb_bit_check ucfeb_bit_check (
		.clock      (clock),        // 40MHz main clock
		.reset      (cfeb_badbits_reset),  // Clear stuck bit FFs
		.check_pulse  (check_pulse),      // Periodic checking
		.single_bx_mode  (single_bx_mode),    // Check for single bx pulses    
		.bit_in      (triad_s1[ily][ids]),  // Bit to check
		.bit_bad    (badbits[ily][ids]) );  // Bit went bad flag
	end
     end
  endgenerate

// Summary badbits for this CFEB
  reg cfeb_badbits_found=0;

  wire cfeb_badbits_or =
       (|badbits[0][7:0])|
       (|badbits[1][7:0])|
       (|badbits[2][7:0])|
       (|badbits[3][7:0])|
       (|badbits[4][7:0])|
       (|badbits[5][7:0]);

  always @(posedge clock) begin
     cfeb_badbits_found <= cfeb_badbits_or;
  end

// Blocked triad bits list, 1=blocked 0=ok to tuse
  reg [MXDS-1:0] blockedbits [MXLY-1:0];

  always @(posedge clock) begin
  blockedbits[0] <= ~ly0_hcm | (badbits[0] & {MXDS {cfeb_badbits_block_ena}});
  blockedbits[1] <= ~ly1_hcm | (badbits[1] & {MXDS {cfeb_badbits_block_ena}});
  blockedbits[2] <= ~ly2_hcm | (badbits[2] & {MXDS {cfeb_badbits_block_ena}});
  blockedbits[3] <= ~ly3_hcm | (badbits[3] & {MXDS {cfeb_badbits_block_ena}});
  blockedbits[4] <= ~ly4_hcm | (badbits[4] & {MXDS {cfeb_badbits_block_ena}});
  blockedbits[5] <= ~ly5_hcm | (badbits[5] & {MXDS {cfeb_badbits_block_ena}});
  end

// Apply Hot Channel Mask to block Errant DiStrips: 1=enable DiStrip, not blocking hstrips, they share a triad start bit
  wire [MXDS-1:0] triad_s2 [MXLY-1:0];  // Masked triads

  assign triad_s2[0] = triad_s1[0] & ~blockedbits[0];
  assign triad_s2[1] = triad_s1[1] & ~blockedbits[1];
  assign triad_s2[2] = triad_s1[2] & ~blockedbits[2];
  assign triad_s2[3] = triad_s1[3] & ~blockedbits[3];
  assign triad_s2[4] = triad_s1[4] & ~blockedbits[4];
  assign triad_s2[5] = triad_s1[5] & ~blockedbits[5];

// Map 2D arrays to 1D for VME
  assign ly0_badbits = badbits[0];
  assign ly1_badbits = badbits[1];
  assign ly2_badbits = badbits[2];
  assign ly3_badbits = badbits[3];
  assign ly4_badbits = badbits[4];
  assign ly5_badbits = badbits[5];

// Map to 1D 48bits for readout machine, mark all blocked if mask_all=0
  assign cfeb_blockedbits = (mask_all) ? {blockedbits[5],blockedbits[4],blockedbits[3],blockedbits[2],blockedbits[1],blockedbits[0]}
                                       : 48'hFFFFFFFFFFFF;
//-------------------------------------------------------------------------------------------------------------------
// Raw hits RAM storage
//-------------------------------------------------------------------------------------------------------------------
// Calculate parity for raw hits RAM write data
  wire [MXLY-1:0] parity_wr;
  wire [MXLY-1:0] parity_rd;

  assign parity_wr[0] = ~(^ triad_s2[0][MXDS-1:0]);
  assign parity_wr[1] = ~(^ triad_s2[1][MXDS-1:0]);
  assign parity_wr[2] = ~(^ triad_s2[2][MXDS-1:0]);
  assign parity_wr[3] = ~(^ triad_s2[3][MXDS-1:0]);
  assign parity_wr[4] = ~(^ triad_s2[4][MXDS-1:0]);
  assign parity_wr[5] = ~(^ triad_s2[5][MXDS-1:0]);

// Raw hits RAM writes incoming hits into port A, reads out to DMB via port B
  wire [MXDS-1:0] fifo_rdata_ly [MXLY-1:0];

  initial $display("cfeb: generating Virtex6 RAMB18E1_S9_S9 raw.rawhits_ram");
  wire [8:0] db [MXLY-1:0];                // Virtex6 dob dummy, no sump needed
  wire dopa=0;                      // Virtex2 doa dummy

  generate
  for (ily=0; ily<=MXLY-1; ily=ily+1) begin: raw
  RAMB18E1 #(                        // Virtex6
  .RAM_MODE      ("TDP"),              // SDP or TDP
  .READ_WIDTH_A    (0),                // 0,1,2,4,9,18,36 Read/write width per port
  .WRITE_WIDTH_A    (9),                // 0,1,2,4,9,18
  .READ_WIDTH_B    (9),                // 0,1,2,4,9,18
  .WRITE_WIDTH_B    (0),                // 0,1,2,4,9,18,36
  .WRITE_MODE_A    ("READ_FIRST"),            // WRITE_FIRST, READ_FIRST, or NO_CHANGE
  .WRITE_MODE_B    ("READ_FIRST"),
  .SIM_COLLISION_CHECK("ALL")                // ALL, WARNING_ONLY, GENERATE_X_ONLY or NONE)
  ) rawhits_ram (
  .WEA        ({2{fifo_wen}}),          //  2-bit A port write enable input
  .ENARDEN      (1'b1),                //  1-bit A port enable/Read enable input
  .RSTRAMARSTRAM    (1'b0),                //  1-bit A port set/reset input
  .RSTREGARSTREG    (1'b0),                //  1-bit A port register set/reset input
  .REGCEAREGCE    (1'b0),                //  1-bit A port register enable/Register enable input
  .CLKARDCLK      (clock),              //  1-bit A port clock/Read clock input
  .ADDRARDADDR    ({fifo_wadr[10:0],3'h7}),      // 14-bit A port address/Read address input 9b->[13:3]
  .DIADI        ({8'h00,triad_s2[ily]}),      // 16-bit A port data/LSB data input
  .DIPADIP      ({1'b0,parity_wr[ily]}),      //  2-bit A port parity/LSB parity input
  .DOADO        (),                  // 16-bit A port data/LSB data output
  .DOPADOP      (),                  //  2-bit A port parity/LSB parity output

  .WEBWE        (),                  //  4-bit B port write enable/Write enable input
  .ENBWREN      (1'b1),                //  1-bit B port enable/Write enable input
  .REGCEB        (1'b0),                //  1-bit B port register enable input
  .RSTRAMB      (1'b0),                //  1-bit B port set/reset input
  .RSTREGB      (1'b0),                //  1-bit B port register set/reset input
  .CLKBWRCLK      (clock),              //  1-bit B port clock/Write clock input
  .ADDRBWRADDR    ({fifo_radr[10:0],3'hF}),      // 14-bit B port address/Write address input 18b->[13:4]
  .DIBDI        (),                  // 16-bit B port data/MSB data input
  .DIPBDIP      (),                  //  2-bit B port parity/MSB parity input
  .DOBDO        ({db[ily][7:0],fifo_rdata_ly[ily]}),// 16-bit B port data/MSB data output
  .DOPBDOP      ({db[ily][8],parity_rd[ily]})    //  2-bit B port parity/MSB parity output
  );
  end
  endgenerate

// Compare read parity to write parity
  wire [MXLY-1:0] parity_expect;

  assign parity_expect[0] = ~(^ fifo_rdata_ly[0]);
  assign parity_expect[1] = ~(^ fifo_rdata_ly[1]);
  assign parity_expect[2] = ~(^ fifo_rdata_ly[2]);
  assign parity_expect[3] = ~(^ fifo_rdata_ly[3]);
  assign parity_expect[4] = ~(^ fifo_rdata_ly[4]);
  assign parity_expect[5] = ~(^ fifo_rdata_ly[5]);

  assign parity_err_cfeb[5:0] =  ~(parity_rd ~^ parity_expect);  // ~^ is bitwise equivalence operator

// Multiplex Raw Hits FIFO RAM output data
  assign fifo_rdata = fifo_rdata_ly[fifo_sel];

//-------------------------------------------------------------------------------------------------------------------
// Stage 3:  Triad Decoder
//      Decodes Triads into DiStrips, Strips, 1/2-Strips.
//      Digital One-shots stretch 1/2-Strip pulses for pattern finding.
//      Hot channel mask applied to Triad DiStrips after storage, but before Triad decoder
//-------------------------------------------------------------------------------------------------------------------
// Local buffer Triad Decoder controls
  reg      persist1 = 0;
  reg  [3:0]  persist  = 0;

  always @(posedge clock) begin
     persist  <=   triad_persist-1'b1;
     persist1 <=  (triad_persist==1 || triad_persist==0);
  end

// Instantiate mxly*mxds = 48 triad decoders
  wire [MXDS-1:0] tskip [MXLY-1:0];  // Skipped triads
  wire [MXHS-1:0] hs    [MXLY-1:0];  // Decoded 1/2-strip pulses

  generate
     for (ily=0; ily<=MXLY-1; ily=ily+1) begin: ily_loop
	for (ids=0; ids<=MXDS-1; ids=ids+1) begin: ids_loop
	   triad_decode utriad(clock,treset,persist,persist1,triad_s2[ily][ids],hs[ily][3+ids*4:ids*4],tskip[ily][ids]);
	end
     end
  endgenerate

  assign triad_skip = (|tskip[0]) | (|tskip[1]) | (|tskip[2]) | (|tskip[3]) | (|tskip[4]) | (|tskip[5]);

// Expand 2d arrays for transmission to next module
  assign ly0hs = hs[0];
  assign ly1hs = hs[1];
  assign ly2hs = hs[2];
  assign ly3hs = hs[3];
  assign ly4hs = hs[4];
  assign ly5hs = hs[5];

// Unused signals
  assign cfeb_sump = | dopa;

//------------------------------------------------------------------------------------------------------------------
// Debug
//------------------------------------------------------------------------------------------------------------------
`ifdef DEBUG_CFEB
// Injector State Machine ASCII display
  reg[71:0] inj_sm_dsp;
  always @* begin
     case (inj_sm)
       pass:    inj_sm_dsp <= "pass     ";
       injecting:  inj_sm_dsp <= "injecting";
       default    inj_sm_dsp <= "pass     ";
     endcase
  end

// Raw hits RAM outputs
  assign fifo_rdata_lyr0 = fifo_rdata_ly[0];
  assign fifo_rdata_lyr1 = fifo_rdata_ly[1];
  assign fifo_rdata_lyr2 = fifo_rdata_ly[2];
  assign fifo_rdata_lyr3 = fifo_rdata_ly[3];
  assign fifo_rdata_lyr4 = fifo_rdata_ly[4];
  assign fifo_rdata_lyr5 = fifo_rdata_ly[5];
`endif

//------------------------------------------------------------------------------------------------------------------
  endmodule
//------------------------------------------------------------------------------------------------------------------
