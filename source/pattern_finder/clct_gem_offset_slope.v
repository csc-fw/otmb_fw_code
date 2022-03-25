`timescale 1ns / 1ps
//-------------------------------------------------------------------------------------------------------------------
// input  CSC bending
// output is offset to CSC cathode key position, for GEMCSC bending angle 
//-------------------------------------------------------------------------------------------------------------------
module clct_gem_offset_slope (
    clock, 
    clct0_xky, 
    clct0_bend, 
    clct0_lr, 
    clct1_xky, 
    clct1_bend, 
    clct1_lr, 
    isME1a0, 
    isME1a1, 
    even, 
    clct0_gemA_outedge,
    clct0_gemB_outedge,
    clct1_gemA_outedge,
    clct1_gemB_outedge,
    clct0_gemA_edgeoffset,
    clct0_gemB_edgeoffset,
    clct1_gemA_edgeoffset,
    clct1_gemB_edgeoffset,
    clct0_gemA_xky_slopecorr,
    clct0_gemB_xky_slopecorr,
    clct1_gemA_xky_slopecorr,
    clct1_gemB_xky_slopecorr
  );

parameter MXADRB       = 4;
parameter MXDATB       = 8;
parameter MINKEYHSME1B = 10'd0;
parameter MAXKEYHSME1B = 10'd511;
parameter MINKEYHSME1A = 10'd512;
parameter MAXKEYHSME1A = 10'd895;

// Ports
  input                  clock;
  input [9:0]  clct0_xky;
  input [3:0]  clct0_bend;
  input        clct0_lr;
  input [9:0]  clct1_xky;
  input [3:0]  clct1_bend;
  input        clct1_lr;
  input                isME1a0;
  input                isME1a1;
  input                   even;
  output [9:0]    clct0_gemA_xky_slopecorr;//extrapolated GEM location
  output [9:0]    clct0_gemB_xky_slopecorr;
  output [9:0]    clct1_gemA_xky_slopecorr;
  output [9:0]    clct1_gemB_xky_slopecorr;

  output [7:0]    clct0_gemA_edgeoffset;
  output [7:0]    clct0_gemB_edgeoffset;
  output [7:0]    clct1_gemA_edgeoffset;
  output [7:0]    clct1_gemB_edgeoffset;

  output  clct0_gemA_outedge;
  output  clct0_gemB_outedge;
  output  clct1_gemA_outedge;
  output  clct1_gemB_outedge;

  wire [7:0]    clct0_gemA_offset;
  wire [7:0]    clct0_gemB_offset;
  wire [7:0]    clct1_gemA_offset;
  wire [7:0]    clct1_gemB_offset;

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
  .rd0 (clct0_offset_me1b_even_B),
  .rd1 (clct1_offset_me1b_even_B)
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

  //wire [9:0] clct0_minxky = isME1a0 ? MINKEYHSME1A:MINKEYHSME1B;
  //wire [9:0] clct1_minxky = isME1a1 ? MINKEYHSME1A:MINKEYHSME1B;
  //wire [9:0] clct0_maxxky = isME1a0 ? MAXKEYHSME1A:MAXKEYHSME1B;
  //wire [9:0] clct1_maxxky = isME1a1 ? MAXKEYHSME1A:MAXKEYHSME1B;

  //assign clct0_gemA_xky_slopecorr = clct0_lr ? ((clct0_xky>clct0_gemA_offset+clct0_minxky) ? (clct0_xky-clct0_gemA_offset):clct0_minxky) : ((clct0_xky+clct0_gemA_offset > clct0_maxxky) ? clct0_maxxky : clct0_xky+clct0_gemA_offset);
  //assign clct0_gemB_xky_slopecorr = clct0_lr ? ((clct0_xky>clct0_gemB_offset+clct0_minxky) ? (clct0_xky-clct0_gemB_offset):clct0_minxky) : ((clct0_xky+clct0_gemB_offset > clct0_maxxky) ? clct0_maxxky : clct0_xky+clct0_gemB_offset);
  //assign clct1_gemA_xky_slopecorr = clct1_lr ? ((clct1_xky>clct1_gemA_offset+clct1_minxky) ? (clct1_xky-clct1_gemA_offset):clct1_minxky) : ((clct1_xky+clct1_gemA_offset > clct1_maxxky) ? clct1_maxxky : clct1_xky+clct1_gemA_offset);
  //assign clct1_gemB_xky_slopecorr = clct1_lr ? ((clct1_xky>clct1_gemB_offset+clct1_minxky) ? (clct1_xky-clct1_gemB_offset):clct1_minxky) : ((clct1_xky+clct1_gemB_offset > clct1_maxxky) ? clct1_maxxky : clct1_xky+clct1_gemB_offset);

  assign clct0_gemA_xky_slopecorr = clct0_lr ? ((clct0_xky>clct0_gemA_offset) ? (clct0_xky-clct0_gemA_offset) : 10'd0) : (clct0_xky+clct0_gemA_offset);
  assign clct0_gemB_xky_slopecorr = clct0_lr ? ((clct0_xky>clct0_gemB_offset) ? (clct0_xky-clct0_gemB_offset) : 10'd0) : (clct0_xky+clct0_gemB_offset);
  assign clct1_gemA_xky_slopecorr = clct1_lr ? ((clct1_xky>clct1_gemA_offset) ? (clct1_xky-clct1_gemA_offset) : 10'd0) : (clct1_xky+clct1_gemA_offset);
  assign clct1_gemB_xky_slopecorr = clct1_lr ? ((clct1_xky>clct1_gemB_offset) ? (clct1_xky-clct1_gemB_offset) : 10'd0) : (clct1_xky+clct1_gemB_offset);

  assign clct0_gemA_outedge = clct0_lr && (clct0_xky<clct0_gemA_offset);
  assign clct0_gemB_outedge = clct0_lr && (clct0_xky<clct0_gemB_offset);
  assign clct1_gemA_outedge = clct1_lr && (clct1_xky<clct1_gemA_offset);
  assign clct1_gemB_outedge = clct1_lr && (clct1_xky<clct1_gemB_offset);

  assign clct0_gemA_edgeoffset = clct0_gemA_outedge ? clct0_gemA_offset-clct0_xky[7:0]: 8'd0;//distance away from gem edge, where clct0_gem_xky_slopecorr=0
  assign clct0_gemB_edgeoffset = clct0_gemB_outedge ? clct0_gemB_offset-clct0_xky[7:0]: 8'd0;
  assign clct1_gemA_edgeoffset = clct1_gemA_outedge ? clct1_gemA_offset-clct1_xky[7:0]: 8'd0;
  assign clct1_gemB_edgeoffset = clct1_gemB_outedge ? clct1_gemB_offset-clct1_xky[7:0]: 8'd0;

//-------------------------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------------------------
