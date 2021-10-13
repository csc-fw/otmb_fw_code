`timescale 1ns / 1ps

// sort CLCT-gem bending angle, pick the small one 
// should add ALCT-CLCT-GEM match
// one option to fix time constraints
module  tree_encoder_alctcopad_TR(
  //input clock,
  input [9:0] win_pri_0 , // bending angle in gem-clct match
  input [9:0] win_pri_1 ,
  input [9:0] win_pri_2 ,
  input [9:0] win_pri_3 ,
  input [9:0] win_pri_4 ,
  input [9:0] win_pri_5 ,
  input [9:0] win_pri_6 ,
  input [9:0] win_pri_7 ,

  input [9:0] gem_xky_0 ,
  input [9:0] gem_xky_1 ,
  input [9:0] gem_xky_2 ,
  input [9:0] gem_xky_3 ,
  input [9:0] gem_xky_4 ,
  input [9:0] gem_xky_5 ,
  input [9:0] gem_xky_6 ,
  input [9:0] gem_xky_7 ,

  output [9:0] gem_xky_best,
  output [9:0] pri_best,
  output [2:0] win_best

  );


  wire [0:0] win_s1  [3:0];        // Tree encoder Finds best 4 of 16 window positions
  reg  [2:0] win_s2  [0:0];

  wire [9:0] pri_s1  [3:0];
  reg  [9:0] pri_s2  [0:0];

  wire [9:0] gem_xky_s1 [3:0];
  reg  [9:0] gem_xky_s2 [0:0];

  assign {pri_s1[3],gem_xky_s1[3],win_s1[3]} = (win_pri_7 < win_pri_6 ) ? {win_pri_7,gem_xky_7 ,1'b1} : {win_pri_6,gem_xky_6 ,1'b0};
  assign {pri_s1[2],gem_xky_s1[2],win_s1[2]} = (win_pri_5 < win_pri_4 ) ? {win_pri_5,gem_xky_5 ,1'b1} : {win_pri_4,gem_xky_4 ,1'b0};
  assign {pri_s1[1],gem_xky_s1[1],win_s1[1]} = (win_pri_3 < win_pri_2 ) ? {win_pri_3,gem_xky_3 ,1'b1} : {win_pri_2,gem_xky_2 ,1'b0};
  assign {pri_s1[0],gem_xky_s1[0],win_s1[0]} = (win_pri_1 < win_pri_0 ) ? {win_pri_1,gem_xky_1 ,1'b1} : {win_pri_0,gem_xky_0 ,1'b0};


  //
  //Line 53: Signal <gem_xky_s1> missing in the sensitivity list is added for synthesis purposes. HDL and post-synthesis simulations may differ as a result.
  always @(pri_s1[0] or win_s1[0] or gem_xky_s1[0]) begin
  //always @(posedge clock) begin
  if      ((pri_s1[3] < pri_s1[2]) &&
      (pri_s1[3] < pri_s1[1]) &&
      (pri_s1[3] < pri_s1[0]))
      begin
      pri_s2[0]  = pri_s1[3];
      win_s2[0]  = {2'd3,win_s1[3]};
      gem_xky_s2[0] = gem_xky_s1[3];
      end

  else if((pri_s1[2] < pri_s1[1]) &&
      (pri_s1[2] < pri_s1[0]))
      begin
      pri_s2[0]  = pri_s1[2];
      win_s2[0]  = {2'd2,win_s1[2]};
      gem_xky_s2[0] = gem_xky_s1[2];
      end

  else if(pri_s1[1] < pri_s1[0])
      begin
      pri_s2[0]  = pri_s1[1];
      win_s2[0]  = {2'd1,win_s1[1]};
      gem_xky_s2[0] = gem_xky_s1[1];
      end
  else
      begin
      pri_s2[0]  = pri_s1[0];
      win_s2[0]  = {2'd0,win_s1[0]};
      gem_xky_s2[0] = gem_xky_s1[0];
      end
  end

  assign win_best = win_s2[0];
  assign pri_best = pri_s2[0];
  assign gem_xky_best = gem_xky_s2[0];


//-------------------------------------------------------------------------------------------------------------------
  endmodule
//-------------------------------------------------------------------------------------------------------------------
