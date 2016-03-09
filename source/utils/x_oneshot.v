`timescale 1ns / 1ps
//`define DEBUG_X_ONESHOT 1
//------------------------------------------------------------------------------------------------------------------
// Digital One-Shot:
//    Produces 1-clock wide pulse when d goes high.
//    Waits for d to go low before re-triggering.
//
//  02/07/2002  Initial
//  09/15/2006  Mod for XST
//  01/13/2009  Mod for ISE 10.1i
//  04/26/2010  Mod for ISE 11.5
//  07/12/2010  Port to ISE 12, convert to nonblocking operators
//-----------------------------------------------------------------------------------------------------------------
  module x_oneshot (d,clock,q);

  input  d;
  input  clock;
  output q;

// State Machine declarations
  reg [2:0] sm;    // synthesis attribute safe_implementation of sm is "yes";
  parameter idle  =  0;
  parameter pulse =  1;
  parameter hold  =  2;

// One-shot state machine
  initial sm = idle;

  always @(posedge clock) begin
    case (sm)
      idle:    if (d) sm <= pulse;
      pulse:          sm <= hold;
      hold:    if(!d) sm <= idle;
      default:        sm <= idle;
    endcase
  end

// Output FF
  reg  q = 0;

  always @(posedge clock) begin
    q <= (sm==pulse);
  end

// Debug state machine display
`ifdef DEBUG_X_ONESHOT
  output [39:0] sm_dsp;
  reg    [39:0] sm_dsp;

  always @* begin
    case (sm)
      idle:   sm_dsp <= "idle ";
      pulse:  sm_dsp <= "pulse";
      hold:   sm_dsp <= "hold ";
      default sm_dsp <= "deflt";
    endcase
  end
`endif

//------------------------------------------------------------------------------------------------------------------
  endmodule
//------------------------------------------------------------------------------------------------------------------
