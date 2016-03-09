`timescale 1ns / 1ps
//`define DEBUG_X_FLASHSM 1
//------------------------------------------------------------------------------------------------------------------
//
//  LED Flash Pulse Generator
//
//  Produces a 13mS pulse on trigger's rising edge by dividing
//  the 40MHZ clock by 2*19.
//
//  11/21/1997  Initial
//  02/03/1998  Added output persistence
//  03/26/1998   Added reset f/f, reduced output width to 13mS
//  06/08/1999  Ported from LCT48 version. Moved trigger from clk to d input
//  08/17/1999  Added hold state
//  10/04/2001  Converted to Verilog
//  10/04/2001  Changed to synchronous design
//  10/16/2001  Changed to x_dff
//  10/19/2001  Changed to x_counter
//  11/26/2001  Fixed trigger x_dff call
//  03/08/2002  Replaced library calls with behavioral code
//  09/23/2005  Mod for ISE 7.1i
//  09/23/2005  Re-write as state machine
//  09/28/2006  XST 8.2 mods, x_flash(11) becomes x_flashsm(19) for same 13ms flash
//  04/26/2010  Mod for ise 11
//  07/12/2010  Port to ise 12, convert to non-blocking operators
//  10/05/2010  Add debug count length, add reg inits
//------------------------------------------------------------------------------------------------------------------
  module x_flashsm (trigger,hold,clock,out);

// Generic
  `ifndef DEBUG_X_FLASHSM  parameter MXCNT = 19; `endif  // Normal persistence counter width
  `ifdef  DEBUG_X_FLASHSM  parameter MXCNT =  2; `endif  // Debug  persistence counter width
  initial  $display("x_flashsm: MXCNT=%d",MXCNT);

// Ports
  input  trigger; // Start flash
  input  hold;    // Hold led on
  input  clock;   // Counter clock
  output out;     // LED drive

// State Machine declaration
  reg [2:0] flash_sm;
  parameter idle  = 0;
  parameter flash = 1;
  parameter hwait = 2;

  // synthesis attribute safe_implementation of flash_sm is "yes";
  // synthesis attribute init                of flash_sm is idle;

// Buffer input
  reg trig_ff=0;
  reg hold_ff=0;

  always @(posedge clock) begin
    trig_ff <= trigger;
    hold_ff <= hold | trigger;
  end

// Buffer output
  reg out=0;

  always @(posedge clock) begin
    out <= (flash_sm != idle);
  end

// Flash persistence counter
  reg [MXCNT:0] cnt=0;

  always @(posedge clock) begin
    if (flash_sm != flash) cnt <= 0;
    else                   cnt <= cnt+1'b1;
  end

  wire cnt_done = cnt[MXCNT];

// Flash state machine
  wire sm_reset = !((flash_sm==idle) || (flash_sm==flash) || (flash_sm==hwait));

  always @(posedge clock) begin
    if (sm_reset) flash_sm <= idle;
    else begin
      case (flash_sm)
        idle:  if (trig_ff )  flash_sm <= flash;
        flash: if (cnt_done)  flash_sm <= hwait;
        hwait: if (!hold_ff)  flash_sm <= idle;
      endcase
    end
  end

// Debug state machine display
`ifdef DEBUG_X_FLASHSM
  output reg [39:0] flash_sm_dsp;

  always @* begin
    case (flash_sm)
      idle:   flash_sm_dsp <= "idle ";
      flash:  flash_sm_dsp <= "flash";
      hwait:  flash_sm_dsp <= "hwait";
      default flash_sm_dsp <= "deflt";
    endcase
  end
`endif

//------------------------------------------------------------------------------------------------------------------
  endmodule
//------------------------------------------------------------------------------------------------------------------
