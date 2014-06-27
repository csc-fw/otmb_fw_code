`timescale 1ns / 1ps
//`define DEBUG_VMESM 1
//-----------------------------------------------------------------------------------------------------------------
//
//  Read User PROM0 and write to VME multiplexer
//
//  PROM data structure
//  Adr  7654 3210  Hex  Description
//  --- ---- ----   --  -----------
//  0  1011 1100  BC  Begin CLCT Header Marker, if missing state machine stops
//  1  tttt oooo  LL  Word count [7:0] kkkk hhhh tttt oooo from BC to FF
//  2  kkkk hhhh  HH  Word count [15:8]
//  3  tttt oooo  12  Month   month/day in "hex-ascii" December 31, 2006
//  4  tttt oooo  31  Day
//  5  tttt oooo  06  Year  2006   = kkkk hhhh tttt oooo
//  6  kkkk hhhh  20  Year
//  7  vvvv vvvv  XX  Version number = vvvv vvvv
//  8  xxxx xxxx  XX  Option
//  9  xxxx xxxx  XX  Option
//  A  xxxx xxxx  XX  Option
//  B  xxxx xxxx  XX  Option
//  C  xxxx xxxx  XX  Option
//  D  xxxx xxxx  XX  Option
//  E  xxxx xxxx  XX  Option
//  F  1110 1100  EC  End Header Marker
//
//  10  aaaa aaaa  LL  VME adr[7:0]
//  11  aaaa aaaa  MM  VME adr[15:8]
//  12  aaaa aaaa  HH  VME adr[23:16]
//
//  13  dddd dddd  LL  VME data[7:0]
//  14  dddd dddd  HH  VME data[15:8]
//
//  L-2  1111 1100  FC  End of CLCT VME data Marker
//  L-1  cccc cccc  cc  Check sum  [7:0] includes addresses 0 to L-2
//  L  1111 1111  FF  End of PROM data Marker
//
//-----------------------------------------------------------------------------------------------------------------
// Error reporting:
//  fmt_err[0] = Missing BC header-begin marker
//  fmt_err[1] = Missing EC header-end marker
//  fmt_err[2] = Missing FC data-end marker
//  fmt_err[3] = Missing FF prom-end marker
//  fmt_err[4] = Word counter overflow
//
//-----------------------------------------------------------------------------------------------------------------
//  05/30/2006  Initial port from jtagsm
//  06/01/2006  Restructure header
//  06/05/2006  Switch to embedded address format
//  07/06/2006  Port to ISE 8.2iSP1
//  07/07/2006  Mods to PROM address logic
//  07/10/2006  Buffer adr and data outputs, align ds0 strobe
//  07/11/2006  Status bits alignment
//  07/12/2006  Abort if missing EC header-end marker
//  07/19/2006  Mod wdcnt clear, add busy extend for jtagsm to avoid prom contention
//  07/20/2006  Negate busy until vme_ready is asserted
//  07/21/2006  Buffer busy_extend
//  07/25/2006  Add persitence to vme signals to guarantee overlap with 10MHz vme clck
//  09/22/2006  Increase machine state vector width so xst recognizes fsm
//  10/02/2006  Remove autostart ff because its always set by parameter
//  01/12/2009  Update for ISE 10.1i
//  07/31/2009  Add reg inits, ds0 was powering up as 1 with ise 10.1i, but was 0 with ise 8.2i
//  08/19/2010  Port to ise 12, change to non-blocking operators
//  08/20/2010  Add short prom ce init count for debug mode
//  08/24/2010  Rename gbl_reset, replace async reset with power up init
//-----------------------------------------------------------------------------------------------------------------
  module vmesm
  (
// Control
  clock,
  global_reset,
  power_up,
  vme_ready,
  start,
  autostart,
  throttle,

// PROM
  prom_data,
  prom_clk,
  prom_oe,
  prom_nce,
  
// VME
  vmesm_oe,
  adr,
  data,
  ds0,

// Status
  sreset,
  busy,
  busy_extend,
  aborted,
  cksum_ok,
  wdcnt_ok,
  vmesm_ok,
  wdcnt,
  cksum,
  fmt_err,
  nvme_writes

`ifdef DEBUG_VMESM
   ,vme_sm_dsp,
  init_done,
  init_cnt_en,
  init_cnt,
  reset_done,
  reset_cnt_en,
  reset_cnt,
  clear_adr,
  next_adr,
  idle_prom,
  blank_data,
  abort,
  latch_prom_data,
  prom_data_ff,
  block_cnt,
  adr_clear,
  adr_en,
  check_flag,
  check_frame,
  header_begin,
  header_end,
  data_end,
  prom_end,
  data_frame,
  cksum_prom,
  wdcnt_prom,
  header_begin_marker,
  header_end_marker,
  data_end_marker,
  prom_end_marker,
  latch_status,
  clear_status,
  wdcnt_ovf,
  prom_adr,
  fmt_errors,
  adr_ff,
  data_ff,
  adr_send,
  adr_getset,
  adr_go,
  adr_getset_ff,
  adr_persist,
  adr_persist_cnt
`endif
  );
//-----------------------------------------------------------------------------------------------------------------
// IO Ports
//-----------------------------------------------------------------------------------------------------------------
// Control
  input      clock;        // 40 MHz clock
  input      global_reset;    // Global reset
  input      power_up;      // DLL clock lock, we wait for it
  input      vme_ready;      // TMB VME registers finished loading with defaults
  input      start;        // Cycle start command
  input      autostart;      // Enable automatic power-up
  input  [3:0]  throttle;      // PROM read-speed control, 0=fastest

// PROM
  input  [7:0]  prom_data;      // prom_data[7:0]
  output      prom_clk;      // prom_ctrl[0]
  output      prom_oe;      // prom_ctrl[1]
  output      prom_nce;      // prom_ctrl[2]

// VME
  output      vmesm_oe;      // Enable vme mux
  output  [23:0]  adr;        // VME register address
  output  [15:0]  data;        // VME data from PROM
  output      ds0;        // VME stobe

// Status
  input      sreset;        // Status signal reset
  output      busy;        // State machine busy
  output      busy_extend;    // State machine busy extended to hold off jtagsm
  output      aborted;      // State machine aborted reading PROM
  output      cksum_ok;      // Check-sum  matches PROM contents
  output      wdcnt_ok;      // Word count matches PROM contents
  output      vmesm_ok;      // Machine ran without errors
  output  [15:0]  wdcnt;        // Word count
  output  [7:0]  cksum;        // Check sum
  output  [4:0]  fmt_err;      // PROM data structure error
  output  [7:0]  nvme_writes;    // Number of vme addresses written

`ifdef DEBUG_VMESM
  output  [71:0]  vme_sm_dsp;
  
  output      init_done;
  output      init_cnt_en;
  output  [6:0]  init_cnt;

  output      reset_done;
  output      reset_cnt_en;
  output  [3:0]  reset_cnt;

  output      clear_adr;
  output      next_adr;
  output      idle_prom;

  output      blank_data;
  output      abort;

  output      latch_prom_data;
  output  [7:0]  prom_data_ff;

  output  [2:0]  block_cnt;
  output      adr_clear;
  output      adr_en;
  
  output      check_flag;
  output      check_frame;
  output      header_begin;
  output      header_end;
  output      data_end;
  output      prom_end;
  output      data_frame;
  
  output  [7:0]  cksum_prom;
  output  [15:0]  wdcnt_prom;

  output      header_begin_marker;
  output      header_end_marker;
  output      data_end_marker;
  output      prom_end_marker;
  output      latch_status;
  output      clear_status;
  output      wdcnt_ovf;
  output  [15:0]  prom_adr;
  output  [4:0]  fmt_errors;
  
  output  [15:0]  data_ff;
  output  [23:0]  adr_ff;
  output      adr_send;
  output      adr_getset;
  output      adr_go;

  output      adr_getset_ff;
  output      adr_persist;
  output  [1:0]  adr_persist_cnt;
`endif

//-----------------------------------------------------------------------------------------------------------------
// Local
//-----------------------------------------------------------------------------------------------------------------
// State Machine declarations
  reg  [3:0] vme_sm;

  parameter wait_dll    =  4'h0;
  parameter wait_vme    =  4'h1;
  parameter idle      =  4'h2;
  parameter init      =  4'h3;
  parameter reset_adr    =  4'h4;
  parameter prom_taccess  =  4'h5;
  parameter latch_prom  =  4'h6;
  parameter inc_adr    =  4'h7;
  parameter persist    =  4'h8;
  parameter unstart    =  4'h9;

  // synthesis attribute safe_implementation of vme_sm is "yes";
  // synthesis attribute init                of vme_sm is "wait_dll";

//-----------------------------------------------------------------------------------------------------------------
// Main Logic
//-----------------------------------------------------------------------------------------------------------------
// FF buffer state machine trigger inputs
  reg  power_up_ff  = 0;
  reg vme_ready_ff = 0;
  reg  start_ff     = 0;

  always @(posedge clock) begin
  power_up_ff  <= power_up;
  vme_ready_ff <= vme_ready;
  start_ff     <= start;
  end

// Signal busy if not idling or waiting for unstart, extend busy to hold off jtagsm to avoid prom contention
  reg  busy  = 0;
  reg  nbusy = 0;
  wire busy_srl;
  wire [3:0] bdly = 0;  // busy extend period, 0=25ns

  wire busy_en  =  (vme_sm != idle) && (vme_sm != unstart)  && vme_ready_ff;
  wire nbusy_en = ((vme_sm == idle) || (vme_sm == unstart));
  assign busy_extend  = !nbusy || busy_srl;

  always @(posedge clock) begin
  busy  <= busy_en;
  nbusy <= nbusy_en;
  end

  SRL16E ubusy (.CLK(clock),.CE(1'b1),.D(busy_en),.A0(bdly[0]),.A1(bdly[1]),.A2(bdly[2]),.A3(bdly[3]),.Q(busy_srl));

// Control signals to the active PROM
  reg   prom_clk = 0;
  reg  prom_oe  = 1;
  reg   prom_nce = 1;
  wire prom_end;

  wire clear_adr = (vme_sm == reset_adr);
  wire next_adr  = (vme_sm == latch_prom) && !prom_end;
  wire idle_prom = (vme_sm == idle) || (vme_sm == unstart);

  always @(posedge clock) begin
  if (global_reset) begin
  prom_clk <= 0;
  prom_oe  <= 1;
  prom_nce <= 1;
  end
  else if (clear_adr) begin
  prom_clk <= 0;  // take clock low, it was prolly idle high
  prom_oe   <= 0;  // 0=reset address, outputs disabled
  prom_nce <= 0;  // 0=chip selected
  end
  else if (idle_prom) begin
  prom_clk <= 0;  // take clk low for idling
  prom_oe   <= 1;  // 0=reset address, outputs disabled
  prom_nce <= 1;  // 1=chip not selected
  end
  else if (next_adr) begin
  prom_clk <= 1;  // advance address
  prom_oe   <= 1;  // 1=outputs enabled
  prom_nce <= 0;  // 0=chip selected
  end
  else begin
  prom_clk <= 0;  // take clk low 
  prom_oe   <= 1;  // 0=reset address, outputs disabled
  prom_nce <= 0;  // 1=chip not selected
  end
  end

// Latch PROM data
  reg [7:0]  prom_data_ff = 0;
  reg [15:0]  prom_adr     = 0;

  wire blank_data      = !((vme_sm == latch_prom) || (vme_sm == inc_adr) || (vme_sm == persist));
  wire latch_prom_data =   (vme_sm == latch_prom);
  
  always @(posedge clock) begin
  if (blank_data) begin
  prom_data_ff  <=  0;
  prom_adr    <= -1;
  end
  if (latch_prom_data) begin
  prom_data_ff  <= prom_data;
  prom_adr    <= prom_adr+1'b1;
  end
  end

// Count words from BC to FF markers, inclusive, 512K PROMs have 512K/8=64K addresses
  reg [15:0]  wdcnt       = 0;
  reg  [15:0]  wdcnt_prom  = 0;
  reg  [7:0]  cksum_prom  = 0;
  wire    clear_status;

  wire wdcnt_en = (vme_sm == latch_prom);

  always @(posedge clock) begin
  if (wdcnt_en    ) wdcnt <= wdcnt+1'b1;
  if (clear_status) wdcnt <= 0;
  end

// Decode control word from PROM
  wire abort;
  wire data_frame;

  wire   header_begin  = (prom_data_ff[7:0] == 8'hBC) && !data_frame;
  wire   header_end  = (prom_data_ff[7:0] == 8'hEC) && !data_frame;
  wire   data_end    = (prom_data_ff[7:0] == 8'hFC) && !data_frame;
  assign prom_end    =((prom_data_ff[7:0] == 8'hFF) && !data_frame) || abort;

// First frame marker and header-end marker must be present else state machine stops
  reg      abort_ff = 0;
  reg   [4:0]  fmt_err  = 0;
  wire [4:0]  fmt_errors;

  wire check_flag  = (vme_sm == latch_prom);
  wire abort_clear = (vme_sm == wait_dll  ) || (vme_sm == wait_vme) || (vme_sm == idle);

  always @(posedge clock) begin
  if (abort_clear) abort_ff <= 0;
  if (check_flag ) abort_ff <= abort;
  end

  wire wdcnt_ovf = (wdcnt > wdcnt_prom) && (wdcnt > 3);
  assign abort = abort_ff || ((wdcnt == 1) && !header_begin) || ((wdcnt == 16) && !header_end) || wdcnt_ovf;

// Extract header/trailer data
  reg  header_begin_marker = 0;
  reg  header_end_marker   = 0;
  reg  data_end_marker     = 0;
  reg  prom_end_marker     = 0;

  wire[15:0] L = wdcnt_prom;
  assign clear_status = (vme_sm == wait_dll) || (vme_sm == wait_vme) ||(vme_sm == init) || sreset;

  assign data_frame  = (wdcnt    >  16'h0010) && (prom_adr <= L-4);
  wire   check_frame  = (wdcnt    >= 16'h0001) && (prom_adr <= L-3);
  
  always @(posedge clock) begin
  if (clear_status) begin
  header_begin_marker  <= 0;
  wdcnt_prom[15:0]  <= 0;
  header_end_marker  <= 0;
  data_end_marker    <= 0;
  cksum_prom       <= 0;
  prom_end_marker    <= 0;
  end
  if      (prom_adr == 0)   header_begin_marker <= header_begin;
  else if (prom_adr == 1)   wdcnt_prom[7:0]     <= prom_data_ff[7:0];
  else if (prom_adr == 2)   wdcnt_prom[15:8]    <= prom_data_ff[7:0];
  else if (prom_adr == 15)  header_end_marker   <= header_end;
  else if (prom_adr == L-3) data_end_marker     <= data_end;
  else if (prom_adr == L-2) cksum_prom          <= prom_data_ff[7:0];
  else if (prom_adr == L-1) prom_end_marker     <= prom_end;
  end

// Extract VME address and data
  reg [23:0]  adr_ff    = 0;
  reg  [15:0]  data_ff   = 0;
  reg [2:0]  block_cnt = 0;

  wire adr_clear  =((vme_sm == latch_prom) && (block_cnt == 4)) || !data_frame;
  wire adr_en    = (vme_sm == latch_prom) && data_frame;

  always @(posedge clock) begin
  if    (adr_clear)  block_cnt <= 0;
  else if (adr_en)  block_cnt <= block_cnt+1'b1;
  end

  always @(posedge clock) begin
  if (adr_en) begin
  case (block_cnt[2:0])
  3'd0:  adr_ff[7:0]    <= prom_data_ff[7:0];  // Latch adr
  3'd1:  adr_ff[15:8]  <= prom_data_ff[7:0];  // Latch adr
  3'd2:  adr_ff[23:16]  <= prom_data_ff[7:0];  // Latch adr
  3'd3:  data_ff[7:0]  <= prom_data_ff[7:0];  // Latch data
  3'd4:  data_ff[15:8]  <= prom_data_ff[7:0];  // Latch data
  endcase
  end
  end

// Transfer PROM data to VME registers, align ds0
  reg [23:0]  adr      = 0;
  reg  [15:0]  data     = 0;
  reg      vmesm_oe = 0;
  reg      ds0      = 0;
  reg      adr_getset_ff   = 0;
  reg  [1:0]  adr_persist_cnt = 0;

  wire adr_getset = ((vme_sm == latch_prom) && (block_cnt == 4)) && data_frame;
  wire adr_go     = (block_cnt == 0);

  always @(posedge clock) begin
  adr_getset_ff <= adr_getset;        // get ready to send adr if block_cnt reached 4  
  end

  wire adr_send    = adr_getset_ff && adr_go;  // send adr when block_cnt turns over to 0 from 4
  wire adr_persist = adr_persist_cnt < 3;    // adr and data assert 4 clocks wide, 1 clock before ds0
  
  always @(posedge clock) begin
  if      (adr_send || clear_status) adr_persist_cnt <= 0;
  else if (adr_persist             ) adr_persist_cnt <= adr_persist_cnt+1'b1;
  end

  always @(posedge clock) begin
  if (adr_send) begin
  adr    <= adr_ff;
  data  <= data_ff;
  ds0    <= 1;
  end
  else if (!adr_persist) begin
  adr    <= 0;
  data  <= 0;
  ds0    <= 0;
  end
  end

  wire blank_oe = clear_status || abort || (vme_sm == idle) || (vme_sm == unstart);
  
  always @(posedge clock) begin
  if      (blank_oe  ) vmesm_oe <= 0;  // release prom bus on clear or abort
  else if (data_frame) vmesm_oe <= 1;  // oe asserts during data frames and holds past last ds0
  end

// Checksum accumulator adds data starting from BC marker to the last VME data frame, inclusive
  reg [7:0] cksum = 0;

  wire cksum_cnt_en = check_flag && check_frame;

  always @(posedge clock) begin
  if (cksum_cnt_en) cksum <= cksum + prom_data_ff;
  if (clear_status) cksum <= 0;
  end

// Init delay counter waits 2uS after asserting /CE low per Xilinx datasheet
  `ifdef DEBUG_VMESM 
  `define MXINIT 4     // Short cycle for simulation
  `else
  `define MXINIT 80     // 2uS for normal PROM access
  `endif
  initial $display ("vmesm: setting PROM access %d",`MXINIT);

  reg [6:0] init_cnt = 0;

  wire init_cnt_en = (vme_sm   == init  );
  wire init_done   = (init_cnt ==`MXINIT);

  always @(posedge clock) begin
  if (init_cnt_en) init_cnt <= init_cnt+1'b1;
  else             init_cnt <= 0;
  end

// Address reset delay counter asserts reset 250nS per Xilinx datasheet
  reg [3:0] reset_cnt = 0;

  wire reset_cnt_en = (vme_sm    == reset_adr);
  wire reset_done   = (reset_cnt == 10);

  always @(posedge clock) begin
  if (reset_cnt_en) reset_cnt <= reset_cnt+1'b1;
  else              reset_cnt <= 0;
  end

// PROM-read speed throttle
  reg [3:0]  throttle_ff  = 0;
  reg  [3:0]  throttle_cnt = 0;
  reg      throttle_en  = 0;

  always @(posedge clock) begin
  throttle_ff <= throttle;
  throttle_en  <= (throttle_ff != 0);
  end

  wire throttle_cnt_en = (vme_sm == persist);

  always @(posedge clock) begin
  if (throttle_cnt_en) throttle_cnt <= throttle_cnt+1'b1;
  else                 throttle_cnt <= 0;
  end

  wire throttle_done = (throttle_cnt == throttle_ff);
  
// Status flags
  reg wdcnt_ok = 0;
  reg cksum_ok = 0;
  reg  vmesm_ok = 0;
  reg aborted  = 0;

  assign fmt_errors[0] = !header_begin_marker;
  assign fmt_errors[1] = !header_end_marker;
  assign fmt_errors[2] = !data_end_marker;
  assign fmt_errors[3] = !prom_end_marker;
  assign fmt_errors[4] =  wdcnt_ovf;
  
  wire latch_status = (vme_sm == unstart);

  always @(posedge clock) begin
  if (latch_status) begin
  wdcnt_ok  <= (wdcnt == wdcnt_prom) && !abort;
  cksum_ok  <= (cksum == cksum_prom) && !abort;
  vmesm_ok  <= (wdcnt == wdcnt_prom) && (cksum == cksum_prom) && !abort && !(|fmt_errors);
  aborted    <= abort;
  fmt_err    <= fmt_errors;
  end
  if (clear_status) begin
  wdcnt_ok  <= 0;
  cksum_ok  <= 0;
  vmesm_ok  <= 0;
  aborted   <= 0;
  fmt_err   <= 0;
  end
  end

// Count number of VME writes
  reg [7:0] nvme_writes = 0;
  
  always @(posedge clock) begin
  if (adr_send    ) nvme_writes <= nvme_writes+1'b1;
  if (clear_status) nvme_writes <= 0;
  end

//--------------------------------------------------------------------------------------------
//  PROM-Reader State machine
//--------------------------------------------------------------------------------------------
  always @(posedge clock) begin
  if    (global_reset) vme_sm <= wait_dll;
  else if  (sreset)       vme_sm <= idle;     //  JG: sets idle_prom
  else begin

  case (vme_sm)
  
  wait_dll:            // Wait for FPGA DLLs to lock
   if (power_up_ff)  vme_sm <= wait_vme;    // FPGA is ready

  wait_vme:            // Wait for VME registers to load
   if (vme_ready_ff)          // VME defaults loaded from FFs
   begin
   if (autostart)    vme_sm <= init;      // Start cycle if autostart enabled
   else        vme_sm <= idle;    // Otherwise stay idle.  JG: sets idle_prom
   end

  idle:              // Wait for VME command to program, power down PROM
   if (start_ff)    vme_sm <= init;      // Start arrived

  init:
   if (init_done)    vme_sm <= reset_adr;    // Power up PROM, 2uS delay.  JG: sets clear_adr

  reset_adr:
   if (reset_done)  vme_sm <= prom_taccess;    // Reset PROM address, 250nS delay
  
  prom_taccess:    vme_sm <= latch_prom;    // Relase reset, wait for output to assert 10ns minimum.  JG: sets next_adr

  latch_prom:      vme_sm <= inc_adr;  // Latch PROM data

  inc_adr:            // Increment PROM address
   if (prom_end)    vme_sm <= unstart;    // First-word marker missing or hit end of PROM data.  JG: sets idle_prom
   else 
   if (throttle_en)  vme_sm <= persist;    // PROM reads at slower speed
   else        vme_sm <= latch_prom;  // PROM reads at full speed.  JG: sets next_adr again

  persist:
   if (throttle_done)  vme_sm <= latch_prom;    // PROM read-speed decrease.  JG: sets next_adr again after a fixed delay.

  unstart:
   if(!start_ff)    vme_sm <= idle;      // Wait for VME write command to go away.  JG: sets idle_prom

  default        vme_sm <= wait_dll;
  endcase
  end
  end

//-----------------------------------------------------------------------------------------------------------------
// Debug
//-----------------------------------------------------------------------------------------------------------------
`ifdef DEBUG_VMESM
// PROM State Machine ASCII display
  reg [71:0] vme_sm_dsp;

  always @* begin
  case (vme_sm)
  wait_dll:    vme_sm_dsp <= "wait_dll ";
  wait_vme:    vme_sm_dsp <= "wait_vme ";
  idle:      vme_sm_dsp <= "idle     ";
  init:      vme_sm_dsp <= "init     ";
  reset_adr:    vme_sm_dsp <= "reset_adr";
  prom_taccess:  vme_sm_dsp <= "prom_tacc";
  latch_prom:    vme_sm_dsp <= "latch_prm";
  inc_adr:    vme_sm_dsp <= "inc_adr  ";
  persist:    vme_sm_dsp <= "persist  ";
  unstart:    vme_sm_dsp <= "unstart  ";
  default      vme_sm_dsp <= "wait_dll ";
  endcase
  end
`endif

//-----------------------------------------------------------------------------------------------------------------
  endmodule
//-----------------------------------------------------------------------------------------------------------------
