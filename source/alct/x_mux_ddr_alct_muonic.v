`timescale 1ns / 1ps
//-------------------------------------------------------------------------------------------------------------------
//  2-to-1 Multiplexer converts 40MHz data to 80MHz
//-------------------------------------------------------------------------------------------------------------------
//  12/03/2001  Initial
//  03/03/2002  Replaced library FFs with behavioral FFs
//  01/29/2003  Added async set to blank /mpc output at startup
//  09/19/2006  Mod for xst
//  10/10/2006  Convert to ddr for virtex2
//  01/22/2008  NB all virtex2 ddr outputs power up as 0 during GSR, the init attribute can not be applied
//  03/20/2009  ISE 10.1i ready
//  03/20/2009  Add sync stage and clock for fpga fabric, separate iob clock
//  03/23/2009  Reinstate din2nd holding stage
//  03/23/2009  Move holding stage to iob clock domain
//  03/24/2009  Add buffer ffs before iobs
//  03/26/2009  Add then remove iob clock buffers between fabric FFs and IOB FFs, didn't improve window
//  03/30/2009  Add inter-stage FFs with programmable clock phase
//  05/28/2009  Add skew and delay constraints to FF paths
//  06/03/2009  Turn off constraints to see if goodspots improves
//  06/12/2009  Change to lac commutator for interstage
//  06/15/2009  Add 1st|2nd swap for digital phase shifter
//  06/16/2009  Remove digital phase shifter
//  08/05/2009  Move timing constraints to ucf, remove async clear, add sync clear to IOB ffs
//  07/14/2010  Mod default width for sim, add display
//  05/02/2013  Port from Virtex-2
//-------------------------------------------------------------------------------------------------------------------
  module x_mux_ddr_alct_muonic
  (
    clock,
    clock_lac,
    clock_2x,
    clock_iob,
    clock_en,
    posneg,
    clr,
    din1st,
    din2nd,
    dout
  );

// Generic
  parameter WIDTH = 8;
  initial  $display("x_mux_ddr_alct_muonic: WIDTH=%d",WIDTH);

// Ports
  input              clock;     // 40MHz TMB main clock
  input              clock_lac; // 40MHz logic accessible clock
  input              clock_2x;  // 80MHz commutator clock
  input              clock_iob; // ALCT rx  40 MHz clock
  input              clock_en;  // Clock enable
  input              posneg;    // Select inter-stage clock 0 or 180 degrees
  input              clr;       // Sync clear
  input  [WIDTH-1:0] din1st;    // Input data 1st-in-time
  input  [WIDTH-1:0] din2nd;    // Input data 2nd-in-time
  output [WIDTH-1:0] dout;      // Output data multiplexed 2-to-1

// Latch fpga fabric inputs in main clock time domain
  reg  [2*WIDTH-1:0] din_ff = 0;
  wire [2*WIDTH-1:0] din;

  assign din = {din2nd,din1st};

  always @(posedge clock) begin
    din_ff <= din;
  end

// Interstage clock latches on rising or falling edge of main clock using clock_2x 
  reg  isen=0;

  always @(posedge clock_2x)begin
    isen <= clock_lac ^ posneg;
  end

// Latch fpga fabric inputs in an inter-stage time domain
  reg  [2*WIDTH-1:0] din_is_ff = 0;

  always @(posedge clock_2x) begin
    if (isen) din_is_ff <= din_ff; // din_is_ff changes every 25 ns, but either rising or falling edge (posneg)
  end

// Pass 1st & 2nd-in-time directly to ODDR in IOB clock time domain (use same-edge feature)
  wire [WIDTH-1:0] din1st_iobff;
  wire [WIDTH-1:0] din2nd_iobff;

  assign din1st_iobff = din_is_ff[WIDTH-1:0];
  assign din2nd_iobff = din_is_ff[2*WIDTH-1:WIDTH];

// Generate array of output IOB DDRs, xst can not infer ddr outputs, alas
  genvar i;
  generate
    for (i=0; i<=WIDTH-1; i=i+1) begin: ddr_gen
      ODDR #(
        .DDR_CLK_EDGE ("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
        .INIT         (1'b0),        // Initial value of Q: 1'b0 or 1'b1
        .SRTYPE       ("SYNC")       // Set/Reset type: "SYNC" or "ASYNC" 
      ) u0 (
        .C  (clock_iob),       // In  1-bit clock input
        .CE (clock_en),        // In  1-bit clock enable input
        .S  (1'b0),            // In  1-bit set
        .R  (clr),             // In  1-bit reset
        .D1 (din1st_iobff[i]), // In  1-bit data input tx on positive edge
        .D2 (din2nd_iobff[i]), // In  1-bit data input tx on negative edge
        .Q  (dout[i])          // Out  1-bit DDR output
      );
    end
  endgenerate

//-------------------------------------------------------------------------------------------------------------------
  endmodule
//-------------------------------------------------------------------------------------------------------------------
