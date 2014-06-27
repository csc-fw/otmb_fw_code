`timescale 1ns / 1ps
//--------------------------------------------------------------------------------------------------------
//  1-to-2 De-multiplexer converts 80MHz data to 40MHz
//--------------------------------------------------------------------------------------------------------
//  12/03/2001  Initial
//  01/29/2002  Added aclr input
//  03/03/2002  Replaced library FFs with behavioral FFs
//  06/04/2004  Add async set for MPC receiver
//  09/19/2006  Mod for xst
//  10/06/2006  Convert to DDR
//  07/15/2010  Conform port order to Virtex 6 version, change to non-blocking operators
//  05/02/2013  Port from Virtex-2
//--------------------------------------------------------------------------------------------------------
  module x_demux_ddr_mpc (clock,set,din,dout1st,dout2nd);

// Generic
  parameter WIDTH = 8;
  initial  $display("x_demux_ddr_mpc: WIDTH=%d",WIDTH);

// Ports
  input        clock;
  input        set;
  input  [WIDTH-1:0]  din;
  output  [WIDTH-1:0]  dout1st;
  output  [WIDTH-1:0]  dout2nd;

// Local
  reg    [WIDTH-1:0]  din1st;    // synthesis attribute IOB of din1st is "true"
  reg    [WIDTH-1:0]  din2nd;    // synthesis attribute IOB of din2nd is "true"
  reg    [WIDTH-1:0]  dout1st;
  reg    [WIDTH-1:0]  dout2nd;

// Latch 80 MHz multiplexed inputs in DDR IOB FFs
// Prefer to latch 1st-in-time on falling edge which reduces latency by 1 clock period
// This version latches 1st-in-time on rising edge to preserve latency of old-style mux version
  always @(posedge clock or posedge set) begin  // Latch 1st-in-time on rising edge
  if (set) din1st <= {WIDTH{1'b1}};        // async set
  else     din1st <= din;              // sync  store
  end

  always @(negedge clock or posedge set) begin  // Latch 2nd-in-time on falling edge
  if (set) din2nd <= {WIDTH{1'b1}};        // async set
  else     din2nd <= din;              // sync  store
  end

// Latch first and second time slices into 40MHz FFs FDCPE
// These are unnecessary legacy FFs to give DDR same timing as old  x_demux
  always @(posedge clock or posedge set) begin
  if (set) dout1st <= {WIDTH{1'b1}};        // async set
  else     dout1st <= din1st;            // sync  store
  end

  always @(posedge clock or posedge set) begin
  if (set) dout2nd <= {WIDTH{1'b1}};        // async set
  else     dout2nd <= din2nd;            // sync  store
  end

//--------------------------------------------------------------------------------------------------------
  endmodule
//--------------------------------------------------------------------------------------------------------
