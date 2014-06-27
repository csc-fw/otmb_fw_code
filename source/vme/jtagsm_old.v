//-----------------------------------------------------------------------------------------------------------------
`timescale 1ns / 1ps
//`define DEBUG_JTAGSM_OLD 1
//-----------------------------------------------------------------------------------------------------------------
//
//  Read User PROM and write to JTAG port
//
//  PROM data structure
//  Adr  76543210  Hex  Description
//  0  10111010  BA  Begin ALCT Marker, if "B" missing state machine stops
//  1  1000aaaa  83  ALCT  MSD 3  Type (288,384,672)
//  2  1000aaaa  88  ALCT      8
//  3  1000aaaa  84  ALCT  LSD 4
//  4  1000mmmm  80  Month MSD 0  in "hex-ascii" April 15, 2006
//  5  1000mmmm  84  Month LSD 4
//  6  1000dddd  81  Day   MSD 1
//  7  1000dddd  85  Day   LSD 5
//  8  1000yyyy  82  Year  MSD 2
//  9  1000yyyy  80  Year      0
//  A  1000yyyy  80  Year      0
//  B  1000yyyy  86  Year  LSD 6
//  C  1000vvvv  81  Version number [3:0]
//  D  1000xxxx  80  Future use
//  E  1000xxxx  80  Future use
//  F  10101010  AA  End ALCT Header Marker
// 10  0ssssttt    First JTAG word, ssss=SEL[3:0], ttt=TCK, TMS, TDI
//  L  0ssssttt    Last  JTAG word
//  L+1  11111010  FA  End of JTAG data Marker
//  L+2  1100wwww  Cw  Word Count [15:12] (includes Adr 0 and end JTAG marker)
//  L+3  1100wwww  Cw  Word Count [11:8]
//  L+4  1100wwww  Cw  Word Count [7:4]
//  L+5 1100wwww  Cw  Word Count [3:0]
//  L+6  1100cccc  Cc  Check Sum  [7:4]
//  L+7  1110cccc  Cc  Check sum  [3:0] includes addresses 0 to L+6
//  L+8  11111111  FF  End of PROM data Marker

//  PROM JTAG data [7:0] format
//  [0]  TDI
//  [1]  TMS
//  [2]  TCK
//  [3]  SEL[0]
//  [4]  SEL[1]
//  [5]  SEL[2]
//  [6]  SEL[3]
//  [7]  Flag
//
//  03/13/2006  Initial
//  03/14/2006  Sim fixes
//  04/05/2006  Add header, trailer, status data
//  04/07/2006  Add status reset for software operation
//  04/10/2006  Add jtag_oe to port list
//  04/12/2006  Remove jtag tri-states, add z to calling module, downsize word counter
//  04/13/2006  Remove prom access delay, speed inc adr to 20MHz
//  04/14/2006  Add jtag throttle
//  04/18/2006  Add fpga jtag tck counter
//  07/20/2006  Negate busy until vme_ready is asserted
//  09/22/2006  Increase machine state vector width so xst recognizes fsm
//  09/28/2006  Extend tck_fpga_cnt_done to d15, to span the allocated 4 bits
//  06/26/2008  Add tckcnt_ok to conform to version v2
//  08/19/2008  Conform to jtagsm_new port list
//  01/12/2009  Mod for ISE 10.1i
//  08/23/2010  Port to ISE 12, add register init, remove async ffs
//-----------------------------------------------------------------------------------------------------------------
  module jtagsm_old
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
  
// JTAG
  jtag_oe,
  tdi,
  tms,
  tck,
  sel,

// Status
  sreset,
  tck_fpga,
  busy,
  aborted,
  header_ok,
  chain_ok,
  tckcnt_ok,
  cksum_ok,
  wdcnt_ok,
  tck_fpga_ok,
  end_ok,
  jtagsm_ok,
  wdcnt,
  cksum,
  tck_fpga_cnt,
  prom_sm_vec,
  format_sm_vec,
  jtag_sm_vec

// Debug
`ifdef DEBUG_JTAGSM_OLD
   ,prom_sm_dsp,
  jtag_write,
  init_done,
  init_cnt_en,
  init_cnt,
  reset_done,
  reset_cnt_en,
  reset_cnt,
  clear_adr,
  next_adr,
  idle_prom,
  wdcnt_prom,
  wdcnt_cnt_en,
  wdcnt_clear,
  cksum_prom,
  blank_data,
  abort,
  header_marker,
  jtag_frame,
  trailer_frame,
  prom_end,
  trailer_cnt_en,
  trailer_cnt,
  latch_status,
  clear_status,
  prom_data_ff,
  check_flag,
  latch_prom_data
`endif
  );
//-----------------------------------------------------------------------------------------------------------------
// IO Ports
//-----------------------------------------------------------------------------------------------------------------
// Control
  input      clock;        // 40 MHz clock
  input      global_reset;    // Global reset
  input      power_up;      // DLL clock lock, we wait for it
  input      vme_ready;      // TMB VME registers loaded from PROM
  input      start;        // Cycle start command
  input      autostart;      // Enable automatic power-up
  input  [3:0]  throttle;      // JTAG speed control, 0=fastest

// PROM
  input  [7:0]  prom_data;      // prom_data[7:0]
  output      prom_clk;      // prom_ctrl[0]
  output      prom_oe;      // prom_ctrl[1]
  output      prom_nce;      // prom_ctrl[2]

// JTAG
  output      jtag_oe;      // Enable jtag drivers else tri-state
  output      tdi;        // jtag_usr[1]
  output      tms;        // jtag_usr[2]
  output      tck;        // jtag_usr[3]
  output  [3:0]  sel;        // sel_usr[3:0]

// Status
  input      sreset;        // Status signal reset
  input      tck_fpga;      // TCK from FPGA JTAG chain 
  output      busy;        // State machine busy
  output      aborted;      // State machine aborted reading PROM
  output      header_ok;      // Header marker found where expected
  output      chain_ok;      // Chain  marker found where expected
  output      tckcnt_ok;      // State machine sent correct number of TCKs to jtag
  output      cksum_ok;      // Check-sum  matches PROM contents
  output      wdcnt_ok;      // Word count matches PROM contents
  output      tck_fpga_ok;    // FPGA jtag tck detected
  output      end_ok;        // End marker detected
  output      jtagsm_ok;      // JTAG state machine completed without errors
  output  [15:0]  wdcnt;        // Word count
  output  [7:0]  cksum;        // Check sum
  output  [3:0]  tck_fpga_cnt;    // FPGA jtag tck counter
  output  [3:0]  prom_sm_vec;    // PROM control State Machine status vector
  output  [2:0]  format_sm_vec;    // Data format  State Machine status vector
  output  [1:0]  jtag_sm_vec;    // JTAG signal  State Machine status vector

//-----------------------------------------------------------------------------------------------------------------
// Debug Ports
//-----------------------------------------------------------------------------------------------------------------
`ifdef DEBUG_JTAGSM_OLD
  output  [71:0]  prom_sm_dsp;
  output      jtag_write;
  output      init_done;
  output      init_cnt_en;
  output  [6:0]  init_cnt;
  output      reset_done;
  output      reset_cnt_en;
  output  [3:0]  reset_cnt;
  output      clear_adr;
  output      next_adr;
  output      idle_prom;
  output  [15:0]  wdcnt_prom;
  output      wdcnt_cnt_en;
  output      wdcnt_clear;
  output  [7:0]  cksum_prom;
  output      blank_data;
  output      abort;
  output      header_marker;
  output      jtag_frame;
  output      trailer_frame;
  output      prom_end;
  output      trailer_cnt_en;
  output  [3:0]  trailer_cnt;
  output      latch_status;
  output      clear_status;
  output  [7:0]  prom_data_ff;
  output      check_flag;
  output      latch_prom_data;
`endif

//-----------------------------------------------------------------------------------------------------------------
// Local
//-----------------------------------------------------------------------------------------------------------------
// State Machine declarations
  reg  [9:0] prom_sm;

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

  // synthesis attribute safe_implementation of prom_sm is "yes";
  // synthesis attribute init                of prom_sm is "wait_dll";

//-----------------------------------------------------------------------------------------------------------------
// Main Logic Section
//-----------------------------------------------------------------------------------------------------------------
// FF buffer state machine trigger inputs
  reg  power_up_ff  = 0;
  reg vme_ready_ff = 0;
  reg  start_ff     = 0;
  reg  autostart_ff = 0;

  always @(posedge clock) begin
  power_up_ff  <= power_up;
  vme_ready_ff <= vme_ready;
  start_ff     <= start;
  autostart_ff <= autostart;
  end

// Signal busy if not idling or waiting for unstart
  reg busy=0;

  wire busy_en = (prom_sm != idle) && (prom_sm != unstart) && vme_ready_ff;

  always @(posedge clock) begin
  busy <= busy_en;
  end

// Control signals to the active PROM
  reg   prom_clk = 0;
  reg  prom_oe  = 1;
  reg   prom_nce = 1;
  wire prom_end;

  wire clear_adr = (prom_sm == reset_adr);
  wire next_adr  = (prom_sm == latch_prom) && !prom_end;
  wire idle_prom = (prom_sm == idle) || (prom_sm == unstart);

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
  reg [7:0] prom_data_ff=0;

  wire blank_data = 
  (prom_sm == wait_dll)  ||
  (prom_sm == wait_vme)  ||
  (prom_sm == idle)    ||
  (prom_sm == init)    ||
  (prom_sm == reset_adr);

  wire latch_prom_data = (prom_sm==latch_prom);
  
  always @(posedge clock) begin
  if (blank_data     ) prom_data_ff <= 0;
  if (latch_prom_data) prom_data_ff <= prom_data;
  end

// Decode control word from PROM
  wire trailer_busy;
  wire abort;

  wire   header_marker = (prom_data_ff[7:0] == 8'hBA);
  wire   jtag_frame   = (prom_data_ff[7]   == 1'b0 );
  wire   trailer_frame = (prom_data_ff[7:6] == 2'b11);
  assign prom_end     = (prom_data_ff[7:0] == 8'hFF) || abort;

// Transfer PROM data to JTAG chain
  reg      tdi     = 0;
  reg      tms     = 0;
  reg      tck     = 0;
  reg  [3:0]  sel     = 4'hC;
  reg      jtag_oe = 0;

  wire check_flag = (prom_sm==latch_prom);
  wire jtag_blank = blank_data || abort || !jtag_frame || wdcnt==0;
  wire jtag_write = (prom_sm==inc_adr) && jtag_frame && !jtag_blank;

  always @(posedge clock) begin
  if (jtag_blank) begin
  tdi    <= 0;
  tms    <= 0;
  tck    <= 0;
  sel    <= 4'hC;
  jtag_oe <= 0;  
  end
  if (jtag_write) begin
  tdi    <= prom_data_ff[0];
  tms    <= prom_data_ff[1];
  tck    <= prom_data_ff[2];
  sel    <= prom_data_ff[6:3];
  jtag_oe <= jtag_frame;
  end
  end

// Init delay counter waits 2uS after asserting /CE low per Xilinx datasheet
  reg [6:0] init_cnt=0;

  wire init_cnt_en = (prom_sm  == init);
  wire init_done   = (init_cnt == 80);

  always @(posedge clock) begin
  if (init_cnt_en) init_cnt <= init_cnt+1'b1;
  else             init_cnt <= 0;
  end

// Address reset delay counter asserts reset 250nS per Xilinx datasheet
  reg [3:0] reset_cnt=0;

  wire reset_cnt_en = (prom_sm == reset_adr);
  wire reset_done   = (reset_cnt == 10);

  always @(posedge clock) begin
  if (reset_cnt_en) reset_cnt <= reset_cnt+1'b1;
  else              reset_cnt <= 0;
  end

// Word counter, counts from BA to FA markers, inclusive, 512K PROMs have 512K/8=64K addresses
  reg [15:0] wdcnt      = 0;
  reg [3:0] trailer_cnt = 0;

  wire wdcnt_cnt_en = check_flag && !trailer_busy;
  wire wdcnt_clear  = (prom_sm == wait_dll) || (prom_sm == init) || sreset;
  
  always @(posedge clock) begin
  if (wdcnt_cnt_en) wdcnt <= wdcnt+1'b1;
  if (wdcnt_clear ) wdcnt <= 0;
  end

// Checksum accumulator adds data starting from BA marker to the last word-count frame, inclusive
  reg [7:0] cksum=0;

  wire cksum_cnt_en = check_flag && (trailer_cnt < 5);
  wire cksum_clear  = (prom_sm == wait_dll) || (prom_sm == init) || sreset;
  
  always @(posedge clock) begin
  if (cksum_cnt_en) cksum <= cksum + prom_data_ff;
  if (cksum_clear ) cksum <= 0;
  end

// First frame marker must be present else state machine stops
  reg abort_ff=0;

  wire abort_clear = (prom_sm == wait_dll) || (prom_sm == wait_vme) || (prom_sm == idle);

  always @(posedge clock) begin
  if (abort_clear) abort_ff <= 0;
  if (check_flag ) abort_ff <= abort;
  end

  assign abort = abort_ff || ((wdcnt == 1) && !header_marker);
  
// Trailer frame counter
  wire   trailer_cnt_clear = blank_data;
  wire   trailer_cnt_en   = check_flag && trailer_busy;
  assign trailer_busy     = (trailer_cnt != 0) || trailer_frame;

  always @(posedge clock) begin
  if (trailer_cnt_en)    trailer_cnt <= trailer_cnt+1'b1;
  if (trailer_cnt_clear)  trailer_cnt <= 0;
  end

// Trailer frame storage
  reg [15:0] wdcnt_prom=0;
  reg  [7:0]  cksum_prom=0;

  always @(posedge clock) begin
  if   (trailer_busy && prom_sm==inc_adr) begin
  case (trailer_cnt)
  4'd1:  wdcnt_prom[15:12]  <= prom_data_ff[3:0];
  4'd2:  wdcnt_prom[11:8]  <= prom_data_ff[3:0];
  4'd3:  wdcnt_prom[7:4]    <= prom_data_ff[3:0];
  4'd4:  wdcnt_prom[3:0]    <= prom_data_ff[3:0];
  4'd5:  cksum_prom[7:4]    <= prom_data_ff[3:0];
  4'd6:  cksum_prom[3:0]    <= prom_data_ff[3:0];
  endcase
  end
  if (prom_sm==wait_dll || prom_sm==idle) begin
  wdcnt_prom <= 0;
  cksum_prom <= 0;
  end
  end

// JTAG speed throttle
  reg [3:0]  throttle_ff  = 0;
  reg  [3:0]  throttle_cnt = 0;
  reg      throttle_en  = 0;

  always @(posedge clock) begin
  throttle_ff <= throttle;
  throttle_en  <= (throttle_ff != 0);
  end

  wire throttle_cnt_en = (prom_sm == persist);

  always @(posedge clock) begin
  if (throttle_cnt_en) throttle_cnt <= throttle_cnt+1'b1;
  else                 throttle_cnt <= 0;
  end

  wire throttle_done = (throttle_cnt == throttle_ff);

// Status flags
  reg tckcnt_ok = 0;
  reg wdcnt_ok  = 0;
  reg cksum_ok  = 0;
  reg jtagsm_ok = 0;
  reg aborted   = 0;

  wire latch_status = (prom_sm == unstart );
  wire clear_status = (prom_sm == wait_dll) || (prom_sm == init) || sreset;

  always @(posedge clock) begin
  if (latch_status) begin
  tckcnt_ok <= (wdcnt == wdcnt_prom) && !abort;
  wdcnt_ok  <= (wdcnt == wdcnt_prom) && !abort;
  cksum_ok  <= (cksum == cksum_prom) && !abort;
  jtagsm_ok <= (wdcnt == wdcnt_prom) && (cksum == cksum_prom) && !abort && (tck_fpga_cnt != 0);
  aborted   <= abort;
  end
  if (clear_status) begin
  tckcnt_ok <= 0;
  wdcnt_ok  <= 0;
  cksum_ok  <= 0;
  jtagsm_ok <= 0;
  aborted   <= 0;
  end
  end

// FPGA JTAG TCK counter to check that state machine can write to jtag chain 4'hC
  reg [3:0]  tck_fpga_cnt = 0;
  reg  [1:0]  tck_fpga_ff  = 0;
  reg      tck_fpga_ok  = 0;

  always @(posedge clock) begin
  if (prom_sm != idle) begin
  tck_fpga_ff[0]  <= tck_fpga;
  tck_fpga_ff[1]  <= tck_fpga_ff[0];
  end
  end

  wire tck_fpga_cnt_done = tck_fpga_cnt[3:0] == 4'hF;
  wire tck_fpga_ticked   = tck_fpga_ff[1]  && !tck_fpga_ff[0];   // tck transitioned 0-to-1
  wire tck_fpga_cnt_en   = tck_fpga_ticked && !tck_fpga_cnt_done; // stop counter at full scale

  always @(posedge clock) begin
  if (clear_status   ) tck_fpga_cnt <= 0;
  if (tck_fpga_cnt_en) tck_fpga_cnt <= tck_fpga_cnt+1'b1;
  end

  always @(posedge clock) begin
  if (clear_status) tck_fpga_ok <= 0;
  if (latch_status) tck_fpga_ok <= (tck_fpga_cnt != 0);
  end

//-----------------------------------------------------------------------------------------------------------------
//  PROM-Reader State machine
//-----------------------------------------------------------------------------------------------------------------
  always @(posedge clock) begin

  if      (global_reset) prom_sm <= wait_dll;
  else if  (sreset      ) prom_sm <= idle;
  else begin
  case (prom_sm)
  
  wait_dll:                    // Wait for FPGA DLLs to lock
   if (power_up_ff)  prom_sm <= wait_vme;    // FPGA is ready

  wait_vme:                    // Wait for VME registers to load
   if (vme_ready_ff)                // VME loaded from PROM
   begin
   if (autostart_ff)  prom_sm <= init;      // Start cycle if autostart enabled
   else        prom_sm <= idle;      // Otherwise stay idle
   end

  idle:                      // Wait for VME command to program, power down PROM
   if (start_ff)    prom_sm <= init;      // Start arrived

  init:
   if (init_done)    prom_sm <= reset_adr;    // Power up PROM, 2uS delay

  reset_adr:
   if (reset_done)  prom_sm <= prom_taccess;  // Reset PROM address, 250nS delay
  
  prom_taccess:    prom_sm <= latch_prom;    // Relase reset, wait for output to assert 10ns minimum

  latch_prom:      prom_sm <= inc_adr;      // Latch PROM data

  inc_adr:                    // Increment PROM address
   if (prom_end)    prom_sm <= unstart;      // First-word marker missing or hit end of PROM data
   else 
   if (throttle_en)  prom_sm <= persist;      // JTAG runs at slower speed
   else        prom_sm <= latch_prom;    // JTAG runs at full speed

  persist:
   if (throttle_done)  prom_sm <= latch_prom;    // JTAG speed decrease

  unstart:
   if (!start_ff)    prom_sm <= idle;      // Wait for VME write command to go away

  default        prom_sm <= wait_dll;
  endcase
  end
  end

// PROM Machine status Vectors
  reg[3:0] prom_sm_vec;

  always @(posedge clock) begin
  case (prom_sm)
  wait_dll:    prom_sm_vec <= 4'h0;
  wait_vme:    prom_sm_vec <= 4'h1;
  idle:      prom_sm_vec <= 4'h2;
  init:      prom_sm_vec <= 4'h3;
  reset_adr:    prom_sm_vec <= 4'h4;
  prom_taccess:  prom_sm_vec <= 4'h5;
  latch_prom:    prom_sm_vec <= 4'h6;
  inc_adr:    prom_sm_vec <= 4'h7;
  persist:    prom_sm_vec <= 4'h8;
  unstart:    prom_sm_vec <= 4'h9;
  default      prom_sm_vec <= 4'hA;
  endcase
  end

// Conforming status signals, not used in this version
  assign header_ok      = jtagsm_ok;  // Header marker found where expected
  assign chain_ok        = jtagsm_ok;  // Chain  marker found where expected
  assign end_ok        = jtagsm_ok;  // End marker detected
  assign format_sm_vec[2:0]  = 0;      // Data format  State Machine status vector
  assign jtag_sm_vec[1:0]    = 0;      // JTAG signal  State Machine status vector

//-----------------------------------------------------------------------------------------------------------------
// Debug
//-----------------------------------------------------------------------------------------------------------------
`ifdef DEBUG_JTAGSM_OLD
// PROM State Machine ASCII display
  reg [71:0] prom_sm_dsp;

  always @* begin
  case (prom_sm)
  wait_dll:    prom_sm_dsp <= "wait_dll ";
  wait_vme:    prom_sm_dsp <= "wait_vme ";
  idle:      prom_sm_dsp <= "idle     ";
  init:      prom_sm_dsp <= "init     ";
  reset_adr:    prom_sm_dsp <= "reset_adr";
  prom_taccess:  prom_sm_dsp <= "prom_tacc";
  latch_prom:    prom_sm_dsp <= "latch_prm";
  inc_adr:    prom_sm_dsp <= "inc_adr  ";
  persist:    prom_sm_dsp <= "persist  ";
  unstart:    prom_sm_dsp <= "unstart  ";
  default      prom_sm_dsp <= "wait_dll ";
  endcase
  end
`endif

//-----------------------------------------------------------------------------------------------------------------
  endmodule
//-----------------------------------------------------------------------------------------------------------------
