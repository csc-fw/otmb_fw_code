`timescale 1ns / 1ps
//-------------------------------------------------------------------------------------------------------------------
//  05/18/2017 Initial
//  20/07/2020  create one for ccLUT algorithm
//  for CCLUT: patA => pid4, pat9=> pid3, pat8=>pid2, pat7=>pid1, pat6=>pid0
//  01/08/2021  results from CCLUT: [4:0] is bending, include 4bit for value, 1bit for L/R; [8:5] is the 4bits for offset
//-------------------------------------------------------------------------------------------------------------------
  module pattern_lut_ccLUT (
    input                    clock,

    input      [MXPIDB-1:0:0]  pat00, pat01,

    input      [MXPATC-1:0]  carry00, carry01,

    output reg [MXOFFSB -1:0]  offs0, offs1,
    //output reg [MXKEYOFFSB -1:0]  key_offs0, key_offs1,
    //output reg [MXSUBKEYOFFSB -1:0]  subkey_offs0, subkey_offs1,
    output reg [MXBNDB-1:0]  bend0, bend1,
    output reg [MXQLTB-1:0]  quality0, quality1

  );

// Constants

`include "pattern_params.v"

parameter MXADRB  = MXPATC;
parameter MXDATB  = 9;//drop 9bits for quality

wire [MXDATB-1:0]   rd0_pat4, rd1_pat4,
                    rd0_pat3, rd1_pat3,
                    rd0_pat2, rd1_pat2,
                    rd0_pat1, rd1_pat1,
                    rd0_pat0, rd1_pat0,
                    rd0_blnk, rd1_blnk;

assign rd0_blnk = 0;
assign rd1_blnk = 0;

//----------------------------------------------------------------------------------------------------------------------
// ROMS
//----------------------------------------------------------------------------------------------------------------------

rom #(
  //.ROM_FILE("rom_patA.mem"),
  .ROM_FILE("rom_pat4.mem"),
  .FALLING_EDGE(1'b1),
  .MXADRB(MXADRB),
  .MXDATB(MXDATB)
)
romA (
  .clock(clock),
  .adr0(carry00),
  .adr1(carry01),
  .rd0 (rd0_pat4),
  .rd1 (rd1_pat4)
);

rom #(
  //.ROM_FILE("rom_pat9.mem"),
  .ROM_FILE("rom_pat3.mem"),
  .FALLING_EDGE(1'b1),
  .MXADRB(MXADRB),
  .MXDATB(MXDATB)
) rom9 (
  .clock(clock),
  .adr0(carry00),
  .adr1(carry01),
  .rd0 (rd0_pat3),
  .rd1 (rd1_pat3)
);

rom #(
  //.ROM_FILE("rom_pat8.mem"),
  .ROM_FILE("rom_pat2.mem"),
  .FALLING_EDGE(1'b1),
  .MXADRB(MXADRB),
  .MXDATB(MXDATB)
) rom8 (
  .clock(clock),
  .adr0(carry00),
  .adr1(carry01),
  .rd0 (rd0_pat2),
  .rd1 (rd1_pat2)
);

rom #(
  //.ROM_FILE("rom_pat7.mem"),
  .ROM_FILE("rom_pat1.mem"),
  .FALLING_EDGE(1'b1),
  .MXADRB(MXADRB),
  .MXDATB(MXDATB)
) rom7 (
  .clock(clock),
  .adr0(carry00),
  .adr1(carry01),
  .rd0 (rd0_pat1),
  .rd1 (rd1_pat1)
);

rom #(
  //.ROM_FILE("rom_pat6.mem"),
  .ROM_FILE("rom_pat0.mem"),
  .FALLING_EDGE(1'b1),
  .MXADRB(MXADRB),
  .MXDATB(MXDATB)
) rom6 (
  .clock(clock),
  .adr0(carry00),
  .adr1(carry01),
  .rd0 (rd0_pat0),
  .rd1 (rd1_pat0)
);

//----------------------------------------------------------------------------------------------------------------------
//
//----------------------------------------------------------------------------------------------------------------------

//wire [MXHITB-1:0] hs_hit00, hs_hit01;
wire [MXPIDB-1:0] hs_pid00, hs_pid01;

assign hs_pid00 = pat00 [0+:MXPIDB];
assign hs_pid01 = pat01 [0+:MXPIDB];

//assign hs_hit00 = pat00 [MXPIDB+:MXHITB];
//assign hs_hit01 = pat01 [MXPIDB+:MXHITB];

// demultiplex the different lookup registers

reg [MXDATB-1:0] rd0, rd1;

always @(*) begin
  case (hs_pid00)
    4'h4:   rd0 = rd0_pat4;
    4'h3:   rd0 = rd0_pat3;
    4'h2:   rd0 = rd0_pat2;
    4'h1:   rd0 = rd0_pat1;
    4'h0:   rd0 = rd0_pat0;
    default: rd0 = rd0_blnk;
  endcase

  case (hs_pid01)
    4'h4:   rd1 = rd1_pat4;
    4'h3:   rd1 = rd1_pat3;
    4'h2:   rd1 = rd1_pat2;
    4'h1:   rd1 = rd1_pat1;
    4'h0:   rd1 = rd1_pat0;
    default: rd1 = rd1_blnk;
  endcase
end

// FAST
//convention of CCLUT output:
//     [8:0] is quality (set all to 0 for now)                                                                                                                  
//     [12:9] is slope value                                                                                                                                   
//     [13] is slope sign                                                                                                                                       
//     [17:14] is offset    
//  for offset:default output is in middle of halfstrip: n+0.5 in halfstrip unit; n*4+2 in ES unit
//  | Value | Value (B)| HS Offset  | Delta HS  | QS Bit  | ES Bit |
//  |-------|          |------------|-----------|---------|--------|
//  |   0   | 0000     |   -7/4     |   -2      |   0     |   1    |
//  |   1   | 0001     |   -3/2     |   -2      |   1     |   0    |
//  |   2   | 0010     |   -5/4     |   -2      |   1     |   1    |
//  |   3   | 0011     |   -1       |   -1      |   0     |   0    |
//  |   4   | 0100     |   -3/4     |   -1      |   0     |   1    |
//  |   5   | 0101     |   -1/2     |   -1      |   1     |   0    |
//  |   6   | 0110     |   -1/4     |   -1      |   1     |   1    |
//  |   7   | 0111     |   0        |   0       |   0     |   0    |
//  |   8   | 1000     |   1/4      |   0       |   0     |   1    |
//  |   9   | 1001     |   1/2      |   0       |   1     |   0    |
//  |   10  | 1010     |   3/4      |   0       |   1     |   1    |
//  |   11  | 1011     |   1        |   1       |   0     |   0    |
//  |   12  | 1100     |   5/4      |   1       |   0     |   1    |
//  |   13  | 1101     |   3/2      |   1       |   1     |   0    |
//  |   14  | 1110     |   7/4      |   1       |   1     |   1    |
//  |   15  | 1111     |   2        |   2       |   0     |   0    |
always @(*) begin

  //key_offs0 <= rd0[17:16] + (rd0[14]&rd0[15]);// real_keyoffs = keyoffs0 -2
  //key_offs1 <= rd1[17:16] + (rd1[14]&rd1[15]);// real_keyoffs = keyoffs1 -2

  //subkey_offs0 <= rd0[15:14]+2'b01;// 2bits
  //subkey_offs1 <= rd1[15:14]+2'b01;// 2bits
  //with 9bits quality bits
  //offs0    <= rd0[17:14];
  //offs1    <= rd1[17:14];
  

  //bend0    <= rd0[13:9];
  //bend1    <= rd1[13:9];

  //quality0 <= rd0[8:0];
  //quality1 <= rd1[8:0];

  //offs0    <= rd0[17:14];
  //offs1    <= rd1[17:14];
  

  bend0    <= rd0[4:0];
  bend1    <= rd1[4:0];
  offs0    <= rd0[8:5];
  offs1    <= rd1[8:5];

  quality0 <= 9'b0;
  quality1 <= 9'b0;

end

//-------------------------------------------------------------------------------------------------------------------
  endmodule
//-------------------------------------------------------------------------------------------------------------------
