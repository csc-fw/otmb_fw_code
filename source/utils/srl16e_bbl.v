`timescale 1ns / 1ps
//-----------------------------------------------------------------------------------------------------------------------
//  SRL16E-based parallel shifter
//
//  Synthesis will not infer SRL16E if the output address is a variable,
//  so SRL16Es are instantiated explicitly here.
//
//  01/31/2003  Initial
//  04/28/2004  Expand to 19 SRLs for RPC data
//  09/13/2006  Mod for xst
//  09/18/2006  Replace instances with generate loop
//  03/07/2007  Remove former port map names
//  07/22/2010  Port to ise 12
//  10/05/2010  Sim check
//-----------------------------------------------------------------------------------------------------------------------
  module srl16e_bbl (clock,ce,adr,d,q);

// Generic
  parameter WIDTH = 19;
  initial  $display("srl16e_bbl: WIDTH=%d",WIDTH);

// Ports
  input        clock;
  input        ce;
  input  [3:0]    adr;
  input  [WIDTH-1:0]  d;
  output  [WIDTH-1:0]  q;

// Generate MXSRL instances of SRL16E
  genvar i;
  generate
  for (i=0; i<WIDTH; i=i+1) begin: srlgen
  SRL16E u00 (.CLK(clock),.CE(ce),.D(d[i]),.A0(adr[0]),.A1(adr[1]),.A2(adr[2]),.A3(adr[3]),.Q(q[i]));
  end
  endgenerate
  
//-----------------------------------------------------------------------------------------------------------------------
  endmodule
//-----------------------------------------------------------------------------------------------------------------------
