`timescale 1ns / 1ps
//-------------------------------------------------------------------------------------------------------------------
// module to count number of 1 in 32 bits binary, 1cfeb including all 6 layers
//
//-------------------------------------------------------------------------------------------------------------------
// latency of this module
module count1s32 #(parameter WIDTH=32) (
    input [WIDTH-1:0] in1, 
    input [WIDTH-1:0] in2, 
    input [WIDTH-1:0] in3, 
    input [WIDTH-1:0] in4, 
    input [WIDTH-1:0] in5, 
    input [WIDTH-1:0] in6, 
    output reg [7:0] out,
    input clk, enable);
  reg [WIDTH-1:0] temp;
  integer ii;
  always @(clk)
    begin
      temp = 0;
      for(ii=0; ii<WIDTH; ii = ii + 1)   
         temp = temp + in1[ii] + in2[ii] + in3[ii] + in4[ii] + in5[ii] + in6[ii];
      out <= enable ? temp : 7'b0;
    end
endmodule 
