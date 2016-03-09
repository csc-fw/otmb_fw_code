`timescale 1ns / 1ps
//-----------------------------------------------------------------------------------------------------------------
// Parameterized programmable delay
//
//  06/14/0202  Initial
//  09/18/2006  Mod for XST
//  09/25/2006  Change to while loop
//  07/09/2010  Port to ISE 12.1
//  10/05/2010  Check non-blocking operators
//-----------------------------------------------------------------------------------------------------------------
  module x_delay (d,clock,delay,q);

// Generic
  parameter  MXDLY = 4;          // Number delay value bits
  localparam MXSR  = 1 << MXDLY; // Number delay stages

  initial  $display("x_delay: MXDLY=%d",MXDLY);
  initial  $display("x_delay: MXSR =%d",MXSR );

// Ports
  input             d;
  input             clock;
  input [MXDLY-1:0] delay;
  output            q;

// Delay stages
  reg  [MXSR-1:1] sr;
  integer i;
  
  always @(posedge clock) begin
    sr[1] <= d;
    i=2;
    while (i<MXSR) begin
      sr[i] <= sr[i-1];
      i=i+1;
    end
  end

// Select delayed output
  wire [MXSR-1:0] srq;

  assign srq[0]        = d;
  assign srq[MXSR-1:1] = sr;

  assign q = srq[delay];

//-----------------------------------------------------------------------------------------------------------------
  endmodule
//-----------------------------------------------------------------------------------------------------------------
