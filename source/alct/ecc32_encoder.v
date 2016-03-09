`timescale 1ns / 1ps
//-------------------------------------------------------------------------------------------------------------------
//   ECC 32-data/7-parity Encoder
//  02/19/2009  Initial copied from Xilinx xapp645 top_32b_EDC.v
//  02/23/2009  Removed FFs + reorganized into separate ecoder/decoder sections
//  07/26/2010  Port to ISE 12
//-------------------------------------------------------------------------------------------------------------------
  module ecc32_encoder (
  enc_in,
  parity_out
  );
//-------------------------------------------------------------------------------------------------------------------
// Ports
//-------------------------------------------------------------------------------------------------------------------
  input  [31:0]  enc_in;
  output  [6:0]  parity_out;

//-------------------------------------------------------------------------------------------------------------------
// Encoder checkbit generator equations
//-------------------------------------------------------------------------------------------------------------------
  wire [6:0]  enc_chk;

  assign enc_chk[0] = enc_in[0]  ^ enc_in[1]  ^ enc_in[3]  ^ enc_in[4]  ^ enc_in[6]  ^ enc_in[8]  ^
                      enc_in[10] ^ enc_in[11] ^ enc_in[13] ^ enc_in[15] ^ enc_in[17] ^ enc_in[19] ^
                      enc_in[21] ^ enc_in[23] ^ enc_in[25] ^ enc_in[26] ^ enc_in[28] ^ enc_in[30];
  assign enc_chk[1] = enc_in[0]  ^ enc_in[2]  ^ enc_in[3]  ^ enc_in[5]  ^ enc_in[6]  ^ enc_in[9]  ^
                      enc_in[10] ^ enc_in[12] ^ enc_in[13] ^ enc_in[16] ^ enc_in[17] ^ enc_in[20] ^
                      enc_in[21] ^ enc_in[24] ^ enc_in[25] ^ enc_in[27] ^ enc_in[28] ^ enc_in[31];
  assign enc_chk[2] = enc_in[1]  ^ enc_in[2]  ^ enc_in[3]  ^ enc_in[7]  ^ enc_in[8]  ^ enc_in[9]  ^
                      enc_in[10] ^ enc_in[14] ^ enc_in[15] ^ enc_in[16] ^ enc_in[17] ^ enc_in[22] ^
                      enc_in[23] ^ enc_in[24] ^ enc_in[25] ^ enc_in[29] ^ enc_in[30] ^ enc_in[31];
  assign enc_chk[3] = enc_in[4]  ^ enc_in[5]  ^ enc_in[6]  ^ enc_in[7]  ^ enc_in[8]  ^ enc_in[9]  ^
                      enc_in[10] ^ enc_in[18] ^ enc_in[19] ^ enc_in[20] ^ enc_in[21] ^ enc_in[22] ^
                      enc_in[23] ^ enc_in[24] ^ enc_in[25];
  assign enc_chk[4] = enc_in[11] ^ enc_in[12] ^ enc_in[13] ^ enc_in[14] ^ enc_in[15] ^ enc_in[16] ^
                      enc_in[17] ^ enc_in[18] ^ enc_in[19] ^ enc_in[20] ^ enc_in[21] ^ enc_in[22] ^
                      enc_in[23] ^ enc_in[24] ^ enc_in[25];
  assign enc_chk[5] = enc_in[26] ^ enc_in[27] ^ enc_in[28] ^ enc_in[29] ^ enc_in[30] ^ enc_in[31];
  assign enc_chk[6] = enc_in[0]  ^ enc_in[1]  ^ enc_in[2]  ^ enc_in[3]  ^ enc_in[4]  ^ enc_in[5]  ^ enc_in[6]  ^ enc_in[7]  ^
                      enc_in[8]  ^ enc_in[9]  ^ enc_in[10] ^ enc_in[11] ^ enc_in[12] ^ enc_in[13] ^ enc_in[14] ^ enc_in[15] ^
                      enc_in[16] ^ enc_in[17] ^ enc_in[18] ^ enc_in[19] ^ enc_in[20] ^ enc_in[21] ^ enc_in[22] ^ enc_in[23] ^
                      enc_in[24] ^ enc_in[25] ^ enc_in[26] ^ enc_in[27] ^ enc_in[28] ^ enc_in[29] ^ enc_in[30] ^ enc_in[31] ^
                      enc_chk[5] ^ enc_chk[4] ^ enc_chk[3] ^ enc_chk[2] ^ enc_chk[1] ^ enc_chk[0];

  assign parity_out[6:0] = enc_chk[6:0];

//-------------------------------------------------------------------------------------------------------------------
  endmodule
//-------------------------------------------------------------------------------------------------------------------
