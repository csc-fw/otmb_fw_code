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
//  20/07/2020  create one for ccLUT algorithm
//-------------------------------------------------------------------------------------------------------------------
  module best_1of5_busy_ccLUT
  (
  input  [MXPATB -1:0]  pat0   , pat1   , pat2   , pat3   , pat4   ,
  input  [MXKEYB -1:0]  key0   , key1   , key2   , key3   , key4   ,
  input  [MXOFFSB-1:0]  offs0  , offs1  , offs2  , offs3  , offs4  ,
  input  [MXQLTB -1:0]  qlt0   , qlt1   , qlt2   , qlt3   , qlt4   ,
  input  [MXBNDB -1:0]  bend0  , bend1  , bend2  , bend3  , bend4  ,
  input  [MXPATC -1:0]  carry0 , carry1 , carry2 , carry3 , carry4 ,

  input                bsy0  , bsy1  , bsy2  , bsy3  , bsy4  ,

  output reg [MXPATB -1:0] best_pat,
  output reg [MXKEYBX-1:0] best_key,
  output reg [MXBNDB -1:0] best_bend,
  output reg [MXPATC -1:0] best_carry,
  output reg [MXXKYB -1:0] best_subkey,
  output reg [MXQLTB -1:0] best_qlt,
  output reg               best_bsy
  );

// Constants

`include "pattern_params.v"

reg [MXOFFSB-1:0] best_offs;

// Choose bits to sort on, either sortable pattern or post-fit quality

  wire [5:0] sort_key0 = (PATLUT && SORT_ON_PATLUT) ? qlt0 : pat0[6:1];
  wire [5:0] sort_key1 = (PATLUT && SORT_ON_PATLUT) ? qlt1 : pat1[6:1];
  wire [5:0] sort_key2 = (PATLUT && SORT_ON_PATLUT) ? qlt2 : pat2[6:1];
  wire [5:0] sort_key3 = (PATLUT && SORT_ON_PATLUT) ? qlt3 : pat3[6:1];
  wire [5:0] sort_key4 = (PATLUT && SORT_ON_PATLUT) ? qlt4 : pat4[6:1];

// Stage 3: Best 1 of 7

  always @* begin
  if((sort_key4 > sort_key3) &&
          (sort_key4 > sort_key2) &&
          (sort_key4 > sort_key1) &&
          (sort_key4 > sort_key0) && !bsy4)
      begin
      best_pat   = pat4;
      //best_key   = {3'd4,key4};
      best_key   = {3'd4,key4} + offs4[3:2]+(offs4[1]&offs4[0])-8'd2;
      best_qlt   = qlt4;
      best_bend  = bend4;
      best_carry = carry4;
      best_offs  = offs4;
      best_bsy   = 0;
      end

  else if((sort_key3 > sort_key2) &&
          (sort_key3 > sort_key1) &&
          (sort_key3 > sort_key0) && !bsy3)
      begin
      best_pat   = pat3;
      best_qlt   = qlt3;
      best_bend  = bend3;
      best_carry = carry3;
      best_offs  = offs3;
      best_key   = {3'd3,key3} + offs3[3:2]+(offs3[1]&offs3[0])-8'd2;
      //best_key   = {3'd3,key3};
      best_bsy   = 0;
      end

  else if((sort_key2 > sort_key1) &&
          (sort_key2 > sort_key0) && !bsy2)
      begin
      best_pat   = pat2;
      best_qlt   = qlt2;
      best_bend  = bend2;
      best_carry = carry2;
      best_offs  = offs2;
      best_key   = {3'd2,key2} + offs2[3:2]+(offs2[1]&offs2[0])-8'd2;
      ///best_key   = {3'd2,key2};
      best_bsy   = 0;
      end

  else if((sort_key1 > sort_key0) && !bsy1)
      begin
      best_pat   = pat1;
      best_qlt   = qlt1;
      best_bend  = bend1;
      best_carry = carry1;
      best_offs  = offs1;
      //best_key   = {3'd1,key1};
      best_key   = {3'd1,key1} + offs1[3:2]+(offs1[1]&offs1[0])-8'd2;
      best_bsy   = 0;
      end

  else if (!bsy0)
      begin
      best_pat   = pat0;
      best_qlt   = qlt0;
      best_bend  = bend0;
      best_carry = carry0;
      best_offs  = offs0;
      //best_key   = {3'd0,key0};
      best_key   = {3'd0,key0} + offs0[3:2]+(offs0[1]&offs0[0])-8'd2;
      best_bsy   = 0;
      end

  else  begin
      best_pat   = 0;
      best_key   = 0;
      best_qlt   = 0;
      best_bend  = 0;
      best_carry = 0;
      best_offs  = 0;
      best_bsy   = 1;
      end
  end

  //wire signed [MXOFFSB -1:0] best_offs_signed   = best_offs;
  //wire signed [MXKEYBX -1:0] best_key_signed    = best_key;
  //wire        [MXXKYB  -1:0] best_subkey_signed = 4*best_key_signed + best_offs_signed;

  //always @(*) begin
  //  if      ((best_key==0   && best_offs<=0) || (best_key==1   && best_offs<=-4))
  //    best_subkey <= 0;
  //  else if ((best_key==127 && best_offs>=3) || (best_key==126 && best_offs>= 7))
  //    best_subkey <= 127*4+3;
  //  else if ((best_key==128 && best_offs<=0) || (best_key==129 && best_offs<=-4))
  //    best_subkey <= 128*4;
  //  else if ((best_key==223 && best_offs>=3) || (best_key==222 && best_offs>= 7))
  //    best_subkey <= 223*4+3;
  //  else
  //    best_subkey <= best_subkey_signed;
  //end

  always @(*) begin
      best_subkey <= {best_key, best_offs[1:0]+1'b1};// 
      //best_subkey <= {best_key, best_offs[1:0]+1'b1} + 1;// 
  end 
//-------------------------------------------------------------------------------------------------------------------
  endmodule
//-------------------------------------------------------------------------------------------------------------------
