`timescale 1ns / 1p

//module for HMT
//first delay hmt to aligned with CLCT, then do HMT+ALCT match
  module hmt
  (
  clock,
  ttc_resync,
  global_reset, 

  fmm_trig_stop,
  bx0_vpf_test,
  
  nhit_cfeb0,
  nhit_cfeb1,
  nhit_cfeb2,
  nhit_cfeb3,
  nhit_cfeb4,
  nhit_cfeb5,
  nhit_cfeb6,

  layers_withhits_cfeb0,
  layers_withhits_cfeb1,
  layers_withhits_cfeb2,
  layers_withhits_cfeb3,
  layers_withhits_cfeb4,
  layers_withhits_cfeb5,
  layers_withhits_cfeb6,
  
  hmt_enable,
  hmt_me1a_enable,
  hmt_thresh1,
  hmt_thresh2,
  hmt_thresh3,
  hmt_aff_thresh,
  
  hmt_delay,
  hmt_alct_win_size,
  hmt_match_win,
  
  wr_adr_xpre_hmt, 
  wr_push_xpre_hmt,
  wr_avail_xpre_hmt, 
  
  wr_adr_xpre_hmt_pipe, 
  wr_push_mux_hmt,
  wr_avail_xpre_hmt_pipe, 
  
  alct_vpf_pipe,
  hmt_anode,

  clct_pretrig,
  clct_vpf_pipe,
  
  cfeb_allow_hmt_ro,
  hmt_allow_cathode,
  hmt_allow_anode,
  hmt_allow_match,
  hmt_allow_cathode_ro,
  hmt_allow_anode_ro,
  hmt_allow_match_ro,
  hmt_outtime_check  ,

  hmt_fired_pretrig,//preCLCT bx
  hmt_active_feb,
  hmt_pretrig_match,
  hmt_fired_xtmb,//CLCT bx
  hmt_wr_avail_xtmb,
  hmt_wr_adr_xtmb,

  hmt_nhits_bx7,//tmb match bx cathode hmt
  hmt_nhits_sig,
  hmt_nhits_bkg,
  hmt_cathode_pipe, // tmb match bx

  //hmt_cathode_fired     , 
  //hmt_anode_fired       , 
  hmt_anode_alct_match  ,
  hmt_cathode_alct_match, 
  hmt_cathode_clct_match, 
  hmt_cathode_lct_match ,
 
  hmt_fired_cathode_only,
  hmt_fired_anode_only,
  hmt_fired_match,
  hmt_fired_or,
  
  hmt_trigger_tmb,// results aligned with ALCT vpf latched for ALCT-CLCT match
  hmt_trigger_tmb_ro,// results aligned with ALCT vpf latched for ALCT-CLCT match
  
  hmt_sump
);
   parameter RAM_ADRB     = 11;        // Address width=log2(ram_depth)
   parameter MXBADR       = RAM_ADRB;  // Header buffer data address bits 

   parameter MXHMTB     =  4;// bits for HMT
   parameter MXCFEB     =  7;
   parameter NHITCFEBB  =  6;
   parameter NHMTHITB   = 10;
	parameter MXLY       =  6;

   `include "../otmb_virtex6_fw_version.v"

  input  clock;
  input  ttc_resync;
  input  global_reset; 

  input  fmm_trig_stop;
  input  bx0_vpf_test;
  
  input  [NHITCFEBB-1: 0] nhit_cfeb0;
  input  [NHITCFEBB-1: 0] nhit_cfeb1;
  input  [NHITCFEBB-1: 0] nhit_cfeb2;
  input  [NHITCFEBB-1: 0] nhit_cfeb3;
  input  [NHITCFEBB-1: 0] nhit_cfeb4;
  input  [NHITCFEBB-1: 0] nhit_cfeb5;
  input  [NHITCFEBB-1: 0] nhit_cfeb6;

  input  [MXLY-1:0]   layers_withhits_cfeb0;
  input  [MXLY-1:0]   layers_withhits_cfeb1;
  input  [MXLY-1:0]   layers_withhits_cfeb2;
  input  [MXLY-1:0]   layers_withhits_cfeb3;
  input  [MXLY-1:0]   layers_withhits_cfeb4;
  input  [MXLY-1:0]   layers_withhits_cfeb5;
  input  [MXLY-1:0]   layers_withhits_cfeb6;
  
  input    hmt_enable;
  input    hmt_me1a_enable;
  input  [7:0] hmt_thresh1;
  input  [7:0] hmt_thresh2;
  input  [7:0] hmt_thresh3;
  input  [6:0] hmt_aff_thresh;
  
  input  [3:0]  hmt_delay;
  input  [3:0]  hmt_alct_win_size;
  output [3:0]  hmt_match_win;

  input [MXBADR-1:0] wr_adr_xpre_hmt;
  input              wr_push_xpre_hmt;
  input              wr_avail_xpre_hmt; 
  
  output [MXBADR-1:0] wr_adr_xpre_hmt_pipe;
  output              wr_push_mux_hmt;
  output              wr_avail_xpre_hmt_pipe; 
  
  input  alct_vpf_pipe;
  input [MXHMTB-1:0] hmt_anode;

  input  clct_pretrig;
  input  clct_vpf_pipe;

  input cfeb_allow_hmt_ro;
  input hmt_allow_cathode;
  input hmt_allow_anode;
  input hmt_allow_match;
  input hmt_allow_cathode_ro;
  input hmt_allow_anode_ro;
  input hmt_allow_match_ro;
  input hmt_outtime_check ;
  
  output  hmt_fired_pretrig;//preCLCT bx
  output [MXCFEB-1  :0]   hmt_active_feb;
  output  hmt_pretrig_match;

  output  hmt_fired_xtmb;//CLCT bx
  output  hmt_wr_avail_xtmb;//CLCT bx
  output  [MXBADR-1:0] hmt_wr_adr_xtmb;
  //output [MXHMTB-1:0]     hmt_cathode_xtmb; //CLCT bx

  output [NHMTHITB-1:0]   hmt_nhits_bx7;//CLCT bx
  output [NHMTHITB-1:0]   hmt_nhits_sig;
  output [NHMTHITB-1:0]   hmt_nhits_bkg;
  output [MXHMTB-1:0]     hmt_cathode_pipe; // tmb match bx

  wire hmt_cathode_fired     ; 
  wire hmt_anode_fired       ; 
  output hmt_anode_alct_match  ;
  output hmt_cathode_alct_match; 
  output hmt_cathode_clct_match; 
  output hmt_cathode_lct_match ;
  
  output hmt_fired_cathode_only;
  output hmt_fired_anode_only;
  output hmt_fired_match;
  output hmt_fired_or;

  output [MXHMTB-1:0] hmt_trigger_tmb;// results aligned with ALCT vpf
  output [MXHMTB-1:0] hmt_trigger_tmb_ro;// results aligned with ALCT vpf
  output hmt_sump;

  assign hmt_anode_fired        = (|hmt_anode[1:0]) && (!hmt_outtime_check || (~|hmt_anode[3:2]));

  wire [3:0]  pdly = 1;      // Power-up reset delay
  wire powerup_q;
  reg   powerup_ff  = 0;

  SRL16E upowerup (.CLK(clock),.CE(~powerup_q),.D(1'b1),.A0(pdly[0]),.A1(pdly[1]),.A2(pdly[2]),.A3(pdly[3]),.Q(powerup_q));

  always @(posedge clock) begin
  powerup_ff <= powerup_q;
  end

  wire powerup_n = ~powerup_ff;  // shifts timing from LUT to FF
  wire reset_sr  = ttc_resync | powerup_n;

  reg [1:0] hmt_reset_ff = 2'b00;
  always @(posedge clock) begin
    hmt_reset_ff[0] <= (global_reset || ttc_resync);
    hmt_reset_ff[1] <= hmt_reset_ff[0] || fmm_trig_stop;
  end
  wire hmt_reset = |hmt_reset_ff;

  wire [MXLY-1:0]   layers_withhits_me1a = layers_withhits_cfeb4 | layers_withhits_cfeb5 | layers_withhits_cfeb6;
  wire [MXLY-1:0]   layers_withhits_me1b = layers_withhits_cfeb0 | layers_withhits_cfeb1 | layers_withhits_cfeb2 | layers_withhits_cfeb3;
  wire [MXLY-1:0]   layers_withhits  =  hmt_me1a_enable ? (layers_withhits_me1a | layers_withhits_me1b) : layers_withhits_me1b;

  wire [2:0] nlayer_withhits = countnlayer(layers_withhits);

  wire [MXCFEB-1  :0]  active_cfeb_s0; 
//`ifdef CSC_TYPE_C
//  initial $display ("CSC_TYPE_C instantiated in HMT module");
//  //normal ME1b
//  assign active_cfeb_s0[0] = nhit_cfeb0 >= hmt_aff_thresh;
//  assign active_cfeb_s0[1] = nhit_cfeb1 >= hmt_aff_thresh;
//  assign active_cfeb_s0[2] = nhit_cfeb2 >= hmt_aff_thresh;
//  assign active_cfeb_s0[3] = nhit_cfeb3 >= hmt_aff_thresh;
//  //reversed ME1a
//  assign active_cfeb_s0[4] = nhit_cfeb6 >= hmt_aff_thresh;
//  assign active_cfeb_s0[5] = nhit_cfeb5 >= hmt_aff_thresh;
//  assign active_cfeb_s0[6] = nhit_cfeb4 >= hmt_aff_thresh;
//`ifdef CSC_TYPE_D
//  initial $display ("CSC_TYPE_D instantiated in HMT module");
//  //reversed ME1b
//  assign active_cfeb_s0[0] = nhit_cfeb3 >= hmt_aff_thresh;
//  assign active_cfeb_s0[1] = nhit_cfeb2 >= hmt_aff_thresh;
//  assign active_cfeb_s0[2] = nhit_cfeb1 >= hmt_aff_thresh;
//  assign active_cfeb_s0[3] = nhit_cfeb0 >= hmt_aff_thresh;
//  //normal ME1a
//  assign active_cfeb_s0[4] = nhit_cfeb4 >= hmt_aff_thresh;
//  assign active_cfeb_s0[5] = nhit_cfeb5 >= hmt_aff_thresh;
//  assign active_cfeb_s0[6] = nhit_cfeb6 >= hmt_aff_thresh;
//`else
//  initial $display ("CSC_TYPE Undefined. Halting from HMT module.");
//  $finish
//`endif
  reg  [NHITCFEBB-1: 0] nhit_cfeb0_s0 [3:0];
  reg  [NHITCFEBB-1: 0] nhit_cfeb1_s0 [3:0];
  reg  [NHITCFEBB-1: 0] nhit_cfeb2_s0 [3:0];
  reg  [NHITCFEBB-1: 0] nhit_cfeb3_s0 [3:0];
  reg  [NHITCFEBB-1: 0] nhit_cfeb4_s0 [3:0];
  reg  [NHITCFEBB-1: 0] nhit_cfeb5_s0 [3:0];
  reg  [NHITCFEBB-1: 0] nhit_cfeb6_s0 [3:0];
  always @(posedge clock) begin
      nhit_cfeb0_s0[0] <= nhit_cfeb0;
      nhit_cfeb1_s0[0] <= nhit_cfeb1;
      nhit_cfeb2_s0[0] <= nhit_cfeb2;
      nhit_cfeb3_s0[0] <= nhit_cfeb3;
      nhit_cfeb4_s0[0] <= nhit_cfeb4;
      nhit_cfeb5_s0[0] <= nhit_cfeb5;
      nhit_cfeb6_s0[0] <= nhit_cfeb6;

      nhit_cfeb0_s0[1] <= nhit_cfeb0_s0[0];
      nhit_cfeb1_s0[1] <= nhit_cfeb1_s0[0];
      nhit_cfeb2_s0[1] <= nhit_cfeb2_s0[0];
      nhit_cfeb3_s0[1] <= nhit_cfeb3_s0[0];
      nhit_cfeb4_s0[1] <= nhit_cfeb4_s0[0];
      nhit_cfeb5_s0[1] <= nhit_cfeb5_s0[0];
      nhit_cfeb6_s0[1] <= nhit_cfeb6_s0[0];

      nhit_cfeb0_s0[2] <= nhit_cfeb0_s0[1];
      nhit_cfeb1_s0[2] <= nhit_cfeb1_s0[1];
      nhit_cfeb2_s0[2] <= nhit_cfeb2_s0[1];
      nhit_cfeb3_s0[2] <= nhit_cfeb3_s0[1];
      nhit_cfeb4_s0[2] <= nhit_cfeb4_s0[1];
      nhit_cfeb5_s0[2] <= nhit_cfeb5_s0[1];
      nhit_cfeb6_s0[2] <= nhit_cfeb6_s0[1];

      nhit_cfeb0_s0[3] <= nhit_cfeb0_s0[2];
      nhit_cfeb1_s0[3] <= nhit_cfeb1_s0[2];
      nhit_cfeb2_s0[3] <= nhit_cfeb2_s0[2];
      nhit_cfeb3_s0[3] <= nhit_cfeb3_s0[2];
      nhit_cfeb4_s0[3] <= nhit_cfeb4_s0[2];
      nhit_cfeb5_s0[3] <= nhit_cfeb5_s0[2];
      nhit_cfeb6_s0[3] <= nhit_cfeb6_s0[2];
  end
`ifdef CSC_TYPE_C
  initial $display ("CSC_TYPE_C instantiated in HMT module");
  //normal ME1b
  assign active_cfeb_s0[0] = (nhit_cfeb0_s0[1] + nhit_cfeb0_s0[2] + nhit_cfeb0_s0[3]) >= hmt_aff_thresh;
  assign active_cfeb_s0[1] = (nhit_cfeb1_s0[1] + nhit_cfeb1_s0[2] + nhit_cfeb1_s0[3]) >= hmt_aff_thresh;
  assign active_cfeb_s0[2] = (nhit_cfeb2_s0[1] + nhit_cfeb2_s0[2] + nhit_cfeb2_s0[3]) >= hmt_aff_thresh;
  assign active_cfeb_s0[3] = (nhit_cfeb3_s0[1] + nhit_cfeb3_s0[2] + nhit_cfeb3_s0[3]) >= hmt_aff_thresh;
  //reversed ME1a
  assign active_cfeb_s0[4] = (nhit_cfeb6_s0[1] + nhit_cfeb6_s0[2] + nhit_cfeb6_s0[3]) >= hmt_aff_thresh;
  assign active_cfeb_s0[5] = (nhit_cfeb5_s0[1] + nhit_cfeb5_s0[2] + nhit_cfeb5_s0[3]) >= hmt_aff_thresh;
  assign active_cfeb_s0[6] = (nhit_cfeb4_s0[1] + nhit_cfeb4_s0[2] + nhit_cfeb4_s0[3]) >= hmt_aff_thresh;
`elsif CSC_TYPE_D
  initial $display ("CSC_TYPE_D instantiated in HMT module");
  //reversed ME1b
  assign active_cfeb_s0[0] = (nhit_cfeb3_s0[1] + nhit_cfeb3_s0[2] + nhit_cfeb3_s0[3]) >= hmt_aff_thresh;
  assign active_cfeb_s0[1] = (nhit_cfeb2_s0[1] + nhit_cfeb2_s0[2] + nhit_cfeb2_s0[3]) >= hmt_aff_thresh;
  assign active_cfeb_s0[2] = (nhit_cfeb1_s0[1] + nhit_cfeb1_s0[2] + nhit_cfeb1_s0[3]) >= hmt_aff_thresh;
  assign active_cfeb_s0[3] = (nhit_cfeb0_s0[1] + nhit_cfeb0_s0[2] + nhit_cfeb0_s0[3]) >= hmt_aff_thresh;
  //normal ME1a
  assign active_cfeb_s0[4] = (nhit_cfeb4_s0[1] + nhit_cfeb4_s0[2] + nhit_cfeb4_s0[3]) >= hmt_aff_thresh;
  assign active_cfeb_s0[5] = (nhit_cfeb5_s0[1] + nhit_cfeb5_s0[2] + nhit_cfeb5_s0[3]) >= hmt_aff_thresh;
  assign active_cfeb_s0[6] = (nhit_cfeb6_s0[1] + nhit_cfeb6_s0[2] + nhit_cfeb6_s0[3]) >= hmt_aff_thresh;
`else
  initial $display ("CSC_TYPE Undefined. Halting. from HMT module");
  $finish
`endif

  wire [NHMTHITB-1:0] nhits_chamber = hmt_me1a_enable ? (nhit_cfeb0 + nhit_cfeb1 + nhit_cfeb2 + nhit_cfeb3 + nhit_cfeb4 + nhit_cfeb5 + nhit_cfeb6) : (nhit_cfeb0 + nhit_cfeb1 + nhit_cfeb2 + nhit_cfeb3);
  reg  [NHMTHITB-1:0] nhits_trig_s0_srl [7:0];//array 8x10bits

  reg  [2:0] nlayer_s0 [7:0];
  reg  [2:0] hmt_nhit_thresh = 3'd5;
  always @(posedge clock) begin
      nhits_trig_s0_srl[7] <= nhits_trig_s0_srl[6];
      nhits_trig_s0_srl[6] <= nhits_trig_s0_srl[5];
      nhits_trig_s0_srl[5] <= nhits_trig_s0_srl[4];
      nhits_trig_s0_srl[4] <= nhits_trig_s0_srl[3];
      nhits_trig_s0_srl[3] <= nhits_trig_s0_srl[2];
      nhits_trig_s0_srl[2] <= nhits_trig_s0_srl[1];
      nhits_trig_s0_srl[1] <= nhits_trig_s0_srl[0];
      nhits_trig_s0_srl[0] <= nhits_chamber;

      nlayer_s0[0]     <= nlayer_withhits;
      nlayer_s0[1]     <= nlayer_s0[0];
      nlayer_s0[2]     <= nlayer_s0[1];
      nlayer_s0[3]     <= nlayer_s0[2];
      nlayer_s0[4]     <= nlayer_s0[3];
      nlayer_s0[5]     <= nlayer_s0[4];
      nlayer_s0[6]     <= nlayer_s0[5];
      nlayer_s0[7]     <= nlayer_s0[6];
  end

  //signal: over 3BX;   control region: over 4BX 

  wire [NHMTHITB-1:0] nhits_trig_s0_bx7 = nhits_trig_s0_srl[2];//center one
  wire [NHMTHITB-1:0] nhits_trig_s0_sig = nhits_trig_s0_srl[3] + nhits_trig_s0_srl[2] + nhits_trig_s0_srl[1];
  //wire [NHMTHITB-1:0] nhits_trig_s0_bkg = nhits_trig_s0_srl[7] + nhits_trig_s0_srl[6] + nhits_trig_s0_srl[5] + nhits_trig_s0_srl[4];
  wire [NHMTHITB-1:0] nhits_trig_s0_bkg = nhits_trig_s0_srl[6] + nhits_trig_s0_srl[5] + nhits_trig_s0_srl[4];
  //peak conditio: nhits_trig_s0_sig >= nhits_trig_s0_bx789 && nhits_trig_s0_sig >= nhits_trig_s0_bx89A
  wire nhits_compare_s0_sig_789 = (nhits_trig_s0_srl[3] > nhits_trig_s0_srl[0]) || (nhits_trig_s0_srl[3] == nhits_trig_s0_srl[0] &&  nhits_trig_s0_srl[2]> nhits_trig_s0_srl[1]);
  wire nhits_compare_s0_sig_89A = (nhits_trig_s0_srl[3] + nhits_trig_s0_srl[2] >  nhits_trig_s0_srl[0] + nhits_chamber) || (nhits_trig_s0_srl[3] + nhits_trig_s0_srl[2] ==  nhits_trig_s0_srl[0] + nhits_chamber && nhits_trig_s0_srl[2] > nhits_trig_s0_srl[0]);
  wire nhits_trig_s0_sig_peak = nhits_compare_s0_sig_789 && nhits_compare_s0_sig_89A;

  //requirement of num of layers with hit is only in the central BX
  wire nlayer_pass_thresh_sig = nlayer_s0[2] >= hmt_nhit_thresh;
  wire nlayer_pass_thresh_bkg = nlayer_s0[5] >= hmt_nhit_thresh;
  //wire nlayer_pass_thresh_sig = nlayer_s0[3] >= hmt_nhit_thresh || nlayer_s0[2] >= hmt_nhit_thresh || nlayer_s0[1] >= hmt_nhit_thresh;
  //wire nlayer_pass_thresh_bkg = nlayer_s0[6] >= hmt_nhit_thresh || nlayer_s0[5] >= hmt_nhit_thresh || nlayer_s0[4] >= hmt_nhit_thresh;

 // wire hmt_bit0_s0 = ((nhits_trig_s0_sig >= hmt_thresh1) || (nhits_trig_s0_sig >= hmt_thresh3)) & nhits_trig_s0_sig_peak &  (~|hmt_fired_s0_ff) & (~hmt_reset) & nlayer_pass_thresh_sig;
 // wire hmt_bit1_s0 = ((nhits_trig_s0_sig >= hmt_thresh2) || (nhits_trig_s0_sig >= hmt_thresh3)) & nhits_trig_s0_sig_peak &  (~|hmt_fired_s0_ff) & (~hmt_reset) & nlayer_pass_thresh_sig;
 // wire hmt_bit2_s0 = ((nhits_trig_s0_bkg >= hmt_thresh1) || (nhits_trig_s0_bkg >= hmt_thresh3)) &  (~|hmt_fired_s0_ff) & (~hmt_reset) & nlayer_pass_thresh_bkg;
 // wire hmt_bit3_s0 = ((nhits_trig_s0_bkg >= hmt_thresh2) || (nhits_trig_s0_bkg >= hmt_thresh3)) &  (~|hmt_fired_s0_ff) & (~hmt_reset) & nlayer_pass_thresh_bkg;
 // wire [MXHMTB-1:0] hmt_cathode_s0 = hmt_enable ? {hmt_bit3_s0, hmt_bit2_s0, hmt_bit1_s0, hmt_bit0_s0} : 4'b0;
  wire [1:0] hmt_intime_s0  = nhits_trig_s0_sig >= hmt_thresh3 ? 2'b11 : (nhits_trig_s0_sig >= hmt_thresh2 ? 2'b10 : {1'b0, nhits_trig_s0_sig >= hmt_thresh1});
  wire [1:0] hmt_outtime_s0 = nhits_trig_s0_bkg >= hmt_thresh3 ? 2'b11 : (nhits_trig_s0_bkg >= hmt_thresh2 ? 2'b10 : {1'b0, nhits_trig_s0_bkg >= hmt_thresh1});
  wire hmt_intime_good  = (~|hmt_fired_s0_ff) & (~hmt_reset) & nlayer_pass_thresh_sig;
  wire hmt_outtime_good = (~|hmt_fired_s0_ff) & (~hmt_reset) & nlayer_pass_thresh_bkg;
  wire [MXHMTB-1:0] hmt_cathode_s0 = hmt_enable ? { hmt_outtime_s0 & {2{hmt_outtime_good}}, hmt_intime_s0 & {2{hmt_intime_good}}} : 4'b0 ;

  wire   hmt_fired_bkg_s0 = |hmt_cathode_s0[3:2];
  wire   hmt_fired_sig_s0 = |hmt_cathode_s0[1:0];
  wire   hmt_fired_s0 = hmt_fired_sig_s0 && (!hmt_outtime_check || !hmt_fired_bkg_s0);

  reg [1:0] hmt_fired_s0_ff = 2'b00;//dead time for 2BX 
  always @(posedge clock) begin
      hmt_fired_s0_ff[0] <= hmt_fired_s0;
      hmt_fired_s0_ff[1] <= hmt_fired_s0_ff[0];
  end

//------------------------------------------------------------------------------------------------------------------
//  Delay HMT to pretrigger
//------------------------------------------------------------------------------------------------------------------
  //hits to build CLCT is counted at nhits_trig_s0_srl[7], with CLCT_drift delay=2BX
  //preCLCT to CLCT: 5BX with CLCT_drift delay=2BX. so hmt to pretrigger:=1BX
  //parameter hmt_dly_const = 4'd6; //delay HMT trigger to CLCT VPF BX
  //parameter hmt_dly_const = 4'd1; //delay HMT trigger to preCLCT BX, old setting
  parameter hmt_dly_const = 4'd0; //delay HMT trigger to preCLCT BX. nhits_trig_s0_srl[2] is synchronized with pretrigger
  //wire [3:0] delay_hmt_aff_adr = hmt_dly_const + 4'd2;// equivalent 4'd3-4'd1

  wire [MXCFEB-1  :0]  active_cfeb_s1_srl; 
  srl16e_bbl #(1)       uhmtfiredpre  ( .clock(clock), .ce(1'b1), .adr(hmt_dly_const-4'd1), .d(hmt_fired_s0),   .q(hmt_fired_s1_srl));
  srl16e_bbl #(MXCFEB)  uhmtaffpre    ( .clock(clock), .ce(1'b1), .adr(hmt_dly_const-4'd1), .d(active_cfeb_s0), .q(active_cfeb_s1_srl));

  wire hmt_fired_s1 = (hmt_dly_const == 4'd0) ? hmt_fired_s0 : hmt_fired_s1_srl;
  wire [MXCFEB-1  :0]  active_cfeb_s1 = (hmt_dly_const == 4'd0) ? active_cfeb_s0 : active_cfeb_s1_srl;
  assign hmt_fired_pretrig = hmt_fired_s1;
  assign hmt_active_feb    = active_cfeb_s1 & {MXCFEB{cfeb_allow_hmt_ro & hmt_fired_s1}};

  assign hmt_pretrig_match = hmt_fired_s1 && clct_pretrig;

//------------------------------------------------------------------------------------------------------------------
//  Delay HMT to post-drift 
//------------------------------------------------------------------------------------------------------------------

  reg [3:0] hmt_postdrift_delay = 4'b0;
  always @(posedge clock) begin
      hmt_postdrift_delay = hmt_dly_const + hmt_delay;
  end

  wire [MXHMTB-1  :0] hmt_cathode_dly;
  wire wr_avail_xtmb_hmt_dly;
  wire [MXBADR-1:0] wr_adr_xtmb_hmt_dly;
  srl16e_bbl #(MXHMTB)      udhmttrig      ( .clock(clock), .ce(1'b1), .adr(hmt_postdrift_delay-4'd1), .d(hmt_cathode_s0    ), .q(hmt_cathode_dly      ));
  srl16e_bbl #(1)           udhmtavailxtmb ( .clock(clock), .ce(1'b1), .adr(hmt_delay-4'd1),           .d(wr_avail_xpre_hmt ), .q(wr_avail_xtmb_hmt_dly));
  srl16e_bbl #(MXBADR)      udhmtadrxtmb   ( .clock(clock), .ce(1'b1), .adr(hmt_delay-4'd1),           .d(wr_adr_xpre_hmt   ), .q(wr_adr_xtmb_hmt_dly  ));

  wire [MXHMTB-1  :0] hmt_cathode_xtmb      = (hmt_postdrift_delay == 4'd0) ? hmt_cathode_s0            : hmt_cathode_dly;
  assign hmt_wr_avail_xtmb  = (hmt_delay  == 4'd0) ? wr_avail_xpre_hmt : wr_avail_xtmb_hmt_dly;
  assign hmt_wr_adr_xtmb    = (hmt_delay  == 4'd0) ? wr_adr_xpre_hmt   : wr_adr_xtmb_hmt_dly;
  assign hmt_fired_xtmb = (|hmt_cathode_xtmb[1:0]) && (!hmt_outtime_check || (~|hmt_cathode_xtmb[3:2]));

//------------------------------------------------------------------------------------------------------------------
//  HMT-ALCT match
// What to do for CLCT*copad match
//------------------------------------------------------------------------------------------------------------------
// FF buffer hmt_window index for fanout, points to 1st position window is closed 
  reg [3:0] winclosing=0;
  reg [3:0] hmt_window = 0;

  always @(posedge clock) begin
  winclosing <= hmt_alct_win_size-1'b1;
  hmt_window <= hmt_alct_win_size;
  end

  wire dynamic_zero = bx0_vpf_test;      // Dynamic zero to mollify xst for certain FF inits

// Decode CLCT window width setting to select which hmt_sr stages to include in hmt_window
  reg [15:0] hmt_sr_include=0;
  integer i;

  always @(posedge clock) begin
  if (powerup_n) begin            // Sych reset on resync or not power up
  hmt_sr_include  <= {16{dynamic_zero}};    // Power up bit 15 to mollify xst compiler warning about [15] constant 0
  end

  else begin
  i=0;
  while (i<=15) begin
  if (hmt_window!=0)
  hmt_sr_include[i] <= (i<=hmt_window-1);  // hmt_window=3, enables sr stages 0,1,2
  else
  hmt_sr_include[i] <= 0;          // hmt_window=0, disables all sr stages
  i=i+1;
  end
  end
  end

// Calculate dynamic hmt window center and positional priorities
  reg  [3:0] hmt_win_priority [15:0];
  wire [3:0] hmt_win_center = hmt_window/2;  // Gives priority to higher winbx for even widths

  always @(posedge clock) begin
  i=0;
  while (i<=15) begin
  if    (ttc_resync            )   hmt_win_priority[i] <= 4'hF;
  else if (i>=hmt_window || i==0)  hmt_win_priority[i] <= 0;                          // i >  lastwin or i=0
  else if (i<=hmt_win_center    )  hmt_win_priority[i] <= hmt_window-4'd1-((hmt_win_center-i[3:0]) << 1);  // i <= center
  else                             hmt_win_priority[i] <= hmt_window-4'd0-((i[3:0]-hmt_win_center) << 1);  // i >  center
  i=i+1;
  end
  end

//------------------------------------------------------------------------------------------------------------------
// ALCT*HMT Matching Section
// Push CLCT vpf into a 16-stage FF shift register for ALCT matching
  reg  [15:1] hmt_vpf_sre=0;        // CLCT valid pattern flag 
  wire [15:0] hmt_vpf_sr;        // Extend CLCT vpf shift register 1bx earlier in time to minimize latency

  assign hmt_vpf_sr[0]    = hmt_fired_xtmb;// Extend CLCT vpf shift register 1bx earlier in time
  assign hmt_vpf_sr[15:1] = hmt_vpf_sre[15:1];

  always @(posedge clock) begin      // Load stage 0 with incoming CLCT
  hmt_vpf_sre[1]    <= hmt_vpf_sr[0];  // Vpf=1 for pattern triggers, may be =0 for external triggers, so use push flag
  i=1;                  // Loop over window positions 1 to 14, 15th is shifted into and 0th is non-ff
  while (i<=14) begin            // Parallel shift all data left
  hmt_vpf_sre[i+1]  <= hmt_vpf_sre[i];
  i=i+1;
  end  // close while
  end  // close clock

// CLCT allocation tag shift register
  reg [15:0]  hmt_tag_sr=0;        // CLCT allocated tag
  wire    hmt_tag_me;        // Tag pulse
  wire [3:0]  hmt_tag_win;        // SR stage to insert tag

  always @(posedge clock) begin
  if (reset_sr) begin            // Sych reset on resync or not power up
  hmt_tag_sr  <= dynamic_zero;      // Load a dynamic 0 on reset, mollify xst
  end

  i=0;                  // Loop over 15 window positions 0 to 14 
  while (i<=14) begin
  if (hmt_tag_me==1 && hmt_tag_win==i && hmt_sr_include[i]) hmt_tag_sr[i+1] <= 1;
  else                  // Otherwise parallel shift all data left
  hmt_tag_sr[i+1] <= hmt_tag_sr[i];
  i=i+1;
  end  // close while
  end  // close clock

// Find highest priority window position that has a non-tagged hmt
  wire [15:0] win_ena;          // Table of enabled window positions
  wire [3:0]  win_pri [15:0];        // Table of window position priorities that are enabled

  genvar j;                // Table window priorities multipled by windwo position enables
  generate
  for (j=0; j<=15; j=j+1) begin: genpri
  assign win_ena[j] = (hmt_sr_include[j]==1 && hmt_vpf_sr[j]==1 && hmt_tag_sr[j]==0);
  assign win_pri[j] = (hmt_win_priority[j] * win_ena[j]);
  end
  endgenerate

  wire [3:0] hmt_win_best;
  wire [3:0] hmt_pri_best;

  tree_encoder utree_encoder_hmt(
      .win_pri_0    (win_pri[ 0]),
      .win_pri_1    (win_pri[ 1]),
      .win_pri_2    (win_pri[ 2]),
      .win_pri_3    (win_pri[ 3]),
      .win_pri_4    (win_pri[ 4]),
      .win_pri_5    (win_pri[ 5]),
      .win_pri_6    (win_pri[ 6]),
      .win_pri_7    (win_pri[ 7]),
      .win_pri_8    (win_pri[ 8]),
      .win_pri_9    (win_pri[ 9]),
      .win_pri_10   (win_pri[10]),
      .win_pri_11   (win_pri[11]),
      .win_pri_12   (win_pri[12]),
      .win_pri_13   (win_pri[13]),
      .win_pri_14   (win_pri[14]),
      .win_pri_15   (win_pri[15]),

      .win_best     (hmt_win_best),
      .pri_best     (hmt_pri_best)
        );
// HMT window width is generated by a pulse propagating down the enabled hmt_sr stages  
  wire hmt_window_open    = |(hmt_vpf_sr & hmt_sr_include);
  wire hmt_window_hastrig = |(hmt_vpf_sr & hmt_sr_include & ~hmt_tag_sr);

// HMT window closes on next bx, check for un-tagged hmt in last bx
  wire   hmt_last_vpf = hmt_vpf_sr[winclosing];        // CLCT token reaches last window position 1bx before tag
  wire   hmt_last_tag = hmt_tag_sr[winclosing];        // Push this event into MPC queue as it reaches last window bx

// HMT matched or alct-only
  wire anode_pulse        = alct_vpf_pipe || hmt_anode_fired;              // ALCT vpf
  wire anode_nocathodehmt = anode_pulse   && !hmt_window_hastrig;  // ALCT arrived, but there was no CLCT window open
  wire hmt_match          = anode_pulse   &&  hmt_window_hastrig;  // ALCT matches CLCT window, push to mpc on current bx

  wire hmt_last_win     = hmt_last_vpf && !hmt_last_tag;  // CLCT reached end of window
  wire hmt_noanode      = hmt_last_win && !anode_pulse;    // No ALCT arrived in window, pushed mpc on last bx
  wire hmt_noanode_lost = hmt_last_win &&  anode_pulse && hmt_win_best!=winclosing;// No ALCT arrived in window, lost to mpc contention

  //Anode * cathode HMT
  assign hmt_tag_me  = hmt_match;    // Tag the matching hmt
  assign hmt_tag_win = hmt_win_best;   // But get the one with highest priority

// Event trigger disposition

  wire hmt_cathode_kept    =  (hmt_match) || (hmt_noanode && !hmt_noanode_lost && ( hmt_allow_cathode|| hmt_allow_cathode_ro));

// Match window mux
  wire [3:0] match_win;
  wire [3:0] match_win_mux;

  assign match_win_mux = (hmt_noanode     ) ? winclosing    : hmt_tag_win;          // if hmt only, disregard priority and take last window position 
  assign hmt_match_win = (hmt_cathode_kept) ? match_win_mux : hmt_win_center;          // Default window position for alct-only events


  // Pointer to SRL delayed HMT signals
  wire [3:0] hmt_srl_ptr   = hmt_match_win;
  wire hmt_ptr_is_0 = hmt_srl_ptr == 4'b0;
  wire [3:0]  hmt_srl_adr = hmt_srl_ptr-1'b1;
  wire [MXHMTB-1    :0] hmt_cathode_srl;
  srl16e_bbl #(MXHMTB   ) uhmt        (.clock(clock),.ce(1'b1),.adr(hmt_srl_adr),.d(hmt_cathode_xtmb),.q(hmt_cathode_srl));
  wire [MXHMTB-1    :0] hmt_cathode_s3   = (hmt_ptr_is_0) ? hmt_cathode_xtmb : hmt_cathode_srl;
  assign hmt_cathode_pipe = hmt_cathode_s3 & {MXHMTB{hmt_cathode_kept}};

  assign hmt_cathode_fired      = (|hmt_cathode_pipe[1:0]) && (!hmt_outtime_check || (~|hmt_cathode_pipe[3:2]));

  assign hmt_anode_alct_match   = hmt_anode_fired   && alct_vpf_pipe;
  assign hmt_cathode_alct_match = hmt_cathode_fired && alct_vpf_pipe;
  assign hmt_cathode_clct_match = hmt_cathode_fired && clct_vpf_pipe;
  assign hmt_cathode_lct_match  = hmt_cathode_fired && alct_vpf_pipe && clct_vpf_pipe;

  //with triggering or readout enabled
  assign hmt_fired_cathode_only = hmt_cathode_fired && !hmt_anode_fired && (hmt_allow_cathode || hmt_allow_cathode_ro);
  assign hmt_fired_anode_only   =!hmt_cathode_fired &&  hmt_anode_fired && (hmt_allow_anode   || hmt_allow_anode_ro);
  assign hmt_fired_match        = hmt_cathode_fired &&  hmt_anode_fired && (hmt_allow_match   || hmt_allow_match_ro);
  assign hmt_fired_or           =(hmt_cathode_fired && (hmt_allow_cathode || hmt_allow_cathode_ro)) || (hmt_anode_fired && (hmt_allow_anode   || hmt_allow_anode_ro)) || (hmt_cathode_fired &&  hmt_anode_fired && (hmt_allow_match   || hmt_allow_match_ro));

  wire [MXHMTB-1    :0] hmt_trigger_match, hmt_trigger_match_ro;

  wire [MXHMTB-1    :0] hmt_trigger_cathode    = hmt_cathode_pipe  & {MXHMTB{hmt_allow_cathode}};
  wire [MXHMTB-1    :0] hmt_trigger_anode      = hmt_anode & {MXHMTB{hmt_allow_anode}};
  wire [MXHMTB-1    :0] hmt_trigger_cathode_ro = hmt_cathode_pipe  & {MXHMTB{hmt_allow_cathode_ro}};
  wire [MXHMTB-1    :0] hmt_trigger_anode_ro   = hmt_anode & {MXHMTB{hmt_allow_anode_ro}};
  //wire [MXHMTB-1    :0] hmt_trigger_match      = hmt_cathode_pipe & hmt_anode & {MXHMTB{hmt_allow_match}};
  //wire [MXHMTB-1    :0] hmt_trigger_match_ro   = hmt_cathode_pipe & hmt_anode & {MXHMTB{hmt_allow_match_ro}};
  assign hmt_trigger_match[1:0]    = (hmt_cathode_pipe[1:0] > hmt_anode[1:0] ? hmt_anode[1:0] : hmt_cathode_pipe[1:0]) & {2{hmt_allow_match}};
  assign hmt_trigger_match[3:2]    = (hmt_cathode_pipe[3:2] > hmt_anode[3:2] ? hmt_anode[3:2] : hmt_cathode_pipe[3:2]) & {2{hmt_allow_match}};
  assign hmt_trigger_match_ro[1:0] = (hmt_cathode_pipe[1:0] > hmt_anode[1:0] ? hmt_anode[1:0] : hmt_cathode_pipe[1:0]) & {2{hmt_allow_match_ro}};
  assign hmt_trigger_match_ro[3:2] = (hmt_cathode_pipe[3:2] > hmt_anode[3:2] ? hmt_anode[3:2] : hmt_cathode_pipe[3:2]) & {2{hmt_allow_match_ro}};


  assign hmt_trigger_tmb     = hmt_trigger_cathode | hmt_trigger_anode | hmt_trigger_match;
  assign hmt_trigger_tmb_ro  = hmt_trigger_cathode_ro | hmt_trigger_anode_ro | hmt_trigger_match_ro;


  wire [3:0] hmt_final_delay = hmt_postdrift_delay+hmt_match_win;
  wire [NHMTHITB-1:0] nhits_trig_dly_bkg;
  wire [NHMTHITB-1:0] nhits_trig_dly_sig;
  wire [NHMTHITB-1:0] nhits_trig_dly_bx7;
  wire [MXBADR-1:0] wr_adr_xpre_hmt_dly;
  wire wr_push_xpre_hmt_dly, wr_avail_xpre_hmt_dly;
  //wire [MXBADR-1:0] wr_adr_xpre_hmt_pipe;
  //wire  wr_avail_xpre_hmt_pipe;
  //wire wr_push_xpre_hmt_pipe;
  srl16e_bbl #(NHMTHITB)    udnhitsbx7   ( .clock(clock), .ce(1'b1), .adr(hmt_final_delay-4'd1), .d(nhits_trig_s0_bx7 ), .q(nhits_trig_dly_bx7 ));
  srl16e_bbl #(NHMTHITB)    udnhitsbxsig ( .clock(clock), .ce(1'b1), .adr(hmt_final_delay-4'd1), .d(nhits_trig_s0_sig ), .q(nhits_trig_dly_sig ));
  srl16e_bbl #(NHMTHITB)    udnhitsbxbkg ( .clock(clock), .ce(1'b1), .adr(hmt_final_delay-4'd1), .d(nhits_trig_s0_bkg ), .q(nhits_trig_dly_bkg ));
  
  srl16e_bbl #(MXBADR)    udnhmtadr   ( .clock(clock), .ce(1'b1), .adr(hmt_final_delay-4'd1), .d(wr_adr_xpre_hmt    ), .q(wr_adr_xpre_hmt_dly   ));
  srl16e_bbl #(1)         udnhmtpush  ( .clock(clock), .ce(1'b1), .adr(hmt_final_delay-4'd1), .d(wr_push_xpre_hmt   ), .q(wr_push_xpre_hmt_dly  ));
  srl16e_bbl #(1)         udnhmtavail ( .clock(clock), .ce(1'b1), .adr(hmt_final_delay-4'd1), .d(wr_avail_xpre_hmt  ), .q(wr_avail_xpre_hmt_dly ));

  assign  hmt_nhits_bx7 = (hmt_final_delay == 4'd0) ? nhits_trig_s0_bx7[9:0] : nhits_trig_dly_bx7[9:0];
  assign  hmt_nhits_sig = (hmt_final_delay == 4'd0) ? nhits_trig_s0_sig[9:0] : nhits_trig_dly_sig[9:0];
  assign  hmt_nhits_bkg = (hmt_final_delay == 4'd0) ? nhits_trig_s0_bkg[9:0] : nhits_trig_dly_bkg[9:0];

  assign  wr_adr_xpre_hmt_pipe   = (hmt_final_delay == 4'd0) ?  wr_adr_xpre_hmt   : wr_adr_xpre_hmt_dly; 
  assign  wr_avail_xpre_hmt_pipe = (hmt_final_delay == 4'd0) ?  wr_avail_xpre_hmt : wr_avail_xpre_hmt_dly;
  wire    wr_push_xpre_hmt_pipe  = (hmt_final_delay == 4'd0) ?  wr_push_xpre_hmt  : wr_push_xpre_hmt_dly;

  assign wr_push_mux_hmt =  hmt_fired_anode_only ? wr_push_xpre_hmt_pipe : (wr_push_xpre_hmt_pipe && hmt_cathode_fired);

  assign hmt_sump = |hmt_pri_best;
 
//------------------------------------------------------------------------------------------------------------------------
// Virtex-6 Specific
//
// 03/21/2013 Initial
//------------------------------------------------------------------------------------------------------------------------
function [2: 0] countnlayer;
  input [5: 0] inp;
  reg   [2: 0] rom;

  begin
    case (inp[5: 0])
      6'b000000: rom = 0;
      6'b000001: rom = 1;
      6'b000010: rom = 1;
      6'b000011: rom = 2;
      6'b000100: rom = 1;
      6'b000101: rom = 2;
      6'b000110: rom = 2;
      6'b000111: rom = 3;
      6'b001000: rom = 1;
      6'b001001: rom = 2;
      6'b001010: rom = 2;
      6'b001011: rom = 3;
      6'b001100: rom = 2;
      6'b001101: rom = 3;
      6'b001110: rom = 3;
      6'b001111: rom = 4;
      6'b010000: rom = 1;
      6'b010001: rom = 2;
      6'b010010: rom = 2;
      6'b010011: rom = 3;
      6'b010100: rom = 2;
      6'b010101: rom = 3;
      6'b010110: rom = 3;
      6'b010111: rom = 4;
      6'b011000: rom = 2;
      6'b011001: rom = 3;
      6'b011010: rom = 3;
      6'b011011: rom = 4;
      6'b011100: rom = 3;
      6'b011101: rom = 4;
      6'b011110: rom = 4;
      6'b011111: rom = 5;
      6'b100000: rom = 1;
      6'b100001: rom = 2;
      6'b100010: rom = 2;
      6'b100011: rom = 3;
      6'b100100: rom = 2;
      6'b100101: rom = 3;
      6'b100110: rom = 3;
      6'b100111: rom = 4;
      6'b101000: rom = 2;
      6'b101001: rom = 3;
      6'b101010: rom = 3;
      6'b101011: rom = 4;
      6'b101100: rom = 3;
      6'b101101: rom = 4;
      6'b101110: rom = 4;
      6'b101111: rom = 5;
      6'b110000: rom = 2;
      6'b110001: rom = 3;
      6'b110010: rom = 3;
      6'b110011: rom = 4;
      6'b110100: rom = 3;
      6'b110101: rom = 4;
      6'b110110: rom = 4;
      6'b110111: rom = 5;
      6'b111000: rom = 3;
      6'b111001: rom = 4;
      6'b111010: rom = 4;
      6'b111011: rom = 5;
      6'b111100: rom = 4;
      6'b111101: rom = 5;
      6'b111110: rom = 5;
      6'b111111: rom = 6;
    endcase

    countnlayer = rom;
  end

endfunction


//-------------------------------------------------------------------------------------------------------------------
  endmodule
//-------------------------------------------------------------------------------------------------------------------
