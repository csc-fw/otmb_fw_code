`timescale 1ns / 1ps
//`define DEBUG_CFEB_BIT_CHECK 1
//--------------------------------------------------------------------------------------------------------
//  Bad CFEB bit detection:
//  CFEB bits continuously high between check pluses are flagged as bad
//
//  12/10/09 Initial
//  01/13/10 Add 1bx high detection
//  08/04/10 Port to ise 12
//--------------------------------------------------------------------------------------------------------
  module cfeb_bit_check
  (
// Ports
  clock,
  reset,
  check_pulse,
  single_bx_mode,
  bit_in,
  bit_bad

//Debug
`ifdef DEBUG_CFEB_BIT_CHECK
  ,sm_dsp
`endif
  );

//--------------------------------------------------------------------------------------------------------
// Ports
//--------------------------------------------------------------------------------------------------------
  input  clock;          // 40MHz main clock
  input  reset;          // Clear stuck bit FFs
  input  check_pulse;    // Periodic checking
  input  single_bx_mode; // Check for single bx pulses
  input  bit_in;         // Bit to check
  output bit_bad;        // Bit went bad flag

// Debug
`ifdef DEBUG_CFEB_BIT_CHECK
  output [31:0] sm_dsp;  // State machine ascii
`endif

//--------------------------------------------------------------------------------------------------------
// State machine declarations
//--------------------------------------------------------------------------------------------------------
  reg [2:0] sm;  // synthesis attribute safe_implementation of sm is "yes";
  parameter idle = 0;
  parameter high = 1;
  parameter hold = 2;

// Status
  assign bit_bad        = (sm==hold);                                 // bit went bad
  wire   bit_went_high  =  bit_in && (check_pulse || single_bx_mode); // bit was high on a check pulse
  wire   bit_still_high =  bit_went_high || single_bx_mode;           // bit still high on next check pulse
  wire   bit_dropped    = !bit_in;                                    // bit went low

//--------------------------------------------------------------------------------------------------------
// Bad-bit detection state machine
//--------------------------------------------------------------------------------------------------------
  initial sm = idle;

  always @(posedge clock) begin
    if (reset) sm <= idle;
    else begin
      case (sm)
        idle: if (bit_went_high) sm <= high; // bit is high on a check pulse, wait for it to drop

        high: if      (bit_still_high) sm <= hold; // bit still high at next check, so its bad
              else if (bit_dropped)   sm <= idle; // it dropped, so its ok

        hold: sm <= hold; // stay here until reset
        
        default: sm <= idle;
      endcase
    end
  end

//--------------------------------------------------------------------------------------------------------
// Debug
//--------------------------------------------------------------------------------------------------------
`ifdef DEBUG_CFEB_BIT_CHECK
  reg [31:0] sm_dsp;
  
  always @* begin
    case (sm)
      idle:     sm_dsp <= "idle";
      high:     sm_dsp <= "high";
      hold:     sm_dsp <= "hold";
      default: sm_dsp <= "deft";
    endcase
  end

`endif
//--------------------------------------------------------------------------------------------------------
endmodule
//--------------------------------------------------------------------------------------------------------
