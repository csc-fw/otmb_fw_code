`timescale 1ns / 1ps
//------------------------------------------------------------------------------------------------------------------
//  VME Section:
//------------------------------------------------------------------------------------------------------------------
//  09/13/2012  Add Virtex-6 GTX receiver registers
//  09/14/2012  Mod 8 new VME registers for Virtex 6 GTX optical receivers and QPLL
//  09/23/2012  Add sysmon
//  12/04/2012  Add sysmon RAM sump
//  02/20/2013  Mod for 7 cfebs
//  02/25/2013  Add 2 event counters for dcfeb[6:5]
//  03/05/2013  New registers for 7-dcfebs
//------------------------------------------------------------------------------------------------------------------
  module vme
  (
// VME Clock Port Map
  clock,
  clock_vme,
  clock_1mhz,
  tmb_clock0_ibufg,
  clock_lock_lost_err,
  ttc_resync,
  global_reset,
  global_reset_en,

// Firmware Version Ports
  cfeb_exists,
  revcode,

// ODMB device
  bd_sel,
  odmb_sel,
  odmb_data,

// VME Bus Input Port Map
  d_vme,
  a,
  am,
  _lword,
  _as,
  _write,
  _ds1,
  _sysclk,
  _ds0,
  _sysfail,
  _sysreset,
  _acfail,
  _iack,
  _iackin,
  _ga,
  _gap,
  _local,

// VME Bus Output Port Map
  _oe,
  dir,
  dtack,
  iackout,
  berr,
  irq,
  ready,

// Loop-Back Control Port Map
  cfeb_oe,
  alct_loop,
  alct_rxoe,
  alct_txoe,
  rpc_loop,
  rpc_loop_tmb,
  dmb_loop,
  _dmb_oe,
  gtl_loop,
  _gtl_oe,
  gtl_loop_lcl,

// User JTAG Port Map
  tck_usr,
  tms_usr,
  tdi_usr,
  tdo_usr,
  sel_usr,
  sel_fpga_chain,

// PROM Port Map
  prom_led,
  prom0_clk,
  prom0_oe,
  _prom0_ce,
  prom1_clk,
  prom1_oe,
  _prom1_ce,
  jsm_busy,
  tck_fpga,

// BPI flash ports
  flash_ctrl,    // [3:0] JRG, goes up for I/O match to UCF with FCS,FOE,FWE,FLATCH = bpi_cs,_ccb_tx14,_ccb_tx26,_ccb_tx3
  flash_ctrl_dualuse,    // [2:0] JRG, goes down to bpi_interface for MUX with FOE,FWE,FLATCH
  bpi_ad_out,
  bpi_active,
  bpi_dev,
  bpi_rst,
  bpi_dsbl,
  bpi_enbl,
  bpi_we,
  bpi_dtack,
  bpi_rd_stat,
  bpi_re,

// 3D3444
  ddd_clock,
  ddd_adr_latch,
  ddd_serial_in,
  ddd_serial_out,
  
// Clock Single Step Port Map
  step_alct,
  step_dmb,
  step_rpc,
  step_cfeb,
  step_run,
  cfeb_clock_en,
  alct_clock_en,

// Hard Resets Port Map
  _hard_reset_alct_fpga,
  _hard_reset_tmb_fpga,

// Status: LED Port Map
  led_fp_lct,
  led_fp_alct,
  led_fp_clct,
  led_fp_l1a,
  led_fp_invp,
  led_fp_nmat,
  led_fp_nl1a,
  led_bd_in,
  led_fp_out,
  led_tmb,     // goes to BPI logic
  led_tmb_out, // comes from BPI logic

// Status: Power Supply Comparator Port Map
  vstat_5p0v,
  vstat_3p3v,
  vstat_1p8v,
  vstat_1p5v,

// Status: Power Supply ADC Port Map
  adc_sclock,
  adc_din,
  _adc_cs,
  adc_dout,

// Status: Temperature ADC Port Map
  _t_crit,
  smb_data,
  smb_clk,
  smb_data_rat,

// Status: Digital Serial Numbers Port Map
  mez_sn,
  tmb_sn,
  rpc_dsn,
  rat_sn_out,

// Status: Clock DCM lock
  lock_tmb_clock0,
  lock_tmb_clock0d,
  lock_alct_rxclockd,
  lock_mpc_clock,
  lock_dcc_clock,
  lock_rpc_rxalt1,
  lock_tmb_clock1,
  lock_alct_rxclock,
  tmbmmcm_locklost,
  tmbmmcm_locklost_cnt,
  qpll_locklost,
  qpll_locklost_cnt,

// Status: Configuration State
  tmb_cfg_done,
  alct_cfg_done,
  mez_done,
  mez_busy,
  alct_startup_msec,
  alct_wait_dll,
  alct_wait_vme,
  alct_wait_cfg,
  alct_startup_done,

// CCB Ports: Status/Configuration
  ccb_cmd,
  ccb_clock40_enable,
  ccb_bcntres,
  ccb_bx0,
  ccb_reserved,
  tmb_reserved,
  tmb_reserved_out,
  tmb_hard_reset,
  alct_hard_reset,
  alct_adb_pulse_sync,
  alct_adb_pulse_async,
  fmm_trig_stop,
  ccb_ignore_rx,
  ccb_allow_ext_bypass,
  ccb_disable_tx,
  ccb_int_l1a_en,
  ccb_ignore_startstop,
  alct_status_en,
  clct_status_en,
  ccb_status_oe,
  ccb_status_oe_lcl,
  tmb_reserved_in,

// CCB Ports: VME TTC Command
  vme_ccb_cmd_enable,
  vme_ccb_cmd,
  vme_ccb_cmd_strobe,
  vme_ccb_data_strobe,
  vme_ccb_subaddr_strobe,
  vme_evcntres,
  vme_bcntres,
  vme_bx0,
  vme_bx0_emu_en,
  fmm_state,

//  CCB TTC lock status
  ccb_ttcrx_lock_never,
  ccb_ttcrx_lost_ever,
  ccb_ttcrx_lost_cnt,

  ccb_qpll_lock_never,
  ccb_qpll_lost_ever,
  ccb_qpll_lost_cnt,

// CCB Ports: Trigger Control
  clct_ext_trig_l1aen,
  alct_ext_trig_l1aen,
  seq_trig_l1aen,
  alct_ext_trig_vme,
  clct_ext_trig_vme,
  ext_trig_both,
  l1a_vme,
  l1a_delay_vme,
  l1a_inj_ram_en,

// ALCT Ports: Trigger Control
  cfg_alct_ext_trig_en,
  cfg_alct_ext_inject_en,
  cfg_alct_ext_trig,
  cfg_alct_ext_inject,
  alct_clear,
  alct_inject,
  alct_inj_ram_en,
  alct_inj_delay,
  alct0_inj,
  alct1_inj,

// ALCT Ports: Sequencer Control/Status
  alct0_vme,
  alct1_vme,

  alct_ecc_en,
  alct_ecc_err_blank,
  alct_txd_int_delay,
  alct_clock_en_vme,
  alct_seq_cmd,

// VME ALCT sync mode ports
  alct_sync_txdata_1st,
  alct_sync_txdata_2nd,
  alct_sync_rxdata_dly,
  alct_sync_rxdata_pre,
  alct_sync_tx_random,
  alct_sync_clr_err,

  alct_sync_1st_err,
  alct_sync_2nd_err,
  alct_sync_1st_err_ff,
  alct_sync_2nd_err_ff,
  alct_sync_ecc_err,

  alct_sync_rxdata_1st,
  alct_sync_rxdata_2nd,
  alct_sync_expect_1st,
  alct_sync_expect_2nd,
  
// ALCT Raw hits RAM Ports
  alct_raw_reset,
  alct_raw_radr,
  alct_raw_rdata,
  alct_raw_busy,
  alct_raw_done,
  alct_raw_wdcnt,

// DMB Ports: Monitored Backplane Signals
  dmb_cfeb_calibrate,
  dmb_l1a_release,
  dmb_reserved_out,
  dmb_reserved_in,
  dmb_rx_ff,
  dmb_tx_reserved,

// CFEB Ports: Injector Control
  mask_all,
  inj_last_tbin,
  inj_febsel,
  inj_wen,
  inj_rwadr,
  inj_wdata,
  inj_ren,
  inj_rdata,
  inj_ramout_busy,

// CFEB Triad Decoder Ports
  triad_persist,
  triad_clr,

// CFEB PreTrigger Ports
  lyr_thresh_pretrig,
  hit_thresh_pretrig,
  pid_thresh_pretrig,
  dmb_thresh_pretrig,
  adjcfeb_dist,

// CFEB Ports: Hot Channel Mask
  cfeb0_ly0_hcm,
  cfeb0_ly1_hcm,
  cfeb0_ly2_hcm,
  cfeb0_ly3_hcm,
  cfeb0_ly4_hcm,
  cfeb0_ly5_hcm,

  cfeb1_ly0_hcm,
  cfeb1_ly1_hcm,
  cfeb1_ly2_hcm,
  cfeb1_ly3_hcm,
  cfeb1_ly4_hcm,
  cfeb1_ly5_hcm,

  cfeb2_ly0_hcm,
  cfeb2_ly1_hcm,
  cfeb2_ly2_hcm,
  cfeb2_ly3_hcm,
  cfeb2_ly4_hcm,
  cfeb2_ly5_hcm,

  cfeb3_ly0_hcm,
  cfeb3_ly1_hcm,
  cfeb3_ly2_hcm,
  cfeb3_ly3_hcm,
  cfeb3_ly4_hcm,
  cfeb3_ly5_hcm,

  cfeb4_ly0_hcm,
  cfeb4_ly1_hcm,
  cfeb4_ly2_hcm,
  cfeb4_ly3_hcm,
  cfeb4_ly4_hcm,
  cfeb4_ly5_hcm,

  cfeb5_ly0_hcm,
  cfeb5_ly1_hcm,
  cfeb5_ly2_hcm,
  cfeb5_ly3_hcm,
  cfeb5_ly4_hcm,
  cfeb5_ly5_hcm,

  cfeb6_ly0_hcm,
  cfeb6_ly1_hcm,
  cfeb6_ly2_hcm,
  cfeb6_ly3_hcm,
  cfeb6_ly4_hcm,
  cfeb6_ly5_hcm,

// Bad CFEB rx bit detection
  bcb_read_enable,
  cfeb_badbits_reset,
  cfeb_badbits_block,
  cfeb_badbits_found,
  cfeb_badbits_blocked,
  cfeb_badbits_nbx,
  
  cfeb0_ly0_badbits,
  cfeb0_ly1_badbits,
  cfeb0_ly2_badbits,
  cfeb0_ly3_badbits,
  cfeb0_ly4_badbits,
  cfeb0_ly5_badbits,
  
  cfeb1_ly0_badbits,
  cfeb1_ly1_badbits,
  cfeb1_ly2_badbits,
  cfeb1_ly3_badbits,
  cfeb1_ly4_badbits,
  cfeb1_ly5_badbits,
  
  cfeb2_ly0_badbits,
  cfeb2_ly1_badbits,
  cfeb2_ly2_badbits,
  cfeb2_ly3_badbits,
  cfeb2_ly4_badbits,
  cfeb2_ly5_badbits,

  cfeb3_ly0_badbits,
  cfeb3_ly1_badbits,
  cfeb3_ly2_badbits,
  cfeb3_ly3_badbits,
  cfeb3_ly4_badbits,
  cfeb3_ly5_badbits,

  cfeb4_ly0_badbits,
  cfeb4_ly1_badbits,
  cfeb4_ly2_badbits,
  cfeb4_ly3_badbits,
  cfeb4_ly4_badbits,
  cfeb4_ly5_badbits,

  cfeb5_ly0_badbits,
  cfeb5_ly1_badbits,
  cfeb5_ly2_badbits,
  cfeb5_ly3_badbits,
  cfeb5_ly4_badbits,
  cfeb5_ly5_badbits,

  cfeb6_ly0_badbits,
  cfeb6_ly1_badbits,
  cfeb6_ly2_badbits,
  cfeb6_ly3_badbits,
  cfeb6_ly4_badbits,
  cfeb6_ly5_badbits,

// Sequencer Ports: External Trigger Enables
  clct_pat_trig_en,
  alct_pat_trig_en,
  alct_match_trig_en,
  adb_ext_trig_en,
  dmb_ext_trig_en,
  clct_ext_trig_en,
  alct_ext_trig_en,
  layer_trig_en,
  all_cfebs_active,
  vme_ext_trig,
  cfeb_en,
  active_feb_src,

// Sequencer Ports: Trigger Modifiers
  clct_flush_delay,
  clct_throttle,
  clct_wr_continuous,
  alct_preClct_width,
  wr_buf_required,
  wr_buf_autoclr_en,
  valid_clct_required,

// Sequencer Ports: pre-CLCT modifiers for L1A*preCLCT overlap
  l1a_preClct_width,
  l1a_preClct_dly,

// Sequencer Ports: External Trigger Delays
  alct_preClct_dly,
  alct_pat_trig_dly,
  adb_ext_trig_dly,
  dmb_ext_trig_dly,
  clct_ext_trig_dly,
  alct_ext_trig_dly,

// Sequencer Ports: CLCT/RPC/RAT Pattern Injector
  inj_trig_vme,
  injector_mask_cfeb,
  ext_trig_inject,
  injector_mask_rat,
  injector_mask_rpc,
  inj_delay_rat,
  rpc_tbins_test,

// Sequencer Ports: CLCT Processing
  sequencer_state,
  scint_veto_vme,
  drift_delay,
  hit_thresh_postdrift,
  pid_thresh_postdrift,
  pretrig_halt,
  scint_veto_clr,

  fifo_mode,
  fifo_tbins_cfeb,
  fifo_pretrig_cfeb,
  fifo_no_raw_hits,

  l1a_delay,
  l1a_internal,
  l1a_internal_dly,
  l1a_window,
  l1a_win_pri_en,
  l1a_lookback,
  l1a_preset_sr,

  l1a_allow_match,
  l1a_allow_notmb,
  l1a_allow_nol1a,
  l1a_allow_alct_only,

  board_id,
  csc_id,
  run_id,
  bxn_offset_pretrig,
  bxn_offset_l1a,
  lhc_cycle,
  l1a_offset,

// Sequencer Ports: Latched CLCTs + Status
  event_clear_vme,
  clct0_vme,
  clct1_vme,
  clctc_vme,
  clctf_vme,
  bxn_clct_vme,
  bxn_l1a_vme,
  bxn_alct_vme,
  trig_source_vme,
  nlayers_hit_vme,
  clct_bx0_sync_err,

// Sequencer Ports: Raw Hits Ram
  dmb_wr,
  dmb_reset,
  dmb_adr,
  dmb_wdata,
  dmb_rdata,
  dmb_wdcnt,
  dmb_busy,

// Sequencer Ports: Buffer Status
  wr_buf_ready,
  wr_buf_adr,
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

// Sequence Ports: Board Status
  uptime,
  bd_status,

// Sequencer Ports: Scope
  scp_runstop,
  scp_auto,
  scp_ch_trig_en,
  scp_trigger_ch,
  scp_force_trig,
  scp_ch_overlay,
  scp_ram_sel,
  scp_tbins,
  scp_radr,
  scp_nowrite,
  scp_waiting,
  scp_trig_done,
  scp_rdata,

// Sequencer Ports: Miniscope
  mini_read_enable,
  mini_tbins_test,
  mini_tbins_word,
  fifo_tbins_mini,
  fifo_pretrig_mini,

// TMB Ports: Configuration
  alct_delay,
  clct_window,

  tmb_sync_err_en,
  tmb_allow_alct,
  tmb_allow_clct,
  tmb_allow_match,

  tmb_allow_alct_ro,
  tmb_allow_clct_ro,
  tmb_allow_match_ro,

  alct_bx0_delay,
  clct_bx0_delay,
  alct_bx0_enable,
  bx0_vpf_test,
  bx0_match,

  mpc_rx_delay,
  mpc_tx_delay,
  mpc_sel_ttc_bx0,
  mpc_idle_blank,
  mpc_me1a_block,
  mpc_oe,

// TMB Ports: Status
  mpc_frame_vme,
  mpc0_frame0_vme,
  mpc0_frame1_vme,
  mpc1_frame0_vme,
  mpc1_frame1_vme,
  mpc_accept_vme,
  mpc_reserved_vme,

// TMB Ports: MPC Injector Control
  mpc_inject,
  ttc_mpc_inj_en,
  mpc_nframes,
  mpc_wen,
  mpc_ren,
  mpc_adr,
  mpc_wdata,
  mpc_rdata,
  mpc_accept_rdata,
  mpc_inj_alct_bx0,
  mpc_inj_clct_bx0,

// CFEB data received on optical link = OR of all bits for ALL CFEBs
  gtx_rx_data_bits_or,

// RPC VME Configuration Ports
  rpc_done,
  rpc_exists,
  rpc_read_enable,
  fifo_tbins_rpc,
  fifo_pretrig_rpc,

// RPC Ports: RAT Control
  rpc_sync,
  rpc_posneg,
  rpc_free_tx0,
  rat_dsn_en,

// RPC Ports: RAT 3D3444 Delay Signals
  dddr_clock,
  dddr_adr_latch,
  dddr_serial_in,
  dddr_busy,

// RPC Ports: Raw Hits Delay
  rpc0_delay,
  rpc1_delay,

// RPC Ports: Injector
  rpc_mask_all,
  rpc_inj_sel,
  rpc_inj_wen,
  rpc_inj_rwadr,
  rpc_inj_wdata,
  rpc_inj_ren,
  rpc_inj_rdata,

// RPC Ports: Raw Hits RAM
  rpc_bank,
  rpc_rdata,
  rpc_rbxn,

// RPC Ports: Hot Channel Mask
  rpc0_hcm,
  rpc1_hcm,

// RPC Ports: Bxn Offset
  rpc_bxn_offset,
  rpc0_bxn_diff,
  rpc1_bxn_diff,

// ALCT Trigger/Readout Counter Ports
  cnt_all_reset,
  cnt_stop_on_ovf,
  cnt_non_me1ab_en,
  cnt_alct_debug,
  cnt_any_ovf_alct,
  cnt_any_ovf_seq,

// ALCT Event Counters
  event_counter0,
  event_counter1,
  event_counter2,
  event_counter3,
  event_counter4,
  event_counter5,
  event_counter6,
  event_counter7,
  event_counter8,
  event_counter9,
  event_counter10,
  event_counter11,
  event_counter12,

// CLCT Event Counters
  event_counter13,
  event_counter14,
  event_counter15,
  event_counter16,
  event_counter17,
  event_counter18,
  event_counter19,
  event_counter20,
  event_counter21,
  event_counter22,
  event_counter23,
  event_counter24,
  event_counter25,
  event_counter26,
  event_counter27,
  event_counter28,
  event_counter29,
  event_counter30,

// TMB Event Counters
  event_counter31,
  event_counter32,
  event_counter33,
  event_counter34,
  event_counter35,
  event_counter36,
  event_counter37,
  event_counter38,
  event_counter39,
  event_counter40,
  event_counter41,
  event_counter42,
  event_counter43,
  event_counter44,
  event_counter45,
  event_counter46,
  event_counter47,
  event_counter48,
  event_counter49,
  event_counter50,
  event_counter51,
  event_counter52,
  event_counter53,
  event_counter54,
  
// L1A Counters
  event_counter55, // L1A received
  event_counter56, // L1A received, TMB in L1A window
  event_counter57, // L1A received, no TMB in window
  event_counter58, // TMB triggered, no L1A in window
  event_counter59, // TMB readouts completed
  event_counter60, // TMB readouts lost by 1-event-per-L1A limit

// STAT Counters
  event_counter61,
  event_counter62,
  event_counter63,
  event_counter64,
  event_counter65,

// Header Counters
  hdr_clear_on_resync,
  pretrig_counter,
  clct_counter,
  trig_counter,
  alct_counter,
  l1a_rx_counter,
  readout_counter,
  orbit_counter,

// ALCT Structure Error Counters
  alct_err_counter0,
  alct_err_counter1,
  alct_err_counter2,
  alct_err_counter3,
  alct_err_counter4,
  alct_err_counter5,

// CLCT pre-trigger coincidence counters
  preClct_l1a_counter,  // CLCT pre-trigger AND L1A coincidence counter
  preClct_alct_counter, // CLCT pre-trigger AND ALCT coincidence counter

// Active CFEB(s) counters
  active_cfebs_event_counter,      // Any CFEB active flag sent to DMB
  active_cfebs_me1a_event_counter, // ME1a CFEB active flag sent to DMB
  active_cfebs_me1b_event_counter, // ME1b CFEB active flag sent to DMB
  active_cfeb0_event_counter,      // CFEB0 active flag sent to DMB
  active_cfeb1_event_counter,      // CFEB1 active flag sent to DMB
  active_cfeb2_event_counter,      // CFEB2 active flag sent to DMB
  active_cfeb3_event_counter,      // CFEB3 active flag sent to DMB
  active_cfeb4_event_counter,      // CFEB4 active flag sent to DMB
  active_cfeb5_event_counter,      // CFEB5 active flag sent to DMB
  active_cfeb6_event_counter,      // CFEB6 active flag sent to DMB

// CSC Orientation Ports
  csc_type,
  csc_me1ab,
  stagger_hs_csc,
  reverse_hs_csc,
  reverse_hs_me1a,
  reverse_hs_me1b,

// Pattern Finder Ports
  clct_blanking,

// 2nd CLCT separation RAM Ports
  clct_sep_src,
  clct_sep_vme,
  clct_sep_ram_we,
  clct_sep_ram_adr,
  clct_sep_ram_wdata,
  clct_sep_ram_rdata,

// Parity Errors
  perr_reset,
  perr_cfeb,
  perr_rpc,
  perr_mini,
  perr_en,
  perr,
  perr_cfeb_ff,
  perr_rpc_ff,
  perr_mini_ff,
  perr_ff,
  perr_ram_ff,

// VME debug register latches
  deb_wr_buf_adr,
  deb_buf_push_adr,
  deb_buf_pop_adr,
  deb_buf_push_data,
  deb_buf_pop_data,

// DDR Ports: Posneg
  alct_rxd_posneg,
  alct_txd_posneg,
  cfeb0_rxd_posneg,
  cfeb1_rxd_posneg,
  cfeb2_rxd_posneg,
  cfeb3_rxd_posneg,
  cfeb4_rxd_posneg,
  cfeb5_rxd_posneg,
  cfeb6_rxd_posneg,

// Phaser VME control/status ports
  dps_fire,
  dps_reset,
  dps_busy,
  dps_lock,

  dps0_phase,
  dps1_phase,
  dps2_phase,
  dps3_phase,
  dps4_phase,
  dps5_phase,
  dps6_phase,
  dps7_phase,
  dps8_phase,

  dps0_sm_vec,
  dps1_sm_vec,
  dps2_sm_vec,
  dps3_sm_vec,
  dps4_sm_vec,
  dps5_sm_vec,
  dps6_sm_vec,
  dps7_sm_vec,
  dps8_sm_vec,

// Interstage delays
  cfeb0_rxd_int_delay,
  cfeb1_rxd_int_delay,
  cfeb2_rxd_int_delay,
  cfeb3_rxd_int_delay,
  cfeb4_rxd_int_delay,
  cfeb5_rxd_int_delay,
  cfeb6_rxd_int_delay,

// Sync error source enables
  sync_err_reset,
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

// Sync error types latched for VME readout
  sync_err,
  alct_ecc_rx_err_ff,
  alct_ecc_tx_err_ff,
  bx0_match_err_ff,
  clock_lock_lost_err_ff,

// Virtex-6 QPLL
  qpll_lock,
  qpll_err,
  qpll_nrst,

// Virtex-6 SNAP12 receiver serial interface
  r12_sclk,
  r12_sdat,
  r12_fok,

// Virtex-6 GTX receiver
  gtx_rx_enable,
  gtx_rx_reset,
  gtx_rx_reset_err_cnt,
  gtx_rx_en_prbs_test,
  gtx_rx_start,
  gtx_rx_fc,
  gtx_rx_valid,
  gtx_rx_match,
  gtx_rx_rst_done,
  gtx_rx_sync_done,
  gtx_rx_pol_swap,
  gtx_rx_err,

// Virtex-6 GTX error counters
  gtx_rx_err_count0,
  gtx_rx_err_count1,
  gtx_rx_err_count2,
  gtx_rx_err_count3,
  gtx_rx_err_count4,
  gtx_rx_err_count5,
  gtx_rx_err_count6,

  gtx_link_had_err,  // link stability monitor: error happened at least once
  gtx_link_good,     // link stability monitor: always good, no errors since last resync
  gtx_link_bad,      // link stability monitor: errors happened over 100 times

  comp_phaser_a_ready,
  comp_phaser_b_ready,
  auto_gtx_reset,

// Sump
  vme_sump
  );

//------------------------------------------------------------------------------------------------------------------
// Generic
//------------------------------------------------------------------------------------------------------------------
  parameter FIRMWARE_TYPE    =  4'h0;      // C=Normal TMB, D=Debug PCB loopback version
  parameter VERSION      =  4'h0;      // Version revision number
  parameter MONTHDAY      = 16'h0000;      // Version date
  parameter YEAR        = 16'h0000;      // Version date
  parameter FPGAID      = 16'h0000;      // FPGA Type XCVnnnn
  parameter ISE_VERSION    = 16'h1234;      // ISE Compiler version
  parameter AUTO_VME      =  1'b1;      // Auto init vme registers
  parameter AUTO_JTAG      =  1'b1;      // Auto init jtag chain
  parameter AUTO_PHASER    =  1'b1;      // Auto init digital phase shifters
  parameter ALCT_MUONIC    =  1'b1;      // Floats ALCT board  in clock-space with independent time-of-flight delay
  parameter CFEB_MUONIC    =  1'b1;      // Floats CFEB boards in clock-space with independent time-of-flight delay
  parameter CCB_BX0_EMULATOR  =  1'b0;      // Turns on bx0 emulator at power up, must be 0 for all CERN versions

  `include "../otmb_virtex6_fw_version.v"

  initial begin
  $display ("vme.FIRMWARE_TYPE    = %H",FIRMWARE_TYPE);
  $display ("vme.VERSION          = %H",VERSION    );
  $display ("vme.MONTHDAY         = %H",MONTHDAY   );
  $display ("vme.YEAR             = %H",YEAR       );
  $display ("vme.FPGAID           = %H",FPGAID     );
  $display ("vme.ISE_VERSION      = %H",ISE_VERSION);
  $display ("vme.AUTO_VME         = %H",AUTO_VME   );
  $display ("vme.AUTO_JTAG        = %H",AUTO_JTAG  );
  $display ("vme.AUTO_PHASER      = %H",AUTO_PHASER);
  $display ("vme.ALCT_MUONIC      = %H",ALCT_MUONIC);
  $display ("vme.CFEB_MUONIC      = %H",CFEB_MUONIC);
  $display ("vme.CCB_BX0_EMULATOR = %H",CCB_BX0_EMULATOR);
  end

//------------------------------------------------------------------------------------------------------------------
// Bus Parameters
//------------------------------------------------------------------------------------------------------------------
  parameter MXCFEB     = 7;        // Number of CFEBs on CSC
  parameter MXLY       = 6;        // Number Layers in CSC
  parameter MXHS       = 32;       // Number of 1/2-Strips per layer
  parameter MXKEYB     = 5;        // Number of key bits
  parameter MXDS       = 8;        // Number of DiStrips per layer
  parameter MXBDID     = 5;        // Number TMB Board ID bits
  parameter MXCSC      = 4;        // Number CSC Chamber ID bits
  parameter MXRID      = 4;        // Number Run ID bits
  parameter MXDRIFT    = 2;        // Number drift delay bits
  parameter MXBXN      = 12;       // Number BXN bits, LHC bunchs numbered 0 to 3563
  parameter MXL1DELAY  = 8;        // NUmber L1Acc delay counter bits
  parameter MXL1WIND   = 4;        // Number L1Acc window width bits
  parameter MXFMODE    = 3;        // Number FIFO Mode bits
  parameter MXTBIN     = 5;        // Number FIFO time bin bits
  parameter MXRAMADR   = 12;       // Number Raw Hits RAM address bits
  parameter MXRAMDATA  = 18;       // Number Raw Hits RAM data bits, does not include fifo wren
  parameter MXCLCT     = 16;       // Number bits per CLCT word
  parameter MXCLCTC    = 3;        // Number bits per CLCT common data word
  parameter MXFRAME    = 16;       // Number bits per muon frame
  parameter MXEXTDLY   = 4;        // Number bits CLCT external trigger delay
  parameter MXMPCDLY   = 4;        // Number MPC delay time bits
  parameter MXARAMADR  = 11;       // Number ALCT Raw Hits RAM address bits
  parameter MXARAMDATA = 18;       // Number ALCT Raw Hits RAM data bits, does not include fifo wren
  parameter MXBUF      = 8;        // Number of buffers
  parameter MXBUFB     = 3;        // Buffer address width
  parameter MXFLUSH    = 4;        // Number bits needed for flush counter
  parameter MXTHROTTLE = 8;        // Number bits needed for throttle counter
  parameter MXDPS      = 9;        // Number of digital phase shifters 2 ALCT + 7 DCFEB
  
  parameter MXRPC      = 2;        // Number RPCs
  parameter MXRPCB     = 1;        // Number RPC ID bits
  parameter MXRPCPAD   = 16;       // Number RPC pads per link board
  parameter MXRPCDB    = 19;       // Number RPC bits per link board

  parameter MXPIDB     = 4;        // Pattern ID bits
  parameter MXHITB     = 3;        // Hits on pattern bits
  parameter MXPATB     = 3+4;      // Pattern bits

// Raw hits RAM parameters
  parameter RAM_DEPTH  = 2048;     // Storage bx depth
  parameter RAM_ADRB   = 11;       // Address width=log2(ram_depth)
  parameter MXBADR     = RAM_ADRB; // Header buffer data address bits
  parameter MXBDATA    = 32;       // Pushed data width

// Counters
  parameter MXCNTVME   = 30;       // VME counters
  parameter MXL1ARX    = 12;       // Number L1As received counter bits
  parameter MXORBIT    = 30;       // Number orbit counter bits

//------------------------------------------------------------------------------------------------------------------
// VME Addresses
//------------------------------------------------------------------------------------------------------------------
//  parameter ADR_TMB_GLOBAL    = 'd26;    // Slot number to address all TMBs in parallel
  parameter ADR_TMB_GLOBAL    = 'd30;    // Slot number to address all OTMBs in parallel
  parameter ADR_BROADCAST     = 'd27;    // Slot number to address all peripheral crate modules

  parameter ADR_IDREG0      = 9'h00;  // ID Register 0
  parameter ADR_IDREG1      = 9'h02;  // ID Register 1
  parameter ADR_IDREG2      = 9'h04;  // ID Register 2
  parameter ADR_IDREG3      = 9'h06;  // ID Register 3

  parameter ADR_VME_STATUS    = 9'h08;  // VME Status Register
  parameter ADR_VME_ADR0      = 9'h0A;  // VME Address read-back
  parameter ADR_VME_ADR1      = 9'h0C;  // VME Address read-back

  parameter ADR_LOOPBK      = 9'h0E;  // Loop-back Register
  parameter ADR_USR_JTAG      = 9'h10;  // User JTAG
  parameter ADR_PROM      = 9'h12;  // PROM

  parameter ADR_DDDSM      = 9'h14;  // 3D3444 State Machine Register + Clock DCMs
  parameter ADR_DDD0      = 9'h16;  // 3D3444 chip 0
  parameter ADR_DDD1      = 9'h18;  // 3D3444 chip 1
  parameter ADR_DDD2      = 9'h1A;  // 3D3444 chip 2
  parameter ADR_DDDOE      = 9'h1C;  // 3D3444 channel enables
  parameter ADR_RATCTRL      = 9'h1E;  // RAT Module control

  parameter ADR_STEP      = 9'h20;  // Step Register
  parameter ADR_LED      = 9'h22;  // Front Panel LEDs
  parameter ADR_ADC      = 9'h24;  // ADCs
  parameter ADR_DSN      = 9'h26;  // Digital Serials

  parameter ADR_MOD_CFG      = 9'h28;  // TMB Configuration
  parameter ADR_CCB_CFG      = 9'h2A;  // CCB Configuration
  parameter ADR_CCB_TRIG      = 9'h2C;  // CCB Trigger Control
  parameter ADR_CCB_STAT0      = 9'h2E;  // CCB Status

  parameter ADR_ALCT_CFG      = 9'h30;  // ALCT Configuration
  parameter ADR_ALCT_INJ      = 9'h32;  // ALCT Injector Control
  parameter ADR_ALCT0_INJ      = 9'h34;  // ALCT Injected ALCT0
  parameter ADR_ALCT1_INJ      = 9'h36;  // ALCT Injected ALCT1
  parameter ADR_ALCT_STAT      = 9'h38;  // ALCT Status
  parameter ADR_ALCT0_RCD      = 9'h3A;  // ALCT Latched LCT0
  parameter ADR_ALCT1_RCD      = 9'h3C;  // ALCT Latched LCT1
  parameter ADR_ALCT_FIFO0    = 9'h3E;  // ALCT FIFO word count

  parameter ADR_DMB_MON      = 9'h40;  // DMB Monitored signals

  parameter ADR_CFEB_INJ      = 9'h42;  // CFEB Injector Control
  parameter ADR_CFEB_INJ_ADR    = 9'h44;  // CFEB Injector RAM address
  parameter ADR_CFEB_INJ_WDATA    = 9'h46;  // CFEB Injector Write Data
  parameter ADR_CFEB_INJ_RDATA    = 9'h48;  // CFEB Injector Read  Data

  parameter ADR_HCM001      = 9'h4A;  // CFEB0 Ly0,Ly1 Hot Channel Mask
  parameter ADR_HCM023      = 9'h4C;  // CFEB0 Ly2,Ly3 Hot Channel Mask
  parameter ADR_HCM045      = 9'h4E;  // CFEB0 Ly4,Ly5 Hot Channel Mask
  parameter ADR_HCM101      = 9'h50;  // CFEB1 Ly0,Ly1 Hot Channel Mask
  parameter ADR_HCM123      = 9'h52;  // CFEB1 Ly2,Ly3 Hot Channel Mask
  parameter ADR_HCM145      = 9'h54;  // CFEB1 Ly4,Ly5 Hot Channel Mask
  parameter ADR_HCM201      = 9'h56;  // CFEB2 Ly0,Ly1 Hot Channel Mask
  parameter ADR_HCM223      = 9'h58;  // CFEB2 Ly2,Ly3 Hot Channel Mask
  parameter ADR_HCM245      = 9'h5A;  // CFEB2 Ly4,Ly5 Hot Channel Mask
  parameter ADR_HCM301      = 9'h5C;  // CFEB3 Ly0,Ly1 Hot Channel Mask
  parameter ADR_HCM323      = 9'h5E;  // CFEB3 Ly2,Ly3 Hot Channel Mask
  parameter ADR_HCM345      = 9'h60;  // CFEB3 Ly4,Ly5 Hot Channel Mask
  parameter ADR_HCM401      = 9'h62;  // CFEB4 Ly0,Ly1 Hot Channel Mask
  parameter ADR_HCM423      = 9'h64;  // CFEB4 Ly2,Ly3 Hot Channel Mask
  parameter ADR_HCM445      = 9'h66;  // CFEB4 Ly4,Ly5 Hot Channel Mask

  parameter ADR_SEQ_TRIG_EN   = 9'h68;  // Sequencer Trigger Source Enables
  parameter ADR_SEQ_TRIG_DLY0 = 9'h6A;  // Sequencer Trigger Source Delays
  parameter ADR_SEQ_TRIG_DLY1 = 9'h6C;  // Sequencer Trigger Source Delays
  parameter ADR_SEQ_TRIG_DLY2 = 9'h194; // Sequencer Trigger Source Delays
  parameter ADR_SEQ_ID        = 9'h6E;  // Sequencer ID info

  parameter ADR_SEQ_CLCT    = 9'h70;  // Sequencer CLCT Configuration
  parameter ADR_SEQ_FIFO    = 9'h72;  // Sequencer FIFO Configuration
  parameter ADR_SEQ_L1A     = 9'h74;  // Sequencer L1A  Configuration
  parameter ADR_SEQ_OFFSET0 = 9'h76;  // Sequencer Counter Offsets

  parameter ADR_SEQ_CLCT0    = 9'h78;  // CLCT Latched LCT0
  parameter ADR_SEQ_CLCT1    = 9'h7A;  // CLCT Latched LCT1
  parameter ADR_SEQ_TRIG_SRC = 9'h7C;  // Sequencer Trigger source read

  parameter ADR_DMB_RAM_ADR   = 9'h7E;  // Sequencer RAM Address
  parameter ADR_DMB_RAM_WDATA = 9'h80;  // Sequencer RAM Write Data
  parameter ADR_DMB_RAM_WDCNT = 9'h82;  // Sequencer RAM Word Count
  parameter ADR_DMB_RAM_RDATA = 9'h84;  // Sequencer RAM Read Data

  parameter ADR_TMB_TRIG      = 9'h86;  // TMB Trigger Configuration

  parameter ADR_MPC0_FRAME0    = 9'h88;  // MPC0 Frame 0 Data sent to MPC
  parameter ADR_MPC0_FRAME1    = 9'h8A;  // MPC0 Frame 1 Data sent to MPC
  parameter ADR_MPC1_FRAME0    = 9'h8C;  // MPC1 Frame 0 Data sent to MPC
  parameter ADR_MPC1_FRAME1    = 9'h8E;  // MPC1 Frame 1 Data sent to MPC
  
  parameter ADR_MPC0_FRAME0_FIFO      = 9'h17C;  // MPC0 Frame 0 Data sent to MPC
  parameter ADR_MPC0_FRAME1_FIFO      = 9'h17E;  // MPC0 Frame 1 Data sent to MPC
  parameter ADR_MPC1_FRAME0_FIFO      = 9'h180;  // MPC1 Frame 0 Data sent to MPC
  parameter ADR_MPC1_FRAME1_FIFO      = 9'h182;  // MPC1 Frame 1 Data sent to MPC
  parameter ADR_MPC_FRAMES_FIFO_CTRL  = 9'h184;  // MPC Frames FIFO control

  parameter ADR_TMB_SPECIAL_COUNT     = 9'h186; // Used to Read MMCM lock time, now just whatever we need it for!
  parameter ADR_TMB_POWER_UP_TIME     = 9'h188; // Read tmb power-up time
  parameter ADR_TMB_LOAD_CFG_TIME     = 9'h18A; // Read tmb config time
  parameter ADR_ALCT_PHASER_LOCK_TIME = 9'h18C; // Read alct clocks lock time
  parameter ADR_ALCT_LOAD_CFG_TIME    = 9'h18E; // Read alct configure time
  parameter ADR_GTX_RST_DONE_TIME     = 9'h190; // Read gtx rx reset done time
  parameter ADR_GTX_SYNC_DONE_TIME    = 9'h192; // Read gtx rx sync done time
  
  parameter ADR_TMB_LATENCY_SR    = 9'h196; // Shift register for "CFEB data received on optical link" latched with MPC frame latch strobe for VME
  
  parameter ADR_MPC_INJ      = 9'h90;  // MPC Injector Control
  parameter ADR_MPC_RAM_ADR    = 9'h92;  // MPC Injector RAM address
  parameter ADR_MPC_RAM_WDATA    = 9'h94;  // MPC Injector RAM Write Data
  parameter ADR_MPC_RAM_RDATA    = 9'h96;  // MPC Injector RAM Read  Data

  parameter ADR_SCP_CTRL      = 9'h98;  // Scope control
  parameter ADR_SCP_RDATA      = 9'h9A;  // Scope read data

  parameter ADR_CCB_CMD      = 9'h9C;  // CCB TTC Command
  parameter ADR_BUF_STAT0      = 9'h9E;  // Buffer Status
  parameter ADR_BUF_STAT1      = 9'hA0;  // Buffer Status
  parameter ADR_BUF_STAT2      = 9'hA2;  // Buffer Status
  parameter ADR_BUF_STAT3      = 9'hA4;  // Buffer Status
  parameter ADR_BUF_STAT4      = 9'hA6;  // Buffer Status
  
  parameter ADR_ALCTFIFO1      = 9'hA8;  // ALCT Raw hits RAM Control
  parameter ADR_ALCTFIFO2      = 9'hAA;  // ALCT Raw hits RAM data

  parameter ADR_SEQMOD      = 9'hAC;  // Sequencer Trigger Modifiers
  parameter ADR_SEQSM      = 9'hAE;  // Sequencer Machine State
  parameter ADR_SEQCLCTM      = 9'hB0;  // Sequencer CLCT msbs
  parameter ADR_TMBTIM      = 9'hB2;  // TMB Timing
  parameter ADR_LHC_CYCLE      = 9'hB4;  // LHC Cycle, max BXN

  parameter ADR_RPC_CFG      = 9'hB6;  // RPC Configuration
  parameter ADR_RPC_RDATA      = 9'hB8;  // RPC sync mode read data
  parameter ADR_RPC_RAW_DELAY    = 9'hBA;  // RPC raw hits delay
  parameter ADR_RPC_INJ      = 9'hBC;  // RPC injector control
  parameter ADR_RPC_INJ_ADR    = 9'hBE;  // RPC injector RAM addresses
  parameter ADR_RPC_INJ_WDATA    = 9'hC0;  // RPC injector RAM write data
  parameter ADR_RPC_INJ_RDATA    = 9'hC2;  // RPC injector RAM read  data
  parameter ADR_RPC_TBINS      = 9'hC4;  // RPC Time bins
  parameter ADR_RPC0_HCM      = 9'hC6;  // RPC hot channel mask
  parameter ADR_RPC1_HCM      = 9'hC8;  // RPC hot channel mask

  parameter ADR_BX0_DELAY      = 9'hCA;  // BX0 to MPC delays
  parameter ADR_NON_TRIG_RO    = 9'hCC;  // Non-triggering readout

  parameter ADR_SCP_TRIG      = 9'hCE;  // Scope trigger source channel

  parameter ADR_CNT_CTRL  = 9'hD0;  // Counter control
  parameter ADR_CNT_RDATA = 9'hD2;  // Counter data

  parameter ADR_JTAGSM0      = 9'hD4;  // JTAG state machine
  parameter ADR_JTAGSM1      = 9'hD6;
  parameter ADR_JTAGSM2      = 9'hD8;

  parameter ADR_VMESM0      = 9'hDA;  // VME state machine
  parameter ADR_VMESM1      = 9'hDC;
  parameter ADR_VMESM2      = 9'hDE;
  parameter ADR_VMESM3      = 9'hE0;
  parameter ADR_VMESM4      = 9'hE2;

  parameter ADR_DDDRSM      = 9'hE4;  // RAT 3D3444 State Machine Register
  parameter ADR_DDDR0      = 9'hE6;  // RAT 3D3444 chip 0

  parameter ADR_UPTIME      = 9'hE8;  // Uptime counter
  parameter ADR_BDSTATUS      = 9'hEA;  // Board status summary

  parameter ADR_BXN_CLCT      = 9'hEC;  // CLCT bxn at pretrigger
  parameter ADR_BXN_ALCT      = 9'hEE;  // ALCT bxn at alct valid pattern flag

  parameter ADR_LAYER_TRIG    = 9'hF0;  // Layer trigger mode

  parameter ADR_ISE_VERSION    = 9'hF2;  // ISE Compiler version
  parameter ADR_TEMP0      = 9'hF4;  // Temporary
  parameter ADR_TEMP1      = 9'hF6;  // Temporary
  parameter ADR_TEMP2      = 9'hF8;  // Temporary
  parameter ADR_PARITY      = 9'hFA;  // Parity errors

  parameter ADR_CCB_STAT1      = 9'hFC;  // CCB Status

  parameter ADR_BXN_L1A      = 9'hFE;  // CLCT bxn at L1A
  parameter ADR_L1A_LOOKBACK    = 9'h100;  // L1A look back
  parameter ADR_SEQ_DEBUG      = 9'h102;  // Sequencer debug latches

  parameter ADR_ALCT_SYNC_CTRL    = 9'h104;  // ALCT sync mode control
  parameter ADR_ALCT_SYNC_TXDATA_1ST  = 9'h106;  // ALCT sync mode transmit data, 1st in time
  parameter ADR_ALCT_SYNC_TXDATA_2ND  = 9'h108;  // ALCT sync mode transmit data, 2nd in time

  parameter ADR_SEQ_OFFSET1    = 9'h10A;  // Sequencer Counter Offsets continued
  parameter ADR_MINISCOPE      = 9'h10C;  // Miniscope

  parameter ADR_PHASER0      = 9'h10E;  // Phaser 0 alct_rxd phase
  parameter ADR_PHASER1      = 9'h110;  // Phaser 1 alct_txd phase
  parameter ADR_PHASER2      = 9'h112;  // Phaser 2 cfeb0_rxd phase
  parameter ADR_PHASER3      = 9'h114;  // Phaser 3 cfeb1_rxd phase
  parameter ADR_PHASER4      = 9'h116;  // Phaser 4 cfeb2_rxd phase
  parameter ADR_PHASER5      = 9'h118;  // Phaser 5 cfeb3_rxd phase
  parameter ADR_PHASER6      = 9'h11A;  // Phaser 6 cfeb4_rxd phase

  parameter ADR_DELAY0_INT    = 9'h11C;  // Interstage delays
  parameter ADR_DELAY1_INT    = 9'h11E;  // Interstage delays
  parameter ADR_SYNC_ERR_CTRL    = 9'h120;  // Sync error control

  parameter ADR_CFEB_BADBITS_CTRL    = 9'h122;  // CFEB  Bad Bit Control/Status
  parameter ADR_CFEB_BADBITS_TIMER  = 9'h124;  // CFEB  Bad Bit Check Interval

  parameter ADR_CFEB0_BADBITS_LY01  = 9'h126;  // CFEB0 Bad Bit Array
  parameter ADR_CFEB0_BADBITS_LY23  = 9'h128;  // CFEB0 Bad Bit Array
  parameter ADR_CFEB0_BADBITS_LY45  = 9'h12A;  // CFEB0 Bad Bit Array

  parameter ADR_CFEB1_BADBITS_LY01  = 9'h12C;  // CFEB1 Bad Bit Array
  parameter ADR_CFEB1_BADBITS_LY23  = 9'h12E;  // CFEB1 Bad Bit Array
  parameter ADR_CFEB1_BADBITS_LY45  = 9'h130;  // CFEB1 Bad Bit Array

  parameter ADR_CFEB2_BADBITS_LY01  = 9'h132;  // CFEB2 Bad Bit Array
  parameter ADR_CFEB2_BADBITS_LY23  = 9'h134;  // CFEB2 Bad Bit Array
  parameter ADR_CFEB2_BADBITS_LY45  = 9'h136;  // CFEB2 Bad Bit Array

  parameter ADR_CFEB3_BADBITS_LY01  = 9'h138;  // CFEB3 Bad Bit Array
  parameter ADR_CFEB3_BADBITS_LY23  = 9'h13A;  // CFEB3 Bad Bit Array
  parameter ADR_CFEB3_BADBITS_LY45  = 9'h13C;  // CFEB3 Bad Bit Array

  parameter ADR_CFEB4_BADBITS_LY01  = 9'h13E;  // CFEB4 Bad Bit Array
  parameter ADR_CFEB4_BADBITS_LY23  = 9'h140;  // CFEB4 Bad Bit Array
  parameter ADR_CFEB4_BADBITS_LY45  = 9'h142;  // CFEB4 Bad Bit Array

  parameter ADR_ALCT_STARTUP_DELAY  = 9'h144;  // ALCT startup delay milliseconds for Spartan-6
  parameter ADR_ALCT_STARTUP_STATUS  = 9'h146;  // ALCT startup delay machine status

// Virtex-6 Only
  parameter ADR_V6_SNAP12_QPLL    = 9'h148;  // Virtex-6 SNAP12 Serial interface + QPLL
  parameter ADR_V6_GTX_RX_ALL    = 9'h14A;  // Virtex-6 GTX  common control
  parameter ADR_V6_GTX_RX0    = 9'h14C;  // Virtex-6 GTX0 control and status
  parameter ADR_V6_GTX_RX1    = 9'h14E;  // Virtex-6 GTX1 control and status
  parameter ADR_V6_GTX_RX2    = 9'h150;  // Virtex-6 GTX2 control and status
  parameter ADR_V6_GTX_RX3    = 9'h152;  // Virtex-6 GTX3 control and status
  parameter ADR_V6_GTX_RX4    = 9'h154;  // Virtex-6 GTX4 control and status
  parameter ADR_V6_GTX_RX5    = 9'h156;  // Virtex-6 GTX5 control and status
  parameter ADR_V6_GTX_RX6    = 9'h158;  // Virtex-6 GTX6 control and status

  parameter ADR_V6_SYSMON      = 9'h15A;  // Virtex-6 Sysmon ADC

  parameter ADR_V6_CFEB_BADBITS_CTRL  = 9'h15C;  // CFEB  Bad Bit Control/Status
  parameter ADR_V6_CFEB5_BADBITS_LY01  = 9'h15E;  // CFEB5 Bad Bit Array
  parameter ADR_V6_CFEB5_BADBITS_LY23  = 9'h160;  // CFEB5 Bad Bit Array
  parameter ADR_V6_CFEB5_BADBITS_LY45  = 9'h162;  // CFEB5 Bad Bit Array

  parameter ADR_V6_CFEB6_BADBITS_LY01  = 9'h164;  // CFEB6 Bad Bit Array
  parameter ADR_V6_CFEB6_BADBITS_LY23  = 9'h166;  // CFEB6 Bad Bit Array
  parameter ADR_V6_CFEB6_BADBITS_LY45  = 9'h168;  // CFEB6 Bad Bit Array

  parameter ADR_V6_PHASER7    = 9'h16A;  // Phaser 7 cfeb5_rxd phase "ME1/1A-side"
  parameter ADR_V6_PHASER8    = 9'h16C;  // Phaser 8 cfeb6_rxd phase "ME1/1B-side"

  parameter ADR_V6_HCM501      = 9'h16E;  // CFEB5 Ly0,Ly1 Hot Channel Mask
  parameter ADR_V6_HCM523      = 9'h170;  // CFEB5 Ly2,Ly3 Hot Channel Mask
  parameter ADR_V6_HCM545      = 9'h172;  // CFEB5 Ly4,Ly5 Hot Channel Mask

  parameter ADR_V6_HCM601      = 9'h174;  // CFEB6 Ly0,Ly1 Hot Channel Mask
  parameter ADR_V6_HCM623      = 9'h176;  // CFEB6 Ly2,Ly3 Hot Channel Mask
  parameter ADR_V6_HCM645      = 9'h178;  // CFEB6 Ly4,Ly5 Hot Channel Mask

  parameter ADR_V6_EXTEND      = 9'h17A;  // DCFEB 7-bit extensions

  parameter ADR_ODMB      = 9'h1EE;  // ODMB mode: various addresses are handled inside odmb_device

//------------------------------------------------------------------------------------------------------------------
// Ports
//------------------------------------------------------------------------------------------------------------------
// VME Clock Port Map
  input  clock;               // TMB 40MHz clock
  input  clock_vme;           // VME 10MHz clock
  input  clock_1mhz;          // 1MHz BPI_ctrl Timer clock
  input  tmb_clock0_ibufg;    // Raw 40MHz clock from CCB
  input  clock_lock_lost_err; // TMB 40MHz main clock lost lock FF
  input  ttc_resync;          // Purge l1a processing stack
  input  global_reset;        // Global reset
  output global_reset_en;     // Enable global reset on lock_lost.  JG: used to be ON by default

// Firmware Version Ports
  input  [MXCFEB-1:0] cfeb_exists; // CFEBs instantiated in this version
  output [14:0]       revcode;     // Firmware revision code

// ODMB device
   output       bd_sel;    // Out Board selected
   input        odmb_sel;  // In  ODMB mode selected
   input [15:0] odmb_data; // In  ODMB data

// VME Bus Input Port Map
`define IO (*IOB="true"*)
  inout  [15:0]  d_vme;    // VME data   D16
`IO  input  [23:1]  a;    // VME Address  A24
`IO  input  [5:0]  am;    // Address modifier
`IO  input    _lword;    // Long word
`IO  input    _as;    // Address Strobe
`IO  input    _write;    // Write strobe, Data Direction: 0=VME Write (read from backplane), 1=VME Read (write to backplane)
`IO  input    _ds1;    // Data Strobe
`IO  input    _sysclk;  // VME System clock
`IO  input    _ds0;    // Data Strobe
`IO  input    _sysfail;  // System fail
`IO  input    _sysreset;  // System reset
`IO  input    _acfail;  // AC power fail
`IO  input    _iack;    // Interrupt acknowledge
  input    _iackin;  // Interrupt in, daisy chain
`IO  input  [4:0]  _ga;    // Geographic address
`IO  input    _gap;    // Geographic address parity
`IO  input    _local;    // Local Addressing: 0=using HexSw, 1=using backplane /GA

// VME Bus Output Port Map
  output    _oe;    // Output enable: 0=D16 drives out to VME backplane
  output    dir;    // Out:  1=VME-->TMB (VME write), 0=TMB-->VME (VME read)
`IO  output    dtack;    // Data acknowledge
  output    iackout;  // Interrupt out daisy chain
  output    berr;    // Bus error
  output    irq;    // Interrupt request
`IO  output    ready;    // Ready: 1=FPGA logic is up, disconnects bootstrap logic hardware

// Loop-Back Control Port Map
  output    cfeb_oe;  // 1=Enable CFEB LVDS drivers
  output    alct_loop;  // 1=ALCT loopback mode
  output    alct_rxoe;  // 1=Enable RAT ALCT LVDS receivers
  output    alct_txoe;  // 1=Enable RAT ALCT LVDS drivers
  output    rpc_loop;  // 1=RPC loopback mode no   RAT
  output    rpc_loop_tmb;  // 1=RPC loopback mode with RAT
  output    dmb_loop;  // 1=DMB loopback mode
  output    _dmb_oe;  // 0=Enable DMB drivers
  output    gtl_loop;  // 1=GTL loopback mode
  output    _gtl_oe;  // 0=Enable GTL drivers
  output    gtl_loop_lcl;  // copy for ccb.v

// User JTAG Port Map
  inout    tck_usr;  // User JTAG tck
  inout    tms_usr;  // User JTAG tms
  inout    tdi_usr;  // User JTAG tdi
  input    tdo_usr;  // User JTAG tdo
  inout  [3:0]  sel_usr;  // Select JTAG chain: 00=ALCT, 01=Mez FPGA+PROMs, 10=User PROMs, 11=Readback
  output    sel_fpga_chain;    // sel_usr[3:0]==4'hC

// PROM Port Map
  inout  [7:0]  prom_led;  // PROM data, shared with 2 PROMs and on-board LEDs
  output    prom0_clk;  // PROM 0 clock
  output    prom0_oe;  // 1=Output enable, 0= Reset address
  output    _prom0_ce;  // 0=Chip enable
  output    prom1_clk;  // PROM 1 clock
  output    prom1_oe;  // 1=Output enable, 0= Reset address
  output    _prom1_ce;  // 0=Chip enable
  output    jsm_busy;  // State machine busy writing
  input    tck_fpga;  // TCK from FPGA JTAG chain 

// BPI flash ports
  output  [3:0] flash_ctrl;         // JRG, goes up for I/O match to UCF with FCS,FOE,FWE,FLATCH = fcs,_ccb_tx14,_ccb_tx26,_ccb_tx3
  input   [2:0] flash_ctrl_dualuse; // JRG, goes down to bpi_interface for MUX with FOE,FWE,FLATCH
  output [22:0] bpi_ad_out;
  output        bpi_active;
  output        bpi_dev;
  output        bpi_rst;
  output        bpi_dsbl;
  output        bpi_enbl;
  output        bpi_we;
  output        bpi_dtack;
  output        bpi_rd_stat;
  output        bpi_re;

// 3D3444
  output          ddd_clock;        // ddd clock
  output          ddd_adr_latch;      // ddd address latch
  output          ddd_serial_in;      // ddd serial data
  input          ddd_serial_out;      // ddd serial readback

// Clock Single Step Port Map
  output          step_alct;        // Single step ALCT clock
  output          step_dmb;        // Single step DMB  clock
  output          step_rpc;        // Single step RPC  clock
  output          step_cfeb;        // Single step CFEB clock
  output          step_run;        // 1=Single step clocks, 0 = 40MHz clocks
  output  [4:0]      cfeb_clock_en;      // 1=Enable CFEB LVDS clock drivers
  output          alct_clock_en;      // 1=Enable ALCT LVDS clock driver

// Hard Resets Port Map
  output          _hard_reset_alct_fpga;  // Hard Reset ALCT
  output          _hard_reset_tmb_fpga;  // Hard Reset TMB (wire-or with power-on-reset chip)

// Status: LED Port Map
  input          led_fp_lct;  // LCT  Blue  CLCT + ALCT match
  input          led_fp_alct; // ALCT  Green  ALCT valid pattern
  input          led_fp_clct; // CLCT  Green  CLCT valid pattern
  input          led_fp_l1a;  // L1A  Green  Level 1 Accept from CCB or internal
  input          led_fp_invp; // INVP  Amber  Invalid pattern after drift delay
  input          led_fp_nmat; // NMAT  Amber  ALCT or CLCT but no match
  input          led_fp_nl1a; // NL1A  Red    L1A did not arrive in window
  input  [7:0]   led_bd_in;   // On-Board LEDs
  output [7:0]   led_fp_out;  // Front Panel LEDs (on board LEDs are connected to prom_led)
  input  [15:0]  led_tmb;     // goes to BPI logic
  inout  [15:0]  led_tmb_out; // comes from BPI logic

// Status: Power Supply Comparator Port Map
  input          vstat_5p0v;        // Voltage Comparator +5.0V, 1=OK
  input          vstat_3p3v;        // Voltage Comparator +3.3V, 1=OK
  input          vstat_1p8v;        // Voltage Comparator +1.8V, 1=OK
  input          vstat_1p5v;        // Voltage Comparator +1.5V, 1=OK

// Status: Power Supply ADC Port Map
  output          adc_sclock;        // ADC serial clock
  output          adc_din;        // ADC serial data in
  output          _adc_cs;        // ADC chip select
  input          adc_dout;        // Serial data from ADC

// Status: Temperature ADC Port Map
  input          _t_crit;        // Temperature ADC Tcritical
  inout          smb_data;        // Temperature ADC serial data
  output          smb_clk;        // Temperature ADC serial clock
  input          smb_data_rat;      // Temperature ADC on RAT module

// Status: Digital Serial Numbers Port Map
  inout          mez_sn;          // Mez serial number, bidir
  inout          tmb_sn;          // TMB serial number, bidir
  input          rpc_dsn;        // RAT serial number, in  = rpc_rxalt[1];
  output          rat_sn_out;        // RAT serial number, out = rpc_posneg

// Status: Clock DCM lock
  input          lock_tmb_clock0;    // DCM lock status
  input          lock_tmb_clock0d;   // DCM lock status
  input          lock_alct_rxclockd; // DCM lock status
  input          lock_mpc_clock;     // DCM lock status
  input          lock_dcc_clock;     // DCM lock status
  input          lock_rpc_rxalt1;    // DCM lock status
  input          lock_tmb_clock1;    // DCM lock status
  input          lock_alct_rxclock;  // DCM lock status
  input 	 tmbmmcm_locklost;   // MMCM lock-lost history
  input  [7:0]	 tmbmmcm_locklost_cnt;
  input 	 qpll_locklost;      // QPLL lock-lost history
  input  [7:0]	 qpll_locklost_cnt;

// Status: Configuration State
  output          tmb_cfg_done;      // TMB reports ready
  input          alct_cfg_done;      // ALCT FPGA reports ready
  input          mez_done;        // Mezzanine FPGA done loading
  output          mez_busy;        // FPGA busy (asserted during config), user I/O after config
  output          alct_startup_msec;    // Msec pulse
  output          alct_wait_dll;      // Waiting for TMB DLL lock
  output          alct_wait_vme;      // Waiting for TMB VME load from user PROM
  output          alct_wait_cfg;      // Waiting for ALCT FPGA to configure from mez PROM
  output          alct_startup_done;    // ALCT FPGA should be configured by now

// CCB Ports: Status/Configuration
  input  [7:0]      ccb_cmd;        // CCB command word
  input          ccb_clock40_enable;    // Enable 40MHz clock
  input          ccb_bcntres;      // Bunch crossing counter reset
  input          ccb_bx0;        // Bunch crossing 0
  input  [4:0]      ccb_reserved;      // Unassigned
  input  [1:0]      tmb_reserved;      // Unassigned
  input  [2:0]      tmb_reserved_out;    // Unassigned
  input          tmb_hard_reset;      // Reload TMB  FPGA
  input          alct_hard_reset;    // Reload ALCT FPGA
  input          alct_adb_pulse_sync;  // ALCT synchronous  test pulse
  input          alct_adb_pulse_async;  // ALCT asynchronous test pulse
  input          fmm_trig_stop;      // Stop clct trigger sequencer
  output          ccb_ignore_rx;      // 1=Ignore CCB backplane inputs
  output          ccb_allow_ext_bypass;  // 1=Allow clct_ext_trigger_ccb even if ccb_ignore_rx=1
  output          ccb_disable_tx;      // 1=Disable CCB backplane outputs
  output          ccb_int_l1a_en;      // 1=Enable CCB internal l1a emulator
  output          ccb_ignore_startstop;  // 1=ignore ttc trig_start/stop commands
  output          alct_status_en;      // 1=Enable status GTL outputs
  output          clct_status_en;      // 1=Enable status GTL outputs
  output          ccb_status_oe;      // 1=Enable ALCT+CLCT CCB status for CCB front panel
  output          ccb_status_oe_lcl;    // copy for ccb.v logic
  output  [4:0]      tmb_reserved_in;    // CCB reserved signals from TMB

// CCB Ports: VME TTC Command
  output          vme_ccb_cmd_enable;    // Disconnect ccb_cmd_bpl, use vme_ccb_cmd;
  output  [7:0]      vme_ccb_cmd;      // CCB command word
  output          vme_ccb_cmd_strobe;    // CCB command word strobe
  output          vme_ccb_data_strobe;  // CCB data word strobe
  output          vme_ccb_subaddr_strobe;  // CCB subaddress strobe
  output          vme_evcntres;      // Event counter reset, from VME
  output          vme_bcntres;      // Bunch crossing counter reset, from VME
  output          vme_bx0;        // Bunch crossing zero, from VME
  output          vme_bx0_emu_en;      // BX0 emulator enable
  input  [2:0]      fmm_state;        // FMM machine state

//  CCB TTC lock status
  input          ccb_ttcrx_lock_never;  // Lock never achieved
  input          ccb_ttcrx_lost_ever;  // Lock was lost at least once
  input  [7:0]      ccb_ttcrx_lost_cnt;    // Number of times lock has been lost

  input          ccb_qpll_lock_never;  // Lock never achieved
  input          ccb_qpll_lost_ever;    // Lock was lost at least once
  input  [7:0]      ccb_qpll_lost_cnt;    // Number of times lock has been lost

// CCB Ports: Trigger Control
  output       clct_ext_trig_l1aen; // 1=Request ccb l1a on clct ext_trig
  output       alct_ext_trig_l1aen; // 1=Request ccb l1a on alct ext_trig
  output       seq_trig_l1aen;      // 1=Request ccb l1a on sequencer trigger
  output       alct_ext_trig_vme;   // 1=Fire alct_ext_trig oneshot
  output       clct_ext_trig_vme;   // 1=Fire clct_ext_trig oneshot
  output       ext_trig_both;       // 1=clct_ext_trig fires alct and alct fires clct_trig, DC level
  output       l1a_vme;             // 1=fire ccb_l1accept oneshot
  output [7:0] l1a_delay_vme;       // Internal L1A delay
  output       l1a_inj_ram_en;      // L1A injector RAM enable

// ALCT Ports: Trigger Control
  output          cfg_alct_ext_trig_en;  // 1=Enable alct_ext_trig   from CCB
  output          cfg_alct_ext_inject_en;  // 1=Enable alct_ext_inject from CCB
  output          cfg_alct_ext_trig;    // 1=Assert alct_ext_trig
  output          cfg_alct_ext_inject;  // 1=Assert alct_ext_inject
  output          alct_clear;        // 1=Blank received data
  output          alct_inject;      // 1=Start ALCT injector
  output          alct_inj_ram_en;    // 1=Link  ALCT injector to CFEB injector RAM
  output  [4:0]      alct_inj_delay;      // Injector delay
  output  [15:0]      alct0_inj;        // Injected ALCT0
  output  [15:0]      alct1_inj;        // Injected ALCT1

// ALCT Ports: Sequencer Control/Status
  input  [15:0]      alct0_vme;        // LCT latched on last valid pattern
  input  [15:0]      alct1_vme;        // LCT latched on last valid pattern

  output          alct_ecc_en;      // Enable ALCT ECC decoder, else do no ECC correction
  output          alct_ecc_err_blank;    // Blank alcts with uncorrected ecc errors
  output  [3:0]      alct_txd_int_delay;    // ALCT data transmit delay, integer bx
  output          alct_clock_en_vme;    // Enable ALCT 40MHz clock
  output  [3:0]      alct_seq_cmd;      // ALCT Sequencer command

// VME ALCT sync mode ports
  output  [9:0]      alct_sync_txdata_1st;  // ALCT sync mode data to send for loopback
  output  [9:0]      alct_sync_txdata_2nd;  // ALCT sync mode data to send for loopback
  output  [3:0]      alct_sync_rxdata_dly;  // ALCT sync mode delay pointer to valid data
  output  [3:0]      alct_sync_rxdata_pre;  // ALCT sync mode delay pointer to valid data, fixed pre-delay
  output          alct_sync_tx_random;  // ALCT sync mode tmb transmits random data to alct
  output          alct_sync_clr_err;    // ALCT sync mode clear rng error FFs

  input          alct_sync_1st_err;    // ALCT sync mode 1st-intime match ok, alct-to-tmb
  input          alct_sync_2nd_err;    // ALCT sync mode 2nd-intime match ok, alct-to-tmb
  input          alct_sync_1st_err_ff;  // ALCT sync mode 1st-intime match ok, alct-to-tmb, latched
  input          alct_sync_2nd_err_ff;  // ALCT sync mode 2nd-intime match ok, alct-to-tmb, latched
  input  [1:0]      alct_sync_ecc_err;    // ALCT sync mode ecc error syndrome

  input  [28:1]      alct_sync_rxdata_1st;  // Demux data for demux timing-in
  input  [28:1]      alct_sync_rxdata_2nd;  // Demux data for demux timing-in
  input  [28:1]      alct_sync_expect_1st;  // Expected demux data for demux timing-in
  input  [28:1]      alct_sync_expect_2nd;  // Expected demux data for demux timing-in

// ALCT Raw hits RAM Ports
  output          alct_raw_reset;      // Reset raw hits write address and done flag
  output  [MXARAMADR-1:0]  alct_raw_radr;      // Raw hits RAM VME read address
  input  [MXARAMDATA-1:0]alct_raw_rdata;      // Raw hits RAM VME read data
  input          alct_raw_busy;      // Raw hits RAM VME busy writing ALCT data
  input          alct_raw_done;      // Raw hits ready for VME readout
  input  [MXARAMADR-1:0]  alct_raw_wdcnt;      // ALCT word count stored in FIFO

// DMB Ports: Monitored Backplane Signals
  input  [2:0]      dmb_cfeb_calibrate;    // DMB calibration
  input          dmb_l1a_release;    // DMB test
  input  [4:0]      dmb_reserved_out;    // DMB unassigned
  input  [2:0]      dmb_reserved_in;    // DMB unassigned
  input  [5:0]      dmb_rx_ff;        // DMB received
  output  [2:0]      dmb_tx_reserved;    // DMB backplane reserved

// CFEB Ports: Injector Control
  output  [MXCFEB-1:0]  mask_all;        // 1=Enable, 0=Turn off all CFEB inputs  
  output  [11:0]      inj_last_tbin;      // Last tbin, may wrap past 1024 ram adr
  output  [MXCFEB-1:0]  inj_febsel;        // 1=Select CFEBn for RAM read/write
  output  [2:0]      inj_wen;        // 1=Write enable injector RAM
  output  [9:0]      inj_rwadr;        // Injector RAM read/write address
  output  [17:0]      inj_wdata;        // Injector RAM write data
  output  [2:0]      inj_ren;        // 1=Read enable Injector RAM
  input  [17:0]      inj_rdata;        // Injector RAM read data
  input          inj_ramout_busy;    // Injector busy

// CFEB Triad Decoder Ports
  output  [3:0]      triad_persist;      // Triad 1/2-strip persistence
  output          triad_clr;        // Triad one-shot clear

// CFEB PreTrigger Ports
  output  [MXHITB-1:0]  lyr_thresh_pretrig;    // Layers hit pre-trigger threshold
  output  [MXHITB-1:0]  hit_thresh_pretrig;    // Hits on pattern template pre-trigger threshold
  output  [MXPIDB-1:0]  pid_thresh_pretrig;    // Pattern shape ID pre-trigger threshold
  output  [MXHITB-1:0]  dmb_thresh_pretrig;    // Hits on pattern template DMB active-feb threshold
  output  [MXKEYB-1+1:0]  adjcfeb_dist;      // Distance from key to cfeb boundary for marking adjacent cfeb as hit

// CFEB Ports: Hot Channel Mask
  output  [MXDS-1:0]    cfeb0_ly0_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb0_ly1_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb0_ly2_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb0_ly3_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb0_ly4_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb0_ly5_hcm;      // 1=enable DiStrip

  output  [MXDS-1:0]    cfeb1_ly0_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb1_ly1_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb1_ly2_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb1_ly3_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb1_ly4_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb1_ly5_hcm;      // 1=enable DiStrip

  output  [MXDS-1:0]    cfeb2_ly0_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb2_ly1_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb2_ly2_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb2_ly3_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb2_ly4_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb2_ly5_hcm;      // 1=enable DiStrip

  output  [MXDS-1:0]    cfeb3_ly0_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb3_ly1_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb3_ly2_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb3_ly3_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb3_ly4_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb3_ly5_hcm;      // 1=enable DiStrip

  output  [MXDS-1:0]    cfeb4_ly0_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb4_ly1_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb4_ly2_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb4_ly3_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb4_ly4_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb4_ly5_hcm;      // 1=enable DiStrip

  output  [MXDS-1:0]    cfeb5_ly0_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb5_ly1_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb5_ly2_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb5_ly3_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb5_ly4_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb5_ly5_hcm;      // 1=enable DiStrip

  output  [MXDS-1:0]    cfeb6_ly0_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb6_ly1_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb6_ly2_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb6_ly3_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb6_ly4_hcm;      // 1=enable DiStrip
  output  [MXDS-1:0]    cfeb6_ly5_hcm;      // 1=enable DiStrip

// Bad CFEB rx bit detection
  output          bcb_read_enable;    // Enable blocked bits in dmb readout
  output  [MXCFEB-1:0]  cfeb_badbits_reset;    // Reset bad cfeb bits FFs on ith CFEB
  output  [MXCFEB-1:0]  cfeb_badbits_block;    // Allow bad bits to block triads on ith CFEB
  input  [MXCFEB-1:0]  cfeb_badbits_found;    // CFEB[n] has at least 1 bad bit
  output          cfeb_badbits_blocked;  // A CFEB had bad bits that were blocked
  output  [15:0]      cfeb_badbits_nbx;    // Cycles a bad bit must be continuously high

  input  [MXDS-1:0]    cfeb0_ly0_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb0_ly1_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb0_ly2_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb0_ly3_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb0_ly4_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb0_ly5_badbits;    // 1=CFEB rx bit went bad
  
  input  [MXDS-1:0]    cfeb1_ly0_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb1_ly1_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb1_ly2_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb1_ly3_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb1_ly4_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb1_ly5_badbits;    // 1=CFEB rx bit went bad
  
  input  [MXDS-1:0]    cfeb2_ly0_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb2_ly1_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb2_ly2_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb2_ly3_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb2_ly4_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb2_ly5_badbits;    // 1=CFEB rx bit went bad
  
  input  [MXDS-1:0]    cfeb3_ly0_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb3_ly1_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb3_ly2_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb3_ly3_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb3_ly4_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb3_ly5_badbits;    // 1=CFEB rx bit went bad
  
  input  [MXDS-1:0]    cfeb4_ly0_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb4_ly1_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb4_ly2_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb4_ly3_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb4_ly4_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb4_ly5_badbits;    // 1=CFEB rx bit went bad

  input  [MXDS-1:0]    cfeb5_ly0_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb5_ly1_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb5_ly2_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb5_ly3_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb5_ly4_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb5_ly5_badbits;    // 1=CFEB rx bit went bad

  input  [MXDS-1:0]    cfeb6_ly0_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb6_ly1_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb6_ly2_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb6_ly3_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb6_ly4_badbits;    // 1=CFEB rx bit went bad
  input  [MXDS-1:0]    cfeb6_ly5_badbits;    // 1=CFEB rx bit went bad

// Sequencer Ports: External Trigger Enables
  output              clct_pat_trig_en;   // Allow CLCT Pattern pre-triggers
  output              alct_pat_trig_en;   // Allow ALCT Pattern pre-trigger
  output              alct_match_trig_en; // Match ALCT*CLCT Pattern pre-triggers
  output              adb_ext_trig_en;    // Allow ADB Test pulse pre-trigger
  output              dmb_ext_trig_en;    // Allow DMB Calibration pre-trigger
  output              clct_ext_trig_en;   // Allow CLCT External pre-trigger from CCB
  output              alct_ext_trig_en;   // Allow ALCT External pre-trigger from CCB
  output              layer_trig_en;      // Allow layer-wide pre-triggering
  output              all_cfebs_active;   // Make all CFEBs active when pre-triggered
  output              vme_ext_trig;       // External pre-trigger from VME
  output [MXCFEB-1:0] cfeb_en;            // Enables CFEBs for triggering and active feb flag
  output              active_feb_src;     // Active cfeb flag source, 0=pretrig, 1=tmb-matching ~8bx later

// Sequencer Ports: Trigger Modifiers
  output [MXFLUSH-1:0]    clct_flush_delay;    // Trigger sequencer flush state timer
  output [MXTHROTTLE-1:0] clct_throttle;       // Pre-trigger throttle to reduce trigger rate
  output                  clct_wr_continuous;  // 1=allow continuous header buffer writing for invalid triggers
  output [3:0]            alct_preClct_width;  // ALCT (alct_active_feb flag) window width for ALCT*preCLCT overlap
  output                  wr_buf_required;     // Require wr_buffer to pretrigger
  output                  wr_buf_autoclr_en;   // Enable frozen buffer auto clear
  output                  valid_clct_required; // Require valid pattern after drift to trigger

// Sequencer Ports: pre-CLCT modifiers for L1A*preCLCT overlap
  output [3:0] l1a_preClct_width; // pre-CLCT window width for L1A*preCLCT overlap
  output [7:0] l1a_preClct_dly;   // pre-CLCT delay for L1A*preCLCT overlap

// Sequencer Ports: External Trigger Delays
  output  [MXEXTDLY-1:0]  alct_preClct_dly;  // ALCT (alct_active_feb flag) delay for ALCT*preCLCT overlap
  output  [MXEXTDLY-1:0]  alct_pat_trig_dly; // ALCT pattern  trigger delay
  output  [MXEXTDLY-1:0]  adb_ext_trig_dly;  // ADB  external trigger delay
  output  [MXEXTDLY-1:0]  dmb_ext_trig_dly;  // DMB  external trigger delay
  output  [MXEXTDLY-1:0]  clct_ext_trig_dly; // CLCT external trigger delay
  output  [MXEXTDLY-1:0]  alct_ext_trig_dly; // ALCT external trigger delay
//output  [MXEXTDLY-1:0]  layer_trig_dly;    // Layer OR      trigger delay

// Sequencer Ports: CLCT/RPC/RAT Pattern Injector
  output          inj_trig_vme;      // Start pattern injector
  output  [MXCFEB-1:0]  injector_mask_cfeb;    // Enable CFEB(n) for injector trigger
  output          ext_trig_inject;    // Changes clct_ext_trig to fire pattern injector
  output          injector_mask_rat;    // Enable RAT for injector trigger
  output          injector_mask_rpc;    // Enable RPC for injector trigger
  output  [3:0]      inj_delay_rat;      // CFEB/RPC Injector waits for RAT injector
  output          rpc_tbins_test;      // Set write_data=address

// Sequencer Ports: CLCT Processing
  input  [11:0]      sequencer_state;    // Sequencer State machine
  input          scint_veto_vme;      // Scintillator veto for FAST Sites

  output  [MXDRIFT-1:0]  drift_delay;      // CSC Drift delay clocks
  output  [MXHITB-1:0]  hit_thresh_postdrift;  // Minimum pattern hits for a valid pattern
  output  [MXPIDB-1:0]  pid_thresh_postdrift;  // Minimum pattern ID   for a valid pattern
  output          pretrig_halt;      // Pretrigger and halt until unhalt arrives
  output          scint_veto_clr;      // Clear scintillator veto ff

  output  [MXFMODE-1:0]  fifo_mode;        // FIFO Mode 0=no dump,1=full,2=local,3=sync
  output  [MXTBIN-1:0]  fifo_tbins_cfeb;    // Number CFEB FIFO time bins to read out
  output  [MXTBIN-1:0]  fifo_pretrig_cfeb;    // Number CFEB FIFO time bins before pretrigger
  output          fifo_no_raw_hits;    // 1=do not wait to store raw hits

  output [MXL1DELAY-1:0] l1a_delay;        // Level1 Accept delay from pretrig status output
  output                 l1a_internal;     // Generate internal Level 1, overrides external
  output [MXL1WIND-1:0]  l1a_internal_dly; // Delay internal l1a to shift position in l1a match window
  output [MXL1WIND-1:0]  l1a_window;       // Level1 Accept window width after delay
  output                 l1a_win_pri_en;   // Enable L1A window priority
  output [MXBADR-1:0]    l1a_lookback;     // Bxn to look back from l1a wr_buf_adr
  output                 l1a_preset_sr;    // Dummy VME bit to feign preset l1a sr group

  output l1a_allow_match;     // Readout allows tmb trig pulse in L1A window (normal mode)
  output l1a_allow_notmb;     // Readout allows no tmb trig pulse in L1A window
  output l1a_allow_nol1a;     // Readout allows tmb trig pulse outside L1A window
  output l1a_allow_alct_only; // Allow alct_only events to readout at L1A

  output  [MXBDID-1:0]  board_id;        // Board ID = VME Slot
  output  [MXCSC-1:0]    csc_id;          // CSC Chamber ID number
  output  [MXRID-1:0]    run_id;          // Run ID
  output  [MXBXN-1:0]    bxn_offset_pretrig;    // BXN offset at reset, for pretrig bxn
  output  [MXBXN-1:0]    bxn_offset_l1a;      // BXN offset at reset, for L1A bxn
  output  [MXBXN-1:0]    lhc_cycle;        // LHC period, max BXN count+1
  output  [MXL1ARX-1:0]  l1a_offset;        // L1A counter preset value

// Sequencer Ports: Latched CLCTs
  output          event_clear_vme;    // Event clear for aff,clct,mpc vme diagnostic registers
  input  [MXCLCT-1:0]  clct0_vme;        // First  CLCT
  input  [MXCLCT-1:0]  clct1_vme;        // Second CLCT
  input  [MXCLCTC-1:0]  clctc_vme;        // Common to CLCT0/1 to TMB
  input  [MXCFEB-1:0]  clctf_vme;        // Active cfeb list at TMB match
  input  [MXBXN-1:0]    bxn_clct_vme;      // CLCT BXN at pre-trigger
  input  [MXBXN-1:0]    bxn_l1a_vme;      // CLCT BXN at L1A
  input  [4:0]      bxn_alct_vme;      // ALCT BXN at alct valid pattern flag
  input  [10:0]      trig_source_vme;    // Trigger source readback
  input  [2:0]      nlayers_hit_vme;    // Number layers hit on layer trigger
  input          clct_bx0_sync_err;    // Sync error: BXN counter==0 did not match bx0

// Sequencer Ports: Raw Hits Ram
  output          dmb_wr;          // Raw hits RAM VME write enable
  output          dmb_reset;        // Raw hits RAM VME address reset
  output  [MXRAMADR-1:0]  dmb_adr;        // Raw hits RAM VME read/write address
  output  [MXRAMDATA-1:0]  dmb_wdata;        // Raw hits RAM VME write data
  input  [MXRAMDATA-1:0]  dmb_rdata;        // Raw hits RAM VME read data
  input  [MXRAMADR-1:0]  dmb_wdcnt;        // Raw hits RAM VME word count
  input          dmb_busy;        // Raw hits RAM VME busy writing DMB data

// Sequencer Ports: Buffer Status
  input          wr_buf_ready;      // Write buffer is ready
  input  [MXBADR-1:0]  wr_buf_adr;        // Current address of header write buffer
  input          buf_q_full;        // All raw hits ram in use, ram writing must stop
  input          buf_q_empty;      // No fences remain on buffer stack
  input          buf_q_ovf_err;      // Tried to push when stack full
  input          buf_q_udf_err;      // Tried to pop when stack empty
  input          buf_q_adr_err;      // Fence adr popped from stack doesnt match rls adr
  input          buf_stalled;      // Buffer write pointer hit a fence and is stalled now
  input          buf_stalled_once;    // Buffer stalled at least once since last resync
  input  [MXBADR-1:0]  buf_fence_dist;      // Distance to 1st fence address
  input  [MXBADR-1+1:0]  buf_fence_cnt;      // Number of fences in fence RAM currently
  input  [MXBADR-1+1:0]  buf_fence_cnt_peak;    // Peak number of fences in fence RAM
  input  [7:0]      buf_display;      // Buffer fraction in use display

// Sequence Ports: Board Status
  input  [15:0]      uptime;          // Uptime since last hard reset
  output  [14:0]      bd_status;        // Board status summary

// Sequencer Ports: Scope
  output          scp_runstop;      // 1=run 0=stop
  output          scp_auto;        // Sequencer readout mode
  output          scp_ch_trig_en;      // Enable channel triggers
  output  [7:0]      scp_trigger_ch;      // Trigger channel 0-159
  output          scp_force_trig;      // Force a trigger
  output          scp_ch_overlay;      // Channel source overlay
  output  [3:0]      scp_ram_sel;      // RAM bank select in VME mode
  output  [2:0]      scp_tbins;        // Time bins per channel code, actual tbins/ch = (tbins+1)*64
  output  [8:0]      scp_radr;        // Channel data read address
  output          scp_nowrite;      // Preserves initial RAM contents for testing

  input          scp_waiting;      // Waiting for trigger
  input          scp_trig_done;      // Trigger done, ready for readout 
  input  [15:0]      scp_rdata;        // Recorded channel data

//  Sequencer Ports: Miniscope
  output          mini_read_enable;    // Enable Miniscope readout
  output          mini_tbins_test;    // Miniscope data=address for testing
  output          mini_tbins_word;    // Insert tbins and pretrig tbins in 1st word
  output  [MXTBIN-1:0]  fifo_tbins_mini;    // Number Mini FIFO time bins to read out
  output  [MXTBIN-1:0]  fifo_pretrig_mini;    // Number Mini FIFO time bins before pretrigger

// TMB Ports: Configuration
  output  [3:0]      alct_delay;        //  Delay ALCT for CLCT match window
  output  [3:0]      clct_window;      //  CLCT match window width
  output  [1:0]      tmb_sync_err_en;    // Allow sync_err to MPC for either muon

  output          tmb_allow_alct;      // Allow ALCT only 
  output          tmb_allow_clct;      // Allow CLCT only
  output          tmb_allow_match;    // Allow ALCT+CLCT match

  output          tmb_allow_alct_ro;    // Allow ALCT only  readout, non-triggering
  output          tmb_allow_clct_ro;    // Allow CLCT only  readout, non-triggering
  output          tmb_allow_match_ro;    // Allow Match only readout, non-triggering

  output  [3:0]      alct_bx0_delay;      // ALCT bx0 delay to mpc transmitter
  output  [3:0]      clct_bx0_delay;      // CLCT bx0 delay to mpc transmitter
  output          alct_bx0_enable;    // Enable using alct bx0, else copy clct bx0
  output          bx0_vpf_test;      // Sets clct_bx0=lct0_vpf for bx0 alignment tests
  input          bx0_match;        // ALCT bx0 and CLCT bx0 match in time

  output  [MXMPCDLY-1:0]  mpc_rx_delay;      // MPC response delay
  output  [MXMPCDLY-1:0]  mpc_tx_delay;      // MPC transmit delay
  output          mpc_sel_ttc_bx0;    // MPC gets ttc_bx0 or bx0_local
  output          mpc_idle_blank;      // Blank mpc output except on trigger, block bx0 too
  output          mpc_me1a_block;      // Block ME1A LCTs from MPC, but still queue for L1A readout
  output          mpc_oe;          // MPC output enable, 1=en

// TMB Ports: Status
  input              mpc_frame_vme;    // In MPC frame latch strobe for VME
  input  [MXFRAME-1:0]  mpc0_frame0_vme;  // MPC best muon 1st frame
  input  [MXFRAME-1:0]  mpc0_frame1_vme;  // MPC best buon 2nd frame
  input  [MXFRAME-1:0]  mpc1_frame0_vme;  // MPC second best muon 1st frame
  input  [MXFRAME-1:0]  mpc1_frame1_vme;  // MPC second best buon 2nd frame
  input  [1:0]         mpc_accept_vme;   // MPC accept response
  input  [1:0]         mpc_reserved_vme; // MPC reserved response

// TMB Ports: MPC Injector Control
  output          mpc_inject;        // Start MPC test pattern injector
  output          ttc_mpc_inj_en;      // Enable ttc_mpc_inject
  output  [7:0]      mpc_nframes;      // Number frames to inject
  output  [3:0]      mpc_wen;        // Select RAM to write
  output  [3:0]      mpc_ren;        // Select RAM to read
  output  [7:0]      mpc_adr;        // Injector RAM read/write address
  output  [15:0]      mpc_wdata;        // Injector RAM write data
  input  [15:0]      mpc_rdata;        // Injector RAM read  data
  input  [3:0]      mpc_accept_rdata;    // MPC response stored in RAM
  output          mpc_inj_alct_bx0;    // ALCT bx0 injector
  output          mpc_inj_clct_bx0;    // CLCT bx0 injector

// CFEB data received on optical link = OR of all bits for ALL CFEBs
  input gtx_rx_data_bits_or;

// RPC VME Configuration Ports
  input          rpc_done;        // RPC FPGA configuration done
  output  [MXRPC-1:0]    rpc_exists;        // RPC Readout list
  output          rpc_read_enable;    // 1 Enable RPC Readout
  output  [MXTBIN-1:0]  fifo_tbins_rpc;      // Number RPC FIFO time bins to read out
  output  [MXTBIN-1:0]  fifo_pretrig_rpc;    // Number RPC FIFO time bins before pretrigger

// RPC Ports: RAT Control
  output          rpc_sync;        // Sync mode
  output          rpc_posneg;        // Clock phase
  output          rpc_free_tx0;      // Unassigned
  output          rat_dsn_en;        // RAT dsn enable

// RPC Ports: RAT 3D3444 Delay Signals
  output          dddr_clock;        // DDDR clock      / rpc_sync
  output          dddr_adr_latch;      // DDDR address latch  / rpc_posneg
  output          dddr_serial_in;      // DDDR serial in    / rpc_loop_tmb
  output          dddr_busy;        // DDDR busy      / rpc_free_tx0

// RPC Ports: Raw Hits Delay
  output  [3:0]      rpc0_delay;        // RPC data delay value
  output  [3:0]      rpc1_delay;        // RPC data delay value

// RPC Ports: Injector
  output          rpc_mask_all;      // 1=Enable, 0=Turn off all RPC inputs
  output          rpc_inj_sel;      // 1=Enable RAM write
  output  [MXRPC-1:0]    rpc_inj_wen;      // 1=Write enable injector RAM
  output  [9:0]      rpc_inj_rwadr;      // Injector RAM read/write address
  output  [MXRPCDB-1:0]  rpc_inj_wdata;      // Injector RAM write data
  output  [MXRPC-1:0]    rpc_inj_ren;      // 1=Read enable Injector RAM
  input  [MXRPCDB-1:0]  rpc_inj_rdata;      // Injector RAM read data

// RPC Ports: Raw Hits RAM
  output  [MXRPCB-1:0]  rpc_bank;        // RPC bank address
  input  [15:0]      rpc_rdata;        // RPC RAM read data
  input  [2:0]      rpc_rbxn;        // RPC RAM read bxn

// RPC Ports: Hot Channel Mask
  output  [MXRPCPAD-1:0]  rpc0_hcm;        // 1=enable RPC pad
  output  [MXRPCPAD-1:0]  rpc1_hcm;        // 1=enable RPC pad

// RPC Ports: Bxn Offset
  output  [3:0]      rpc_bxn_offset;      // RPC bunch crossing offset
  input  [3:0]      rpc0_bxn_diff;      // RPC - offset
  input  [3:0]      rpc1_bxn_diff;      // RPC - offset

// ALCT Trigger/Readout Counter Ports
  output cnt_all_reset;    // Trigger/Readout counter reset
  output cnt_stop_on_ovf;  // Stop all counters if any overflows
  output cnt_non_me1ab_en; // Allow clct pretrig counters count non me1ab
  output cnt_alct_debug;   // Enable ALCT debug lct error counter
  input  cnt_any_ovf_alct; // At least one alct counter overflowed
  input  cnt_any_ovf_seq;  // At least one sequencer counter overflowed

// ALCT Event Counters
  input  [MXCNTVME-1:0]  event_counter0; // Event counter 1D remap
  input  [MXCNTVME-1:0]  event_counter1;
  input  [MXCNTVME-1:0]  event_counter2;
  input  [MXCNTVME-1:0]  event_counter3;
  input  [MXCNTVME-1:0]  event_counter4;
  input  [MXCNTVME-1:0]  event_counter5;
  input  [MXCNTVME-1:0]  event_counter6;
  input  [MXCNTVME-1:0]  event_counter7;
  input  [MXCNTVME-1:0]  event_counter8;
  input  [MXCNTVME-1:0]  event_counter9;
  input  [MXCNTVME-1:0]  event_counter10;
  input  [MXCNTVME-1:0]  event_counter11;
  input  [MXCNTVME-1:0]  event_counter12;

// CLCT Event Counters
  input  [MXCNTVME-1:0]  event_counter13; // Event counter 1D remap
  input  [MXCNTVME-1:0]  event_counter14;
  input  [MXCNTVME-1:0]  event_counter15;
  input  [MXCNTVME-1:0]  event_counter16;
  input  [MXCNTVME-1:0]  event_counter17;
  input  [MXCNTVME-1:0]  event_counter18;
  input  [MXCNTVME-1:0]  event_counter19;
  input  [MXCNTVME-1:0]  event_counter20;
  input  [MXCNTVME-1:0]  event_counter21;
  input  [MXCNTVME-1:0]  event_counter22;
  input  [MXCNTVME-1:0]  event_counter23;
  input  [MXCNTVME-1:0]  event_counter24;
  input  [MXCNTVME-1:0]  event_counter25;
  input  [MXCNTVME-1:0]  event_counter26;
  input  [MXCNTVME-1:0]  event_counter27;
  input  [MXCNTVME-1:0]  event_counter28;
  input  [MXCNTVME-1:0]  event_counter29;
  input  [MXCNTVME-1:0]  event_counter30;

// TMB Event Counters
  input  [MXCNTVME-1:0]  event_counter31;
  input  [MXCNTVME-1:0]  event_counter32;
  input  [MXCNTVME-1:0]  event_counter33;
  input  [MXCNTVME-1:0]  event_counter34;
  input  [MXCNTVME-1:0]  event_counter35;
  input  [MXCNTVME-1:0]  event_counter36;
  input  [MXCNTVME-1:0]  event_counter37;
  input  [MXCNTVME-1:0]  event_counter38;
  input  [MXCNTVME-1:0]  event_counter39;
  input  [MXCNTVME-1:0]  event_counter40;
  input  [MXCNTVME-1:0]  event_counter41;
  input  [MXCNTVME-1:0]  event_counter42;
  input  [MXCNTVME-1:0]  event_counter43;
  input  [MXCNTVME-1:0]  event_counter44;
  input  [MXCNTVME-1:0]  event_counter45;
  input  [MXCNTVME-1:0]  event_counter46;
  input  [MXCNTVME-1:0]  event_counter47;
  input  [MXCNTVME-1:0]  event_counter48;
  input  [MXCNTVME-1:0]  event_counter49;
  input  [MXCNTVME-1:0]  event_counter50;
  input  [MXCNTVME-1:0]  event_counter51;
  input  [MXCNTVME-1:0]  event_counter52;
  input  [MXCNTVME-1:0]  event_counter53;
  input  [MXCNTVME-1:0]  event_counter54;

// L1A Counters
  input  [MXCNTVME-1:0]  event_counter55; // L1A received
  input  [MXCNTVME-1:0]  event_counter56; // L1A received, TMB in L1A window
  input  [MXCNTVME-1:0]  event_counter57; // L1A received, no TMB in window
  input  [MXCNTVME-1:0]  event_counter58; // TMB triggered, no L1A in window
  input  [MXCNTVME-1:0]  event_counter59; // TMB readouts completed
  input  [MXCNTVME-1:0]  event_counter60; // TMB readouts lost by 1-event-per-L1A limit

// STAT Counters
  input  [MXCNTVME-1:0]  event_counter61;
  input  [MXCNTVME-1:0]  event_counter62;
  input  [MXCNTVME-1:0]  event_counter63;
  input  [MXCNTVME-1:0]  event_counter64;
  input  [MXCNTVME-1:0]  event_counter65;

// Header Counters
  output                hdr_clear_on_resync; // Clear header counters on ttc_resync
  input  [MXCNTVME-1:0] pretrig_counter;     // Pre-trigger counter
  input  [MXCNTVME-1:0] clct_counter;        // CLCT counter
  input  [MXCNTVME-1:0] trig_counter;        // TMB trigger counter
  input  [MXCNTVME-1:0] alct_counter;        // ALCTs received counter
  input  [MXL1ARX-1:0]  l1a_rx_counter;      // L1As received from ccb counter
  input  [MXL1ARX-1:0]  readout_counter;     // Readout counter
  input  [MXORBIT-1:0]  orbit_counter;       // Orbit counter

// ALCT Structure Error Counters
  input  [7:0] alct_err_counter0; // Error counter 1D remap
  input  [7:0] alct_err_counter1;
  input  [7:0] alct_err_counter2;
  input  [7:0] alct_err_counter3;
  input  [7:0] alct_err_counter4;
  input  [7:0] alct_err_counter5;

// CLCT pre-trigger coincidence counters
  input  [MXCNTVME-1:0] preClct_l1a_counter;  // CLCT pre-trigger AND L1A coincidence counter
  input  [MXCNTVME-1:0] preClct_alct_counter; // CLCT pre-trigger AND ALCT coincidence counter

// Active CFEB(s) counters
  input  [MXCNTVME-1:0] active_cfebs_event_counter;      // Any CFEB active flag sent to DMB
  input  [MXCNTVME-1:0] active_cfebs_me1a_event_counter; // ME1a CFEB active flag sent to DMB
  input  [MXCNTVME-1:0] active_cfebs_me1b_event_counter; // ME1b CFEB active flag sent to DMB
  input  [MXCNTVME-1:0] active_cfeb0_event_counter;      // CFEB0 active flag sent to DMB
  input  [MXCNTVME-1:0] active_cfeb1_event_counter;      // CFEB1 active flag sent to DMB
  input  [MXCNTVME-1:0] active_cfeb2_event_counter;      // CFEB2 active flag sent to DMB
  input  [MXCNTVME-1:0] active_cfeb3_event_counter;      // CFEB3 active flag sent to DMB
  input  [MXCNTVME-1:0] active_cfeb4_event_counter;      // CFEB4 active flag sent to DMB
  input  [MXCNTVME-1:0] active_cfeb5_event_counter;      // CFEB5 active flag sent to DMB
  input  [MXCNTVME-1:0] active_cfeb6_event_counter;      // CFEB6 active flag sent to DMB

// CSC Orientation Ports
  input  [3:0] csc_type;        // Firmware compile type
  input        csc_me1ab;       // 1=ME1A or ME1B CSC type
  input        stagger_hs_csc;  // 1=Staggered CSC, 0=non-staggered
  input        reverse_hs_csc;  // 1=Reverse staggered CSC, non-me1
  input        reverse_hs_me1a; // 1=reverse me1a hstrips prior to pattern sorting
  input        reverse_hs_me1b; // 1=reverse me1b hstrips prior to pattern sorting

// Pattern Finder Ports
  output          clct_blanking;      // clct_blanking
//  output  [3:0]      pid_thresh_pretrig;    // pid_thresh_pretrig
//  output  [2:0]      dmb_thresh_pretrig;    // dmb_thresh_pretrig

// 2nd CLCT separation RAM Ports
  output          clct_sep_src;      // CLCT separation source 1=vme, 0=ram
  output  [7:0]      clct_sep_vme;      // CLCT separation from vme
  output          clct_sep_ram_we;    // CLCT separation RAM write enable
  output  [3:0]      clct_sep_ram_adr;    // CLCT separation RAM rw address VME
  output  [15:0]      clct_sep_ram_wdata;    // CLCT separation RAM write data VME
  input  [15:0]      clct_sep_ram_rdata;    // CLCT separation RAM read  data VME
//  output          clct_sep_ram_sel_ab;  // CLCT separation RAM read  data source a/b

// Parity Errors
  output          perr_reset;        // Parity error reset
  input  [MXCFEB-1:0]  perr_cfeb;        // CFEB RAM parity error
  input          perr_rpc;        // RPC  RAM parity error
  input          perr_mini;        // Mini RAM parity error
  input          perr_en;        // Parity error checking enabled
  input          perr;          // Parity error summary        

  input  [MXCFEB-1:0]  perr_cfeb_ff;      // CFEB RAM parity error, latched
  input          perr_rpc_ff;      // RPC  RAM parity error, latched
  input          perr_mini_ff;      // Mini RAM parity error, latches
  input          perr_ff;        // Parity error summary,  latched
  input  [48:0]      perr_ram_ff;      // Mapped bad parity RAMs, 6x7=42 cfebs + 5 rpcs + 2 miniscope

// VME debug register latches
  input  [MXBADR-1:0]  deb_wr_buf_adr;      // Buffer write address at last pretrig
  input  [MXBADR-1:0]  deb_buf_push_adr;    // Queue push address at last push
  input  [MXBADR-1:0]  deb_buf_pop_adr;    // Queue pop  address at last pop
  input  [MXBDATA-1:0]  deb_buf_push_data;    // Queue push data at last push
  input  [MXBDATA-1:0]  deb_buf_pop_data;    // Queue pop  data at last pop

// DDR Ports: Posnegs
  output          alct_rxd_posneg;    // ALCT alct-to-tmb inter-stage clock select 0 or 180 degrees
  output          alct_txd_posneg;    // ALCT tmb-to-alct inter-stage clock select 0 or 180 degrees
  output          cfeb0_rxd_posneg;    // CFEB cfeb-to-tmb inter-stage clock select 0 or 180 degrees
  output          cfeb1_rxd_posneg;    // CFEB cfeb-to-tmb inter-stage clock select 0 or 180 degrees
  output          cfeb2_rxd_posneg;    // CFEB cfeb-to-tmb inter-stage clock select 0 or 180 degrees
  output          cfeb3_rxd_posneg;    // CFEB cfeb-to-tmb inter-stage clock select 0 or 180 degrees
  output          cfeb4_rxd_posneg;    // CFEB cfeb-to-tmb inter-stage clock select 0 or 180 degrees
  output          cfeb5_rxd_posneg;    // CFEB cfeb-to-tmb inter-stage clock select 0 or 180 degrees
  output          cfeb6_rxd_posneg;    // CFEB cfeb-to-tmb inter-stage clock select 0 or 180 degrees

// Phaser VME control/status ports
  output  [MXDPS-1:0]    dps_fire;        // Set new phase
  output  [MXDPS-1:0]    dps_reset;        // VME Reset current phase
  input  [MXDPS-1:0]    dps_busy;        // Phase shifter busy
  input  [MXDPS-1:0]    dps_lock;        // PLL lock status

  output  [7:0]      dps0_phase;        // Phase to set, 0-255
  output  [7:0]      dps1_phase;        // Phase to set, 0-255
  output  [7:0]      dps2_phase;        // Phase to set, 0-255
  output  [7:0]      dps3_phase;        // Phase to set, 0-255
  output  [7:0]      dps4_phase;        // Phase to set, 0-255
  output  [7:0]      dps5_phase;        // Phase to set, 0-255
  output  [7:0]      dps6_phase;        // Phase to set, 0-255
  output  [7:0]      dps7_phase;        // Phase to set, 0-255
  output  [7:0]      dps8_phase;        // Phase to set, 0-255

  input  [2:0]      dps0_sm_vec;      // Phase shifter machine state
  input  [2:0]      dps1_sm_vec;      // Phase shifter machine state
  input  [2:0]      dps2_sm_vec;      // Phase shifter machine state
  input  [2:0]      dps3_sm_vec;      // Phase shifter machine state
  input  [2:0]      dps4_sm_vec;      // Phase shifter machine state
  input  [2:0]      dps5_sm_vec;      // Phase shifter machine state
  input  [2:0]      dps6_sm_vec;      // Phase shifter machine state
  input  [2:0]      dps7_sm_vec;      // Phase shifter machine state
  input  [2:0]      dps8_sm_vec;      // Phase shifter machine state

// Interstage delays
  output  [3:0]      cfeb0_rxd_int_delay;  // Interstage delay
  output  [3:0]      cfeb1_rxd_int_delay;  // Interstage delay
  output  [3:0]      cfeb2_rxd_int_delay;  // Interstage delay
  output  [3:0]      cfeb3_rxd_int_delay;  // Interstage delay
  output  [3:0]      cfeb4_rxd_int_delay;  // Interstage delay
  output  [3:0]      cfeb5_rxd_int_delay;  // Interstage delay
  output  [3:0]      cfeb6_rxd_int_delay;  // Interstage delay

// Sync error source enables
  output          sync_err_reset;      // VME sync error reset
  output          clct_bx0_sync_err_en;  // TMB  clock pulse count err bxn!=0+offset at ttc_bx0 arrival
  output          alct_ecc_rx_err_en;    // ALCT uncorrected ECC error in data ALCT received from TMB
  output          alct_ecc_tx_err_en;    // ALCT uncorrected ECC error in data ALCT transmitted to TMB
  output          bx0_match_err_en;    // ALCT alct_bx0 != clct_bx0
  output          clock_lock_lost_err_en;  // 40MHz main clock lost lock

// Sync error action enables
  output          sync_err_blanks_mpc_en;    // Sync error blanks LCTs to MPC
  output          sync_err_stops_pretrig_en;  // Sync error stops CLCT pre-triggers
  output          sync_err_stops_readout_en;  // Sync error stops L1A readouts
  output          sync_err_forced;      // Force sync_err=1

// Sync error types latched for VME readout
  input          sync_err;        // Sync error OR of enabled types of error
  input          alct_ecc_rx_err_ff;    // ALCT uncorrected ECC error in data ALCT received from TMB
  input          alct_ecc_tx_err_ff;    // ALCT uncorrected ECC error in data ALCT transmitted to TMB
  input          bx0_match_err_ff;    // ALCT alct_bx0 != clct_bx0
  input          clock_lock_lost_err_ff;  // 40MHz main clock lost lock

// Virtex-6 QPLL
  input          qpll_lock;        // QPLL locked status
  input          qpll_err;        // QPLL error status
  output          qpll_nrst;        // Reset QPLL

// Virtex-6 SNAP12 receiver serial interface
  output          r12_sclk;        // Serial interface clock, drive high
  input          r12_sdat;        // Serial interface data
  input          r12_fok;        // Serial interface status

// Virtex-6 GTX receiver
  output  [MXCFEB-1:0]  gtx_rx_enable;    // Enable GTX optical input, you should disable copper via mask_all
  output  [MXCFEB-1:0]  gtx_rx_reset;    // Reset this GTX
  output  [MXCFEB-1:0]  gtx_rx_reset_err_cnt;  // Reset PRBS test error counters
  output  [MXCFEB-1:0]  gtx_rx_en_prbs_test;  // Select random input test data mode

  input  [MXCFEB-1:0]  gtx_rx_start;     // Set when the DCFEB Start Pattern is present
  input  [MXCFEB-1:0]  gtx_rx_fc;        // Flags when Rx sees "FC" code (sent by Tx) for latency measurement
  input  [MXCFEB-1:0]  gtx_rx_valid;     // Valid data detected on link
  input  [MXCFEB-1:0]  gtx_rx_match;     // PRBS test data match detected, for PRBS tests, a VALID = "should have a match" such that !MATCH is an error
  input  [MXCFEB-1:0]  gtx_rx_rst_done;  // These get set before rxsync cycle begins
  input  [MXCFEB-1:0]  gtx_rx_sync_done; // Use these to determine gtx_ready
  input  [MXCFEB-1:0]  gtx_rx_pol_swap;  // GTX 5,6 [ie dcfeb 4,5] have swapped rx board routes
  input  [MXCFEB-1:0]  gtx_rx_err;       // PRBS test detects an error

// Virtex-6 GTX error counters
  input  [15:0]      gtx_rx_err_count0;    // Error count on this fiber channel
  input  [15:0]      gtx_rx_err_count1;    // Error count on this fiber channel
  input  [15:0]      gtx_rx_err_count2;    // Error count on this fiber channel
  input  [15:0]      gtx_rx_err_count3;    // Error count on this fiber channel
  input  [15:0]      gtx_rx_err_count4;    // Error count on this fiber channel
  input  [15:0]      gtx_rx_err_count5;    // Error count on this fiber channel
  input  [15:0]      gtx_rx_err_count6;    // Error count on this fiber channel

  input  [MXCFEB-1:0]  gtx_link_had_err;   // link stability monitor: error happened at least once
  input  [MXCFEB-1:0]  gtx_link_good;      // link stability monitor: always good, no errors since last resync
  input  [MXCFEB-1:0]  gtx_link_bad;       // link stability monitor: errors happened over 100 times

  output    comp_phaser_a_ready;
  output    comp_phaser_b_ready;
  output    auto_gtx_reset;

// Sump
  output          vme_sump;        // Unused signals

//------------------------------------------------------------------------------------------------------------------
// VME I/O Registers rd=read, wr=write
//------------------------------------------------------------------------------------------------------------------
  wire  [15:0]  id_reg0_rd;
  wire  [15:0]  id_reg1_rd;
  wire  [15:0]  id_reg2_rd;
  wire  [15:0]  id_reg3_rd;

  wire  [15:0]  vme_status_rd;

  reg    [15:0]  vme_adr0_wr;
  wire  [15:0]  vme_adr0_rd;
  
  reg    [13:0]  vme_adr1_wr;
  wire  [15:0]  vme_adr1_rd;

  wire  [15:0]  tmb_loop_ro;
  reg    [15:0]  tmb_loop_wr;
  wire  [15:0]  tmb_loop_rd;

  reg    [15:0]  usr_jtag_wr;
  wire  [15:0]  usr_jtag_rd;

  reg    [15:0]  prom_wr;
  wire   [15:0]  prom_rd;

  reg    [15:0]  dddsm_wr;
  wire  [15:0]  dddsm_rd;

  reg    [15:0]  ddd0_wr;
  wire  [15:0]  ddd0_rd;

  reg    [15:0]  ddd1_wr;
  wire  [15:0]  ddd1_rd;

  reg    [15:0]  ddd2_wr;
  wire  [15:0]  ddd2_rd;

  reg    [15:0]  dddoe_wr;
  wire  [15:0]  dddoe_rd;

  reg    [15:0]  rat_control_wr;
  wire  [15:0]  rat_control_rd;

  reg    [15:0]  step_wr;
  wire  [15:0]  step_rd;

  reg    [15:0]  led_wr;
  wire  [15:0]  led_rd;

  reg    [15:0]  adc_wr;
  wire  [15:0]  adc_rd;

  reg    [15:0]  dsn_wr;
  wire  [15:0]  dsn_rd;

  reg    [15:0]  mod_cfg_wr;
  wire  [15:0]  mod_cfg_rd;

  reg    [15:0]  ccb_cfg_wr;
  wire  [15:0]  ccb_cfg_rd;

  reg    [15:0]  ccb_trig_wr;
  wire  [15:0]  ccb_trig_rd;

  wire  [15:0]  ccb_stat0_rd;
  wire  [15:0]  ccb_stat1_rd;

  reg    [15:0]  alct_cfg_wr;
  wire  [15:0]  alct_cfg_rd;

  reg    [15:0]  alct_inj_wr;
  wire  [15:0]  alct_inj_rd;

  reg    [15:0]  alct0_inj_wr;
  wire  [15:0]  alct0_inj_rd;

  reg    [15:0]  alct1_inj_wr;
  wire  [15:0]  alct1_inj_rd;

  reg    [15:0]  alct_stat_wr;
  wire  [15:0]  alct_stat_rd;

  wire  [15:0]  alct0_rcd_rd;
  wire  [15:0]  alct1_rcd_rd;
  wire  [15:0]  alct_fifo0_rd;
  wire  [15:0]  dmb_mon_rd;

  reg    [15:0]  cfeb_inj_wr;
  wire  [15:0]  cfeb_inj_rd;

  reg    [15:0]  cfeb_inj_adr_wr;
  wire  [15:0]  cfeb_inj_adr_rd;

  reg    [15:0]  cfeb_inj_wdata_wr;
  wire  [15:0]  cfeb_inj_wdata_rd;

  wire  [15:0]  cfeb_inj_rdata_rd;

  reg    [15:0]  hcm001_wr;
  wire  [15:0]  hcm001_rd;

  reg    [15:0]  hcm023_wr;
  wire  [15:0]  hcm023_rd;

  reg    [15:0]  hcm045_wr;
  wire  [15:0]  hcm045_rd;

  reg    [15:0]  hcm101_wr;
  wire  [15:0]  hcm101_rd;

  reg    [15:0]  hcm123_wr;
  wire  [15:0]  hcm123_rd;

  reg    [15:0]  hcm145_wr;
  wire  [15:0]  hcm145_rd;

  reg    [15:0]  hcm201_wr;
  wire  [15:0]  hcm201_rd;

  reg    [15:0]  hcm223_wr;
  wire  [15:0]  hcm223_rd;

  reg    [15:0]  hcm245_wr;
  wire  [15:0]  hcm245_rd;

  reg    [15:0]  hcm301_wr;
  wire  [15:0]  hcm301_rd;

  reg    [15:0]  hcm323_wr;
  wire  [15:0]  hcm323_rd;

  reg    [15:0]  hcm345_wr;
  wire  [15:0]  hcm345_rd;

  reg    [15:0]  hcm401_wr;
  wire  [15:0]  hcm401_rd;

  reg    [15:0]  hcm423_wr;
  wire  [15:0]  hcm423_rd;

  reg    [15:0]  hcm445_wr;
  wire  [15:0]  hcm445_rd;

  reg    [15:0]  hcm501_wr;
  wire  [15:0]  hcm501_rd;

  reg    [15:0]  hcm523_wr;
  wire  [15:0]  hcm523_rd;

  reg    [15:0]  hcm545_wr;
  wire  [15:0]  hcm545_rd;

  reg    [15:0]  hcm601_wr;
  wire  [15:0]  hcm601_rd;

  reg    [15:0]  hcm623_wr;
  wire  [15:0]  hcm623_rd;

  reg    [15:0]  hcm645_wr;
  wire  [15:0]  hcm645_rd;

  reg   [15:0]  seq_trigen_wr;
  wire  [15:0]  seq_trigen_rd;

  reg   [15:0]  seq_trigdly0_wr;
  wire  [15:0]  seq_trigdly0_rd;

  reg   [15:0]  seq_trigdly1_wr;
  wire  [15:0]  seq_trigdly1_rd;
  
  reg   [15:0]  seq_trigdly2_wr;
  wire  [15:0]  seq_trigdly2_rd;

  reg    [15:0]  seq_id_wr;
  wire  [15:0]  seq_id_rd;

  reg    [15:0]  seq_clct_wr;
  wire  [15:0]  seq_clct_rd;

  reg    [15:0]  seq_fifo_wr;
  wire  [15:0]  seq_fifo_rd;

  reg    [15:0]  seq_l1a_wr;
  wire  [15:0]  seq_l1a_rd;

  reg    [15:0]  seq_offset0_wr;
  wire  [15:0]  seq_offset0_rd;

  wire  [15:0]  seq_clct0_rd;
  wire  [15:0]  seq_clct1_rd;
  wire  [15:0]  seq_trig_source_rd;

  reg    [15:0]  dmb_ram_adr_wr;
  wire  [15:0]  dmb_ram_adr_rd;

  reg    [15:0]  dmb_ram_wdata_wr;
  wire  [15:0]  dmb_ram_wdata_rd;

  wire  [15:0]  dmb_ram_wdcnt_rd;
  wire  [15:0]  dmb_ram_rdata_rd;

  reg    [15:0]  tmb_trig_wr;
  wire  [15:0]  tmb_trig_rd;

  wire  [15:0]  mpc0_frame0_rd;
  wire  [15:0]  mpc0_frame1_rd;
  wire  [15:0]  mpc1_frame0_rd;
  wire  [15:0]  mpc1_frame1_rd;
  
  reg  [15:0] mpc_frames_fifo_ctrl_wr;
  wire [15:0] mpc_frames_fifo_ctrl_rd;

// counters to monitor startup timing...
//   Read bits 20:5 or 19:4 or 17:2 to VME... 800 or 400 or 100 ns resolution, counts to 52.4 or 26.2 or 6.5 ms
  wire  [15:0] tmb_special_count_rd = tck_mez_cnt[15:0]; // was used for {11'b00000000000,fast_sum[4:0]};   // Adr 186 -- test: count bits in phaser_lock + alct_load_cfg
  wire  [15:0] tmb_power_up_time_rd = tmb_power_up_time[17:2];     // Adr 188
  wire  [15:0] tmb_load_cfg_time_rd = tmb_load_cfg_time[17:2];     // Adr 18A
  wire  [15:0] alct_phaser_lock_time_rd = alct_phaser_lock_time[17:2]; // Adr 18C
  wire  [15:0] alct_load_cfg_time_rd = alct_load_cfg_time[17:2];   // Adr 18E -- time after alct_config_wait
  wire  [15:0] gtx_rst_done_time_rd = comp_phaser_lock_time[17:2];     // Adr 190  JRG, changed for 04062015 version... change name later!
//  wire  [15:0] gtx_rst_done_time_rd = gtx_rst_done_time[17:2];     // old Adr 190 -- does not wait for cfeb phaser lock?
  wire  [15:0] gtx_sync_done_time_rd = gtx_sync_done_time[17:2];   // Adr 192 -- does not wait for cfeb phaser lock?

  wire [15:0]  mpc0_frame0_fifo_rd;
  wire [15:0]  mpc0_frame1_fifo_rd;
  wire [15:0]  mpc1_frame0_fifo_rd;
  wire [15:0]  mpc1_frame1_fifo_rd;
  
  wire [15:0] tmb_latency_sr_rd;
  
  reg    [15:0]  mpc_inj_wr;
  wire  [15:0]  mpc_inj_rd;

  reg    [15:0]  mpc_ram_adr_wr;
  wire  [15:0]  mpc_ram_adr_rd;

  reg    [15:0]  mpc_ram_wdata_wr;
  wire  [15:0]  mpc_ram_wdata_rd;

  wire  [15:0]  mpc_ram_rdata_rd;

  reg    [15:0]  scp_ctrl_wr;
  wire  [15:0]  scp_ctrl_rd;

  reg    [15:0]  scp_rdata_wr;
  wire  [15:0]  scp_rdata_rd;

  reg    [15:0]  ccb_cmd_wr;
  wire  [15:0]  ccb_cmd_rd;

  wire  [15:0]  buf_stat0_rd;
  wire  [15:0]  buf_stat1_rd;
  wire  [15:0]  buf_stat2_rd;
  wire  [15:0]  buf_stat3_rd;
  wire  [15:0]  buf_stat4_rd;

  reg    [15:0]  alct_fifo1_wr;
  wire  [15:0]  alct_fifo1_rd;

  wire  [15:0]  alct_fifo2_rd;

  reg    [15:0]  seq_trigmod_wr;
  wire  [15:0]  seq_trigmod_rd;

  wire  [15:0]  seq_smstat_rd;
  wire  [15:0]  seq_clctmsb_rd;

  reg    [15:0]  tmb_timing_wr;
  wire  [15:0]  tmb_timing_rd;

  reg    [15:0]  lhc_cycle_wr;
  wire  [15:0]  lhc_cycle_rd;

  reg    [15:0]  rpc_cfg_wr;
  wire  [15:0]  rpc_cfg_rd;

  wire  [15:0]  rpc_rdata_rd;

  reg    [15:0]  rpc_raw_delay_wr;
  wire  [15:0]  rpc_raw_delay_rd;

  reg    [15:0]  rpc_inj_wr;
  wire  [15:0]  rpc_inj_rd;

  reg    [15:0]  rpc_inj_adr_wr;
  wire  [15:0]  rpc_inj_adr_rd;

  reg    [15:0]  rpc_inj_wdata_wr;
  wire  [15:0]  rpc_inj_wdata_rd;

  wire  [15:0]  rpc_inj_rdata_rd;

  reg    [15:0]  rpc_tbins_wr;
  wire  [15:0]  rpc_tbins_rd;

  reg    [15:0]  rpc0_hcm_wr;
  wire  [15:0]  rpc0_hcm_rd;

  reg    [15:0]  rpc1_hcm_wr;
  wire  [15:0]  rpc1_hcm_rd;

  reg    [15:0]  bx0_delay_wr;
  wire  [15:0]  bx0_delay_rd;

  reg    [15:0]  non_trig_ro_wr;
  wire  [15:0]  non_trig_ro_rd;

  reg    [15:0]  scp_trigger_ch_wr;
  wire  [15:0]  scp_trigger_ch_rd;

  reg  [15:0] cnt_ctrl_wr;
  wire [15:0] cnt_ctrl_rd;

  wire  [15:0]  cnt_rdata_rd;

  reg    [15:0]  jtagsm0_wr;
  wire  [15:0]  jtagsm0_rd;

  wire  [15:0]  jtagsm1_rd;
  wire  [15:0]  jtagsm2_rd;

  reg   [15:0]  vmesm0_wr;
  wire  [15:0]  vmesm0_rd;

  wire  [15:0]  vmesm1_rd;
  wire  [15:0]  vmesm2_rd;
  wire  [15:0]  vmesm3_rd;

  reg    [15:0]  vmesm4_wr;
  wire  [15:0]  vmesm4_rd;

  reg    [15:0]  dddrsm_wr;
  wire  [15:0]  dddrsm_rd;

  reg    [15:0]  dddr_wr;
  wire  [15:0]  dddr_rd;

  wire  [15:0]  uptime_rd;
  wire  [15:0]  bd_status_rd;

  wire  [15:0]  bxn_clct_rd;
  wire  [15:0]  bxn_alct_rd;
  wire  [15:0]  bxn_l1a_rd;

  reg    [15:0]  layer_trig_wr;
  wire  [15:0]  layer_trig_rd;

  wire  [15:0]  ise_version_rd;

  reg    [15:0]  temp0_wr;
  wire  [15:0]  temp0_rd;

  reg    [15:0]  temp1_wr;
  wire  [15:0]  temp1_rd;

  reg    [15:0]  temp2_wr;
  wire  [15:0]  temp2_rd;
  
  reg    [15:0]  parity_wr;
  wire  [15:0]  parity_rd;

  reg    [15:0]  l1a_lookback_wr;
  wire  [15:0]  l1a_lookback_rd;

  reg    [15:0]  seqdeb_wr;
  wire  [15:0]  seqdeb_rd;

  reg    [15:0]  alct_sync_ctrl_wr;
  wire  [15:0]  alct_sync_ctrl_rd;

  reg    [15:0]  alct_sync_txdata_1st_wr;
  wire  [15:0]  alct_sync_txdata_1st_rd;

  reg    [15:0]  alct_sync_txdata_2nd_wr;
  wire  [15:0]  alct_sync_txdata_2nd_rd;

  reg    [15:0]  seq_offset1_wr;
  wire  [15:0]  seq_offset1_rd;

  reg    [15:0]  miniscope_wr;
  wire  [15:0]  miniscope_rd;

  reg    [15:0]  phaser0_wr;
  wire  [15:0]  phaser0_rd;

  reg    [15:0]  phaser1_wr;
  wire  [15:0]  phaser1_rd;

  reg    [15:0]  phaser2_wr;
  wire  [15:0]  phaser2_rd;

  reg    [15:0]  phaser3_wr;
  wire  [15:0]  phaser3_rd;

  reg    [15:0]  phaser4_wr;
  wire  [15:0]  phaser4_rd;

  reg    [15:0]  phaser5_wr;
  wire  [15:0]  phaser5_rd;

  reg    [15:0]  phaser6_wr;
  wire  [15:0]  phaser6_rd;

  reg    [15:0]  phaser7_wr;
  wire  [15:0]  phaser7_rd;

  reg    [15:0]  phaser8_wr;
  wire  [15:0]  phaser8_rd;

  reg    [15:0]  delay0_int_wr;
  wire  [15:0]  delay0_int_rd;

  reg    [15:0]  delay1_int_wr;
  wire  [15:0]  delay1_int_rd;

  reg    [15:0]  sync_err_ctrl_wr;
  wire  [15:0]  sync_err_ctrl_rd;

  reg    [15:0]  cfeb_badbits_ctrl_wr;
  wire  [15:0]  cfeb_badbits_ctrl_rd;

  reg    [15:0]  cfeb_v6_badbits_ctrl_wr;
  wire  [15:0]  cfeb_v6_badbits_ctrl_rd;

  reg    [15:0]  cfeb_badbits_nbx_wr;
  wire  [15:0]  cfeb_badbits_nbx_rd;

  wire  [15:0]  cfeb0_badbits_ly01_rd;
  wire  [15:0]  cfeb0_badbits_ly23_rd;
  wire  [15:0]  cfeb0_badbits_ly45_rd;

  wire  [15:0]  cfeb1_badbits_ly01_rd;
  wire  [15:0]  cfeb1_badbits_ly23_rd;
  wire  [15:0]  cfeb1_badbits_ly45_rd;

  wire  [15:0]  cfeb2_badbits_ly01_rd;
  wire  [15:0]  cfeb2_badbits_ly23_rd;
  wire  [15:0]  cfeb2_badbits_ly45_rd;

  wire  [15:0]  cfeb3_badbits_ly01_rd;
  wire  [15:0]  cfeb3_badbits_ly23_rd;
  wire  [15:0]  cfeb3_badbits_ly45_rd;

  wire  [15:0]  cfeb4_badbits_ly01_rd;
  wire  [15:0]  cfeb4_badbits_ly23_rd;
  wire  [15:0]  cfeb4_badbits_ly45_rd;

  wire  [15:0]  cfeb5_badbits_ly01_rd;
  wire  [15:0]  cfeb5_badbits_ly23_rd;
  wire  [15:0]  cfeb5_badbits_ly45_rd;

  wire  [15:0]  cfeb6_badbits_ly01_rd;
  wire  [15:0]  cfeb6_badbits_ly23_rd;
  wire  [15:0]  cfeb6_badbits_ly45_rd;

  reg   [15:0]  alct_startup_delay_wr;
  wire  [15:0]  alct_startup_delay_rd;
  wire  [15:0]  alct_startup_status_rd;

  reg   [15:0]  virtex6_snap12_qpll_wr;
  wire  [15:0]  virtex6_snap12_qpll_rd;

  reg   [15:0]  virtex6_gtx_rx_all_wr;
  wire  [15:0]  virtex6_gtx_rx_all_rd;

  reg   [15:0]  virtex6_gtx_rx_wr [MXCFEB-1:0];
  wire  [15:0]  virtex6_gtx_rx_rd [MXCFEB-1:0];

  reg   [15:0]  virtex6_sysmon_wr;
  wire  [15:0]  virtex6_sysmon_rd;

  reg   [15:0]  virtex6_extend_wr;
  wire  [15:0]  virtex6_extend_rd;

//------------------------------------------------------------------------------------------------------------------
// Address Write Decodes
//------------------------------------------------------------------------------------------------------------------
  wire      wr_tmb_loop;
  wire      wr_usr_jtag;
  wire      wr_usr_jtag_dis;
  wire      wr_prom;

  wire      wr_dddsm;
  wire      wr_ddd0;
  wire      wr_ddd1;
  wire      wr_ddd2;
  wire      wr_dddoe;
  wire      wr_rat_control;

  wire      wr_step;
  wire      wr_led;
  wire      wr_adc;
  wire      wr_dsn;

  wire      wr_mod_cfg;
  wire      wr_ccb_cfg;
  wire      wr_ccb_trig;
  wire      wr_alct_cfg;
  wire      wr_alct_inj;
  wire      wr_alct0_inj;
  wire      wr_alct1_inj;
  wire      wr_alct_stat;
  wire      wr_cfeb_inj;
  wire      wr_cfeb_inj_adr;
  wire      wr_cfeb_inj_wdata;

  wire      wr_hcm001;
  wire      wr_hcm023;
  wire      wr_hcm045;
  wire      wr_hcm101;
  wire      wr_hcm123;
  wire      wr_hcm145;
  wire      wr_hcm201;
  wire      wr_hcm223;
  wire      wr_hcm245;
  wire      wr_hcm301;
  wire      wr_hcm323;
  wire      wr_hcm345;
  wire      wr_hcm401;
  wire      wr_hcm423;
  wire      wr_hcm445;
  wire      wr_hcm501;
  wire      wr_hcm523;
  wire      wr_hcm545;
  wire      wr_hcm601;
  wire      wr_hcm623;
  wire      wr_hcm645;

  wire      wr_seq_trigen;
  wire      wr_seq_trigdly0;
  wire      wr_seq_trigdly1;
  wire      wr_seq_trigdly2;
  wire      wr_seq_id;
  wire      wr_seq_clct;
  wire      wr_seq_fifo;
  wire      wr_seq_l1a;
  wire      wr_seq_offset0;
  wire      wr_dmb_ram_adr;
  wire      wr_dmb_ram_wdata;
  wire      wr_tmb_trig;
  wire      wr_mpc_inj;
  wire      wr_mpc_ram_adr;
  wire      wr_mpc_ram_wdata;

  wire      wr_scp_ctrl;
  wire      wr_scp_rdata;
  wire      wr_ccb_cmd;
  wire      wr_alct_fifo1;

  wire      wr_seq_trigmod;
  wire      wr_tmb_timing;
  wire      wr_lhc_cycle;

  wire      wr_rpc_cfg;
  wire      wr_rpc_raw_delay;
  wire      wr_rpc_inj;
  wire      wr_rpc_inj_adr;
  wire      wr_rpc_inj_wdata;
  wire      wr_rpc_tbins;
  wire      wr_rpc0_hcm;
  wire      wr_rpc1_hcm;

  wire      wr_bx0_delay;
  wire      wr_non_trig_ro;
  wire      wr_scp_trigger_ch;
  wire      wr_cnt_ctrl;
  wire      wr_jtagsm0;
  wire      wr_vmesm0;
  wire      wr_vmesm4;

  wire      wr_dddrsm;
  wire      wr_dddr;

  wire      wr_layer_trig;
  wire      wr_temp0;
  wire      wr_temp1;
  wire      wr_temp2;
  wire      wr_parity;
  wire      wr_l1a_lookback;
  wire      wr_seqdeb;

  wire      wr_alct_sync_ctrl;
  wire      wr_alct_sync_txdata_1st;
  wire      wr_alct_sync_txdata_2nd;

  wire      wr_seq_offset1;
  wire      wr_miniscope;

  wire      wr_phaser0;
  wire      wr_phaser1;
  wire      wr_phaser2;
  wire      wr_phaser3;
  wire      wr_phaser4;
  wire      wr_phaser5;
  wire      wr_phaser6;
  wire      wr_phaser7;
  wire      wr_phaser8;

  wire      wr_delay0_int;
  wire      wr_delay1_int;
  wire      wr_sync_err_ctrl;
  wire      wr_cfeb_badbits_ctrl;
  wire      wr_cfeb_v6_badbits_ctrl;
  wire      wr_cfeb_badbits_nbx;
  wire      wr_alct_startup_delay;

  wire      wr_virtex6_snap12_qpll;
  wire      wr_virtex6_gtx_rx_all;
  wire [6:0]    wr_virtex6_gtx_rx;
  wire      wr_virtex6_sysmon;
  wire      wr_virtex6_extend;
  wire      wr_adr_cap;
  
       // Virtex-6 GTX error counters
       wire    [7:0]           gtx_rx_err_count [MXCFEB-1:0];    // JRG In:    Error count on each fiber channel
         assign        gtx_rx_err_count[0][7:0] = gtx_rx_err_count0[7:0];      //      Error count on this fiber channel
         assign        gtx_rx_err_count[1][7:0] = gtx_rx_err_count1[7:0];      //      Error count on this fiber channel
         assign        gtx_rx_err_count[2][7:0] = gtx_rx_err_count2[7:0];      //      Error count on this fiber channel
         assign        gtx_rx_err_count[3][7:0] = gtx_rx_err_count3[7:0];      //      Error count on this fiber channel
         assign        gtx_rx_err_count[4][7:0] = gtx_rx_err_count4[7:0];      //      Error count on this fiber channel
         assign        gtx_rx_err_count[5][7:0] = gtx_rx_err_count5[7:0];      //      Error count on this fiber channel
         assign        gtx_rx_err_count[6][7:0] = gtx_rx_err_count6[7:0];      //      Error count on this fiber channel
       wire    [11:0]          gtx_rx_err_count_all; // R      JRG: create a sum of all GTX error counts


  wire wr_mpc_frames_fifo_ctrl;
  
//---------------------------------------------------------------------------------------------------------------------
//  Power-up Section
//---------------------------------------------------------------------------------------------------------------------
// Power-up goes high on first clock rising edge after DCM locks...
//  JG: power_up is in fact held low until  lock_tmb_clock0  is set
  wire [3:0] pdly      = 5;  // Power-up reset delay (after global_reset is released)
  reg        power_up  = 0;
  reg  [1:0] power_up2 = 0;
  wire       powerupq;

  SRL16E upowerup (.CLK(clock),.CE(~power_up),.D(1'b1),.A0(pdly[0]),.A1(pdly[1]),.A2(pdly[2]),.A3(pdly[3]),.Q(powerupq));

// FPGA Ready, disconnects boostrap logic hardware
  reg  ready         = 0;  // IOB ff ready to boot register
  reg ccb_status_tri = 1;  // synthesis attribute KEEP of ccb_status_tri is "true";

  wire   power_up_latch = (powerupq & lock_tmb_clock0) | power_up; // JGhere, inserted requirement here for clock0 to lock
  wire   ready_int      = power_up;      // Fabric ff
  assign tmb_cfg_done   = power_up & power_up2[1];  // Force LUT insertion to create a single source
  wire   power_up_reset = global_reset & global_reset_en; // global reset is enabled at least once; JG: default used to be "reassert on lock_lost" too
  assign mez_busy       = ~mez_done;      // Available for future use

  always @(posedge clock_vme) begin
     if (power_up_reset) begin
	power_up   <= 0;
	ready      <= 0;
	ccb_status_tri  <= 0;
     end
     else begin
	power_up   <= power_up_latch;          // Internal ff init
	ready      <= power_up_latch;          // send ready to boot register
	ccb_status_tri  <= !power_up_latch;    // ccb status tri stated until powerup done
     end
  end

  always @(posedge clock) begin            // 2bx later for prom_led
     power_up2[0] <= power_up;
     power_up2[1] <= power_up2[0];
  end

// ISE hack
  // synthesis attribute IOB  of ccb_status_tri            is "false";

// counters to monitor startup timing...
//   Read bits 20:5 or 19:4 or 17:2 to VME... 800 or 400 or 100 ns resolution, counts to 52.4 or 26.2 or 6.5 ms
//  reg  [23:0]  tmb_mmcm_lock_time = 24'h000000;    // Adr 186 --probably the same as power-up time -->> 144
  reg  [23:0]  tmb_power_up_time = 24'h000000;     // Adr 188 -->> 144
  reg  [23:0]  tmb_load_cfg_time = 24'h000000;     // Adr 18A -->> 187
  reg  [23:0]  alct_phaser_lock_time = 24'h000000; // Adr 18C -->> 1169 = 469 usec. during alct_config_wait?
  reg  [23:0]  alct_load_cfg_time = 24'h000000;    // Adr 18E -- time after alct_config_wait, 653
  reg  [23:0]  comp_phaser_lock_time = 24'h000000; // Adr ??? use this to replace Adr 190
  reg  [23:0]  gtx_rst_done_time = 24'h000000;     // was Adr 190 -->> 273 (doesn't need a fiber?)
  reg  [23:0]  gtx_sync_done_time = 24'h000000;    // Adr 192 -->> 307 (doesn't need a fiber?)
  reg   [3:0]  ldps_busy = 4'h0;      // permanently set after first mmcm phaser lock cycle is completed
  reg          mmcm_firstlock = 1'b0;  // permanently set after first mmcm lock
  reg          gtx_rst_completed = 1'b0;  // permanently set after first gtx_rst is completed
  reg          gtx_sync_completed = 1'b0; // permanently set after first gtx_sync is completed
  reg          jsm_cfg_done = 1'b0;    // permanently set after first alct jtag configure cycle is completed
  reg          alct_phaser_done_r = 1'b0;    // permanently set after first alct dps phaser lock cycle  is complete
  reg          comp_phaser2_done_r = 1'b0;    // permanently set after first comp dps phaser lock cycle  is complete
  reg          comp_phaser3_done_r = 1'b0;    // permanently set after first comp dps phaser lock cycle  is complete
  reg          gtx_sync_too_long = 1'b0;

  always @(posedge tmb_clock0_ibufg) begin
    if (lock_tmb_clock0) mmcm_firstlock <= 1'b1;      // so it will only time the first mmcm lock cycle
//    if (!lock_tmb_clock0 && !mmcm_firstlock && (tmb_mmcm_lock_time[17:10] != 8'hFF)) tmb_mmcm_lock_time <= tmb_mmcm_lock_time + 1'b1;
    if (!power_up && (tmb_power_up_time[17:10] != 8'hFF)) tmb_power_up_time <= tmb_power_up_time + 1'b1;
    if (!vsm_ready && (tmb_load_cfg_time[17:10] != 8'hFF)) tmb_load_cfg_time <= tmb_load_cfg_time + 1'b1; // time until TMB is ready

    if (phaser0_rd[2]) ldps_busy[0] <= 1'b1; // phaser 0 and 1 are for ALCT (dps 0,1)
    if (phaser1_rd[2]) ldps_busy[1] <= 1'b1;
    if (phaser7_rd[2]) ldps_busy[2] <= 1'b1; // phaser 7 and 8 are for comparator fiber links from DCFEBs (dps 2,3)
    if (phaser8_rd[2]) ldps_busy[3] <= 1'b1;
    if (!alct_phaser_done_r) alct_phaser_done_r <= alct_phaser_done;
    if (!comp_phaser2_done_r) comp_phaser2_done_r <= comp_phaser2_done;
    if (!comp_phaser3_done_r) comp_phaser3_done_r <= comp_phaser3_done;
     
    if (!alct_phaser_done_r && (alct_phaser_lock_time[17:10] != 8'hFF)) alct_phaser_lock_time <= alct_phaser_lock_time + 1'b1; // time until TMB clocks for alct are ready and locked
    if ( (!comp_phaser2_done_r | !comp_phaser3_done_r) && (comp_phaser_lock_time[17:10] != 8'hFF)) comp_phaser_lock_time <= comp_phaser_lock_time + 1'b1; // time until TMB clocks for comp are ready and locked
    gtx_sync_too_long  <=  (~|gtx_sync_done_time[15:10]) & (|gtx_sync_done_time[17:16]); // gtx s.b. done before 800us, so reset at 1638us and release at 1664us... repeats cycle 2 more times if needed at 3276 and 4915us

// JRG, note that alct_startup_done means alct is ready to receive jtag cfg data.  use  jsm_ok  to indicate cfg is done!
    if (jsm_ok) jsm_cfg_done <= 1'b1;
    if (!jsm_cfg_done && alct_startup_done && (alct_load_cfg_time[17:10] != 8'hFF)) alct_load_cfg_time <= alct_load_cfg_time + 1'b1; // time to send alct config data after alct fpga is ready for it; for total delay add alct_startup_delay and the longer of power_up_time or tmb_load_cfg_time

    if (gtx_rst_done) gtx_rst_completed <= 1'b1;      // so it will only time the first reset cycle completion
    if (!gtx_rst_completed && (gtx_rst_done_time[17:10] != 8'hFF)) gtx_rst_done_time <= gtx_rst_done_time + 1'b1; // note: reset is followed by sync

    if (virtex6_gtx_rx_all_rd[3]) gtx_sync_completed <= 1'b1;      // so it will only time the first sync cycle completion
    if (!gtx_sync_completed && (gtx_sync_done_time[17:10] != 8'hFF)) gtx_sync_done_time <= gtx_sync_done_time + 1'b1; // note: sync comes after reset

    fast_sum <= absum + cdsum;   // Adr 186 --JGhere, test: count bits in phaser_lock + alct_load_cfg
  end

  assign alct_phaser_done =  ( !(|dps_busy[1:0]) && (&ldps_busy[1:0]) && (&dps_lock[1:0]) );  //  use to time the first alct dps phaser cycle
  assign comp_phaser2_done =  ( (!dps_busy[2]) && ldps_busy[2] && dps_lock[2]  );  // use to time the first comp dps phaser2 cycle
  assign comp_phaser3_done =  ( (!dps_busy[3]) && ldps_busy[3] && dps_lock[3]  );  // use to time the first comp dps phaser3 cycle
  assign gtx_rst_done = &gtx_rx_rst_done;

  assign comp_phaser_a_ready =   comp_phaser2_done_r;    // permanently set after first comp dps phaser lock cycle  is complete
  assign comp_phaser_b_ready =   comp_phaser3_done_r;    // permanently set after first comp dps phaser lock cycle  is complete
  assign auto_gtx_reset = gtx_sync_too_long;  // gtx did not sync after hard reset, so force a gtx reset


  reg [4:0] fast_sum = 0;
  wire [2:0] sa = fast6count(alct_phaser_lock_time[7:2]);
  wire [2:0] sb = fast6count(alct_phaser_lock_time[13:8]);
  wire [2:0] sc = fast6count(alct_load_cfg_time[7:2]);
  wire [2:0] sd = fast6count(alct_load_cfg_time[13:8]);
  wire [3:0] absum = sa + sb;
  wire [3:0] cdsum = sc + sd;
   
  function [2:0] fast6count;
     input [5:0] s;
     begin
	fast6count[0] = ^s[5:0];   // an odd number of bits are set
	fast6count[1] = s==6'b111111 |  // all 6 set, or exactly 3, or exactly 2
// set 3 out of 6, 20 ways :
          ( s==6'b000111 | s==6'b111000 | 
	    s==6'b001011 | s==6'b001101 | s==6'b001110  |  s==6'b010011 | s==6'b010101 | s==6'b010110  |  s==6'b100011 | s==6'b100101 | s==6'b100110 | 
	    s==6'b011001 | s==6'b011010 | s==6'b011100  |  s==6'b101001 | s==6'b101010 | s==6'b101100  |  s==6'b110001 | s==6'b110010 | s==6'b110100 ) |
// set 2 out of 6, 15 ways :
          ( s==6'b000011 | s==6'b000101 | s==6'b000110  |  s==6'b001001 | s==6'b001010 | s==6'b001100  | 
	    s==6'b010001 | s==6'b010010 | s==6'b010100 | s==6'b011000 | 
	    s==6'b100001 | s==6'b100010 | s==6'b100100 | s==6'b101000 | s==6'b110000 );
	fast6count[2] = s==6'b111111 |  // all 6 set, or exactly 4, or exactly 5
// set 4 out of 6, 15 ways :
          ( s==6'b111100 | s==6'b111010 | s==6'b111001  |  s==6'b110110 | s==6'b110101 | s==6'b110011  | 
	    s==6'b101110 | s==6'b101101 | s==6'b101011 | s==6'b100111 | 
	    s==6'b011110 | s==6'b011101 | s==6'b011011 | s==6'b010111 | s==6'b001111 ) |
// set 4 out of 6, 15 ways :
          ( s==6'b111110 | s==6'b111101 | s==6'b111011  |  s==6'b110111 | s==6'b101111 | s==6'b011111 );
     end
  endfunction



//------------------------------------------------------------------------------------------------------------------
// Startup wait for Spartan-6: 33,761,696 cfg bits/8 = 4220212 clocks 20MHz = 8440424 40MHz = 210.60msec for LHC 40.078414MHz
//------------------------------------------------------------------------------------------------------------------
  wire [15:0] alct_startup_delay;
  wire vsm_ready;

  alct_startup ualct_startup
  (
    // Inputs
    .clock              (clock),                    // In  40 MHz clock
    .global_reset       (global_reset),             // In  Global reset
    .power_up           (power_up),                 // In  DLL clock lock, we wait for it
    .vme_ready          (vsm_ready),                // In  TMB VME registers loaded from PROM
    .alct_startup_delay (alct_startup_delay[15:0]), // In  Msec to wait for ALCT FPGA after TMB is up: 212-100=112msec for Spartan-6 on ALCT
    // Outputs
    .alct_startup_msec (alct_startup_msec), // Out  Msec pulse
    .alct_wait_dll     (alct_wait_dll),     // Out  Waiting for TMB DLL lock
    .alct_wait_vme     (alct_wait_vme),     // Out  Waiting for TMB VME load from user PROM
    .alct_wait_cfg     (alct_wait_cfg),     // Out  Waiting for ALCT FPGA to configure from mez PROM
    .alct_startup_done (alct_startup_done)  // Out  ALCT FPGA should be configured by now
  );

//------------------------------------------------------------------------------------------------------------------
// VME Bus Logic
//------------------------------------------------------------------------------------------------------------------
// VME input IOB FFs
  (*IOB="true" *) reg [23:1] a_vme     = 0;
  (*IOB="true" *) reg [5:0]  am_vme    = 0;
  (*IOB="true" *) reg [4:0]  nga       = 1;
  (*IOB="true" *) reg        ngap      = 1;
  (*IOB="true" *) reg        niack     = 1;
  (*IOB="true" *) reg        nlword    = 1;
  (*IOB="true" *) reg        nds0      = 1;
  (*IOB="true" *) reg        nds1      = 1;
  (*IOB="true" *) reg        nas       = 1;
  (*IOB="true" *) reg        nwrite    = 1;
  (*IOB="true" *) reg        nsysclk   = 1;
  (*IOB="true" *) reg        nsysfail  = 1;
  (*IOB="true" *) reg        nsysreset = 1;
  (*IOB="true" *) reg        nacfail   = 1;
  (*IOB="false"*) reg        nlocal    = 1;  // clock domain conflict precludes IOB ff for vme_geo[6]

  always @(posedge clock_vme) begin
    a_vme     <=   a;
    am_vme    <=   am;
    nga       <=  _ga;
    ngap      <=  _gap;
    niack     <=  _iack;  
    nlword    <=  _lword;
    nds0      <=  _ds0;
    nds1      <=  _ds1;
    nas       <=  _as;
    nwrite    <=  _write;
    nsysclk   <=  _sysclk;
    nsysfail  <=  _sysfail;
    nsysreset <=  _sysreset;
    nacfail   <=  _acfail;
    nlocal    <=  _local;
  end

// Uninvert VME negative logic backplane signals at IOB exit
  wire [4:0] ga       = ~nga;
  wire       gap      = ~ngap;
  wire       iack     = ~niack;  
  wire       lword    = ~nlword;
  wire       ds0      = ~nds0;
  wire       ds1      = ~nds1;
  wire       as       = ~nas;
  wire       write    = ~nwrite;
  wire       sysclk   = ~nsysclk;
  wire       sysfail  = ~nsysfail;
  wire       sysreset = ~nsysreset;
  wire       acfail   = ~nacfail;
  wire       local    = ~nlocal;

// Match VME Address and Address Mode
  wire global_match = (a_vme[23:19] == ADR_TMB_GLOBAL); // A[] matches TMB global address
  wire slot_match   = (a_vme[23:19] == ga[4:0]);        // A[] matches this board's VME slot
  wire brcst_match  = (a_vme[23:19] == ADR_BROADCAST);  // A[] matches broadcast address
  wire boot_match   = (a_vme[18:16] == 3'b111);         // A[] matches hardware bootstrap address
  wire am_match     = (am_vme=='h39 || am_vme=='h3D) && iack==0;                               // 39=A24 non-priv mode, 3D=A24 supervisor mode
  wire bd_accessed  = (global_match || slot_match || brcst_match) && am_match;                 // Board accessed, for LED display only 
  wire bd_match     = (global_match || slot_match || brcst_match) && am_match && !boot_match;  // Board is selected

// Board Select FF, U102A on TMB
  reg bd_sel=0;

  always @(posedge clock_vme) begin
     bd_sel <= bd_match & ds0;
  end

// DTACK data acknowledge IOB FF, xst automatically creates a duplicate in fabric for feedback signal
  reg dtack     = 0;  // IOB copy  JRG: Check polarity!
  reg dtack_int = 0;  // Fabric copy

  always @(posedge clock_vme) begin
//    dtack      <= bd_sel & ds0 & (!bpi_dev | !bpi_dtack);  // IOB   flip flop has no feedback path, now include BPI
//    dtack_int  <= bd_sel & ds0 & (!bpi_dev | !bpi_dtack);  // Fabric flip flop has feedback to logic, now include BPI
     dtack      <= bd_sel & ds0 & (!bpi_dev | bpi_dtack);  // IOB   flip flop has no feedback path, now include BPI
     dtack_int  <= bd_sel & ds0 & (!bpi_dev | bpi_dtack);  // Fabric flip flop has feedback to logic, now include BPI
//    dtack      <= bd_sel & ds0;    // IOB    flip flop has no feedback path
//    dtack_int  <= bd_sel & ds0;    // Fabric flip flop has feedback to logic
  end

// Construct read and write strobes
  wire vsm_ds0;

  wire read    = !write;
  wire dir     = !(bd_sel && ds0 && read);  // 1=VME-->TMB (write), 0=TMB-->VME (read)
  wire _oe     = !(bd_sel && ds0);    // 0=Enable VME d[15:0] buffer
  wire fpga_oe = !_oe && !dir;      // 1=enable fpga outputs to VME bus driver ICs (when dir==0)

  wire clk_en  = (ds0 && write && !dtack_int && bd_sel) || vsm_ds0;  // 1=enable register for writing
  wire adr_cap =  ds0 && write && !dtack_int;        // 1=capture VME address for debug readback

// Interrupts
  assign iackout = (~_iackin) & ~iack;          // Pass interrupt daisy chain
  assign irq     = 0;              // Interrupt request not implemented
  assign berr    = 0;              // Bus error not implemented

//------------------------------------------------------------------------------------------------------------------
// VME Read-Data Multiplexer
//------------------------------------------------------------------------------------------------------------------
  reg  [15:0] data_out;
  wire [23:0] vsm_adr;
  wire        vsm_oe;

  wire [8:0]  reg_adr = (vsm_oe) ? vsm_adr[8:0] : {a_vme[8:1],1'b0};  // Pad A0, multplex vme backplane with vmesm prom data

  always @* begin
  case (reg_adr)
  ADR_IDREG0:      data_out  <= id_reg0_rd;
  ADR_IDREG1:      data_out  <= id_reg1_rd;
  ADR_IDREG2:      data_out  <= id_reg2_rd;
  ADR_IDREG3:      data_out  <= id_reg3_rd;
                 
  ADR_VME_STATUS:      data_out  <= vme_status_rd;
  ADR_VME_ADR0:      data_out  <= vme_adr0_rd;
  ADR_VME_ADR1:      data_out  <= vme_adr1_rd;
                 
  ADR_LOOPBK:      data_out  <= tmb_loop_rd;
  ADR_USR_JTAG:      data_out  <= usr_jtag_rd;
  ADR_PROM:      data_out  <= prom_rd;
                 
  ADR_DDDSM:      data_out  <= dddsm_rd;
  ADR_DDD0:      data_out  <= ddd0_rd;
  ADR_DDD1:      data_out  <= ddd1_rd;
  ADR_DDD2:      data_out  <= ddd2_rd;
  ADR_DDDOE:      data_out  <= dddoe_rd;
  ADR_RATCTRL:      data_out  <= rat_control_rd;
                 
  ADR_STEP:      data_out  <= step_rd;
  ADR_LED:      data_out  <= led_rd;
  ADR_ADC:      data_out  <= adc_rd;
  ADR_DSN:      data_out  <= dsn_rd;
                 
  ADR_MOD_CFG:      data_out  <= mod_cfg_rd;
  ADR_CCB_CFG:      data_out  <= ccb_cfg_rd;
  ADR_CCB_TRIG:      data_out  <= ccb_trig_rd;
  ADR_CCB_STAT0:      data_out  <= ccb_stat0_rd;
                 
  ADR_ALCT_CFG:      data_out  <= alct_cfg_rd;
  ADR_ALCT_INJ:      data_out  <= alct_inj_rd;
  ADR_ALCT0_INJ:      data_out  <= alct0_inj_rd;
  ADR_ALCT1_INJ:      data_out  <= alct1_inj_rd;
  ADR_ALCT_STAT:      data_out  <= alct_stat_rd;
  ADR_ALCT0_RCD:      data_out  <= alct0_rcd_rd;
  ADR_ALCT1_RCD:      data_out  <= alct1_rcd_rd;
  ADR_ALCT_FIFO0:      data_out  <= alct_fifo0_rd;
                 
  ADR_DMB_MON:      data_out  <= dmb_mon_rd;
                 
  ADR_CFEB_INJ:      data_out  <= cfeb_inj_rd;
  ADR_CFEB_INJ_ADR:    data_out  <= cfeb_inj_adr_rd;
  ADR_CFEB_INJ_WDATA:    data_out  <= cfeb_inj_wdata_rd;
  ADR_CFEB_INJ_RDATA:    data_out  <= cfeb_inj_rdata_rd;
                 
  ADR_HCM001:      data_out  <= hcm001_rd;
  ADR_HCM023:      data_out  <= hcm023_rd;
  ADR_HCM045:      data_out  <= hcm045_rd;
  ADR_HCM101:      data_out  <= hcm101_rd;
  ADR_HCM123:      data_out  <= hcm123_rd;
  ADR_HCM145:      data_out  <= hcm145_rd;
  ADR_HCM201:      data_out  <= hcm201_rd;
  ADR_HCM223:      data_out  <= hcm223_rd;
  ADR_HCM245:      data_out  <= hcm245_rd;
  ADR_HCM301:      data_out  <= hcm301_rd;
  ADR_HCM323:      data_out  <= hcm323_rd;
  ADR_HCM345:      data_out  <= hcm345_rd;
  ADR_HCM401:      data_out  <= hcm401_rd;
  ADR_HCM423:      data_out  <= hcm423_rd;
  ADR_HCM445:      data_out  <= hcm445_rd;
                 
  ADR_SEQ_TRIG_EN:   data_out  <= seq_trigen_rd;
  ADR_SEQ_TRIG_DLY0: data_out  <= seq_trigdly0_rd;
  ADR_SEQ_TRIG_DLY1: data_out  <= seq_trigdly1_rd;
  ADR_SEQ_TRIG_DLY2: data_out  <= seq_trigdly2_rd;
  ADR_SEQ_ID:        data_out  <= seq_id_rd;
                 
  ADR_SEQ_CLCT:      data_out  <= seq_clct_rd;
  ADR_SEQ_FIFO:      data_out  <= seq_fifo_rd;
  ADR_SEQ_L1A:      data_out  <= seq_l1a_rd;
  ADR_SEQ_OFFSET0:    data_out  <= seq_offset0_rd;
                 
  ADR_SEQ_CLCT0:      data_out  <= seq_clct0_rd;
  ADR_SEQ_CLCT1:      data_out  <= seq_clct1_rd;
  ADR_SEQ_TRIG_SRC:    data_out  <= seq_trig_source_rd;
                 
  ADR_DMB_RAM_ADR:    data_out  <= dmb_ram_adr_rd;
  ADR_DMB_RAM_WDATA:    data_out  <= dmb_ram_wdata_rd;
  ADR_DMB_RAM_WDCNT:    data_out  <= dmb_ram_wdcnt_rd;
  ADR_DMB_RAM_RDATA:    data_out  <= dmb_ram_rdata_rd;
                 
  ADR_TMB_TRIG:      data_out  <= tmb_trig_rd;
                 
  ADR_MPC0_FRAME0:    data_out  <= mpc0_frame0_rd;
  ADR_MPC0_FRAME1:    data_out  <= mpc0_frame1_rd;
  ADR_MPC1_FRAME0:    data_out  <= mpc1_frame0_rd;
  ADR_MPC1_FRAME1:    data_out  <= mpc1_frame1_rd;
  
  ADR_MPC0_FRAME0_FIFO:    data_out  <= mpc0_frame0_fifo_rd;
  ADR_MPC0_FRAME1_FIFO:    data_out  <= mpc0_frame1_fifo_rd;
  ADR_MPC1_FRAME0_FIFO:    data_out  <= mpc1_frame0_fifo_rd;
  ADR_MPC1_FRAME1_FIFO:    data_out  <= mpc1_frame1_fifo_rd;
  
  ADR_MPC_FRAMES_FIFO_CTRL: data_out  <= mpc_frames_fifo_ctrl_rd;

  ADR_TMB_SPECIAL_COUNT:     data_out  <= tmb_special_count_rd;     // Adr 186 used to Read MMCM lock time, now just whatever we need it for!
  ADR_TMB_POWER_UP_TIME:     data_out  <= tmb_power_up_time_rd;     // Adr 188
  ADR_TMB_LOAD_CFG_TIME:     data_out  <= tmb_load_cfg_time_rd;     // Adr 18A
  ADR_ALCT_PHASER_LOCK_TIME: data_out  <= alct_phaser_lock_time_rd; // Adr 18C
  ADR_ALCT_LOAD_CFG_TIME:    data_out  <= alct_load_cfg_time_rd;    // Adr 18E -- time after alct_config_wait
  ADR_GTX_RST_DONE_TIME:     data_out  <= gtx_rst_done_time_rd;     // Adr 190
  ADR_GTX_SYNC_DONE_TIME:    data_out  <= gtx_sync_done_time_rd;    // Adr 192
  
  ADR_TMB_LATENCY_SR: data_out  <= tmb_latency_sr_rd; // Adr 196

  ADR_MPC_INJ:      data_out  <= mpc_inj_rd;
  ADR_MPC_RAM_ADR:    data_out  <= mpc_ram_adr_rd;  
  ADR_MPC_RAM_WDATA:    data_out  <= mpc_ram_wdata_rd;
  ADR_MPC_RAM_RDATA:    data_out  <= mpc_ram_rdata_rd;
                 
  ADR_SCP_CTRL:      data_out  <= scp_ctrl_rd;
  ADR_SCP_RDATA:      data_out  <= scp_rdata_rd;
                 
  ADR_CCB_CMD:      data_out  <= ccb_cmd_rd;
  ADR_BUF_STAT0:      data_out  <= buf_stat0_rd;
  ADR_BUF_STAT1:      data_out  <= buf_stat1_rd;
  ADR_BUF_STAT2:      data_out  <= buf_stat2_rd;
  ADR_BUF_STAT3:      data_out  <= buf_stat3_rd;
  ADR_BUF_STAT4:      data_out  <= buf_stat4_rd;
  ADR_ALCTFIFO1:      data_out  <= alct_fifo1_rd;
  ADR_ALCTFIFO2:      data_out  <= alct_fifo2_rd;
  ADR_SEQMOD:      data_out  <= seq_trigmod_rd;
  ADR_SEQSM:      data_out  <= seq_smstat_rd;
  ADR_SEQCLCTM:      data_out  <= seq_clctmsb_rd;
  ADR_TMBTIM:      data_out  <= tmb_timing_rd;
  ADR_LHC_CYCLE:      data_out  <= lhc_cycle_rd;
                 
  ADR_RPC_CFG:      data_out  <= rpc_cfg_rd;
  ADR_RPC_RDATA:      data_out  <= rpc_rdata_rd;
  ADR_RPC_RAW_DELAY:    data_out  <= rpc_raw_delay_rd;
  ADR_RPC_INJ:      data_out  <= rpc_inj_rd;
  ADR_RPC_INJ_ADR:    data_out  <= rpc_inj_adr_rd;
  ADR_RPC_INJ_WDATA:    data_out  <= rpc_inj_wdata_rd;
  ADR_RPC_INJ_RDATA:    data_out  <= rpc_inj_rdata_rd;
  ADR_RPC_TBINS:      data_out  <= rpc_tbins_rd;
  ADR_RPC0_HCM:      data_out  <= rpc0_hcm_rd;
  ADR_RPC1_HCM:      data_out  <= rpc1_hcm_rd;
  ADR_BX0_DELAY:      data_out  <= bx0_delay_rd;
  ADR_NON_TRIG_RO:    data_out  <= non_trig_ro_rd;
                 
  ADR_SCP_TRIG:      data_out  <= scp_trigger_ch_rd;
                 
  ADR_CNT_CTRL:  data_out  <= cnt_ctrl_rd;
  ADR_CNT_RDATA: data_out  <= cnt_rdata_rd;
                 
  ADR_JTAGSM0:      data_out  <= jtagsm0_rd;
  ADR_JTAGSM1:      data_out  <= jtagsm1_rd;
  ADR_JTAGSM2:      data_out  <= jtagsm2_rd;
                 
  ADR_VMESM0:      data_out  <= vmesm0_rd;
  ADR_VMESM1:      data_out  <= vmesm1_rd;
  ADR_VMESM2:      data_out  <= vmesm2_rd;
  ADR_VMESM3:      data_out  <= vmesm3_rd;
  ADR_VMESM4:      data_out  <= vmesm4_rd;
                 
  ADR_DDDRSM:      data_out  <= dddrsm_rd;
  ADR_DDDR0:      data_out  <= dddr_rd;
                 
  ADR_UPTIME:      data_out  <= uptime_rd;
  ADR_BDSTATUS:      data_out  <= bd_status_rd;
                 
  ADR_BXN_CLCT:      data_out  <= bxn_clct_rd;
  ADR_BXN_ALCT:      data_out  <= bxn_alct_rd;
                 
  ADR_LAYER_TRIG:      data_out  <= layer_trig_rd;
                 
  ADR_ISE_VERSION:    data_out  <= ise_version_rd;
  ADR_TEMP0:      data_out  <= temp0_rd;
  ADR_TEMP1:      data_out  <= temp1_rd;
  ADR_TEMP2:      data_out  <= temp2_rd;
  ADR_PARITY:      data_out  <= parity_rd;
                 
  ADR_CCB_STAT1:      data_out  <= ccb_stat1_rd;
  ADR_BXN_L1A:      data_out  <= bxn_l1a_rd;
  ADR_L1A_LOOKBACK:    data_out  <= l1a_lookback_rd;
  ADR_SEQ_DEBUG:      data_out  <= seqdeb_rd;
                 
  ADR_ALCT_SYNC_CTRL:    data_out  <= alct_sync_ctrl_rd;
  ADR_ALCT_SYNC_TXDATA_1ST:  data_out  <= alct_sync_txdata_1st_rd;
  ADR_ALCT_SYNC_TXDATA_2ND:  data_out  <= alct_sync_txdata_2nd_rd;
                 
  ADR_SEQ_OFFSET1:    data_out  <= seq_offset1_rd;
  ADR_MINISCOPE:      data_out  <= miniscope_rd;
                 
  ADR_PHASER0:      data_out  <= phaser0_rd;
  ADR_PHASER1:      data_out  <= phaser1_rd;
  ADR_PHASER2:      data_out  <= phaser2_rd;
  ADR_PHASER3:      data_out  <= phaser3_rd;
  ADR_PHASER4:      data_out  <= phaser4_rd;
  ADR_PHASER5:      data_out  <= phaser5_rd;
  ADR_PHASER6:      data_out  <= phaser6_rd;
                 
  ADR_DELAY0_INT:      data_out  <= delay0_int_rd;
  ADR_DELAY1_INT:      data_out  <= delay1_int_rd;
  ADR_SYNC_ERR_CTRL:    data_out  <= sync_err_ctrl_rd;
                 
  ADR_CFEB_BADBITS_CTRL:    data_out  <= cfeb_badbits_ctrl_rd;
  ADR_CFEB_BADBITS_TIMER:    data_out  <= cfeb_badbits_nbx_rd;
                 
  ADR_CFEB0_BADBITS_LY01:    data_out  <= cfeb0_badbits_ly01_rd;
  ADR_CFEB0_BADBITS_LY23:    data_out  <= cfeb0_badbits_ly23_rd;
  ADR_CFEB0_BADBITS_LY45:    data_out  <= cfeb0_badbits_ly45_rd;
                 
  ADR_CFEB1_BADBITS_LY01:    data_out  <= cfeb1_badbits_ly01_rd;
  ADR_CFEB1_BADBITS_LY23:    data_out  <= cfeb1_badbits_ly23_rd;
  ADR_CFEB1_BADBITS_LY45:    data_out  <= cfeb1_badbits_ly45_rd;
                 
  ADR_CFEB2_BADBITS_LY01:    data_out  <= cfeb2_badbits_ly01_rd;
  ADR_CFEB2_BADBITS_LY23:    data_out  <= cfeb2_badbits_ly23_rd;
  ADR_CFEB2_BADBITS_LY45:    data_out  <= cfeb2_badbits_ly45_rd;
                 
  ADR_CFEB3_BADBITS_LY01:    data_out  <= cfeb3_badbits_ly01_rd;
  ADR_CFEB3_BADBITS_LY23:    data_out  <= cfeb3_badbits_ly23_rd;
  ADR_CFEB3_BADBITS_LY45:    data_out  <= cfeb3_badbits_ly45_rd;
                 
  ADR_CFEB4_BADBITS_LY01:    data_out  <= cfeb4_badbits_ly01_rd;
  ADR_CFEB4_BADBITS_LY23:    data_out  <= cfeb4_badbits_ly23_rd;
  ADR_CFEB4_BADBITS_LY45:    data_out  <= cfeb4_badbits_ly45_rd;
                 
  ADR_ALCT_STARTUP_DELAY:    data_out  <= alct_startup_delay_rd;
  ADR_ALCT_STARTUP_STATUS:  data_out  <= alct_startup_status_rd;
                 
// Virtex-6 Only             
  ADR_V6_SNAP12_QPLL:    data_out  <= virtex6_snap12_qpll_rd;
  ADR_V6_GTX_RX_ALL:    data_out  <= virtex6_gtx_rx_all_rd;

  ADR_V6_GTX_RX0:      data_out  <= virtex6_gtx_rx_rd[0];
  ADR_V6_GTX_RX1:      data_out  <= virtex6_gtx_rx_rd[1];
  ADR_V6_GTX_RX2:      data_out  <= virtex6_gtx_rx_rd[2];
  ADR_V6_GTX_RX3:      data_out  <= virtex6_gtx_rx_rd[3];
  ADR_V6_GTX_RX4:      data_out  <= virtex6_gtx_rx_rd[4];
  ADR_V6_GTX_RX5:      data_out  <= virtex6_gtx_rx_rd[5];
  ADR_V6_GTX_RX6:      data_out  <= virtex6_gtx_rx_rd[6];

  ADR_V6_SYSMON:      data_out  <=  virtex6_sysmon_rd;

  ADR_V6_CFEB_BADBITS_CTRL:  data_out  <=  cfeb_v6_badbits_ctrl_rd;
  ADR_V6_CFEB5_BADBITS_LY01:  data_out  <= cfeb5_badbits_ly01_rd;
  ADR_V6_CFEB5_BADBITS_LY23:  data_out  <= cfeb5_badbits_ly23_rd;
  ADR_V6_CFEB5_BADBITS_LY45:  data_out  <= cfeb5_badbits_ly45_rd;

  ADR_V6_CFEB6_BADBITS_LY01:  data_out  <= cfeb6_badbits_ly01_rd;
  ADR_V6_CFEB6_BADBITS_LY23:  data_out  <= cfeb6_badbits_ly23_rd;
  ADR_V6_CFEB6_BADBITS_LY45:  data_out  <= cfeb6_badbits_ly45_rd;

  ADR_V6_PHASER7:      data_out  <= phaser7_rd;
  ADR_V6_PHASER8:      data_out  <= phaser8_rd;

  ADR_V6_HCM501:      data_out  <= hcm501_rd;
  ADR_V6_HCM523:      data_out  <= hcm523_rd;
  ADR_V6_HCM545:      data_out  <= hcm545_rd;
  ADR_V6_HCM601:      data_out  <= hcm601_rd;
  ADR_V6_HCM623:      data_out  <= hcm623_rd;
  ADR_V6_HCM645:      data_out  <= hcm645_rd;

  ADR_V6_EXTEND:      data_out  <= virtex6_extend_rd;

  ADR_ODMB:      data_out  <= odmb_data;

  default:      data_out  <= 16'hDEAF;
  endcase
  end

//------------------------------------------------------------------------------------------------------------------
// VME Write-Data Address Decoder
//------------------------------------------------------------------------------------------------------------------
  assign wr_tmb_loop    = (reg_adr==ADR_LOOPBK      && clk_en);
  assign wr_usr_jtag    = (reg_adr==ADR_USR_JTAG    && clk_en) && !wr_usr_jtag_dis;
  assign wr_prom      = (reg_adr==ADR_PROM      && clk_en);

  assign wr_dddsm      = (reg_adr==ADR_DDDSM      && clk_en);
  assign wr_ddd0      = (reg_adr==ADR_DDD0      && clk_en);
  assign wr_ddd1      = (reg_adr==ADR_DDD1      && clk_en);
  assign wr_ddd2      = (reg_adr==ADR_DDD2      && clk_en);
  assign wr_dddoe      = (reg_adr==ADR_DDDOE      && clk_en);
  assign wr_rat_control    = (reg_adr==ADR_RATCTRL      && clk_en);

  assign wr_step      = (reg_adr==ADR_STEP      && clk_en);
  assign wr_led      = (reg_adr==ADR_LED      && clk_en);
  assign wr_adc      = (reg_adr==ADR_ADC      && clk_en);
  assign wr_dsn      = (reg_adr==ADR_DSN      && clk_en);

  assign wr_mod_cfg    = (reg_adr==ADR_MOD_CFG      && clk_en);
  assign wr_ccb_cfg    = (reg_adr==ADR_CCB_CFG      && clk_en);
  assign wr_ccb_trig    = (reg_adr==ADR_CCB_TRIG    && clk_en);
  assign wr_alct_cfg    = (reg_adr==ADR_ALCT_CFG    && clk_en);
  assign wr_alct_inj    = (reg_adr==ADR_ALCT_INJ    && clk_en);
  assign wr_alct0_inj    = (reg_adr==ADR_ALCT0_INJ    && clk_en);
  assign wr_alct1_inj    = (reg_adr==ADR_ALCT1_INJ    && clk_en);
  assign wr_alct_stat    = (reg_adr==ADR_ALCT_STAT    && clk_en);
  assign wr_cfeb_inj    = (reg_adr==ADR_CFEB_INJ    && clk_en);
  assign wr_cfeb_inj_adr    = (reg_adr==ADR_CFEB_INJ_ADR    && clk_en);
  assign wr_cfeb_inj_wdata  = (reg_adr==ADR_CFEB_INJ_WDATA    && clk_en);

  assign wr_hcm001    = (reg_adr==ADR_HCM001      && clk_en);
  assign wr_hcm023    = (reg_adr==ADR_HCM023      && clk_en);
  assign wr_hcm045    = (reg_adr==ADR_HCM045      && clk_en);
  assign wr_hcm101    = (reg_adr==ADR_HCM101      && clk_en);
  assign wr_hcm123    = (reg_adr==ADR_HCM123      && clk_en);
  assign wr_hcm145    = (reg_adr==ADR_HCM145      && clk_en);
  assign wr_hcm201    = (reg_adr==ADR_HCM201      && clk_en);
  assign wr_hcm223    = (reg_adr==ADR_HCM223      && clk_en);
  assign wr_hcm245    = (reg_adr==ADR_HCM245      && clk_en);
  assign wr_hcm301    = (reg_adr==ADR_HCM301      && clk_en);
  assign wr_hcm323    = (reg_adr==ADR_HCM323      && clk_en);
  assign wr_hcm345    = (reg_adr==ADR_HCM345      && clk_en);
  assign wr_hcm401    = (reg_adr==ADR_HCM401      && clk_en);
  assign wr_hcm423    = (reg_adr==ADR_HCM423      && clk_en);
  assign wr_hcm445    = (reg_adr==ADR_HCM445      && clk_en);
  assign wr_hcm501    = (reg_adr==ADR_V6_HCM501   && clk_en);
  assign wr_hcm523    = (reg_adr==ADR_V6_HCM523   && clk_en);
  assign wr_hcm545    = (reg_adr==ADR_V6_HCM545   && clk_en);
  assign wr_hcm601    = (reg_adr==ADR_V6_HCM601   && clk_en);
  assign wr_hcm623    = (reg_adr==ADR_V6_HCM623   && clk_en);
  assign wr_hcm645    = (reg_adr==ADR_V6_HCM645   && clk_en);

  assign wr_seq_trigen   = (reg_adr==ADR_SEQ_TRIG_EN   && clk_en);
  assign wr_seq_trigdly0 = (reg_adr==ADR_SEQ_TRIG_DLY0 && clk_en);
  assign wr_seq_trigdly1 = (reg_adr==ADR_SEQ_TRIG_DLY1 && clk_en);
  assign wr_seq_trigdly2 = (reg_adr==ADR_SEQ_TRIG_DLY2 && clk_en);
  assign wr_seq_id       = (reg_adr==ADR_SEQ_ID        && clk_en);

  assign wr_seq_clct      = (reg_adr==ADR_SEQ_CLCT      && clk_en);
  assign wr_seq_fifo      = (reg_adr==ADR_SEQ_FIFO      && clk_en);
  assign wr_seq_l1a       = (reg_adr==ADR_SEQ_L1A       && clk_en);
  assign wr_seq_offset0   = (reg_adr==ADR_SEQ_OFFSET0   && clk_en);
  assign wr_dmb_ram_adr   = (reg_adr==ADR_DMB_RAM_ADR   && clk_en);
  assign wr_dmb_ram_wdata = (reg_adr==ADR_DMB_RAM_WDATA && clk_en);
  assign wr_tmb_trig      = (reg_adr==ADR_TMB_TRIG      && clk_en);
  assign wr_mpc_inj       = (reg_adr==ADR_MPC_INJ       && clk_en);
  assign wr_mpc_ram_adr   = (reg_adr==ADR_MPC_RAM_ADR   && clk_en);
  assign wr_mpc_ram_wdata = (reg_adr==ADR_MPC_RAM_WDATA && clk_en);

  assign wr_scp_ctrl  = (reg_adr==ADR_SCP_CTRL  && clk_en);
  assign wr_scp_rdata = (reg_adr==ADR_SCP_RDATA && clk_en);

  assign wr_ccb_cmd    = (reg_adr==ADR_CCB_CMD      && clk_en);
  assign wr_alct_fifo1    = (reg_adr==ADR_ALCTFIFO1    && clk_en);
  assign wr_seq_trigmod    = (reg_adr==ADR_SEQMOD      && clk_en);
  assign wr_tmb_timing    = (reg_adr==ADR_TMBTIM      && clk_en);
  assign wr_lhc_cycle    = (reg_adr==ADR_LHC_CYCLE    && clk_en);

  assign wr_rpc_cfg    = (reg_adr==ADR_RPC_CFG      && clk_en);
  assign wr_rpc_raw_delay    = (reg_adr==ADR_RPC_RAW_DELAY    && clk_en);
  assign wr_rpc_inj    = (reg_adr==ADR_RPC_INJ      && clk_en);
  assign wr_rpc_inj_adr    = (reg_adr==ADR_RPC_INJ_ADR    && clk_en);
  assign wr_rpc_inj_wdata    = (reg_adr==ADR_RPC_INJ_WDATA    && clk_en);
  assign wr_rpc_tbins    = (reg_adr==ADR_RPC_TBINS    && clk_en);
  assign wr_rpc0_hcm    = (reg_adr==ADR_RPC0_HCM    && clk_en);
  assign wr_rpc1_hcm    = (reg_adr==ADR_RPC1_HCM    && clk_en);
  assign wr_bx0_delay    = (reg_adr==ADR_BX0_DELAY    && clk_en);
  assign wr_non_trig_ro    = (reg_adr==ADR_NON_TRIG_RO    && clk_en);

  assign wr_scp_trigger_ch = (reg_adr==ADR_SCP_TRIG && clk_en);
  assign wr_cnt_ctrl       = (reg_adr==ADR_CNT_CTRL && clk_en);

  assign wr_jtagsm0    = (reg_adr==ADR_JTAGSM0      && clk_en);
  assign wr_vmesm0    = (reg_adr==ADR_VMESM0      && clk_en);
  assign wr_vmesm4    = (reg_adr==ADR_VMESM4      && clk_en);

  assign wr_dddrsm    = (reg_adr==ADR_DDDRSM      && clk_en);
  assign wr_dddr       = (reg_adr==ADR_DDDR0      && clk_en);

  assign wr_layer_trig    = (reg_adr==ADR_LAYER_TRIG    && clk_en);

  assign wr_temp0      = (reg_adr==ADR_TEMP0      && clk_en);
  assign wr_temp1      = (reg_adr==ADR_TEMP1      && clk_en);
  assign wr_temp2      = (reg_adr==ADR_TEMP2      && clk_en);
  assign wr_parity    = (reg_adr==ADR_PARITY      && clk_en);
  assign wr_l1a_lookback    = (reg_adr==ADR_L1A_LOOKBACK    && clk_en);
  assign wr_seqdeb    = (reg_adr==ADR_SEQ_DEBUG    && clk_en);

  assign wr_alct_sync_ctrl  = (reg_adr==ADR_ALCT_SYNC_CTRL    && clk_en);
  assign wr_alct_sync_txdata_1st  = (reg_adr==ADR_ALCT_SYNC_TXDATA_1ST  && clk_en);
  assign wr_alct_sync_txdata_2nd  = (reg_adr==ADR_ALCT_SYNC_TXDATA_2ND  && clk_en);

  assign wr_seq_offset1    = (reg_adr==ADR_SEQ_OFFSET1    && clk_en);
  assign wr_miniscope    = (reg_adr==ADR_MINISCOPE    && clk_en);

  assign wr_phaser0    = (reg_adr==ADR_PHASER0      && clk_en);
  assign wr_phaser1    = (reg_adr==ADR_PHASER1      && clk_en);
  assign wr_phaser2    = (reg_adr==ADR_PHASER2      && clk_en);
  assign wr_phaser3    = (reg_adr==ADR_PHASER3      && clk_en);
  assign wr_phaser4    = (reg_adr==ADR_PHASER4      && clk_en);
  assign wr_phaser5    = (reg_adr==ADR_PHASER5      && clk_en);
  assign wr_phaser6    = (reg_adr==ADR_PHASER6      && clk_en);
  assign wr_phaser7    = (reg_adr==ADR_V6_PHASER7    && clk_en);
  assign wr_phaser8    = (reg_adr==ADR_V6_PHASER8    && clk_en);

  assign wr_delay0_int    = (reg_adr==ADR_DELAY0_INT    && clk_en);
  assign wr_delay1_int    = (reg_adr==ADR_DELAY1_INT    && clk_en);
  assign wr_sync_err_ctrl    = (reg_adr==ADR_SYNC_ERR_CTRL    && clk_en);

  assign wr_cfeb_badbits_ctrl  = (reg_adr==ADR_CFEB_BADBITS_CTRL  && clk_en);
  assign wr_cfeb_v6_badbits_ctrl  = (reg_adr==ADR_V6_CFEB_BADBITS_CTRL  && clk_en);
  assign wr_cfeb_badbits_nbx  = (reg_adr==ADR_CFEB_BADBITS_TIMER  && clk_en);

  assign wr_alct_startup_delay  = (reg_adr==ADR_ALCT_STARTUP_DELAY  && clk_en);
  
  assign wr_virtex6_snap12_qpll  = (reg_adr==ADR_V6_SNAP12_QPLL    && clk_en);
  assign wr_virtex6_gtx_rx_all  = (reg_adr==ADR_V6_GTX_RX_ALL    && clk_en);
  assign wr_virtex6_gtx_rx[0]  = (reg_adr==ADR_V6_GTX_RX0    && clk_en);
  assign wr_virtex6_gtx_rx[1]  = (reg_adr==ADR_V6_GTX_RX1    && clk_en);
  assign wr_virtex6_gtx_rx[2]  = (reg_adr==ADR_V6_GTX_RX2    && clk_en);
  assign wr_virtex6_gtx_rx[3]  = (reg_adr==ADR_V6_GTX_RX3    && clk_en);
  assign wr_virtex6_gtx_rx[4]  = (reg_adr==ADR_V6_GTX_RX4    && clk_en);
  assign wr_virtex6_gtx_rx[5]  = (reg_adr==ADR_V6_GTX_RX5    && clk_en);
  assign wr_virtex6_gtx_rx[6]  = (reg_adr==ADR_V6_GTX_RX6    && clk_en);
  assign wr_virtex6_sysmon  = (reg_adr==ADR_V6_SYSMON    && clk_en);

  assign wr_virtex6_extend  = (reg_adr==ADR_V6_EXTEND    && clk_en);
  assign wr_adr_cap    = (adr_cap);
  
  assign wr_mpc_frames_fifo_ctrl = (reg_adr==  ADR_MPC_FRAMES_FIFO_CTRL && clk_en);
  
//------------------------------------------------------------------------------------------------------------------
// VME Bidirectional Data Bus
//------------------------------------------------------------------------------------------------------------------
  wire [15:0] vsm_data, data_send;
  wire [15:0] d;
  
  assign d_vme     = (fpga_oe) ? data_send         : {16{1'bz}};     // transmit to backplane, else float
  assign data_send = (bpi_dev) ? bpi_outdata[15:0] : data_out[15:0]; // JGhere, select bpi data or vme_reg data to send
  assign d[15:0]   = (vsm_oe)  ? vsm_data[15:0]    : d_vme[15:0];    // insert backplane or prom data to write
  
  initial begin
  	$monitor($time, "  VME Monitor: address = 0x%h data = 0x%h", a, d_vme);
  end
  
//------------------------------------------------------------------------------------------------------------------
// ADR_VMESM0=DA  VME State Machine Control Register
// ADR_VMESM1=DC  VME State Machine Word count
// ADR_VMESM2=DE  VME State Machine Check sum + PROM data structure error
// ADR_VMESM3=E0  VME State Machine Number of vme addresses written
// ADR_VMESM4=E2  VME State Machine Expected data to be written from VME PROM
//------------------------------------------------------------------------------------------------------------------
  initial begin
    vmesm0_wr[0]     = 0;           // RW Manual cycle start command
    vmesm0_wr[1]     = 0;           // RW Status signal reset
    vmesm0_wr[2]     = AUTO_VME;    // R  Auto-start after hard-reset
    vmesm0_wr[3]     = 0;           // R  State machine busy writing
    vmesm0_wr[4]     = 0;           // R  State machine aborted reading PROM
    vmesm0_wr[5]     = 0;           // R  Check-sum  matches PROM contents
    vmesm0_wr[6]     = 0;           // R  Word count matches PROM contents
    vmesm0_wr[7]     = AUTO_JTAG;   // R  JTAG SM autostart after vmesm completes
    vmesm0_wr[8]     = 0;           // R  TMB VME registers loaded from PROM
    vmesm0_wr[9]     = 0;           // R  Machine ran without errors
    vmesm0_wr[10]    = 0;           // R  vsm_path_ok
    vmesm0_wr[11]    = AUTO_PHASER; // RW Phaser SM autostart after vmesm completes
    vmesm0_wr[15:12] = 0;           // RW PROM-read speed control, 0=fastest
  end

  initial begin
     vmesm4_wr[15:0] = 0; // RW vmesm over-writes this with even/odd data to test prom path
  end

  wire [7:0] vsm_prom_data;
  wire       vsm_start;
  wire       vsm_sreset;
  wire       vsm_jtag_auto;
  wire       vsm_busy;
  wire       vsm_aborted;
  wire       vsm_cksum_ok;
  wire       vsm_wdcnt_ok;
  wire       vsm_ok;
  wire       vsm_path_ok;
  wire       vsm_phaser_auto;

  wire [3:0]  vsm_throttle;
  wire [15:0] vsm_wdcnt;
  wire [7:0]  vsm_cksum;
  wire [4:0]  vsm_fmt_err;
  wire [7:0]  vsm_nvme_writes;

  wire [3:0] jsm_prom_sm_vec,   jsm_prom_sm_vec_new,   jsm_prom_sm_vec_old;  // Interlopers from JSM, ran out of jsm reg bits
  wire [2:0] jsm_format_sm_vec, jsm_format_sm_vec_new, jsm_format_sm_vec_old;
  wire [1:0] jsm_jtag_sm_vec,   jsm_jtag_sm_vec_new,   jsm_jtag_sm_vec_old;

  wire vme_ready     = ready_int;  // JG: this is really just power_up!
  wire vsm_autostart = AUTO_VME;

  assign vmesm0_rd[0]     = vsm_start;         // RW Manual cycle start command
  assign vmesm0_rd[1]     = vsm_sreset;        // RW Status signal reset
  assign vmesm0_rd[2]     = vsm_autostart;     // R  Auto-start after hard-reset
  assign vmesm0_rd[3]     = vsm_busy;          // R  State machine busy writing
  assign vmesm0_rd[4]     = vsm_aborted;       // R  State machine aborted reading PROM
  assign vmesm0_rd[5]     = vsm_cksum_ok;      // R  Check-sum  matches PROM contents
  assign vmesm0_rd[6]     = vsm_wdcnt_ok;      // R  Word count matches PROM contents
  assign vmesm0_rd[7]     = vsm_jtag_auto;     // RW JTAG SM autostart after vmesm completes
  assign vmesm0_rd[8]     = vsm_ready;         // R  TMB VME registers loaded from PROM. JGhere: was vme_ready, so now it's correct
  assign vmesm0_rd[9]     = vsm_ok;            // R  Machine ran without errors
  assign vmesm0_rd[10]    = vsm_path_ok;       // R  PROM wrote to vmesm4 register ok
  assign vmesm0_rd[11]    = vsm_phaser_auto;   // RW Phaser SM autostart after vmesm completes
  assign vmesm0_rd[15:12] = vsm_throttle[3:0]; // RW PROM-read speed control, 0=fastest

  assign vsm_start         = vmesm0_wr[0];     // RW Manual cycle start command
  assign vsm_sreset        = vmesm0_wr[1];     // RW Status signal reset
  assign vsm_jtag_auto     = vmesm0_wr[7];     // RW JTAG SM autostart after vmesm completes
  assign vsm_phaser_auto   = vmesm0_wr[11];    // RW Phaser SM autostart after vmesm completes
  assign vsm_throttle[3:0] = vmesm0_wr[15:12]; // RW PROM-read speed control, 0=fastest

  assign vmesm1_rd[15:0] = vsm_wdcnt[15:0]; // R  Word count
  
  assign vmesm2_rd[7:0]   = vsm_cksum[7:0];       // R  Check sum
  assign vmesm2_rd[12:8]  = vsm_fmt_err[4:0];     // R  PROM data structure error
  assign vmesm2_rd[14:13] = jsm_jtag_sm_vec[1:0]; // R  JSM JTAG format  State Machine status vector
  assign vmesm2_rd[15]    = 0;                    // R  Unassigned

  assign vmesm3_rd[7:0]   = vsm_nvme_writes[7:0];   // R Number of vme addresses written
  assign vmesm3_rd[11:8]  = jsm_prom_sm_vec[3:0];   // R JSM PROM control State Machine status vector
  assign vmesm3_rd[14:12] = jsm_format_sm_vec[2:0]; // R JSM JTAG format  State Machine status vector
  assign vmesm3_rd[15]    = 0;                      // R Unassigned

  assign vmesm4_rd[15:0] = vmesm4_wr[15:0];      // R vmesm writes to this register to check prom data path
  assign vsm_path_ok     =(vmesm4_wr==16'h55AA); // R Expected data to be written from VME PROM

  vmesm uvmesm
  (
// Control
   .clock      (clock),    // In  40 MHz clock
   .global_reset  (global_reset),      // In  Global reset
   .power_up    (power_up),    // In  DLL clock lock, we wait for it
   .vme_ready    (vme_ready),    // In  TMB VME registers finished setting defaults.  JG: really just power_up
   .start      (vsm_start),    // In  Cycle start command
   .autostart    (AUTO_VME),    // In  Enable automatic power-up
   .throttle    (vsm_throttle[3:0]),  // In  PROM read-speed control, 0=fastest
// PROM
   .prom_data    (vsm_prom_data[7:0]),  // In  prom_data[7:0]
   .prom_clk    (vsm_prom_clk),    // Out  prom_ctrl[0]
   .prom_oe    (vsm_prom_oe),    // Out  prom_ctrl[1]
   .prom_nce    (vsm_prom_nce),    // Out  prom_ctrl[2]
   .vmesm_oe    (vsm_oe),    // Out  Enable vme mux
   .adr      (vsm_adr[23:0]),  // Out  VME register address
   .data      (vsm_data[15:0]),  // Out  VME data from PROM
   .ds0      (vsm_ds0),    // Out  VME stobe
// Status
   .sreset      (vsm_sreset),    // In  Status signal reset
   .busy      (vsm_busy),    // Out  State machine busy
   .busy_extend  (vsm_busy_extend),    // Out  State machine busy extended to hold off jtagsm
   .aborted    (vsm_aborted),    // Out  State machine aborted reading PROM
   .cksum_ok    (vsm_cksum_ok),    // Out  Check-sum  matches PROM contents
   .wdcnt_ok    (vsm_wdcnt_ok),    // Out  Word count matches PROM contents
   .vmesm_ok    (vsm_ok),    // Out  Machine ran without errors
   .wdcnt      (vsm_wdcnt[15:0]),  // Out  Word count
   .cksum      (vsm_cksum[7:0]),  // Out  Check sum
   .fmt_err    (vsm_fmt_err[4:0]),  // Out  PROM data structure error
   .nvme_writes  (vsm_nvme_writes[7:0])          // Out  Number of vme addresses written
  );
//------------------------------------------------------------------------------------------------------------------
// ADR_IDREG0=00  ID Register 0, Readonly
// ADR_IDREG0=02  ID Register 1, Readonly
// ADR_IDREG0=04  ID Register 2, Readonly
// ADR_IDREG0=06  ID Register 3, Readonly
//------------------------------------------------------------------------------------------------------------------
// Construct firmware revcode from global define, truncate for DMB frame
  wire [15:0]  revcode_vme;
  wire [15:0]  version_slot;

  assign revcode_vme[8:0]    = (MONTHDAY[15:12]*10 + MONTHDAY[11:8])*32+ (MONTHDAY[7:4]*10 + MONTHDAY[3:0]);
  assign revcode_vme[12:9]  = YEAR[3:0]+4'hA;    // Need to reformat this in year 2018
  assign revcode_vme[15:13]  = FPGAID[15:13];    // Virtex 2,4,6 etc

  assign revcode[14:0]    = revcode_vme[14:0];  // Sequencer format is 15 bits, VME is 16

// VME ID Registers, Readonly
  assign version_slot[ 3: 0]  = FIRMWARE_TYPE[3:0];  // Firmware type, C=Normal TMB, D=Debug loopback
  assign version_slot[ 7: 4]  = VERSION[3:0];      // Version revision number
  assign version_slot[11: 8]  = ga[3:0  ];      // Geographic address for this board
  assign version_slot[15:12]  = {3'b000,ga[4]};    // Geographic address msb

  assign id_reg0_rd = version_slot[15:0];
  assign id_reg1_rd = MONTHDAY[15:0];
  assign id_reg2_rd = YEAR[15:0];
  assign id_reg3_rd = revcode_vme[15:0];

//------------------------------------------------------------------------------------------------------------------
// ADR_VME_STATUS=08  VME Bus Status Register, Readonly
//------------------------------------------------------------------------------------------------------------------
  assign vme_status_rd[ 0] = ga[0];
  assign vme_status_rd[ 1] = ga[1];
  assign vme_status_rd[ 2] = ga[2];
  assign vme_status_rd[ 3] = ga[3];
  assign vme_status_rd[ 4] = ga[4];
  assign vme_status_rd[ 5] = gap;
  assign vme_status_rd[ 6] = lword;
  assign vme_status_rd[ 7] = as;
  assign vme_status_rd[ 8] = ds1;
  assign vme_status_rd[ 9] = sysclk;
  assign vme_status_rd[10] = sysfail;
  assign vme_status_rd[11] = sysreset;
  assign vme_status_rd[12] = acfail;
  assign vme_status_rd[13] = iack;
  assign vme_status_rd[14] = local;
  assign vme_status_rd[15] = ready_int;

//------------------------------------------------------------------------------------------------------------------
// ADR_VME_ADR0=0A  VME Address [15:00] Read-back Register, Readonly
// ADR_VME_ADR1=0C  VME Address [23:16] Read-back Register, Readonly
//           Capture last VME write address. Readonly, for backplane loopback testing
//------------------------------------------------------------------------------------------------------------------
  initial begin
     vme_adr0_wr = 16'h0000;
     vme_adr1_wr = 16'h0000;
  end

  wire [15:0]  vme_adr0_cap;
  wire [13:0]  vme_adr1_cap;

  assign vme_adr0_cap[0]    = lword;
  assign vme_adr0_cap[15:1]  = a_vme[15:1];

  assign vme_adr1_cap[ 7: 0]  = a_vme[23:16];
  assign vme_adr1_cap[13: 8]  = am_vme[5:0];

  always @(posedge clock_vme) begin
     if (wr_adr_cap)
       begin
	  vme_adr0_wr <= vme_adr0_cap;
	  vme_adr1_wr <= vme_adr1_cap;
       end
  end

  assign vme_adr0_rd[15:0] = vme_adr0_wr[15:0];
  assign vme_adr1_rd[15:0] = {2'b00,vme_adr1_wr[13:0]};

//------------------------------------------------------------------------------------------------------------------
// ADR_LOOPBK=0E  TMB Loopback-mode Register
//          Load defaults at power up, Tri-State control bits until power_up
//------------------------------------------------------------------------------------------------------------------
// Power-up readonly defaults
  assign tmb_loop_ro[0]    = 1'b1;        // 1=CFEB output enable
  assign tmb_loop_ro[1]    = 1'b0;        // 0=No ALCT loop-back
  assign tmb_loop_ro[2]    = 1'b1;        // 1=Enable RAT ALCT LVDS receivers
  assign tmb_loop_ro[3]    = 1'b1;        // 1=Enable RAT ALCT LVDS drivers
  assign tmb_loop_ro[4]    = 1'b0;        // 1=RPC Loop-back (with RAT)
  assign tmb_loop_ro[5]    = 1'b0;        // 1=RPC Loop-back (no RAT  ), used only in bdtest firmware
  assign tmb_loop_ro[6]    = 1'b0;        // 1=PC Loop-back  (with RAT)
  assign tmb_loop_ro[7]    = 1'b0;        // 0=No DMB loop-back
  assign tmb_loop_ro[8]    = 1'b0;        // 0=DMB driver enable
  assign tmb_loop_ro[9]     = 1'b0;        // 0=No GTL loop-back
  assign tmb_loop_ro[10]     = 1'b0;        // 0=Enable GTL outputs
  assign tmb_loop_ro[13:11]  = 0;        // dmb_tx_reserved[2:0], not used
  assign tmb_loop_ro[15:14]  = 0;        // Not used

// Overwritable defaults
  initial begin
     tmb_loop_wr[1:0]      = 0;        // Not used
     tmb_loop_wr[2]        = 1'b1;        // 1=Enable RAT ALCT LVDS receivers
     tmb_loop_wr[3]        = 1'b1;        // 1=Enable RAT ALCT LVDS drivers
     tmb_loop_wr[5:4]      = 0;        // Not used
     tmb_loop_wr[6]        = 1'b0;        // 1=PC Loop-back  (with RAT)
     tmb_loop_wr[15:7]      = 0;        // Not used
  end

  assign  cfeb_oe        = tmb_loop_ro[0];  // 1=CFEB output enable
  assign  alct_loop      = tmb_loop_ro[1];  // 0=No ALCT loop-back
  assign  alct_rxoe      = tmb_loop_wr[2];  // 1=Enable RAT ALCT LVDS receivers
  assign  alct_txoe      = tmb_loop_wr[3];  // 1=Enable RAT ALCT LVDS drivers
  assign  rpc_loop      = tmb_loop_ro[4];  // 0=No RPC Loop-back (with RAT)
  wire  rpc_loop_bdtest    = tmb_loop_ro[5];  // 1=En RPC Loop-back (no RAT  ), used only in bdtest firmware
  assign  rpc_loop_tmb    = tmb_loop_wr[6];  // 0=No RPC Loop-back (with RAT)
  assign  dmb_loop      = tmb_loop_ro[7];  // 0=No DMB loop-back
  assign  _dmb_oe        = tmb_loop_ro[8];  // 0=DMB driver enable
  assign  gtl_loop      = tmb_loop_ro[9];  // 0=No GTL loop-back
  assign  _gtl_oe        = tmb_loop_ro[10];  // 0=Enable GTL outputs
  assign  gtl_loop_lcl    = tmb_loop_ro[9];  // copy for ccb.v

  assign tmb_loop_rd[1:0]    = tmb_loop_ro[1:0];
  assign tmb_loop_rd[2]    = tmb_loop_wr[2];
  assign tmb_loop_rd[3]    = tmb_loop_wr[3];
  assign tmb_loop_rd[5:4]    = tmb_loop_ro[5:4];
  assign tmb_loop_rd[6]    = tmb_loop_wr[6];
  assign tmb_loop_rd[15:7]  = tmb_loop_wr[15:7];

  assign dmb_tx_reserved[2:0]  = tmb_loop_wr[13:11]; // DMB backplane reserved, not used

//------------------------------------------------------------------------------------------------------------------
// ADR_USR_JTAG=10   User JTAG Register
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
     usr_jtag_wr[15:0] = 16'h0000;
  end

  wire [7:0] jsm_prom_data;
  wire [6:0] jsm_usr_jtag,  jsm_usr_jtag_new,  jsm_usr_jtag_old;

  wire jsm_prom_clk;
  wire jsm_prom_oe;
  wire jsm_prom_nce;

  wire jsm_busy;
  wire jsm_jtag_oe;

  reg jen=0;                      // float jtag IOs until first vme write to this register
  always @(posedge clock_vme) jen <= wr_usr_jtag | jen;

  reg tdi_usr_mux;                  // Circumvents xst inability to reg an inout signal, hence the "_"
  reg  tms_usr_mux;
  reg tck_usr_mux;
  reg [3:0] sel_usr_mux;

  always @* begin
     if (jsm_busy && vsm_jtag_auto && jsm_jtag_oe) begin
	tdi_usr_mux      <= jsm_usr_jtag[0];
	tms_usr_mux      <= jsm_usr_jtag[1];
	tck_usr_mux      <= jsm_usr_jtag[2];
	sel_usr_mux[3:0] <= jsm_usr_jtag[6:3];
     end
     else begin
	tdi_usr_mux     <= usr_jtag_wr[0];
	tms_usr_mux     <= usr_jtag_wr[1];
	tck_usr_mux     <= usr_jtag_wr[2];
	sel_usr_mux[3:0] <= usr_jtag_wr[6:3];
     end
  end

// Circumvent xst inability to reg an inout signal
  wire jtag_tristate= (jsm_busy && vsm_jtag_auto && jsm_jtag_oe) || jen;

  assign tdi_usr      = (jtag_tristate) ? tdi_usr_mux : 1'bz;  
  assign tms_usr      = (jtag_tristate) ? tms_usr_mux : 1'bz;
  assign tck_usr      = (jtag_tristate) ? tck_usr_mux : 1'bz;
  assign sel_usr[3:0]    = (jtag_tristate) ? sel_usr_mux : 4'bzzzz;
  assign sel_fpga_chain  = (jtag_tristate) ? 1'b1 : (sel_usr_mux[3:0]==4'hC);

  assign usr_jtag_rd [0]= tdi_usr;          // Reads back levels asserted by U76 bus-hold
  assign usr_jtag_rd [1]= tms_usr;
  assign usr_jtag_rd [2]= tck_usr;
  assign usr_jtag_rd [3]= sel_usr[0];
  assign usr_jtag_rd [4]= sel_usr[1];
  assign usr_jtag_rd [5]= sel_usr[2];
  assign usr_jtag_rd [6]= sel_usr[3];

  assign usr_jtag_rd[13:7] = usr_jtag_wr[13:7];    // Readback
  assign usr_jtag_rd[14]   = wr_usr_jtag_dis;      // 1=writes to adr10 are blocked
  assign usr_jtag_rd[15]   = tdo_usr;          // N.B.  this is an input

//------------------------------------------------------------------------------------------------------------------
// ADR_PROM=12    PROM register
//          Data bus shared with on-board LEDs, select bus with led_bd_src register bit
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
     prom_wr[7:0]  = 8'hCD;    // PROM data shared with on-board LEDs
     prom_wr[8]    = 1'b0;      // PROM0 clock  
     prom_wr[9]    = 1'b0;      // PROM0 output enable
     prom_wr[10]    = 1'b1;      // PROM0 /chip_enable
     prom_wr[11]    = 1'b0;      // PROM1 clock
     prom_wr[12]    = 1'b0;      // PROM1 output enable
     prom_wr[13]    = 1'b1;      // PROM1 /chip_enable
     prom_wr[14]    = 1'b0;      // 0=on-board LED vector is PROM data souce
     prom_wr[15]    = 0;
  end

  reg  [7:0] prom_mux;
  reg  [7:0] led_bd_out;
  wire      led_bd_src;

  always @* begin    // Prom data mux
     if    (vsm_busy)    prom_mux <= led_bd_out;
     else if (jsm_busy)    prom_mux <= led_bd_out;
     else if (led_bd_src)   prom_mux <= prom_wr[7:0];
     else           prom_mux <= led_bd_out;
  end

  assign prom_led = (prom0_oe || prom1_oe  || !power_up2[1] || jsm_busy || vsm_busy) ? 8'hzz : prom_mux;  // Read prom a when prom_oe=1

  reg  prom0_clk;
  reg  prom0_oe;
  reg  _prom0_ce;
  reg  prom1_clk;
  reg  prom1_oe;
  reg  _prom1_ce;

  always @* begin
     if (vsm_busy) begin
	prom0_clk  <= vsm_prom_clk;
	prom0_oe  <= vsm_prom_oe;
	_prom0_ce  <= vsm_prom_nce;
	prom1_clk  <= 0;
	prom1_oe  <= 1;
	_prom1_ce  <= 1;
     end
     else if (jsm_busy) begin
	prom0_clk  <= 0;
	prom0_oe  <= 1;
	_prom0_ce  <= 1;
	prom1_clk  <= jsm_prom_clk;
	prom1_oe  <= jsm_prom_oe;
	_prom1_ce  <= jsm_prom_nce;
     end
     else begin
	prom0_clk  <= prom_wr[8];
	prom0_oe  <= prom_wr[9];
	_prom0_ce  <= (power_up) ? prom_wr[10] : 1'b1;
	prom1_clk  <= prom_wr[11];
	prom1_oe  <= prom_wr[12];
	_prom1_ce  <= (power_up) ? prom_wr[13] : 1'b1;
     end
  end

  assign led_bd_src= prom_wr[14];  // 0=prom data bus carries on-board LED data

  assign prom_rd[ 7:0]      = prom_led;
  assign prom_rd[15:8]      = prom_wr[15:8];
  assign jsm_prom_data[7:0] = prom_led[7:0];
  assign vsm_prom_data[7:0] = prom_led[7:0];

//------------------------------------------------------------------------------------------------------------------
// ADR_JTAGSM0=D4  JTAG State Machine Register
// ADR_JTAGSM1=D6  JTAG Word-count Bits [15:0]
// ADR_JTAGSM2=D8  JTAG Checksum
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
     jtagsm0_wr[0]    = 0;  // RW  Manual cycle start command
     jtagsm0_wr[1]    = 0;  // RW  Status signal reset
     jtagsm0_wr[2]    = 0;  // RW  1=select new JTAG format, 0=select old format
     jtagsm0_wr[10:3]  = 0;  // R  Readonly
     jtagsm0_wr[11]    = 0;  // RW  1=disable writes to adr_usr_jtag
     jtagsm0_wr[15:12]  = 0;  // RW  JTAG speed control, 0=fastest
  end

  wire [15:0]  jsm_wdcnt,    jsm_wdcnt_new,    jsm_wdcnt_old;
  wire [3:0]  jsm_throttle;
  wire [7:0]  jsm_cksum,    jsm_cksum_new,    jsm_cksum_old;
  wire [3:0]  tck_fpga_cnt,  tck_fpga_cnt_new,  tck_fpga_cnt_old;

  wire jsm_aborted;
  wire jsm_cksum_ok;
  wire jsm_wdcnt_ok;
  wire jsm_tckcnt_ok;
  wire jsm_tck_fpga_ok;
  wire jsm_ok;
  wire jsm_end_ok;
  wire jsm_header_ok;
  wire jsm_chain_ok;

  assign vsm_ready    = !vsm_busy_extend && vme_ready; // JGhere, THIS indicates that TMB VME registers loaded from PROM
  wire   vsm_ready_s6    = vsm_ready && alct_startup_done;
  wire   tck_fpga_gated  = tck_fpga  && !global_reset;  // Prevent ISE from trying to put 2 FFs into 1 IOB

  wire   jsm_start    = jtagsm0_wr[0];  // RW  Manual cycle start command
  wire   jsm_sreset    = jtagsm0_wr[1];  // RW  Status signal reset
  wire   jsm_sel      = jtagsm0_wr[2];  // RW  1=select new JTAG format, 0=select old format
  assign wr_usr_jtag_dis  = jtagsm0_wr[11];  // RW  1=disable writes to adr_usr_jtag
  assign jsm_throttle[3:0]= jtagsm0_wr[15:12];// RW  JTAG speed control, 0=fastest

  assign jtagsm0_rd[0]  = jsm_start;    // RW  Manual cycle start command
  assign jtagsm0_rd[1]  = jsm_sreset;    // RW  Status signal reset
  assign jtagsm0_rd[2]  = jsm_sel;      // RW  1=select new JTAG format, 0=select old format
  assign jtagsm0_rd[3]  = jsm_busy;      // R  State machine busy writing
  assign jtagsm0_rd[4]  = jsm_aborted;    // R  State machine aborted reading PROM
  assign jtagsm0_rd[5]  = jsm_cksum_ok;    // R  Check-sum  matches PROM contents
  assign jtagsm0_rd[6]  = jsm_wdcnt_ok;    // R  Word count matches PROM contents
  assign jtagsm0_rd[7]  = jsm_tck_fpga_ok;  // R  FPGA jtag tck detected
  assign jtagsm0_rd[8]  = vsm_ready;    // R  TMB VME registers loaded from PROM.  JGhere: was vme_ready, so now it's correct
  assign jtagsm0_rd[9]  = jsm_ok;      // R  JTAG state machine completed without errors
  assign jtagsm0_rd[10]  = jsm_jtag_oe;    // R  Enable jtag drivers else tri-state
  assign jtagsm0_rd[11]  = wr_usr_jtag_dis;  // RW  1=disable writes to adr_usr_jtag
  assign jtagsm0_rd[15:12]= jsm_throttle[3:0];// RW  JTAG speed control, 0=fastest

  assign jtagsm1_rd[15:0]  = jsm_wdcnt[15:0];  // R  jtag word-count bits [15:0]

  assign jtagsm2_rd[7:0]  = jsm_cksum[7:0];  // R  jtag checksum
  assign jtagsm2_rd[11:8]  = tck_fpga_cnt[3:0];// R  fpga jtag tck counter  
  assign jtagsm2_rd[12]  = jsm_tckcnt_ok;  // R  jsm_tckcnt_ok
  assign jtagsm2_rd[13]  = jsm_end_ok;    // R  prom end flag detected
  assign jtagsm2_rd[14]  = jsm_header_ok;  // R  Header marker found where expected
  assign jtagsm2_rd[15]  = jsm_chain_ok;    // R  Chain  marker found where expected


// JRG:  MEZ JTAG TCK counter to check when software sends TCKs to the JTAG input (will not catch hardware glitches via boot reg, etc)
   reg [15:0] tck_mez_cnt = 0;
   reg [1:0]  tck_mez_ff  = 0;

   always @(posedge clock) begin
      if (cnt_all_reset)  begin   //use  ttc_resync?
	 tck_mez_cnt <= 0;
	 tck_mez_ff  <= 0;
      end
      else
	if (tck_mez_cnt_en) tck_mez_cnt <= tck_mez_cnt+1'b1;
      if (sel_usr[3:2] == 2'h1) begin  // mez jtag bus is selected
	 tck_mez_ff[0]  <= jsm_usr_jtag_new[2]; // tck_mez;
	 tck_mez_ff[1]  <= tck_mez_ff[0];
      end
   end

   wire tck_mez_cnt_done = (tck_mez_cnt[15:10]==6'h3F);        // Stop counter at "FC" full scale so it won't wrap
   wire tck_mez_ticked   =  !tck_mez_ff[1]  &&  tck_mez_ff[0];    // tck transitioned 0-to-1
   wire tck_mez_cnt_en   =  tck_mez_ticked && !tck_mez_cnt_done;


//------------------------------------------------------------------------------------------------------------------
// New jtagsm uses compact ALCT User PROM data format
//------------------------------------------------------------------------------------------------------------------
  wire jsm_start_new    = jsm_start     && jsm_sel;
  wire jsm_autostart_new  = vsm_jtag_auto && jsm_sel;
  
  jtagsm_new ujtagsm_new
  (  
// Control
     .clock      (clock),            // In  40MHz clock
     .global_reset  (global_reset),          // In  Global reset
     .power_up    (power_up),            // In  DCM clock lock, we wait for it
     .vme_ready    (vsm_ready_s6),          // In  TMB VME registers loaded from PROM. JGhere, and alct fpga wait completed
     .start      (jsm_start_new),        // In  Cycle start command
     .autostart    (jsm_autostart_new),      // In  Enable automatic power-up
     .throttle    (jsm_throttle[3:0]),      // In  JTAG speed control, 0=fastest
// PROM
     .prom_data    (jsm_prom_data[7:0]),      // In  prom_data[7:0]
     .prom_clk    (jsm_prom_clk_new),        // Out  prom_ctrl[3]
     .prom_oe    (jsm_prom_oe_new),        // Out  prom_ctrl[4]
     .prom_nce    (jsm_prom_nce_new),        // Out  prom_ctrl[5]
//JTAG
     .jtag_oe    (jsm_jtag_oe_new),        // Out  Enable jtag drivers else tri-state
     .tdi      (jsm_usr_jtag_new[0]),      // Out  jtag_usr[1]
     .tms      (jsm_usr_jtag_new[1]),      // Out  jtag_usr[2]
     .tck      (jsm_usr_jtag_new[2]),      // Out  jtag_usr[3]
     .sel      (jsm_usr_jtag_new[6:3]),    // Out  sel_usr[3:0]
// Status
     .sreset      (jsm_sreset),          // In  Status signal reset
     .tck_fpga    (tck_fpga_gated),          // In  TCK from FPGA JTAG chain 
     .busy      (jsm_busy_new),          // Out  State machine busy writing
     .aborted    (jsm_aborted_new),        // Out  State machine abend signal
     .header_ok    (jsm_header_ok_new),      // Out  Header marker found where expected
     .chain_ok    (jsm_chain_ok_new),        // Out  Chain  marker found where expected
     .tckcnt_ok    (jsm_tckcnt_ok_new),      // Out  State machine sent correct number of TCKs to jtag
     .cksum_ok    (jsm_cksum_ok_new),        // Out  Check-sum  matches PROM contents
     .wdcnt_ok    (jsm_wdcnt_ok_new),        // Out  Word count matches PROM contents
     .tck_fpga_ok  (jsm_tck_fpga_ok_new),      // Out  FPGA jtag tck detected
     .end_ok      (jsm_end_ok_new),        // Out  End marker detected
     .jtagsm_ok    (jsm_ok_new),          // Out  JTAG state machine completed without errors
     .wdcnt      (jsm_wdcnt_new[15:0]),      // Out  Word count
     .cksum      (jsm_cksum_new[7:0]),      // Out  Check sum
     .tck_fpga_cnt  (tck_fpga_cnt_new[3:0]),    // Out  fpga jtag tck counter
     .prom_sm_vec  (jsm_prom_sm_vec_new[3:0]),    // Out  PROM control State Machine status vector
     .format_sm_vec  (jsm_format_sm_vec_new[2:0]),  // Out  Data format  State Machine status vector
     .jtag_sm_vec  (jsm_jtag_sm_vec_new[1:0])    // Out  JTAG signal  State Machine status vector
  );

//------------------------------------------------------------------------------------------------------------------
// Old jtagsm uses old ALCT User PROM data format
//------------------------------------------------------------------------------------------------------------------
  wire jsm_start_old    = jsm_start     && !jsm_sel;
  wire jsm_autostart_old  = vsm_jtag_auto && !jsm_sel;

  jtagsm_old ujtagsm_old
  (  
// Control
     .clock      (clock),            // In  40MHz clock
     .global_reset  (global_reset),          // In  Global reset
     .power_up    (power_up),            // In  DCM clock lock, we wait for it
     .vme_ready    (vsm_ready_s6),          // In  TMB VME registers loaded from PROM. JGhere, and alct fpga wait completed
     .start      (jsm_start_old),        // In  Cycle start command
     .autostart    (jsm_autostart_old),      // In  Enable automatic power-up
     .throttle    (jsm_throttle[3:0]),      // In  JTAG speed control, 0=fastest
// PROM
     .prom_data    (jsm_prom_data[7:0]),      // In  prom_data[7:0]
     .prom_clk    (jsm_prom_clk_old),        // Out  prom_ctrl[3]
     .prom_oe    (jsm_prom_oe_old),        // Out  prom_ctrl[4]
     .prom_nce    (jsm_prom_nce_old),        // Out  prom_ctrl[5]
//JTAG
     .jtag_oe    (jsm_jtag_oe_old),        // Out  Enable jtag drivers else tri-state
     .tdi      (jsm_usr_jtag_old[0]),      // Out  jtag_usr[1]
     .tms      (jsm_usr_jtag_old[1]),      // Out  jtag_usr[2]
     .tck      (jsm_usr_jtag_old[2]),      // Out  jtag_usr[3]
     .sel      (jsm_usr_jtag_old[6:3]),    // Out  sel_usr[3:0]
// Status
     .sreset      (jsm_sreset),          // In  Status signal reset
     .tck_fpga    (tck_fpga_gated),        // In  TCK from FPGA JTAG chain 
     .busy      (jsm_busy_old),          // Out  State machine busy writing
     .aborted    (jsm_aborted_old),        // Out  State machine abend signal
     .header_ok    (jsm_header_ok_old),      // Out  Header marker found where expected
     .chain_ok    (jsm_chain_ok_old),        // Out  Chain  marker found where expected
     .tckcnt_ok    (jsm_tckcnt_ok_old),      // Out  State machine sent correct number of TCKs to jtag
     .cksum_ok    (jsm_cksum_ok_old),        // Out  Check-sum  matches PROM contents
     .wdcnt_ok    (jsm_wdcnt_ok_old),        // Out  Word count matches PROM contents
     .tck_fpga_ok  (jsm_tck_fpga_ok_old),      // Out  FPGA jtag tck detected
     .end_ok      (jsm_end_ok_old),        // Out  End marker detected
     .jtagsm_ok    (jsm_ok_old),          // Out  JTAG state machine completed without errors
     .wdcnt      (jsm_wdcnt_old[15:0]),      // Out  Word count
     .cksum      (jsm_cksum_old[7:0]),      // Out  Check sum
     .tck_fpga_cnt  (tck_fpga_cnt_old[3:0]),    // Out  fpga jtag tck counter
     .prom_sm_vec  (jsm_prom_sm_vec_old[3:0]),    // Out  PROM control State Machine status vector
     .format_sm_vec  (jsm_format_sm_vec_old[2:0]),  // Out  Data format  State Machine status vector
     .jtag_sm_vec  (jsm_jtag_sm_vec_old[1:0])    // Out  JTAG signal  State Machine status vector
  );

// JTAGsm PROM signal multiplexer
  assign jsm_prom_clk       = (jsm_sel) ? jsm_prom_clk_new        : jsm_prom_clk_old;        // prom_ctrl[3]
  assign jsm_prom_oe       = (jsm_sel) ? jsm_prom_oe_new        : jsm_prom_oe_old;        // prom_ctrl[4]
  assign jsm_prom_nce       = (jsm_sel) ? jsm_prom_nce_new        : jsm_prom_nce_old;        // prom_ctrl[5]

  assign jsm_jtag_oe       = (jsm_sel) ? jsm_jtag_oe_new        : jsm_jtag_oe_old;        // Enable jtag drivers else tri-state
  assign jsm_usr_jtag[6:0]   = (jsm_sel) ? jsm_usr_jtag_new[6:0]    : jsm_usr_jtag_old[6:0];    // jtag_usr[1]

// JTAGsm status multiplexer
  assign jsm_busy         = (jsm_sel) ? jsm_busy_new          : jsm_busy_old;          // State machine busy writing
  assign jsm_aborted       = (jsm_sel) ? jsm_aborted_new        : jsm_aborted_old;        // State machine abend signal
  assign jsm_header_ok     = (jsm_sel) ? jsm_header_ok_new      : jsm_header_ok_old;      // Header marker found where expected
  assign jsm_chain_ok       = (jsm_sel) ? jsm_chain_ok_new        : jsm_chain_ok_old;        // Chain  marker found where expected
  assign jsm_tckcnt_ok     = (jsm_sel) ? jsm_tckcnt_ok_new      : jsm_tckcnt_ok_old;      // State machine sent correct number of TCKs to jtag
  assign jsm_cksum_ok       = (jsm_sel) ? jsm_cksum_ok_new        : jsm_cksum_ok_old;        // Check-sum  matches PROM contents
  assign jsm_wdcnt_ok       = (jsm_sel) ? jsm_wdcnt_ok_new        : jsm_wdcnt_ok_old;        // Word count matches PROM contents
  assign jsm_tck_fpga_ok     = (jsm_sel) ? jsm_tck_fpga_ok_new      : jsm_tck_fpga_ok_old;      // FPGA jtag tck detected
  assign jsm_end_ok       = (jsm_sel) ? jsm_end_ok_new        : jsm_end_ok_old;        // End marker detected
  assign jsm_ok         = (jsm_sel) ? jsm_ok_new          : jsm_ok_old;          // JTAG state machine completed without errors
  assign jsm_wdcnt[15:0]     = (jsm_sel) ? jsm_wdcnt_new[15:0]      : jsm_wdcnt_old[15:0];      // Word count
  assign jsm_cksum[7:0]     = (jsm_sel) ? jsm_cksum_new[7:0]      : jsm_cksum_old[7:0];      // Check sum
  assign tck_fpga_cnt[3:0]   = (jsm_sel) ? tck_fpga_cnt_new[3:0]    : tck_fpga_cnt_old[3:0];    // fpga jtag tck counter
  assign jsm_prom_sm_vec[3:0]   = (jsm_sel) ? jsm_prom_sm_vec_new[3:0]    : jsm_prom_sm_vec_old[3:0];    // PROM control State Machine status vector
  assign jsm_format_sm_vec[2:0]= (jsm_sel) ? jsm_format_sm_vec_new[2:0]  : jsm_format_sm_vec_old[2:0];  // Data format  State Machine status vector
  assign jsm_jtag_sm_vec[1:0]   = (jsm_sel) ? jsm_jtag_sm_vec_new[1:0]    : jsm_jtag_sm_vec_old[1:0];    // JTAG signal  State Machine status vector

//------------------------------------------------------------------------------------------------------------------
// ADR_DDDSM=14    DDD 3D3444 State Machine Control and FPGA DCM Status
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
     dddsm_wr[0]        = 0;          // Start  ddd state machine
     dddsm_wr[1]        = 0;          // Manual ddd_clock
     dddsm_wr[2]        = 1;          // Manual ddd_adr_latch, active low
     dddsm_wr[3]        = 0;          // Manual ddd_serial_in (out from fpga to ddd)
     dddsm_wr[4]        = 0;          // Readonly
     dddsm_wr[5]        = 1;          // Auto start
     dddsm_wr[15:6]      = 0;          // Readonly
  end

  wire   ddd_clock_sm;
  wire   ddd_adr_latch_sm; 
  wire   ddd_serial_in_sm;
  wire   ddd_busy;
  wire   ddd_verify_ok;  

  wire   ddd_start_vme  = dddsm_wr[0];      // Start  ddd state machine
  wire   ddd_clock_vme  = dddsm_wr[1];      // Manual ddd_clock
  wire   ddd_adr_latch_vme= dddsm_wr[2];      // Manual ddd_adr_latch
  wire   ddd_serial_in_vme= dddsm_wr[3];      // Manual ddd_serial_in (out from fpga to ddd)
  wire   ddd_autostart  = dddsm_wr[5];      // Auto start

  assign dddsm_rd[0]    = ddd_start_vme;    // Start  ddd state machine
  assign dddsm_rd[1]    = ddd_clock;      // Clock to 3d3444 
  assign dddsm_rd[2]    = ddd_adr_latch;    // Adr_latch to 3d3444 
  assign dddsm_rd[3]    = ddd_serial_in;    // Serial data in to 3d3444
  assign dddsm_rd[4]    = ddd_serial_out;    // Serial data out from 3d3444
  assign dddsm_rd[5]    = ddd_autostart;    // Auto start state
  assign dddsm_rd[6]    = ddd_busy;        // State machine busy writing
  assign dddsm_rd[7]    = ddd_verify_ok;    // Data readback verified OK

  assign dddsm_rd[8]    = lock_tmb_clock0;    // tmb clock0  lock status
  assign dddsm_rd[9]    = lock_tmb_clock0d;    // tmb clock0d  lock status
  assign dddsm_rd[10]    = lock_tmb_clock1;    // tmb clock1  lock status
  assign dddsm_rd[11]    = lock_alct_rxclock;  // alct clock  lock status
  assign dddsm_rd[12]    = lock_alct_rxclockd;  // alct clockd  lock status
  assign dddsm_rd[13]    = lock_mpc_clock;    // mpc clock  lock status
  assign dddsm_rd[14]    = lock_dcc_clock;    // dcc clock  lock status
  assign dddsm_rd[15]    = lock_rpc_rxalt1;    // rpc rxalt1  lock status

// DDD 3D3444 multiplexer: OR state machine signals with manual VME control
  assign ddd_clock    = ddd_clock_vme   || ddd_clock_sm;
  assign ddd_adr_latch  = ddd_adr_latch_vme  && ddd_adr_latch_sm;   // latches active low
  assign ddd_serial_in  = ddd_serial_in_vme  || ddd_serial_in_sm;

//------------------------------------------------------------------------------------------------------------------
// ADR_DDD0 =16    3D3444 chip 0 Delay Register
// ADR_DDD1 =18    3D3444 chip 1 Delay Register
// ADR_DDD2 =1A    3D3444 chip 2 Delay Register
// ADR_DDDOE=1C    3D3444 Channel Enables Register
//------------------------------------------------------------------------------------------------------------------
// 3D3444 Power-up Default Delays, 2ns steps
  initial begin
     dddoe_wr[15:0]  = 16'h0FFF;      // Output enable, 0FFF=enable all

     ddd0_wr[3:0]  = 4'd0;        // Ch 0:  ALCT  tof clock ALCT time of flight offset  9m=17ns, 10m= 5ns, add 12ns/meter,modulo25
     ddd0_wr[7:4]  = 4'd01;      // Ch 1:  ALCT  txd clock ALCT transmit delay      9m= 3ns, 10m=15ns, add 12ns/meter,modulo25
     ddd0_wr[11:8]  = 4'd06;      // Ch 2:  DMB   tx  clock from CERN timing tests 6/2009
     ddd0_wr[15:12]  = 4'd09;      // Ch 3:  RPC   tx  clock

     ddd1_wr[3:0]  = 4'd00;      // Ch 4:  ALCT  rxd clock ALCT receive delay (was tmb1 clock)
     ddd1_wr[7:4]  = 4'd00;      // Ch 5:  CFEB  rxd clock CFEB receive delay (was mpc)
     ddd1_wr[11:8]  = 4'd00;      // Ch 6:  CFEB  tof clock (was dcc)
     ddd1_wr[15:12]  = 4'd07;      // Ch 7:  CFEB0 rx  clock 15ns nom

     ddd2_wr[3:0]  = 4'd07;      // Ch 8:  CFEB1 rx  clock
     ddd2_wr[7:4]  = 4'd07;      // Ch 9:  CFEB2 rx  clock
     ddd2_wr[11:8]  = 4'd07;      // Ch10:  CFEB3 rx  clock
     ddd2_wr[15:12]  = 4'd07;      // Ch11:  CFEB4 rx  clock
  end

  assign ddd0_rd[15:0]   = ddd0_wr[15:0];
  assign ddd1_rd[15:0]   = ddd1_wr[15:0];
  assign ddd2_rd[15:0]   = ddd2_wr[15:0];
  assign dddoe_rd[15:0]  = dddoe_wr[15:0];

// TMB DDD 3D3444 delay chip bank automatic power-up initialization
  ddd_tmb uddd_tmb
  (  
     .clock      (clock),      // In  Delay chip data clock
     .global_reset  (global_reset),    // In  Global reset
     .power_up    (power_up),      // In  DCM clock lock, we wait for it
     .vme_ready    (vsm_ready_s6),    // In  VME registers loaded from prom. JGhere, and alct fpga wait completed
     .start      (ddd_start_vme),  // In  Cycle start command
     .autostart_en  (ddd_autostart),  // In  Enable automatic power-up
     .oe        (dddoe_wr[11:0]),   // In  Output enables 12'hFFF=enable al

     .delay_ch0    (ddd0_wr[3:0]),    // In  Channel  0 delay steps
     .delay_ch1    (ddd0_wr[7:4]),    // In  Channel  1 delay steps
     .delay_ch2    (ddd0_wr[11:8]),  // In  Channel  2 delay steps
     .delay_ch3    (ddd0_wr[15:12]),  // In  Channel  3 delay steps

     .delay_ch4    (ddd1_wr[3:0]),    // In  Channel  4 delay steps
     .delay_ch5    (ddd1_wr[7:4]),    // In  Channel  5 delay steps
     .delay_ch6    (ddd1_wr[11:8]),  // In  Channel  6 delay steps
     .delay_ch7    (ddd1_wr[15:12]),  // In  Channel  7 delay steps

     .delay_ch8    (ddd2_wr[3:0]),    // In  Channel  8 delay steps
     .delay_ch9    (ddd2_wr[7:4]),    // In  Channel  9 delay steps
     .delay_ch10    (ddd2_wr[11:8]),  // In  Channel 10 delay steps
     .delay_ch11    (ddd2_wr[15:12]),  // In  Channel 11 delay steps

     .serial_clock  (ddd_clock_sm),    // Out  3D3444 clock
     .serial_out    (ddd_serial_in_sm),  // Out  3D3444 data
     .adr_latch    (ddd_adr_latch_sm),  // Out  3D3444 adr strobe
     .serial_in    (ddd_serial_out),  // In  3D3444 verify

     .busy      (ddd_busy),      // Out  State machine busy writing
     .verify_ok    (ddd_verify_ok)    // Out  Data readback verified OK
  );

//------------------------------------------------------------------------------------------------------------------
// ADR_RATCTRL=1E  RAT Control Register
//------------------------------------------------------------------------------------------------------------------
// RAT Control power-up defaults
  initial begin
     rat_control_wr[0]      = 0;          // RW  rpc_sync
     rat_control_wr[1]      = 0;          // RW  rpc_posneg
     rat_control_wr[2]      = 0;          // RW  rpc_lptmb,    unused
     rat_control_wr[3]      = 0;          // RW  rpc_free_tx0
     rat_control_wr[4]      = 1;          // RW  rpc_dsn_en,   unused
     rat_control_wr[5]      = 0;          // RW  rat_clk_mode, unused
     rat_control_wr[15:6]    = 0;          //    Unassigned
  end

  assign rpc_sync        = rat_control_wr[0];  // RW  Sync mode
  assign rpc_posneg      = rat_control_wr[1];  // RW  Clock phase
  wire   rpc_lptmb      = rat_control_wr[2];  // RW  Unused
  assign rpc_free_tx0      = rat_control_wr[3];  // RW  Unassigned
  assign rat_dsn_en      = rat_control_wr[4];  // RW  Enable RAT dsn
  assign rat_control_rd[15:0]  = rat_control_wr[15:0];  //    Readback

//------------------------------------------------------------------------------------------------------------------
// ADR_DDDRSM=E4  RAT 3D3444 State Machine Register
//------------------------------------------------------------------------------------------------------------------
// RAT DDD 3D3444 State Machine defaults
  initial begin
     dddrsm_wr[0]    = 0;      // Start  ddd state machine
     dddrsm_wr[1]    = 0;      // Manual ddd_clock
     dddrsm_wr[2]    = 1;      // Manual ddd_adr_latch, active low
     dddrsm_wr[3]    = 0;      // Manual ddd_serial_in (out from fpga to ddd)
     dddrsm_wr[4]    = 0;      // Serial data from 3d3444
     dddrsm_wr[5]    = 1;      // Auto start
     dddrsm_wr[7:6]    = 0;      // Readonly
     dddrsm_wr[11:8]    = 4'b0011;    // dddr_oe[3:0] output enables
     dddrsm_wr[12]    = 1;      // 1=start RAT machine when starting TMB machine
     dddrsm_wr[13]    = 1;      // 1=use negative clock edge to latch verify data, 0=posedge
     dddrsm_wr[15:14]  = 3;      // Delay before latching verify data
  end

// RAT DDD 3D3444 State Machine Control
  wire dddr_linktmb;
  wire dddr_clock;
  wire dddr_adr_latch; 
  wire dddr_serial_in;
  wire dddr_busy;
  wire dddr_verify_ok;
  wire dddr_serial_out;

  wire [3:0]  dddr_oe;
  wire [1:0]  dddr_verify_dly;

  wire   dddr_start_vme   = dddrsm_wr[0];    // Start  ddd state machine
  wire   dddr_clock_vme   = dddrsm_wr[1];    // Manual ddd_clock
  wire   dddr_adr_latch_vme= dddrsm_wr[2];    // Manual ddd_adr_latch
  wire   dddr_serial_in_vme= dddrsm_wr[3];    // Manual ddd_serial_in (out from fpga to ddd)
  wire   dddr_autostart   = dddrsm_wr[5];    // Auto start
  assign dddr_oe[3:0]     = dddrsm_wr[11:8];    // dddr_oe[3:0] output enables
  assign dddr_linktmb     = dddrsm_wr[12];    // 1=start RAT machine when starting TMB machine
  wire   dddr_rxphase     = dddrsm_wr[13];    // 1=use negative clock edge to latch verify data, 0=posedge
  assign dddr_verify_dly[1:0]=dddrsm_wr[15:14];  // Delay before latching verify data

  assign dddrsm_rd[0]    = dddr_start_vme;    // RW  Start  ddd state machine
  assign dddrsm_rd[1]    = dddr_clock;      // RW  Clock to 3d3444 
  assign dddrsm_rd[2]    = dddr_adr_latch;    // RW  Adr_latch to 3d3444 
  assign dddrsm_rd[3]    = dddr_serial_in;    // RW  Serial data in goes to 3d3444
  assign dddrsm_rd[4]    = dddr_serial_out;    // R  Serial data out comes from 3d3444
  assign dddrsm_rd[5]    = dddr_autostart;    // RW  Auto start state
  assign dddrsm_rd[6]    = dddr_busy;      // R  State machine busy writing
  assign dddrsm_rd[7]    = dddr_verify_ok;    // R  Data readback verified OK
  assign dddrsm_rd[11:8]  = dddr_oe[3:0];      // RW  Output enables
  assign dddrsm_rd[12]  = dddr_linktmb;      // RW  1=start RAT machine when starting TMB machine
  assign dddrsm_rd[13]  = dddr_rxphase;      // RW  1=use negative clock edge to latch verify data, 0=posedge
  assign dddrsm_rd[15:14]  = dddr_verify_dly[1:0];  // RW  Delay before latching verify data

// Latch both edges of serial verify data from RAT 3D3444
  initial $display ("vme: instantiating Virtex6 IDDR");

  IDDR #(
  .DDR_CLK_EDGE  ("SAME_EDGE_PIPELINED"),// "OPPOSITE_EDGE", "SAME_EDGE" or "SAME_EDGE_PIPELINED" 
  .INIT_Q1    (1'b0),          // Initial value of Q1: 1'b0 or 1'b1
  .INIT_Q2    (1'b0),          // Initial value of Q2: 1'b0 or 1'b1
  .SRTYPE      ("SYNC")        // Set/Reset type: "SYNC" or "ASYNC" 
  ) dddrin (
  .C  (clock),              // 1-bit clock input
  .CE  (1'b1),                // 1-bit clock enable input
  .R  (1'b0),                // 1-bit reset
  .S  (1'b0),                // 1-bit set
  .D  (rpc_dsn),              // 1-bit DDR data input
  .Q1  (dddr_sdo0),            // 1-bit output for positive edge of clock 
  .Q2  (dddr_sdo1));            // 1-bit output for negative edge of clock

  reg dddr_sdo0_ff = 0;
  reg dddr_sdo1_ff = 0;
  
  always @(posedge clock) begin  // Sync to local clock
     dddr_sdo0_ff <= dddr_sdo0;
     dddr_sdo1_ff <= dddr_sdo1;  
  end

  assign dddr_serial_out  = (dddr_rxphase) ? dddr_sdo1_ff : dddr_sdo0_ff;
  wire rpc_dsn_ff = dddr_sdo0;

// RAT DDD 3D3444 multiplexer: OR state machine signals with manual VME control
  wire dddr_clock_sm;
  wire dddr_adr_latch_sm; 
  wire dddr_serial_in_sm;
  wire dddr_start;

  assign dddr_start    = dddr_start_vme    || (ddd_start_vme && dddr_linktmb);  // starts rat with tmb
  assign dddr_clock    = dddr_clock_vme     || dddr_clock_sm;
  assign dddr_adr_latch  = dddr_adr_latch_vme  && dddr_adr_latch_sm;          // latches active low
  assign dddr_serial_in  = dddr_serial_in_vme  || dddr_serial_in_sm;

//------------------------------------------------------------------------------------------------------------------
// ADR_DDDR0=E6    RAT 3D3444 chip 0 Register
//------------------------------------------------------------------------------------------------------------------
// RAT DDD 3D3444 State Machine defaults// RAT DDD 3D3444 Delay Register
  initial begin
     dddr_wr[3:0]  = 4'h3;  // default 3
     dddr_wr[7:4]  = 4'h3;  // default 3
     dddr_wr[11:8]  = 4'h0;
     dddr_wr[15:12]  = 4'h0;
  end

  assign dddr_rd[15:0] = dddr_wr[15:0];

// RAT DDD 3D3444 delay chip programming
  ddd_rat uddd_rat
  (
   .clock      (clock),        // In  Delay chip data clock
   .global_reset  (global_reset),      // In  Global reset
   .power_up    (power_up),        // In  DCM clock lock, we wait for it
   .vme_ready    (vsm_ready),      // In  VME registers loaded
   .start      (dddr_start),      // In  Cycle start command
   .autostart_en  (dddr_autostart),    // In  Enable automatic power-up
   .oe        (dddr_oe[3:0]),     // In  Output enables 4'hF=enable all
   .verify_dly    (dddr_verify_dly[1:0]),  // In  Delay before latching verify data
   .delay_ch0    (dddr_wr[3:0]),      // In  Channel  0 delay steps
   .delay_ch1    (dddr_wr[7:4]),      // In  Channel  0 delay steps
   .delay_ch2    (dddr_wr[11:8]),    // In  Channel  0 delay steps
   .delay_ch3    (dddr_wr[15:12]),    // In  Channel  0 delay steps
   .serial_clock  (dddr_clock_sm),    // Out  3D3444 clock
   .serial_out    (dddr_serial_in_sm),  // Out  3D3444 data
   .adr_latch    (dddr_adr_latch_sm),  // Out  3D3444 adr strobe
   .serial_in    (dddr_serial_out),    // In  3D3444 verify
   .busy      (dddr_busy),      // Out  State machine busy writing
   .verify_ok    (dddr_verify_ok)    // Out  Data readback verified OK
  );

//------------------------------------------------------------------------------------------------------------------
// ADR_STEP=20    Step Register
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin  // synthesis attribute IOB of step_wr is "false";
     step_wr[ 0]    = 1'b0;      // Step ALCT clock
     step_wr[ 1]    = 1'b0;      // Step DMB clock
     step_wr[ 2]    = 1'b0;      // Step RPC clock
     step_wr[ 3]    = 1'b0;      // Step CFEB clock
     step_wr[ 4]    = 1'b0;      // 0= Run, 1=Step clocks
     step_wr[ 5]    = 1'b1;      // 1=Enable CFEB0 Clock
     step_wr[ 6]    = 1'b1;      // 1=Enable CFEB1 Clock
     step_wr[ 7]    = 1'b1;      // 1=Enable CFEB2 Clock
     step_wr[ 8]    = 1'b1;      // 1=Enable CFEB3 Clock
     step_wr[ 9]    = 1'b1;      // 1=Enable CFEB4 Clock    IOB clock contention with alct_txa[17]
     step_wr[10]    = 1'b1;      // 1=Enable ALCT Clocks    IOB clock contention with alct_txb[19]
     step_wr[11]    = 1'b1;      // 1=Disable ALCT Hard Reset
     step_wr[12]    = 1'b1;      // 1=Disable TMB  Hard Reset
     step_wr[15:13]  = 0;
  end

  assign step_alct           = step_wr[0]; 
  assign step_dmb             = step_wr[1];
  assign step_rpc             = step_wr[2];
  assign step_cfeb           = step_wr[3];
  assign step_run             = step_wr[4];
  assign cfeb_clock_en[4:0]    = step_wr[9:5];
  assign alct_clock_en         = step_wr[10];
  assign _hard_reset_alct_fpga = step_wr[11];
  assign _hard_reset_tmb_fpga  = step_wr[12];

  assign step_rd[15:0]         = step_wr[15:0];

//------------------------------------------------------------------------------------------------------------------
// ADR_LED=22  Front Panel + On-Board LED Register
//        On-board LEDs shared with PROM data bus
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
     led_wr[ 7:0] = 8'hAB;                // Front panel LEDs
     led_wr[15:8] = 8'hCD;                // On-board LEDs shared with PROM data bus
  end

// LED Signals
  wire [7:0]  led_fp_in;
  reg   [7:0]  led_fp_out;
  wire    led_fp_src_vme;
  wire    led_bd_src_vme;
  wire    led_fp_cylon;
  wire    led_bd_cylon;

// Cylon pattern generators
  wire [7:0] cylon_one;
  wire [7:0] cylon_two;
  wire [1:0] led_flash_rate=0;

  cylon1 ucylon1 (clock,led_flash_rate,cylon_one);  // One cylon eye  for power-up
  cylon2 ucylon2 (clock,led_flash_rate,cylon_two);  // Two cylon eyes for trigger-stop

// LED Front Panel Cylon mode at power up
  parameter MXCYLON = 26;
  reg  [MXCYLON-1:0] cylon_cnt = 0;
  reg               pup_cylon = 0;

  wire cylon_cnt_done = cylon_cnt[MXCYLON-1];

  always @(posedge clock) begin
     if (!cylon_cnt_done) cylon_cnt <= cylon_cnt+1'b1;
  end

  always @(posedge clock) begin
     pup_cylon <= pup_cylon || cylon_cnt_done;
  end

// LED display Register
  always @* begin
     if    (led_fp_src_vme)  led_fp_out <= led_wr[7:0];  // VME sources LED pattern
     else if  (led_fp_cylon)    led_fp_out <= cylon_one;  // cylon pattern from cfg
     else if (!pup_cylon)    led_fp_out <= cylon_one;  // cylon pattern at power up
     else            led_fp_out <= led_fp_in;  // normal mode
  end

  always @* begin
     if    (led_bd_src_vme)  led_bd_out <= led_wr[15:8];  // VME sources LED pattern
     else if  (led_bd_cylon)    led_bd_out <= cylon_one;  // cylon pattern
     else if (!pup_cylon)    led_bd_out <= cylon_one;  // cylon pattern at power up
     else            led_bd_out <= led_bd_in;  // normal mode
  end

  assign led_rd[ 7:0] = led_fp_out;
  assign led_rd[15:8] = led_bd_out;

// LED VME access to this module
  reg bd_acc_ff=0;

  always @(posedge clock_vme) begin
     bd_acc_ff <= bd_accessed & ds0;
  end

  x_flashsm #(21) uflash_vme (bd_acc_ff,1'b0,clock,led_fp_vme);

// LED Front Panel signals
  wire led_flash_on_stop;

  wire led_flash = led_flash_on_stop && fmm_trig_stop;
  wire led_fp_nl1a_mux = (buf_stalled) ? cylon_two[0] : led_fp_nl1a;    // Flash NL1A if buffers full

  assign led_fp_in[0] = (led_flash) ? cylon_two [0] : led_fp_lct;      // LCT  Blue
  assign led_fp_in[1] = (led_flash) ? cylon_two [1] : led_fp_alct;    // ALCT  Green
  assign led_fp_in[2] = (led_flash) ? cylon_two [2] : led_fp_clct;    // CLCT  Green
  assign led_fp_in[3] = (led_flash) ? cylon_two [3] : led_fp_l1a;      // L1A  Green
  assign led_fp_in[4] = (led_flash) ? cylon_two [4] : led_fp_invp;    // INVP  Amber
  assign led_fp_in[5] = (led_flash) ? cylon_two [5] : led_fp_nmat;    // NMAT  Amber
  assign led_fp_in[6] = (led_flash) ? cylon_two [6] : led_fp_nl1a_mux;  // NL1A  Red
  assign led_fp_in[7] = !led_fp_vme;                    // VME  Green

//------------------------------------------------------------------------------------------------------------------
// ADR_ADC=24    ADC Register
//          Status: Power Supply Comparator, Power Supply ADC, Temperature ADC
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
     adc_wr[5:0]      = 0;      // Readonly
     adc_wr[6]      = 1'b0;      // VADC serial clock
     adc_wr[7]      = 1'b0;      // VADC serial data
     adc_wr[8]      = 1'b1;      // VADC /chip select
     adc_wr[9]      = 1'b0;      // TADC serial clock
     adc_wr[10]      = 1'b1;      // TADC serial data
     adc_wr[11]      = 1'b0;      // TADC serial data from RAT
     adc_wr[15:12]    = 0;
  end

  wire smb_data_in;
  wire smb_data_out;
  
  assign adc_sclock  = adc_wr[6];
  assign adc_din    = adc_wr[7];
  assign _adc_cs    = adc_wr[8];
  assign smb_clk    = adc_wr[9];

  assign smb_data_out  = adc_wr[10];
  assign smb_data    = (smb_data_out)? 1'bz : smb_data_out;    // Open Drain SMB_data out, t enables on low
  assign smb_data_in  = smb_data;                  // SMB_data bidir input

  assign adc_rd[0]  = vstat_5p0v;  // Readonly
  assign adc_rd[1]  = vstat_3p3v;  // Readonly
  assign adc_rd[2]  = vstat_1p8v;  // Readonly
  assign adc_rd[3]  = vstat_1p5v;  // Readonly
  assign adc_rd[4]  = _t_crit;    // Readonly
  assign adc_rd[5]  = adc_dout;    // Readonly
  assign adc_rd[6]  = adc_sclock;  // Write/Read
  assign adc_rd[7]  = adc_din;    // Write/Read
  assign adc_rd[8]  = _adc_cs;    // Write/Read
  assign adc_rd[9]  = smb_clk;    // Write/Read
  assign adc_rd[10]  = smb_data_in;  // Write/Read
  assign adc_rd[11]  = smb_data_rat;  // Readonly smb_data from RAT
  assign adc_rd[12]  = adc_wr[12];  // Unused
  assign adc_rd[13]  = adc_wr[13];  // Unused
  assign adc_rd[14]  = adc_wr[14];  // Unused
  assign adc_rd[15]  = adc_wr[15];  // Unused

//------------------------------------------------------------------------------------------------------------------
//  ADR_DSN=26    Digital Serial Number Register
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
     dsn_wr[0]      = 1'b0;    // TMB Digital Serial SM Start
     dsn_wr[1]      = 1'b0;    // TMB Digital Serial Write Pulse
     dsn_wr[2]      = 1'b0;    // TMB Digital Serial Init Pulse
     dsn_wr[4:3]      = 0;
     dsn_wr[5]      = 1'b0;    // MEZ Digital Serial SM Start
     dsn_wr[6]      = 1'b0;    // MEZ Digital Serial Write Pulse
     dsn_wr[7]      = 1'b0;    // MEZ Digital Serial Init Pulse
     dsn_wr[9:8]      = 0;
     dsn_wr[10]      = 1'b0;    // RAT Digital Serial SM Start
     dsn_wr[11]      = 1'b0;    // RAT Digital Serial Write Pulse
     dsn_wr[12]      = 1'b0;    // RAT Digital Serial Init Pulse
     dsn_wr[15:13]    = 0;
  end

  wire tmb_sn_start  =  dsn_wr[0];
  wire tmb_sn_write  =  dsn_wr[1];
  wire tmb_sn_init  =  dsn_wr[2];

  wire mez_sn_start  =  dsn_wr[5];
  wire mez_sn_write  =  dsn_wr[6];
  wire mez_sn_init  =  dsn_wr[7];

  wire rat_sn_start  =  dsn_wr[10];
  wire rat_sn_write  =  dsn_wr[11];
  wire rat_sn_init  =  dsn_wr[12];

// Bidirectional DSN IO pin
  dsn_tmb udsn_tmb (
  .clock      (clock),      // In  Clock
  .global_reset  (global_reset),    // In  Global reset
  .start      (tmb_sn_start),    // In  Begin counting
  .dsn_io      (tmb_sn),      // IO  DSN chip I/O pin
  .wr_data    (tmb_sn_write),    // In  DSN data bit to output
  .wr_init    (tmb_sn_init),    // In  DSN init mode
  .busy      (tmb_sn_busy),    // Out  DSN chip is busy
  .rd_data    (tmb_sn_data));    // Out  DSN data read from chip

  dsn_tmb udsn_mez (
  .clock      (clock),      // In  Clock
  .global_reset  (global_reset),    // In  Global reset
  .start      (mez_sn_start),    // In  Begin counting
  .dsn_io      (mez_sn),      // IO  DSN chip I/O pin
  .wr_data    (mez_sn_write),    // In  DSN data bit to output
  .wr_init    (mez_sn_init),    // In  DSN init mode
  .busy      (mez_sn_busy),    // Out  DSN chip is busy
  .rd_data    (mez_sn_data));    // Out  DSN data read from chip

// Unidirectional DSN IO pins
  dsn_rat udsn_rat (
  .clock      (clock),      // In  Clock
  .global_reset  (global_reset),    // In  Global reset
  .start      (rat_sn_start),    // In  Begin counting
  .dsn_in      (rpc_dsn_ff),    // In  Non-bidir input  for RAT
  .dsn_out    (rat_sn_out),    // Out  Non-bidir output for RAT
  .wr_data    (rat_sn_write),    // In  DSN data bit to output
  .wr_init    (rat_sn_init),    // In  DSN init mode
  .busy      (rat_sn_busy),    // Out  DSN chip is busy
  .rd_data    (rat_sn_data));    // Out  DSN data read from chip

  assign dsn_rd[2:0]  =  dsn_wr[2:0];
  assign dsn_rd[3]  =  tmb_sn_busy;
  assign dsn_rd[4]  =  tmb_sn_data;

  assign dsn_rd[7:5]  =  dsn_wr[7:5];
  assign dsn_rd[8]  =  mez_sn_busy;
  assign dsn_rd[9]  =  mez_sn_data;

  assign dsn_rd[12:10]=  dsn_wr[12:10];
  assign dsn_rd[13]  =  rat_sn_busy;
  assign dsn_rd[14]  =  rat_sn_data;
  assign dsn_rd[15]  =  dsn_wr[15];

//------------------------------------------------------------------------------------------------------------------
//  ADR_MOD_CFG=28    TMB Module Configuration Register
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
     mod_cfg_wr[0]    = 0;    // 1=Front Panel LEDs sourced from VME register
     mod_cfg_wr[1]    = 0;    // 1=FP LED Cylon mode, cool
     mod_cfg_wr[2]    = 1;    // 1=Flash in trigger_stop mode
     mod_cfg_wr[3]    = 0;    // 1=On-Board    LEDs sourced from VME register
     mod_cfg_wr[4]    = 0;    // 1=BD LED Cylon mode, cool
     mod_cfg_wr[11:5]  = 0;    // Readonly
     mod_cfg_wr[12]    = 0;    // 1=Enable global reset on lock_lost. JRG, for mmcm_lock_lost resets: was 1, now 0 for testing
     mod_cfg_wr[15:13]  = 0;    // Readonly
  end

  assign led_fp_src_vme    = mod_cfg_wr[0];  // RW  1=Front Panel LEDs sourced from VME register
  assign led_fp_cylon    = mod_cfg_wr[1];  // RW  1=Front Panel LEDs Cylon mode, cool
  assign led_flash_on_stop  = mod_cfg_wr[2];  // RW  1=Flash front panel in trigger_stop mode
  assign led_bd_src_vme    = mod_cfg_wr[3];  // RW  1=On-Board    LEDs sourced from VME register
  assign led_bd_cylon    = mod_cfg_wr[4];  // RW  1=On-Board    LEDs Cylon mode, cool
  assign global_reset_en    = mod_cfg_wr[12];  // RW  Enable global reset on lock_lost.  JG: used to be ON by default

  assign mod_cfg_rd[4:0]    = mod_cfg_wr[4:0];  // RW  Readback
  assign mod_cfg_rd[11:5]    = cfeb_exists[6:0];  // R  CFEBs instantiated in this firmware
  assign mod_cfg_rd[12]    = mod_cfg_wr[12];  // RW  Readback
  assign mod_cfg_rd[13]    = power_up;    // R  Power-up FF
  assign mod_cfg_rd[14]    = ddd_autostart;  // R  DDD autostart
  assign mod_cfg_rd[15]    = mez_done;    // R  Mezzanine status

  wire   mod_cfg_sump    = (|mod_cfg_wr[15:13]) | (|mod_cfg_wr[11:5]);

//------------------------------------------------------------------------------------------------------------------
//  ADR_CCB_CFG=2A    CCB Configuration Register
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
     ccb_cfg_wr[0]          = 0;      // 1=Ignore CCB backplane inputs
     ccb_cfg_wr[1]          = 0;      // 1=Disable CCB backplane outputs
     ccb_cfg_wr[2]          = 0;      // 1=Enable CCB internal L1A emulator
     ccb_cfg_wr[3]          = 0;      // 1=Enable ALCT+CLCT CCB status for CCB front panelpanel
     ccb_cfg_wr[4]          = 0;      // 1=Enable ALCT status GTL outputs
     ccb_cfg_wr[5]          = 0;      // 1=Enable CLCT status GTL outputs
     ccb_cfg_wr[6]          = 0;      // 1=fire ccb_l1accept oneshot
     ccb_cfg_wr[11:7]        = 0;      // CCB reserved signals from TMB, not used yet
     ccb_cfg_wr[12]          = 0;      // Event counter reset, from VME
     ccb_cfg_wr[13]          = 0;      // Bunch crossing counter reset, from VME
     ccb_cfg_wr[14]          = 0;      // Bunch crossing zero, from VME
     ccb_cfg_wr[15]          = CCB_BX0_EMULATOR;  // BX0 emulator enable, must be 0 for CERN versions
  end

  assign ccb_ignore_rx      = ccb_cfg_wr[0];  // RW  1=Ignore CCB backplane inputs
  assign ccb_disable_tx      = ccb_cfg_wr[1];  // RW  1=Disble tranmistted CCB backplane outputs
  assign ccb_int_l1a_en      = ccb_cfg_wr[2];  // RW  1=Enable internal l1a emualtor
  assign ccb_status_oe_lcl    = ccb_cfg_wr[3];  // RW  1=Enable ALCT+CLCT CCB status for CCB front panel
  assign alct_status_en      = ccb_cfg_wr[4];  // RW  1=Enable status GTL outputs
  assign clct_status_en      = ccb_cfg_wr[5];  // RW  1=Enable status GTL outputs
  assign l1a_vme        = ccb_cfg_wr[6];  // RW  1=fire ccb_l1accept oneshot
  assign tmb_reserved_in[4:0]    = ccb_cfg_wr[11:7];  // W  CCB reserved signals from TMB, not used yet

  wire   vme_evcntres_vme      = ccb_cfg_wr[12];  // W  Event counter reset, from VME
  wire   vme_bcntres_vme      = ccb_cfg_wr[13];  // W  Bunch crossing counter reset, from VME
  wire   vme_bx0_vme      = ccb_cfg_wr[14];  // W  Bunch crossing zero, from VME
  wire   vme_bx0_emu_en      = ccb_cfg_wr[15];  // W  BX0 emulator enable, must be 0 for CERN versions
  
  assign ccb_cfg_rd[6:0]      = ccb_cfg_wr[6:0];    //    Readback
  assign ccb_cfg_rd[8:7]      = tmb_reserved[1:0];    // R  Unassigned
  assign ccb_cfg_rd[11:9]      = tmb_reserved_out[2:0];  // R  Unassigned
  assign ccb_cfg_rd[12]      = tmb_hard_reset;    // R  Reload TMB  FPGA
  assign ccb_cfg_rd[13]      = alct_hard_reset;    // R  Reload ALCT FPGA
  assign ccb_cfg_rd[14]      = alct_adb_pulse_sync;    // R  ALCT synchronous  test pulse
  assign ccb_cfg_rd[15]      = alct_adb_pulse_async;    // R  ALCT asynchronous test pulse

  assign  ccb_status_oe = (ccb_status_tri) ? 1'bz: ccb_status_oe_lcl;  // 1=CCB output enable

  x_oneshot uevc (.d(vme_evcntres_vme),.clock(clock),.q(vme_evcntres));
  x_oneshot ubcn (.d(vme_bcntres_vme ),.clock(clock),.q(vme_bcntres ));
  x_oneshot ubx0 (.d(vme_bx0_vme     ),.clock(clock),.q(vme_bx0     ));

//------------------------------------------------------------------------------------------------------------------
//  ADR_CCB_TRIG=2C    CCB Trigger Control Register
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
     ccb_trig_wr[0]    = 1'b0;    // 1=Request ccb l1a on alct ext_trig
     ccb_trig_wr[1]    = 1'b0;    // 1=Request ccb l1a on clct ext_trig
     ccb_trig_wr[2]    = 1'b1;    // 1=Request ccb l1a on sequencer trigger
     ccb_trig_wr[3]    = 1'b0;    // 1=Fire alct_ext_trig oneshot
     ccb_trig_wr[4]    = 1'b0;    // 1=Fire clct_ext_trig oneshot
     ccb_trig_wr[5]    = 1'b0;    // 1=clct_ext_trig fires alct and alct fires clct_trig, DC level
     ccb_trig_wr[6]    = 1'b0;    // 1=Allow clct_ext_trigger_ccb even if ccb_ignore_rx=1
     ccb_trig_wr[7]    = 1'b0;    // 1=ignore ttc trig_start/stop commands
     ccb_trig_wr[15:8] = 8'd114;  // Internal L1A delay (not same as sequencer internal)
  end

  assign alct_ext_trig_l1aen  = ccb_trig_wr[0];    // RW  1=Request ccb l1a on clct ext_trig
  assign clct_ext_trig_l1aen  = ccb_trig_wr[1];    // RW  1=Request ccb l1a on alct ext_trig
  assign seq_trig_l1aen       = ccb_trig_wr[2];    // RW  1=Request ccb l1a on alct sequencer trig
  assign alct_ext_trig_vme    = ccb_trig_wr[3];    // RW  1=Fire alct_ext_trig oneshot
  assign clct_ext_trig_vme    = ccb_trig_wr[4];    // RW  1=Fire clct_ext_trig oneshot
  assign ext_trig_both        = ccb_trig_wr[5];    // RW  1=clct_ext_trig fires alct and alct fires clct_trig, DC level
  assign ccb_allow_ext_bypass = ccb_trig_wr[6];    // RW  1=Allow clct_ext_trigger_ccb even if ccb_ignore_rx=1
  assign ccb_ignore_startstop = ccb_trig_wr[7];    // RW  1=ignore ttc trig_start/stop commands
  assign l1a_delay_vme[7:0]   = ccb_trig_wr[15:8]; // RW  Internal L1A delay
  assign ccb_trig_rd[15:0]    = ccb_trig_wr[15:0]; //     Readback

//------------------------------------------------------------------------------------------------------------------
// ADR_CCB_STAT0=2E    CCB Status Register, Readonly
//------------------------------------------------------------------------------------------------------------------
  assign ccb_stat0_rd[7:0]    = ccb_cmd[7:0];     // R  CCB command word
  assign ccb_stat0_rd[8]      = ccb_clock40_enable;  // R  Enable 40MHz clock
  assign ccb_stat0_rd[9]      = ccb_reserved[0];  // R  ccb_ttcrx_ready
  assign ccb_stat0_rd[10]     = ccb_reserved[1];  // R  ccb_qpll_locked
  assign ccb_stat0_rd[11]     = ccb_reserved[2];  // R  Unassigned
  assign ccb_stat0_rd[12]     = ccb_reserved[3];  // R  Unassigned
  assign ccb_stat0_rd[13]     = ccb_reserved[4];  // R  Unassigned
  assign ccb_stat0_rd[14]     = ccb_bcntres;      // R  Bunch crossing counter reset, backplane
  assign ccb_stat0_rd[15]     = ccb_bx0;          // R  Bunch crossing 0 from backplane

//------------------------------------------------------------------------------------------------------------------
//  ADR_ALCT_CFG=30    ALCT Configuration Register
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
     alct_cfg_wr[0]          = 0;  // RW  1=Enable alct_ext_trig   from CCB
     alct_cfg_wr[1]          = 0;  // RW  1=Enable alct_ext_inject from CCB
     alct_cfg_wr[2]          = 0;  // RW  1=Assert alct_ext_trig
     alct_cfg_wr[3]          = 0;  // RW  1=Assert alct_ext_inject
     alct_cfg_wr[7:4]        = 0;  // RW  ALCT Sequencer command
     alct_cfg_wr[8]          = 1;  // RW  1=connect ccb_clock40_enable to alct_clock_en_vme
     alct_cfg_wr[9]          = 0;  // RW  alct_clock_en_vme (unless [8]=1)
     alct_cfg_wr[10]          = 0;  // RO  alct_muonic conditional compile
     alct_cfg_wr[11]          = 0;  // RO  cfeb_muonic conditional compile
     alct_cfg_wr[15:12]        = 0;  // RW  Free
  end

  assign cfg_alct_ext_trig_en    = alct_cfg_wr[0];  // RW  1=Enable alct_ext_trig   from CCB
  assign cfg_alct_ext_inject_en  = alct_cfg_wr[1];    // RW  1=Enable alct_ext_inject from CCB
  assign cfg_alct_ext_trig    = alct_cfg_wr[2];  // RW  1=Assert alct_ext_trig
  assign cfg_alct_ext_inject    = alct_cfg_wr[3];  // RW  1=Assert alct_ext_inject
  assign alct_seq_cmd[3:0]    = alct_cfg_wr[7:4];  // RW  ALCT Sequencer command
  wire   alct_clock_use_ccb    = alct_cfg_wr[8];  // RW   1=alct sees ccb_clock40_enable,0 sees [9]
  wire   alct_clock_use_vme    = alct_cfg_wr[9];  // RW  alct_clock_en_vme (unless [8]=1)

  assign alct_cfg_rd[9:0]      = alct_cfg_wr[9:0];  // RW  Readback
  assign alct_cfg_rd[10]      = ALCT_MUONIC;    // RO  Floats ALCT board  in clock-space with independent time-of-flight delay
  assign alct_cfg_rd[11]      = CFEB_MUONIC;    // RO  Floats CFEB boards in clock-space with independent time-of-flight delay
  assign alct_cfg_rd[15:12]    = alct_cfg_wr[15:12];  // RW  Readback

  assign alct_clock_en_vme    = (alct_clock_use_ccb) ? ccb_clock40_enable : alct_clock_use_vme;    // Select ALCT 40MHz clock en

//------------------------------------------------------------------------------------------------------------------
// ADR_ALCT_INJ=32    ALCT Injector Control Register
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
     alct_inj_wr[0]          = 1'b0;              // 1=Blank received ALCT data
     alct_inj_wr[1]          = 1'b0;              // 1=Start ALCT injector
     alct_inj_wr[2]          = 1'b0;              // 1=Start ALCT injector with clct inject command
     alct_inj_wr[3]          = 1'b0;              // 1=Link  ALCT injector to CFEB injector RAM
     alct_inj_wr[4]          = 1'b0;              // 1=Link  L1A  injector to CFEB injector RAM
     alct_inj_wr[9:5]        = 5'd13;            // Injector delay, was d8 in pre-rat firmware
     alct_inj_wr[15:10]        = 0;
  end

  assign alct_clear        = alct_inj_wr[0];        // RW  1=Blank received data
  wire   alct_inject_mux      = alct_inj_wr[1];        // RW  1=Start ALCT injector
  wire   alct_sync_clct      = alct_inj_wr[2];        // RW  1=Start ALCT injector with clct inject command
  assign alct_inj_ram_en      = alct_inj_wr[3];        // RW  1=Link  ALCT injector to CFEB injector RAM
  assign l1a_inj_ram_en      = alct_inj_wr[4];        // RW  1=Link  L1A  injector to CFEB injector RAM
  assign alct_inj_delay[4:0]    = alct_inj_wr[9:5];        // RW  Injector delay
  assign alct_inj_rd[15:0]    = alct_inj_wr[15:0];      //    Readback

  assign alct_inject        = alct_inject_mux || (alct_sync_clct &&  inj_trig_vme);  // Start ALCT and CLCT injectors at same time, cool.

//------------------------------------------------------------------------------------------------------------------
// ADR_ALCT0_INJ=34    ALCT Injected ALCT0 Register
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
     alct0_inj_wr[15:0]        = 16'h0877;            // ALCT0 Injected, Q=3,Key=7,BXN=1
  end

  assign alct0_inj[15:0]      = alct0_inj_wr[15:0];      // RW  Injected ALCT0
  assign alct0_inj_rd[15:0]    = alct0_inj_wr[15:0];      //    Readback

//------------------------------------------------------------------------------------------------------------------
// ADR_ALCT1_INJ=36    ALCT Injected ALCT1 Register
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
     alct1_inj_wr[15:0]        = 16'h0BD5;            // ALCT1 Injected Q=2,Key=61,BXN=1
  end

  assign alct1_inj[15:0]      = alct1_inj_wr[15:0];      // RW  Injected ALCT1
  assign alct1_inj_rd[15:0]    = alct1_inj_wr[15:0];      //    Readback

//------------------------------------------------------------------------------------------------------------------
// ADR_ALCT_STAT =38    ALCT Sequencer Control/Status Register
// ADR_ALCT0_RCD =3A    ALCT Latched ALCT0, Readonly
// ADR_ALCT1_RCD =3C    ALCT Latched ALCT1, Readonly
// ADR_ALCT_FIFO0=3E    ALCT Raw Hits FIFO RAM Status, Readonly
//------------------------------------------------------------------------------------------------------------------
// ADR_ALCT_STAT =38 ALCT Sequencer Control/Status Register
  initial begin
  alct_stat_wr[0]          = 0;              // R  ALCT FPGA loaded  
  alct_stat_wr[1]          = 1;              // RW  Enable ALCT ECC decoder, else do no ECC correction
  alct_stat_wr[2]          = 1;              // RW  Blank alcts with uncorrected ecc errors
  alct_stat_wr[4:3]        = 0;              // R  ALCT sync mode ecc error syndrome
  alct_stat_wr[11:5]        = 0;              // RW  Free
  alct_stat_wr[15:12]        = 0;              // RW  ALCT data transmit delay, integer bx
  end

  assign alct_ecc_en        = alct_stat_wr[1];        // RW  Enable ALCT ECC decoder, else do no ECC correction
  assign alct_ecc_err_blank    = alct_stat_wr[2];        // RW  Blank alcts with uncorrected ecc errors
  assign alct_txd_int_delay[3:0]  = alct_stat_wr[15:12];      // RW  ALCT data transmit delay, integer bx

  assign alct_stat_rd[0]      = alct_cfg_done;        // R  ALCT FPGA loaded
  assign alct_stat_rd[1]      = alct_ecc_en;          // RW  Enable ALCT ECC decoder, else do no ECC correction
  assign alct_stat_rd[2]      = alct_ecc_err_blank;      // RW  Blank alcts with uncorrected ecc errors
  assign alct_stat_rd[4:3]    = alct_sync_ecc_err[1:0];    // R  ALCT sync mode ecc error syndrome
  assign alct_stat_rd[11:5]    = alct_stat_wr[11:5];      // RW  Free
  assign alct_stat_rd[15:12]    = alct_txd_int_delay[3:0];    // RW  ALCT data transmit delay, integer bx  

  wire alct_stat_sump = alct_stat_wr[0] | (|alct_stat_wr[4:3]);  // Unused write-only

// ADR_ALCT0_RCD =3A ALCT Latched ALCT0
  assign alct0_rcd_rd[15:0]    = alct0_vme[15:0];        // R  LCT latched on last valid pattern

// ADR_ALCT1_RCD =3C ALCT Latched ALCT1
  assign alct1_rcd_rd[15:0]    = alct1_vme[15:0];        // R  LCT latched on last valid pattern

// ADR_ALCT_FIFO0=3E ALCT Raw Hits FIFO RAM Status
  assign alct_fifo0_rd[0]      = alct_raw_busy;        // R  Raw hits RAM VME busy writing ALCT data
  assign alct_fifo0_rd[1]      = alct_raw_done;        // R  Raw hits ready for VME readout
  assign alct_fifo0_rd[12:2]    = alct_raw_wdcnt[10:0];      // R  ALCT word count stored in FIFO
  assign alct_fifo0_rd[14:13]    = alct_raw_rdata[17:16];    // R  Raw hits RAM VME read data MSBs
  assign alct_fifo0_rd[15]    = 0;              // R  Unassigned

//------------------------------------------------------------------------------------------------------------------
// ADR_ALCTFIFO1=A8    ALCT Raw Hits RAM Control Register
// ADR_ALCTFIFO2=AA    ALCT Raw hits RAM Data Register
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
  alct_fifo1_wr[15:0]        = 0;              // ALCT Raw hits ram control
  end

// ALCT Register: Raw Hits FIFO RAM read control
  wire   alct_demux_mode;

  assign alct_raw_reset      = alct_fifo1_wr[0];        // RW  Reset raw hits write address and done flag
  assign alct_raw_radr[10:0]    = alct_fifo1_wr[11:1];      // RW  Raw hits RAM VME read address
  assign alct_demux_mode      = alct_fifo1_wr[13];      // RW  0=fifo2 reads RAM, 1=fifo2 reads 80mhz demux
  assign alct_fifo1_rd[15:0]    = alct_fifo1_wr[15:0];      //    Readback
  
// ALCT Register: Raw Hits FIFO RAM read data LSBs (MSBs in alct_fifo0_rd) or 80MHz demux data
  reg [15:0] alct_fifo2_mux=0;

  always @(posedge clock) begin
  if (alct_demux_mode) begin
  case (alct_raw_radr[2:0])
  3'h0:    alct_fifo2_mux[15:0] <=  {2'h0,alct_sync_rxdata_1st[14: 1]};  // R  80MHz demux latch received data
  3'h1:    alct_fifo2_mux[15:0] <=  {2'h0,alct_sync_rxdata_1st[28:15]};
  3'h2:    alct_fifo2_mux[15:0] <=  {2'h0,alct_sync_rxdata_2nd[14:1 ]};
  3'h3:    alct_fifo2_mux[15:0] <=  {2'h0,alct_sync_rxdata_2nd[28:15]};
  3'h4:    alct_fifo2_mux[15:0] <=  {2'h0,alct_sync_expect_1st[14: 1]};  // R  80MHz demux latch expected data in sync mode
  3'h5:    alct_fifo2_mux[15:0] <=  {2'h0,alct_sync_expect_1st[28:15]};
  3'h6:    alct_fifo2_mux[15:0] <=  {2'h0,alct_sync_expect_2nd[14:1 ]};
  3'h7:    alct_fifo2_mux[15:0] <=  {2'h0,alct_sync_expect_2nd[28:15]};
  default:  alct_fifo2_mux[15:0] <=  {2'h0,alct_sync_rxdata_1st[14: 1]};
  endcase
  end
  else    alct_fifo2_mux[15:0] <= alct_raw_rdata[15:0];        // R  Raw hits RAM VME read data
  end

  assign alct_fifo2_rd[15:0]    = alct_fifo2_mux[15:0];          // R  Raw hits RAM VME read data

//------------------------------------------------------------------------------------------------------------------
// ADR_DMB_MON=40    DMB Monitored Backplane Signals Register, Readonly
//------------------------------------------------------------------------------------------------------------------
  assign dmb_mon_rd[2:0]      = dmb_cfeb_calibrate[2:0];    // R  DMB calibration
  assign dmb_mon_rd[3]      = dmb_l1a_release;        // R  DMB test
  assign dmb_mon_rd[8:4]      = dmb_reserved_out[4:0];    // R  DMB unassigned
  assign dmb_mon_rd[11:9]      = dmb_reserved_in[2:0];      // R  DMB unassigned
  assign dmb_mon_rd[15:12]    = {(| dmb_rx_ff[5:3]),dmb_rx_ff[2:0]};// R  DMB received

//------------------------------------------------------------------------------------------------------------------
// ADR_CFEB_INJ = 0x42    CFEB Injector Control Register
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
  cfeb_inj_wr[4:0]        = 5'b11111;            // 1=Enable, 0=Turn off all CFEB inputs
  cfeb_inj_wr[9:5]        = 5'b00000;            // 1=Select CFEBn for RAM read/write
  cfeb_inj_wr[14:10]        = 5'b11111;            // Enable CFEB(n) for injector trigger
  cfeb_inj_wr[15]          = 1'b0;              // Start pattern injector
  end

  assign mask_all[4:0]      = cfeb_inj_wr[4:0];        // RW  1=Enable, 0=Turn off all CFEB inputs  
  assign inj_febsel[4:0]      = cfeb_inj_wr[9:5];        // RW  1=Select CFEBn for RAM read/write
  assign injector_mask_cfeb[4:0]  = cfeb_inj_wr[14:10];      // RW  Enable CFEB(n) for injector trigger
  assign inj_trig_vme        = cfeb_inj_wr[15];        // RW  Start pattern injector

  assign cfeb_inj_rd[14:0]    = cfeb_inj_wr[14:0];      //    Readback
  assign cfeb_inj_rd[15]      = inj_ramout_busy;        // R  Injector busy

  assign inj_last_tbin[11:0]    = 1023;              // Last tbin, may wrap past 1024 ram adr

//------------------------------------------------------------------------------------------------------------------
// ADR_CFEB_INJ_ADR=44    CFEB Injector RAM Address Register
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
  cfeb_inj_adr_wr[2:0]      = 3'b000;            // 1=Write enable injector RAM
  cfeb_inj_adr_wr[5:3]      = 3'b000;            // 1=Read enable Injector RAM
  cfeb_inj_adr_wr[15:6]      = 10'h000;            // Injector RAM read/write address
  end

  assign inj_wen[2:0]        = cfeb_inj_adr_wr[ 2:0];    // RW  1=Write enable injector RAM
  assign inj_ren[2:0]        = cfeb_inj_adr_wr[ 5:3];    // RW  1=Read enable Injector RAM
  assign inj_rwadr[9:0]      = cfeb_inj_adr_wr[15:6];    // RW  Injector RAM read/write address
  assign cfeb_inj_adr_rd[15:0]  = cfeb_inj_adr_wr[15:0];    //    Readback

//------------------------------------------------------------------------------------------------------------------
// ADR_CFEB_INJ_WDATA=46  CFEB Injector Write Data Register
// ADR_CFEB_INJ_RDATA=48  CFEB Injector Read  Data Register
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
  cfeb_inj_wdata_wr[15:0]      = 16'h0000;            // Injector RAM write data
  end

// CFEB Injector Write Data
  assign inj_wdata[15:0]      = cfeb_inj_wdata_wr[15:0];    // RW  Injector RAM write data
  assign cfeb_inj_wdata_rd[15:0]  = cfeb_inj_wdata_wr[15:0];    //    Readback

// CFEB Injector Read Data
  assign cfeb_inj_rdata_rd[15:0]  = inj_rdata[15:0];        // R  Injector RAM read data

//------------------------------------------------------------------------------------------------------------------
// ADR_HCM001=4A    CFEB0 Ly0,Ly1 Hot Channel Mask
// ADR_HCM023=4C    CFEB0 Ly2,Ly3
// ADR_HCM045=4E    CFEB0 Ly4,Ly5
// ADR_HCM101=50    CFEB1 Ly0,Ly1
// ADR_HCM123=52    CFEB1 Ly2,Ly3
// ADR_HCM145=54    CFEB1 Ly4,Ly5
// ADR_HCM201=56    CFEB2 Ly0,Ly1
// ADR_HCM223=58    CFEB2 Ly2,Ly3
// ADR_HCM245=5A    CFEB2 Ly4,Ly5
// ADR_HCM301=5C    CFEB3 Ly0,Ly1
// ADR_HCM323=5E    CFEB3 Ly2,Ly3
// ADR_HCM345=60    CFEB3 Ly4,Ly5
// ADR_HCM401=62    CFEB4 Ly0,Ly1
// ADR_HCM423=64    CFEB4 Ly2,Ly3
// ADR_HCM445=66    CFEB4 Ly4,Ly5
// ADR_V6_HCM501=16E  CFEB5 Ly0,Ly1
// ADR_V6_HCM523=170  CFEB5 Ly2,Ly3
// ADR_V6_HCM545=172  CFEB5 Ly4,Ly5
// ADR_V6_HCM601=174  CFEB6 Ly0,Ly1
// ADR_V6_HCM623=176  CFEB6 Ly2,Ly3
// ADR_V6_HCM645=178  CFEB6 Ly4,Ly5
//------------------------------------------------------------------------------------------------------------------
// CFEB Hot Channel Mask Defaults
  parameter DEF_CFEB0_LY0_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB0_LY1_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB0_LY2_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB0_LY3_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB0_LY4_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB0_LY5_HCM    =  8'b11111111;  // 1=Enable DiStrip

  parameter DEF_CFEB1_LY0_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB1_LY1_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB1_LY2_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB1_LY3_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB1_LY4_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB1_LY5_HCM    =  8'b11111111;  // 1=Enable DiStrip

  parameter DEF_CFEB2_LY0_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB2_LY1_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB2_LY2_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB2_LY3_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB2_LY4_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB2_LY5_HCM    =  8'b11111111;  // 1=Enable DiStrip

  parameter DEF_CFEB3_LY0_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB3_LY1_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB3_LY2_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB3_LY3_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB3_LY4_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB3_LY5_HCM    =  8'b11111111;  // 1=Enable DiStrip

  parameter DEF_CFEB4_LY0_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB4_LY1_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB4_LY2_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB4_LY3_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB4_LY4_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB4_LY5_HCM    =  8'b11111111;  // 1=Enable DiStrip

  parameter DEF_CFEB5_LY0_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB5_LY1_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB5_LY2_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB5_LY3_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB5_LY4_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB5_LY5_HCM    =  8'b11111111;  // 1=Enable DiStrip

  parameter DEF_CFEB6_LY0_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB6_LY1_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB6_LY2_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB6_LY3_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB6_LY4_HCM    =  8'b11111111;  // 1=Enable DiStrip
  parameter DEF_CFEB6_LY5_HCM    =  8'b11111111;  // 1=Enable DiStrip

// CFEB Hot Channel Mask defaults, packed
  initial begin
  hcm001_wr[15:0] = {DEF_CFEB0_LY1_HCM,DEF_CFEB0_LY0_HCM};
  hcm023_wr[15:0] = {DEF_CFEB0_LY3_HCM,DEF_CFEB0_LY2_HCM};
  hcm045_wr[15:0] = {DEF_CFEB0_LY5_HCM,DEF_CFEB0_LY4_HCM};

  hcm101_wr[15:0] = {DEF_CFEB1_LY1_HCM,DEF_CFEB1_LY0_HCM};
  hcm123_wr[15:0] = {DEF_CFEB1_LY3_HCM,DEF_CFEB1_LY2_HCM};
  hcm145_wr[15:0] = {DEF_CFEB1_LY5_HCM,DEF_CFEB1_LY4_HCM};

  hcm201_wr[15:0] = {DEF_CFEB2_LY1_HCM,DEF_CFEB2_LY0_HCM};
  hcm223_wr[15:0] = {DEF_CFEB2_LY3_HCM,DEF_CFEB2_LY2_HCM};
  hcm245_wr[15:0] = {DEF_CFEB2_LY5_HCM,DEF_CFEB2_LY4_HCM};

  hcm301_wr[15:0] = {DEF_CFEB3_LY1_HCM,DEF_CFEB3_LY0_HCM};
  hcm323_wr[15:0] = {DEF_CFEB3_LY3_HCM,DEF_CFEB3_LY2_HCM};
  hcm345_wr[15:0] = {DEF_CFEB3_LY5_HCM,DEF_CFEB3_LY4_HCM};

  hcm401_wr[15:0] = {DEF_CFEB4_LY1_HCM,DEF_CFEB4_LY0_HCM};
  hcm423_wr[15:0] = {DEF_CFEB4_LY3_HCM,DEF_CFEB4_LY2_HCM};
  hcm445_wr[15:0] = {DEF_CFEB4_LY5_HCM,DEF_CFEB4_LY4_HCM};

  hcm501_wr[15:0] = {DEF_CFEB5_LY1_HCM,DEF_CFEB5_LY0_HCM};
  hcm523_wr[15:0] = {DEF_CFEB5_LY3_HCM,DEF_CFEB5_LY2_HCM};
  hcm545_wr[15:0] = {DEF_CFEB5_LY5_HCM,DEF_CFEB5_LY4_HCM};

  hcm601_wr[15:0] = {DEF_CFEB6_LY1_HCM,DEF_CFEB6_LY0_HCM};
  hcm623_wr[15:0] = {DEF_CFEB6_LY3_HCM,DEF_CFEB6_LY2_HCM};
  hcm645_wr[15:0] = {DEF_CFEB6_LY5_HCM,DEF_CFEB6_LY4_HCM};
  end

  assign cfeb0_ly0_hcm = hcm001_wr[ 7:0];    // Mask map 2 layers to 1 register
  assign cfeb0_ly1_hcm = hcm001_wr[15:8];
  assign cfeb0_ly2_hcm = hcm023_wr[ 7:0];
  assign cfeb0_ly3_hcm = hcm023_wr[15:8];
  assign cfeb0_ly4_hcm = hcm045_wr[ 7:0];
  assign cfeb0_ly5_hcm = hcm045_wr[15:8];

  assign cfeb1_ly0_hcm = hcm101_wr[ 7:0];
  assign cfeb1_ly1_hcm = hcm101_wr[15:8];
  assign cfeb1_ly2_hcm = hcm123_wr[ 7:0];
  assign cfeb1_ly3_hcm = hcm123_wr[15:8];
  assign cfeb1_ly4_hcm = hcm145_wr[ 7:0];
  assign cfeb1_ly5_hcm = hcm145_wr[15:8];

  assign cfeb2_ly0_hcm = hcm201_wr[ 7:0];
  assign cfeb2_ly1_hcm = hcm201_wr[15:8];
  assign cfeb2_ly2_hcm = hcm223_wr[ 7:0];
  assign cfeb2_ly3_hcm = hcm223_wr[15:8];
  assign cfeb2_ly4_hcm = hcm245_wr[ 7:0];
  assign cfeb2_ly5_hcm = hcm245_wr[15:8];

  assign cfeb3_ly0_hcm = hcm301_wr[ 7:0];
  assign cfeb3_ly1_hcm = hcm301_wr[15:8];
  assign cfeb3_ly2_hcm = hcm323_wr[ 7:0];
  assign cfeb3_ly3_hcm = hcm323_wr[15:8];
  assign cfeb3_ly4_hcm = hcm345_wr[ 7:0];
  assign cfeb3_ly5_hcm = hcm345_wr[15:8];

  assign cfeb4_ly0_hcm = hcm401_wr[ 7:0];
  assign cfeb4_ly1_hcm = hcm401_wr[15:8];
  assign cfeb4_ly2_hcm = hcm423_wr[ 7:0];
  assign cfeb4_ly3_hcm = hcm423_wr[15:8];
  assign cfeb4_ly4_hcm = hcm445_wr[ 7:0];
  assign cfeb4_ly5_hcm = hcm445_wr[15:8];

  assign cfeb5_ly0_hcm = hcm501_wr[ 7:0];
  assign cfeb5_ly1_hcm = hcm501_wr[15:8];
  assign cfeb5_ly2_hcm = hcm523_wr[ 7:0];
  assign cfeb5_ly3_hcm = hcm523_wr[15:8];
  assign cfeb5_ly4_hcm = hcm545_wr[ 7:0];
  assign cfeb5_ly5_hcm = hcm545_wr[15:8];

  assign cfeb6_ly0_hcm = hcm601_wr[ 7:0];
  assign cfeb6_ly1_hcm = hcm601_wr[15:8];
  assign cfeb6_ly2_hcm = hcm623_wr[ 7:0];
  assign cfeb6_ly3_hcm = hcm623_wr[15:8];
  assign cfeb6_ly4_hcm = hcm645_wr[ 7:0];
  assign cfeb6_ly5_hcm = hcm645_wr[15:8];

  assign  hcm001_rd[15:0] = hcm001_wr[15:0];  // Readback
  assign  hcm023_rd[15:0] = hcm023_wr[15:0];
  assign  hcm045_rd[15:0] = hcm045_wr[15:0];

  assign  hcm101_rd[15:0] = hcm101_wr[15:0];
  assign  hcm123_rd[15:0] = hcm123_wr[15:0];
  assign  hcm145_rd[15:0] = hcm145_wr[15:0];

  assign  hcm201_rd[15:0] = hcm201_wr[15:0];
  assign  hcm223_rd[15:0] = hcm223_wr[15:0];
  assign  hcm245_rd[15:0] = hcm245_wr[15:0];

  assign  hcm301_rd[15:0] = hcm301_wr[15:0];
  assign  hcm323_rd[15:0] = hcm323_wr[15:0];
  assign  hcm345_rd[15:0] = hcm345_wr[15:0];

  assign  hcm401_rd[15:0] = hcm401_wr[15:0];
  assign  hcm423_rd[15:0] = hcm423_wr[15:0];
  assign  hcm445_rd[15:0] = hcm445_wr[15:0];

  assign  hcm501_rd[15:0] = hcm501_wr[15:0];
  assign  hcm523_rd[15:0] = hcm523_wr[15:0];
  assign  hcm545_rd[15:0] = hcm545_wr[15:0];

  assign  hcm601_rd[15:0] = hcm601_wr[15:0];
  assign  hcm623_rd[15:0] = hcm623_wr[15:0];
  assign  hcm645_rd[15:0] = hcm645_wr[15:0];

//------------------------------------------------------------------------------------------------------------------
// ADR_SEQ_TRIG_EN = 0x68    Sequencer External Trigger Enables Register
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
  seq_trigen_wr[0]        = 1'b1;            // Allow CLCT Pattern triggers
  seq_trigen_wr[1]        = 1'b0;            // Allow ALCT Pattern trigger
  seq_trigen_wr[2]        = 1'b0;            // Allow ALCT*CLCT Pattern triggers
  seq_trigen_wr[3]        = 1'b0;            // Allow ADB external trigger
  seq_trigen_wr[4]        = 1'b0;            // Allow DMB external trigger
  seq_trigen_wr[5]        = 1'b0;            // Allow CLCT External trigger from CCB
  seq_trigen_wr[6]        = 1'b0;            // Allow ALCT External trigger from CCB
  seq_trigen_wr[7]        = 1'b0;            // External trigger from VME
  seq_trigen_wr[8]        = 1'b0;            // Changes ext_trig to fire pattern injector
  seq_trigen_wr[9]        = 1'b0;            // Make all CFEBs active when triggered
  seq_trigen_wr[14:10]      = 5'b11111;          // Enables CFEBs for triggering and active feb flag
  seq_trigen_wr[15]        = 1'b1;            // Select source of cfeb_en,1=from mask_all, 0=from VME
  end

// Sequencer trigger enables register
  reg  [MXCFEB-1:0] cfeb_en={MXCFEB{1'b1}};
  wire [MXCFEB-1:0] cfeb_en_vme;
  wire        cfeb_en_source;

  assign clct_pat_trig_en      = seq_trigen_wr[0];      // RW  Allow CLCT Pattern pre-triggers
  assign alct_pat_trig_en      = seq_trigen_wr[1];      // RW  Allow ALCT Pattern pre-trigger
  assign alct_match_trig_en    = seq_trigen_wr[2];      // RW  Allow ALCT*CLCT Pattern pre-triggers
  assign adb_ext_trig_en      = seq_trigen_wr[3];      // RW  Allow ADB Test pulse pre-trigger
  assign dmb_ext_trig_en      = seq_trigen_wr[4];      // RW  Allow DMB Calibration pre-trigger
  assign clct_ext_trig_en      = seq_trigen_wr[5];      // RW  Allow CLCT External pre-trigger from CCB
  assign alct_ext_trig_en      = seq_trigen_wr[6];      // RW  Allow ALCT External pre-trigger from CCB
  assign vme_ext_trig        = seq_trigen_wr[7];      // RW  External pre-trigger from VME
  assign ext_trig_inject      = seq_trigen_wr[8];      // RW  Changes clct_ext_trig to fire pattern injector
  assign all_cfebs_active      = seq_trigen_wr[9];      // RW  Make all CFEBs active when pre-triggered
  assign cfeb_en_vme[4:0]      = seq_trigen_wr[14:10];    // RW*  Enables CFEBs for triggering and active feb flag
  assign cfeb_en_source      = seq_trigen_wr[15];    // RW  Select source of cfeb_en,1=from mask_all, 0=from VME

  assign seq_trigen_rd[9:0]    = seq_trigen_wr[9:0];    //    Readback what was written
  assign seq_trigen_rd[14:10]    = cfeb_en[4:0];        //    Readback actual cfeb_en state, altered by mask_all
  assign seq_trigen_rd[15]    = seq_trigen_wr[15];    //    Readback what was written

  always @(posedge clock) begin
  if (cfeb_en_source==1) cfeb_en <= mask_all[MXCFEB-1:0];
  else                   cfeb_en <= cfeb_en_vme[MXCFEB-1:0];
  end

//------------------------------------------------------------------------------------------------------------------
// ADR_SEQ_TRIG_DLY0=6A    Sequencer Trigger Delays Register: First Group
// ADR_SEQ_TRIG_DLY1=6C    Sequencer Trigger Delays Register: Second Group
// ADR_SEQ_TRIG_DLY2=194   Sequencer Trigger Delays Register: Third Group
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults First+Second+Third Group
  initial begin
    seq_trigdly0_wr[3:0]   = 4'd4;   // ALCT (alct_active_feb flag) window width for ALCT*preCLCT overlap
    seq_trigdly0_wr[7:4]   = 4'd2;   // ALCT (alct_active_feb flag) delay for ALCT*preCLCT overlap
    seq_trigdly0_wr[11:8]  = 4'd0;   // ALCT pattern  trigger delay
    seq_trigdly0_wr[15:12] = 4'd1;   // ADB  external trigger delay

    seq_trigdly1_wr[3:0]   = 4'd1;   // DMB  external trigger delay
    seq_trigdly1_wr[7:4]   = 4'd7;   // CLCT External trigger delay
    seq_trigdly1_wr[11:8]  = 4'd7;   // ALCT External trigger delay
    seq_trigdly1_wr[15:12] = 4'd0;   // Free
    
    seq_trigdly2_wr[3:0]   = 4'd4;   // pre-CLCT window width for L1A*preCLCT overlap
    seq_trigdly2_wr[11:4]  = 8'd128; // pre-CLCT delay for L1A*preCLCT overlap
    seq_trigdly2_wr[15:12] = 4'd0;   // Free
  end

  assign alct_preClct_width[3:0] = seq_trigdly0_wr[3:0];   // RW  ALCT (alct_active_feb flag) window width for ALCT*preCLCT overlap
  assign alct_preClct_dly[3:0]   = seq_trigdly0_wr[7:4];   // RW  ALCT (alct_active_feb flag) delay for ALCT*preCLCT overlap
  assign alct_pat_trig_dly[3:0]  = seq_trigdly0_wr[11:8];  // RW  ALCT Pattern trigger delay
  assign adb_ext_trig_dly[3:0]   = seq_trigdly0_wr[15:12]; // RW  ADB External trigger delay
  assign seq_trigdly0_rd[15:0]   = seq_trigdly0_wr[15:0];  //     Readback

  assign dmb_ext_trig_dly[3:0]  = seq_trigdly1_wr[3:0];    // RW  DMB External trigger delay
  assign clct_ext_trig_dly[3:0] = seq_trigdly1_wr[7:4];    // RW  CLCT External trigger delay
  assign alct_ext_trig_dly[3:0] = seq_trigdly1_wr[11:8];   // RW  ALCT External trigger delay
//assign layer_trig_dly[3:0]    = seq_trigdly1_wr[15:12];  // RW  Free
  assign seq_trigdly1_rd[15:0]  = seq_trigdly1_wr[15:0];   //     Readback
  
  assign l1a_preClct_width[3:0] = seq_trigdly2_wr[3:0];    // RW  pre-CLCT window width for L1A*preCLCT overlap
  assign l1a_preClct_dly[7:0]   = seq_trigdly2_wr[11:4];   // RW  pre-CLCT delay for L1A*preCLCT overlap
  assign seq_trigdly2_rd[15:0]  = seq_trigdly2_wr[15:0];   //     Readback

//------------------------------------------------------------------------------------------------------------------
// ADR_SEQ_ID=6E    Sequencer ID Information Register, Board & CSC ID
//------------------------------------------------------------------------------------------------------------------
  initial begin
  seq_id_wr[4:0]      = 5'd0;                // Board ID = VME Slot
  seq_id_wr[8:5]      = 4'd0;                // CSC Chamber ID number
  seq_id_wr[12:9]      = 4'd0;                // Run ID
  seq_id_wr[15:13]    = 3'd0;                // Free
  end

  wire [15:0] seq_id_def;
  wire [3:0]  csc_id_def = 4'd5;                // CSC Chamber ID number
  wire [3:0]  run_id_def = 4'd0;                // Run ID
  reg  [3:0]  csc_ga_def = 4'h0;                // VME slot address

  always @* begin                        // Default CSC ID based on slot
  if    (ga == 5'd0 ) csc_ga_def[3:0] <= csc_id_def[3:0];  // No slot ID, use defined default
  else if  (ga <  5'd12) csc_ga_def[3:0] <= ga[4:1];      // Slots 01-10 use slot/2 (tmb is in slot 6)
  else                  csc_ga_def[3:0] <= ga[4:1]-1'b1;    // Slots 14-20 use slot/2-1
  end

  assign seq_id_def[4:0]      = ga[4:0];          // Board ID = VME Slot
  assign seq_id_def[8:5]      = csc_ga_def[3:0];      // CSC Chamber ID number
  assign seq_id_def[12:9]      = run_id_def[3:0];      // Run ID
  assign seq_id_def[15:13]    = 0;

  always @(posedge clock) begin
  if      (!power_up) seq_id_wr  <= seq_id_def;        // Load non-constant defaults that can not be done via initial
  else if (wr_seq_id) seq_id_wr  <= d[15:0];
  end

  assign board_id[4:0]      = seq_id_wr[4:0];      // RW  Board ID = VME Slot
  assign csc_id[3:0]        = seq_id_wr[8:5];      // RW  CSC Chamber ID number
  assign run_id[3:0]        = seq_id_wr[12:9];      // RW  Run ID
  assign seq_id_rd[15:0]      = seq_id_wr[15:0];      //    Readback

//------------------------------------------------------------------------------------------------------------------
// ADR_SEQ_CLCT=70    Sequencer CLCT Processing Drift + Pattern Register
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
  seq_clct_wr[3:0]        = 4'd6;            // Triad output persistence, a 6 gives 6 clock-wide output
  seq_clct_wr[6:4]        = 3'd4;            // Hits on pattern template pre-trigger threshold
  seq_clct_wr[9:7]        = 3'd4;            // dmb_thresh_pretrig[2:0]=hit_thresh_pretrig default
  seq_clct_wr[12:10]        = 3'd4;            // Minimum post-drift pattern hits for a valid pattern
  seq_clct_wr[14:13]        = 2'd2;            // CSC Drift delay clocks
  seq_clct_wr[15]          = 1'b0;            // Pretrigger and halt until unhalt arrives
  end

  assign triad_persist[3:0]    = seq_clct_wr[3:0];      // RW  Triad 1/2-strip persistence
  assign hit_thresh_pretrig[2:0]  = seq_clct_wr[6:4];      // RW  Hits on pattern template pre-trigger threshold
  assign dmb_thresh_pretrig[2:0]  = seq_clct_wr[9:7];      // RW  dmb_thresh_pretrig[2:0]=hit_thresh_pretrig default
  assign hit_thresh_postdrift[2:0]= seq_clct_wr[12:10];    // RW  Minimum post-drift pattern hits for a valid pattern
  assign drift_delay[1:0]      = seq_clct_wr[14:13];    // RW  CSC Drift delay clocks
  assign pretrig_halt        = seq_clct_wr[15];      // RW  Pretrigger and halt until unhalt arrives
  assign seq_clct_rd[15:0]    = seq_clct_wr[15:0];    //    Readback

// Clear triad one-shots if persistence is changed
  parameter triad_clr_width = 3;
  reg [1:0] triad_cnt = 0;
  reg triad_clr       = 0;

  wire triad_cnt_busy = (triad_cnt != 0);
  
  always @(posedge clock) begin
  if    (global_reset  ) triad_cnt <= 0;
  else if  (wr_seq_clct   ) triad_cnt <= triad_clr_width;
  else if (triad_cnt_busy) triad_cnt <= triad_cnt-1'b1;
  end

  always @(posedge clock) begin
  triad_clr <= triad_cnt_busy;
  end

//------------------------------------------------------------------------------------------------------------------
// ADR_SEQ_FIFO=72    Sequencer FIFO Control Register
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
  seq_fifo_wr[2:0]        = 3'd1;            // FIFO Mode 0=no dump,1=full,2=local,3=sync, 4=nodaq
  seq_fifo_wr[7:3]        = 5'd7;            // Number FIFO time bins to read out
  seq_fifo_wr[12:8]        = 5'd2;            // Number FIFO time bins before pretrigger
  seq_fifo_wr[13]          = 1'd0;            // 1=do not wait to store raw hits
  seq_fifo_wr[14]          = 0;            // Free 1
  seq_fifo_wr[15]          = 0;            // Enable blocked bits in dmb readout
  end

  assign fifo_mode[2:0]      = seq_fifo_wr[2:0];      // RW  FIFO Mode 0=no dump,1=full,2=local,3=sync
  assign fifo_tbins_cfeb[4:0]    = seq_fifo_wr[7:3];      // RW  Number FIFO time bins to read out
  assign fifo_pretrig_cfeb[4:0]  = seq_fifo_wr[12:8];    // RW  Number FIFO time bins before pretrigger
  assign fifo_no_raw_hits      = seq_fifo_wr[13];      // RW  1=do not wait to store raw hits
  assign bcb_read_enable          = seq_fifo_wr[15];      // RW  Enable blocked bits in dmb readout

  assign seq_fifo_rd[15:0]    = seq_fifo_wr[15:0];    //    Readback

//------------------------------------------------------------------------------------------------------------------
// ADR_SEQ_L1A=74    Sequencer Level 1 Accept Configuration Register  
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
  seq_l1a_wr[7:0]   = 8'd128; // Level 1 Accept delay from pretrig status output
  seq_l1a_wr[11:8]  = 4'd3;   // Level 1 Accept window width after delay
  seq_l1a_wr[12]    = 1'b0;   // 1=Generate internal Level 1, overrides external
  seq_l1a_wr[15:13] = 3'd0;   // Delay internal l1a to shift position in l1a match window
  end

  assign l1a_delay[7:0]        = seq_l1a_wr[7:0];   // RW  Level1 Accept delay from pretrig status output
  assign l1a_window[3:0]       = seq_l1a_wr[11:8];  // RW  Level1 Accept window width after delay
  assign l1a_internal          = seq_l1a_wr[12];    // RW  Generate internal Level 1, overrides external
  assign l1a_internal_dly[2:0] = seq_l1a_wr[15:13]; // RW  Delay internal l1a to shift position in l1a match window
  assign l1a_internal_dly[3]   = 0;                 //    Ran out of bits =:-( 
  assign seq_l1a_rd[15:0]      = seq_l1a_wr[15:0];  //    Readback

//------------------------------------------------------------------------------------------------------------------
// ADR_SEQ_OFFSET0=76  Sequencer Counter Offsets Register  [continued in Adr 0x10A]
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
  seq_offset0_wr[3:0]        = 4'h0;            // L1A counter preset value
  seq_offset0_wr[15:4]      = 12'h000;          // BXN offset at reset, for pretrig bxn
  end

  assign l1a_offset[11:0]      = {8'h00,seq_offset0_wr[3:0]};  // RW  L1A counter preset value
  assign bxn_offset_pretrig[11:0]  = seq_offset0_wr[15:4];      // RW  BXN offset at reset, for pretrig bxn
  assign seq_offset0_rd[15:0]    = seq_offset0_wr[15:0];      //    Readback

//------------------------------------------------------------------------------------------------------------------
// ADR_SEQ_CLCT0   =78  Sequencer Latched CLCT0, Readonly
// ADR_SEQ_CLCT1   =7A  Sequencer Latched CLCT1, Readonly
// ADR_SEQ_TRIG_SRC=7C  Sequencer Trigger source, Readonly + Sync status
//------------------------------------------------------------------------------------------------------------------
// Sequencer Register: Latched CLCT0 LSBs
  assign seq_clct0_rd[15:0]    = clct0_vme[15:0];      // R  First CLCT

// Sequencer Register: Latched CLCT1 LSBs
  assign seq_clct1_rd[15:0]    = clct1_vme[15:0];      // R  Second CLCT

// Sequencer Register: Trigger Source Readback
  assign seq_trig_source_rd[10:0]  = trig_source_vme[10:0];  // R  Trigger source vector
  assign seq_trig_source_rd[15:11]  = 0;          // R  Unassigned

//------------------------------------------------------------------------------------------------------------------
// ADR_DMB_RAM_ADR  =7E  Sequencer Raw Hits RAM Address Register
// ADR_DMB_RAM_WDATA=80  Sequencer RAM Write Data
// ADR_DMB_RAM_WDCNT=82  Sequencer RAM Word Count, Readonly
// ADR_DMB_RAM_RDATA=84  Sequencer RAM Read Data,  Readonly
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  parameter DEF_RAM_WDATA      = 18'h00000;        // Raw hits RAM VME write data
  initial begin
  dmb_ram_adr_wr[11:0]      = 12'h000;          // Raw hits RAM VME read/write address
  dmb_ram_adr_wr[12]        = 1'b0;            // Raw hits RAM VME write enable
  dmb_ram_adr_wr[13]        = 1'b0;            // Raw hits RAM VME address reset
  dmb_ram_adr_wr[15:14]      = DEF_RAM_WDATA[17:16];    // Raw hits RAM VME write data
  end

// Sequencer register ADR_DMB_RAM_ADR Raw Hits RAM Address
  assign dmb_adr[11:0]      = dmb_ram_adr_wr[11:0];    // RW  Raw hits RAM VME read/write address
  assign dmb_wr          = dmb_ram_adr_wr[12];    // RW  Raw hits RAM VME write enable
  assign dmb_reset        = dmb_ram_adr_wr[13];    // RW  Raw hits RAM VME address reset
  assign dmb_wdata[17:16]      = dmb_ram_adr_wr[15:14];  // RW  Raw hits RAM VME write data
  assign dmb_ram_adr_rd[15:0]    = dmb_ram_adr_wr[15:0];    //    Readback

// Sequencer register ADR_DMB_RAM_WDATA Raw Hits Ram Write Data LSBs
  initial begin
  dmb_ram_wdata_wr[15:0]      = DEF_RAM_WDATA[15:0];    // Power-up default
  end

  assign dmb_wdata[15: 0]      = dmb_ram_wdata_wr[15:0];  // RW  Raw hits RAM VME write data
  assign dmb_ram_wdata_rd[15:0]  = tmb_trig_wr[15:0];    //    Readback

// Sequencer register ADR_DMB_RAM_WDCNT Raw Hits Ram Word Count + Read Data MSBs
  assign dmb_ram_wdcnt_rd[11: 0]  = dmb_wdcnt[11: 0];      // R  Raw hits RAM VME word count
  assign dmb_ram_wdcnt_rd[13:12]  = dmb_rdata[17:16];      // R  Raw hits RAM VME read data MSBs
  assign dmb_ram_wdcnt_rd[14]    = dmb_busy;          // R  Raw hits RAM VME busy writing DMB data
  assign dmb_ram_wdcnt_rd[15]    = 0;

// Sequencer RegisterADR_DMB_RAM_RDATA Raw Hits Ram Read Data LSBs
  assign dmb_ram_rdata_rd[15: 0]  = dmb_rdata[15: 0];      // R  Raw hits RAM VME read data LSBs
  
//------------------------------------------------------------------------------------------------------------------
// ADR_TMB_TRIG=86    TMB Trigger Configuration Register
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
  tmb_trig_wr[1:0]        = 2'b11;          // 1=Allow sync_err to MPC for either muon
  tmb_trig_wr[2]          = 1'b0;            // 1=Allow ALCT only
  tmb_trig_wr[3]          = 1'b1;            // 1=Allow CLCT only
  tmb_trig_wr[4]          = 1'b1;            // 1=Allow ALCT+CLCT match
  tmb_trig_wr[8:5]        = 4'd7;            // Delay for MPC response
  tmb_trig_wr[12:9]        = 0;            // Readonly
  tmb_trig_wr[13]          = 1;            // 1=MPC gets ttc_bx0 or 0=bx0_local aka clct_bx0
  tmb_trig_wr[14]          = 0;            // 1=blank mpc output except on trigger, blocks bx0 to mpc
  tmb_trig_wr[15]          = 1;            // 1=enable output to mpc, 0 asets mpc driver FFs to 1s
  end

  assign tmb_sync_err_en[1:0]    = tmb_trig_wr[1:0];      // RW  Allow sync_err to MPC for either muon
  assign tmb_allow_alct      = tmb_trig_wr[2];      // RW  Allow ALCT only 
  assign tmb_allow_clct      = tmb_trig_wr[3];      // RW  Allow CLCT only
  assign tmb_allow_match      = tmb_trig_wr[4];      // RW  Allow ALCT+CLCT match
  assign mpc_rx_delay[3:0]    = tmb_trig_wr[8:5];      // RW  Delay for MPC response
  assign mpc_sel_ttc_bx0      = tmb_trig_wr[13];      // RW  1=MPC gets ttc_bx0 or 0=bx0_local
  assign mpc_idle_blank      = tmb_trig_wr[14];      // RW  1=blank mpc output except on trigger, block bx0 too
  assign mpc_oe          = tmb_trig_wr[15];      // RW  1=MPC output enable, 0=aset outputs to 1s

  assign tmb_trig_rd[ 8:0]    = tmb_trig_wr[ 8:0];    //    Readback
  assign tmb_trig_rd[10:9]    = mpc_accept_vme[1:0];    // R  MPC accept response
  assign tmb_trig_rd[12:11]    = mpc_reserved_vme[1:0];  // R  MPC reserved response
  assign tmb_trig_rd[15:13]    = tmb_trig_wr[15:13];    //    Readback

//------------------------------------------------------------------------------------------------------------------
// ADR_MPC0_FRAME0=88    MPC0 Frame 0 Data sent to MPC, Readonly
// ADR_MPC0_FRAME1=8A    MPC0 Frame 1 Data sent to MPC, Readonly
// ADR_MPC1_FRAME0=8C    MPC1 Frame 0 Data sent to MPC, Readonly
// ADR_MPC1_FRAME1=8E    MPC1 Frame 1 Data sent to MPC, Readonly
//------------------------------------------------------------------------------------------------------------------
// TMB Registers: Latched Data Sent to MPC (before injector)
  assign mpc0_frame0_rd[15:0]    = mpc0_frame0_vme[15:0];  // R  1st in time, 1st muon
  assign mpc0_frame1_rd[15:0]    = mpc0_frame1_vme[15:0];  // R  2nd in time, 1st muon
  assign mpc1_frame0_rd[15:0]    = mpc1_frame0_vme[15:0];  // R  1st in time, 2nd muon
  assign mpc1_frame1_rd[15:0]    = mpc1_frame1_vme[15:0];  // R  2nd in time, 2nd muon

// Power-up defaults
  initial begin
    mpc_frames_fifo_ctrl_wr[0] = 1'b1; // FIFO write control register set in VME. Default = 1
    mpc_frames_fifo_ctrl_wr[1] = 1'b0; // FIFO read control register set in VME. After reading one "event" from FIFO the register resets to 0. Default = 0.
  end

// Assign MPC frames to input of FIFO
  wire [63:0] mpc_frames_fifo_wr;
  assign      mpc_frames_fifo_wr[15:0]  = mpc0_frame0_vme[15:0];
  assign      mpc_frames_fifo_wr[31:16] = mpc0_frame1_vme[15:0];
  assign      mpc_frames_fifo_wr[47:32] = mpc1_frame0_vme[15:0];
  assign      mpc_frames_fifo_wr[63:48] = mpc1_frame1_vme[15:0];

// Set "FIFO write enable" for one clock if MPC frame latch
// Note: mpc_frame_vme is stroboscope - it is 1 only for one clock when MPC frames latch
  wire mpc_frames_fifo_ctrl_wr_en;
//  assign mpc_frames_fifo_ctrl_wr_en = ( mpc_frames_fifo_ctrl_wr[0] ) ? mpc_frame_vme : 1'b0; // YP FIXME!  Use FIFO write control register set in VME to disable writing to FIFO
  assign mpc_frames_fifo_ctrl_wr_en = mpc_frame_vme;

// Set "read enable" for one clock to read exactly one event from FIFO
  reg mpc_frames_fifo_ctrl_rd_en;
  reg fifo_rd_en_1;
  reg fifo_rd_en_2;
  initial begin
    mpc_frames_fifo_ctrl_rd_en<=1'b0;
    fifo_rd_en_1 <= 1'b0;
    fifo_rd_en_2 <= 1'b0;
  end
  always @(posedge clock) begin
    fifo_rd_en_1<=mpc_frames_fifo_ctrl_wr[1];
    fifo_rd_en_2<=fifo_rd_en_1;
    if ( fifo_rd_en_1 && !fifo_rd_en_2 ) begin
      mpc_frames_fifo_ctrl_rd_en<=1'b1;
    end
    else begin
      mpc_frames_fifo_ctrl_rd_en<=1'b0;
    end
  end
  
  wire [63:0]  mpc_frames_fifo_rd;
  
  wire mpc_frames_fifo_ctrl_full;
  wire mpc_frames_fifo_ctrl_wr_ack;
  wire mpc_frames_fifo_ctrl_overflow;
  wire mpc_frames_fifo_ctrl_empty;
  wire mpc_frames_fifo_ctrl_prog_full;
  wire mpc_frames_fifo_ctrl_sbiterr;
  wire mpc_frames_fifo_ctrl_dbiterr;
  
  fifo_MPCFrames ufifo_MPCFrames
  (
  .clk(       clock                          ),
  .rst(       global_reset                   ),
  .din(       mpc_frames_fifo_wr             ),
  .wr_en(     mpc_frames_fifo_ctrl_wr_en     ),
  .rd_en(     mpc_frames_fifo_ctrl_rd_en     ),
  .dout(      mpc_frames_fifo_rd             ),
  .full(      mpc_frames_fifo_ctrl_full      ),
  .wr_ack(    mpc_frames_fifo_ctrl_wr_ack    ),
  .overflow(  mpc_frames_fifo_ctrl_overflow  ),
  .empty(     mpc_frames_fifo_ctrl_empty     ),
  .prog_full( mpc_frames_fifo_ctrl_prog_full ),
  .sbiterr(   mpc_frames_fifo_ctrl_sbiterr   ),
  .dbiterr(   mpc_frames_fifo_ctrl_dbiterr   )
  );
  
  assign mpc0_frame0_fifo_rd[15:0] = mpc_frames_fifo_rd[15:0];
  assign mpc0_frame1_fifo_rd[15:0] = mpc_frames_fifo_rd[31:16];
  assign mpc1_frame0_fifo_rd[15:0] = mpc_frames_fifo_rd[47:32];
  assign mpc1_frame1_fifo_rd[15:0] = mpc_frames_fifo_rd[63:48];
  
  assign mpc_frames_fifo_ctrl_rd[0] = mpc_frames_fifo_ctrl_wr[0];
  assign mpc_frames_fifo_ctrl_rd[1] = mpc_frames_fifo_ctrl_wr[1];
  assign mpc_frames_fifo_ctrl_rd[2] = mpc_frames_fifo_ctrl_full;
  assign mpc_frames_fifo_ctrl_rd[3] = mpc_frames_fifo_ctrl_wr_ack;
  assign mpc_frames_fifo_ctrl_rd[4] = mpc_frames_fifo_ctrl_overflow;
  assign mpc_frames_fifo_ctrl_rd[5] = mpc_frames_fifo_ctrl_empty;
  assign mpc_frames_fifo_ctrl_rd[6] = mpc_frames_fifo_ctrl_prog_full;
  assign mpc_frames_fifo_ctrl_rd[7] = mpc_frames_fifo_ctrl_sbiterr;
  assign mpc_frames_fifo_ctrl_rd[8] = mpc_frames_fifo_ctrl_dbiterr;
  
//------------------------------------------------------------------------------------------------------------------
// ADR_MPC_INJ=90    MPC Injector Control Register
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
  mpc_inj_wr[7:0]          = 8'h05;          // Number frames to inject
  mpc_inj_wr[8]          = 1'b0;            // 1=Start MPC test pattern injector
  mpc_inj_wr[9]          = 1'b1;            // 1=Enable TTC injector start
  mpc_inj_wr[13:10]        = 0;            // Readonly
  mpc_inj_wr[14]          = 0;            // 1=Fire ALCT bx0 injector one-shot
  mpc_inj_wr[15]          = 0;            // 1=Fire ALCT bx0 injector one-shot
  end

  assign mpc_nframes[7:0]      = mpc_inj_wr[7:0];      // RW  Number frames to inject
  assign mpc_inject        = mpc_inj_wr[8];      // RW  Start MPC test pattern injector
  assign ttc_mpc_inj_en      = mpc_inj_wr[9];      // RW  1=Enable TTC injector start

  assign mpc_inj_alct_bx0      = mpc_inj_wr[14];      // RW  Fire ALCT bx0 injector one-shot
   assign mpc_inj_clct_bx0      = mpc_inj_wr[15];      // RW  Fire CLCT bx0 injector one-shot

  assign mpc_inj_rd[9:0]      = mpc_inj_wr[9:0];      // RW  Readback
  assign mpc_inj_rd[13:10]    = mpc_accept_rdata[3:0];  // R
  assign mpc_inj_rd[15:14]    = mpc_inj_wr[15:14];    // RW

//------------------------------------------------------------------------------------------------------------------
// ADR_MPC_RAM_ADR=92    MPC Injector RAM address Register
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
  mpc_ram_adr_wr[3:0]        = 4'b0000;          // Select RAM to write
  mpc_ram_adr_wr[7:4]        = 4'b0000;          // Select RAM to read 
  mpc_ram_adr_wr[15:8]      = 8'h00;          // Injector RAM read/write address
  end

  assign mpc_wen[3:0]        = mpc_ram_adr_wr[ 3:0];    // RW  Select RAM to write
  assign mpc_ren[3:0]        = mpc_ram_adr_wr[ 7:4];    // RW  Select RAM to read 
  assign mpc_adr[7:0]        = mpc_ram_adr_wr[15:8];    // RW  Injector RAM read/write address

  assign mpc_ram_adr_rd[15:0]    = mpc_ram_adr_wr[15:0];    //    Readback

//------------------------------------------------------------------------------------------------------------------
// ADR_MPC_RAM_WDATA=94    MPC Injector RAM Write Data Register
// ADR_MPC_RAM_RDATA=96    MPC Injector RAM Read  Data Register, Readonly
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
  mpc_ram_wdata_wr[15:0]      = 16'h0000;          // MPC Injector RAM write dat
  end

// MPC Injector Write-data
  assign mpc_wdata[15:0]      = mpc_ram_wdata_wr[15:0];  // RW  Injector RAM write data
  assign mpc_ram_wdata_rd[15:0]  = mpc_ram_wdata_wr[15:0];  //    Readback

// MPC Injector Read-data
  assign mpc_ram_rdata_rd[15:0]  = mpc_rdata[15:0];      // R  Injector RAM read  data

//------------------------------------------------------------------------------------------------------------------
// ADR_SCP_CTRL  =98    Scope Control Register
// ADR_SCP_RDATA=9A    Scope Read Data Register
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
  scp_ctrl_wr[0]          = 1;            // 1=enable channel triggers
  scp_ctrl_wr[1]          = 0;            // 1=run 0=stop
  scp_ctrl_wr[2]          = 0;            // Force a trigger
  scp_ctrl_wr[3]          = 0;            // Sequencer auto readout mode to DMB
  scp_ctrl_wr[4]          = 0;            // Nowrite preserves initial RAM contents for testing
  scp_ctrl_wr[7:5]        = 4;            // Time bins per channel code, actual tbins/ch = (tbins+1)*64
  scp_ctrl_wr[11:8]        = 0;            // RAM bank select in VME mode
  scp_ctrl_wr[12]          = 0;            // R=Waiting for trigger, w=Preserves initial RAM contents for testing
  scp_ctrl_wr[13]          = 0;            // Extended read address
  scp_ctrl_wr[15:14]        = 0;            // Free
  end

  assign scp_ch_trig_en      = scp_ctrl_wr[0];      // RW  Enable channel triggers
  assign scp_runstop        = scp_ctrl_wr[1];      // RW  1=run 0=stop
  assign scp_force_trig      = scp_ctrl_wr[2];      // RW  Force a trigger
  assign scp_auto          = scp_ctrl_wr[3];      // RW  Sequencer auto readout mode to DMB
  assign scp_nowrite        = scp_ctrl_wr[4];      // RW  Preserves initial RAM contents for testing
  assign scp_tbins[2:0]      = scp_ctrl_wr[7:5];      // RW  Time bins per channel code, actual tbins/ch = (tbins+1)*64
  assign scp_ram_sel[3:0]      = scp_ctrl_wr[11:8];    // RW  RAM bank select in VME mode

  assign scp_ctrl_rd[11:0]    = scp_ctrl_wr[11:0];    // RW  Readback
  assign scp_ctrl_rd[12]       = scp_waiting;        // R  Waiting for trigger
  assign scp_ctrl_rd[13]       = scp_trig_done;      // R  Trigger done, ready for readout
  assign scp_ctrl_rd[15:14]    = scp_ctrl_wr[15:14];    // RW  Readback

// Scope Read Data Register
  initial begin
  scp_rdata_wr[15:0]        = 0;            //     Channel data read address default
  end

  assign scp_radr[8:0]      = scp_rdata_wr[8:0];    // W  Channel data read address
  assign scp_rdata_rd[15:0]    = scp_rdata[15:0];      // R  Recorded channel data

//------------------------------------------------------------------------------------------------------------------
// ADR_CCB_CMD=9C    CCB VME TTC Command Register
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
  ccb_cmd_wr[0]          = 0;            // Disconnect ccb_cmd_bpl, use vme_ccb_cmd;
  ccb_cmd_wr[1]          = 0;            // CCB command word strobe
  ccb_cmd_wr[2]          = 0;            // CCB data word strobe
  ccb_cmd_wr[3]          = 0;            // CCB subaddress strobe
  ccb_cmd_wr[6:4]          = 0;            // Readonly
  ccb_cmd_wr[7]          = 0;            // Unassigned
  ccb_cmd_wr[15:8]        = 0;            // CCB command word
  end

  assign vme_ccb_cmd_enable    = ccb_cmd_wr[0];      // RW  Disconnect ccb_cmd_bpl, use vme_ccb_cmd
  assign vme_ccb_cmd_strobe    = ccb_cmd_wr[1];      // RW  CCB command word strobe
  assign vme_ccb_data_strobe    = ccb_cmd_wr[2];      // RW  CCB data word strobe
  assign vme_ccb_subaddr_strobe  = ccb_cmd_wr[3];      // RW  CCB subaddress strobe
  assign vme_ccb_cmd[7:0]      = ccb_cmd_wr[15:8];      // RW  CCB command word

  assign ccb_cmd_rd[3:0]      = ccb_cmd_wr[3:0];      // RW  Readback
  assign ccb_cmd_rd[6:4]      = fmm_state[2:0];      // R  FMM machine state
  assign ccb_cmd_rd[7]      = ccb_cmd_wr[7];      // RW  Unassigned
  assign ccb_cmd_rd[15:8]      = ccb_cmd_wr[15:8];      // RW  CCB command word

//------------------------------------------------------------------------------------------------------------------
// ADR_BUF_STAT0=9E    Buffer Status Registers, Readonly
// ADR_BUF_STAT1=A0
// ADR_BUF_STAT2=A2
// ADR_BUF_STAT3=A4
// ADR_BUF_STAT4=A6
//------------------------------------------------------------------------------------------------------------------
  assign buf_stat0_rd[0]    = wr_buf_ready;          // R  Write buffer is ready
  assign buf_stat0_rd[1]    = buf_stalled;          // R  Buffer write pointer hit a fence and is stalled now
  assign buf_stat0_rd[2]    = buf_q_full;          // R  All raw hits ram in use, ram writing must stop
  assign buf_stat0_rd[3]    = buf_q_empty;          // R  No fences remain on buffer stack
  assign buf_stat0_rd[4]    = buf_q_ovf_err;        // R  Tried to push when stack full
  assign buf_stat0_rd[5]    = buf_q_udf_err;        // R  Tried to pop when stack empty
  assign buf_stat0_rd[6]    = buf_q_adr_err;        // R  Fence adr popped from stack doesnt match rls adr
  assign buf_stat0_rd[7]    = buf_stalled_once;        // R  Buffer stalled at least once since last resync
  assign buf_stat0_rd[15:8]  = buf_display[7:0];        // R  Buffer fraction in use display

  assign buf_stat1_rd[10:0]  = wr_buf_adr[MXBADR-1:0];    // R  Current ddress of header write buffer
  assign buf_stat1_rd[15:11]  = 0;              // R  Free

  assign buf_stat2_rd[10:0]  = buf_fence_dist[MXBADR-1:0];  // R  Distance to 1st fence address
  assign buf_stat2_rd[15:11]  = 0;              // R  Free

  assign buf_stat3_rd[11:0]  = buf_fence_cnt[MXBADR-1+1:0];  // R  Number of fences in fence RAM currently
  assign buf_stat3_rd[15:12]  = 0;              // R  Free

  assign buf_stat4_rd[11:0]  = buf_fence_cnt_peak[MXBADR:0];  // R  Peak number of fences in fence RAM
  assign buf_stat4_rd[15:12]  = 0;              // R  Free

//------------------------------------------------------------------------------------------------------------------
// ADR_SEQMOD=AC    Sequencer Trigger Modifiers Register
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
    seq_trigmod_wr[3:0] = 1; // RW  Trigger sequencer flush state timer
    seq_trigmod_wr[4]   = 1; // RW  1=Enable frozen buffer auto clear
    seq_trigmod_wr[5]   = 0; // RW  1=allow continuous header buffer writing for invalid triggers

    seq_trigmod_wr[6]   = 1; // RW  Require wr_buffer to pretrigger
    seq_trigmod_wr[7]   = 1; // RW  Require valid pattern after drift to trigger

    seq_trigmod_wr[8]   = 1; // RW  Readout allows tmb trig pulse in L1A window (normal mode)
    seq_trigmod_wr[9]   = 0; // RW  Readout allows no tmb trig pulse in L1A window
    seq_trigmod_wr[10]  = 0; // RW  Readout allows tmb trig pulse outside L1A window
    seq_trigmod_wr[11]  = 0; // RW  Allow alct_only events to readout at L1A  

    seq_trigmod_wr[12]  = 0; // RW  Clear scintillator veto ff
    seq_trigmod_wr[13]  = 0; // R  Scintillator veto state
    seq_trigmod_wr[14]  = 0; // RW  Active cfeb flag source, 0=pretrig, 1=tmb-matching ~8bx later
    seq_trigmod_wr[15]  = 0; // RW  Event clear for aff,clct,mpc vme diagnostic registers
  end

  assign clct_flush_delay[3:0] = seq_trigmod_wr[3:0];   // RW  Trigger sequencer flush state timer
  assign wr_buf_autoclr_en     = seq_trigmod_wr[4];     // RW  Enable frozen buffer auto clear
  assign clct_wr_continuous    = seq_trigmod_wr[5];     // RW  1=allow continuous header buffer writing for invalid triggers

  assign wr_buf_required       = seq_trigmod_wr[6];     // RW  Require wr_buffer to pretrigger
  assign valid_clct_required   = seq_trigmod_wr[7];     // RW  Require valid pattern after drift to trigger

  assign l1a_allow_match       = seq_trigmod_wr[8];     // RW  Readout allows tmb trig pulse in L1A window (normal mode)
  assign l1a_allow_notmb       = seq_trigmod_wr[9];     // RW  Readout allows no tmb trig pulse in L1A window
  assign l1a_allow_nol1a       = seq_trigmod_wr[10];    // RW  Readout allows tmb trig pulse outside L1A window
  assign l1a_allow_alct_only   = seq_trigmod_wr[11];    // RW  Allow alct_only events to readout at L1A

  assign scint_veto_clr        = seq_trigmod_wr[12];    // RW  Clear scintillator veto ff
  wire   scint_veto_dummy      = seq_trigmod_wr[13];    // W  Event clear for aff,clct,mpc vme diagnostic registers
  assign active_feb_src        = seq_trigmod_wr[14];    // RW  Active cfeb flag source, 0=pretrig, 1=tmb-matching ~8bx later
  assign event_clear_vme       = seq_trigmod_wr[15];    // RW  Event clear for aff,clct,mpc vme diagnostic registers

  assign seq_trigmod_rd[12:0]  = seq_trigmod_wr[12:0];  // RW  Readback
  assign seq_trigmod_rd[13]    = scint_veto_vme;        // R  Scintillator veto state
  assign seq_trigmod_rd[15:14] = seq_trigmod_wr[15:14]; // RW  Readback

//------------------------------------------------------------------------------------------------------------------
// ADR_SEQSM    = 0xAE  Sequencer Machine State Register, Readonly
// ADR_SEQCLCTM = 0xB0  Sequencer CLCT msbs Register, Readonly
//------------------------------------------------------------------------------------------------------------------
// Sequencer Register: Machine State
  assign seq_smstat_rd[11:0]    = sequencer_state[11:0];  // R  Sequencer state machines
  assign seq_smstat_rd[15:12]    = 0;

// Sequencer Register: CLCT MSBs
  assign seq_clctmsb_rd[2:0]    = clctc_vme[2:0];      // R  Common to CLCT0/1 to TMB
  assign seq_clctmsb_rd[9:3]    = clctf_vme[6:0];      // R  Active cfeb list at TMB match
  assign seq_clctmsb_rd[13:10]  = 0;            // R  Unassigned
  assign seq_clctmsb_rd[14]    = clock_lock_lost_err;    // R  40MHz main clock lost lock FF
  assign seq_clctmsb_rd[15]    = clct_bx0_sync_err;    // R  Sync error: BXN counter==0 did not match bx0

//------------------------------------------------------------------------------------------------------------------
// ADR_TMBTIM = 0xB2  TMB ALCT*CLCT Coincidence Timing Register
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
  tmb_timing_wr[3:0]        = 4;            // Delay ALCT for CLCT match window 6/22/07
  tmb_timing_wr[7:4]        = 3;            // CLCT match window width
  tmb_timing_wr[11:8]        = 4'd0;            // MPC transmit delay
  tmb_timing_wr[15:12]      = 0;
  end

  assign alct_delay[3:0]      = tmb_timing_wr[3:0];    // RW  Delay ALCT for CLCT match window
  assign clct_window[3:0]      = tmb_timing_wr[7:4];    // RW  CLCT match window width
  assign mpc_tx_delay[3:0]    = tmb_timing_wr[11:8];    // RW  MPC transmit delay
  assign tmb_timing_rd[15:0]    = tmb_timing_wr[15:0];    // RW  Readback

//------------------------------------------------------------------------------------------------------------------
// ADR_LHC_CYCLE = 0xB4    LHC Cycle Counter Maximum BXN Register
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
  lhc_cycle_wr[11:0]        = 12'd3564;          // LHC period, max BXN count+1
  lhc_cycle_wr[15:12]        = 0;
  end

  assign lhc_cycle[11:0]      = lhc_cycle_wr[11:0];    // RW  LHC cycle max BXN
  assign lhc_cycle_rd[15:0]    = lhc_cycle_wr[15:0];    //    Readback

//------------------------------------------------------------------------------------------------------------------
// ADR_RPC_CFG   = 0xB6    RPC Configuration Register
// ADR_RPC_RDATA = 0xB8    RPC sync mode read data Register, Readonly
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
  rpc_cfg_wr[1:0]          = 2'b11;          // rpc_exists    RPC Readout list
  rpc_cfg_wr[3:2]          = 2'b00;          // RW free      Unused 
  rpc_cfg_wr[4]          = 1;            // rpc_read_enable  1 Enable RPC Readout to DMB
  rpc_cfg_wr[8:5]          = 4'h0;            // rpc_bxn_offset  RPC bunch crossing offset
  rpc_cfg_wr[9]          = 1'b0;            // rpc_bank      RPC bank select for static read
  rpc_cfg_wr[10]          = 1'b0;            // RW free      Unused
  rpc_cfg_wr[15:11]        = 0;            // W Free      Read is occupied
  end

// RPC Configuration
  assign rpc_exists[MXRPC-1:0]  = rpc_cfg_wr[1:0];      // RW  RPC Readout list
  assign rpc_read_enable      = rpc_cfg_wr[4];      // RW  1 Enable RPC Readout
  assign rpc_bxn_offset[3:0]    = rpc_cfg_wr[8:5];      // RW  RPC bunch crossing offset
  assign rpc_bank[0]        = rpc_cfg_wr[9];      // RW  RPC bank address for rpc_rdata_rd

  assign rpc_cfg_rd[10:0]      = rpc_cfg_wr[10:0];      // R  Readback
  assign rpc_cfg_rd[13:11]    = rpc_rbxn[2:0];      // R  RPC RAM read data MSBs
  assign rpc_cfg_rd[14]      = rpc_done;          // R  RPC FPGA done
  assign rpc_cfg_rd[15]      = rpc_cfg_wr[15];      // RW  Readback

// RPC  Raw Hits data, static readback for sync mode, MSBs are in rpc_rbxn
  assign rpc_rdata_rd[15:0]    = rpc_rdata[15:0];      // R  RPC RAM read data LSBs

//------------------------------------------------------------------------------------------------------------------
// ADR_RPC_RAW_DELAY=BA    RPC Raw Hits Delay Register + RPC BXN differences
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
  rpc_raw_delay_wr[3:0]      = 0;            // RPC 0 raw hits data delay value to align with CLCT
  rpc_raw_delay_wr[7:4]      = 0;            // RPC 1 raw hits data delay value
  rpc_raw_delay_wr[15:8]      = 8;            // Readonly
  end

  assign rpc0_delay[3:0]       = rpc_raw_delay_wr[3:0];  // RW  RPC raw hits data delay value
  assign rpc1_delay[3:0]       = rpc_raw_delay_wr[7:4];  // RW  RPC raw hits data delay value
  
  assign rpc_raw_delay_rd[3:0]  = rpc0_delay[3:0];      // RW  Readback
  assign rpc_raw_delay_rd[7:4]  = rpc1_delay[3:0];      // RW  Readback
  assign rpc_raw_delay_rd[11:8]  = rpc0_bxn_diff[3:0];    // R  RPC-offset
  assign rpc_raw_delay_rd[15:12]  = rpc1_bxn_diff[3:0];    // R  RPC-offset

//------------------------------------------------------------------------------------------------------------------
// ADR_RPC_INJ=BC    RPC Injector Control Register
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
  rpc_inj_wr[0]          = 1;            // RW  rpc_mask_all  1=Enable, 0=Turn off all RPC inputs
  rpc_inj_wr[1]          = 0;            // RW  injector_mask_rat  1=Enable RAT for injector trigger
  rpc_inj_wr[2]          = 1;            // RW  injector_mask_rpc  1=Enable RPC for injector trigger
  rpc_inj_wr[6:3]          = 7;            // RW  inj_delay_rat[3:0]  0 CFEB/RPC Injector waits for RAT injector
  rpc_inj_wr[7]          = 0;            // RW  rpc_inj_sel  1=Enable RAM write
  rpc_inj_wr[10:8]        = 0;            // R  rpc_inj_wdata msbs
  rpc_inj_wr[13:11]        = 0;            // R  rpc_inj_rdata msbs
  rpc_inj_wr[14]          = 0;            // RW  Free
  rpc_inj_wr[15]          = 0;            // RW  Set write_data=address
  end

// RPC Injector + r/w data msbs
  assign rpc_mask_all        = rpc_inj_wr[0];      // RW  1=Enable, 0=Turn off all RPC inputs
  assign injector_mask_rat    = rpc_inj_wr[1];      // RW  Enable RAT for injector trigger
  assign injector_mask_rpc    = rpc_inj_wr[2];      // RW  Enable RPC for injector trigger
  assign inj_delay_rat[3:0]    = rpc_inj_wr[6:3];      // RW  CFEB/RPC Injector waits for RAT injector
  assign rpc_inj_sel        = rpc_inj_wr[7];      // RW  1=Enable RAM write
  assign rpc_inj_wdata[18:16]    = rpc_inj_wr[10:8];      // RW
  assign rpc_tbins_test      = rpc_inj_wr[15];      // RW  Set write_data=address

  assign rpc_inj_rd[7:0]      = rpc_inj_wr[7:0];      // R  Injector bits
  assign rpc_inj_rd[10:8]      = rpc_inj_wr[10:8];      // R  rpc_inj_wdata msbs
  assign rpc_inj_rd[13:11]    = rpc_inj_rdata[18:16];    // R  rpc_inj_rdata msbs
  assign rpc_inj_rd[14]      = rpc_inj_wr[14];      // RW  Free
  assign rpc_inj_rd[15]      = rpc_inj_wr[15];      // RW  Set write_data=address

//------------------------------------------------------------------------------------------------------------------
// ADR_RPC_INJ_ADR  =BE    RPC Injector RAM Address Register
// ADR_RPC_INJ_WDATA=C0    RPC injector RAM write data
// ADR_RPC_INJ_RDATA=C2    RPC injector RAM read  data, Readonly
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
  rpc_inj_adr_wr[1:0]        = 0;            // wen [1:0] 1=Write enable injector RAM
  rpc_inj_adr_wr[3:2]        = 0;            // Unused
  rpc_inj_adr_wr[5:4]        = 0;            // ren [1:0] 1=Read  enable injector RAM
  rpc_inj_adr_wr[7:6]        = 0;            // Unused
  rpc_inj_adr_wr[15:8]      = 0;            // wadr[7:0] RAM read/write address
  end

  assign rpc_inj_wen[1:0]      = rpc_inj_adr_wr[1:0];    // RW  1=Write enable injector RAM
  assign rpc_inj_ren[1:0]      = rpc_inj_adr_wr[5:4];    // RW  1=Read enable Injector RAM
  assign rpc_inj_rwadr[7:0]    = rpc_inj_adr_wr[15:8];    // RW  Injector RAM read/write address
  assign rpc_inj_rwadr[9:8]    = 0;            //    Need to find a place to connect 2 bits

  assign rpc_inj_adr_rd[15:0]    = rpc_inj_adr_wr[15:0];    //    Readback

// RPC Injector Write Data, MSBs in rpc_inj
  initial begin
  rpc_inj_wdata_wr[15:0]      = 0;            // RPC Injector RAM write data
  end

  assign rpc_inj_wdata[15:0]    = rpc_inj_wdata_wr[15:0];  // RW  RPC Injector RAM write data LSBs
  assign rpc_inj_wdata_rd[15:0]  = rpc_inj_wdata_wr[15:0];  //    Readback

// RPC Injector Read Data, MSBs in rpc_inj
  assign rpc_inj_rdata_rd[15:0]  = rpc_inj_rdata[15:0];    // R  RPC Injector RAM read data LSBs

//------------------------------------------------------------------------------------------------------------------
// ADR_RPC_TBINS=C4    RPC Time bins
//------------------------------------------------------------------------------------------------------------------
  initial begin
  rpc_tbins_wr[4:0]        = 5'd7;            // Number RPC FIFO time bins to read out
  rpc_tbins_wr[9:5]        = 5'd2;            // Number RPC FIFO time bins before pretriggert
  rpc_tbins_wr[10]        = 0;            // 1=Independent RPC and CFEB tbins, 0=copy cfeb tbins
  rpc_tbins_wr[15:11]        = 0;            // Unused
  end

  wire [4:0] fifo_tbins_rpc_wr;
  wire [4:0] fifo_pretrig_rpc_wr;
  wire       rpc_decouple;

  assign fifo_tbins_rpc_wr[4:0]  = rpc_tbins_wr[4:0];    // RW  Number RPC FIFO time bins to read out
  assign fifo_pretrig_rpc_wr[4:0]  = rpc_tbins_wr[9:5];    // RW  Number RPC FIFO time bins before pretrigger
  assign rpc_decouple        = rpc_tbins_wr[10];      // RW  1=Independent rpc tbins, 0=copy cfeb tbins

  assign rpc_tbins_rd[15:0]    = rpc_tbins_wr[15:0];    //    Readback

// FF Buffer rpc tbins multiplexer
  reg [4:0] fifo_tbins_rpc   = 5'd7;
  reg [4:0] fifo_pretrig_rpc = 5'd2;

  always @(posedge clock) begin
  fifo_tbins_rpc[4:0]    <= (rpc_decouple) ? fifo_tbins_rpc_wr[4:0]   : fifo_tbins_cfeb[4:0];  
  fifo_pretrig_rpc[4:0] <= (rpc_decouple) ? fifo_pretrig_rpc_wr[4:0] : fifo_pretrig_cfeb[4:0];
  end

//------------------------------------------------------------------------------------------------------------------
// ADR_RPC0_HCM=C6    RPC0 Hot Channel Mask Register
// ADR_RPC1_HCM=C8    RPC1 Hot Channel Mask Register
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
  rpc0_hcm_wr[15:0]        = 16'hFFFF;          // bit(n)=1=enable RPC pad (n)
  rpc1_hcm_wr[15:0]        = 16'hFFFF;          // bit(n)=1=enable RPC pad (n)
  end

  assign rpc0_hcm[MXRPCPAD-1:0]  = rpc0_hcm_wr[15:0];    // RW  1=enable RPC pad
  assign rpc1_hcm[MXRPCPAD-1:0]  = rpc1_hcm_wr[15:0];    // RW  1=enable RPC pad

  assign rpc0_hcm_rd[15:0]    = rpc0_hcm_wr[15:0];    //    Readback
  assign rpc1_hcm_rd[15:0]    = rpc1_hcm_wr[15:0];    //    Readback

//------------------------------------------------------------------------------------------------------------------
// ADR_BX0_DELAY=CA    BX0 to MPC Delays
//------------------------------------------------------------------------------------------------------------------
  initial begin
  bx0_delay_wr[3:0]        = 0;            // ALCT bx0 delay to mpc transmitter 
  bx0_delay_wr[7:4]        = 0;            // CLCT bx0 delay to mpc transmitter
  bx0_delay_wr[8]          = 1;            // 1=Enable using alct bx0, else copy clct bx0
  bx0_delay_wr[9]          = 0;            // Sets clct_bx0=lct0_vpf for bx0 alignment tests
  bx0_delay_wr[10]        = 0;            // Readonly
  bx0_delay_wr[15:11]        = 0;            // Free
  end

  assign alct_bx0_delay[3:0]    = bx0_delay_wr[3:0];    // RW  ALCT bx0 delay to mpc transmitter
  assign clct_bx0_delay[3:0]    = bx0_delay_wr[7:4];    // RW  CLCT bx0 delay to mpc transmitter
  assign alct_bx0_enable      = bx0_delay_wr[8];      // RW  1=Enable using alct bx0, else copy clct bx0
  assign bx0_vpf_test        = bx0_delay_wr[9];      // RW  Sets clct_bx0=lct0_vpf for bx0 alignment tests

  assign bx0_delay_rd[9:0]    = bx0_delay_wr[9:0];    // RW  Readback
  assign bx0_delay_rd[10]      = bx0_match;        // R  ALCT bx0 and CLCT bx0 match in time
  assign bx0_delay_rd[15:11]    = bx0_delay_wr[15:11];    // RW  Readback

//------------------------------------------------------------------------------------------------------------------
// ADR_NON_TRIG_RO=CC  Non-Triggering Readout Events, ME1A/B reversal
//------------------------------------------------------------------------------------------------------------------
  initial begin
  non_trig_ro_wr[0]        = 0;            // RW  tmb_allow_alct_ro  Allow ALCT only  readout, non-triggering
  non_trig_ro_wr[1]        = 1;            // RW  tmb_allow_clct_ro  Allow CLCT only  readout, non-triggering
  non_trig_ro_wr[2]        = 1;            // RW  tmb_allow_match_ro  Allow Match only readout, non-triggering
  non_trig_ro_wr[3]        = 1;            // RW  Block ME1A LCTs from MPC, but still queue for L1A readout
  non_trig_ro_wr[4]        = 0;            // RW  1=allow clct pretrig counters 6,7 count non me1ab pretrigs

  non_trig_ro_wr[5]        = 0;            // R  1=ME1A or ME1B CSC type
  non_trig_ro_wr[6]        = 0;            // R  1=Staggered CSC, 0=non-staggered
  non_trig_ro_wr[7]        = 0;            // R  1=Reverse staggered CSC, non-me1
  non_trig_ro_wr[8]        = 0;            // R  1=reverse me1a hstrips prior to pattern sorting
  non_trig_ro_wr[9]        = 0;            // R  1=reverse me1b hstrips prior to pattern sorting

  non_trig_ro_wr[11:10]      = 0;            // RW  Free 2
  non_trig_ro_wr[15:12]      = 0;            // R  Firmware compile type
  end

  assign tmb_allow_alct_ro    = non_trig_ro_wr[0];    // RW  Allow ALCT only  readout, non-triggering
  assign tmb_allow_clct_ro    = non_trig_ro_wr[1];    // RW  Allow CLCT only  readout, non-triggering
  assign tmb_allow_match_ro    = non_trig_ro_wr[2];    // RW  Allow Match only readout, non-triggering
  assign mpc_me1a_block      = non_trig_ro_wr[3];    // RW  Block ME1A LCTs from MPC, but still queue for L1A readout
  assign cnt_non_me1ab_en      = non_trig_ro_wr[4];    // RW  Allow clct pretrig counters count non me1ab

  assign non_trig_ro_rd[4:0]    = non_trig_ro_wr[4:0];    // RW  Readback
  assign non_trig_ro_rd[5]    = csc_me1ab;        // R  1=ME1A or ME1B CSC type
  assign non_trig_ro_rd[6]    = stagger_hs_csc;      // R  1=Staggered CSC, 0=non-staggered
  assign non_trig_ro_rd[7]    = reverse_hs_csc;      // R  1=Reverse staggered CSC, non-me1
  assign non_trig_ro_rd[8]    = reverse_hs_me1a;      // R  1=reverse me1a hstrips prior to pattern sorting
  assign non_trig_ro_rd[9]    = reverse_hs_me1b;      // R  1=reverse me1b hstrips prior to pattern sorting
  assign non_trig_ro_rd[11:10]  = non_trig_ro_wr[11:10];  // RW  Free 2
  assign non_trig_ro_rd[15:12]  = csc_type[3:0];      // R  Firmware compile type

//------------------------------------------------------------------------------------------------------------------
// ADR_SCP_TRIG=CE  Scope Channel Trigger Source Register
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
  scp_trigger_ch_wr[7:0]      = 0;            // Scope trigger channel, ch0= pretrig
  scp_trigger_ch_wr[14:8]      = 0;            // Free
  scp_trigger_ch_wr[15]      = 0;            // Channel source overlay
  end

  assign scp_trigger_ch[7:0]    = scp_trigger_ch_wr[7:0];  // RW  Scope trigger channel
  assign scp_ch_overlay      = scp_trigger_ch_wr[15];  // RW  Channel source overlay

  assign scp_trigger_ch_rd[15:0]  = scp_trigger_ch_wr[15:0];  //    Readback

//------------------------------------------------------------------------------------------------------------------
// ADR_CNT_CTRL=0xD0  Trigger/Readout Counter Control Register                                                        
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
    cnt_ctrl_wr[0]    = 0; // RW  1=reset all counters
    cnt_ctrl_wr[1]    = 0; // RW  1=take snapshot of current count
    cnt_ctrl_wr[2]    = 0; // RW  1=Stop all counters if any overflows
    cnt_ctrl_wr[3]    = 0; // R  At least one alct counter overflowed
    cnt_ctrl_wr[4]    = 0; // R  At least one sequencer counter overflowed
    cnt_ctrl_wr[5]    = 1; // RW  1=Enable alct lct error alct debug counter
    cnt_ctrl_wr[6]    = 0; // RW  1=Clear VME    counters on ttc_resync
    cnt_ctrl_wr[7]    = 1; // RW  1=Clear Header counters on ttc_resync
    cnt_ctrl_wr[8]    = 0; // RW  0=read counter lower 16 bits, 1=upper 14 
    cnt_ctrl_wr[14:9] = 0; // RW  Counter address
    cnt_ctrl_wr[15]   = 0; // RW  Parity error reset
  end

  wire [6:0] cnt_select;
  wire       cnt_snapshot;
  wire       cnt_all_reset_vme;
  wire       cnt_clear_on_resync;

  assign cnt_all_reset_vme   = cnt_ctrl_wr[0];    // RW  1=reset all VME counters (doesnt clear header)
  assign cnt_snapshot        = cnt_ctrl_wr[1];    // RW  1=take snapshot of current count
  assign cnt_stop_on_ovf     = cnt_ctrl_wr[2];    // RW  1=Stop all counters if any overflows
  assign cnt_alct_debug      = cnt_ctrl_wr[5];    // RW  1=Enable alct lct error alct debug counter
  assign cnt_clear_on_resync = cnt_ctrl_wr[6];    // RW  1=Clear VME    counters on ttc_resync
  assign hdr_clear_on_resync = cnt_ctrl_wr[7];    // RW  1=Clear Header counters on ttc_resync
  assign cnt_adr_lsb         = cnt_ctrl_wr[8];    // RW  0=read counter lower 16 bits, 1=upper 14 
  assign cnt_select[6:0]     = cnt_ctrl_wr[15:9]; // RW  Counter address

  assign cnt_ctrl_rd[2:0]    = cnt_ctrl_wr[2:0];  // RW  Readback
  assign cnt_ctrl_rd[3]      = cnt_any_ovf_alct;  // R  At least one alct counter overflowed
  assign cnt_ctrl_rd[4]      = cnt_any_ovf_seq;   // R  At least one sequencer counter overflowed
  assign cnt_ctrl_rd[15:5]   = cnt_ctrl_wr[15:5]; // RW  Readback

  assign cnt_all_reset       = cnt_all_reset_vme || (ttc_resync && cnt_clear_on_resync);
  
  // x_oneshot is Digital One-Shot defined in utils/x_oneshot.v
  x_oneshot usnap (.d(cnt_snapshot),.clock(clock),.q(cnt_snapshot_os));

//------------------------------------------------------------------------------------------------------------------
// ADR_CNT_RDATA=0xD2  Trigger/Readout Counter Data Register                                                          
//------------------------------------------------------------------------------------------------------------------
// Remap 1D counters to 2D, because XST does not support 2D ports
  parameter MXCNT = 93;                     // Number of counters, last counter id is mxcnt-1
  reg  [MXCNTVME-1:0] cnt_snap [MXCNT-1:0]; // Event counter snapshot 2D
  wire [MXCNTVME-1:0] cnt      [MXCNT-1:0]; // Event counter 2D map

// ALCT Event Counters
  assign cnt[0]  = event_counter0;
  assign cnt[1]  = event_counter1;
  assign cnt[2]  = event_counter2;
  assign cnt[3]  = event_counter3;
  assign cnt[4]  = event_counter4;
  assign cnt[5]  = event_counter5;
  assign cnt[6]  = event_counter6;
  assign cnt[7]  = event_counter7;
  assign cnt[8]  = event_counter8;
  assign cnt[9]  = event_counter9;
  assign cnt[10] = event_counter10;
  assign cnt[11] = event_counter11;
  assign cnt[12] = event_counter12;

// CLCT Event Counters
  assign cnt[13]  = event_counter13;
  assign cnt[14]  = event_counter14;
  assign cnt[15]  = event_counter15;
  assign cnt[16]  = event_counter16;
  assign cnt[17]  = event_counter17;
  assign cnt[18]  = event_counter18;
  assign cnt[19]  = event_counter19;
  assign cnt[20]  = event_counter20;
  assign cnt[21]  = event_counter21;
  assign cnt[22]  = event_counter22;
  assign cnt[23]  = event_counter23;
  assign cnt[24]  = event_counter24;
  assign cnt[25]  = event_counter25;
  assign cnt[26]  = event_counter26;
  assign cnt[27]  = event_counter27;
  assign cnt[28]  = event_counter28;
  assign cnt[29]  = event_counter29;
  assign cnt[30]  = event_counter30;

// TMB Event Counters
  assign cnt[31]  = event_counter31;
  assign cnt[32]  = event_counter32;
  assign cnt[33]  = event_counter33;
  assign cnt[34]  = event_counter34;
  assign cnt[35]  = event_counter35;
  assign cnt[36]  = event_counter36;
  assign cnt[37]  = event_counter37;
  assign cnt[38]  = event_counter38;
  assign cnt[39]  = event_counter39;
  assign cnt[40]  = event_counter40;
  assign cnt[41]  = event_counter41;
  assign cnt[42]  = event_counter42;
  assign cnt[43]  = event_counter43;
  assign cnt[44]  = event_counter44;
  assign cnt[45]  = event_counter45;
  assign cnt[46]  = event_counter46;
  assign cnt[47]  = event_counter47;
  assign cnt[48]  = event_counter48;
  assign cnt[49]  = event_counter49;
  assign cnt[50]  = event_counter50;
  assign cnt[51]  = event_counter51;
  assign cnt[52]  = event_counter52;
  assign cnt[53]  = event_counter53;
  assign cnt[54]  = event_counter54;

// L1A Counters
  assign cnt[55]  = event_counter55; // L1A received
  assign cnt[56]  = event_counter56; // L1A received, TMB in L1A window
  assign cnt[57]  = event_counter57; // L1A received, no TMB in window
  assign cnt[58]  = event_counter58; // TMB triggered, no L1A in window
  assign cnt[59]  = event_counter59; // TMB readouts completed
  assign cnt[60]  = event_counter60; // TMB readouts lost by 1-event-per-L1A limit

// STAT Counters
  assign cnt[61]  = event_counter61;
  assign cnt[62]  = event_counter62;
  assign cnt[63]  = event_counter63;
  assign cnt[64]  = event_counter64;
  assign cnt[65]  = event_counter65;

// Header Counters, not reset via direct VME command
  assign cnt[66]  = pretrig_counter; // Pre-trigger counter
  assign cnt[67]  = clct_counter;    // CLCT counter
  assign cnt[68]  = trig_counter;    // TMB trigger counter
  assign cnt[69]  = alct_counter;    // ALCTs received counter
  assign cnt[70]  = l1a_rx_counter;  // L1As received from ccb counter, only 12 bits
  assign cnt[71]  = readout_counter; // Readout counter, only 12 bits
  assign cnt[72]  = orbit_counter;   // Orbit counter

// ALCT Structure Error Counters
  assign cnt[73]  = alct_err_counter0;
  assign cnt[74]  = alct_err_counter1;
  assign cnt[75]  = alct_err_counter2;
  assign cnt[76]  = alct_err_counter3;
  assign cnt[77]  = alct_err_counter4;
  assign cnt[78]  = alct_err_counter5;

// CCB TTC Lock Error Counters
  assign cnt[79]  = ccb_ttcrx_lost_cnt;  // Number of times lock has been lost
  assign cnt[80]  = ccb_qpll_lost_cnt;  // Number of times lock has been lost

// CLCT pre-trigger coincidence counters
// NOTE: these counters 81-87 were previously used for Virtex-6 GTX Optical Receiver Error Counters
  assign cnt[81]  = preClct_l1a_counter;  // CLCT pre-trigger AND L1A coincidence counter
  assign cnt[82]  = preClct_alct_counter; // CLCT pre-trigger AND ALCT coincidence counter

// Active CFEB(s) counters
// NOTE: counters 81-87 were previously used for Virtex-6 GTX Optical Receiver Error Counters
  assign cnt[83]  = active_cfeb0_event_counter;      // CFEB0 active flag sent to DMB
  assign cnt[84]  = active_cfeb1_event_counter;      // CFEB1 active flag sent to DMB
  assign cnt[85]  = active_cfeb2_event_counter;      // CFEB2 active flag sent to DMB
  assign cnt[86]  = active_cfeb3_event_counter;      // CFEB3 active flag sent to DMB
  assign cnt[87]  = active_cfeb4_event_counter;      // CFEB4 active flag sent to DMB
  assign cnt[88]  = active_cfeb5_event_counter;      // CFEB5 active flag sent to DMB
  assign cnt[89]  = active_cfeb6_event_counter;      // CFEB6 active flag sent to DMB
  assign cnt[90]  = active_cfebs_me1a_event_counter; // ME1a CFEB active flag sent to DMB
  assign cnt[91]  = active_cfebs_me1b_event_counter; // ME1b CFEB active flag sent to DMB
  assign cnt[92]  = active_cfebs_event_counter;      // Any CFEB active flag sent to DMB
  
// Virtex-6 GTX Optical Receiver Error Counters
//  assign cnt[81]  = gtx_rx_err_count0;  // Error count on this fiber channel
//  assign cnt[82]  = gtx_rx_err_count1;
//  assign cnt[83]  = gtx_rx_err_count2;
//  assign cnt[84]  = gtx_rx_err_count3;
//  assign cnt[85]  = gtx_rx_err_count4;
//  assign cnt[86]  = gtx_rx_err_count5;
//  assign cnt[87]  = gtx_rx_err_count6;

// Snapshot current value of all counters at once
  genvar j;
  generate
    for (j=0; j<MXCNT; j=j+1) begin: gensnap
      always @(posedge clock) begin
        if (!power_up      ) cnt_snap[j] <= {MXCNTVME{1'b1}}; // Load 1s on startup, defeats warnings for short counters
        if (cnt_snapshot_os) cnt_snap[j] <= cnt[j];           // Snapshot of j-th counter
      end
    end
  endgenerate

// Latch addressed counter for readout
  reg [29:0] cnt_rdata=0; // Full 30-bit width register

  always @(posedge clock) begin
    cnt_rdata <= cnt_snap[cnt_select];
  end

// Muliplex counter halves to fit in VMED16, if lsb=0 select lower 16 bits, if lsb=1 select upper 14
  assign cnt_rdata_rd = (cnt_adr_lsb) ? cnt_rdata[29:16] : cnt_rdata[15:0];

//------------------------------------------------------------------------------------------------------------------
// ADR_UPTIME=E8  Uptime Counter Register, Readonly
//------------------------------------------------------------------------------------------------------------------
  assign uptime_rd[15:0] = uptime[15:0];    // units =25ns*3564*16384=1.46sec

//------------------------------------------------------------------------------------------------------------------
// ADR_BDSTATUS=EA    Board Status Summary Register, Readonly
//------------------------------------------------------------------------------------------------------------------
// Board Status
  reg [15:0] bd_status_ff=0;

  wire bd_status_ok =
  (vstat_5p0v && vstat_3p3v && vstat_1p8v && vstat_1p5v    && _t_crit) &&
  (vsm_ok && !vsm_aborted && vsm_cksum_ok && vsm_wdcnt_ok  && vsm_path_ok) &&
  (jsm_ok && !jsm_aborted && jsm_cksum_ok && jsm_wdcnt_ok  && jsm_tckcnt_ok);

  always @(posedge clock) begin
  bd_status_ff[ 0]  <= bd_status_ok;      // Voltages OK, temperature OK, prom-load OK

  bd_status_ff[ 1]  <= vstat_5p0v;        // Voltage Comparator +5.0V, 1=OK
  bd_status_ff[ 2]  <= vstat_3p3v;        // Voltage Comparator +3.3V, 1=OK
  bd_status_ff[ 3]  <= vstat_1p8v;        // Voltage Comparator +1.8V, 1=OK
  bd_status_ff[ 4]  <= vstat_1p5v;        // Voltage Comparator +1.5V, 1=OK
  bd_status_ff[ 5]  <= _t_crit;          // Temperature ADC Tcritical

  bd_status_ff[ 6]  <= vsm_ok;          // VME  Machine ran without errors
  bd_status_ff[ 7]  <= vsm_aborted;        // VME  State machine aborted reading PROM
  bd_status_ff[ 8]  <= vsm_cksum_ok;      // VME  Check-sum  matches PROM contents
  bd_status_ff[ 9]  <= vsm_wdcnt_ok;      // VME  Word count matches PROM contents

  bd_status_ff[10]  <= jsm_ok;          // JTAG state machine completed without errors
  bd_status_ff[11]  <= jsm_aborted;        // JTAG  State machine aborted reading PROM
  bd_status_ff[12]  <= jsm_cksum_ok;      // JTAG  Check-sum  matches PROM contents
  bd_status_ff[13]  <= jsm_wdcnt_ok;      // JTAG  Word count matches PROM contents
  bd_status_ff[14]  <= jsm_tck_fpga_ok;      // FPGA jtag tck detected
  bd_status_ff[15]  <= jsm_tckcnt_ok;      // State machine sent correct number of TCKs to jtag
  end

  assign bd_status_rd[15:0]  = bd_status_ff[15:0];  // Readback
  assign bd_status[14:0]     = bd_status_ff[14:0];  // Raw hits header limited to 14 bits width

//------------------------------------------------------------------------------------------------------------------
// ADR_BXN_CLCT=EC    CLCT bxn at pretrigger Register
// ADR_BXN_ALCT=EE    ALCT bxn at alct valid pattern flag Register
// ADR_BXN_L1A=FE    CLCT bxn at L1A
//------------------------------------------------------------------------------------------------------------------
// CLCT Bunch crossing register at pretrigger
  assign bxn_clct_rd[11:0]  = bxn_clct_vme[11:0];  // CLCT BXN at pre-trigger
  assign bxn_clct_rd[15:12]  = 0;        // Unassigned

// ALCT Bunch crossing register
  assign bxn_alct_rd[4:0]    = bxn_alct_vme[4:0];  // ALCT BXN at alct valid pattern flag
  assign bxn_alct_rd[15:5]  = 0;        // Unassigned

// CLCT Bunch crossing register at L1A
  assign bxn_l1a_rd[11:0]    = bxn_l1a_vme[11:0];  // CLCT BXN at L1A
  assign bxn_l1a_rd[15:12]  = 0;        // Unassigned

//------------------------------------------------------------------------------------------------------------------
// ADR_LAYER_TRIG=F0  Layer Trigger Mode Register
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
  layer_trig_wr[0]        = 1'b0;          // RW  1=Enable layer trigger mode
  layer_trig_wr[3:1]        = 3'd4;          // RW  Layer-wide threshold
  layer_trig_wr[6:4]        = 0;          // R  Number layers hit on layer trigger, readonly
  layer_trig_wr[7]        = 0;          // RW  Free
  layer_trig_wr[15:8]       = 0;          // RW  CLCT pre-trigger throttle
  end

  assign layer_trig_en      = layer_trig_wr[0];    // RW  Scope trigger channel
  assign lyr_thresh_pretrig[2:0]  = layer_trig_wr[3:1];  // RW  Number layers required for layer trigger
  assign clct_throttle[7:0]    = layer_trig_wr[15:8];  // RW  CLCT pre-trigger throttle

  assign layer_trig_rd[3:0]    = layer_trig_wr[3:0];  // RW  Readback
  assign layer_trig_rd[6:4]    = nlayers_hit_vme[2:0];  // R  Number layers hit on layer trigger
  assign layer_trig_rd[15:7]    = layer_trig_wr[15:7];  // RW

//------------------------------------------------------------------------------------------------------------------
// ADR_ISE_VERSION=F2  ISE Compiler version Regster
//------------------------------------------------------------------------------------------------------------------
  assign ise_version_rd[15:0]  = ISE_VERSION[15:0];

//------------------------------------------------------------------------------------------------------------------
// ADR_TEMP0=F4 Temporary Pattern Finder Register
//------------------------------------------------------------------------------------------------------------------
// Power-up defaults
  initial begin
  temp0_wr[0]            = 1;        // 1=clct_blanking
  temp0_wr[1]            = 0;        // Free
  temp0_wr[5:2]          = 4'h0;        // pid_thresh_pretrig[3:0]
  temp0_wr[9:6]          = 4'h0;        // pid_thresh_postdrift[3:0]
  temp0_wr[15:10]          = 6'd5;        // adjcfeb_dist[5:0] 5 enables hs0,1,2,3,4 and hs27,28,29,30,31
  end

  wire   clct_blanking_vme     = temp0_wr[0];    // 1=clct_blanking
//  wire   stagger_csc        = temp0_wr[1];    // 1=Staggered CSC, 0=non-staggered
  assign pid_thresh_pretrig[3:0]  = temp0_wr[5:2];  // pid_thresh_pretrig[3:0]
  assign pid_thresh_postdrift[3:0]= temp0_wr[9:6];  // pid_thresh_postdrift[3:0]
  assign adjcfeb_dist[5:0]    = temp0_wr[15:10];  // adjacent cfeb distance, 5 enables hs0,1,2,3,4 and hs27,28,29,30,31

  assign temp0_rd[15:0]      = temp0_wr[15:0];  // Readback

  wire   allow_no_blanking    = (tmb_allow_alct || l1a_allow_notmb || l1a_allow_alct_only);
  assign clct_blanking       = (allow_no_blanking) ? clct_blanking_vme : 1'b1;

//------------------------------------------------------------------------------------------------------------------
// ADR_TEMP1=F6 Temporary Pattern Finder CLCT Separation Register
//------------------------------------------------------------------------------------------------------------------
  initial begin
  temp1_wr[0]          = 1;        // CLCT separation source 1=vme, 0=ram
  temp1_wr[1]          = 0;        // CLCT separation RAM write enable
  temp1_wr[5:2]        = 0;        // CLCT separation RAM rw address VME
//  temp1_wr[6]         = 0;        // CLCT separation RAM read  data source 1=a 0=b
  temp1_wr[7:6]         = 0;        // Free
  temp1_wr[15:8]        = 10;        // CLCT separation from vme
  end

  assign clct_sep_src      = temp1_wr[0];    // CLCT separation source 1=vme, 0=ram
  assign clct_sep_ram_we    = temp1_wr[1];    // CLCT separation RAM write enable
  assign clct_sep_ram_adr[3:0]= temp1_wr[5:2];  // CLCT separation RAM rw address VME
//  assign clct_sep_ram_sel_ab  = temp1_wr[6];    // CLCT separation RAM read  data source 1=a 0=b

  assign clct_sep_vme[7:0]  = temp1_wr[15:8];  // CLCT separation from vme
  assign temp1_rd[15:0]    = temp1_wr[15:0];  // Readback

//------------------------------------------------------------------------------------------------------------------
// ADR_TEMP2=F8 Temporary Pattern Finder CLCT Separation RAM Data Register
//------------------------------------------------------------------------------------------------------------------
  initial begin
  temp2_wr[15:0]          = 0;              // CLCT separation RAM write data VME
  end

  assign clct_sep_ram_wdata[15:0]  = temp2_wr[15:0];        // CLCT separation RAM write data VME
  assign temp2_rd[15:0]      = clct_sep_ram_rdata[15:0];    // CLCT separation RAM read  data VME

//------------------------------------------------------------------------------------------------------------------
// ADR_PARITY=FA Parity errors
//------------------------------------------------------------------------------------------------------------------
  initial begin
  parity_wr[15:0]        = 0;                // Power up default
  end

  wire [3:0]  perr_adr    =  parity_wr[3:0];          // RW  Parity data bank select
  wire    perr_sump0    = |parity_wr[5:4];          // W  Unassigned
  wire    perr_reset_vme  =  parity_wr[6];          // RW  Parity error reset
  wire    perr_sump1    = |parity_wr[15:7];          // W  Unassigned

  reg [7:0]  parity_rd_mux;

  assign parity_rd[3:0]  = perr_adr[3:0];            // RW  Parity data bank select
  assign parity_rd[4]    = perr_en;                // R  Parity error latch enabled
  assign parity_rd[5]    = perr;                  // R  Parity error summary
  assign parity_rd[6]    = perr_ff;                // R  Parity error summary,  latched
  assign parity_rd[7]    = perr_reset_vme;            // RW  Parity error reset
  assign parity_rd[15:8]  = parity_rd_mux[7:0];          // R  Parity data mux

  always @* begin
  case (perr_adr)
  4'd0:  parity_rd_mux <= {2'h0,  perr_ram_ff[ 5: 0]};      // R  cfeb0 rams
  4'd1:  parity_rd_mux <= {2'h0,  perr_ram_ff[11: 6]};      // R  cfeb1 rams
  4'd2:  parity_rd_mux <= {2'h0,  perr_ram_ff[17:12]};      // R  cfeb2 rams
  4'd3:  parity_rd_mux <= {2'h0,  perr_ram_ff[23:18]};      // R  cfeb3 rams
  4'd4:  parity_rd_mux <= {2'h0,  perr_ram_ff[29:24]};      // R  cfeb4 rams
  4'd5:  parity_rd_mux <= {2'h0,  perr_ram_ff[35:30]};      // R  cfeb5 rams
  4'd6:  parity_rd_mux <= {2'h0,  perr_ram_ff[41:36]};      // R  cfeb6 rams
  4'd7:  parity_rd_mux <= {3'h0,  perr_ram_ff[46:42]};      // R  rpc   rams
  4'd8:  parity_rd_mux <= {6'h00, perr_ram_ff[48:47]};      // R  mini  rams
  4'd9:  parity_rd_mux <= {1'h0,  perr_cfeb[6:0]};        // R  cfeb parity errors
  4'd10:  parity_rd_mux <= {1'h0,  perr_cfeb_ff[6:0]};      // R  cfeb parity errors,latched
  4'd11:  parity_rd_mux <= {6'h00, perr_rpc_ff,perr_rpc};      // R  rpc  parity errors,latched
  4'd12:  parity_rd_mux <= {6'h00, perr_mini_ff, perr_mini};    // R  mini parity errors,latched
  default  parity_rd_mux <=  8'hFF;                // R  sub-addressing error flag
  endcase
  end

  x_oneshot uperr (.d(perr_reset_vme),.clock(clock),.q(perr_reset));

//------------------------------------------------------------------------------------------------------------------
// ADR_CCB_STAT1=FC  CCB Status Register, Readonly
//------------------------------------------------------------------------------------------------------------------
//  CCB TTC lock status
  assign ccb_stat1_rd[0]    = ccb_ttcrx_lock_never;      // Lock never achieved
  assign ccb_stat1_rd[1]    = ccb_ttcrx_lost_ever;       // Lock was lost at least once
  assign ccb_stat1_rd[2]    = ccb_qpll_lock_never;       // Lock never achieved
  assign ccb_stat1_rd[3]    = ccb_qpll_lost_ever;        // Lock was lost at least once
  assign ccb_stat1_rd[15:4]  = 0;                // Free

//------------------------------------------------------------------------------------------------------------------
// ADR_L1A_LOOKBACK=100 L1A Look Back Register
//------------------------------------------------------------------------------------------------------------------
  initial begin
  l1a_lookback_wr[10:0]      = 11'd128;            // RW  bxn to look back from l1a wr_buf_adr
  l1a_lookback_wr[12:11]      = 2'h0;              // RW  Injector RAM write data MSBs
  l1a_lookback_wr[14:13]      = 2'h0;              // R  Injector RAM read  data MSBs
  l1a_lookback_wr[15]        = 1;              // RW  Enable L1A window priority, limits to 1 readout per L1A
  end

  assign l1a_lookback[10:0]    = l1a_lookback_wr[10:0];    // RW  bxn to look back from l1a wr_buf_adr
  assign inj_wdata[17:16]      = l1a_lookback_wr[12:11];    // RW  Injector RAM write data MSBs
  assign l1a_win_pri_en      = l1a_lookback_wr[15];      // RW  Enable L1A window priority

  assign l1a_lookback_rd[12:0]  = l1a_lookback_wr[12:0];    // RW  Readback
  assign l1a_lookback_rd[14:13]  = inj_rdata[17:16];        // R  Injector RAM read  data MSBs
  assign l1a_lookback_rd[15]    = l1a_lookback_wr[15];      // RW  Readback

  wire l1a_lookback_sump      = |l1a_lookback_wr[14:13];

//------------------------------------------------------------------------------------------------------------------
// ADR_SEQ_DEBUG=102 Sequencer debug latches
//------------------------------------------------------------------------------------------------------------------
  initial begin
  seqdeb_wr[3:0]      = 0;                  // RW  Parity data bank select
  seqdeb_wr[4]      = 0;                  // W  Dummy L1A sr preset, keep at 0 
  seqdeb_wr[15:5]      = 0;                  // W  Unused
  end

  wire [3:0]  seqdeb_adr    =  seqdeb_wr[3:0];          // RW  Parity data bank select
  assign      l1a_preset_sr =  seqdeb_wr[4];            // W  Dummy L1A sr preset, keep at 0 
  wire    seqdeb_sump    = |seqdeb_wr[15:5];          // W  Unused

  reg [11:0]  seqdeb_rd_mux;

  assign seqdeb_rd[3:0]  = seqdeb_adr[3:0];            // RW  Parity data bank select
  assign seqdeb_rd[15:4]  = seqdeb_rd_mux[11:0];          // R  Seqdeb data mux

  always @* begin
  case (seqdeb_adr)
  4'd0:  seqdeb_rd_mux <= deb_wr_buf_adr[10:0];          // R  Buffer write address at last pretrig
  4'd1:  seqdeb_rd_mux <= deb_buf_push_adr[10:0];        // R  Queue push address at last push
  4'd2:  seqdeb_rd_mux <= deb_buf_pop_adr[10:0];          // R  Queue pop  address at last pop
  4'd3:  seqdeb_rd_mux <= deb_buf_push_data[11:0];        // R  Queue push data at last push
  4'd4:  seqdeb_rd_mux <= deb_buf_push_data[23:12];        // R
  4'd5:  seqdeb_rd_mux <= deb_buf_push_data[31:24];        // R
  4'd6:  seqdeb_rd_mux <= deb_buf_pop_data[11:0];        // R  Queue pop data at last pop
  4'd7:  seqdeb_rd_mux <= deb_buf_pop_data[23:12];        // R
  4'd8:  seqdeb_rd_mux <= deb_buf_pop_data[31:24];        // R
  default:seqdeb_rd_mux <= 0;                    // R  Unassigned
  endcase
  end

//------------------------------------------------------------------------------------------------------------------
// ADR_ALCT_SYNC_CTRL=104 ALCT sync mode control
//------------------------------------------------------------------------------------------------------------------
  initial begin
  alct_sync_ctrl_wr[3:0]        = 0;            // ALCT sync mode delay pointer to valid data
  alct_sync_ctrl_wr[4]        = 0;            // ALCT sync mode tmb transmits random data to alct
  alct_sync_ctrl_wr[5]        = 0;            // ALCT sync mode clear rng error FFs
  alct_sync_ctrl_wr[9:6]        = 0;            // Readonly
  alct_sync_ctrl_wr[11:10]      = 0;            // Free
  alct_sync_ctrl_wr[15:12]      = 10-1;            // ALCT sync mode delay pointer to valid data, fixed pre-delay
  end

  assign alct_sync_rxdata_dly[3:0]  = alct_sync_ctrl_wr[3:0];  // RW  ALCT sync mode delay pointer to valid data
  assign alct_sync_tx_random      = alct_sync_ctrl_wr[4];    // RW  ALCT sync mode tmb transmits random data to alct
  assign alct_sync_clr_err      = alct_sync_ctrl_wr[5];    // RW  ALCT sync mode clear rng error FFs
  assign alct_sync_rxdata_pre[3:0]  = alct_sync_ctrl_wr[15:12];  // RW  ALCT sync mode delay pointer to valid data, fixed pre-delay

  assign alct_sync_ctrl_rd[5:0]    = alct_sync_ctrl_wr[5:0];  // RW  Readback
  assign alct_sync_ctrl_rd[6]      = alct_sync_1st_err;    // R  ALCT sync mode 1st-intime match ok, alct-to-tmb
  assign alct_sync_ctrl_rd[7]      = alct_sync_2nd_err;    // R  ALCT sync mode 2nd-intime match ok, alct-to-tmb
  assign alct_sync_ctrl_rd[8]      = alct_sync_1st_err_ff;    // R  ALCT sync mode 1st-intime match ok, alct-to-tmb, latched
  assign alct_sync_ctrl_rd[9]      = alct_sync_2nd_err_ff;    // R  ALCT sync mode 2nd-intime match ok, alct-to-tmb, latched
  assign alct_sync_ctrl_rd[15:10]    = alct_sync_ctrl_wr[15:10];  // RW  Readback

//------------------------------------------------------------------------------------------------------------------
// ADR_ALCT_SYNC_TXDATA_1ST=106 ALCT sync mode transmit data 1st
// ADR_ALCT_SYNC_TXDATA_2ND=108 ALCT sync mode transmit data 2nd
//------------------------------------------------------------------------------------------------------------------
  initial begin
  alct_sync_txdata_1st_wr[15:0]      = 0;              // Power-up default
  alct_sync_txdata_2nd_wr[15:0]      = 0;              // Power-up default
  end

  assign alct_sync_txdata_1st[9:0]    = alct_sync_txdata_1st_wr[9:0];  // RW  ALCT sync mode data to send for loopback
  assign alct_sync_txdata_2nd[9:0]    = alct_sync_txdata_2nd_wr[9:0];  // RW  ALCT sync mode data to send for loopback

  assign alct_sync_txdata_1st_rd[15:0]  = alct_sync_txdata_1st_wr[15:0];// RW  Readback
  assign alct_sync_txdata_2nd_rd[15:0]  = alct_sync_txdata_2nd_wr[15:0];// RW  Readback

//------------------------------------------------------------------------------------------------------------------
// ADR_SEQ_OFFSET1=10A  Sequencer Counter Offsets Register  [continued from Adr 0x76]
//------------------------------------------------------------------------------------------------------------------
  initial begin
  seq_offset1_wr[11:0]      = 12'h000;            // Bxn counter for L1A preset value
  seq_offset1_wr[15:12]      = 3'h0;              // Free
  end

  assign bxn_offset_l1a[11:0]    = seq_offset1_wr[11:0];      // RW  BXN offset at reset, for pretrig bxn
  assign seq_offset1_rd[15:0]    = seq_offset1_wr[15:0];      //    Readback

//------------------------------------------------------------------------------------------------------------------
// ADR_MINISCOPE=10C Miniscope Register
//------------------------------------------------------------------------------------------------------------------
  initial begin
  miniscope_wr[0]          = 1;              // Enable Miniscope readout
  miniscope_wr[1]          = 0;              // Miniscope data=address for testing
  miniscope_wr[2]          = 1;              // Insert tbins and pretrig tbins in 1st word
  miniscope_wr[7:3]        = 22;              // Number Mini FIFO time bins to read out
  miniscope_wr[12:8]        = 4;              // Number Mini FIFO time bins before pretrigger
  miniscope_wr[15:13]        = 0;              // Free
  end
  
  assign mini_read_enable      = miniscope_wr[0];        // RW  Enable Miniscope readout
  assign mini_tbins_test      = miniscope_wr[1];        // RW  Miniscope data=address for testing
  assign mini_tbins_word      = miniscope_wr[2];        // RW  Insert tbins and pretrig tbins in 1st word
  assign fifo_tbins_mini[4:0]    = miniscope_wr[7:3] & 5'h1E;  // RW  Number Mini FIFO time bins to read out, force even
  assign fifo_pretrig_mini[4:0]  = miniscope_wr[12:8];      // RW  Number Mini FIFO time bins before pretrigger

  assign miniscope_rd[15:0]    = miniscope_wr[15:0];      //    Readback

//------------------------------------------------------------------------------------------------------------------
// ADR_PHASER0    = 0x10E DCM Phase Shifter Register: ALCT  rxd
// ADR_PHASER1    = 0x110 DCM Phase Shifter Register: ALCT  txd
// ADR_PHASER2    = 0x112 DCM Phase Shifter Register: CFEB0 rxd
// ADR_PHASER3    = 0x114 DCM Phase Shifter Register: CFEB1 rxd
// ADR_PHASER4    = 0x116 DCM Phase Shifter Register: CFEB2 rxd
// ADR_PHASER5    = 0x118 DCM Phase Shifter Register: CFEB3 rxd
// ADR_PHASER6    = 0x11A DCM Phase Shifter Register: CFEB4 rxd
// ADR_V6_PHASER7 = 0x16A DCM Phase Shifter Register: CFEB5 rxd "ME1/1A-side"
// ADR_V6_PHASER8 = 0x16C DCM Phase Shifter Register: CFEB6 rxd "ME1/1B-side"
//------------------------------------------------------------------------------------------------------------------
  wire [MXDPS-1:0] dps_fire_vme;

// Phaser 0: ALCT rxd
  initial begin
  phaser0_wr[0]          = 0;              // RW  Set new phase, software sets then unsets  
  phaser0_wr[1]          = 0;              // RW  Reset current phase to 32
  phaser0_wr[6:2]          = 0;              // R  Readonly
  phaser0_wr[7]          = 0;              // RW  Posneg
  phaser0_wr[13:8]        = 32;              // RW  Phase to set, 0-63
  phaser0_wr[14]          = 0;              // RW  Phase quarter cycle shift
  phaser0_wr[15]          = 0;              // RW  Phase half    cycle shift
  end

  assign dps_fire_vme[0]      = phaser0_wr[0];        // RW  Set new phase, software sets then unsets
  assign dps_reset[0]        = phaser0_wr[1];        // RW  Reset current phase to 32
  assign alct_rxd_posneg      = phaser0_wr[7];        // RW  Posneg
  assign dps0_phase[7:0]      = phaser0_wr[15:8];        // RW  Phase to set, 0-255

  assign phaser0_rd[1:0]      = phaser0_wr[1:0];        // RW  Readback
  assign phaser0_rd[2]      = dps_busy[0];          // R  Phase shifter busy
  assign phaser0_rd[3]      = dps_lock[0];          // R  DCM lock status
  assign phaser0_rd[6:4]      = dps0_sm_vec[2:0];        // R  Phase shifter machine state
  assign phaser0_rd[15:7]      = phaser0_wr[15:7];        // RW  Readback

// Phaser 1: ALCT txd
  initial begin
  phaser1_wr[0]          = 0;              // RW  Set new phase, software sets then unsets  
  phaser1_wr[1]          = 0;              // RW  Reset current phase to 32
  phaser1_wr[6:2]          = 0;              // R  Readonly
  phaser1_wr[7]          = 0;              // RW  Posneg
  phaser1_wr[13:8]        = 32;              // RW  Phase to set, 0-63
  phaser1_wr[14]          = 0;              // RW  Phase quarter cycle shift
  phaser1_wr[15]          = 0;              // RW  Phase half    cycle shift
  end

  assign dps_fire_vme[1]      = phaser1_wr[0];        // RW  Set new phase, software sets then unsets
  assign dps_reset[1]        = phaser1_wr[1];        // RW  Reset current phase to 32
  assign alct_txd_posneg      = phaser1_wr[7];        // RW  Posneg
  assign dps1_phase[7:0]      = phaser1_wr[15:8];        // RW  Phase to set, 0-255

  assign phaser1_rd[1:0]      = phaser1_wr[1:0];        // RW  Readback
  assign phaser1_rd[2]      = dps_busy[1];          // R  Phase shifter busy
  assign phaser1_rd[3]      = dps_lock[1];          // R  DCM lock status
  assign phaser1_rd[6:4]      = dps1_sm_vec[2:0];        // R  Phase shifter machine state
  assign phaser1_rd[15:7]      = phaser1_wr[15:7];        // RW  Readback

// Phaser 2: CFEB0 rxd
  initial begin
  phaser2_wr[0]           = 0;              // RW  Set new phase, software sets then unsets  
  phaser2_wr[1]           = 0;              // RW  Reset current phase to 32
  phaser2_wr[6:2]         = 0;              // R  Readonly
  phaser2_wr[7]           = 0;              // RW  Posneg
  phaser2_wr[13:8]        = 32;             // RW  Phase to set, 0-63
  phaser2_wr[14]          = 0;              // RW  Phase quarter cycle shift
  phaser2_wr[15]          = 0;              // RW  Phase half    cycle shift
  end

// JGhere: for OTMB, ME1/1a uses dps2 (with values from phaser 7) and  ME1/1b uses dps3 (with values from phaser 8) 
//   JRG, so dps2 write values come from phaser 7 instead of phaser 2
  assign dps_fire_vme[2]      = phaser7_wr[0];        // RW  Set new phase, software sets then unsets
  assign dps_reset[2]         = phaser7_wr[1];        // RW  Reset current phase to 32
  assign cfeb0_rxd_posneg     = phaser7_wr[7];        // RW  Posneg
  assign dps2_phase[7:0]      = phaser7_wr[15:8];     // RW  Phase to set, 0-255

// JRG: readbacks from phaser 2-6 are meaningless; for 2 & 3 you should look at phaser 7 & 8 
  assign phaser2_rd[1:0]      = phaser2_wr[1:0];      // RW  Readback
  assign phaser2_rd[2]        = dps_busy[2];          // R  Phase shifter busy
  assign phaser2_rd[3]        = dps_lock[2];          // R  DCM lock status
  assign phaser2_rd[6:4]      = dps2_sm_vec[2:0];     // R  Phase shifter machine state
  assign phaser2_rd[15:7]     = phaser2_wr[15:7];     // RW  Readback

// Phaser 3: CFEB1 rxd
  initial begin
  phaser3_wr[0]           = 0;              // RW  Set new phase, software sets then unsets  
  phaser3_wr[1]           = 0;              // RW  Reset current phase to 32
  phaser3_wr[6:2]         = 0;              // R  Readonly
  phaser3_wr[7]           = 0;              // RW  Posneg
  phaser3_wr[13:8]        = 32;             // RW  Phase to set, 0-63
  phaser3_wr[14]          = 0;              // RW  Phase quarter cycle shift
  phaser3_wr[15]          = 0;              // RW  Phase half    cycle shift
  end

//   JRG, dps3 write values come from phaser 8 instead of phaser 3
  assign dps_fire_vme[3]      = phaser8_wr[0];        // RW  Set new phase, software sets then unsets
  assign dps_reset[3]         = phaser8_wr[1];        // RW  Reset current phase to 32
  assign cfeb1_rxd_posneg     = phaser8_wr[7];        // RW  Posneg
  assign dps3_phase[7:0]      = phaser8_wr[15:8];     // RW  Phase to set, 0-255

// JRG: readbacks from phaser 2-6 are meaningless; for 2 & 3 you should look at phaser 7 & 8 
  assign phaser3_rd[1:0]      = phaser3_wr[1:0];      // RW  Readback
  assign phaser3_rd[2]        = dps_busy[3];          // R  Phase shifter busy
  assign phaser3_rd[3]        = dps_lock[3];          // R  DCM lock status
  assign phaser3_rd[6:4]      = dps3_sm_vec[2:0];     // R  Phase shifter machine state
  assign phaser3_rd[15:7]     = phaser3_wr[15:7];     // RW  Readback

// Phaser 4: CFEB2 rxd
  initial begin
  phaser4_wr[0]          = 0;              // RW  Set new phase, software sets then unsets  
  phaser4_wr[1]          = 0;              // RW  Reset current phase to 32
  phaser4_wr[6:2]          = 0;              // R  Readonly
  phaser4_wr[7]          = 0;              // RW  Posneg
  phaser4_wr[13:8]        = 32;              // RW  Phase to set, 0-63
  phaser4_wr[14]          = 0;              // RW  Phase quarter cycle shift
  phaser4_wr[15]          = 0;              // RW  Phase half    cycle shift
  end

// JRG: dps4-8 do not exist anymore, and phaser 4-6 do nothing
  assign dps_fire_vme[4]      = phaser4_wr[0];        // RW  Set new phase, software sets then unsets
  assign dps_reset[4]        = phaser4_wr[1];        // RW  Reset current phase to 32
  assign cfeb2_rxd_posneg      = phaser4_wr[7];        // RW  Posneg
  assign dps4_phase[7:0]      = phaser4_wr[15:8];        // RW  Phase to set, 0-255

// JRG: readbacks from phaser 2-6 are meaningless
  assign phaser4_rd[1:0]      = phaser4_wr[1:0];        // RW  Readback
  assign phaser4_rd[2]      = dps_busy[4];          // R  Phase shifter busy
  assign phaser4_rd[3]      = dps_lock[4];          // R  DCM lock status
  assign phaser4_rd[6:4]      = dps4_sm_vec[2:0];        // R  Phase shifter machine state
  assign phaser4_rd[15:7]      = phaser4_wr[15:7];        // RW  Readback

// Phaser 5: cfeb3 rxd
  initial begin
  phaser5_wr[0]          = 0;              // RW  Set new phase, software sets then unsets  
  phaser5_wr[1]          = 0;              // RW  Reset current phase to 32
  phaser5_wr[6:2]          = 0;              // R  Readonly
  phaser5_wr[7]          = 0;              // RW  Posneg
  phaser5_wr[13:8]        = 32;              // RW  Phase to set, 0-63
  phaser5_wr[14]          = 0;              // RW  Phase quarter cycle shift
  phaser5_wr[15]          = 0;              // RW  Phase half    cycle shift
  end

// JRG: dps4-8 do not exist anymore, and phaser 4-6 do nothing
  assign dps_fire_vme[5]      = phaser5_wr[0];        // RW  Set new phase, software sets then unsets
  assign dps_reset[5]        = phaser5_wr[1];        // RW  Reset current phase to 32
  assign cfeb3_rxd_posneg      = phaser5_wr[7];        // RW  Posneg
  assign dps5_phase[7:0]      = phaser5_wr[15:8];        // RW  Phase to set, 0-255

// JRG: readbacks from phaser 2-6 are meaningless
  assign phaser5_rd[1:0]      = phaser5_wr[1:0];        // RW  Readback
  assign phaser5_rd[2]      = dps_busy[5];          // R  Phase shifter busy
  assign phaser5_rd[3]      = dps_lock[5];          // R  DCM lock status
  assign phaser5_rd[6:4]      = dps5_sm_vec[2:0];        // R  Phase shifter machine state
  assign phaser5_rd[15:7]      = phaser5_wr[15:7];        // RW  Readback

// Phaser 6: cfeb4 rxd
  initial begin
  phaser6_wr[0]          = 0;              // RW  Set new phase, software sets then unsets  
  phaser6_wr[1]          = 0;              // RW  Reset current phase to 32
  phaser6_wr[6:2]          = 0;              // R  Readonly
  phaser6_wr[7]          = 0;              // RW  Posneg
  phaser6_wr[13:8]        = 32;              // RW  Phase to set, 0-63
  phaser6_wr[14]          = 0;              // RW  Phase quarter cycle shift
  phaser6_wr[15]          = 0;              // RW  Phase half    cycle shift
  end

// JRG: dps4-8 do not exist anymore, and phaser 4-6 do nothing
  assign dps_fire_vme[6]      = phaser6_wr[0];        // RW  Set new phase, software sets then unsets
  assign dps_reset[6]        = phaser6_wr[1];        // RW  Reset current phase to 32
  assign cfeb4_rxd_posneg      = phaser6_wr[7];        // RW  Posneg
  assign dps6_phase[7:0]      = phaser6_wr[15:8];        // RW  Phase to set, 0-255

// JRG: readbacks from phaser 2-6 are meaningless
  assign phaser6_rd[1:0]      = phaser6_wr[1:0];        // RW  Readback
  assign phaser6_rd[2]      = dps_busy[6];          // R  Phase shifter busy
  assign phaser6_rd[3]      = dps_lock[6];          // R  DCM lock status
  assign phaser6_rd[6:4]      = dps6_sm_vec[2:0];        // R  Phase shifter machine state
  assign phaser6_rd[15:7]      = phaser6_wr[15:7];        // RW  Readback

// Phaser 7: cfeb5 rxd  Virtex-6 only "ME1/1A-side"
  initial begin
  phaser7_wr[0]          = 0;              // RW  Set new phase, software sets then unsets  
  phaser7_wr[1]          = 0;              // RW  Reset current phase to 32
  phaser7_wr[6:2]        = 0;              // R  Readonly
  phaser7_wr[7]          = 0;              // RW  Posneg
  phaser7_wr[13:8]       = 32;             // RW  Phase to set, 0-63
  phaser7_wr[14]         = 0;              // RW  Phase quarter cycle shift
  phaser7_wr[15]         = 0;              // RW  Phase half    cycle shift
  end

  assign dps_fire_vme[7]      = phaser7_wr[0];        // RW  Set new phase, software sets then unsets
  assign dps_reset[7]         = phaser7_wr[1];        // RW  Reset current phase to 32
  assign cfeb5_rxd_posneg     = phaser7_wr[7];        // RW  Posneg    // JGhere: apply this value for all A-side cfebs
  assign dps7_phase[7:0]      = phaser7_wr[15:8];     // RW  Phase to set, 0-255

// JGhere: for OTMB, ME1/1a uses dps2 (with values from phaser 7) and  ME1/1b uses dps3 (with values from phaser 8) 
//   JRG, so phaser7 read values come from dps2 instead of dps7 (which no longer exists)
  assign phaser7_rd[1:0]      = phaser7_wr[1:0];      // RW  Readback
  assign phaser7_rd[2]        = dps_busy[2];          // R  Phase shifter busy
  assign phaser7_rd[3]        = dps_lock[2];          // R  DCM lock status
  assign phaser7_rd[6:4]      = dps2_sm_vec[2:0];     // R  Phase shifter machine state
  assign phaser7_rd[15:7]     = phaser7_wr[15:7];     // RW  Readback

// Phaser 8: cfeb6 rxd  Virtex-6 only "ME1/1B-side"
  initial begin
  phaser8_wr[0]          = 0;              // RW  Set new phase, software sets then unsets  
  phaser8_wr[1]          = 0;              // RW  Reset current phase to 32
  phaser8_wr[6:2]        = 0;              // R  Readonly
  phaser8_wr[7]          = 0;              // RW  Posneg
  phaser8_wr[13:8]       = 32;             // RW  Phase to set, 0-63
  phaser8_wr[14]         = 0;              // RW  Phase quarter cycle shift
  phaser8_wr[15]         = 0;              // RW  Phase half    cycle shift
  end

  assign dps_fire_vme[8]      = phaser8_wr[0];        // RW  Set new phase, software sets then unsets
  assign dps_reset[8]         = phaser8_wr[1];        // RW  Reset current phase to 32
  assign cfeb6_rxd_posneg     = phaser8_wr[7];        // RW  Posneg    // JGhere: apply this value for all B-side cfebs
  assign dps8_phase[7:0]      = phaser8_wr[15:8];     // RW  Phase to set, 0-255

//   JRG, phaser8 read values come from dps3 instead of dps8 (which no longer exists)
  assign phaser8_rd[1:0]      = phaser8_wr[1:0];      // RW  Readback
  assign phaser8_rd[2]        = dps_busy[3];          // R  Phase shifter busy
  assign phaser8_rd[3]        = dps_lock[3];          // R  DCM lock status
  assign phaser8_rd[6:4]      = dps3_sm_vec[2:0];     // R  Phase shifter machine state
  assign phaser8_rd[15:7]     = phaser8_wr[15:7];     // RW  Readback

// Phaser autostart after vmesm completes reading user PROM
  wire fire_phaser_auto_d = vsm_phaser_auto & vsm_ready & power_up;

  x_oneshot upfire (.d(fire_phaser_auto_d),.clock(clock),.q(fire_phaser_auto));

  assign dps_fire[MXDPS-1:0]  = {MXDPS{fire_phaser_auto}} | dps_fire_vme[MXDPS-1:0];

//------------------------------------------------------------------------------------------------------------------
// ADR_DELAY0_INT=11C DDR Interstage delays
// ADR_DELAY1_INT=11E DDR Interstage delays
//------------------------------------------------------------------------------------------------------------------
// Delay0_is
  initial begin
  delay0_int_wr[3:0]        = 0;              // RW  CFEB0 Interstage delay  
  delay0_int_wr[7:4]        = 0;              // RW  CFEB1 Interstage delay  
  delay0_int_wr[11:8]       = 0;              // RW  CFEB2 Interstage delay  
  delay0_int_wr[15:12]      = 0;              // RW  CFEB3 Interstage delay  
  end
/*
  assign cfeb0_rxd_int_delay[3:0]  = delay0_int_wr[3:0];      // RW  CFEB0 Interstage delay
  assign cfeb1_rxd_int_delay[3:0]  = delay0_int_wr[7:4];      // RW  CFEB1 Interstage delay
  assign cfeb2_rxd_int_delay[3:0]  = delay0_int_wr[11:8];     // RW  CFEB2 Interstage delay
  assign cfeb3_rxd_int_delay[3:0]  = delay0_int_wr[15:12];    // RW  CFEB3 Interstage delay
*/
// JGhere, new shared delay values for ME1/1b side:
  assign cfeb0_rxd_int_delay[3:0]  = delay1_int_wr[11:8];     // RW  CFEB0 Interstage delay
  assign cfeb1_rxd_int_delay[3:0]  = delay1_int_wr[11:8];     // RW  CFEB1 Interstage delay
  assign cfeb2_rxd_int_delay[3:0]  = delay1_int_wr[11:8];     // RW  CFEB2 Interstage delay
  assign cfeb3_rxd_int_delay[3:0]  = delay1_int_wr[11:8];     // RW  CFEB3 Interstage delay

  assign delay0_int_rd[15:0]    = delay0_int_wr[15:0];      //    Readback

// Delay1_is
  initial begin
  delay1_int_wr[3:0]        = 0;              // RW  CFEB4 Interstage delay  
  delay1_int_wr[7:4]        = 0;              // RW  CFEB5 Interstage delay    
  delay1_int_wr[11:8]       = 0;              // RW  CFEB6 Interstage delay  
  delay1_int_wr[15:12]      = 0;              // RW  Free
  end

//  assign cfeb4_rxd_int_delay[3:0]  = delay1_int_wr[3:0];      // RW  CFEB4 Interstage delay
//  assign cfeb5_rxd_int_delay[3:0]  = delay1_int_wr[7:4];      // RW  CFEB5 Interstage delay
//  assign cfeb6_rxd_int_delay[3:0]  = delay1_int_wr[11:8];     // RW  CFEB6 Interstage delay
// JGhere, new shared delay values for ME1/1a side:
  assign cfeb4_rxd_int_delay[3:0] = delay1_int_wr[7:4];      // RW  CFEB4 Interstage delay
  assign cfeb5_rxd_int_delay[3:0] = delay1_int_wr[7:4];      // RW  CFEB4 Interstage delay
  assign cfeb6_rxd_int_delay[3:0] = delay1_int_wr[7:4];      // RW  CFEB4 Interstage delay

  assign delay1_int_rd[15:0]    = delay1_int_wr[15:0];      //    Readback

//------------------------------------------------------------------------------------------------------------------
// ADR_SYNC_ERR_CTRL=0x120 Sync Error Control
//------------------------------------------------------------------------------------------------------------------
  initial begin
  sync_err_ctrl_wr[0]    = 0;                  // RW  VME sync error reset
  sync_err_ctrl_wr[1]    = 1;                  // RW  TMB  clock pulse count err bxn!=0+offset at ttc_bx0 arrival
  sync_err_ctrl_wr[2]    = 0;                  // RW  ALCT uncorrected ECC error in data TMB received from ALCT
  sync_err_ctrl_wr[3]    = 0;                  // RW  ALCT uncorrected ECC error in data ALCT received from TMB
  sync_err_ctrl_wr[4]    = 0;                  // RW  ALCT alct_bx0 != clct_bx0
  sync_err_ctrl_wr[5]    = 0;                  // RW  40MHz main clock lost lock

  sync_err_ctrl_wr[6]    = 0;                  // RW  Sync error blanks LCTs to MPC
  sync_err_ctrl_wr[7]    = 0;                  // RW  Sync error stops CLCT pre-triggers
  sync_err_ctrl_wr[8]    = 0;                  // RW  Sync error stops L1A readouts

  sync_err_ctrl_wr[14:9]  = 0;                  // R  Readonly
  sync_err_ctrl_wr[15]  = 0;                  // RW  Force sync_err=1
  end

// Sync error source enables
  assign sync_err_reset      = sync_err_ctrl_wr[0];      // RW  VME sync error reset, does not clear clct_bx0_sync_err (ttc_resync)
  assign clct_bx0_sync_err_en    = sync_err_ctrl_wr[1];      // RW  TMB  clock pulse count err bxn!=0+offset at ttc_bx0 arrival
  assign alct_ecc_rx_err_en    = sync_err_ctrl_wr[2];      // RW  ALCT uncorrected ECC error in data ALCT received from TMB
  assign alct_ecc_tx_err_en    = sync_err_ctrl_wr[3];      // RW  ALCT uncorrected ECC error in data ALCT transmitted to TMB
  assign bx0_match_err_en      = sync_err_ctrl_wr[4];      // RW  ALCT alct_bx0 != clct_bx0
  assign clock_lock_lost_err_en  = sync_err_ctrl_wr[5];      // RW  40MHz main clock lost lock

// Sync error action enables
  assign sync_err_blanks_mpc_en  = sync_err_ctrl_wr[6];      // RW  Sync error blanks LCTs to MPC
  assign sync_err_stops_pretrig_en= sync_err_ctrl_wr[7];      // RW  Sync error stops CLCT pre-triggers
  assign sync_err_stops_readout_en= sync_err_ctrl_wr[8];      // RW  Sync error stops L1A readouts
  assign sync_err_forced      = sync_err_ctrl_wr[15];      // RW  Force sync_err=1

// Sync error types latched for VME readout
  assign sync_err_ctrl_rd[8:0]  = sync_err_ctrl_wr[8:0];    // RW  Readback
  assign sync_err_ctrl_rd[9]    = sync_err;            // R  Sync error OR of enabled types of error
  assign sync_err_ctrl_rd[10]    = clct_bx0_sync_err;      // R  TMB  clock pulse count err bxn!=0+offset at ttc_bx0 arrival
  assign sync_err_ctrl_rd[11]    = alct_ecc_rx_err_ff;      // R  ALCT uncorrected ECC error in data ALCT received from TMB
  assign sync_err_ctrl_rd[12]    = alct_ecc_tx_err_ff;      // R  ALCT uncorrected ECC error in data ALCT transmitted to TMB
  assign sync_err_ctrl_rd[13]    = bx0_match_err_ff;        // R  ALCT alct_bx0 != clct_bx0
  assign sync_err_ctrl_rd[14]    = clock_lock_lost_err_ff;    // R  40MHz main clock lost lock
  assign sync_err_ctrl_rd[15]    = sync_err_ctrl_wr[15];      // RW  Readback

// See Adr86[1:0] for tmb_sync_err_en[1:0] Allow sync_err to MPC for either muon, and Adr38[2]alct_ecc_err_blank
  wire   sync_err_ctrl_sump    = |sync_err_ctrl_wr[14:9];    // R  Readonly sump

//------------------------------------------------------------------------------------------------------------------
// ADR_CFEB_BADBITS_CTRL    = 0x122 CFEB  Bad Bits Control/Status
// ADR_V6_CFEB_BADBITS_CTRL = 0x15C CFEB  Bad Bits Control/Status
// ADR_CFEB_BADBITS_TIMER   = 0x124 CFEB  Bad Bits Check Interval
//------------------------------------------------------------------------------------------------------------------
// ADR_CFEB_BADBIT_CTRL  = 0x122 CFEB  Bad Bits Control/Status
  initial begin
  cfeb_badbits_ctrl_wr[4:0]         = 0;                // RW  Reset bad cfeb bits FFs
  cfeb_badbits_ctrl_wr[9:5]         = 0;                // RW  Allow bad bits to block triads
  cfeb_badbits_ctrl_wr[14:10]       = 0;                // RO  CFEB[n] has at least 1 bad bit
  cfeb_badbits_ctrl_wr[15]          = 0;                // RO  A CFEB had bad bits that were blocked
  end

  wire   cfeb_badbits_blocked        = |(cfeb_badbits_found[MXCFEB-1:0] & cfeb_badbits_block[MXCFEB-1:0]);

  assign cfeb_badbits_reset[4:0]     = (cfeb_badbits_ctrl_wr[4:0] | {5{ttc_resync}});   // RW  Reset bad bits FFs for cfeb[n]
  assign cfeb_badbits_block[4:0]     = cfeb_badbits_ctrl_wr[9:5];    // RW  Block bad bits on cfeb[n]
  wire   cfeb_badbits_ctrl_sump      =|cfeb_badbits_ctrl_wr[15:10];

  assign cfeb_badbits_ctrl_rd[9:0]   = cfeb_badbits_ctrl_wr[9:0];    // RW  Readback
  assign cfeb_badbits_ctrl_rd[14:10] = cfeb_badbits_found[4:0];    // RO  CFEB[n] has at least 1 bad bit
  assign cfeb_badbits_ctrl_rd[15]    = cfeb_badbits_blocked;      // RO  A CFEB had bad bits that were blocked

// ADR_V6_CFEB_BADBITS_CTRL = 0x15C CFEB  Bad Bits Control/Status
  initial begin
  cfeb_v6_badbits_ctrl_wr[1:0]        = 0;              // RW  Reset bad cfeb bits FFs
  cfeb_v6_badbits_ctrl_wr[3:2]        = 0;              // RW  Allow bad bits to block triads
  cfeb_v6_badbits_ctrl_wr[5:4]        = 0;              // RO  CFEB[n] has at least 1 bad bit
  cfeb_v6_badbits_ctrl_wr[15:6]       = 0;              // RW  Unused
  end

  assign cfeb_badbits_reset[6:5]      = (cfeb_v6_badbits_ctrl_wr[1:0] | {2{ttc_resync}});  // RW  Reset bad bits FFs for cfeb[n]
  assign cfeb_badbits_block[6:5]      = cfeb_v6_badbits_ctrl_wr[3:2];  // RW  Block bad bits on cfeb[n]
  wire   cfeb_v6_badbits_ctrl_sump    =|cfeb_v6_badbits_ctrl_wr[5:4];  // RO

  assign cfeb_v6_badbits_ctrl_rd[3:0]  = cfeb_v6_badbits_ctrl_wr[3:0];  // RW  Readback
  assign cfeb_v6_badbits_ctrl_rd[5:4]  = cfeb_badbits_found[6:5];      // RO  CFEB[n] has at least 1 bad bit
  assign cfeb_v6_badbits_ctrl_rd[15:6] = cfeb_v6_badbits_ctrl_wr[15:6];  // RW  Unused

// ADR_CFEB_BADBIT_TIMER = 0x124 CFEB  Bad Bit Check Interval for bad bits
  initial begin
  cfeb_badbits_nbx_wr[15:0]          = 'd3564;            // RW  Cycles a bad bit must be continuously high
  end

  assign cfeb_badbits_nbx[15:0]      = cfeb_badbits_nbx_wr[15:0];    // RW  Cycles a bad bit must be continuously high
  assign cfeb_badbits_nbx_rd[15:0]   = cfeb_badbits_nbx_wr[15:0];    // RW  Readback

///------------------------------------------------------------------------------------------------------------------
// ADR_CFEB0_BADBITS_LY01 = 0x126 CFEB0 Bad Bits Array
// ADR_CFEB0_BADBITS_LY23 = 0x128 CFEB0 Bad Bits Array
// ADR_CFEB0_BADBITS_LY45 = 0x12A CFEB0 Bad Bits Array
//
// ADR_CFEB1_BADBITS_LY01 = 0x12C CFEB1 Bad Bits Array
// ADR_CFEB1_BADBITS_LY23 = 0x12E CFEB1 Bad Bits Array
// ADR_CFEB1_BADBITS_LY45 = 0x130 CFEB1 Bad Bits Array
//
// ADR_CFEB2_BADBITS_LY01 = 0x132 CFEB2 Bad Bits Array
// ADR_CFEB2_BADBITS_LY23 = 0x134 CFEB2 Bad Bits Array
// ADR_CFEB2_BADBITS_LY45 = 0x136 CFEB2 Bad Bits Array
//
// ADR_CFEB3_BADBITS_LY01 = 0x138 CFEB3 Bad Bits Array
// ADR_CFEB3_BADBITS_LY23 = 0x13A CFEB3 Bad Bits Array
// ADR_CFEB3_BADBITS_LY45 = 0x13C CFEB3 Bad Bits Array
//
// ADR_CFEB4_BADBITS_LY01 = 0x13E CFEB4 Bad Bits Array
// ADR_CFEB4_BADBITS_LY23 = 0x140 CFEB4 Bad Bits Array
// ADR_CFEB4_BADBITS_LY45 = 0x142 CFEB4 Bad Bits Array
//
// Virtex-6 only
// ADR_V6_CFEB5_BADBITS_LY01 = 0x15C CFEB5 Bad Bits Array
// ADR_V6_CFEB5_BADBITS_LY23 = 0x15E CFEB5 Bad Bits Array
// ADR_V6_CFEB5_BADBITS_LY45 = 0x160 CFEB5 Bad Bits Array
///
// ADR_V6_CFEB6_BADBITS_LY01 = 0x162 CFEB6 Bad Bits Array
// ADR_V6_CFEB6_BADBITS_LY23 = 0x164 CFEB6 Bad Bits Array
// ADR_V6_CFEB6_BADBITS_LY45 = 0x166 CFEB6 Bad Bits Array
//------------------------------------------------------------------------------------------------------------------
  assign cfeb0_badbits_ly01_rd[15:0] = {cfeb0_ly1_badbits,cfeb0_ly0_badbits};
  assign cfeb0_badbits_ly23_rd[15:0] = {cfeb0_ly3_badbits,cfeb0_ly2_badbits};
  assign cfeb0_badbits_ly45_rd[15:0] = {cfeb0_ly5_badbits,cfeb0_ly4_badbits};

  assign cfeb1_badbits_ly01_rd[15:0] = {cfeb1_ly1_badbits,cfeb1_ly0_badbits};
  assign cfeb1_badbits_ly23_rd[15:0] = {cfeb1_ly3_badbits,cfeb1_ly2_badbits};
  assign cfeb1_badbits_ly45_rd[15:0] = {cfeb1_ly5_badbits,cfeb1_ly4_badbits};

  assign cfeb2_badbits_ly01_rd[15:0] = {cfeb2_ly1_badbits,cfeb2_ly0_badbits};
  assign cfeb2_badbits_ly23_rd[15:0] = {cfeb2_ly3_badbits,cfeb2_ly2_badbits};
  assign cfeb2_badbits_ly45_rd[15:0] = {cfeb2_ly5_badbits,cfeb2_ly4_badbits};

  assign cfeb3_badbits_ly01_rd[15:0] = {cfeb3_ly1_badbits,cfeb3_ly0_badbits};
  assign cfeb3_badbits_ly23_rd[15:0] = {cfeb3_ly3_badbits,cfeb3_ly2_badbits};
  assign cfeb3_badbits_ly45_rd[15:0] = {cfeb3_ly5_badbits,cfeb3_ly4_badbits};

  assign cfeb4_badbits_ly01_rd[15:0] = {cfeb4_ly1_badbits,cfeb4_ly0_badbits};
  assign cfeb4_badbits_ly23_rd[15:0] = {cfeb4_ly3_badbits,cfeb4_ly2_badbits};
  assign cfeb4_badbits_ly45_rd[15:0] = {cfeb4_ly5_badbits,cfeb4_ly4_badbits};

// Virtex-6 only
  assign cfeb5_badbits_ly01_rd[15:0] = {cfeb5_ly1_badbits,cfeb5_ly0_badbits};
  assign cfeb5_badbits_ly23_rd[15:0] = {cfeb5_ly3_badbits,cfeb5_ly2_badbits};
  assign cfeb5_badbits_ly45_rd[15:0] = {cfeb5_ly5_badbits,cfeb5_ly4_badbits};

  assign cfeb6_badbits_ly01_rd[15:0] = {cfeb6_ly1_badbits,cfeb6_ly0_badbits};
  assign cfeb6_badbits_ly23_rd[15:0] = {cfeb6_ly3_badbits,cfeb6_ly2_badbits};
  assign cfeb6_badbits_ly45_rd[15:0] = {cfeb6_ly5_badbits,cfeb6_ly4_badbits};

//------------------------------------------------------------------------------------------------------------------
// ADR_ALCT_STARTUP_DELAY = 0x144 ALCT startup delay milliseconds for Spartan-6
//------------------------------------------------------------------------------------------------------------------
  initial begin
  alct_startup_delay_wr[15:0]      = 16'd116;            // RW  ALCT-TMB = 212msec-100msec=112msec + 4pad
  end

  assign alct_startup_delay[15:0]    = alct_startup_delay_wr[15:0];  // RW  Msec to wait after TMB powers up
  assign alct_startup_delay_rd[15:0]  = alct_startup_delay_wr[15:0];  // RW  Readback

//------------------------------------------------------------------------------------------------------------------
// ADR_ALCT_STARTUP_STATUS = 0x146 ALCT startup machine status, Reaonly
//------------------------------------------------------------------------------------------------------------------
  assign alct_startup_status_rd[0]  = global_reset;       // R  Global reset
  assign alct_startup_status_rd[1]  = power_up;           // R  DLL clock lock, we wait for it
  assign alct_startup_status_rd[2]  = vsm_ready;          // R  TMB VME registers loaded from PROM
  assign alct_startup_status_rd[3]  = alct_startup_msec;  // R  Msec pulse
  assign alct_startup_status_rd[4]  = alct_wait_dll;      // R  Waiting for TMB DLL lock
  assign alct_startup_status_rd[5]  = alct_wait_vme;      // R  Waiting for TMB VME load from user PROM
  assign alct_startup_status_rd[6]  = alct_wait_cfg;      // R  Waiting for ALCT FPGA to configure from mez PROM
  assign alct_startup_status_rd[7]  = alct_startup_done;  // R  ALCT FPGA should be configured by now
  assign alct_startup_status_rd[15:8] = tmbmmcm_locklost_cnt[7:0]; // R  TMB MMCM lock-lost count
//  assign alct_startup_status_rd[15:8]  = 0;             // R  Unassigned

//------------------------------------------------------------------------------------------------------------------
// ADR_V6_SNAP12_QPLL = 0x148
//------------------------------------------------------------------------------------------------------------------
  initial begin
// QPLL status
  virtex6_snap12_qpll_wr[0]      = 1;     // RW  nReset QPLL, 0=reset
  virtex6_snap12_qpll_wr[1]      = 0;     // R  QPLL locked status
  virtex6_snap12_qpll_wr[2]      = 0;     // R  QPLL error status
  virtex6_snap12_qpll_wr[3]      = 0;     // R  QPLL lock-lost history
// SNAP12 rx serial interface
  virtex6_snap12_qpll_wr[4]      = 1;     // RW  Serial interface clock, drive high
  virtex6_snap12_qpll_wr[5]      = 0;     // R  Serial interface data
  virtex6_snap12_qpll_wr[6]      = 0;     // R  Serial interface status
// QPLL & TMB MMCM status
  virtex6_snap12_qpll_wr[7]      = 0;     // R  TMB MMCM lock lost history
  virtex6_snap12_qpll_wr[15:8]   = 0;     // R  QPLL lock-lost count
  end

  assign qpll_nrst          = virtex6_snap12_qpll_wr[0];    // RW  nReset QPLL, 0=reset
  assign r12_sclk           = virtex6_snap12_qpll_wr[4];    // RW  Serial interface clock, drive high
  assign virtex6_snap12_qpll_rd[0]  = qpll_nrst;       // RW  nReset QPLL, 0=reset
  assign virtex6_snap12_qpll_rd[1]  = qpll_lock;       // R  QPLL locked status
  assign virtex6_snap12_qpll_rd[2]  = qpll_err;        // R  QPLL error status
  assign virtex6_snap12_qpll_rd[3]  = qpll_locklost;   // R  QPLL lock-lost history
//  assign virtex6_snap12_qpll_rd[3]  = virtex6_snap12_qpll_wr[3];    // RW  Unused
  assign virtex6_snap12_qpll_rd[4] = r12_sclk;         // RW  Serial interface clock, drive high
  assign virtex6_snap12_qpll_rd[5] = r12_sdat;         // R  Serial interface data
  assign virtex6_snap12_qpll_rd[6] = r12_fok;          // R  Serial interface status
  assign virtex6_snap12_qpll_rd[7] = tmbmmcm_locklost; // R  TMB MMCM lock lost history
  assign virtex6_snap12_qpll_rd[15:8] = qpll_locklost_cnt[7:0];   // R  QPLL lock-lost count
//  assign virtex6_snap12_qpll_rd[15:7]  = virtex6_snap12_qpll_wr[15:7];    // RW  Unused

   wire virtex6_snap12_qpll_sump   = 0;  // R  Unused write bits
//  wire virtex6_snap12_qpll_sump    = (|virtex6_snap12_qpll_wr[2:1]) | (|virtex6_snap12_qpll_wr[6:5]);

//------------------------------------------------------------------------------------------------------------------
// ADR_V6_GTX_RX_ALL = 0x14A
//------------------------------------------------------------------------------------------------------------------
// Virtex-6 powers up with GTX enabled, CFEB DDR disabled
  parameter gtx_rx_enable_default = 1;

  initial begin
     virtex6_gtx_rx_all_wr[0] = gtx_rx_enable_default;  // RW  Enable/Unreset all GTX optical inputs; you should disable copper via mask_all
     virtex6_gtx_rx_all_wr[1] = 0;      // RW  Reset  all GTX rx_sync modules
     virtex6_gtx_rx_all_wr[2] = 0;      // RW   JRG: now this is Select all PRBS inputs test mode
//      virtex6_gtx_rx_all_wr[2] = 0;     // RW   JRG: was Reset  all PRBS test error counters
//      virtex6_gtx_rx_all_wr[3] = 0;     // RW   JRG: was Select all PRBS inputs test mode
     virtex6_gtx_rx_all_wr[10:3] = 0;   // R    Readonly
     virtex6_gtx_rx_all_wr[15:11] = 0;  // RW   JRG: Unused until recent changes
  end

   wire   gtx_rx_enable_all = virtex6_gtx_rx_all_wr[0];  // RW  Enable/Unreset all GTX optical inputs; you should disable copper via mask_all
   wire  gtx_rx_reset_all  = virtex6_gtx_rx_all_wr[1];   // RW  Reset all GTX
   wire  gtx_rx_reset_err_cnt_all = 0;    // RW   JRG: this will NEVER Reset all PRBS test error counters
//    wire   gtx_rx_reset_err_cnt_all = virtex6_gtx_rx_all_wr[2];     // RW   Reset all PRBS test error counters
//    wire   gtx_rx_en_prbs_test_all  = virtex6_gtx_rx_all_wr[3];     // RW   Select all  random input test data mode
   wire  gtx_rx_en_prbs_test_all  = virtex6_gtx_rx_all_wr[2];  // RW   JRG: was bit3; Select all  random input test data mode

      assign virtex6_gtx_rx_all_rd[2:0] = virtex6_gtx_rx_all_wr[2:0]; // RW   Readback. JRG: changed these around; it was 4 bits, now 3 bits == PRBS test enable, Reset GTX rx_sync, Enable/Unreset GTX
      assign virtex6_gtx_rx_all_rd[3] = &gtx_rx_sync_done[MXCFEB-1:0];// R    JRG: this changed... rx_sync_done (bit8) moved here (AND all gtx_ready)
      assign virtex6_gtx_rx_all_rd[4] = &gtx_link_good[MXCFEB-1:0];   // R    link stability monitor: TRUE indicates all links have been stable for at least 15 BX
      assign virtex6_gtx_rx_all_rd[5] = |gtx_link_had_err[MXCFEB-1:0];// R    link stability monitor: TRUE indicates an error happened at least once on a link
      assign virtex6_gtx_rx_all_rd[6] = |gtx_link_bad[MXCFEB-1:0];    // R    link stability monitor: TRUE indicates that errors happened over 100 times on a link
//    assign virtex6_gtx_rx_all_rd[4] = |gtx_rx_start[MXCFEB-1:0];    // R    JRG: not useful! -- Set when the DCFEB Start Pattern is present
//    assign virtex6_gtx_rx_all_rd[5] = |gtx_rx_fc[MXCFEB-1:0];       // R    JRG: not useful! -- Flags when Rx sees "FC" code (sent by Tx) for latency measurement
//    assign virtex6_gtx_rx_all_rd[6] = |gtx_rx_valid[MXCFEB-1:0];    // R    JRG: not useful! -- Valid data detected on link
//    assign virtex6_gtx_rx_all_rd[7] = |gtx_rx_match[MXCFEB-1:0];    // R    JRG: not useful! -- PRBS test data match detected, for PRBS tests, a VALID = "should have a match" such that !MATCH is an error
      assign virtex6_gtx_rx_all_rd[7] = |gtx_rx_pol_swap[MXCFEB-1:0]; // R    JRG: was bit9, and not very useful to read this signal -- GTX 5,6 [ie dcfeb 4,5] have swapped rx board routes that are corrected within the GTX module
//    assign virtex6_gtx_rx_all_rd[10]= |gtx_rx_err[MXCFEB-1:0];      // R    PRBS test detects an error

      assign virtex6_gtx_rx_all_rd[15:8] = (gtx_rx_err_count_all[11:8]==4'h0) ? gtx_rx_err_count_all[7:0] : 8'hFE; // R JRG: a sum of all GTX error counts, full scale set at hex FE


//    assign virtex6_gtx_rx_all_rd[15:11] = virtex6_gtx_rx_all_wr[15:11]; // RW       JRG: was Unused
      wire virtex6_gtx_rx_all_sump    = |virtex6_gtx_rx_all_wr[10:3]; // R    Unused write bits. JRG: used to be [10:4]

      assign gtx_rx_err_count_all[11:0] = gtx_rx_err_count0[7:0]+gtx_rx_err_count1[7:0]+gtx_rx_err_count2[7:0]+gtx_rx_err_count3[7:0]+gtx_rx_err_count4[7:0]+gtx_rx_err_count5[7:0]+gtx_rx_err_count6[7:0];


//------------------------------------------------------------------------------------------------------------------
// Virtex-6 GTX receiver 0 = 0x14C through receiver 6 = 0x158
//------------------------------------------------------------------------------------------------------------------
// 2D map for generate
  wire [MXCFEB-1:0] virtex6_gtx_rx_sump;

// Generate 7 VME registers
  genvar idcfeb;
  generate
  for (idcfeb=0; idcfeb<MXCFEB; idcfeb=idcfeb+1) begin: gen_gtx_rx

  initial begin
     virtex6_gtx_rx_wr[idcfeb][0]      = gtx_rx_enable_default; // RW  Enable/Unreset GTX optical input, you should disable copper via mask_all
     virtex6_gtx_rx_wr[idcfeb][1]      = 0; // RW  Reset this GTX rx_sync. JRG: 0 & 1 should be combined, consider this later... if you hold RESET true it's really the same as a Disable, so when false it's like an Enable
//     virtex6_gtx_rx_wr[idcfeb][2]      = 0; // RW  JRG: not useful! -- Reset PRBS test error counters
//     virtex6_gtx_rx_wr[idcfeb][3]      = 0; // RW  was enable PRBS inputs test mode
     virtex6_gtx_rx_wr[idcfeb][2]      = 0; // RW  JRG: moved from bit3 to bit2 -- Enable PRBS inputs test mode
     virtex6_gtx_rx_wr[idcfeb][10:3]   = 0; // R   Readonly.  JRG: was [10:4]
     virtex6_gtx_rx_wr[idcfeb][15:11]  = 0; // RW  JRG: Unused until recent changes
  end

     assign gtx_rx_enable[idcfeb] = virtex6_gtx_rx_wr[idcfeb][0] | gtx_rx_enable_all; // RW  Enable GTX optical input, you should disable copper via mask_all
     assign gtx_rx_reset[idcfeb]  = virtex6_gtx_rx_wr[idcfeb][1] | gtx_rx_reset_all;  // RW  Reset this GTX rx_sync

//    assign gtx_rx_reset_err_cnt[idcfeb] = virtex6_gtx_rx_wr[idcfeb][2] | gtx_rx_reset_err_cnt_all; // RW   Reset PRBS test error counters
     assign gtx_rx_reset_err_cnt[idcfeb]  = gtx_rx_reset_err_cnt_all;     // RW   JRG: just the ALL case will Reset PRBS test error counters
//    assign gtx_rx_en_prbs_test[idcfeb]  = virtex6_gtx_rx_wr[idcfeb][3] | gtx_rx_en_prbs_test_all;  // RW   Select random input test data mode
     assign gtx_rx_en_prbs_test[idcfeb]   = virtex6_gtx_rx_wr[idcfeb][2] | gtx_rx_en_prbs_test_all;  // RW   Select random input test data mode

     assign virtex6_gtx_rx_rd[idcfeb][2:0] = virtex6_gtx_rx_wr[idcfeb][2:0]|virtex6_gtx_rx_all_wr[2:0]; // RW  Readback. JRG: changed these around; it was 4 bits, now 3 bits == PRBS test enable, Reset GTX rx_sync, Enable/Unreset GTX  ---> new: OR these bits with virtex6_gtx_rx_all_wr[2:0]
     assign virtex6_gtx_rx_rd[idcfeb][3] = gtx_rx_sync_done[idcfeb]; // R    JRG: this changed... rx_sync_done moved here (gtx_ready)
     assign virtex6_gtx_rx_rd[idcfeb][4] = gtx_link_good[idcfeb];    // R    link stability monitor: TRUE indicates this link has been stable for at least 15 BX
     assign virtex6_gtx_rx_rd[idcfeb][5] = gtx_link_had_err[idcfeb]; // R    link stability monitor: TRUE indicates an error happened at least once on this link
     assign virtex6_gtx_rx_rd[idcfeb][6] = gtx_link_bad[idcfeb];     // R    link stability monitor: TRUE indicates that errors happened over 100 times on this link

// orig    assign virtex6_gtx_rx_rd[idcfeb][4] = gtx_rx_start[idcfeb]; // R    JRG: not useful! -- Set when the DCFEB Start Pattern is present
// orig    assign virtex6_gtx_rx_rd[idcfeb][5] = gtx_rx_fc[idcfeb];    // R    JRG: not useful! -- Flags when Rx sees "FC" code (sent by Tx) for latency measurement
// orig    assign virtex6_gtx_rx_rd[idcfeb][6] = gtx_rx_valid[idcfeb]; // R    JRG: not useful! -- Valid data detected on link
// orig    assign virtex6_gtx_rx_rd[idcfeb][7] = gtx_rx_match[idcfeb]; // R    JRG: not useful! -- PRBS test data match detected, for PRBS tests, a VALID = "should have a match" such that !MATCH is an error

        assign virtex6_gtx_rx_rd[idcfeb][7]    = gtx_rx_pol_swap[idcfeb];      // R  JRG: was bit9, and not very useful to read this signal -- GTX 5,6 [ie dcfeb 4,5] have swapped rx board routes that are corrected within the GTX module
        assign virtex6_gtx_rx_rd[idcfeb][15:8] =  gtx_rx_err_count[idcfeb];    // R  JRG: constructed this 8-bit array set above
//      assign virtex6_gtx_rx_rd[idcfeb][10]    = gtx_rx_err[idcfeb];               // R    JRG: not useful! -- PRBS test detects an error
//      assign virtex6_gtx_rx_rd[idcfeb][15:11] = virtex6_gtx_rx_wr[idcfeb][15:11]; // RW   JRG: was Unused
        assign virtex6_gtx_rx_sump[idcfeb] = |virtex6_gtx_rx_wr[idcfeb][10:3]; // R  Unused write bits. JRG: used to be [10:4]
  end
  endgenerate

//------------------------------------------------------------------------------------------------------------------
// ADR_V6_SYSMON = 0x15A
//------------------------------------------------------------------------------------------------------------------
// Power up
  initial begin
  virtex6_sysmon_wr[4:0]  = 0;    // RW  ADC channel
  virtex6_sysmon_wr[5]  = 0;    // RW  Active-high reset
  virtex6_sysmon_wr[15:6]  = 0;    // RW  Unused write bits
  end

// Virtex6 Sysmon instance
  wire [4:0]  adc_adr;
  wire [9:0]  adc_data;
  wire    adc_reset;
  wire    adc_valid;

  gtx_sysmon usysmon
  (
  .clock    (clock),        // In  40 MHz main
  .reset    (adc_reset),      // In  Active-high reset
  .adc_adr  (adc_adr[4:0]),      // In  ADC channel
  .adc_data  (adc_data[9:0]),    // Out  ADC data
  .adc_valid  (adc_valid),      // Out  ADC data valid
  .adc_sump  (adc_sump)        // Out  ADC RAM sump
  );

// Register map
  assign adc_adr[4:0]          = virtex6_sysmon_wr[4:0];      // RW  ADC channel
  assign adc_reset          = virtex6_sysmon_wr[5];        // RW  Active-high reset
  wire   virtex6_sysmon_sump      = |virtex6_sysmon_wr[15:6];      // RW  Unused write bits

  assign virtex6_sysmon_rd[4:0]    = adc_adr[4:0];            // RW  ADC channel
  assign virtex6_sysmon_rd[5]      = adc_valid;            // R  ADC data valid
  assign virtex6_sysmon_rd[15:6]    = adc_data[9:0];          // R  ADC data

//------------------------------------------------------------------------------------------------------------------
// ADR_V6_EXTEND = 0x17A  DCFEB 7-bit extensions for Adr 0x42 and 0x68
//------------------------------------------------------------------------------------------------------------------
// Power up
  initial begin
  virtex6_extend_wr[1:0]        = 2'b11;          // RW  1=Enable, 0=Turn off all CFEB inputs
  virtex6_extend_wr[3:2]        = 2'b00;          // RW  1=Select CFEBn for RAM read/write
  virtex6_extend_wr[5:4]        = 2'b11;          // RW  1=Enable CFEBn for injector trigger
  virtex6_extend_wr[7:6]        = 2'b11;          // RW  1=Enable CFEBn for triggering and active feb flag
  virtex6_extend_wr[9:8]        = 0;            // RO  Readonly
  virtex6_extend_wr[15:10]      = 0;            // RW  Unused
  end

  assign mask_all[6:5]        = virtex6_extend_wr[1:0];  // RW  Extend 0x42[4:0]   = mask_all[4:0]           1=Enable, 0=Turn off all CFEB inputs
  assign inj_febsel[6:5]        = virtex6_extend_wr[3:2];  // RW  Extend 0x42[9:5]   = inj_febsel[4:0]         1=Select CFEBn for RAM read/write
  assign injector_mask_cfeb[6:5]    = virtex6_extend_wr[5:4];  // RW  Extend 0x42[14:10] = injector_mask_cfeb[4:0] 1=Enable CFEB(n) for injector trigger
  assign cfeb_en_vme[6:5]        = virtex6_extend_wr[7:6];  // RW  Extend 0x68[14:10] = cfeb_en_vme[4:0]       1=Enable CFEBs for triggering and active feb flag
  
  assign virtex6_extend_rd[7:0]    = virtex6_extend_wr[7:0];  // RW  Readback
  assign virtex6_extend_rd[9:8]    = cfeb_en[6:5];        // RO  Extend 0x68 cfeb_en[4:0] Readback actual cfeb_en state, altered by mask_all
  assign virtex6_extend_rd[15:10]    = virtex6_extend_wr[15:10];  // RW  Unused

  wire   virtex6_extend_sump      = |virtex6_extend_wr[9:8];  // RO

//------------------------------------------------------------------------------------------------------------------
// ADR_TMB_LATENCY_SR = 0x196 TMB Latency Shift Register
//------------------------------------------------------------------------------------------------------------------
  reg [31:0] tmb_latency_sr = 0;
  reg [15:0] tmb_latency_sr_latched = 0;
  assign tmb_latency_sr_rd = tmb_latency_sr_latched;

// Power up
  initial begin
    tmb_latency_sr         = 0;
    tmb_latency_sr_latched = 0;
  end
  
// Shift register
  always @(posedge clock or posedge global_reset) begin
    if(global_reset) tmb_latency_sr <= 0;
    else             tmb_latency_sr <= { tmb_latency_sr[30:0], gtx_rx_data_bits_or };
  end

// Latch on trigger
  always @(posedge clock or posedge global_reset) begin
    if (global_reset)       tmb_latency_sr_latched <= 0;
    else if (mpc_frame_vme) tmb_latency_sr_latched <= tmb_latency_sr[20:5];
  end

//------------------------------------------------------------------------------------------------------------------
// VME Write-Registers latch data when addressed + latch power-up defaults
//------------------------------------------------------------------------------------------------------------------
  always @(posedge clock_vme) begin
  if (wr_tmb_loop)        tmb_loop_wr         <=  d[15:0];
  if (wr_usr_jtag)        usr_jtag_wr         <=  d[15:0];
  if (wr_prom)          prom_wr          <=  d[15:0];
  if (wr_dddsm)          dddsm_wr        <=  d[15:0];
  if (wr_ddd0)          ddd0_wr          <=  d[15:0];
  if (wr_ddd1)          ddd1_wr          <=  d[15:0];
  if (wr_ddd2)          ddd2_wr          <=  d[15:0];
  if (wr_dddoe)          dddoe_wr        <=  d[15:0];
  if (wr_rat_control)        rat_control_wr      <=  d[15:0];
  if (wr_step)          step_wr          <=  d[15:0];
  if (wr_led)            led_wr          <=  d[15:0];
  if (wr_adc)            adc_wr          <=  d[15:0];
  if (wr_dsn)            dsn_wr          <=  d[15:0];
  if (wr_mod_cfg)          mod_cfg_wr        <=  d[15:0];
  if (wr_ccb_cfg)          ccb_cfg_wr        <=  d[15:0];
  if (wr_ccb_trig)        ccb_trig_wr        <=  d[15:0];
  if (wr_alct_cfg)        alct_cfg_wr        <=  d[15:0];
  if (wr_alct_inj)        alct_inj_wr        <=  d[15:0];
  if (wr_alct0_inj)        alct0_inj_wr      <=  d[15:0];
  if (wr_alct1_inj)        alct1_inj_wr      <=  d[15:0];
  if (wr_alct_stat)        alct_stat_wr      <=  d[15:0];
  if (wr_cfeb_inj  )        cfeb_inj_wr        <=  d[15:0];
  if (wr_cfeb_inj_adr)      cfeb_inj_adr_wr      <=  d[15:0];
  if (wr_cfeb_inj_wdata)      cfeb_inj_wdata_wr    <=  d[15:0];
  if (wr_hcm001)          hcm001_wr        <=  d[15:0];
  if (wr_hcm023)          hcm023_wr        <=  d[15:0];
  if (wr_hcm045)          hcm045_wr        <=  d[15:0];
  if (wr_hcm101)          hcm101_wr        <=  d[15:0];
  if (wr_hcm123)          hcm123_wr        <=  d[15:0];
  if (wr_hcm145)          hcm145_wr        <=  d[15:0];
  if (wr_hcm201)          hcm201_wr        <=  d[15:0];
  if (wr_hcm223)          hcm223_wr        <=  d[15:0];
  if (wr_hcm245)          hcm245_wr        <=  d[15:0];
  if (wr_hcm301)          hcm301_wr        <=  d[15:0];
  if (wr_hcm323)          hcm323_wr        <=  d[15:0];
  if (wr_hcm345)          hcm345_wr        <=  d[15:0];
  if (wr_hcm401)          hcm401_wr        <=  d[15:0];
  if (wr_hcm423)          hcm423_wr        <=  d[15:0];
  if (wr_hcm445)          hcm445_wr        <=  d[15:0];
  if (wr_hcm501)          hcm501_wr        <=  d[15:0];
  if (wr_hcm523)          hcm523_wr        <=  d[15:0];
  if (wr_hcm545)          hcm545_wr        <=  d[15:0];
  if (wr_hcm601)          hcm601_wr        <=  d[15:0];
  if (wr_hcm623)          hcm623_wr        <=  d[15:0];
  if (wr_hcm645)          hcm645_wr        <=  d[15:0];
  if (wr_seq_trigen)      seq_trigen_wr    <=  d[15:0];
  if (wr_seq_trigdly0)    seq_trigdly0_wr  <=  d[15:0];
  if (wr_seq_trigdly1)    seq_trigdly1_wr  <=  d[15:0];
  if (wr_seq_trigdly2)    seq_trigdly2_wr  <=  d[15:0];
//if (wr_seq_id)          seq_id_wr        <=  d[15:0];
  if (wr_seq_clct)        seq_clct_wr        <=  d[15:0];
  if (wr_seq_fifo)        seq_fifo_wr        <=  d[15:0];
  if (wr_seq_l1a)          seq_l1a_wr        <=  d[15:0];
  if (wr_seq_offset0)        seq_offset0_wr      <=  d[15:0];
  if (wr_dmb_ram_adr)        dmb_ram_adr_wr      <=  d[15:0];
  if (wr_dmb_ram_wdata)      dmb_ram_wdata_wr    <=  d[15:0];
  if (wr_tmb_trig)        tmb_trig_wr        <=  d[15:0];
  if (wr_mpc_inj)          mpc_inj_wr        <=  d[15:0];
  if (wr_mpc_ram_adr)        mpc_ram_adr_wr      <=  d[15:0];
  if (wr_mpc_ram_wdata)      mpc_ram_wdata_wr    <=  d[15:0];
  if (wr_scp_ctrl)        scp_ctrl_wr        <=  d[15:0];
  if (wr_scp_rdata)        scp_rdata_wr      <=  d[15:0];
  if (wr_ccb_cmd)          ccb_cmd_wr        <=  d[15:0];
  if (wr_alct_fifo1)        alct_fifo1_wr      <=  d[15:0];
  if (wr_seq_trigmod)        seq_trigmod_wr      <=  d[15:0];
  if (wr_tmb_timing)        tmb_timing_wr      <=  d[15:0];
  if (wr_lhc_cycle)        lhc_cycle_wr      <=  d[15:0];
  if (wr_rpc_cfg)          rpc_cfg_wr        <=  d[15:0];
  if (wr_rpc_raw_delay)      rpc_raw_delay_wr    <=  d[15:0];
  if (wr_rpc_inj)          rpc_inj_wr        <=  d[15:0];
  if (wr_rpc_inj_adr)        rpc_inj_adr_wr      <=  d[15:0];
  if (wr_rpc_inj_wdata)      rpc_inj_wdata_wr    <=  d[15:0];
  if (wr_rpc_tbins)        rpc_tbins_wr      <=  d[15:0];
  if (wr_rpc0_hcm)        rpc0_hcm_wr        <=  d[15:0];
  if (wr_rpc1_hcm)        rpc1_hcm_wr        <=  d[15:0];
  if (wr_bx0_delay)        bx0_delay_wr      <=  d[15:0];
  if (wr_non_trig_ro)        non_trig_ro_wr      <=  d[15:0];
  if (wr_scp_trigger_ch)      scp_trigger_ch_wr    <=  d[15:0];
  if (wr_cnt_ctrl)        cnt_ctrl_wr        <=  d[15:0];
  if (wr_jtagsm0)          jtagsm0_wr        <=  d[15:0];
  if (wr_vmesm0)          vmesm0_wr        <=  d[15:0];
  if (wr_vmesm4)          vmesm4_wr        <=  d[15:0];
  if (wr_dddrsm)          dddrsm_wr        <=  d[15:0];
  if (wr_dddr)          dddr_wr          <=  d[15:0];
  if (wr_layer_trig)        layer_trig_wr      <=  d[15:0];
  if (wr_temp0)          temp0_wr        <=  d[15:0];
  if (wr_temp1)          temp1_wr        <=  d[15:0];
  if (wr_temp2)          temp2_wr        <=  d[15:0];
  if (wr_parity)          parity_wr        <=  d[15:0];
  if (wr_l1a_lookback)      l1a_lookback_wr      <=  d[15:0];
  if (wr_seqdeb)          seqdeb_wr        <=  d[15:0];
  if (wr_alct_sync_ctrl)      alct_sync_ctrl_wr    <=  d[15:0];
  if (wr_alct_sync_txdata_1st)  alct_sync_txdata_1st_wr  <=  d[15:0];
  if (wr_alct_sync_txdata_2nd)  alct_sync_txdata_2nd_wr  <=  d[15:0];
  if (wr_seq_offset1)        seq_offset1_wr      <=  d[15:0];
  if (wr_miniscope)        miniscope_wr      <=  d[15:0];
  if (wr_phaser0)          phaser0_wr        <=  d[15:0];
  if (wr_phaser1)          phaser1_wr        <=  d[15:0];
  if (wr_phaser2)          phaser2_wr        <=  d[15:0];
  if (wr_phaser3)          phaser3_wr        <=  d[15:0];
  if (wr_phaser4)          phaser4_wr        <=  d[15:0];
  if (wr_phaser5)          phaser5_wr        <=  d[15:0];
  if (wr_phaser6)          phaser6_wr        <=  d[15:0];
  if (wr_phaser7)          phaser7_wr        <=  d[15:0];
  if (wr_phaser8)          phaser8_wr        <=  d[15:0];
  if (wr_delay0_int)        delay0_int_wr      <=  d[15:0];
  if (wr_delay1_int)        delay1_int_wr      <=  d[15:0];
  if (wr_sync_err_ctrl)      sync_err_ctrl_wr    <=  d[15:0];
  if (wr_cfeb_badbits_ctrl)    cfeb_badbits_ctrl_wr  <=  d[15:0];
  if (wr_cfeb_v6_badbits_ctrl) cfeb_v6_badbits_ctrl_wr  <=  d[15:0];
  if (wr_cfeb_badbits_nbx)    cfeb_badbits_nbx_wr    <=  d[15:0];
  if (wr_alct_startup_delay)    alct_startup_delay_wr  <=  d[15:0];
  if (wr_virtex6_snap12_qpll) virtex6_snap12_qpll_wr <=  d[15:0];
  if (wr_virtex6_gtx_rx_all)  virtex6_gtx_rx_all_wr  <=  d[15:0];
  if (wr_virtex6_gtx_rx[0])   virtex6_gtx_rx_wr[0] <=  d[15:0];
  if (wr_virtex6_gtx_rx[1])   virtex6_gtx_rx_wr[1] <=  d[15:0];
  if (wr_virtex6_gtx_rx[2])   virtex6_gtx_rx_wr[2] <=  d[15:0];
  if (wr_virtex6_gtx_rx[3])   virtex6_gtx_rx_wr[3] <=  d[15:0];
  if (wr_virtex6_gtx_rx[4])   virtex6_gtx_rx_wr[4] <=  d[15:0];
  if (wr_virtex6_gtx_rx[5])   virtex6_gtx_rx_wr[5] <=  d[15:0];
  if (wr_virtex6_gtx_rx[6])   virtex6_gtx_rx_wr[6] <=  d[15:0];  
  if (wr_virtex6_sysmon)      virtex6_sysmon_wr    <=  d[15:0];
  if (wr_virtex6_extend)      virtex6_extend_wr    <=  d[15:0];
  if (wr_mpc_frames_fifo_ctrl) mpc_frames_fifo_ctrl_wr <= d[15:0];
  end

//------------------------------------------------------------------------------------------------------------------
// Sump for unused signals
//------------------------------------------------------------------------------------------------------------------
  assign vme_sump =
  perr_sump0          |
  perr_sump1          |
  seqdeb_sump          |
  alct_stat_sump        |
  sync_err_ctrl_sump      |
  cfeb_badbits_ctrl_sump    |
  mod_cfg_sump        |
  l1a_lookback_sump      |
  scint_veto_dummy      |
  bx0_delay_wr[10]      |
  rpc_lptmb          |
  rpc_loop_bdtest        |
  cylon_two[7]        |
  (|phaser0_wr[6:2])      |
  (|phaser1_wr[6:2])      |
  (|phaser2_wr[6:2])      |
  (|phaser3_wr[6:2])      |
  (|phaser4_wr[6:2])      |
  (|phaser5_wr[6:2])      |
  (|phaser6_wr[6:2])      |
  (|phaser7_wr[6:2])      |
  (|phaser8_wr[6:2])      |
  (|vsm_adr[23:9])      |
  (|usr_jtag_wr[15:14])    |
  (|dsn_wr[14:13])      | (|dsn_wr[9:8])      | (|dsn_wr[4:3])    |
  (|tmb_loop_wr[1:0])      | (|tmb_loop_wr[5:4])    | (|tmb_loop_wr[10:7])  |
  (|non_trig_ro_wr[9:5])    | (|non_trig_ro_wr[15:12])  |
  (|vmesm0_wr[10:8])      | (|vmesm0_wr[6:2])      |
   !(|tmb_loop_ro[3:2])      | tmb_loop_ro[6]      | (|tmb_loop_ro[15:11])  |
  (|dddsm_wr[15:6])      | dddsm_wr[4]        |
  (|dddrsm_wr[7:6])      | dddrsm_wr[4]        |
  (|adc_wr[5:0])        | adc_wr[11]        |
  (|alct_cfg_wr[11:10])    |
  (|mpc_inj_wr[13:10])    |
  (|scp_ctrl_wr[13:12])    |
  (|scp_rdata_wr[15:9])    |
  (|ccb_cmd_wr[6:4])      |
  (|rpc_cfg_wr[14:11])    |
  (|rpc_raw_delay_wr[15:8])  |
  (|rpc_inj_wr[13:11])    |
  (|cnt_ctrl_wr[4:3])      |
  (|jtagsm0_wr[10:3])      |
  (|layer_trig_wr[6:4])    |
  (|alct_sync_ctrl_wr[9:6])  |
  (|virtex6_gtx_rx_sump)    |
  virtex6_snap12_qpll_sump  |
  virtex6_gtx_rx_all_sump    |
  virtex6_sysmon_sump      |
  adc_sump          |
  cfeb_v6_badbits_ctrl_sump  |
  virtex6_extend_sump
  ;


  reg ds0_r=0;
  always @(posedge clock or posedge global_reset) begin
    if (global_reset) ds0_r <= 0; // consider if ds0 should be registered or use the raw input... rise on time & fall early?
    else   ds0_r <= ds0;
  end
  
  wire        bpi_dev = (bd_sel & (a_vme[17:15] == 3'h5)); // a_vme is [23:1], for bpi_dev address we use 3 bits: [17:15] <-- this correctly works in real hardware
//  wire        bpi_dev = (bd_sel & (a_vme[18:16] == 3'h5));   // a_vme is [23:1], for bpi_dev address we use 3 bits: [18:16] <-- this correctly works in simulation
  wire [9:0]  bpi_cmd = (a_vme[11:2]);                     // a_vme is [23:1], for bpi_command we use 10 bits: [11:2] <-- this correctly works in real hardware
//  wire [9:0]  bpi_cmd = (a_vme[12:3]);                       // a_vme is [23:1], for bpi_command we use 10 bits: [12:3] <-- this correctly works in simulation
  wire [15:0] bpi_fifo_dout;
  wire [10:0] bpi_fifo_cnt;
  wire [15:0] bpi_stat;
  wire [31:0] bpi_time;
  wire [15:0] bpi_outdata;       // out to VME
  wire [15:0] bpi_cmd_fifo_data; // out
  wire        bpi_dtack;
  wire        bpi_rst;
  wire        bpi_we;
  wire        bpi_re;
  wire        bpi_dsbl;
  wire        bpi_enbl;
  wire        bpi_rd_stat;
  
  wire        bpi_busy;      // JRG, all done
  wire        bpi_load_data; // JRG, all done
  wire        bpi_execute;   // JRG, all done
  wire [15:0] bpi_data_from; // JRG, all done
  wire [15:0] bpi_data_to;   // JRG, all done
  wire [22:0] bpi_addr;      // JRG, all done
  wire  [1:0] bpi_op;        // JRG, all done

  BPI_PORT bpi_vme (
    .CLK (clock),        // 40MHz clock
    .RST (global_reset), // system reset
     // VME selection/control
    .DEVICE  (bpi_dev),     // 1 bit indicating this device has been selected... JRG: choose any available OTMB adr range
    .STROBE  (ds0),         // Data strobe synchronized to rising or falling edge of clock and asynchronously cleared
    .COMMAND (bpi_cmd),     // [9:0] command portion of VME address... JRG: assume it is address bits 11:2?
    .WRITE_B (nwrite),      // VME read/write_bar
    .INDATA  (d),           // [15:0] data from VME writes to be provided to BPI interface
    .OUTDATA (bpi_outdata), // out data from BPI interface to VME buss for reads
    .DTACK   (bpi_dtack),   // out DTACK to VME  ^^^JG: All Good^^^
     // BPI controls...  JRG: what modules do these connect with?
    .BPI_RST           (bpi_rst),           // out Resets BPI interface state machines
    .BPI_CMD_FIFO_DATA (bpi_cmd_fifo_data), // out Data for command FIFO
    .BPI_WE            (bpi_we),            // out Command FIFO write enable  (pulse one clock cycle for one write)
    .BPI_RE            (bpi_re),            // out Read-back FIFO read enable  (pulse one clock cycle for one read)
    .BPI_DSBL          (bpi_dsbl),          // out Disable parsing of BPI commands in the command FIFO (while being filled)
    .BPI_ENBL          (bpi_enbl),          // out Enable  parsing of BPI commands in the command FIFO
    .BPI_RD_STATUS     (bpi_rd_stat),       // out Read BPI interface status register command received
    .BPI_RBK_FIFO_DATA (bpi_fifo_dout),     // in [15:0] Data on output of the Read-back FIFO
    .BPI_RBK_WRD_CNT   (bpi_fifo_cnt),      // in [10:0] Word count of the Read-back FIFO (number of available reads)
    .BPI_STATUS        (bpi_stat),          // in [15:0] FIFO status bits and latest value of the PROM status register. 
    .BPI_TIMER         (bpi_time)           // in [31:0] General timer
  );

  BPI_ctrl  #( .USE_CHIPSCOPE (0) ) bpi_engine (  // also has two FIFOs
    .CLK     (clock),      // in 40 MHz clock
    .CLK1MHZ (clock_1mhz), // in  1 MHz clock for timers
    .RST     (bpi_rst),    // in 
     // Interface Signals to/from VME interface
    .BPI_CMD_FIFO_DATA (bpi_cmd_fifo_data), // in [15:0] Data for command FIFO
    .BPI_WE            (bpi_we),            // in Command FIFO write enable  (pulse one clock cycle for one write)
    .BPI_RE            (bpi_re),            // in Read back FIFO read enable  (pulse one clock cycle for one read)
    .BPI_DSBL          (bpi_dsbl),          // in Disable parsing of BPI commands in the command FIFO (while being filled)
    .BPI_ENBL          (bpi_enbl),          // in Enable  parsing of BPI commands in the command FIFO
    .BPI_RBK_FIFO_DATA (bpi_fifo_dout),     // out [15:0] Data on output of the Read back FIFO
    .BPI_RBK_WRD_CNT   (bpi_fifo_cnt),      // out [10:0] Word count of the Read back FIFO (number of available reads)
    .BPI_STATUS        (bpi_stat),          // out [15:0] FIFO status bits and latest value of the PROM status register. 
    .BPI_TIMER         (bpi_time),          // out [31:0] General timer
     // Signals to/from low level BPI interface
    .BPI_BUSY      (bpi_busy),            // in 
    .BPI_DATA_FROM (bpi_data_from[15:0]), // in [15:0] 
    .BPI_LOAD_DATA (bpi_load_data),       // in 
    .BPI_ACTIVE    (bpi_active),          // Out "BPI Active set to 1 when data lines are for BPI communications": going to BPI_CTRL and to otmb_virtex6_top then to sequencer and to outside trough mez_tp[3]
    .BPI_OP        (bpi_op[1:0]),         // out [1:0] 
    .BPI_ADDR      (bpi_addr[22:0]),      // out [22:0] 
    .BPI_DATA_TO   (bpi_data_to[15:0]),   // out [15:0] 
    .BPI_EXECUTE   (bpi_execute)          // out 
  );

  bpi_interface bpi_busctrl (
    .CLK          (clock),               // in 40 MHz clock
    .RST          (bpi_rst),             // in  -- JRG: from BPI_VME
    .ADDR         (bpi_addr[22:0]),      // in [22:0] Bank/Array Address  -- JRG: from BPI_CTRL
    .CMD_DATA_OUT (bpi_data_to[15:0]),   // in [15:0] Command or Data being written to FLASH device  -- JRG: from BPI_CTRL
    .OP           (bpi_op[1:0]),         // in [1:0] Operation: 00-standby, 01-write, 10-read, 11-not allowed(standby)  -- JRG: from BPI_CTRL
    .EXECUTE      (bpi_execute),         // in  -- JRG: from BPI_CTRL
    .DATA_IN      (bpi_data_from[15:0]), // out [15:0] Data read from FLASH device  -- JRG: to BPI_CTRL
    .LOAD_DATA    (bpi_load_data),       // out Clock enable signal for capturing Data read from FLASH device  -- JRG: to BPI_CTRL
    .BUSY         (bpi_busy),            // out Operation in progress signal (not ready)  -- JRG: to BPI_CTRL
    // signals for Dual purpose data lines
    .BPI_ACTIVE (bpi_active), // In "BPI Active set to 1 when data lines are for BPI communications": coming from BPI_CTRL
    .DUAL_DATA  (led_tmb),    // in [15:0] Data provided for non BPI communications -- JRG: probably should be TMB signals for LEDs
    // external connections cooresponding to I/O pins
    .BPI_AD     (bpi_ad_out),    // out [22:0]  JRG, what is this?
    // JRG: do I use this access port to define the IO pins in ref to UCF?  I think yes...
    .CFG_DAT    (led_tmb_out),   // inout [15:0]  JRG, what is this?  Probably should match it to LED bus (16) named in UCF, take out to TOP
// JRG, not needed:   output RS0,
// JRG, not needed:   output RS1,
//    .FCS_B    (prm_fcs),  // out, take to otmb_top
//    .FOE_B    (prm_foe),  // out, take to otmb_top
//    .FWE_B    (prm_fwe),  // out, take to otmb_top
//    .FLATCH_B (prm_load), // out, take to otmb_top
    .FLASH_CTRL         (flash_ctrl),        // out [3:0] ~fcs, ~foe, ~fwe, ~latch_adr
    .FLASH_CTRL_DUALUSE (flash_ctrl_dualuse) // in [2:0] ~foe, ~fwe, ~latch_adr
  );

/*
BPI use cases we've got to handle for OTMB
------------------------------------------
  External Prom_Adr bus:   [23 bits, keep this I/O buffer control in TMB modules, uses obuf_ff at 40 MHz]
    -driven by TMB logic [DMB_Tx data with i/o register]  (use bpi_dev signal from TMB VME decode as the MUX switch for this?)
    -also driven by BPI_ctrl via bpi_interface?   Will a 25 ns i/o register delay on this mess up BPI transactions?
       -->  What Adr signal do I pass out from BPI code and hand to TMB "DMB_Tx" mux logic?


  External Prom_Data bus:   [16 bits, this is currently low-speed for TMB LEDs... ok to have I/O control for this in BPI modules, but how?]
    -driven by TMB logic [FP_LED control for TMB] 
       -->  Should I pass TMB LED bits into the BPI "Dual_Data" port?
    -also driven by BPI_ctrl via bpi_interface?
    -and also an input for BPI_ctrl from the Prom via bpi_interface?  (needs a direction switch... does it exist already?)
       -->  Maybe this part is handled by  data_from  and  data _to?  Then no changes would be needed here...


 How are those things above related to these bpi_interface ports?
    .DUAL_DATA (),    // in [15:0] Data provided for non BPI communications    Q: comes from where? purpose?  Use it for TMB LED output?
     // external connections corresponding to I/O pins... are these only needed if TMB logic will use these pins as input?
    .BPI_AD (),    // inout [22:0]   Q: what is this?   ignore?  TMB will drive Adr bus elsewhere (mixed with DMB_Tx data i/o register)
    .CFG_DAT (),   // inout [15:0]   Q: what is this?   ignore?  I don't see a use for it on OTMB...


Note:  I plan to delete the following line from bpi_interface... any bad side effects?  The Adr I/O will be driven in TMB logic.
    IOBUF #(.DRIVE(12),.IOSTANDARD("DEFAULT"),.SLEW("SLOW")) IOBUF_BPI_AD[22:0] (.O(bpi_ad_in),.IO(BPI_AD),.I(bpi_ad_out_r),.T(bpi_dir));
       -->  Then I guess I also have to delete the BPI_AD port as well, right?


  */

//------------------------------------------------------------------------------------------------------------------
  endmodule
//------------------------------------------------------------------------------------------------------------------

