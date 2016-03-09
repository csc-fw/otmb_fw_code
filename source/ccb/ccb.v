`timescale 1ns / 1ps
//`define DEBUG_CCB 0  // uncomment to enable state machine ascii display for simulator
//------------------------------------------------------------------------------------------------------------------
// CCB signals
//------------------------------------------------------------------------------------------------------------------
//  12/20/2000  Initial
//  01/02/2002  Changed external to ext
//  03/11/2002  Changed library calls to behavioral code, removed mpc temporary code
//  03/29/2002  Added status enables + internal L1A logic + move l1a request from tmb2001a.v
//  04/09/2002  Added dmb_rx and dmb_ext_trig
//  05/02/2002  Added adb ext trig
//  06/06/2002  Moved external trigger processing to sequencer
//  08/01/2002  Added mpc injector ttc command
//  03/13/2003  New ttc decodes
//  03/13/2003  New vme cmd
//  03/15/2003  Add bx0 decode
//  03/25/2003  Add wait for bx0 after start triggering
//  04/29/2003  Add ttc_bxreset per OSU demand
//  10/06/2003  Expand dmb_rx for tmb2003a
//  04/12/2004  Un-inverted tmb_cfg_done beco no pull-ups on TMB
//  04/13/2004  Re-invert tmb_cfg_done beco GTL drivers have bus hold
//  04/20/2004  Remove redundant dmb_rx[1:0] IOB FFs, was OK in VirtexE, fails in Virtex2
//  08/30/2004  Allow alct_ext_trig from ccb similar to clct
//  08/08/2005  Fix ccb_status tri-state bus contention
//  09/15/2006  Mod for xst
//  09/19/2006  Fix gtl_loop_lcl, invert to enable ccb_tx
//  10/04/2006  Restructure cmd decoder loop
//  04/27/2007  Mod ffm state machine for resync, add ascii states, add ignore for ttc_start/stop, l1reset=>resync
//  08/22/2007  Orbit counter reset
//  05/22/2008  Add global reset + style tweaks, convert async to sync reset for FMM
//  05/30/2008  Add vme_evcntres
//  08/27/2008  Add ttc lock status
//  08/28/2008  Add lock cnt reset
//  01/13/2009  Mod for ISE 10.1i
//  04/22/2009  Add recovery to SMs
//  05/22/2009  Fix vme_bx0
//  09/23/2009  Push IO FFs into IOBs
//  04/27/2010  Add bx0 emulator for sync_err checking
//  04/29/2010  Add FF to bx0 emulator
//  05/13/2010  Remove resync from bx0 emulator, add inits to fmm state shadow ff and trig stop ff
//  06/30/2010  Mod injector RAM for alct and l1a bits
//  07/23/2010  Port to ise 12, arithmetic mods, fix sump OR
//  07/26/2010  Add iob attribute for dmb_rx and _ccb_tx
//  07/26/2010  Change to non-blocking operators on l1a_sm
//  08/19/2010  Replace * with &
//  11/12/2010  Invert oe and fanout ccb_tx bus to prevent inverter packing in ilogic block ise 12 warning in map
//  12/01/2010  Add virtex2 opt out for oe keep
//  02/13/2013  Virtex-6 only
//------------------------------------------------------------------------------------------------------------------
  module ccb
  (
// CCB I/O
  clock,
  global_reset,
  _ccb_rx,
  _ccb_tx,

// VME Control
  ccb_ignore_rx,
  ccb_allow_ext_bypass,
  ccb_disable_tx,
  ccb_int_l1a_en,
  ccb_ignore_startstop,
  alct_status_en,
  clct_status_en,
  gtl_loop_lcl,
  ccb_status_oe_lcl,
  lhc_cycle,

// TMB to CCB
  clct_status,
  alct_status,
  tmb_cfg_done,
  alct_cfg_done,
  tmb_reserved_in,

// Commands From CCB
  ccb_cmd,
  ccb_cmd_strobe,
  ccb_data_strobe,
  ccb_subaddr_strobe,

// Signals From CCB
  ccb_clock40_enable,
  ccb_reserved,
  ccb_evcntres,
  ccb_bcntres,
  ccb_bx0,
  ccb_l1accept,

  tmb_hard_reset,
  alct_hard_reset,
  tmb_reserved,
  alct_adb_pulse_sync,
  alct_adb_pulse_async,
  clct_ext_trig,
  alct_ext_trig,
  dmb_ext_trig,
  tmb_reserved_out,
  ccb_sump,

// Monitored DMB Signals
  dmb_cfeb_calibrate,
  dmb_l1a_release,
  dmb_reserved_out,
  dmb_reserved_in,

// DMB Rx
  dmb_rx,
  dmb_rx_ff,

// MPC Muon Accept
  mpc_in,

// Level 1 Accept Ports from VME and Sequencer
  clct_ext_trig_l1aen,
  alct_ext_trig_l1aen,
  seq_trig_l1aen,
  seq_trigger,

// Trigger ports from VME
  alct_ext_trig_vme,
  clct_ext_trig_vme,
  ext_trig_both,
  l1a_vme,
  l1a_delay_vme,
  l1a_inj_ram,
  l1a_inj_ram_en,
  inj_ramout_busy,

// TTC Decoded Commands
  ttc_bx0,
  ttc_resync,
  ttc_bxreset,
  ttc_mpc_inject,
  ttc_orbit_reset,
  fmm_trig_stop,

// VME
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
  cnt_all_reset,
  ccb_ttcrx_lock_never,
  ccb_ttcrx_lost_ever,
  ccb_ttcrx_lost_cnt,
  ccb_qpll_lock_never,
  ccb_qpll_lost_ever,
  ccb_qpll_lost_cnt

// Debug
`ifdef DEBUG_CCB
  ,sm_reset
  ,fmm_sm_disp
  ,l1a_sm_disp
  ,tmb_l1a_request
  ,int_l1a_request
  ,tmb_l1a_request_mux
`endif
  );
  
//------------------------------------------------------------------------------------------------------------------
// Constants:
//------------------------------------------------------------------------------------------------------------------
  parameter MXBXN    =  12;          // Number BXN bits, LHC bunchs numbered 0 to 3563

//------------------------------------------------------------------------------------------------------------------
// CCB Ports
//------------------------------------------------------------------------------------------------------------------
  input         clock;          // 40MHz TMB system clock
  input         global_reset;      // 1=Reset everything
  input  [50:0] _ccb_rx;        // GTLP data from CCB, inverted
  output [26:0] _ccb_tx;        // GTLP data to   CCB, inverted

// VME Control Ports
  input        ccb_ignore_rx;      // 1=Ignore CCB backplane inputs
  input        ccb_allow_ext_bypass;  // 1=Allow alct/clct_ext_trigger_ccb even if ccb_ignore_rx=1
  input        ccb_disable_tx;      // 1=Disable CCB backplane outputs
  input        ccb_int_l1a_en;      // 1=Enable CCB internal l1a emulator
  input        ccb_ignore_startstop;  // 1=ignore ttc trig_start/stop commands
  input        alct_status_en;      // 1=Enable status GTL outputs
  input        clct_status_en;      // 1=Enable status GTL outputs
  input        gtl_loop_lcl;      // 1=Enable gtl loop mode
  input        ccb_status_oe_lcl;    // 1=Enable status GTL outputs
  input  [MXBXN-1:0]  lhc_cycle;        // LHC period, max BXN count+1

// TMB signals transmitted to CCB
  input  [8:0]    clct_status;      // CLCT status for CCB front panel (VME sets status_oe)
  input  [8:0]    alct_status;      // ALCT status for CCB front panel
  input        tmb_cfg_done;      // FPGA loaded
  input        alct_cfg_done;      // FPGA loaded
  input  [4:0]    tmb_reserved_in;    // Unassigned

// TMB Command Word
  output  [7:0]    ccb_cmd;        // CCB command word
  output        ccb_cmd_strobe;      // CCB command word strobe
  output        ccb_data_strobe;    // CCB data word strobe
  output        ccb_subaddr_strobe;    // CCB subaddress strobe

// TMB signals received from CCB
  output        ccb_clock40_enable;    // Enable 40MHz clock
  output  [4:0]    ccb_reserved;      // Unassigned
  output        ccb_evcntres;      // Event counter reset
  output        ccb_bcntres;      // Bunch crossing counter reset
  output        ccb_bx0;        // Bunch crossing zero
  output        ccb_l1accept;      // Level 1 Accept

  output        tmb_hard_reset;      // Reload TMB  FPGA
  output        alct_hard_reset;    // Reload ALCT FPGA
  output  [1:0]    tmb_reserved;      // Unassigned
  output        alct_adb_pulse_sync;  // ALCT synchronous  test pulse
  output        alct_adb_pulse_async;  // ALCT asynchronous test pulse
  output        clct_ext_trig;      // CLCT external trigger
  output        alct_ext_trig;      // ALCT external trigger
  output        dmb_ext_trig;      // DMB  external trigger
  output  [2:0]    tmb_reserved_out;    // Unassigned
  output        ccb_sump;        // Unused signals

// Monitored DMB Signals
  output  [2:0]    dmb_cfeb_calibrate;    // DMB calibration
  output        dmb_l1a_release;    // DMB test
  output  [4:0]    dmb_reserved_out;    // DMB unassigned
  output  [2:0]    dmb_reserved_in;    // DMB unassigned

// DMB Received
  input  [5:0]    dmb_rx;          // DMB Received data
  output  [5:0]    dmb_rx_ff;        // DMB latched for VME

// MPC Muon Accept (not latched or inverted here)
  output  [1:0]    mpc_in;          // MPC muon accept reply

// Level 1 Accept Ports from VME and Sequencer
  input        clct_ext_trig_l1aen;  // 1=Request ccb l1a on clct ext_trig
  input        alct_ext_trig_l1aen;  // 1=Request ccb l1a on alct ext_trig
  input        seq_trig_l1aen;      // 1=Request ccb l1a on sequencer trigger
  input        seq_trigger;      // Sequencer requests L1A from CCB

// Trigger ports from VME
  input        alct_ext_trig_vme;    // 1=Fire alct_ext_trig oneshot
  input        clct_ext_trig_vme;    // 1=Fire clct_ext_trig oneshot
  input        ext_trig_both;      // 1=clct_ext_trig fires alct and alct fires clct_trig, DC level
  input        l1a_vme;        // 1=fire ccb_l1accept oneshot
  input  [7:0]    l1a_delay_vme;      // Internal L1A delay
  input        l1a_inj_ram;      // L1A injector RAM pulse
  input        l1a_inj_ram_en;      // L1A injector RAM enable
  input        inj_ramout_busy;    // Injector RAM busy

// TTC Decoded Commands
  output        ttc_bx0;        // Bunch crossing zero
  output        ttc_resync;        // Purge l1a processing stack
  output        ttc_bxreset;      // Reset bxn
  output        ttc_mpc_inject;      // Start MPC injector
  output        ttc_orbit_reset;    // Reset orbit counter
  output        fmm_trig_stop;      // Stop clct trigger sequencer

// VME
  input        vme_ccb_cmd_enable;    // Disconnect ccb_cmd_bpl, use vme_ccb_cmd;
  input  [7:0]    vme_ccb_cmd;      // CCB command word
  input        vme_ccb_cmd_strobe;    // CCB command word strobe
  input        vme_ccb_data_strobe;  // CCB data word strobe
  input        vme_ccb_subaddr_strobe;  // CCB subaddress strobe
  input        vme_evcntres;      // Event counter reset, from VME
  input        vme_bcntres;      // Bunch crossing counter reset, from VME
  input        vme_bx0;        // Bunch crossing zero, from VME
  input        vme_bx0_emu_en;      // BX0 emulator enable
  output  [2:0]    fmm_state;        // FMM machine state

//  CCB TTC lock status
  input        cnt_all_reset;      // Trigger/Readout counter reset
  output        ccb_ttcrx_lock_never;  // Lock never achieved
  output        ccb_ttcrx_lost_ever;  // Lock was lost at least once
  output  [7:0]    ccb_ttcrx_lost_cnt;    // Number of times lock has been lost
  output        ccb_qpll_lock_never;  // Lock never achieved
  output        ccb_qpll_lost_ever;    // Lock was lost at least once
  output  [7:0]    ccb_qpll_lost_cnt;    // Number of times lock has been lost

// Debug
`ifdef DEBUG_CCB
  output        sm_reset;        // State machine reset
  output  [55:0]    fmm_sm_disp;      // FMM machine state ascii display
  output  [55:0]    l1a_sm_disp;      // L1A machine state ascii display
  output        tmb_l1a_request;
  output        int_l1a_request;
  output        tmb_l1a_request_mux;
`endif

//------------------------------------------------------------------------------------------------------------------
// Local
//------------------------------------------------------------------------------------------------------------------
  wire  [7:0]    ccb_data_gtl;
  wire  [7:0]    ccb_cmd_gtl;
  wire        ccb_cmd_strobe_gtl;
  wire        ccb_data_strobe_gtl;
  wire        alct_ext_trigger_ccb;
  wire        clct_ext_trigger_ccb;
  wire        ccb_l1accept_ccb;
  wire        l1a_done;

//---------------------------------------------------------------------------------------------------------------------
//  Power-up Section:
//---------------------------------------------------------------------------------------------------------------------
// Startup timer waits for TMB to initialize
  wire  [3:0]  pdly = 1;      // Power-up reset delay
  reg    powerup_ff   = 0;

  SRL16E upowerup (.CLK(clock),.CE(!powerupq),.D(1'b1),.A0(pdly[0]),.A1(pdly[1]),.A2(pdly[2]),.A3(pdly[3]),.Q(powerupq));

  always @(posedge clock) begin
  powerup_ff <= powerupq && !global_reset;
  end

  wire sm_reset     = !powerup_ff;  // shifts timing from LUT to FF
  wire startup_done =  powerup_ff;

//---------------------------------------------------------------------------------------------------------------------
//  CCB Receiver Section:
//---------------------------------------------------------------------------------------------------------------------
// Buffer VME controls
  reg alct_status_en_ff    = 0;
  reg clct_status_en_ff    = 0;
  reg clct_ext_trig_l1aen_ff  = 0;
  reg alct_ext_trig_l1aen_ff  = 0;
  reg seq_trig_l1aen_ff    = 0;
  reg ext_trig_both_ff    = 0;

  always @(posedge clock) begin
  alct_status_en_ff     <= alct_status_en;
  clct_status_en_ff     <= clct_status_en;
  clct_ext_trig_l1aen_ff  <= clct_ext_trig_l1aen;
  alct_ext_trig_l1aen_ff  <= alct_ext_trig_l1aen;
  seq_trig_l1aen_ff    <= seq_trig_l1aen;
  ext_trig_both_ff    <= ext_trig_both;
  end

// Latch CCB inputs in IOB FFs, and un-invert GTLP, do not process MPC signals [35:34]
  reg   [33:0]  ccb_rx_iobff_a = {34{1'b1}}; // synthesis attribute IOB of ccb_rx_iobff_a is "true";
  reg   [50:36] ccb_rx_iobff_b = {15{1'b1}}; // synthesis attribute IOB of ccb_rx_iobff_b is "true";
  wire [50:0]   ccb_rx_iobff;
  wire [35:34] zero = 2'b00;
  
  always @(posedge clock) begin
  ccb_rx_iobff_a[33:0]  <= _ccb_rx[33:0];
  ccb_rx_iobff_b[50:36] <= _ccb_rx[50:36];
  end

  assign ccb_rx_iobff = {~ccb_rx_iobff_b[50:36],zero[35:34],~ccb_rx_iobff_a[33:0]};
  
// Block CCB signals if CCB is not present
  wire [50:0]  ccb_rx_ff;
  wire        block_ccb;

  assign block_ccb       = (ccb_ignore_rx || sm_reset);
  assign ccb_rx_ff[50:0] = (block_ccb) ? {51{1'b0}} : ccb_rx_iobff;

// Map signal names received from CCB
  assign  ccb_clock40_enable  =  ccb_rx_ff[ 0];
  assign  ccb_reserved[4]    =  ccb_rx_ff[ 1];
  assign  ccb_cmd_gtl[0]    =  ccb_rx_ff[ 2];
  assign  ccb_cmd_gtl[1]    =  ccb_rx_ff[ 3];
  assign  ccb_cmd_gtl[2]    =  ccb_rx_ff[ 4];
  assign  ccb_cmd_gtl[3]    =  ccb_rx_ff[ 5];
  assign  ccb_cmd_gtl[4]    =  ccb_rx_ff[ 6];
  assign  ccb_cmd_gtl[5]    =  ccb_rx_ff[ 7];
  assign  ccb_evcntres    =  ccb_rx_ff[ 8] | vme_evcntres;
  assign  ccb_bcntres      =  ccb_rx_ff[ 9] | vme_bcntres;
  assign  ccb_cmd_strobe_gtl  =  ccb_rx_ff[10];
  assign  ccb_bx0        =  ccb_rx_ff[11] | vme_bx0;
  assign  ccb_l1accept_ccb  =  ccb_rx_ff[12];
  assign  ccb_data_strobe_gtl  =  ccb_rx_ff[13];
  assign  ccb_data_gtl[0]    =  ccb_rx_ff[14];
  assign  ccb_data_gtl[1]    =  ccb_rx_ff[15];
  assign  ccb_data_gtl[2]    =  ccb_rx_ff[16];
  assign  ccb_data_gtl[3]    =  ccb_rx_ff[17];
  assign  ccb_data_gtl[4]    =  ccb_rx_ff[18];
  assign  ccb_data_gtl[5]    =  ccb_rx_ff[19];
  assign  ccb_data_gtl[6]    =  ccb_rx_ff[20];
  assign  ccb_data_gtl[7]    =  ccb_rx_ff[21];
  assign  ccb_reserved[0]    =  ccb_rx_ff[22];
  assign  ccb_reserved[1]    =  ccb_rx_ff[23];
  assign  ccb_reserved[2]    =  ccb_rx_ff[24];
  assign  ccb_reserved[3]    =  ccb_rx_ff[25];
  assign  tmb_hard_reset    =  ccb_rx_ff[26];
  assign  alct_hard_reset    =  ccb_rx_ff[27];
  assign  tmb_reserved[0]    =  ccb_rx_ff[28];
  assign  tmb_reserved[1]    =  ccb_rx_ff[29];
  assign  alct_adb_pulse_sync  =  ccb_rx_ff[30];
  assign  alct_adb_pulse_async=  ccb_rx_ff[31];
  assign  clct_ext_trigger_ccb=  (ccb_allow_ext_bypass) ? ccb_rx_iobff[32] : ccb_rx_ff[32];
  assign  alct_ext_trigger_ccb=  (ccb_allow_ext_bypass) ? ccb_rx_iobff[33] : ccb_rx_ff[33];
  assign  mpc_in[0]      =  _ccb_rx[34];    // 80MHz, not latched or inverted here
  assign  mpc_in[1]      =  _ccb_rx[35];    // 80MHz, not latched or inverted here
  assign  tmb_reserved_out[0]  =  ccb_rx_ff[36];
  assign  tmb_reserved_out[1]  =  ccb_rx_ff[37];
  assign  tmb_reserved_out[2]  =  ccb_rx_ff[38];
  assign  dmb_cfeb_calibrate[0]=  ccb_rx_ff[39];
  assign  dmb_cfeb_calibrate[1]=  ccb_rx_ff[40];
  assign  dmb_cfeb_calibrate[2]=  ccb_rx_ff[41];
  assign  dmb_l1a_release    =  ccb_rx_ff[42];
  assign  dmb_reserved_out[0]  =  ccb_rx_ff[43];
  assign  dmb_reserved_out[1]  =  ccb_rx_ff[44];
  assign  dmb_reserved_out[2]  =  ccb_rx_ff[45];
  assign  dmb_reserved_out[3]  =  ccb_rx_ff[46];
  assign  dmb_reserved_out[4]  =  ccb_rx_ff[47];
  assign  dmb_reserved_in[0]  =  ccb_rx_ff[48];
  assign  dmb_reserved_in[1]  =  ccb_rx_ff[49];
  assign  dmb_reserved_in[2]  =  ccb_rx_ff[50];

// Multiplex cmd, data, and subaddr onto cmd bus
  wire [7:0] ccb_cmd_mux;

  assign ccb_cmd_gtl[7]     =  ccb_bcntres;  // For ALCT, don't use for cmd decoding here
  assign ccb_cmd_gtl[6]     =  ccb_evcntres;  // For ALCT, don't use for cmd decoding here

  assign ccb_cmd_mux = (ccb_data_strobe) ? ccb_data_gtl : ccb_cmd_gtl;

// Multiplex VME-sourced TTC commands with CCB backplane signals
  reg [7:0] vme_ccb_cmd_s0 = 0;
  reg [7:0] vme_ccb_cmd_ff = 0;

  always @(posedge clock) begin
  vme_ccb_cmd_s0  <= vme_ccb_cmd;  // delay vme cmd to be in time with vme strobe one-shots
  vme_ccb_cmd_ff  <= vme_ccb_cmd_s0;
  end

  x_oneshot uvmecs (.d(vme_ccb_cmd_strobe    ),.clock(clock),.q(vme_ccb_cmd_strobe_os    ));
  x_oneshot uvmeds (.d(vme_ccb_data_strobe   ),.clock(clock),.q(vme_ccb_data_strobe_os   ));
  x_oneshot uvmess (.d(vme_ccb_subaddr_strobe),.clock(clock),.q(vme_ccb_subaddr_strobe_os));

  assign ccb_cmd[7:0]      = (vme_ccb_cmd_enable) ? vme_ccb_cmd_ff[7:0]    : ccb_cmd_mux[7:0];
  assign ccb_cmd_strobe    = (vme_ccb_cmd_enable) ? vme_ccb_cmd_strobe_os    : ccb_cmd_strobe_gtl;
  assign ccb_data_strobe    = (vme_ccb_cmd_enable) ? vme_ccb_data_strobe_os    : ccb_data_strobe_gtl;
  assign ccb_subaddr_strobe  = (vme_ccb_cmd_enable) ? vme_ccb_subaddr_strobe_os  : 1'b0;

// Decode CCB TTC command, latch it, and one-clock-wide pulse it coincident with ccb_cmd_strobe
  parameter MXDEC = 'h32;    // Highest CCB Command decode
  reg  [MXDEC:0] ccb_cmd_dec =0;

  integer i;
  always @(posedge clock) begin
  i=0;
  while (i<=MXDEC)
  begin
  ccb_cmd_dec[i] <= (ccb_cmd[5:0]==i) && ccb_cmd_strobe;
  i=i+1;
  end
  end

// Map decoded signal names: per CCB 2001 spec version 2.2 01/06/2003
  wire ttc_bx0_dec        = ccb_cmd_dec['h01];  // Bunch Crossing Zero   
  wire ttc_resync          = ccb_cmd_dec['h03];  // Reset L1 readout buffers and resynchronize optical links   
//  wire ttc_hard_reset        = ccb_cmd_dec['h04];  // Reload all FPGAs from EPROMs   
  wire ttc_start_trigger      = ccb_cmd_dec['h06];  // 
  wire ttc_stop_trigger      = ccb_cmd_dec['h07];  // 
//  wire ttc_test_enable      = ccb_cmd_dec['h08];  // 
//  wire ttc_private_gap      = ccb_cmd_dec['h09];  // 
//  wire ttc_private_orbit      = ccb_cmd_dec['h0A];  // 
//  wire ttc_tmb_hard_reset      = ccb_cmd_dec['h10];  // Reload TMB FPGAs from EPROM   
//  wire ttc_alct_hard_reset    = ccb_cmd_dec['h11];  // Reload ALCT FPGAs from EPROM   
//  wire ttc_dmb_hard_reset      = ccb_cmd_dec['h12];  // Reload DMB FPGAs from EPROM   
//  wire ttc_mpc_hard_reset      = ccb_cmd_dec['h13];  // Reload MPC FPGAs from EPROM   
//  wire ttc_dmb_cfeb_calibrate0  = ccb_cmd_dec['h14];  // CFEB Calibrate Pre-Amp Gain   
//  wire ttc_dmb_cfeb_calibrate1  = ccb_cmd_dec['h15];  // CFEB Trigger Pattern Calibration   
//  wire ttc_dmb_cfeb_calibrate2  = ccb_cmd_dec['h16];  // CFEB Pedestal Calibration   
//  wire ttc_dmb_cfeb_initiate    = ccb_cmd_dec['h17];  // Initiate CFEB calibration (Hold next L1ACC and Pretriggers) Alct_adb_pulse_sync  18  Pulse Anode Discriminator, synchronous   
//  wire ttc_alct_adb_pulse_async  = ccb_cmd_dec['h19];  // Pulse Anode Discriminator, asynchronous   
//  wire ttc_clct_external_trigger  = ccb_cmd_dec['h1A];  // External Trigger All CLCTs   
//  wire ttc_alct_external_trigger  = ccb_cmd_dec['h1B];  // External Trigger All ALCTs   
//  wire ttc_soft_reset        = ccb_cmd_dec['h1C];  // Initializes the FPGA on DMB, TMB and MPC boards   
//  wire ttc_dmb_soft_reset      = ccb_cmd_dec['h1D];  // Initializes the FPGA on a DMB   
//  wire ttc_tmb_soft_reset      = ccb_cmd_dec['h1E];  // Initializes the FPGA on a TMB   
//  wire ttc_mpc_soft_reset      = ccb_cmd_dec['h1F];  // Initializes the FPGA on a MPC   
//  wire ttc_send_bcnt        = ccb_cmd_dec['h20];  // Send Bunch_Counter[7..0] to ccb_data[7..0] bus   
//  wire ttc_send_evcnt_lsb      = ccb_cmd_dec['h21];  // Send Event_Counter[7..0] to ccb_data[7..0] bus   
//  wire ttc_send_evcnt_msb      = ccb_cmd_dec['h22];  // Send Event_Counter[15..8] to ccb_data[7..0] bus   
//  wire ttc_send_evcnt        = ccb_cmd_dec['h23];  // Send Event_Counter[23..16] to ccb_data[7..0] bus   
  wire ttc_mpc_inject        = ccb_cmd_dec['h24];  // Injects patterns from TMBs internal RAM to MPC Alct_adb_pulse  25  Generate both synchronous and asynchronous anode discriminator pulses   
//  wire ttc_mpc_pattern        = ccb_cmd_dec['h30];  // Injects patterns from MPCs input FIFO to SP   
//  wire ttc_ms_pattern        = ccb_cmd_dec['h31];  // Injects patterns from MS input FIFO to Global Muon Trigger   
  wire ttc_bxreset        = ccb_cmd_dec['h32];  // Resets bxn, does not reset l1a count or buffers
  wire ttc_orbit_reset      = 0;          // Reset orbit counter, not defined yet

  assign ccb_sump = (|ccb_cmd_dec) | (|ccb_rx_ff[35:34]);  // Unused signals

// DMB Received data IOB
  reg [5:0]  dmb_rx_ff = 0;          // synthesis attribute IOB of dmb_rx_ff is "true";
  wire     tmb_l1a_release;
  wire    dmb_ext_trig;

  always @(posedge clock) begin        // Copy for VME
  dmb_rx_ff[5:0]  <= dmb_rx[5:0];  
  end

  assign tmb_l1a_release  = dmb_rx_ff[0];    // DMB Requested l1a release
  assign dmb_ext_trig    = dmb_rx_ff[1];    // DMB Requested ext_trig

// Multiplex External triggers from CCB or VME
  reg   alct_ext_trig = 0;
  reg   clct_ext_trig = 0;

  wire alct_ext_trig_vme_pulse;
  wire clct_ext_trig_vme_pulse;

  x_oneshot ualct_ext (.d(alct_ext_trig_vme),.clock(clock),.q(alct_ext_trig_vme_pulse));
  x_oneshot uclct_ext (.d(clct_ext_trig_vme),.clock(clock),.q(clct_ext_trig_vme_pulse));

  always @(posedge clock) begin
  alct_ext_trig <= alct_ext_trigger_ccb | alct_ext_trig_vme_pulse | (clct_ext_trigger_ccb & ext_trig_both_ff);
  clct_ext_trig <= clct_ext_trigger_ccb | clct_ext_trig_vme_pulse | (alct_ext_trigger_ccb & ext_trig_both_ff);
  end

// Assert tmb_l1a_request in response to an external trigger or a sequencer trigger (take care not to do both)
  reg  tmb_l1a_request = 0;
  reg  int_l1a_request = 0;

  wire tmb_l1a_request_mux =
  (clct_ext_trig & clct_ext_trig_l1aen_ff) | 
  (alct_ext_trig & alct_ext_trig_l1aen_ff) |
  (seq_trigger   & seq_trig_l1aen_ff     );

  always @(posedge clock) begin
  tmb_l1a_request  <= tmb_l1a_request_mux & ~ccb_disable_tx;
  int_l1a_request  <= tmb_l1a_request_mux &  ccb_int_l1a_en;
  end

// Internal L1A Generator State Machine
  reg  [1:0] l1a_sm;        // synthesis attribute safe_implementation of l1a_sm is "yes";
  parameter idle  =  0;
  parameter count  =  1;

  initial l1a_sm = idle;

  always @(posedge clock) begin
  if   (sm_reset)          l1a_sm <= idle;
  else begin
  case (l1a_sm)
  idle:  if (int_l1a_request)  l1a_sm <= count;
  count:  if (l1a_done)      l1a_sm <= idle;
  default              l1a_sm <= idle;
  endcase
  end
  end

// Internal L1A Generator Counter
  reg [7:0] l1a_delay_cnt = 0;

  always @(posedge clock) begin
  if    (l1a_sm == idle) l1a_delay_cnt <= 0;          // sync clear
  else if  (l1a_sm != idle) l1a_delay_cnt <= l1a_delay_cnt + 1'd1;  // sync count
  end

  assign l1a_done      = l1a_delay_cnt == l1a_delay_vme;
  wire   int_l1a_pulse = l1a_done && (l1a_sm != idle);

// Multiplex Level 1 Accepts from CCB, VME and Internal delay generator
  reg ccb_l1accept = 0;

  x_oneshot uvmel1a (.d(l1a_vme),.clock(clock),.q(l1a_vme_pulse));

  always @(posedge clock) begin
  ccb_l1accept <= ccb_l1accept_ccb | l1a_vme_pulse | int_l1a_pulse | (l1a_inj_ram & l1a_inj_ram_en & inj_ramout_busy);
  end

// Internal bx0  emulator
  reg [MXBXN-1:0]  bxn_emu = 0;                // LHC period, max BXN count+1
  reg             bx0_emu = 0;

  wire bxn_emu_ovf    = bxn_emu == lhc_cycle[11:0]-1;      // BXN maximum count for pretrig bxn counter
  wire bxn_emu_reset  = bxn_emu_ovf || !vme_bx0_emu_en;

  always @(posedge clock) begin
  if (bxn_emu_reset) bxn_emu <= 0;
  else               bxn_emu <= bxn_emu + 1'b1;
  end

  always @(posedge clock) begin
  bx0_emu <= (bxn_emu==0);                  // emulator bxn wrapped to bx0
  end

  assign ttc_bx0 = (vme_bx0_emu_en) ? bx0_emu : ttc_bx0_dec;  // select ttc bx0 or emulator bx0

//---------------------------------------------------------------------------------------------------------------------
//  FMM Section:
//---------------------------------------------------------------------------------------------------------------------
// FMM State Machine Declarations
  reg  [4:0] fmm_sm;          // synthesis attribute safe_implementation of fmm_sm is yes;
  parameter fmm_startup  =  0;    // synthesis attribute fsm_encoding        of fmm_sm is auto;
  parameter fmm_resync  =  1;
  parameter fmm_stop    =  2;
  parameter fmm_wait_bx0  =  3;
  parameter fmm_run    =  4;

  wire ignore = ccb_ignore_startstop;

// FMM State Machine
  initial fmm_sm = fmm_startup;
  
  always @(posedge clock) begin
  if    (sm_reset  ) fmm_sm <= fmm_startup;    // start-up reset
  else if  (ttc_resync) fmm_sm <= fmm_resync;    // re-sync  reset
  else begin

  case (fmm_sm)

  fmm_startup:                  // Startup wait
    if (startup_done)
     fmm_sm <= fmm_stop;

  fmm_resync:                    // Resync
    if (ttc_bx0)                // Bx0 arrived 1bx after resync
     fmm_sm <= fmm_run;    
    else 
     fmm_sm <= fmm_wait_bx0;

  fmm_stop:                    // Stop triggers
    if (ttc_start_trigger && !ignore)
     fmm_sm <= fmm_wait_bx0;

  fmm_wait_bx0:                  // Wait for bx0 after start_trigger
    if (ttc_bx0)
     fmm_sm <= fmm_run;
    else if (ttc_stop_trigger && !ignore)
     fmm_sm <= fmm_stop;

  fmm_run:                    // Process triggers
    if (ttc_stop_trigger && !ignore)
     fmm_sm <= fmm_stop;

  default
     fmm_sm <= fmm_stop;
  endcase
  end
  end


// FMM Control signals
  reg fmm_trig_stop = 1;                  // Power up stop state

  always @(posedge clock) begin
  if (sm_reset)  fmm_trig_stop <= 1;            // sync reset
  else      fmm_trig_stop <= (fmm_sm != fmm_run);  // Stop clct trigger sequencer
  end

// Monitor FFM state
  reg [2:0] fmm_state=0;
  always @(posedge clock) begin
  case (fmm_sm)
  fmm_startup:  fmm_state <= 0;
  fmm_resync:    fmm_state <= 1;
  fmm_stop:    fmm_state <= 2;
  fmm_wait_bx0:  fmm_state <= 3;
  fmm_run:    fmm_state <= 4;
  endcase
  end

//---------------------------------------------------------------------------------------------------------------------
//  CCB TTC lock status
//---------------------------------------------------------------------------------------------------------------------
  wire ccb_ttcrx_ready = ccb_reserved[0];
  wire ccb_qpll_locked = ccb_reserved[1];
  wire ccb_cnt_reset   = cnt_all_reset || sm_reset;

  ccb_lock uccb_lock0 (
  .clock    (clock),          // In  TMB main 40MHz clock
  .lock    (ccb_ttcrx_ready),      // In  Lock signal from TTC
  .reset    (ccb_cnt_reset),      // In  Reset FFs and counter
  .lock_never  (ccb_ttcrx_lock_never),    // Out  Lock never achieved
  .lost_ever  (ccb_ttcrx_lost_ever),    // Out  Lock was lost at least once
  .lost_cnt  (ccb_ttcrx_lost_cnt[7:0])  // Out  Number of times lock has been lost
  );

  ccb_lock uccb_lock1 (
  .clock    (clock),          // In  TMB main 40MHz clock
  .lock    (ccb_qpll_locked),      // In  Lock signal from TTC
  .reset    (ccb_cnt_reset),      // In  Reset FFs and counter
  .lock_never  (ccb_qpll_lock_never),    // Out  Lock never achieved
  .lost_ever  (ccb_qpll_lost_ever),    // Out  Lock was lost at least once
  .lost_cnt  (ccb_qpll_lost_cnt[7:0])  // Out  Number of times lock has been lost
  );

//---------------------------------------------------------------------------------------------------------------------
//  CCB Transmitter Section:
//---------------------------------------------------------------------------------------------------------------------
// Map transmitted signal names, invert for GTLP, latch in IOB FFs
  reg  [26:0] ccb_tx_ff = 0;  // synthesis attribute IOB of ccb_tx_ff is "true";

  always @(posedge clock) begin
  ccb_tx_ff[8:0]    <=  ~(clct_status[8:0] & {9{clct_status_en_ff}});  // Output GTL high if this board is not selected
  ccb_tx_ff[17:9]    <=  ~(alct_status[8:0] & {9{alct_status_en_ff}});  // Output GTL high if this board is not selected
  ccb_tx_ff[18]    <=  ~tmb_cfg_done;
  ccb_tx_ff[19]    <=  ~alct_cfg_done;
  ccb_tx_ff[20]    <=  ~tmb_l1a_request;
  ccb_tx_ff[21]    <=  ~(tmb_l1a_release & ~ccb_disable_tx);
  ccb_tx_ff[26:22]  <=  ~tmb_reserved_in[4:0];
  end

  (*KEEP="true"*)
  wire [1:0] ccb_status_noe = ~{ccb_status_oe_lcl,ccb_status_oe_lcl};    //xsynthesis attribute KEEP of ccb_status_noe is "true"
  
  assign _ccb_tx[17:0] = (ccb_status_noe) ? {18{1'bz}} : ccb_tx_ff[17:0];  // ORs !ccb_status_oe_lcl to prevent packing err in ilogic for ise 12
  assign _ccb_tx[26:18]= (gtl_loop_lcl  ) ? { 9{1'bz}} : ccb_tx_ff[26:18];

//---------------------------------------------------------------------------------------------------------------------
//   Simulation state machine display
//---------------------------------------------------------------------------------------------------------------------
`ifdef DEBUG_CCB
// FMM State Machine display
  reg [55:0] fmm_sm_disp;

  always @* begin
  case (fmm_sm)
  fmm_startup:  fmm_sm_disp <= "startup";
  fmm_resync:    fmm_sm_disp <= "resync ";
  fmm_stop:    fmm_sm_disp <= "stop   ";
  fmm_wait_bx0:  fmm_sm_disp <= "waitbx0";
  fmm_run:    fmm_sm_disp <= "run    ";
  default      fmm_sm_disp <= "default";
  endcase
  end

// Internal L1A Generator State Machine display
  reg [55:0] l1a_sm_disp;

  always @* begin
  case (l1a_sm)
  idle:  l1a_sm_disp <= "idle   ";
  count:  l1a_sm_disp <= "count  ";
  default  l1a_sm_disp <= "default";
  endcase
  end
`endif

//------------------------------------------------------------------------------------------------------------------
  endmodule
//------------------------------------------------------------------------------------------------------------------
