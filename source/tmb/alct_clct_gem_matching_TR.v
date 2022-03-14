`timescale 1ns / 1ps
// the module is to check ALCT, CLCT, GEM position matching
// step1  ALCT+CLCT+Copad matching
// step2  ALCT+CLCT+singleGEM matching if no copad matching is found
// step3  ALCT+CLCT matching if ALCT+CLCT+singleGEM and ALCT+CLCT+copad are not found
// step4  CLCT+Copad matching if ALCT is not found
// step5  ALCT+Copad matching if CLCT is not found
//  after above match:
//  if CLCT+copad is not found or not allowed by configuration, then copy ALCT0 into ALCT1
//  if ALCT+copad is not found or not allowed by configuration, then copy CLCT0 into CLCT1
//  low Q ALCT/CLCT (nhit=3) could be removed for step3,4,5 match, and this is controlled by configuration
//  default:   match_drop_lowqalct=false, me1a_match_drop_lowqclct=True, me1b_match_drop_lowqclct=True
//
//2021.08  ignore the consistency check between GEMCSC bending and CLCT bending . may add this later
// add clock to increase 1BX latency for alct_clct_gem_matching, to optimize the timing constraints
// one option to optimize the time constraint

module  alct_clct_gem_matching_TR(
  input clock,
    
  input evenchamber,

  input alct0_vpf,
  input alct1_vpf,

  input [6:0] alct0_wg,
  input [6:0] alct1_wg,

  input [2:0] alct0_nhit,
  input [2:0] alct1_nhit,

  input clct0_vpf,
  input clct1_vpf,
  input [9:0] clct0_xky,
  input [9:0] clct1_xky,
  input [4:0] clct0_bnd,//l or r
  input [4:0] clct1_bnd,
  input [2:0] clct0_nhit,
  input [2:0] clct1_nhit,

  //input gem_me1a_match_enable,
  //input gem_me1b_match_enable,
  input match_drop_lowqalct, // drop lowQ stub when no GEM      
  input me1a_match_drop_lowqclct, // drop lowQ stub when no GEM      
  input me1b_match_drop_lowqclct, // drop lowQ stub when no GEM      
  input gemA_match_ignore_position, 
  input gemB_match_ignore_position, 
  input tmb_allow_match,
  input tmb_copad_alct_allow,
  input tmb_copad_clct_allow,
  input gemcsc_ignore_bend_check,

  input [MXCLUSTER_CHAMBER-1:0] gemA_vpf,
  input [MXCLUSTER_CHAMBER-1:0] gemB_vpf,

  input [6:0] gemA_cluster0_wg_lo,
  input [6:0] gemA_cluster1_wg_lo,
  input [6:0] gemA_cluster2_wg_lo,
  input [6:0] gemA_cluster3_wg_lo,
  input [6:0] gemA_cluster4_wg_lo,
  input [6:0] gemA_cluster5_wg_lo,
  input [6:0] gemA_cluster6_wg_lo,
  input [6:0] gemA_cluster7_wg_lo,

  input [6:0] gemA_cluster0_wg_mi,
  input [6:0] gemA_cluster1_wg_mi,
  input [6:0] gemA_cluster2_wg_mi,
  input [6:0] gemA_cluster3_wg_mi,
  input [6:0] gemA_cluster4_wg_mi,
  input [6:0] gemA_cluster5_wg_mi,
  input [6:0] gemA_cluster6_wg_mi,
  input [6:0] gemA_cluster7_wg_mi,

  input [6:0] gemA_cluster0_wg_hi,
  input [6:0] gemA_cluster1_wg_hi,
  input [6:0] gemA_cluster2_wg_hi,
  input [6:0] gemA_cluster3_wg_hi,
  input [6:0] gemA_cluster4_wg_hi,
  input [6:0] gemA_cluster5_wg_hi,
  input [6:0] gemA_cluster6_wg_hi,
  input [6:0] gemA_cluster7_wg_hi,

  input [9:0] gemA_cluster0_xky_lo,
  input [9:0] gemA_cluster1_xky_lo,
  input [9:0] gemA_cluster2_xky_lo,
  input [9:0] gemA_cluster3_xky_lo,
  input [9:0] gemA_cluster4_xky_lo,
  input [9:0] gemA_cluster5_xky_lo,
  input [9:0] gemA_cluster6_xky_lo,
  input [9:0] gemA_cluster7_xky_lo,

  input [9:0] gemA_cluster0_xky_hi,
  input [9:0] gemA_cluster1_xky_hi,
  input [9:0] gemA_cluster2_xky_hi,
  input [9:0] gemA_cluster3_xky_hi,
  input [9:0] gemA_cluster4_xky_hi,
  input [9:0] gemA_cluster5_xky_hi,
  input [9:0] gemA_cluster6_xky_hi,
  input [9:0] gemA_cluster7_xky_hi,

  input [9:0] gemA_cluster0_xky_mi,
  input [9:0] gemA_cluster1_xky_mi,
  input [9:0] gemA_cluster2_xky_mi,
  input [9:0] gemA_cluster3_xky_mi,
  input [9:0] gemA_cluster4_xky_mi,
  input [9:0] gemA_cluster5_xky_mi,
  input [9:0] gemA_cluster6_xky_mi,
  input [9:0] gemA_cluster7_xky_mi,

  input [6:0] gemB_cluster0_wg_lo,
  input [6:0] gemB_cluster1_wg_lo,
  input [6:0] gemB_cluster2_wg_lo,
  input [6:0] gemB_cluster3_wg_lo,
  input [6:0] gemB_cluster4_wg_lo,
  input [6:0] gemB_cluster5_wg_lo,
  input [6:0] gemB_cluster6_wg_lo,
  input [6:0] gemB_cluster7_wg_lo,

  input [6:0] gemB_cluster0_wg_mi,
  input [6:0] gemB_cluster1_wg_mi,
  input [6:0] gemB_cluster2_wg_mi,
  input [6:0] gemB_cluster3_wg_mi,
  input [6:0] gemB_cluster4_wg_mi,
  input [6:0] gemB_cluster5_wg_mi,
  input [6:0] gemB_cluster6_wg_mi,
  input [6:0] gemB_cluster7_wg_mi,

  input [6:0] gemB_cluster0_wg_hi,
  input [6:0] gemB_cluster1_wg_hi,
  input [6:0] gemB_cluster2_wg_hi,
  input [6:0] gemB_cluster3_wg_hi,
  input [6:0] gemB_cluster4_wg_hi,
  input [6:0] gemB_cluster5_wg_hi,
  input [6:0] gemB_cluster6_wg_hi,
  input [6:0] gemB_cluster7_wg_hi,

  input [9:0] gemB_cluster0_xky_lo,
  input [9:0] gemB_cluster1_xky_lo,
  input [9:0] gemB_cluster2_xky_lo,
  input [9:0] gemB_cluster3_xky_lo,
  input [9:0] gemB_cluster4_xky_lo,
  input [9:0] gemB_cluster5_xky_lo,
  input [9:0] gemB_cluster6_xky_lo,
  input [9:0] gemB_cluster7_xky_lo,

  input [9:0] gemB_cluster0_xky_hi,
  input [9:0] gemB_cluster1_xky_hi,
  input [9:0] gemB_cluster2_xky_hi,
  input [9:0] gemB_cluster3_xky_hi,
  input [9:0] gemB_cluster4_xky_hi,
  input [9:0] gemB_cluster5_xky_hi,
  input [9:0] gemB_cluster6_xky_hi,
  input [9:0] gemB_cluster7_xky_hi,

  input [9:0] gemB_cluster0_xky_mi,
  input [9:0] gemB_cluster1_xky_mi,
  input [9:0] gemB_cluster2_xky_mi,
  input [9:0] gemB_cluster3_xky_mi,
  input [9:0] gemB_cluster4_xky_mi,
  input [9:0] gemB_cluster5_xky_mi,
  input [9:0] gemB_cluster6_xky_mi,
  input [9:0] gemB_cluster7_xky_mi,

  input [MXCLUSTER_CHAMBER-1:0] copad_match, // copad 
  input [MXCLUSTER_CHAMBER-1:0] copad_A0_B,
  input [MXCLUSTER_CHAMBER-1:0] copad_A1_B,
  input [MXCLUSTER_CHAMBER-1:0] copad_A2_B,
  input [MXCLUSTER_CHAMBER-1:0] copad_A3_B,
  input [MXCLUSTER_CHAMBER-1:0] copad_A4_B,
  input [MXCLUSTER_CHAMBER-1:0] copad_A5_B,
  input [MXCLUSTER_CHAMBER-1:0] copad_A6_B,
  input [MXCLUSTER_CHAMBER-1:0] copad_A7_B,
  //input [9:0] copad_cluster0_xky_mi,
  //input [9:0] copad_cluster1_xky_mi,
  //input [9:0] copad_cluster2_xky_mi,
  //input [9:0] copad_cluster3_xky_mi,
  //input [9:0] copad_cluster4_xky_mi,
  //input [9:0] copad_cluster5_xky_mi,
  //input [9:0] copad_cluster6_xky_mi,
  //input [9:0] copad_cluster7_xky_mi,

  //-------------------------------------------------------------------------------------------------------------------
  //following outputs should have no latency compared to timing match results 
  output       alct_gemA_match_found,
  output       alct_gemB_match_found,
  output       clct_gemA_match_found,
  output       clct_gemB_match_found,
  output       alct_copad_match_found,
  output       clct_copad_match_found,

  //-------------------------------------------------------------------------------------------------------------------
  //following outputs should have 1BX latency compared to timing match results 
  //output [2:0] alct0_clct0_copad_best_icluster,
  //output [9:0] alct0_clct0_copad_best_angle,
  //output [9:0] alct0_clct0_copad_best_cscxky,
  //output [2:0] alct0_clct1_copad_best_icluster,
  //output [9:0] alct0_clct1_copad_best_angle,
  //output [9:0] alct0_clct1_copad_best_cscxky,
  //output [2:0] alct1_clct0_copad_best_icluster,
  //output [9:0] alct1_clct0_copad_best_angle,
  //output [9:0] alct1_clct0_copad_best_cscxky,
  //output [2:0] alct1_clct1_copad_best_icluster,
  //output [9:0] alct1_clct1_copad_best_angle,
  //output [9:0] alct1_clct1_copad_best_cscxky,
  output       alct0_clct0_copad_match_found,
  output       alct1_clct1_copad_match_found,
  output       swapalct_copad_match,
  output       swapclct_copad_match,
  output       alct_clct_copad_nomatch,

  //output [2:0] alct0_clct0_gemA_best_icluster,
  //output [9:0] alct0_clct0_gemA_best_angle,
  //output [9:0] alct0_clct0_gemA_best_cscxky,
  //output [2:0] alct0_clct1_gemA_best_icluster,
  //output [9:0] alct0_clct1_gemA_best_angle,
  //output [9:0] alct0_clct1_gemA_best_cscxky,
  //output [2:0] alct1_clct0_gemA_best_icluster,
  //output [9:0] alct1_clct0_gemA_best_angle,
  //output [9:0] alct1_clct0_gemA_best_cscxky,
  //output [2:0] alct1_clct1_gemA_best_icluster,
  //output [9:0] alct1_clct1_gemA_best_angle,
  //output [9:0] alct1_clct1_gemA_best_cscxky,
  //output [2:0] alct0_clct0_gemB_best_icluster,
  //output [9:0] alct0_clct0_gemB_best_angle,
  //output [9:0] alct0_clct0_gemB_best_cscxky,
  //output [2:0] alct0_clct1_gemB_best_icluster,
  //output [9:0] alct0_clct1_gemB_best_angle,
  //output [9:0] alct0_clct1_gemB_best_cscxky,
  //output [2:0] alct1_clct0_gemB_best_icluster,
  //output [9:0] alct1_clct0_gemB_best_angle,
  //output [9:0] alct1_clct0_gemB_best_cscxky,
  //output [2:0] alct1_clct1_gemB_best_icluster,
  //output [9:0] alct1_clct1_gemB_best_angle,
  //output [9:0] alct1_clct1_gemB_best_cscxky,
  //output       alct0_clct0_bestgem, // 0 for GEMA, 1 for GEMB
  //output       alct0_clct1_bestgem,
  //output       alct1_clct0_bestgem,
  //output       alct1_clct1_bestgem,
  output       alct0_clct0_gem_match_found,
  output       alct1_clct1_gem_match_found,
  output       swapalct_gem_match,
  output       swapclct_gem_match,
  output       alct_clct_gemA_match,
  output       alct_clct_gemB_match,
  output       alct_clct_gem_nomatch,

  output       alct0_clct0_nogem_match_found,
  output       alct1_clct1_nogem_match_found,

  output       clct0_copad_match_found,
  output       clct1_copad_match_found,
  output       swapclct_clctcopad_match,
  output [6:0] alct0wg_fromcopad,
  output [6:0] alct1wg_fromcopad,

  output       alct0_copad_match_found,
  output       alct1_copad_match_found,
  output       swapalct_alctcopad_match,
  output [9:0] clct0xky_fromcopad,
  output [9:0] clct1xky_fromcopad,

  output       alct0_clct0_match_found_final,
  output       alct1_clct1_match_found_final,
  output       swapalct_final,
  output       swapclct_final,
  output       alct0fromcopad,
  output       alct1fromcopad,
  output       clct0fromcopad,
  output       clct1fromcopad,

  output       copyalct0_foralct1,
  output       copyclct0_forclct1,

  output       best_cluster0_ingemB,
  output [2:0] best_cluster0_iclst,
  output       best_cluster0_vpf,
  output [9:0] best_cluster0_angle,
  output       best_cluster1_ingemB,
  output [2:0] best_cluster1_iclst,
  output       best_cluster1_vpf,
  output [9:0] best_cluster1_angle,

  output       alctclctgem_match_sump
  );

  parameter MXCLUSTER_CHAMBER       = 8; // Num GEM clusters  per Chamber
  parameter MXCLUSTER_SUPERCHAMBER  = 16; //Num GEM cluster  per superchamber
  parameter MXBENDANGLEB            = 10; //internal,  10bits for bending angle 

  //low quality stub
  wire alct0_lowQ = alct0_nhit == 3'd3;
  wire alct1_lowQ = alct1_nhit == 3'd3;
  wire clct0_lowQ = clct0_nhit == 3'd3;
  wire clct1_lowQ = clct1_nhit == 3'd3;

  wire  drop_lowqalct0 = alct0_lowQ && match_drop_lowqalct;
  wire  drop_lowqalct1 = alct1_lowQ && match_drop_lowqalct;
  
  wire  drop_lowqclct0 = clct0_lowQ && ((me1a_match_drop_lowqclct && clct0_xky[9]) || (me1b_match_drop_lowqclct && !clct0_xky[9]));
  wire  drop_lowqclct1 = clct1_lowQ && ((me1a_match_drop_lowqclct && clct1_xky[9]) || (me1b_match_drop_lowqclct && !clct1_xky[9]));

  wire  tmb_allow_match_any = (tmb_allow_match || tmb_copad_alct_allow || tmb_copad_clct_allow);

  wire [6:0] gemA_cluster_cscwg_lo[MXCLUSTER_CHAMBER-1:0] = {
      gemA_cluster7_wg_lo,
      gemA_cluster6_wg_lo,
      gemA_cluster5_wg_lo,
      gemA_cluster4_wg_lo,
      gemA_cluster3_wg_lo,
      gemA_cluster2_wg_lo,
      gemA_cluster1_wg_lo,
      gemA_cluster0_wg_lo
      };

  wire [6:0] gemA_cluster_cscwg_hi[MXCLUSTER_CHAMBER-1:0] = {
      gemA_cluster7_wg_hi,
      gemA_cluster6_wg_hi,
      gemA_cluster5_wg_hi,
      gemA_cluster4_wg_hi,
      gemA_cluster3_wg_hi,
      gemA_cluster2_wg_hi,
      gemA_cluster1_wg_hi,
      gemA_cluster0_wg_hi
      };

  wire [9:0] gemA_cluster_cscxky_lo[MXCLUSTER_CHAMBER-1:0] = {
      gemA_cluster7_xky_lo,
      gemA_cluster6_xky_lo,
      gemA_cluster5_xky_lo,
      gemA_cluster4_xky_lo,
      gemA_cluster3_xky_lo,
      gemA_cluster2_xky_lo,
      gemA_cluster1_xky_lo,
      gemA_cluster0_xky_lo
      };

  wire [9:0] gemA_cluster_cscxky_mi[MXCLUSTER_CHAMBER-1:0] = {
      gemA_cluster7_xky_mi,
      gemA_cluster6_xky_mi,
      gemA_cluster5_xky_mi,
      gemA_cluster4_xky_mi,
      gemA_cluster3_xky_mi,
      gemA_cluster2_xky_mi,
      gemA_cluster1_xky_mi,
      gemA_cluster0_xky_mi
      };

  wire [9:0] gemA_cluster_cscxky_hi[MXCLUSTER_CHAMBER-1:0] = {
      gemA_cluster7_xky_hi,
      gemA_cluster6_xky_hi,
      gemA_cluster5_xky_hi,
      gemA_cluster4_xky_hi,
      gemA_cluster3_xky_hi,
      gemA_cluster2_xky_hi,
      gemA_cluster1_xky_hi,
      gemA_cluster0_xky_hi
      };

  wire [6:0] gemB_cluster_cscwg_lo[MXCLUSTER_CHAMBER-1:0] = {
      gemB_cluster7_wg_lo,
      gemB_cluster6_wg_lo,
      gemB_cluster5_wg_lo,
      gemB_cluster4_wg_lo,
      gemB_cluster3_wg_lo,
      gemB_cluster2_wg_lo,
      gemB_cluster1_wg_lo,
      gemB_cluster0_wg_lo
      };

  wire [6:0] gemB_cluster_cscwg_hi[MXCLUSTER_CHAMBER-1:0] = {
      gemB_cluster7_wg_hi,
      gemB_cluster6_wg_hi,
      gemB_cluster5_wg_hi,
      gemB_cluster4_wg_hi,
      gemB_cluster3_wg_hi,
      gemB_cluster2_wg_hi,
      gemB_cluster1_wg_hi,
      gemB_cluster0_wg_hi
      };

  wire [9:0] gemB_cluster_cscxky_lo[MXCLUSTER_CHAMBER-1:0] = {
      gemB_cluster7_xky_lo,
      gemB_cluster6_xky_lo,
      gemB_cluster5_xky_lo,
      gemB_cluster4_xky_lo,
      gemB_cluster3_xky_lo,
      gemB_cluster2_xky_lo,
      gemB_cluster1_xky_lo,
      gemB_cluster0_xky_lo
      };

  wire [9:0] gemB_cluster_cscxky_mi[MXCLUSTER_CHAMBER-1:0] = {
      gemB_cluster7_xky_mi,
      gemB_cluster6_xky_mi,
      gemB_cluster5_xky_mi,
      gemB_cluster4_xky_mi,
      gemB_cluster3_xky_mi,
      gemB_cluster2_xky_mi,
      gemB_cluster1_xky_mi,
      gemB_cluster0_xky_mi
      };

  wire [9:0] gemB_cluster_cscxky_hi[MXCLUSTER_CHAMBER-1:0] = {
      gemB_cluster7_xky_hi,
      gemB_cluster6_xky_hi,
      gemB_cluster5_xky_hi,
      gemB_cluster4_xky_hi,
      gemB_cluster3_xky_hi,
      gemB_cluster2_xky_hi,
      gemB_cluster1_xky_hi,
      gemB_cluster0_xky_hi
      };

  wire [MXCLUSTER_CHAMBER-1:0] copad_A_B [MXCLUSTER_CHAMBER-1:0];
  assign copad_A_B[0] = copad_A0_B;
  assign copad_A_B[1] = copad_A1_B;
  assign copad_A_B[2] = copad_A2_B;
  assign copad_A_B[3] = copad_A3_B;
  assign copad_A_B[4] = copad_A4_B;
  assign copad_A_B[5] = copad_A5_B;
  assign copad_A_B[6] = copad_A6_B;
  assign copad_A_B[7] = copad_A7_B;

  wire [MXCLUSTER_CHAMBER-1:0] copad_matchB_s0;
  assign copad_matchB_s0[0] = copad_A0_B[0] | copad_A1_B[0] | copad_A2_B[0] | copad_A3_B[0] | copad_A4_B[0] | copad_A5_B[0] | copad_A6_B[0] | copad_A7_B[0];
  assign copad_matchB_s0[1] = copad_A0_B[1] | copad_A1_B[1] | copad_A2_B[1] | copad_A3_B[1] | copad_A4_B[1] | copad_A5_B[1] | copad_A6_B[1] | copad_A7_B[1];
  assign copad_matchB_s0[2] = copad_A0_B[2] | copad_A1_B[2] | copad_A2_B[2] | copad_A3_B[2] | copad_A4_B[2] | copad_A5_B[2] | copad_A6_B[2] | copad_A7_B[2];
  assign copad_matchB_s0[3] = copad_A0_B[3] | copad_A1_B[3] | copad_A2_B[3] | copad_A3_B[3] | copad_A4_B[3] | copad_A5_B[3] | copad_A6_B[3] | copad_A7_B[3];
  assign copad_matchB_s0[4] = copad_A0_B[4] | copad_A1_B[4] | copad_A2_B[4] | copad_A3_B[4] | copad_A4_B[4] | copad_A5_B[4] | copad_A6_B[4] | copad_A7_B[4];
  assign copad_matchB_s0[5] = copad_A0_B[5] | copad_A1_B[5] | copad_A2_B[5] | copad_A3_B[5] | copad_A4_B[5] | copad_A5_B[5] | copad_A6_B[5] | copad_A7_B[5];
  assign copad_matchB_s0[6] = copad_A0_B[6] | copad_A1_B[6] | copad_A2_B[6] | copad_A3_B[6] | copad_A4_B[6] | copad_A5_B[6] | copad_A6_B[6] | copad_A7_B[6];
  assign copad_matchB_s0[7] = copad_A0_B[7] | copad_A1_B[7] | copad_A2_B[7] | copad_A3_B[7] | copad_A4_B[7] | copad_A5_B[7] | copad_A6_B[7] | copad_A7_B[7];
  //wire [9:0] copad_cluster_cscxky_mi[MXCLUSTER_CHAMBER-1:0];
  reg [9:0] copad_cluster_cscxky0_mi[MXCLUSTER_CHAMBER-1:0];
  reg [9:0] copad_cluster_cscxky1_mi[MXCLUSTER_CHAMBER-1:0];

  reg [9:0] gemA_cluster_cscxky_mi_r[MXCLUSTER_CHAMBER-1:0];
  reg [9:0] gemB_cluster_cscxky_mi_r[MXCLUSTER_CHAMBER-1:0];

  wire [MXCLUSTER_CHAMBER-1:0] alct0_gemA_match_s0; 
  wire [MXCLUSTER_CHAMBER-1:0] alct1_gemA_match_s0; 
  wire [MXCLUSTER_CHAMBER-1:0] alct0_gemB_match_s0; 
  wire [MXCLUSTER_CHAMBER-1:0] alct1_gemB_match_s0; 

  reg [MXCLUSTER_CHAMBER-1:0] alct0_gemA_match = 0; 
  reg [MXCLUSTER_CHAMBER-1:0] alct1_gemA_match = 0; 
  reg [MXCLUSTER_CHAMBER-1:0] alct0_gemB_match = 0; 
  reg [MXCLUSTER_CHAMBER-1:0] alct1_gemB_match = 0; 

  wire [MXCLUSTER_CHAMBER-1:0] clct0_gemA_match; 
  wire [MXCLUSTER_CHAMBER-1:0] clct1_gemA_match; 
  wire [MXCLUSTER_CHAMBER-1:0] clct0_gemB_match; 
  wire [MXCLUSTER_CHAMBER-1:0] clct1_gemB_match; 

  wire [MXCLUSTER_CHAMBER-1:0] clct0_gemA_match_s0; 
  wire [MXCLUSTER_CHAMBER-1:0] clct1_gemA_match_s0; 
  wire [MXCLUSTER_CHAMBER-1:0] clct0_gemB_match_s0; 
  wire [MXCLUSTER_CHAMBER-1:0] clct1_gemB_match_s0; 

  wire [MXCLUSTER_CHAMBER-1:0] clct0_gemA_match_me1ab; 
  wire [MXCLUSTER_CHAMBER-1:0] clct1_gemA_match_me1ab; 
  wire [MXCLUSTER_CHAMBER-1:0] clct0_gemB_match_me1ab; 
  wire [MXCLUSTER_CHAMBER-1:0] clct1_gemB_match_me1ab; 

  //wire [MXCLUSTER_CHAMBER-1:0] clct0_gemA_match_ok; 
  //wire [MXCLUSTER_CHAMBER-1:0] clct1_gemA_match_ok; 
  //wire [MXCLUSTER_CHAMBER-1:0] clct0_gemB_match_ok; 
  //wire [MXCLUSTER_CHAMBER-1:0] clct1_gemB_match_ok; 
  reg [MXCLUSTER_CHAMBER-1:0] clct0_gemA_match_ok = 0; 
  reg [MXCLUSTER_CHAMBER-1:0] clct1_gemA_match_ok = 0; 
  reg [MXCLUSTER_CHAMBER-1:0] clct0_gemB_match_ok = 0; 
  reg [MXCLUSTER_CHAMBER-1:0] clct1_gemB_match_ok = 0; 

  reg [MXCLUSTER_CHAMBER-1:0] copad_match_r = 0;
  reg [MXCLUSTER_CHAMBER-1:0] alct0_copad_matchB [MXCLUSTER_CHAMBER-1:0]; 
  reg [MXCLUSTER_CHAMBER-1:0] alct1_copad_matchB [MXCLUSTER_CHAMBER-1:0]; 
  reg [MXCLUSTER_CHAMBER-1:0] clct0_copad_matchB [MXCLUSTER_CHAMBER-1:0]; 
  reg [MXCLUSTER_CHAMBER-1:0] clct1_copad_matchB [MXCLUSTER_CHAMBER-1:0]; 

  wire  alct0_copad_matchB_any [MXCLUSTER_CHAMBER-1:0]; 
  wire  alct1_copad_matchB_any [MXCLUSTER_CHAMBER-1:0]; 
  wire  clct0_copad_matchB_any [MXCLUSTER_CHAMBER-1:0]; 
  wire  clct1_copad_matchB_any [MXCLUSTER_CHAMBER-1:0]; 

  wire [MXCLUSTER_CHAMBER-1:0] alct0_copad_match; 
  wire [MXCLUSTER_CHAMBER-1:0] alct1_copad_match; 
  wire [MXCLUSTER_CHAMBER-1:0] clct0_copad_match_ok; 
  wire [MXCLUSTER_CHAMBER-1:0] clct1_copad_match_ok; 

  wire [MXCLUSTER_CHAMBER-1:0] clct0_gemA_ME1a; 
  wire [MXCLUSTER_CHAMBER-1:0] clct0_gemA_ME1b; 
  wire [MXCLUSTER_CHAMBER-1:0] clct0_gemB_ME1a; 
  wire [MXCLUSTER_CHAMBER-1:0] clct0_gemB_ME1b; 
  wire [MXCLUSTER_CHAMBER-1:0] clct1_gemA_ME1a; 
  wire [MXCLUSTER_CHAMBER-1:0] clct1_gemA_ME1b; 
  wire [MXCLUSTER_CHAMBER-1:0] clct1_gemB_ME1a; 
  wire [MXCLUSTER_CHAMBER-1:0] clct1_gemB_ME1b; 
  

  wire [MXCLUSTER_CHAMBER-1:0] alct0_clct0_gemA_match; 
  wire [MXCLUSTER_CHAMBER-1:0] alct0_clct1_gemA_match; 
  wire [MXCLUSTER_CHAMBER-1:0] alct1_clct0_gemA_match; 
  wire [MXCLUSTER_CHAMBER-1:0] alct1_clct1_gemA_match; 
  wire [MXCLUSTER_CHAMBER-1:0] alct0_clct0_gemB_match; 
  wire [MXCLUSTER_CHAMBER-1:0] alct0_clct1_gemB_match; 
  wire [MXCLUSTER_CHAMBER-1:0] alct1_clct0_gemB_match; 
  wire [MXCLUSTER_CHAMBER-1:0] alct1_clct1_gemB_match; 

  wire [MXCLUSTER_CHAMBER-1:0] alct0_clct0_copad_match; 
  wire [MXCLUSTER_CHAMBER-1:0] alct0_clct1_copad_match; 
  wire [MXCLUSTER_CHAMBER-1:0] alct1_clct0_copad_match; 
  wire [MXCLUSTER_CHAMBER-1:0] alct1_clct1_copad_match; 

  wire                     clct0_gemA_bend [MXCLUSTER_CHAMBER-1:0];
  wire                     clct1_gemA_bend [MXCLUSTER_CHAMBER-1:0];
  wire                     clct0_gemB_bend [MXCLUSTER_CHAMBER-1:0];
  wire                     clct1_gemB_bend [MXCLUSTER_CHAMBER-1:0];
  reg  [MXBENDANGLEB-1:0]  clct0_gemA_angle [MXCLUSTER_CHAMBER-1:0];
  reg  [MXBENDANGLEB-1:0]  clct1_gemA_angle [MXCLUSTER_CHAMBER-1:0];
  reg  [MXBENDANGLEB-1:0]  clct0_gemB_angle [MXCLUSTER_CHAMBER-1:0];
  reg  [MXBENDANGLEB-1:0]  clct1_gemB_angle [MXCLUSTER_CHAMBER-1:0];
  wire [MXBENDANGLEB-1:0]  alct0_clct0_gemA_angle [MXCLUSTER_CHAMBER-1:0];
  wire [MXBENDANGLEB-1:0]  alct0_clct1_gemA_angle [MXCLUSTER_CHAMBER-1:0];
  wire [MXBENDANGLEB-1:0]  alct0_clct0_gemB_angle [MXCLUSTER_CHAMBER-1:0];
  wire [MXBENDANGLEB-1:0]  alct0_clct1_gemB_angle [MXCLUSTER_CHAMBER-1:0];
  wire [MXBENDANGLEB-1:0]  alct1_clct0_gemA_angle [MXCLUSTER_CHAMBER-1:0];
  wire [MXBENDANGLEB-1:0]  alct1_clct1_gemA_angle [MXCLUSTER_CHAMBER-1:0];
  wire [MXBENDANGLEB-1:0]  alct1_clct0_gemB_angle [MXCLUSTER_CHAMBER-1:0];
  wire [MXBENDANGLEB-1:0]  alct1_clct1_gemB_angle [MXCLUSTER_CHAMBER-1:0];

  wire [MXBENDANGLEB-1:0]  alct0_clct0_copad_angle [MXCLUSTER_CHAMBER-1:0];
  wire [MXBENDANGLEB-1:0]  alct0_clct1_copad_angle [MXCLUSTER_CHAMBER-1:0];
  wire [MXBENDANGLEB-1:0]  alct1_clct0_copad_angle [MXCLUSTER_CHAMBER-1:0];
  wire [MXBENDANGLEB-1:0]  alct1_clct1_copad_angle [MXCLUSTER_CHAMBER-1:0];

  wire [MXBENDANGLEB-1:0]  clct0_copad_angle [MXCLUSTER_CHAMBER-1:0];
  wire [MXBENDANGLEB-1:0]  clct1_copad_angle [MXCLUSTER_CHAMBER-1:0];
  wire [MXBENDANGLEB-1:0]  alct0_copad_angle [MXCLUSTER_CHAMBER-1:0];
  wire [MXBENDANGLEB-1:0]  alct1_copad_angle [MXCLUSTER_CHAMBER-1:0];

  //  pT           odd,    even;  ME1A     odd,    even
  //  10.0         29.9,   13.7;          22.4,    10.3
  //  15.0         20.1,   9.9;           15.1,    7.4
  parameter ME1BODD      = 10'd30; // ignore the sign check for small bending angle
  parameter ME1BEVEN     = 10'd14; // ignore the sign check for small bending angle
  parameter ME1AODD      = 10'd22; // ignore the sign check for small bending angle
  parameter ME1AEVEN     = 10'd10; // ignore the sign check for small bending angle
  parameter MAXGEMCSCBND = 10'd1023;// invalid bending 
  wire [9:0] bending_min_me1a = evenchamber ? ME1AEVEN : ME1AODD;
  wire [9:0] bending_min_me1b = evenchamber ? ME1BEVEN : ME1BODD;
  wire clct0_bend = clct0_bnd[4];// bending direction, left or right 
  wire clct1_bend = clct1_bnd[4];// bending direction, left or right 

  wire [7:0] clct0_gemA_offset;
  wire [7:0] clct0_gemB_offset;
  wire [7:0] clct1_gemA_offset;
  wire [7:0] clct1_gemB_offset;
 clct_gem_offset_slope uclctoffset(
    .clock            (clock), 
    .clct0_bend       (clct0_bnd[3:0]), //clct0 bending, abs value
    .clct1_bend       (clct1_bnd[3:0]), //clct1 bending, abs value
    .isME1a0          (clct0_xky[9]),  // Me1a or not, isME1a0=1 means clct0 in ME1a
    .isME1a1          (clct1_xky[9]),  //Me1a or not, isME1a1=1 means clct1 in ME1a 
    .even             (evenchamber),   //even chamber pair not, even=1 means even chamber pair 
    .clct0_gemA_offset(clct0_gemA_offset), // output, offset for clct0-gemA strip position match
    .clct0_gemB_offset(clct0_gemB_offset),//output, offset for clct0-gemB strip position match
    .clct1_gemA_offset(clct1_gemA_offset),//output, offset for clct1-gemA strip position match
    .clct1_gemB_offset(clct1_gemB_offset)  // output, offset for clct1-gemB strip position match
  );

  //cross the edge is not real issue as the match code is checking whether gem and csc both me1a or me1b. so we ignore it
  wire [9:0] clct0_gemA_xky_slopecorr = clct0_bend ? (clct0_xky-clct0_gemA_offset) : (clct0_xky+clct0_gemA_offset);
  wire [9:0] clct0_gemB_xky_slopecorr = clct0_bend ? (clct0_xky-clct0_gemB_offset) : (clct0_xky+clct0_gemB_offset);
  wire [9:0] clct1_gemA_xky_slopecorr = clct1_bend ? (clct1_xky-clct1_gemA_offset) : (clct1_xky+clct1_gemA_offset);
  wire [9:0] clct1_gemB_xky_slopecorr = clct1_bend ? (clct1_xky-clct1_gemB_offset) : (clct1_xky+clct1_gemB_offset);

  genvar i;
  genvar k;
  generate
  for (i=0; i<MXCLUSTER_CHAMBER; i=i+1) begin: gem_csc_match
       //ME1a with CFEB 4, 5,6 while ME1b with CFEB 0, 1,2,3
      //assign clct0_gemA_ME1a[i]   = clct0_xky[9]  && gemA_cluster_cscxky_mi[i][9]  && gem_me1a_match_enable;
      //assign clct0_gemB_ME1a[i]   = clct0_xky[9]  && gemB_cluster_cscxky_mi[i][9]  && gem_me1a_match_enable;
      //assign clct1_gemA_ME1a[i]   = clct0_xky[9]  && gemA_cluster_cscxky_mi[i][9]  && gem_me1a_match_enable;
      //assign clct1_gemB_ME1a[i]   = clct0_xky[9]  && gemB_cluster_cscxky_mi[i][9]  && gem_me1a_match_enable;
      //assign clct0_gemA_ME1b[i]   = !clct0_xky[9] && !gemA_cluster_cscxky_mi[i][9] && gem_me1b_match_enable;
      //assign clct0_gemB_ME1b[i]   = !clct0_xky[9] && !gemB_cluster_cscxky_mi[i][9] && gem_me1b_match_enable;
      //assign clct1_gemA_ME1b[i]   = !clct0_xky[9] && !gemA_cluster_cscxky_mi[i][9] && gem_me1b_match_enable;
      //assign clct1_gemB_ME1b[i]   = !clct0_xky[9] && !gemB_cluster_cscxky_mi[i][9] && gem_me1b_match_enable;

      assign clct0_gemA_match_me1ab[i] = clct0_xky[9]  == gemA_cluster_cscxky_mi[i][9]; 
      assign clct0_gemB_match_me1ab[i] = clct0_xky[9]  == gemB_cluster_cscxky_mi[i][9]; 
      assign clct1_gemA_match_me1ab[i] = clct1_xky[9]  == gemA_cluster_cscxky_mi[i][9]; 
      assign clct1_gemB_match_me1ab[i] = clct1_xky[9]  == gemB_cluster_cscxky_mi[i][9]; 

      assign clct0_gemA_bend[i]   = clct0_xky > gemA_cluster_cscxky_mi[i]; //bending direction means clct_xky > gem_xky
      assign clct0_gemB_bend[i]   = clct0_xky > gemB_cluster_cscxky_mi[i];
      assign clct1_gemA_bend[i]   = clct1_xky > gemA_cluster_cscxky_mi[i];
      assign clct1_gemB_bend[i]   = clct1_xky > gemB_cluster_cscxky_mi[i];

      //assign clct0_gemA_match[i] = clct0_vpf && gemA_vpf[i] && (gemA_match_ignore_position || (clct0_xky >= gemA_cluster_cscxky_lo[i] && clct0_xky <= gemA_cluster_cscxky_hi[i])) &&  clct0_gemA_match_me1ab[i]; 
      //assign clct1_gemA_match[i] = clct1_vpf && gemA_vpf[i] && (gemA_match_ignore_position || (clct1_xky >= gemA_cluster_cscxky_lo[i] && clct1_xky <= gemA_cluster_cscxky_hi[i])) &&  clct1_gemA_match_me1ab[i]; 
      //assign clct0_gemB_match[i] = clct0_vpf && gemB_vpf[i] && (gemB_match_ignore_position || (clct0_xky >= gemB_cluster_cscxky_lo[i] && clct0_xky <= gemB_cluster_cscxky_hi[i])) &&  clct0_gemB_match_me1ab[i]; 
      //assign clct1_gemB_match[i] = clct1_vpf && gemB_vpf[i] && (gemB_match_ignore_position || (clct1_xky >= gemB_cluster_cscxky_lo[i] && clct1_xky <= gemB_cluster_cscxky_hi[i])) &&  clct1_gemB_match_me1ab[i]; 
      //with bending direction check
      //assign clct0_gemA_match_s0[i] = clct0_gemA_match[i] && (gemcsc_ignore_bend_check || (clct0_xky[9] && bending_min_me1a >= clct0_gemA_angle[i]) || (!clct0_xky[9] && bending_min_me1b >= clct0_gemA_angle[i]) || (clct0_gemA_bend[i] == clct0_bend));
      //assign clct0_gemB_match_s0[i] = clct0_gemB_match[i] && (gemcsc_ignore_bend_check || (clct0_xky[9] && bending_min_me1a >= clct0_gemB_angle[i]) || (!clct0_xky[9] && bending_min_me1b >= clct0_gemB_angle[i]) || (clct0_gemB_bend[i] == clct0_bend));
      //assign clct1_gemA_match_s0[i] = clct1_gemA_match[i] && (gemcsc_ignore_bend_check || (clct1_xky[9] && bending_min_me1a >= clct1_gemA_angle[i]) || (!clct1_xky[9] && bending_min_me1b >= clct1_gemA_angle[i]) || (clct1_gemA_bend[i] == clct1_bend));
      //assign clct1_gemB_match_s0[i] = clct1_gemB_match[i] && (gemcsc_ignore_bend_check || (clct1_xky[9] && bending_min_me1a >= clct1_gemB_angle[i]) || (!clct1_xky[9] && bending_min_me1b >= clct1_gemB_angle[i]) || (clct1_gemB_bend[i] == clct1_bend));

      //adding CSC xky correction from CSC slope
      assign clct0_gemA_match[i] = clct0_vpf && gemA_vpf[i] && (gemA_match_ignore_position || (clct0_gemA_xky_slopecorr >= gemA_cluster_cscxky_lo[i] && clct0_gemA_xky_slopecorr <= gemA_cluster_cscxky_hi[i])) &&  clct0_gemA_match_me1ab[i]; 
      assign clct1_gemA_match[i] = clct1_vpf && gemA_vpf[i] && (gemA_match_ignore_position || (clct1_gemB_xky_slopecorr >= gemA_cluster_cscxky_lo[i] && clct1_gemB_xky_slopecorr <= gemA_cluster_cscxky_hi[i])) &&  clct1_gemA_match_me1ab[i]; 
      assign clct0_gemB_match[i] = clct0_vpf && gemB_vpf[i] && (gemB_match_ignore_position || (clct0_gemA_xky_slopecorr >= gemB_cluster_cscxky_lo[i] && clct0_gemA_xky_slopecorr <= gemB_cluster_cscxky_hi[i])) &&  clct0_gemB_match_me1ab[i]; 
      assign clct1_gemB_match[i] = clct1_vpf && gemB_vpf[i] && (gemB_match_ignore_position || (clct1_gemB_xky_slopecorr >= gemB_cluster_cscxky_lo[i] && clct1_gemB_xky_slopecorr <= gemB_cluster_cscxky_hi[i])) &&  clct1_gemB_match_me1ab[i]; 
      
      //with CSC xky correction from CSC slope, the bending direction check could be ignore. 
      assign clct0_gemA_match_s0[i] = clct0_gemA_match[i];
      assign clct0_gemB_match_s0[i] = clct0_gemB_match[i];
      assign clct1_gemA_match_s0[i] = clct1_gemA_match[i];
      assign clct1_gemB_match_s0[i] = clct1_gemB_match[i];

      assign alct0_gemA_match_s0[i] = alct0_vpf && gemA_vpf[i] && (gemA_match_ignore_position || (alct0_wg  >= gemA_cluster_cscwg_lo[i]  && alct0_wg  <= gemA_cluster_cscwg_hi[i] )); 
      assign alct1_gemA_match_s0[i] = alct1_vpf && gemA_vpf[i] && (gemA_match_ignore_position || (alct1_wg  >= gemA_cluster_cscwg_lo[i]  && alct1_wg  <= gemA_cluster_cscwg_hi[i] )); 
      assign alct0_gemB_match_s0[i] = alct0_vpf && gemB_vpf[i] && (gemB_match_ignore_position || (alct0_wg  >= gemB_cluster_cscwg_lo[i]  && alct0_wg  <= gemB_cluster_cscwg_hi[i] )); 
      assign alct1_gemB_match_s0[i] = alct1_vpf && gemB_vpf[i] && (gemB_match_ignore_position || (alct1_wg  >= gemB_cluster_cscwg_lo[i]  && alct1_wg  <= gemB_cluster_cscwg_hi[i] )); 

      always @ (posedge clock) begin
           alct0_gemA_match[i]    <= alct0_gemA_match_s0[i];
           alct1_gemA_match[i]    <= alct1_gemA_match_s0[i];
           alct0_gemB_match[i]    <= alct0_gemB_match_s0[i];
           alct1_gemB_match[i]    <= alct1_gemB_match_s0[i];
           clct0_gemA_match_ok[i] <= clct0_gemA_match_s0[i];
           clct1_gemA_match_ok[i] <= clct1_gemA_match_s0[i];
           clct0_gemB_match_ok[i] <= clct0_gemB_match_s0[i];
           clct1_gemB_match_ok[i] <= clct1_gemB_match_s0[i];
           //alct0_gemA_match[i] <= alct0_vpf && gemA_vpf[i] && (gemA_match_ignore_position || (alct0_wg  >= gemA_cluster_cscwg_lo[i]  && alct0_wg  <= gemA_cluster_cscwg_hi[i] )); 
           //alct1_gemA_match[i] <= alct1_vpf && gemA_vpf[i] && (gemA_match_ignore_position || (alct1_wg  >= gemA_cluster_cscwg_lo[i]  && alct1_wg  <= gemA_cluster_cscwg_hi[i] )); 
           //alct0_gemB_match[i] <= alct0_vpf && gemB_vpf[i] && (gemB_match_ignore_position || (alct0_wg  >= gemB_cluster_cscwg_lo[i]  && alct0_wg  <= gemB_cluster_cscwg_hi[i] )); 
           //alct1_gemB_match[i] <= alct1_vpf && gemB_vpf[i] && (gemB_match_ignore_position || (alct1_wg  >= gemB_cluster_cscwg_lo[i]  && alct1_wg  <= gemB_cluster_cscwg_hi[i] )); 
           //clct0_gemA_match_ok[i] <= clct0_gemA_match[i] && (gemcsc_ignore_bend_check || (clct0_xky[9] && bending_min_me1a >= clct0_gemA_angle[i]) || (!clct0_xky[9] && bending_min_me1b >= clct0_gemA_angle[i]) || (clct0_gemA_bend[i] == clct0_bend));
           //clct0_gemB_match_ok[i] <= clct0_gemB_match[i] && (gemcsc_ignore_bend_check || (clct0_xky[9] && bending_min_me1a >= clct0_gemB_angle[i]) || (!clct0_xky[9] && bending_min_me1b >= clct0_gemB_angle[i]) || (clct0_gemB_bend[i] == clct0_bend));
           //clct1_gemA_match_ok[i] <= clct1_gemA_match[i] && (gemcsc_ignore_bend_check || (clct1_xky[9] && bending_min_me1a >= clct1_gemA_angle[i]) || (!clct1_xky[9] && bending_min_me1b >= clct1_gemA_angle[i]) || (clct1_gemA_bend[i] == clct1_bend));
           //clct1_gemB_match_ok[i] <= clct1_gemB_match[i] && (gemcsc_ignore_bend_check || (clct1_xky[9] && bending_min_me1a >= clct1_gemB_angle[i]) || (!clct1_xky[9] && bending_min_me1b >= clct1_gemB_angle[i]) || (clct1_gemB_bend[i] == clct1_bend));
           clct0_gemA_angle[i] <= clct0_gemA_match[i] ? (clct0_gemA_bend[i] ? (clct0_xky-gemA_cluster_cscxky_mi[i]) : (gemA_cluster_cscxky_mi[i]-clct0_xky)) : MAXGEMCSCBND; 
           clct0_gemB_angle[i] <= clct0_gemB_match[i] ? (clct0_gemB_bend[i] ? (clct0_xky-gemB_cluster_cscxky_mi[i]) : (gemB_cluster_cscxky_mi[i]-clct0_xky)) : MAXGEMCSCBND; 
           clct1_gemA_angle[i] <= clct1_gemA_match[i] ? (clct1_gemA_bend[i] ? (clct1_xky-gemA_cluster_cscxky_mi[i]) : (gemA_cluster_cscxky_mi[i]-clct1_xky)) : MAXGEMCSCBND; 
           clct1_gemB_angle[i] <= clct1_gemB_match[i] ? (clct1_gemB_bend[i] ? (clct1_xky-gemB_cluster_cscxky_mi[i]) : (gemB_cluster_cscxky_mi[i]-clct1_xky)) : MAXGEMCSCBND; 
           
           copad_match_r[i]    <= copad_match[i];

           copad_cluster_cscxky0_mi[i] <= (copad_match[i] && alct0_gemA_match_s0[i])  ? gemA_cluster_cscxky_mi[i] : gemB_cluster_cscxky_mi[i]; 
           copad_cluster_cscxky1_mi[i] <= (copad_match[i] && alct1_gemA_match_s0[i])  ? gemA_cluster_cscxky_mi[i] : gemB_cluster_cscxky_mi[i]; 
           gemA_cluster_cscxky_mi_r[i] <= gemA_cluster_cscxky_mi[i];
           gemB_cluster_cscxky_mi_r[i] <= gemB_cluster_cscxky_mi[i];
 
      end
      //it is possible that for copad pair, CLCT/ALCt only match with gemB cluster not gemA cluster
      //to avoid duplicate copad+ALCT/CLCT match, only with either gemA_cluster[i]+copad_A_B[i][k] or gemB_cluster[i]+coapd_A_B[..][i]+!gemA_cluster[k]
      //the first part gemA-ALCT/CLCT match is found and copad is valid for this gemA cluster, handle by i(copad_match[i] && alct0_gemA_match)
      //the second part gemB-ALCT/CLCT match is found and copad is valid for this gemB clsuter, And no gemA-ALCT/CLCT, handled by alct0_copad_matchB[i][k]
      for (k=0; k<MXCLUSTER_CHAMBER; k=k+1) begin: gem_csc_matchAB
          always @ (posedge clock) begin
           alct0_copad_matchB[i][k] = (copad_A_B[k][i] && alct0_gemB_match_s0[i] && !alct0_gemA_match_s0[k]);
           alct1_copad_matchB[i][k] = (copad_A_B[k][i] && alct1_gemB_match_s0[i] && !alct1_gemA_match_s0[k]);
           clct0_copad_matchB[i][k] = (copad_A_B[k][i] && clct0_gemB_match_s0[i] && !clct0_gemA_match_s0[k]);
           clct1_copad_matchB[i][k] = (copad_A_B[k][i] && clct1_gemB_match_s0[i] && !clct1_gemA_match_s0[k]);
          //alct0_copad_matchB[i][k] <= copad_A_B[k][i] && !(alct0_vpf && gemA_vpf[k] && (gemA_match_ignore_position || (alct0_wg  >= gemA_cluster_cscwg_lo[k]  && alct0_wg  <= gemA_cluster_cscwg_hi[k] )));
          //alct1_copad_matchB[i][k] <= copad_A_B[k][i] && !(alct1_vpf && gemA_vpf[k] && (gemA_match_ignore_position || (alct1_wg  >= gemA_cluster_cscwg_lo[k]  && alct1_wg  <= gemA_cluster_cscwg_hi[k] )));
          //clct0_copad_matchB[i][k] <= copad_A_B[k][i] && !(clct0_gemA_match[k] && (gemcsc_ignore_bend_check || (clct0_xky[9] && bending_min_me1a >= clct0_gemA_angle[k]) || (!clct0_xky[9] && bending_min_me1b >= clct0_gemA_angle[k]) || (clct0_gemA_bend[k] == clct0_bend)));
          //clct1_copad_matchB[i][k] <= copad_A_B[k][i] && !(clct1_gemA_match[k] && (gemcsc_ignore_bend_check || (clct1_xky[9] && bending_min_me1a >= clct1_gemA_angle[k]) || (!clct1_xky[9] && bending_min_me1b >= clct1_gemA_angle[k]) || (clct1_gemA_bend[k] == clct1_bend)));
	  end
      end 

      assign alct0_copad_matchB_any[i] = |alct0_copad_matchB[i][MXCLUSTER_CHAMBER-1:0];
      assign alct1_copad_matchB_any[i] = |alct1_copad_matchB[i][MXCLUSTER_CHAMBER-1:0];
      assign clct0_copad_matchB_any[i] = |clct0_copad_matchB[i][MXCLUSTER_CHAMBER-1:0];
      assign clct1_copad_matchB_any[i] = |clct1_copad_matchB[i][MXCLUSTER_CHAMBER-1:0];

       //equivalent to  (copad_match[i] && alct0_gemA_match ) || (copad_A_B[0][i] && alct0_gemB_match   [i] && !alct0_gemA_match   [0]) || (copad_A_B[1][i] && alct0_gemB_match   [i] && !alct0_gemA_match   [1]) || ...
      assign alct0_copad_match[i]    = (copad_match_r[i] && alct0_gemA_match   [i]) || (alct0_gemB_match   [i] && (|alct0_copad_matchB[i][MXCLUSTER_CHAMBER-1:0]));
      assign alct1_copad_match[i]    = (copad_match_r[i] && alct1_gemA_match   [i]) || (alct1_gemB_match   [i] && (|alct1_copad_matchB[i][MXCLUSTER_CHAMBER-1:0]));
      assign clct0_copad_match_ok[i] = (copad_match_r[i] && clct0_gemA_match_ok[i]) || (clct0_gemB_match_ok[i] && (|clct0_copad_matchB[i][MXCLUSTER_CHAMBER-1:0]));
      assign clct1_copad_match_ok[i] = (copad_match_r[i] && clct1_gemA_match_ok[i]) || (clct1_gemB_match_ok[i] && (|clct1_copad_matchB[i][MXCLUSTER_CHAMBER-1:0]));

      assign clct0_copad_angle[i] = clct0_copad_match_ok[i] ? ((copad_match_r[i] && clct0_gemA_match_ok[i]) ? clct0_gemA_angle[i] : clct0_gemB_angle[i]) : MAXGEMCSCBND;
      assign clct1_copad_angle[i] = clct1_copad_match_ok[i] ? ((copad_match_r[i] && clct1_gemA_match_ok[i]) ? clct1_gemA_angle[i] : clct1_gemB_angle[i]) : MAXGEMCSCBND;
       
      assign alct0_copad_angle[i] = alct0_copad_match[i] ? 10'b0 : MAXGEMCSCBND;
      assign alct1_copad_angle[i] = alct1_copad_match[i] ? 10'b0 : MAXGEMCSCBND;

      assign alct0_clct0_gemA_match[i] = (alct0_gemA_match[i] && clct0_gemA_match_ok[i]);
      assign alct0_clct1_gemA_match[i] = (alct0_gemA_match[i] && clct1_gemA_match_ok[i]);
      assign alct1_clct0_gemA_match[i] = (alct1_gemA_match[i] && clct0_gemA_match_ok[i]);
      assign alct1_clct1_gemA_match[i] = (alct1_gemA_match[i] && clct1_gemA_match_ok[i]);
      assign alct0_clct0_gemB_match[i] = (alct0_gemB_match[i] && clct0_gemB_match_ok[i]);
      assign alct0_clct1_gemB_match[i] = (alct0_gemB_match[i] && clct1_gemB_match_ok[i]);
      assign alct1_clct0_gemB_match[i] = (alct1_gemB_match[i] && clct0_gemB_match_ok[i]);
      assign alct1_clct1_gemB_match[i] = (alct1_gemB_match[i] && clct1_gemB_match_ok[i]);

      assign alct0_clct0_gemA_angle[i] = alct0_clct0_gemA_match[i] ? clct0_gemA_angle[i] : MAXGEMCSCBND; 
      assign alct0_clct0_gemB_angle[i] = alct0_clct0_gemB_match[i] ? clct0_gemB_angle[i] : MAXGEMCSCBND; 
      assign alct0_clct1_gemA_angle[i] = alct0_clct1_gemA_match[i] ? clct1_gemA_angle[i] : MAXGEMCSCBND; 
      assign alct0_clct1_gemB_angle[i] = alct0_clct1_gemB_match[i] ? clct1_gemB_angle[i] : MAXGEMCSCBND; 
      assign alct1_clct0_gemA_angle[i] = alct1_clct0_gemA_match[i] ? clct0_gemA_angle[i] : MAXGEMCSCBND; 
      assign alct1_clct0_gemB_angle[i] = alct1_clct0_gemB_match[i] ? clct0_gemB_angle[i] : MAXGEMCSCBND; 
      assign alct1_clct1_gemA_angle[i] = alct1_clct1_gemA_match[i] ? clct1_gemA_angle[i] : MAXGEMCSCBND; 
      assign alct1_clct1_gemB_angle[i] = alct1_clct1_gemB_match[i] ? clct1_gemB_angle[i] : MAXGEMCSCBND; 

      assign alct0_clct0_copad_match[i] = (copad_match_r[i] &&alct0_gemA_match[i] && clct0_gemA_match_ok[i]) || (alct0_gemB_match[i] && clct0_gemB_match_ok[i] && (|alct0_copad_matchB[i][MXCLUSTER_CHAMBER-1:0]));;
      assign alct0_clct1_copad_match[i] = (copad_match_r[i] &&alct0_gemA_match[i] && clct1_gemA_match_ok[i]) || (alct0_gemB_match[i] && clct1_gemB_match_ok[i] && (|alct0_copad_matchB[i][MXCLUSTER_CHAMBER-1:0]));;
      assign alct1_clct0_copad_match[i] = (copad_match_r[i] &&alct1_gemA_match[i] && clct0_gemA_match_ok[i]) || (alct1_gemB_match[i] && clct0_gemB_match_ok[i] && (|alct1_copad_matchB[i][MXCLUSTER_CHAMBER-1:0]));;
      assign alct1_clct1_copad_match[i] = (copad_match_r[i] &&alct1_gemA_match[i] && clct1_gemA_match_ok[i]) || (alct1_gemB_match[i] && clct1_gemB_match_ok[i] && (|alct1_copad_matchB[i][MXCLUSTER_CHAMBER-1:0]));;

      assign alct0_clct0_copad_angle[i] = alct0_clct0_copad_match[i] ? ((copad_match_r[i]&& clct0_gemA_match_ok[i]) ? clct0_gemA_angle[i] : clct0_gemB_angle[i]) : MAXGEMCSCBND;
      assign alct0_clct1_copad_angle[i] = alct0_clct1_copad_match[i] ? ((copad_match_r[i]&& clct1_gemA_match_ok[i]) ? clct1_gemA_angle[i] : clct1_gemB_angle[i]) : MAXGEMCSCBND;
      assign alct1_clct0_copad_angle[i] = alct1_clct0_copad_match[i] ? ((copad_match_r[i]&& clct0_gemA_match_ok[i]) ? clct0_gemA_angle[i] : clct0_gemB_angle[i]) : MAXGEMCSCBND;
      assign alct1_clct1_copad_angle[i] = alct1_clct1_copad_match[i] ? ((copad_match_r[i]&& clct1_gemA_match_ok[i]) ? clct1_gemA_angle[i] : clct1_gemB_angle[i]) : MAXGEMCSCBND;

    end
  endgenerate 

  //-------------------------------------------------------------------------------------------------------------------
  //step0 match results : ALCT-GEM, CLCT-GEM, ALCT_copad, CLCT_copad
  //algin with timing match results
  //-------------------------------------------------------------------------------------------------------------------
  
  wire [MXCLUSTER_CHAMBER-1:0] alct0_copad_match_s0;
  wire [MXCLUSTER_CHAMBER-1:0] alct1_copad_match_s0;
  wire [MXCLUSTER_CHAMBER-1:0] clct0_copad_match_s0;
  wire [MXCLUSTER_CHAMBER-1:0] clct1_copad_match_s0;
  //either alct0+gemA+gemA_is_copad or alct0+gemB+gemB_is_copad
  assign alct0_copad_match_s0 = (alct0_gemA_match_s0 & copad_match) | (alct0_gemB_match_s0 & copad_matchB_s0);
  assign alct1_copad_match_s0 = (alct1_gemA_match_s0 & copad_match) | (alct1_gemB_match_s0 & copad_matchB_s0);
  assign clct0_copad_match_s0 = (clct0_gemA_match_s0 & copad_match) | (clct0_gemB_match_s0 & copad_matchB_s0);
  assign clct1_copad_match_s0 = (clct1_gemA_match_s0 & copad_match) | (clct1_gemB_match_s0 & copad_matchB_s0);
  assign alct_gemA_match_found  = (|alct0_gemA_match_s0 ) || (|alct1_gemA_match_s0 );
  assign alct_gemB_match_found  = (|alct0_gemB_match_s0 ) || (|alct1_gemB_match_s0 );
  assign clct_gemA_match_found  = (|clct0_gemA_match_s0 ) || (|clct1_gemA_match_s0 );
  assign clct_gemB_match_found  = (|clct0_gemB_match_s0 ) || (|clct1_gemB_match_s0 );
  assign alct_copad_match_found = (|alct0_copad_match_s0) || (|alct1_copad_match_s0);
  assign clct_copad_match_found = (|clct0_copad_match_s0) || (|clct1_copad_match_s0);

  //-------------------------------------------------------------------------------------------------------------------
  // step1  ALCT+CLCT+Copad matching
  //ALCT-CLCT+GEM Copad match, very challenging part!, lot of combinations!
  //-------------------------------------------------------------------------------------------------------------------

  wire [2:0] alct0_clct0_copad_best_icluster;
  wire [MXBENDANGLEB-1:0] alct0_clct0_copad_best_angle;
  tree_encoder_alctclctgem_TR ualct0_clct0_copad_match(
      //clock,
      alct0_clct0_copad_angle[0],
      alct0_clct0_copad_angle[1],
      alct0_clct0_copad_angle[2],
      alct0_clct0_copad_angle[3],
      alct0_clct0_copad_angle[4],
      alct0_clct0_copad_angle[5],
      alct0_clct0_copad_angle[6],
      alct0_clct0_copad_angle[7],

      alct0_clct0_copad_best_angle,
      alct0_clct0_copad_best_icluster
      );

  wire [2:0] alct0_clct1_copad_best_icluster;
  wire [MXBENDANGLEB-1:0] alct0_clct1_copad_best_angle;
  tree_encoder_alctclctgem_TR ualct0_clct1_copad_match(
      //clock,
      alct0_clct1_copad_angle[0],
      alct0_clct1_copad_angle[1],
      alct0_clct1_copad_angle[2],
      alct0_clct1_copad_angle[3],
      alct0_clct1_copad_angle[4],
      alct0_clct1_copad_angle[5],
      alct0_clct1_copad_angle[6],
      alct0_clct1_copad_angle[7],

      alct0_clct1_copad_best_angle,
      alct0_clct1_copad_best_icluster
      );

  wire [2:0] alct1_clct0_copad_best_icluster;
  wire [MXBENDANGLEB-1:0] alct1_clct0_copad_best_angle;
  tree_encoder_alctclctgem_TR ualct1_clct0_copad_match(
      //clock,
      alct1_clct0_copad_angle[0],
      alct1_clct0_copad_angle[1],
      alct1_clct0_copad_angle[2],
      alct1_clct0_copad_angle[3],
      alct1_clct0_copad_angle[4],
      alct1_clct0_copad_angle[5],
      alct1_clct0_copad_angle[6],
      alct1_clct0_copad_angle[7],

      alct1_clct0_copad_best_angle,
      alct1_clct0_copad_best_icluster
      );

  wire [2:0] alct1_clct1_copad_best_icluster;
  wire [MXBENDANGLEB-1:0] alct1_clct1_copad_best_angle;
  tree_encoder_alctclctgem_TR ualct1_clct1_copad_match(
      //clock,
      alct1_clct1_copad_angle[0],
      alct1_clct1_copad_angle[1],
      alct1_clct1_copad_angle[2],
      alct1_clct1_copad_angle[3],
      alct1_clct1_copad_angle[4],
      alct1_clct1_copad_angle[5],
      alct1_clct1_copad_angle[6],
      alct1_clct1_copad_angle[7],

      alct1_clct1_copad_best_angle,
      alct1_clct1_copad_best_icluster
      );


  wire alct0_clct0_copad_match_any = ( |alct0_clct0_copad_match ) && tmb_allow_match_any;
  wire alct0_clct1_copad_match_any = ( |alct0_clct1_copad_match ) && tmb_allow_match_any;
  wire alct1_clct0_copad_match_any = ( |alct1_clct0_copad_match ) && tmb_allow_match_any;
  wire alct1_clct1_copad_match_any = ( |alct1_clct1_copad_match ) && tmb_allow_match_any;

  //include 1.alct0=clct0-copad, alct1-clct1-copad
  //2. alct0=clct1-copad, alct1-clct0-copad
  // alct0 is not copied to alct1 yet if alct0 is valid while alct1 is invalid
  //EMTF decouples LCT anyway and OTMB usually tries to send out different ALCT-CLCT combinations 
  assign alct0_clct0_copad_match_found = alct0_clct0_copad_match_any || alct0_clct1_copad_match_any || alct1_clct0_copad_match_any || alct1_clct1_copad_match_any;
  reg alct1_clct1_copad_match_found_r = 1'b0;
  reg swapclct_copad_match_r = 1'b0;
  reg swapalct_copad_match_r = 1'b0;

  reg cluster0layer_alct_clct_copad_r = 1'b0;
  reg cluster1layer_alct_clct_copad_r = 1'b0;
  reg [2:0] best_cluster0_alct_clct_copad_r = 3'b0;
  reg [2:0] best_cluster1_alct_clct_copad_r = 3'b0;
  reg [MXBENDANGLEB-1:0] best_angle0_alct_clct_copad_r = 10'b0;
  reg [MXBENDANGLEB-1:0] best_angle1_alct_clct_copad_r = 10'b0;
  //reg [2:0] alct_clct_copad_match_type = 3'b111;
  always @(*) begin
      //ALCT0+CLCT0+copad match found
      if (alct0_clct0_copad_match_any && alct0_clct0_copad_best_angle < alct0_clct1_copad_best_angle && alct0_clct0_copad_best_angle < alct1_clct1_copad_best_angle)
      begin
          alct1_clct1_copad_match_found_r <= alct1_clct1_copad_match_any;
          swapclct_copad_match_r          <= 1'b0;
          swapalct_copad_match_r          <= 1'b0;
          best_cluster0_alct_clct_copad_r <= alct0_clct0_copad_best_icluster;
          best_cluster1_alct_clct_copad_r <= alct1_clct1_copad_best_icluster;
          best_angle0_alct_clct_copad_r   <= alct0_clct0_copad_best_angle;
          best_angle1_alct_clct_copad_r   <= alct1_clct1_copad_best_angle;
          cluster0layer_alct_clct_copad_r <= alct0_copad_matchB_any[alct0_clct0_copad_best_icluster];
          cluster1layer_alct_clct_copad_r <= alct1_copad_matchB_any[alct1_clct1_copad_best_icluster];
      end
      //ALCT0+CLCT1+copad match found
      else if (alct0_clct1_copad_match_any && alct0_clct1_copad_best_angle < alct1_clct0_copad_best_angle && alct0_clct1_copad_best_angle < alct0_clct0_copad_best_angle)
      begin
          alct1_clct1_copad_match_found_r <= alct1_clct0_copad_match_any;
          swapclct_copad_match_r          <= 1'b1;
          swapalct_copad_match_r          <= 1'b0;
          best_cluster0_alct_clct_copad_r <= alct0_clct1_copad_best_icluster;
          best_cluster1_alct_clct_copad_r <= alct1_clct0_copad_best_icluster;
          best_angle0_alct_clct_copad_r   <= alct0_clct1_copad_best_angle;
          best_angle1_alct_clct_copad_r   <= alct1_clct0_copad_best_angle;
          cluster0layer_alct_clct_copad_r <= alct0_copad_matchB_any[alct0_clct1_copad_best_icluster];
          cluster1layer_alct_clct_copad_r <= alct1_copad_matchB_any[alct1_clct0_copad_best_icluster];
      end
      //ALCT1+CLCT0+copad match found
      else if (alct1_clct0_copad_match_any && alct1_clct0_copad_best_angle < alct1_clct1_copad_best_angle)
      begin
          alct1_clct1_copad_match_found_r <= alct0_clct1_copad_match_any;
          swapclct_copad_match_r          <= 1'b0;
          swapalct_copad_match_r          <= 1'b1;
          best_cluster0_alct_clct_copad_r <= alct1_clct0_copad_best_icluster;
          best_cluster1_alct_clct_copad_r <= alct0_clct1_copad_best_icluster;
          best_angle0_alct_clct_copad_r   <= alct1_clct0_copad_best_angle;
          best_angle1_alct_clct_copad_r   <= alct0_clct1_copad_best_angle;
          cluster0layer_alct_clct_copad_r <= alct1_copad_matchB_any[alct1_clct0_copad_best_icluster];
          cluster1layer_alct_clct_copad_r <= alct0_copad_matchB_any[alct0_clct1_copad_best_icluster];
      end
      else if (alct1_clct1_copad_match_any)// alct1_clct1_copad has minimum bending angle or no match
      begin
          alct1_clct1_copad_match_found_r <= alct0_clct0_copad_match_any;
          swapclct_copad_match_r          <= 1'b1;// at least one ALCT-CLCT-copad match is found
          swapalct_copad_match_r          <= 1'b1;
          best_cluster0_alct_clct_copad_r <= alct1_clct1_copad_best_icluster;
          best_cluster1_alct_clct_copad_r <= alct0_clct0_copad_best_icluster;
          best_angle0_alct_clct_copad_r   <= alct1_clct1_copad_best_angle;
          best_angle1_alct_clct_copad_r   <= alct0_clct0_copad_best_angle;
          cluster0layer_alct_clct_copad_r <= alct1_copad_matchB_any[alct1_clct1_copad_best_icluster];
          cluster1layer_alct_clct_copad_r <= alct0_copad_matchB_any[alct0_clct0_copad_best_icluster];
      end
      else begin
          alct1_clct1_copad_match_found_r <= 1'b0;
          swapclct_copad_match_r          <= 1'b0;
          swapalct_copad_match_r          <= 1'b0;
          best_cluster0_alct_clct_copad_r <= 3'b0;
          best_cluster1_alct_clct_copad_r <= 3'b0;
          best_angle0_alct_clct_copad_r   <= 10'b0;
          best_angle1_alct_clct_copad_r   <= 10'b0;
          cluster0layer_alct_clct_copad_r <=  1'b0;
          cluster1layer_alct_clct_copad_r <=  1'b0;
      end
  end


  //alct0_clct0_copad_match_found, alct1_clct1_copad_match_found: here index0 & 1 is after sorting. swapped ALCT or CLCT if necessary!
  assign alct1_clct1_copad_match_found = alct1_clct1_copad_match_found_r;
  assign swapclct_copad_match = swapclct_copad_match_r;
  assign swapalct_copad_match = swapalct_copad_match_r;

  wire best_cluster0_alct_clct_copad_vpf = alct0_clct0_copad_match_found;
  wire best_cluster1_alct_clct_copad_vpf = alct1_clct1_copad_match_found;

  assign alct_clct_copad_nomatch = !alct0_clct0_copad_match_found;


  //-------------------------------------------------------------------------------------------------------------------
  // step2  ALCT+CLCT+singleGEM matching plus no copad matching
  //ALCT-CLCT+singleGEM match, very challenging part!, lot of combinations!
  //-------------------------------------------------------------------------------------------------------------------

  wire [2:0] alct0_clct0_gemA_best_icluster;
  wire [MXBENDANGLEB-1:0] alct0_clct0_gemA_best_angle;
  tree_encoder_alctclctgem_TR ualct0_clct0_gemA_match(
      //clock,
      alct0_clct0_gemA_angle[0],
      alct0_clct0_gemA_angle[1],
      alct0_clct0_gemA_angle[2],
      alct0_clct0_gemA_angle[3],
      alct0_clct0_gemA_angle[4],
      alct0_clct0_gemA_angle[5],
      alct0_clct0_gemA_angle[6],
      alct0_clct0_gemA_angle[7],

      alct0_clct0_gemA_best_angle,
      alct0_clct0_gemA_best_icluster
      );


  wire [2:0] alct0_clct0_gemB_best_icluster;
  wire [MXBENDANGLEB-1:0] alct0_clct0_gemB_best_angle;
  tree_encoder_alctclctgem_TR ualct0_clct0_gemB_match(
      //clock,
      alct0_clct0_gemB_angle[0],
      alct0_clct0_gemB_angle[1],
      alct0_clct0_gemB_angle[2],
      alct0_clct0_gemB_angle[3],
      alct0_clct0_gemB_angle[4],
      alct0_clct0_gemB_angle[5],
      alct0_clct0_gemB_angle[6],
      alct0_clct0_gemB_angle[7],

      alct0_clct0_gemB_best_angle,
      alct0_clct0_gemB_best_icluster
      );

  wire [2:0] alct1_clct0_gemA_best_icluster;
  wire [MXBENDANGLEB-1:0] alct1_clct0_gemA_best_angle;
  tree_encoder_alctclctgem_TR ualct1_clct0_gemA_match(
      //clock,
      alct1_clct0_gemA_angle[0],
      alct1_clct0_gemA_angle[1],
      alct1_clct0_gemA_angle[2],
      alct1_clct0_gemA_angle[3],
      alct1_clct0_gemA_angle[4],
      alct1_clct0_gemA_angle[5],
      alct1_clct0_gemA_angle[6],
      alct1_clct0_gemA_angle[7],

      alct1_clct0_gemA_best_angle,
      alct1_clct0_gemA_best_icluster
      );


  wire [2:0] alct1_clct0_gemB_best_icluster;
  wire [MXBENDANGLEB-1:0] alct1_clct0_gemB_best_angle;
  tree_encoder_alctclctgem_TR ualct1_clct0_gemB_match(
      //clock,
      alct1_clct0_gemB_angle[0],
      alct1_clct0_gemB_angle[1],
      alct1_clct0_gemB_angle[2],
      alct1_clct0_gemB_angle[3],
      alct1_clct0_gemB_angle[4],
      alct1_clct0_gemB_angle[5],
      alct1_clct0_gemB_angle[6],
      alct1_clct0_gemB_angle[7],

      alct1_clct0_gemB_best_angle,
      alct1_clct0_gemB_best_icluster
      );


  wire [2:0] alct0_clct1_gemA_best_icluster;
  wire [MXBENDANGLEB-1:0] alct0_clct1_gemA_best_angle;
  tree_encoder_alctclctgem_TR ualct0_clct1_gemA_match(
      //clock,
      alct0_clct1_gemA_angle[0],
      alct0_clct1_gemA_angle[1],
      alct0_clct1_gemA_angle[2],
      alct0_clct1_gemA_angle[3],
      alct0_clct1_gemA_angle[4],
      alct0_clct1_gemA_angle[5],
      alct0_clct1_gemA_angle[6],
      alct0_clct1_gemA_angle[7],

      alct0_clct1_gemA_best_angle,
      alct0_clct1_gemA_best_icluster
      );


  wire [2:0] alct0_clct1_gemB_best_icluster;
  wire [MXBENDANGLEB-1:0] alct0_clct1_gemB_best_angle;
  tree_encoder_alctclctgem_TR ualct0_clct1_gemB_match(
      //clock,
      alct0_clct1_gemB_angle[0],
      alct0_clct1_gemB_angle[1],
      alct0_clct1_gemB_angle[2],
      alct0_clct1_gemB_angle[3],
      alct0_clct1_gemB_angle[4],
      alct0_clct1_gemB_angle[5],
      alct0_clct1_gemB_angle[6],
      alct0_clct1_gemB_angle[7],

      alct0_clct1_gemB_best_angle,
      alct0_clct1_gemB_best_icluster
      );

  wire [2:0] alct1_clct1_gemA_best_icluster;
  wire [MXBENDANGLEB-1:0] alct1_clct1_gemA_best_angle;
  tree_encoder_alctclctgem_TR ualct1_clct1_gemA_match(
      //clock,
      alct1_clct1_gemA_angle[0],
      alct1_clct1_gemA_angle[1],
      alct1_clct1_gemA_angle[2],
      alct1_clct1_gemA_angle[3],
      alct1_clct1_gemA_angle[4],
      alct1_clct1_gemA_angle[5],
      alct1_clct1_gemA_angle[6],
      alct1_clct1_gemA_angle[7],

      alct1_clct1_gemA_best_angle,
      alct1_clct1_gemA_best_icluster
      );


  wire [2:0] alct1_clct1_gemB_best_icluster;
  wire [MXBENDANGLEB-1:0] alct1_clct1_gemB_best_angle;
  tree_encoder_alctclctgem_TR ualct1_clct1_gemB_match(
      //clock,
      alct1_clct1_gemB_angle[0],
      alct1_clct1_gemB_angle[1],
      alct1_clct1_gemB_angle[2],
      alct1_clct1_gemB_angle[3],
      alct1_clct1_gemB_angle[4],
      alct1_clct1_gemB_angle[5],
      alct1_clct1_gemB_angle[6],
      alct1_clct1_gemB_angle[7],

      alct1_clct1_gemB_best_angle,
      alct1_clct1_gemB_best_icluster
      );


  wire alct0_clct0_gemA_match_any  = (|alct0_clct0_gemA_match) && tmb_allow_match;
  wire alct0_clct1_gemA_match_any  = (|alct0_clct1_gemA_match) && tmb_allow_match;
  wire alct1_clct0_gemA_match_any  = (|alct1_clct0_gemA_match) && tmb_allow_match;
  wire alct1_clct1_gemA_match_any  = (|alct1_clct1_gemA_match) && tmb_allow_match;

  wire alct0_clct0_gemB_match_any  = (|alct0_clct0_gemB_match) && tmb_allow_match;
  wire alct0_clct1_gemB_match_any  = (|alct0_clct1_gemB_match) && tmb_allow_match;
  wire alct1_clct0_gemB_match_any  = (|alct1_clct0_gemB_match) && tmb_allow_match;
  wire alct1_clct1_gemB_match_any  = (|alct1_clct1_gemB_match) && tmb_allow_match;

  assign alct_clct_gemA_match      = alct0_clct0_gemA_match_any || alct0_clct1_gemA_match_any || alct1_clct0_gemA_match_any || alct1_clct1_gemA_match_any;
  assign alct_clct_gemB_match      = alct0_clct0_gemB_match_any || alct0_clct1_gemB_match_any || alct1_clct0_gemB_match_any || alct1_clct1_gemB_match_any;

  //which bend angle is small? gemA or gemB
  wire alct0_clct0_bestgem         = alct0_clct0_gemB_best_angle < alct0_clct0_gemA_best_angle;//0 for selecting gemA, 1 for gemB
  wire alct0_clct0_gem_match_any   = alct0_clct0_bestgem ? alct0_clct0_gemB_match_any : alct0_clct0_gemA_match_any;

  wire alct0_clct1_bestgem         = alct0_clct1_gemB_best_angle < alct0_clct1_gemA_best_angle;//0 for selecting gemA, 1 for gemB
  wire alct0_clct1_gem_match_any   = alct0_clct1_bestgem ? alct0_clct1_gemB_match_any : alct0_clct1_gemA_match_any;

  wire alct1_clct0_bestgem         = alct1_clct0_gemB_best_angle < alct1_clct0_gemA_best_angle;//0 for selecting gemA, 1 for gemB
  wire alct1_clct0_gem_match_any   = alct1_clct0_bestgem ? alct1_clct0_gemB_match_any : alct1_clct0_gemA_match_any;

  wire alct1_clct1_bestgem         = alct1_clct1_gemB_best_angle < alct1_clct1_gemA_best_angle;//0 for selecting gemA, 1 for gemB
  wire alct1_clct1_gem_match_any   = alct1_clct1_bestgem ? alct1_clct1_gemB_match_any : alct1_clct1_gemA_match_any;


  // do ALCT-CLCT-singleGEM match on top of ALCT-CLCT-Copad match!
  // alct0_clct0_gem match is good if either alct_clct_copad match is not found or only alct1_clct1_copad found, then both alct0 and clct0 is fine to use for ALCT-CCLT-singleGEM match
  wire alct0_clct0_gem_match_ok  = alct0_clct0_gem_match_any && (alct_clct_copad_nomatch || ( swapclct_copad_match &&  swapalct_copad_match && !alct0_clct0_copad_match_any));
  wire alct0_clct1_gem_match_ok  = alct0_clct1_gem_match_any && (alct_clct_copad_nomatch || (!swapclct_copad_match &&  swapalct_copad_match && !alct0_clct1_copad_match_any));
  wire alct1_clct0_gem_match_ok  = alct1_clct0_gem_match_any && (alct_clct_copad_nomatch || ( swapclct_copad_match && !swapalct_copad_match && !alct1_clct0_copad_match_any));
  wire alct1_clct1_gem_match_ok  = alct1_clct1_gem_match_any && (alct_clct_copad_nomatch || (!swapclct_copad_match && !swapalct_copad_match && !alct1_clct1_copad_match_any));

 //if  alct or clct is already used for ALCT-CLCT-Copad match, then set the bending angle of this ALCT-CLCT-singleGEM match to be invalid
  wire [MXBENDANGLEB-1:0] alct0_clct0_gem_best_angle  = alct0_clct0_gem_match_ok ? (alct0_clct0_bestgem ? alct0_clct0_gemB_best_angle : alct0_clct0_gemA_best_angle) : MAXGEMCSCBND;
  wire [MXBENDANGLEB-1:0] alct0_clct1_gem_best_angle  = alct0_clct1_gem_match_ok ? (alct0_clct1_bestgem ? alct0_clct1_gemB_best_angle : alct0_clct1_gemA_best_angle) : MAXGEMCSCBND;
  wire [MXBENDANGLEB-1:0] alct1_clct0_gem_best_angle  = alct1_clct0_gem_match_ok ? (alct1_clct0_bestgem ? alct1_clct0_gemB_best_angle : alct1_clct0_gemA_best_angle) : MAXGEMCSCBND;
  wire [MXBENDANGLEB-1:0] alct1_clct1_gem_best_angle  = alct1_clct1_gem_match_ok ? (alct1_clct1_bestgem ? alct1_clct1_gemB_best_angle : alct1_clct1_gemA_best_angle) : MAXGEMCSCBND;


  //alct0_clct0_gem_match_found, alct1_clct1_gem_match_found.  here index0 & 1 is after sorting
  assign alct0_clct0_gem_match_found = (alct0_clct0_gem_match_ok || alct0_clct1_gem_match_ok || alct1_clct0_gem_match_ok || alct1_clct1_gem_match_ok ) && alct_clct_copad_nomatch;
  
  // alct1_clct1_gem match could be from 
  // 1. alct0_clct0_gem_match is found and then another set of alct_clct_gem_match is also found. no ALCT-CLCT-copad is found
  // 2. alct0_clct0_copad_match is found but alct1_clct1_copad_match is not found !!
  reg alct1_clct1_gem_match_found_r = 1'b0;
  reg swapclct_gem_match_r = 1'b0;
  reg swapalct_gem_match_r = 1'b0;

  reg       cluster0layer_alct_clct_gem_r = 1'b0;
  reg       cluster1layer_alct_clct_gem_r = 1'b0;
  reg [2:0] best_cluster0_alct_clct_gem_r = 3'b0;
  reg [2:0] best_cluster1_alct_clct_gem_r = 3'b0;
  reg [MXBENDANGLEB-1:0] best_angle0_alct_clct_gem_r = 3'b0;
  reg [MXBENDANGLEB-1:0] best_angle1_alct_clct_gem_r = 3'b0;

  always @(*) begin
       //***********************************************************
       //ALCT0+CLCT0+SingleGEM plus no copad match
      if (alct0_clct0_gem_match_ok && alct0_clct0_gem_best_angle < alct0_clct1_gem_best_angle && alct0_clct0_gem_best_angle < alct1_clct1_gem_best_angle)
      begin // alct0_clct0_gem_best_angle is minimum and good for use.
          // alct_clct_copad_nomatch = true,  alct0_clct0_gem goes to build LCT0
          // alct_clct_copad_nomatch = false, alct0_clct0_gem goes to build LCT1
          if (alct_clct_copad_nomatch) begin
              alct1_clct1_gem_match_found_r <= alct1_clct1_gem_match_ok;
              swapclct_gem_match_r          <= 1'b0;
              swapalct_gem_match_r          <= 1'b0;
              cluster0layer_alct_clct_gem_r <= alct0_clct0_bestgem;
              best_cluster0_alct_clct_gem_r <= alct0_clct0_bestgem ? alct0_clct0_gemB_best_icluster : alct0_clct0_gemA_best_icluster;
              best_angle0_alct_clct_gem_r   <= alct0_clct0_bestgem ? alct0_clct0_gemB_best_angle    : alct0_clct0_gemA_best_angle;
              cluster1layer_alct_clct_gem_r <= alct1_clct1_bestgem;
              best_cluster1_alct_clct_gem_r <= alct1_clct1_bestgem ? alct1_clct1_gemB_best_icluster : alct1_clct1_gemA_best_icluster;
              best_angle1_alct_clct_gem_r   <= alct1_clct1_bestgem ? alct1_clct1_gemB_best_angle    : alct1_clct1_gemA_best_angle;
          end 
          else begin
              //alct0_clct0_gem goes to LCT1 and alct1_clct1_copad would go to LCT0
              alct1_clct1_gem_match_found_r <= alct0_clct0_gem_match_ok;
              swapclct_gem_match_r          <= 1'b1;
              swapalct_gem_match_r          <= 1'b1;
              cluster0layer_alct_clct_gem_r <= 1'b0;
              best_cluster0_alct_clct_gem_r <= 3'b0;//invlaid cluster
              best_angle0_alct_clct_gem_r   <= 10'b0;
              cluster1layer_alct_clct_gem_r <= alct0_clct0_bestgem;
              best_cluster1_alct_clct_gem_r <= alct0_clct0_bestgem ? alct0_clct0_gemB_best_icluster : alct0_clct0_gemA_best_icluster;
              best_angle1_alct_clct_gem_r   <= alct0_clct0_bestgem ? alct0_clct0_gemB_best_angle    : alct0_clct0_gemA_best_angle;
          end
      end
       //***********************************************************
       //ALCT0+CLCT1+SingleGEM plus no copad
      else if (alct0_clct1_gem_match_ok && alct0_clct1_gem_best_angle < alct0_clct0_gem_best_angle && alct0_clct1_gem_best_angle < alct1_clct0_gem_best_angle)
      begin
          if (alct_clct_copad_nomatch) begin
              alct1_clct1_gem_match_found_r <= alct1_clct0_gem_match_ok;
              swapclct_gem_match_r          <= 1'b1;
              swapalct_gem_match_r          <= 1'b0;
              cluster0layer_alct_clct_gem_r <= alct0_clct1_bestgem;
              best_cluster0_alct_clct_gem_r <= alct0_clct1_bestgem ? alct0_clct1_gemB_best_icluster : alct0_clct1_gemA_best_icluster;
              best_angle0_alct_clct_gem_r   <= alct0_clct1_bestgem ? alct0_clct1_gemB_best_angle    : alct0_clct1_gemA_best_angle;
              cluster1layer_alct_clct_gem_r <= alct1_clct0_bestgem;
              best_cluster1_alct_clct_gem_r <= alct1_clct0_bestgem ? alct1_clct0_gemB_best_icluster : alct1_clct0_gemA_best_icluster;
              best_angle1_alct_clct_gem_r   <= alct1_clct0_bestgem ? alct1_clct0_gemB_best_angle    : alct1_clct0_gemA_best_angle;
          end
          else begin
              //alct0_clct1_gem goes to LCT1 and alct1_clct0_copad would go to LCT0
              alct1_clct1_gem_match_found_r <= alct0_clct1_gem_match_ok;
              swapclct_gem_match_r          <= 1'b0;
              swapalct_gem_match_r          <= 1'b1;
              cluster0layer_alct_clct_gem_r <= 1'b0;
              best_cluster0_alct_clct_gem_r <= 3'b0;//invlaid cluster
              best_angle0_alct_clct_gem_r   <= 10'b0;
              cluster1layer_alct_clct_gem_r <= alct0_clct1_bestgem;
              best_cluster1_alct_clct_gem_r <= alct0_clct1_bestgem ? alct0_clct1_gemB_best_icluster : alct0_clct1_gemA_best_icluster;
              best_angle1_alct_clct_gem_r   <= alct0_clct1_bestgem ? alct0_clct1_gemB_best_angle    : alct0_clct1_gemA_best_angle;
          end
      end
       //***********************************************************
       //ALCT1+CLCT0+SingleGEM plus no copad
      else if (alct1_clct0_gem_match_ok && alct1_clct0_gem_best_angle < alct1_clct1_gem_best_angle)
      begin
          if (alct_clct_copad_nomatch) begin
              alct1_clct1_gem_match_found_r <= alct0_clct1_gem_match_ok;
              swapclct_gem_match_r          <= 1'b0;
              swapalct_gem_match_r          <= 1'b1;
              cluster0layer_alct_clct_gem_r <= alct1_clct0_bestgem;
              best_cluster0_alct_clct_gem_r <= alct1_clct0_bestgem ? alct1_clct0_gemB_best_icluster : alct1_clct0_gemA_best_icluster;
              best_angle0_alct_clct_gem_r   <= alct1_clct0_bestgem ? alct1_clct0_gemB_best_angle    : alct1_clct0_gemA_best_angle;
              cluster1layer_alct_clct_gem_r <= alct0_clct1_bestgem;
              best_cluster1_alct_clct_gem_r <= alct0_clct1_bestgem ? alct0_clct1_gemB_best_icluster : alct0_clct1_gemA_best_icluster;
              best_angle1_alct_clct_gem_r   <= alct0_clct1_bestgem ? alct0_clct1_gemB_best_angle    : alct0_clct1_gemA_best_angle;
          end
          else begin
              //alct1_clct0_gem goes to LCT1 and alct0_clct1_copad would go to LCT0
              alct1_clct1_gem_match_found_r <= alct1_clct0_gem_match_ok;
              swapclct_gem_match_r          <= 1'b1;
              swapalct_gem_match_r          <= 1'b0;
              cluster0layer_alct_clct_gem_r <= 1'b0;
              best_cluster0_alct_clct_gem_r <= 3'b0;//invlaid cluster
              best_angle0_alct_clct_gem_r   <= 10'b0;
              cluster1layer_alct_clct_gem_r <= alct1_clct0_bestgem;
              best_cluster1_alct_clct_gem_r <= alct1_clct0_bestgem ? alct1_clct0_gemB_best_icluster : alct1_clct0_gemA_best_icluster;
              best_angle1_alct_clct_gem_r   <= alct1_clct0_bestgem ? alct1_clct0_gemB_best_angle    : alct1_clct0_gemA_best_angle;
          end
      end
       //***********************************************************
       //ALCT1+CLCT1+SingleGEM plus no copad or copad match is already found
      else if (alct1_clct1_gem_match_ok)// alct1_clct1_gem_best_angle is minimum
      begin
          if (alct_clct_copad_nomatch) begin
              alct1_clct1_gem_match_found_r <= alct0_clct0_gem_match_ok;
              swapclct_gem_match_r          <= 1'b1;
              swapalct_gem_match_r          <= 1'b1;
              cluster0layer_alct_clct_gem_r <= alct1_clct1_bestgem;
              best_cluster0_alct_clct_gem_r <= alct1_clct1_bestgem ? alct1_clct1_gemB_best_icluster : alct1_clct1_gemA_best_icluster;
              best_angle0_alct_clct_gem_r   <= alct1_clct1_bestgem ? alct1_clct1_gemB_best_angle    : alct1_clct1_gemA_best_angle;
              cluster1layer_alct_clct_gem_r <= alct0_clct0_bestgem;
              best_cluster1_alct_clct_gem_r <= alct0_clct0_bestgem ? alct0_clct0_gemB_best_icluster : alct0_clct0_gemA_best_icluster;
              best_angle1_alct_clct_gem_r   <= alct0_clct0_bestgem ? alct0_clct0_gemB_best_angle    : alct0_clct0_gemA_best_angle;
          end
          else begin
              //alct1_clct1_gem goes to LCT1 and alct0_clct1_copad would go to LCT0
              alct1_clct1_gem_match_found_r <= alct1_clct1_gem_match_ok;
              swapclct_gem_match_r          <= 1'b0;
              swapalct_gem_match_r          <= 1'b0;
              cluster0layer_alct_clct_gem_r <= 1'b0;
              best_cluster0_alct_clct_gem_r <= 3'b0;//invlaid cluster
              best_angle0_alct_clct_gem_r   <= 10'b0;
              cluster1layer_alct_clct_gem_r <= alct1_clct1_bestgem;
              best_cluster1_alct_clct_gem_r <= alct1_clct1_bestgem ? alct1_clct1_gemB_best_icluster : alct1_clct1_gemA_best_icluster;
              best_angle1_alct_clct_gem_r   <= alct1_clct1_bestgem ? alct1_clct1_gemB_best_angle    : alct1_clct1_gemA_best_angle;
          end
      end
       //***********************************************************
      else 
      begin
          alct1_clct1_gem_match_found_r <= 1'b0;
          swapclct_gem_match_r          <= 1'b0;
          swapalct_gem_match_r          <= 1'b0;
          cluster1layer_alct_clct_gem_r <= 1'b0;
          best_cluster1_alct_clct_gem_r <= 3'b0;//invlaid cluster
          cluster0layer_alct_clct_gem_r <= 1'b0;
          best_cluster0_alct_clct_gem_r <= 3'b0;//invlaid cluster
          best_angle0_alct_clct_gem_r   <= 10'b0;
          best_angle1_alct_clct_gem_r   <= 10'b0;
      end
  end

  assign alct1_clct1_gem_match_found = alct1_clct1_gem_match_found_r;
  assign swapclct_gem_match = swapclct_gem_match_r;
  assign swapalct_gem_match = swapalct_gem_match_r;

  wire  best_cluster0_alct_clct_gem_vpf = alct0_clct0_gem_match_found;
  wire  best_cluster1_alct_clct_gem_vpf = alct1_clct1_gem_match_found;

  assign alct_clct_gem_nomatch = !alct1_clct1_gem_match_found && !alct0_clct0_gem_match_found;

  //-------------------------------------------------------------------------------------------------------------------
  // step3  ALCT+CLCT matching
  //-------------------------------------------------------------------------------------------------------------------
  //old alct-clct match in tmb.v
  //for GEMCSC match, GEM match should be considered for ALCT1-CLCT1 match
  //should we consider that alct+lowQ clct match ???????? 
  //-------------------------------------------------------------------------------------------------------------------
  // alct1_clct1_nogem match could be from 
  // 1. no alct_clct_gem/alct_clct_copad match if found.
  // 2. alct0_clct0_copad_match/alct0_clct0_gem_match is found but alct1_clct1_copad_match/alct1_clct1_gem_match is not found !!

  reg alct0_vpf_r = 1'b0;
  reg alct1_vpf_r = 1'b0;
  reg clct0_vpf_r = 1'b0;
  reg clct1_vpf_r = 1'b0;
  reg drop_lowqalct0_r = 1'b0;
  reg drop_lowqalct1_r = 1'b0;
  reg drop_lowqclct0_r = 1'b0;
  reg drop_lowqclct1_r = 1'b0;

  always @ (posedge clock) begin
      alct0_vpf_r <= alct0_vpf;
      alct1_vpf_r <= alct1_vpf;
      clct0_vpf_r <= clct0_vpf;
      clct1_vpf_r <= clct1_vpf;
      drop_lowqalct0_r <= drop_lowqalct0;
      drop_lowqalct1_r <= drop_lowqalct1;
      drop_lowqclct0_r <= drop_lowqclct0;
      drop_lowqclct1_r <= drop_lowqclct1;
  end

  wire alct_clct_nogem_nocopad   = alct_clct_gem_nomatch && alct_clct_copad_nomatch;
  wire alct1_clct1_nogem_nocopad = !alct1_clct1_gem_match_found && !alct1_clct1_copad_match_found;

  assign alct0_clct0_nogem_match_found = alct_clct_nogem_nocopad && alct0_vpf_r && clct0_vpf_r && !drop_lowqalct0_r && !drop_lowqclct0_r && tmb_allow_match; 

  wire alct1_vpf_afterswap = (swapalct_copad_match || swapalct_gem_match) ? (alct0_vpf_r && !drop_lowqalct0_r) : (alct1_vpf_r && !drop_lowqalct1_r);
  wire clct1_vpf_afterswap = (swapclct_copad_match || swapclct_gem_match) ? (clct0_vpf_r && !drop_lowqclct0_r) : (clct1_vpf_r && !drop_lowqclct1_r);
  assign alct1_clct1_nogem_match_found = (alct1_vpf_afterswap && clct1_vpf_afterswap && alct1_clct1_nogem_nocopad && tmb_allow_match);

  //-------------------------------------------------------------------------------------------------------------------
  // step4  CLCT+Copad matching
  //CLCT+GEM Copad match, very challenging part!, lot of combinations!
  //-------------------------------------------------------------------------------------------------------------------
  wire  alct0_clct0_match = alct0_clct0_copad_match_found || alct0_clct0_gem_match_found || alct0_clct0_nogem_match_found;
  wire  alct1_clct1_match = alct1_clct1_copad_match_found || alct1_clct1_gem_match_found || alct1_clct1_nogem_match_found;

  wire [2:0] clct0_copad_best_icluster;
  wire [MXBENDANGLEB-1:0] clct0_copad_best_angle;
  tree_encoder_alctclctgem_TR uclct0_copad_match(
      //clock,
      clct0_copad_angle[0],
      clct0_copad_angle[1],
      clct0_copad_angle[2],
      clct0_copad_angle[3],
      clct0_copad_angle[4],
      clct0_copad_angle[5],
      clct0_copad_angle[6],
      clct0_copad_angle[7],

      clct0_copad_best_angle,
      clct0_copad_best_icluster
      );

  wire [2:0] clct1_copad_best_icluster;
  wire [MXBENDANGLEB-1:0] clct1_copad_best_angle;
  tree_encoder_alctclctgem_TR uclct1_copad_match(
      //clock,
      clct1_copad_angle[0],
      clct1_copad_angle[1],
      clct1_copad_angle[2],
      clct1_copad_angle[3],
      clct1_copad_angle[4],
      clct1_copad_angle[5],
      clct1_copad_angle[6],
      clct1_copad_angle[7],

      clct1_copad_best_angle,
      clct1_copad_best_icluster
      );

  // clct1_copad match could be from 
  // no alct1 is found.

  //still need to find out wire group of GEM pad
  wire clct0_copad_match_any = ( |clct0_copad_match_ok ) && !drop_lowqclct0_r;
  wire clct1_copad_match_any = ( |clct1_copad_match_ok ) && !drop_lowqclct1_r;
  
  assign clct0_copad_match_found  = !alct0_clct0_match && (clct0_copad_match_any || clct1_copad_match_any);
  assign clct1_copad_match_found  = !alct1_clct1_match && ((swapclct_copad_match || swapclct_gem_match || (clct0_copad_match_found && (!clct0_copad_match_any || clct0_copad_best_angle > clct1_copad_best_angle))) ? clct0_copad_match_any : clct1_copad_match_any);
  //only case to swap clct0 and clct1 here: both LCTs built from CLCT+copad
  assign swapclct_clctcopad_match = (clct0_copad_match_found && clct1_copad_match_found && (clct0_copad_best_angle > clct1_copad_best_angle)) || (!alct0_clct0_match && !clct0_copad_match_any && clct1_copad_match_any);

  //either gemA or gemB in copad is matched for first CLCT+copad match
  //cluster0layer_clct_copad =1 means gemB part in copad is matched with CLCT
  wire cluster0layer_clct_copad = swapclct_clctcopad_match ? clct1_copad_matchB_any[clct1_copad_best_icluster] : clct0_copad_matchB_any[clct0_copad_best_icluster];
  wire cluster1layer_clct_copad = swapclct_clctcopad_match ? clct0_copad_matchB_any[clct0_copad_best_icluster] : clct1_copad_matchB_any[clct1_copad_best_icluster];
  wire [2:0] best_cluster0_clct_copad_iclst = swapclct_clctcopad_match ?  clct1_copad_best_icluster : clct0_copad_best_icluster;
  wire [2:0] best_cluster1_clct_copad_iclst = swapclct_clctcopad_match ?  clct0_copad_best_icluster : clct1_copad_best_icluster;
  wire [MXBENDANGLEB-1:0] best_angle0_clct_copad = swapclct_clctcopad_match ?  clct1_copad_best_angle : clct0_copad_best_angle;
  wire [MXBENDANGLEB-1:0] best_angle1_clct_copad = swapclct_clctcopad_match ?  clct0_copad_best_angle : clct1_copad_best_angle;

  assign alct0wg_fromcopad = swapclct_clctcopad_match ? wg1fromGEMcluster(clct1_copad_best_icluster) : wg0fromGEMcluster(clct0_copad_best_icluster);
  assign alct1wg_fromcopad = swapclct_clctcopad_match ? wg0fromGEMcluster(clct0_copad_best_icluster) : wg1fromGEMcluster(clct1_copad_best_icluster);

  wire clct0_copad_match_good = clct0_copad_match_found && tmb_copad_clct_allow;
  wire clct1_copad_match_good = clct1_copad_match_found && tmb_copad_clct_allow;

  //-------------------------------------------------------------------------------------------------------------------
  // step5  ALCT+Copad matching
  //ALCT+GEM Copad match, very challenging part!, lot of combinations!
  //-------------------------------------------------------------------------------------------------------------------

  wire [2:0] alct0_copad_best_icluster;
  wire [MXBENDANGLEB-1:0] alct0_copad_best_angle;
  wire [9:0] alct0_copad_best_cscxky;
  tree_encoder_alctcopad_TR ualct0_copad_match(
      //clock,
      alct0_copad_angle[0],
      alct0_copad_angle[1],
      alct0_copad_angle[2],
      alct0_copad_angle[3],
      alct0_copad_angle[4],
      alct0_copad_angle[5],
      alct0_copad_angle[6],
      alct0_copad_angle[7],

      copad_cluster_cscxky1_mi[0],
      copad_cluster_cscxky1_mi[1],
      copad_cluster_cscxky1_mi[2],
      copad_cluster_cscxky1_mi[3],
      copad_cluster_cscxky1_mi[4],
      copad_cluster_cscxky1_mi[5],
      copad_cluster_cscxky1_mi[6],
      copad_cluster_cscxky1_mi[7],

      alct0_copad_best_cscxky,
      alct0_copad_best_angle,
      alct0_copad_best_icluster
      );

  wire [2:0] alct1_copad_best_icluster;
  wire [MXBENDANGLEB-1:0] alct1_copad_best_angle;
  wire [9:0] alct1_copad_best_cscxky;
  tree_encoder_alctcopad_TR ualct1_copad_match(
      //clock,
      alct1_copad_angle[0],
      alct1_copad_angle[1],
      alct1_copad_angle[2],
      alct1_copad_angle[3],
      alct1_copad_angle[4],
      alct1_copad_angle[5],
      alct1_copad_angle[6],
      alct1_copad_angle[7],

      copad_cluster_cscxky1_mi[0],
      copad_cluster_cscxky1_mi[1],
      copad_cluster_cscxky1_mi[2],
      copad_cluster_cscxky1_mi[3],
      copad_cluster_cscxky1_mi[4],
      copad_cluster_cscxky1_mi[5],
      copad_cluster_cscxky1_mi[6],
      copad_cluster_cscxky1_mi[7],

      alct1_copad_best_cscxky,
      alct1_copad_best_angle,
      alct1_copad_best_icluster
      );

  //assign alct0_copad_match_found  = !clct0_vpf && (alct1_copad_best_angle != MAXGEMCSCBND) || (alct1_copad_best_angle != MAXGEMCSCBND);
  //assign alct1_copad_match_found  = !clct1_vpf && (alct0_copad_best_angle != MAXGEMCSCBND) && (alct1_copad_best_angle != MAXGEMCSCBND);

  wire alct0_copad_match_any = (|alct0_copad_match) && !drop_lowqalct0_r;
  wire alct1_copad_match_any = (|alct1_copad_match) && !drop_lowqalct1_r;

  assign alct0_copad_match_found = !alct0_clct0_match && !clct0_copad_match_good && (alct0_copad_match_any || alct1_copad_match_any);
  assign alct1_copad_match_found = !alct1_clct1_match && !clct1_copad_match_good && ((swapalct_copad_match || swapalct_gem_match || (alct0_copad_match_found && !alct0_copad_match_any)) ? alct0_copad_match_any : alct1_copad_match_any);//

  assign swapalct_alctcopad_match = alct0_copad_match_found && !alct0_copad_match_any;

  //either gemA or gemB in copad is matched for ALCT+copad match
  //cluster0layer_alct_copad =1 means gemB part in copad is matched with ALCT
  wire cluster0layer_alct_copad = swapalct_alctcopad_match ? alct1_copad_matchB_any[alct1_copad_best_icluster] : alct0_copad_matchB_any[alct0_copad_best_icluster];
  wire cluster1layer_alct_copad = swapalct_alctcopad_match ? alct0_copad_matchB_any[alct0_copad_best_icluster] : alct1_copad_matchB_any[alct1_copad_best_icluster];
  wire [2:0] best_cluster0_alct_copad_iclst = swapalct_alctcopad_match ?  alct1_copad_best_icluster : alct0_copad_best_icluster;
  wire [2:0] best_cluster1_alct_copad_iclst = swapalct_alctcopad_match ?  alct0_copad_best_icluster : alct1_copad_best_icluster;
  wire [MXBENDANGLEB-1:0] best_angle0_alct_copad = 0;
  wire [MXBENDANGLEB-1:0] best_angle1_alct_copad = 0;

  assign clct0xky_fromcopad = swapalct_alctcopad_match ? alct1_copad_best_cscxky : alct0_copad_best_cscxky;
  assign clct1xky_fromcopad = swapalct_alctcopad_match ? alct0_copad_best_cscxky : alct1_copad_best_cscxky;

  wire alct0_copad_match_good = alct0_copad_match_found && tmb_copad_alct_allow;
  wire alct1_copad_match_good = alct1_copad_match_found && tmb_copad_alct_allow;

  assign  alct0_clct0_match_found_final = alct0_clct0_copad_match_found || alct0_clct0_gem_match_found || alct0_clct0_nogem_match_found || clct0_copad_match_good || alct0_copad_match_good;
  assign  alct1_clct1_match_found_final = alct1_clct1_copad_match_found || alct1_clct1_gem_match_found || alct1_clct1_nogem_match_found || clct1_copad_match_good || alct1_copad_match_good;

  assign  swapalct_final  = swapalct_copad_match || swapalct_gem_match || (swapalct_alctcopad_match && tmb_copad_alct_allow);
  assign  swapclct_final  = swapclct_copad_match || swapclct_gem_match || (swapclct_clctcopad_match && tmb_copad_clct_allow);

  assign  alct0fromcopad  = clct0_copad_match_good && !alct0_vpf_r;
  assign  alct1fromcopad  = clct1_copad_match_good && !alct1_vpf_r;
  assign  clct0fromcopad  = alct0_copad_match_good && !clct0_vpf_r;
  assign  clct1fromcopad  = alct1_copad_match_good && !clct1_vpf_r;

  assign  copyalct0_foralct1 = alct0_vpf_r && !alct1_vpf_r && !clct1_copad_match_good && clct1_vpf_r;
  assign  copyclct0_forclct1 = clct0_vpf_r && !clct1_vpf_r && !alct1_copad_match_good && alct1_vpf_r;

  //select the best match cluster
  assign  best_cluster0_vpf    = best_cluster0_alct_clct_copad_vpf || best_cluster0_alct_clct_gem_vpf || clct0_copad_match_good || alct0_copad_match_good;
  assign  best_cluster0_ingemB =(best_cluster0_alct_clct_copad_vpf & cluster0layer_alct_clct_copad_r) | 
                                (best_cluster0_alct_clct_gem_vpf   & cluster0layer_alct_clct_gem_r) | 
                                (clct0_copad_match_good            & cluster0layer_clct_copad) |
                                (alct0_copad_match_good            & cluster0layer_alct_copad) ;
  assign  best_cluster0_iclst  = ({3{best_cluster0_alct_clct_copad_vpf}} & best_cluster0_alct_clct_copad_r) | 
                                 ({3{best_cluster0_alct_clct_gem_vpf}}   & best_cluster0_alct_clct_gem_r) | 
                                 ({3{clct0_copad_match_good}}            & best_cluster0_clct_copad_iclst) | 
                                 ({3{alct0_copad_match_good}}            & best_cluster0_alct_copad_iclst);
  assign  best_cluster0_angle  = ({MXBENDANGLEB{best_cluster0_alct_clct_copad_vpf}} & best_angle0_alct_clct_copad_r) | 
                                 ({MXBENDANGLEB{best_cluster0_alct_clct_gem_vpf}}   & best_angle0_alct_clct_gem_r) | 
                                 ({MXBENDANGLEB{clct0_copad_match_good}}            & best_angle0_clct_copad) | 
                                 ({MXBENDANGLEB{alct0_copad_match_good}}            & best_angle0_alct_copad);

  assign  best_cluster1_vpf    = best_cluster1_alct_clct_copad_vpf || best_cluster1_alct_clct_gem_vpf || clct1_copad_match_good || alct1_copad_match_good;
  assign  best_cluster1_ingemB =(best_cluster1_alct_clct_copad_vpf & cluster1layer_alct_clct_copad_r) |  
                                (best_cluster1_alct_clct_gem_vpf   & cluster1layer_alct_clct_gem_r)|
                                (clct1_copad_match_good            & cluster1layer_clct_copad) |
                                (alct1_copad_match_good            & cluster1layer_alct_copad) ;
  assign  best_cluster1_iclst  = ({3{best_cluster1_alct_clct_copad_vpf}} & best_cluster1_alct_clct_copad_r) | 
                                 ({3{best_cluster1_alct_clct_gem_vpf}}   & best_cluster1_alct_clct_gem_r) | 
                                 ({3{clct1_copad_match_good}}            & best_cluster1_clct_copad_iclst) | 
                                 ({3{alct1_copad_match_good}}            & best_cluster1_alct_copad_iclst);
  assign  best_cluster1_angle  = ({MXBENDANGLEB{best_cluster1_alct_clct_copad_vpf}} & best_angle1_alct_clct_copad_r) | 
                                 ({MXBENDANGLEB{best_cluster1_alct_clct_gem_vpf}}   & best_angle1_alct_clct_gem_r) | 
                                 ({MXBENDANGLEB{clct1_copad_match_good}}            & best_angle1_clct_copad) | 
                                 ({MXBENDANGLEB{alct1_copad_match_good}}            & best_angle1_alct_copad);

  reg [6:0] copad_cluster0_wg0_mi_r = 7'b0;
  reg [6:0] copad_cluster1_wg0_mi_r = 7'b0;
  reg [6:0] copad_cluster2_wg0_mi_r = 7'b0;
  reg [6:0] copad_cluster3_wg0_mi_r = 7'b0;
  reg [6:0] copad_cluster4_wg0_mi_r = 7'b0;
  reg [6:0] copad_cluster5_wg0_mi_r = 7'b0;
  reg [6:0] copad_cluster6_wg0_mi_r = 7'b0;
  reg [6:0] copad_cluster7_wg0_mi_r = 7'b0;
  reg [6:0] copad_cluster0_wg1_mi_r = 7'b0;
  reg [6:0] copad_cluster1_wg1_mi_r = 7'b0;
  reg [6:0] copad_cluster2_wg1_mi_r = 7'b0;
  reg [6:0] copad_cluster3_wg1_mi_r = 7'b0;
  reg [6:0] copad_cluster4_wg1_mi_r = 7'b0;
  reg [6:0] copad_cluster5_wg1_mi_r = 7'b0;
  reg [6:0] copad_cluster6_wg1_mi_r = 7'b0;
  reg [6:0] copad_cluster7_wg1_mi_r = 7'b0;

  always @(posedge clock) begin
      copad_cluster0_wg0_mi_r <= (clct0_gemA_match_s0[0] && copad_match[0]) ? gemA_cluster0_wg_mi : gemB_cluster0_wg_mi;
      copad_cluster1_wg0_mi_r <= (clct0_gemA_match_s0[1] && copad_match[1]) ? gemA_cluster1_wg_mi : gemB_cluster1_wg_mi;
      copad_cluster2_wg0_mi_r <= (clct0_gemA_match_s0[2] && copad_match[2]) ? gemA_cluster2_wg_mi : gemB_cluster2_wg_mi;
      copad_cluster3_wg0_mi_r <= (clct0_gemA_match_s0[3] && copad_match[3]) ? gemA_cluster3_wg_mi : gemB_cluster3_wg_mi;
      copad_cluster4_wg0_mi_r <= (clct0_gemA_match_s0[4] && copad_match[4]) ? gemA_cluster4_wg_mi : gemB_cluster4_wg_mi;
      copad_cluster5_wg0_mi_r <= (clct0_gemA_match_s0[5] && copad_match[5]) ? gemA_cluster5_wg_mi : gemB_cluster5_wg_mi;
      copad_cluster6_wg0_mi_r <= (clct0_gemA_match_s0[6] && copad_match[6]) ? gemA_cluster6_wg_mi : gemB_cluster6_wg_mi;
      copad_cluster7_wg0_mi_r <= (clct0_gemA_match_s0[7] && copad_match[7]) ? gemA_cluster7_wg_mi : gemB_cluster7_wg_mi;
      copad_cluster0_wg1_mi_r <= (clct1_gemA_match_s0[0] && copad_match[0]) ? gemA_cluster0_wg_mi : gemB_cluster0_wg_mi;
      copad_cluster1_wg1_mi_r <= (clct1_gemA_match_s0[1] && copad_match[1]) ? gemA_cluster1_wg_mi : gemB_cluster1_wg_mi;
      copad_cluster2_wg1_mi_r <= (clct1_gemA_match_s0[2] && copad_match[2]) ? gemA_cluster2_wg_mi : gemB_cluster2_wg_mi;
      copad_cluster3_wg1_mi_r <= (clct1_gemA_match_s0[3] && copad_match[3]) ? gemA_cluster3_wg_mi : gemB_cluster3_wg_mi;
      copad_cluster4_wg1_mi_r <= (clct1_gemA_match_s0[4] && copad_match[4]) ? gemA_cluster4_wg_mi : gemB_cluster4_wg_mi;
      copad_cluster5_wg1_mi_r <= (clct1_gemA_match_s0[5] && copad_match[5]) ? gemA_cluster5_wg_mi : gemB_cluster5_wg_mi;
      copad_cluster6_wg1_mi_r <= (clct1_gemA_match_s0[6] && copad_match[6]) ? gemA_cluster6_wg_mi : gemB_cluster6_wg_mi;
      copad_cluster7_wg1_mi_r <= (clct1_gemA_match_s0[7] && copad_match[7]) ? gemA_cluster7_wg_mi : gemB_cluster7_wg_mi;
  end
        
function [6: 0] wg0fromGEMcluster;
  input [2: 0] icluster;
  reg   [6: 0] wg;
  begin
    case (icluster)
        3'd0 :  wg = copad_cluster0_wg0_mi_r;
        3'd1 :  wg = copad_cluster1_wg0_mi_r;
        3'd2 :  wg = copad_cluster2_wg0_mi_r;
        3'd3 :  wg = copad_cluster3_wg0_mi_r;
        3'd4 :  wg = copad_cluster4_wg0_mi_r;
        3'd5 :  wg = copad_cluster5_wg0_mi_r;
        3'd6 :  wg = copad_cluster6_wg0_mi_r;
        3'd7 :  wg = copad_cluster7_wg0_mi_r;
    endcase

    wg0fromGEMcluster = wg;
  end

endfunction


function [6: 0] wg1fromGEMcluster;
  input [2: 0] icluster;
  reg   [6: 0] wg;
  begin
    case (icluster)
        3'd0 :  wg = copad_cluster0_wg1_mi_r;
        3'd1 :  wg = copad_cluster1_wg1_mi_r;
        3'd2 :  wg = copad_cluster2_wg1_mi_r;
        3'd3 :  wg = copad_cluster3_wg1_mi_r;
        3'd4 :  wg = copad_cluster4_wg1_mi_r;
        3'd5 :  wg = copad_cluster5_wg1_mi_r;
        3'd6 :  wg = copad_cluster6_wg1_mi_r;
        3'd7 :  wg = copad_cluster7_wg1_mi_r;
    endcase

    wg1fromGEMcluster = wg;
  end

endfunction

//function [9: 0] xkyfromGEMcluster;
//  input [2: 0] icluster;
//  input [9:0] cluster0_xky_mi;
//  input [9:0] cluster1_xky_mi;
//  input [9:0] cluster2_xky_mi;
//  input [9:0] cluster3_xky_mi;
//  input [9:0] cluster4_xky_mi;
//  input [9:0] cluster5_xky_mi;
//  input [9:0] cluster6_xky_mi;
//  input [9:0] cluster7_xky_mi;
//
//  reg   [9: 0] xky;
//  begin
//    case (icluster):
//        3'd0 :  xky = cluster0_xky_mi;
//        3'd1 :  xky = cluster1_xky_mi;
//        3'd2 :  xky = cluster2_xky_mi;
//        3'd3 :  xky = cluster3_xky_mi;
//        3'd4 :  xky = cluster4_xky_mi;
//        3'd5 :  xky = cluster5_xky_mi;
//        3'd6 :  xky = cluster6_xky_mi;
//        3'd7 :  xky = cluster7_xky_mi;
//    endcase
//
//    xkyfromGEMcluster = xky;
//  end
//
//endfunction
assign alctclctgem_match_sump = 
    (|alct0_copad_best_angle) |
    (|alct1_copad_best_angle) ;


//-------------------------------------------------------------------------------------------------------------------
  endmodule
//-------------------------------------------------------------------------------------------------------------------

