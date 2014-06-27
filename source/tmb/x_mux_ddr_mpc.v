`timescale 1ns / 1ps
//-----------------------------------------------------------------------------------------------------------------------//
//  2-to-1 Multiplexer converts 40MHz data to 80MHz
//-----------------------------------------------------------------------------------------------------------------------//
//  12/03/2001  Initial
//  03/03/2002  Replaced library FFs with behavioral FFs
//  01/29/2003  Added async set to blank /mpc output at startup
//  09/19/2006  Mod for xst
//  10/10/2006  Convert to ddr for virtex2
//  01/22/2008  NB all virtex2 ddr outputs power up as 0 during GSR, the init attribute can not be applied
//  07/14/2010  Mod port order to conform to virtex 6 version
//  05/02/2013  Port from Virtex-2
//-----------------------------------------------------------------------------------------------------------------------
  module x_mux_ddr_mpc (clock,clock_en,set,din1st,din2nd,dout);

// Generic
  parameter WIDTH = 8;
  initial  $display("x_mux_ddr_mpc: WIDTH=%d",WIDTH);

// Ports
  input        clock;      // 40 MHz clock
  input        clock_en;    // Clock enable
  input        set;      // Async set
  input  [WIDTH-1:0]  din1st;      // Input data 1st-in-time
  input  [WIDTH-1:0]  din2nd;      // Input data 2nd-in-time
  output  [WIDTH-1:0]  dout;      // Output data multiplexed 2-to-1

// Latch second time slice to a holding FF FDCPE so dout will be aligned with 40MHz clock
  reg [WIDTH-1:0]  din2nd_ff = 0;

  always @(posedge clock or posedge set) begin
  if (set) din2nd_ff <= {WIDTH{1'b1}};// async preset
  else     din2nd_ff <= din2nd;    // sync  store
  end

// Generate array of output DDRs, xst can not infer ddr outputs
  genvar i;
  generate
  for (i=0; i<=WIDTH-1; i=i+1) begin: oddr_gen
  ODDR #(
  .DDR_CLK_EDGE ("OPPOSITE_EDGE"),  // "OPPOSITE_EDGE" or "SAME_EDGE" 
  .INIT         (1'b1),        // Initial value of Q: 1'b0 or 1'b1
  .SRTYPE       ("ASYNC")        // Set/Reset type: "SYNC" or "ASYNC" 
  ) u0 (
  .C  (clock),            // In  1-bit clock input
  .CE  (clock_en),            // In  1-bit clock enable input
  .S  (set),              // In  1-bit set
  .R  (1'b0),              // In  1-bit reset
  .D1  (din1st[i]),          // In  1-bit data input tx on positive edge
  .D2  (din2nd_ff[i]),          // In  1-bit data input tx on negative edge
  .Q  (dout[i]));            // Out  1-bit DDR output
  end
  endgenerate

//-----------------------------------------------------------------------------------------------------------------------
  endmodule
//-----------------------------------------------------------------------------------------------------------------------
