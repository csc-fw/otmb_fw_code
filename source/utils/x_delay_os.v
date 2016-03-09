`timescale 1ns / 1ps
//-----------------------------------------------------------------------------------------------------------------
// Digital One-Shot with parameterized programmable delay:
//    Produces delayed 1-clock wide pulse when d goes high.
//    Waits for d to go low before re-triggering.
//
//  05/31/2002  Initial
//  09/25/2006  XST mods
//  07/09/2010  Port to ISE 12
//  10/05/2010  Check non-blocking operators, add reg init
//-----------------------------------------------------------------------------------------------------------------
  module x_delay_os (d,clock,delay,q);
  
// Generic
  parameter  MXDLY =  4;          // Number delay value bits
  localparam MXSR  =  1 << MXDLY; // Number delay stages

  initial  $display("x_delay_os: MXDLY=%d",MXDLY);
  initial  $display("x_delay_os: MXSR =%d",MXSR );

// Ports
  input              d;
  input              clock;
  input  [MXDLY-1:0] delay;
  output             q;

// Inhibit one-shot clips inputs to 1 clock width
  reg  inhibit=0;

  always @(posedge clock) begin
    inhibit <= d;
  end

  wire d_oneshot = (d & ~inhibit);

// Delay stages
  reg  [MXSR-1:1] sr;
  integer i;

  always @(posedge clock) begin
    sr[1] <= d_oneshot;
    i=2;
    while (i<MXSR) begin
      sr[i] <= sr[i-1];
      i=i+1;
    end
  end

// Select delayed output
  wire [MXSR-1:0] srq;
  
  assign srq[0]        = d_oneshot;
  assign srq[MXSR-1:1] = sr;

  assign q = srq[delay];

//-----------------------------------------------------------------------------------------------------------------
  endmodule
//-----------------------------------------------------------------------------------------------------------------
