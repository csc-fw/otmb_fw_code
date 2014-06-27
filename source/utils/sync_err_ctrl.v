`timescale 1ns / 1ps
//----------------------------------------------------------------------------------------------------------------
// Synchronization Error Control
//
//  09/14/2009  Initial
//  04/28/2010  Add forced sync error for system test
//  05/12/2010  Add clock_lock_lost error type
//  05/12/2010  Separate clct_bx0 sync error because it clears long after ttc_resync
//  08/17/2010  Port to ISE 12
//----------------------------------------------------------------------------------------------------------------

  module sync_err_ctrl
  (
// Clock
  clock,
  ttc_resync,
  sync_err_reset,

// Sync error sources
  clct_bx0_sync_err,
  alct_ecc_rx_err,
  alct_ecc_tx_err,
  bx0_match_err,
  clock_lock_lost_err,

// Sync error source enables
  clct_bx0_sync_err_en,
  alct_ecc_rx_err_en,
  alct_ecc_tx_err_en,
  bx0_match_err_en,
  clock_lock_lost_err_en,

// Sync error action enables
  sync_err_blanks_mpc_en,
  sync_err_stops_pretrig_en,
  sync_err_stops_readout_en,
  sync_err_forced,

// Sync error types latched
  sync_err,
  alct_ecc_rx_err_ff,
  alct_ecc_tx_err_ff,
  bx0_match_err_ff,
  clock_lock_lost_err_ff,

// Sync error actions
  sync_err_blanks_mpc,
  sync_err_stops_pretrig,
  sync_err_stops_readout
  );
//----------------------------------------------------------------------------------------------------------------
// Ports
//----------------------------------------------------------------------------------------------------------------
// Clock
  input  clock;            // Main 40MHz clock
  input  ttc_resync;          // TTC resync command
  input  sync_err_reset;        // VME sync error reset

// Sync error sources
  input  clct_bx0_sync_err;      // TMB  clock pulse count err bxn!=0+offset at ttc_bx0 arrival
  input  alct_ecc_rx_err;      // ALCT uncorrected ECC error in data ALCT received from TMB
  input  alct_ecc_tx_err;      // ALCT uncorrected ECC error in data ALCT transmitted to TMB
  input  bx0_match_err;        // ALCT alct_bx0 != clct_bx0
  input  clock_lock_lost_err;    // 40MHz main clock lost lock

// Sync error source enables
  input  clct_bx0_sync_err_en;    // TMB  clock pulse count err bxn!=0+offset at ttc_bx0 arrival
  input  alct_ecc_rx_err_en;      // ALCT uncorrected ECC error in data ALCT received from TMB
  input  alct_ecc_tx_err_en;      // ALCT uncorrected ECC error in data ALCT transmitted to TMB
  input  bx0_match_err_en;      // ALCT alct_bx0 != clct_bx0
  input  clock_lock_lost_err_en;    // 40MHz main clock lost lock

// Sync error action enables
  input  sync_err_blanks_mpc_en;    // Sync error blanks LCTs to MPC
  input  sync_err_stops_pretrig_en;  // Sync error stops CLCT pre-triggers
  input  sync_err_stops_readout_en;  // Sync error stops L1A readouts
  input  sync_err_forced;      // Force sync_err=1

// Sync error types latched for VME readout
  output  sync_err;          // Sync error OR of enabled types of error
  output  alct_ecc_rx_err_ff;      // ALCT uncorrected ECC error in data ALCT received from TMB
  output  alct_ecc_tx_err_ff;      // ALCT uncorrected ECC error in data ALCT transmitted to TMB
  output  bx0_match_err_ff;      // ALCT alct_bx0 != clct_bx0
  output  clock_lock_lost_err_ff;    // 40MHz main clock lost lock FF
  
// Sync error actions
  output  sync_err_blanks_mpc;    // Sync error blanks LCTs to MPC
  output  sync_err_stops_pretrig;    // Sync error stops CLCT pre-triggers
  output  sync_err_stops_readout;    // Sync error stops L1A readouts

// Latch sync error sources ON until reset
  reg alct_ecc_rx_err_ff     = 0;
  reg alct_ecc_tx_err_ff     = 0;
  reg bx0_match_err_ff       = 0;
  reg clock_lock_lost_err_ff = 0;

  wire sync_clr = ttc_resync || sync_err_reset;

  always @(posedge clock) begin
  if (sync_clr) begin
  alct_ecc_rx_err_ff     <= 0;
  alct_ecc_tx_err_ff     <= 0;
  bx0_match_err_ff       <= 0;
  clock_lock_lost_err_ff <= 0;
  end
  else begin
  alct_ecc_rx_err_ff     <= alct_ecc_rx_err     || alct_ecc_rx_err_ff;
  alct_ecc_tx_err_ff     <= alct_ecc_tx_err     || alct_ecc_tx_err_ff;
  bx0_match_err_ff       <= bx0_match_err      || bx0_match_err_ff;
  clock_lock_lost_err_ff <= clock_lock_lost_err || clock_lock_lost_err_ff;
  end
  end

// Sync error flipflop
  reg sync_err_ff = 0;
  
  wire sync_set = 
  (alct_ecc_rx_err     && alct_ecc_rx_err_en)    ||  // ALCT uncorrected ECC error in data ALCT received from TMB
  (alct_ecc_tx_err     && alct_ecc_tx_err_en)    ||  // ALCT uncorrected ECC error in data ALCT transmitted to TMB
  (bx0_match_err       && bx0_match_err_en  )    ||  // ALCT alct_bx0 != clct_bx0
  (clock_lock_lost_err && clock_lock_lost_err_en)  ||  // 40MHz main clock lost lock FF
  sync_err_forced;                  // Force sync_err=1

  always @(posedge clock) begin
  if (sync_clr) sync_err_ff <= 0;
  else          sync_err_ff <= sync_set || sync_err_ff;
  end

  assign sync_err = sync_err_ff || (clct_bx0_sync_err && clct_bx0_sync_err_en);

// Assert sync error actions
  reg sync_err_blanks_mpc    = 0;
  reg sync_err_stops_pretrig = 0;
  reg sync_err_stops_readout = 0;

  always @(posedge clock) begin
  if (sync_clr) begin
  sync_err_blanks_mpc    <= 0;
  sync_err_stops_pretrig <= 0;
  sync_err_stops_readout <= 0;
  end
  else if (sync_err) begin
  sync_err_blanks_mpc    <= sync_err_blanks_mpc_en;
  sync_err_stops_pretrig <= sync_err_stops_pretrig_en;
  sync_err_stops_readout <= sync_err_stops_readout_en;
  end
  end

//----------------------------------------------------------------------------------------------------------------
  endmodule
//----------------------------------------------------------------------------------------------------------------
