`timescale 1ns / 1ps
//`define DEBUG_FENCE_QUEUE 1
//--------------------------------------------------------------------------------------------------------------------
//  Dual Port FIFO keeps track of available raw hits buffer space
//
//  12/06/2007  Initial port from sequencer stack_fifo
//  12/07/2007  Add debug IOs
//  12/11/2007  Disable reads if FIFO empty
//  12/20/2007  Restructure parameters passed to ram block
//  01/23/2008  Change debug name
//  11/15/2008  Add data array to queue storage
//  04/24/2009  Add reg init 0s
//  09/13/2010  Port to ise 12
//  09/14/2010  Add passed parameter display
//--------------------------------------------------------------------------------------------------------------------
  module fence_queue
  (
  clock,
  reset,
  push,
  wr_data,
  pop,
  rd_data,
  full,
  empty,
  ovf,
  udf,
  nwords,
  sump

`ifdef DEBUG_FENCE_QUEUE
  ,rd_adr
  ,wr_adr
`endif
  );

//--------------------------------------------------------------------------------------------------------------------
// Generics caller may over-ride
//--------------------------------------------------------------------------------------------------------------------
  parameter ADRB   = 11;      // Address bits
  parameter MXADR = 2048;      // RAM addresses
  parameter WIDTH = ADRB+32;    // Data width, fence data is itself an address

  initial  $display("fence_queue: ADRB =%d",ADRB );
  initial  $display("fence_queue: MXADR=%d",MXADR);
  initial  $display("fence_queue: WIDTH=%d",WIDTH);

//--------------------------------------------------------------------------------------------------------------------
// Ports
//--------------------------------------------------------------------------------------------------------------------
  input        clock;    // IO clock
  input        reset;    // sync reset
  input        push;    // write into FIFO
  input  [WIDTH-1:0]  wr_data;  // data into FIFO
  input        pop;    // read from FIFO

  output  [WIDTH-1:0]  rd_data;  // FIFO data out
  output        full;    // FIFO full
  output        empty;    // FIFO empty
  output        ovf;    // overflow, tried to push when full
  output        udf;    // underflow, tried to pop when empty
  output  [ADRB:0]  nwords;    // word count in FIFO
  output        sump;     // Unused signals

// Debug
`ifdef DEBUG_FENCE_QUEUE
  output  [ADRB-1:0]  rd_adr;    // read address for last pop
  output  [ADRB-1:0]  wr_adr;    // write address for current push
`endif

//--------------------------------------------------------------------------------------------------------------------
// Local
//--------------------------------------------------------------------------------------------------------------------
  reg    [ADRB:0]  nwords=0;  // number of words pushed but not popped 
  reg    [ADRB-1:0]  rd_adr=0;  // read address for last pop
  reg    [ADRB-1:0]  wr_adr=0;  // write address for current push

//--------------------------------------------------------------------------------------------------------------------
// FIFO write control
//--------------------------------------------------------------------------------------------------------------------
  assign  full  = (nwords == MXADR);
  assign  empty = (nwords == 0);

  wire  push_en = push && !full;
  wire  pop_en  = pop  && !empty;
  wire  rd_enb  = !empty;

// Dual port block RAM
  ramblock # (
  .RAM_WIDTH (WIDTH),            // Data width+parity
  .RAM_ADRB  (ADRB))            // Address bits
  uramblk0
  (
  .clock    (clock),          // Write clock
  .wr_wea    (push_en),          // Write enable      port A
  .wr_adra  (wr_adr[ADRB-1:0]),      // Read/Write address  port A
  .wr_dataa  (wr_data[WIDTH-1:0]),    // Write data       port A
  .rd_enb    (rd_enb),          // Read enable      port B
  .rd_adrb  (rd_adr[ADRB-1:0]),      // Read/Write address  port B
  .rd_datab  (rd_data[WIDTH-1:0]),    // Read  data      port B
  .dang    (dang)            // Dangling pin sump  port A/B
  );

// Pop RAM address counter
  always @(posedge clock) begin
  if    (reset ) rd_adr <= 0;
  else if  (pop_en) rd_adr <= rd_adr+1'b1;
  end

// Push RAM address counter
  always @(posedge clock) begin
  if    (reset  ) wr_adr <= 0;
  else if  (push_en) wr_adr <= wr_adr+1'b1;
  end

// Fifo word counter
  always @(posedge clock) begin
  if (reset) nwords <= 0;
  else begin
  case ({push_en, pop_en})
   2'b00 : nwords <= nwords;    // Idle
   2'b01 : nwords <= nwords-1'b1;  // Pop
   2'b10 : nwords <= nwords+1'b1;  // Push
   2'b11 : nwords <= nwords;    // Push & pop
  endcase
  end
  end 

// Underflow latch, tried to pop when empty
  reg  udf=0;

  always @(posedge clock) begin
  if    (reset)      udf <= 0;
  else if  (pop && empty)  udf <= 1;
  end

// Overflow latch, tried to push when full
  reg  ovf=0;

  always @(posedge clock) begin
  if    (reset)      ovf <= 0; 
  else if  (push && full)  ovf <= 1; 
  end 

// Sump for unused signals
  assign sump = dang;

//--------------------------------------------------------------------------------------------------------------------
  endmodule
//--------------------------------------------------------------------------------------------------------------------
