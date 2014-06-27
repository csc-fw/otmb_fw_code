`timescale 1ns / 1ps
//`define DEBUG_DSN_TMB 1
//--------------------------------------------------------------------------------------------------------------
// DSN
//
// Digital Serial Number Reader for TMB mezzanine and main board
//
//  12/18/2001  Initial
//  12/19/2001  Cycle time is now the same for write 1 and write 0, >120us
//  03/12/2002  Replaced library calls with behavioral code
//  12/04/2003  Added non-bidir I/Os for RAT
//  12/11/2003  Add global reset
//  04/26/2004  Rename gbl_reset
//  09/22/2006  Mod for xst
//  09/29/2006  Add ratmode disconnect for dsn_io
//  04/27/2009  Add safe implementation to state machine
//  08/11/2009  Modify to use 1x clock instead of 1/4x vme clock
//  08/20/2010  Port to ise 12, replace blocking with non-blocking operators, add debug display
//  08/20/2010  Rebuild bidir io with conditional generate
//  08/26/2010  Move reg for non debug version, add generate block names for ise 8
//  08/26/2010  Push inverter to input side of dsn_out ff, was getting map warnings
//  09/10/2010  Invert rat output
//  12/16/2010  Separate rat and tmb dsn modules
//  12/17/2010  Remove dsn_io pullup, hdl pullup causes wrong bonded iob count
//--------------------------------------------------------------------------------------------------------------
  module dsn_tmb
  (
  clock,
  global_reset,
  start,
  dsn_io,
  wr_data,
  wr_init,
  busy,
  rd_data

  `ifdef DEBUG_DSN_TMB
  ,dsn_sm_dsp
  ,count_done
  ,write_done
  ,latch_data
  ,end_count
  ,end_write
  ,count
  `endif
  );
//--------------------------------------------------------------------------------------------------------------
// Generic
//--------------------------------------------------------------------------------------------------------------
// Counter widths
  parameter MXCNT    =  17;    // Main counter dimension
  parameter MXEND    =  5;    // End counter width, log2(mxcnt)+1
  parameter CNT_BUSY  =  16;    // Init  busy duration
  parameter CNT_INIT  =  15;    // Init  pulse duration,          low for 900 uS
  parameter CNT_SLOT  =  13;    // Slot duration          low for >120us
  parameter CNT_LONG  =  12;    // Long  pulse duration, logic 0, low for 102 uS
  parameter CNT_SHORT  =  6;    // Short pulse duration, logic 1, low for 1.6 uS
  parameter CNT_READ  =  8;    // Master Read delay              latch at 12 uS

// Ports
  input   clock;          // 40MHz clock
  input  global_reset;      // Global reset
  input  start;          // Begin counting
  inout  dsn_io;          // DSN chip I/O pin
  input  wr_data;        // DSN data bit to output
  input  wr_init;        // DSN init mode
  output  busy;          // DSN chip is busy
  output  rd_data;        // DSN data read from chip

// Debug
  `ifdef DEBUG_DSN_TMB
  output  count_done;
  output  write_done;
  output  latch_data;
  output  [MXEND-1:0] end_count;
  output  [MXEND-1:0] end_write;
  output  [MXCNT-1:0] count;
  `endif

// State Machine declarations
  reg [5:0] dsn_sm;  // synthesis attribute safe_implementation of dsn_sm is "yes";

  parameter idle    =  0;
  parameter pulse    =  1;
  parameter wait1    =  2;
  parameter latch    =  3;
  parameter hold    =  4;
  parameter unstart  =  5;

// Terminal count controls pulse width
  reg [MXEND-1:0] end_count;
  reg [MXEND-1:0] end_write;
  reg  [MXCNT-1:0] count=0;
  
  always @* begin
  if      (wr_init == 1) begin end_count <= CNT_BUSY; end_write <= CNT_INIT;  end
  else if (wr_data == 0) begin end_count <= CNT_SLOT; end_write <= CNT_LONG;  end
  else if (wr_data == 1) begin end_count <= CNT_SLOT; end_write <= CNT_SHORT; end
  else                   begin end_count <= CNT_BUSY; end_write <= CNT_INIT;  end
  end

  wire count_done = count[end_count];
  wire write_done = count[end_write];
  wire latch_data = count[CNT_READ];

// Output Pulse-width-modulated FF
  reg  dsn_out_ff=0;

  always @(posedge clock) begin
  if (write_done)  dsn_out_ff <= 0;
  else      dsn_out_ff <= (dsn_sm==pulse) || dsn_out_ff;
  end

// Bidir I/O pins for TMB, pullup is now in ucf
  assign dsn_io = (dsn_out_ff) ? 1'b0 : 1'bz;
  assign dsn_in =  dsn_io;

// Main Counter
  assign busy  = (dsn_sm != idle) && (dsn_sm != unstart);

  always @(posedge clock) begin
  if    (dsn_sm==idle) count <= 0;
  else if (busy        ) count <= count + 1'b1; 
  end

// Latch data bit from DSN chip after dsn_io deasserts. And-gate forces FF into CLB, IOB pair has clock conflict in virtex2
  reg rd_data = 0;

  always @(posedge clock) begin
  if (dsn_sm==latch) rd_data <= dsn_in && (dsn_sm==latch);
  end

// DSN State Machine
  always @(posedge clock) begin
  if (global_reset)     dsn_sm <= idle;
  else begin
  case (dsn_sm )
  idle:    if (start)     dsn_sm <= pulse;
  pulse:           dsn_sm <= wait1;
  wait1:   if (latch_data) dsn_sm <= latch;
  latch:           dsn_sm <= hold;
  hold:    if (count_done) dsn_sm <= unstart;
  unstart: if (!start)   dsn_sm <= idle;
  default:                 dsn_sm <= idle;
  endcase
  end
  end

// Debug
   `ifdef DEBUG_DSN_TMB
  output reg [39:0] dsn_sm_dsp;

  always @* begin
  case (dsn_sm)
  idle:    dsn_sm_dsp <= "idle ";
  pulse:   dsn_sm_dsp <= "pulse";
  wait1:   dsn_sm_dsp <= "wait ";
  latch:   dsn_sm_dsp <= "latch";
  hold:    dsn_sm_dsp <= "hold ";
  unstart: dsn_sm_dsp <= "unstr";
  default: dsn_sm_dsp <= "wtf!!";  // undefined
  endcase
  end
   `endif

//--------------------------------------------------------------------------------------------------------------
  endmodule
//--------------------------------------------------------------------------------------------------------------
