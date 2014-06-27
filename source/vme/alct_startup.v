`timescale 1ns / 1ps
//`define DEBUG_ALCT_STARTUP = 1
//-----------------------------------------------------------------------------------------------------------------
//
//  Waits for Spartan-6 ALCT FPGA configuration after simultaneous hard reset to TMB and ALCT FPGAs
//
//-----------------------------------------------------------------------------------------------------------------
// 08/16/2012  Initial
//
//-----------------------------------------------------------------------------------------------------------------
  module alct_startup
  (
// Inputs
  clock,
  global_reset,
  power_up,
  vme_ready,
  alct_startup_delay,

// Outputs
  alct_startup_msec,
  alct_wait_dll,
  alct_wait_vme,
  alct_wait_cfg,
  alct_startup_done

`ifdef DEBUG_ALCT_STARTUP
  ,alct_sm_dsp
  ,msec_ctr
  ,cfg_ctr
  ,msec_ctr_en
  ,cfg_done
`endif
  );

//-----------------------------------------------------------------------------------------------------------------
// IO Ports
//-----------------------------------------------------------------------------------------------------------------
// Inputs
  input      clock;        // 40 MHz clock
  input      global_reset;    // Global reset
  input      power_up;      // DLL clock lock, we wait for it
  input      vme_ready;      // TMB VME registers loaded from PROM
  input  [15:0]  alct_startup_delay;  // Msec to wait for ALCT FPGA after TMB is up: 212-100=112msec for Spartan-6 on ALCT

// Outputs
  output      alct_startup_msec;  // Msec pulse
  output      alct_wait_dll;    // Waiting for TMB DLL lock
  output      alct_wait_vme;    // Waiting for TMB VME load from user PROM
  output      alct_wait_cfg;    // Waiting for ALCT FPGA to configure from mez PROM
  output      alct_startup_done;  // ALCT FPGA should be configured by now

`ifdef DEBUG_ALCT_STARTUP
  output  [31:0]  alct_sm_dsp;
  output  [15:0]  msec_ctr;
  output  [15:0]  cfg_ctr;
  output      msec_ctr_en;
  output      cfg_done;
`endif

//-----------------------------------------------------------------------------------------------------------------
// Startup counters
//-----------------------------------------------------------------------------------------------------------------
// FF buffer state machine trigger inputs
  reg  power_up_ff  = 0;
  reg vme_ready_ff = 0;

  always @(posedge clock) begin
  power_up_ff  <= power_up;
  vme_ready_ff <= vme_ready;
  end

// State Machine declarations
  parameter wait_dll  = 4'h0;
  parameter wait_vme  = 4'h1;
  parameter wait_cfg  = 4'h2;
  parameter alct_done  = 4'h3;

  reg  [3:0] alct_sm   = wait_dll;
  // synthesis attribute safe_implementation of alct_sm is "yes";

// Startup wait for Spartan-6: 33,761,696 cfg bits/8 = 4220212 clocks 20MHz = 8440424 40MHz = 210.60msec for LHC 40.078414MHz
  reg [15:0] msec_ctr = 0;
  reg [15:0] cfg_ctr  = 0;

// Generate 1 millisecond pulse rate
  `ifdef DEBUG_ALCT_STARTUP
  wire msec = (msec_ctr == 16'd5-1);    // 1 msec for debug 5 ticks
  `else
  wire msec = (msec_ctr == 16'd40078-1);  // 1 msec at LHC period 40.078414MHz
  `endif

  wire msec_ctr_en = (alct_sm == wait_cfg) && (alct_startup_delay > 0);

  always @(posedge clock) begin
  if (msec_ctr_en) begin
  if (msec)  msec_ctr <= 0;
  else    msec_ctr <= msec_ctr + 1'b1;
  end
  end

// Count 1 millisecond pulses
  wire cfg_done = (cfg_ctr >= alct_startup_delay);

  always @(posedge clock) begin
  if      (cfg_done) cfg_ctr <= 0;
  else if (msec    ) cfg_ctr <= cfg_ctr + 1'b1;
  end

//-----------------------------------------------------------------------------------------------------------------
//  ALCT startup state machine
//-----------------------------------------------------------------------------------------------------------------
  always @(posedge clock) begin
  if (global_reset)  alct_sm <= wait_dll;
  else begin

  case (alct_sm)
  
  wait_dll:                    // Wait for FPGA DLLs to lock
   if (power_up_ff)  alct_sm <= wait_vme;

  wait_vme:                    // Wait for VME registers to load from PROM
   if (vme_ready_ff)  alct_sm <= wait_cfg;

  wait_cfg:
   if (cfg_done)    alct_sm <= alct_done;    // Wait for ALCT FPGA cfg
  
  alct_done:      alct_sm <= alct_done;    // Stay forever
          
  default        alct_sm <= alct_done;
  endcase
  end
  end

// Machine status
  reg alct_wait_dll    = 0;
  reg alct_wait_vme    = 0;
  reg alct_wait_cfg    = 0;
  reg alct_startup_done  = 0;

  assign alct_startup_msec = msec;

  always @(posedge clock) begin
  alct_wait_dll    <= (alct_sm==wait_dll);
  alct_wait_vme    <= (alct_sm==wait_vme);
  alct_wait_cfg    <= (alct_sm==wait_cfg);
  alct_startup_done  <= (alct_sm==alct_done);
  end

//-----------------------------------------------------------------------------------------------------------------
// Debug
//-----------------------------------------------------------------------------------------------------------------
`ifdef DEBUG_ALCT_STARTUP
// State Machine ASCII display
  reg [31:0] alct_sm_dsp;

  always @* begin
  case (alct_sm)
  wait_dll:    alct_sm_dsp <= "wdll";
  wait_vme:    alct_sm_dsp <= "wvme";
  wait_cfg:    alct_sm_dsp <= "wcfg";
  alct_done:    alct_sm_dsp <= "done";
  default      alct_sm_dsp <= "done";
  endcase
  end
`endif

  endmodule
