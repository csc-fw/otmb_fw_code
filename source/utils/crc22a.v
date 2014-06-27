`timescale 1ns / 1ps
//-------------------------------------------------------------------------------------------------------------------
//
//  CRC-22 with 16-bit parallel loading data and synchronous reset
//  Polynomial = x22+x1+1
//
//  12/03/2002  Initial
//  01/16/2003  Reverse output bit order to suit OSU
//  03/19/2003  Un-reverse output bits per OSU
//  07/30/2004  Remove reversed bits logic, it never gets used
//  09/19/2006  Mod for xst
//  04/23/2009  Mod for ise 10.1i
//  07/26/2010  Port to ise 12
//  10/05/2010  Check non-blocking operators
//-------------------------------------------------------------------------------------------------------------------

  module crc22a (clock,data,reset,crc);

  input      clock;
  input  [15:0]  data;
  input      reset;

  output  [21:0]  crc;  

// Latch crc function result
  reg    [21:0]  crc = 0;

  always @(posedge clock) begin
  if (reset)  crc <= 0;
  else    crc  <= nextCRC22_D16(data,crc);
  end

//-------------------------------------------------------------------------------------------------------------------
// File:  CRC22_D16.v
// Date:  Tue Dec  3 00:44:19 2002
//
// Purpose: Verilog module containing a synthesizable CRC function
//   * polynomial: (0 1 22)
//   * data width: 16
//   * convention: the first serial data bit is D[15]
// Info: jand@easics.be (Jan Decaluwe)
//     http://www.easics.com
//-------------------------------------------------------------------------------------------------------------------

  function [21:0] nextCRC22_D16;

  input [15:0] Data;
  input [21:0] CRC;

  reg [15:0] D;
  reg [21:0] C;
  reg [21:0] NewCRC;

  begin
  D = Data;
  C = CRC;

  NewCRC[ 0] = D[ 0] ^ C[ 6];
  NewCRC[ 1] = D[ 1] ^ D[ 0] ^ C[ 6] ^ C[ 7];
  NewCRC[ 2] = D[ 2] ^ D[ 1] ^ C[ 7] ^ C[ 8];
  NewCRC[ 3] = D[ 3] ^ D[ 2] ^ C[ 8] ^ C[ 9];
  NewCRC[ 4] = D[ 4] ^ D[ 3] ^ C[ 9] ^ C[10];
  NewCRC[ 5] = D[ 5] ^ D[ 4] ^ C[10] ^ C[11];
  NewCRC[ 6] = D[ 6] ^ D[ 5] ^ C[11] ^ C[12];
  NewCRC[ 7] = D[ 7] ^ D[ 6] ^ C[12] ^ C[13];
  NewCRC[ 8] = D[ 8] ^ D[ 7] ^ C[13] ^ C[14];
  NewCRC[ 9] = D[ 9] ^ D[ 8] ^ C[14] ^ C[15];
  NewCRC[10] = D[10] ^ D[ 9] ^ C[15] ^ C[16];
  NewCRC[11] = D[11] ^ D[10] ^ C[16] ^ C[17];
  NewCRC[12] = D[12] ^ D[11] ^ C[17] ^ C[18];
  NewCRC[13] = D[13] ^ D[12] ^ C[18] ^ C[19];
  NewCRC[14] = D[14] ^ D[13] ^ C[19] ^ C[20];
  NewCRC[15] = D[15] ^ D[14] ^ C[20] ^ C[21];
  NewCRC[16] = D[15] ^ C[ 0] ^ C[21];
  NewCRC[17] = C[ 1];
  NewCRC[18] = C[ 2];
  NewCRC[19] = C[ 3];
  NewCRC[20] = C[ 4];
  NewCRC[21] = C[ 5];

  nextCRC22_D16 = NewCRC;
  end
  endfunction

//-------------------------------------------------------------------------------------------------------------------
  endmodule
//-------------------------------------------------------------------------------------------------------------------
