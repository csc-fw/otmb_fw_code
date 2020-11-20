`timescale 1ns / 1ps
// the module is to check ALCT, CLCT, GEM position matching

module  tree_encoder(
    
  input alct0_vpf,
  input alct1_vpf,

  input [6:0] alct0_wg,
  input [6:0] alct1_wg,

  input clct0_vpf,
  input clct1_vpf,
  input [9:0] clct0_xky,
  input [9:0] clct1_xky,

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

  output  alct0_gemA_match_pos,
  output  alct0_gemB_match_pos,
  output  alct0_copad_match_pos,
  output  alct1_gemA_match_pos,
  output  alct1_gemB_match_pos,
  output  alct1_copad_match_pos,
  output  clct0_gemA_match_pos,
  output  clct0_gemB_match_pos,
  output  clct0_copad_match_pos,
  output  clct1_gemA_match_pos,
  output  clct1_gemB_match_pos,
  output  clct1_copad_match_pos,

  output  clct0_gem_bending,
  output  clct1_gem_bending,
  output [3:0] pri_best

  );

  parameter MXCLUSTER_CHAMBER       = 8; // Num GEM clusters  per Chamber
  parameter MXCLUSTER_SUPERCHAMBER  = 16; //Num GEM cluster  per superchamber

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

  wire [MXCLUSTER_CHAMBER-1:0] alct0_gemA_match; 
  wire [MXCLUSTER_CHAMBER-1:0] alct1_gemA_match; 
  wire [MXCLUSTER_CHAMBER-1:0] clct0_gemA_match; 
  wire [MXCLUSTER_CHAMBER-1:0] clct1_gemA_match; 

  wire [MXCLUSTER_CHAMBER-1:0] alct0_gemB_match; 
  wire [MXCLUSTER_CHAMBER-1:0] alct1_gemB_match; 
  wire [MXCLUSTER_CHAMBER-1:0] clct0_gemB_match; 
  wire [MXCLUSTER_CHAMBER-1:0] clct1_gemB_match; 

  wire [MXCLUSTER_CHAMBER-1:0] alct0_clct0_gem_match; 
  wire [MXCLUSTER_CHAMBER-1:0] alct0_clct1_gem_match; 
  wire [MXCLUSTER_CHAMBER-1:0] alct1_clct0_gem_match; 
  wire [MXCLUSTER_CHAMBER-1:0] alct1_clct1_gem_match; 

  wire [MXCLUSTER_CHAMBER-1:0] alct0_clct0_copad_match; 
  wire [MXCLUSTER_CHAMBER-1:0] alct0_clct1_copad_match; 
  wire [MXCLUSTER_CHAMBER-1:0] alct1_clct0_copad_match; 
  wire [MXCLUSTER_CHAMBER-1:0] alct1_clct1_copad_match; 

  genvar i;
  generate
  for (i=0; i<MXCLUSTER_CHAMBER; i=i+1) begin: gem_csc_match
      alct0_gemA_match[i] = alct0_vpf && gemA_vpf[i] && alct0_wg  >= gemA_cluster_cscwg_lo[i]  && alct0_wg  <= gemA_cluster_cscwg_hi[i]; 
      alct1_gemA_match[i] = alct1_vpf && gemA_vpf[i] && alct1_wg  >= gemA_cluster_cscwg_lo[i]  && alct1_wg  <= gemA_cluster_cscwg_hi[i]; 
      clct0_gemA_match[i] = clct0_vpf && gemA_vpf[i] && clct0_xky >= gemA_cluster_cscxky_lo[i] && clct0_xky <= gemA_cluster_cscxky_hi[i]; 
      clct1_gemA_match[i] = clct1_vpf && gemA_vpf[i] && clct1_xky >= gemA_cluster_cscxky_lo[i] && clct1_xky <= gemA_cluster_cscxky_hi[i]; 
      alct0_gemB_match[i] = alct0_vpf && gemB_vpf[i] && alct0_wg  >= gemB_cluster_cscwg_lo[i]  && alct0_wg  <= gemB_cluster_cscwg_hi[i]; 
      alct1_gemB_match[i] = alct1_vpf && gemB_vpf[i] && alct1_wg  >= gemB_cluster_cscwg_lo[i]  && alct1_wg  <= gemB_cluster_cscwg_hi[i]; 
      clct0_gemB_match[i] = clct0_vpf && gemB_vpf[i] && clct0_xky >= gemB_cluster_cscxky_lo[i] && clct0_xky <= gemB_cluster_cscxky_hi[i]; 
      clct1_gemB_match[i] = clct1_vpf && gemB_vpf[i] && clct1_xky >= gemB_cluster_cscxky_lo[i] && clct1_xky <= gemB_cluster_cscxky_hi[i]; 

      alct0_copad_match[i] = alct0_gemA_match[i] && copad_match[i];
      alct1_copad_match[i] = alct1_gemA_match[i] && copad_match[i];
      clct0_copad_match[i] = clct0_gemA_match[i] && copad_match[i];
      clct1_copad_match[i] = clct1_gemA_match[i] && copad_match[i];

      alct0_clct0_gem_match[i] = (alct0_gemA_match[i] && clct0_gemA_match[i]) || (alct0_gemB_match[i] && clct0_gemB_match[i]);
      alct0_clct1_gem_match[i] = (alct0_gemA_match[i] && clct1_gemA_match[i]) || (alct0_gemB_match[i] && clct1_gemB_match[i]);
      alct1_clct0_gem_match[i] = (alct1_gemA_match[i] && clct0_gemA_match[i]) || (alct1_gemB_match[i] && clct0_gemB_match[i]);
      alct1_clct1_gem_match[i] = (alct1_gemA_match[i] && clct1_gemA_match[i]) || (alct1_gemB_match[i] && clct1_gemB_match[i]);

      alct0_clct0_copad_match[i] = alct0_copad_match[i] && clct0_copad_match[i];
      alct0_clct1_copad_match[i] = alct0_copad_match[i] && clct1_copad_match[i];
      alct1_clct0_copad_match[i] = alct1_copad_match[i] && clct0_copad_match[i];
      alct1_clct1_copad_match[i] = alct1_copad_match[i] && clct1_copad_match[i];

    end
  endgenerate 



//-------------------------------------------------------------------------------------------------------------------
  endmodule
//-------------------------------------------------------------------------------------------------------------------
