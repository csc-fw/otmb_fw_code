`timescale 1ns / 1ps
//-------------------------------------------------------------------------------------------------------------------
//   ECC 16-data/6-parity Encoder
//
//  02/19/2009  Initial copied from Xilinx xapp645 top_32b_EDC.v
//  02/23/2009  Removed FFs + reorganized into separate ecoder/decoder sections
//  03/03/2009  Converted from 32-bit version
//  07/26/2010  Port to ISE 12
//-------------------------------------------------------------------------------------------------------------------
  module ecc16_encoder
  (
  enc_in,
  parity_out
  );
//-------------------------------------------------------------------------------------------------------------------
// Ports
//-------------------------------------------------------------------------------------------------------------------
  input  [15:0] enc_in;
  output [5:0]  parity_out;

//-------------------------------------------------------------------------------------------------------------------
// Encoder checkbit generator equations
//-------------------------------------------------------------------------------------------------------------------
  wire [5:0]  enc_chk;

  assign enc_chk[0] = enc_in[0]  ^ enc_in[1]  ^ enc_in[3]  ^ enc_in[4]  ^ enc_in[6]  ^ enc_in[8]  ^ enc_in[10] ^ enc_in[11] ^ enc_in[13] ^ enc_in[15];
  assign enc_chk[1] = enc_in[0]  ^ enc_in[2]  ^ enc_in[3]  ^ enc_in[5]  ^ enc_in[6]  ^ enc_in[9]  ^ enc_in[10] ^ enc_in[12] ^ enc_in[13];
  assign enc_chk[2] = enc_in[1]  ^ enc_in[2]  ^ enc_in[3]  ^ enc_in[7]  ^ enc_in[8]  ^ enc_in[9]  ^ enc_in[10] ^ enc_in[14] ^ enc_in[15];
  assign enc_chk[3] = enc_in[4]  ^ enc_in[5]  ^ enc_in[6]  ^ enc_in[7]  ^ enc_in[8]  ^ enc_in[9]  ^ enc_in[10];
  assign enc_chk[4] = enc_in[11] ^ enc_in[12] ^ enc_in[13] ^ enc_in[14] ^ enc_in[15];
  assign enc_chk[5] = enc_in[0]  ^ enc_in[1]  ^ enc_in[2]  ^ enc_in[3]  ^ enc_in[4]  ^ enc_in[5]  ^ enc_in[6]  ^ enc_in[7]  ^
                      enc_in[8]  ^ enc_in[9]  ^ enc_in[10] ^ enc_in[11] ^ enc_in[12] ^ enc_in[13] ^ enc_in[14] ^ enc_in[15] ^
                      enc_chk[4] ^ enc_chk[3] ^ enc_chk[2] ^ enc_chk[1] ^ enc_chk[0];

  assign parity_out[5:0] = enc_chk[5:0];

//-------------------------------------------------------------------------------------------------------------------
  endmodule
//-------------------------------------------------------------------------------------------------------------------
