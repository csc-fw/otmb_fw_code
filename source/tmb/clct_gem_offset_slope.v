`timescale 1ns / 1ps
//-------------------------------------------------------------------------------------------------------------------
// input  CSC bending
// output is offset to CSC cathode key position, for GEMCSC bending angle 
//-------------------------------------------------------------------------------------------------------------------
module clct_gem_offset_slope (
    clock, 
    clct0_bend, 
    clct1_bend, 
    isME1a0, 
    isME1a1, 
    even, 
    clct0_gemA_offset,
    clct0_gemB_offset,
    clct1_gemA_offset,
    clct1_gemB_offset
  );

parameter MXADRB       = 4;
parameter MXDATB       = 8;
// Ports
  input                  clock;
  input [3:0]  clct0_bend;
  input [3:0]  clct0_bend;
  input                isME1a0;
  input                isME1a1;
  input                   even;
  output[7:0]    clct0_gemA_offset;
  output[7:0]    clct0_gemB_offset;
  output[7:0]    clct1_gemA_offset;
  output[7:0]    clct1_gemB_offset;


  wire [7:0] clct0_offset_me1b_odd_A,  clct0_offset_me1b_odd_B;
  wire [7:0] clct1_offset_me1b_odd_A,  clct1_offset_me1b_odd_B;
  wire [7:0] clct0_offset_me1b_even_A, clct0_offset_me1b_even_B;
  wire [7:0] clct1_offset_me1b_even_A, clct1_offset_me1b_even_B;
  wire [7:0] clct0_offset_me1a_odd_A,  clct0_offset_me1a_odd_B;
  wire [7:0] clct1_offset_me1a_odd_A,  clct1_offset_me1a_odd_B;
  wire [7:0] clct0_offset_me1a_even_A, clct0_offset_me1a_even_B;
  wire [7:0] clct1_offset_me1a_even_A, clct1_offset_me1a_even_B;
  
// ME1B part 
rom_cscoffset_slope #(
  .ROM_FILE("GEMCSCSlopeCorr_ME1b_odd_layer1.mem"),
  .MXADRB(MXADRB),
  .MXDATB(MXDATB),
  .ROMLENGTH(16)
) romoffsetme1boddA (
  .clock(clock),
  .adr0(clct0_bend),
  .adr1(clct1_bend),
  .rd0 (clct0_offset_me1b_odd_A),
  .rd1 (clct1_offset_me1b_odd_A)
);

rom_cscoffset_slope #(
  .ROM_FILE("GEMCSCSlopeCorr_ME1b_even_layer1.mem"),
  .MXADRB(MXADRB),
  .MXDATB(MXDATB),
  .ROMLENGTH(16)
) romoffsetme1bevenA (
  .clock(clock),
  .adr0(clct0_bend),
  .adr1(clct1_bend),
  .rd0 (clct0_offset_me1b_even_A),
  .rd1 (clct1_offset_me1b_even_A)
);

rom_cscoffset_slope #(
  .ROM_FILE("GEMCSCSlopeCorr_ME1b_odd_layer2.mem"),
  .MXADRB(MXADRB),
  .MXDATB(MXDATB),
  .ROMLENGTH(16)
) romoffsetme1boddB (
  .clock(clock),
  .adr0(clct0_bend),
  .adr1(clct1_bend),
  .rd0 (clct0_offset_me1b_odd_B),
  .rd1 (clct1_offset_me1b_odd_B)
);

rom_cscoffset_slope #(
  .ROM_FILE("GEMCSCSlopeCorr_ME1b_even_layer2.mem"),
  .MXADRB(MXADRB),
  .MXDATB(MXDATB),
  .ROMLENGTH(16)
) romoffsetme1bevenB (
  .clock(clock),
  .adr0(clct0_bend),
  .adr1(clct1_bend),
  .rd0 (clct0_offset_me1b_odd_B),
  .rd1 (clct1_offset_me1b_odd_B)
);

// ME1A part 
rom_cscoffset_slope #(
  .ROM_FILE("GEMCSCSlopeCorr_ME1a_odd_layer1.mem"),
  .MXADRB(MXADRB),
  .MXDATB(MXDATB),
  .ROMLENGTH(16)
) romoffsetme1aoddA (
  .clock(clock),
  .adr0(clct0_bend),
  .adr1(clct1_bend),
  .rd0 (clct0_offset_me1a_odd_A),
  .rd1 (clct1_offset_me1a_odd_A)
);

rom_cscoffset_slope #(
  .ROM_FILE("GEMCSCSlopeCorr_ME1a_even_layer1.mem"),
  .MXADRB(MXADRB),
  .MXDATB(MXDATB),
  .ROMLENGTH(16)
) romoffsetme1aevenA (
  .clock(clock),
  .adr0(clct0_bend),
  .adr1(clct1_bend),
  .rd0 (clct0_offset_me1a_even_A),
  .rd1 (clct1_offset_me1a_even_A)
);

rom_cscoffset_slope #(
  .ROM_FILE("GEMCSCSlopeCorr_ME1a_odd_layer2.mem"),
  .MXADRB(MXADRB),
  .MXDATB(MXDATB),
  .ROMLENGTH(16)
) romoffsetme1aoddB (
  .clock(clock),
  .adr0(clct0_bend),
  .adr1(clct1_bend),
  .rd0 (clct0_offset_me1a_odd_B),
  .rd1 (clct1_offset_me1a_odd_B)
);

rom_cscoffset_slope #(
  .ROM_FILE("GEMCSCSlopeCorr_ME1a_even_layer2.mem"),
  .MXADRB(MXADRB),
  .MXDATB(MXDATB),
  .ROMLENGTH(16)
) romoffsetme1aevenB (
  .clock(clock),
  .adr0(clct0_bend),
  .adr1(clct1_bend),
  .rd0 (clct0_offset_me1a_even_B),
  .rd1 (clct1_offset_me1a_even_B)
);

  wire [7:0] clct0_offset_gemA_even = isME1a0 ? clct0_offset_me1a_even_A : clct0_offset_me1b_even_A;
  wire [7:0] clct1_offset_gemA_even = isME1a1 ? clct1_offset_me1a_even_A : clct1_offset_me1b_even_A;
  wire [7:0] clct0_offset_gemA_odd  = isME1a0 ? clct0_offset_me1a_odd_A  : clct0_offset_me1b_odd_A;
  wire [7:0] clct1_offset_gemA_odd  = isME1a1 ? clct1_offset_me1a_odd_A  : clct1_offset_me1b_odd_A;
  wire [7:0] clct0_offset_gemB_even = isME1a0 ? clct0_offset_me1a_even_B : clct0_offset_me1b_even_B;
  wire [7:0] clct1_offset_gemB_even = isME1a1 ? clct1_offset_me1a_even_B : clct1_offset_me1b_even_B;
  wire [7:0] clct0_offset_gemB_odd  = isME1a0 ? clct0_offset_me1a_odd_B  : clct0_offset_me1b_odd_B;
  wire [7:0] clct1_offset_gemB_odd  = isME1a1 ? clct1_offset_me1a_odd_B  : clct1_offset_me1b_odd_B;

  assign clct0_gemA_offset      = even ? clct0_offset_gemA_even : clct0_offset_gemA_odd;
  assign clct0_gemB_offset      = even ? clct0_offset_gemB_even : clct0_offset_gemB_odd;
  assign clct1_gemA_offset      = even ? clct1_offset_gemA_even : clct1_offset_gemA_odd;
  assign clct1_gemB_offset      = even ? clct1_offset_gemB_even : clct1_offset_gemB_odd;


//-------------------------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------------------------
