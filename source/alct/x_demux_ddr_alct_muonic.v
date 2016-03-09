`timescale 1ns / 1ps
//------------------------------------------------------------------------------------------------------------------
//  1-to-2 De-multiplexer converts 80MHz data to 40MHz - ALCT Version
//------------------------------------------------------------------------------------------------------------------
//  07/10/2009  Initial  Copy from cfeb version, only difference is iob attribute is enabled in verilog, does not use ucf
//  07/22/2009  Remove posneg
//  08/05/2009  Remove interstage delay SRL and iob async clear, add final stage sync clear
//  08/13/2009  Put posneg back in
//  08/20/2009  2x posneg version with new ucf locs
//  07/19/2010  Conform to Virtex 6 ports
//  05/02/2013  Port from Virtex-2
//------------------------------------------------------------------------------------------------------------------
  module x_demux_ddr_alct_muonic
  (
    clock,
    clock_2x,
    clock_iob,
    clock_lac,
    posneg,
    clr,
    din,
    dout1st,
    dout2nd
  );

// Generic
  parameter WIDTH = 16;
  initial  $display("x_demux_ddr_alct_muonic: WIDTH=%d",WIDTH);

// Ports
  input              clock;     // 40MHz TMB main clock
  input              clock_2x;  // 80MHz commutator clock
  input              clock_iob; // 40MHZ iob ddr clock
  input              clock_lac; // 40MHz logic accessible clock
  input              posneg;    // Select inter-stage clock 0 or 180 degrees
  input              clr;       // Sync clear
  input  [WIDTH-1:0] din;       // 80MHz ddr data
  output [WIDTH-1:0] dout1st;   // Data de-multiplexed 1st in time
  output [WIDTH-1:0] dout2nd;   // Data de-multiplexed 2nd in time

// Latch 80 MHz multiplexed inputs in DDR IOB FFs in the clock_iob time domain
  reg    [WIDTH-1:0]  din1st=0;    // synthesis attribute IOB of din1st is "true";
  reg    [WIDTH-1:0]  din2nd=0;    // synthesis attribute IOB of din2nd is "true";    

  always @(negedge clock_iob) begin  // Latch 1st-in-time on falling edge
    din1st <= din;
  end
  
  always @(posedge clock_iob) begin  // Latch 2nd-in-time on rising edge
    din2nd <= din;
  end

// Delay 1st-in-time by 1/2 cycle to align with 2nd-in-time, in the clock_iob time domain
  reg   [WIDTH-1:0] din1st_ff=0;

  always @(posedge clock_iob) begin
    din1st_ff <= din1st;
  end

// Interstage clock enable latches data on rising or falling edge of main clock using clock_2x 
  reg  is_en=0;

  always @(posedge clock_2x)begin
    is_en <= clock_lac ^ posneg;
  end

// Latch demux data in inter-stage time domain
  reg [WIDTH-1:0]  din1st_is=0;
  reg [WIDTH-1:0]  din2nd_is=0;

  always @(posedge clock_2x) begin
    if (is_en) begin
      din1st_is <= din1st_ff;
      din2nd_is <= din2nd;
    end
  end

// Synchronize demux data in main clock time domain
  reg [WIDTH-1:0]  dout1st=0;
  reg [WIDTH-1:0]  dout2nd=0;

  always @(posedge clock) begin
    if (clr) begin
      dout1st <= 0;
      dout2nd <= 0;
    end
    else begin
      dout1st <= din1st_is;
      dout2nd <= din2nd_is;
    end
  end

//------------------------------------------------------------------------------------------------------------------
  endmodule
//------------------------------------------------------------------------------------------------------------------
