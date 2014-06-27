`timescale 1ns / 1ps
//-------------------------------------------------------------------------------------------------------------------
// Finds best 1 of 7 1/2-strip patterns comparing all patterns simultaneously
//
//  11/08/2006  Initial
//  12/13/2006  Non-busy version
//  12/20/2006  Replace envelope hits with pattern ids
//  12/22/2006  Sort based on 6-bit patterns instead of just number of hits
//  01/10/2007  Increase pattern bits to 3 hits + 4 bends 
//  01/25/2007  Add busy logic to best_1of5.v
//  05/08/2007  Change pattern numbers 1-9 to 0-8 so lsb now implies bend direction, ignore lsb during sort
//  08/11/2010   Port to ISE 12
//  02/19/2013  Expand to best 1 of 7
//-------------------------------------------------------------------------------------------------------------------
  module best_1of7_busy
  (
  pat0, pat1, pat2, pat3, pat4, pat5, pat6,
  key0, key1, key2, key3, key4, key5, key6,
  bsy0, bsy1, bsy2, bsy3, bsy4, bsy5, bsy6,
  best_pat,
  best_key,
  best_bsy
  );

// Constants
  parameter MXPATB    =  3+4;    // Pattern bits
  parameter MXKEYB    =  5;      // Number of 1/2-strip key bits on 1 CFEB
  parameter MXKEYBX    =  8;      // Number of 1/2-strip key bits

// Ports  
  input  [MXPATB-1:0]  pat0, pat1, pat2, pat3, pat4, pat5, pat6;
  input  [MXKEYB-1:0]  key0, key1, key2, key3, key4, key5, key6;
  input          bsy0, bsy1, bsy2, bsy3, bsy4, bsy5, bsy6;

  output  [MXPATB-1:0]  best_pat;
  output  [MXKEYBX-1:0]  best_key;
  output          best_bsy;

// Stage 3: Best 1 of 7
  reg  [MXPATB-1:0]  best_pat;
  reg  [MXKEYBX-1:0]  best_key;
  reg          best_bsy;

  always @* begin
  if      ((pat6[6:1] > pat5[6:1]) &&
      (pat6[6:1] > pat4[6:1]) &&
      (pat6[6:1] > pat3[6:1]) &&
      (pat6[6:1] > pat2[6:1]) &&
      (pat6[6:1] > pat1[6:1]) &&
      (pat6[6:1] > pat0[6:1]) && !bsy6)
      begin
      best_pat  = pat6;
      best_key  = {3'd6,key6};
      best_bsy  = 0;
      end

  else if((pat5[6:1] > pat4[6:1]) &&
      (pat5[6:1] > pat3[6:1]) &&
      (pat5[6:1] > pat2[6:1]) &&
      (pat5[6:1] > pat1[6:1]) &&
      (pat5[6:1] > pat0[6:1]) && !bsy5)
      begin
      best_pat  = pat5;
      best_key  = {3'd5,key5};
      best_bsy  = 0;
      end

  else if((pat4[6:1] > pat3[6:1]) &&
      (pat4[6:1] > pat2[6:1]) &&
      (pat4[6:1] > pat1[6:1]) &&
      (pat4[6:1] > pat0[6:1]) && !bsy4)
      begin
      best_pat  = pat4;
      best_key  = {3'd4,key4};
      best_bsy  = 0;
      end

  else if((pat3[6:1] > pat2[6:1]) &&
      (pat3[6:1] > pat1[6:1]) &&
      (pat3[6:1] > pat0[6:1]) && !bsy3)
      begin
      best_pat  = pat3;
      best_key  = {3'd3,key3};
      best_bsy  = 0;
      end

  else if((pat2[6:1] > pat1[6:1]) &&
      (pat2[6:1] > pat0[6:1]) && !bsy2)
      begin
      best_pat  = pat2;
      best_key  = {3'd2,key2};
      best_bsy  = 0;
      end

  else if((pat1[6:1] > pat0[6:1]) && !bsy1)
      begin
      best_pat  = pat1;
      best_key  = {3'd1,key1};
      best_bsy  = 0;
      end

  else if (!bsy0)
      begin
      best_pat  = pat0;
      best_key  = {3'd0,key0};
      best_bsy  = 0;
      end
      
  else  begin
      best_pat  = 0;
      best_key  = 0;
      best_bsy  = 1;
      end
  end

//-------------------------------------------------------------------------------------------------------------------
  endmodule
//-------------------------------------------------------------------------------------------------------------------
