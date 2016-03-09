`timescale 1ns / 1ps
//-------------------------------------------------------------------------------------------------------------------
//   ECC 32/7 Decoder
//
//  02/19/2009  Initial copied from Xilinx xapp645 top_32b_EDC.v
//  02/23/2009  Removed FFs + reorganized into ecoder/decoder sections
//  03/02/2009  Add enable
//  07/26/2010  Port to ISE 12
//-------------------------------------------------------------------------------------------------------------------
  module ecc32_decoder (
    dec_in,
    parity_in,
    ecc_en,
    dec_out,
    error
  );

//-------------------------------------------------------------------------------------------------------------------
// Ports
//-------------------------------------------------------------------------------------------------------------------
  input  [31:0] dec_in;    // Data to decode
  input  [6:0]  parity_in; // ECC parity for input data
  input         ecc_en;    // Enable error correction
  output [31:0] dec_out;   // Error corrected out
  output [1:0]  error;     // Error syndrome code

//-------------------------------------------------------------------------------------------------------------------
// Decoder
//-------------------------------------------------------------------------------------------------------------------
// Syndrome creation: 7 syndrome bits are created based on the 32-bit data and its associated checkbits
  wire [6:0]  syndrome_chk;
  
  assign syndrome_chk[0] = dec_in[0]  ^ dec_in[1]  ^ dec_in[3]  ^ dec_in[4]  ^ dec_in[6]  ^ dec_in[8]  ^
                           dec_in[10] ^ dec_in[11] ^ dec_in[13] ^ dec_in[15] ^ dec_in[17] ^ dec_in[19] ^
                           dec_in[21] ^ dec_in[23] ^ dec_in[25] ^ dec_in[26] ^ dec_in[28] ^ dec_in[30];
  assign syndrome_chk[1] = dec_in[0]  ^ dec_in[2]  ^ dec_in[3]  ^ dec_in[5]  ^ dec_in[6]  ^ dec_in[9]  ^
                           dec_in[10] ^ dec_in[12] ^ dec_in[13] ^ dec_in[16] ^ dec_in[17] ^ dec_in[20] ^
                           dec_in[21] ^ dec_in[24] ^ dec_in[25] ^ dec_in[27] ^ dec_in[28] ^ dec_in[31];
  assign syndrome_chk[2] = dec_in[1]  ^ dec_in[2]  ^ dec_in[3]  ^ dec_in[7]  ^ dec_in[8]  ^ dec_in[9]  ^
                           dec_in[10] ^ dec_in[14] ^ dec_in[15] ^ dec_in[16] ^ dec_in[17] ^ dec_in[22] ^
                           dec_in[23] ^ dec_in[24] ^ dec_in[25] ^ dec_in[29] ^ dec_in[30] ^ dec_in[31];
  assign syndrome_chk[3] = dec_in[4]  ^ dec_in[5]  ^ dec_in[6]  ^ dec_in[7]  ^ dec_in[8]  ^ dec_in[9]  ^
                           dec_in[10] ^ dec_in[18] ^ dec_in[19] ^ dec_in[20] ^ dec_in[21] ^ dec_in[22] ^
                           dec_in[23] ^ dec_in[24] ^ dec_in[25];
  assign syndrome_chk[4] = dec_in[11] ^ dec_in[12] ^ dec_in[13] ^ dec_in[14] ^ dec_in[15] ^ dec_in[16] ^
                           dec_in[17] ^ dec_in[18] ^ dec_in[19] ^ dec_in[20] ^ dec_in[21] ^ dec_in[22] ^
                           dec_in[23] ^ dec_in[24] ^ dec_in[25];
  assign syndrome_chk[5] = dec_in[26] ^ dec_in[27] ^ dec_in[28] ^ dec_in[29] ^ dec_in[30] ^ dec_in[31];
  assign syndrome_chk[6] = dec_in[0]  ^ dec_in[1]  ^ dec_in[2]  ^ dec_in[3]  ^ dec_in[4]  ^ dec_in[5]  ^ dec_in[6]  ^ dec_in[7]  ^ 
                           dec_in[8]  ^ dec_in[9]  ^ dec_in[10] ^ dec_in[11] ^ dec_in[12] ^ dec_in[13] ^ dec_in[14] ^ dec_in[15] ^
                           dec_in[16] ^ dec_in[17] ^ dec_in[18] ^ dec_in[19] ^ dec_in[20] ^ dec_in[21] ^ dec_in[22] ^ dec_in[23] ^
                           dec_in[24] ^ dec_in[25] ^ dec_in[26] ^ dec_in[27] ^ dec_in[28] ^ dec_in[29] ^ dec_in[30] ^ dec_in[31] ^
                           parity_in[5] ^ parity_in[4] ^ parity_in[3] ^ parity_in[2] ^ parity_in[1] ^ parity_in[0];

// Error correction mask
  reg  [31:0] mask;
  wire [6:0]  syndrome;

  assign syndrome = syndrome_chk ^ parity_in;

  always @* begin: correction_mask
    case (syndrome)
      7'b1000011:  mask <= 32'h00000001;// 0
      7'b1000101:  mask <= 32'h00000002;// 1
      7'b1000110:  mask <= 32'h00000004;// 2
      7'b1000111:  mask <= 32'h00000008;// 3
      7'b1001001:  mask <= 32'h00000010;// 4
      7'b1001010:  mask <= 32'h00000020;// 5
      7'b1001011:  mask <= 32'h00000040;// 6
      7'b1001100:  mask <= 32'h00000080;// 7
      7'b1001101:  mask <= 32'h00000100;// 8
      7'b1001110:  mask <= 32'h00000200;// 9
      7'b1001111:  mask <= 32'h00000400;// 10
      7'b1010001:  mask <= 32'h00000800;// 11
      7'b1010010:  mask <= 32'h00001000;// 12
      7'b1010011:  mask <= 32'h00002000;// 13
      7'b1010100:  mask <= 32'h00004000;// 14
      7'b1010101:  mask <= 32'h00008000;// 15
      7'b1010110:  mask <= 32'h00010000;// 16
      7'b1010111:  mask <= 32'h00020000;// 17
      7'b1011000:  mask <= 32'h00040000;// 18
      7'b1011001:  mask <= 32'h00080000;// 19
      7'b1011010:  mask <= 32'h00100000;// 20
      7'b1011011:  mask <= 32'h00200000;// 21
      7'b1011100:  mask <= 32'h00400000;// 22
      7'b1011101:  mask <= 32'h00800000;// 23
      7'b1011110:  mask <= 32'h01000000;// 24
      7'b1011111:  mask <= 32'h02000000;// 25
      7'b1100001:  mask <= 32'h04000000;// 26
      7'b1100010:  mask <= 32'h08000000;// 27
      7'b1100011:  mask <= 32'h10000000;// 28
      7'b1100100:  mask <= 32'h20000000;// 29
      7'b1100101:  mask <= 32'h40000000;// 30
      7'b1100110:  mask <= 32'h80000000;// 31
      default:     mask <= 32'h00000000;
    endcase
  end

// Corrected output
  assign dec_out = (ecc_en) ? (mask ^ dec_in) : dec_in;

//-------------------------------------------------------------------------------------------------------------------
// Decoder syndrom error code
//-------------------------------------------------------------------------------------------------------------------
// 00 = no error/data corrected
// 01 = single bit error
// 10 = double bit error
// 11 = single check-bit error
//-------------------------------------------------------------------------------------------------------------------
  reg   [1:0]  error;

  always @* begin: error_status
    case (syndrome[6])
      1'b0: begin
        case (syndrome[5:0])
          6'b000000: error <= 2'b00; // no error 
          default:   error <= 2'b10; // double error
        endcase 
      end
      1'b1: begin   // detect multiple errors errors in rows101, 110 and 111 are not valid single error
        case (syndrome[5:3])
        3'b101:  error <= 2'b11;
        3'b110:  error <= 2'b11;
        3'b111:  error <= 2'b11;
        default: error <= 2'b01; // single error
        endcase 
      end
      default:   error <= 2'b11;
    endcase 
  end

//-------------------------------------------------------------------------------------------------------------------
  endmodule
//-------------------------------------------------------------------------------------------------------------------
