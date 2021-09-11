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
  
  hmt_enable,
  hmt_thresh1,
  hmt_thresh2,
  hmt_thresh3,
  hmt_aff_thresh,
  
  hmt_delay,
  hmt_alct_win_size,
  hmt_match_win,
  
  alct_vpf_pipe,
  hmt_anode,

  clct_pretrig,
  clct_vpf_pipe,
  clct_match,
  
  cfeb_allow_hmt_ro,
  hmt_allow_cathode,
  hmt_allow_anode,
  hmt_allow_match,
  hmt_allow_cathode_ro,
  hmt_allow_anode_ro,
  hmt_allow_match_ro,

  hmt_fired_pretrig,//preCLCT bx
  hmt_active_cfeb,
  

  hmt_nhits_bx7,//tmb match bx cathode hmt
  hmt_nhits_bx678,
  hmt_nhits_bx2345,
  hmt_cathode_pipe, // tmb match bx

  hmt_cathode_fired     , 
  hmt_anode_fired       , 
  hmt_anode_alct_match  ,
  hmt_cathode_alct_match, 
  hmt_cathode_clct_match, 
  hmt_cathode_lct_match ,
 
  hmt_fired_cathode_only,
  hmt_fired_anoode_only,
  hmt_fired_match,
  hmt_fired_or,
  
  hmt_trigger_tmb,// results aligned with ALCT vpf latched for ALCT-CLCT match
  hmt_trigger_tmb_ro,// results aligned with ALCT vpf latched for ALCT-CLCT match
  
  hmt_sump
);


   parameter MXHMTB     =  4;// bits for HMT
   parameter NHITCFEBB  =  6;
   parameter MXCFEB     =  5;
   parameter NHMTHITB   = 10;


  input  clock;
  input  ttc_resync,
  input  global_reset, 

  input  fmm_trig_stop,
  
  input  [NHITCFEBB-1: 0] nhit_cfeb0;
  input  [NHITCFEBB-1: 0] nhit_cfeb1;
  input  [NHITCFEBB-1: 0] nhit_cfeb2;
  input  [NHITCFEBB-1: 0] nhit_cfeb3;
  input  [NHITCFEBB-1: 0] nhit_cfeb4;
  
  input    hmt_enable;
  input  [7:0] hmt_thresh1;
  input  [7:0] hmt_thresh2;
  input  [7:0] hmt_thresh3;
  input  [6:0] hmt_aff_thresh;
  
  input  [3:0]  hmt_delay;
  input  [3:0]  hmt_alct_win_size;
  output [3:0]  hmt_match_win;
  
  input  alct_vpf_pipe;
  input [MXHMTB-1:0] hmt_anode;

  input  clct_pretrig;
  input  clct_vpf_xtmb;

  input hmt_allow_cathode;
  input hmt_allow_anode;
  input hmt_allow_match;
  input hmt_allow_cathode_ro;
  input hmt_allow_anode_ro;
  input hmt_allow_match_ro;
  
  output  hmt_fired_pretrig;//preCLCT bx
  output [MXCFEB-1  :0]   hmt_active_cfeb;

  //output [MXHMTB-1:0]     hmt_cathode_xtmb; //CLCT bx

  output [NHMTHITB-1:0]   hmt_nhits_bx7;//CLCT bx
  output [NHMTHITB-1:0]   hmt_nhits_bx678;
  output [NHMTHITB-1:0]   hmt_nhits_bx2345;
  output [MXHMTB-1:0]     hmt_cathode_pipe; // tmb match bx

  output hmt_cathode_fired     ; 
  output hmt_anode_fired       ; 
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

  assign hmt_anode_fired        = (|hmt_anode[1:0]);

  reg [1:0] hmt_reset_ff = 2'b00;
  always @(posedge clock) begin
    hmt_reset_ff[0] <= (global_reset || ttc_resync);
    hmt_reset_ff[1] <= hmt_reset_ff[0] || fmm_trig_stop;
  end
  wire hmt_reset = |hmt_reset_ff;

  wire [MXCFEB-1  :0]  active_cfeb_s0; 
  assign active_cfeb_s0[0] = nhit_cfeb0 >= hmt_aff_thresh;
  assign active_cfeb_s0[1] = nhit_cfeb1 >= hmt_aff_thresh;
  assign active_cfeb_s0[2] = nhit_cfeb2 >= hmt_aff_thresh;
  assign active_cfeb_s0[3] = nhit_cfeb3 >= hmt_aff_thresh;
  assign active_cfeb_s0[4] = nhit_cfeb4 >= hmt_aff_thresh;

  wire [NHMTHITB-1:0] nhits_chamber = nhit_cfeb0 + nhit_cfeb1 + nhit_cfeb2 + nhit_cfeb3 + nhit_cfeb4;
  reg  [NHMTHITB-1:0] nhits_trig_s0_srl [7:0];//array 8x10bits

  always @(posedge clock) begin
      nhits_trig_s0_srl[7] <= nhits_trig_s0_srl[6];
      nhits_trig_s0_srl[6] <= nhits_trig_s0_srl[5];
      nhits_trig_s0_srl[5] <= nhits_trig_s0_srl[4];
      nhits_trig_s0_srl[4] <= nhits_trig_s0_srl[3];
      nhits_trig_s0_srl[3] <= nhits_trig_s0_srl[2];
      nhits_trig_s0_srl[2] <= nhits_trig_s0_srl[1];
      nhits_trig_s0_srl[1] <= nhits_trig_s0_srl[0];
      nhits_trig_s0_srl[0] <= nhits_chamber;
  end

  //signal: over 3BX;   control region: over 4BX 

  wire [NHMTHITB-1:0] nhits_trig_s0_bx7    = nhits_trig_s0_srl[2];//center one
  wire [NHMTHITB-1:0] nhits_trig_s0_bx678  = nhits_trig_s0_srl[3] + nhits_trig_s0_srl[2] + nhits_trig_s0_srl[1];
  wire [NHMTHITB-1:0] nhits_trig_s0_bx2345 = nhits_trig_s0_srl[7] + nhits_trig_s0_srl[6] + nhits_trig_s0_srl[5] + nhits_trig_s0_srl[4];
  //peak conditio: nhits_trig_s0_bx678 >= nhits_trig_s0_bx789 && nhits_trig_s0_bx678 >= nhits_trig_s0_bx89A
  wire nhits_compare_s0_bx678_789 = (nhits_trig_s0_srl[3] > nhits_trig_s0_srl[0]) || (nhits_trig_s0_srl[3] == nhits_trig_s0_srl[0] &&  nhits_trig_s0_srl[2]> nhits_trig_s0_srl[1]);
  wire nhits_compare_s0_bx678_89A = (nhits_trig_s0_srl[3] + nhits_trig_s0_srl[2] >  nhits_trig_s0_srl[0] + nhits_chamber) || (nhits_trig_s0_srl[3] + nhits_trig_s0_srl[2] ==  nhits_trig_s0_srl[0] + nhits_chamber && nhits_trig_s0_srl[2] > nhits_trig_s0_srl[0]);
  wire nhits_trig_s0_bx678_peak = nhits_compare_s0_bx678_789 && nhits_compare_s0_bx678_89A;

  wire hmt_bit0_s0 = ((nhits_trig_s0_bx678 >= hmt_thresh1) || (nhits_trig_s0_bx678 >= hmt_thresh3)) & nhits_trig_s0_bx678_peak &  (~|hmt_fired_s0_ff) & (~hmt_reset);
  wire hmt_bit1_s0 = ((nhits_trig_s0_bx678 >= hmt_thresh2) || (nhits_trig_s0_bx678 >= hmt_thresh3)) & nhits_trig_s0_bx678_peak &  (~|hmt_fired_s0_ff) & (~hmt_reset);
  wire hmt_bit2_s0 = ((nhits_trig_s0_bx2345 >= hmt_thresh1) || (nhits_trig_s0_bx2345 >= hmt_thresh3)) &  (~|hmt_fired_s0_ff) & (~hmt_reset);
  wire hmt_bit3_s0 = ((nhits_trig_s0_bx2345 >= hmt_thresh2) || (nhits_trig_s0_bx2345 >= hmt_thresh3)) &  (~|hmt_fired_s0_ff) & (~hmt_reset);
  wire [MXHMTB-1:0] hmt_trigger_s0 = hmt_enable ? {hmt_bit3_s0, hmt_bit2_s0, hmt_bit1_s0, hmt_bit0_s0} : 4'b0;

  wire   hmt_fired_s0   = hmt_bit0_s0 || hmt_bit1_s0;

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
  wire [3:0] delay_hmt_aff_adr = hmt_dly_const + 4'd2;// equivalent 4'd3-4'd1

  wire [MXCFEB-1  :0]  active_cfeb_s1; 
  srl16e_bbl #(1)       uhmtfiredpre  ( .clock(clock), .ce(1'b1), .adr(hmt_dly_const-4'd1), .d(hmt_fired_s0),   .q(hmt_fired_s1_srl));
  srl16e_bbl #(MXCFEB)  uhmtaffpre    ( .clock(clock), .ce(1'b1), .adr(delay_hmt_aff_adr),  .d(active_cfeb_s1), .q(active_cfeb_s1));

  wire hmt_fired_s1 = (hmt_dly_const == 4'd0) ? hmt_fired_s0 : hmt_fired_s1_srl;
  assign hmt_fired_pretrigger = hmt_fired_s1;
  assign hmt_active_cfeb      = active_cfeb_s1;

  wire hmt_pretrigger_match   = hmt_fired_pretrigger && clct_pretrig;

//------------------------------------------------------------------------------------------------------------------
//  Delay HMT to post-drift 
//------------------------------------------------------------------------------------------------------------------

  reg [3:0] hmt_postdrift_delay = 4'b0;
  always @(posedge clock) begin
      hmt_postdrift_delay = hmt_dly_const + hmt_delay;
  end

  wire [MXHMTB-1  :0] hmt_cathode_dly;
  srl16e_bbl #(MXHMTB)      udhmttrig    ( .clock(clock), .ce(1'b1), .adr(hmt_postdrift_delay-4'd1), .d(hmt_cathode_s0    ),    .q(hmt_cathode_dly      ));
  wire [MXHMTB-1  :0] hmt_cathode_xtmb      = (hmt_postdrift_delay == 4'd0) ? hmt_cathode_s0            : hmt_cathode_dly;

  wire hmt_fired_xtmb = |hmt_cathode_xtmb[1:0];

//------------------------------------------------------------------------------------------------------------------
//  HMT-ALCT match
//------------------------------------------------------------------------------------------------------------------
// FF buffer hmt_window index for fanout, points to 1st position window is closed 
  reg [3:0] winclosing=0;

  always @(posedge clock) begin
  winclosing <= hmt_alct_win_size-1'b1;
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
  if    (ttc_resync            ) hmt_win_priority[i] <= 4'hF;
  else if (i>=hmt_window || i==0) hmt_win_priority[i] <= 0;                          // i >  lastwin or i=0
  else if (i<=hmt_win_center    ) hmt_win_priority[i] <= hmt_window-4'd1-((hmt_win_center-i[3:0]) << 1);  // i <= center
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

  wire hmt_cathode_kept    =  (hmt_match) || (hmt_noanode && !hmt_noanode_lost);

// Match window mux
  wire [3:0] match_win;
  wire [3:0] match_win_mux;

  assign match_win_mux = (hmt_noanode     ) ? winclosing    : hmt_tag_win;          // if hmt only, disregard priority and take last window position 
  assign hmt_match_win = (hmt_cathode_kept) ? match_win_mux : hmt_win_center;          // Default window position for alct-only events


  // Pointer to SRL delayed HMT signals
  assign hmt_srl_ptr   = hmt_match_win;
  wire hmt_ptr_is_0 = hmt_srl_ptr == 4'b0;
  wire [3:0]  hmt_srl_adr = hmt_srl_ptr-1'b1;
  wire [MXHMTB-1    :0] hmt_cathode_srl;
  srl16e_bbl #(MXHMTB   ) uhmt        (.clock(clock),.ce(1'b1),.adr(hmt_srl_adr),.d(hmt_cathode_xtmb),.q(chmt_cathode_srl));
  assign hmt_cathode_pipe   = (hmt_ptr_is_0) ? hmt_cathode_xtmb : hmt_cathode_srl;

  assign hmt_cathode_fired      = (|hmt_cathode_pipe[1:0]);
  assign hmt_anode_alct_match   = hmt_anode_fired && alct_vpf_pipe;
  assign hmt_cathode_alct_match = hmt_cathode_fired && alct_vpf_pipe;
  assign hmt_cathode_clct_match = hmt_cathode_fired && clct_vpf_pipe;
  assign hmt_cathode_lct_match  = hmt_cathode_fired && alct_vpf_pipe && clct_vpf_pipe;

  assign hmt_fired_cathode_only = hmt_cathode_fired && !hmt_anode_fired;
  assign hmt_fired_anode_only   =!hmt_cathode_fired &&  hmt_anode_fired;
  assign hmt_fired_match        = hmt_cathode_fired &&  hmt_anode_fired;
  assign hmt_fired_or           = hmt_cathode_fired ||  hmt_anode_fired;

  wire [MXHMTB-1    :0] hmt_trigger_cathode    = hmt_cathode_pipe  & {MXHMTB{hmt_allow_cathode}};
  wire [MXHMTB-1    :0] hmt_trigger_anode      = hmt_anode & {MXHMTB{hmt_allow_anode}};
  wire [MXHMTB-1    :0] hmt_trigger_match      = hmt_cathode_pipe & hmt_anode & {MXHMTB{hmt_allow_match}};
  wire [MXHMTB-1    :0] hmt_trigger_cathode_ro = hmt_cathode_pipe  & {MXHMTB{hmt_allow_cathode_ro}};
  wire [MXHMTB-1    :0] hmt_trigger_anode_ro   = hmt_anode & {MXHMTB{hmt_allow_anode_ro}};
  wire [MXHMTB-1    :0] hmt_trigger_match_ro   = hmt_cathode_pipe & hmt_anode & {MXHMTB{hmt_allow_match_ro}};

  assign hmt_trigger_tmb     = hmt_trigger_cathode | hmt_trigger_anode | hmt_trigger_match;
  assign hmt_trigger_tmb_ro  = hmt_trigger_cathode_ro | hmt_trigger_anode_ro | hmt_trigger_match_ro;


  wire [3:0] hmt_final_delay = hmt_postdrift_delay+hmt_match_win;
  wire [NHMTHITB-1:0] nhits_trig_dly_bx2345;
  wire [NHMTHITB-1:0] nhits_trig_dly_bx678;
  wire [NHMTHITB-1:0] nhits_trig_dly_bx7;
  srl16e_bbl #(NHMTHITB)    udnhitsbx7   ( .clock(clock), .ce(1'b1), .adr(hmt_final_delay-4'd1), .d(nhits_trig_s0_bx7    ), .q(nhits_trig_dly_bx7      ));
  srl16e_bbl #(NHMTHITB)    udnhitsbx678 ( .clock(clock), .ce(1'b1), .adr(hmt_final_delay-4'd1), .d(nhits_trig_s0_bx678  ), .q(nhits_trig_dly_bx678    ));
  srl16e_bbl #(NHMTHITB)    udnhitsbx2345( .clock(clock), .ce(1'b1), .adr(hmt_final_delay-4'd1), .d(nhits_trig_s0_bx2345 ), .q(nhits_trig_dly_bx2345   ));

  assign  hmt_nhits_bx7    = (hmt_final_delay == 4'd0) ? nhits_trig_s0_bx7[9:0]    : nhits_trig_dly_bx7[9:0];
  assign  hmt_nhits_bx678  = (hmt_final_delay == 4'd0) ? nhits_trig_s0_bx678[9:0]  : nhits_trig_dly_bx678[9:0];
  assign  hmt_nhits_bx2345 = (hmt_final_delay == 4'd0) ? nhits_trig_s0_bx2345[9:0] : nhits_trig_dly_bx2345[9:0];


//-------------------------------------------------------------------------------------------------------------------
  endmodule
//-------------------------------------------------------------------------------------------------------------------
