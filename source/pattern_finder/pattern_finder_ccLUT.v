`timescale 1ns / 1ps

// J.Gilmore, 10/13/17: edits to fix Deadzone handling (Yuri's algo2016, see sequencer.v too) and active_cfeb+neighbor logic

//`define DEBUG_PATTERN_FINDER  // Turn on debug mode
//-------------------------------------------------------------------------------------------------------------------
// Conditional compile flags, normally set by global defines. Override here for standalone debugging
//-------------------------------------------------------------------------------------------------------------------
// `define CSC_TYPE_A   04'hA  // Normal ME234/1
// `define CSC_TYPE_B   04'hB  // Reversed ME234/1
// `define CSC_TYPE_C   04'hC  // Normal ME1B, reversed ME1A
// `define CSC_TYPE_D   04'hD  // Reversed ME1B, normal ME1A
//-------------------------------------------------------------------------------------------------------------------
// 02/08/2013 Initial Virtex-6
// 02/11/2013 Tune simulator DCM defparams
// 02/11/2013 Unfold pattern finder, remove clock_2x and clock_lac
// 02/15/2013 Expand to 7 CFEBs
// 03/25/2013 Replace layer trigger count1s with ROM
// 04/03/2013 Fix cfeb_hit logic
// 12/05/2017 need to consider layerTrig in busy/dead zone logic... (layer_trig_en_ff & layer_trig_s0); // JG: Is this OK? Here?
//-------------------------------------------------------------------------------------------------------------------
module pattern_finder_ccLUT (
  // Clock Ports
  clock,
  global_reset,

`ifndef DEBUG_PATTERN_FINDER
  // CFEB Ports
  cfeb0_ly0hs, cfeb0_ly1hs, cfeb0_ly2hs, cfeb0_ly3hs, cfeb0_ly4hs, cfeb0_ly5hs,
  cfeb1_ly0hs, cfeb1_ly1hs, cfeb1_ly2hs, cfeb1_ly3hs, cfeb1_ly4hs, cfeb1_ly5hs,
  cfeb2_ly0hs, cfeb2_ly1hs, cfeb2_ly2hs, cfeb2_ly3hs, cfeb2_ly4hs, cfeb2_ly5hs,
  cfeb3_ly0hs, cfeb3_ly1hs, cfeb3_ly2hs, cfeb3_ly3hs, cfeb3_ly4hs, cfeb3_ly5hs,
  cfeb4_ly0hs, cfeb4_ly1hs, cfeb4_ly2hs, cfeb4_ly3hs, cfeb4_ly4hs, cfeb4_ly5hs,
  //Tao, ME1/1->MEX/1
  //cfeb5_ly0hs, cfeb5_ly1hs, cfeb5_ly2hs, cfeb5_ly3hs, cfeb5_ly4hs, cfeb5_ly5hs,
  //cfeb6_ly0hs, cfeb6_ly1hs, cfeb6_ly2hs, cfeb6_ly3hs, cfeb6_ly4hs, cfeb6_ly5hs,
`else 
  // CFEB Ports, debug
  tmb_clock0,
  cfeb0_ly0hst, cfeb0_ly1hst, cfeb0_ly2hst, cfeb0_ly3hst, cfeb0_ly4hst, cfeb0_ly5hst,
  cfeb1_ly0hst, cfeb1_ly1hst, cfeb1_ly2hst, cfeb1_ly3hst, cfeb1_ly4hst, cfeb1_ly5hst,
  cfeb2_ly0hst, cfeb2_ly1hst, cfeb2_ly2hst, cfeb2_ly3hst, cfeb2_ly4hst, cfeb2_ly5hst,
  cfeb3_ly0hst, cfeb3_ly1hst, cfeb3_ly2hst, cfeb3_ly3hst, cfeb3_ly4hst, cfeb3_ly5hst,
  cfeb4_ly0hst, cfeb4_ly1hst, cfeb4_ly2hst, cfeb4_ly3hst, cfeb4_ly4hst, cfeb4_ly5hst,
  //Tao, ME1/1->MEX/1
  //cfeb5_ly0hst, cfeb5_ly1hst, cfeb5_ly2hst, cfeb5_ly3hst, cfeb5_ly4hst, cfeb5_ly5hst,
  //cfeb6_ly0hst, cfeb6_ly1hst, cfeb6_ly2hst, cfeb6_ly3hst, cfeb6_ly4hst, cfeb6_ly5hst,
`endif

  // CSC Orientation Ports
  csc_type,
  csc_me1ab,
  stagger_hs_csc,
  reverse_hs_csc,
  reverse_hs_me1a,
  reverse_hs_me1b,

  // PreTrigger Ports
  layer_trig_en,
  lyr_thresh_pretrig,
  hit_thresh_pretrig,
  pid_thresh_pretrig,
  dmb_thresh_pretrig,
  cfeb_en,
  adjcfeb_dist,
  clct_blanking,

  cfeb_hit,
  cfeb_active,

  cfeb_layer_trig,
  cfeb_layer_or,
  cfeb_nlayers_hit,

  //HMT part
  //hmt_nhits_trig,

  drift_delay,
// Algo2016: configuration
  algo2016_use_dead_time_zone,
  algo2016_dead_time_zone_size,

  // 2nd CLCT separation RAM Ports
  clct_sep_src,
  clct_sep_vme,
  clct_sep_ram_we,
  clct_sep_ram_adr,
  clct_sep_ram_wdata,
  clct_sep_ram_rdata,

  // CLCT Pattern-finder results
  hs_hit_1st,
  hs_pid_1st,
  hs_key_1st,
  hs_bnd_1st,
  hs_xky_1st,
  hs_car_1st,
  hs_run2pid_1st,

  hs_hit_2nd,
  hs_pid_2nd,
  hs_key_2nd,
  hs_bsy_2nd,
  hs_bnd_2nd,
  hs_xky_2nd,
  hs_car_2nd,
  hs_run2pid_2nd,

  hs_layer_trig,
  hs_nlayers_hit,
  hs_layer_or

`ifdef DEBUG_PATTERN_FINDER 
  // Debug
  , purge_sm_dsp
  , reset
  , lock

  , lyr_thresh_pretrig_ff
  , hit_thresh_pretrig_ff
  , pid_thresh_pretrig_ff
  , dmb_thresh_pretrig_ff
  , cfeb_en_ff
  , layer_trig_en_ff

  , busy_min
  , busy_max
  , busy_key
  , clct0_is_on_me1a

  , debug_hs_hit_s0
  , debug_hs_hit_s0ab
  , debug_hs_hit
`endif
);

//-------------------------------------------------------------------------------------------------------------------
// Constants
//-------------------------------------------------------------------------------------------------------------------
`include "pattern_params.v"
  //parameter MXCFEB  = 5;             // Number of CFEBs on CSC
  //parameter MXLY    = 6;             // Number of layers in CSC
  //parameter MXDS    = 8;             // Number of DiStrips per layer on 1 CFEB
  //parameter MXDSX   = MXCFEB * MXDS; // Number of DiStrips per layer on 5 CFEBs
  //parameter MXHS    = 32;            // Number of HalfStrips per layer on 1 CFEB
  //parameter MXHSX   = MXCFEB * MXHS; // Number of HalfStrips per layer on 5 CFEBs
  //parameter MXKEY   = MXHS;          // Number of key HalfSrips on 1 CFEB
  //parameter MXKEYB  = 5;             // Number of HalfSrip key bits on 1 CFEB
  //parameter MXKEYX  = MXCFEB * MXHS; // Number of key HalfSrips on 5 CFEBs
  //parameter MXKEYBX = 8;             // Number of HalfSrip key bits on 5 CFEBs

  //parameter MXPIDB  = 4;             // Pattern ID bits
  //parameter MXHITB  = 3;             // Hits on pattern bits
  //parameter MXPATB  = 3 + 4;         // Pattern bits
  parameter MXDRIFT = 2;             // Number drift delay bits
//-------------------------------------------------------------------------------------------------------------------
// Ports
//-------------------------------------------------------------------------------------------------------------------
`ifndef DEBUG_PATTERN_FINDER
  // Clock Ports
  input clock;        // 40MHz TMB main clock
  input global_reset; // 1=Reset everything

  // CFEB Ports
  // Triad decoder 1/2-strip pulses
  input [MXHS - 1: 0] cfeb0_ly0hs, cfeb0_ly1hs, cfeb0_ly2hs, cfeb0_ly3hs, cfeb0_ly4hs, cfeb0_ly5hs;
  input [MXHS - 1: 0] cfeb1_ly0hs, cfeb1_ly1hs, cfeb1_ly2hs, cfeb1_ly3hs, cfeb1_ly4hs, cfeb1_ly5hs;
  input [MXHS - 1: 0] cfeb2_ly0hs, cfeb2_ly1hs, cfeb2_ly2hs, cfeb2_ly3hs, cfeb2_ly4hs, cfeb2_ly5hs;
  input [MXHS - 1: 0] cfeb3_ly0hs, cfeb3_ly1hs, cfeb3_ly2hs, cfeb3_ly3hs, cfeb3_ly4hs, cfeb3_ly5hs;
  input [MXHS - 1: 0] cfeb4_ly0hs, cfeb4_ly1hs, cfeb4_ly2hs, cfeb4_ly3hs, cfeb4_ly4hs, cfeb4_ly5hs;
  //Tao, ME1/1->MEX/1
  //input [MXHS - 1: 0] cfeb5_ly0hs, cfeb5_ly1hs, cfeb5_ly2hs, cfeb5_ly3hs, cfeb5_ly4hs, cfeb5_ly5hs;
  //input [MXHS - 1: 0] cfeb6_ly0hs, cfeb6_ly1hs, cfeb6_ly2hs, cfeb6_ly3hs, cfeb6_ly4hs, cfeb6_ly5hs;
`else
  // Clock Ports, debug
  output clock;       // 40MHz TMB main clock
  input global_reset; // 1=Reset everything
  input tmb_clock0;

  // CFEB Ports, debug
  // Triad decoder 1/2-strip pulses, FF buffered for sim
  input [MXHS - 1: 0] cfeb0_ly0hst, cfeb0_ly1hst, cfeb0_ly2hst, cfeb0_ly3hst, cfeb0_ly4hst, cfeb0_ly5hst;
  input [MXHS - 1: 0] cfeb1_ly0hst, cfeb1_ly1hst, cfeb1_ly2hst, cfeb1_ly3hst, cfeb1_ly4hst, cfeb1_ly5hst;
  input [MXHS - 1: 0] cfeb2_ly0hst, cfeb2_ly1hst, cfeb2_ly2hst, cfeb2_ly3hst, cfeb2_ly4hst, cfeb2_ly5hst;
  input [MXHS - 1: 0] cfeb3_ly0hst, cfeb3_ly1hst, cfeb3_ly2hst, cfeb3_ly3hst, cfeb3_ly4hst, cfeb3_ly5hst;
  input [MXHS - 1: 0] cfeb4_ly0hst, cfeb4_ly1hst, cfeb4_ly2hst, cfeb4_ly3hst, cfeb4_ly4hst, cfeb4_ly5hst;
  //Tao, ME1/1->MEX/1
  //input [MXHS - 1: 0] cfeb5_ly0hst, cfeb5_ly1hst, cfeb5_ly2hst, cfeb5_ly3hst, cfeb5_ly4hst, cfeb5_ly5hst;
  //input [MXHS - 1: 0] cfeb6_ly0hst, cfeb6_ly1hst, cfeb6_ly2hst, cfeb6_ly3hst, cfeb6_ly4hst, cfeb6_ly5hst;
`endif

  // CSC Orientation Ports
  output [3: 0] csc_type;        // Firmware compile type
  output        csc_me1ab;       // 1=ME1A or ME1B CSC type
  output        stagger_hs_csc;  // 1=Staggered CSC non-me1, 0=non-staggered me1
  output        reverse_hs_csc;  // 1=Reverse staggered CSC, non-me1
  output        reverse_hs_me1a; // 1=reverse me1a hstrips prior to pattern sorting
  output        reverse_hs_me1b; // 1=reverse me1b hstrips prior to pattern sorting

  // PreTrigger Ports
  input layer_trig_en;                          // 1=Enable layer trigger mode
  input [MXHITB - 1: 0]     lyr_thresh_pretrig; // Layers hit pre-trigger threshold
  input [MXHITB - 1: 0]     hit_thresh_pretrig; // Hits on pattern template pre-trigger threshold
  input [MXPIDB - 1: 0]     pid_thresh_pretrig; // Pattern shape ID pre-trigger threshold
  input [MXHITB - 1: 0]     dmb_thresh_pretrig; // Hits on pattern template DMB active-feb threshold
  input [MXCFEB - 1: 0]     cfeb_en;            // 1=Enable cfeb for pre-triggering
  input [MXKEYB - 1 + 1: 0] adjcfeb_dist;       // Distance from key to cfeb boundary for marking adjacent cfeb as hit
  input                     clct_blanking;      // 1=Blank clct outputs if zero hits

  output [MXCFEB - 1: 0] cfeb_hit;         // This CFEB has a pattern over pre-trigger threshold
  output [MXCFEB - 1: 0] cfeb_active;      // CFEBs marked active for DMB readout
  output                 cfeb_layer_trig;  // Layer pretrigger
  output [MXLY - 1: 0]   cfeb_layer_or;    // OR of hstrips on each layer
  output [MXHITB - 1: 0] cfeb_nlayers_hit; // Number of CSC layers hit

  //HMT
  //output [9:0] hmt_nhits_trig;

  // 2nd CLCT separation RAM Ports
  input          clct_sep_src;       // CLCT separation source 1=VME, 0=RAM
  input  [7: 0]  clct_sep_vme;       // CLCT separation from VME
  input          clct_sep_ram_we;    // CLCT separation RAM write enable
  input  [3: 0]  clct_sep_ram_adr;   // CLCT separation RAM rw address VME
  input  [15: 0] clct_sep_ram_wdata; // CLCT separation RAM write data VME
  output [15: 0] clct_sep_ram_rdata; // CLCT separation RAM read  data VME

  input [MXDRIFT-1:0] drift_delay;         // CSC Drift delay clocks
// Algo2016: configuration
  input       algo2016_use_dead_time_zone; // Dead time zone switch: 0 - "old" whole chamber is dead when pre-CLCT is registered, 1 - algo2016 only half-strips around pre-CLCT are marked dead
  input [4:0] algo2016_dead_time_zone_size;// Constant size of the dead time zone

  // CLCT Pattern-finder results
  output [MXHITB - 1: 0]  hs_hit_1st; // 1st CLCT pattern hits
  output [MXPIDB - 1: 0]  hs_pid_1st; // 1st CLCT pattern ID
  output [MXKEYBX - 1: 0] hs_key_1st; // 1st CLCT key 1/2-strip
//Tao CCLUT pattern
  output [MXXKYB     - 1 : 0] hs_xky_1st; // 1st CLCT key 1/8-strip
  output [MXBNDB     - 1 : 0] hs_bnd_1st; // 1st CLCT pattern lookup bend angle
  output [MXPATC     - 1 : 0] hs_car_1st; // 1st CLCT pattern lookup comparator-code
  output [MXPIDB - 1: 0]  hs_run2pid_1st; // 1st CLCT pattern ID

  output [MXHITB - 1: 0]  hs_hit_2nd; // 2nd CLCT pattern hits
  output [MXPIDB - 1: 0]  hs_pid_2nd; // 2nd CLCT pattern ID
  output [MXKEYBX - 1: 0] hs_key_2nd; // 2nd CLCT key 1/2-strip
  output                  hs_bsy_2nd; // 2nd CLCT busy, logic error indicator
//Tao CCLUT pattern
  output [MXXKYB     - 1 : 0] hs_xky_2nd; // 1st CLCT key 1/8-strip     
  output [MXBNDB     - 1 : 0] hs_bnd_2nd; // 1st CLCT pattern lookup bend angle
  output [MXPATC     - 1 : 0] hs_car_2nd; // 1st CLCT pattern lookup comparator-code
  output [MXPIDB - 1: 0]  hs_run2pid_2nd; // 1st CLCT pattern ID

  output                 hs_layer_trig;  // Layer triggered
  output [MXHITB - 1: 0] hs_nlayers_hit; // Number of layers hit
  output [MXLY - 1: 0]   hs_layer_or;    // Layer OR

`ifdef DEBUG_PATTERN_FINDER 
  // Debug
  output [39: 0] purge_sm_dsp;
  output         reset;
  output         lock;

  output [MXHITB - 1: 0] lyr_thresh_pretrig_ff;
  output [MXHITB - 1: 0] hit_thresh_pretrig_ff;
  output [MXPIDB - 1: 0] pid_thresh_pretrig_ff;
  output [MXHITB - 1: 0] dmb_thresh_pretrig_ff;
  output [MXCFEB - 1: 0] cfeb_en_ff;
  output                 layer_trig_en_ff;

  output [MXKEYBX - 1: 0] busy_min;
  output [MXKEYBX - 1: 0] busy_max;
  output [MXHSX - 1: 0]   busy_key;
  output                  clct0_is_on_me1a;

  output debug_hs_hit_s0;
  output debug_hs_hit_s0ab;
  output debug_hs_hit;
`endif

//-------------------------------------------------------------------------------------------------------------------
// Load global definitions
//-------------------------------------------------------------------------------------------------------------------
`include "../otmb_virtex6_fw_version.v"
`ifdef CSC_TYPE_A initial $display ("CSC_TYPE_A=%H",`CSC_TYPE_A); `endif // Normal   ME234/1
`ifdef CSC_TYPE_B initial $display ("CSC_TYPE_B=%H",`CSC_TYPE_B); `endif // Reversed ME234/1
`ifdef CSC_TYPE_C initial $display ("CSC_TYPE_C=%H",`CSC_TYPE_C); `endif // Normal   ME1B, reversed ME1A
`ifdef CSC_TYPE_D initial $display ("CSC_TYPE_D=%H",`CSC_TYPE_D); `endif // Reversed ME1B, normal   ME1A
`define	STAGGER_HS_CSC 01'h1
//-------------------------------------------------------------------------------------------------------------------
// Debug mode, FF aligns inputs, and has local DLL to generate 2x clock and lac clock
//-------------------------------------------------------------------------------------------------------------------
`ifdef DEBUG_PATTERN_FINDER 
  // Flip-flop align hs inputs
  reg [MXHS - 1: 0] cfeb0_ly0hs, cfeb0_ly1hs, cfeb0_ly2hs, cfeb0_ly3hs, cfeb0_ly4hs, cfeb0_ly5hs;
  reg [MXHS - 1: 0] cfeb1_ly0hs, cfeb1_ly1hs, cfeb1_ly2hs, cfeb1_ly3hs, cfeb1_ly4hs, cfeb1_ly5hs;
  reg [MXHS - 1: 0] cfeb2_ly0hs, cfeb2_ly1hs, cfeb2_ly2hs, cfeb2_ly3hs, cfeb2_ly4hs, cfeb2_ly5hs;
  reg [MXHS - 1: 0] cfeb3_ly0hs, cfeb3_ly1hs, cfeb3_ly2hs, cfeb3_ly3hs, cfeb3_ly4hs, cfeb3_ly5hs;
  reg [MXHS - 1: 0] cfeb4_ly0hs, cfeb4_ly1hs, cfeb4_ly2hs, cfeb4_ly3hs, cfeb4_ly4hs, cfeb4_ly5hs;
  //Tao, ME1/1->MEX/1
  //reg [MXHS - 1: 0] cfeb5_ly0hs, cfeb5_ly1hs, cfeb5_ly2hs, cfeb5_ly3hs, cfeb5_ly4hs, cfeb5_ly5hs;
  //reg [MXHS - 1: 0] cfeb6_ly0hs, cfeb6_ly1hs, cfeb6_ly2hs, cfeb6_ly3hs, cfeb6_ly4hs, cfeb6_ly5hs;

  wire clock;
  always @(posedge clock) begin
    {cfeb0_ly5hs, cfeb0_ly4hs, cfeb0_ly3hs, cfeb0_ly2hs, cfeb0_ly1hs, cfeb0_ly0hs} <= {cfeb0_ly5hst, cfeb0_ly4hst, cfeb0_ly3hst, cfeb0_ly2hst, cfeb0_ly1hst, cfeb0_ly0hst};
    {cfeb1_ly5hs, cfeb1_ly4hs, cfeb1_ly3hs, cfeb1_ly2hs, cfeb1_ly1hs, cfeb1_ly0hs} <= {cfeb1_ly5hst, cfeb1_ly4hst, cfeb1_ly3hst, cfeb1_ly2hst, cfeb1_ly1hst, cfeb1_ly0hst};
    {cfeb2_ly5hs, cfeb2_ly4hs, cfeb2_ly3hs, cfeb2_ly2hs, cfeb2_ly1hs, cfeb2_ly0hs} <= {cfeb2_ly5hst, cfeb2_ly4hst, cfeb2_ly3hst, cfeb2_ly2hst, cfeb2_ly1hst, cfeb2_ly0hst};
    {cfeb3_ly5hs, cfeb3_ly4hs, cfeb3_ly3hs, cfeb3_ly2hs, cfeb3_ly1hs, cfeb3_ly0hs} <= {cfeb3_ly5hst, cfeb3_ly4hst, cfeb3_ly3hst, cfeb3_ly2hst, cfeb3_ly1hst, cfeb3_ly0hst};
    {cfeb4_ly5hs, cfeb4_ly4hs, cfeb4_ly3hs, cfeb4_ly2hs, cfeb4_ly1hs, cfeb4_ly0hs} <= {cfeb4_ly5hst, cfeb4_ly4hst, cfeb4_ly3hst, cfeb4_ly2hst, cfeb4_ly1hst, cfeb4_ly0hst};
  end

  // Global clock input buffers
  IBUFG uibufg4p ( // Input clock buffer primitive for single-ended I/O
    .I(tmb_clock0 ),
    .O(tmb_clock0_ibufg)
  );
  BUFG ugbuftmb1x ( // Clock buffer primitive with one clock input and one clock output
    .I(clock_dcm ),
    .O(clock )
  );

  // Main TMB DLL generates clocks at 1x=40MHz, 2x=80MHz, and 1/4 =10MHz
  DCM udcmtmb ( // Digital Clock Manager (DCM) primitive
    .CLKIN    (tmb_clock0_ibufg),
    .CLKFB    (clock),
    .RST      (1'b0),
    .DSSEN    (1'b0),
    .PSINCDEC (1'b0),
    .PSEN     (1'b0),
    .PSCLK    (1'b0),
    .CLK0     (clock_dcm),
    .CLK90    (),
    .CLK180   (),
    .CLK270   (),
    .CLK2X    (),
    .CLK2X180 (),
    .CLKDV    (),
    .CLKFX    (),
    .CLKFX180 (),
    .LOCKED   (lock),
    .STATUS   (),
    .PSDONE   ()
  );
  defparam udcmtmb.CLK_FEEDBACK = "1X";
  defparam udcmtmb.FACTORY_JF   = "F0F0";
`endif

//-------------------------------------------------------------------------------------------------------------------
// Stage 4A1: Power up, reset, and purge
//-------------------------------------------------------------------------------------------------------------------
  reg  ready = 0;
  wire reset = !ready;

  always @(posedge clock) begin
    ready <= !global_reset;
  end

  // Pipeline purge blanks pattern finder until pipes are cleared
  reg [1: 0] purge_sm;  // synthesis attribute safe_implementation of purge_sm is yes;
  parameter pass  = 0;
  parameter purge = 1;

  reg [2: 0] purge_cnt = 0;

  always @(posedge clock) begin
    if (reset) purge_cnt <= 0;
    else if (purge_sm == purge) purge_cnt <= purge_cnt + 1'b1;
    else purge_cnt <= 0;
  end

  wire purge_done = (purge_cnt == 7);
  wire purging    = (purge_sm == purge) || reset;

  // Pipeline purge state machine
  initial purge_sm = purge;

  always @(posedge clock) begin
    if (reset) purge_sm <= purge;
    else begin
      case (purge_sm)
        pass: purge_sm <= pass;
        purge: if (purge_done) purge_sm <= pass;
      endcase
    end
  end

//-------------------------------------------------------------------------------------------------------------------
// Local copy of number-planes-hit pretrigger threshold powers up with high threshold to block spurious patterns
//-------------------------------------------------------------------------------------------------------------------
  reg [MXHITB - 1: 0] lyr_thresh_pretrig_ff = 3'h7;  // Layers hit pre-trigger threshold
  reg [MXHITB - 1: 0] hit_thresh_pretrig_ff = 3'h7;  // Hits on pattern template pre-trigger threshold
  reg [MXPIDB - 1: 0] pid_thresh_pretrig_ff = 4'hF;  // Pattern shape ID pre-trigger threshold
  reg [MXHITB - 1: 0] dmb_thresh_pretrig_ff = 3'h7;  // Hits on pattern template DMB active-feb threshold
  reg [MXCFEB - 1: 0] cfeb_en_ff            = 7'h00; // CFEB enabled for pre-triggering
  reg                 layer_trig_en_ff      = 1'b0;  // Layer trigger mode enabled

  always @(posedge clock) begin
    if (purging) begin // Transient power-up values
      lyr_thresh_pretrig_ff <= 3'h7;
      hit_thresh_pretrig_ff <= 3'h7;
      pid_thresh_pretrig_ff <= 4'hF;
      dmb_thresh_pretrig_ff <= 3'h7;
      cfeb_en_ff            <= 7'h00;
      layer_trig_en_ff      <= 1'b0;
    end
    else begin // Subsequent VME values
      lyr_thresh_pretrig_ff <= lyr_thresh_pretrig;
      hit_thresh_pretrig_ff <= hit_thresh_pretrig;
      pid_thresh_pretrig_ff <= pid_thresh_pretrig;
      dmb_thresh_pretrig_ff <= dmb_thresh_pretrig;
      cfeb_en_ff            <= cfeb_en;
      layer_trig_en_ff      <= layer_trig_en;
    end
  end

  // Generate mask for marking adjacent cfeb as hit if nearby keys are over thresh
  reg [MXHS - 1: 0] adjcfeb_mask_nm1; // Adjacent CFEB active feb flag mask
  reg [MXHS - 1: 0] adjcfeb_mask_np1;

  genvar ihs;
  generate
    for (ihs = 0; ihs <= 31; ihs = ihs + 1) begin: genmask
      always @(posedge clock) begin
        adjcfeb_mask_nm1[     ihs] <= (ihs < adjcfeb_dist);
        adjcfeb_mask_np1[31 - ihs] <= (ihs < adjcfeb_dist);
      end
    end
  endgenerate


//-------------------------------------------------------------------------------------------------------------------
// Stage 4A3: CSC_TYPE_A: Normal ME234/1
  //Tao, ME1/1->MEX/1, should be normal CSC
//-------------------------------------------------------------------------------------------------------------------
`ifdef CSC_TYPE_A

  wire [MXHS * MXCFEB - 1: 0] me234_ly0hs;
  wire [MXHS * MXCFEB - 1: 0] me234_ly1hs;
  wire [MXHS * MXCFEB - 1: 0] me234_ly2hs;
  wire [MXHS * MXCFEB - 1: 0] me234_ly3hs;
  wire [MXHS * MXCFEB - 1: 0] me234_ly4hs;
  wire [MXHS * MXCFEB - 1: 0] me234_ly5hs;

  // Orientation flags
  assign csc_type        = 4'hA; // Firmware compile type
  assign csc_me1ab       = 0;    // 1 = ME1A or ME1B CSC, ignore for MEX/1
  assign reverse_hs_csc  = 0;    // 1 = Reversed  CSC non-ME1
  assign reverse_hs_me1a = 0;    // 1 = Reverse ME1A HalfStrips prior to pattern sorting
  assign reverse_hs_me1b = 0;    // 1 = Reverse ME1B HalfStrips prior to pattern sorting
  initial $display ("CSC_TYPE_A instantiated");


  // Normal ME1B CFEBs: 3, 2, 1, 0
  assign me234_ly0hs = {cfeb4_ly0hs, cfeb3_ly0hs, cfeb2_ly0hs, cfeb1_ly0hs, cfeb0_ly0hs};
  assign me234_ly1hs = {cfeb4_ly1hs, cfeb3_ly1hs, cfeb2_ly1hs, cfeb1_ly1hs, cfeb0_ly1hs};
  assign me234_ly2hs = {cfeb4_ly2hs, cfeb3_ly2hs, cfeb2_ly2hs, cfeb1_ly2hs, cfeb0_ly2hs};
  assign me234_ly3hs = {cfeb4_ly3hs, cfeb3_ly3hs, cfeb2_ly3hs, cfeb1_ly3hs, cfeb0_ly3hs};
  assign me234_ly4hs = {cfeb4_ly4hs, cfeb3_ly4hs, cfeb2_ly4hs, cfeb1_ly4hs, cfeb0_ly4hs};
  assign me234_ly5hs = {cfeb4_ly5hs, cfeb3_ly5hs, cfeb2_ly5hs, cfeb1_ly5hs, cfeb0_ly5hs};

//-------------------------------------------------------------------------------------------------------------------
// Stage 4A4: CSC_TYPE_B: Reserved ME234/1
// Tao, ME1/1->MEX/1, should be reversed CSC
//-------------------------------------------------------------------------------------------------------------------
`elsif CSC_TYPE_B
// Tao, ME1/1->MEX/1, should be reversed CSC

  wire [MXHS * MXCFEB - 1: 0] me234_ly0hs;
  wire [MXHS * MXCFEB - 1: 0] me234_ly1hs;
  wire [MXHS * MXCFEB - 1: 0] me234_ly2hs;
  wire [MXHS * MXCFEB - 1: 0] me234_ly3hs;
  wire [MXHS * MXCFEB - 1: 0] me234_ly4hs;
  wire [MXHS * MXCFEB - 1: 0] me234_ly5hs;

  // Orientation flags
  assign csc_type        = 4'hB; // Firmware compile type
  assign csc_me1ab       = 0;    // 1 = ME1A or ME1B CSC
  assign reverse_hs_csc  = 1;    // 1 = Reversed  CSC non-ME1
  assign reverse_hs_me1a = 0;    // 1 = Reverse ME1A HalfStrips prior to pattern sorting
  assign reverse_hs_me1b = 0;    // 1 = Reverse ME1B HalfStrips prior to pattern sorting
  initial $display ("CSC_TYPE_B instantiated");

  // Generate hs reversal map for ME1B
  wire [MXHS - 1: 0] cfeb0_ly0hsr, cfeb0_ly1hsr, cfeb0_ly2hsr, cfeb0_ly3hsr, cfeb0_ly4hsr, cfeb0_ly5hsr;
  wire [MXHS - 1: 0] cfeb1_ly0hsr, cfeb1_ly1hsr, cfeb1_ly2hsr, cfeb1_ly3hsr, cfeb1_ly4hsr, cfeb1_ly5hsr;
  wire [MXHS - 1: 0] cfeb2_ly0hsr, cfeb2_ly1hsr, cfeb2_ly2hsr, cfeb2_ly3hsr, cfeb2_ly4hsr, cfeb2_ly5hsr;
  wire [MXHS - 1: 0] cfeb3_ly0hsr, cfeb3_ly1hsr, cfeb3_ly2hsr, cfeb3_ly3hsr, cfeb3_ly4hsr, cfeb3_ly5hsr;
  wire [MXHS - 1: 0] cfeb4_ly0hsr, cfeb4_ly1hsr, cfeb4_ly2hsr, cfeb4_ly3hsr, cfeb4_ly4hsr, cfeb4_ly5hsr;

  generate
    for (ihs = 0; ihs <= MXHS - 1; ihs = ihs + 1) begin: hsrev
      assign cfeb0_ly0hsr[ihs] = cfeb0_ly0hs[(MXHS - 1) - ihs];
      assign cfeb0_ly1hsr[ihs] = cfeb0_ly1hs[(MXHS - 1) - ihs];
      assign cfeb0_ly2hsr[ihs] = cfeb0_ly2hs[(MXHS - 1) - ihs];
      assign cfeb0_ly3hsr[ihs] = cfeb0_ly3hs[(MXHS - 1) - ihs];
      assign cfeb0_ly4hsr[ihs] = cfeb0_ly4hs[(MXHS - 1) - ihs];
      assign cfeb0_ly5hsr[ihs] = cfeb0_ly5hs[(MXHS - 1) - ihs];

      assign cfeb1_ly0hsr[ihs] = cfeb1_ly0hs[(MXHS - 1) - ihs];
      assign cfeb1_ly1hsr[ihs] = cfeb1_ly1hs[(MXHS - 1) - ihs];
      assign cfeb1_ly2hsr[ihs] = cfeb1_ly2hs[(MXHS - 1) - ihs];
      assign cfeb1_ly3hsr[ihs] = cfeb1_ly3hs[(MXHS - 1) - ihs];
      assign cfeb1_ly4hsr[ihs] = cfeb1_ly4hs[(MXHS - 1) - ihs];
      assign cfeb1_ly5hsr[ihs] = cfeb1_ly5hs[(MXHS - 1) - ihs];

      assign cfeb2_ly0hsr[ihs] = cfeb2_ly0hs[(MXHS - 1) - ihs];
      assign cfeb2_ly1hsr[ihs] = cfeb2_ly1hs[(MXHS - 1) - ihs];
      assign cfeb2_ly2hsr[ihs] = cfeb2_ly2hs[(MXHS - 1) - ihs];
      assign cfeb2_ly3hsr[ihs] = cfeb2_ly3hs[(MXHS - 1) - ihs];
      assign cfeb2_ly4hsr[ihs] = cfeb2_ly4hs[(MXHS - 1) - ihs];
      assign cfeb2_ly5hsr[ihs] = cfeb2_ly5hs[(MXHS - 1) - ihs];

      assign cfeb3_ly0hsr[ihs] = cfeb3_ly0hs[(MXHS - 1) - ihs];
      assign cfeb3_ly1hsr[ihs] = cfeb3_ly1hs[(MXHS - 1) - ihs];
      assign cfeb3_ly2hsr[ihs] = cfeb3_ly2hs[(MXHS - 1) - ihs];
      assign cfeb3_ly3hsr[ihs] = cfeb3_ly3hs[(MXHS - 1) - ihs];
      assign cfeb3_ly4hsr[ihs] = cfeb3_ly4hs[(MXHS - 1) - ihs];
      assign cfeb3_ly5hsr[ihs] = cfeb3_ly5hs[(MXHS - 1) - ihs];

      assign cfeb4_ly0hsr[ihs] = cfeb4_ly0hs[(MXHS - 1) - ihs];
      assign cfeb4_ly1hsr[ihs] = cfeb4_ly1hs[(MXHS - 1) - ihs];
      assign cfeb4_ly2hsr[ihs] = cfeb4_ly2hs[(MXHS - 1) - ihs];
      assign cfeb4_ly3hsr[ihs] = cfeb4_ly3hs[(MXHS - 1) - ihs];
      assign cfeb4_ly4hsr[ihs] = cfeb4_ly4hs[(MXHS - 1) - ihs];
      assign cfeb4_ly5hsr[ihs] = cfeb4_ly5hs[(MXHS - 1) - ihs];

    end
  endgenerate


// Reverse all CFEBs and reverse layers, fixed by Tao, 2019-07-16
  assign me234_ly5hs = {cfeb0_ly0hsr, cfeb1_ly0hsr, cfeb2_ly0hsr, cfeb3_ly0hsr, cfeb4_ly0hsr};
  assign me234_ly4hs = {cfeb0_ly1hsr, cfeb1_ly1hsr, cfeb2_ly1hsr, cfeb3_ly1hsr, cfeb4_ly1hsr};
  assign me234_ly3hs = {cfeb0_ly2hsr, cfeb1_ly2hsr, cfeb2_ly2hsr, cfeb3_ly2hsr, cfeb4_ly2hsr};
  assign me234_ly2hs = {cfeb0_ly3hsr, cfeb1_ly3hsr, cfeb2_ly3hsr, cfeb3_ly3hsr, cfeb4_ly3hsr};
  assign me234_ly1hs = {cfeb0_ly4hsr, cfeb1_ly4hsr, cfeb2_ly4hsr, cfeb3_ly4hsr, cfeb4_ly4hsr};
  assign me234_ly0hs = {cfeb0_ly5hsr, cfeb1_ly5hsr, cfeb2_ly5hsr, cfeb3_ly5hsr, cfeb4_ly5hsr};

//-------------------------------------------------------------------------------------------------------------------
// Stage 4A5: CSC_TYPE_X Undefined
//-------------------------------------------------------------------------------------------------------------------
`else
  initial $display ("CSC_TYPE Undefined. Halting.");
  $finish
`endif

//-------------------------------------------------------------------------------------------------------------------
// Stage 4B: Combine ME1A and ME1B into one 7-CFEB CSC
//
// ly0hs:   -1 00 | 00 01 02 03 04 05 06 07 ... 216 217 218 219 220 221 222 223 | 224 no shift
// ly1hs:   -1 00 | 00 01 02 03 04 05 06 07 ... 216 217 218 219 220 221 222 223 | 224 no shift
// ly2hs:   -1 00 | 00 01 02 03 04 05 06 07 ... 216 217 218 219 220 221 222 223 | 224 no shift, key layer 2
// ly3hs:   -1 00 | 00 01 02 03 04 05 06 07 ... 216 217 218 219 220 221 222 223 | 224 no shift
// ly4hs:   -1 00 | 00 01 02 03 04 05 06 07 ... 216 217 218 219 220 221 222 223 | 224 no shift
// ly5hs:   -1 00 | 00 01 02 03 04 05 06 07 ... 216 217 218 219 220 221 222 223 | 224 no shift
// Tao, ME1/1->MEX/1 add stagger feature
//-------------------------------------------------------------------------------------------------------------------
// Staggered layers
//-------------------------------------------------------------------------------------------------------------------
	parameter j=1;								// Shift negative array indexes positive

`ifdef STAGGER_HS_CSC
        assign stagger_hs_csc  = 1;    // 1 = Staggered CSC non-ME1

	wire [MXHSX-1+j:-0+j] ly0hs;
	wire [MXHSX-1+j:-1+j] ly1hs;
	wire [MXHSX-1+j:-0+j] ly2hs;				// key layer 2
	wire [MXHSX-1+j:-1+j] ly3hs;
	wire [MXHSX-1+j:-0+j] ly4hs;
	wire [MXHSX-1+j:-1+j] ly5hs;

	assign ly0hs = {      me234_ly0hs};		// Stagger correction
	assign ly1hs = {1'b0, me234_ly1hs};
	assign ly2hs = {      me234_ly2hs};     //key layer, no change
	assign ly3hs = {1'b0, me234_ly3hs};
	assign ly4hs = {      me234_ly4hs};
	assign ly5hs = {1'b0, me234_ly5hs};
`else
        assign stagger_hs_csc  = 0;    // 1 = Staggered CSC non-ME1
`endif

//-------------------------------------------------------------------------------------------------------------------
// Stage 4C:  Layer-trigger mode
//-------------------------------------------------------------------------------------------------------------------
  // Layer Trigger Mode, delay 1bx for FF
  reg [MXLY - 1: 0] layer_or_s0;

// JG: add CFEN_EN_FF req. here to prevent killed cfebs from firing the layer trigger
  always @(posedge clock) begin
	layer_or_s0[0] = |{cfeb4_ly0hs, cfeb3_ly0hs, cfeb2_ly0hs, cfeb1_ly0hs, cfeb0_ly0hs};
	layer_or_s0[1] = |{cfeb4_ly1hs, cfeb3_ly1hs, cfeb2_ly1hs, cfeb1_ly1hs, cfeb0_ly1hs};
	layer_or_s0[2] = |{cfeb4_ly2hs, cfeb3_ly2hs, cfeb2_ly2hs, cfeb1_ly2hs, cfeb0_ly2hs};
	layer_or_s0[3] = |{cfeb4_ly3hs, cfeb3_ly3hs, cfeb2_ly3hs, cfeb1_ly3hs, cfeb0_ly3hs};
	layer_or_s0[4] = |{cfeb4_ly4hs, cfeb3_ly4hs, cfeb2_ly4hs, cfeb1_ly4hs, cfeb0_ly4hs};
	layer_or_s0[5] = |{cfeb4_ly5hs, cfeb3_ly5hs, cfeb2_ly5hs, cfeb1_ly5hs, cfeb0_ly5hs};
  end


  // Sum number of layers hit into a binary pattern number
  wire [MXHITB - 1: 0] nlayers_hit_s0;
  wire                 layer_trig_s0;

  assign nlayers_hit_s0 = count1s( layer_or_s0[5: 0] );
  assign layer_trig_s0  = ( nlayers_hit_s0 >= lyr_thresh_pretrig_ff );

  // Delay 1bx more to coincide with pretrigger
  parameter dlya = 4'd0;
  srl16e_bbl #(1)      udlya0 ( .clock(clock), .ce(1'b1), .adr(dlya), .d(layer_trig_s0 ), .q(cfeb_layer_trig ) );
  srl16e_bbl #(MXHITB) udlya1 ( .clock(clock), .ce(1'b1), .adr(dlya), .d(nlayers_hit_s0), .q(cfeb_nlayers_hit) );
  srl16e_bbl #(MXLY)   udlya2 ( .clock(clock), .ce(1'b1), .adr(dlya), .d(layer_or_s0   ), .q(cfeb_layer_or   ) );
  //srl16e_bbl #(10)   udnhits( .clock(clock), .ce(1'b1), .adr(dlya), .d(nhits_trig_s0   ), .q(nhits_trig_pre   ) );

  // Delay 4bx to latch in time with 1st and 2nd clct, need to FF these again to align
  wire [MXLY - 1: 0]   hs_layer_or_dly;
  wire [MXHITB - 1: 0] hs_nlayers_hit_dly;

  parameter dlyb = 4'd3;
  srl16e_bbl #(1)      udlyb0 ( .clock(clock), .ce(1'b1), .adr(dlyb), .d(layer_trig_s0 ), .q(hs_layer_latch    ) );
  srl16e_bbl #(MXHITB) udlyb1 ( .clock(clock), .ce(1'b1), .adr(dlyb), .d(nlayers_hit_s0), .q(hs_nlayers_hit_dly) );
  srl16e_bbl #(1)      udlyb2 ( .clock(clock), .ce(1'b1), .adr(dlyb), .d(layer_trig_s0 ), .q(hs_layer_trig_dly ) );
  srl16e_bbl #(MXLY)   udlyb3 ( .clock(clock), .ce(1'b1), .adr(dlyb), .d(layer_or_s0   ), .q(hs_layer_or_dly   ) );
  //srl16e_bbl #(10)    udnhits2( .clock(clock), .ce(1'b1), .adr(dlya), .d(nhits_trig_s0 ), .q(nhits_trig_dly    ) );

//-------------------------------------------------------------------------------------------------------------------
// Stage 4D: 1/2-Strip Pattern Finder
// Finds number of hits in pattern templates for each key 1/2-strip.
//
//        hs 0123456789A
// ly0[10:0] xxxxxkxxxxx    5+1+5 =11
// ly1[ 7:3]    xxkxx       2+1+2 = 5
// ly2[ 5:5]      k         0+1+0 = 1
// ly3[ 7:3]    xxkxx       2+1+2 = 5
// ly4[ 9:1]  xxxxkxxxx     4+1+4 = 9
// ly5[10:0] xxxxxkxxxxx    5+1+5 =11
//
//                               11111111 11111
//                               55555555 66666
//       hs  54321 01234567      23456789 01234
// ly0[10:0] 00000|aaaaaaaa......bbbbbbbb|00000
// ly1[ 7:3]    00|aaaaaaaa......bbbbbbbb|00
// ly2[ 5:5]      |aaaaaaaa......bbbbbbbb|
// ly3[ 7:3]    00|aaaaaaaa......bbbbbbbb|00
// ly4[ 9:1]  0000|aaaaaaaa......bbbbbbbb|0000
// ly5[10:0] 00000|aaaaaaaa......bbbbbbbb|00000
//-------------------------------------------------------------------------------------------------------------------
// CCLUT v1 version:
//        hs 0123456789ABC
// ly0[10:0] xxxxxkxxxx     5+1+5 = 11
// ly1[ 9:1]  xxxxkxxx      4+1+4 = 9
// ly2[ 7:3]    xxkxx       2+1+2 = 5
// ly3[ 7:3]    xxkxx       2+1+2 = 5
// ly4[ 9:1]  xxxxkxxxxx    4+1+4 = 9
// ly5[10:0] xxxxxkxxxxxx   5+1+5 = 11
//
//                                11111111 11111
//                                55555555 66666
//       hs  654321 01234567      23456789 01234 
// ly0[10:0]  00000|aaaaaaaa......bbbbbbbb|00000
// ly1[ 7:3]   0000|aaaaaaaa......bbbbbbbb|0000
// ly2[ 5:5]     00|aaaaaaaa......bbbbbbbb|00
// ly3[ 7:3]     00|aaaaaaaa......bbbbbbbb|00
// ly4[ 9:1]   0000|aaaaaaaa......bbbbbbbb|0000
// ly5[10:0]  00000|aaaaaaaa......bbbbbbbb|00000


// CCLUT v2 version: with 11bits comparator code
//        hs 0123456789ABC
// ly0[10:0] xxxxxkxxxx     5+1+5 = 11
// ly1[ 7:3]  xxxxkxxx      4+1+4 = 9
// ly2[ 5:5]      k         0+1+0 = 1
// ly3[ 7:3]    xxkxx       2+1+2 = 5
// ly4[ 9:1]  xxxxkxxxxx    4+1+4 = 9
// ly5[10:0] xxxxxkxxxxxx   5+1+5 = 11
//
//                                11111111 11111
//                                55555555 66666
//       hs  654321 01234567      23456789 01234
// ly0[10:0]  00000|aaaaaaaa......bbbbbbbb|00000
// ly1[ 7:3]   0000|aaaaaaaa......bbbbbbbb|0000
// ly2[ 5:5]       |aaaaaaaa......bbbbbbbb|
// ly3[ 7:3]     00|aaaaaaaa......bbbbbbbb|00
// ly4[ 9:1]   0000|aaaaaaaa......bbbbbbbb|0000
// ly5[10:0]  00000|aaaaaaaa......bbbbbbbb|00000

//
//-------------------------------------------------------------------------------------------------------------------
// Staggered layers
//-------------------------------------------------------------------------------------------------------------------

// Create hs arrays with 0s padded at left and right csc edges
	parameter k=5;		// Shift negative array indexes positive

//-------------------------------------------------------------------------------------------------------------------
// CCLUT v2 version:
	wire [MXHSX-1+5+k:-5+k]  ly0hs_pad;
	wire [MXHSX-1+4+k:-4+k]  ly1hs_pad;
`ifdef CCLUT_V2
	wire [MXHSX-1+0+k:-0+k]  ly2hs_pad;//CCLUTv2
`else
	wire [MXHSX-1+2+k:-2+k]  ly2hs_pad;//CCLUTv1
`endif
	wire [MXHSX-1+2+k:-2+k]  ly3hs_pad;
	wire [MXHSX-1+4+k:-4+k]  ly4hs_pad;
	wire [MXHSX-1+5+k:-5+k]  ly5hs_pad;

`ifdef STAGGER_HS_CSC
// Pad 0s beyond csc edges: whole CSC
	assign ly0hs_pad = {5'b00000, ly0hs[MXHSX-1+j:j],              5'b00000};
	assign ly1hs_pad = {4'b0000,  ly1hs[MXHSX-1+j:j], ly1hs[-1+j], 3'b000  };
 `ifdef CCLUT_V2
	assign ly2hs_pad = {          ly2hs[MXHSX-1+j:j]                       };//CCLUTv2
 `else
	assign ly2hs_pad = {2'b00,    ly2hs[MXHSX-1+j:j],              2'b00   };//CCLUTv1
 `endif
	assign ly3hs_pad = {2'b00,    ly3hs[MXHSX-1+j:j], ly3hs[-1+j], 1'b0    };
	assign ly4hs_pad = {4'b0000,  ly4hs[MXHSX-1+j:j],              4'b0000 };
	assign ly5hs_pad = {5'b00000, ly5hs[MXHSX-1+j:j], ly5hs[-1+j], 4'b0000 };

`else
	assign ly0hs_pad = {5'b00000, me234_ly0hs[MXHSX-1:0], 5'b00000};
	assign ly1hs_pad = {4'b0000,  me234_ly1hs[MXHSX-1:0], 4'b0000 };
 `ifdef CCLUT_V2
	assign ly2hs_pad = {          me234_ly2hs[MXHSX-1:0]          };//CCLUTv2
 `else
	assign ly2hs_pad = {2'b00,    me234_ly2hs[MXHSX-1:0], 2'b00   };//CCLUTv1
 `endif
	assign ly3hs_pad = {2'b00,    me234_ly3hs[MXHSX-1:0], 2'b00   };
	assign ly4hs_pad = {4'b0000,  me234_ly4hs[MXHSX-1:0], 4'b0000 };
	assign ly5hs_pad = {5'b00000, me234_ly5hs[MXHSX-1:0], 5'b00000};
`endif

// Find pattern hits for each 1/2-strip key
	wire [MXHITB-1:0] hs_hit [MXHSX-1:0];
	wire [MXPIDB-1:0] hs_pid [MXHSX-1:0];
        wire [MXPATC - 1: 0] hs_carry [MXHSX - 1: 0]; //Tao CCLUT, carry->comparator code 

 `ifdef CCLUT_V2
	generate
	for (ihs=0; ihs<=MXHSX-1; ihs=ihs+1) begin: patgen
	    pattern_unit_ccLUTv2 upat (
	    .ly0 (ly0hs_pad[ihs + 5 + k: ihs - 5 + k]),
	    .ly1 (ly1hs_pad[ihs + 4 + k: ihs - 4 + k]),
	    .ly2 (ly2hs_pad[ihs + 0 + k: ihs - 0 + k]),	//key on ly2, CCLUT v2, 11bits comparator code
            .ly3 (ly3hs_pad[ihs + 2 + k: ihs - 2 + k]),
            .ly4 (ly4hs_pad[ihs + 4 + k: ihs - 4 + k]),
            .ly5 (ly5hs_pad[ihs + 5 + k: ihs - 5 + k]),
            .pat_nhits (hs_hit[ihs]),
            .pat_id (hs_pid[ihs]), //pid range 6-10
            .pat_carry (hs_carry[ihs]));
        end
       endgenerate
 `else
	generate
	for (ihs=0; ihs<=MXHSX-1; ihs=ihs+1) begin: patgen
	    pattern_unit_ccLUT upat (
	    .ly0 (ly0hs_pad[ihs + 5 + k: ihs - 5 + k]),
	    .ly1 (ly1hs_pad[ihs + 4 + k: ihs - 4 + k]),
            .ly2 (ly2hs_pad[ihs + 2 + k: ihs - 2 + k]),	//key on ly2, CCLUT v1, 12bits comparator code
            .ly3 (ly3hs_pad[ihs + 2 + k: ihs - 2 + k]),
            .ly4 (ly4hs_pad[ihs + 4 + k: ihs - 4 + k]),
            .ly5 (ly5hs_pad[ihs + 5 + k: ihs - 5 + k]),
            .pat_nhits (hs_hit[ihs]),
            .pat_id (hs_pid[ihs]), //pid range 6-10
            .pat_carry (hs_carry[ihs]));
        end
       endgenerate
 `endif

// before CCLUT, Tao
//`ifdef STAGGER_HS_CSC
//// Pad 0s beyond csc edges: whole CSC
//	assign ly0hs_pad = {5'b00000, ly0hs[MXHSX-1+j:j],              5'b00000};
//	assign ly1hs_pad = {2'b00,    ly1hs[MXHSX-1+j:j], ly1hs[-1+j], 1'b0    };
//	assign ly2hs_pad = {          ly2hs[MXHSX-1+j:j]                       };
//	assign ly3hs_pad = {2'b00,    ly3hs[MXHSX-1+j:j], ly3hs[-1+j], 1'b0    };
//	assign ly4hs_pad = {4'b0000,  ly4hs[MXHSX-1+j:j],              4'b0000 };
//	assign ly5hs_pad = {5'b00000, ly5hs[MXHSX-1+j:j], ly5hs[-1+j], 4'b0000 };
//
//`else
//	assign ly0hs_pad = {5'b00000, me234_ly0hs[MXHSX-1:0], 5'b00000};
//	assign ly1hs_pad = {2'b00,    me234_ly1hs[MXHSX-1:0], 2'b00   };
//	assign ly2hs_pad = {          me234_ly2hs[MXHSX-1:0]          };
//	assign ly3hs_pad = {2'b00,    me234_ly3hs[MXHSX-1:0], 2'b00   };
//	assign ly4hs_pad = {4'b0000,  me234_ly4hs[MXHSX-1:0], 4'b0000 };
//	assign ly5hs_pad = {5'b00000, me234_ly5hs[MXHSX-1:0], 5'b00000};
//`endif
//
//// Find pattern hits for each 1/2-strip key
//	wire [MXHITB-1:0] hs_hit [MXHSX-1:0];
//	wire [MXPIDB-1:0] hs_pid [MXHSX-1:0];
//
//	generate
//	for (ihs=0; ihs<=MXHSX-1; ihs=ihs+1) begin: patgen
//	    pattern_unit upat (
//	    .ly0 (ly0hs_pad[ihs + 5 + k: ihs - 5 + k]),
//	    .ly1 (ly1hs_pad[ihs + 2 + k: ihs - 2 + k]),
//	    .ly2 (ly2hs_pad[ihs + 0 + k: ihs - 0 + k]),	//key on ly2
//          .ly3 (ly3hs_pad[ihs + 2 + k: ihs - 2 + k]),
//          .ly4 (ly4hs_pad[ihs + 4 + k: ihs - 4 + k]),
//          .ly5 (ly5hs_pad[ihs + 5 + k: ihs - 5 + k]),
//          .pat_nhits (hs_hit[ihs]),
//          .pat_id (hs_pid[ihs]));
//        end
//       endgenerate

  // Store Pattern Unit results
  reg [MXHITB - 1: 0] hs_hit_s0ab [MXHSX - 1: 0];
  reg [MXPIDB - 1: 0] hs_pid_s0ab [MXHSX - 1: 0];
  reg [MXPATC - 1: 0] hs_carry_s0ab [MXHSX - 1: 0];//CCLUT, Tao

  generate
    for (ihs = 0; ihs <= MXHSX - 1; ihs = ihs + 1) begin: store_ab
      always @(posedge clock) begin
// JG: add cfeb_en requirement to prevent triggers from killed boards
// Tao ME1/1->MEX/1, now type_c: normal; type_d: reversed
`ifdef CSC_TYPE_A
           hs_hit_s0ab[ihs] <= cfeb_en_ff[ihs/MXHS] ? hs_hit[ihs] : 3'b0;
           hs_pid_s0ab[ihs] <= cfeb_en_ff[ihs/MXHS] ? hs_pid[ihs] : 4'b0;
           hs_carry_s0ab[ihs] <= cfeb_en_ff[(ihs/MXHS)] ? hs_carry[ihs] : 12'b0;
`elsif CSC_TYPE_B
           hs_hit_s0ab[ihs] <= cfeb_en_ff[MXCFEB-1-ihs/MXHS] ? hs_hit[ihs] : 3'b0;
           hs_pid_s0ab[ihs] <= cfeb_en_ff[MXCFEB-1-ihs/MXHS] ? hs_pid[ihs] : 4'b0;
           hs_carry_s0ab[ihs] <= cfeb_en_ff[MXCFEB-1-(ihs/MXHS)] ? hs_carry[ihs] : 12'b0;
`endif
      end
    end
  endgenerate

  // S0 latch: realign with main clock, legacy to maintain sequencer timing
  reg [MXHITB - 1: 0] hs_hit_s0 [MXHSX - 1: 0];
  reg [MXPIDB - 1: 0] hs_pid_s0 [MXHSX - 1: 0];
  reg [MXPATC - 1: 0] hs_carry_s0 [MXHSX - 1: 0];//CCLUT, Tao
  generate
    for (ihs = 0; ihs <= MXHSX - 1; ihs = ihs + 1) begin: store_s0
      always @(posedge clock) begin
        hs_hit_s0[ihs] <= (algo2016_use_dead_time_zone & hs_dead_drift[ihs]) ?    3'b0 : hs_hit_s0ab[ihs];
        hs_pid_s0[ihs] <= (algo2016_use_dead_time_zone & hs_dead_drift[ihs]) ?    4'b0 : hs_pid_s0ab[ihs];
        hs_carry_s0[ihs] <= (algo2016_use_dead_time_zone & hs_dead_drift[ihs]) ? 12'b0 : hs_carry_s0ab[ihs];
      end
    end
  endgenerate

  // Convert s0 pattern IDs and hits into sort-able pattern numbers, [6:4]=nhits, [3:0]=pattern id
  wire [MXPATB - 1: 0] hs_pat_s0 [MXHSX - 1: 0];
  generate
    for (ihs = 0; ihs <= MXHSX - 1; ihs = ihs + 1) begin: patcat
      assign hs_pat_s0[ihs] = {hs_hit_s0[ihs], hs_pid_s0[ihs]};
    end
  endgenerate

//-------------------------------------------------------------------------------------------------------------------
// Stage 5A: Pre-Trigger Look-ahead
//    Set active FEB bit ASAP if any pattern is over threshold.
//    It comes out before the priority encoder result
//-------------------------------------------------------------------------------------------------------------------
  // Flag keys with pattern hits over threshold, use fast-out hit numbers before s0 latch
  reg [MXHS - 1: 0] hs_key_hit0, hs_key_pid0, hs_key_dmb0;
  reg [MXHS - 1: 0] hs_key_hit1, hs_key_pid1, hs_key_dmb1;
  reg [MXHS - 1: 0] hs_key_hit2, hs_key_pid2, hs_key_dmb2;
  reg [MXHS - 1: 0] hs_key_hit3, hs_key_pid3, hs_key_dmb3;
  reg [MXHS - 1: 0] hs_key_hit4, hs_key_pid4, hs_key_dmb4;
  //Tao, ME1/1->MEX/1
  //reg [MXHS - 1: 0] hs_key_hit5, hs_key_pid5, hs_key_dmb5;
  //reg [MXHS - 1: 0] hs_key_hit6, hs_key_pid6, hs_key_dmb6;

  // Display CSC_TYPE
`ifdef CSC_TYPE_A initial $display ("CSC_TYPE_A is defined for pre-trigger look-ahead"); `endif
`ifdef CSC_TYPE_B initial $display ("CSC_TYPE_B is defined for pre-trigger look-ahead"); `endif
`ifdef CSC_TYPE_C initial $display ("CSC_TYPE_C is defined for pre-trigger look-ahead"); `endif
`ifdef CSC_TYPE_D initial $display ("CSC_TYPE_D is defined for pre-trigger look-ahead"); `endif

// Flag keys with pattern hits over threshold, use fast-out hit numbers before s0 latch
// JGhere: mask off dead channels from recent hits; need to bring in  "algo2016_use_dead_time_zone" signal to enable
  generate
    for (ihs = 0; ihs <= MXHS - 1; ihs = ihs + 1) begin: thrg
      always @(posedge clock) begin: thrff
       `ifdef CSC_TYPE_A
        // Normal ME234/1
        hs_key_hit0[ihs] = (hs_hit_s0ab[ihs + MXHS*0]   >= hit_thresh_pretrig_ff) && !(algo2016_use_dead_time_zone & hs_key_dead[ihs + MXHS*0]); // Normal 
        hs_key_hit1[ihs] = (hs_hit_s0ab[ihs + MXHS*1]   >= hit_thresh_pretrig_ff) && !(algo2016_use_dead_time_zone & hs_key_dead[ihs + MXHS*1]);
        hs_key_hit2[ihs] = (hs_hit_s0ab[ihs + MXHS*2]   >= hit_thresh_pretrig_ff) && !(algo2016_use_dead_time_zone & hs_key_dead[ihs + MXHS*2]);
        hs_key_hit3[ihs] = (hs_hit_s0ab[ihs + MXHS*3]   >= hit_thresh_pretrig_ff) && !(algo2016_use_dead_time_zone & hs_key_dead[ihs + MXHS*3]);
        hs_key_hit4[ihs] = (hs_hit_s0ab[ihs + MXHS*4]   >= hit_thresh_pretrig_ff) && !(algo2016_use_dead_time_zone & hs_key_dead[ihs + MXHS*4]);

        hs_key_pid0[ihs] = (hs_pid_s0ab[ihs + MXHS*0]   >= pid_thresh_pretrig_ff) && !(algo2016_use_dead_time_zone & hs_key_dead[ihs + MXHS*0]); // Normal 
        hs_key_pid1[ihs] = (hs_pid_s0ab[ihs + MXHS*1]   >= pid_thresh_pretrig_ff) && !(algo2016_use_dead_time_zone & hs_key_dead[ihs + MXHS*1]);
        hs_key_pid2[ihs] = (hs_pid_s0ab[ihs + MXHS*2]   >= pid_thresh_pretrig_ff) && !(algo2016_use_dead_time_zone & hs_key_dead[ihs + MXHS*2]);
        hs_key_pid3[ihs] = (hs_pid_s0ab[ihs + MXHS*3]   >= pid_thresh_pretrig_ff) && !(algo2016_use_dead_time_zone & hs_key_dead[ihs + MXHS*3]);
        hs_key_pid4[ihs] = (hs_pid_s0ab[ihs + MXHS*4]   >= pid_thresh_pretrig_ff) && !(algo2016_use_dead_time_zone & hs_key_dead[ihs + MXHS*4]);

        hs_key_dmb0[ihs] = (hs_hit_s0ab[ihs + MXHS*0]   >= dmb_thresh_pretrig_ff) && !(algo2016_use_dead_time_zone & hs_key_dead[ihs + MXHS*0]); // Normal 
        hs_key_dmb1[ihs] = (hs_hit_s0ab[ihs + MXHS*1]   >= dmb_thresh_pretrig_ff) && !(algo2016_use_dead_time_zone & hs_key_dead[ihs + MXHS*1]);
        hs_key_dmb2[ihs] = (hs_hit_s0ab[ihs + MXHS*2]   >= dmb_thresh_pretrig_ff) && !(algo2016_use_dead_time_zone & hs_key_dead[ihs + MXHS*2]);
        hs_key_dmb3[ihs] = (hs_hit_s0ab[ihs + MXHS*3]   >= dmb_thresh_pretrig_ff) && !(algo2016_use_dead_time_zone & hs_key_dead[ihs + MXHS*3]);
        hs_key_dmb4[ihs] = (hs_hit_s0ab[ihs + MXHS*4]   >= dmb_thresh_pretrig_ff) && !(algo2016_use_dead_time_zone & hs_key_dead[ihs + MXHS*4]);

       `elsif CSC_TYPE_B
         // Reversed ME234/1
        hs_key_hit0[ihs] = (hs_hit_s0ab[MXHS*5 -1 -ihs] >= hit_thresh_pretrig_ff) && !(algo2016_use_dead_time_zone & hs_key_dead[MXHS*5 -1 -ihs]); // Reversed ME1B
        hs_key_hit1[ihs] = (hs_hit_s0ab[MXHS*4 -1 -ihs] >= hit_thresh_pretrig_ff) && !(algo2016_use_dead_time_zone & hs_key_dead[MXHS*4 -1 -ihs]);
        hs_key_hit2[ihs] = (hs_hit_s0ab[MXHS*3 -1 -ihs] >= hit_thresh_pretrig_ff) && !(algo2016_use_dead_time_zone & hs_key_dead[MXHS*3 -1 -ihs]);
        hs_key_hit3[ihs] = (hs_hit_s0ab[MXHS*2 -1 -ihs] >= hit_thresh_pretrig_ff) && !(algo2016_use_dead_time_zone & hs_key_dead[MXHS*2 -1 -ihs]);
        hs_key_hit4[ihs] = (hs_hit_s0ab[MXHS*1 -1 -ihs] >= hit_thresh_pretrig_ff) && !(algo2016_use_dead_time_zone & hs_key_dead[MXHS*1 -1 -ihs]);

        hs_key_pid0[ihs] = (hs_pid_s0ab[MXHS*5 -1 -ihs] >= pid_thresh_pretrig_ff) && !(algo2016_use_dead_time_zone & hs_key_dead[MXHS*5 -1 -ihs]); // Reversed
        hs_key_pid1[ihs] = (hs_pid_s0ab[MXHS*4 -1 -ihs] >= pid_thresh_pretrig_ff) && !(algo2016_use_dead_time_zone & hs_key_dead[MXHS*4 -1 -ihs]);
        hs_key_pid2[ihs] = (hs_pid_s0ab[MXHS*3 -1 -ihs] >= pid_thresh_pretrig_ff) && !(algo2016_use_dead_time_zone & hs_key_dead[MXHS*3 -1 -ihs]);
        hs_key_pid3[ihs] = (hs_pid_s0ab[MXHS*2 -1 -ihs] >= pid_thresh_pretrig_ff) && !(algo2016_use_dead_time_zone & hs_key_dead[MXHS*2 -1 -ihs]);
        hs_key_pid4[ihs] = (hs_pid_s0ab[MXHS*1 -1 -ihs] >= pid_thresh_pretrig_ff) && !(algo2016_use_dead_time_zone & hs_key_dead[MXHS*1 -1 -ihs]);

        hs_key_dmb0[ihs] = (hs_hit_s0ab[MXHS*5 -1 -ihs] >= dmb_thresh_pretrig_ff) && !(algo2016_use_dead_time_zone & hs_key_dead[MXHS*5 -1 -ihs]); // Reversed
        hs_key_dmb1[ihs] = (hs_hit_s0ab[MXHS*4 -1 -ihs] >= dmb_thresh_pretrig_ff) && !(algo2016_use_dead_time_zone & hs_key_dead[MXHS*4 -1 -ihs]);
        hs_key_dmb2[ihs] = (hs_hit_s0ab[MXHS*3 -1 -ihs] >= dmb_thresh_pretrig_ff) && !(algo2016_use_dead_time_zone & hs_key_dead[MXHS*3 -1 -ihs]);
        hs_key_dmb3[ihs] = (hs_hit_s0ab[MXHS*2 -1 -ihs] >= dmb_thresh_pretrig_ff) && !(algo2016_use_dead_time_zone & hs_key_dead[MXHS*2 -1 -ihs]);
        hs_key_dmb4[ihs] = (hs_hit_s0ab[MXHS*1 -1 -ihs] >= dmb_thresh_pretrig_ff) && !(algo2016_use_dead_time_zone & hs_key_dead[MXHS*1 -1 -ihs]);
      
       `else
          initial $display ("CSC_TYPE Undefined. Halting.");
          $finish
       `endif
      end
    end
  endgenerate

// JGhere: begin algo2016_use_dead_time_zone definition section; mark hit key HS busy and include nearby strips in deadzone
  parameter  dead_span = 4;  // Defines how far the deadzone extends from the key HS
//  parameter  DEADSPAN = 4'd6;  // Default size for the deadzone, in HS
//  wire [3:0] dead_span = (algo2016_dead_time_zone_size == 0) ? DEADSPAN : algo2016_dead_time_zone_size[4:1];// the span is just half of the dead time zone size  -- not allowed by ISE!  needs to be constant...
  reg  [MXKEYX - 1: 0] hs_key_busyAB = 0; // set if this key HS was hit
  wire [MXKEYX - 1: 0] hs_key_dead;       // set if this key HS was near a hit HS
  wire [MXKEYX - 1: 0] hs_dead_drift;     // drift-delayed copy of hs_key_dead

  //Tao, ME1/1->MEX/1, MXHSXB-> MXKEYX here
  generate  // for ME1b
    for (ihs = 0; ihs <= MXKEYX-1; ihs = ihs + 1) begin: busyg_me234  // JG: gives 0, 127 here., Tao => MXKEYX for ME234
      always @(posedge clock) begin: busyff_me234  // JG: think about negedge... but don't kill a HS before it triggers
        hs_key_busyAB[ihs] = ((hs_hit_s0ab[ihs] >= hit_thresh_pretrig_ff) &   // JG, require pretrig thresh to mark busy
			      (hs_pid_s0ab[ihs] >= pid_thresh_pretrig_ff)) || (layer_trig_en_ff & layer_trig_s0); // JG: Is this OK? Here?
      end
// JG: for every HS, apply the dead signal if it's near the key HS; simple OR, but watch for chamber edge limits
      if (ihs >= dead_span && ihs <= (MXKEYX-1-dead_span)) assign hs_key_dead[ihs] = |hs_key_busyAB[(ihs+dead_span):(ihs-dead_span)]; //
      else if (ihs < dead_span) assign hs_key_dead[ihs] = |hs_key_busyAB[(ihs+dead_span):0]; // 5:0
      else  assign hs_key_dead[ihs] = |hs_key_busyAB[(MXKEYX-1):(ihs-dead_span)]; // 159:154
    end
  endgenerate

// JG: delay the dead zone to apply it on hs_hit/pid arrays going into the best_1of logic after the drift time
  wire [3:0]         drift_adr;
  assign drift_adr = drift_delay - 4'b1;
  srl16e_bbl #(MXKEYX) deadzone_drift (.clock(clock),.ce(1'b1),.adr(drift_adr),.d(hs_key_dead),.q(hs_dead_drift));


  // Output active FEB signal, and adjacent FEBs if hit is near board boundary
  wire [6: 1] cfebnm1_dmb;  // Adjacent CFEB-1 has a pattern over threshold, there is no CFEB0-1
  wire [5: 0] cfebnp1_dmb;  // Adjacent CFEB+1 has a pattern over threshold, there is no CFEB6+1
  wire [MXCFEB - 1: 0] cfeb_dmb; // This CFEB has a pattern over DMB-trigger threshold

  wire [MXHS - 1: 0] hs_key_hitpid0 = hs_key_hit0 & hs_key_pid0; // hits on key satisfy both hit and pid thresholds
  wire [MXHS - 1: 0] hs_key_hitpid1 = hs_key_hit1 & hs_key_pid1;
  wire [MXHS - 1: 0] hs_key_hitpid2 = hs_key_hit2 & hs_key_pid2;
  wire [MXHS - 1: 0] hs_key_hitpid3 = hs_key_hit3 & hs_key_pid3;
  wire [MXHS - 1: 0] hs_key_hitpid4 = hs_key_hit4 & hs_key_pid4;

  wire [MXHS - 1: 0] hs_key_dmbpid0 = hs_key_dmb0 & hs_key_pid0; // hits on key satisfy both dmb and pid thresholds, but not used.
  wire [MXHS - 1: 0] hs_key_dmbpid1 = hs_key_dmb1 & hs_key_pid1;
  wire [MXHS - 1: 0] hs_key_dmbpid2 = hs_key_dmb2 & hs_key_pid2;
  wire [MXHS - 1: 0] hs_key_dmbpid3 = hs_key_dmb3 & hs_key_pid3;
  wire [MXHS - 1: 0] hs_key_dmbpid4 = hs_key_dmb4 & hs_key_pid4;

  wire cfeb_layer_trigger = cfeb_layer_trig && layer_trig_en_ff;

// JG: TMB algo uses these bits to set clct_pretrig_rqst...
  assign cfeb_hit[0] = ( ( | hs_key_hitpid0) || cfeb_layer_trigger ) && cfeb_en_ff[0];
  assign cfeb_hit[1] = ( ( | hs_key_hitpid1) || cfeb_layer_trigger ) && cfeb_en_ff[1];
  assign cfeb_hit[2] = ( ( | hs_key_hitpid2) || cfeb_layer_trigger ) && cfeb_en_ff[2];
  assign cfeb_hit[3] = ( ( | hs_key_hitpid3) || cfeb_layer_trigger ) && cfeb_en_ff[3];
  assign cfeb_hit[4] = ( ( | hs_key_hitpid4) || cfeb_layer_trigger ) && cfeb_en_ff[4];

// JGhere: OLD Bug Fix! add logic to cleanly separate the pretrig levels from the dmb/cfeb_active levels...
  assign cfeb_dmb[0] = ( ( | hs_key_dmb0) || cfeb_layer_trigger ) && cfeb_en_ff[0];
  assign cfeb_dmb[1] = ( ( | hs_key_dmb1) || cfeb_layer_trigger ) && cfeb_en_ff[1];
  assign cfeb_dmb[2] = ( ( | hs_key_dmb2) || cfeb_layer_trigger ) && cfeb_en_ff[2];
  assign cfeb_dmb[3] = ( ( | hs_key_dmb3) || cfeb_layer_trigger ) && cfeb_en_ff[3];
  assign cfeb_dmb[4] = ( ( | hs_key_dmb4) || cfeb_layer_trigger ) && cfeb_en_ff[4];

  //Tao, ME1/1->MEX/1
// JGhere: OLD Bug Fix! add cfeb_en requirement to trigger a neighbor cfeb...
  assign cfebnm1_dmb[1] = | (hs_key_dmb1 & adjcfeb_mask_nm1) && cfeb_en_ff[1]; // cfeb1 has hits near cfeb0
  assign cfebnm1_dmb[2] = | (hs_key_dmb2 & adjcfeb_mask_nm1) && cfeb_en_ff[2]; // cfeb2 has hits near cfeb1
  assign cfebnm1_dmb[3] = | (hs_key_dmb3 & adjcfeb_mask_nm1) && cfeb_en_ff[3]; // cfeb3 has hits near cfeb2
  assign cfebnm1_dmb[4] = | (hs_key_dmb4 & adjcfeb_mask_nm1) && cfeb_en_ff[4]; // cfeb3 has hits near cfeb3
// JGhere: OLD Bug Fix! add cfeb_en requirement to trigger a neighbor cfeb...
  assign cfebnp1_dmb[0] = | (hs_key_dmb0 & adjcfeb_mask_np1) && cfeb_en_ff[0]; // cfeb0 has hits near cfeb1
  assign cfebnp1_dmb[1] = | (hs_key_dmb1 & adjcfeb_mask_np1) && cfeb_en_ff[1]; // cfeb1 has hits near cfeb2
  assign cfebnp1_dmb[2] = | (hs_key_dmb2 & adjcfeb_mask_np1) && cfeb_en_ff[2]; // cfeb2 has hits near cfeb3
  assign cfebnp1_dmb[3] = | (hs_key_dmb3 & adjcfeb_mask_np1) && cfeb_en_ff[3]; // cfeb2 has hits near cfeb3

  // Output active FEB signal, and adjacent FEBs if hit is near board boundary
// JGhere: OLD Bug Fix! fix logic to cleanly separate the pretrig levels from the dmb/cfeb_active levels...
  assign cfeb_active[0] = (cfebnm1_dmb[1] || cfeb_dmb[0]                   );
  assign cfeb_active[1] = (cfebnm1_dmb[2] || cfeb_dmb[1] || cfebnp1_dmb[0] );
  assign cfeb_active[2] = (cfebnm1_dmb[3] || cfeb_dmb[2] || cfebnp1_dmb[1] );
  assign cfeb_active[3] = (cfebnm1_dmb[4] || cfeb_dmb[3] || cfebnp1_dmb[2] );
  assign cfeb_active[4] = (                  cfeb_dmb[4] || cfebnp1_dmb[3] );

//-------------------------------------------------------------------------------------------------------------------
// Stage 5B: 1/2-Strip Priority Encoder
//     Select the 1st best pattern from 224 Key 1/2-Strips
//-------------------------------------------------------------------------------------------------------------------
  // Best 7 of 224 1/2-strip patterns
  wire [MXPATB - 1: 0] hs_pat_s1_tmp [MXCFEB-1 : 0];
  wire [MXPATB - 1: 0] hs_pat_s1 [MXCFEB-1 : 0];
  wire [MXKEYB - 1: 0] hs_key_s1 [MXCFEB-1 : 0]; // partial key for 1 of 32
  wire [MXPATC-1:0]    hs_carry_s1 [MXCFEB-1 :0]; //CCLUT, Tao, comparator code
  wire [MXOFFSB -1:0]  hs_offs_s1  [MXCFEB-1 :0]; //keyhs offset, CCLUT
  wire [MXBNDB-1:0]    hs_bend_s1  [MXCFEB-1 :0]; // bending , CCLUT
  //CCLUT, Tao, new 1/32 sorter with comparator code
  genvar i;
  generate
    for (i = 0; i <= MXCFEB-1; i = i + 1) begin: hs_gen
      assign hs_pat_s1[i] = hs_pat_s1_tmp[i]-4'd6;// subtract pattern id by 4 to revert patid back to 0-4
      best_1of32_ccLUT ubest1of32_1st (
        .clock(clock),
        .pat00(hs_pat_s0[i * 32 +  0]),
        .pat01(hs_pat_s0[i * 32 +  1]),
        .pat02(hs_pat_s0[i * 32 +  2]),
        .pat03(hs_pat_s0[i * 32 +  3]),
        .pat04(hs_pat_s0[i * 32 +  4]),
        .pat05(hs_pat_s0[i * 32 +  5]),
        .pat06(hs_pat_s0[i * 32 +  6]),
        .pat07(hs_pat_s0[i * 32 +  7]),
        .pat08(hs_pat_s0[i * 32 +  8]),
        .pat09(hs_pat_s0[i * 32 +  9]),
        .pat10(hs_pat_s0[i * 32 + 10]),
        .pat11(hs_pat_s0[i * 32 + 11]),
        .pat12(hs_pat_s0[i * 32 + 12]),
        .pat13(hs_pat_s0[i * 32 + 13]),
        .pat14(hs_pat_s0[i * 32 + 14]),
        .pat15(hs_pat_s0[i * 32 + 15]),
        .pat16(hs_pat_s0[i * 32 + 16]),
        .pat17(hs_pat_s0[i * 32 + 17]),
        .pat18(hs_pat_s0[i * 32 + 18]),
        .pat19(hs_pat_s0[i * 32 + 19]),
        .pat20(hs_pat_s0[i * 32 + 20]),
        .pat21(hs_pat_s0[i * 32 + 21]),
        .pat22(hs_pat_s0[i * 32 + 22]),
        .pat23(hs_pat_s0[i * 32 + 23]),
        .pat24(hs_pat_s0[i * 32 + 24]),
        .pat25(hs_pat_s0[i * 32 + 25]),
        .pat26(hs_pat_s0[i * 32 + 26]),
        .pat27(hs_pat_s0[i * 32 + 27]),
        .pat28(hs_pat_s0[i * 32 + 28]),
        .pat29(hs_pat_s0[i * 32 + 29]),
        .pat30(hs_pat_s0[i * 32 + 30]),
        .pat31(hs_pat_s0[i * 32 + 31]),
        // Hit Carry
        .carry00(hs_carry_s0[i * 32 +  0]),
        .carry01(hs_carry_s0[i * 32 +  1]),
        .carry02(hs_carry_s0[i * 32 +  2]),
        .carry03(hs_carry_s0[i * 32 +  3]),
        .carry04(hs_carry_s0[i * 32 +  4]),
        .carry05(hs_carry_s0[i * 32 +  5]),
        .carry06(hs_carry_s0[i * 32 +  6]),
        .carry07(hs_carry_s0[i * 32 +  7]),
        .carry08(hs_carry_s0[i * 32 +  8]),
        .carry09(hs_carry_s0[i * 32 +  9]),
        .carry10(hs_carry_s0[i * 32 + 10]),
        .carry11(hs_carry_s0[i * 32 + 11]),
        .carry12(hs_carry_s0[i * 32 + 12]),
        .carry13(hs_carry_s0[i * 32 + 13]),
        .carry14(hs_carry_s0[i * 32 + 14]),
        .carry15(hs_carry_s0[i * 32 + 15]),
        .carry16(hs_carry_s0[i * 32 + 16]),
        .carry17(hs_carry_s0[i * 32 + 17]),
        .carry18(hs_carry_s0[i * 32 + 18]),
        .carry19(hs_carry_s0[i * 32 + 19]),
        .carry20(hs_carry_s0[i * 32 + 20]),
        .carry21(hs_carry_s0[i * 32 + 21]),
        .carry22(hs_carry_s0[i * 32 + 22]),
        .carry23(hs_carry_s0[i * 32 + 23]),
        .carry24(hs_carry_s0[i * 32 + 24]),
        .carry25(hs_carry_s0[i * 32 + 25]),
        .carry26(hs_carry_s0[i * 32 + 26]),
        .carry27(hs_carry_s0[i * 32 + 27]),
        .carry28(hs_carry_s0[i * 32 + 28]),
        .carry29(hs_carry_s0[i * 32 + 29]),
        .carry30(hs_carry_s0[i * 32 + 30]),
        .carry31(hs_carry_s0[i * 32 + 31]),
        // Outputs
        .best_pat   (hs_pat_s1_tmp[i]),
        .best_key   (hs_key_s1[i]),
        .best_carry (hs_carry_s1[i])
      );
    end
  endgenerate



  // Best 1 of 5 HalfStrip patterns
  wire [MXPATB - 1: 0]  hs_pat_s2;
  wire [MXKEYBX - 1: 0] hs_key_s2;  // full key for 1 of 224
  wire [MXXKYB - 1:0]   hs_xky_s2; // CCLUT, Tao
  wire [MXBNDB - 1:0]   hs_bnd_s2;
  wire [MXPATC - 1:0]   hs_car_s2; //hit carry, comparator code

  best_1of5_ccLUT #(.PATLUT(PATLUT))
  ubest1of5_1st (
  // pattern inputs
    .pat0(hs_pat_s1[0]),
    .pat1(hs_pat_s1[1]),
    .pat2(hs_pat_s1[2]),
    .pat3(hs_pat_s1[3]),
    .pat4(hs_pat_s1[4]),
  // key hs inputs
    .key0(hs_key_s1[0]),
    .key1(hs_key_s1[1]),
    .key2(hs_key_s1[2]),
    .key3(hs_key_s1[3]),
    .key4(hs_key_s1[4]),
  // carry inputs from fit lut
    .carry0(hs_carry_s1[0]),
    .carry1(hs_carry_s1[1]),
    .carry2(hs_carry_s1[2]),
    .carry3(hs_carry_s1[3]),
    .carry4(hs_carry_s1[4]),
  // offs inputs from fit lut
    .offs0(hs_offs_s1[0]),
    .offs1(hs_offs_s1[1]),
    .offs2(hs_offs_s1[2]),
    .offs3(hs_offs_s1[3]),
    .offs4(hs_offs_s1[4]),
  // quality inputs from fit lut
  // bend inputs from fit lut
    .bend0(hs_bend_s1[0]),
    .bend1(hs_bend_s1[1]),
    .bend2(hs_bend_s1[2]),
    .bend3(hs_bend_s1[3]),
    .bend4(hs_bend_s1[4]),
  // best pattern output
    .best_pat (hs_pat_s2),
    .best_key (hs_key_s2),
  // best fit result
    .best_subkey (hs_xky_s2),
    .best_carry  (hs_car_s2),
    .best_bend   (hs_bnd_s2)
  );

  // Latch final hs pattern data for 1st CLCT
  reg [MXPATB - 1:0] hs_pat_1st_nodly;
  reg [MXKEYBX- 1:0] hs_key_1st_nodly;
  reg [MXBNDB - 1:0] hs_bnd_1st_nodly;
  reg [MXPATC - 1:0] hs_car_1st_nodly;
  reg [MXXKYB - 1:0] hs_xky_1st_nodly;

  always @(posedge clock) begin
    hs_pat_1st_nodly <= hs_pat_s2;
    hs_key_1st_nodly <= hs_key_s2;
    hs_xky_1st_nodly <= hs_xky_s2;//CCLUT, Tao
    hs_bnd_1st_nodly <= hs_bnd_s2;
    hs_car_1st_nodly <= hs_car_s2;
  end

//-------------------------------------------------------------------------------------------------------------------
// Stage 6A: Delay 1st CLCT to output at same time as 2nd CLCT
//-------------------------------------------------------------------------------------------------------------------
  wire [MXPATB - 1: 0]  hs_pat_1st_dly;
  wire [MXKEYBX - 1: 0] hs_key_1st_dly;
  wire [MXHITB - 1: 0]  hs_hit_1st_dly;
  wire [MXBNDB -1:0] hs_bnd_1st_dly;
  wire [MXPATC -1:0] hs_car_1st_dly;
  wire [MXXKYB -1:0] hs_xky_1st_dly;

  parameter cdly = 4'd0;

  srl16e_bbl #(MXPATB ) upatbbl (.clock(clock), .ce(1'b1), .adr(cdly), .d(hs_pat_1st_nodly), .q(hs_pat_1st_dly));
  srl16e_bbl #(MXKEYBX) ukeybbl (.clock(clock), .ce(1'b1), .adr(cdly), .d(hs_key_1st_nodly), .q(hs_key_1st_dly));
  //CCLUT, Tao
  srl16e_bbl #(MXBNDB) ubndbbl (.clock(clock), .ce(1'b1), .adr(cdly), .d(hs_bnd_1st_nodly), .q(hs_bnd_1st_dly));
  srl16e_bbl #(MXPATC) ucarbbl (.clock(clock), .ce(1'b1), .adr(cdly), .d(hs_car_1st_nodly), .q(hs_car_1st_dly));
  srl16e_bbl #(MXXKYB) uxkybbl (.clock(clock), .ce(1'b1), .adr(cdly), .d(hs_xky_1st_nodly), .q(hs_xky_1st_dly));

  // Final 1st CLCT flipflop
  reg [MXPIDB - 1:0] hs_pid_1st = 0;
  reg [MXHITB - 1:0] hs_hit_1st = 0;
  reg [MXKEYBX- 1:0] hs_key_1st = 0;
  reg [MXBNDB - 1:0] hs_bnd_1st = 0;
  reg [MXPATC - 1:0] hs_car_1st = 0;
  reg [MXXKYB - 1:0] hs_xky_1st = 0;
  reg [MXPIDB - 1:0] hs_run2pid_1st=0;

  assign hs_hit_1st_dly = hs_pat_1st_dly[MXPATB - 1: MXPIDB];

  wire blank_1st    = ((hs_hit_1st_dly == 0) && (clct_blanking == 1)) || purging;
  wire lyr_trig_1st = (hs_layer_latch && layer_trig_en_ff);

  wire [MXPIDB     - 1:0] hs_run2pid_1st_dly = run2pid(hs_bnd_1st_dly);

  always @(posedge clock) begin
    if (blank_1st) begin       // blank 1st CLCT
      hs_pid_1st <= 0;
      hs_hit_1st <= 0;
      hs_key_1st <= 0;
      hs_bnd_1st <= 0;
      hs_car_1st <= 0;
      hs_xky_1st <= 0;
      hs_run2pid_1st <= 0;
    end
    else if (lyr_trig_1st) begin        // layer-trigger mode
      hs_pid_1st <= 1;                  // Pattern id=1 for layer triggers
      hs_hit_1st <= hs_nlayers_hit_dly; // Insert number of layers hit
      hs_key_1st <= 0;                  // Dummy key
      hs_bnd_1st <= 0;
      hs_car_1st <= 0;
      hs_xky_1st <= 0;
      hs_run2pid_1st <= 0;
    end
    else begin          // else assert final 1st clct
      hs_key_1st <= hs_key_1st_dly;
      hs_pid_1st <= hs_pat_1st_dly[MXPIDB - 1: 0];//change pid range 10-6 into range 4-0
      hs_hit_1st <= hs_pat_1st_dly[MXPATB - 1: MXPIDB];
      hs_bnd_1st <= hs_bnd_1st_dly;
      hs_car_1st <= hs_car_1st_dly;
      hs_xky_1st <= hs_xky_1st_dly;
      hs_run2pid_1st <= hs_run2pid_1st_dly;
    end
  end

  // FF layer-mode status
  reg                 hs_layer_trig;
  reg [MXLY - 1: 0]   hs_layer_or;
  reg [MXHITB - 1: 0] hs_nlayers_hit;

  //reg [9:0]           hmt_nhits_trig;

  always @(posedge clock) begin
    hs_layer_trig  <= hs_layer_trig_dly;
    hs_layer_or    <= hs_layer_or_dly;
    hs_nlayers_hit <= hs_nlayers_hit_dly;
    //hmt_nhits_trig  <= nhits_trig_dly; 
  end


//-------------------------------------------------------------------------------------------------------------------
// Stage 6B: Mark key 1/2-strips near the 1st CLCT key as busy to exclude them from 2nd CLCT priority encoding
//-------------------------------------------------------------------------------------------------------------------
// Dual-Port RAM with Asynchronous Read: look up busy key region for excluding 2nd clct, port A=VME r/w, port B=readonly
  wire [3: 0]  adra;   // Port A address, set by VME register
  wire [3: 0]  adrb;   // Port B address, set by pattern ID number 0 to 9
  wire [15: 0] rdataa; // Port A read data, read by VME register
  wire [15: 0] rdatab; // Port B read data, reads out pspan,nspan for this pattern ID number
  wire [15: 0] wdataa; // Port A writedata, written by VME register, there is no portb wdatab

  assign wea    = clct_sep_ram_we;
  assign adra   = clct_sep_ram_adr;
  assign wdataa = clct_sep_ram_wdata;

  assign clct_sep_ram_rdata = rdataa;
  assign adrb[3: 0] = hs_pat_s2[MXPIDB - 1: 0]; // Pattern ID points to nspan,pspan values for this bend angle

  // Instantiate 16adr x 16bit dual port RAM
  // Port A: write/read via VME
  // Port B: readonly pattern ID lookup
  // Initial RAM contents   FFEEDDCCBBAA99887766554433221100
  parameter nsep = 128'h0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A;
  parameter psep = 128'h0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A;
  generate
    for (i = 0; i <= 7; i = i + 1) begin: sepram07
      parameter INIT_07 = {nsep[i + 120], nsep[i + 112], nsep[i + 104], nsep[i + 96], nsep[i + 88], nsep[i + 80], nsep[i + 72], nsep[i + 64], nsep[i + 56], nsep[i + 48], nsep[i + 40], nsep[i + 32], nsep[i + 24], nsep[i + 16], nsep[i + 8], nsep[i - 0]};
      RAM16X1D #( .INIT(INIT_07) ) uram16x1d ( // Primitive: 16-Deep by 1-Wide Static Dual Port Synchronous RAM
        .WCLK  (clock),     // Port A Write clock input
        .WE    (wea),       // Port A Write enable input
        .A0    (adra[0]),   // Port A R/W address[0] input bit
        .A1    (adra[1]),   // Port A R/W address[1] input bit
        .A2    (adra[2]),   // Port A R/W address[2] input bit
        .A3    (adra[3]),   // Port A R/W address[3] input bit
        .D     (wdataa[i]), // Port A Write 1-bit data input
        .SPO   (rdataa[i]), // Port A R/W 1-bit data output for A0-A3

        .DPRA0 (adrb[0]),   // Port B Read address[0] input bit
        .DPRA1 (adrb[1]),   // Port B Read address[1] input bit
        .DPRA2 (adrb[2]),   // Port B Read address[2] input bit
        .DPRA3 (adrb[03]),  // Port B Read address[3] input bit
        .DPO   (rdatab[i])  // Port B Read-only 1-bit data output for DPRA
      );

      //     if (i<=7) begin: gena defparam sepram[i].uram16x1d.INIT = {nsep[i+120],nsep[i+112],nsep[i+104],nsep[i+96],nsep[i+88],nsep[i+80],nsep[i+72],nsep[i+64],nsep[i+56],nsep[i+48],nsep[i+40],
      //               nsep[i+32],nsep[i+24],nsep[i+16],nsep[i+8],nsep[i-0]}; end
      //     else    begin: genb defparam sepram[i].uram16x1d.INIT = {psep[i+112],psep[i+104],psep[i+96 ],psep[i+88],psep[i+80],psep[i+72],psep[i+64],psep[i+56],psep[i+48],psep[i+40],psep[i+32],
      //             psep[i+24],psep[i+16],psep[i+8 ],psep[i+0],psep[i-8]}; end
    end
  endgenerate

  generate
    for (i = 8; i <= 15; i = i + 1) begin: sepram815
      parameter INIT_815 = {psep[i + 112], psep[i + 104], psep[i + 96 ], psep[i + 88], psep[i + 80], psep[i + 72], psep[i + 64], psep[i + 56], psep[i + 48], psep[i + 40], psep[i + 32], psep[i + 24], psep[i + 16], psep[i + 8 ], psep[i + 0], psep[i - 8]};
      RAM16X1D #( .INIT(INIT_815) ) uram16x1d ( // Primitive: 16-Deep by 1-Wide Static Dual Port Synchronous RAM
        .WCLK  (clock),     // Port A Write clock input
        .WE    (wea),       // Port A Write enable input
        .A0    (adra[0]),   // Port A R/W address[0] input bit
        .A1    (adra[1]),   // Port A R/W address[1] input bit
        .A2    (adra[2]),   // Port A R/W address[2] input bit
        .A3    (adra[3]),   // Port A R/W address[3] input bit
        .D     (wdataa[i]), // Port A Write 1-bit data input
        .SPO   (rdataa[i]), // Port A R/W 1-bit data output for A0-A3

        .DPRA0 (adrb[0]),   // Port B Read address[0] input bit
        .DPRA1 (adrb[1]),   // Port B Read address[1] input bit
        .DPRA2 (adrb[2]),   // Port B Read address[2] input bit
        .DPRA3 (adrb[03]),  // Port B Read address[3] input bit
        .DPO   (rdatab[i])  // Port B Read-only 1-bit data output for DPRA
      );

      //     if (i<=7) begin: gena defparam sepram[i].uram16x1d.INIT = {nsep[i+120],nsep[i+112],nsep[i+104],nsep[i+96],nsep[i+88],nsep[i+80],nsep[i+72],nsep[i+64],nsep[i+56],nsep[i+48],nsep[i+40],
      //               nsep[i+32],nsep[i+24],nsep[i+16],nsep[i+8],nsep[i-0]}; end
      //     else    begin: genb defparam sepram[i].uram16x1d.INIT = {psep[i+112],psep[i+104],psep[i+96 ],psep[i+88],psep[i+80],psep[i+72],psep[i+64],psep[i+56],psep[i+48],psep[i+40],psep[i+32],
      //             psep[i+24],psep[i+16],psep[i+8 ],psep[i+0],psep[i-8]}; end
    end
  endgenerate

  // Extract busy key spans from RAM data
  wire [7: 0] nspan_ram;
  wire [7: 0] pspan_ram;

  assign nspan_ram = rdatab[ 7: 0];
  assign pspan_ram = rdatab[15: 8];

  // Multiplex with single-parameter busy key span from vme
  reg [7: 0] nspan;
  reg [7: 0] pspan;

  always @(posedge clock) begin
    nspan <= (clct_sep_src) ? clct_sep_vme : nspan_ram;
    pspan <= (clct_sep_src) ? clct_sep_vme : pspan_ram;
  end

  // CSC Type C or D delimiters for excluding 2nd clct span ME1B hs0-127  ME1A hs128-223
  reg [MXKEYBX - 1: 0] busy_min;
  reg [MXKEYBX - 1: 0] busy_max;

    //Tao, ME1/1->MEX/1
  //wire clct0_is_on_me1a = hs_key_s2[MXKEYBX - 1]; // 1 for CFEBs 4,5,6  and 0 for CFEBs 0,1,2,3

  always @ * begin
    //TYPE_A or TYPE_B
    busy_max <= (hs_key_s2 <= 8'd159 - pspan) ? hs_key_s2 + pspan : 8'd159;
    busy_min <= (hs_key_s2 >= nspan) ? hs_key_s2 - nspan : 8'd0;
  end

  // Latch busy key 1/2-strips for excluding 2nd clct
  reg [MXHSX - 1: 0] busy_key; //JG, better to use MXKEYX here.

  genvar ikey;
  generate
    for (ikey = 0; ikey <= MXHSX - 1; ikey = ikey + 1) begin: bloop
      always @(posedge clock) begin
        busy_key[ikey] <= (ikey >= busy_min) && (ikey <= busy_max);
      end
    end
  endgenerate

//-------------------------------------------------------------------------------------------------------------------
// Stage 7A: 1/2-Strip Priority Encoder
//    Find 2nd best of 160 patterns, excluding busy region around 1st best key
//-------------------------------------------------------------------------------------------------------------------
  // Delay 1st CLCT pattern numbers to align in time with 1st CLCT busy keys
  wire [MXPATB - 1: 0] hs_pat_s3 [MXHSX - 1: 0];
  wire [MXPATC - 1: 0] hs_carry_s3 [MXHSX - 1: 0];

  parameter pdly = 4'd1;

  genvar ibit;
  generate
    for (ikey = 0; ikey <= MXHSX - 1; ikey = ikey + 1) begin: key_loop
      for (ibit = 0; ibit <= MXPATB - 1; ibit = ibit + 1) begin: bit_loop
        SRL16E u0 ( // Primitive: 16-Bit Shift Register Look-Up Table (LUT) with Clock Enable
          .CLK(clock),
          .CE(1'b1),
          .D(hs_pat_s0[ikey][ibit]),
          .A0(pdly[0]),
          .A1(pdly[1]),
          .A2(pdly[2]),
          .A3(pdly[3]),
          .Q(hs_pat_s3[ikey][ibit])
        );
      end

    // also do it for comparator code, hit carrry
      for (ibit = 0; ibit <= MXPATC - 1; ibit = ibit + 1) begin: bit_loop_carry
        SRL16E u0 ( // Primitive: 16-Bit Shift Register Look-Up Table (LUT) with Clock Enable
          .CLK(clock),
          .CE(1'b1),
          .D(hs_carry_s0[ikey][ibit]),
          .A0(pdly[0]),
          .A1(pdly[1]),
          .A2(pdly[2]),
          .A3(pdly[3]),
          .Q(hs_carry_s3[ikey][ibit])
        );
      end

    end
  endgenerate

  // Best 5 of 224 1/2-strip patterns
  wire [MXPATB - 1: 0] hs_pat_s4_tmp [MXCFEB - 1: 0];
  wire [MXPATB - 1: 0] hs_pat_s4 [MXCFEB - 1: 0];
  wire [MXKEYB - 1: 0] hs_key_s4 [MXCFEB - 1: 0]; // partial key for 1 of 32
  wire [MXCFEB - 1: 0] hs_bsy_s4;
  wire [MXOFFSB-1:0]   hs_offs_s4  [MXCFEB - 1:0];//CCLUT, Tao
  wire [MXBNDB -1:0]   hs_bend_s4  [MXCFEB - 1:0];
  wire [MXPATC -1:0]   hs_carry_s4 [MXCFEB - 1:0];

  generate
    for (i = 0; i <= MXCFEB - 1; i = i + 1) begin: hs_2nd_gen
      assign hs_pat_s4[i] = hs_pat_s4_tmp[i]-4'd6;// subtract pattern id by 4 to revert patid back to 0-4
      best_1of32_busy_ccLUT ubest1of32_2nd (
        .clock(clock),
        .pat00(hs_pat_s3[i * 32 + 0]),
        .pat01(hs_pat_s3[i * 32 + 1]),
        .pat02(hs_pat_s3[i * 32 + 2]),
        .pat03(hs_pat_s3[i * 32 + 3]),
        .pat04(hs_pat_s3[i * 32 + 4]),
        .pat05(hs_pat_s3[i * 32 + 5]),
        .pat06(hs_pat_s3[i * 32 + 6]),
        .pat07(hs_pat_s3[i * 32 + 7]),
        .pat08(hs_pat_s3[i * 32 + 8]),
        .pat09(hs_pat_s3[i * 32 + 9]),
        .pat10(hs_pat_s3[i * 32 + 10]),
        .pat11(hs_pat_s3[i * 32 + 11]),
        .pat12(hs_pat_s3[i * 32 + 12]),
        .pat13(hs_pat_s3[i * 32 + 13]),
        .pat14(hs_pat_s3[i * 32 + 14]),
        .pat15(hs_pat_s3[i * 32 + 15]),
        .pat16(hs_pat_s3[i * 32 + 16]),
        .pat17(hs_pat_s3[i * 32 + 17]),
        .pat18(hs_pat_s3[i * 32 + 18]),
        .pat19(hs_pat_s3[i * 32 + 19]),
        .pat20(hs_pat_s3[i * 32 + 20]),
        .pat21(hs_pat_s3[i * 32 + 21]),
        .pat22(hs_pat_s3[i * 32 + 22]),
        .pat23(hs_pat_s3[i * 32 + 23]),
        .pat24(hs_pat_s3[i * 32 + 24]),
        .pat25(hs_pat_s3[i * 32 + 25]),
        .pat26(hs_pat_s3[i * 32 + 26]),
        .pat27(hs_pat_s3[i * 32 + 27]),
        .pat28(hs_pat_s3[i * 32 + 28]),
        .pat29(hs_pat_s3[i * 32 + 29]),
        .pat30(hs_pat_s3[i * 32 + 30]),
        .pat31(hs_pat_s3[i * 32 + 31]),
        //hit carry, comparator code
        .carry00(hs_carry_s3[i * 32 + 0]),
        .carry01(hs_carry_s3[i * 32 + 1]),
        .carry02(hs_carry_s3[i * 32 + 2]),
        .carry03(hs_carry_s3[i * 32 + 3]),
        .carry04(hs_carry_s3[i * 32 + 4]),
        .carry05(hs_carry_s3[i * 32 + 5]),
        .carry06(hs_carry_s3[i * 32 + 6]),
        .carry07(hs_carry_s3[i * 32 + 7]),
        .carry08(hs_carry_s3[i * 32 + 8]),
        .carry09(hs_carry_s3[i * 32 + 9]),
        .carry10(hs_carry_s3[i * 32 + 10]),
        .carry11(hs_carry_s3[i * 32 + 11]),
        .carry12(hs_carry_s3[i * 32 + 12]),
        .carry13(hs_carry_s3[i * 32 + 13]),
        .carry14(hs_carry_s3[i * 32 + 14]),
        .carry15(hs_carry_s3[i * 32 + 15]),
        .carry16(hs_carry_s3[i * 32 + 16]),
        .carry17(hs_carry_s3[i * 32 + 17]),
        .carry18(hs_carry_s3[i * 32 + 18]),
        .carry19(hs_carry_s3[i * 32 + 19]),
        .carry20(hs_carry_s3[i * 32 + 20]),
        .carry21(hs_carry_s3[i * 32 + 21]),
        .carry22(hs_carry_s3[i * 32 + 22]),
        .carry23(hs_carry_s3[i * 32 + 23]),
        .carry24(hs_carry_s3[i * 32 + 24]),
        .carry25(hs_carry_s3[i * 32 + 25]),
        .carry26(hs_carry_s3[i * 32 + 26]),
        .carry27(hs_carry_s3[i * 32 + 27]),
        .carry28(hs_carry_s3[i * 32 + 28]),
        .carry29(hs_carry_s3[i * 32 + 29]),
        .carry30(hs_carry_s3[i * 32 + 30]),
        .carry31(hs_carry_s3[i * 32 + 31]),
        // Outputs
        .best_pat   (hs_pat_s4_tmp[i]),
        .best_key   (hs_key_s4[i]),
        .best_carry (hs_carry_s4[i]),
        // Busy flags
        .best_bsy(hs_bsy_s4[i]),
        .bsy(busy_key[i * 32 + 31: i * 32])
      );
    end
  endgenerate

  // Best 1 of 5 1/2-strip patterns
  wire [MXPATB - 1: 0]  hs_pat_s5;
  wire [MXKEYBX - 1: 0] hs_key_s5;  // full key for 1 of 160
  wire [MXHITB - 1: 0]  hs_hit_s5;
  wire [MXXKYB -1:0]    hs_xky_s5; // CCLUT, Tao
  wire [MXBNDB -1:0]    hs_bnd_s5;
  wire [MXPATC -1:0]    hs_car_s5;
  wire hs_bsy_s5;

  // CCLUT, Tao, best_1of7_busy_ccLUT
  best_1of5_busy_ccLUT #(.PATLUT(PATLUT))
  ubest1of5_2nd (
  // pattern inputs
    .pat0(hs_pat_s4[0]),
    .pat1(hs_pat_s4[1]),
    .pat2(hs_pat_s4[2]),
    .pat3(hs_pat_s4[3]),
    .pat4(hs_pat_s4[4]),
  // key hs inputs
    .key0(hs_key_s4[0]),
    .key1(hs_key_s4[1]),
    .key2(hs_key_s4[2]),
    .key3(hs_key_s4[3]),
    .key4(hs_key_s4[4]),
  // carry inputs from fit lut
    .carry0(hs_carry_s4[0]),
    .carry1(hs_carry_s4[1]),
    .carry2(hs_carry_s4[2]),
    .carry3(hs_carry_s4[3]),
    .carry4(hs_carry_s4[4]),
  // offs inputs from fit lut
    .offs0(hs_offs_s4[0]),
    .offs1(hs_offs_s4[1]),
    .offs2(hs_offs_s4[2]),
    .offs3(hs_offs_s4[3]),
    .offs4(hs_offs_s4[4]),
  // bend inputs from fit lut
    .bend0(hs_bend_s4[0]),
    .bend1(hs_bend_s4[1]),
    .bend2(hs_bend_s4[2]),
    .bend3(hs_bend_s4[3]),
    .bend4(hs_bend_s4[4]),
  // best pattern output
    .bsy0(hs_bsy_s4[0]),
    .bsy1(hs_bsy_s4[1]),
    .bsy2(hs_bsy_s4[2]),
    .bsy3(hs_bsy_s4[3]),
    .bsy4(hs_bsy_s4[4]),
  // best pattern output
    .best_pat(hs_pat_s5),
    .best_key(hs_key_s5),
  // best fit result
    .best_subkey(hs_xky_s5),
    .best_bend  (hs_bnd_s5),
    .best_carry (hs_car_s5),
  // busy flags
    .best_bsy(hs_bsy_s5)
  );

  wire [MXPIDB     - 1:0] hs_run2pid_2nd_s5 = run2pid(hs_bnd_s5);
  // Latch final 2nd CLCT
  reg [MXPIDB     - 1:0] hs_pid_2nd;
  reg [MXHITB     - 1:0] hs_hit_2nd;
  reg [MXKEYBX    - 1:0] hs_key_2nd;
  reg [MXBNDB     - 1:0] hs_bnd_2nd;
  reg [MXPATC     - 1:0] hs_car_2nd;
  reg [MXXKYB - 1:0]     hs_xky_2nd;
  reg                    hs_bsy_2nd;
  reg [MXPIDB     - 1:0] hs_run2pid_2nd;

  assign hs_hit_s5 = hs_pat_s5[MXPATB - 1: MXPIDB];
  wire blank_2nd    = ((hs_hit_s5 == 0) && (clct_blanking == 1)) || purging;
  wire lyr_trig_2nd = (hs_layer_latch && layer_trig_en_ff);

  always @(posedge clock) begin
    if (blank_2nd) begin
      hs_pid_2nd <= 0;
      hs_hit_2nd <= 0;
      hs_key_2nd <= 0;
      hs_bnd_2nd <= 0;
      hs_car_2nd <= 0;
      hs_xky_2nd <= 0;
      hs_bsy_2nd <= hs_bsy_s5;
      hs_run2pid_2nd <= 0;
    end
    else if (lyr_trig_2nd) begin    // layer-trigger mode
      hs_pid_2nd <= 0;
      hs_hit_2nd <= 0;
      hs_key_2nd <= 0;
      hs_bnd_2nd <= 0;
      hs_car_2nd <= 0;
      hs_xky_2nd <= 0;
      hs_bsy_2nd <= hs_bsy_s5;
      hs_run2pid_2nd <= 0;
    end
    else begin         // else assert final 2nd clct
      hs_pid_2nd <= hs_pat_s5[MXPIDB - 1: 0];// change pid range 10 to 6 into range 4-0
      hs_hit_2nd <= hs_pat_s5[MXPATB - 1: MXPIDB];
      hs_key_2nd <= hs_key_s5;
      hs_bsy_2nd <= hs_bsy_s5;
      hs_bnd_2nd <= hs_bnd_s5;
      hs_car_2nd <= hs_car_s5;
      hs_xky_2nd <= hs_xky_s5;
      hs_run2pid_2nd <= hs_run2pid_2nd_s5;
    end
  end

  //--------------------------------------------------------------------------------------------------------------------
  // Pattern LUT Uses Dual Port RAM to Operate Simultanously on first and second CLCTs (from different BX)
  //--------------------------------------------------------------------------------------------------------------------

  generate
  for (i = 0; i <=  MXCFEB - 1; i = i + 1) begin: pat_lut
  pattern_lut_ccLUT upattern_lut (
    // 40 MHz clock input
    .clock(clock),

    // Sortable pattern inputs
    .pat00(hs_pat_s1[i][MXPIDB-1:0]),
    .pat01(hs_pat_s4[i][MXPIDB-1:0]),

    // Carried half-strip bits
    .carry00(hs_carry_s1[i]),
    .carry01(hs_carry_s4[i]),

    // LUT Quarterstrip output
    .offs0(hs_offs_s1[i]),
    .offs1(hs_offs_s4[i]),

    // LUT Bend angle output
    .bend0(hs_bend_s1[i]),
    .bend1(hs_bend_s4[i])

  );
  end
  endgenerate


//------------------------------------------------------------------------------------------------------------------------
// Prodcedural function to sum number of layers hit into a binary value - ROM version
// Returns  count1s = (inp[5]+inp[4]+inp[3])+(inp[2]+inp[1]+inp[0]);
//
// Virtex-6 Specific
//
// 03/21/2013 Initial
//------------------------------------------------------------------------------------------------------------------------
function [2: 0] count1s;
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

    count1s = rom;
  end

endfunction

//========================
// LUt to convert run3 bending into run2 pattern id
function [3: 0] run2pid;
  input [4: 0] bnd;
  reg   [3: 0] pid;

  begin
    case (bnd[4: 0])
      5'd0 : pid = 4'd10;
      5'd1 : pid = 4'd10;
      5'd2 : pid = 4'd10;
      5'd3 : pid = 4'd8 ;
      5'd4 : pid = 4'd8 ;
      5'd5 : pid = 4'd8 ;
      5'd6 : pid = 4'd6 ;
      5'd7 : pid = 4'd6 ;
      5'd8 : pid = 4'd6 ;
      5'd9 : pid = 4'd4 ;
      5'd10: pid = 4'd4 ;
      5'd11: pid = 4'd4 ;
      5'd12: pid = 4'd2 ;
      5'd13: pid = 4'd2 ;
      5'd14: pid = 4'd2 ;
      5'd15: pid = 4'd2 ;
      5'd16: pid = 4'd10;
      5'd17: pid = 4'd10;
      5'd18: pid = 4'd10;
      5'd19: pid = 4'd9 ;
      5'd20: pid = 4'd9 ;
      5'd21: pid = 4'd9 ;
      5'd22: pid = 4'd7 ;
      5'd23: pid = 4'd7 ;
      5'd24: pid = 4'd7 ;
      5'd25: pid = 4'd5 ;
      5'd26: pid = 4'd5 ;
      5'd27: pid = 4'd5 ;
      5'd28: pid = 4'd3 ;
      5'd29: pid = 4'd3 ;
      5'd30: pid = 4'd3 ;
      5'd31: pid = 4'd3 ;
  endcase

  run2pid = pid;

  end

endfunction

//-------------------------------------------------------------------------------------------------------------------
// Debug
//-------------------------------------------------------------------------------------------------------------------
`ifdef DEBUG_PATTERN_FINDER 
  // Stage0 timing markers
  wire [MXHSX - 1: 0] debug_hs_hit_vec;
  wire [MXHSX - 1: 0] debug_hs_hit_s0ab_vec;
  wire [MXHSX - 1: 0] debug_hs_hit_s0_vec;

  generate
    for (ihs = 0; ihs <= MXHSX - 1; ihs = ihs + 1) begin: deb1gen
      assign debug_hs_hit_vec[ihs]      = | hs_hit[ihs];
      assign debug_hs_hit_s0ab_vec[ihs] = | hs_hit_s0ab[ihs];
      assign debug_hs_hit_s0_vec[ihs]   = | hs_hit_s0[ihs];
    end
  endgenerate

  assign debug_hs_hit      = | debug_hs_hit_vec;
  assign debug_hs_hit_s0ab = | debug_hs_hit_s0ab_vec;
  assign debug_hs_hit_s0   = | debug_hs_hit_s0_vec;

  // Purge state machine
  reg[39: 0] purge_sm_dsp;
  always @ * begin
    case (purge_sm)
      pass: purge_sm_dsp    <= "pass ";
      purge: purge_sm_dsp   <= "purge";
      default purge_sm_dsp <= "error";
    endcase
  end
`endif

//-------------------------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------------------------
