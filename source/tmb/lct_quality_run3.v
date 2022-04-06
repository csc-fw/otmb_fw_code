`timescale 1ns / 1ps
//-------------------------------------------------------------------------------------------------------------------
// LCT Quality
//
// 01/17/2008 Initial
// 01/17/2008 Q=4 reserved, Q=3-1 shifted down
// 08/17/2010 Port to ISE 12
// 08/11/2021 lct quality for non-ME11
//-------------------------------------------------------------------------------------------------------------------

module lct_quality_run3 (A, C, alct_nhit, clct_nhit,Q);

// Ports
  input  A;       // bit: ALCT was found
  input  C;       // bit: CLCT was found
  input  [2:0] alct_nhit; // 4-bit CLCT pattern number that is presently 1 for n-layer triggers, 2-10 for current patterns, 11-15 "for future expansion".
  input  [2:0] clct_nhit;
  output [1:0] Q; // 4-bit TMB quality output

// Quality-by-quality definition
  reg [1:0] Q;

  always @* begin

  if (A && C) begin
      if      (alct_nhit == 3'd6 || clct_nhit == 3'd6 )     Q=2'b11;
      else if (alct_nhit == 3'd5 || clct_nhit == 3'd5 )     Q=2'b10;
      else if (alct_nhit == 3'd4 || clct_nhit == 3'd4 )     Q=2'b01;
      else                                            Q=2'b0;
  end
  else                                           Q=2'b0; // should never be assigned
  end

//-------------------------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------------------------
