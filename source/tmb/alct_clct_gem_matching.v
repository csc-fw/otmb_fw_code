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

module  alct_clct_gem_matching(
    
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
  input clct0_bend,//l or r
  input clct1_bend,
  input [2:0] clct0_nhit,
  input [2:0] clct1_nhit,

  input match_drop_lowqalct, // drop lowQ stub when no GEM      
  input me1a_match_drop_lowqclct, // drop lowQ stub when no GEM      
  input me1b_match_drop_lowqclct, // drop lowQ stub when no GEM      
  input gemA_match_ignore_position, 
  input gemB_match_ignore_position, 
  input tmb_copad_alct_allow,
  input tmb_copad_clct_allow,

  input [7:0] gemA_vpf,
  input [7:0] gemB_vpf,

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

  //input [6:0] gemB_cluster0_wg_mi,
  //input [6:0] gemB_cluster1_wg_mi,
  //input [6:0] gemB_cluster2_wg_mi,
  //input [6:0] gemB_cluster3_wg_mi,
  //input [6:0] gemB_cluster4_wg_mi,
  //input [6:0] gemB_cluster5_wg_mi,
  //input [6:0] gemB_cluster6_wg_mi,
  //input [6:0] gemB_cluster7_wg_mi,

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

  input [7:0] copad_match, // copad 
  //input [9:0] copad_cluster0_xky_mi,
  //input [9:0] copad_cluster1_xky_mi,
  //input [9:0] copad_cluster2_xky_mi,
  //input [9:0] copad_cluster3_xky_mi,
  //input [9:0] copad_cluster4_xky_mi,
  //input [9:0] copad_cluster5_xky_mi,
  //input [9:0] copad_cluster6_xky_mi,
  //input [9:0] copad_cluster7_xky_mi,

  output       alct_gemA_match_found,
  output       alct_gemB_match_found,
  output       clct_gemA_match_found,
  output       clct_gemB_match_found,
  output       alct_copad_match_found,
  output       clct_copad_match_found,

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

  output       gemcsc_match_dummy
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

  wire [6:0] gemA_cluster_cscwg_lo[MXCLUSTER_CHAMBER-1:0] = {
      gemA_cluster0_wg_lo,
      gemA_cluster1_wg_lo,
      gemA_cluster2_wg_lo,
      gemA_cluster3_wg_lo,
      gemA_cluster4_wg_lo,
      gemA_cluster5_wg_lo,
      gemA_cluster6_wg_lo,
      gemA_cluster7_wg_lo
      };

  wire [6:0] gemA_cluster_cscwg_hi[MXCLUSTER_CHAMBER-1:0] = {
      gemA_cluster0_wg_hi,
      gemA_cluster1_wg_hi,
      gemA_cluster2_wg_hi,
      gemA_cluster3_wg_hi,
      gemA_cluster4_wg_hi,
      gemA_cluster5_wg_hi,
      gemA_cluster6_wg_hi,
      gemA_cluster7_wg_hi
      };

  wire [9:0] gemA_cluster_cscxky_lo[MXCLUSTER_CHAMBER-1:0] = {
      gemA_cluster0_xky_lo,
      gemA_cluster1_xky_lo,
      gemA_cluster2_xky_lo,
      gemA_cluster3_xky_lo,
      gemA_cluster4_xky_lo,
      gemA_cluster5_xky_lo,
      gemA_cluster6_xky_lo,
      gemA_cluster7_xky_lo
      };

  wire [9:0] gemA_cluster_cscxky_mi[MXCLUSTER_CHAMBER-1:0] = {
      gemA_cluster0_xky_mi,
      gemA_cluster1_xky_mi,
      gemA_cluster2_xky_mi,
      gemA_cluster3_xky_mi,
      gemA_cluster4_xky_mi,
      gemA_cluster5_xky_mi,
      gemA_cluster6_xky_mi,
      gemA_cluster7_xky_mi
      };

  wire [9:0] gemA_cluster_cscxky_hi[MXCLUSTER_CHAMBER-1:0] = {
      gemA_cluster0_xky_hi,
      gemA_cluster1_xky_hi,
      gemA_cluster2_xky_hi,
      gemA_cluster3_xky_hi,
      gemA_cluster4_xky_hi,
      gemA_cluster5_xky_hi,
      gemA_cluster6_xky_hi,
      gemA_cluster7_xky_hi
      };

  wire [6:0] gemB_cluster_cscwg_lo[MXCLUSTER_CHAMBER-1:0] = {
      gemB_cluster0_wg_lo,
      gemB_cluster1_wg_lo,
      gemB_cluster2_wg_lo,
      gemB_cluster3_wg_lo,
      gemB_cluster4_wg_lo,
      gemB_cluster5_wg_lo,
      gemB_cluster6_wg_lo,
      gemB_cluster7_wg_lo
      };

  wire [6:0] gemB_cluster_cscwg_hi[MXCLUSTER_CHAMBER-1:0] = {
      gemB_cluster0_wg_hi,
      gemB_cluster1_wg_hi,
      gemB_cluster2_wg_hi,
      gemB_cluster3_wg_hi,
      gemB_cluster4_wg_hi,
      gemB_cluster5_wg_hi,
      gemB_cluster6_wg_hi,
      gemB_cluster7_wg_hi
      };

  wire [9:0] gemB_cluster_cscxky_lo[MXCLUSTER_CHAMBER-1:0] = {
      gemB_cluster0_xky_lo,
      gemB_cluster1_xky_lo,
      gemB_cluster2_xky_lo,
      gemB_cluster3_xky_lo,
      gemB_cluster4_xky_lo,
      gemB_cluster5_xky_lo,
      gemB_cluster6_xky_lo,
      gemB_cluster7_xky_lo
      };

  wire [9:0] gemB_cluster_cscxky_mi[MXCLUSTER_CHAMBER-1:0] = {
      gemB_cluster0_xky_mi,
      gemB_cluster1_xky_mi,
      gemB_cluster2_xky_mi,
      gemB_cluster3_xky_mi,
      gemB_cluster4_xky_mi,
      gemB_cluster5_xky_mi,
      gemB_cluster6_xky_mi,
      gemB_cluster7_xky_mi
      };

  wire [9:0] gemB_cluster_cscxky_hi[MXCLUSTER_CHAMBER-1:0] = {
      gemB_cluster0_xky_hi,
      gemB_cluster1_xky_hi,
      gemB_cluster2_xky_hi,
      gemB_cluster3_xky_hi,
      gemB_cluster4_xky_hi,
      gemB_cluster5_xky_hi,
      gemB_cluster6_xky_hi,
      gemB_cluster7_xky_hi
      };

  wire [9:0] copad_cluster_cscxky_mi[MXCLUSTER_CHAMBER-1:0];


  wire [MXCLUSTER_CHAMBER-1:0] alct0_gemA_match; 
  wire [MXCLUSTER_CHAMBER-1:0] alct1_gemA_match; 
  wire [MXCLUSTER_CHAMBER-1:0] clct0_gemA_match; 
  wire [MXCLUSTER_CHAMBER-1:0] clct1_gemA_match; 
  wire [MXCLUSTER_CHAMBER-1:0] clct0_gemA_match_ok; 
  wire [MXCLUSTER_CHAMBER-1:0] clct1_gemA_match_ok; 

  wire [MXCLUSTER_CHAMBER-1:0] alct0_gemB_match; 
  wire [MXCLUSTER_CHAMBER-1:0] alct1_gemB_match; 
  wire [MXCLUSTER_CHAMBER-1:0] clct0_gemB_match; 
  wire [MXCLUSTER_CHAMBER-1:0] clct1_gemB_match; 
  wire [MXCLUSTER_CHAMBER-1:0] clct0_gemB_match_ok; 
  wire [MXCLUSTER_CHAMBER-1:0] clct1_gemB_match_ok; 

  wire [MXCLUSTER_CHAMBER-1:0] alct0_copad_match; 
  wire [MXCLUSTER_CHAMBER-1:0] alct1_copad_match; 
  wire [MXCLUSTER_CHAMBER-1:0] clct0_copad_match; 
  wire [MXCLUSTER_CHAMBER-1:0] clct1_copad_match; 
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
  wire [MXBENDANGLEB-1:0]  clct0_gemA_angle [MXCLUSTER_CHAMBER-1:0];
  wire [MXBENDANGLEB-1:0]  clct1_gemA_angle [MXCLUSTER_CHAMBER-1:0];
  wire [MXBENDANGLEB-1:0]  clct0_gemB_angle [MXCLUSTER_CHAMBER-1:0];
  wire [MXBENDANGLEB-1:0]  clct1_gemB_angle [MXCLUSTER_CHAMBER-1:0];
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

  parameter smallbending = 10'd16; // ignore the sign check for small bending angle
  parameter MAXGEMCSCBND = 10'd1023;// invalid bending 

  genvar i;
  generate
  for (i=0; i<MXCLUSTER_CHAMBER; i=i+1) begin: gem_csc_match
      assign alct0_gemA_match[i] = alct0_vpf && gemA_vpf[i] && (gemA_match_ignore_position || (alct0_wg  >= gemA_cluster_cscwg_lo[i]  && alct0_wg  <= gemA_cluster_cscwg_hi[i] )); 
      assign alct1_gemA_match[i] = alct1_vpf && gemA_vpf[i] && (gemA_match_ignore_position || (alct1_wg  >= gemA_cluster_cscwg_lo[i]  && alct1_wg  <= gemA_cluster_cscwg_hi[i] )); 
      assign clct0_gemA_match[i] = clct0_vpf && gemA_vpf[i] && (gemA_match_ignore_position || (clct0_xky >= gemA_cluster_cscxky_lo[i] && clct0_xky <= gemA_cluster_cscxky_hi[i])); 
      assign clct1_gemA_match[i] = clct1_vpf && gemA_vpf[i] && (gemA_match_ignore_position || (clct1_xky >= gemA_cluster_cscxky_lo[i] && clct1_xky <= gemA_cluster_cscxky_hi[i])); 
      assign alct0_gemB_match[i] = alct0_vpf && gemB_vpf[i] && (gemB_match_ignore_position || (alct0_wg  >= gemB_cluster_cscwg_lo[i]  && alct0_wg  <= gemB_cluster_cscwg_hi[i] )); 
      assign alct1_gemB_match[i] = alct1_vpf && gemB_vpf[i] && (gemB_match_ignore_position || (alct1_wg  >= gemB_cluster_cscwg_lo[i]  && alct1_wg  <= gemB_cluster_cscwg_hi[i] )); 
      assign clct0_gemB_match[i] = clct0_vpf && gemB_vpf[i] && (gemB_match_ignore_position || (clct0_xky >= gemB_cluster_cscxky_lo[i] && clct0_xky <= gemB_cluster_cscxky_hi[i])); 
      assign clct1_gemB_match[i] = clct1_vpf && gemB_vpf[i] && (gemB_match_ignore_position || (clct1_xky >= gemB_cluster_cscxky_lo[i] && clct1_xky <= gemB_cluster_cscxky_hi[i])); 

      assign clct0_gemA_bend[i]   = clct0_xky > gemA_cluster_cscxky_mi[i];
      assign clct0_gemB_bend[i]   = clct0_xky > gemB_cluster_cscxky_mi[i];
      assign clct1_gemA_bend[i]   = clct1_xky > gemA_cluster_cscxky_mi[i];
      assign clct1_gemB_bend[i]   = clct1_xky > gemB_cluster_cscxky_mi[i];

       //ME1a with CFEB 4, 5,6 while ME1b with CFEB 0, 1,2,3
      assign clct0_gemA_ME1a[i]   = clct0_xky[9] && gemA_cluster_cscxky_mi[i][9] ;
      assign clct0_gemB_ME1a[i]   = clct0_xky[9] && gemB_cluster_cscxky_mi[i][9] ;
      assign clct1_gemA_ME1a[i]   = clct0_xky[9] && gemA_cluster_cscxky_mi[i][9] ;
      assign clct1_gemB_ME1a[i]   = clct0_xky[9] && gemB_cluster_cscxky_mi[i][9] ;
      assign clct0_gemA_ME1b[i]   = !clct0_xky[9] && !gemA_cluster_cscxky_mi[i][9] ;
      assign clct0_gemB_ME1b[i]   = !clct0_xky[9] && !gemB_cluster_cscxky_mi[i][9] ;
      assign clct1_gemA_ME1b[i]   = !clct0_xky[9] && !gemA_cluster_cscxky_mi[i][9] ;
      assign clct1_gemB_ME1b[i]   = !clct0_xky[9] && !gemB_cluster_cscxky_mi[i][9] ;

      //ignore bending direction check
      assign clct0_gemA_match_ok[i] = clct0_gemA_match[i]; 
      assign clct0_gemB_match_ok[i] = clct0_gemB_match[i]; 
      assign clct1_gemA_match_ok[i] = clct1_gemA_match[i]; 
      assign clct1_gemB_match_ok[i] = clct1_gemB_match[i]; 
      //with bending direction check
      //assign clct0_gemA_match_ok[i] = clct0_gemA_match[i] && (clct0_gemA_bend[i] == clct0_bend) && (clct0_gemA_ME1a[i] || clct0_gemA_ME1b[i]);
      //assign clct0_gemB_match_ok[i] = clct0_gemB_match[i] && (clct0_gemB_bend[i] == clct0_bend) && (clct0_gemB_ME1a[i] || clct0_gemB_ME1b[i]);
      //assign clct1_gemA_match_ok[i] = clct1_gemA_match[i] && (clct1_gemA_bend[i] == clct1_bend) && (clct1_gemA_ME1a[i] || clct1_gemA_ME1b[i]);
      //assign clct1_gemB_match_ok[i] = clct1_gemB_match[i] && (clct1_gemB_bend[i] == clct1_bend) && (clct1_gemB_ME1a[i] || clct1_gemB_ME1b[i]);

      assign clct0_gemA_angle[i] = clct0_gemA_match_ok[i] ? (clct0_gemA_bend[i] ? (clct0_xky-gemA_cluster_cscxky_mi[i]) : (gemA_cluster_cscxky_mi[i]-clct0_xky)) : MAXGEMCSCBND; 
      assign clct0_gemB_angle[i] = clct0_gemB_match_ok[i] ? (clct0_gemB_bend[i] ? (clct0_xky-gemB_cluster_cscxky_mi[i]) : (gemB_cluster_cscxky_mi[i]-clct0_xky)) : MAXGEMCSCBND; 
      assign clct1_gemA_angle[i] = clct1_gemA_match_ok[i] ? (clct1_gemA_bend[i] ? (clct1_xky-gemA_cluster_cscxky_mi[i]) : (gemA_cluster_cscxky_mi[i]-clct1_xky)) : MAXGEMCSCBND; 
      assign clct1_gemB_angle[i] = clct1_gemB_match_ok[i] ? (clct1_gemB_bend[i] ? (clct1_xky-gemB_cluster_cscxky_mi[i]) : (gemB_cluster_cscxky_mi[i]-clct1_xky)) : MAXGEMCSCBND; 
      //
      assign copad_cluster_cscxky_mi[i] = copad_match[i] ? gemA_cluster_cscxky_mi[i] : 10'h3FF;//use all 3FF as default csc coordinate for copad 

      assign alct0_copad_match[i] = alct0_gemA_match[i] && copad_match[i];
      assign alct1_copad_match[i] = alct1_gemA_match[i] && copad_match[i];
      assign clct0_copad_match[i] = clct0_gemA_match[i] && copad_match[i];
      assign clct1_copad_match[i] = clct1_gemA_match[i] && copad_match[i];

      assign clct0_copad_match_ok[i] = clct0_copad_match[i] && clct0_gemA_match_ok[i];
      assign clct1_copad_match_ok[i] = clct1_copad_match[i] && clct1_gemA_match_ok[i];

      assign clct0_copad_angle[i] = clct0_copad_match_ok[i] ? clct0_gemA_angle[i] : MAXGEMCSCBND;
      assign clct1_copad_angle[i] = clct1_copad_match_ok[i] ? clct1_gemA_angle[i] : MAXGEMCSCBND;
       
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

      //alct0_clct0_gem_match[i] = (alct0_gemA_match[i] && clct0_gemA_match_ok[i]) || (alct0_gemB_match[i] && clct0_gemB_match_ok[i]);
      //alct0_clct1_gem_match[i] = (alct0_gemA_match[i] && clct1_gemA_match_ok[i]) || (alct0_gemB_match[i] && clct1_gemB_match_ok[i]);
      //alct1_clct0_gem_match[i] = (alct1_gemA_match[i] && clct0_gemA_match_ok[i]) || (alct1_gemB_match[i] && clct0_gemB_match_ok[i]);
      //alct1_clct1_gem_match[i] = (alct1_gemA_match[i] && clct1_gemA_match_ok[i]) || (alct1_gemB_match[i] && clct1_gemB_match_ok[i]);

      assign alct0_clct0_copad_match[i] = alct0_copad_match[i] && clct0_copad_match_ok[i];
      assign alct0_clct1_copad_match[i] = alct0_copad_match[i] && clct1_copad_match_ok[i];
      assign alct1_clct0_copad_match[i] = alct1_copad_match[i] && clct0_copad_match_ok[i];
      assign alct1_clct1_copad_match[i] = alct1_copad_match[i] && clct1_copad_match_ok[i];

      assign alct0_clct0_copad_angle[i] = alct0_clct0_copad_match[i] ? clct0_gemA_angle[i] : MAXGEMCSCBND;
      assign alct0_clct1_copad_angle[i] = alct0_clct1_copad_match[i] ? clct1_gemA_angle[i] : MAXGEMCSCBND;
      assign alct1_clct0_copad_angle[i] = alct1_clct0_copad_match[i] ? clct0_gemA_angle[i] : MAXGEMCSCBND;
      assign alct1_clct1_copad_angle[i] = alct1_clct1_copad_match[i] ? clct1_gemA_angle[i] : MAXGEMCSCBND;

    end
  endgenerate 

  //-------------------------------------------------------------------------------------------------------------------
  //match results : ALCT-GEM, CLCT-GEM, ALCT_copad, CLCT_copad
  //-------------------------------------------------------------------------------------------------------------------
  assign alct_gemA_match_found  = (|alct0_gemA_match)  || (|alct1_gemA_match);
  assign alct_gemB_match_found  = (|alct0_gemB_match)  || (|alct1_gemB_match);
  assign clct_gemA_match_found  = (|clct0_gemA_match)  || (|clct1_gemA_match);
  assign clct_gemB_match_found  = (|clct0_gemB_match)  || (|clct1_gemB_match);
  assign alct_copad_match_found = (|alct0_copad_match) || (|alct1_copad_match);
  assign clct_copad_match_found = (|clct0_copad_match) || (|clct1_copad_match);

  //-------------------------------------------------------------------------------------------------------------------
  // step1  ALCT+CLCT+Copad matching
  //ALCT-CLCT+GEM Copad match, very challenging part!, lot of combinations!
  //-------------------------------------------------------------------------------------------------------------------

  wire [2:0] alct0_clct0_copad_best_icluster;
  wire [MXBENDANGLEB-1:0] alct0_clct0_copad_best_angle;
  wire [9:0] alct0_clct0_copad_best_cscxky;
  tree_encoder_alctclctgem ualct0_clct0_copad_match(
      alct0_clct0_copad_angle[0],
      alct0_clct0_copad_angle[1],
      alct0_clct0_copad_angle[2],
      alct0_clct0_copad_angle[3],
      alct0_clct0_copad_angle[4],
      alct0_clct0_copad_angle[5],
      alct0_clct0_copad_angle[6],
      alct0_clct0_copad_angle[7],

      copad_cluster_cscxky_mi[0],
      copad_cluster_cscxky_mi[1],
      copad_cluster_cscxky_mi[2],
      copad_cluster_cscxky_mi[3],
      copad_cluster_cscxky_mi[4],
      copad_cluster_cscxky_mi[5],
      copad_cluster_cscxky_mi[6],
      copad_cluster_cscxky_mi[7],

      alct0_clct0_copad_best_cscxky,
      alct0_clct0_copad_best_angle,
      alct0_clct0_copad_best_icluster
      );

  wire [2:0] alct0_clct1_copad_best_icluster;
  wire [MXBENDANGLEB-1:0] alct0_clct1_copad_best_angle;
  wire [9:0] alct0_clct1_copad_best_cscxky;
  tree_encoder_alctclctgem ualct0_clct1_copad_match(
      alct0_clct1_copad_angle[0],
      alct0_clct1_copad_angle[1],
      alct0_clct1_copad_angle[2],
      alct0_clct1_copad_angle[3],
      alct0_clct1_copad_angle[4],
      alct0_clct1_copad_angle[5],
      alct0_clct1_copad_angle[6],
      alct0_clct1_copad_angle[7],

      copad_cluster_cscxky_mi[0],
      copad_cluster_cscxky_mi[1],
      copad_cluster_cscxky_mi[2],
      copad_cluster_cscxky_mi[3],
      copad_cluster_cscxky_mi[4],
      copad_cluster_cscxky_mi[5],
      copad_cluster_cscxky_mi[6],
      copad_cluster_cscxky_mi[7],

      alct0_clct1_copad_best_cscxky,
      alct0_clct1_copad_best_angle,
      alct0_clct1_copad_best_icluster
      );

  wire [2:0] alct1_clct0_copad_best_icluster;
  wire [MXBENDANGLEB-1:0] alct1_clct0_copad_best_angle;
  wire [9:0] alct1_clct0_copad_best_cscxky;
  tree_encoder_alctclctgem ualct1_clct0_copad_match(
      alct1_clct0_copad_angle[0],
      alct1_clct0_copad_angle[1],
      alct1_clct0_copad_angle[2],
      alct1_clct0_copad_angle[3],
      alct1_clct0_copad_angle[4],
      alct1_clct0_copad_angle[5],
      alct1_clct0_copad_angle[6],
      alct1_clct0_copad_angle[7],

      copad_cluster_cscxky_mi[0],
      copad_cluster_cscxky_mi[1],
      copad_cluster_cscxky_mi[2],
      copad_cluster_cscxky_mi[3],
      copad_cluster_cscxky_mi[4],
      copad_cluster_cscxky_mi[5],
      copad_cluster_cscxky_mi[6],
      copad_cluster_cscxky_mi[7],

      alct1_clct0_copad_best_cscxky,
      alct1_clct0_copad_best_angle,
      alct1_clct0_copad_best_icluster
      );

  wire [2:0] alct1_clct1_copad_best_icluster;
  wire [MXBENDANGLEB-1:0] alct1_clct1_copad_best_angle;
  wire [9:0] alct1_clct1_copad_best_cscxky;
  tree_encoder_alctclctgem ualct1_clct1_copad_match(
      alct1_clct1_copad_angle[0],
      alct1_clct1_copad_angle[1],
      alct1_clct1_copad_angle[2],
      alct1_clct1_copad_angle[3],
      alct1_clct1_copad_angle[4],
      alct1_clct1_copad_angle[5],
      alct1_clct1_copad_angle[6],
      alct1_clct1_copad_angle[7],

      copad_cluster_cscxky_mi[0],
      copad_cluster_cscxky_mi[1],
      copad_cluster_cscxky_mi[2],
      copad_cluster_cscxky_mi[3],
      copad_cluster_cscxky_mi[4],
      copad_cluster_cscxky_mi[5],
      copad_cluster_cscxky_mi[6],
      copad_cluster_cscxky_mi[7],

      alct1_clct1_copad_best_cscxky,
      alct1_clct1_copad_best_angle,
      alct1_clct1_copad_best_icluster
      );

  wire alct0_clct0_copad_match_any = |alct0_clct0_copad_match;
  wire alct0_clct1_copad_match_any = |alct0_clct1_copad_match;
  wire alct1_clct0_copad_match_any = |alct1_clct0_copad_match;
  wire alct1_clct1_copad_match_any = |alct1_clct1_copad_match;

  //include 1.alct0=clct0-copad, alct1-clct1-copad
  //2. alct0=clct1-copad, alct1-clct0-copad
  // alct0 is not copied to alct1 yet if alct0 is valid while alct1 is invalid
  //EMTF decouples LCT anyway and OTMB usually tries to send out different ALCT-CLCT combinations 
  assign alct0_clct0_copad_match_found = alct0_clct0_copad_match_any || alct0_clct1_copad_match_any || alct1_clct0_copad_match_any || alct1_clct1_copad_match_any;
  reg alct1_clct1_copad_match_found_r = 1'b0;
  reg swapclct_copad_match_r = 1'b0;
  reg swapalct_copad_match_r = 1'b0;

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
      end
      else begin
          alct1_clct1_copad_match_found_r <= 1'b0;
          swapclct_copad_match_r          <= 1'b0;
          swapalct_copad_match_r          <= 1'b0;
          best_cluster0_alct_clct_copad_r <= 3'b0;
          best_cluster1_alct_clct_copad_r <= 3'b0;
          best_angle0_alct_clct_copad_r   <= 10'b0;
          best_angle1_alct_clct_copad_r   <= 10'b0;
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
  wire [9:0] alct0_clct0_gemA_best_cscxky;
  tree_encoder_alctclctgem ualct0_clct0_gemA_match(
      alct0_clct0_gemA_angle[0],
      alct0_clct0_gemA_angle[1],
      alct0_clct0_gemA_angle[2],
      alct0_clct0_gemA_angle[3],
      alct0_clct0_gemA_angle[4],
      alct0_clct0_gemA_angle[5],
      alct0_clct0_gemA_angle[6],
      alct0_clct0_gemA_angle[7],

      gemA_cluster_cscxky_mi[0],
      gemA_cluster_cscxky_mi[1],
      gemA_cluster_cscxky_mi[2],
      gemA_cluster_cscxky_mi[3],
      gemA_cluster_cscxky_mi[4],
      gemA_cluster_cscxky_mi[5],
      gemA_cluster_cscxky_mi[6],
      gemA_cluster_cscxky_mi[7],

      alct0_clct0_gemA_best_cscxky,
      alct0_clct0_gemA_best_angle,
      alct0_clct0_gemA_best_icluster
      );


  wire [2:0] alct0_clct0_gemB_best_icluster;
  wire [MXBENDANGLEB-1:0] alct0_clct0_gemB_best_angle;
  wire [9:0] alct0_clct0_gemB_best_cscxky;
  tree_encoder_alctclctgem ualct0_clct0_gemB_match(
      alct0_clct0_gemB_angle[0],
      alct0_clct0_gemB_angle[1],
      alct0_clct0_gemB_angle[2],
      alct0_clct0_gemB_angle[3],
      alct0_clct0_gemB_angle[4],
      alct0_clct0_gemB_angle[5],
      alct0_clct0_gemB_angle[6],
      alct0_clct0_gemB_angle[7],

      gemB_cluster_cscxky_mi[0],
      gemB_cluster_cscxky_mi[1],
      gemB_cluster_cscxky_mi[2],
      gemB_cluster_cscxky_mi[3],
      gemB_cluster_cscxky_mi[4],
      gemB_cluster_cscxky_mi[5],
      gemB_cluster_cscxky_mi[6],
      gemB_cluster_cscxky_mi[7],

      alct0_clct0_gemB_best_cscxky,
      alct0_clct0_gemB_best_angle,
      alct0_clct0_gemB_best_icluster
      );

  wire [2:0] alct1_clct0_gemA_best_icluster;
  wire [MXBENDANGLEB-1:0] alct1_clct0_gemA_best_angle;
  wire [9:0] alct1_clct0_gemA_best_cscxky;
  tree_encoder_alctclctgem ualct1_clct0_gemA_match(
      alct1_clct0_gemA_angle[0],
      alct1_clct0_gemA_angle[1],
      alct1_clct0_gemA_angle[2],
      alct1_clct0_gemA_angle[3],
      alct1_clct0_gemA_angle[4],
      alct1_clct0_gemA_angle[5],
      alct1_clct0_gemA_angle[6],
      alct1_clct0_gemA_angle[7],

      gemA_cluster_cscxky_mi[0],
      gemA_cluster_cscxky_mi[1],
      gemA_cluster_cscxky_mi[2],
      gemA_cluster_cscxky_mi[3],
      gemA_cluster_cscxky_mi[4],
      gemA_cluster_cscxky_mi[5],
      gemA_cluster_cscxky_mi[6],
      gemA_cluster_cscxky_mi[7],

      alct1_clct0_gemA_best_cscxky,
      alct1_clct0_gemA_best_angle,
      alct1_clct0_gemA_best_icluster
      );


  wire [2:0] alct1_clct0_gemB_best_icluster;
  wire [MXBENDANGLEB-1:0] alct1_clct0_gemB_best_angle;
  wire [9:0] alct1_clct0_gemB_best_cscxky;
  tree_encoder_alctclctgem ualct1_clct0_gemB_match(
      alct1_clct0_gemB_angle[0],
      alct1_clct0_gemB_angle[1],
      alct1_clct0_gemB_angle[2],
      alct1_clct0_gemB_angle[3],
      alct1_clct0_gemB_angle[4],
      alct1_clct0_gemB_angle[5],
      alct1_clct0_gemB_angle[6],
      alct1_clct0_gemB_angle[7],

      gemB_cluster_cscxky_mi[0],
      gemB_cluster_cscxky_mi[1],
      gemB_cluster_cscxky_mi[2],
      gemB_cluster_cscxky_mi[3],
      gemB_cluster_cscxky_mi[4],
      gemB_cluster_cscxky_mi[5],
      gemB_cluster_cscxky_mi[6],
      gemB_cluster_cscxky_mi[7],

      alct1_clct0_gemB_best_cscxky,
      alct1_clct0_gemB_best_angle,
      alct1_clct0_gemB_best_icluster
      );


  wire [2:0] alct0_clct1_gemA_best_icluster;
  wire [MXBENDANGLEB-1:0] alct0_clct1_gemA_best_angle;
  wire [9:0] alct0_clct1_gemA_best_cscxky;
  tree_encoder_alctclctgem ualct0_clct1_gemA_match(
      alct0_clct1_gemA_angle[0],
      alct0_clct1_gemA_angle[1],
      alct0_clct1_gemA_angle[2],
      alct0_clct1_gemA_angle[3],
      alct0_clct1_gemA_angle[4],
      alct0_clct1_gemA_angle[5],
      alct0_clct1_gemA_angle[6],
      alct0_clct1_gemA_angle[7],

      gemA_cluster_cscxky_mi[0],
      gemA_cluster_cscxky_mi[1],
      gemA_cluster_cscxky_mi[2],
      gemA_cluster_cscxky_mi[3],
      gemA_cluster_cscxky_mi[4],
      gemA_cluster_cscxky_mi[5],
      gemA_cluster_cscxky_mi[6],
      gemA_cluster_cscxky_mi[7],

      alct0_clct1_gemA_best_cscxky,
      alct0_clct1_gemA_best_angle,
      alct0_clct1_gemA_best_icluster
      );


  wire [2:0] alct0_clct1_gemB_best_icluster;
  wire [MXBENDANGLEB-1:0] alct0_clct1_gemB_best_angle;
  wire [9:0] alct0_clct1_gemB_best_cscxky;
  tree_encoder_alctclctgem ualct0_clct1_gemB_match(
      alct0_clct1_gemB_angle[0],
      alct0_clct1_gemB_angle[1],
      alct0_clct1_gemB_angle[2],
      alct0_clct1_gemB_angle[3],
      alct0_clct1_gemB_angle[4],
      alct0_clct1_gemB_angle[5],
      alct0_clct1_gemB_angle[6],
      alct0_clct1_gemB_angle[7],

      gemB_cluster_cscxky_mi[0],
      gemB_cluster_cscxky_mi[1],
      gemB_cluster_cscxky_mi[2],
      gemB_cluster_cscxky_mi[3],
      gemB_cluster_cscxky_mi[4],
      gemB_cluster_cscxky_mi[5],
      gemB_cluster_cscxky_mi[6],
      gemB_cluster_cscxky_mi[7],

      alct0_clct1_gemB_best_cscxky,
      alct0_clct1_gemB_best_angle,
      alct0_clct1_gemB_best_icluster
      );

  wire [2:0] alct1_clct1_gemA_best_icluster;
  wire [MXBENDANGLEB-1:0] alct1_clct1_gemA_best_angle;
  wire [9:0] alct1_clct1_gemA_best_cscxky;
  tree_encoder_alctclctgem ualct1_clct1_gemA_match(
      alct1_clct1_gemA_angle[0],
      alct1_clct1_gemA_angle[1],
      alct1_clct1_gemA_angle[2],
      alct1_clct1_gemA_angle[3],
      alct1_clct1_gemA_angle[4],
      alct1_clct1_gemA_angle[5],
      alct1_clct1_gemA_angle[6],
      alct1_clct1_gemA_angle[7],

      gemA_cluster_cscxky_mi[0],
      gemA_cluster_cscxky_mi[1],
      gemA_cluster_cscxky_mi[2],
      gemA_cluster_cscxky_mi[3],
      gemA_cluster_cscxky_mi[4],
      gemA_cluster_cscxky_mi[5],
      gemA_cluster_cscxky_mi[6],
      gemA_cluster_cscxky_mi[7],

      alct1_clct1_gemA_best_cscxky,
      alct1_clct1_gemA_best_angle,
      alct1_clct1_gemA_best_icluster
      );


  wire [2:0] alct1_clct1_gemB_best_icluster;
  wire [MXBENDANGLEB-1:0] alct1_clct1_gemB_best_angle;
  wire [9:0] alct1_clct1_gemB_best_cscxky;
  tree_encoder_alctclctgem ualct1_clct1_gemB_match(
      alct1_clct1_gemB_angle[0],
      alct1_clct1_gemB_angle[1],
      alct1_clct1_gemB_angle[2],
      alct1_clct1_gemB_angle[3],
      alct1_clct1_gemB_angle[4],
      alct1_clct1_gemB_angle[5],
      alct1_clct1_gemB_angle[6],
      alct1_clct1_gemB_angle[7],

      gemB_cluster_cscxky_mi[0],
      gemB_cluster_cscxky_mi[1],
      gemB_cluster_cscxky_mi[2],
      gemB_cluster_cscxky_mi[3],
      gemB_cluster_cscxky_mi[4],
      gemB_cluster_cscxky_mi[5],
      gemB_cluster_cscxky_mi[6],
      gemB_cluster_cscxky_mi[7],

      alct1_clct1_gemB_best_cscxky,
      alct1_clct1_gemB_best_angle,
      alct1_clct1_gemB_best_icluster
      );


  wire alct0_clct0_gemA_match_any  = |alct0_clct0_gemA_match;
  wire alct0_clct1_gemA_match_any  = |alct0_clct1_gemA_match;
  wire alct1_clct0_gemA_match_any  = |alct1_clct0_gemA_match;
  wire alct1_clct1_gemA_match_any  = |alct1_clct1_gemA_match;

  wire alct0_clct0_gemB_match_any  = |alct0_clct0_gemB_match;
  wire alct0_clct1_gemB_match_any  = |alct0_clct1_gemB_match;
  wire alct1_clct0_gemB_match_any  = |alct1_clct0_gemB_match;
  wire alct1_clct1_gemB_match_any  = |alct1_clct1_gemB_match;

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

  wire alct_clct_nogem_nocopad   = alct_clct_gem_nomatch && alct_clct_copad_nomatch;
  wire alct1_clct1_nogem_nocopad = !alct1_clct1_gem_match_found && !alct1_clct1_copad_match_found;

  assign alct0_clct0_nogem_match_found = alct_clct_nogem_nocopad && alct0_vpf && clct0_vpf && !drop_lowqalct0 && !drop_lowqclct0; 

  //wire alct1_vpf_nocopad  = (swapalct_copad_match ? alct0_vpf : alct1_vpf);
  //wire alct1_vpf_nogem    = (swapalct_gem_match   ? alct0_vpf : alct1_vpf);
  //wire clct1_vpf_nocopad  = (swapclct_copad_match ? clct0_vpf : clct1_vpf);
  //wire clct1_vpf_nogem    = (swapclct_gem_match   ? clct0_vpf : clct1_vpf);

  //assign alct1_clct1_nogem_match_found = alct_clct_nogem_nocopad ? (alct1_vpf && clct1_vpf) : ((alct1_vpf_nocopad && clct1_vpf_nocopad && !alct1_clct1_copad_match_found) || (alct1_vpf_nogem && clct1_vpf_nogem && !alct1_clct1_gem_match_found)); 

  wire alct1_vpf_afterswap = (swapalct_copad_match || swapalct_gem_match) ? (alct0_vpf && !drop_lowqalct0) : (alct1_vpf && !drop_lowqalct1);
  wire clct1_vpf_afterswap = (swapclct_copad_match || swapclct_gem_match) ? (clct0_vpf && !drop_lowqclct0) : (clct1_vpf && !drop_lowqclct1);
  assign alct1_clct1_nogem_match_found = (alct1_vpf_afterswap && clct1_vpf_afterswap && alct1_clct1_nogem_nocopad);

  //-------------------------------------------------------------------------------------------------------------------
  // step4  CLCT+Copad matching
  //CLCT+GEM Copad match, very challenging part!, lot of combinations!
  //-------------------------------------------------------------------------------------------------------------------

  wire [2:0] clct0_copad_best_icluster;
  wire [MXBENDANGLEB-1:0] clct0_copad_best_angle;
  wire [9:0] clct0_copad_best_cscxky;
  tree_encoder_alctclctgem uclct0_copad_match(
      clct0_copad_angle[0],
      clct0_copad_angle[1],
      clct0_copad_angle[2],
      clct0_copad_angle[3],
      clct0_copad_angle[4],
      clct0_copad_angle[5],
      clct0_copad_angle[6],
      clct0_copad_angle[7],

      copad_cluster_cscxky_mi[0],
      copad_cluster_cscxky_mi[1],
      copad_cluster_cscxky_mi[2],
      copad_cluster_cscxky_mi[3],
      copad_cluster_cscxky_mi[4],
      copad_cluster_cscxky_mi[5],
      copad_cluster_cscxky_mi[6],
      copad_cluster_cscxky_mi[7],

      clct0_copad_best_cscxky,
      clct0_copad_best_angle,
      clct0_copad_best_icluster
      );

  wire [2:0] clct1_copad_best_icluster;
  wire [MXBENDANGLEB-1:0] clct1_copad_best_angle;
  wire [9:0] clct1_copad_best_cscxky;
  tree_encoder_alctclctgem uclct1_copad_match(
      clct1_copad_angle[0],
      clct1_copad_angle[1],
      clct1_copad_angle[2],
      clct1_copad_angle[3],
      clct1_copad_angle[4],
      clct1_copad_angle[5],
      clct1_copad_angle[6],
      clct1_copad_angle[7],

      copad_cluster_cscxky_mi[0],
      copad_cluster_cscxky_mi[1],
      copad_cluster_cscxky_mi[2],
      copad_cluster_cscxky_mi[3],
      copad_cluster_cscxky_mi[4],
      copad_cluster_cscxky_mi[5],
      copad_cluster_cscxky_mi[6],
      copad_cluster_cscxky_mi[7],

      clct1_copad_best_cscxky,
      clct1_copad_best_angle,
      clct1_copad_best_icluster
      );

  // clct1_copad match could be from 
  // no alct1 is found.

  //still need to find out wire group of GEM pad
  wire clct0_copad_match_any = ( |clct0_copad_match_ok ) && !drop_lowqclct0;
  wire clct1_copad_match_any = ( |clct1_copad_match_ok ) && !drop_lowqclct1;
  assign clct0_copad_match_found  = !alct0_vpf && (clct0_copad_match_any || clct1_copad_match_any);
  assign clct1_copad_match_found  = !alct1_vpf && ((swapclct_copad_match || swapclct_gem_match) ? clct0_copad_match_any : clct1_copad_match_any);
  //only case to swap clct0 and clct1 here: both LCTs built from CLCT+copad
  assign swapclct_clctcopad_match = clct0_copad_match_found && clct1_copad_match_found && (clct0_copad_best_angle > clct1_copad_best_angle);
  wire [2:0] best_cluster0_clct_copad_iclst = swapclct_clctcopad_match ?  clct1_copad_best_icluster : clct0_copad_best_icluster;
  wire [2:0] best_cluster1_clct_copad_iclst = swapclct_clctcopad_match ?  clct0_copad_best_icluster : clct1_copad_best_icluster;
  wire [MXBENDANGLEB-1:0] best_angle0_clct_copad = swapclct_clctcopad_match ?  clct1_copad_best_angle : clct0_copad_best_angle;
  wire [MXBENDANGLEB-1:0] best_angle1_clct_copad = swapclct_clctcopad_match ?  clct0_copad_best_angle : clct1_copad_best_angle;


  //-------------------------------------------------------------------------------------------------------------------
  // step5  ALCT+Copad matching
  //ALCT+GEM Copad match, very challenging part!, lot of combinations!
  //-------------------------------------------------------------------------------------------------------------------

  wire [2:0] alct0_copad_best_icluster;
  wire [MXBENDANGLEB-1:0] alct0_copad_best_angle;
  wire [9:0] alct0_copad_best_cscxky;
  tree_encoder_alctclctgem ualct0_copad_match(
      alct0_copad_angle[0],
      alct0_copad_angle[1],
      alct0_copad_angle[2],
      alct0_copad_angle[3],
      alct0_copad_angle[4],
      alct0_copad_angle[5],
      alct0_copad_angle[6],
      alct0_copad_angle[7],

      copad_cluster_cscxky_mi[0],
      copad_cluster_cscxky_mi[1],
      copad_cluster_cscxky_mi[2],
      copad_cluster_cscxky_mi[3],
      copad_cluster_cscxky_mi[4],
      copad_cluster_cscxky_mi[5],
      copad_cluster_cscxky_mi[6],
      copad_cluster_cscxky_mi[7],

      alct0_copad_best_cscxky,
      alct0_copad_best_angle,
      alct0_copad_best_icluster
      );

  wire [2:0] alct1_copad_best_icluster;
  wire [MXBENDANGLEB-1:0] alct1_copad_best_angle;
  wire [9:0] alct1_copad_best_cscxky;
  tree_encoder_alctclctgem ualct1_copad_match(
      alct1_copad_angle[0],
      alct1_copad_angle[1],
      alct1_copad_angle[2],
      alct1_copad_angle[3],
      alct1_copad_angle[4],
      alct1_copad_angle[5],
      alct1_copad_angle[6],
      alct1_copad_angle[7],

      copad_cluster_cscxky_mi[0],
      copad_cluster_cscxky_mi[1],
      copad_cluster_cscxky_mi[2],
      copad_cluster_cscxky_mi[3],
      copad_cluster_cscxky_mi[4],
      copad_cluster_cscxky_mi[5],
      copad_cluster_cscxky_mi[6],
      copad_cluster_cscxky_mi[7],

      alct1_copad_best_cscxky,
      alct1_copad_best_angle,
      alct1_copad_best_icluster
      );

  //assign alct0_copad_match_found  = !clct0_vpf && (alct1_copad_best_angle != MAXGEMCSCBND) || (alct1_copad_best_angle != MAXGEMCSCBND);
  //assign alct1_copad_match_found  = !clct1_vpf && (alct0_copad_best_angle != MAXGEMCSCBND) && (alct1_copad_best_angle != MAXGEMCSCBND);

  wire alct0_copad_match_any = (|alct0_copad_match) && !drop_lowqalct0;
  wire alct1_copad_match_any = (|alct1_copad_match) && !drop_lowqalct1;
  assign alct0_copad_match_found = !clct0_vpf && (alct0_copad_match_any || alct1_copad_match_any);
  assign alct1_copad_match_found = !clct1_vpf && ((swapalct_copad_match || swapalct_gem_match) ? alct0_copad_match_any : alct1_copad_match_any);//

  assign clct0xky_fromcopad = alct0_copad_best_cscxky;
  assign clct1xky_fromcopad = alct1_copad_best_cscxky;

  wire clct0_copad_match_good = clct0_copad_match_found && tmb_copad_clct_allow;
  wire alct0_copad_match_good = alct0_copad_match_found && tmb_copad_alct_allow;
  wire clct1_copad_match_good = clct1_copad_match_found && tmb_copad_clct_allow;
  wire alct1_copad_match_good = alct1_copad_match_found && tmb_copad_alct_allow;

  assign  alct0_clct0_match_found_final = alct0_clct0_copad_match_found || alct0_clct0_gem_match_found || alct0_clct0_nogem_match_found || clct0_copad_match_good || alct0_copad_match_good;
  assign  alct1_clct1_match_found_final = alct1_clct1_copad_match_found || alct1_clct1_gem_match_found || alct1_clct1_nogem_match_found || clct1_copad_match_good || alct1_copad_match_good;

  assign  swapalct_final  = swapalct_copad_match || swapalct_gem_match;
  assign  swapclct_final  = swapclct_copad_match || swapclct_gem_match || (swapclct_clctcopad_match && tmb_copad_clct_allow);

  assign  alct0fromcopad  = clct0_copad_match_good && !alct0_vpf;
  assign  alct1fromcopad  = clct1_copad_match_good && !alct1_vpf;
  assign  clct0fromcopad  = alct0_copad_match_good && !clct0_vpf;
  assign  clct1fromcopad  = alct1_copad_match_good && !clct1_vpf;

  assign  copyalct0_foralct1 = !alct1_vpf && !clct1_copad_match_good && clct1_vpf;
  assign  copyclct0_forclct1 = !clct1_vpf && !alct1_copad_match_good && alct1_vpf;

  //select the best match cluster
  assign  best_cluster0_ingemB = best_cluster0_alct_clct_gem_vpf & cluster0layer_alct_clct_gem_r;
  assign  best_cluster0_vpf    = best_cluster0_alct_clct_copad_vpf || best_cluster0_alct_clct_gem_vpf || clct0_copad_match_good || alct0_copad_match_good;
  assign  best_cluster0_iclst  = ({3{best_cluster0_alct_clct_copad_vpf}} & best_cluster0_alct_clct_copad_r) | 
                                 ({3{best_cluster0_alct_clct_gem_vpf}}   & best_cluster0_alct_clct_gem_r) | 
                                 ({3{clct0_copad_match_good}}            & best_cluster0_clct_copad_iclst) | 
                                 ({3{alct0_copad_match_good}}            & alct0_copad_best_icluster);
  assign  best_cluster0_angle  = ({MXBENDANGLEB{best_cluster0_alct_clct_copad_vpf}} & best_angle0_alct_clct_copad_r) | 
                                 ({MXBENDANGLEB{best_cluster0_alct_clct_gem_vpf}}   & best_angle0_alct_clct_gem_r) | 
                                 ({MXBENDANGLEB{clct0_copad_match_good}}            & best_angle0_clct_copad) | 
                                 ({MXBENDANGLEB{alct0_copad_match_good}}            & alct0_copad_best_angle);

  assign  best_cluster1_ingemB = best_cluster1_alct_clct_gem_vpf & cluster1layer_alct_clct_gem_r;
  assign  best_cluster1_vpf    = best_cluster1_alct_clct_copad_vpf || best_cluster1_alct_clct_gem_vpf || clct1_copad_match_good || alct1_copad_match_good;
  assign  best_cluster1_iclst  = ({3{best_cluster1_alct_clct_copad_vpf}} & best_cluster1_alct_clct_copad_r) | 
                                 ({3{best_cluster1_alct_clct_gem_vpf}}   & best_cluster1_alct_clct_gem_r) | 
                                 ({3{clct1_copad_match_good}}            & best_cluster1_clct_copad_iclst) | 
                                 ({3{alct1_copad_match_good}}            & alct1_copad_best_icluster);
  assign  best_cluster1_angle  = ({MXBENDANGLEB{best_cluster1_alct_clct_copad_vpf}} & best_angle1_alct_clct_copad_r) | 
                                 ({MXBENDANGLEB{best_cluster1_alct_clct_gem_vpf}}   & best_angle1_alct_clct_gem_r) | 
                                 ({MXBENDANGLEB{clct1_copad_match_good}}            & best_angle1_clct_copad) | 
                                 ({MXBENDANGLEB{alct1_copad_match_good}}            & alct1_copad_best_angle);


  assign  gemcsc_match_dummy = 1'b1;

  assign alct0wg_fromcopad = wgfromGEMcluster(
      clct0_copad_best_icluster
      //clct0_copad_best_icluster, 
      //gemA_cluster0_wg_mi,
      //gemA_cluster1_wg_mi,
      //gemA_cluster2_wg_mi,
      //gemA_cluster3_wg_mi,
      //gemA_cluster4_wg_mi,
      //gemA_cluster5_wg_mi,
      //gemA_cluster6_wg_mi,
      //gemA_cluster7_wg_mi
      );
  
  assign alct1wg_fromcopad = wgfromGEMcluster(
      clct1_copad_best_icluster
      //clct1_copad_best_icluster, 
      //gemA_cluster0_wg_mi,
      //gemA_cluster1_wg_mi,
      //gemA_cluster2_wg_mi,
      //gemA_cluster3_wg_mi,
      //gemA_cluster4_wg_mi,
      //gemA_cluster5_wg_mi,
      //gemA_cluster6_wg_mi,
      //gemA_cluster6_wg_mi
  );




function [6: 0] wgfromGEMcluster;
  input [2: 0] icluster;
  //input [6:0] cluster0_wg_mi;
  //input [6:0] cluster1_wg_mi;
  //input [6:0] cluster2_wg_mi;
  //input [6:0] cluster3_wg_mi;
  //input [6:0] cluster4_wg_mi;
  //input [6:0] cluster5_wg_mi;
  //input [6:0] cluster6_wg_mi;
  //input [6:0] cluster7_wg_mi;

  reg   [6: 0] wg;
  begin
    case (icluster)
        3'd0 :  wg = gemA_cluster0_wg_mi;
        3'd1 :  wg = gemA_cluster1_wg_mi;
        3'd2 :  wg = gemA_cluster2_wg_mi;
        3'd3 :  wg = gemA_cluster3_wg_mi;
        3'd4 :  wg = gemA_cluster4_wg_mi;
        3'd5 :  wg = gemA_cluster5_wg_mi;
        3'd6 :  wg = gemA_cluster6_wg_mi;
        3'd7 :  wg = gemA_cluster7_wg_mi;
    endcase

    wgfromGEMcluster = wg;
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



//-------------------------------------------------------------------------------------------------------------------
  endmodule
//-------------------------------------------------------------------------------------------------------------------

