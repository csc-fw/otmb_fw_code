`timescale 1ns / 1ps
//`define DEBUG_BUFFER_WRITE_CTRL 1
//-------------------------------------------------------------------------------------------------------------------
// Raw Hits RAM buffer address logic
//-------------------------------------------------------------------------------------------------------------------
//  12/07/2007  Initial fifo-based version
//  12/10/2007  Add distance to nearest fence calculation
//  12/11/2007  Mods to RAM sim options, fence logic
//  12/12/2007  Increase pre-store, change min event size to a constant
//  12/13/2007  Delay buf_empty 1bx to compensate for fifo RAM access latnecy
//  12/13/2007  Add free-space display
//  12/14/2007  Change status names to distinguish queue status from buffer status, add buffer stalled signal
//  12/17/2007  Revert buf signal names to match sequencer
//  01/17/2008  Add pop fence address output to sequencer for readout state machine
//  01/23/2008  Change queue to store allocated event address, calculate fence using popped event address
//  01/24/2008  FF buffer fence dist to increase clock speed, power up with q empty ff set
//  04/22/2008  Tune read_adr_offset for new pre-trigger state machine
//  11/15/2008  Add data array to queue storage
//  05/26/2010  Rename sump
//  06/26/2010  Add stalled_once signal
//  09/15/2010  Port to ISE 12, replace blocking operators
//  11/29/2010  FF buffer setback arithemetic, gives 21% speed increase, elimintates map optimized-out blocks
//-------------------------------------------------------------------------------------------------------------------
  module buffer_write_ctrl
  (
// CCB Ports
  clock,
  ttc_resync,

// CFEB Raw Hits FIFO RAM Ports
  fifo_wen,
  fifo_wadr,

// CFEB VME Configuration Ports
  fifo_pretrig_cfeb,
  fifo_no_raw_hits,

// RPC VME Configuration Ports
  fifo_pretrig_rpc,

// Fence Buffer Write Control
  buf_reset,
  buf_push,
  buf_push_adr,
  buf_push_data,

  wr_buf_ready,
  wr_buf_adr,

// Fence buffer adr and data at head of queue
  buf_queue_adr,
  buf_queue_data,

// Sequencer Buffer Read Control
  buf_pop,
  buf_pop_adr,

// Sequencer Buffer Status
  buf_q_full,
  buf_q_empty,
  buf_q_ovf_err,
  buf_q_udf_err,
  buf_q_adr_err,
  buf_stalled,
  buf_stalled_once,
  buf_fence_dist,
  buf_fence_cnt,
  buf_fence_cnt_peak,
  buf_display,
  buf_sump

// Debug
`ifdef DEBUG_BUFFER_WRITE_CTRL
  ,buf_sm_dsp
  ,power_up
  ,reset
  ,pretrig_setback
  ,prestore_setback
  ,next_fence_adr
  ,fence_dist_min
  ,fence_dist

  ,prestore_done
  ,hit_fence
  ,hold_done
  ,adr_err
`endif
  );

//------------------------------------------------------------------------------------------------------------------
// Constants
//------------------------------------------------------------------------------------------------------------------
  parameter MXTBIN      = 5;      // Time bin address width
  parameter READ_ADR_OFFSET  = 6;      // Number clocks from first address to pretrigger adr latch, tuned 04/22/08
  parameter PRESTORE_SAFETY  = 2;      // Pre-store safety beyond pre-trig tbins

// Queue RAM parameters
  parameter RAM_DEPTH      = 2048;      // Storage bx depth
  parameter RAM_ADRB      = 11;      // Address width=log2(ram_depth)
  parameter MXBADR      = RAM_ADRB;    // Pushed address width
  parameter MXBDATA      = 32;      // Pushed data width
  
//------------------------------------------------------------------------------------------------------------------
// Ports
//------------------------------------------------------------------------------------------------------------------
// CCB
  input          clock;        // 40MHz TMB main clock
  input          ttc_resync;      // Resync TMB

// CFEB Raw Hits FIFO RAM
  output          fifo_wen;      // 1=Write enable FIFO RAM
  output  [RAM_ADRB-1:0]  fifo_wadr;      // FIFO RAM write address

// CFEB VME Configuration
  input  [MXTBIN-1:0]  fifo_pretrig_cfeb;  // Number FIFO time bins before pretrigger
  input          fifo_no_raw_hits;  // 1=do not wait to store raw hits

// RPC VME Configuration
  input  [MXTBIN-1:0]  fifo_pretrig_rpc;  // Number FIFO time bins before pretrigger

// Fence Buffer Write Control
  input          buf_reset;      // Free all buffer space
  input          buf_push;      // Allocate write buffer
  input  [MXBADR-1:0]  buf_push_adr;    // Address of write buffer to allocate  
  input  [MXBDATA-1:0]  buf_push_data;    // Data associated with push_adr
  
  output          wr_buf_ready;    // Write buffer is ready
  output  [MXBADR-1:0]  wr_buf_adr;      // Current address of header write buffer

// Fence buffer adr and data at head of queue
  output  [MXBADR-1:0]  buf_queue_adr;    // Address of fence queued for readout
  output  [MXBDATA-1:0]  buf_queue_data;    // Data associated with queue adr

// Fence Buffer Read Control
  input          buf_pop;      // Specified buffer is to be released
  input  [MXBADR-1:0]  buf_pop_adr;    // Address of read buffer to release

// Fence Buffer Status
  output          buf_q_full;      // All raw hits ram in use, ram writing must stop
  output          buf_q_empty;    // No fences remain in buffer queue
  output          buf_q_ovf_err;    // Tried to push when queue full
  output          buf_q_udf_err;    // Tried to pop when queue empty
  output          buf_q_adr_err;    // Fence adr popped from queue doesnt match rls adr
  output          buf_stalled;    // Buffer write pointer hit a fence and is stalled now
  output          buf_stalled_once;  // Buffer stalled at least once since last resync
  output  [MXBADR-1:0]  buf_fence_dist;    // Distance to 1st fence address
  output  [MXBADR-1+1:0]  buf_fence_cnt;    // Number of fences in fence RAM currently
  output  [MXBADR-1+1:0]  buf_fence_cnt_peak;  // Peak number of fences in fence RAM
  output  [7:0]      buf_display;    // Buffer fraction in use display
  output          buf_sump;       // Unused signals

// Debug
`ifdef DEBUG_BUFFER_WRITE_CTRL
  output  [63:0]      buf_sm_dsp;
  output          power_up;
  output          reset;
  output  [RAM_ADRB-1:0]  pretrig_setback;
  output  [RAM_ADRB-1:0]  prestore_setback;
  output  [RAM_ADRB-1:0]  next_fence_adr;
  output  [MXBADR-1:0]  fence_dist_min;
  output  [MXBADR-1:0]  fence_dist;

  output          prestore_done;
  output          hit_fence;
  output          hold_done;
  output          adr_err;
`endif

//------------------------------------------------------------------------------------------------------------------
// FIFO Write Control Section
//------------------------------------------------------------------------------------------------------------------
// Buffer control state machine
  reg  [3:0] buf_sm;        // synthesis attribute safe_implementation of buf_sm is "yes";
  parameter bsm_init    =  0;  // Starting state, buf unready, adress counter stopped, ram write disabled
  parameter bsm_prestore  =  1;  // Fence cleared, buf unready, address incrementing for pre-storing raw hits
  parameter bsm_run    =  2;  // Run mode, buf ready, buffer address counter incrementing every bx
  parameter bsm_hold    =  3;  // Hit a fence, buf unready, buffer address counter stopped
  
// Local power-up reset
  wire [3:0]  pdly = 5;      // Hold power down longer than simulator GSR

  SRL16E upup (.CLK(clock),.CE(~power_up),.D(1'b1),.A0(pdly[0]),.A1(pdly[1]),.A2(pdly[2]),.A3(pdly[3]),.Q(power_up));

  wire reset    = ttc_resync || buf_reset;

// Fence queue-fifo instantiation
  wire [MXBADR-1+1:0] fence_cnt;

  fence_queue #(RAM_ADRB,RAM_DEPTH,MXBADR+MXBDATA) ufence_queue
  (
  .clock    (clock),              // In  IO clock
  .reset    (reset),              // In  sync reset
  .push    (buf_push),              // In  write into FIFO
  .wr_data  ({buf_push_data,buf_push_adr}),    // In  data into FIFO
  .pop    (buf_pop),              // In  read from FIFO
  .rd_data  ({buf_queue_data,buf_queue_adr}),  // Out  FIFO data out
  .full    (full),                // Out  FIFO full
  .empty    (empty),              // Out  FIFO empty
  .ovf    (buf_q_ovf_err),          // Out  overflow, tried to push when full
  .udf    (buf_q_udf_err),          // Out  underflow, tried to pop when empty
  .nwords    (fence_cnt[MXBADR-1+1:0]),      // Out  word count in FIFO
  .sump    (sump)                 // Out  Unused signals
  );

// Delay buffer status signals 1bx to compensate for RAM access latency
  reg [MXBADR-1+1:0] buf_fence_cnt=0;
  reg   buf_q_empty = 1;
  reg   buf_q_full  = 0;

  always @(posedge clock) begin  
  buf_q_empty   <= empty;
  buf_q_full     <= full;
  buf_fence_cnt  <= fence_cnt;
  end

// Pre-calculate fence address setback from pre-trigger address, take larger of cfeb or rpc pretrig tbins
  wire [RAM_ADRB-1:0] next_fence_adr;
  wire [RAM_ADRB-1:0] pretrig_setback;
  wire [RAM_ADRB-1:0] prestore_setback;
  reg  [RAM_ADRB-1:0] buf_setback=0;

  assign pretrig_setback  = (fifo_pretrig_cfeb >= fifo_pretrig_rpc) ? fifo_pretrig_cfeb : fifo_pretrig_rpc;
  assign prestore_setback =  READ_ADR_OFFSET+1+PRESTORE_SAFETY;

  always @(posedge clock) begin
  buf_setback <= pretrig_setback-prestore_setback;
  end

  assign next_fence_adr = buf_queue_adr-buf_setback;  // compensate for pre-trig latency

// Find distance to next fence, FF buffer for speed
  reg  [MXBADR-1:0  ] fence_dist      = -1;
  wire [RAM_ADRB-1:0] highest_ram_adr = RAM_DEPTH-1;

  always @(posedge clock) begin
  fence_dist <= buf_q_empty ? highest_ram_adr : (next_fence_adr-fifo_wadr);
  end

// Minimum allowed distance to next fence is adr space needed for at least 1 more event
  wire [MXBADR-1:0] fence_dist_min;

  assign fence_dist_min = 64;  // Acutal min dist depends on many variables, so just use a large-enough constant

// Delay fence pop adr 1bx to compare with fence from queue
  reg [MXBADR-1:0] buf_pop_adr_ff=0;
  reg buf_pop_ff=0;

  always @(posedge clock) begin
  buf_pop_ff    <= buf_pop;
  buf_pop_adr_ff  <= buf_pop_adr;
  end 

// Popped fence address must match expected address
  reg buf_q_adr_err=0;

  wire adr_err =  (buf_pop_adr_ff != buf_queue_adr) && buf_pop_ff;

  always @(posedge clock) begin
  if    (reset)    buf_q_adr_err <= 0; 
  else if  (adr_err)  buf_q_adr_err <= 1; 
  end 

// Store peak fence count
  reg [MXBADR-1+1:0] buf_fence_cnt_peak=0;

  wire new_peak = fence_cnt > buf_fence_cnt_peak;

  always @(posedge clock) begin
  if    (reset   ) buf_fence_cnt_peak <= 0;
  else if  (new_peak) buf_fence_cnt_peak <= fence_cnt;
  end

// Buffer fence distance and stall indicator for display and VME
  reg buf_stalled_once=0;

  assign buf_fence_dist  = fence_dist;
  assign buf_stalled    = (buf_sm == bsm_hold);

  always @(posedge clock) begin
  if      (reset      ) buf_stalled_once <= 0;
  else if (buf_stalled) buf_stalled_once <= 1;
  end  

// Buffer fraction in use display
  wire [MXBADR-1:0] used_space = 2047-fence_dist;
  
  assign buf_display[7] = used_space > (2048 * 875) /1000;  // 87.5%
  assign buf_display[6] = used_space > (2048 * 750) /1000;  // 75.0%
  assign buf_display[5] = used_space > (2048 * 625) /1000;  // 62.5%
  assign buf_display[4] = used_space > (2048 * 500) /1000;  // 50.0%
  assign buf_display[3] = used_space > (2048 * 375) /1000;  // 37.5 %
  assign buf_display[2] = used_space > (2048 * 250) /1000;  // 25.0%
  assign buf_display[1] = used_space > (2048 * 125) /1000;  // 12.5%
  assign buf_display[0] = !buf_q_empty;            // 00.0% used

// Buffer control state machine: Prestore counter
  reg [RAM_ADRB-1:0] prestore_cnt=0;

  always @(posedge clock) begin
  if (buf_sm!=bsm_prestore) prestore_cnt <= 0;
  else            prestore_cnt <= prestore_cnt+1'b1;
  end

  wire [MXBADR-1:0] prestore_bx = pretrig_setback + prestore_setback;

  wire prestore_done = (prestore_cnt==prestore_bx);

// Buffer control state machine: signals
  wire hit_fence   = (fence_dist==0);
  wire hold_done  = (fence_dist>fence_dist_min);  // wait for fence distance to be larger than min

// Buffer control state machine 
  initial buf_sm = bsm_init;

  always @(posedge clock) begin
  if (reset)              // On over-riding resync or reset
  buf_sm <= bsm_init;          // Go erase all fence markers
  else
  case (buf_sm)
  bsm_init:              
    if (power_up)          // Reset state reached when resync asserted after power up
    if (!fifo_no_raw_hits)
      buf_sm <= bsm_prestore;    // Prestore raw hits
      else
      buf_sm <= bsm_run;      // Unless they are not used

  bsm_prestore:
    if (hit_fence)
    buf_sm <= bsm_hold;        // Hold if fence marker hit [should not be possible at this point]
    else if (prestore_done)      // Wait for tbins before pre-trigger to write into raw hits RAM
    buf_sm <= bsm_run;

  bsm_run:              // Run mode: enables wr_buf_ready to trigger section
    if (hit_fence)
    buf_sm <= bsm_hold;        // Hold if fence marker hit

  bsm_hold:
    if (hold_done)          // Continue to hold until fence is erased
    if (!fifo_no_raw_hits)
      buf_sm <= bsm_prestore;    // Prestore raw hits
      else
      buf_sm <= bsm_run;      // Unless they are not used
  default
    buf_sm <= bsm_init;
  endcase
  end

// RAM address counter increments every bx
  reg [RAM_ADRB-1:0] fifo_wadr=0;

  wire   wadr_en  = !hit_fence && ((buf_sm==bsm_run) || (buf_sm==bsm_prestore));  // enable fifo address increment
  assign fifo_wen = wadr_en;                            // enable fifo ram write

  always @(posedge clock) begin
  if    (reset  ) fifo_wadr <= 0;
  else if  (wadr_en) fifo_wadr <= fifo_wadr+1'b1;
  end

  assign wr_buf_adr   = fifo_wadr;                            // RAM write address for raw hits and header
  assign wr_buf_ready = !hit_fence && (buf_sm == bsm_run) && (fence_dist>fence_dist_min);  // Buffer ready to pre-trigger

// Unused signals
  assign buf_sump = sump;

//------------------------------------------------------------------------------------------------------------------
// Debug
//------------------------------------------------------------------------------------------------------------------
`ifdef DEBUG_BUFFER_WRITE_CTRL
// Write-buffer switch State Machine
  reg[63:0] buf_sm_dsp;

  always @* begin
  case (buf_sm)
  bsm_init:    buf_sm_dsp <= "init    ";
  bsm_prestore:  buf_sm_dsp <= "prestore";
  bsm_run:    buf_sm_dsp <= "run     ";
  bsm_hold:    buf_sm_dsp <= "hold    ";
  default      buf_sm_dsp <= "init    ";
  endcase
  end
`endif

//-------------------------------------------------------------------------------------------------------------------
  endmodule
//-------------------------------------------------------------------------------------------------------------------
