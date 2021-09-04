`timescale 1ns / 1ps
//-------------------------------------------------------------------------------------------------------------------
// 5bits pattern ID definition
//
//-------------------------------------------------------------------------------------------------------------------

module  patid_5bits(lct0_vpf,clct0_pid,lct1_vpf,clct1_pid, out_pid);

// Ports
  input lct0_vpf;
  input [2:0]  clct0_pid;
  input lct1_vpf;
  input [2:0]  clct1_pid;
  output reg [4:0] out_pid;

  always @* begin

  if (lct0_vpf && !lct1_vpf)                out_pid = clct0_pid;
  else if (lct0_vpf && lct1_vpf)            out_pid = clct1_pid * 5 + clct0_pid + 5'd5;
  else if (!lct0_vpf && lct1_vpf)           out_pid = 5'b11110;
  else                                      out_pid = 5'b11111;
  end

//-------------------------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------------------------
