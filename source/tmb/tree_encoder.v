`timescale 1ns / 1ps


module  tree_encoder(
  input [3:0] win_pri_0 ,
  input [3:0] win_pri_1 ,
  input [3:0] win_pri_2 ,
  input [3:0] win_pri_3 ,
  input [3:0] win_pri_4 ,
  input [3:0] win_pri_5 ,
  input [3:0] win_pri_6 ,
  input [3:0] win_pri_7 ,
  input [3:0] win_pri_8 ,
  input [3:0] win_pri_9 ,
  input [3:0] win_pri_10,
  input [3:0] win_pri_11,
  input [3:0] win_pri_12,
  input [3:0] win_pri_13,
  input [3:0] win_pri_14,
  input [3:0] win_pri_15,

  output [3:0] clct_win_best,
  output [3:0] clct_pri_best

  );


  wire [0:0] win_s0  [7:0];        // Tree encoder Finds best 4 of 16 window positions
  wire [1:0] win_s1  [3:0];

  wire [3:0] pri_s0  [7:0];
  wire [3:0] pri_s1  [3:0];

  assign {pri_s0[7],win_s0[7]} = (win_pri_15 > win_pri_14) ? {win_pri_15,1'b1} : {win_pri_14,1'b0};
  assign {pri_s0[6],win_s0[6]} = (win_pri_13 > win_pri_12) ? {win_pri_13,1'b1} : {win_pri_12,1'b0};
  assign {pri_s0[5],win_s0[5]} = (win_pri_11 > win_pri_10) ? {win_pri_11,1'b1} : {win_pri_10,1'b0};
  assign {pri_s0[4],win_s0[4]} = (win_pri_9  > win_pri_8 ) ? {win_pri_9 ,1'b1} : {win_pri_8 ,1'b0};
  assign {pri_s0[3],win_s0[3]} = (win_pri_7  > win_pri_6 ) ? {win_pri_7 ,1'b1} : {win_pri_6 ,1'b0};
  assign {pri_s0[2],win_s0[2]} = (win_pri_5  > win_pri_4 ) ? {win_pri_5 ,1'b1} : {win_pri_4 ,1'b0};
  assign {pri_s0[1],win_s0[1]} = (win_pri_3  > win_pri_2 ) ? {win_pri_3 ,1'b1} : {win_pri_2 ,1'b0};
  assign {pri_s0[0],win_s0[0]} = (win_pri_1  > win_pri_0 ) ? {win_pri_1 ,1'b1} : {win_pri_0 ,1'b0};

  assign {pri_s1[3],win_s1[3]} = (pri_s0[7] > pri_s0[6]) ? {pri_s0[7],{1'b1,win_s0[7]}} : {pri_s0[6],{1'b0,win_s0[6]}};
  assign {pri_s1[2],win_s1[2]} = (pri_s0[5] > pri_s0[4]) ? {pri_s0[5],{1'b1,win_s0[5]}} : {pri_s0[4],{1'b0,win_s0[4]}};
  assign {pri_s1[1],win_s1[1]} = (pri_s0[3] > pri_s0[2]) ? {pri_s0[3],{1'b1,win_s0[3]}} : {pri_s0[2],{1'b0,win_s0[2]}};
  assign {pri_s1[0],win_s1[0]} = (pri_s0[1] > pri_s0[0]) ? {pri_s0[1],{1'b1,win_s0[1]}} : {pri_s0[0],{1'b0,win_s0[0]}};

  reg  [3:0] win_s2 [0:0];          // Parallel encoder finds best 1-of-4 window positions
  reg  [3:0] pri_s2 [0:0];

  always @(pri_s1[0] or win_s1[0]) begin
  if      ((pri_s1[3] > pri_s1[2]) &&
      (pri_s1[3] > pri_s1[1]) &&
      (pri_s1[3] > pri_s1[0]))
      begin
      pri_s2[0]  = pri_s1[3];
      win_s2[0]  = {2'd3,win_s1[3]};
      end

  else if((pri_s1[2] > pri_s1[1]) &&
      (pri_s1[2] > pri_s1[0]))
      begin
      pri_s2[0]  = pri_s1[2];
      win_s2[0]  = {2'd2,win_s1[2]};
      end

  else if(pri_s1[1] > pri_s1[0])
      begin
      pri_s2[0]  = pri_s1[1];
      win_s2[0]  = {2'd1,win_s1[1]};
      end
  else
      begin
      pri_s2[0]  = pri_s1[0];
      win_s2[0]  = {2'd0,win_s1[0]};
      end
  end

  assign clct_win_best = win_s2[0];
  assign clct_pri_best = pri_s2[0];


//-------------------------------------------------------------------------------------------------------------------
  endmodule
//-------------------------------------------------------------------------------------------------------------------
