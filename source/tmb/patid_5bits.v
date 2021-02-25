`timescale 1ns / 1ps
//-------------------------------------------------------------------------------------------------------------------
// 5bits pattern ID definition
//
//-------------------------------------------------------------------------------------------------------------------

module  patid_5bits(lct0_vpf,clct0_pid,lct1_vpf,clct1_pid, out_pid);

// Ports
  input lct0_vpf;
  input [3:0]  clct0_pid;
  input lct1_vpf;
  input [3:0]  clct1_pid;
  output [5:0] out_pid;

// Quality-by-quality definition
  reg [5:0] out_pid;

  always @* begin

  if (lct0_vpf && !lct1_vpf)                out_pid = clct0_pid;
  else                                      out_pid = clct0_pid * 5 + clct1_pid + 5;
  end

//-------------------------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------------------------
