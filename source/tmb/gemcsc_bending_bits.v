`timescale 1ns / 1ps
//-------------------------------------------------------------------------------------------------------------------
// GEMCSC bending angle converted into 4bits value 
//-------------------------------------------------------------------------------------------------------------------
//
//
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
module lct_quality (ACC,A,C,A4,C4,P,CPAT,Q);

// Ports
  input  ACC;     // ALCT accelerator muon bit
  input  A;       // bit: ALCT was found
  input  C;       // bit: CLCT was found
  input  A4;      // bit (N_A>=4), where N_A=number of ALCT layers
  input  C4;      // bit (N_C>=4), where N_C=number of CLCT layers
  input  [3:0] P; // 4-bit CLCT pattern number that is presently 1 for n-layer triggers, 2-10 for current patterns, 11-15 "for future expansion".
  input  CPAT;    // bit for cathode .pattern trigger., i.e. (P>=2 && P<=10) at present
  output [3:0] Q; // 4-bit TMB quality output

// Quality-by-quality definition
  reg [3:0] Q;

  always @* begin

  if      ( !ACC && A4 && C4 && P==10 )          Q=15; // HQ muon, straight
  else if ( !ACC && A4 && C4 && (P==9 || P==8) ) Q=14; // HQ muon, slight bend
  else if ( !ACC && A4 && C4 && (P==7 || P==6) ) Q=13; // HQ muon, more
  else if ( !ACC && A4 && C4 && (P==5 || P==4) ) Q=12; // HQ muon, more
  else if ( !ACC && A4 && C4 && (P==3 || P==2) ) Q=11; // HQ muon, more
  //                                              Q=10; // reserved for HQ muons with future patterns
  //                                              Q=9;  // reserved for HQ muons with future patterns
  else if (  ACC   &&  A4       &&  C4 && CPAT ) Q=8; // HQ muon, but accel ALCT
  else if (      A && !A4       &&  C4 && CPAT ) Q=7; // HQ cathode, but marginal anode
  else if (            A4 &&  C && !C4 && CPAT ) Q=6; // HQ anode, but marginal cathode
  else if (      A && !A4 &&  C && !C4 && CPAT ) Q=5; // marginal anode and cathode
  //                                               Q=4; // reserved for LQ muons with 2D information in the future
  else if (      A        &&  C        && P==1 ) Q=3; // any match but layer CLCT
  else if (     !A        &&  C                ) Q=2; // some CLCT, no ALCT (unmatched)
  else if (      A        && !C                ) Q=1; // some ALCT, no CLCT (unmatched)
  else                                           Q=0; // should never be assigned
  end

//-------------------------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------------------------
