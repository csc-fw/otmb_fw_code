`timescale 1ns / 1ps
//----------------------------------------------------------------------------------------------------------------
//  Linear Feedback Shift Register
//  Generates pseudo-random patterns
//  From Xilinx xapp210
//----------------------------------------------------------------------------------------------------------------
//  01/20/2009  Mod for 56-bit alct data path
//  02/24/2009   Mod for 49-bit alct data path
//  07/26/2010  Port to ise 12
//----------------------------------------------------------------------------------------------------------------
  module alct_lfsr_rng(clock,ce,reset,lfsr);

// Generic
//  parameter LFSR_LENGTH = 56;
  parameter LFSR_LENGTH = 49;

// Ports
  input                        clock; // 40 Mhz clock
  input                        ce;    // Clock enable
  input                        reset; // Restart series
  output reg [LFSR_LENGTH-1:0] lfsr;  // Random series

// LFSR Random Pattern Generator
//  wire [LFSR_LENGTH-1:0] lfsr_seed = 56'h123456789ABCDE;
  wire [LFSR_LENGTH-1:0] lfsr_seed = 49'h123456789ABCD;

//  wire feedback = ~(lfsr[15] ^ lfsr[14] ^ lfsr[12] ^ lfsr[ 3]);  // 16 bit version
//  wire feedback = ~(lfsr[55] ^ lfsr[54] ^ lfsr[34] ^ lfsr[33]);  // 56 bit version 2x28
  wire feedback = ~(lfsr[48] ^ lfsr[39]);              // 49 bit version

  always @(posedge clock) begin
    if      (reset) lfsr <=  lfsr_seed;
    else if (ce)    lfsr <= {lfsr[LFSR_LENGTH-2:0],feedback};
  end
  
//----------------------------------------------------------------------------------------------------------------
  endmodule
//----------------------------------------------------------------------------------------------------------------
