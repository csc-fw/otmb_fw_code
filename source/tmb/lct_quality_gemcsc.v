`timescale 1ns / 1ps
//-------------------------------------------------------------------------------------------------------------------
// LCT Quality
//
// 01/17/2008 Initial
// 01/17/2008 Q=4 reserved, Q=3-1 shifted down
// 08/17/2010 Port to ISE 12
//-------------------------------------------------------------------------------------------------------------------

module lct_quality_run3 (alct_clct_copad_match, alct_clct_gem_match, alct_clct_match, clct_copad_match, alct_copad_match, gemcsc_bend_enable,Q);

// Ports
  input  alct_clct_copad_match;
  input  alct_clct_gem_match;
  input  alct_clct_match;
  input  clct_copad_match;
  input  alct_copad_match;
  input  gemcsc_bend_enable;
  output [2:0] Q;

// Quality-by-quality definition
  reg [2:0] Q;

  always @* begin
      if      (alct_clct_copad_match &&  gemcsc_bend_enable ) Q=3'b111;
      else if (alct_clct_copad_match && !gemcsc_bend_enable ) Q=3'b110;
      else if (alct_clct_gem_match && gemcsc_bend_enable )        Q=3'b101;
      else if (alct_clct_gem_match && !gemcsc_bend_enable )   Q=3'b100;
      else if (alct_clct_match )                              Q=3'b011;
      else if (clct_copad_match )                             Q=3'b001;
      else if (alct_copad_match )                             Q=3'b010;
      else Q=3'b000;
  end

//-------------------------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------------------------
