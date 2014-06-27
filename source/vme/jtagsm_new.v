`timescale 1ns / 1ps
//`define DEBUG_JTAGSM_NEW = 1
//-----------------------------------------------------------------------------------------------------------------
//  Reads User PROM and writes to JTAG port
//-----------------------------------------------------------------------------------------------------------------
//  PROM data structure
//  Adr  76543210  Hex  Description
//  0  10111010  BA  Begin ALCT Marker, if "B" missing state machine stops
//  1  1000aaaa  83  ALCT  MSD 3  Type (288,384,672)
//  2  1000aaaa  88  ALCT      8
//  3  1000aaaa  84  ALCT  LSD 4
//  4  1000mmmm  80  Month MSD 0  in "hex-ascii" June 9, 2008
//  5  1000mmmm  86  Month LSD 6
//  6  1000dddd  80  Day   MSD 0
//  7  1000dddd  89  Day   LSD 9
//  8  1000yyyy  82  Year  MSD 2
//  9  1000yyyy  80  Year      0
//  A  1000yyyy  80  Year      0
//  B  1000yyyy  88  Year  LSD 8
//  C  1000vvvv  81  Version number [3:0]
//  D  1000xxxx  80  Future use
//  E  1000xxxx  80  Future use
//  F  10101010  EA  End ALCT Header Marker
//
//  10  1100ssss  Cs  Begin Marker for Chain ssss[3:0]
//  11  tttttttt  ww  TCK count [15:8]
//  12  tttttttt  ww  TCK count [7:0]
//  13  sisisisi  si  JTAG data
//  14  sisisisi  si  JTAG data
//  15  sisisisi  si  JTAG data
//
//  16  1100ssss  Cs  Begin Marker for Chain ssss[3:0]
//  17  tttttttt  ww  TCK count [15:8]
//  18  tttttttt  ww  TCK count [7:0]
//  19  sisisisi  si  JTAG data
//  20  sisisisi  si  JTAG data
//  21  sisisisi  si  JTAG data
//
//  T-1  11111010  FC  End of JTAG data Marker
//  T+0 tttttttt  tt  TCK Count Total [17:16]  Includes tcks sent for all chain blocks
//  T+1  tttttttt  tt  TCK Count Total [15:8]
//  T+2  tttttttt  tt  TCK Count Total [7:0]
//  T+3 wwwwwwww  ww  Word Count [15:8]    Includes Adr0[BA] to last adr[FF]
//  T+4 wwwwwwww  ww  Word Count [7:0]
//  T+5  cccccccc  cc  Check sum  [7:0]    Includes addresses 0 thru T+4, does not include itself or FF
//  T+6  11111111  FF  End of PROM data Marker
//
//  PROM JTAG data [7:0] format
//  [0]  TDI[0]
//  [1]  TMS[0]
//  [2]  TDI[1]
//  [3]  TMS[1]
//  [4]  TDI[2]
//  [5]  TMS[2]
//  [6]  TDI[3]
//  [7]  TMS[3]
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
//  06/06/2008  Add debug ifdef
//  06/09/2008  Convert to new format
//  06/12/2008  PROM byte-reading machine decoupled from format scanner machine
//  06/26/2008  Debug done, port to tmb2005x
//  07/01/2008  Add end_ok and abort to port list, add tck loopback for debug
//  07/03/2008  Mod to hold tck high and end of chain unless D-code overrides
//  07/04/2008  Rewrite to make prom machine master
//  07/06/2008  Put tck check back in, begin new format machine
//  07/07/2008  Add tck high option on c-block code, hold jtag between chain blocks
//  07/07/2008  Mod state machine resets
//  07/08/2008  Mod status clearing
//  01/12/2009  Mod for ISE 10.1i
//  08/24/2010  Port to ISE 12, non blocking operators, replace sim prom tristate logic
//-----------------------------------------------------------------------------------------------------------------
  module jtagsm_new
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
`ifdef DEBUG_JTAGSM_NEW 
   ,prom_sm_dsp,
  format_sm_dsp,
  jtag_sm_dsp,

  init_done,
  init_cnt_en,
  init_cnt,

  reset_done,
  reset_cnt_en,
  reset_cnt,

  taccess,
  taccess_done,

  clear_adr,
  next_adr,
  idle_prom,
  prom_case,

  prom_ready,
  last_word,
  next_chain_word,
  next_chain_latch,
  last_word_latch,

  latch_prom_data,
  hold_prom_adr,
  prom_data_ff,

  reset_prom,
  prom_end,
  chain_end,
  chain_ending,
  chain_exit,
  next_adr_en,
  goto_idle,

  header_frame,
  trailer_frame,
  inc_adr_slow,

  fetch_cnt,
  fetch_max,
  fetch_cnt_clr,
  fetch_cnt_en,
  fetch_done,

  trailer_cnt,
  load_trailer_cnt,
  trailer_clear,

  tckcnt_prom,
  wdcnt_prom,
  cksum_prom,

  header_marker,
  chain_marker,
  end_marker,
  all_ok,

  latch_status,
  clear_status,
  cksum_cnt_en,

  throttle_cnt,
  throttle_max,
  throttle_cnt_en,
  throttle_done,

  jtag_write,
  chain_sel,
  chain_latch,
  hold_tck_high,

  tckcnt0_latch,
  tckcnt1_latch,
  tck_cnt,

  tck_sent_cnt,
  tck_total_cnt,

  tck_low_done,
  tck_high_done,
  tck_cnt_done,

  tck_scan,
  tdi_scan,
  tms_scan,
  jtag_data,
  tck_scan_valid,

// PROM emulator
  adr,
  inc_adr_rom,
  adr_reset
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
  `ifndef DEBUG_JTAGSM_NEW 
  input  [7:0]  prom_data;      // Data input from PROM
  `else
  inout  [7:0]  prom_data;      // Data input from simulator ROM
  `endif
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
`ifdef DEBUG_JTAGSM_NEW 
  output  [71:0]  prom_sm_dsp;
  output  [95:0]  format_sm_dsp;
  output  [87:0]  jtag_sm_dsp;

  output      init_done;
  output      init_cnt_en;
  output  [6:0]  init_cnt;

  output      reset_done;
  output      reset_cnt_en;
  output  [3:0]  reset_cnt;

  output      taccess;
  output      taccess_done;

  output      clear_adr;
  output      next_adr;
  output      idle_prom;
  output  [2:0]  prom_case;

  output      prom_ready;
  output  [15:0]  last_word;
  output  [15:0]  next_chain_word;
  output      next_chain_latch;
  output      last_word_latch;

  output      latch_prom_data;
  output      hold_prom_adr;
  output  [7:0]  prom_data_ff;

  output      reset_prom;
  output      prom_end;
  output      chain_end;
  output      chain_ending;
  output      chain_exit;
  output      next_adr_en;
  output      goto_idle;

  output      header_frame;
  output      trailer_frame;
  output      inc_adr_slow;

  output  [7:0]  fetch_cnt;
  output  [7:0]  fetch_max;
  output      fetch_cnt_clr;
  output      fetch_cnt_en;
  output      fetch_done;

  output  [2:0]  trailer_cnt;
  output      load_trailer_cnt;
  output      trailer_clear;

  output  [17:0]  tckcnt_prom;
  output  [15:0]  wdcnt_prom;
  output  [7:0]  cksum_prom;

  output      header_marker;
  output      chain_marker;
  output      end_marker;
  output  [7:0]  all_ok;

  output      latch_status;
  output      clear_status;
  output      cksum_cnt_en;

  output  [3:0]  throttle_cnt;
  output  [3:0]  throttle_max;
  output      throttle_cnt_en;
  output      throttle_done;

  output      jtag_write;
  output  [3:0]  chain_sel;
  output      chain_latch;
  output      hold_tck_high;

  output      tckcnt0_latch;
  output      tckcnt1_latch;
  output  [15:0]  tck_cnt;

  output  [15:0]  tck_sent_cnt;
  output  [17:0]  tck_total_cnt;

  output      tck_low_done;
  output      tck_high_done;
  output      tck_cnt_done;

  output      tck_scan;
  output      tdi_scan;
  output      tms_scan;
  output  [7:0]  jtag_data;
  output      tck_scan_valid;

// PROM emulator
  output  [5:0]  adr;
  output      inc_adr_rom;
  output      adr_reset;
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
  parameter hold_adr    =  4'h7;
  parameter inc_adr    =  4'h8;
  parameter unstart    =  4'h9;

  // synthesis attribute safe_implementation of prom_sm is "yes";
  // synthesis attribute init                of prom_sm is "wait_dll";

  reg  [6:0] format_sm;

  parameter wait_prom    =  3'h0;
  parameter check_header  =  3'h1;
  parameter wait_chain  =  3'h2;
  parameter load_chain  =  3'h3;
  parameter load_tckcnt0  =  3'h4;
  parameter load_tckcnt1  =  3'h5;
  parameter abend      =  3'h6;

  // synthesis attribute safe_implementation of format_sm is "yes";
  // synthesis attribute init                of format_sm is "wait_prom";

  reg  [2:0] jtag_sm;

  parameter wait_format  =  2'h0;
  parameter tck_low    =  2'h1;
  parameter tck_high    =  2'h2;

  // synthesis attribute safe_implementation of jtag_sm is "yes";
  // synthesis attribute init                of jtag_sm is "wait_format";

//--------------------------------------------------------------------------------------------
// Power up
//--------------------------------------------------------------------------------------------
// FF buffer state machine trigger inputs
  reg  power_up_ff = 0;
  reg vme_ready_ff= 0;
  reg  start_ff  = 0;
  reg  autostart_ff= 0;

  always @(posedge clock) begin
  power_up_ff  <= power_up;
  vme_ready_ff <= vme_ready;
  start_ff     <= start;
  autostart_ff <= autostart;
  end

// Signal busy if not idling or waiting for unstart
  reg busy = 1;

  wire busy_en = (prom_sm != idle) && (prom_sm != unstart);

  always @(posedge clock) begin
  busy <= busy_en;
  end
//--------------------------------------------------------------------------------------------
// Control signals to the active PROM
//--------------------------------------------------------------------------------------------
  reg   prom_clk  = 0;
  reg  prom_oe  = 0;
  reg   prom_nce  = 1;

  wire reset_prom;
  wire prom_end;
  wire next_adr_en;

  wire clear_adr  =  (prom_sm == init) || (prom_sm == reset_adr);
  wire next_adr  = ((prom_sm == latch_prom) || (prom_sm == hold_adr)) && !prom_end  && next_adr_en;
  wire idle_prom  =  (prom_sm == idle) || (prom_sm == unstart) || (prom_sm == wait_dll) || (prom_sm == wait_vme) || global_reset;
  wire taccess  =  (prom_sm == prom_taccess);

  always @(posedge clock) begin
  if (idle_prom) begin            // PROM case 1: powered down
  prom_clk <= 0;  // 0=take clk low for idling
  prom_oe   <= 0;  // 0=reset address, outputs disabled
  prom_nce <= 1;  // 1=chip not selected
  end
  else if (clear_adr) begin          // PROM case 2: enabled, clearing address
  prom_clk <= 0;  // 0=take clock low, it was prolly idle high
  prom_oe   <= 0;  // 0=reset address, outputs disabled
  prom_nce <= 0;  // 0=chip selected
  end
  else if (taccess) begin            // PROM case 3: enabled, read adr 0
  prom_clk <= 0;  // 0=take clock low, it was prolly idle high
  prom_oe   <= 1;  // 0=reset address, outputs disabled
  prom_nce <= 0;  // 0=chip selected
  end
  else if (next_adr) begin          // PROM case 4: enabled, clock=1
  prom_clk <= 1;  // 1=advance address
  prom_oe   <= 1;  // 1=outputs enabled
  prom_nce <= 0;  // 0=chip selected
  end
  else begin                  // PROM case 5: enabled, clock=0
  prom_clk <= 0;  // 0=hold address
  prom_oe   <= 1;  // 1=outputs enabled
  prom_nce <= 0;  // 0=chip selected
  end
  end

// Latch PROM data and address, 512K PROMs have 512K/8=64K addresses
  reg [ 7:0] prom_data_ff = 0;
  reg [15:0] wdcnt        = 0;

  wire clear_prom_data = (prom_sm == wait_dll  ) || (prom_sm==init) || sreset;
  wire latch_prom_data = (prom_sm == latch_prom);
  wire hold_prom_adr   = (prom_sm == hold_adr  );

  always @(posedge clock) begin
  if (clear_prom_data)  begin
  prom_data_ff  <= 0;
  wdcnt      <= 0;
  end
  if (latch_prom_data)  begin
  prom_data_ff  <= prom_data;
  wdcnt      <= wdcnt+1'b1;
  end
  end

// Checksum accumulator adds data starting from BA marker to the last word-count frame, inclusive
  reg [7:0] cksum      = 0;
  reg [2:0] trailer_cnt  = 0;

  wire cksum_cnt_en = latch_prom_data && (trailer_cnt < 5);
  
  always @(posedge clock) begin
  if (clear_prom_data) cksum <= 0;
  if (cksum_cnt_en   ) cksum <= cksum + prom_data_ff;
  end

//-----------------------------------------------------------------------------------------------------------------
//  PROM-Reader State Machine Signals
//-----------------------------------------------------------------------------------------------------------------
// Init delay counter waits 2uS after asserting /CE low per Xilinx datasheet
  `ifdef DEBUG_JTAGSM_NEW 
  parameter init_fullscale = 3;  // 75nS for fast simulation
  `else
  parameter init_fullscale = 80;  // 80x25nS=2uS for normal mode
  `endif

  reg [6:0] init_cnt = 0;

  wire init_cnt_en = (prom_sm  == init);
  wire init_done   = (init_cnt == init_fullscale);

  always @(posedge clock) begin
  if (init_cnt_en) init_cnt <= init_cnt+1'b1;
  else        init_cnt <= 0;
  end

// Address reset delay counter asserts reset 250nS per Xilinx datasheet
  reg [3:0] reset_cnt = 0;

  wire reset_cnt_en = (prom_sm == reset_adr);
  wire reset_done   = (reset_cnt == 10);

  always @(posedge clock) begin
  if (reset_cnt_en) reset_cnt <= reset_cnt+1'b1;
  else        reset_cnt <= 0;
  end

// Access delay counter waits for PROM output after oe enabled
  reg [1:0] taccess_cnt;

  wire taccess_cnt_en = (prom_sm == prom_taccess);
  wire taccess_done   = (taccess_cnt == 2);

  always @(posedge clock) begin
  if (taccess_cnt_en) taccess_cnt <= taccess_cnt+1'b1;
  else        taccess_cnt <= 0;
  end

// PROM Word Pointers
  reg [15:0] next_chain_word  = 16'h0011;  // Point to 1st byte after header
  reg [15:0] last_word    = 16'hFFFF;  // Point to last prom byte
  reg [15:0] tck_cnt      = 0;
  reg       chain_end    = 0;
  reg       next_chain_latch = 0;

  wire chain_ready;
  wire chain_ending;
  wire chain_latch;

  wire last_word_latch =  chain_ending;

  wire [15:0] full_chain_words  = tck_cnt/4;    // Number of full jtag data bytes in this chain
  wire        partial_chain_words = |tck_cnt[1:0];  // Number of partial jtag data bytes, either 0 or 1
  wire [15:0] nchain_words        = full_chain_words+partial_chain_words;

  always @(posedge clock) begin
  if      (clear_prom_data ) next_chain_word <= 16'h0011;                // Point to 1st byte after header
  else if (next_chain_latch) next_chain_word <= next_chain_word+16'd3+nchain_words;  // Point to next chain marker
  end

  always @(posedge clock) begin
  if      (clear_prom_data) last_word <= 16'hFFFF;        // Point to last prom byte
  else if (last_word_latch) last_word <= next_chain_word+16'd6;  // Point to last trailer word
  end

  assign chain_ready  = (wdcnt==next_chain_word);          // Reached next chain adddress
  assign prom_end    = (wdcnt==last_word) || aborted;      // Reached last prom  address

// PROM read fetch speed select, fast thru header, slow thru jtag bytes
  wire fetch_done;
  wire header_frame  = (wdcnt < 'h10);
  wire trailer_frame = (wdcnt >  last_word-6);
  wire inc_adr_slow  = !(header_frame||trailer_frame);
  wire inc_adr_fast  = !inc_adr_slow || (chain_end || chain_ending);
  
  assign next_adr_en = (inc_adr_fast) ? 1'b1 : fetch_done;

// PROM read fetch speed defines JTAG tck period, wait 100ns per tck + 2*4*throttle
  parameter  fetch_min = 16-3;  // 400ns per prom byte, throttle=0, 3bx overhead subtracted
  reg   [7:0] fetch_cnt = 0;
  wire [7:0] fetch_max;

  wire   fetch_cnt_en  = hold_prom_adr && inc_adr_slow;
  wire   fetch_cnt_clr = inc_adr_fast||latch_prom_data;
  assign fetch_max     = fetch_min+(throttle<<3);      // fetch_min+8*(throttle, tck=1 add 1bx, tck=0 add 1bx, 4tck/byte=add 8bx

  always @(posedge clock) begin
  if     (fetch_cnt_clr)  fetch_cnt <= 0;
  else if (fetch_cnt_en )  fetch_cnt <= fetch_cnt+1'b1;
  end

  assign fetch_done = (fetch_cnt==fetch_max);

// Store trailer frames
  reg [17:0] tckcnt_prom   = 0;
  reg [15:0] wdcnt_prom    = 0;
  reg  [ 7:0] cksum_prom    = 0;

  wire   load_trailer_cnt = latch_prom_data && trailer_frame;
  wire   trailer_clear  = !trailer_frame;

  always @(posedge clock)begin
  if   (load_trailer_cnt) begin
  case (trailer_cnt)
  3'd0:  tckcnt_prom[17:16]  <= prom_data_ff[1:0];
  3'd1:  tckcnt_prom[15:8]  <= prom_data_ff[7:0];
  3'd2:  tckcnt_prom[7:0]  <= prom_data_ff[7:0];
  3'd3:  wdcnt_prom[15:8]  <= prom_data_ff[7:0];
  3'd4:  wdcnt_prom[7:0]    <= prom_data_ff[7:0];
  3'd5:  cksum_prom[7:0]    <= prom_data_ff[7:0];
  endcase
  trailer_cnt <= trailer_cnt+1'b1;
  end
  else if (trailer_clear)
  trailer_cnt  <= 0;
  end
  wire end_marker  = (trailer_cnt==6) && (prom_data_ff==8'hFF);  // No strobe for this

// Status flags
  reg [17:0] tck_total_cnt = 0; // TCKs sent all chains

  reg header_ok  = 0;
  reg chain_ok  = 0;
  reg  tckcnt_ok  = 0;
  reg wdcnt_ok  = 0;
  reg cksum_ok  = 0;
  reg end_ok    = 0;
  reg jtagsm_ok  = 0;
  reg status_nos  = 0;

  wire header_marker;
  wire chain_marker;
  wire tck_fpga_cnt_ok;
  wire [7:0] all_ok;
  reg   tck_fpga_ok = 0;

  wire latch_status = (prom_sm==unstart) && !status_nos;  // oneshot at unstart
  wire clear_status = (prom_sm == wait_dll) || (prom_sm == init) || sreset;

  wire latch_headerid = (format_sm==check_header);
  wire latch_chainid  = (format_sm==load_chain);

  assign all_ok[0] = header_ok;
  assign all_ok[1] = chain_ok;
  assign all_ok[2] = (wdcnt == wdcnt_prom); 
  assign all_ok[3] = (cksum == cksum_prom);
  assign all_ok[4] = end_marker;
  assign all_ok[5] = tck_fpga_cnt_ok;
  assign all_ok[6] = (tck_total_cnt == tckcnt_prom);
  assign all_ok[7] = !aborted;

  always @(posedge clock) begin
  if (clear_status) begin
  header_ok  <= 0;
  chain_ok  <= 0;
  tckcnt_ok  <= 0;
  wdcnt_ok  <= 0;
  cksum_ok  <= 0;
  end_ok    <= 0;
  tck_fpga_ok  <= 0;
  jtagsm_ok  <= 0;
  status_nos  <= 0;
  end
  else begin
  if (latch_headerid) header_ok <= header_marker;
  if (latch_chainid ) chain_ok  <= chain_marker;
  if (latch_status  ) begin
  tckcnt_ok  <= (tck_total_cnt == tckcnt_prom);
  wdcnt_ok  <= (wdcnt == wdcnt_prom);
  cksum_ok  <= (cksum == cksum_prom);
  end_ok    <= end_marker;
  tck_fpga_ok  <= tck_fpga_cnt_ok;
  jtagsm_ok  <= &all_ok;
  status_nos  <= 1; 
  end
  end
  end

// FPGA JTAG TCK counter to check that state machine can write to jtag chain 4'hC
  reg [3:0]  tck_fpga_cnt = 0;
  reg  [1:0]  tck_fpga_ff  = 0;

  always @(posedge clock) begin
  if (prom_sm != idle) begin
  tck_fpga_ff[0]  <= tck_fpga;
  tck_fpga_ff[1]  <= tck_fpga_ff[0];
  end
  end

  wire tck_fpga_cnt_done = (tck_fpga_cnt[3:0]==4'hF);        // Stop counter at full scale so it wont wrap
  wire tck_fpga_ticked   = tck_fpga_ff[1]  && !tck_fpga_ff[0];   // tck transitioned 0-to-1
  wire tck_fpga_cnt_en   = tck_fpga_ticked && !tck_fpga_cnt_done;

  always @(posedge clock) begin
  if (clear_status)  tck_fpga_cnt <= 0;
  if (tck_fpga_cnt_en)tck_fpga_cnt <= tck_fpga_cnt+1'b1;
  end
  
  assign tck_fpga_cnt_ok = (tck_fpga_cnt != 0);          // At least one tick looped back

// PROM marker must be present where expected else state machine stops
  reg aborted=0;
  
  wire oh_noes = ((wdcnt == 1) && !header_marker) || (format_sm == abend);

  always @(posedge clock) begin
  if (clear_status) aborted <= 0;
  else              aborted <= oh_noes || aborted;
  end

  assign reset_prom = (sreset || aborted || (jtag_sm == abend)) && !((prom_sm == unstart) || (prom_sm == idle));

// Unstart goes to idle when all state machines are done
  wire goto_idle = (format_sm == wait_prom) && !start_ff;

//-----------------------------------------------------------------------------------------------------------------
//  PROM-Reader State Machine inits PROM, steps through addresses according to next_adr from jtag machine
//-----------------------------------------------------------------------------------------------------------------
  always @(posedge clock) begin
  if    (global_reset)  prom_sm <= wait_dll;
  else if  (reset_prom)  prom_sm <= unstart;
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
  
  prom_taccess:
   if (taccess_done)  prom_sm <= latch_prom;    // Release reset, wait for output to assert 10ns minimum

  latch_prom:                    // Latch PROM data
   if     (prom_end)  prom_sm <= unstart;      // First-word marker missing or hit end of PROM data
   else if(next_adr)  prom_sm <= inc_adr;      // Fast mode: go to next adr
   else        prom_sm <= hold_adr;      // Slow mode: hold current address until jtag byte scan is complete
   
  hold_adr:                    // Hold current address until jtag byte scan is complete
   if(next_adr)    prom_sm <= inc_adr;      // Tis complete

  inc_adr:      prom_sm <= latch_prom;    // Increment PROM address

  unstart:
   if(goto_idle)    prom_sm <= idle;      // Wait for VME write command to go away

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
  hold_adr:    prom_sm_vec <= 4'h7;
  inc_adr:    prom_sm_vec <= 4'h8;
  unstart:    prom_sm_vec <= 4'h9;
  default      prom_sm_vec <= 4'hA;
  endcase
  end

//-----------------------------------------------------------------------------------------------------------------
// Transfer PROM data to JTAG chain
//-----------------------------------------------------------------------------------------------------------------
  reg      tdi = 0;        // JTAG output FFs
  reg      tms = 0;
  reg      tck = 0;
  reg  [3:0]  sel = 4'hC;        // Default points to empty FPGA JTAG Loop chain
  reg      jtag_oe = 0;

  wire    tck_scan;        // Asstert tck,tms,tdi prom data
  reg      tdi_scan;        // do not init
  reg      tms_scan;        // do not init
  wire    tck_scan_valid;

  reg [3:0]  chain_sel     = 4'hC;  // Chain adr from prom
  reg      hold_tck_high = 1;

// JTAG output enable
  reg jtag_oe_ff=0;

  wire jtag_oe_clear = !busy || chain_ending || aborted;
  wire jtag_write= tck_scan_valid;

  always @(posedge clock) begin
  if      (jtag_oe_clear) jtag_oe_ff <= 0;
  else if (chain_latch  ) jtag_oe_ff <= 1;
  end

// JTAG bus drivers
  always @(posedge clock) begin
  jtag_oe <= jtag_oe_ff;
  end

  always @(posedge clock) begin
  if (jtag_write) begin    // Assert JTAG signals read from prom byte scan
  tck    <= tck_scan;
  tms    <= tms_scan;
  tdi    <= tdi_scan;
  sel    <= chain_sel[3:0];
  end
  else if (jtag_oe_ff) begin  // Assert JTAG signals between chain blocks
  tck    <= hold_tck_high;
  tms    <= 0;
  tdi    <= 0;
  sel    <= chain_sel[3:0];
  end
  else begin          // Release JTAG signals when machines are idle
  tdi    <= 0;
  tms    <= 0;
  tck    <= 0;
  sel    <= 4'hC;
  end
  end

//-----------------------------------------------------------------------------------------------------------------
// Format State Machine Signals
//-----------------------------------------------------------------------------------------------------------------
// Wait for PROM to go ready
  wire prom_ready = latch_prom_data && (wdcnt==0);

// Load JTAG chain address and check chain frame marker Bs
  wire [3:0] chain_adr;
  wire chain_exit;

  assign header_marker = (prom_data_ff[7:0]==8'hBA);
  assign chain_marker  = (prom_data_ff[7:4]==4'hC )||(prom_data_ff[7:4]==8'hD )||(prom_data_ff[7:0]==8'hFC);
  assign chain_latch   = (format_sm == load_chain) && latch_prom_data && !(header_frame || trailer_frame);
  assign chain_adr     =  prom_data_ff[3:0];      // New chain address
  assign hold_tck_flag = !prom_data_ff[4];      // C=hold tck high, D=hold tck low
  assign chain_exit   =  prom_data_ff[7:0]==8'hFC;  // Last chain marker
  assign chain_ending  =  chain_exit && chain_latch;  // Last chain marker lookahead

  always @(posedge clock) begin
  if (clear_status) begin
  chain_sel     <= 4'hC;
  hold_tck_high <= 1;
  chain_end    <= 0;
  end
  if (chain_latch) begin 
  chain_sel     <= chain_adr;    // New chain adr
  hold_tck_high <= hold_tck_flag;  // New tck mode
  chain_end    <= chain_exit;  // Reached last chain address
  end
  end

// Load 2 byte TCK word count
  wire  tckcnt0_latch = (format_sm==load_tckcnt0) && latch_prom_data && !chain_end;
  wire  tckcnt1_latch = (format_sm==load_tckcnt1) && latch_prom_data && !chain_end;

  always @(posedge clock) begin
  if (clear_status)  tck_cnt <= 0;
  else begin
  if (tckcnt0_latch) tck_cnt[15:8] <= prom_data_ff[7:0];  // Load MSBs first
  if (tckcnt1_latch) tck_cnt[7:0]  <= prom_data_ff[7:0];  // Load LSBs last
  next_chain_latch <= tckcnt1_latch;            // All bytes loaded
  end
  end

//-----------------------------------------------------------------------------------------------------------------
// JTAG State Machine Signals
//-----------------------------------------------------------------------------------------------------------------
// Wait for format machine to load a chain block
  wire format_ready = next_chain_latch;

// Count TCKs sent
  reg [15:0] tck_sent_cnt=0;  // TCKs sent this chain

  wire throttle_done;
  wire tck_low_done;
  wire tck_high_done;

  always @(posedge clock) begin
  if    (clear_status ) tck_total_cnt <= 0;
  else if  (tck_high_done) tck_total_cnt <= tck_total_cnt+1'b1;
  end

  always @(posedge clock) begin
  if    (format_ready ) tck_sent_cnt <= 0;
  else if  (tck_high_done) tck_sent_cnt <= tck_sent_cnt+1'b1;
  end

  wire tck_cnt_done = (tck_sent_cnt == tck_cnt);

// Store JTAG data byte
  reg [7:0] jtag_data;
  
  always @(posedge clock) begin
  jtag_data <= prom_data_ff;
  end

// Select TDI,TMS pair pointed to by scan counter, could use shift reg here but incur clocking delay
  assign tck_scan       =  (jtag_sm == tck_high);
  assign tck_scan_valid = ((jtag_sm == tck_high)||(jtag_sm == tck_low)) && !tck_cnt_done;
  
  always @* begin
  case (tck_sent_cnt[1:0])
  2'd0: {tms_scan,tdi_scan}  <= jtag_data[1:0];
  2'd1: {tms_scan,tdi_scan}  <= jtag_data[3:2];
  2'd2: {tms_scan,tdi_scan}  <= jtag_data[5:4];
  2'd3: {tms_scan,tdi_scan}  <= jtag_data[7:6];
  endcase
  end

// JTAG speed throttle
  parameter  throttle_min = 4'd1;  // Adds 1bx minimum to throttle timer, so tck persists at least 2bx
  reg   [3:0] throttle_cnt = 0;
  wire [3:0] throttle_max;

  wire   throttle_cnt_en = ((jtag_sm == tck_low) || (jtag_sm == tck_high)) && !throttle_done;
  assign throttle_max    = throttle+throttle_min;

  always @(posedge clock) begin
  if (throttle_cnt_en) throttle_cnt <= throttle_cnt+1'b1;
  else                 throttle_cnt <= 0;
  end

  assign throttle_done = (throttle_cnt == throttle_max);
  assign tck_low_done  = ((jtag_sm == tck_low ) && throttle_done);
  assign tck_high_done = ((jtag_sm == tck_high) && throttle_done);

//-----------------------------------------------------------------------------------------------------------------
// PROM Format State Machine interprets embedded PROM chain blocks
//-----------------------------------------------------------------------------------------------------------------
  always @(posedge clock) begin
  if    (global_reset)  format_sm <= wait_prom;
  else if  (sreset)    format_sm <= wait_prom;
  else begin

  case (format_sm)
  
  wait_prom:                      // Wait for PROM to read adr 0
   if (prom_ready)    format_sm <= check_header;  // Adr 0 has been read

  check_header:                    // Check 1st header frame is correct
   if (header_marker)    format_sm <= wait_chain;  // Tis
   else          format_sm <= abend;      // Tisnt

  wait_chain:                      // Wait for PROM to read next chain marker
   if (chain_ready)    format_sm <= load_chain;    // Reached chain location

  load_chain:                      // Load chain adr and marker
   if (latch_prom_data) begin
   if (chain_exit)    format_sm <= wait_prom;    // No more chains left
   else if
      (chain_marker)    format_sm <= load_tckcnt0;  // Chain adr and marker are OK, begin jtag scan
   else          format_sm <= abend;      // Marker error detected
  end

  load_tckcnt0:                    // Load 1st TCK count frame
   if (latch_prom_data)  format_sm <= load_tckcnt1;  // Wait for PROM data latch

  load_tckcnt1:
   if (latch_prom_data)  format_sm <= wait_chain;  // All tck count frames loaded

  abend:          format_sm <= wait_prom;    // Error in PROM format detected

  default          format_sm <= wait_prom;    // Initial state
  endcase
  end
  end

// Format Machine status Vectors
  reg [2:0] format_sm_vec;

  always @(posedge clock) begin
  case (format_sm)
  wait_prom:    format_sm_vec <= 'h0;
  check_header:  format_sm_vec <= 'h1;
  wait_chain:    format_sm_vec <= 'h2;
  load_chain:    format_sm_vec <= 'h3;
  load_tckcnt0:  format_sm_vec <= 'h4;
  load_tckcnt1:  format_sm_vec <= 'h5;
  abend:      format_sm_vec <= 'h6;
  default      format_sm_vec <= 'h7;
  endcase
  end

//-----------------------------------------------------------------------------------------------------------------
// JTAG Data Shift State Machine
//-----------------------------------------------------------------------------------------------------------------
  always @(posedge clock) begin
  if    (global_reset)  jtag_sm <= wait_format;
  else if  (sreset)    jtag_sm <= wait_format;
  else begin

  case (jtag_sm)
  
  wait_format:                  // Wait for format machine to load a chain block
   if (format_ready)  jtag_sm <= tck_low;      // Chain block loaded

  tck_low:                    // Set tck low, assert tms,tdi
   if (tck_low_done) begin            // Holding tck low until throttle done
   if (tck_cnt_done)  jtag_sm <= wait_format;    // Finished current chain
   else        jtag_sm <= tck_high;      // Go to tck high
   end

  tck_high:                    // Set tck high, hold tms, tdi
   if (tck_high_done)  jtag_sm <= tck_low;      // Holding tck high until throttle done

  default        jtag_sm <= wait_format;    // Initial state
  endcase
  end
  end

// JTAG Machine status Vectors
  reg[1:0] jtag_sm_vec;

  always @(posedge clock) begin
  case (jtag_sm)
  wait_format:  jtag_sm_vec <= 'h0;
  tck_low:    jtag_sm_vec <= 'h1;
  tck_high:    jtag_sm_vec <= 'h2;
  default      jtag_sm_vec <= 'h0;
  endcase
  end

//-----------------------------------------------------------------------------------------------------------------
// Debug
//-----------------------------------------------------------------------------------------------------------------
`ifdef DEBUG_JTAGSM_NEW 
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
  hold_adr:    prom_sm_dsp <= "hold_adr ";
  inc_adr:    prom_sm_dsp <= "inc_adr  ";
  unstart:    prom_sm_dsp <= "unstart  ";
  default      prom_sm_dsp <= "wait_dll ";
  endcase
  end

// PROM case tracking
  reg   [2:0] prom_case = 0;

  always @(posedge clock) begin
  if    (idle_prom)  prom_case <= 1;    // PROM powered down
  else if (clear_adr) prom_case <= 2;    // PROM enabled, clearing address
  else if (taccess)  prom_case <= 3;    // PROM enabled, accessing adr 0
  else if (next_adr)  prom_case <= 4;    // PROM enabled, clock=1
  else         prom_case <= 5;    // PROM enabled, clock=0
  end

// Format State Machine ASCII display
  reg [95:0] format_sm_dsp;

  always @* begin
  case (format_sm)
  wait_prom:    format_sm_dsp <= "wait_prom   ";
  check_header:  format_sm_dsp <= "ck_header   ";
  wait_chain:    format_sm_dsp <= "wait_chain  ";
  load_chain:    format_sm_dsp <= "load_chain  ";
  load_tckcnt0:  format_sm_dsp <= "load_tckcnt0";
  load_tckcnt1:  format_sm_dsp <= "load_tckcnt1";
  abend:      format_sm_dsp <= "abend       ";
  default      format_sm_dsp <= "wait_prom   ";
  endcase
  end

// Jtag state machine ASCII display
  reg [87:0] jtag_sm_dsp;

  always @* begin
  case (jtag_sm)
  wait_format:  jtag_sm_dsp <= "wait_format";
  tck_low:    jtag_sm_dsp <= "tck_low    ";
  tck_high:    jtag_sm_dsp <= "tck_high   ";
  default      jtag_sm_dsp <= "wait_format";
  endcase
  end

//-----------------------------------------------------------------------------------------------------------------
// PROM Emulator
//-----------------------------------------------------------------------------------------------------------------
// ROM Storage
  parameter MXADR   = 16'h0020;    // Last ROM address
  parameter MXADRB  = 6;      // Width of ROM address
  parameter CKADR    = MXADR-1;    // Address to insert checksum

  wire [7:0] rom [MXADR:0];      // Da ROM himself

  wire [17:0] tckcnt_rom  = 2+8;    // Manually entered tck total for all chains
  wire [15:0] wdcnt_rom  = MXADR+1;
  wire [7:0]  checksum_rom;

// Port remap
  wire clk = prom_clk;        // Incrmement PROM address
  wire oe  = prom_oe;          // oe=0  resets address, tri-states data out
  wire nce = prom_nce;        // nce=1 resets address, tri-states data out

// Increment address counter
  reg [MXADRB-1:0] adr=0;
  reg inc_adr_en=0;

  always @(posedge clock) begin
  if (!clk) inc_adr_en <= 1;
  else      inc_adr_en <= clk && !inc_adr_en;
  end

  wire inc_adr_rom = clk && inc_adr_en;

  wire adr_reset = !oe || nce;    // Reset adr if oe=0 or nce=1

  always @(posedge clock or posedge adr_reset) begin
  if    (adr_reset)    adr = 0;
  else if (inc_adr_rom)  adr = adr+1'b1;
  end

// Loop up PROM data at adr
  assign rom[16'h0000]  = 8'hBA;  // Header
  assign rom[16'h0001]  = 8'h81;
  assign rom[16'h0002]  = 8'h82;
  assign rom[16'h0003]  = 8'h83;
  assign rom[16'h0004]  = 8'h84;
  assign rom[16'h0005]  = 8'h85;
  assign rom[16'h0006]  = 8'h86;
  assign rom[16'h0007]  = 8'h87;
  assign rom[16'h0008]  = 8'h88;
  assign rom[16'h0009]  = 8'h89;
  assign rom[16'h000A]  = 8'h8A;
  assign rom[16'h000B]  = 8'h8B;
  assign rom[16'h000C]  = 8'h8C;
  assign rom[16'h000D]  = 8'h8D;
  assign rom[16'h000E]  = 8'h8E;
  assign rom[16'h000F]  = 8'hEA;

  assign rom[16'h0010]  = 8'hDA;  // Chain Block
  assign rom[16'h0011]  = 8'h00;
  assign rom[16'h0012]  = 8'h02;
  assign rom[16'h0013]  = 8'h33;

  assign rom[16'h0014]  = 8'hDB;  // Chain Block
  assign rom[16'h0015]  = 8'h00;
  assign rom[16'h0016]  = 8'h08;
  assign rom[16'h0017]  = 8'hCC;
  assign rom[16'h0018]  = 8'hCC;

  assign rom[16'h0019]  = 8'hFC;
  assign rom[16'h001A]  = tckcnt_rom[17:16];  // Trailer
  assign rom[16'h001B]  = tckcnt_rom[15:8];
  assign rom[16'h001C]  = tckcnt_rom[7:0];
  assign rom[16'h001D]  = wdcnt_rom[15:8];
  assign rom[16'h001E]  = wdcnt_rom[7:0];
  assign rom[16'h001F]  = checksum_rom;
  assign rom[16'h0020]  = 8'hFF;        // Last word marker

// Tri-state rom output
  assign prom_data = (adr_reset) ? 8'hzz : rom[adr];

// Checksum
  wire [7:0] sum [CKADR-1:0];

  assign sum[0]=rom[0];

  genvar i;
  generate
  for (i=1; i<CKADR; i=i+1) begin: ckgen
  assign sum[i]=sum[i-1]+rom[i];
  end
  endgenerate

  assign checksum_rom=sum[CKADR-1];

`endif
//-----------------------------------------------------------------------------------------------------------------
  endmodule
//-----------------------------------------------------------------------------------------------------------------
