`timescale 1ns / 1ps
//------------------------------------------------------------------------------------------------------------------------
//  Finds:    Best matching pattern template and number of layers hit on that pattern for 1 key 1/2-strip
//  Returns:  Best matching pattern template ID, and number of hits on the pattern
//
//  12/19/2006  Initial
//  12/22/2006  Change comparison direction
//  01/05/2007  Change to combined 1/2-strip and distrip method
//  01/09/2007  Replace count1s adders with LUT version
//  01/10/2007  Narrow layer inputs to exclude unused 1/2-strips
//  01/16/2007  Change from 15 to 9 patterns
//  01/18/2007  Mod pattern 5 OR
//  02/22/2007  Add pipleline latch
//  02/27/2007  Reposition pipleline for max speed, min area
//  05/08/2007  Change pattern numbers 1-9 to 0-8 so lsb now implies bend direction
//  05/23/2007  Mod pattern 3 ly5 to mirror pattern 2
//  06/08/2007  Remove pipeline stage
//  06/12/2007  Had to revert to pipeline stage, could only achieve 30MHz otherwise
//  06/15/2007  Incorporate layer mode as pattern 1, shift clct patterns IDs to the range 2-10
//  06/28/2007  Shift key layer to ly2, flip patterns top-to-bottom, old ly0 becomes new ly5, left bends become right
//  07/02/2007  Flip pat[i][5:0] to pat[i][0:5] to match prior ly3 result, reduces fpga usage from 93% to 90%
//  08/11/2010  Port to ise 12
//  08/12/2010  Replace LUT version of count1s because xst 12.2 inferred read-only ram instead of luts
//  02/08/2013  Initial Virtex-6
//  02/11/2013  Remove clock_2x
//  03/21/2013  Replace adders with ROM, reduces area ratio from 26% to 20%
//
//  for CCLUT: patA => pid4, pat9=> pid3, pat8=>pid2, pat7=>pid1, pat6=>pid0
//------------------------------------------------------------------------------------------------------------------------
// convention of 12-bits comparator code: [11:0]
// [1:0] is the first layer and [11:10] is the last layer (layer6)
// for each layer: 00 means no hit, 01 means 1st HS, 10 means 2nd HS, 11 means 3rd HS????
  module pattern_unit_ccLUT
  (
// Inputs
//CCLUT, v2
  input [10:0] ly0, //  2,3,4,5, 6, 7,8,9,10
  input [ 9:1] ly1, //   3,4,5,6,7,8,9
  input [ 7:3] ly2, // 5,6,7 Key layer 2
  input [ 7:3] ly3,   
  input [ 9:1] ly4, //  1,2,3,4,5, 6, 7,8,9,10,11
  input [10:0] ly5, // 1/2-strips 1 layer 1 cell

// Outputs
  output [MXHITB-1:0] pat_nhits, // Number layers hit for highest pattern
  output [MXPIDB-1:0] pat_id,    // Highest pattern found
  output [MXPATC-1:0] pat_carry  // Highest pattern found
  );

//------------------------------------------------------------------------------------------------------------------------
// Generic
//------------------------------------------------------------------------------------------------------------------------

`include "pattern_params.v"
`include "pattern_mask_ccLUT.v"

//------------------------------------------------------------------------------------------------------------------------
// Finds best 1-of-9 1/2-strip patterns for 1 key 1/2-strip
// Returns pattern number 2-10 and number of layers hit on that pattern 0-6.
// Pattern LSB = bend direction
// Hit pattern LUTs for 1 layer: - = don't care, xx= one hit or the other or both
// CCLUT: comparator code for each layer except key layer.  HS order in 000 is low->high
//        000 => 2'b00;  
//        x00 => 2'b01; 
//        0x0 => 2'b01; 
//        00x => 2'b11; 
//------------------------------------------------------------------------------------------------------------------------

  wire [0:2] pat   [MXPID-1:MIPID][0:MXLY-1]; // Ordering 0:LXLY-1 uses 132 LUTs, and fpga usage is 90%, matches ly3 key result

// Pattern A                                                                                                                                       0123456789A
  assign pat[A][0] = {3{pat_en[A]}} &  pat_maskA[15+:3] & {                            ly0[4],ly0[5],ly0[6]                              }; // ly0 ----xxx----
  assign pat[A][1] = {3{pat_en[A]}} &  pat_maskA[12+:3] & {                            ly1[4],ly1[5],ly1[6]                              }; // ly1 ----xxx----
  assign pat[A][2] = {3{pat_en[A]}} &  pat_maskA[9 +:3] & {                            ly2[4],ly2[5],ly2[6]                              }; // ly2 ----xkx----
  assign pat[A][3] = {3{pat_en[A]}} &  pat_maskA[6 +:3] & {                            ly3[4],ly3[5],ly3[6]                              }; // ly3 ----xxx----
  assign pat[A][4] = {3{pat_en[A]}} &  pat_maskA[3 +:3] & {                            ly4[4],ly4[5],ly4[6]                              }; // ly4 ----xxx----
  assign pat[A][5] = {3{pat_en[A]}} &  pat_maskA[0 +:3] & {                            ly5[4],ly5[5],ly5[6]                              }; // ly5 ----xxx----

// Pattern 9                                                                                                                                        0123456789ABC
  assign pat[9][0] = {3{pat_en[9]}} &  pat_mask9[15+:3] & {              ly0[2],ly0[3],ly0[4]                                            } ; // ly0 --xxx------
  assign pat[9][1] = {3{pat_en[9]}} &  pat_mask9[12+:3] & {                     ly1[3],ly1[4],ly1[5]                                     } ; // ly1 ---xxx-----
  assign pat[9][2] = {3{pat_en[9]}} &  pat_mask9[9 +:3] & {                            ly2[4],ly2[5],ly2[6]                              } ; // ly2 ----xkx----
  assign pat[9][3] = {3{pat_en[9]}} &  pat_mask9[6 +:3] & {                            ly3[4],ly3[5],ly3[6]                              } ; // ly3 ----xxx----
  assign pat[9][4] = {3{pat_en[9]}} &  pat_mask9[3 +:3] & {                                   ly4[5],ly4[6],ly4[7]                       } ; // ly4 -----xxx---
  assign pat[9][5] = {3{pat_en[9]}} &  pat_mask9[0 +:3] & {                                          ly5[6],ly5[7],ly5[8]                } ; // ly5 ------xxx--

// Pattern 8                                                                                                                                       0123456789A
  assign pat[8][0] = {3{pat_en[8]}} &  pat_mask8[15+:3] & {                                          ly0[6],ly0[7],ly0[8]                }; // ly0 ------xxx--
  assign pat[8][1] = {3{pat_en[8]}} &  pat_mask8[12+:3] & {                                   ly1[5],ly1[6],ly1[7]                       }; // ly1 -----xxx---
  assign pat[8][2] = {3{pat_en[8]}} &  pat_mask8[9 +:3] & {                            ly2[4],ly2[5],ly2[6]                              }; // ly2 ----xkx----
  assign pat[8][3] = {3{pat_en[8]}} &  pat_mask8[6 +:3] & {                            ly3[4],ly3[5],ly3[6]                              }; // ly3 ----xxx----
  assign pat[8][4] = {3{pat_en[8]}} &  pat_mask8[3 +:3] & {                     ly4[3],ly4[4],ly4[5]                                     }; // ly4 ---xxx-----
  assign pat[8][5] = {3{pat_en[8]}} &  pat_mask8[0 +:3] & {              ly5[2],ly5[3],ly5[4]                                            }; // ly5 --xxx------

// Pattern 7                                                                                                                                       0123456789ABC
  assign pat[7][0] = {3{pat_en[7]}} &  pat_mask7[15+:3] & {ly0[0],ly0[1],ly0[2]                                                          }; // ly0 xxx--------
  assign pat[7][1] = {3{pat_en[7]}} &  pat_mask7[12+:3] & {       ly1[1],ly1[2],ly1[3]                                                   }; // ly1 -xxx-------
  assign pat[7][2] = {3{pat_en[7]}} &  pat_mask7[9 +:3] & {                     ly2[3],ly2[4],ly2[5]                                     }; // ly2 ---xxk-----
  assign pat[7][3] = {3{pat_en[7]}} &  pat_mask7[6 +:3] & {                                   ly3[5],ly3[6],ly3[7]                       }; // ly3 -----xxx---
  assign pat[7][4] = {3{pat_en[7]}} &  pat_mask7[3 +:3] & {                                                 ly4[7],ly4[8],ly4[9]         }; // ly4 -------xxx-
  assign pat[7][5] = {3{pat_en[7]}} &  pat_mask7[0 +:3] & {                                                        ly5[8],ly5[9],ly5[A]  }; // ly5 --------xxx

// Pattern 6                                                                                                                                       0123456789ABC
  assign pat[6][0] = {3{pat_en[6]}} &  pat_mask6[15+:3] & {                                                        ly0[8],ly0[9],ly0[A]  }; // ly0 --------xxx--
  assign pat[6][1] = {3{pat_en[6]}} &  pat_mask6[12+:3] & {                                                 ly1[7],ly1[8],ly1[9]         }; // ly1 -------xxx---
  assign pat[6][2] = {3{pat_en[6]}} &  pat_mask6[9 +:3] & {                                   ly2[5],ly2[6],ly2[7]                       }; // ly2 -----kxx-----
  assign pat[6][3] = {3{pat_en[6]}} &  pat_mask6[6 +:3] & {                     ly3[3],ly3[4],ly3[5]                                     }; // ly3 ---xxx-------
  assign pat[6][4] = {3{pat_en[6]}} &  pat_mask6[3 +:3] & {       ly4[1],ly4[2],ly4[3]                                                   }; // ly4 -xxx---------
  assign pat[6][5] = {3{pat_en[6]}} &  pat_mask6[0 +:3] & {ly5[0],ly5[1],ly5[2]                                                          }; // ly5 xxx----------

  //assign pat[5][0] = 3'b000;
  //assign pat[5][1] = 3'b000;
  //assign pat[5][2] = 3'b000;
  //assign pat[5][3] = 3'b000;
  //assign pat[5][4] = 3'b000;
  //assign pat[5][5] = 3'b000;

  //assign pat[4][0] = 3'b000;
  //assign pat[4][1] = 3'b000;
  //assign pat[4][2] = 3'b000;
  //assign pat[4][3] = 3'b000;
  //assign pat[4][4] = 3'b000;
  //assign pat[4][5] = 3'b000;

  //assign pat[3][0] = 3'b000;
  //assign pat[3][1] = 3'b000;
  //assign pat[3][2] = 3'b000;
  //assign pat[3][3] = 3'b000;
  //assign pat[3][4] = 3'b000;
  //assign pat[3][5] = 3'b000;

  //assign pat[2][0] = 3'b000;
  //assign pat[2][1] = 3'b000;
  //assign pat[2][2] = 3'b000;
  //assign pat[2][3] = 3'b000;
  //assign pat[2][4] = 3'b000;
  //assign pat[2][5] = 3'b000;

// Count number of layers hit for each pattern
  wire [MXHITB-1:0] nhits [MXPID-1:MIPID];
  wire        [5:0] lyhit [MXPID-1:MIPID];

  genvar i;
  generate
  for (i=MIPID; i<=MXPID-1; i=i+1) begin: gencount
      assign lyhit[i] = ({|(pat[i][0]),|(pat[i][1]),|(pat[i][2]),|(pat[i][3]),|(pat[i][4]),|(pat[i][5])});
      assign nhits[i] = count1s(lyhit[i]);
  end
  endgenerate

// Generate carry flags for each pattern, each layer

  reg  [MXPATC-1:0] carry [MXPID-1:MIPID];

  genvar ily;
  genvar ipat;
  generate
  for (ipat=MIPID; ipat<MXPID; ipat=ipat+1) begin: patloop
    //for (ily=0; ily<6; ily=ily+1) begin: lyloop
    //  always @(*) begin
    //        if      (pat[ipat][ily][0]) carry [ipat][(ily*2)+:2] = 2'd1;
    //        else if (pat[ipat][ily][1]) carry [ipat][(ily*2)+:2] = 2'd2;
    //        else if (pat[ipat][ily][2]) carry [ipat][(ily*2)+:2] = 2'd3;
    //        else                        carry [ipat][(ily*2)+:2] = 2'd0;
    //  end // always
    //end // lyloop
    always @(*) begin
        case(pat[ipat][0])//layer0
            3'b001 : carry [ipat][1:0] <= 2'b01;
            3'b010 : carry [ipat][1:0] <= 2'b10;
            3'b100 : carry [ipat][1:0] <= 2'b11;
            default: carry [ipat][1:0] <= 2'b00;
        endcase
        case(pat[ipat][1])//layer1
            3'b001 : carry [ipat][3:2] <= 2'b01;
            3'b010 : carry [ipat][3:2] <= 2'b10;
            3'b100 : carry [ipat][3:2] <= 2'b11;
            default: carry [ipat][3:2] <= 2'b00;
        endcase
        carry [ipat][4] <= pat[ipat][2][1];//key layer, layer2
        case(pat[ipat][3])//layer3
            3'b001 : carry [ipat][6:5] <= 2'b01;
            3'b010 : carry [ipat][6:5] <= 2'b10;
            3'b100 : carry [ipat][6:5] <= 2'b11;
            default: carry [ipat][6:5] <= 2'b00;
        endcase
        case(pat[ipat][4])//layer4
            3'b001 : carry [ipat][8:7] <= 2'b01;
            3'b010 : carry [ipat][8:7] <= 2'b10;
            3'b100 : carry [ipat][8:7] <= 2'b11;
            default: carry [ipat][8:7] <= 2'b00;
        endcase
        case(pat[ipat][5])//layer5
            3'b001 : carry [ipat][10:9] <= 2'b01;
            3'b010 : carry [ipat][10:9] <= 2'b10;
            3'b100 : carry [ipat][10:9] <= 2'b11;
            default: carry [ipat][10:9] <= 2'b00;
        endcase

    end // always

  end // patloop
  endgenerate

// Best 1 of 8 Priority Encoder, perfers higher pattern number if hits are equal
  wire [MXHITB-1:0] nhits_s0 [2:0];
  wire [MXHITB-1:0] nhits_s1 [1:0];
  wire [MXHITB-1:0] nhits_s2 [0:0];

  wire [MXPATC-1:0] carry_s0 [2:0];
  wire [MXPATC-1:0] carry_s1 [1:0];
  wire [MXPATC-1:0] carry_s2 [0:0];

  wire [2:0] pid_s0;
  wire [1:0] pid_s1 [1:0];
  wire [MXPIDB-1:0] pid_s2 [0:0];

// 5 to 3
  assign {nhits_s0[2],pid_s0[2],carry_s0[2]} =                         {nhits[A],1'b0,carry[A]};
  assign {nhits_s0[1],pid_s0[1],carry_s0[1]} = (nhits[8] > nhits[9]) ? {nhits[8],1'b0,carry[8]} : {nhits[9],1'b1,carry[9]};
  assign {nhits_s0[0],pid_s0[0],carry_s0[0]} = (nhits[6] > nhits[7]) ? {nhits[6],1'b0,carry[6]} : {nhits[7],1'b1,carry[7]};

// 3 to 2
  assign {nhits_s1[1],pid_s1[1],carry_s1[1]} =                               {nhits_s0[2],{1'b0,pid_s0[2]},carry_s0[2]};
  assign {nhits_s1[0],pid_s1[0],carry_s1[0]} = (nhits_s0[0] > nhits_s0[1]) ? {nhits_s0[1],{1'b0,pid_s0[0]},carry_s0[0]} : {nhits_s0[1],{1'b1,pid_s0[1]},carry_s0[1]};

// 2 to 1
  assign {nhits_s2[0],pid_s2[0],carry_s2[0]} = (nhits_s1[0] > nhits_s1[1]) ? {nhits_s1[0],{1'b0,pid_s1[0]},carry_s1[0]} : {nhits_s1[1],{1'b1,pid_s1[1]},carry_s1[1]};


// Add 2 to pid to shift to range 2-10

  assign pat_nhits = nhits_s2 [0][MXHITB-1:0];
  assign pat_id    = pid_s2   [0][MXPIDB-1:0];
  assign pat_carry = carry_s2 [0][MXPATC-1:0];

//------------------------------------------------------------------------------------------------------------------------
//  Prodcedural function to sum number of layers hit into a binary value - ROM version
//  Returns   count1s = (inp[5]+inp[4]+inp[3])+(inp[2]+inp[1]+inp[0]);
//
//  Virtex-6 Specific
//
//  03/21/2013  Initial
//------------------------------------------------------------------------------------------------------------------------

  function  [2:0] count1s;
  input     [5:0] inp;
  reg       [2:0] rom;

  begin
  case(inp[5:0])
  6'b000000: rom = 0;
  6'b000001: rom = 1;
  6'b000010: rom = 1;
  6'b000011: rom = 2;
  6'b000100: rom = 1;
  6'b000101: rom = 2;
  6'b000110: rom = 2;
  6'b000111: rom = 3;
  6'b001000: rom = 1;
  6'b001001: rom = 2;
  6'b001010: rom = 2;
  6'b001011: rom = 3;
  6'b001100: rom = 2;
  6'b001101: rom = 3;
  6'b001110: rom = 3;
  6'b001111: rom = 4;
  6'b010000: rom = 1;
  6'b010001: rom = 2;
  6'b010010: rom = 2;
  6'b010011: rom = 3;
  6'b010100: rom = 2;
  6'b010101: rom = 3;
  6'b010110: rom = 3;
  6'b010111: rom = 4;
  6'b011000: rom = 2;
  6'b011001: rom = 3;
  6'b011010: rom = 3;
  6'b011011: rom = 4;
  6'b011100: rom = 3;
  6'b011101: rom = 4;
  6'b011110: rom = 4;
  6'b011111: rom = 5;
  6'b100000: rom = 1;
  6'b100001: rom = 2;
  6'b100010: rom = 2;
  6'b100011: rom = 3;
  6'b100100: rom = 2;
  6'b100101: rom = 3;
  6'b100110: rom = 3;
  6'b100111: rom = 4;
  6'b101000: rom = 2;
  6'b101001: rom = 3;
  6'b101010: rom = 3;
  6'b101011: rom = 4;
  6'b101100: rom = 3;
  6'b101101: rom = 4;
  6'b101110: rom = 4;
  6'b101111: rom = 5;
  6'b110000: rom = 2;
  6'b110001: rom = 3;
  6'b110010: rom = 3;
  6'b110011: rom = 4;
  6'b110100: rom = 3;
  6'b110101: rom = 4;
  6'b110110: rom = 4;
  6'b110111: rom = 5;
  6'b111000: rom = 3;
  6'b111001: rom = 4;
  6'b111010: rom = 4;
  6'b111011: rom = 5;
  6'b111100: rom = 4;
  6'b111101: rom = 5;
  6'b111110: rom = 5;
  6'b111111: rom = 6;
  endcase

  count1s = rom;

  end
  endfunction

//------------------------------------------------------------------------------------------------------------------------
  endmodule
//------------------------------------------------------------------------------------------------------------------------

