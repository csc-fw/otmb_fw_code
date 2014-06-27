`timescale 1ns / 1ps
//-------------------------------------------------------------------------------------------------------------------
//
// Virtex6: LFSR
//
//-------------------------------------------------------------------------------------------------------------------
//  09/05/2012  Port from TAMU lfsr_R24_c160.v
//  09/12/2012  Conform module names
//-------------------------------------------------------------------------------------------------------------------

module gtx_lfsr_r24_c160
  (
   CLK,
   CE,
   RST,
   LFSR
   );

   //-------------------------------------------------------------------------------------------------------------------
   // Generic
   //-------------------------------------------------------------------------------------------------------------------
   parameter init_fill = 24'h4DB62E;

   //-------------------------------------------------------------------------------------------------------------------
   // Ports
   //-------------------------------------------------------------------------------------------------------------------
   input      CLK;
   input      CE;
   input      RST;
   output [23:0]     LFSR;

   // Output Registers
   reg [23:0]       LFSR;

   //-------------------------------------------------------------------------------------------------------------------
   // Linear Feedback Shift Register
   // [24,23,22,17] Fibonacci Implementation
   //-------------------------------------------------------------------------------------------------------------------
   always @(posedge CLK or posedge RST) begin
      if(RST)
  LFSR <= init_fill;
      else
  if(CE) begin
     LFSR[0]  <= LFSR[10] ^ LFSR[17] ^ LFSR[20] ^ LFSR[23] ^ LFSR[0];
     LFSR[1]  <= LFSR[11] ^ LFSR[17] ^ LFSR[18] ^ LFSR[21] ^ LFSR[22] ^ LFSR[23] ^ LFSR[0] ^ LFSR[1];
     LFSR[2]  <= LFSR[12] ^ LFSR[17] ^ LFSR[18] ^ LFSR[19] ^ LFSR[0]  ^ LFSR[1]  ^ LFSR[2];
     LFSR[3]  <= LFSR[13] ^ LFSR[18] ^ LFSR[19] ^ LFSR[20] ^ LFSR[1]  ^ LFSR[2]  ^ LFSR[3];
     LFSR[4]  <= LFSR[14] ^ LFSR[19] ^ LFSR[20] ^ LFSR[21] ^ LFSR[2]  ^ LFSR[3]  ^ LFSR[4];
     LFSR[5]  <= LFSR[15] ^ LFSR[20] ^ LFSR[21] ^ LFSR[22] ^ LFSR[3]  ^ LFSR[4]  ^ LFSR[5];
     LFSR[6]  <= LFSR[16] ^ LFSR[21] ^ LFSR[22] ^ LFSR[23] ^ LFSR[4]  ^ LFSR[5]  ^ LFSR[6];
     LFSR[7]  <= LFSR[0]  ^ LFSR[5]  ^ LFSR[6]  ^ LFSR[7];
     LFSR[8]  <= LFSR[1]  ^ LFSR[6]  ^ LFSR[7]  ^ LFSR[8];
     LFSR[9]  <= LFSR[2]  ^ LFSR[7]  ^ LFSR[8]  ^ LFSR[9];
     LFSR[10] <= LFSR[3]  ^ LFSR[8]  ^ LFSR[9]  ^ LFSR[10];
     LFSR[11] <= LFSR[4]  ^ LFSR[9]  ^ LFSR[10] ^ LFSR[11];
     LFSR[12] <= LFSR[5]  ^ LFSR[10] ^ LFSR[11] ^ LFSR[12];
     LFSR[13] <= LFSR[6]  ^ LFSR[11] ^ LFSR[12] ^ LFSR[13];
     LFSR[14] <= LFSR[7]  ^ LFSR[12] ^ LFSR[13] ^ LFSR[14];
     LFSR[15] <= LFSR[8]  ^ LFSR[13] ^ LFSR[14] ^ LFSR[15];
     LFSR[16] <= LFSR[9]  ^ LFSR[14] ^ LFSR[15] ^ LFSR[16];
     LFSR[17] <= LFSR[10] ^ LFSR[15] ^ LFSR[16] ^ LFSR[17];
     LFSR[18] <= LFSR[11] ^ LFSR[16] ^ LFSR[17] ^ LFSR[18];
     LFSR[19] <= LFSR[12] ^ LFSR[17] ^ LFSR[18] ^ LFSR[19];
     LFSR[20] <= LFSR[13] ^ LFSR[18] ^ LFSR[19] ^ LFSR[20];
     LFSR[21] <= LFSR[14] ^ LFSR[19] ^ LFSR[20] ^ LFSR[21];
     LFSR[22] <= LFSR[15] ^ LFSR[20] ^ LFSR[21] ^ LFSR[22];
     LFSR[23] <= LFSR[16] ^ LFSR[21] ^ LFSR[22] ^ LFSR[23];
  end
   end

endmodule
