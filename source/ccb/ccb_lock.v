`timescale 1ns / 1ps
//`define DEBUG_CCB_LOCK 1
//-------------------------------------------------------------------------------------------------------------------
// Monitors TTC PLL lock signals from CCB
//
//  08/27/2008  Initial
//  04/22/2009  Add sm recovery state
//  07/23/2010  Port to ISE 12
//  07/26/2010  Change to non-blocking operators
//  07/28/2010  Change integer lengths
//-------------------------------------------------------------------------------------------------------------------
  module ccb_lock
  (  
  clock,
  lock,
  reset,
  lock_never,
  lost_ever,
  lost_cnt

`ifdef DEBUG_CCB_LOCK , lock_sm_dsp `endif
  );

// Ports
  input  clock;        // TMB main 40MHz clock
  input  lock;        // Lock signal from TTC
  input  reset;        // Reset FFs and counter
  output  lock_never;      // Lock never achieved
  output  lost_ever;      // Lock was lost at least once
  output  lost_cnt;      // Number of times lock has been lost

// State Machine declarations
  reg  [2:0] lock_sm;      // synthesis attribute safe_implementation of lock_sm is "yes";

  parameter wait_lock  = 0;  // waiting for lock to go high
  parameter have_lock  = 1;  // lock went high
  parameter lost_lock = 2;  // lock was high but later went low

// Lock tracking state machine
  initial lock_sm = wait_lock;

  always @(posedge clock) begin
  if (reset)  lock_sm <= wait_lock;
  else begin
  case (lock_sm)

  wait_lock:
   if (lock)  lock_sm  <= have_lock;

  have_lock:
   if (!lock)  lock_sm  <= lost_lock;

  lost_lock:  lock_sm <= wait_lock;

  default    lock_sm  <= wait_lock;
  endcase
  end
  end

// Locked never
  reg lock_never=1;

  wire locked = (lock_sm==have_lock);

  always @(posedge clock) begin
  if    (reset ) lock_never <= 1;
  else if  (locked) lock_never <= 0;
  end

// Lock lost count
  reg [7:0] lost_cnt=0;
  
  wire ovf    = (lost_cnt == 8'hFF);
  wire lost   = (lock_sm  == lost_lock);
  wire cnt_en =  lost && !ovf;

  always @(posedge clock) begin
  if    (reset ) lost_cnt <= 0;
  else if (cnt_en) lost_cnt <= lost_cnt+1'b1;
  end

// Lock ever lost, at least once
  reg lost_ever=0;
  
  always @(posedge clock) begin
  if    (reset) lost_ever <= 0;
  else if  (lost ) lost_ever <= 1;
  end

// Debug
`ifdef DEBUG_CCB_LOCK
  output [39:0] lock_sm_dsp;
  reg    [39:0] lock_sm_dsp;

  always @* begin
  case (lock_sm)
  wait_lock:  lock_sm_dsp <= "wait";
  have_lock:  lock_sm_dsp <= "have";
  lost_lock:  lock_sm_dsp <= "lost";
  default    lock_sm_dsp <= "errs";
  endcase
  end
`endif

//-------------------------------------------------------------------------------------------------------------------
  endmodule
//-------------------------------------------------------------------------------------------------------------------
