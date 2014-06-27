`timescale 1ns / 1ps
//`define DEBUG_CYLON1 1
//--------------------------------------------------------------------------------------------------------------
//  Cylon sequence generator, one eye
//
//  10/01/2003  Initial
//  09/28/2006  Mod xst remove output ff, inferred ROM is already registered
//  10/10/2006  Replace init ff with srl
//  05/21/2007  Rename cylon9 to cylon1 to distinguish from 2-eye, add rate
//  08/11/2009  Replace 10MHz clock_vme with  40MHz clock, increase prescale counter by 2 bits
//  04/22/2010  Port to ise 11, add FF to srl output to sync with gsr
//  07/09/2010  Port to ise 12
//--------------------------------------------------------------------------------------------------------------
  module cylon1 (clock,rate,q);

// Ports
  input       clock;
  input  [1:0]  rate;
  output  [7:0]  q;

// Initialization
  wire [3:0] pdly  = 0;
  reg        ready = 0;
  wire       idly;

  SRL16E uinit (.CLK(clock),.CE(!idly),.D(1'b1),.A0(pdly[0]),.A1(pdly[1]),.A2(pdly[2]),.A3(pdly[3]),.Q(idly));

  always @(posedge clock) begin
  ready <= idly;
  end

// Scale clock down below visual fusion
  `ifndef DEBUG_CYLON1
  parameter MXPRE = 21;  `else
  parameter MXPRE = 2;
  `endif

  reg  [MXPRE-1:0] prescaler  = 0;
  wire [MXPRE-1:0] full_scale = {MXPRE{1'b1}};

  always @(posedge clock) begin
  if (ready)
  prescaler <= prescaler + rate + 1'b1;
  end
 
  wire next_adr = (prescaler==full_scale);

// ROM address pointer runs 0 to 13
  reg  [3:0] adr = 15;

  wire last_adr = (adr==13);
  
  always @(posedge clock) begin
  if (next_adr) begin
  if (last_adr) adr <= 0;
  else          adr <= adr + 1'b1;
  end
  end

// Display pattern ROM
  reg  [7:0] rom;

  always @(adr) begin
  case (adr)
  4'd0:  rom  <=  8'b00000001;
  4'd1:  rom  <=  8'b00000010;
  4'd2:  rom  <=  8'b00000100;
  4'd3:  rom  <=  8'b00001000;
  4'd4:  rom  <=  8'b00010000;
  4'd5:  rom  <=  8'b00100000;
  4'd6:  rom  <=  8'b01000000;
  4'd7:  rom  <=  8'b10000000;
  4'd8:  rom  <=  8'b01000000;
  4'd9:  rom  <=  8'b00100000;
  4'd10:  rom  <=  8'b00010000;
  4'd11:  rom  <=  8'b00001000;
  4'd12:  rom  <=  8'b00000100;
  4'd13:  rom  <=  8'b00000010;
  4'd14:  rom  <=  8'b00000001;
  4'd15:  rom  <=  8'b11111111;
  endcase
  end

  assign q = rom;

//--------------------------------------------------------------------------------------------------------------
  endmodule
//--------------------------------------------------------------------------------------------------------------
