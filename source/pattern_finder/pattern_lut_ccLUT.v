`timescale 1ns / 1ps
//-------------------------------------------------------------------------------------------------------------------
//  05/18/2017 Initial
//  20/07/2020  create one for ccLUT algorithm
//-------------------------------------------------------------------------------------------------------------------
  module pattern_lut_ccLUT (
    input                    clock,

    input      [MXPATB-1:0]  pat00, pat01,

    input      [MXPATC-1:0]  carry00, carry01,

    output reg [MXOFFSB -1:0]  offs0, offs1,
    output reg [MXBNDB-1:0]  bend0, bend1,
    output reg [MXQLTB-1:0]  quality0, quality1

  );

// Constants

`include "pattern_params.v"

parameter MXADRB  = 12;
parameter MXDATB  = 18;

wire [MXDATB-1:0]   rd0_patA, rd1_patA,
                    rd0_pat9, rd1_pat9,
                    rd0_pat8, rd1_pat8,
                    rd0_pat7, rd1_pat7,
                    rd0_pat6, rd1_pat6,
                    rd0_pat5, rd1_pat5,
                    rd0_pat4, rd1_pat4,
                    rd0_pat3, rd1_pat3,
                    rd0_pat2, rd1_pat2,
                    rd0_blnk, rd1_blnk;

assign rd0_blnk = 0;
assign rd1_blnk = 0;

//----------------------------------------------------------------------------------------------------------------------
// ROMS
//----------------------------------------------------------------------------------------------------------------------

generate
if (pat_en[A])
rom #(
  .ROM_FILE("../source/pattern_finder/rom_patA.mem"),
  .FALLING_EDGE(1'b1),
  .MXADRB(MXADRB),
  .MXDATB(MXDATB)
)
romA (
  .clock(clock),
  .adr0(carry00),
  .adr1(carry01),
  .rd0 (rd0_patA),
  .rd1 (rd1_patA)
);
else
  assign rd0_pat10 = 0;
endgenerate

generate
if (pat_en[9])
rom #(
  .ROM_FILE("../source/pattern_finder/rom_pat9.mem"),
  .FALLING_EDGE(1'b1),
  .MXADRB(MXADRB),
  .MXDATB(MXDATB)
) rom9 (
  .clock(clock),
  .adr0(carry00),
  .adr1(carry01),
  .rd0 (rd0_pat9),
  .rd1 (rd1_pat9)
);
else
  assign rd0_pat9 = 0;
endgenerate

generate
if (pat_en[8])
rom #(
  .ROM_FILE("../source/pattern_finder/rom_pat8.mem"),
  .FALLING_EDGE(1'b1),
  .MXADRB(MXADRB),
  .MXDATB(MXDATB)
) rom8 (
  .clock(clock),
  .adr0(carry00),
  .adr1(carry01),
  .rd0 (rd0_pat8),
  .rd1 (rd1_pat8)
);
else
  assign rd0_pat8 = 0;
endgenerate

generate
if (pat_en[7])
rom #(
  .ROM_FILE("../source/pattern_finder/rom_pat7.mem"),
  .FALLING_EDGE(1'b1),
  .MXADRB(MXADRB),
  .MXDATB(MXDATB)
) rom7 (
  .clock(clock),
  .adr0(carry00),
  .adr1(carry01),
  .rd0 (rd0_pat7),
  .rd1 (rd1_pat7)
);
else
  assign rd0_pat7 = 0;
endgenerate

generate
if (pat_en[6])
rom #(
  .ROM_FILE("../source/pattern_finder/rom_pat6.mem"),
  .FALLING_EDGE(1'b1),
  .MXADRB(MXADRB),
  .MXDATB(MXDATB)
) rom6 (
  .clock(clock),
  .adr0(carry00),
  .adr1(carry01),
  .rd0 (rd0_pat6),
  .rd1 (rd1_pat6)
);
else
  assign rd0_pat6 = 0;
endgenerate

//generate
//if (pat_en[5])
//rom #(
//  .ROM_FILE("../source/pattern_finder/rom_pat5.mem"),
//  .FALLING_EDGE(1'b1),
//  .MXADRB(MXADRB),
//  .MXDATB(MXDATB)
//) rom5 (
//  .clock(clock),
//  .adr0(carry00),
//  .adr1(carry01),
//  .rd0 (rd0_pat5),
//  .rd1 (rd1_pat5)
//);
//else
//  assign rd0_pat5 = 0;
//endgenerate
//
//generate
//if (pat_en[4])
//rom #(
//  .ROM_FILE("../source/pattern_finder/rom_pat4.mem"),
//  .FALLING_EDGE(1'b1),
//  .MXADRB(MXADRB),
//  .MXDATB(MXDATB)
//) rom4 (
//  .clock(clock),
//  .adr0(carry00),
//  .adr1(carry01),
//  .rd0 (rd0_pat4),
//  .rd1 (rd1_pat4)
//);
//else
//  assign rd0_pat4 = 0;
//endgenerate
//
//generate
//if (pat_en[3])
//rom #(
//  .ROM_FILE("../source/pattern_finder/rom_pat3.mem"),
//  .FALLING_EDGE(1'b1),
//  .MXADRB(MXADRB),
//  .MXDATB(MXDATB)
//) rom3 (
//  .clock(clock),
//  .adr0(carry00),
//  .adr1(carry01),
//  .rd0 (rd0_pat3),
//  .rd1 (rd1_pat3)
//);
//else
//  assign rd0_pat3 = 0;
//endgenerate
//
//generate
//if (pat_en[2])
//  rom #(
//.ROM_FILE("../source/pattern_finder/rom_pat2.mem"),
//.FALLING_EDGE(1'b1),
//  .MXADRB(MXADRB),
//  .MXDATB(MXDATB)
//) rom2 (
//  .clock(clock),
//  .adr0(carry00),
//  .adr1(carry01),
//  .rd0 (rd0_pat2),
//  .rd1 (rd1_pat2)
//);
//else
//  assign rd0_pat2 = 0;
//endgenerate

//----------------------------------------------------------------------------------------------------------------------
//
//----------------------------------------------------------------------------------------------------------------------

wire [MXHITB-1:0] hs_hit00, hs_hit01;
wire [MXPIDB-1:0] hs_pid00, hs_pid01;

assign hs_pid00 = pat00 [0+:MXPIDB];
assign hs_pid01 = pat01 [0+:MXPIDB];

assign hs_hit00 = pat00 [MXPIDB+:MXHITB];
assign hs_hit01 = pat01 [MXPIDB+:MXHITB];

// demultiplex the different lookup registers

reg [MXDATB-1:0] rd0, rd1;

always @(*) begin
  case (hs_pid00)
    16'hA:   rd0 = (pat_en['hA]) ? rd0_patA : rd0_blnk;
    16'h9:   rd0 = (pat_en['h9]) ? rd0_pat9 : rd0_blnk;
    16'h8:   rd0 = (pat_en['h8]) ? rd0_pat8 : rd0_blnk;
    16'h7:   rd0 = (pat_en['h7]) ? rd0_pat7 : rd0_blnk;
    16'h6:   rd0 = (pat_en['h6]) ? rd0_pat6 : rd0_blnk;
    16'h5:   rd0 = (pat_en['h5]) ? rd0_pat5 : rd0_blnk;
    16'h4:   rd0 = (pat_en['h4]) ? rd0_pat4 : rd0_blnk;
    16'h3:   rd0 = (pat_en['h3]) ? rd0_pat3 : rd0_blnk;
    16'h2:   rd0 = (pat_en['h2]) ? rd0_pat2 : rd0_blnk;
    default: rd0 =                            rd0_blnk;
  endcase

  case (hs_pid01)
    16'hA:   rd1 = (pat_en['hA]) ? rd1_patA : rd1_blnk;
    16'h9:   rd1 = (pat_en['h9]) ? rd1_pat9 : rd1_blnk;
    16'h8:   rd1 = (pat_en['h8]) ? rd1_pat8 : rd1_blnk;
    16'h7:   rd1 = (pat_en['h7]) ? rd1_pat7 : rd1_blnk;
    16'h6:   rd1 = (pat_en['h6]) ? rd1_pat6 : rd1_blnk;
    16'h5:   rd1 = (pat_en['h5]) ? rd1_pat5 : rd1_blnk;
    16'h4:   rd1 = (pat_en['h4]) ? rd1_pat4 : rd1_blnk;
    16'h3:   rd1 = (pat_en['h3]) ? rd1_pat3 : rd1_blnk;
    16'h2:   rd1 = (pat_en['h2]) ? rd1_pat2 : rd1_blnk;
    default: rd1 =                            rd1_blnk;
  endcase
end

// FAST
always @(*) begin

  offs0    <= rd0[17:14];
  offs1    <= rd1[17:14];

  bend0    <= rd0[13:9];
  bend1    <= rd1[13:9];

  quality0 <= rd0[8:0];
  quality1 <= rd1[8:0];

end

//-------------------------------------------------------------------------------------------------------------------
  endmodule
//-------------------------------------------------------------------------------------------------------------------
