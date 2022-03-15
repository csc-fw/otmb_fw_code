`timescale 1ns / 1ps
//-------------------------------------------------------------------------------------------------------------------
// GEMCSC bending angle converted into 4bits value 
// input gemcsc bending, unit is 1/8 strip. total 7bits
// output 4bits value
//-------------------------------------------------------------------------------------------------------------------
//https://github.com/gem-sw/GEMCode/blob/DisplacedMuonTriggerPtassignment/GEMValidation/interface/Helpers.h
//const double ME11GEMdPhi[8][3] = {
//		{-2, 1.0, 1.0},
//		{5.0,  0.02131422,  0.00907379 },
//		{7.0,  0.01480166,  0.00658598 },
//		{10.0,  0.01019511,  0.00467867 },
//		{15.0,  0.00685720,  0.00336636 },
//		{20.0,  0.00528981,  0.00279064 },
//		{30.0,  0.00381797,  0.00231837 },
//		{40.0,  0.00313074,  0.00213513 },
//    };
//const double ME21GEMdPhi[8][3] = {
//		{-2, 1.0, 1.0},
//		{5.0,  0.00884066,  0.00479478 },
//		{7.0,  0.00660301,  0.00403733 },
//		{10.0,  0.00503144,  0.00369953 },
//		{15.0,  0.00409270,  0.00358023 },
//		{20.0,  0.00378257,  0.00358023 },
//		{30.0,  0.00369842,  0.00358023 },
//		{40.0,  0.00369842,  0.00358023 },
//    };
// ME1/B 1/8 strip = 2*pi/(36x128x4) = 0.00034089;   ME1/A 1/8 strip = 2*pi/(36*96*4)=0.00045451282
//  pT  	 odd, 	 even;  ME1A	 odd, 	 even
//  5.0 	 62.5, 	 26.6;    	46.9, 	 20.0
//  7.0 	 43.4, 	 19.3;    	32.6, 	 14.5
//  10.0 	 29.9, 	 13.7;    	22.4, 	 10.3
//  15.0 	 20.1, 	 9.9;    	15.1, 	 7.4
//  20.0 	 15.5, 	 8.2;    	11.6, 	 6.1
//  30.0 	 11.2, 	 6.8;    	8.4, 	 5.1
//  40.0 	 9.2, 	 6.3;    	6.9, 	 4.7
// odd: 100, 63, 56, 49, 43, 37, 32, 28, 24, 20,  17, 15, 13, 11,  9
//even:  46, 30, 27, 25, 23, 20, 18, 16, 14, 12, 10,  8,  6,   5,  4
//uniform for even and odd: 
//       60, 56, 52, 48, 44, 40, 36, 32, 28, 24, 20, 16,   12, 8,  4
module gemcsc_bending_bits (
    clock,  
    gemcsc_bending0,//gemcsc bending angle for first LCT 
    gemcsc_bending1,//gemcsc bending angle for second LCT
    gemcsc_gemB0,   //gemcsc match from CSC-gemB match for 1st LCT
    gemcsc_gemB1,   //gemcsc match from CSC-gemB match for 2nd LCT
    isME1a0,       //1st LCT in ME1a or not
    isME1a1,       //2nd LCT in ME1a or not
    even,          // evenchamber or not
    bending_bits0, //corrected gemcsc bending angle 
    bending_bits1  //corrected gemcsc bending angle
  );

parameter MXADRB       = 7;
parameter MXDATB       = 4;
// Ports
  input                  clock;
  input [6:0]  gemcsc_bending0;
  input [6:0]  gemcsc_bending1;
  input           gemcsc_gemB0;
  input           gemcsc_gemB1;
  input                isME1a0;
  input                isME1a1;
  input                   even;
  output[3:0]    bending_bits0;
  output[3:0]    bending_bits1;


  wire [3:0] bending_bit0_me1b_odd_A,  bending_bit0_me1b_odd_B;
  wire [3:0] bending_bit1_me1b_odd_A,  bending_bit1_me1b_odd_B;
  wire [3:0] bending_bit0_me1b_even_A, bending_bit0_me1b_even_B;
  wire [3:0] bending_bit1_me1b_even_A, bending_bit1_me1b_even_B;
  wire [3:0] bending_bit0_me1a_odd_A,  bending_bit0_me1a_odd_B;
  wire [3:0] bending_bit1_me1a_odd_A,  bending_bit1_me1a_odd_B;
  wire [3:0] bending_bit0_me1a_even_A, bending_bit0_me1a_even_B;
  wire [3:0] bending_bit1_me1a_even_A, bending_bit1_me1a_even_B;
  wire [3:0] bending_bit0_even, bending_bit0_odd;
  wire [3:0] bending_bit1_even, bending_bit1_odd;
  
//ME1B part
rom_gemcsc_slope #(
  .ROM_FILE("GEMCSC_SlopeAmendment_NoCOSI_ME1b_odd_layer1.mem"),
  .MXADRB(MXADRB),
  .MXDATB(MXDATB),
  .ROMLENGTH(128)
) romme1boddA (
  .clock(clock),
  .adr0(gemcsc_bending0),
  .adr1(gemcsc_bending1),
  .rd0 (bending_bit0_me1b_odd_A),
  .rd1 (bending_bit1_me1b_odd_A)
);

rom_gemcsc_slope #(
  .ROM_FILE("GEMCSC_SlopeAmendment_NoCOSI_ME1b_even_layer1.mem"),
  .MXADRB(MXADRB),
  .MXDATB(MXDATB),
  .ROMLENGTH(128)
) romme1bevenA (
  .clock(clock),
  .adr0(gemcsc_bending0),
  .adr1(gemcsc_bending1),
  .rd0 (bending_bit0_me1b_even_A),
  .rd1 (bending_bit1_me1b_even_A)
);

rom_gemcsc_slope #(
  .ROM_FILE("GEMCSC_SlopeAmendment_NoCOSI_ME1b_odd_layer2.mem"),
  .MXADRB(MXADRB),
  .MXDATB(MXDATB),
  .ROMLENGTH(128)
) romme1boddB (
  .clock(clock),
  .adr0(gemcsc_bending0),
  .adr1(gemcsc_bending1),
  .rd0 (bending_bit0_me1b_odd_B),
  .rd1 (bending_bit1_me1b_odd_B)
);

rom_gemcsc_slope #(
  .ROM_FILE("GEMCSC_SlopeAmendment_NoCOSI_ME1b_even_layer2.mem"),
  .MXADRB(MXADRB),
  .MXDATB(MXDATB),
  .ROMLENGTH(128)
) romme1bevenB (
  .clock(clock),
  .adr0(gemcsc_bending0),
  .adr1(gemcsc_bending1),
  .rd0 (bending_bit0_me1b_even_B),
  .rd1 (bending_bit1_me1b_even_B)
);


//ME1A part
rom_gemcsc_slope #(
  .ROM_FILE("GEMCSC_SlopeAmendment_NoCOSI_ME1a_odd_layer1.mem"),
  .MXADRB(MXADRB),
  .MXDATB(MXDATB),
  .ROMLENGTH(128)
) romme1aoddA (
  .clock(clock),
  .adr0(gemcsc_bending0),
  .adr1(gemcsc_bending1),
  .rd0 (bending_bit0_me1a_odd_A),
  .rd1 (bending_bit1_me1a_odd_A)
);

rom_gemcsc_slope #(
  .ROM_FILE("GEMCSC_SlopeAmendment_NoCOSI_ME1a_even_layer1.mem"),
  .MXADRB(MXADRB),
  .MXDATB(MXDATB),
  .ROMLENGTH(128)
) romme1aevenA (
  .clock(clock),
  .adr0(gemcsc_bending0),
  .adr1(gemcsc_bending1),
  .rd0 (bending_bit0_me1a_even_A),
  .rd1 (bending_bit1_me1a_even_A)
);

rom_gemcsc_slope #(
  .ROM_FILE("GEMCSC_SlopeAmendment_NoCOSI_ME1a_odd_layer2.mem"),
  .MXADRB(MXADRB),
  .MXDATB(MXDATB),
  .ROMLENGTH(128)
) romme1aoddB (
  .clock(clock),
  .adr0(gemcsc_bending0),
  .adr1(gemcsc_bending1),
  .rd0 (bending_bit0_me1a_odd_B),
  .rd1 (bending_bit1_me1a_odd_B)
);

rom_gemcsc_slope #(
  .ROM_FILE("GEMCSC_SlopeAmendment_NoCOSI_ME1a_even_layer2.mem"),
  .MXADRB(MXADRB),
  .MXDATB(MXDATB),
  .ROMLENGTH(128)
) romme1aevenB (
  .clock(clock),
  .adr0(gemcsc_bending0),
  .adr1(gemcsc_bending1),
  .rd0 (bending_bit0_me1a_even_B),
  .rd1 (bending_bit1_me1a_even_B)
);

  wire [3:0] bending_bit0_even_A = isME1a0 ? bending_bit0_me1a_even_A : bending_bit0_me1b_even_A;
  wire [3:0] bending_bit0_even_B = isME1a0 ? bending_bit0_me1a_even_B : bending_bit0_me1b_even_B;
  wire [3:0] bending_bit1_even_A = isME1a1 ? bending_bit1_me1a_even_A : bending_bit1_me1b_even_A;
  wire [3:0] bending_bit1_even_B = isME1a1 ? bending_bit1_me1a_even_B : bending_bit1_me1b_even_B;

  wire [3:0] bending_bit0_odd_A  = isME1a0 ? bending_bit0_me1a_odd_A : bending_bit0_me1b_odd_A;
  wire [3:0] bending_bit0_odd_B  = isME1a0 ? bending_bit0_me1a_odd_B : bending_bit0_me1b_odd_B;
  wire [3:0] bending_bit1_odd_A  = isME1a1 ? bending_bit1_me1a_odd_A : bending_bit1_me1b_odd_A;
  wire [3:0] bending_bit1_odd_B  = isME1a1 ? bending_bit1_me1a_odd_B : bending_bit1_me1b_odd_B;

  assign bending_bit0_even = gemcsc_gemB0 ? bending_bit0_even_B : bending_bit0_even_A;
  assign bending_bit1_even = gemcsc_gemB1 ? bending_bit1_even_B : bending_bit1_even_A;
  assign bending_bit0_odd  = gemcsc_gemB0 ? bending_bit0_odd_B  : bending_bit0_odd_A;
  assign bending_bit1_odd  = gemcsc_gemB1 ? bending_bit1_odd_B  : bending_bit1_odd_A;
  assign bending_bits0 = even ? bending_bit0_even : bending_bit0_odd;
  assign bending_bits1 = even ? bending_bit1_even : bending_bit1_odd;

//// Quality-by-quality definition
//  reg [3:0] out;
//  assign bending_bits = out;
//
//  always @* begin
//    if (gemcsc_bending[6:2] >= 5'b10000) out <= 4'b1111;
//    else                                 out <= gemcsc_bending[5:2];// namely hs
//  end

//-------------------------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------------------------
