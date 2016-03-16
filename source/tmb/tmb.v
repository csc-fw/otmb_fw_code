`timescale 1ns / 1ps
//`define DEBUG_TMB 1
//`define DEBUG_MPC 1
//-------------------------------------------------------------------------------------------------------------------
//  TMB
//    Sends 80MHz data from ALCT and Sequencer to MPC
//    Outputs ALCT+CLCT match results for Sequencer header
//    Receives 80MHz MPC desision result, sends de-muxed to Sequencer
//------------------------------------------------------------------------------------------------------------------
//  03/04/2002   Initial
//  03/05/2002   trigger mods
//  03/06/2002   FFd CLCT inputs, unFF in Sequencer
//  03/07/2002   minor signal name changes
//  03/17/2002   FFd mpc_frame0,1 to improve timing
//  03/22/2002   Fixed alct_vpf_tp, alct_vpf_tp
//  04/24/2002   Shortened ALCT pipe by 1, based on FAST site test with CSC muons
//  04/26/2002   Added allow_match
//  06/03/2002   Added bx0_local, replaces bxn[1] in mpc frames
//  06/13/2002   ALCT flood was keeping tmb_trig busy, so don't allow alct_only triggers here (now done in sequencer)
//  06/17/2002   Another ALCT flood fix, removed alct_vpf_p2 from clct_only
//  07/03/2002   Fixed alct latching, muon duplication, mpc injector, mpc frame order
//  07/08/2002   Added mpc_response_ff and mpc_frame_ff for sequencer, mpc_delay now programmable
//  07/17/2002   Now latch mpc_response on trigger or inject
//  07/24/2002   Added mpc response RAM storage
//  08/01/2002   Added ttc_mpc_inject
//  11/25/2002   Updated clct format and mpc format
//  01/08/2003  Renamed clct0_in to clct0_tmb, removed input FF stage
//  01/29/2003  Pushed sync_err and bx0_local into clct
//  01/29/2003  Rename alct0_in to alct0_tmb
//  01/29/2003  Added startup blanking for mpc output
//  01/31/2003  Replace alct shift registers with srl16e parallel shifter
//  02/04/2003  Replace match logic and trigger latching, fix mpc_response_ff and mpc vme latching
//  02/26/2003  Power up uses 2x clock for mpc_tx asyn set
//  03/02/2003  Added match window location for off-line statistics
//  03/05/2003  Mod bxn in mpc frame for clct_only or alct_only 
//  03/06/2003  Fix tmb_busy if match happens on last_clct, fixed match window count
//  03/07/2003  Fix clct_only and match win
//  04/30/2003  Remove mpc_wait_done, only use mpc_response_ff, add mpc_accept_tp for scope
//  09/11/2003  Remove FFs on mpc_accept and mpc_reserved, moved mpc_accept_tp and mpc_accept_vme to sequencer
//  03/15/2004  Convert 80MHz inputs to ddr
//  03/15/2004  Convert 80MHz outputs to ddr
//  04/20/2004  Revert all DDR to 80MHz
//  06/04/2004  Mod injector to work for 256 tbins, change to x_demux_v2 with aset for mpc_accept
//  06/07/2004  Fix clct pipe -> clct real, so clct data is correct if alct matches in 1st clct window tick
//  06/10/2004  Add programmable mpc_tx delay
//  10/04/2004  Poobah demands ttc_bx0 sent to mpc instead of bx0_local
//  09/12/2006  Mods for xst
//  09/25/2006  More xst mods
//  10/04/2006  Set ffs=0 init value. XST should be doing that, but does not
//  10/10/2006  Replace 80mhz mux and demux with 40mhz ddr
//  10/23/2006  Blanked 2nd muon mpc sync err and bxn if 2nd muon doesnt exist
//  04/09/2007  Add mpc output enable via vme
//  04/27/2007  Remove rx sync stage, shifts rx clock 12.5ns
//  04/30/2007  Revert rx sync stage, because we can't shift mpc rx data by the necessary half cycle for ddr2
//  05/09/2007  Update srl16e_bbl port names
//  05/21/2007  Remove 2bx in mpc path, blank mpc quality if no valid lct
//  07/17/2007  Convert to virtex2 RAMs, add state machine ascii display
//  07/18/2007  Update injector RAM inits
//  08/10/2007  Alter trig_pulse logic to always send pulse on match or when match window closes
//  08/23/2007  Increase mxalct for full bxn
//  08/24/2007  Remove bxn difference calc, same info is already available in header
//  10/19/2007  Restructure clct0/1 add clctc to carry bits common to clct0/1
//  10/22/2007  Add clctb buffer
//  10/24/2007  Add wr_buf_adr to all sequencer replies
//  10/29/2007  Replace clctb with wr_adr_xtmb
//  11/05/2007  Blank sync err in 2nd lct if only 1 lct exists
//  01/17/2008  Replaced lct quality with a plug-in module
//  01/18/2008  Replace first,second with 0,1
//  02/28/2008  Clean up bx0
//  02/29/2008  Mod pipe adr
//  03/03/2008  New alct matching pipeline
//  03/19/2008  Resume pipeline after unwelcome time-wasting interruption
//  04/17/2008  Replace pipeline logic with from tmb_match subdesign
//  04/18/2008  Add indicator to prevent accidental compile with debug_mpc turned on
//  04/23/2008  Blank empty LCTs except for bx0 heartbeat
//  04/29/2008  Add mpc xmit counter signals to sequencer
//  05/09/2008  Move xmpc frame storage to latch after mpc_tx_delay instead of before, makes bx0 delay independent
//  05/12/2008  Move alct bx0 mux to srl input, add vme injector
//  05/19/2008  Replace mpc rx pileline FFs with SRLs, remove mpc response ff
//  06/02/2008  Add active feb list to clct data
//  07/14/2008  Add Non-triggering readout mode
//  07/15/2008  Nontrig bugfix
//  08/12/2008  Add bx0_match
//  08/28/2008  Add me1a clct blocking to mpc
//  09/04/2008  Replace me1a blocking logic to remove combinatorial loop
//  09/05/2008  Move me1a logic to output side of tmb FFs, cant meet timing constraint at FF inputs
//  09/12/2008  Bugfix tmb was blocking LCTs to MPC for CLCTs on CFEB4 in normal CSCs
//  10/22/2008  Conform signal names to sequencer output signals
//  11/15/2008  Allow wr_avail_rtmb without trig_pulse
//  03/02/2009  Add ecc error syndrome to alct data
//  04/24/2009  Add mpc injector state machine recovery state
//  05/04/2009  Add alct1,clct1 real time test points
//  05/14/2009  Add bx0=vpf test mode for bx0 alignment tests
//  07/22/2009  Remove clock_vme global net to make room for cfeb digital phase shifter gbufs
//  08/07/2009  Revert to 10mhz vme clock
//  08/12/2009  Remove clock_vme again
//  09/04/2009  Add bx0 mez test points
//  09/09/2009  Remove bx0 mez test points to save space, yeah it makes a difference
//  09/16/2009  Block lcts to  mpc outputs on sync error
//  02/10/2010  Add event clear for vme diagnostic registers
//  02/12/2010  Blank non-triggering status bits for triggering events
//  02/26/2010  Revert non-trigging blanking temporarily
//  02/28/2010  Fixed non-triggering status bits
//  03/04/2010  Fix clct|alct duplication for case where first clct|alct is dummy
//  04/16/2010  Fix kill logic for me1a
//  06/22/2010  Fix match window logic, was discarding clct_only events when >=2 clcts were in window
//  07/23/2010  Replace ddr sub-modules
//  08/17/2010  Port to ISE 12, replace blocking operators, mod window center arithemetic for 4 bits
//  08/18/2010  Replace vector*scalar with vector & replicated scalar to avoid multiplier inference
//  08/18/2010  Replace multiply x 2 with left shift by 1
//  08/19/2010  Mod clct_tag_sr to init 0 from a dynamic input signal to mollify xst
//  08/25/2010  Replace async ffs
//  10/11/2010  Add virtex 6 RAM option
//  10/15/2010  Virtex 6 RAMs for mpc
//  10/18/2010  Mod RAM collision check
//  09/13/2012  Fix RAM collision check syntax
//  02/14/2013  Virtex-6 only
//  02/21/2013  Expand to 7 CFEB
//-------------------------------------------------------------------------------------------------------------------
  module tmb
  (
// CCB
  clock,
  ttc_resync,

// ALCT
  alct0_tmb,
  alct1_tmb,
  alct_bx0_rx,
  alct_ecc_err,

// TMB-Sequencer Pipelines
  wr_adr_xtmb,
  wr_adr_rtmb,
  wr_adr_xmpc,
  wr_adr_rmpc,

  wr_push_xtmb,
  wr_push_rtmb,
  wr_push_xmpc,
  wr_push_rmpc,

  wr_avail_xtmb,
  wr_avail_rtmb,
  wr_avail_xmpc,
  wr_avail_rmpc,

// Sequencer
  clct0_xtmb,
  clct1_xtmb,
  clctc_xtmb,
  clctf_xtmb,
  bx0_xmpc,

  tmb_trig_pulse,
  tmb_trig_keep,
  tmb_non_trig_keep,
  tmb_match,
  tmb_alct_only,
  tmb_clct_only,
  tmb_match_win,
  tmb_match_pri,
  tmb_alct_discard,
  tmb_clct_discard,
  tmb_clct0_discard,
  tmb_clct1_discard,
  tmb_aff_list,

  tmb_match_ro,
  tmb_alct_only_ro,
  tmb_clct_only_ro,

  tmb_no_alct,
  tmb_no_clct,
  tmb_one_alct,
  tmb_one_clct,
  tmb_two_alct,
  tmb_two_clct,
  tmb_dupe_alct,
  tmb_dupe_clct,
  tmb_rank_err,

  tmb_alct0,
  tmb_alct1,
  tmb_alctb,
  tmb_alcte,

// MPC Status
  mpc_frame_ff,
  mpc0_frame0_ff,
  mpc0_frame1_ff,
  mpc1_frame0_ff,
  mpc1_frame1_ff,

  mpc_xmit_lct0,
  mpc_xmit_lct1,

  mpc_response_ff,
  mpc_accept_ff,
  mpc_reserved_ff,

// MPC IOBs
  _mpc_rx,
  _mpc_tx,

// VME Configuration
  alct_delay,
  clct_window,

  tmb_sync_err_en,
  tmb_allow_alct,
  tmb_allow_clct,
  tmb_allow_match,

  tmb_allow_alct_ro,
  tmb_allow_clct_ro,
  tmb_allow_match_ro,

  csc_id,
  csc_me1ab,
  alct_bx0_delay,
  clct_bx0_delay,
  alct_bx0_enable,
  bx0_vpf_test,
  bx0_match,

  mpc_rx_delay,
  mpc_tx_delay,
  mpc_idle_blank,
  mpc_me1a_block,
  mpc_oe,
  sync_err_blanks_mpc,

// VME Status
  event_clear_vme,
  mpc_frame_vme,
  mpc0_frame0_vme,
  mpc0_frame1_vme,
  mpc1_frame0_vme,
  mpc1_frame1_vme,
  mpc_accept_vme,
  mpc_reserved_vme,

// MPC Injector
  mpc_inject,
  ttc_mpc_inject,
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

// Status
  alct_vpf_tp,
  clct_vpf_tp,
  clct_window_tp,

  alct0_vpf_tprt,
  alct1_vpf_tprt,
  clct_vpf_tprt,
  clct_window_tprt,

// Sump
  tmb_sump

// Debug
`ifdef DEBUG_TMB
  ,alct0_pipe
  ,alct1_pipe
  ,alct0_pipe_vpf

  ,clct0_pipe
  ,clct1_pipe
  ,clctc_pipe
  ,clctf_pipe

  ,alct0_real
  ,alct1_real

  ,clct0_real
  ,clct1_real
  ,clctc_real

  ,winclosing
  ,clct_sr_include
  ,clct_vpf_sr
  ,clct_vpf_sre
  ,clct_window_open
  ,clct_window_haslcts
  ,clct_tag_sr  
  ,clct_last_vpf
  ,clct_last_tag
  ,clct_last_win

  ,alct_pulse
  ,clct_match
  ,alct_noclct
  ,clct_noalct
  ,clct_noalct_lost

  ,clct_win_center
  ,clct_win_best
  ,clct_pri_best

  ,clct_tag_me
  ,clct_tag_win
  ,clct_srl_adr
  ,win_ena

  ,mpc_sm_dsp
  ,mpc_aset
  ,mpc0_inj0
  ,mpc0_inj1
  ,mpc1_inj0
  ,mpc1_inj1
  ,mpc_rdata_01
  ,mpc_rdata_23
  ,bank01
  ,bank23

// Decompose ALCT muons
  ,alct0_valid
  ,alct0_quality
  ,alct0_amu
  ,alct0_key
  ,alct0_bxn

  ,alct1_valid
  ,alct1_quality
  ,alct1_amu
  ,alct1_key
  ,alct1_bxn

// Decompose CLCT muons
  ,clct0_valid
  ,clct0_nhit
  ,clct0_pat
  ,clct0_bend
  ,clct0_key
  ,clct0_cfeb

  ,clct1_valid
  ,clct1_nhit
  ,clct1_pat
  ,clct1_bend
  ,clct1_key
  ,clct1_cfeb

  ,clct_bxn
  ,clct_sync_err

// CLCT is from ME1A
  ,clct0_cfeb456
  ,clct1_cfeb456
  ,kill_clct0
  ,kill_clct1
  ,kill_trig

// Trig keep elements
  ,tmb_trig_keep_ff
  ,tmb_non_trig_keep_ff
  ,clct_keep
  ,alct_keep
  ,clct_keep_ro
  ,alct_keep_ro
  ,clct_discard
  ,alct_discard
  ,match_win
  ,clct_srl_ptr
  ,trig_pulse
  ,trig_keep
  ,non_trig_keep
  ,alct_only
  ,wr_push_mux
  ,clct_match_ro
  ,alct_noclct_ro
  ,clct_noalct_ro
  ,alct_only_trig

// Window priority table
  ,deb_clct_win_priority0,  deb_clct_win_priority1,  deb_clct_win_priority2,  deb_clct_win_priority3
  ,deb_clct_win_priority4,  deb_clct_win_priority5,  deb_clct_win_priority6,  deb_clct_win_priority7
  ,deb_clct_win_priority8,  deb_clct_win_priority9,  deb_clct_win_priority10, deb_clct_win_priority11
  ,deb_clct_win_priority12, deb_clct_win_priority13, deb_clct_win_priority14, deb_clct_win_priority15

// Window priorities enabled
  ,deb_win_pri0,  deb_win_pri1,  deb_win_pri2,  deb_win_pri3
  ,deb_win_pri4,  deb_win_pri5,  deb_win_pri6,  deb_win_pri7
  ,deb_win_pri8,  deb_win_pri9,  deb_win_pri10, deb_win_pri11
  ,deb_win_pri12, deb_win_pri13, deb_win_pri14, deb_win_pri15
`endif

`ifdef DEBUG_MPC
  ,mpc_debug_mode
`endif
  );
//------------------------------------------------------------------------------------------------------------------
// Parameters
//------------------------------------------------------------------------------------------------------------------
// Raw hits RAM parameters
  parameter RAM_DEPTH    = 2048;        // Storage bx depth
  parameter RAM_ADRB    = 11;        // Address width=log2(ram_depth)
  parameter RAM_WIDTH    = 8;        // Data width
  parameter MXBADR    = RAM_ADRB;      // Header buffer data address bits

// Constants
  parameter MXCFEB    =   7;        // Number of CFEBs on CSC
  parameter MXALCT    =  16;        // Number bits per ALCT word
  parameter MXCLCT    =  16;        // Number bits per CLCT word
  parameter MXCLCTC    =  3;        // Number bits per CLCT common data word
  parameter MXMPCRX    =  2;        // Number bits from MPC
  parameter MXMPCTX    =  32;        // Number bits sent to MPC
  parameter MXFRAME    =  16;        // Number bits per muon frame
  parameter MXALCTPIPE  =  6;        // Number clocks to delay ALCT
  parameter MXMPCPIPE    =  16;        // Number clocks to delay mpc response
  parameter MXMPCDLY    =  4;        // MPC delay time bits

//------------------------------------------------------------------------------------------------------------------
//Ports
//------------------------------------------------------------------------------------------------------------------
// CCB
  input          clock;        // 40MHz TMB main clock
  input          ttc_resync;      // Purge CLCT pipeline

// ALCT
  input  [MXALCT-1:0]  alct0_tmb;      // ALCT best muon
  input  [MXALCT-1:0]  alct1_tmb;      // ALCT second best muon
  input          alct_bx0_rx;    // ALCT bx0 received
  input  [1:0]      alct_ecc_err;    // ALCT ecc syndrome code

// TMB-Sequencer Pipelines
  input  [MXBADR-1:0]  wr_adr_xtmb;    // Buffer write address after drift time
  output  [MXBADR-1:0]  wr_adr_rtmb;    // Buffer write address at TMB matching time
  output  [MXBADR-1:0]  wr_adr_xmpc;    // Buffer write address at MPC xmit to sequencer
  output  [MXBADR-1:0]  wr_adr_rmpc;    // Buffer write address at MPC received

  input          wr_push_xtmb;    // Buffer write strobe after drift time
  output          wr_push_rtmb;    // Buffer write strobe at TMB matching time
  output          wr_push_xmpc;    // Buffer write strobe at MPC xmit to sequencer
  output          wr_push_rmpc;    // Buffer write strobe at MPC received

  input          wr_avail_xtmb;    // Buffer available after drift time
  output          wr_avail_rtmb;    // Buffer available at TMB matching time
  output          wr_avail_xmpc;    // Buffer available at MPC xmit to sequencer
  output          wr_avail_rmpc;    // Buffer available at MPC received

// Sequencer
  input  [MXCLCT-1:0]  clct0_xtmb;      // First  CLCT
  input  [MXCLCT-1:0]  clct1_xtmb;      // Second CLCT
  input  [MXCLCTC-1:0]  clctc_xtmb;      // Common to CLCT0/1 to TMB
  input  [MXCFEB-1:0]  clctf_xtmb;      // Active feb list to TMB
  input          bx0_xmpc;      // bx0 to mpc

  output          tmb_trig_pulse;    // ALCT or CLCT or both triggered
  output          tmb_trig_keep;    // ALCT or CLCT or both triggered, and trigger is allowed
  output          tmb_non_trig_keep;  // Event did not trigger, but keep it for readout
  output          tmb_match;      // ALCT and CLCT matched in time
  output          tmb_alct_only;    // Only ALCT triggered
  output          tmb_clct_only;    // Only CLCT triggered
  output  [3:0]      tmb_match_win;    // Location of alct in clct window
  output  [3:0]      tmb_match_pri;    // Priority of clct in clct window
  output          tmb_alct_discard;  // ALCT pair was not used for LCT
  output          tmb_clct_discard;  // CLCT pair was not used for LCT
  output          tmb_clct0_discard;  // CLCT0 was discarded from ME1A
  output          tmb_clct1_discard;  // CLCT1 was discarded from ME1A
  output  [MXCFEB-1:0]  tmb_aff_list;    // Active CFEBs for CLCT used in TMB match

  output          tmb_match_ro;    // ALCT and CLCT matched in time, non-triggering readout
  output          tmb_alct_only_ro;  // Only ALCT triggered, non-triggering readout
  output          tmb_clct_only_ro;  // Only CLCT triggered, non-triggering readout

  output          tmb_no_alct;    // No ALCT
  output          tmb_no_clct;    // No CLCT
  output          tmb_one_alct;    // One ALCT
  output          tmb_one_clct;    // One CLCT
  output          tmb_two_alct;    // Two ALCTs
  output          tmb_two_clct;    // Two CLCTs
  output          tmb_dupe_alct;    // ALCT0 copied into ALCT1 to make 2nd LCT
  output          tmb_dupe_clct;    // CLCT0 copied into CLCT1 to make 2nd LCT
  output          tmb_rank_err;    // LCT1 has higher quality than LCT0

  output  [10:0]      tmb_alct0;      // ALCT best muon latched at trigger
  output  [10:0]      tmb_alct1;      // ALCT second best muon latched at trigger
  output  [4:0]      tmb_alctb;      // ALCT bxn latched at trigger
  output  [1:0]      tmb_alcte;      // ALCT ecc error syndrome latched at trigger

// MPC Status
  output          mpc_frame_ff;    // MPC frame latch
  output  [MXFRAME-1:0]  mpc0_frame0_ff;    // MPC best muon 1st frame
  output  [MXFRAME-1:0]  mpc0_frame1_ff;    // MPC best buon 2nd frame
  output  [MXFRAME-1:0]  mpc1_frame0_ff;    // MPC second best muon 1st frame
  output  [MXFRAME-1:0]  mpc1_frame1_ff;    // MPC second best buon 2nd frame

  output          mpc_xmit_lct0;    // MPC LCT0 sent
  output          mpc_xmit_lct1;    // MPC LCT1 sent

  output          mpc_response_ff;  // MPC accept is ready
  output  [1:0]      mpc_accept_ff;    // MPC muon accept response
  output  [1:0]      mpc_reserved_ff;  // MPC reserved

// MPC IOBs
  input  [MXMPCRX-1:0]  _mpc_rx;      // MPC 80MHz tx data
  output  [MXMPCTX-1:0]  _mpc_tx;      // MPC 80MHz rx data

// VME Configuration
  input  [3:0]      alct_delay;      // Delay ALCT for CLCT match window
  input  [3:0]      clct_window;    // CLCT match window width

  input  [1:0]      tmb_sync_err_en;  // Allow sync_err to MPC for either muon
  input          tmb_allow_alct;    // Allow ALCT only 
  input          tmb_allow_clct;    // Allow CLCT only
  input          tmb_allow_match;  // Allow Match only

  input          tmb_allow_alct_ro;  // Allow ALCT only  readout, non-triggering
  input          tmb_allow_clct_ro;  // Allow CLCT only  readout, non-triggering
  input          tmb_allow_match_ro;  // Allow Match only readout, non-triggering

  input  [3:0]      csc_id;        // CSC station number
  input          csc_me1ab;      // 1=ME1A or ME1B CSC type
  input  [3:0]      alct_bx0_delay;    // ALCT bx0 delay to mpc transmitter
  input  [3:0]      clct_bx0_delay;    // CLCT bx0 delay to mpc transmitter
  input          alct_bx0_enable;  // Enable using alct bx0, else copy clct bx0
  input          bx0_vpf_test;    // Sets clct_bx0=lct0_vpf for bx0 alignment tests
  output          bx0_match;      // ALCT bx0 and CLCT bx0 match in time

  input  [MXMPCDLY-1:0]  mpc_rx_delay;    // Wait for MPC accept
  input  [MXMPCDLY-1:0]  mpc_tx_delay;    // Delay LCT to MPC
  input          mpc_idle_blank;    // Blank mpc output except on trigger, block bx0 too
  input          mpc_me1a_block;    // Block ME1A LCTs to MPC, but still queue for L1A readout
  input          mpc_oe;        // MPC output enable, 1=en
  input          sync_err_blanks_mpc;// Sync error blanks LCTs to MPC

// VME Status
  input          event_clear_vme;  // Event clear for aff,clct,mpc vme diagnostic registers
  output          mpc_frame_vme;    // MPC frame latch
  output  [MXFRAME-1:0]  mpc0_frame0_vme;  // MPC best muon 1st frame
  output  [MXFRAME-1:0]  mpc0_frame1_vme;  // MPC best buon 2nd frame
  output  [MXFRAME-1:0]  mpc1_frame0_vme;  // MPC second best muon 1st frame
  output  [MXFRAME-1:0]  mpc1_frame1_vme;  // MPC second best buon 2nd frame
  output  [1:0]      mpc_accept_vme;    // MPC accept latched for VME
  output  [1:0]      mpc_reserved_vme;  // MPC reserved latched for VME

// MPC Injector
  input          mpc_inject;      // Start MPC test pattern injector, VME
  input          ttc_mpc_inject;    // Start MPC injector, TTC command
  input          ttc_mpc_inj_en;    // Enable TTC inject command
  input  [7:0]      mpc_nframes;    // Number frames to inject
  input  [3:0]      mpc_wen;      // Select RAM to write
  input  [3:0]      mpc_ren;      // Select RAM to read 
  input  [7:0]      mpc_adr;      // Injector RAM read/write address
  input  [15:0]      mpc_wdata;      // Injector RAM write data
  output  [15:0]      mpc_rdata;      // Injector RAM read  data
  output  [3:0]      mpc_accept_rdata;  // MPC response stored in RAM
  input          mpc_inj_alct_bx0;  // ALCT bx0 injector
  input          mpc_inj_clct_bx0;  // CLCT bx0 injector

// Status
  output          alct_vpf_tp;    // Timing test point, FF buffered for IOBs
  output          clct_vpf_tp;    // Timing test point
  output          clct_window_tp;    // Timing test point
  
  output          alct0_vpf_tprt;    // Timing test point, unbuffered real time for internal scope
  output          alct1_vpf_tprt;    // Timing test point
  output          clct_vpf_tprt;    // Timing test point
  output          clct_window_tprt;  // Timing test point

// Sump
  output          tmb_sump;      // Unused signals

//------------------------------------------------------------------------------------------------------------------
// Debug Ports
//------------------------------------------------------------------------------------------------------------------
`ifdef DEBUG_TMB
  output  [MXALCT-1:0]  alct0_pipe;
  output  [MXALCT-1:0]  alct1_pipe;
  output           alct0_pipe_vpf;

  output  [MXCLCT-1:0]  clct0_pipe;
  output  [MXCLCT-1:0]  clct1_pipe;
  output  [MXCLCTC-1:0]  clctc_pipe;
  output  [MXCFEB-1:0]  clctf_pipe;

  output  [MXALCT-1:0]  alct0_real;
  output  [MXALCT-1:0]  alct1_real;

  output  [MXCLCT-1:0]  clct0_real;
  output  [MXCLCT-1:0]  clct1_real;
  output  [MXCLCTC-1:0]  clctc_real;

  output  [3:0]      winclosing;
  output  [15:0]      clct_sr_include;
  output  [15:0]      clct_vpf_sr;
  output  [15:1]      clct_vpf_sre;

  output           clct_window_open;
  output           clct_window_haslcts;

  output  [15:0]      clct_tag_sr;  
  output           clct_last_vpf;
  output           clct_last_tag;
  output           clct_last_win;

  output          alct_pulse;
  output          clct_match;
  output          alct_noclct;
  output          clct_noalct;
  output          clct_noalct_lost;

  output  [3:0]      clct_win_center;
  output  [3:0]      clct_win_best;
  output  [3:0]      clct_pri_best;

  output          clct_tag_me;
  output  [3:0]      clct_tag_win;
  output  [3:0]      clct_srl_adr;
  output  [15:0]      win_ena;

  output  [71:0]      mpc_sm_dsp;      // Injector state machine ascii states
  output          mpc_set;      // mpc_tx  sync set at power up  
  output  [MXFRAME-1:0]  mpc0_inj0;      // injected 1st muon 1st frame
  output  [MXFRAME-1:0]  mpc0_inj1;      // injected 1st muon 2nd frame
  output  [MXFRAME-1:0]  mpc1_inj0;      // injected 2nd muon 1st frame
  output  [MXFRAME-1:0]  mpc1_inj1;      // injected 2nd muon 2nd frame
  output  [15:0]      mpc_rdata_01;
  output  [15:0]      mpc_rdata_23;
  output          bank01;
  output          bank23;

// Decompose ALCT muons
  output          alct0_valid;    // Valid pattern flag
  output  [1:0]      alct0_quality;    // Pattern quality
  output          alct0_amu;      // Accelerator muon
  output  [6:0]      alct0_key;      // Key Wire Group
  output  [4:0]      alct0_bxn;      // Bunch crossing number, reduced width for mpc

  output          alct1_valid;    // Valid pattern flag
  output  [1:0]      alct1_quality;    // Pattern quality
  output          alct1_amu;      // Accelerator muon
  output  [6:0]      alct1_key;      // Key Wire Group
  output  [4:0]      alct1_bxn;      // Bunch crossing number, reduced width for mpc

// Decompose CLCT muons
  output          clct0_valid;    // Valid pattern flag
  output  [2:0]      clct0_nhit;      // Hits on pattern
  output  [3:0]      clct0_pat;      // Pattern shape
  output          clct0_bend;      // Bend direction
  output  [4:0]      clct0_key;      // Key 1/2-Strip
  output  [2:0]      clct0_cfeb;      // Key CFEB ID

  output          clct1_valid;    // Valid pattern flag
  output  [2:0]      clct1_nhit;      // Hits on pattern
  output  [3:0]      clct1_pat;      // Pattern shape
  output          clct1_bend;      // Bend direction
  output  [4:0]      clct1_key;      // Key 1/2-Strip
  output  [2:0]      clct1_cfeb;      // Key CFEB ID

  output  [1:0]      clct_bxn;      // Bunch crossing number
  output          clct_sync_err;    // Bx0 disagreed with bxn counter

// CLCT is from ME1A
  output          clct0_cfeb456;    // CLCT0 is on CFEB4,5,6 hence ME1A
  output          clct1_cfeb456;    // CLCT1 is on CFEB4,5,6 hence ME1A
  output          kill_clct0;      // Delete CLCT0 from ME1A
  output          kill_clct1;      // Delete CLCT1 from ME1A
  output          kill_trig;      // Kill clct-trig, both CLCTs are ME1As, and there is no alct in alct-only mode

// Trig keep elements
  output          tmb_trig_keep_ff;
  output          tmb_non_trig_keep_ff;
  output          clct_keep;
  output          alct_keep;
  output          clct_keep_ro;
  output          alct_keep_ro;
  output          clct_discard;
  output          alct_discard;
  output  [3:0]      match_win;
  output  [3:0]       clct_srl_ptr;
  output          trig_pulse;
  output          trig_keep;
  output          non_trig_keep;
  output          alct_only;
  output          wr_push_mux;
  output          clct_match_ro;
  output          alct_noclct_ro;
  output          clct_noalct_ro;
  output          alct_only_trig;

// Window priority table
  output  [3:0]      deb_clct_win_priority0,  deb_clct_win_priority1,  deb_clct_win_priority2,  deb_clct_win_priority3;
  output  [3:0]      deb_clct_win_priority4,  deb_clct_win_priority5,  deb_clct_win_priority6,  deb_clct_win_priority7;
  output  [3:0]      deb_clct_win_priority8,  deb_clct_win_priority9,  deb_clct_win_priority10, deb_clct_win_priority11;
  output  [3:0]      deb_clct_win_priority12, deb_clct_win_priority13, deb_clct_win_priority14, deb_clct_win_priority15;

// Window priorities enabled
  output  [3:0]      deb_win_pri0,  deb_win_pri1,  deb_win_pri2,  deb_win_pri3;
  output  [3:0]      deb_win_pri4,  deb_win_pri5,  deb_win_pri6,  deb_win_pri7;
  output  [3:0]      deb_win_pri8,  deb_win_pri9,  deb_win_pri10, deb_win_pri11;
  output  [3:0]      deb_win_pri12, deb_win_pri13, deb_win_pri14, deb_win_pri15;
`endif

`ifdef DEBUG_MPC
  output          mpc_debug_mode;    // Prevents accidental compile with debug_mpc turned on
`endif
//------------------------------------------------------------------------------------------------------------------
// Local
//------------------------------------------------------------------------------------------------------------------
// Pipeline registers
  reg [MXBADR-1:0] wr_adr_rtmb = 0;  // Buffer write address at TMB matching time
  reg [MXBADR-1:0] wr_adr_xmpc = 0;  // Buffer write address at MPC xmit to sequencer
  reg [MXBADR-1:0] wr_adr_rmpc = 0;  // Buffer write address at MPC received

  reg wr_push_rtmb = 0;        // Buffer write strobe at TMB matching time
  reg wr_push_xmpc = 0;        // Buffer write strobe at MPC xmit to sequencer
  reg wr_push_rmpc = 0;        // Buffer write strobe at MPC received

  reg wr_avail_rtmb = 0;        // Buffer available at TMB matching time
  reg wr_avail_xmpc = 0;        // Buffer available at MPC xmit to sequencer
  reg wr_avail_rmpc = 0;        // Buffer available at MPC received

// MPC Frames
  wire [MXFRAME-1:0]  mpc0_inj0;
  wire [MXFRAME-1:0]  mpc0_inj1;
  wire [MXFRAME-1:0]  mpc1_inj0;
  wire [MXFRAME-1:0]  mpc1_inj1;

  wire [MXFRAME-1:0]  mpc0_frame0;
  wire [MXFRAME-1:0]  mpc0_frame1;
  wire [MXFRAME-1:0]  mpc1_frame0;
  wire [MXFRAME-1:0]  mpc1_frame1;

  reg   [MXFRAME-1:0]  mpc0_frame0_ff  = 0;
  reg   [MXFRAME-1:0]  mpc0_frame1_ff  = 0;
  reg   [MXFRAME-1:0]  mpc1_frame0_ff  = 0;
  reg   [MXFRAME-1:0]  mpc1_frame1_ff  = 0;

  reg   [MXFRAME-1:0]  mpc0_frame0_vme = 0;
  reg   [MXFRAME-1:0]  mpc0_frame1_vme = 0;
  reg   [MXFRAME-1:0]  mpc1_frame0_vme = 0;
  reg   [MXFRAME-1:0]  mpc1_frame1_vme = 0;

  reg   [7:0]      mpc_frame_cnt  = 0;
  wire        mpc_frame_done;
  wire [7:0]      mpc_inj_adr;
  wire [7:0]      vme_adr;

//------------------------------------------------------------------------------------------------------------------
// Startup timer to force mpc output high at power up
//------------------------------------------------------------------------------------------------------------------
  wire [3:0]  pdly = 1;      // Power-up reset delay
  wire powerup_q;
  reg   powerup_ff  = 0;

  SRL16E upowerup (.CLK(clock),.CE(~powerup_q),.D(1'b1),.A0(pdly[0]),.A1(pdly[1]),.A2(pdly[2]),.A3(pdly[3]),.Q(powerup_q));

  always @(posedge clock) begin
  powerup_ff <= powerup_q;
  end

  wire powerup_n = ~powerup_ff;  // shifts timing from LUT to FF
  wire reset_sr  = ttc_resync | powerup_n;

// MPC power-up blanking
  reg  mpc_set = 1;

  always @(posedge clock) begin
  mpc_set <= (!powerup_ff || !mpc_oe || sync_err_blanks_mpc);
  end

//------------------------------------------------------------------------------------------------------------------
// Push ALCT data into a 1bx to 16bx pipeline delay to compensate for CLCT processing time
//------------------------------------------------------------------------------------------------------------------
  wire [MXALCT-1:0] alct0_pipe, alct0_srl;
  wire [MXALCT-1:0] alct1_pipe, alct1_srl;
  wire [1:0]        alcte_pipe, alcte_srl, alcte_tmb;
  reg  [3:0] alct_srl_adr = 0;

  always @(posedge clock) begin
  alct_srl_adr <= alct_delay-1'b1;
  end

  assign alcte_tmb[1:0] = alct_ecc_err[1:0];

  srl16e_bbl #(MXALCT) ualct0 (.clock(clock),.ce(1'b1),.adr(alct_srl_adr),.d(alct0_tmb),.q(alct0_srl));
  srl16e_bbl #(MXALCT) ualct1 (.clock(clock),.ce(1'b1),.adr(alct_srl_adr),.d(alct1_tmb),.q(alct1_srl));
  srl16e_bbl #(2)      ualcte (.clock(clock),.ce(1'b1),.adr(alct_srl_adr),.d(alcte_tmb),.q(alcte_srl));

  wire alct_ptr_is_0 = (alct_delay == 0);               // Use direct input if SRL address is 0, 1st SRL output has 1bx overhead

  assign alct0_pipe = (alct_ptr_is_0) ? alct0_tmb : alct0_srl;  // First  CLCT after clct pipe delay
  assign alct1_pipe = (alct_ptr_is_0) ? alct1_tmb : alct1_srl;  // Second CLCT after clct pipe delay
  assign alcte_pipe = (alct_ptr_is_0) ? alcte_tmb : alcte_srl;  // Second CLCT after clct pipe delay 

  wire   alct0_pipe_vpf = alct0_pipe[0];
  wire   alct1_pipe_vpf = alct1_pipe[0];

//------------------------------------------------------------------------------------------------------------------
// Push CLCT data into a 1bx to 16bx pipeline delay to wait for an alct match
//------------------------------------------------------------------------------------------------------------------
  wire [MXCLCT-1:0]  clct0_pipe, clct0_srl; // First  CLCT
  wire [MXCLCT-1:0]  clct1_pipe, clct1_srl; // Second CLCT
  wire [MXCLCTC-1:0] clctc_pipe, clctc_srl; // Common to CLCT0/1 to TMB
  wire [MXCFEB-1:0]  clctf_pipe, clctf_srl; // Active cfeb list to TMB
  wire [MXBADR-1:0]  wr_adr_xtmb_pipe, wr_adr_xtmb_srl; // Buffer write address after clct pipeline delay
  wire [3:0]         clct_srl_ptr;

  wire [3:0] clct_srl_adr = clct_srl_ptr-1;        // Pointer to clct SRL data accounts for SLR 1bx latency

  srl16e_bbl #(MXCLCT ) uclct0 (.clock(clock),.ce(1'b1),.adr(clct_srl_adr),.d(clct0_xtmb),.q(clct0_srl));
  srl16e_bbl #(MXCLCT ) uclct1 (.clock(clock),.ce(1'b1),.adr(clct_srl_adr),.d(clct1_xtmb),.q(clct1_srl));
  srl16e_bbl #(MXCLCTC) uclctc (.clock(clock),.ce(1'b1),.adr(clct_srl_adr),.d(clctc_xtmb),.q(clctc_srl));
  srl16e_bbl #(MXCFEB ) uclctf (.clock(clock),.ce(1'b1),.adr(clct_srl_adr),.d(clctf_xtmb),.q(clctf_srl));

  srl16e_bbl #(MXBADR) utwadr   (.clock(clock),.ce(1'b1),.adr(clct_srl_adr),.d(wr_adr_xtmb  ),.q(wr_adr_xtmb_srl  ));
  srl16e_bbl #(1)      utwpush  (.clock(clock),.ce(1'b1),.adr(clct_srl_adr),.d(wr_push_xtmb ),.q(wr_push_xtmb_srl ));
  srl16e_bbl #(1)      utwavail (.clock(clock),.ce(1'b1),.adr(clct_srl_adr),.d(wr_avail_xtmb),.q(wr_avail_xtmb_srl));

  wire clct_ptr_is_0 = (clct_srl_ptr == 0);             // Use direct input if SRL address is 0, 1st SRL output has 1bx overhead

  assign clct0_pipe = (clct_ptr_is_0) ? clct0_xtmb : clct0_srl;  // First  CLCT after clct pipe delay
  assign clct1_pipe = (clct_ptr_is_0) ? clct1_xtmb : clct1_srl;  // Second CLCT after clct pipe delay
  assign clctc_pipe = (clct_ptr_is_0) ? clctc_xtmb : clctc_srl;  // Common to CLCT0/1 after clct pipe delay
  assign clctf_pipe = (clct_ptr_is_0) ? clctf_xtmb : clctf_srl;  // Active cfeb list  after clct pipe delay

  assign wr_adr_xtmb_pipe   = (clct_ptr_is_0) ? wr_adr_xtmb   : wr_adr_xtmb_srl;  // Buffer write address after clct pipeline delay
  wire   wr_push_xtmb_pipe  = (clct_ptr_is_0) ? wr_push_xtmb  : wr_push_xtmb_srl;
  wire   wr_avail_xtmb_pipe = (clct_ptr_is_0) ? wr_avail_xtmb : wr_avail_xtmb_srl;

//------------------------------------------------------------------------------------------------------------------
// Pre-calculate dynamic clct window parameters
//------------------------------------------------------------------------------------------------------------------
// FF buffer clct_window index for fanout, points to 1st position window is closed 
  reg [3:0] winclosing=0;

  always @(posedge clock) begin
  winclosing <= clct_window-1'b1;
  end

  wire dynamic_zero = bx0_vpf_test;      // Dynamic zero to mollify xst for certain FF inits

// Decode CLCT window width setting to select which clct_sr stages to include in clct_window
  reg [15:0] clct_sr_include=0;
  integer i;

  always @(posedge clock) begin
  if (powerup_n) begin            // Sych reset on resync or not power up
  clct_sr_include  <= {16{dynamic_zero}};    // Power up bit 15 to mollify xst compiler warning about [15] constant 0
  end

  else begin
  i=0;
  while (i<=15) begin
  if (clct_window!=0)
  clct_sr_include[i] <= (i<=clct_window-1);  // clct_window=3, enables sr stages 0,1,2
  else
  clct_sr_include[i] <= 0;          // clct_window=0, disables all sr stages
  i=i+1;
  end
  end
  end

// Calculate dynamic clct window center and positional priorities
  reg  [3:0] clct_win_priority [15:0];
  wire [3:0] clct_win_center = clct_window/2;  // Gives priority to higher winbx for even widths

  always @(posedge clock) begin
  i=0;
  while (i<=15) begin
  if    (ttc_resync            ) clct_win_priority[i] <= 4'hF;
  else if (i>=clct_window || i==0) clct_win_priority[i] <= 0;                          // i >  lastwin or i=0
  else if (i<=clct_win_center    ) clct_win_priority[i] <= clct_window-4'd1-((clct_win_center-i[3:0]) << 1);  // i <= center
  else                             clct_win_priority[i] <= clct_window-4'd0-((i[3:0]-clct_win_center) << 1);  // i >  center
  i=i+1;
  end
  end

//------------------------------------------------------------------------------------------------------------------
// ALCT*CLCT Matching Section
//------------------------------------------------------------------------------------------------------------------
// Push CLCT vpf into a 16-stage FF shift register for ALCT matching
  reg  [15:1] clct_vpf_sre=0;        // CLCT valid pattern flag 
  wire [15:0] clct_vpf_sr;        // Extend CLCT vpf shift register 1bx earlier in time to minimize latency

  assign clct_vpf_sr[0]    = wr_push_xtmb;// Extend CLCT vpf shift register 1bx earlier in time
  assign clct_vpf_sr[15:1] = clct_vpf_sre[15:1];

  always @(posedge clock) begin      // Load stage 0 with incoming CLCT
  clct_vpf_sre[1]    <= clct_vpf_sr[0];  // Vpf=1 for pattern triggers, may be =0 for external triggers, so use push flag
  i=1;                  // Loop over window positions 1 to 14, 15th is shifted into and 0th is non-ff
  while (i<=14) begin            // Parallel shift all data left
  clct_vpf_sre[i+1]  <= clct_vpf_sre[i];
  i=i+1;
  end  // close while
  end  // close clock

// CLCT allocation tag shift register
  reg [15:0]  clct_tag_sr=0;        // CLCT allocated tag
  wire    clct_tag_me;        // Tag pulse
  wire [3:0]  clct_tag_win;        // SR stage to insert tag

  always @(posedge clock) begin
  if (reset_sr) begin            // Sych reset on resync or not power up
  clct_tag_sr  <= dynamic_zero;      // Load a dynamic 0 on reset, mollify xst
  end

  i=0;                  // Loop over 15 window positions 0 to 14 
  while (i<=14) begin
  if (clct_tag_me==1 && clct_tag_win==i && clct_sr_include[i]) clct_tag_sr[i+1] <= 1;
  else                  // Otherwise parallel shift all data left
  clct_tag_sr[i+1] <= clct_tag_sr[i];
  i=i+1;
  end  // close while
  end  // close clock

// Find highest priority window position that has a non-tagged clct
  wire [15:0] win_ena;          // Table of enabled window positions
  wire [3:0]  win_pri [15:0];        // Table of window position priorities that are enabled

  genvar j;                // Table window priorities multipled by windwo position enables
  generate
  for (j=0; j<=15; j=j+1) begin: genpri
  assign win_ena[j] = (clct_sr_include[j]==1 && clct_vpf_sr[j]==1 && clct_tag_sr[j]==0);
  assign win_pri[j] = (clct_win_priority[j] * win_ena[j]);
  end
  endgenerate

  wire [0:0] win_s0  [7:0];        // Tree encoder Finds best 4 of 16 window positions
  wire [1:0] win_s1  [3:0];

  wire [3:0] pri_s0  [7:0];
  wire [3:0] pri_s1  [3:0];

  assign {pri_s0[7],win_s0[7]} = (win_pri[15] > win_pri[14]) ? {win_pri[15],1'b1} : {win_pri[14],1'b0};
  assign {pri_s0[6],win_s0[6]} = (win_pri[13] > win_pri[12]) ? {win_pri[13],1'b1} : {win_pri[12],1'b0};
  assign {pri_s0[5],win_s0[5]} = (win_pri[11] > win_pri[10]) ? {win_pri[11],1'b1} : {win_pri[10],1'b0};
  assign {pri_s0[4],win_s0[4]} = (win_pri[ 9] > win_pri[ 8]) ? {win_pri[ 9],1'b1} : {win_pri[ 8],1'b0};
  assign {pri_s0[3],win_s0[3]} = (win_pri[ 7] > win_pri[ 6]) ? {win_pri[ 7],1'b1} : {win_pri[ 6],1'b0};
  assign {pri_s0[2],win_s0[2]} = (win_pri[ 5] > win_pri[ 4]) ? {win_pri[ 5],1'b1} : {win_pri[ 4],1'b0};
  assign {pri_s0[1],win_s0[1]} = (win_pri[ 3] > win_pri[ 2]) ? {win_pri[ 3],1'b1} : {win_pri[ 2],1'b0};
  assign {pri_s0[0],win_s0[0]} = (win_pri[ 1] > win_pri[ 0]) ? {win_pri[ 1],1'b1} : {win_pri[ 0],1'b0};

  assign {pri_s1[3],win_s1[3]} = (pri_s0[7] > pri_s0[6]) ? {pri_s0[7],{1'b1,win_s0[7]}} : {pri_s0[6],{1'b0,win_s0[6]}};
  assign {pri_s1[2],win_s1[2]} = (pri_s0[5] > pri_s0[4]) ? {pri_s0[5],{1'b1,win_s0[5]}} : {pri_s0[4],{1'b0,win_s0[4]}};
  assign {pri_s1[1],win_s1[1]} = (pri_s0[3] > pri_s0[2]) ? {pri_s0[3],{1'b1,win_s0[3]}} : {pri_s0[2],{1'b0,win_s0[2]}};
  assign {pri_s1[0],win_s1[0]} = (pri_s0[1] > pri_s0[0]) ? {pri_s0[1],{1'b1,win_s0[1]}} : {pri_s0[0],{1'b0,win_s0[0]}};

  reg  [3:0] win_s2 [0:0];          // Parallel encoder finds best 1-of-4 window positions
  reg  [3:0] pri_s2 [0:0];

  always @(pri_s1[0] or win_s1[0]) begin
  if      ((pri_s1[3] > pri_s1[2]) &&
      (pri_s1[3] > pri_s1[1]) &&
      (pri_s1[3] > pri_s1[0]))
      begin
      pri_s2[0]  = pri_s1[3];
      win_s2[0]  = {2'd3,win_s1[3]};
      end

  else if((pri_s1[2] > pri_s1[1]) &&
      (pri_s1[2] > pri_s1[0]))
      begin
      pri_s2[0]  = pri_s1[2];
      win_s2[0]  = {2'd2,win_s1[2]};
      end

  else if(pri_s1[1] > pri_s1[0])
      begin
      pri_s2[0]  = pri_s1[1];
      win_s2[0]  = {2'd1,win_s1[1]};
      end
  else
      begin
      pri_s2[0]  = pri_s1[0];
      win_s2[0]  = {2'd0,win_s1[0]};
      end
  end

  wire [3:0] clct_win_best = win_s2[0];
  wire [3:0] clct_pri_best = pri_s2[0];

// CLCT window width is generated by a pulse propagating down the enabled clct_sr stages  
  wire clct_window_open    = |(clct_vpf_sr & clct_sr_include);
  wire clct_window_haslcts = |(clct_vpf_sr & clct_sr_include & ~clct_tag_sr);

// CLCT window closes on next bx, check for un-tagged clct in last bx
  wire   clct_last_vpf = clct_vpf_sr[winclosing];        // CLCT token reaches last window position 1bx before tag
  wire   clct_last_tag = clct_tag_sr[winclosing];        // Push this event into MPC queue as it reaches last window bx

// CLCT matched or alct-only
  wire alct_pulse  = alct0_pipe_vpf;              // ALCT vpf
  wire alct_noclct = alct_pulse   && !clct_window_haslcts;  // ALCT arrived, but there was no CLCT window open
  wire clct_match  = alct_pulse   &&  clct_window_haslcts;  // ALCT matches CLCT window, push to mpc on current bx

  wire clct_last_win    = clct_last_vpf && !clct_last_tag;  // CLCT reached end of window
  wire clct_noalct      = clct_last_win && !alct_pulse;    // No ALCT arrived in window, pushed mpc on last bx
  wire clct_noalct_lost = clct_last_win &&  alct_pulse && clct_win_best!=winclosing;// No ALCT arrived in window, lost to mpc contention

// ALCT*CLCT match: alct arrived while there were 1 or more un-tagged clcts in the window
  assign clct_tag_me  = clct_match;    // Tag the matching clct
  assign clct_tag_win = clct_win_best;   // But get the one with highest priority

// Event trigger disposition
  reg  [MXCFEB-1:0] tmb_aff_list  = 0;
  reg  [3:0]        tmb_match_win = 0;
  reg  [3:0]        tmb_match_pri = 0;
  wire              alct_only_trig;

  wire clct_keep    =((clct_match && tmb_allow_match   ) || (clct_noalct &&  tmb_allow_clct    && !clct_noalct_lost));
  wire alct_keep    = (clct_match && tmb_allow_match   ) || (alct_noclct &&  tmb_allow_alct);

  wire clct_keep_ro  = (clct_match && tmb_allow_match_ro) || (clct_noalct &&  tmb_allow_clct_ro && !clct_noalct_lost);
  wire alct_keep_ro  = (clct_match && tmb_allow_match_ro) || (alct_noclct &&  tmb_allow_alct_ro);

  wire clct_discard  = (clct_match && !tmb_allow_match  ) || (clct_noalct && !tmb_allow_clct) || clct_noalct_lost;
  wire alct_discard  =  alct_pulse && !alct_keep;

// Match window mux
  wire [3:0] match_win;
  wire [3:0] match_win_mux;

  wire clct_kept = (clct_keep || clct_keep_ro);

  assign match_win_mux = (clct_noalct) ? winclosing    : clct_tag_win;          // if clct only, disregard priority and take last window position                          // Pointer to SRL delayed CLCT signals
  assign match_win     = (clct_kept  ) ? match_win_mux : clct_win_center;          // Default window position for alct-only events

//!  assign match_win   = (clct_keep || clct_keep_ro) ? clct_tag_win : clct_win_center;  // Default window position for alct-only events
  assign clct_srl_ptr   = match_win;

//  wire trig_pulse    = clct_match || clct_noalct || clct_noalct_lost || alct_noclct;    // Event pulse
  wire trig_pulse    = clct_match || clct_noalct || clct_noalct_lost || alct_only_trig;  // Event pulse
  
  wire trig_keep    = (clct_keep    || alct_keep);                    // Keep event for trigger and readout
  wire non_trig_keep  = (clct_keep_ro || alct_keep_ro);                  // Keep non-triggering event for readout only

  wire alct_only    = (alct_noclct && tmb_allow_alct) && !clct_keep;          // An alct-only trigger
  wire wr_push_mux  = (alct_only) ? trig_pulse : (wr_push_xtmb_pipe  && trig_pulse);  // Buffer write strobe at TMB matching time

  wire clct_match_tr  = clct_match  && trig_keep;    // ALCT and CLCT matched in time, nontriggering event
  wire alct_noclct_tr  = alct_noclct && trig_keep;    // Only ALCT triggered, nontriggering event
  wire clct_noalct_tr  = clct_noalct && trig_keep;    // Only CLCT triggered, nontriggering event

  wire clct_match_ro  = clct_match  && non_trig_keep;  // ALCT and CLCT matched in time, nontriggering event
  wire alct_noclct_ro  = alct_noclct && non_trig_keep;  // Only ALCT triggered, nontriggering event
  wire clct_noalct_ro  = clct_noalct && non_trig_keep;  // Only CLCT triggered, nontriggering event

  assign alct_only_trig = (alct_noclct && tmb_allow_alct) || (alct_noclct_ro && tmb_allow_alct_ro);// ALCT-only triggers are allowed

// Latch clct match results for TMB and MPC pathways
  reg  tmb_trig_pulse       = 0;
  reg  tmb_trig_keep_ff     = 0;
  reg tmb_non_trig_keep_ff = 0;

  reg  tmb_match         = 0;
  reg  tmb_alct_only       = 0;
  reg  tmb_clct_only       = 0;

  reg  tmb_match_ro_ff       = 0;
  reg  tmb_alct_only_ro_ff  = 0;
  reg  tmb_clct_only_ro_ff  = 0;

  reg tmb_alct_discard     = 0;
  reg tmb_clct_discard     = 0;

  reg [10:0]  tmb_alct0    = 0;                // ALCT best muon latched at trigger
  reg [10:0]  tmb_alct1    = 0;                // ALCT second best muon latched at trigger
  reg [ 4:0]  tmb_alctb    = 0;                // ALCT bxn latched at trigger
  reg  [ 1:0]  tmb_alcte    = 0;                // ALCT ecc latched at trigger

  always @(posedge clock) begin
    tmb_trig_pulse       <= trig_pulse;    // ALCT or CLCT or both triggered
    tmb_trig_keep_ff     <= trig_keep;     // ALCT or CLCT or both triggered, and trigger is allowed
    tmb_non_trig_keep_ff <= non_trig_keep; // Event did not trigger but is kept for readout

    tmb_match            <= clct_match_tr  && tmb_allow_match; // ALCT and CLCT matched in time
    tmb_alct_only        <= alct_noclct_tr && tmb_allow_alct;  // Only ALCT triggered
    tmb_clct_only        <= clct_noalct_tr && tmb_allow_clct;  // Only CLCT triggered

    tmb_match_ro_ff      <= clct_match_ro  && tmb_allow_match_ro; // ALCT and CLCT matched in time, nontriggering event
    tmb_alct_only_ro_ff  <= alct_noclct_ro && tmb_allow_alct_ro;  // Only ALCT triggered, nontriggering event
    tmb_clct_only_ro_ff  <= clct_noalct_ro && tmb_allow_clct_ro;  // Only CLCT triggered, nontriggering event

    tmb_match_win        <= match_win;     // Location of alct in clct window
    tmb_match_pri        <= clct_pri_best; // Priority of clct that matched
    tmb_aff_list         <= clctf_pipe;    // Active feb pipe

    tmb_alct_discard     <= alct_discard;  // ALCT was not used for LCT
    tmb_clct_discard     <= clct_discard;  // CLCT was not used for LCT

    tmb_alct0            <= alct0_pipe[10:0]; // Copy of ALCT for header
    tmb_alct1            <= alct1_pipe[10:0];
    tmb_alctb            <= alct0_pipe[15:11];
    tmb_alcte            <= alcte_pipe[1:0];

    wr_adr_rtmb          <= wr_adr_xtmb_pipe;   // Buffer write address at TMB matching time, continuous
    wr_push_rtmb         <= wr_push_mux;        // Buffer write strobe at TMB matching time
    wr_avail_rtmb        <= wr_avail_xtmb_pipe; // Buffer available at TMB matching time
  end

// Had to wait for kill signal to go valid
  wire kill_trig;

  assign tmb_match_ro     = tmb_match_ro_ff     & kill_trig;  // ALCT and CLCT matched in time, nontriggering event
  assign tmb_alct_only_ro = tmb_alct_only_ro_ff & kill_trig;  // Only ALCT triggered, nontriggering event
  assign tmb_clct_only_ro = tmb_clct_only_ro_ff & kill_trig;  // Only CLCT triggered, nontriggering event

// Post FF mod trig_keep for me1a
  assign tmb_trig_keep     = tmb_trig_keep_ff     && (!kill_trig || tmb_alct_only);
  assign tmb_non_trig_keep = tmb_non_trig_keep_ff && !tmb_trig_keep;
  
// Pipelined CLCTs, aligned in time with trig_pulse
  reg [MXCLCT-1:0]  clct0_real;
  reg [MXCLCT-1:0]  clct1_real;
  reg [MXCLCTC-1:0]  clctc_real;

  wire keep_clct = trig_pulse && (trig_keep || non_trig_keep);

  always @(posedge clock) begin
  clct0_real <= clct0_pipe & {MXCLCT  {keep_clct}};
  clct1_real <= clct1_pipe & {MXCLCT  {keep_clct}};
  clctc_real <= clctc_pipe & {MXCLCTC {keep_clct}};
  end

// Latch pipelined ALCTs, aligned in time with CLCTs because CLCTs are delayed 1bx in the SRLs
  reg [MXALCT-1:0] alct0_real = 0;
  reg [MXALCT-1:0] alct1_real = 0;

  always @(posedge clock) begin
  alct0_real <= alct0_pipe;
  alct1_real <= alct1_pipe;
  end

// Output vpf test point signals for timing-in, removed FFs so internal scope will be in real-time
  reg  alct_vpf_tp    = 0;
  reg  clct_vpf_tp    = 0;
  reg clct_window_tp = 0;

  assign alct0_vpf_tprt  = alct0_pipe_vpf;  // Real time for internal scope
  assign alct1_vpf_tprt  = alct1_pipe_vpf;
  assign clct_vpf_tprt  = clct_vpf_sr[0];
  assign clct_window_tprt  = clct_window_open;
  
  always @(posedge clock) begin        // FF-buffered for fpga IOBs
  alct_vpf_tp    <= alct0_pipe_vpf;
  clct_vpf_tp    <= clct_vpf_sr[0];
  clct_window_tp  <= clct_window_open;
  end

// CLCTs from ME1A
  reg kill_me1a_clcts=0;

  always @(posedge clock) begin
  if (ttc_resync)  kill_me1a_clcts  <= 1;              // Foil xst warning for typeA and typeB compiles 
  else      kill_me1a_clcts <= mpc_me1a_block && csc_me1ab;  // Kill CLCTs from ME1A if blocking is on
  end

  wire clct0_exists  = clct0_real[0];          // CLCT0 vpf
  wire clct1_exists  = clct1_real[0];          // CLCT1 vpf

  wire clct0_cfeb456  = clct0_real[15];          // CLCT0 is on CFEB4-6 hence ME1A
  wire clct1_cfeb456  = clct1_real[15];          // CLCT1 is on CFEB4-6 hence ME1A

  wire   kill_clct0  = clct0_cfeb456 && kill_me1a_clcts;  // Delete CLCT0 from ME1A
  wire   kill_clct1  = clct1_cfeb456 && kill_me1a_clcts;  // Delete CLCT1 from ME1A
  assign kill_trig  = ((kill_clct0 && clct0_exists) && (kill_clct1 && clct1_exists))  // Kill both clcts
  ||                 ((kill_clct0 && clct0_exists) && !clct1_exists)
  ||                ((kill_clct1 && clct1_exists) && !clct0_exists);

  assign tmb_clct0_discard = kill_clct0;
  assign tmb_clct1_discard = kill_clct1;

//------------------------------------------------------------------------------------------------------------------
// Fill in missing ALCT if CLCT has 2 muons, missing CLCT if ALCT has 2 muons
//------------------------------------------------------------------------------------------------------------------
  wire  alct0_vpf  = alct0_real[0];          // Extract valid pattern flags
  wire  alct1_vpf  = alct1_real[0];
  wire  clct0_vpf  = clct0_real[0];
  wire  clct1_vpf  = clct1_real[0];
  
  wire [1:0] clct_bxn_insert  = clctc_real[1:0];      // CLCT bunch crossing number for events missing alct

  wire  tmb_no_alct  = !alct0_vpf;
  wire  tmb_no_clct  = !clct0_vpf;

  wire  tmb_one_alct = alct0_vpf && !alct1_vpf;
  wire  tmb_one_clct = clct0_vpf && !clct1_vpf;

  wire  tmb_two_alct = alct0_vpf && alct1_vpf;
  wire  tmb_two_clct = clct0_vpf && clct1_vpf;

  wire  tmb_dupe_alct = tmb_one_alct && tmb_two_clct;  // Duplicate alct if there are 2 clcts
  wire  tmb_dupe_clct = tmb_one_clct && tmb_two_alct;  // Duplicate clct if there are 2 alcts

// Duplicate alct and clct
  reg  [MXALCT-1:0]  alct0;
  reg  [MXALCT-1:0]  alct1;
  wire [MXALCT-1:0]  alct_dummy;

  reg  [MXCLCT-1:0]  clct0;
  reg  [MXCLCT-1:0]  clct1;
  wire [MXCLCT-1:0]  clct_dummy;
  
  reg  [MXCLCTC-1:0] clctc;
  wire [MXCLCTC-1:0] clctc_dummy;

  assign alct_dummy  = clct_bxn_insert[1:0] << 11;    // Insert clct bxn for clct-only events
  assign clct_dummy  = 0;                  // Blank  clct for alct-only events
  assign clctc_dummy = 0;                  // Blank  clct common for alct-only events

  always @* begin
  if      (tmb_no_clct  ) begin clct0 <= clct_dummy; clct1 <= clct_dummy; clctc <= clctc_dummy; end // clct0 and clct1 do not exist, use dummy clct  
  else if (tmb_dupe_clct) begin clct0 <= clct0_real; clct1 <= clct0_real; clctc <= clctc_real;  end // clct0 exists, but clct1 does not exist, copy clct0 into clct1
  else                    begin clct0 <= clct0_real; clct1 <= clct1_real; clctc <= clctc_real;  end // clct0 and clct1 exist, so use them
  end

  always @* begin
  if      (tmb_no_alct  ) begin alct0 <= alct_dummy; alct1 <= alct_dummy; end // alct0 and alct1 do not exist, use dummy alct
  else if (tmb_dupe_alct) begin alct0 <= alct0_real; alct1 <= alct0_real; end // alct0 exists, but alct1 does not exist, copy alct0 into alct1
  else                    begin alct0 <= alct0_real; alct1 <= alct1_real; end // alct0 and alct1 exist, so use them
  end

// LCT valid pattern flags
  wire lct0_vpf  = alct0_vpf || clct0_vpf;      // First muon exists
  wire lct1_vpf  = alct1_vpf || clct1_vpf;      // Second muon exists

// Decompose ALCT muons
  wire      alct0_valid    = alct0[0];      // Valid pattern flag
  wire  [1:0]  alct0_quality  = alct0[2:1];    // Pattern quality
  wire      alct0_amu    = alct0[3];      // Accelerator muon
  wire  [6:0]  alct0_key    = alct0[10:4];    // Key Wire Group
  wire  [4:0]  alct0_bxn    = alct0[15:11];    // Bunch crossing number

  wire      alct1_valid    = alct1[0];      // Valid pattern flag
  wire  [1:0]  alct1_quality  = alct1[2:1];    // Pattern quality
  wire      alct1_amu    = alct1[3];      // Accelerator muon
  wire  [6:0]  alct1_key    = alct1[10:4];    // Key Wire Group
  wire  [4:0]  alct1_bxn    = alct1[15:11];    // Bunch crossing number

// Decompose CLCT muons
  wire       clct0_valid    = clct0[0];      // Valid pattern flag
  wire  [2:0]  clct0_nhit    = clct0[3:1];    // Hits on pattern 0-6
  wire  [3:0]  clct0_pat    = clct0[7:4];    // Pattern shape 0-A
  wire      clct0_bend    = clct0[4];      // Bend direction, same as pid lsb
  wire  [4:0]  clct0_key    = clct0[12:8];    // 1/2-strip ID number
  wire  [2:0]  clct0_cfeb    = clct0[15:13];    // Key CFEB ID

  wire  [1:0]  clct_bxn    = clctc[1:0];    // Bunch crossing number
  wire      clct_sync_err  = clctc[2];      // Bx0 disagreed with bxn counter

  wire       clct1_valid    = clct1[0];      // Valid pattern flag
  wire  [2:0]  clct1_nhit    = clct1[3:1];    // Hits on pattern 0-6
  wire  [3:0]  clct1_pat    = clct1[7:4];    // Pattern shape 0-A
  wire      clct1_bend    = clct1[4];      // Bend direction, same as pid lsb
  wire  [4:0]  clct1_key    = clct1[12:8];    // 1/2-strip ID number
  wire  [2:0]  clct1_cfeb    = clct1[15:13];    // Key CFEB ID

//------------------------------------------------------------------------------------------------------------------
// LCT Quality
//------------------------------------------------------------------------------------------------------------------
  wire [3:0] lct0_quality;
  wire [3:0] lct1_quality;

  wire [2:0] alct0_nhit = alct0_quality + 3;      // Convert alct quality to number of hits
  wire [2:0] alct1_nhit = alct1_quality + 3;

  wire clct0_cpat = (clct0_nhit >= 2);
  wire clct1_cpat = (clct1_nhit >= 2);

  lct_quality ulct0quality
  (
  .ACC  (alct0_amu),      // In  ALCT accelerator muon bit
  .A    (alct0_valid),      // In  bit: ALCT was found
  .C    (clct0_valid),      // In  bit: CLCT was found
  .A4    (alct0_nhit[2]),    // In  bit (N_A>=4), where N_A=number of ALCT layers
  .C4    (clct0_nhit[2]),    // In  bit (N_C>=4), where N_C=number of CLCT layers
  .P    (clct0_pat[3:0]),    // In  4-bit CLCT pattern number that is presently 1 for n-layer triggers, 2-10 for current patterns, 11-15 "for future expansion".
  .CPAT  (clct0_cpat),      // In  bit for cathode .pattern trigger., i.e. (P>=2 && P<=10) at present
  .Q    (lct0_quality[3:0])    // Out  4-bit TMB quality output
  );

  lct_quality ulct1quality
  (
  .ACC  (alct1_amu),      // In  ALCT accelerator muon bit
  .A    (alct1_valid),      // In  bit: ALCT was found
  .C    (clct1_valid),      // In  bit: CLCT was found
  .A4    (alct1_nhit[2]),    // In  bit (N_A>=4), where N_A=number of ALCT layers
  .C4    (clct1_nhit[2]),    // In  bit (N_C>=4), where N_C=number of CLCT layers
  .P    (clct1_pat[3:0]),    // In  4-bit CLCT pattern number that is presently 1 for n-layer triggers, 2-10 for current patterns, 11-15 "for future expansion".
  .CPAT  (clct1_cpat),      // In  bit for cathode .pattern trigger., i.e. (P>=2 && P<=10) at present
  .Q    (lct1_quality[3:0])    // Out  4-bit TMB quality output
  );

//------------------------------------------------------------------------------------------------------------------
// Delay alct and clct bx0 strobes
//------------------------------------------------------------------------------------------------------------------
  wire [3:0] alct_bx0_adr = alct_bx0_delay-1;
  wire [3:0] clct_bx0_adr = clct_bx0_delay-1;

  x_oneshot uinjalctbx0 (.d(mpc_inj_alct_bx0),.clock(clock),.q(inj_alct_bx0_pulse));  // VME bx0 injector
  x_oneshot uinjclctbx0 (.d(mpc_inj_clct_bx0),.clock(clock),.q(inj_clct_bx0_pulse));

  wire clct_bx0_mux = (bx0_vpf_test)   ?  lct0_vpf    : bx0_xmpc;    // Use lct0 vpf if enabled, use use real clct bx0
  wire alct_bx0_mux = (alct_bx0_enable) ? alct_bx0_rx : clct_bx0_mux;  // Use alct bx0 if enabled, else copy clct bx0

  wire alct_bx0_src = alct_bx0_mux || inj_alct_bx0_pulse;
  wire clct_bx0_src = clct_bx0_mux || inj_clct_bx0_pulse;

  srl16e_bbl #(1) ualctbx0 (.clock(clock),.ce(1'b1),.adr(alct_bx0_adr),.d(alct_bx0_src),.q(alct_bx0_srl));
  srl16e_bbl #(1) uclctbx0 (.clock(clock),.ce(1'b1),.adr(clct_bx0_adr),.d(clct_bx0_src),.q(clct_bx0_srl));

  wire alct_bxdly_is_0 = (alct_bx0_delay == 0);          // Use direct input if SRL address is 0 because
  wire clct_bxdly_is_0 = (clct_bx0_delay == 0);          // 1st SRL output has 1bx overhead

  wire alct_bx0 = (alct_bxdly_is_0) ? alct_bx0_src : alct_bx0_srl;
  wire clct_bx0 = (clct_bxdly_is_0) ? clct_bx0_src : clct_bx0_srl;

  reg bx0_match=0;
  always @(posedge clock) begin
  if      (ttc_resync) bx0_match <= 0;
  else if (clct_bx0  ) bx0_match <= alct_bx0;            // alct_bx0 and clct_bx0 match in time
  end

//------------------------------------------------------------------------------------------------------------------
// Format MPC output words
//------------------------------------------------------------------------------------------------------------------
  assign  mpc0_frame0[6:0]  =  alct0_key[6:0];
  assign  mpc0_frame0[10:7]  =  clct0_pat[3:0];
  assign  mpc0_frame0[14:11]  =  lct0_quality[3:0];
  assign  mpc0_frame0[15]    =  lct0_vpf;

  assign  mpc0_frame1[7:0]  =  {clct0_cfeb[2:0],clct0_key[4:0]};
  assign  mpc0_frame1[8]    =  clct0_bend;
  assign  mpc0_frame1[9]    =  clct_sync_err & tmb_sync_err_en[0];
  assign  mpc0_frame1[10]    =  alct0_bxn[0];
  assign  mpc0_frame1[11]    =  clct_bx0;  // bx0 gets replaced after mpc_tx_delay, keep here to mollify xst
  assign  mpc0_frame1[15:12]  =  csc_id[3:0];

  assign  mpc1_frame0[6:0]  =  alct1_key[6:0];
  assign  mpc1_frame0[10:7]  =  clct1_pat[3:0];
  assign  mpc1_frame0[14:11]  =  lct1_quality[3:0];
  assign  mpc1_frame0[15]    =  lct1_vpf;

  assign  mpc1_frame1[7:0]  =  {clct1_cfeb[2:0],clct1_key[4:0]};
  assign  mpc1_frame1[8]    =  clct1_bend;
  assign  mpc1_frame1[9]    =  clct_sync_err & tmb_sync_err_en[1];
  assign  mpc1_frame1[10]    =  alct1_bxn[0];
  assign  mpc1_frame1[11]    =  alct_bx0;  // bx0 gets replaced after mpc_tx_delay, keep here to mollify xst
  assign  mpc1_frame1[15:12]  =  csc_id[3:0];

// Construct MPC output words for MPC, blanked if no muons present, except bx0 [inserted after mpc_tx_delay]
  wire [MXFRAME-1:0]  mpc0_frame0_pulse;
  wire [MXFRAME-1:0]  mpc0_frame1_pulse;
  wire [MXFRAME-1:0]  mpc1_frame0_pulse;
  wire [MXFRAME-1:0]  mpc1_frame1_pulse;

  wire trig_mpc  = tmb_trig_pulse && tmb_trig_keep;    // Trigger this event
  wire trig_mpc0 = trig_mpc && lct0_vpf && !kill_clct0;  // LCT 0 is valid, send to mpc
  wire trig_mpc1 = trig_mpc && lct1_vpf && !kill_clct1;  // LCT 1 is valid, send to mpc

  assign mpc0_frame0_pulse = (trig_mpc0) ? mpc0_frame0 : 16'h0;
  assign mpc0_frame1_pulse = (trig_mpc0) ? mpc0_frame1 : 16'h0;
  assign mpc1_frame0_pulse = (trig_mpc1) ? mpc1_frame0 : 16'h0;
  assign mpc1_frame1_pulse = (trig_mpc1) ? mpc1_frame1 : 16'h0;

// TMB is supposed to rank LCTs, but doesn't yet
  assign tmb_rank_err = (lct0_quality[3:0] * lct0_vpf) < (lct1_quality[3:0] * lct1_vpf);

//-------------------------------------------------------------------------------------------------------------------
// MPC Transmitter Section
//-------------------------------------------------------------------------------------------------------------------
// Mulitplex MPC data with VME RAM
  reg  pass_ff=0;

  wire [MXMPCTX-1:0] mpc_real_fr0    = {mpc1_frame0_pulse,mpc0_frame0_pulse};
  wire [MXMPCTX-1:0] mpc_real_fr1    = {mpc1_frame1_pulse,mpc0_frame1_pulse};

  wire [MXMPCTX-1:0] mpc_inject_fr0  = {mpc1_inj0,mpc0_inj0};
  wire [MXMPCTX-1:0] mpc_inject_fr1  = {mpc1_inj1,mpc0_inj1};

  wire [MXMPCTX-1:0] mpc_frame0    = (pass_ff) ? mpc_real_fr0 : mpc_inject_fr0;
  wire [MXMPCTX-1:0] mpc_frame1    = (pass_ff) ? mpc_real_fr1 : mpc_inject_fr1;

// Parallel shifter to delay MPC data: delay=0 bypasses srl16s, delay=1 uses adr=0 in srl16s
  wire [MXMPCTX-1:0]  mpc_frame0_srl, mpc_frame0_mux, mpc_frame0_dly;
  wire [MXMPCTX-1:0]  mpc_frame1_srl, mpc_frame1_mux, mpc_frame1_dly, mpc_frame1_mod;

  reg [3:0] mpc_tx_delaym1    = 0;
  reg [3:0] mpc_rx_delaym1    = 0;
  reg      mpc_tx_delay_is_0 = 0;
  reg      mpc_rx_delay_is_0 = 0;

  always @(posedge clock) begin
  mpc_tx_delaym1    <= mpc_tx_delay -  4'h1;
  mpc_rx_delaym1    <= mpc_rx_delay -  4'h1;
  mpc_tx_delay_is_0 <= mpc_tx_delay == 0;
  mpc_rx_delay_is_0 <= mpc_rx_delay == 0;
  end

  wire wsrlen = !mpc_tx_delay_is_0;  // disable shift registers if they are not being used
  wire rsrlen = !mpc_rx_delay_is_0;

  srl16e_bbl #(MXFRAME*2) umpctxdly0 (.clock(clock),.ce(wsrlen),.adr(mpc_tx_delaym1),.d(mpc_frame0[31:0]),.q(mpc_frame0_srl[31:0]));
  srl16e_bbl #(MXFRAME*2) umpctxdly1 (.clock(clock),.ce(wsrlen),.adr(mpc_tx_delaym1),.d(mpc_frame1[31:0]),.q(mpc_frame1_srl[31:0]));

  assign mpc_frame0_mux = (mpc_tx_delay_is_0) ? mpc_frame0 : mpc_frame0_srl;  // frame 0 after mpc_tx_delay
  assign mpc_frame1_mux = (mpc_tx_delay_is_0) ? mpc_frame1 : mpc_frame1_srl;   // frame 1 after mpc_tx_delay

// Insert bx0 into LCTs after mpc_tx_delay
  assign mpc_frame1_mod[10:0]  = mpc_frame1_mux[10:0];
  assign mpc_frame1_mod[11]  = clct_bx0 && !mpc_idle_blank;  // insert bx0 into mpc0_frame1[11] aka frame1[11]
  assign mpc_frame1_mod[26:12]= mpc_frame1_mux[26:12];
  assign mpc_frame1_mod[27]  = alct_bx0 && !mpc_idle_blank;  // insert bx0 into mpc1_frame1[11] aka frame1[27]
  assign mpc_frame1_mod[31:28]= mpc_frame1_mux[31:28];

  assign mpc_frame0_dly = mpc_frame0_mux;            // Send frame 0 unmodified
  assign mpc_frame1_dly = mpc_frame1_mod;            // Send frame 1 with bx0s inserted

  assign mpc_xmit_lct0 = mpc_frame0_dly[15];          // LCT0 sent to MPC
  assign mpc_xmit_lct1 = mpc_frame0_dly[31];          // LCT1 sent to MPC

// Parallel shifter to delay MPC write-buffer strobes
  wire [MXBADR-1:0] wr_adr_rtmb_srl;
  wire [MXBADR-1:0] wr_adr_rtmb_dly;

  srl16e_bbl #(MXBADR) umwadr   (.clock(clock),.ce(wsrlen),.adr(mpc_tx_delaym1),.d(wr_adr_rtmb  ),.q(wr_adr_rtmb_srl  ));
  srl16e_bbl #(1)      umwpush  (.clock(clock),.ce(wsrlen),.adr(mpc_tx_delaym1),.d(wr_push_rtmb ),.q(wr_push_rtmb_srl ));
  srl16e_bbl #(1)      umwavail (.clock(clock),.ce(wsrlen),.adr(mpc_tx_delaym1),.d(wr_avail_rtmb),.q(wr_avail_rtmb_srl));
  srl16e_bbl #(1)      umwtrigm (.clock(clock),.ce(wsrlen),.adr(mpc_tx_delaym1),.d(trig_mpc     ),.q(trig_mpc_srl     ));

  assign wr_adr_rtmb_dly   = (mpc_tx_delay_is_0) ? wr_adr_rtmb   : wr_adr_rtmb_srl;  // Buffer write address after mpc pipeline delay
  wire   wr_push_rtmb_dly  = (mpc_tx_delay_is_0) ? wr_push_rtmb  : wr_push_rtmb_srl;
  wire   wr_avail_rtmb_dly = (mpc_tx_delay_is_0) ? wr_avail_rtmb : wr_avail_rtmb_srl;
  wire   trig_mpc_rtmb_dly = (mpc_tx_delay_is_0) ? trig_mpc      : trig_mpc_srl;

// Push MPC frames into header RAM after mpc_tx_delay
  reg  mpc_frame_ff=0;
  always @(posedge clock) begin
    wr_adr_xmpc   <= wr_adr_rtmb_dly;
    wr_push_xmpc  <= wr_push_rtmb_dly;
    wr_avail_xmpc <= wr_avail_rtmb_dly;
    mpc_frame_ff  <= trig_mpc_rtmb_dly;                // Pipeline strobes

    {mpc1_frame0_ff,mpc0_frame0_ff} <= mpc_frame0_dly; // Pulsed copy of LCTs for header
    {mpc1_frame1_ff,mpc0_frame1_ff} <= mpc_frame1_dly;
  end

// Latch MPC output words for VME
  reg mpc_frame_vme = 0;
  always @(posedge clock) begin
    mpc_frame_vme <= trig_mpc_rtmb_dly; // Pipeline strobes: report to VME that MPC words are latched
    if (event_clear_vme) begin
      {mpc1_frame0_vme,mpc0_frame0_vme} <= 0;
      {mpc1_frame1_vme,mpc0_frame1_vme} <= 0;
    end
    else if (trig_mpc_rtmb_dly) begin
      {mpc1_frame0_vme,mpc0_frame0_vme} <= mpc_frame0_dly; // Latched copy of LCTs for VME
      {mpc1_frame1_vme,mpc0_frame1_vme} <= mpc_frame1_dly;
    end
  end

// Transmit multiplexed MPC data at 80MHz, invert for GTLP drivers
  x_mux_ddr_mpc #(MXMPCTX) umpcmux
  (
  .clock    (clock),      // In  40 MHz clock
  .clock_en  (1'b1),        // In  Clock enable
  .set    (mpc_set),      // In  Sync set
`ifdef DEBUG_MPC
  .din1st    (mpc_frame0_dly),  // In  Input data 1st-in-time
  .din2nd    (mpc_frame1_dly),  // In  Input data 2nd-in-time
`else
  .din1st    (~mpc_frame0_dly),  // In  Input data 1st-in-time
  .din2nd    (~mpc_frame1_dly),  // In  Input data 2nd-in-time
`endif
  .dout    (_mpc_tx)      // Out  Output data multiplexed 2-to-1
  );

//------------------------------------------------------------------------------------------------------------------
// MPC Injector State Machine Declarations
//------------------------------------------------------------------------------------------------------------------
  reg [3:0]    mpc_sm;      // synthesis attribute safe_implementation of mpc_sm is "yes";
  parameter     pass    =  0;
  parameter    start    =  1;
  parameter     injecting  =  2;
  parameter    hold    =  3;

// MPC Injector start FF
  reg mpc_inj_start;

  always @(posedge clock) begin
  mpc_inj_start <= mpc_inject || (ttc_mpc_inject && ttc_mpc_inj_en);
  end

// MPC Injector State Machine
  initial mpc_sm = pass;

  always @(posedge clock) begin
  if (powerup_n)                 mpc_sm <= pass;
  else begin
  case (mpc_sm)
  pass:      if (mpc_inj_start ) mpc_sm <= start;
  start:               mpc_sm <= injecting;
  injecting: if (mpc_frame_done) mpc_sm <= hold;
  hold:      if (!mpc_inj_start) mpc_sm <= pass;
  default                        mpc_sm <= pass;
  endcase
  end
  end

// MPC Injector frame Counter
  always @(posedge clock) begin
  if (mpc_sm==injecting)  mpc_frame_cnt = mpc_frame_cnt + 1'b1;  // Sync  count
  else          mpc_frame_cnt = 0;            // Sync  load
  end

  assign  mpc_frame_done  = mpc_frame_cnt == (mpc_nframes-8'h01);  // fails for 256 unless use 8'h01
  assign  mpc_inj_adr    = mpc_frame_cnt;
  assign   vme_adr      = mpc_adr;

// Pass state FF delays output mux 1 cycle
  always @(posedge clock) begin
  pass_ff <= (mpc_sm != injecting);
  end

// Injector RAM control signals
  wire [15:0] mpc_rdata_01;
  wire [15:0] mpc_rdata_23;

  wire wea01  = |mpc_wen[1:0];      // VME writes to one of the two inj01 RAM address banks
  wire wea23  = |mpc_wen[3:2];      // VME writes to one of the two inj23 RAM address banks
  wire bank01  =  mpc_wen[1] | mpc_ren[1];  // bank=0 for mpc0_inj0, bank=1 for mpc0_inj1
  wire bank23  =  mpc_wen[3] | mpc_ren[3];  // bank=0 for mpc1_inj0, bank=1 for mpc1_inj1

//------------------------------------------------------------------------------------------------------------------
// MPC Injector RAMs
//  Port A: rw 16 bits x 2 words via VME
//  Port B: ro 32 bits x 1 word  via inj SM
//------------------------------------------------------------------------------------------------------------------
  initial $display("tmb: generating Virtex6 RAMB36E1_S18_S36 uinjram01 and uinjram23");

  wire [15:0] injram01_adra, injram23_adra;
  wire [15:0] injram01_adrb, injram23_adrb;
  wire [15:0] injdum0,       injdum1;

  assign injram01_adra[3:0]  = 4'hF;    // Port A data=18, adr=11, valid adr bits [14:4]
  assign injram01_adra[14:4] = {2'h0,vme_adr[7:0],bank01};
  assign injram01_adra[15]   = 1'b1;

  assign injram01_adrb[4:0]  = 5'h1F;    // Port B data=36, adr=10, valid adr bits [14:5]
  assign injram01_adrb[14:5] = {2'h0,mpc_inj_adr[7:0]};
  assign injram01_adrb[15]   = 1'b1;

  assign injram23_adra[3:0]  = 4'hF;    // Port A data=18, adr=11, valid adr bits [14:4]
  assign injram23_adra[14:4] = {2'h0,vme_adr[7:0],bank23};
  assign injram23_adra[15]   = 1'b1;

  assign injram23_adrb[4:0]  = 5'h1F;    // Port B data=36, adr=10, valid adr bits [14:5]
  assign injram23_adrb[14:5] = {2'h0,mpc_inj_adr[7:0]};
  assign injram23_adrb[15]   = 1'b1;

// Initialize MPC Injector muon 0
//  Frame                          "FFFFEEEEDDDDCCCCBBBBAAAA9999888877776666555544443333222211110000"
//  defparam uinjram01.INIT_00=256'hB007A007B006A006B005A005B004A004B003A003B002A002B001A001B000A000;
//  defparam uinjram01.INIT_01=256'hB00FA00FA00EA00EB00DA00DB00CA00CB00BA00BB00AA00AB009A009B008A008;

// Initialize MPC Injector muon 1
//  Frame                          "FFFFEEEEDDDDCCCCBBBBAAAA9999888877776666555544443333222211110000"
//  defparam uinjram23.INIT_00=256'hD007C007D006C006D005C005D004C004D003C003D002C002D001C001D000C000;
//  defparam uinjram23.INIT_01=256'hD00FC00FD00EC00ED00DC00DD00CC00CD00BC00BD00AC00AD009C009D008C008;
  
// MPC Injector RAM: first muon
  RAMB36E1 #(
  .INIT_00 (256'hB007A007B006A006B005A005B004A004B003A003B002A002B001A001B000A000),
  .INIT_01 (256'hB00FA00FA00EA00EB00DA00DB00CA00CB00BA00BB00AA00AB009A009B008A008),
  .RAM_MODE      ("TDP"),            // "SDP" or "TDP"
  .READ_WIDTH_A    (18),              // 0, 1, 2, 4, 9, 18, 36 or 72
  .WRITE_WIDTH_A    (18),              // 0, 1, 2, 4, 9, 18, 36
  .READ_WIDTH_B    (36),              // 0, 1, 2, 4, 9, 18, 36
  .WRITE_WIDTH_B    (0),              // 0, 1, 2, 4, 9, 18, 36 or 72
  .WRITE_MODE_A    ("READ_FIRST"),          // ("READ_FIRST"), "READ_FIRST", or "NO_CHANGE"
  .WRITE_MODE_B    ("READ_FIRST"),
  .SIM_COLLISION_CHECK("ALL")              // "ALL", "WARNING_ONLY", "GENERATE_X_ONLY" or "NONE"
  ) uinjram01 (
  .WEA        ({4{wea01}}),          //  4-bit A port write enable input
  .ENARDEN      (1'b1),              //  1-bit A port enable/Read enable input
  .REGCEAREGCE    (1'b0),              //  1-bit A port register enable/Register enable input
  .RSTRAMARSTRAM    (1'b0),              //  1-bit A port set/reset input
  .RSTREGARSTREG    (1'b0),              //  1-bit A port register set/reset input
  .CLKARDCLK      (clock),            //  1-bit A port clock/Read clock input
  .ADDRARDADDR    (injram01_adra[15:0]),      // 16-bit A port address/Read address input 18b->[14:4]
  .DIADI        ({16'h0000,mpc_wdata[15:0]}),  // 32-bit A port data/LSB data input
  .DIPADIP      (),                //  4-bit A port parity/LSB parity input
  .DOADO        ({injdum0,mpc_rdata_01[15:0]}),  // 32-bit A port data/LSB data output
  .DOPADOP      (),                //  4-bit A port parity/LSB parity output

  .WEBWE        (),                //  8-bit B port write enable/Write enable input
  .ENBWREN      (1'b1),              //  1-bit B port enable/Write enable input
  .REGCEB        (1'b0),              //  1-bit B port register enable input
  .RSTRAMB      (1'b0),              //  1-bit B port set/reset input
  .RSTREGB      (1'b0),              //  1-bit B port register set/reset input
  .CLKBWRCLK      (clock),            //  1-bit B port clock/Write clock input
  .ADDRBWRADDR    (injram01_adrb[15:0]),      // 16-bit B port address/Write address input  36b->[14:5]
  .DIBDI        (),                // 32-bit B port data/MSB data input
  .DIPBDIP      (),                //  4-bit B port parity/MSB parity input
  .DOBDO        ({mpc0_inj1,mpc0_inj0}),    // 32-bit B port data/MSB data output
  .DOPBDOP      (),                //  4-bit B port parity/MSB parity output

  .CASCADEINA      (),                //  1-bit A port cascade input
  .CASCADEINB      (),                //  1-bit B port cascade input
  .CASCADEOUTA    (),                //  1-bit A port cascade output
  .CASCADEOUTB    (),                //  1-bit B port cascade output
  .INJECTDBITERR    (),                //  1-bit Inject a double bit error
  .INJECTSBITERR    (),                //  1-bit Inject a single bit error
  .DBITERR      (),                //  1-bit double bit error status output
  .ECCPARITY      (),                //  8-bit generated error correction parity
  .RDADDRECC      (),                //  9-bit ECC read address
  .SBITERR      ()                //  1-bit Single bit error status output
  );

// MPC Injector RAM: second muon
  RAMB36E1 #(
  .INIT_00 (256'hD007C007D006C006D005C005D004C004D003C003D002C002D001C001D000C000),
  .INIT_01 (256'hD00FC00FD00EC00ED00DC00DD00CC00CD00BC00BD00AC00AD009C009D008C008),
  .RAM_MODE      ("TDP"),            // "SDP" or "TDP"
  .READ_WIDTH_A    (18),              // 0, 1, 2, 4, 9, 18, 36 or 72
  .WRITE_WIDTH_A    (18),              // 0, 1, 2, 4, 9, 18, 36
  .READ_WIDTH_B    (36),              // 0, 1, 2, 4, 9, 18, 36
  .WRITE_WIDTH_B    (0),              // 0, 1, 2, 4, 9, 18, 36 or 72
  .WRITE_MODE_A    ("READ_FIRST"),          // ("READ_FIRST"), "READ_FIRST", or "NO_CHANGE"
  .WRITE_MODE_B    ("READ_FIRST"),
  .SIM_COLLISION_CHECK("ALL")              // "ALL", "WARNING_ONLY", "GENERATE_X_ONLY" or "NONE"
  ) uinjram23 (
  .WEA        ({4{wea23}}),          //  4-bit A port write enable input
  .ENARDEN      (1'b1),              //  1-bit A port enable/Read enable input
  .REGCEAREGCE    (1'b0),              //  1-bit A port register enable/Register enable input
  .RSTRAMARSTRAM    (1'b0),              //  1-bit A port set/reset input
  .RSTREGARSTREG    (1'b0),              //  1-bit A port register set/reset input
  .CLKARDCLK      (clock),            //  1-bit A port clock/Read clock input
  .ADDRARDADDR    (injram23_adra[15:0]),      // 16-bit A port address/Read address input 36b->[14:5]
  .DIADI        ({16'h0000,mpc_wdata[15:0]}),  // 32-bit A port data/LSB data input
  .DIPADIP      (),                //  4-bit A port parity/LSB parity input
  .DOADO        ({injdum1,mpc_rdata_23[15:0]}),  // 32-bit A port data/LSB data output
  .DOPADOP      (),                //  4-bit A port parity/LSB parity output

  .WEBWE        (),                //  8-bit B port write enable/Write enable input
  .ENBWREN      (1'b1),              //  1-bit B port enable/Write enable input
  .REGCEB        (1'b0),              //  1-bit B port register enable input
  .RSTRAMB      (1'b0),              //  1-bit B port set/reset input
  .RSTREGB      (1'b0),              //  1-bit B port register set/reset input
  .CLKBWRCLK      (clock),            //  1-bit B port clock/Write clock input
  .ADDRBWRADDR    (injram23_adrb[15:0]),      // 16-bit B port address/Write address input  18b->[14:5]
  .DIBDI        (),                // 32-bit B port data/MSB data input
  .DIPBDIP      (),                //  4-bit B port parity/MSB parity input
  .DOBDO        ({mpc1_inj1,mpc1_inj0}),    // 32-bit B port data/MSB data output
  .DOPBDOP      (),                //  4-bit B port parity/MSB parity output

  .CASCADEINA      (),                //  1-bit A port cascade input
  .CASCADEINB      (),                //  1-bit B port cascade input
  .CASCADEOUTA    (),                //  1-bit A port cascade output
  .CASCADEOUTB    (),                //  1-bit B port cascade output
  .INJECTDBITERR    (),                //  1-bit Inject a double bit error
  .INJECTSBITERR    (),                //  1-bit Inject a single bit error
  .DBITERR      (),                //  1-bit double bit error status output
  .ECCPARITY      (),                //  8-bit generated error correction parity
  .RDADDRECC      (),                //  9-bit ECC read address
  .SBITERR      ()                //  1-bit Single bit error status output
  );

// Multiplex Injector RAM VME read data
  reg [15:0]  mpc_rdata;

  always @* begin
  case (mpc_ren)
  4'b0001: mpc_rdata <= mpc_rdata_01;
  4'b0010: mpc_rdata <= mpc_rdata_01;
  4'b0100: mpc_rdata <= mpc_rdata_23;
  4'b1000: mpc_rdata <= mpc_rdata_23;
  default   mpc_rdata <= mpc_rdata_01;
  endcase
  end

//-------------------------------------------------------------------------------------------------------------------
// MPC Receiver Section
//-------------------------------------------------------------------------------------------------------------------
// Receive and de-multiplex MPC response
  wire  [1:0]  _mpc_rx_1st;
  wire  [1:0]  _mpc_rx_2nd;

  x_demux_ddr_mpc #(MXMPCRX) umpcdemux (  // must use ddr and not ddr2 beco we can't shift mpc rx data a half cycle
  .clock    (clock),
  .set    (powerup_n),
  .din    (_mpc_rx[1:0]),
  .dout1st  (_mpc_rx_1st[1:0]),
  .dout2nd  (_mpc_rx_2nd[1:0]));

// Map and un-invert demultiplexed signal names
  wire [1:0] mpc_accept;
  wire [1:0] mpc_reserved;

  assign mpc_accept[0]   = !_mpc_rx_1st[0];
  assign mpc_accept[1]   = !_mpc_rx_2nd[0];
  assign mpc_reserved[0] = !_mpc_rx_1st[1];
  assign mpc_reserved[1] = !_mpc_rx_2nd[1];

// Delay MPC processing timer for injector start to match trigger start
  reg mpc_sm_start_ff=0;

  always @(posedge clock) begin
  mpc_sm_start_ff <= (mpc_sm==start);
  end

  wire mpc_wait_start = mpc_frame_ff || mpc_sm_start_ff;

// MPC receive delay pipeline, wait for MPC to select muons for SP
  wire [MXBADR-1:0] wr_adr_rmpc_srl;
  wire [MXBADR-1:0] wr_adr_rmpc_dly;

  srl16e_bbl #(MXBADR) umradr   (.clock(clock),.ce(rsrlen),.adr(mpc_rx_delaym1),.d(wr_adr_xmpc   ),.q(wr_adr_rmpc_srl  ));
  srl16e_bbl #(1)      umrpush  (.clock(clock),.ce(rsrlen),.adr(mpc_rx_delaym1),.d(wr_push_xmpc  ),.q(wr_push_rmpc_srl ));
  srl16e_bbl #(1)      umravail (.clock(clock),.ce(rsrlen),.adr(mpc_rx_delaym1),.d(wr_avail_xmpc ),.q(wr_avail_rmpc_srl));
  srl16e_bbl #(1)      umrtrigm (.clock(clock),.ce(rsrlen),.adr(mpc_rx_delaym1),.d(mpc_wait_start),.q(trig_rmpc_srl    ));

  assign wr_adr_rmpc_dly   = (mpc_rx_delay_is_0) ? wr_adr_xmpc    : wr_adr_rmpc_srl;  // Buffer write address after mpc pipeline delay
  wire   wr_push_rmpc_dly  = (mpc_rx_delay_is_0) ? wr_push_xmpc   : wr_push_rmpc_srl;
  wire   wr_avail_rmpc_dly = (mpc_rx_delay_is_0) ? wr_avail_xmpc  : wr_avail_rmpc_srl;
  wire   mpc_response      = (mpc_rx_delay_is_0) ? mpc_wait_start : trig_rmpc_srl;

  reg      mpc_response_ff = 0;
  reg [1:0]  mpc_accept_ff   = 0;
  reg [1:0]  mpc_reserved_ff = 0;

  always @(posedge clock) begin
  wr_adr_rmpc    <= wr_adr_rmpc_dly;
  wr_push_rmpc  <= wr_push_rmpc_dly;
  wr_avail_rmpc  <= wr_avail_rmpc_dly;

  mpc_response_ff  <= mpc_response;
  mpc_accept_ff  <= mpc_accept[1:0];
  mpc_reserved_ff  <= mpc_reserved[1:0];
  end

// Latch MPC response for VME readout
  reg [1:0] mpc_accept_vme   = 0;
  reg [1:0] mpc_reserved_vme = 0;

  always @(posedge clock) begin
  if (mpc_response) begin
  mpc_accept_vme[1:0]   <= mpc_accept[1:0];
  mpc_reserved_vme[1:0] <= mpc_reserved[1:0];
  end
  end

//------------------------------------------------------------------------------------------------------------------
// MPC Accept RAM: Stores mpc_accept + mpc_reserved
//  Port A: ro 16-bit data via VME 256 tbins deep
//  Port B: wo 16-bit data via injector SM
//------------------------------------------------------------------------------------------------------------------
  wire [15:0]  mpcacc_wdata = {12'h000,mpc_reserved[1],mpc_reserved[0],mpc_accept[1],mpc_accept[0]};
  wire [15:0]  mpcacc_rdata;

  assign  mpc_accept_rdata[3:0] =  mpcacc_rdata[3:0];


  initial $display("tmb: generating Virtex6 RAMB18E1_S18_S18 umpcacc");

  RAMB18E1 #(                      // Virtex6
  .RAM_MODE      ("TDP"),            // SDP or TDP
   .READ_WIDTH_A    (18),              // 0,1,2,4,9,18,36 Read/write width per port
  .WRITE_WIDTH_A    (0),              // 0,1,2,4,9,18
  .READ_WIDTH_B    (0),              // 0,1,2,4,9,18
  .WRITE_WIDTH_B    (18),              // 0,1,2,4,9,18,36
  .WRITE_MODE_A    ("READ_FIRST"),          // Must be same for both ports in SDP mode: WRITE_FIRST, READ_FIRST, or NO_CHANGE)
  .WRITE_MODE_B    ("READ_FIRST"),
  .SIM_COLLISION_CHECK("ALL")              // ALL, WARNING_ONLY, GENERATE_X_ONLY or NONE)
  ) uram (
  .WEA        (),                //  2-bit A port write enable input
  .ENARDEN      (1'b1),              //  1-bit A port enable/Read enable input
  .RSTRAMARSTRAM    (1'b0),              //  1-bit A port set/reset input
  .RSTREGARSTREG    (1'b0),              //  1-bit A port register set/reset input
  .REGCEAREGCE    (1'b0),              //  1-bit A port register enable/Register enable input
  .CLKARDCLK      (clock),            //  1-bit A port clock/Read clock input
  .ADDRARDADDR    ({2'h0,vme_adr[7:0],4'hF}),    // 14-bit A port address/Read address input 18b->[13:4]
  .DIADI        (),                // 16-bit A port data/LSB data input
  .DIPADIP      (),                //  2-bit A port parity/LSB parity input
  .DOADO        (mpcacc_rdata[15:0]),      // 16-bit A port data/LSB data output
  .DOPADOP      (),                //  2-bit A port parity/LSB parity output

  .WEBWE        ({4{mpc_sm==injecting}}),    //  4-bit B port write enable/Write enable input
  .ENBWREN      (1'b1),              //  1-bit B port enable/Write enable input
  .REGCEB        (1'b0),              //  1-bit B port register enable input
  .RSTRAMB      (1'b0),              //  1-bit B port set/reset input
  .RSTREGB      (1'b0),              //  1-bit B port register set/reset input
  .CLKBWRCLK      (clock),            //  1-bit B port clock/Write clock input
  .ADDRBWRADDR    ({2'h0,mpc_inj_adr[7:0],4'hF}),  // 14-bit B port address/Write address input 18b->[13:4]
  .DIBDI        (mpcacc_wdata[15:0]),      // 16-bit B port data/MSB data input
  .DIPBDIP      (),                //  2-bit B port parity/MSB parity input
  .DOBDO        (),                // 16-bit B port data/MSB data output
  .DOPBDOP      ()                //  2-bit B port parity/MSB parity output
  );

//------------------------------------------------------------------------------------------------------------------
// Sump
//------------------------------------------------------------------------------------------------------------------
  assign tmb_sump =
  (|injdum0)        |
  (|injdum1)        |
  (|mpcacc_rdata[15:4])  |
  (|alct0_nhit[1:0])    |
  (|alct1_nhit[1:0])    |
  clct0_nhit[0]      |
  clct1_nhit[0]      |
  (|alct0_bxn[4:1])    | (|alct1_bxn[4:1])  |
  (|clct_bxn[1:0])    |
  mpc_frame1_mux[11]    |
  mpc_frame1_mux[27];

//------------------------------------------------------------------------------------------------------------------
// Debug
//------------------------------------------------------------------------------------------------------------------
`ifdef DEBUG_TMB
// Injector state machine ASCII display
  reg[71:0] mpc_sm_dsp;
  always @* begin
  case (mpc_sm)
  pass:    mpc_sm_dsp <= "pass     ";
  start:    mpc_sm_dsp <= "start    ";
  injecting:  mpc_sm_dsp <= "injecting";
  hold  :  mpc_sm_dsp <= "hold     ";
  default    mpc_sm_dsp <= "pass     ";
  endcase
  end

// Window priority table
  assign deb_clct_win_priority0  = clct_win_priority[0];
  assign deb_clct_win_priority1  = clct_win_priority[1];
  assign deb_clct_win_priority2  = clct_win_priority[2];
  assign deb_clct_win_priority3  = clct_win_priority[3];
  assign deb_clct_win_priority4  = clct_win_priority[4];
  assign deb_clct_win_priority5  = clct_win_priority[5];
  assign deb_clct_win_priority6  = clct_win_priority[6];
  assign deb_clct_win_priority7  = clct_win_priority[7];
  assign deb_clct_win_priority8  = clct_win_priority[8];
  assign deb_clct_win_priority9  = clct_win_priority[9];
  assign deb_clct_win_priority10 = clct_win_priority[10];
  assign deb_clct_win_priority11 = clct_win_priority[11];
  assign deb_clct_win_priority12 = clct_win_priority[12];
  assign deb_clct_win_priority13 = clct_win_priority[13];
  assign deb_clct_win_priority14 = clct_win_priority[14];
  assign deb_clct_win_priority15 = clct_win_priority[15];

// Window priorities enabled
  assign deb_win_pri0  = win_pri[0];
  assign deb_win_pri1  = win_pri[1];
  assign deb_win_pri2  = win_pri[2];
  assign deb_win_pri3  = win_pri[3];
  assign deb_win_pri4  = win_pri[4];
  assign deb_win_pri5  = win_pri[5];
  assign deb_win_pri6  = win_pri[6];
  assign deb_win_pri7  = win_pri[7];
  assign deb_win_pri8  = win_pri[8];
  assign deb_win_pri9  = win_pri[9];
  assign deb_win_pri10 = win_pri[10];
  assign deb_win_pri11 = win_pri[11];
  assign deb_win_pri12 = win_pri[12];
  assign deb_win_pri13 = win_pri[13];
  assign deb_win_pri14 = win_pri[14];
  assign deb_win_pri15 = win_pri[15];
`endif

`ifdef DEBUG_MPC
  assign mpc_debug_mode=1;
`endif

//-------------------------------------------------------------------------------------------------------------------
  endmodule
//-------------------------------------------------------------------------------------------------------------------
