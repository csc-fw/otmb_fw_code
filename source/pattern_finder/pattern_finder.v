`timescale 1ns / 1ps



//`define DEBUG_PATTERN_FINDER  // Turn on debug mode
//-------------------------------------------------------------------------------------------------------------------
// Conditional compile flags, normally set by global defines. Override here for standalone debugging
//-------------------------------------------------------------------------------------------------------------------
// `define CSC_TYPE_C   04'hC  // Normal ME1B, reversed ME1A
// `define CSC_TYPE_D   04'hD  // Reversed ME1B, normal ME1A
//-------------------------------------------------------------------------------------------------------------------
// 02/08/2013 Initial Virtex-6
// 02/11/2013 Tune simulator DCM defparams
// 02/11/2013 Unfold pattern finder, remove clock_2x and clock_lac
// 02/15/2013 Expand to 7 CFEBs
// 03/25/2013 Replace layer trigger count1s with ROM
// 04/03/2013 Fix cfeb_hit logic
//-------------------------------------------------------------------------------------------------------------------
module pattern_finder (
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
  cfeb5_ly0hs, cfeb5_ly1hs, cfeb5_ly2hs, cfeb5_ly3hs, cfeb5_ly4hs, cfeb5_ly5hs,
  cfeb6_ly0hs, cfeb6_ly1hs, cfeb6_ly2hs, cfeb6_ly3hs, cfeb6_ly4hs, cfeb6_ly5hs,
`else 
  // CFEB Ports, debug
  tmb_clock0,
  cfeb0_ly0hst, cfeb0_ly1hst, cfeb0_ly2hst, cfeb0_ly3hst, cfeb0_ly4hst, cfeb0_ly5hst,
  cfeb1_ly0hst, cfeb1_ly1hst, cfeb1_ly2hst, cfeb1_ly3hst, cfeb1_ly4hst, cfeb1_ly5hst,
  cfeb2_ly0hst, cfeb2_ly1hst, cfeb2_ly2hst, cfeb2_ly3hst, cfeb2_ly4hst, cfeb2_ly5hst,
  cfeb3_ly0hst, cfeb3_ly1hst, cfeb3_ly2hst, cfeb3_ly3hst, cfeb3_ly4hst, cfeb3_ly5hst,
  cfeb4_ly0hst, cfeb4_ly1hst, cfeb4_ly2hst, cfeb4_ly3hst, cfeb4_ly4hst, cfeb4_ly5hst,
  cfeb5_ly0hst, cfeb5_ly1hst, cfeb5_ly2hst, cfeb5_ly3hst, cfeb5_ly4hst, cfeb5_ly5hst,
  cfeb6_ly0hst, cfeb6_ly1hst, cfeb6_ly2hst, cfeb6_ly3hst, cfeb6_ly4hst, cfeb6_ly5hst,
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

  hs_hit_2nd,
  hs_pid_2nd,
  hs_key_2nd,
  hs_bsy_2nd,

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
  parameter MXCFEB  = 7;             // Number of CFEBs on CSC
  parameter MXLY    = 6;             // Number of layers in CSC
  parameter MXDS    = 8;             // Number of DiStrips per layer on 1 CFEB
  parameter MXDSX   = MXCFEB * MXDS; // Number of DiStrips per layer on 7 CFEBs
  parameter MXHS    = 32;            // Number of HalfStrips per layer on 1 CFEB
  parameter MXHSX   = MXCFEB * MXHS; // Number of HalfStrips per layer on 7 CFEBs
  parameter MXKEY   = MXHS;          // Number of key HalfSrips on 1 CFEB
  parameter MXKEYB  = 5;             // Number of HalfSrip key bits on 1 CFEB
  parameter MXKEYX  = MXCFEB * MXHS; // Number of key HalfSrips on 7 CFEBs
  parameter MXKEYBX = 8;             // Number of HalfSrip key bits on 7 CFEBs

  parameter MXPIDB  = 4;             // Pattern ID bits
  parameter MXHITB  = 3;             // Hits on pattern bits
  parameter MXPATB  = 3 + 4;         // Pattern bits

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
  input [MXHS - 1: 0] cfeb5_ly0hs, cfeb5_ly1hs, cfeb5_ly2hs, cfeb5_ly3hs, cfeb5_ly4hs, cfeb5_ly5hs;
  input [MXHS - 1: 0] cfeb6_ly0hs, cfeb6_ly1hs, cfeb6_ly2hs, cfeb6_ly3hs, cfeb6_ly4hs, cfeb6_ly5hs;
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
  input [MXHS - 1: 0] cfeb5_ly0hst, cfeb5_ly1hst, cfeb5_ly2hst, cfeb5_ly3hst, cfeb5_ly4hst, cfeb5_ly5hst;
  input [MXHS - 1: 0] cfeb6_ly0hst, cfeb6_ly1hst, cfeb6_ly2hst, cfeb6_ly3hst, cfeb6_ly4hst, cfeb6_ly5hst;
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

  // 2nd CLCT separation RAM Ports
  input          clct_sep_src;       // CLCT separation source 1=VME, 0=RAM
  input  [7: 0]  clct_sep_vme;       // CLCT separation from VME
  input          clct_sep_ram_we;    // CLCT separation RAM write enable
  input  [3: 0]  clct_sep_ram_adr;   // CLCT separation RAM rw address VME
  input  [15: 0] clct_sep_ram_wdata; // CLCT separation RAM write data VME
  output [15: 0] clct_sep_ram_rdata; // CLCT separation RAM read  data VME

  // CLCT Pattern-finder results
  output [MXHITB - 1: 0]  hs_hit_1st; // 1st CLCT pattern hits
  output [MXPIDB - 1: 0]  hs_pid_1st; // 1st CLCT pattern ID
  output [MXKEYBX - 1: 0] hs_key_1st; // 1st CLCT key 1/2-strip

  output [MXHITB - 1: 0]  hs_hit_2nd; // 2nd CLCT pattern hits
  output [MXPIDB - 1: 0]  hs_pid_2nd; // 2nd CLCT pattern ID
  output [MXKEYBX - 1: 0] hs_key_2nd; // 2nd CLCT key 1/2-strip
  output                  hs_bsy_2nd; // 2nd CLCT busy, logic error indicator

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
`ifdef CSC_TYPE_C initial $display ("CSC_TYPE_C=%H",`CSC_TYPE_C); `endif // Normal   ME1B, reversed ME1A
`ifdef CSC_TYPE_D initial $display ("CSC_TYPE_D=%H",`CSC_TYPE_D); `endif // Reversed ME1B, normal   ME1A

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
  reg [MXHS - 1: 0] cfeb5_ly0hs, cfeb5_ly1hs, cfeb5_ly2hs, cfeb5_ly3hs, cfeb5_ly4hs, cfeb5_ly5hs;
  reg [MXHS - 1: 0] cfeb6_ly0hs, cfeb6_ly1hs, cfeb6_ly2hs, cfeb6_ly3hs, cfeb6_ly4hs, cfeb6_ly5hs;

  wire clock;
  always @(posedge clock) begin
    {cfeb0_ly5hs, cfeb0_ly4hs, cfeb0_ly3hs, cfeb0_ly2hs, cfeb0_ly1hs, cfeb0_ly0hs} <= {cfeb0_ly5hst, cfeb0_ly4hst, cfeb0_ly3hst, cfeb0_ly2hst, cfeb0_ly1hst, cfeb0_ly0hst};
    {cfeb1_ly5hs, cfeb1_ly4hs, cfeb1_ly3hs, cfeb1_ly2hs, cfeb1_ly1hs, cfeb1_ly0hs} <= {cfeb1_ly5hst, cfeb1_ly4hst, cfeb1_ly3hst, cfeb1_ly2hst, cfeb1_ly1hst, cfeb1_ly0hst};
    {cfeb2_ly5hs, cfeb2_ly4hs, cfeb2_ly3hs, cfeb2_ly2hs, cfeb2_ly1hs, cfeb2_ly0hs} <= {cfeb2_ly5hst, cfeb2_ly4hst, cfeb2_ly3hst, cfeb2_ly2hst, cfeb2_ly1hst, cfeb2_ly0hst};
    {cfeb3_ly5hs, cfeb3_ly4hs, cfeb3_ly3hs, cfeb3_ly2hs, cfeb3_ly1hs, cfeb3_ly0hs} <= {cfeb3_ly5hst, cfeb3_ly4hst, cfeb3_ly3hst, cfeb3_ly2hst, cfeb3_ly1hst, cfeb3_ly0hst};
    {cfeb4_ly5hs, cfeb4_ly4hs, cfeb4_ly3hs, cfeb4_ly2hs, cfeb4_ly1hs, cfeb4_ly0hs} <= {cfeb4_ly5hst, cfeb4_ly4hst, cfeb4_ly3hst, cfeb4_ly2hst, cfeb4_ly1hst, cfeb4_ly0hst};
    {cfeb5_ly5hs, cfeb5_ly4hs, cfeb5_ly3hs, cfeb5_ly2hs, cfeb5_ly1hs, cfeb5_ly0hs} <= {cfeb5_ly5hst, cfeb5_ly4hst, cfeb5_ly3hst, cfeb5_ly2hst, cfeb5_ly1hst, cfeb5_ly0hst};
    {cfeb6_ly5hs, cfeb6_ly4hs, cfeb6_ly3hs, cfeb6_ly2hs, cfeb6_ly1hs, cfeb6_ly0hs} <= {cfeb6_ly5hst, cfeb6_ly4hst, cfeb6_ly3hst, cfeb6_ly2hst, cfeb6_ly1hst, cfeb6_ly0hst};
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
// Stage 4A3: CSC_TYPE_C: Normal ME1B, reversed ME1A
//-------------------------------------------------------------------------------------------------------------------
`ifdef CSC_TYPE_C
  wire [MXHS * 3 - 1: 0] me1a_ly0hs;
  wire [MXHS * 3 - 1: 0] me1a_ly1hs;
  wire [MXHS * 3 - 1: 0] me1a_ly2hs;
  wire [MXHS * 3 - 1: 0] me1a_ly3hs;
  wire [MXHS * 3 - 1: 0] me1a_ly4hs;
  wire [MXHS * 3 - 1: 0] me1a_ly5hs;

  wire [MXHS * 4 - 1: 0] me1b_ly0hs;
  wire [MXHS * 4 - 1: 0] me1b_ly1hs;
  wire [MXHS * 4 - 1: 0] me1b_ly2hs;
  wire [MXHS * 4 - 1: 0] me1b_ly3hs;
  wire [MXHS * 4 - 1: 0] me1b_ly4hs;
  wire [MXHS * 4 - 1: 0] me1b_ly5hs;

  // Orientation flags
  assign csc_type        = 4'hC; // Firmware compile type
  assign csc_me1ab       = 1;    // 1 = ME1A or ME1B CSC
  assign stagger_hs_csc  = 0;    // 1 = Staggered CSC non-ME1
  assign reverse_hs_csc  = 0;    // 1 = Reversed  CSC non-ME1
  assign reverse_hs_me1a = 1;    // 1 = Reverse ME1A HalfStrips prior to pattern sorting
  assign reverse_hs_me1b = 0;    // 1 = Reverse ME1B HalfStrips prior to pattern sorting
  initial $display ("CSC_TYPE_C instantiated");

  // Generate hs reversal map for ME1A
  wire [MXHS - 1: 0] cfeb4_ly0hsr, cfeb4_ly1hsr, cfeb4_ly2hsr, cfeb4_ly3hsr, cfeb4_ly4hsr, cfeb4_ly5hsr;
  wire [MXHS - 1: 0] cfeb5_ly0hsr, cfeb5_ly1hsr, cfeb5_ly2hsr, cfeb5_ly3hsr, cfeb5_ly4hsr, cfeb5_ly5hsr;
  wire [MXHS - 1: 0] cfeb6_ly0hsr, cfeb6_ly1hsr, cfeb6_ly2hsr, cfeb6_ly3hsr, cfeb6_ly4hsr, cfeb6_ly5hsr;

  generate
    for (ihs = 0; ihs <= MXHS - 1; ihs = ihs + 1) begin: hsrev
      assign cfeb4_ly0hsr[ihs] = cfeb4_ly0hs[(MXHS - 1) - ihs];
      assign cfeb4_ly1hsr[ihs] = cfeb4_ly1hs[(MXHS - 1) - ihs];
      assign cfeb4_ly2hsr[ihs] = cfeb4_ly2hs[(MXHS - 1) - ihs];
      assign cfeb4_ly3hsr[ihs] = cfeb4_ly3hs[(MXHS - 1) - ihs];
      assign cfeb4_ly4hsr[ihs] = cfeb4_ly4hs[(MXHS - 1) - ihs];
      assign cfeb4_ly5hsr[ihs] = cfeb4_ly5hs[(MXHS - 1) - ihs];

      assign cfeb5_ly0hsr[ihs] = cfeb5_ly0hs[(MXHS - 1) - ihs];
      assign cfeb5_ly1hsr[ihs] = cfeb5_ly1hs[(MXHS - 1) - ihs];
      assign cfeb5_ly2hsr[ihs] = cfeb5_ly2hs[(MXHS - 1) - ihs];
      assign cfeb5_ly3hsr[ihs] = cfeb5_ly3hs[(MXHS - 1) - ihs];
      assign cfeb5_ly4hsr[ihs] = cfeb5_ly4hs[(MXHS - 1) - ihs];
      assign cfeb5_ly5hsr[ihs] = cfeb5_ly5hs[(MXHS - 1) - ihs];

      assign cfeb6_ly0hsr[ihs] = cfeb6_ly0hs[(MXHS - 1) - ihs];
      assign cfeb6_ly1hsr[ihs] = cfeb6_ly1hs[(MXHS - 1) - ihs];
      assign cfeb6_ly2hsr[ihs] = cfeb6_ly2hs[(MXHS - 1) - ihs];
      assign cfeb6_ly3hsr[ihs] = cfeb6_ly3hs[(MXHS - 1) - ihs];
      assign cfeb6_ly4hsr[ihs] = cfeb6_ly4hs[(MXHS - 1) - ihs];
      assign cfeb6_ly5hsr[ihs] = cfeb6_ly5hs[(MXHS - 1) - ihs];
    end
  endgenerate

  // Reversed ME1A CFEBs: 4, 5, 6
  assign me1a_ly0hs = {cfeb4_ly0hsr, cfeb5_ly0hsr, cfeb6_ly0hsr};
  assign me1a_ly1hs = {cfeb4_ly1hsr, cfeb5_ly1hsr, cfeb6_ly1hsr};
  assign me1a_ly2hs = {cfeb4_ly2hsr, cfeb5_ly2hsr, cfeb6_ly2hsr};
  assign me1a_ly3hs = {cfeb4_ly3hsr, cfeb5_ly3hsr, cfeb6_ly3hsr};
  assign me1a_ly4hs = {cfeb4_ly4hsr, cfeb5_ly4hsr, cfeb6_ly4hsr};
  assign me1a_ly5hs = {cfeb4_ly5hsr, cfeb5_ly5hsr, cfeb6_ly5hsr};

  // Normal ME1B CFEBs: 3, 2, 1, 0
  assign me1b_ly0hs = {cfeb3_ly0hs, cfeb2_ly0hs, cfeb1_ly0hs, cfeb0_ly0hs};
  assign me1b_ly1hs = {cfeb3_ly1hs, cfeb2_ly1hs, cfeb1_ly1hs, cfeb0_ly1hs};
  assign me1b_ly2hs = {cfeb3_ly2hs, cfeb2_ly2hs, cfeb1_ly2hs, cfeb0_ly2hs};
  assign me1b_ly3hs = {cfeb3_ly3hs, cfeb2_ly3hs, cfeb1_ly3hs, cfeb0_ly3hs};
  assign me1b_ly4hs = {cfeb3_ly4hs, cfeb2_ly4hs, cfeb1_ly4hs, cfeb0_ly4hs};
  assign me1b_ly5hs = {cfeb3_ly5hs, cfeb2_ly5hs, cfeb1_ly5hs, cfeb0_ly5hs};

//-------------------------------------------------------------------------------------------------------------------
// Stage 4A4: CSC_TYPE_D: Normal ME1A, reversed ME1B
//-------------------------------------------------------------------------------------------------------------------
`elsif CSC_TYPE_D
  wire [MXHS * 3 - 1: 0] me1a_ly0hs;
  wire [MXHS * 3 - 1: 0] me1a_ly1hs;
  wire [MXHS * 3 - 1: 0] me1a_ly2hs;
  wire [MXHS * 3 - 1: 0] me1a_ly3hs;
  wire [MXHS * 3 - 1: 0] me1a_ly4hs;
  wire [MXHS * 3 - 1: 0] me1a_ly5hs;

  wire [MXHS * 4 - 1: 0] me1b_ly0hs;
  wire [MXHS * 4 - 1: 0] me1b_ly1hs;
  wire [MXHS * 4 - 1: 0] me1b_ly2hs;
  wire [MXHS * 4 - 1: 0] me1b_ly3hs;
  wire [MXHS * 4 - 1: 0] me1b_ly4hs;
  wire [MXHS * 4 - 1: 0] me1b_ly5hs;

  // Orientation flags
  assign csc_type        = 4'hD; // Firmware compile type
  assign csc_me1ab       = 1;    // 1 = ME1A or ME1B CSC
  assign stagger_hs_csc  = 0;    // 1 = Staggered CSC non-ME1
  assign reverse_hs_csc  = 0;    // 1 = Reversed  CSC non-ME1
  assign reverse_hs_me1a = 0;    // 1 = Reverse ME1A HalfStrips prior to pattern sorting
  assign reverse_hs_me1b = 1;    // 1 = Reverse ME1B HalfStrips prior to pattern sorting
  initial $display ("CSC_TYPE_D instantiated");

  // Generate hs reversal map for ME1B
  wire [MXHS - 1: 0] cfeb0_ly0hsr, cfeb0_ly1hsr, cfeb0_ly2hsr, cfeb0_ly3hsr, cfeb0_ly4hsr, cfeb0_ly5hsr;
  wire [MXHS - 1: 0] cfeb1_ly0hsr, cfeb1_ly1hsr, cfeb1_ly2hsr, cfeb1_ly3hsr, cfeb1_ly4hsr, cfeb1_ly5hsr;
  wire [MXHS - 1: 0] cfeb2_ly0hsr, cfeb2_ly1hsr, cfeb2_ly2hsr, cfeb2_ly3hsr, cfeb2_ly4hsr, cfeb2_ly5hsr;
  wire [MXHS - 1: 0] cfeb3_ly0hsr, cfeb3_ly1hsr, cfeb3_ly2hsr, cfeb3_ly3hsr, cfeb3_ly4hsr, cfeb3_ly5hsr;

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
    end
  endgenerate

  // Normal ME1A CFEBs: 6, 5, 4
  assign me1a_ly0hs = {cfeb6_ly0hs, cfeb5_ly0hs, cfeb4_ly0hs};
  assign me1a_ly1hs = {cfeb6_ly1hs, cfeb5_ly1hs, cfeb4_ly1hs};
  assign me1a_ly2hs = {cfeb6_ly2hs, cfeb5_ly2hs, cfeb4_ly2hs};
  assign me1a_ly3hs = {cfeb6_ly3hs, cfeb5_ly3hs, cfeb4_ly3hs};
  assign me1a_ly4hs = {cfeb6_ly4hs, cfeb5_ly4hs, cfeb4_ly4hs};
  assign me1a_ly5hs = {cfeb6_ly5hs, cfeb5_ly5hs, cfeb4_ly5hs};

  // Reversed ME1B CFEBs: 0, 1, 2, 3
  assign me1b_ly0hs = {cfeb0_ly0hsr, cfeb1_ly0hsr, cfeb2_ly0hsr, cfeb3_ly0hsr};
  assign me1b_ly1hs = {cfeb0_ly1hsr, cfeb1_ly1hsr, cfeb2_ly1hsr, cfeb3_ly1hsr};
  assign me1b_ly2hs = {cfeb0_ly2hsr, cfeb1_ly2hsr, cfeb2_ly2hsr, cfeb3_ly2hsr};
  assign me1b_ly3hs = {cfeb0_ly3hsr, cfeb1_ly3hsr, cfeb2_ly3hsr, cfeb3_ly3hsr};
  assign me1b_ly4hs = {cfeb0_ly4hsr, cfeb1_ly4hsr, cfeb2_ly4hsr, cfeb3_ly4hsr};
  assign me1b_ly5hs = {cfeb0_ly5hsr, cfeb1_ly5hsr, cfeb2_ly5hsr, cfeb3_ly5hsr};

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
//-------------------------------------------------------------------------------------------------------------------
  wire [MXHSX - 1: 0] ly0hs;
  wire [MXHSX - 1: 0] ly1hs;
  wire [MXHSX - 1: 0] ly2hs;      // key layer 2
  wire [MXHSX - 1: 0] ly3hs;
  wire [MXHSX - 1: 0] ly4hs;
  wire [MXHSX - 1: 0] ly5hs;

  assign ly0hs = {me1a_ly0hs, me1b_ly0hs}; // No stagger correction
  assign ly1hs = {me1a_ly1hs, me1b_ly1hs};
  assign ly2hs = {me1a_ly2hs, me1b_ly2hs};
  assign ly3hs = {me1a_ly3hs, me1b_ly3hs};
  assign ly4hs = {me1a_ly4hs, me1b_ly4hs};
  assign ly5hs = {me1a_ly5hs, me1b_ly5hs};

//-------------------------------------------------------------------------------------------------------------------
// Stage 4C:  Layer-trigger mode
//-------------------------------------------------------------------------------------------------------------------
  // Layer Trigger Mode, delay 1bx for FF
  reg [MXLY - 1: 0] layer_or_s0;

  always @(posedge clock) begin
    layer_or_s0[0] = | {cfeb6_ly0hs, cfeb5_ly0hs, cfeb4_ly0hs, cfeb3_ly0hs, cfeb2_ly0hs, cfeb1_ly0hs, cfeb0_ly0hs};
    layer_or_s0[1] = | {cfeb6_ly1hs, cfeb5_ly1hs, cfeb4_ly1hs, cfeb3_ly1hs, cfeb2_ly1hs, cfeb1_ly1hs, cfeb0_ly1hs};
    layer_or_s0[2] = | {cfeb6_ly2hs, cfeb5_ly2hs, cfeb4_ly2hs, cfeb3_ly2hs, cfeb2_ly2hs, cfeb1_ly2hs, cfeb0_ly2hs};
    layer_or_s0[3] = | {cfeb6_ly3hs, cfeb5_ly3hs, cfeb4_ly3hs, cfeb3_ly3hs, cfeb2_ly3hs, cfeb1_ly3hs, cfeb0_ly3hs};
    layer_or_s0[4] = | {cfeb6_ly4hs, cfeb5_ly4hs, cfeb4_ly4hs, cfeb3_ly4hs, cfeb2_ly4hs, cfeb1_ly4hs, cfeb0_ly4hs};
    layer_or_s0[5] = | {cfeb6_ly5hs, cfeb5_ly5hs, cfeb4_ly5hs, cfeb3_ly5hs, cfeb2_ly5hs, cfeb1_ly5hs, cfeb0_ly5hs};
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

  // Delay 4bx to latch in time with 1st and 2nd clct, need to FF these again to align
  wire [MXLY - 1: 0]   hs_layer_or_dly;
  wire [MXHITB - 1: 0] hs_nlayers_hit_dly;

  parameter dlyb = 4'd3;
  srl16e_bbl #(1)      udlyb0 ( .clock(clock), .ce(1'b1), .adr(dlyb), .d(layer_trig_s0 ), .q(hs_layer_latch    ) );
  srl16e_bbl #(MXHITB) udlyb1 ( .clock(clock), .ce(1'b1), .adr(dlyb), .d(nlayers_hit_s0), .q(hs_nlayers_hit_dly) );
  srl16e_bbl #(1)      udlyb2 ( .clock(clock), .ce(1'b1), .adr(dlyb), .d(layer_trig_s0 ), .q(hs_layer_trig_dly ) );
  srl16e_bbl #(MXLY)   udlyb3 ( .clock(clock), .ce(1'b1), .adr(dlyb), .d(layer_or_s0   ), .q(hs_layer_or_dly   ) );

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
//                               22222222 22222
//                               11112222 22222
//       hs  54321 01234567      67890123 45678
// ly0[10:0] 00000|aaaaaaaa......bbbbbbbb|00000
// ly1[ 7:3]    00|aaaaaaaa......bbbbbbbb|00
// ly2[ 5:5]      |aaaaaaaa......bbbbbbbb|
// ly3[ 7:3]    00|aaaaaaaa......bbbbbbbb|00
// ly4[ 9:1]  0000|aaaaaaaa......bbbbbbbb|0000
// ly5[10:0] 00000|aaaaaaaa......bbbbbbbb|00000
//
//-------------------------------------------------------------------------------------------------------------------
  // Create HalfStrip arrays with 0s padded at left and right csc edges
  parameter k      = 5;  // Shift negative array indexes positive
  parameter MXHSXA = 224;  // Last hs +1 on ME1A
  parameter MXHSXB = 128;  // Last hs +1 on ME1B

  wire [MXHSXA - 1 + 5 + k: MXHSXB - 5 + k] ly0hs_pad_me1a;
  wire [MXHSXA - 1 + 2 + k: MXHSXB - 2 + k] ly1hs_pad_me1a;
  wire [MXHSXA - 1 + 0 + k: MXHSXB - 0 + k] ly2hs_pad_me1a;
  wire [MXHSXA - 1 + 2 + k: MXHSXB - 2 + k] ly3hs_pad_me1a;
  wire [MXHSXA - 1 + 4 + k: MXHSXB - 4 + k] ly4hs_pad_me1a;
  wire [MXHSXA - 1 + 5 + k: MXHSXB - 5 + k] ly5hs_pad_me1a;

  wire [MXHSXB - 1 + 5 + k: 0 - 5 + k] ly0hs_pad_me1b;
  wire [MXHSXB - 1 + 2 + k: 0 - 2 + k] ly1hs_pad_me1b;
  wire [MXHSXB - 1 + 0 + k: 0 - 0 + k] ly2hs_pad_me1b;
  wire [MXHSXB - 1 + 2 + k: 0 - 2 + k] ly3hs_pad_me1b;
  wire [MXHSXB - 1 + 4 + k: 0 - 4 + k] ly4hs_pad_me1b;
  wire [MXHSXB - 1 + 5 + k: 0 - 5 + k] ly5hs_pad_me1b;

  // Pad 0s beyond CSC edges ME1A hs128-223, isolate it from ME1B
  assign ly0hs_pad_me1a = {5'b00000, ly0hs[223: 128], 5'b00000};
  assign ly1hs_pad_me1a = {   2'b00, ly1hs[223: 128], 2'b00   };
  assign ly2hs_pad_me1a = {          ly2hs[223: 128]          };
  assign ly3hs_pad_me1a = {   2'b00, ly3hs[223: 128], 2'b00   };
  assign ly4hs_pad_me1a = { 4'b0000, ly4hs[223: 128], 4'b0000 };
  assign ly5hs_pad_me1a = {5'b00000, ly5hs[223: 128], 5'b00000};

  // Pad 0s beyond CSC edges ME1B hs0-127, isolate it from ME1A
  assign ly0hs_pad_me1b = {5'b00000, ly0hs[127: 0], 5'b00000};
  assign ly1hs_pad_me1b = {   2'b00, ly1hs[127: 0], 2'b00   };
  assign ly2hs_pad_me1b = {          ly2hs[127: 0]          };
  assign ly3hs_pad_me1b = {   2'b00, ly3hs[127: 0], 2'b00   };
  assign ly4hs_pad_me1b = { 4'b0000, ly4hs[127: 0], 4'b0000 };
  assign ly5hs_pad_me1b = {5'b00000, ly5hs[127: 0], 5'b00000};

  // Find pattern hits for each HalfStrip key
  wire [MXHITB - 1: 0] hs_hit [MXHSX - 1: 0];
  wire [MXPIDB - 1: 0] hs_pid [MXHSX - 1: 0];

  generate
    for (ihs = 128; ihs <= 223; ihs = ihs + 1) begin: patgen_me1a
      pattern_unit upat_me1a (
        .ly0 (ly0hs_pad_me1a[ihs + 5 + k: ihs - 5 + k]),
        .ly1 (ly1hs_pad_me1a[ihs + 2 + k: ihs - 2 + k]),
        .ly2 (ly2hs_pad_me1a[ihs + 0 + k: ihs - 0 + k]),  //key on ly2
        .ly3 (ly3hs_pad_me1a[ihs + 2 + k: ihs - 2 + k]),
        .ly4 (ly4hs_pad_me1a[ihs + 4 + k: ihs - 4 + k]),
        .ly5 (ly5hs_pad_me1a[ihs + 5 + k: ihs - 5 + k]),
        .pat_nhits (hs_hit[ihs]),
        .pat_id (hs_pid[ihs]));
    end
  endgenerate

  generate
    for (ihs = 0; ihs <= 127; ihs = ihs + 1) begin: patgen_me1b
      pattern_unit upat_me1b (
        .ly0 (ly0hs_pad_me1b[ihs + 5 + k: ihs - 5 + k]),
        .ly1 (ly1hs_pad_me1b[ihs + 2 + k: ihs - 2 + k]),
        .ly2 (ly2hs_pad_me1b[ihs + 0 + k: ihs - 0 + k]),  //key on ly2
        .ly3 (ly3hs_pad_me1b[ihs + 2 + k: ihs - 2 + k]),
        .ly4 (ly4hs_pad_me1b[ihs + 4 + k: ihs - 4 + k]),
        .ly5 (ly5hs_pad_me1b[ihs + 5 + k: ihs - 5 + k]),
        .pat_nhits (hs_hit[ihs]),
        .pat_id (hs_pid[ihs]));
    end
  endgenerate

  // Store Pattern Unit results
  reg [MXHITB - 1: 0] hs_hit_s0ab [MXHSX - 1: 0];
  reg [MXPIDB - 1: 0] hs_pid_s0ab [MXHSX - 1: 0];

  generate
    for (ihs = 0; ihs <= MXHSX - 1; ihs = ihs + 1) begin: store_ab
      always @(posedge clock) begin
        hs_hit_s0ab[ihs] <= hs_hit[ihs];
        hs_pid_s0ab[ihs] <= hs_pid[ihs];
      end
    end
  endgenerate

  // S0 latch: realign with main clock, legacy to maintain sequencer timing
  reg [MXHITB - 1: 0] hs_hit_s0 [MXHSX - 1: 0];
  reg [MXPIDB - 1: 0] hs_pid_s0 [MXHSX - 1: 0];

  generate
    for (ihs = 0; ihs <= MXHSX - 1; ihs = ihs + 1) begin: store_s0
      always @(posedge clock) begin
        hs_hit_s0[ihs] <= hs_hit_s0ab[ihs];
        hs_pid_s0[ihs] <= hs_pid_s0ab[ihs];
      end
    end
  endgenerate

  // pre-s0 latch signals for pre-trigger speed
  wire [MXHITB - 1: 0] hs_hit_pre_s0 [MXHSX - 1: 0];
  wire [MXPIDB - 1: 0] hs_pid_pre_s0 [MXHSX - 1: 0];

  generate
    for (ihs = 0; ihs <= MXHSX - 1; ihs = ihs + 1) begin: build_pad_ab
      assign hs_hit_pre_s0[ihs] = hs_hit_s0ab[ihs];
      assign hs_pid_pre_s0[ihs] = hs_pid_s0ab[ihs];
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
//     Set active FEB bit ASAP if any pattern is over threshold.
//    It comes out before the priority encoder result
//-------------------------------------------------------------------------------------------------------------------
  // Flag keys with pattern hits over threshold, use fast-out hit numbers before s0 latch
  reg [MXHS - 1: 0] hs_key_hit0, hs_key_pid0, hs_key_dmb0;
  reg [MXHS - 1: 0] hs_key_hit1, hs_key_pid1, hs_key_dmb1;
  reg [MXHS - 1: 0] hs_key_hit2, hs_key_pid2, hs_key_dmb2;
  reg [MXHS - 1: 0] hs_key_hit3, hs_key_pid3, hs_key_dmb3;
  reg [MXHS - 1: 0] hs_key_hit4, hs_key_pid4, hs_key_dmb4;
  reg [MXHS - 1: 0] hs_key_hit5, hs_key_pid5, hs_key_dmb5;
  reg [MXHS - 1: 0] hs_key_hit6, hs_key_pid6, hs_key_dmb6;

  // Display CSC_TYPE
`ifdef CSC_TYPE_C initial $display ("CSC_TYPE_C is defined for pre-trigger look-ahead"); `endif
`ifdef CSC_TYPE_D initial $display ("CSC_TYPE_D is defined for pre-trigger look-ahead"); `endif

  // Flag keys with pattern hits over threshold, use fast-out hit numbers before s0 latch
  generate

    for (ihs = 0; ihs <= MXHS - 1; ihs = ihs + 1) begin: thrg
      always @(posedge clock) begin: thrff
        `ifdef CSC_TYPE_C 
        // Reversed ME1A, Normal ME1B
        hs_key_hit0[ihs] = (hs_hit_pre_s0[ihs + MXHS * 0]     >= hit_thresh_pretrig_ff); // Normal ME1B
        hs_key_hit1[ihs] = (hs_hit_pre_s0[ihs + MXHS * 1]     >= hit_thresh_pretrig_ff);
        hs_key_hit2[ihs] = (hs_hit_pre_s0[ihs + MXHS * 2]     >= hit_thresh_pretrig_ff);
        hs_key_hit3[ihs] = (hs_hit_pre_s0[ihs + MXHS * 3]     >= hit_thresh_pretrig_ff);
        hs_key_hit4[ihs] = (hs_hit_pre_s0[MXHS * 7 - 1 - ihs] >= hit_thresh_pretrig_ff); // Reversed ME1A
        hs_key_hit5[ihs] = (hs_hit_pre_s0[MXHS * 6 - 1 - ihs] >= hit_thresh_pretrig_ff);
        hs_key_hit6[ihs] = (hs_hit_pre_s0[MXHS * 5 - 1 - ihs] >= hit_thresh_pretrig_ff);

        hs_key_pid0[ihs] = (hs_pid_pre_s0[ihs + MXHS * 0]     >= pid_thresh_pretrig_ff); // Normal ME1B
        hs_key_pid1[ihs] = (hs_pid_pre_s0[ihs + MXHS * 1]     >= pid_thresh_pretrig_ff);
        hs_key_pid2[ihs] = (hs_pid_pre_s0[ihs + MXHS * 2]     >= pid_thresh_pretrig_ff);
        hs_key_pid3[ihs] = (hs_pid_pre_s0[ihs + MXHS * 3]     >= pid_thresh_pretrig_ff);
        hs_key_pid4[ihs] = (hs_pid_pre_s0[MXHS * 7 - 1 - ihs] >= pid_thresh_pretrig_ff); // Reversed ME1A
        hs_key_pid5[ihs] = (hs_pid_pre_s0[MXHS * 6 - 1 - ihs] >= pid_thresh_pretrig_ff);
        hs_key_pid6[ihs] = (hs_pid_pre_s0[MXHS * 5 - 1 - ihs] >= pid_thresh_pretrig_ff);

        hs_key_dmb0[ihs] = (hs_hit_pre_s0[ihs + MXHS * 0]     >= dmb_thresh_pretrig_ff); // Normal ME1B
        hs_key_dmb1[ihs] = (hs_hit_pre_s0[ihs + MXHS * 1]     >= dmb_thresh_pretrig_ff);
        hs_key_dmb2[ihs] = (hs_hit_pre_s0[ihs + MXHS * 2]     >= dmb_thresh_pretrig_ff);
        hs_key_dmb3[ihs] = (hs_hit_pre_s0[ihs + MXHS * 3]     >= dmb_thresh_pretrig_ff);
        hs_key_dmb4[ihs] = (hs_hit_pre_s0[MXHS * 7 - 1 - ihs] >= dmb_thresh_pretrig_ff); // Reversed ME1A
        hs_key_dmb5[ihs] = (hs_hit_pre_s0[MXHS * 6 - 1 - ihs] >= dmb_thresh_pretrig_ff);
        hs_key_dmb6[ihs] = (hs_hit_pre_s0[MXHS * 5 - 1 - ihs] >= dmb_thresh_pretrig_ff);

        `elsif CSC_TYPE_D
         // Normal ME1A, Reversed ME1B
        hs_key_hit0[ihs] = (hs_hit_pre_s0[MXHS * 4 - 1 - ihs] >= hit_thresh_pretrig_ff); // Reversed ME1B
        hs_key_hit1[ihs] = (hs_hit_pre_s0[MXHS * 3 - 1 - ihs] >= hit_thresh_pretrig_ff);
        hs_key_hit2[ihs] = (hs_hit_pre_s0[MXHS * 2 - 1 - ihs] >= hit_thresh_pretrig_ff);
        hs_key_hit3[ihs] = (hs_hit_pre_s0[MXHS * 1 - 1 - ihs] >= hit_thresh_pretrig_ff);
        hs_key_hit4[ihs] = (hs_hit_pre_s0[ihs + MXHS * 4]     >= hit_thresh_pretrig_ff); // Normal ME1A
        hs_key_hit5[ihs] = (hs_hit_pre_s0[ihs + MXHS * 5]     >= hit_thresh_pretrig_ff);
        hs_key_hit6[ihs] = (hs_hit_pre_s0[ihs + MXHS * 6]     >= hit_thresh_pretrig_ff);

        hs_key_pid0[ihs] = (hs_pid_pre_s0[MXHS * 4 - 1 - ihs] >= pid_thresh_pretrig_ff); // Reversed ME1B
        hs_key_pid1[ihs] = (hs_pid_pre_s0[MXHS * 3 - 1 - ihs] >= pid_thresh_pretrig_ff);
        hs_key_pid2[ihs] = (hs_pid_pre_s0[MXHS * 2 - 1 - ihs] >= pid_thresh_pretrig_ff);
        hs_key_pid3[ihs] = (hs_pid_pre_s0[MXHS * 1 - 1 - ihs] >= pid_thresh_pretrig_ff);
        hs_key_pid4[ihs] = (hs_pid_pre_s0[ihs + MXHS * 4]     >= pid_thresh_pretrig_ff); // Normal ME1A
        hs_key_pid5[ihs] = (hs_pid_pre_s0[ihs + MXHS * 5]     >= pid_thresh_pretrig_ff);
        hs_key_pid6[ihs] = (hs_pid_pre_s0[ihs + MXHS * 6]     >= pid_thresh_pretrig_ff);

        hs_key_dmb0[ihs] = (hs_hit_pre_s0[MXHS * 4 - 1 - ihs] >= dmb_thresh_pretrig_ff); // Reversed ME1B
        hs_key_dmb1[ihs] = (hs_hit_pre_s0[MXHS * 3 - 1 - ihs] >= dmb_thresh_pretrig_ff);
        hs_key_dmb2[ihs] = (hs_hit_pre_s0[MXHS * 2 - 1 - ihs] >= dmb_thresh_pretrig_ff);
        hs_key_dmb3[ihs] = (hs_hit_pre_s0[MXHS * 1 - 1 - ihs] >= dmb_thresh_pretrig_ff);
        hs_key_dmb4[ihs] = (hs_hit_pre_s0[ihs + MXHS * 4]     >= dmb_thresh_pretrig_ff); // Normal ME1A
        hs_key_dmb5[ihs] = (hs_hit_pre_s0[ihs + MXHS * 5]     >= dmb_thresh_pretrig_ff);
        hs_key_dmb6[ihs] = (hs_hit_pre_s0[ihs + MXHS * 6]     >= dmb_thresh_pretrig_ff);
      
        `else
          initial $display ("CSC_TYPE Undefined. Halting.");
          $finish
        `endif
      end
    end
  endgenerate

  // Output active FEB signal, and adjacent FEBs if hit is near board boundary
  wire [6: 1] cfebnm1_hit;  // Adjacent CFEB-1 has a pattern over threshold, there is no CFEB0-1
  wire [5: 0] cfebnp1_hit;  // Adjacent CFEB+1 has a pattern over threshold, there is no CFEB6+1

  wire [MXHS - 1: 0] hs_key_hitpid0 = hs_key_hit0 & hs_key_pid0; // hits on key satify both hit and pid thresholds
  wire [MXHS - 1: 0] hs_key_hitpid1 = hs_key_hit1 & hs_key_pid1;
  wire [MXHS - 1: 0] hs_key_hitpid2 = hs_key_hit2 & hs_key_pid2;
  wire [MXHS - 1: 0] hs_key_hitpid3 = hs_key_hit3 & hs_key_pid3;
  wire [MXHS - 1: 0] hs_key_hitpid4 = hs_key_hit4 & hs_key_pid4;
  wire [MXHS - 1: 0] hs_key_hitpid5 = hs_key_hit5 & hs_key_pid5;
  wire [MXHS - 1: 0] hs_key_hitpid6 = hs_key_hit6 & hs_key_pid6;

  wire cfeb_layer_trigger = cfeb_layer_trig && layer_trig_en_ff;

  assign cfeb_hit[0] = ( ( | hs_key_hitpid0) || cfeb_layer_trigger ) && cfeb_en_ff[0];
  assign cfeb_hit[1] = ( ( | hs_key_hitpid1) || cfeb_layer_trigger ) && cfeb_en_ff[1];
  assign cfeb_hit[2] = ( ( | hs_key_hitpid2) || cfeb_layer_trigger ) && cfeb_en_ff[2];
  assign cfeb_hit[3] = ( ( | hs_key_hitpid3) || cfeb_layer_trigger ) && cfeb_en_ff[3];
  assign cfeb_hit[4] = ( ( | hs_key_hitpid4) || cfeb_layer_trigger ) && cfeb_en_ff[4];
  assign cfeb_hit[5] = ( ( | hs_key_hitpid5) || cfeb_layer_trigger ) && cfeb_en_ff[5];
  assign cfeb_hit[6] = ( ( | hs_key_hitpid6) || cfeb_layer_trigger ) && cfeb_en_ff[6];

  assign cfebnm1_hit[1] = | (hs_key_hitpid1 & adjcfeb_mask_nm1); // cfeb1 has hits near cfeb0
  assign cfebnm1_hit[2] = | (hs_key_hitpid2 & adjcfeb_mask_nm1); // cfeb2 has hits near cfeb1
  assign cfebnm1_hit[3] = | (hs_key_hitpid3 & adjcfeb_mask_nm1); // cfeb3 has hits near cfeb2
  assign cfebnm1_hit[4] = 0; // cfeb4 does not see cfeb3
  assign cfebnm1_hit[5] = | (hs_key_hitpid5 & adjcfeb_mask_nm1); // cfeb5 has hits near cfeb4
  assign cfebnm1_hit[6] = | (hs_key_hitpid6 & adjcfeb_mask_nm1); // cfeb6 has hits near cfeb5

  assign cfebnp1_hit[0] = | (hs_key_hitpid0 & adjcfeb_mask_np1); // cfeb0 has hits near cfeb1
  assign cfebnp1_hit[1] = | (hs_key_hitpid1 & adjcfeb_mask_np1); // cfeb1 has hits near cfeb2
  assign cfebnp1_hit[2] = | (hs_key_hitpid2 & adjcfeb_mask_np1); // cfeb2 has hits near cfeb3
  assign cfebnp1_hit[3] = 0; // cfeb3 does not see cfeb4
  assign cfebnp1_hit[4] = | (hs_key_hitpid4 & adjcfeb_mask_np1); // cfeb4 has hits near cfeb5
  assign cfebnp1_hit[5] = | (hs_key_hitpid5 & adjcfeb_mask_np1); // cfeb5 has hits near cfeb6

  // Output active FEB signal, and adjacent FEBs if hit is near board boundary
  assign cfeb_active[0] = (cfebnm1_hit[1] || cfeb_hit[0] ||                   ( | hs_key_dmb0)) && cfeb_en_ff[0];
  assign cfeb_active[1] = (cfebnm1_hit[2] || cfeb_hit[1] || cfebnp1_hit[0] || ( | hs_key_dmb1)) && cfeb_en_ff[1];
  assign cfeb_active[2] = (cfebnm1_hit[3] || cfeb_hit[2] || cfebnp1_hit[1] || ( | hs_key_dmb2)) && cfeb_en_ff[2];
  assign cfeb_active[3] = (                  cfeb_hit[3] || cfebnp1_hit[2] || ( | hs_key_dmb3)) && cfeb_en_ff[3];

  assign cfeb_active[4] = (cfebnm1_hit[5] || cfeb_hit[4] ||                   ( | hs_key_dmb4)) && cfeb_en_ff[4];
  assign cfeb_active[5] = (cfebnm1_hit[6] || cfeb_hit[5] || cfebnp1_hit[4] || ( | hs_key_dmb5)) && cfeb_en_ff[5];
  assign cfeb_active[6] = (                  cfeb_hit[6] || cfebnp1_hit[5] || ( | hs_key_dmb6)) && cfeb_en_ff[6];

//-------------------------------------------------------------------------------------------------------------------
// Stage 5B: 1/2-Strip Priority Encoder
//     Select the 1st best pattern from 224 Key 1/2-Strips
//-------------------------------------------------------------------------------------------------------------------
  // Best 7 of 224 1/2-strip patterns
  wire [MXPATB - 1: 0] hs_pat_s1 [6: 0];
  wire [MXKEYB - 1: 0] hs_key_s1 [6: 0]; // partial key for 1 of 32

  genvar i;
  generate
    for (i = 0; i <= 6; i = i + 1) begin: hs_gen
      best_1of32 ubest1of32_1st (
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
        .best_pat(hs_pat_s1[i]),
        .best_key(hs_key_s1[i])
      );
    end
  endgenerate

  // Best 1 of 7 HalfStrip patterns
  wire [MXPATB - 1: 0]  hs_pat_s2;
  wire [MXKEYBX - 1: 0] hs_key_s2;  // full key for 1 of 224

  best_1of7 ubest1of7_1st(
    .pat0(hs_pat_s1[0]),
    .pat1(hs_pat_s1[1]),
    .pat2(hs_pat_s1[2]),
    .pat3(hs_pat_s1[3]),
    .pat4(hs_pat_s1[4]),
    .pat5(hs_pat_s1[5]),
    .pat6(hs_pat_s1[6]),

    .key0(hs_key_s1[0]),
    .key1(hs_key_s1[1]),
    .key2(hs_key_s1[2]),
    .key3(hs_key_s1[3]),
    .key4(hs_key_s1[4]),
    .key5(hs_key_s1[5]),
    .key6(hs_key_s1[6]),

    .best_pat(hs_pat_s2),
    .best_key(hs_key_s2)
  );

  // Latch final hs pattern data for 1st CLCT
  reg [MXPATB - 1: 0]  hs_pat_1st_nodly;
  reg [MXKEYBX - 1: 0] hs_key_1st_nodly;

  always @(posedge clock) begin
    hs_pat_1st_nodly <= hs_pat_s2;
    hs_key_1st_nodly <= hs_key_s2;
  end

//-------------------------------------------------------------------------------------------------------------------
// Stage 6A: Delay 1st CLCT to output at same time as 2nd CLCT
//-------------------------------------------------------------------------------------------------------------------
  wire [MXPATB - 1: 0]  hs_pat_1st_dly;
  wire [MXKEYBX - 1: 0] hs_key_1st_dly;
  wire [MXHITB - 1: 0]  hs_hit_1st_dly;

  parameter cdly = 4'd0;

  srl16e_bbl #(MXPATB ) upatbbl (.clock(clock), .ce(1'b1), .adr(cdly), .d(hs_pat_1st_nodly), .q(hs_pat_1st_dly));
  srl16e_bbl #(MXKEYBX) ukeybbl (.clock(clock), .ce(1'b1), .adr(cdly), .d(hs_key_1st_nodly), .q(hs_key_1st_dly));

  // Final 1st CLCT flipflop
  reg [MXPIDB - 1: 0]  hs_pid_1st;
  reg [MXHITB - 1: 0]  hs_hit_1st;
  reg [MXKEYBX - 1: 0] hs_key_1st;

  assign hs_hit_1st_dly = hs_pat_1st_dly[MXPATB - 1: MXPIDB];
  wire blank_1st    = ((hs_hit_1st_dly == 0) && (clct_blanking == 1)) || purging;
  wire lyr_trig_1st = (hs_layer_latch && layer_trig_en_ff);

  always @(posedge clock) begin
    if (blank_1st) begin       // blank 1st CLCT
      hs_pid_1st <= 0;
      hs_hit_1st <= 0;
      hs_key_1st <= 0;
    end
    else if (lyr_trig_1st) begin      // layer-trigger mode
      hs_pid_1st <= 1;                  // Pattern id=1 for layer triggers
      hs_hit_1st <= hs_nlayers_hit_dly; // Insert number of layers hit
      hs_key_1st <= 0;                  // Dummy key
    end
    else begin          // else assert final 1st clct
      hs_key_1st <= hs_key_1st_dly;
      hs_pid_1st <= hs_pat_1st_dly[MXPIDB - 1: 0];
      hs_hit_1st <= hs_pat_1st_dly[MXPATB - 1: MXPIDB];
    end
  end

  // FF layer-mode status
  reg                 hs_layer_trig;
  reg [MXLY - 1: 0]   hs_layer_or;
  reg [MXHITB - 1: 0] hs_nlayers_hit;

  always @(posedge clock) begin
    hs_layer_trig  <= hs_layer_trig_dly;
    hs_layer_or    <= hs_layer_or_dly;
    hs_nlayers_hit <= hs_nlayers_hit_dly;
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

  wire clct0_is_on_me1a = hs_key_s2[MXKEYBX - 1]; // 1 for CFEBs 4,5,6  and 0 for CFEBs 0,1,2,3

  always @ * begin
    if (clct0_is_on_me1a) begin // CLCT0 is on ME1A cfeb4-6, limit blanking region to 128-223
      busy_max <= (hs_key_s2 <= 223 - pspan) ? hs_key_s2 + pspan : 8'd223;
      busy_min <= (hs_key_s2 >= 128 + nspan) ? hs_key_s2 - nspan : 8'd128;
    end
    else begin // CLCT0 is on ME1B cfeb0-cfeb3, limit blanking region to 0-127
      busy_max <= (hs_key_s2 <= 127 - pspan) ? hs_key_s2 + pspan : 8'd127;
      busy_min <= (hs_key_s2 >= nspan) ? hs_key_s2 - nspan : 8'd0;
    end
  end

  // Latch busy key 1/2-strips for excluding 2nd clct
  reg [MXHSX - 1: 0] busy_key;

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
//    Find 2nd best of 224 patterns, excluding busy region around 1st best key
//-------------------------------------------------------------------------------------------------------------------
  // Delay 1st CLCT pattern numbers to align in time with 1st CLCT busy keys
  wire [MXPATB - 1: 0] hs_pat_s3 [MXHSX - 1: 0];

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
    end
  endgenerate

  // Best 7 of 224 1/2-strip patterns
  wire [MXPATB - 1: 0] hs_pat_s4 [6: 0];
  wire [MXKEYB - 1: 0] hs_key_s4 [6: 0]; // partial key for 1 of 32
  wire [6: 0]          hs_bsy_s4;

  generate
    for (i = 0; i <= 6; i = i + 1) begin: hs_2nd_gen
      best_1of32_busy ubest1of32_2nd (
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
        .bsy(busy_key[i * 32 + 31: i * 32]),
        .best_pat(hs_pat_s4[i]),
        .best_key(hs_key_s4[i]),
        .best_bsy(hs_bsy_s4[i])
      );
    end
  endgenerate

  // Best 1 of 7 1/2-strip patterns
  wire [MXPATB - 1: 0]  hs_pat_s5;
  wire [MXKEYBX - 1: 0] hs_key_s5;  // full key for 1 of 224
  wire [MXHITB - 1: 0]  hs_hit_s5;
  wire hs_bsy_s5;

  best_1of7_busy ubest1of7_2nd (
    .pat0(hs_pat_s4[0]),
    .pat1(hs_pat_s4[1]),
    .pat2(hs_pat_s4[2]),
    .pat3(hs_pat_s4[3]),
    .pat4(hs_pat_s4[4]),
    .pat5(hs_pat_s4[5]),
    .pat6(hs_pat_s4[6]),

    .key0(hs_key_s4[0]),
    .key1(hs_key_s4[1]),
    .key2(hs_key_s4[2]),
    .key3(hs_key_s4[3]),
    .key4(hs_key_s4[4]),
    .key5(hs_key_s4[5]),
    .key6(hs_key_s4[6]),

    .bsy0(hs_bsy_s4[0]),
    .bsy1(hs_bsy_s4[1]),
    .bsy2(hs_bsy_s4[2]),
    .bsy3(hs_bsy_s4[3]),
    .bsy4(hs_bsy_s4[4]),
    .bsy5(hs_bsy_s4[5]),
    .bsy6(hs_bsy_s4[6]),

    .best_pat(hs_pat_s5),
    .best_key(hs_key_s5),
    .best_bsy(hs_bsy_s5)
  );

  // Latch final 2nd CLCT
  reg [MXPIDB - 1: 0]  hs_pid_2nd;
  reg [MXHITB - 1: 0]  hs_hit_2nd;
  reg [MXKEYBX - 1: 0] hs_key_2nd;
  reg hs_bsy_2nd;

  assign hs_hit_s5 = hs_pat_s5[MXPATB - 1: MXPIDB];
  wire blank_2nd    = ((hs_hit_s5 == 0) && (clct_blanking == 1)) || purging;
  wire lyr_trig_2nd = (hs_layer_latch && layer_trig_en_ff);

  always @(posedge clock) begin
    if (blank_2nd) begin
      hs_pid_2nd <= 0;
      hs_hit_2nd <= 0;
      hs_key_2nd <= 0;
      hs_bsy_2nd <= hs_bsy_s5;
    end
    else if (lyr_trig_2nd) begin    // layer-trigger mode
      hs_pid_2nd <= 0;
      hs_hit_2nd <= 0;
      hs_key_2nd <= 0;
      hs_bsy_2nd <= hs_bsy_s5;
    end
    else begin         // else assert final 2nd clct
      hs_pid_2nd <= hs_pat_s5[MXPIDB - 1: 0];
      hs_hit_2nd <= hs_pat_s5[MXPATB - 1: MXPIDB];
      hs_key_2nd <= hs_key_s5;
      hs_bsy_2nd <= hs_bsy_s5;
    end
  end

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
