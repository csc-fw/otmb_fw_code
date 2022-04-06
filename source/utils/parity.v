`timescale 1ns / 1ps
//`define DEBUG_PARITY 1
//------------------------------------------------------------------------------------------------------------------
// Process Parity Errors
//
//  11/18/2008  Add pulsed output sequencer perr counter
//  11/18/2008  Mod perr enable to wait for raw hits rams to write parity to all 2K addresses
//  11/26/2008  Add ram error map
//  04/30/2009  Add miniscope ram parity
//  08/17/2010  Port to ISE 12
//  02/21/2013  Expand to 7 CFEBs
//------------------------------------------------------------------------------------------------------------------
  module parity
  (
// Clock
  clock,
  global_reset,
  perr_reset,

// Parity inputs
  parity_err_cfeb0,
  parity_err_cfeb1,
  parity_err_cfeb2,
  parity_err_cfeb3,
  parity_err_cfeb4,
  parity_err_cfeb5,
  parity_err_cfeb6,
  parity_err_rpc,
  parity_err_mini,

// Raw hits RAM control
  fifo_wen,

// Parity summary to sequencer and VME
  perr_cfeb,
  perr_rpc,
  perr_mini,
  perr_en,
  perr,
  perr_pulse,

  perr_cfeb_ff,
  perr_rpc_ff,
  perr_mini_ff,
  perr_ff,
  perr_ram_ff

`ifdef DEBUG_PARITY
  ,parity_rd
  ,fifo_wadr_cnt_en
  ,fifo_wadr_done
  ,reset
`endif
  );
//------------------------------------------------------------------------------------------------------------------
// Bus widths
//------------------------------------------------------------------------------------------------------------------
  parameter MXCFEB  = 7;            // Number of CFEBs on CSC
  parameter MXLY    = 6;            // Number Layers in CSC
  parameter RAM_ADRB  = 11;            // Address width=log2(ram_depth)

//------------------------------------------------------------------------------------------------------------------
// Ports
//------------------------------------------------------------------------------------------------------------------
// Clock
  input          clock;          // 40MHz TMB main clock
  input          global_reset;      // Global reset
  input          perr_reset;        // Parity error reset

// Parity inputs
  input  [MXLY-1:0]    parity_err_cfeb0;    // CFEB raw hits RAM parity errors
  input  [MXLY-1:0]    parity_err_cfeb1;    // CFEB raw hits RAM parity errors
  input  [MXLY-1:0]    parity_err_cfeb2;    // CFEB raw hits RAM parity errors
  input  [MXLY-1:0]    parity_err_cfeb3;    // CFEB raw hits RAM parity errors
  input  [MXLY-1:0]    parity_err_cfeb4;    // CFEB raw hits RAM parity errors
  input  [MXLY-1:0]    parity_err_cfeb5;    // CFEB raw hits RAM parity errors
  input  [MXLY-1:0]    parity_err_cfeb6;    // CFEB raw hits RAM parity errors
  input  [4:0]      parity_err_rpc;      // RPC  raw hits RAM parity errors
  input  [1:0]      parity_err_mini;    // Miniscope     RAM parity errors

// Raw hits RAM control
  input          fifo_wen;        // 1=Write enable FIFO RAM

// Parity summary to sequencer and VME
  output  [MXCFEB-1:0]  perr_cfeb;        // CFEB RAM parity error
  output          perr_rpc;        // RPC  RAM parity error
  output          perr_mini;        // Mini RAM parity error
  output          perr_en;        // Parity error latch enabled
  output          perr;          // Parity error summary        
  output          perr_pulse;        // Parity error pulse for counting
  
  output  [MXCFEB-1:0]  perr_cfeb_ff;      // CFEB RAM parity error, latched
  output          perr_rpc_ff;      // RPC  RAM parity error, latched
  output          perr_mini_ff;      // Mini RAM parity error, latches
  output          perr_ff;        // Parity error summary,  latched
  output  [48:0]      perr_ram_ff;      // Mapped bad parity RAMs, 42 cfebs + 5 rpcs + 2 mini

// Debug
`ifdef DEBUG_PARITY
  output  [15:0]      parity_rd;
  output          fifo_wadr_cnt_en;
  output          fifo_wadr_done;
  output          reset;
`endif

//------------------------------------------------------------------------------------------------------------------
// Continuous parity error calculation
//------------------------------------------------------------------------------------------------------------------
  assign perr_cfeb[0]  = | parity_err_cfeb0[MXLY-1:0];
  assign perr_cfeb[1]  = | parity_err_cfeb1[MXLY-1:0];
  assign perr_cfeb[2]  = | parity_err_cfeb2[MXLY-1:0];
  assign perr_cfeb[3]  = | parity_err_cfeb3[MXLY-1:0];
  assign perr_cfeb[4]  = | parity_err_cfeb4[MXLY-1:0];
  assign perr_cfeb[5]  = | parity_err_cfeb5[MXLY-1:0];
  assign perr_cfeb[6]  = | parity_err_cfeb6[MXLY-1:0];
  assign perr_rpc    = | parity_err_rpc[4:0];
  assign perr_mini  = | parity_err_mini[1:0];

  assign perr      = (|perr_cfeb) || perr_rpc || perr_mini;

// Wait for raw hits RAM address to wrap around, indicating parity bit was written to all addresses
  `ifndef DEBUG_PARITY parameter FIFO_LAST_ADR = 4096; `endif  // Make sure fifo wrote all addresses before checking parity
  `ifdef  DEBUG_PARITY parameter FIFO_LAST_ADR = 8;   `endif  // Shorten for simulator

  reg [12:0] fifo_wadr_cnt = 0;
  reg perr_en = 0;
  
  wire fifo_wadr_cnt_en = fifo_wen && !perr_en;
  wire fifo_wadr_done   = fifo_wadr_cnt > FIFO_LAST_ADR;
  wire reset            = perr_reset || global_reset;

  always @(posedge clock) begin
  if (fifo_wadr_cnt_en) fifo_wadr_cnt <= fifo_wadr_cnt+1'b1;
  else          fifo_wadr_cnt <= 0;
  end

  always @(posedge clock) begin
  if     (reset)       perr_en <= 0;
  else if (fifo_wadr_done) perr_en <= 1;
  end

// Latch errors 
  reg  [MXCFEB-1:0] perr_cfeb_ff  = 0;
  reg         perr_rpc_ff  = 0;
  reg         perr_mini_ff  = 0;
  reg         perr_ff    = 0;

  always @(posedge clock) begin
  if (reset) begin
  perr_cfeb_ff <= 0;
  perr_rpc_ff  <= 0;
  perr_mini_ff <= 0;
  perr_ff     <= 0;
  end
  else if (perr_en) begin
  perr_cfeb_ff <= perr_cfeb_ff | perr_cfeb;
  perr_rpc_ff  <= perr_rpc_ff  | perr_rpc;
  perr_mini_ff <= perr_mini_ff | perr_mini;
  perr_ff     <= perr_ff      | perr;
  end
  end

// Parity error pulse to sequencer for counting
  reg  perr_pulse = 0;

  always @(posedge clock) begin
  perr_pulse <= perr & perr_en;
  end

// Map bad parity RAMs, 6x7=42 cfebs and 5 rpcs and 2 miniscope
  reg [48:0] perr_ram_ff=0;

  wire reset_perr_ram = reset || !perr_en;

  always @(posedge clock) begin
  if (reset_perr_ram) perr_ram_ff <= 0;
  else begin
  perr_ram_ff[ 5: 0]  <= perr_ram_ff[ 5: 0] | parity_err_cfeb0[5:0];  // cfeb0 rams
  perr_ram_ff[11: 6]  <= perr_ram_ff[11: 6] | parity_err_cfeb1[5:0];  // cfeb1 rams
  perr_ram_ff[17:12]  <= perr_ram_ff[17:12] | parity_err_cfeb2[5:0];  // cfeb2 rams
  perr_ram_ff[23:18]  <= perr_ram_ff[23:18] | parity_err_cfeb3[5:0];  // cfeb3 rams
  perr_ram_ff[29:24]  <= perr_ram_ff[29:24] | parity_err_cfeb4[5:0];  // cfeb4 rams
  perr_ram_ff[35:30]  <= perr_ram_ff[35:30] | parity_err_cfeb5[5:0];  // cfeb5 rams
  perr_ram_ff[41:36]  <= perr_ram_ff[41:36] | parity_err_cfeb6[5:0];  // cfeb6 rams
  perr_ram_ff[46:42]  <= perr_ram_ff[46:42] | parity_err_rpc[4:0];  // rpc   rams
  perr_ram_ff[48:47]  <= perr_ram_ff[48:47] | parity_err_mini[1:0];  // mini  rams
  end
  end

//------------------------------------------------------------------------------------------------------------------
// Debug
//------------------------------------------------------------------------------------------------------------------
`ifdef DEBUG_PARITY
  assign parity_rd[4:0]  = perr_cfeb[4:0];
  assign parity_rd[5]    = perr_rpc;
  assign parity_rd[6]    = perr_mini;
  assign parity_rd[7]    = perr_en;
  assign parity_rd[8]    = perr;
  assign parity_rd[13:9]  = perr_cfeb_ff[4:0];
  assign parity_rd[14]  = perr_rpc_ff;
  assign parity_rd[15]  = perr_ff;
`endif

//------------------------------------------------------------------------------------------------------------------
  endmodule
//------------------------------------------------------------------------------------------------------------------
