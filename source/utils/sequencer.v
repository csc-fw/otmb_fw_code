`timescale 1ns / 1ps
//`define DEBUG_SEQUENCER 1
//------------------------------------------------------------------------------------------------------------------
//  Sequencer
//------------------------------------------------------------------------------------------------------------------
//
//  Pretriggers on either pattern finder or external trigger.
//     Sequences event processing.
//    Controls Raw Hits RAMs
//    Outputs CLCTs to TMB
//    Records TMB match result
//    Outputs Raw Hits to DMB
//
//   02/07/2002  Ported from LCT99 AHDL
//  02/13/2002  Added ext_inject
//  02/14/2002  Added TTC counters
//  02/15/2002  Trigger path pipeline delay tuning
//  02/19/2002  Removed encode state to align sm with trigger path
//  02/21/2002  Moved to Pentium 4 platform
//  02/21/2002  Adjusted L1A counters, changed l1a to count all L1As, not just those that trigger
//  02/24/2002  New clct_fifo logic
//  02/28/2002  Delayed clct_fifo data wrt fifo_busy, so busy goes low 1 clock before data is done
//  03/01/2002  Added DMB transmission RAM
//  03/01/2002  Replaced library instances with behavioral code
//  03/02/2002  Fixed RAM word count
//  03/03/2002  Added ALCT RAM readout
//  03/07/2002  Added TMB ports
//  03/07/2002  New header format
//  03/08/2002  Replaced header mux with parallel shifter
//  03/08/2002  Removed vme_reset from raw hits RAM write-address counter
//  03/08/2002  Put vme_reset back in, it's needed to keep VME from re-reading same event
//  03/08/2002  Moved l1a_match to an xtmb latching header word
//  03/08/2002  Fixed driver conflict
//  03/10/2002  Changed marker frames
//  03/10/2002  Started ALCT readout 1 clock earlier, delayed ALCT data 1 clock
//  03/10/2002  Modified header bit assignments, stored header count in header frame, added firmware revcode
//  03/11/2002  Changed revcode format
//  03/11/2002  Delayed fifo_data 2 clocks wrt fifo_busy
//  03/12/2002  Removed debug ports
//  03/12/2002  Added clct_status array for CCB
//  03/12/2002  Added led_alct
//  03/13/2002  Added led_bd array
//  03/26/2002  State machine outputs now go to on-board LEDs
//  03/26/2002  ALCT-only mods, changed led_pretrig to led_clct
//  03/27/2002  Fixed stat_invpat for alct-only, fixed DMB pin assignments, added sequencer_state for vme readout
//  03/28/2002  Added alct_fifo_reset, was l1a before
//  04/02/2002  Changed alct_fifo_reset to be xlast instead of idle
//  04/03/2002  Pushed alct_start_read 2 clocks earlier to remove 2 words at start of alct readout
//  04/04/2002  Output latched CLCTs to VME
//  04/09/2002  Moved dmb_rx to ccb.v
//  04/24/2002  Added scint_veto, removed header and alct from fifo sync mode
//  04/25/2002  Added trig_keep
//  05/01/2002  Changed ccb l1a request from ccb to start with tmb pre-trig
//  05/02/2002  Fixed scint_veto FF
//  05/03/2002  Removed keep_event, now L1A is just not issued for non-keep events, L1A can only be sent once per pretrig
//  05/06/2002  L1A delay mux for alct_trig_pulse
//  05/07/2002  Added veto oneshot, shifted l1a delay -2 for alct trigger
//  05/08/2002  Tuned L1A delays for clct and alct so L1A is correct time after status 0 output
//  05/14/2002  Fixed external trigger
//  06/03/2002  Re-organized trigger input mux, add bx0_local
//  06/04/2002  New revcode from VME
//  06/05/2002  Trig mux fix
//  06/07/2002  Added vme trigger source readback
//  06/10/2002  LEDs now use VPFs
//  06/13/2002  Added clct pattern trigger delay (didnt delay active_febs too, assume will use all_febs_active bit)
//  06/14/2002  Delayed active_feb to be in time with delayed active_feb_flag
//  06/17/2002  Removed clct pattern trigger delay, it causes a lot of problems, added l1a request delay for drift time
//  06/24/2002  Added match requirement to pre-trigger, new trigger vector in headers 4,5
//  06/25/2002  Revert to previous active_feb staging to improve speed
//  06/26/2002  Add trig_source_noflush to keep external triggers and alct triggers, but prevent alct self-matching in tmb
//  06/27/2002  Revert noflush because tmb really needs clct to request l1a
//  07/03/2002  CLCT latching fixed
//  07/08/2002  Delayed mpc frame latching from tmb processing stage
//  11/25/2002  New cfeb patterns
//  12/02/2002  Start mult-buffer mods
//  12/05/2002  Add ranlct random active feb signals for DMB
//  12/09/2002  Add force_active
//  12/16/2002  New fifo controller signals
//  12/17/2002  Block pretrigger if buffer not available, unless override enabled
//  12/19/2002  Add to trigger ram data
//  01/22/2003  Add alct vpf and clct active feb test points, separate alct_1st_valid and alct_active_feb triggers
//  01/29/2003  Push sync_err and bx0_local into clct words
//  02/04/2003  Tmb status mods
//  02/05/2003  New clct sequencer and discard counters
//  02/06/2003  L1A processing added
//  02/07/2003  Scope now has trigger source select, added l1a stack
//  02/10/2003  L1A push logic
//  02/11/2003  Header unpacking
//  02/14/2003  Readout format
//  02/18/2003  Continued
//  02/19/2003  Continued
//  02/20/2003  Delay crc mux enables 1 clock
//  02/21/2003  Add rd_feb_list for clct_fifo local readout
//  02/24/2003  New clct_fifo
//  02/25/2003  Resets for L1A RAM and dmb RAM address at power up
//  02/26/2003  Debug
//  02/27/2003  No progress, day wasted by OSU and Hauser
//  02/28/2003  Advance wr_buf_pretrig by 2 clocks to minimize buffer waits
//  03/01/2003  Separated CLCT trigger from TMB/MPC processing for speed, added turbo mode to bypass buffer waits
//  03/01/2003  Add FMM trig_ready, programmable flush timer
//  03/02/2003  Separated CLCT TMB MPC state machines
//  03/03/2003  Fixed mpc response timeout, new parallel shifter for mpc response buffer number, deleted mpc machine
//  03/04/2003  New bxn logic per Smith/Hauser/Varela
//  03/06/2003  Fixed bxn for ovf and bx0 arriving at the same time
//  03/07/2003  Readout section replaced with OSU headers
//  03/08/2003  TMB and MPC timeouts prevent tmb_sm hang
//  03/09/2003  Readout mods
//  03/09/2003  Added missing e0c frame, retimed mod4, added status outputs, on-board LEDs
//  03/10/2003  Fix to block start_read if no cfebs
//  03/11/2003  Push alct_only, but mark as no-buffer events
//  03/12/2003  Debugs removed
//  03/12/2003  LEDs, state, peak buffer count
//  03/15/2003  Scope clock changed from vme for speed, l1resets now syncronous, async was unstable
//  03/16/2003  L1A LED fix
//  03/18/2003  Add dmb_busy to scope
//  03/19/2003  Bring in cfeb_exists from top level, un-reverse crc22, fix match window latch
//  03/25/2003  Clip active_feb_flag to single pulse, add invp to scope
//  04/04/2003  Mods for DMB data available signal at L1A instead of on readout pop
//  04/15/2003  Mods for dmb_dav failure if 2nd l1a is 75ns after 1st l1a, bxn now latches at l1a
//  04/29/2003  LHC_CYCLE now VME programmable, add ttc_bxreset to reset bxn but not l1a or buffers
//  04/30/2003  Add mpc_accept_tp for scope display
//  05/07/2003  New scope signals, correct drift delay counter for 1-clock longer cfeb_v8.v pipeline
//  05/08/2003  Mods for scope64
//  05/09/2003  Change nowrbuf discard count enable
//  05/12/2003  Add cfeb info to header, add drift strobe to scope
//  05/13/2003  Mods for scope96
//  05/14/2003  Add buf_nbusy to scope, add alct raw hits sync
//  05/15/2003  Add scope to dmb readout
//  05/16/2003  Mods for scope readout
//  05/19/2003  Add nrams to scope
//  06/04/2003  Add nl1a flash on buffer full, programmable flash rate
//  09/10/2003  Hacked for mpc_accept debug
//  09/11/2003  Added mpc_accept_tp and mpc_accept_vme, moved here from tmb.v
//  09/12/2003  Add allowpretrignoflush, unhacked mpc_accept debug
//  10/06/2003  Mod for tmb2003a
//  05/10/2004  Add RPC scope ports
//  05/18/2004  Add RPC injector logic
//  05/19/2004  Add RPC raw hits readout, increase header for RPC info
//  05/20/2004  Conform RPC raws hits format to match CFEB
//  05/24/2004  Skip RPC readout if all RPCs are disabled, but still send markers
//  06/09/2004  Add last_header calculation to avoid underflow if r_nheaders =0
//  06/10/2004  Add mpc_tx_delay
//  06/17/2004  Add programmable scope trigger channel
//  07/23/2004  Add nph_pattern to header
//  07/30/2004  Remove crc reversed data, it was unused
//  08/02/2004  Add event counters
//  08/03/2004  Add tmb status counters to VME readout
//  08/05/2004  Add mpc accept counters
//  08/26/2004  Add counter stop if any overflows
//  10/01/2004  Add scp_auto to header
//  10/04/2004  Poobah demands ttc_bx0 instead of bx0_local sent to mpc
//  05/19/2006  Add active feb flag blanking for disabled cfebs
//  07/26/2006  Add prom state machine status to header data
//  07/27/2006  Add uptime and board status to header
//  08/02/2006  Add layer or trigger
//  08/04/2006  Expand trigger source vector to 8:0
//  08/15/2006  Remove ff from layer_trig signal to speed up by 1 clock
//  08/31/2006  Output bxn to vme
//  09/12/2006  Mods for xst
//  09/20/2006  More xst mods
//  09/29/2006  x_flash(11) becomes x_flashsm(19) for same 13ms flash
//  10/03/2006  Mod ramlut calls
//  10/05/2006  Replace for-loops with while-loops for xst
//  10/16/2006  Add clct0 key and cfeb to scope
//  10/17/2006  Add first_pat to scope
//  10/20/2006  add l1a window position to header22
//  10/20/2006  Fix l1a received counter
//  10/24/2006  Mods to l1a window position logic
//  11/22/2006  Mod scope channels
//  11/29/2006  Remove debug scope channels, reorder hsds
//  02/12/2007  Mod sequencer to set all_cfebs_active only for cfebs enabled for readout
//  04/06/2007  Reduce RPC arrays from 2 to 4
//  04/27/2007  Rename ttc_l1reset to ttc_resync
//  05/16/2007  Go cylon in stop mode instead of flash, it looked too much like prom loading failures
//  05/21/2007  Move cylon to vme, send flash signal to vme
//  06/20/2007  Integrate layer trigger with pattern finder, remove ranlct
//  06/22/2007  Increase tmb match timeout beco clct_width is temporarily 7bx
//  07/02/2007  Revert timeouts until can check consequences in simulator
//  07/10/2007  Increase tmb match timeout, but make clct_sm wait before re-arming for new event, else get wrong tmb buf
//  07/20/2007  Reduce ram count
//  07/23/2007  New scope.v has 512tbins, 1/2 fewer rams
//  07/31/2007  Increase tmb match timeout again, extend count to 5 bits, to allow for clct_width=15 but not 16 (ie 0)
//  08/10/2007  Mod tmb_sm to discard event on trig_pulse if not also trig_keep, don't push event on l1a stack either
//  08/13/2007  Add buffer reset state machine, add buffer-reset counter
//  08/15/2007  Restructure header per poobah, increase l1a_rx_counter from 4 bits to 12
//  08/20/2007  Major reassignment of header bits, increase from 26 words to 32
//  08/22/2007  Add bx0 counter, mod trailer logic for new format
//  08/27/2007  Fix alct header section
//  08/29/2007  Expand revcode, fix readout counter
//  09/04/2007  More header mods
//  09/05/2007  Yet more header mods
//  09/07/2007  Fix header 22,37,38 + alct counter
//  09/10/2007  Add tmb matching details to header
//  09/12/2007  Latch tmb dupe signals using mpc data strobe, which is 1bx later than matching info
//  09/12/2007  Took ff off of dupe signals, added no alct counter
//  09/14/2007  Revert to normal scope channels
//  10/01/2007  New clct fifo ports
//  10/03/2007  Mod cfeb read start to begin after header instead of at header start
//  10/09/2007  Conform crc logic to ddu, skip de0f marker because ddu logic fails to include it
//  10/15/2007  Remove clct_fifo debug scope connections
//  10/16/2007  Remove OR of 2 high order tbin bits in of raw hits stream, just let 4-bit tbin markers wrap at 16
//  10/18/2007  Remove FF on LCT0/1 to save 1bx latency, add vpf blanking for clarity in simulator
//  10/19/2007  Restructure clct0/1 and add new clcb to carry info common to both clcts
//  10/25/2007  Replace ramluts with block rams
//  10/30/2007  Add block ram address pipeline
//  10/31/2007  Tune pipeline timing
//  11/01/2007  Replace tmb timeout counters with tmb event counters
//  12/14/2007  Replace buffer status signals with new buffer_write_ctrl
//  12/18/2007  Add inhibit for auto buffer reset
//  12/19/2008  Replace L1A stack
//  01/16/2008  Delete L1A stack, replace entire L1A processing section
//  01/17/2008  Repairs for sequencer-tmb_wrbuf subdesign simulation
//  01/18/2008  Replace first,second with 0,1
//  01/22/2008  Mod dmb shadow ram enables to avoid port conflicts in simulator
//  01/23/2008  Replace buffer write control module
//  01/24/2008  Limit buf pop to 1bx pulse, tune l1a offset to make pretrig bx correspond to l1a bx + l1a delay
//  02/05/2008  Add parity errors to header27 and vme adr FA
//  02/06/2008  Replace alct window width oneshot with triad decoder zero delay counter logic
//  02/07/2008  Add pretrig-drift_delay pipleline
//  02/26/2008  Replace entire pre-trigger section with pretrig_unit.v import
//  02/29/2008  New pre-trigger pipeline and header storage write-enables
//  03/03/2008  Add l1a continuous write to header ram pipeline
//  04/18/2008  New tmb.v connections clct_width changed to clct_window for consistency
//  04/18/2008  Reorganize counters, add new counters from tmb.v
//  04/21/2008  Change tp to tprt realtime test points
//  04/22/2008  Add triad test point at input to raw hits RAMs, decrease drift delay pipe 1bx
//  04/23/2008  Add clct_blanking to clear clcts with no hits
//  04/24/2008  Make clct1 invalid if it has hits below threshold
//  04/25/2008  Add independent rpc tbins to header
//  04/29/2008  New event counter logic
//  04/30/2008  New scope channel assignments, added throttle state to deadtime counter
//  05/01/2008  Rearrange scope channels, push clct_counter into ram 1bx after xtmb, fix hdr11,22,28 write strobes
//  05/09/2008  Move xmpc frame storage to latch after mpc_tx_delay instead of before, makes bx0 delay independent
//  05/19/2008  Replace mpc rx pipeline in tmb.v, response pipe chained to tx delay pipe, fixes mpc response counter too
//  05/19/2008  Mod alct stucture error detection to exclude wg=amu=q=bxn=0
//  05/23/2008  Add lock_lost to sync_err
//  05/30/2008  Conform powerup block, add startup state to readout machine to give buffer queue logic time to reset
//  06/02/2008  Add lock_lost to header
//  06/03/2008  Add received scope signal mux, mod active_feb mux to scope
//  07/14/2008  Add non-triggering event keep
//  08/01/2008  Gate r_nrpcs_read with rpc_read_enable to zero rpc count in header if rpc readout is off
//  08/23/2008  Add csc orientation to header
//  08/28/2008  Add me1a me1b pre-trig counters
//  09/11/2008  Add trig keep to header41
//  09/17/2008  Mod scope.v
//  09/18/2008  Add scp no write to vme
//  09/19/2008  Mod scp start to wait for rpc to finish
//  09/24/2008  Reassign scope channels to skip mod 16 beco DMB allows only 15-bit readout, add me1a discard counters
//  10/22/2008  Conform tmb signal names to sequencer output signals
//  10/24/2008  Add tmb_trig_write
//  10/28/2008  Fix eef marker insertion for short-header-only format
//  10/29/2008  Mod long header-only mode to blank cfeb and rpc lists
//  11/14/2008  Add sync error counter
//  11/15/2008  Add data array to queue storage
//  11/16/2008  Mod l1a led to flash on any l1a push into queue
//  11/16/2008  Mod l1a type logic
//  12/02/2008  Add l1a look back
//  12/08/2008  Mod wr_buf_ready for notmb L1A readouts
//  12/08/2008  Add buffer status latches for vme debug register
//  12/10/2008  Change counter enables[34:26] from wr_en_rtmb to wr_push_rtmb to avoid continuous counting in l1a-mode
//  02/24/2009  Add ecc to data received from alct, add 2 ecc rx error counters
//  03/06/2009  Shift counters up by 1 for new alct crc tx error counter
//  03/06/2009  Add 5 separate cfeb pretrig counters
//  03/06/2009  Add separate l1a bxn offset, a huge mistake in my opinion
//  03/11/2009  Add alct counters for all ecc syndrome cases
//  04/24/2009  Replace 5 dmb raw hits rams with 4 ram cascade to gain 1 ram, add recovery to state machines
//  04/27/2009  Add dopa sump
//  04/30/2009  Add perr miniscope
//  05/01/2009  Add miniscope readout
//  05/05/2009  Miniscope readout sm bugfix
//  05/06/2009  Advance miniscope readout 1bx with lookahead logic
//  05/08/2009  Send pre trig marker to rpc raw hits ram
//  06/06/2009  Consolidate dmb_tx FFs into one section
//  06/05/2009  Add dmb_tx_reserved[4:0] for spare tmb-to-dmb signals
//  07/22/2009  Remove clock_vme global net to make room for cfeb digital phase shifter gbufs
//  08/07/2009  Revert to 10mhz vme clock
//  08/12/2009  Remove clock_vme again
//  08/25/2009  Mod clct sm re-trigger to stay busy only for enabled trigger sources
//  09/14/2009  Move sync error processing to sync_err_ctrl.v module
//  09/16/2009  Add sync errors stop pretrig and l1a readout 
//  09/21/2009  Restrict bxn offsets to be in the interval 0 < lhc_cycle to prevent non-physical bxns
//  09/28/2009  Push dmb ffs into iobs
//  10/07/2009  Fix record type
//  10/15/2009  Remove empty bit in usrldrift
//  12/15/2009  Add bad cfeb list to hdr30
//  02/10/2010  Add event clear for vme diagnostic registers
//  03/07/2010  Add blocked cfebs readout
//  04/16/2010  Update read_sm_dsp states
//  04/29/2010  Add bxn_sync_err to clct sync error
//  05/12/2010  Mod bxn sync error logic pulse 1bx for counter and to fix sync_err always 1
//  05/27/2010  Add inits to all reg declarations
//  05/27/2010  Add widths to adder integers to conform to xst 12.1
//  05/28/2010  Add debug outputs for postdrift stobes, increase l1a offset to full width
//  06/09/2010  Add l1a window priorities and one event per l1a mode, bugfix multiple l1as in window
//  06/25/2010  New miniscope channels delay pretrig bits and now include L1A signals
//  06/26/2010  Reduce miniscope channels to 14 because unpacker is weak
//  07/01/2010  Add counter for events lost from readout due to L1A window prioritizing
//  09/20/2010  Port to ise 12
//  09/21/2010  Replace * operators
//  09/22/2010  Add l1a window sr preset from vme
//  10/01/2010  Replace scope ram with sdp
//  10/06/2010  Revert to blocking operators because l1a ram adr calcs require them
//  10/18/2010  Add virtex 6 RAM option
//  05/27/2011  Stupid positional port changes for ISE 13
//  05/27/2011  Shorten cb_cnt{1:0] to [0:0], replace cb_sm with blocking operators
//  02/21/2013  Expand to 7 cfebs
//  03/07/2013  Restore normal scope channels
//
//------------------------------------------------------------------------------------------------------------------
//  Readout Format:
//------------------------------------------------------------------------------------------------------------------
//  Record Types:
//
//  rType  Dump  Header
//  0    No    Full
//  1    Full  Full
//  2    Local  Full
//  3    No    Short
//
//  Full and Local Dump Format:
//  1  DB0C   header   Beginning Of Cathode Data
//  e   event   header    Event info
//  e   clct   header    Cathode LCTs
//  e   tmb     header    TMB match result
//  e   mpc   header    MPC frames
//  e   buf   header    Buffer status
//  e   rpc   header    RPC status
//  e  6E0B   header    End of header block 
//  n   hits        FEB0 raw hits 
//  n   hits        FEB1 raw hits 
//  n   hits        FEB2 raw hits 
//  n   hits        FEB3 raw hits 
//  n   hits        FEB4 raw hits
//  1  6B04    (option)  Start of RPC data
//  n   RPC pads (option)  RPC data
//  1  6E04    (option)  End of RPC data
//  1  6B05    (option)  Start of scope data
//  n  scope data(option)  Scope data
//  1  6E05    (option)  End of scope data
//  1  6E0C        End of Cathode data
//  1  2AAA        Optional to make word count x4
//  1  5555        Optional to make word count x4
//  1   E0F        End of Frame
//  1   crc0        CRC22
//  1   crc1        CRC22
//  1   frame wordcount  Total words in transmission
//  ---
//  x frames = nheaders+E0B+ncfebs*(4*ntbins)+EOC+2(2AAA 5555)+EOF+2crc+wdcnt
//
//  Long Header-only Format:
//  1  DB0C     header   Beginning Of Cathode Data
//  e   event   header    Event info
//  e   clct   header    Cathode LCTs
//  e   tmb     header    TMB match result
//  e   mpc   header    MPC frames
//  e   buf   header    Buffer status
//  1  6E0B
//  1  6E0C
//  1   E0F        End of Frame
//  1   crc0        CRC22
//  1   crc1        CRC22
//  1   frame wordcount  Total words in transmission
//  ---
//  x frames = nheaders+E0B+E0C+EOF+2crc+wdcnt
//
//  Short Header-only Format:
//  1  DB0C   header    Beginning Of Cathode Data
//  7   event   header    Event info
//  1   E0F        End of Frame
//  1   crc0        CRC22
//  1   crc1        CRC22
//  1   frame wordcount  Total words in transmission
//  ---
//  12 frames = 8headers+EOF+2crc+wdcnt
//
//------------------------------------------------------------------------------------------------------------------
// Ports:
//------------------------------------------------------------------------------------------------------------------
  module  sequencer
  (
// CCB
  clock,
  global_reset,
  clock_lock_lost_err,
  ccb_l1accept,
  ccb_evcntres,
  ttc_bx0,
  ttc_resync,
  ttc_bxreset,
  ttc_orbit_reset,
  fmm_trig_stop,
  sync_err,
  clct_bx0_sync_err,

// ALCT
  alct_active_feb,
  alct0_valid,
  alct1_valid,
  read_sm_xdmb,
  
// External Triggers
  alct_adb_pulse_sync,
  dmb_ext_trig,
  clct_ext_trig,
  alct_ext_trig,
  vme_ext_trig,
  ext_trig_inject,

// External Trigger Enables
  clct_pat_trig_en,
  alct_pat_trig_en,
  alct_match_trig_en,
  adb_ext_trig_en,
  dmb_ext_trig_en,
  clct_ext_trig_en,
  alct_ext_trig_en,
  layer_trig_en,
  cfeb_en,
  active_feb_src,

// Trigger modifiers
  all_cfebs_active,
  alct_preClct_width,
  wr_buf_required,
  wr_buf_autoclr_en,
  valid_clct_required,
  sync_err_stops_pretrig,
  sync_err_stops_readout,

// External Trigger Delays
  alct_preClct_dly,
  alct_pat_trig_dly,
  adb_ext_trig_dly,
  dmb_ext_trig_dly,
  clct_ext_trig_dly,
  alct_ext_trig_dly,

// pre-CLCT modifiers for L1A*preCLCT overlap
  l1a_preClct_width,
  l1a_preClct_dly,

// CLCT/RPC/RAT Pattern Injector
  inj_trig_vme,
  injector_mask_cfeb,
  injector_mask_rat,
  injector_mask_rpc,
  inj_delay_rat,
  injector_go_cfeb,
  injector_go_rat,
  injector_go_rpc,

// Status from CFEB
  triad_skip,
  triad_tp,
  cfeb_badbits_found,
  cfeb_badbits_blocked,

// Pattern Finder PreTrigger Ports
  cfeb_hit,
  cfeb_active,

  cfeb_layer_trig,
  cfeb_layer_or,
  cfeb_nlayers_hit,

// Pattern Finder CLCT results
  hs_hit_1st,
  hs_pid_1st,
  hs_key_1st,

  hs_hit_2nd,
  hs_pid_2nd,
  hs_key_2nd,
  hs_bsy_2nd,

  hs_layer_trig,
  hs_nlayers_hit,
  hs_layer_or,

// DMB
  alct_dmb,
  dmb_tx_reserved,
  dmb_tx,      // Out going to outside: if "BPI Active" then to "BPI Flash PROM Address connector", else to "DMB backplane connector"
  bpi_ad_out,  // In coming from vme:   [22:0] BPI Flash PROM Address
  bpi_active,  // In coming from vme:   BPI Active

// ALCT Status
  alct_cfg_done,

// CSC Orientation Ports
  csc_me1ab,
  stagger_hs_csc,
  reverse_hs_csc,
  reverse_hs_me1a,
  reverse_hs_me1b,

// CLCT VME Configuration
  clct_blanking,
  bxn_offset_pretrig,
  bxn_offset_l1a,
  lhc_cycle,
  l1a_offset,
  drift_delay,
  triad_persist,

  lyr_thresh_pretrig,
  hit_thresh_pretrig,
  pid_thresh_pretrig,
  dmb_thresh_pretrig,
  hit_thresh_postdrift,
  pid_thresh_postdrift,

  clct_flush_delay,
  clct_throttle,
  clct_wr_continuous,

  alct_delay,
  clct_window,

  tmb_allow_alct,
  tmb_allow_clct,
  tmb_allow_match,

  tmb_allow_alct_ro,
  tmb_allow_clct_ro,
  tmb_allow_match_ro,

  mpc_tx_delay,
  mpc_sel_ttc_bx0,
  pretrig_halt,

  uptime,
  bd_status,

  board_id,
  csc_id,
  run_id,

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

  fifo_mode,
  fifo_tbins_cfeb,
  fifo_pretrig_cfeb,

  seq_trigger,
  sequencer_state,
  
  event_clear_vme,
  clct0_vme,
  clct1_vme,
  clctc_vme,
  clctf_vme,
  trig_source_vme,
  nlayers_hit_vme,
  bxn_clct_vme,
  bxn_l1a_vme,

// RPC VME Configuration
  rpc_exists,
  rpc_read_enable,
  fifo_tbins_rpc,
  fifo_pretrig_rpc,

// CCB Status Signals
  clct_status,

// Scintillator Veto
  scint_veto_clr,
  scint_veto,
  scint_veto_vme,

// Front Panel LEDs
  led_lct,
  led_alct,
  led_clct,
  led_l1a_intime,
  led_invpat,
  led_nomatch,
  led_nol1a_flush,

// On Board LEDs
  led_bd,

// Buffer Write Control
  buf_reset,
  buf_push,
  buf_push_adr,
  buf_push_data,

  wr_buf_ready,
  wr_buf_adr,

// Fence buffer adr and data at head of queue
  buf_queue_adr,
  buf_queue_data,

// Buffer Read Control
  buf_pop,
  buf_pop_adr,

// Buffer Status
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

// CFEB Sequencer Readout Control
  rd_start_cfeb,
  rd_abort_cfeb,
  rd_list_cfeb,
  rd_ncfebs,
  rd_fifo_adr,

// CFEB Blockedbits Readout Control
  rd_start_bcb,
  rd_abort_bcb,
  rd_list_bcb,
  rd_ncfebs_bcb,

// RPC Sequencer Readout Control
  rd_start_rpc,
  rd_abort_rpc,
  rd_list_rpc,
  rd_nrpcs,
  rd_rpc_offset,
  clct_pretrig,

// CFEB Sequencer Frame
  cfeb_first_frame,
  cfeb_last_frame,
  cfeb_adr,
  cfeb_tbin,
  cfeb_rawhits,
  cfeb_fifo_busy,

// CFEB Blockedbits Frame
  bcb_read_enable,
  bcb_first_frame,
  bcb_last_frame,
  bcb_blkbits,
  bcb_cfeb_adr,
  bcb_fifo_busy,

// RPC Sequencer Frame
  rpc_first_frame,
  rpc_last_frame,
  rpc_adr,
  rpc_tbinbxn,
  rpc_rawhits,
  rpc_fifo_busy,

// CLCT Raw Hits RAM
  dmb_wr,
  dmb_reset,
  dmb_adr,
  dmb_wdata,
  dmb_rdata,
  dmb_wdcnt,
  dmb_busy,

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

// TMB LCT Match
  clct0_xtmb,
  clct1_xtmb,
  clctc_xtmb,
  clctf_xtmb,
  bx0_xmpc,
  bx0_match,

  tmb_trig_pulse,
  tmb_trig_keep,
  tmb_non_trig_keep,
  tmb_alct_only,
  tmb_clct_only,
  tmb_match,
  tmb_match_win,
  tmb_match_pri,
  tmb_alct_discard,
  tmb_clct_discard,
  tmb_clct0_discard,
  tmb_clct1_discard,
  tmb_aff_list,

  tmb_alct_only_ro,
  tmb_clct_only_ro,
  tmb_match_ro,

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

// TMB Status
  alct0_vpf_tprt,
  alct1_vpf_tprt,
  clct_vpf_tprt,
  clct_window_tprt,

// Firmware Version
  revcode,

// RPC/ALCT Scope
  scp_rpc0_bxn,
  scp_rpc1_bxn,
  scp_rpc0_nhits,
  scp_rpc1_nhits,
  scp_alct_rx,

// Scope
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

// Miniscope
  mini_read_enable,
  mini_fifo_busy,
  mini_first_frame,
  mini_last_frame,
  mini_rdata,
  fifo_wdata_mini,
  wr_mini_offset,

// Mini Sequencer Readout Control
  rd_start_mini,
  rd_abort_mini,
  rd_mini_offset,

// Trigger/Readout Counter Ports
  cnt_all_reset,
  cnt_stop_on_ovf,
  cnt_non_me1ab_en,
  cnt_any_ovf_seq,
  cnt_any_ovf_alct,

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
  event_counter55,
  event_counter56,
  event_counter57,
  event_counter58,
  event_counter59,
  event_counter60,
  event_counter61,
  event_counter62,
  event_counter63,
  event_counter64,
  event_counter65,

// Event Counter Ports
  hdr_clear_on_resync,
  pretrig_counter,
  clct_counter,
  alct_counter,
  trig_counter,
  l1a_rx_counter,
  readout_counter,
  orbit_counter,

// CLCT pre-trigger coincidence counters
  preClct_l1a_counter,  // CLCT pre-trigger AND L1A  coincidence counter
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

// Parity Errors
  perr_pulse,
  perr_cfeb_ff,
  perr_rpc_ff,
  perr_mini_ff,
  perr_ff,

// VME debug register latches
  deb_wr_buf_adr,
  deb_buf_push_adr,
  deb_buf_pop_adr,
  deb_buf_push_data,
  deb_buf_pop_data,

// Sump
  sequencer_sump

// Debug
`ifdef DEBUG_SEQUENCER
  ,clct_sm_dsp
  ,read_sm_dsp
  ,cb_sm_dsp

  ,clct0_valid
  ,clct1_valid
  ,clct0_vpf
  ,clct1_vpf

  ,clct0
  ,clct1
  ,clcta
  ,clctc
  ,clctf

  ,bxn_counter

  ,wr_buf_avail
  ,clct_pretrig_rqst
  ,r_has_buf
  ,r_has_hdr
  ,l1a_type
  ,readout_type
  ,l1a_match_win
  ,l1a_cnt_win
  ,l1a_bxn_win
  ,l1a_push_me
  ,l1a_keep
  ,l1a_window_open
  ,l1a_pulse
  ,l1a_match
  ,l1a_notmb
  ,tmb_nol1a

  ,l1a_wdata
  ,l1a_wdata_notmb
  ,l1a_rdata
  ,wr_avail_xl1a
  
  ,discard_tmbreject
  ,tmb_trig_write

  ,wr_en_xpre
  ,wr_en_xpre1
  ,wr_en_xtmb
  ,wr_en_rtmb
  ,wr_en_rtmb1
  ,wr_en_xmpc
  ,wr_en_rmpc

  ,alct_preClct_window

  ,pretrig_data
  ,postdrift_data
  ,postdrift_adr
  
  ,clct_push_xtmb
  ,bxn_counter_xtmb

  ,active_feb_flag
  ,startup_done
  ,sm_reset
  
  ,deb_dmb_tx
  ,deb_dmb_nwr

  ,clct_pop_xtmb
  ,clct_wr_adr_xtmb
  ,clct_wr_avail_xtmb

  ,l1a_delay_wadr  
  ,l1a_delay_radr
  ,l1a_delay_adj
`endif
  );
//------------------------------------------------------------------------------------------------------------------
// Constants:
//------------------------------------------------------------------------------------------------------------------
  parameter MXCFEB       = 7;           // Number CFEBs
  parameter MXCFEBB      = 3;           // Number CFEB ID bits
  parameter MXLY         = 6;           // Number Layers in CSC
  parameter MXDS         = 8;           // Number of DiStrips per layer
  parameter MXHS         = 32;          // Number 1/2-Strips per layer
  parameter MXHSX        = MXCFEB*MXHS; // Number of 1/2-Strips per layer on 7 CFEBs
  parameter MXKEY        = MXHS;        // Number Key 1/2-strips
  parameter MXKEYB       = 5;           // Number Key bits
  parameter MXKEYX       = MXHSX;       // Number of key 1/2-strips on 7 CFEBs
  parameter MXKEYBX      = 8;           // Number of 1/2-strip key bits on 7 CFEBs

  parameter MXPIDB       = 4;           // Pattern ID bits
  parameter MXHITB       = 3;           // Hits on pattern bits
  parameter MXPATB       = 3+4;         // Pattern bits

  parameter MXBDID       = 5;          // Number TMB Board ID bits
  parameter MXCSC        = 4;          // Number CSC Chamber ID bits
  parameter MXRID        = 4;          // Number Run ID bits
  parameter LCT_TYPE     = 1;          // Set to 1 for Cathode, 0 for Anode
//  parameter LHC_CYCLE    = 3564;       // Highest LHC bxn
//  parameter LHC_CYCLE    = 924;        // Highest LHC bxn for CERN beam test
  parameter MXDMB        = 49;         // Number DMB output bits, not including hardware dmb clock
  parameter NSTARTUP     = 6;          // Number clocks to stay in starup state
  parameter MXDRIFT      = 2;          // Number drift delay bits
  parameter MXBXN        = 12;         // Number BXN bits, LHC bunchs numbered 0 to 3563
  parameter NFCBITS      = 11;         // Number bits for frame counter
  parameter MXEXTDLY     = 4;          // Number bits CLCT external trigger delay
  parameter MXMPCPIPE    = 16;         // Number clocks to delay mpc response
  parameter MXMPCDLY     = 4;          // MPC delay time bits

  parameter MXL1A        = 4;          // Number L1A counter bits
  parameter MXL1DELAY    = 8;          // Number L1Acc delay counter bits
  parameter MXL1WIND     = 4;          // Number L1ACC window width bits
  parameter L1ADLYOFFSET = 7;          // Correction to programmed n L1A delay so status window is n after pretrig
  
  parameter MXBUF        = 16;        // Number of buffers
  parameter MXBUFB       = 4;         // Buffer address width 
  parameter MXFMODE      = 3;         // Number FIFO Mode bits
  parameter MXTBIN       = 5;         // Number FIFO time bin bits
  parameter MXFIFO       = 8;         // FIFO Slice data width

  parameter MXHW         = 19;        // Number bits in a header frame
  parameter MXHD         = 42;        // Number DMB header words, must be even, and a multiple of 4, minus 2 (for e0b and e0c)
  parameter MNHD         = 8;         // Number DMB header words for no-buffer events
  parameter NHBITS       = 6;         // Number bits needed for header count

  parameter MXTLR        = 5;         // Number Trailer words
  parameter NTBITS       = 3;         // Number bits needed for trailer count

  parameter MXFLUSH      = 4;         // Number bits needed for flush counter
  parameter MXTHROTTLE   = 8;         // Number bits needed for throttle counter

// Raw hits RAM parameters
  parameter RAM_DEPTH    = 2048;      // Storage bx depth
  parameter RAM_ADRB     = 11;        // Address width=log2(ram_depth)
  parameter RAM_WIDTH    = 8;         // Data width

// Raw hits buffer parameters
  parameter MXBADR       = RAM_ADRB;  // Header buffer data address bits
  parameter MXBDATA      = 32;        // Pushed data width
  parameter MXSTAT       = 2;         // Buffer status bits

// VME raw hits storage
  parameter MXRAMADR     = 12;        // Number VME Raw Hits RAM address bits
  parameter MXRAMDATA    = 18;        // Number VME Raw Hits RAM data bits, does not include fifo wren

// CLCT arrays
  parameter MXALCT       = 16;        // Number bits per ALCT word
  parameter MXCLCT       = 16;        // Number bits per CLCT word
  parameter MXCLCTA      = 7;         // Number bits per CLCT auxiliary data word
  parameter MXCLCTC      = 3;         // Number bits per CLCT common data word
  parameter MXMPCRX      = 2;         // Number bits from MPC
  parameter MXMPCTX      = 32;        // Number bits sent to MPC
  parameter MPCTIME      = 3;         // Number clocks to wait for MPC response
  parameter MXFRAME      = 16;        // Number bits per muon frame

// RPC Constants
  parameter MXRPC        = 2;         // Number RPCs
  parameter MXRPCB       = 1;         // Number RPC ID bits

// Counters
  parameter MXCNTVME     = 30;        // VME counter length
  parameter MXL1ARX      = 12;        // Number L1As received counter bits
  parameter MXORBIT      = 30;        // Number orbit counter bits

//------------------------------------------------------------------------------------------------------------------
// I/O Ports:
//------------------------------------------------------------------------------------------------------------------
// CCB
  input          clock;               // 40MHz TMB main clock
  input          global_reset;        // 1=Reset everything
  input          clock_lock_lost_err; // 40MHz main clock lost lock FF
  input          ccb_l1accept;        // Level 1 Accept
  input          ccb_evcntres;        // Event counter (L1A) reset command
  input          ttc_bx0;             // Bunch crossing 0 flag
  input          ttc_resync;          // Purge l1a processing stack
  input          ttc_bxreset;         // Reset bxn
  input          ttc_orbit_reset;     // Reset orbit counter
  input          fmm_trig_stop;       // Stop clct trigger sequencer
  input          sync_err;            // Sync error OR of enabled types of error
  output         clct_bx0_sync_err;   // TMB clock pulse count err bxn!=0+offset at ttc_bx0 arrival

// ALCT
  input          alct_active_feb; // ALCT Pattern pre-trigger (faster than alct_1st_valid)
  input          alct0_valid;     // ALCT has valid LCT
  input          alct1_valid;     // ALCT has valid LCT
  output         read_sm_xdmb;    // TMB sequencer starting a readout

// External Triggers
  input          alct_adb_pulse_sync; // ADB Test pulse trigger
  input          dmb_ext_trig;        // DMB Calibration trigger
  input          clct_ext_trig;       // CLCT External trigger from CCB
  input          alct_ext_trig;       // ALCT External trigger from CCB
  input          vme_ext_trig;        // External trigger from VME
  input          ext_trig_inject;     // Changes clct_ext_trig to fire pattern injector

// External Trigger Enables
  input              clct_pat_trig_en;    // Allow CLCT Pattern triggers
  input              alct_pat_trig_en;    // Allow ALCT Pattern trigger
  input              alct_match_trig_en;  // Allow ALCT*CLCT Pattern trigger
  input              adb_ext_trig_en;     // Allow ADB Test pulse trigger
  input              dmb_ext_trig_en;     // Allow DMB Calibration trigger
  input              clct_ext_trig_en;    // Allow CLCT External trigger from CCB
  input              alct_ext_trig_en;    // Allow ALCT External trigger from CCB
  input              layer_trig_en;       // Allow layer-wide triggering
  input              all_cfebs_active;    // Make all CFEBs active when triggered
  input [MXCFEB-1:0] cfeb_en;             // 1=Enable this CFEB for triggering + sending active feb flag
  input              active_feb_src;      // Active cfeb flag source, 0=pretrig, 1=tmb-matching ~8bx later

  input [3:0]        alct_preClct_width;  // ALCT (alct_active_feb flag) window width for ALCT*preCLCT overlap
  input              wr_buf_required;     // Require wr_buffer to pretrigger
  input              wr_buf_autoclr_en;   // Enable frozen buffer auto clear
  input              valid_clct_required; // Require valid pattern after drift to trigger

  input sync_err_stops_pretrig; // Sync error stops CLCT pre-triggers
  input sync_err_stops_readout; // Sync error stops L1A readouts

// External Trigger Delays
  input  [MXEXTDLY-1:0]  alct_preClct_dly;  // ALCT (alct_active_feb flag) delay for ALCT*preCLCT overlap
  input  [MXEXTDLY-1:0]  alct_pat_trig_dly; // ALCT (alct0_valid flag) pattern trigger delay
  input  [MXEXTDLY-1:0]  adb_ext_trig_dly;  // ADB  external trigger delay
  input  [MXEXTDLY-1:0]  dmb_ext_trig_dly;  // DMB  external trigger delay
  input  [MXEXTDLY-1:0]  clct_ext_trig_dly; // CLCT external trigger delay
  input  [MXEXTDLY-1:0]  alct_ext_trig_dly; // ALCT external trigger delay

// pre-CLCT modifiers for L1A*preCLCT overlap
  input [3:0] l1a_preClct_width; // pre-CLCT window width for L1A*preCLCT overlap
  input [7:0] l1a_preClct_dly;   // pre-CLCT delay for L1A*preCLCT overlap

// CLCT/RPC/RAT Pattern Injector
  input               inj_trig_vme;       // Start pattern injector
  input  [MXCFEB-1:0] injector_mask_cfeb; // Enable CFEB(n) for injector trigger
  input               injector_mask_rat;  // Enable RAT for injector trigger
  input               injector_mask_rpc;  // Enable RPC for injector trigger
  input  [3:0]        inj_delay_rat;      // CFEB/RPC Injector waits for RAT injector
  output [MXCFEB-1:0] injector_go_cfeb;   // Start CFEB(n) pattern injector
  output              injector_go_rat;    // Start RAT     pattern injector
  output              injector_go_rpc;    // Start RPC     pattern injector

// CFEB Status Ports
  input [MXCFEB-1:0] triad_skip;           // Triads skipped
  input [MXCFEB-1:0] triad_tp;             // Triad test point at input to raw hits RAM
  input [MXCFEB-1:0] cfeb_badbits_found;   // CFEB[n] has at least 1 bad bit
  input              cfeb_badbits_blocked; // A CFEB had bad bits that were blocked
  
// Pattern Finder PreTrigger Ports
  input  [MXCFEB-1:0]  cfeb_hit;        // This CFEB has a pattern over pre-trigger threshold
  input  [MXCFEB-1:0]  cfeb_active;     // CFEBs marked for DMB readout

  input          cfeb_layer_trig;    // Layer pretrigger
  input  [MXLY-1:0]    cfeb_layer_or;      // OR of hstrips on each layer at pre-trigger
  input  [MXHITB-1:0]  cfeb_nlayers_hit;    // Number of CSC layers hit
  
// Pattern Finder CLCT results
  input  [MXHITB-1:0]  hs_hit_1st;        // 1st CLCT pattern hits
  input  [MXPIDB-1:0]  hs_pid_1st;        // 1st CLCT pattern ID
  input  [MXKEYBX-1:0]  hs_key_1st;        // 1st CLCT key 1/2-strip

  input  [MXHITB-1:0]  hs_hit_2nd;        // 2nd CLCT pattern hits
  input  [MXPIDB-1:0]  hs_pid_2nd;        // 2nd CLCT pattern ID
  input  [MXKEYBX-1:0]  hs_key_2nd;        // 2nd CLCT key 1/2-strip
  input          hs_bsy_2nd;        // 2nd CLCT busy, logic error indicator

  input          hs_layer_trig;      // Layer triggered
  input  [MXHITB-1:0]  hs_nlayers_hit;      // Number of layers hit
  input  [MXLY-1:0]    hs_layer_or;      // Layer ORs at pattern finder output

// DMB Ports
  input  [18:0]      alct_dmb;        // ALCT to DMB
  input  [2:0]       dmb_tx_reserved; // DMB backplane reserved
  output [MXDMB-1:0] dmb_tx;          // going to outside: if "BPI Active" then to "BPI Flash PROM Address connector", else to "DMB backplane connector"
  input  [22:0]      bpi_ad_out;      // coming from vme:  [22:0] BPI Flash PROM Address
  input              bpi_active;      // coming from vme:  BPI Active

// ALCT Status
  input          alct_cfg_done;      // ALCT FPGA configuration done

// CSC Orientation Ports
  input          csc_me1ab;        // 1=ME1A or ME1B CSC type
  input          stagger_hs_csc;      // 1=Staggered CSC non-me1, 0=non-staggered me1
  input          reverse_hs_csc;      // 1=Reverse staggered CSC, non-me1
  input          reverse_hs_me1a;    // 1=reverse me1a hstrips prior to pattern sorting
  input          reverse_hs_me1b;    // 1=reverse me1b hstrips prior to pattern sorting

// CLCT VME Configuration Ports
  input          clct_blanking;      // Clct_blanking=1 clears clcts with 0 hits
  input  [MXBXN-1:0]    bxn_offset_pretrig;    // BXN offset at reset for pretrig
  input  [MXBXN-1:0]    bxn_offset_l1a;      // BXN offset at reset for L1A
  input  [MXBXN-1:0]    lhc_cycle;        // LHC period, max BXN count+1
  input  [MXL1ARX-1:0]  l1a_offset;        // L1A counter preset value
  input  [MXDRIFT-1:0]  drift_delay;      // CSC Drift delay clocks
  input  [3:0]      triad_persist;      // Triad 1/2-strip persistence

  input  [MXHITB-1:0]  lyr_thresh_pretrig;    // Layers hit pre-trigger threshold
  input  [MXHITB-1:0]  hit_thresh_pretrig;    // Hits on pattern template pre-trigger threshold
  input  [MXPIDB-1:0]  pid_thresh_pretrig;    // Pattern shape ID pre-trigger threshold
  input  [MXHITB-1:0]  dmb_thresh_pretrig;    // Hits on pattern template DMB active-feb threshold
  input  [MXHITB-1:0]  hit_thresh_postdrift;  // Minimum pattern hits for a valid pattern
  input  [MXPIDB-1:0]  pid_thresh_postdrift;  // Minimum pattern ID   for a valid pattern

  input [MXTHROTTLE-1:0] clct_throttle;      // Pre-trigger throttle to reduce trigger rate
  input [MXFLUSH-1:0]    clct_flush_delay;   // Pre-trigger sequencer flush state timer
  input                  clct_wr_continuous; // 1=allow continuous header buffer writing for invalid triggers

  input  [3:0] alct_delay;  // Delay ALCT for CLCT match window
  input  [3:0] clct_window; // CLCT match window width

  input tmb_allow_alct;  // Allow ALCT only 
  input tmb_allow_clct;  // Allow CLCT only
  input tmb_allow_match; // Allow Match only

  input tmb_allow_alct_ro;  // Allow ALCT only  readout, non-triggering
  input tmb_allow_clct_ro;  // Allow CLCT only  readout, non-triggering
  input tmb_allow_match_ro; // Allow Match only readout, non-triggering

  input  [MXMPCDLY-1:0] mpc_tx_delay;    // Delay LCT to MPC
  input                 mpc_sel_ttc_bx0; // MPC gets ttc_bx0 or bx0_local
  input                 pretrig_halt;    // Pretrigger and halt until unhalt arrives

  output [15:0] uptime;    // Uptime since last hard reset
  input  [14:0] bd_status; // Board status summary

  input  [MXBDID-1:0] board_id; // Board ID hex switch
  input  [MXCSC-1:0]  csc_id;   // CSC Chamber ID number
  input  [MXRID-1:0]  run_id;   // Run ID

  input  [MXL1DELAY-1:0] l1a_delay;        // Level1 Accept delay from pretrig status output
  input                  l1a_internal;     // Generate internal Level 1, overrides external
  input  [MXL1WIND-1:0]  l1a_internal_dly; // Delay internal l1a to shift position in l1a match window
  input  [MXL1WIND-1:0]  l1a_window;       // Level1 Accept window width after delay
  input                  l1a_win_pri_en;   // Enable L1A window priority
  input  [MXBADR-1:0]    l1a_lookback;     // Bxn to look back from l1a wr_buf_adr
  input                  l1a_preset_sr;    // Dummy VME bit to feign preset l1a sr group

  input                  l1a_allow_match;     // Readout allows tmb trig pulse in L1A window (normal mode)
  input                  l1a_allow_notmb;     // Readout allows no tmb trig pulse in L1A window
  input                  l1a_allow_nol1a;     // Readout allows tmb trig pulse outside L1A window
  input                  l1a_allow_alct_only; // Allow alct_only events to readout at L1A

  input  [MXFMODE-1:0] fifo_mode;         // FIFO Mode 0=no dump w/header,1=full,2=local,3=no dump short header
  input  [MXTBIN-1:0]  fifo_tbins_cfeb;   // Number CFEB FIFO time bins to read out
  input  [MXTBIN-1:0]  fifo_pretrig_cfeb; // Number CFEB FIFO time bins before pretrigger

  output        seq_trigger;     // Sequencer requests L1A from CCB
  output [11:0] sequencer_state; // Sequencer state for vme read

  input          event_clear_vme;  // Event clear for aff,alct,clct,mpc vme diagnostic registers
  output  [MXCLCT-1:0]  clct0_vme;      // First  CLCT
  output  [MXCLCT-1:0]  clct1_vme;      // Second CLCT
  output  [MXCLCTC-1:0]  clctc_vme;      // Common to CLCT0/1 to TMB
  output  [MXCFEB-1:0]  clctf_vme;      // Active cfeb list at TMB match
  output  [10:0]      trig_source_vme;  // Trigger source vector for VME readback
  output  [2:0]      nlayers_hit_vme;  // Number layers hit on layer trigger
  output  [MXBXN-1:0]    bxn_clct_vme;    // CLCT BXN at pre-trigger
  output  [MXBXN-1:0]    bxn_l1a_vme;    // CLCT BXN at L1A

// RPC VME Configuration Ports
  input  [MXRPC-1:0]    rpc_exists;      // RPC Readout list
  input          rpc_read_enable;  // 1 Enable RPC Readout
  input  [MXTBIN-1:0]  fifo_tbins_rpc;    // Number RPC FIFO time bins to read out
  input  [MXTBIN-1:0]  fifo_pretrig_rpc;  // Number RPC FIFO time bins before pretrigger

// Status signals to CCB front panel
  output  [8:0]      clct_status;    // Array of stat_ signals for CCB

// Scintillator Veto
  input          scint_veto_clr;    // Clear scintillator veto ff
  output          scint_veto;      // Scintillator veto for FAST Sites
  output          scint_veto_vme;    // Scintillator veto for FAST Sites

// Front Panel CLCT LEDs:
  output          led_lct;      // LCT    Blue  CLCT + ALCT match
  output          led_alct;      // ALCT    Green  ALCT valid pattern
  output          led_clct;      // CLCT    Green  CLCT valid pattern
  output          led_l1a_intime;    // L1A    Green  Level 1 Accept from CCB or internal
  output          led_invpat;      // INVP    Amber  Invalid pattern after drift delay
  output          led_nomatch;    // NMAT    Amber  CLCT or ALCT but no match
  output          led_nol1a_flush;  // NL1A    Red    L1A did not arrive in window

// On Board LEDs
  output  [7:0]      led_bd;        // On-Board LEDs

// Buffer Write Control
  output          buf_reset;      // Free all buffer space
  output          buf_push;      // Allocate write buffer
  output  [MXBADR-1:0]  buf_push_adr;    // Address of write buffer to allocate  
  output  [MXBDATA-1:0]  buf_push_data;    // Data associated with push_adr

  input          wr_buf_ready;    // Write buffer is ready
  input  [MXBADR-1:0]  wr_buf_adr;      // Current address of header write buffer

// Fence buffer adr and data at head of queue
  input  [MXBADR-1:0]  buf_queue_adr;    // Address of fence queued for readout
  input  [MXBDATA-1:0]  buf_queue_data;    // Data associated with queue adr

// Buffer Read Control
  output          buf_pop;      // Specified buffer is to be released
  output  [MXBADR-1:0]  buf_pop_adr;    // Address of read buffer to release

// FIFO Controller Buffer Status
  input          buf_q_full;      // All raw hits ram in use, ram writing must stop
  input          buf_q_empty;    // No fences remain on buffer stack
  input          buf_q_ovf_err;    // Tried to push when stack full
  input          buf_q_udf_err;    // Tried to pop when stack empty
  input          buf_q_adr_err;    // Fence adr popped from stack doesnt match rls adr
  input          buf_stalled;    // Buffer write pointer hit a fence and is stalled now
  input          buf_stalled_once;  // Buffer stalled at least once since last resync
  input  [MXBADR-1:0]  buf_fence_dist;    // Distance to 1st fence address
  input  [MXBADR-1+1:0]  buf_fence_cnt;    // Number of fences in fence RAM currently
  input  [MXBADR-1+1:0]  buf_fence_cnt_peak;  // Peak number of fences in fence RAM
  input  [7:0]      buf_display;    // Buffer fraction in use display

// CFEB Sequencer Readout Control
  output          rd_start_cfeb;    // Initiates a FIFO readout
  output          rd_abort_cfeb;    // Abort FIFO dump
  output  [MXCFEB-1:0]   rd_list_cfeb;    // List of CFEBs to read out
  output  [MXCFEBB-1:0]  rd_ncfebs;      // Number of CFEBs in feb_list (4 or 5 depending on CSC type)
  output  [RAM_ADRB-1:0]  rd_fifo_adr;    // RAM address at pre-trig, must be valid 1bx before rd_start

// CFEB Blockedbits Readout Control
  output          rd_start_bcb;    // Start readout sequence
  output          rd_abort_bcb;    // Cancel readout
  output  [MXCFEB-1:0]   rd_list_bcb;    // List of CFEBs to read out
  output  [MXCFEBB-1:0]  rd_ncfebs_bcb;    // Number of CFEBs in bcb_list (0 to 5)

// RPC Sequencer Readout Control
  output                rd_start_rpc;  // Start readout sequence
  output                rd_abort_rpc;  // Cancel readout
  output [MXRPC-1:0]    rd_list_rpc;   // List of RPCs to read out
  output [MXRPCB-1+1:0] rd_nrpcs;      // Number of RPCs in rpc_list (0 or 1-to-2 depending on CSC type)
  output [RAM_ADRB-1:0] rd_rpc_offset; // RAM address rd_fifo_adr offset for rpc read out
  output                clct_pretrig;  // Pre-trigger marker at (clct_sm==pretrig)

// CFEB Sequencer Frame
  input          cfeb_first_frame;  // First frame valid 2bx after rd_start
  input          cfeb_last_frame;  // Last frame valid 1bx after busy goes down
  input  [MXCFEBB-1:0]  cfeb_adr;      // FIFO dump FEB ID
  input  [MXTBIN-1:0]  cfeb_tbin;      // FIFO dump Time Bin #
  input  [7:0]      cfeb_rawhits;    // Layer data from FIFO
  input          cfeb_fifo_busy;    // Readout busy sending data to sequencer, goes down 1bx early

// CFEB Blockedbits Frame
  input          bcb_read_enable;  // Enable blocked bits in readout
  input          bcb_first_frame;  // First frame valid 2bx after rd_start
  input          bcb_last_frame;    // Last frame valid 1bx after busy goes down
  input  [11:0]      bcb_blkbits;    // CFEB blocked bits frame data
  input  [MXCFEBB-1:0]  bcb_cfeb_adr;    // CFEB ID  
  input          bcb_fifo_busy;    // Readout busy sending data to sequencer, goes down 1bx early

// RPC Sequencer Frame
  input          rpc_first_frame;  // First frame valid 2bx after rd_start
  input          rpc_last_frame;    // Last frame valid 1bx after busy goes down
  input  [MXRPCB-1:0]  rpc_adr;      // FIFO dump RPC ID
  input  [MXTBIN-1:0]  rpc_tbinbxn;    // FIFO dump RPC tbin or bxn for DMB
  input  [7:0]      rpc_rawhits;    // FIFO dump RPC pad hits, 8 of 16 per cycle
  input          rpc_fifo_busy;    // Readout busy sending data to sequencer, goes down 1bx early

// CLCT Raw Hits RAM
  input          dmb_wr;        // Raw hits RAM VME write enable
  input          dmb_reset;      // Raw hits RAM VME address reset
  input  [MXRAMADR-1:0]  dmb_adr;      // Raw hits RAM VME read/write address
  input  [MXRAMDATA-1:0]  dmb_wdata;      // Raw hits RAM VME write data
  output  [MXRAMDATA-1:0]  dmb_rdata;      // Raw hits RAM VME read data
  output  [MXRAMADR-1:0]  dmb_wdcnt;      // Raw hits RAM VME word count
  output          dmb_busy;      // Raw hits RAM VME busy writing DMB data

// TMB-Sequencer Pipelines
  output  [MXBADR-1:0]  wr_adr_xtmb;    // Buffer write address after drift time
  input  [MXBADR-1:0]  wr_adr_rtmb;    // Buffer write address at TMB matching time
  input  [MXBADR-1:0]  wr_adr_xmpc;    // Buffer write address at MPC xmit to sequencer
  input  [MXBADR-1:0]  wr_adr_rmpc;    // Buffer write address at MPC received

  output          wr_push_xtmb;    // Buffer write strobe after drift time
  input          wr_push_rtmb;    // Buffer write strobe at TMB matching time
  input          wr_push_xmpc;    // Buffer write strobe at MPC xmit to sequencer
  input          wr_push_rmpc;    // Buffer write strobe at MPC received

  output          wr_avail_xtmb;    // Buffer available after drift time
  input          wr_avail_rtmb;    // Buffer available at TMB matching time
  input          wr_avail_xmpc;    // Buffer available at MPC xmit to sequencer
  input          wr_avail_rmpc;    // Buffer available at MPC received

// TMB LCT Match
  output  [MXCLCT-1:0]  clct0_xtmb;      // 1st CLCT to TMB
  output  [MXCLCT-1:0]  clct1_xtmb;      // 2nd CLCT to TMB
  output  [MXCLCTC-1:0]  clctc_xtmb;      // Common to CLCT0/1 to TMB
  output  [MXCFEB-1:0]  clctf_xtmb;      // Active cfeb list to TMB
  output          bx0_xmpc;      // bx0 to mpc
  input          bx0_match;      // ALCT bx0 and CLCT bx0 match in time

  input          tmb_trig_pulse;    // TMB Triggered on ALCT or CLCT or both
  input          tmb_trig_keep;    // ALCT or CLCT or both triggered, and trigger is allowed
  input          tmb_non_trig_keep;  // Event did not trigger, but keep it for readout
  input          tmb_match;      // ALCT and CLCT matched in time
  input          tmb_alct_only;    // Only ALCT triggered
  input          tmb_clct_only;    // Only CLCT triggered
  input  [3:0]      tmb_match_win;    // Location of alct in clct window
  input  [3:0]      tmb_match_pri;    // Priority of clct in clct window
  input          tmb_alct_discard;  // ALCT pair was not used for LCT
  input          tmb_clct_discard;  // CLCT pair was not used for LCT
  input          tmb_clct0_discard;  // CLCT0 was discarded from ME1A
  input          tmb_clct1_discard;  // CLCT1 was discarded from ME1A
  input  [MXCFEB-1:0]  tmb_aff_list;    // Active CFEBs for CLCT used in TMB match

  input          tmb_match_ro;    // ALCT and CLCT matched in time, non-triggering reaodut
  input          tmb_alct_only_ro;  // Only ALCT triggered, non-triggering reaodut
  input          tmb_clct_only_ro;  // Only CLCT triggered, non-triggering reaodut

  input          tmb_no_alct;    // No  ALCT
  input          tmb_no_clct;    // No  CLCT
  input          tmb_one_alct;    // One ALCT
  input          tmb_one_clct;    // One CLCT
  input          tmb_two_alct;    // Two ALCTs
  input          tmb_two_clct;    // Two CLCTs
  input          tmb_dupe_alct;    // ALCT0 copied into ALCT1 to make 2nd LCT
  input          tmb_dupe_clct;    // CLCT0 copied into CLCT1 to make 2nd LCT
  input          tmb_rank_err;    // LCT1 has higher quality than LCT0

  input  [10:0]      tmb_alct0;      // ALCT best muon latched at trigger
  input  [10:0]      tmb_alct1;      // ALCT second best muon latched at trigger
  input  [4:0]      tmb_alctb;      // ALCT bxn latched at trigger
  input  [1:0]      tmb_alcte;      // ALCT ecc error syndrome latched at trigger

// MPC Status
  input          mpc_frame_ff;    // MPC frame latch strobe
  input  [MXFRAME-1:0]  mpc0_frame0_ff;    // MPC best muon 1st frame
  input  [MXFRAME-1:0]  mpc0_frame1_ff;    // MPC best buon 2nd frame
  input  [MXFRAME-1:0]  mpc1_frame0_ff;    // MPC second best muon 1st frame
  input  [MXFRAME-1:0]  mpc1_frame1_ff;    // MPC second best buon 2nd frame

  input          mpc_xmit_lct0;    // MPC LCT0 sent
  input          mpc_xmit_lct1;    // MPC LCT1 sent

  input          mpc_response_ff;  // MPC accept is ready
  input  [1:0]      mpc_accept_ff;    // MPC muon accept response
  input  [1:0]      mpc_reserved_ff;  // MPC reserved

// TMB Status
  input          alct0_vpf_tprt;    // Timing test point, unbuffered real time for internal scope
  input          alct1_vpf_tprt;    // Timing test point
  input          clct_vpf_tprt;    // Timing test point
  input          clct_window_tprt;  // Timing test point

// Firmware Version
  input  [14:0]      revcode;      // Firmware revision code

// RPC/ALCT Scope
  input  [2:0]      scp_rpc0_bxn;    // RPC0 bunch crossing number
  input  [2:0]      scp_rpc1_bxn;    // RPC1 bunch crossing number
  input  [3:0]      scp_rpc0_nhits;    // RPC0 number of pads hit
  input  [3:0]      scp_rpc1_nhits;    // RPC1 number of pads hit
  input  [55:0]      scp_alct_rx;    // ALCT received signals to scope

// Scope
  input          scp_runstop;    // 1=run 0=stop
  input          scp_auto;      // Sequencer readout mode
  input          scp_ch_trig_en;    // Enable channel triggers
  input  [7:0]      scp_trigger_ch;    // Channel to trigger on, 0-159
  input          scp_force_trig;    // Force a trigger
  input          scp_ch_overlay;    // Channel source overlay
  input  [3:0]      scp_ram_sel;    // RAM bank select in VME mode
  input  [2:0]      scp_tbins;      // Time bins per channel code, actual tbins/ch = (tbins+1)*64
  input  [8:0]      scp_radr;      // Channel data read address
  input          scp_nowrite;    // Preserves initial RAM contents for testing
  output          scp_waiting;    // Waiting for trigger
  output          scp_trig_done;    // Trigger done, ready for readout 
  output  [15:0]      scp_rdata;      // Recorded channel data

// Miniscope
  input                    mini_read_enable; // Enable Miniscope readout
  input                    mini_fifo_busy;   // Readout busy sending data to sequencer, goes down 1bx early
  input                    mini_first_frame; // First frame valid 2bx after rd_start
  input                    mini_last_frame;  // Last frame valid 1bx after busy goes down
  input  [RAM_WIDTH*2-1:0] mini_rdata;       // FIFO dump miniscope
  output [RAM_WIDTH*2-1:0] fifo_wdata_mini;  // Miniscope FIFO RAM write data
  output [RAM_ADRB-1:0]    wr_mini_offset;   // RAM address offset for miniscope write

// Mini Sequencer Readout Control
  output                rd_start_mini;  // Start readout sequence
  output                rd_abort_mini;  // Cancel readout
  output [RAM_ADRB-1:0] rd_mini_offset; // RAM address rd_fifo_adr offset for miniscope read out

// Trigger/Readout Counter Ports
  input  cnt_all_reset;    // Trigger/Readout counter reset
  input  cnt_stop_on_ovf;  // Stop all counters if any overflows
  input  cnt_any_ovf_alct; // At least one alct counter overflowed
  input  cnt_non_me1ab_en; // Allow clct pretrig counters count non me1ab
  output cnt_any_ovf_seq;  // At least one sequencer counter overflowed

  output  [MXCNTVME-1:0]  event_counter13;  // Event counter 1D remap
  output  [MXCNTVME-1:0]  event_counter14;
  output  [MXCNTVME-1:0]  event_counter15;
  output  [MXCNTVME-1:0]  event_counter16;
  output  [MXCNTVME-1:0]  event_counter17;
  output  [MXCNTVME-1:0]  event_counter18;
  output  [MXCNTVME-1:0]  event_counter19;
  output  [MXCNTVME-1:0]  event_counter20;
  output  [MXCNTVME-1:0]  event_counter21;
  output  [MXCNTVME-1:0]  event_counter22;
  output  [MXCNTVME-1:0]  event_counter23;
  output  [MXCNTVME-1:0]  event_counter24;
  output  [MXCNTVME-1:0]  event_counter25;
  output  [MXCNTVME-1:0]  event_counter26;
  output  [MXCNTVME-1:0]  event_counter27;
  output  [MXCNTVME-1:0]  event_counter28;
  output  [MXCNTVME-1:0]  event_counter29;
  output  [MXCNTVME-1:0]  event_counter30;
  output  [MXCNTVME-1:0]  event_counter31;
  output  [MXCNTVME-1:0]  event_counter32;
  output  [MXCNTVME-1:0]  event_counter33;
  output  [MXCNTVME-1:0]  event_counter34;
  output  [MXCNTVME-1:0]  event_counter35;
  output  [MXCNTVME-1:0]  event_counter36;
  output  [MXCNTVME-1:0]  event_counter37;
  output  [MXCNTVME-1:0]  event_counter38;
  output  [MXCNTVME-1:0]  event_counter39;
  output  [MXCNTVME-1:0]  event_counter40;
  output  [MXCNTVME-1:0]  event_counter41;
  output  [MXCNTVME-1:0]  event_counter42;
  output  [MXCNTVME-1:0]  event_counter43;
  output  [MXCNTVME-1:0]  event_counter44;
  output  [MXCNTVME-1:0]  event_counter45;
  output  [MXCNTVME-1:0]  event_counter46;
  output  [MXCNTVME-1:0]  event_counter47;
  output  [MXCNTVME-1:0]  event_counter48;
  output  [MXCNTVME-1:0]  event_counter49;
  output  [MXCNTVME-1:0]  event_counter50;
  output  [MXCNTVME-1:0]  event_counter51;
  output  [MXCNTVME-1:0]  event_counter52;
  output  [MXCNTVME-1:0]  event_counter53;
  output  [MXCNTVME-1:0]  event_counter54;
  output  [MXCNTVME-1:0]  event_counter55;
  output  [MXCNTVME-1:0]  event_counter56;
  output  [MXCNTVME-1:0]  event_counter57;
  output  [MXCNTVME-1:0]  event_counter58;
  output  [MXCNTVME-1:0]  event_counter59;
  output  [MXCNTVME-1:0]  event_counter60;
  output  [MXCNTVME-1:0]  event_counter61;
  output  [MXCNTVME-1:0]  event_counter62;
  output  [MXCNTVME-1:0]  event_counter63;
  output  [MXCNTVME-1:0]  event_counter64;
  output  [MXCNTVME-1:0]  event_counter65;

// Event Counter Ports
  input                   hdr_clear_on_resync; // Clear header counters on ttc_resync
  output  [MXCNTVME-1:0]  pretrig_counter;     // Pre-trigger counter
  output  [MXCNTVME-1:0]  clct_counter;        // CLCT counter
  output  [MXCNTVME-1:0]  alct_counter;        // ALCTs received counter
  output  [MXCNTVME-1:0]  trig_counter;        // TMB trigger counter
  output  [MXL1ARX-1:0]   l1a_rx_counter;      // L1As received from ccb counter
  output  [MXL1ARX-1:0]   readout_counter;     // Readout counter
  output  [MXORBIT-1:0]   orbit_counter;       // Orbit counter

// CLCT pre-trigger coincidence counters
  output  [MXCNTVME-1:0]  preClct_l1a_counter;  // CLCT pre-trigger AND L1A coincidence counter
  output  [MXCNTVME-1:0]  preClct_alct_counter; // CLCT pre-trigger AND ALCT coincidence counter

// Active CFEB(s) counters
  output  [MXCNTVME-1:0] active_cfebs_event_counter;      // Any CFEB active flag sent to DMB
  output  [MXCNTVME-1:0] active_cfebs_me1a_event_counter; // ME1a CFEB active flag sent to DMB
  output  [MXCNTVME-1:0] active_cfebs_me1b_event_counter; // ME1b CFEB active flag sent to DMB
  output  [MXCNTVME-1:0] active_cfeb0_event_counter;      // CFEB0 active flag sent to DMB
  output  [MXCNTVME-1:0] active_cfeb1_event_counter;      // CFEB1 active flag sent to DMB
  output  [MXCNTVME-1:0] active_cfeb2_event_counter;      // CFEB2 active flag sent to DMB
  output  [MXCNTVME-1:0] active_cfeb3_event_counter;      // CFEB3 active flag sent to DMB
  output  [MXCNTVME-1:0] active_cfeb4_event_counter;      // CFEB4 active flag sent to DMB
  output  [MXCNTVME-1:0] active_cfeb5_event_counter;      // CFEB5 active flag sent to DMB
  output  [MXCNTVME-1:0] active_cfeb6_event_counter;      // CFEB6 active flag sent to DMB

// Parity Errors
  input                perr_pulse;   // Parity error pulse for counting
  input  [MXCFEB-1:0]  perr_cfeb_ff; // CFEB RAM parity error, latched
  input                perr_rpc_ff;  // RPC  RAM parity error, latched
  input                perr_mini_ff; // Mini RAM parity error, latched
  input                perr_ff;      // Parity error summary,  latched

// VME debug register latches
  output  [MXBADR-1:0]  deb_wr_buf_adr;      // Buffer write address at last pretrig
  output  [MXBADR-1:0]  deb_buf_push_adr;    // Queue push address at last push
  output  [MXBADR-1:0]  deb_buf_pop_adr;    // Queue pop  address at last pop
  output  [MXBDATA-1:0]  deb_buf_push_data;    // Queue push data at last push
  output  [MXBDATA-1:0]  deb_buf_pop_data;    // Queue pop  data at last pop

// Sump
  output          sequencer_sump;      // Unused signals

// Debug
`ifdef DEBUG_SEQUENCER
  output  [63:0]      clct_sm_dsp;      // CLCT Processing State Machine ascii state names
  output  [63:0]      read_sm_dsp;      // Readout Processing State Machine ascii state names
  output  [79:0]      cb_sm_dsp;        // Clear-buffer state machine ascii state names

  output          clct0_valid;
  output          clct1_valid;
  output          clct0_vpf;
  output          clct1_vpf;

  output  [MXCLCT-1:0]  clct0;
  output  [MXCLCT-1:0]  clct1;
  output  [MXCLCTA-1:0]  clcta;
  output  [MXCLCTC-1:0]  clctc;
  output  [MXCFEB-1:0]  clctf;

  output  [MXBXN-1:0]    bxn_counter;

  output       wr_buf_avail;
  output       clct_pretrig_rqst;
  output       r_has_buf;
  output       r_has_hdr;
  output [1:0] l1a_type;
  output [1:0] readout_type;          

  output  [MXL1WIND-1:0]  l1a_match_win;
  output  [MXL1ARX-1:0]  l1a_cnt_win;
  output  [MXBXN-1:0]    l1a_bxn_win;
  output          l1a_push_me;
  output          l1a_keep;
  output          l1a_window_open;
  output          l1a_pulse;
  output          l1a_match;
  output          l1a_notmb;
  output          tmb_nol1a;

  output  [32-1:0]    l1a_wdata;
  output  [32-1:0]    l1a_wdata_notmb;
  output  [32-1:0]    l1a_rdata;
  output          wr_avail_xl1a;  

  output           discard_tmbreject;
  output          tmb_trig_write;
  
  output          wr_en_xpre;
  output          wr_en_xpre1;
  output          wr_en_xtmb;
  output          wr_en_rtmb;
  output          wr_en_rtmb1;
  output          wr_en_xmpc;
  output          wr_en_rmpc;

  output          alct_preClct_window;
  output  [21-1:0]    pretrig_data;
  output  [21-1:0]    postdrift_data;
  output  [3:0]      postdrift_adr;
  
  output          clct_push_xtmb;
  output  [1:0]      bxn_counter_xtmb;
  
  output          active_feb_flag;
  output          startup_done;
  output          sm_reset;
  
  output   [15:0]      deb_dmb_tx;
  output              deb_dmb_nwr;

  output          clct_pop_xtmb;
  output  [MXBADR-1:0]  clct_wr_adr_xtmb;
  output          clct_wr_avail_xtmb;

  output  [7:0]      l1a_delay_wadr;  
  output  [7:0]      l1a_delay_radr;
  output  [7:0]      l1a_delay_adj;
`endif

//------------------------------------------------------------------------------------------------------------------
// Local:
//------------------------------------------------------------------------------------------------------------------
  wire alct_preClct; // ALCT*CLCT pre-trigger coincidence

  wire clct0_vpf;
  wire clct1_vpf;

  wire wr_en_rtmb;
  wire tmb_nol1a;
  wire no_daq;

  wire l1a_match;
  wire l1a_notmb;  
  wire l1a_received;
  wire l1a_forced;

// Header parallel shifter
  wire  [MXHW-1:0]    header00_;
  wire  [MXHW-1:0]    header01_;
  wire  [MXHW-1:0]    header02_;
  wire  [MXHW-1:0]    header03_;
  wire  [MXHW-1:0]    header04_;
  wire  [MXHW-1:0]    header05_;
  wire  [MXHW-1:0]    header06_;
  wire  [MXHW-1:0]    header07_;
  wire  [MXHW-1:0]    header08_;
  wire  [MXHW-1:0]    header09_;
  wire  [MXHW-1:0]    header10_;
  wire  [MXHW-1:0]    header11_;
  wire  [MXHW-1:0]    header12_;
  wire  [MXHW-1:0]    header13_;
  wire  [MXHW-1:0]    header14_;
  wire  [MXHW-1:0]    header15_;
  wire  [MXHW-1:0]    header16_;
  wire  [MXHW-1:0]    header17_;
  wire  [MXHW-1:0]    header18_;
  wire  [MXHW-1:0]    header19_;
  wire  [MXHW-1:0]    header20_;
  wire  [MXHW-1:0]    header21_;
  wire  [MXHW-1:0]    header22_;
  wire  [MXHW-1:0]    header23_;
  wire  [MXHW-1:0]    header24_;
  wire  [MXHW-1:0]    header25_;
  wire  [MXHW-1:0]    header26_;
  wire  [MXHW-1:0]    header27_;
  wire  [MXHW-1:0]    header28_;
  wire  [MXHW-1:0]    header29_;
  wire  [MXHW-1:0]    header30_;
  wire  [MXHW-1:0]    header31_;
  wire  [MXHW-1:0]    header32_;
  wire  [MXHW-1:0]    header33_;
  wire  [MXHW-1:0]    header34_;
  wire  [MXHW-1:0]    header35_;
  wire  [MXHW-1:0]    header36_;
  wire  [MXHW-1:0]    header37_;
  wire  [MXHW-1:0]    header38_;
  wire  [MXHW-1:0]    header39_;
  wire  [MXHW-1:0]    header40_;
  wire  [MXHW-1:0]    header41_;

// Front Panel LED FFs
  reg            led_lct_ff         = 0;
  reg            led_alct_ff        = 0;
  reg            led_clct_ff        = 0;
  reg            led_l1a_intime_ff  = 0;
  reg            led_invpat_ff      = 0;
  reg            led_nol1a_flush_ff = 0;
  reg            led_nomatch_ff     = 0;

// On Board LED FFs
  reg            led_hold=0;

// FIFO related
  wire          fifo_read_done;
  reg    [MXCFEB-1:0]  cfebs_read;
  reg            xpop_done=0;

// Blockedbits related
  wire          bcb_fifo_done;
  
// RPC related
  wire          rpc_fifo_done;
  reg            rpcs_all_empty=0;

// DMB Related
  reg    [MXHW-1:0]    dmb_ff=0;

// Scope related
  wire scp_read_done;

// Miniscope related
  wire          mini_fifo_done;

// Dump RAM image
  reg    [MXRAMDATA-1:0]  seq_wdata=0;

// CLCT Sequencer State Declarations
  reg [5:0] clct_sm;      // synthesis attribute safe_implementation of clct_sm is "yes";
  reg [2:0] clct_sm_vec;

  parameter startup  =  0;  // Startup waiting for initial debris to clear
  parameter idle    =  1;  // Idling, waiting for pretrig
  parameter pretrig  =  2;  // Pretriggered, pushed event into pretrigger pipeline
  parameter throttle  =  3;  // Reduce trigger rate
  parameter flush    =  4;  // Flushing event, throttling trigger rate
  parameter halt    =  5;  // Halted, waiting for un-halt from VME

// Readout State Declarations
  reg  [23:0] read_sm;      // synthesis attribute safe_implementation of read_sm is "yes";
  reg [4:0]  read_sm_vec;

  parameter xstartup  =  0;  // Startup wait for buffer status to update after a reset
  parameter xckstack  =  1;  // Idling, waiting for stack data
  parameter xdmb    =  2;  // Begin send to dmb

  parameter xheader  =  3;  // Send header to DMB
  parameter xe0b    =  4;  // Send EOB marker
  parameter xdump    =  5;  // Send fifo dump to DMB

  parameter xb04    =  6;  // Send B04 Begin RPC marker
  parameter xrpc    =  7;  // Send RPC Pad data
  parameter xe04    =  8;  // Send E04 End of RPC marker

  parameter xb05    =  9;  // Send B05 frame to begin scope
  parameter xscope  =  10;  // Send scope frames
  parameter xe05    =  11;  // Send E05 frame to end scope

  parameter xb07    =  12;  // Send B07 frame to begin mini scope
  parameter xmini    =  13;  // Send mini scope frames
  parameter xe07    =  14;  // Send E07 frame to end scope

  parameter xbcb    =  15;  // Send BCB frame to begin cfeb blocked bits
  parameter xblkbit  =  16;  // Send cfeb blocked bits frames
  parameter xecb    =  17;  // Send ECB frame to end cfeb blocked bits
  
  parameter xe0c    =  18;  // Send E0C marker to DMB
  parameter xmod40  =  19;  // Send 2 words to make word count multiple of 4
  parameter xmod41  =  20;  // Send 2 words to make word count multiple of 4

  parameter xe0f    =  21;  // Send E0F frame
  parameter xcrc0    =  22;  // Send crc frames
  parameter xcrc1    =  23;  // Send crc frames
  parameter xlast    =  24;  // Send last frame with word count

  parameter xpop    =  25;  // Pop data off stack, go back to idle
  parameter xhalt    =  26;  // Halted, wait for resume

//-----------------------------------------------------------------------------------------------------------------
// State machine power-up reset + global reset
//-----------------------------------------------------------------------------------------------------------------
  wire [3:0] pdly  = NSTARTUP-1;              // Power-up reset delay
  reg startup_done = 0;

  SRL16E upup (.CLK(clock),.CE(!powerupq),.D(1'b1),.A0(pdly[0]),.A1(pdly[1]),.A2(pdly[2]),.A3(pdly[3]),.Q(powerupq));

  always @(posedge clock) begin
    startup_done <= powerupq && !global_reset;
  end

  wire startup_blank = !startup_done; // Blank DMB outputs
  wire sm_reset      = !startup_done; // State machine reset

//------------------------------------------------------------------------------------------------------------------
// TTC Counter Section
//
//    Bunch Crossing Counter:
//       Increments by 1 every clock cycle, runs from 0 to 3563.
//      Resets to bxn_preset value when resync or bxreset is received.
//      Bxn_preset is likely to be the L0 latency of 160 cycles.
//      If bunch crossing 0 (bx0) does not arrive when the count is bxn_preset, the sync_err bit is set.
//      Latch BXN at pre-trigger and again at L1A for DMB header.
//
//    L1A Event Counter:
//      L1A tx Counts level 1 accepts requested by counting TMB pre-triggers.
//      L1A rx Increments by 1 for each CCB l1a or for each pretrigger with internal l1a.
//      Resets to l1a_offset when evcntres | resync is received.
//      
//------------------------------------------------------------------------------------------------------------------
// Restrict bxn offsets to be in the interval 0 < lhc_cycle to prevent non-physical bxns
  reg [MXBXN-1:0] bxn_offset_pretrig_lim = 0;
  reg [MXBXN-1:0] bxn_offset_l1a_lim     = 0;

  always @(posedge clock) begin
  bxn_offset_pretrig_lim <= (bxn_offset_pretrig >= lhc_cycle) ? (lhc_cycle-1'b1) : (bxn_offset_pretrig);
  bxn_offset_l1a_lim     <= (bxn_offset_l1a     >= lhc_cycle) ? (lhc_cycle-1'b1) : (bxn_offset_l1a); 
  end

// Bunch Crossing Counter, counts 0 to 3563, presets at resync or bxreset, stops counting, resumes at bx0
  reg [MXBXN-1:0] bxn_counter  = 0;
  reg             bxn_hold     = 0;
  reg             bxn_sync_err = 0;

  wire bxn_reset  = ttc_resync || ttc_bxreset;             // Stop counting, load preset
  wire bxn_sync   = bxn_counter == bxn_offset_pretrig_lim; // BXN now at offset value
  wire bxn_ovf    = bxn_counter == lhc_cycle[11:0]-1;      // BXN maximum count for pretrig bxn counter
  wire bxn_preset = (bxn_hold || bxn_reset) && !ttc_bx0;   // Load bxn offset value

  wire bx0_local = bxn_counter == 0;                        // This TMBs bxn is at 0
  wire bx0_xmpc  = (mpc_sel_ttc_bx0) ? ttc_bx0 : bx0_local; // Send ttc bx0 or local bx0 to mpc
  
  always @(posedge clock) begin
    if      ( bxn_reset ) bxn_hold <= 1; // Count hold FF 
    else if ( ttc_bx0   ) bxn_hold <= 0;

    if      (bxn_preset) bxn_counter  <= bxn_offset_pretrig_lim;  // Counter
    else if (bxn_ovf   ) bxn_counter  <= 0;
    else                 bxn_counter  <= bxn_counter+1'b1;

    if      (bxn_preset)  bxn_sync_err <= 0;            // Sync err latch if count isnt at offset on ttc_bx0
    else if (ttc_bx0   )  bxn_sync_err <= !bxn_sync || bxn_sync_err;
    else if (bxn_sync  )  bxn_sync_err <= !ttc_bx0  || bxn_sync_err;
  end

  assign clct_bx0_sync_err = bxn_sync_err || bxn_preset;      // latches on sync error, clears on resync

// Enable sync error counting only when triggers are enabled
  reg sync_err_cnt_en = 0;

  always @(posedge clock) begin
    if (!fmm_trig_stop)
    sync_err_cnt_en <= (ttc_bx0 && !bxn_sync) || (bxn_sync && !bxn_hold && !ttc_bx0);  // pulses 1bx per sync error
  end

// Shadow bunch crossing counter counts 0 to 3563 for L1A because it has a separate preset
  reg  [MXBXN-1:0]  bxn_counter_l1a = 0;

  wire bxn_ovf_l1a = bxn_counter_l1a == lhc_cycle[11:0]-1;    // BXN maximum count for L1A bxn counter

  always @(posedge clock) begin
    if      (bxn_preset)  bxn_counter_l1a <= bxn_offset_l1a_lim;
    else if (bxn_ovf_l1a) bxn_counter_l1a <= 0;
    else                  bxn_counter_l1a <= bxn_counter_l1a+1'b1;
  end

// Orbit Counter, counts bx0s from bx counter
  reg [MXORBIT-1:0] orbit_counter = 0;

  wire orbit_cnt_reset = ttc_orbit_reset || ccb_evcntres || (ttc_resync && hdr_clear_on_resync);
  wire orbit_cnt_ovf   = (orbit_counter == {MXCNTVME{1'b1}});
  wire orbit_cnt_en    = bxn_ovf && !orbit_cnt_ovf;

  always @(posedge clock) begin
    if      (orbit_cnt_reset) orbit_counter=0;
    else if (orbit_cnt_en   ) orbit_counter=orbit_counter+1'b1;
  end

  assign uptime[15:0]=orbit_counter[29:14];    // Uptime for vme, orbit=3564x25ns=89.1us, 1.46 seconds per tick

// Pre-trigger counter, resets at evcntres or resync
  reg   [MXCNTVME-1:0]  pretrig_counter = 0;

  wire pretrig_cnt_reset = ccb_evcntres || (ttc_resync && hdr_clear_on_resync);
  wire pretrig_cnt_ovf   = (pretrig_counter == {MXCNTVME{1'b1}});
  wire pretrig_cnt_en    = clct_pretrig && !pretrig_cnt_ovf;

  always @(posedge clock) begin
    if      (pretrig_cnt_reset) pretrig_counter = 0;
    else if (pretrig_cnt_en   ) pretrig_counter = pretrig_counter + 1'b1;
  end

// CLCT pre-trigger AND L1A coincidence counter (YP August 2015)
  reg [MXCNTVME-1:0] preClct_l1a_counter = 0;
  // add delay to CLCT pre-trigger
  wire preClct = (clct_sm == pretrig);
//  wire preClct_ff;         // delayed CLCT pre-trigger
//  x_delay_os #( .MXDLY(8) ) upreClct_delay (.d(clct_pretrig),.clock(clock),.delay(l1a_preClct_dly),.q(preClct_ff)); 
  wire preClct_ff = preClct;         // Lets not delay CLCT pre-trigger for now
  
  // open CLCT pre-trigger window
  reg  [3:0] preClct_width_cnt = 0;
  wire       preClct_width_bsy = (preClct_width_cnt != 0); 
  //
  always @(posedge clock) begin
    if      ( ttc_resync        ) preClct_width_cnt = 0;                        // Clear on reset
    else if ( preClct_ff        ) preClct_width_cnt = l1a_preClct_width - 1'b1; // Load persistence count
    else if ( preClct_width_bsy ) preClct_width_cnt = preClct_width_cnt - 1'b1; // Decrement count down to 0
  end
  //
  wire preClct_window = preClct_width_bsy | preClct_ff; // Assert immediately, hold until count done
  //
//  wire preClct_l1a_cnt_reset = ccb_evcntres || (ttc_resync && hdr_clear_on_resync);
  wire preClct_l1a_cnt_reset = vme_cnt_reset;
  wire preClct_l1a_cnt_ovf   = (preClct_l1a_counter == {MXCNTVME{1'b1}});
  wire preClct_l1a_cnt_en    = preClct_window && l1a_pulse && !preClct_l1a_cnt_ovf;
//  wire preClct_l1a_cnt_en    =                   l1a_pulse && !preClct_l1a_cnt_ovf;  // Let's count l1as only for now
  //
  always @(posedge clock) begin
    if      (preClct_l1a_cnt_reset) preClct_l1a_counter = 0;
    else if (preClct_l1a_cnt_en   ) preClct_l1a_counter = preClct_l1a_counter + 1'b1;
  end

// CLCT pre-trigger AND ALCT coincidence counter (YP August 2015)
  reg   [MXCNTVME-1:0]  preClct_alct_counter = 0;

//  wire preClct_alct_cnt_reset = ccb_evcntres || (ttc_resync && hdr_clear_on_resync);
  wire preClct_alct_cnt_reset = vme_cnt_reset;
  wire preClct_alct_cnt_ovf   = (preClct_alct_counter == {MXCNTVME{1'b1}});
  wire preClct_alct_cnt_en    = alct_preClct && !preClct_alct_cnt_ovf;
//  wire preClct_alct_cnt_en    = alct_active_feb && !preClct_alct_cnt_ovf;

  always @(posedge clock) begin
    if      (preClct_alct_cnt_reset) preClct_alct_counter = cnt_fatzero;
    else if (preClct_alct_cnt_en   ) preClct_alct_counter = preClct_alct_counter + 1'b1;
  end

// Active CFEB(s) counters (YP January 2016)
  reg   [MXCNTVME-1:0]  active_cfebs_event_counter      = 0; // Any CFEB active flag sent to DMB
  reg   [MXCNTVME-1:0]  active_cfebs_me1a_event_counter = 0; // ME1a CFEB active flag sent to DMB
  reg   [MXCNTVME-1:0]  active_cfebs_me1b_event_counter = 0; // ME1a CFEB active flag sent to DMB
  reg   [MXCNTVME-1:0]  active_cfeb0_event_counter      = 0; // CFEB0 active flag sent to DMB
  reg   [MXCNTVME-1:0]  active_cfeb1_event_counter      = 0; // CFEB1 active flag sent to DMB
  reg   [MXCNTVME-1:0]  active_cfeb2_event_counter      = 0; // CFEB2 active flag sent to DMB
  reg   [MXCNTVME-1:0]  active_cfeb3_event_counter      = 0; // CFEB3 active flag sent to DMB
  reg   [MXCNTVME-1:0]  active_cfeb4_event_counter      = 0; // CFEB4 active flag sent to DMB
  reg   [MXCNTVME-1:0]  active_cfeb5_event_counter      = 0; // CFEB5 active flag sent to DMB
  reg   [MXCNTVME-1:0]  active_cfeb6_event_counter      = 0; // CFEB6 active flag sent to DMB

  wire active_cfebs_event_counter_reset      = vme_cnt_reset;
  wire active_cfebs_me1a_event_counter_reset = vme_cnt_reset;
  wire active_cfebs_me1b_event_counter_reset = vme_cnt_reset;
  wire active_cfeb0_event_counter_reset      = vme_cnt_reset;
  wire active_cfeb1_event_counter_reset      = vme_cnt_reset;
  wire active_cfeb2_event_counter_reset      = vme_cnt_reset;
  wire active_cfeb3_event_counter_reset      = vme_cnt_reset;
  wire active_cfeb4_event_counter_reset      = vme_cnt_reset;
  wire active_cfeb5_event_counter_reset      = vme_cnt_reset;
  wire active_cfeb6_event_counter_reset      = vme_cnt_reset;
  
  wire active_cfebs_event_counter_ovf      = (active_cfebs_event_counter      == {MXCNTVME{1'b1}});
  wire active_cfebs_me1a_event_counter_ovf = (active_cfebs_me1a_event_counter == {MXCNTVME{1'b1}});
  wire active_cfebs_me1b_event_counter_ovf = (active_cfebs_me1b_event_counter == {MXCNTVME{1'b1}});
  wire active_cfeb0_event_counter_ovf      = (active_cfeb0_event_counter      == {MXCNTVME{1'b1}});
  wire active_cfeb1_event_counter_ovf      = (active_cfeb1_event_counter      == {MXCNTVME{1'b1}});
  wire active_cfeb2_event_counter_ovf      = (active_cfeb2_event_counter      == {MXCNTVME{1'b1}});
  wire active_cfeb3_event_counter_ovf      = (active_cfeb3_event_counter      == {MXCNTVME{1'b1}});
  wire active_cfeb4_event_counter_ovf      = (active_cfeb4_event_counter      == {MXCNTVME{1'b1}});
  wire active_cfeb5_event_counter_ovf      = (active_cfeb5_event_counter      == {MXCNTVME{1'b1}});
  wire active_cfeb6_event_counter_ovf      = (active_cfeb6_event_counter      == {MXCNTVME{1'b1}});
  
  wire active_cfebs_event_counter_en      = (|active_feb_list) && !active_cfebs_event_counter_ovf;
  wire active_cfebs_me1a_event_counter_en =  (|active_feb_list[6:4]) && !(|active_feb_list[3:0]) && !active_cfebs_me1a_event_counter_ovf; // Only ME1A was active
  wire active_cfebs_me1b_event_counter_en = !(|active_feb_list[6:4]) &&  (|active_feb_list[3:0]) && !active_cfebs_me1b_event_counter_ovf; // Only ME1B was active
  wire active_cfeb0_event_counter_en      = active_feb_list[0] && !active_cfeb0_event_counter_ovf;
  wire active_cfeb1_event_counter_en      = active_feb_list[1] && !active_cfeb1_event_counter_ovf;
  wire active_cfeb2_event_counter_en      = active_feb_list[2] && !active_cfeb2_event_counter_ovf;
  wire active_cfeb3_event_counter_en      = active_feb_list[3] && !active_cfeb3_event_counter_ovf;
  wire active_cfeb4_event_counter_en      = active_feb_list[4] && !active_cfeb4_event_counter_ovf;
  wire active_cfeb5_event_counter_en      = active_feb_list[5] && !active_cfeb5_event_counter_ovf;
  wire active_cfeb6_event_counter_en      = active_feb_list[6] && !active_cfeb6_event_counter_ovf;
  
  always @(posedge clock) begin
    if      (active_cfebs_event_counter_reset) active_cfebs_event_counter = cnt_fatzero;
    else if (active_cfebs_event_counter_en   ) active_cfebs_event_counter = active_cfebs_event_counter + 1'b1;
    //
    if      (active_cfebs_me1a_event_counter_reset) active_cfebs_me1a_event_counter = cnt_fatzero;
    else if (active_cfebs_me1a_event_counter_en   ) active_cfebs_me1a_event_counter = active_cfebs_me1a_event_counter + 1'b1;
    //
    if      (active_cfebs_me1b_event_counter_reset) active_cfebs_me1b_event_counter = cnt_fatzero;
    else if (active_cfebs_me1b_event_counter_en   ) active_cfebs_me1b_event_counter = active_cfebs_me1b_event_counter + 1'b1;
    //
    if      (active_cfeb0_event_counter_reset) active_cfeb0_event_counter = cnt_fatzero;
    else if (active_cfeb0_event_counter_en   ) active_cfeb0_event_counter = active_cfeb0_event_counter + 1'b1;
    //
    if      (active_cfeb1_event_counter_reset) active_cfeb1_event_counter = cnt_fatzero;
    else if (active_cfeb1_event_counter_en   ) active_cfeb1_event_counter = active_cfeb1_event_counter + 1'b1;
    //
    if      (active_cfeb2_event_counter_reset) active_cfeb2_event_counter = cnt_fatzero;
    else if (active_cfeb2_event_counter_en   ) active_cfeb2_event_counter = active_cfeb2_event_counter + 1'b1;
    //
    if      (active_cfeb3_event_counter_reset) active_cfeb3_event_counter = cnt_fatzero;
    else if (active_cfeb3_event_counter_en   ) active_cfeb3_event_counter = active_cfeb3_event_counter + 1'b1;
    //
    if      (active_cfeb4_event_counter_reset) active_cfeb4_event_counter = cnt_fatzero;
    else if (active_cfeb4_event_counter_en   ) active_cfeb4_event_counter = active_cfeb4_event_counter + 1'b1;
    //
    if      (active_cfeb5_event_counter_reset) active_cfeb5_event_counter = cnt_fatzero;
    else if (active_cfeb5_event_counter_en   ) active_cfeb5_event_counter = active_cfeb5_event_counter + 1'b1;
    //
    if      (active_cfeb6_event_counter_reset) active_cfeb6_event_counter = cnt_fatzero;
    else if (active_cfeb6_event_counter_en   ) active_cfeb6_event_counter = active_cfeb6_event_counter + 1'b1;
  end
  
// CLCT counter, presets at evcntres or resync
  reg   [MXCNTVME-1:0]  clct_counter = 0;

  wire clct_cnt_reset = ccb_evcntres || (ttc_resync && hdr_clear_on_resync);
  wire clct_cnt_ovf   = (clct_counter == {MXCNTVME{1'b1}});
  wire clct_cnt_en    = clct0_vpf && !clct_cnt_ovf;

  always @(posedge clock) begin
    if      (clct_cnt_reset) clct_counter = 0;
    else if (clct_cnt_en   ) clct_counter = clct_counter+1'b1;
  end

// ALCT counter, presets at evcntres or resync
  reg   [MXCNTVME-1:0]  alct_counter = 0;

  wire alct_cnt_reset = ccb_evcntres || (ttc_resync && hdr_clear_on_resync);
  wire alct_cnt_ovf   = (alct_counter == {MXCNTVME{1'b1}});
  wire alct_cnt_en    = alct_active_feb && !alct_cnt_ovf;

  always @(posedge clock) begin
    if      (alct_cnt_reset) alct_counter = 0;
    else if (alct_cnt_en   ) alct_counter = alct_counter+1'b1;
  end

// Trigger counter, presets at evcntres or resync, counts all triggers including ones not sent to mpc
  reg   [MXCNTVME-1:0]  trig_counter = 0;

  wire trig_cnt_reset = ccb_evcntres || (ttc_resync && hdr_clear_on_resync);
  wire trig_cnt_ovf   = (trig_counter == {MXCNTVME{1'b1}});
  wire tmb_trig_write = tmb_trig_pulse && (tmb_trig_keep || tmb_non_trig_keep);
  wire trig_cnt_en    = tmb_trig_write && !trig_cnt_ovf;

  always @(posedge clock) begin
    if      (trig_cnt_reset) trig_counter = 0;
    else if (trig_cnt_en   ) trig_counter = trig_counter+1'b1;
  end

// Level Accept Rx Counter, counts ccb_l1accepts received, presets at evcntres or resync
  reg  [MXL1ARX-1:0] l1a_rx_counter = 0;    // L1As received from ccb
  wire [MXL1ARX-1:0] l1a_rx_counter_plus1;  // L1As received from ccb plus 1 lookahead
  wire               l1a_pulse;

  wire l1a_cnt_reset = ccb_evcntres || (ttc_resync && hdr_clear_on_resync);
  wire l1a_rxcnt_en  = l1a_pulse;        // l1a_ccb || l1a_int

  always @(posedge clock) begin
    if      (l1a_cnt_reset) l1a_rx_counter = l1a_offset;
    else if (l1a_rxcnt_en ) l1a_rx_counter = l1a_rx_counter+1'b1;
  end

  assign l1a_rx_counter_plus1 = l1a_rx_counter+1'b1;

// Readout counter, counts actual L1A readouts
  reg  [MXL1ARX-1:0]  readout_counter=0;    // Readout counter
  reg   [NHBITS-1:0]  header_cnt=0;      // Header  counter

  wire rocnt_en = (read_sm==xckstack) && !buf_q_empty && !no_daq;

  always @(posedge clock) begin
    if      (l1a_cnt_reset) readout_counter = 0;
    else if (rocnt_en     ) readout_counter = readout_counter+1'b1;
  end

//------------------------------------------------------------------------------------------------------------------
// Trigger Source Section
//
//  Type  Source      Delay  External  Description
//  ----  --------------  -----  --------  --------------------------------------------------------
//  0    CLCT VPF    No    N      Cathode LCT Pattern Trigger, this is the normal trigger mode
//  1    ALCT Active    Adj    Y      ALCT Trigger acting as Scintillator
//  2    CLCT*ALCT Act  Adj    N      CLCT*ALCT Pattern Trigger
//  3    ADB  Test Pulse  Adj    Y      Anode Test Pulse Trigger
//  4    DMB  Ext Trig  Adj    Y      DMB Calibration Trigger, delay usually adjusted by DMB
//  5    CLCT Ext Trig  Adj    Y      FAST Site Scintillator Trigger
//  6    ALCT Ext Trig  Adj    Y      ALCT External trigger, force TMB readout only if ALCT VPF not present
//  7    VME  Ext Trig  No    Y      VME  External trigger, for self-test
//
//
//    CLCT Pattern Trigger:
//       CFEB logic modules compare pattern numbers to the number-of-planes-hit threshold value,
//      and send list of key layers hit.
//
//    ALCT Trigger:
//      ALCT Active FEB Flag starts the TMB sequencer if ALCT pre-triggered.
//
//    Match Trigger:
//      Requires ALCT Active FEB window in coincidence with CLCT pre-trig
//
//    ADB Test Pulse Trigger:
//      CCB Pulses ALCT Anode Front End boards, triggers TMB for readout
//
//    DMB External Trigger:
//      DMB injects charge into CFEBs, triggers TMB for readout
//
//    CLCT External Trigger (Scintillator):
//      Assert ext_trig from CCB or CCB front panel connector P10 pins 17+,18-.
//      Set pat_trig_enable=0 so external trigger mode ignores pattern triggers.
//      The user must delay ext_trig to allow for CSC drift.
//      Active FEB flag is 1 clock wide, regardless of ext_trig width.
//      Ext_trig must go low before re-trigger.
//
//    Injector Triggers:
//      Injector RAMs send data to the pattern finder, which could cause a pattern trigger.
//      Set mask_all=0 to keep CFEB signals from interfering.
//      Injector may be started either by ext_trig*ext_trig_inj from CCB or by
//      VME command inj_trig_vme.
//
//------------------------------------------------------------------------------------------------------------------
// On CCB or VME command, start CFEB pattern injectors
  reg  [MXCFEB-1:0]  injector_go_cfeb = 0;
  reg          injector_go_rat  = 0;
  reg          injector_go_rpc  = 0;

  wire inj_trig_cmd = (clct_ext_trig && clct_ext_trig_en && ext_trig_inject) || inj_trig_vme;
  wire inj_trig_pulse;
  wire inj_trig_pulse_ff;

  x_oneshot uinjpulse (.d(inj_trig_cmd ), .clock(clock),.q(inj_trig_pulse));
  x_delay   uninjdly  (.d(inj_trig_pulse),.clock(clock),.delay(inj_delay_rat[3:0]),.q(inj_trig_pulse_ff));

  always@(posedge clock) begin
    injector_go_cfeb[MXCFEB-1:0] <= {MXCFEB{inj_trig_pulse_ff}} & injector_mask_cfeb; // waits for rat
    injector_go_rpc              <=         inj_trig_pulse_ff   & injector_mask_rpc;  // waits for rat
    injector_go_rat              <=         inj_trig_pulse      & injector_mask_rat;  // fires first
  end

// Raw hits & header RAM buffer status
  wire wr_buf_avail          = (wr_buf_ready || !wr_buf_required);        // clct_sm may process new triggers
  wire buf_fence_cnt_is_peak = (buf_fence_cnt_peak[11:0]==buf_fence_cnt[11:0]);  // Peak number of fences in fence RAM

// CLCT Pattern Trigger on hit cfebs, includes only cfebs with actual hits, and not overlaps from adjacent cfebs 
  wire [MXCFEB-1:0] active_feb;
  wire any_cfeb_hit;    

  assign any_cfeb_hit           = (|cfeb_hit[MXCFEB-1:0]);                               // Any CFEB has a hit
  assign active_feb[MXCFEB-1:0] = cfeb_active[MXCFEB-1:0] | {MXCFEB{all_cfebs_active}};  // Active list includes boundary overlaps

// Delay External trigger sources
  wire  alct_pre_trig_os; // ALCT  pre-trigger before drift and priority encode
  wire  alct_pat_trig_os; // ALCT pattern trigger after drift
  wire  adb_ext_trig_os;  // ADB  test pulse trigger
  wire  dmb_ext_trig_os;  // DMB  calibration trigger
  wire  clct_ext_trig_os; // CLCT external trigger from ccb (scintillator)
  wire  alct_ext_trig_os; // ALCT external trigger from ccb

  x_delay_os #(4) udly0 (.d(alct_active_feb    ),.clock(clock),.delay(alct_preClct_dly ),.q(alct_pre_trig_os));  
  x_delay_os #(4) udly1 (.d(alct0_valid        ),.clock(clock),.delay(alct_pat_trig_dly),.q(alct_pat_trig_os));  
  x_delay_os #(4) udly2 (.d(alct_adb_pulse_sync),.clock(clock),.delay(adb_ext_trig_dly ),.q(adb_ext_trig_os ));  
  x_delay_os #(4) udly3 (.d(dmb_ext_trig       ),.clock(clock),.delay(dmb_ext_trig_dly ),.q(dmb_ext_trig_os ));  
  x_delay_os #(4) udly4 (.d(clct_ext_trig      ),.clock(clock),.delay(clct_ext_trig_dly),.q(clct_ext_trig_os));
  x_delay_os #(4) udly5 (.d(alct_ext_trig      ),.clock(clock),.delay(alct_ext_trig_dly),.q(alct_ext_trig_os));

// Open an ALCT pretrig coincidence window, updates if new alcts arrive, uses triad decoder fast look-ahead counter
  reg  [3:0] alct_width_cnt=0;
  wire [3:0] alct_preClct_win;

  wire alct_width_bsy   = (alct_width_cnt != 0); 
  wire alct_open_window = alct_pre_trig_os; // ALCT match window opens on alct_active_feb
  
  always @(posedge clock) begin
    if      (ttc_resync      )  alct_width_cnt = 0;                         // Clear on reset
    else if (alct_open_window)  alct_width_cnt = alct_preClct_width - 1'b1; // Load persistence count
    else if (alct_width_bsy  )  alct_width_cnt = alct_width_cnt  - 1'b1;    // Decrement count down to 0
  end

  wire   alct_preClct_window = alct_width_bsy | alct_open_window;                              // Assert immediately, hold until count done
  assign alct_preClct_win    = (alct_open_window) ? 4'h0: alct_preClct_width - alct_width_cnt; // Position of alct active feb signal at pretrigger
  wire   alct_required       = alct_match_trig_en && !clct_pat_trig_en;                        // ALCT coincidence is required

// Pre-trigger Source Multiplexer
  wire [8:0] trig_source;

  assign trig_source[0] = any_cfeb_hit     && clct_pat_trig_en;                     // CLCT pattern pretrigger
  assign trig_source[1] = alct_pat_trig_os && alct_pat_trig_en;                     // ALCT pattern trigger
  assign trig_source[2] = any_cfeb_hit     && alct_match_trig_en;                   // ALCT*CLCT match pattern pretrigger, success presumed
  assign trig_source[3] = adb_ext_trig_os  && adb_ext_trig_en;                      // ADB external trigger
  assign trig_source[4] = dmb_ext_trig_os  && dmb_ext_trig_en;                      // DMB external trigger
  assign trig_source[5] = clct_ext_trig_os && clct_ext_trig_en && !ext_trig_inject; // CLCT external trigger from CCB
  assign trig_source[6] = alct_ext_trig_os && alct_ext_trig_en;                     // ALCT external trigger from CCB
  assign trig_source[7] = vme_ext_trig;                                             // VME  external trigger from backplane
  assign trig_source[8] = cfeb_layer_trig  && layer_trig_en;                        // Layer-wide trigger

// Pre-trigger
  reg  noflush    = 0;
  reg  nothrottle = 0;
  wire flush_done;
  wire throttle_done;

  wire clct_pretrig_rqst= (| trig_source[7:0]) && !sync_err_stops_pretrig; // CLCT pretrigger requested, dont trig on [8]

  assign clct_pretrig = (clct_sm == pretrig);                        // CLCT pre-triggered
  assign alct_preClct = (clct_sm == pretrig) && alct_preClct_window; // ALCT*CLCT pre-trigger coincidence

// *****************************************************************************
// YP: THIS IS WHERE CLCT DEADTIME IS
// *****************************************************************************
  wire clct_pat_trig  = any_cfeb_hit && clct_pat_trig_en;        // Trigger source is a CLCT pattern
  wire clct_retrigger = clct_pat_trig && noflush && nothrottle;  // Immediate re-trigger
  wire clct_notbusy   = !clct_pretrig_rqst;                      // Ready for next pretrig  
  wire clct_deadtime  = (clct_sm==flush) || (clct_sm==throttle); // CLCT Bx pretrig machine waited for triads to dissipate before rearm

// Pre-trigger keep or discard
  wire discard_nowrbuf = clct_pretrig && !wr_buf_avail;                   // Discard pretrig because wr_buf was not ready
  wire discard_noalct  = clct_pretrig && !alct_preClct  && alct_required; // Discard pretrig because alct was not in window
  wire discard_pretrig = discard_nowrbuf || discard_noalct;               // Discard this pretrig

  wire clct_push_pretrig = clct_pretrig && !discard_pretrig; // Keep this pretrig, push it into pipeline

// CLCT pre-trigger State Machine
  always @(posedge clock or posedge sm_reset) begin
    if      (sm_reset  ) clct_sm = startup; // async reset
    else if (ttc_resync) clct_sm = halt;    // sync  reset
    else begin

      case (clct_sm)

        startup:            // Delay for active feb bits to clear
          if (startup_done) // Startup countdown timer
           clct_sm = halt;  // Start up halted, wait for FMM trigger start

        idle:                         // Idling, waiting for next pre-trigger request
          if (fmm_trig_stop)          // TTC stop trigger command
           clct_sm = halt;
          else if (clct_pretrig_rqst) // Pre-trigger requested
           clct_sm = pretrig;

        pretrig:                    // Pre-triggered, send Active FEB bits to DMB
          if (!nothrottle)          // Throttle trigger rate before re-arming
           clct_sm = throttle;    
          else if (!noflush)        // Flush triads before re-arming
           clct_sm = flush;
          else if (!clct_retrigger) // Stay in pre-trig for immediate re-trigger
           clct_sm = idle;

        throttle:                // Decrease pre-trigger rate
          if (throttle_done)     // Countdown timer
            if (!noflush)
             clct_sm = flush;      // Flush if required
            else if (pretrig_halt)
             clct_sm = halt;       // Halt if required
            else
             clct_sm = idle;       // Otherwise go directly from throttle to idle

        flush:                   // Wait fixed time for 1/2-strip one-shots to dissipate  
          if (flush_done) begin  // Countdown timer
            if (pretrig_halt)    // Pretrigger and halt mode
             clct_sm = halt;
            else                 // Ready for next trigger
             clct_sm =idle;
          end

        halt:                    // Halted, wait for resume from VME or FMM
          if (!fmm_trig_stop && !pretrig_halt)
          if (!noflush)
           clct_sm = flush;      // Flush if required
          else
           clct_sm = idle;       // Otherwise go directly from halt to idle

        default
          clct_sm = idle;

      endcase
    end
  end

// Throttle state timer, reduce trigger rate
  reg   [MXTHROTTLE-1:0] throttle_cnt=0;

  always @(posedge clock) begin
    if      (clct_sm != throttle) throttle_cnt = clct_throttle - 1'b1; // Sync load
    else if (clct_sm == throttle) throttle_cnt = throttle_cnt  - 1'b1; // Only count during throttle
  end

  assign throttle_done = (throttle_cnt == 0) || nothrottle;

  always @(posedge clock) begin
    nothrottle <= (clct_throttle == 0);
  end
  
// Trigger flush state timer. Wait for 1/2-strip one-shots and raw hits fifo to clear
  reg   [MXFLUSH-1:0] flush_cnt=0;

  wire flush_cnt_clr = (clct_sm != flush) || !clct_notbusy;  // Flush timer resets if triad debris remains
  wire flush_cnt_ena = (clct_sm == flush);

  always @(posedge clock) begin
    if    (flush_cnt_clr) flush_cnt = clct_flush_delay-1'b1; // sync load before entering flush state
    else if (flush_cnt_ena) flush_cnt = flush_cnt-1'b1;      // only count during flush
  end

  assign flush_done = ((flush_cnt == 0) || noflush) && clct_notbusy;

  always @(posedge clock) begin
    noflush  <= (clct_flush_delay == 0);
  end

// Delay trigger source and cfeb active feb list 1bx for clct_sm to go to pretrig state
  reg [MXCFEB-1:0] active_feb_s0  = 0;
  reg [MXCFEB-1:0] cfeb_hit_s0    = 0;
  reg [2:0]        nlayers_hit_s0 = 0;
  reg [8:0]        trig_source_s0 = 0;

  always @(posedge clock) begin
    active_feb_s0  <= active_feb;    // CFEBs active, including overlaps
    cfeb_hit_s0    <= cfeb_hit;      // CFEBs hit, not including overlaps
    nlayers_hit_s0 <= cfeb_nlayers_hit;
    trig_source_s0 <= trig_source;
  end

  wire trig_source_ext = (|trig_source_s0[7:3]) | trig_source_s0[1];          // Trigger source was not CLCT pattern
  wire trig_clct_flash = clct_pretrig & (trig_source_s0[0] || trig_source_s0[7:2]);  // Trigger source flashes CLCT light

// Record which CFEBs were hit at pretrigger
  reg [MXCFEB-1:0] cfeb_hit_at_pretrig = 0;

  always @(posedge clock) begin
    cfeb_hit_at_pretrig <= cfeb_hit_s0 & {MXCFEB{clct_pretrig}};
  end

// Trigger source was ME1A or ME1B
// YP: code below mixed up pre-triggers and active cfebs, so I modified it to have only pre-triggers
//  wire only_me1a_hit =  (|active_feb_s0[6:4]) && !(|active_feb_s0[3:0]); // Only ME1A was hit
//  wire only_me1b_hit = !(|active_feb_s0[6:4]) &&  (|active_feb_s0[3:0]); // Only ME1B was hit
  wire only_me1a_hit =  (|cfeb_hit_s0[6:4]) && !(|cfeb_hit_s0[3:0]); // Only ME1A was hit
  wire only_me1b_hit = !(|cfeb_hit_s0[6:4]) &&  (|cfeb_hit_s0[3:0]); // Only ME1B was hit

  wire clct_pretrig_me1a = clct_pretrig && (csc_me1ab || cnt_non_me1ab_en) && only_me1a_hit && clct_pat_trig_en;  // Pretriggered on ME1A only
  wire clct_pretrig_me1b = clct_pretrig && (csc_me1ab || cnt_non_me1ab_en) && only_me1b_hit && clct_pat_trig_en;  // Pretriggered on ME1B only

// Modify trig_source[2] if there were ALCT coincidence, and add sources 9,10 for ME1A ME1B
  wire [10:0] trig_source_s0_mod;
  
  assign trig_source_s0_mod[1:0] = trig_source_s0[1:0];      // Copy non-alct trigger source bits
  assign trig_source_s0_mod[2]   = alct_preClct_window && clct_pretrig && alct_match_trig_en;  // ALCT window was open at pretrig
  assign trig_source_s0_mod[8:3] = trig_source_s0[8:3];      // Copy non-alct trigger source bits
  assign trig_source_s0_mod[9]   = clct_pretrig_me1a;        // CLCT pre-trigger was ME1A only
  assign trig_source_s0_mod[10]  = clct_pretrig_me1b;        // CLCT pre-trigger was ME1B only

// Retain a copy of latest pretrig for VME
  reg [2:0]        nlayers_hit_vme = 0;
  reg [10:0]       trig_source_vme = 0;
  reg  [MXBXN-1:0] bxn_clct_vme    = 0;

  always @(posedge clock) begin
    if (event_clear_vme) begin
      nlayers_hit_vme <= 0;
      trig_source_vme <= 0;
      bxn_clct_vme    <= 0;
    end
    else if (clct_push_pretrig) begin
      nlayers_hit_vme <= nlayers_hit_s0;
      trig_source_vme <= trig_source_s0_mod;
      bxn_clct_vme    <= bxn_counter;
    end
  end
  
// On Pretrigger send Active FEB word to DMB, persist 1 cycle per event
  wire [MXCFEB-1:0] active_feb_list_pre; // Active FEB list to DMB at pretrig time
  wire [MXCFEB-1:0] active_feb_list_tmb; // Active FEB list to DMB at tmb match time
  wire [MXCFEB-1:0] active_feb_list;     // Active FEB list selection
  
  wire              active_feb_flag_pre; // Active FEB flag to DMB at pretrig time
  wire              active_feb_flag_tmb; // Active FEB flag to DMB at tmb match time
  wire              active_feb_flag;     // Active FEB flag selection

  assign active_feb_flag_pre = clct_push_pretrig;
  assign active_feb_list_pre = active_feb_s0[MXCFEB-1:0] & {MXCFEB{active_feb_flag_pre}};

  assign active_feb_flag_tmb = tmb_trig_write;
  assign active_feb_list_tmb = tmb_aff_list & {MXCFEB{active_feb_flag_tmb}};

  assign active_feb_flag = (active_feb_src) ? active_feb_flag_tmb : active_feb_flag_pre;
  assign active_feb_list = (active_feb_src) ? active_feb_list_tmb : active_feb_list_pre;

// Delay TMB active feb list 1bx so it can share tmb+1bx RAM
  reg [MXCFEB-1:0] tmb_aff_list_ff = 0;
  
  always @(posedge clock) begin
    tmb_aff_list_ff <= tmb_aff_list;
  end

//------------------------------------------------------------------------------------------------------------------
// Pre-trigger Pipeline
// Pushes CLCT pretrigger data into pipeline to wait for pattern finder and drift delay
//------------------------------------------------------------------------------------------------------------------
// On pretrigger push buffer address and bxn into the pre-trigger pipeline
  parameter PATTERN_FINDER_LATENCY = 2;  // Tuned 4/22/08
  parameter MXPTRID = 23;

  wire [3:0]         postdrift_adr;
  wire [MXPTRID-1:0] pretrig_data;
  wire [MXPTRID-1:0] postdrift_data;

  assign pretrig_data[0]     = clct_push_pretrig;        // Pre-trigger flag alias active_feb_flag
  assign pretrig_data[11:1]  = wr_buf_adr[MXBADR-1:0];   // Buffer address at pre-trigger
  assign pretrig_data[12]    = wr_buf_avail;             // Buffer address was valid at pre-trigger
  assign pretrig_data[14:13] = bxn_counter[1:0];         // BXN at pre-trigger, only lsbs are needed for clct
  assign pretrig_data[15]    = trig_source_ext;          // Trigger source was not CLCT pattern
  assign pretrig_data[22:16] = active_feb_list_pre[6:0]; // Active feb list at pre-trig

  assign postdrift_adr = PATTERN_FINDER_LATENCY + drift_delay;

  srl16e_bbl #(MXPTRID) usrldrift (.clock(clock),.ce(1'b1),.adr(postdrift_adr),.d(pretrig_data),.q(postdrift_data));

// Extract pre-trigger data after drift delay, compensated for pattern-finder latency + programmable drift delay
  wire              clct_pop_xtmb        = postdrift_data[0];     // CLCT postdrift flag aka active_feb_flag
  wire [MXBADR-1:0] clct_wr_adr_xtmb     = postdrift_data[11:1];  // Buffer address at pre-trigger
  wire              clct_wr_avail_xtmb   = postdrift_data[12];    // Buffer address was valid at pre-trigger
  wire [1:0]        bxn_counter_xtmb     = postdrift_data[14:13]; // BXN at pre-trigger, only lsbs are needed for clct
  wire              trig_source_ext_xtmb = postdrift_data[15];    // Trigger source was not CLCT pattern
  wire [MXCFEB-1:0] aff_list_xtmb        = postdrift_data[22:16]; // Active feb list

// After drift, send CLCT words to TMB, persist 1 cycle only, blank invalid CLCTs unless override
  wire clct0_hit_valid = (hs_hit_1st >= hit_thresh_postdrift);    // CLCT is over hit thresh
  wire clct0_pid_valid = (hs_pid_1st >= pid_thresh_postdrift);    // CLCT is over pid thresh

  wire clct1_hit_valid = (hs_hit_2nd >= hit_thresh_postdrift);    // CLCT is over hit thresh
  wire clct1_pid_valid = (hs_pid_2nd >= pid_thresh_postdrift);    // CLCT is over pid thresh

  wire clct0_really_valid = (clct0_hit_valid && clct0_pid_valid);    // CLCT is over thresh and not external
  wire clct1_really_valid = (clct1_hit_valid && clct1_pid_valid);    // CLCT is over thresh and not external

  wire clct0_valid = clct0_really_valid || trig_source_ext_xtmb || !valid_clct_required;
  wire clct1_valid = clct1_really_valid || trig_source_ext_xtmb || !valid_clct_required;

  assign clct0_vpf = clct0_valid && clct_pop_xtmb;
  assign clct1_vpf = clct1_valid && clct_pop_xtmb;

// Construct CLCTs for sending to TMB matching. These are node names only
  wire [MXCLCT-1:0]  clct0, clct0_xtmb;
  wire [MXCLCT-1:0]  clct1, clct1_xtmb;
  wire [MXCLCTA-1:0] clcta, clcta_xtmb;
  wire [MXCLCTC-1:0] clctc, clctc_xtmb;
  wire [MXCFEB-1:0]  clctf, clctf_xtmb;

  assign clct0[0]    = clct0_vpf;       // Valid pattern flag
  assign clct0[3:1]  = hs_hit_1st[2:0]; // Hits on pattern 0-6
  assign clct0[7:4]  = hs_pid_1st[3:0]; // Pattern shape 0-A
  assign clct0[15:8] = hs_key_1st[7:0]; // 1/2-strip ID number

  assign clct1[0]    = clct1_vpf;       // Valid pattern flag
  assign clct1[3:1]  = hs_hit_2nd[2:0]; // Hits on pattern 0-6
  assign clct1[7:4]  = hs_pid_2nd[3:0]; // Pattern shape 0-A
  assign clct1[15:8] = hs_key_2nd[7:0]; // 1/2-strip ID number

  assign clcta[5:0]  = hs_layer_or[5:0]; // Layer ORs at pattern finder output
  assign clcta[6]    = hs_bsy_2nd;       // 2nd CLCT busy, logic error indicator

  assign clctc[1:0]  = bxn_counter_xtmb[1:0]; // Bunch crossing number
  assign clctc[2]    = sync_err;              // BX0 disagrees with BXN count

  assign clctf[6:0]  = aff_list_xtmb[6:0]; // Active feb list post drift

// Blank CLCTs with insufficient hits
  wire clct0_blanking = clct_blanking && !clct0_vpf;
  wire clct1_blanking = clct_blanking && !clct1_vpf;

// Send CLCTs to TMB for ALCT matching and MPC readout
  assign clct0_xtmb = clct0 & {MXCLCT {!clct0_blanking}};
  assign clct1_xtmb = clct1 & {MXCLCT {!clct1_blanking}};
  assign clcta_xtmb = clcta & {MXCLCTA{!clct0_blanking}};
  assign clctc_xtmb = clctc & {MXCLCTC{!clct0_blanking}};
  assign clctf_xtmb = clctf & {MXCFEB {!clct0_blanking}};

// Latch CLCTs for VME
  reg [MXCLCT-1:0]  clct0_vme=0;
  reg [MXCLCT-1:0]  clct1_vme=0;
  reg [MXCLCTC-1:0] clctc_vme=0;
  reg [MXCFEB-1:0]  clctf_vme=0;

  wire clear_clct_vme = event_clear_vme | clct_pretrig;

  always @(posedge clock) begin
    if (clear_clct_vme) begin    // Clear clcts in case event gets flushed
      clct0_vme <= 0;
      clct1_vme <= 0;
      clctc_vme <= 0;
      clctf_vme <= 0;
    end
    else if (clct0_vpf) begin
      clct0_vme <= clct0_xtmb;
      clct1_vme <= clct1_xtmb;
      clctc_vme <= clctc_xtmb;
      clctf_vme <= clctf_xtmb;
    end
  end

// Discard event if there was no valid first pattern after drift
  wire [1:0] clct_invp;
  
  assign clct_invp[0] = !(clct0_vpf || trig_source_ext_xtmb);                     // Force valid for external trigger
  assign clct_invp[1] = !(clct1_vpf || trig_source_ext_xtmb) && (hs_hit_2nd !=0); // clct1 invalid if it has hits below thresh

  wire discard_invp   =  clct_invp[0] && clct_pop_xtmb;    // Discard event, clct0 failed hit or pid thresh
  wire clct_push_xtmb = !clct_invp[0] && clct_pop_xtmb;    // Keep event, push to TMB section

  wire clct_en           = clct_pop_xtmb   && !trig_source_ext_xtmb;       // Popped out of pipeline and was not external trig
  wire discard_inv_clct0 = clct0_hit_valid && !clct0_pid_valid && clct_en; // Discarded clct0 that passed hit thresh but failed pid thresh
  wire discard_inv_clct1 = clct1_hit_valid && !clct1_pid_valid && clct_en; // Discarded clct1 that passed hit thresh but failed pid thresh

// TMB response, variable tmb latency depends on when alct arrived in clct window
  wire discard_tmbreject  = (tmb_trig_pulse && !tmb_trig_keep); // TMB could not match clct to alct

//------------------------------------------------------------------------------------------------------------------
// Event Discard Counter and TMB Response Failure Section
//------------------------------------------------------------------------------------------------------------------
// Event discard counters
  wire discard_nowrbuf_cnt_en   = discard_nowrbuf;
  wire discard_noalct_cnt_en    = discard_noalct;
  wire discard_invp_cnt_en      = discard_invp;      // Discarded event, invalid pattern, clct0 failed hit or pid thresh
  wire discard_inv_clct0_cnt_en = discard_inv_clct0; // Discarded clct0 that passed hit thresh but failed pid thresh
  wire discard_inv_clct1_cnt_en = discard_inv_clct1; // Discarded clct1 that passed hit thresh but failed pid thresh
  wire discard_tmbreject_cnt_en = discard_tmbreject;
  wire discard_event_led        = discard_nowrbuf || discard_noalct || discard_tmbreject;

// L1A requested but not received or L1A received and no TMB in window
  wire l1a_match_cnt_en = l1a_match;  // TMB triggered, TMB in L1A window
  wire l1a_notmb_cnt_en = l1a_notmb;  // L1A received, no TMB in window
  wire tmb_nol1a_cnt_en = tmb_nol1a;  // TMB triggered, no L1A received
  wire l1a_los_win;                   // TMB readouts lost due to L1A prioritizing

//------------------------------------------------------------------------------------------------------------------
// Trigger/Readout VME Counter Section
//------------------------------------------------------------------------------------------------------------------
// Counter registers
  parameter MNCNT        = 13;            // First sequencer counter, not number of counters because they start elsewhere
  parameter MXCNT        = 65;            // Last  sequencer counter, not number of counters becouse they end elsewhere
  parameter RESYNCCNT_ID = 63;            // TTC Resyncs received counter does not get cleared

  reg [MXCNTVME-1:0] cnt [MXCNT:MNCNT]; // TMB counter array, counters[6:0] are in alct.v
  reg [MXCNT:MNCNT]  cnt_en = 0;        // Counter increment enables

// Counter enable strobes
  always @(posedge clock) begin
    cnt_en[13]  <= clct_pretrig;                 // CLCT pretrigger is on any cfeb

    cnt_en[14]  <= cfeb_hit_at_pretrig[0];       // CLCT pretrigger is on CFEB0
    cnt_en[15]  <= cfeb_hit_at_pretrig[1];       // CLCT pretrigger is on CFEB1
    cnt_en[16]  <= cfeb_hit_at_pretrig[2];       // CLCT pretrigger is on CFEB2
    cnt_en[17]  <= cfeb_hit_at_pretrig[3];       // CLCT pretrigger is on CFEB3
    cnt_en[18]  <= cfeb_hit_at_pretrig[4];       // CLCT pretrigger is on CFEB4
    cnt_en[19]  <= cfeb_hit_at_pretrig[5];       // CLCT pretrigger is on CFEB5
    cnt_en[20]  <= cfeb_hit_at_pretrig[6];       // CLCT pretrigger is on CFEB6

    cnt_en[21]  <= clct_pretrig_me1a;            // CLCT pretrigger is on ME1A cfeb4-6 only
    cnt_en[22]  <= clct_pretrig_me1b;            // CLCT pretrigger is on ME1B cfeb0-3 only

    cnt_en[23]  <= discard_nowrbuf_cnt_en;       // CLCT pretrig discarded, no wrbuf available, buffer stalled
    cnt_en[24]  <= discard_noalct_cnt_en;        // CLCT pretrig discarded, no alct in window
    cnt_en[25]  <= discard_invp_cnt_en;          // CLCT CLCT discarded, CLCT0 had invalid pattern after drift
    cnt_en[26]  <= discard_inv_clct0_cnt_en;     // CLCT CLCT0 passed hit thresh but failed pid thresh after drift
    cnt_en[27]  <= discard_inv_clct1_cnt_en;     // CLCT CLCT1 passed hit thresh but failed pid thresh after drift
    cnt_en[28]  <= clct_deadtime;                // CLCT Bx pre-triggrer machine had to wait for triads to dissipate before rearming

    cnt_en[29]  <= clct_push_xtmb && clct0_vpf;  // CLCT CLCT0 sent to TMB matching
    cnt_en[30]  <= clct_push_xtmb && clct1_vpf;  // CLCT CLCT1 sent to TMB matching

    cnt_en[31]  <= tmb_trig_pulse && tmb_trig_keep;     // TMB  TMB matching accepted a match, alct-only, or clct-only event
    cnt_en[32]  <= tmb_trig_write && tmb_match;         // TMB  CLCT*ALCT matched trigger
    cnt_en[33]  <= tmb_trig_write && tmb_alct_only;     // TMB  ALCT-only trigger
    cnt_en[34]  <= tmb_trig_write && tmb_clct_only;     // TMB  CLCT-only trigger

    cnt_en[35]  <= discard_tmbreject_cnt_en;            // TMB  TMB matching rejected event
    cnt_en[36]  <= tmb_trig_pulse && tmb_non_trig_keep; // TMB  TMB matching rejected event, but keep for readout anyway
    cnt_en[37]  <= tmb_trig_write && tmb_alct_discard;  // TMB  TMB matching discarded an ALCT pair
    cnt_en[38]  <= tmb_trig_write && tmb_clct_discard;  // TMB  TMB matching discarded a  CLCT pair
    cnt_en[39]  <= tmb_trig_write && tmb_clct0_discard; // TMB  TMB matching discarded CLCT0 from ME1A
    cnt_en[40]  <= tmb_trig_write && tmb_clct1_discard; // TMB  TMB matching discarded CLCT1 from ME1A

    cnt_en[41]  <= tmb_no_alct   && wr_push_rtmb;       // TMB  Matching found no  ALCT
    cnt_en[42]  <= tmb_no_clct   && wr_push_rtmb;       // TMB  Matching found no  CLCT
    cnt_en[43]  <= tmb_one_alct  && wr_push_rtmb;       // TMB  Matching found One ALCT
    cnt_en[44]  <= tmb_one_clct  && wr_push_rtmb;       // TMB  Matching found One CLCT
    cnt_en[45]  <= tmb_two_alct  && wr_push_rtmb;       // TMB  Matching found Two ALCTs
    cnt_en[46]  <= tmb_two_clct  && wr_push_rtmb;       // TMB  Matching found Two CLCTs

    cnt_en[47]  <= tmb_dupe_alct && wr_push_rtmb;       // TMB  ALCT0 copied into ALCT1 to make 2nd LCT
    cnt_en[48]  <= tmb_dupe_clct && wr_push_rtmb;       // TMB  CLCT0 copied into CLCT1 to make 2nd LCT
    cnt_en[49]  <= tmb_rank_err  && wr_push_rtmb;       // TMB  LCT1 has higher quality than LCT0, error

    cnt_en[50]  <= mpc_xmit_lct0;                       // TMB  Transmitted LCT0 to MPC
    cnt_en[51]  <= mpc_xmit_lct1;                       // TMB  Transmitted LCT1 to MPC

    cnt_en[52]  <= mpc_response_ff && mpc_accept_ff[0];  // TMB  MPC accepted LCT0
    cnt_en[53]  <= mpc_response_ff && mpc_accept_ff[1];  // TMB  MPC accepted LCT1
    cnt_en[54]  <= mpc_response_ff && !(|mpc_accept_ff); // TMB  MPC rejected both LCT0 & LCT1

    cnt_en[55]  <= l1a_received;              // L1A  L1A received
    cnt_en[56]  <= l1a_match_cnt_en;          // L1A  L1A received, TMB in L1A window
    cnt_en[57]  <= l1a_notmb_cnt_en;          // L1A  L1A received,  no TMB in window
    cnt_en[58]  <= tmb_nol1a_cnt_en;          // L1A  TMB triggered, no L1A in window
    cnt_en[59]  <= (read_sm == xcrc0);        // L1A  TMB readouts completed
    cnt_en[60]  <= l1a_los_win;               // L1A  TMB readouts lost due to L1A prioritizing
    
    cnt_en[61]  <= (|triad_skip[MXCFEB-1:0]); // STAT  CLCT Triads skipped
    cnt_en[62]  <= buf_reset && startup_done; // STAT  Raw hits buffer had to be reset due to ovf, error
    cnt_en[63]  <= ttc_resync;                // STAT  TTC Resyncs received
    cnt_en[64]  <= sync_err_cnt_en;           // STAT  TTC sync errors
    cnt_en[65]  <= perr_pulse;                // STAT Raw hits RAM parity errors
  end

// Counter overflow disable
  wire [MXCNTVME-1:0] cnt_fullscale = {MXCNTVME{1'b1}};
  wire [MXCNT:MNCNT]  cnt_nof;

  genvar j;
  generate
    for (j=MNCNT; j<=MXCNT; j=j+1) begin: gennof
      assign cnt_nof[j] = (cnt[j] < cnt_fullscale);    // 1=counter j not overflowed
    end
  endgenerate

  wire cnt_any_ovf_clct = !(&cnt_nof);        // 1 or more counters overflowed

  reg cnt_en_all      = 0;
  reg cnt_any_ovf_seq = 0;

  always @(posedge clock) begin
    cnt_any_ovf_seq <= cnt_any_ovf_clct;
    cnt_en_all      <= !((cnt_any_ovf_clct || cnt_any_ovf_alct) && cnt_stop_on_ovf);
  end

// Counting
  wire vme_cnt_reset = ccb_evcntres || cnt_all_reset;
  wire cnt_fatzero   = {MXCNTVME{1'b0}};

  generate
    for (j=MNCNT; j<=MXCNT; j=j+1) begin: gencnt
      always @(posedge clock) begin
        if (vme_cnt_reset) begin
          if (!(j==RESYNCCNT_ID && ttc_resync)) // Don't let ttc_resync clear the resync counter, eh
            cnt[j] = cnt_fatzero;               // Clear counter j
        end
        else if (cnt_en_all) begin
          if (cnt_en[j] && cnt_nof[j]) cnt[j] = cnt[j]+1'b1;  // Increment counter j if it has not overflowed
        end
      end
    end
  endgenerate

// Map 2D counter array to 1D for io ports
  assign event_counter13  = cnt[13];
  assign event_counter14  = cnt[14];
  assign event_counter15  = cnt[15];
  assign event_counter16  = cnt[16];
  assign event_counter17  = cnt[17];
  assign event_counter18  = cnt[18];
  assign event_counter19  = cnt[19];
  assign event_counter20  = cnt[20];
  assign event_counter21  = cnt[21];
  assign event_counter22  = cnt[22];
  assign event_counter23  = cnt[23];
  assign event_counter24  = cnt[24];
  assign event_counter25  = cnt[25];
  assign event_counter26  = cnt[26];
  assign event_counter27  = cnt[27];
  assign event_counter28  = cnt[28];
  assign event_counter29  = cnt[29];
  assign event_counter30  = cnt[30];
  assign event_counter31  = cnt[31];
  assign event_counter32  = cnt[32];
  assign event_counter33  = cnt[33];
  assign event_counter34  = cnt[34];
  assign event_counter35  = cnt[35];
  assign event_counter36  = cnt[36];
  assign event_counter37  = cnt[37];
  assign event_counter38  = cnt[38];
  assign event_counter39  = cnt[39];
  assign event_counter40  = cnt[40];
  assign event_counter41  = cnt[41];
  assign event_counter42  = cnt[42];
  assign event_counter43  = cnt[43];
  assign event_counter44  = cnt[44];
  assign event_counter45  = cnt[45];
  assign event_counter46  = cnt[46];
  assign event_counter47  = cnt[47];
  assign event_counter48  = cnt[48];
  assign event_counter49  = cnt[49];
  assign event_counter50  = cnt[50];
  assign event_counter51  = cnt[51];
  assign event_counter52  = cnt[52];
  assign event_counter53  = cnt[53];
  assign event_counter54  = cnt[54];
  assign event_counter55  = cnt[55];
  assign event_counter56  = cnt[56];
  assign event_counter57  = cnt[57];
  assign event_counter58  = cnt[58];
  assign event_counter59  = cnt[59];
  assign event_counter60  = cnt[60];
  assign event_counter61  = cnt[61];
  assign event_counter62  = cnt[62];
  assign event_counter63  = cnt[63];
  assign event_counter64  = cnt[64];
  assign event_counter65  = cnt[65];

//------------------------------------------------------------------------------------------------------------------
// Multi-buffer storage for event header
//------------------------------------------------------------------------------------------------------------------
// Pre-trigger: store pre-trigger data in RAM mapping array
  parameter MXXPRE = 90; // Pre-trig data bits

  wire [MXXPRE-1:0] xpre_wdata; // Mapping array
  wire [MXXPRE-1:0] xpre_rdata; // Mapping array

  assign xpre_wdata[6:0]   =  active_feb_list_pre[6:0]; // Active FEB list sent to DAQMB
  assign xpre_wdata[17:7]  =  trig_source_s0_mod[10:0]; // Trigger source vector
  assign xpre_wdata[29:18] =  bxn_counter[11:0];        // Full Bunch Crossing number at pretrig
  assign xpre_wdata[59:30] =  orbit_counter[29:0];      // Orbit count at pre-trigger
  assign xpre_wdata[60]    =  sync_err;                 // BXN sync error
  assign xpre_wdata[64:61] =  alct_preClct_win[3:0];    // ALCT active_feb_flag position in pretrig window

  assign xpre_wdata[75:65] =  wr_buf_adr[MXBADR-1:0]; // Address of write buffer at pretrig
  assign xpre_wdata[86:76] =  buf_fence_dist[10:0];   // Distance to 1st fence address at pretrigger
  assign xpre_wdata[87]    =  wr_buf_avail;           // Write buffer is ready or bypassed
  assign xpre_wdata[88]    =  wr_buf_ready;           // Write buffer is ready
  assign xpre_wdata[89]    =  buf_stalled;            // All buffer memory space is in use

// Pre-trigger+1bx: store pre-trigger counter 1bx after pretrig to give it time to count current event
  parameter MXXPRE1 = 60; // Pre-trig+1bx data bits

  wire [MXXPRE1-1:0] xpre1_wdata; // Mapping array
  wire [MXXPRE1-1:0] xpre1_rdata; // Mapping array

  assign xpre1_wdata[29:0]  = pretrig_counter[29:0]; // Pre-trigger counter
  assign xpre1_wdata[59:30] = alct_counter[29:0];    // ALCT counter at pre-trigger

// Post-drift: store CLCT data sent to TMB in RAM mapping array
  parameter MXXTMB = 44;                    // Post drift CLCT data
  wire [MXXTMB-1:0]  xtmb_wdata;                // Mapping array
  wire [MXXTMB-1:0]  xtmb_rdata;                // Mapping array
  
  assign xtmb_wdata[15:0]  =  clct0_xtmb[15:0]; // CLCT0 after drift
  assign xtmb_wdata[31:16] =  clct1_xtmb[15:0]; // CLCT1 after drift
  assign xtmb_wdata[34:32] =  clctc_xtmb[2:0];  // CLCT0/1 common after drift
  assign xtmb_wdata[41:35] =  clcta_xtmb[6:0];  // CLCT0/1 common after drift
  assign xtmb_wdata[42]    =  clct_invp[0];     // CLCT had invalid pattern after drift delay
  assign xtmb_wdata[43]    =  clct_invp[1];     // CLCT had invalid pattern after drift delay

// Post-drift+1bx: store CLCT counter in RAM mapping array
  parameter MXXTMB1 = 30;         // Post drift CLCT counter
  wire [MXXTMB1-1:0] xtmb1_wdata; // Mapping array
  wire [MXXTMB1-1:0] xtmb1_rdata; // Mapping array

  assign xtmb1_wdata[29:0]  =  clct_counter[29:0];      // CLCTs sent to TMB section

// TMB match: store TMB match results in RAM mapping array
  parameter MXRTMB = 23;        // TMB match data bits
  wire [MXRTMB-1:0] rtmb_wdata; // Mapping array
  wire [MXRTMB-1:0] rtmb_rdata; // Mapping array

  assign rtmb_wdata[0]   = tmb_match;          // ALCT and CLCT matched in time
  assign rtmb_wdata[1]   = tmb_alct_only;      // Only ALCT triggered
  assign rtmb_wdata[2]   = tmb_clct_only;      // Only CLCT triggered
  assign rtmb_wdata[6:3] = tmb_match_win[3:0]; // Location of alct in clct window

  assign rtmb_wdata[7]   =  tmb_no_alct;       // No ALCT
  assign rtmb_wdata[8]   =  tmb_one_alct;      // One ALCT
  assign rtmb_wdata[9]   =  tmb_one_clct;      // One CLCT
  assign rtmb_wdata[10]  =  tmb_two_alct;      // Two ALCTs
  assign rtmb_wdata[11]  =  tmb_two_clct;      // Two CLCTs
  assign rtmb_wdata[12]  =  tmb_dupe_alct;     // ALCT0 copied into ALCT1 to make 2nd LCT
  assign rtmb_wdata[13]  =  tmb_dupe_clct;     // CLCT0 copied into CLCT1 to make 2nd LCT
  assign rtmb_wdata[14]  =  tmb_rank_err;      // LCT1 has higher quality than LCT0

  assign rtmb_wdata[15]  =  tmb_match_ro;      // ALCT and CLCT matched in time, non-triggering readout
  assign rtmb_wdata[16]  =  tmb_alct_only_ro;  // Only ALCT triggered, non-triggering readout
  assign rtmb_wdata[17]  =  tmb_clct_only_ro;  // Only CLCT triggered, non-triggering readout

  assign rtmb_wdata[18]  =  tmb_trig_pulse;    // TMB trig pulse agreed with rtmb_push
  assign rtmb_wdata[19]  =  tmb_trig_keep;     // TMB said keep triggering event
  assign rtmb_wdata[20]  =  tmb_non_trig_keep; // TMB said keep non-triggering event
  assign rtmb_wdata[21]  =  tmb_clct0_discard; // TMB discarded clct0 from ME1A
  assign rtmb_wdata[22]  =  tmb_clct1_discard; // TMB discarded clct1 from ME1A

// TMB match: store ALCTs sent to MPC in RAM mapping array, arrives same bx as tmb match result
  parameter MXALCTD = 11+11+5+2; // ALCT transmit frame data bits, 2alcts + bxn + tmb stats
  wire [MXALCTD-1:0] alct_wdata; // Mapping array
  wire [MXALCTD-1:0] alct_rdata; // Mapping array

  assign alct_wdata[10:0]  =  tmb_alct0[10:0]; // ALCT best muon latched at trigger
  assign alct_wdata[21:11] =  tmb_alct1[10:0]; // ALCT second best muon latched at trigger
  assign alct_wdata[26:22] =  tmb_alctb[4:0];  // ALCT shared bxn
  assign alct_wdata[28:27] =  tmb_alcte[1:0];  // ALCT ecc error syndrome latched at trigger

// TMB match+1bx: store TMB match results in RAM mapping array, 1bx later to give it time to count current event
  parameter MXRTMB1 = 37;         // Trigger counter
  wire [MXRTMB1-1:0] rtmb1_wdata; // Mapping array
  wire [MXRTMB1-1:0] rtmb1_rdata; // Mapping array

  assign rtmb1_wdata[29:0]  = trig_counter[29:0];   // TMB trigger counter
  assign rtmb1_wdata[36:30] = tmb_aff_list_ff[6:0]; // Active cfeb list at TMB match, saves 1 ram if put here

// MPC transmit: store MPC transmit frame data in RAM mapping array
  parameter MXXMPC = 64;        // MPC transmit frame data bits
  wire [MXXMPC-1:0] xmpc_wdata; // Mapping array
  wire [MXXMPC-1:0] xmpc_rdata; // Mapping array

  assign xmpc_wdata[15:0]  = mpc0_frame0_ff[15:0]; // MPC muon 0 frame 0
  assign xmpc_wdata[31:16] = mpc0_frame1_ff[15:0]; // MPC muon 0 frame 1
  assign xmpc_wdata[47:32] = mpc1_frame0_ff[15:0]; // MPC muon 1 frame 0
  assign xmpc_wdata[63:48] = mpc1_frame1_ff[15:0]; // MPC muon 1 frame 1

// MPC receive: store MPC response data in RAM mapping array
  parameter MXRMPC = 4;         // MPC receive data bits
  wire [MXRMPC-1:0] rmpc_wdata; // Mapping array
  wire [MXRMPC-1:0] rmpc_rdata; // Mapping array

  assign rmpc_wdata[1:0] = mpc_accept_ff[1:0];   // MPC muon accept response
  assign rmpc_wdata[3:2] = mpc_reserved_ff[1:0]; // MPC reserved

// L1A: store L1A results in RAM mapping array
  parameter MXL1AD = 32;             // L1A data bits
  wire [MXL1AD-1:0] l1a_wdata;       // Mapping array
  wire [MXL1AD-1:0] l1a_wdata_notmb; // Mapping array
  wire [MXL1AD-1:0] l1a_rdata;       // Mapping array

  wire [MXL1WIND-1:0] l1a_match_win;
  wire [MXL1ARX-1:0]  l1a_cnt_win;
  wire [MXBXN-1:0]    l1a_bxn_win;
  wire                l1a_push_me;
  wire                l1a_keep;
  wire                wr_avail_xl1a; // Buffer available at L1A match

  assign l1a_wdata[11:0]  = l1a_bxn_win[11:0];            // BXN at L1A arrival
  assign l1a_wdata[23:12] = l1a_cnt_win[11:0];            // L1As received at time of this event
  assign l1a_wdata[27:24] = l1a_match_win[3:0];           // Position of l1a in window
  assign l1a_wdata[28]    = l1a_push_me;                  // L1A with TMB in window, and readouts enabled
  assign l1a_wdata[29]    = l1a_notmb && l1a_allow_notmb; // L1A with no TMB in window, readout anyway
  assign l1a_wdata[30]    = tmb_nol1a && l1a_allow_nol1a; // TMB with no L1A arrival, readout anyway
  assign l1a_wdata[31]    = wr_avail_xl1a;                // Buffer available at L1A match

  assign l1a_wdata_notmb[11:0]  =  bxn_counter_l1a[11:0];        // BXN at L1A arrival, uses separate offset
  assign l1a_wdata_notmb[23:12] =  l1a_rx_counter_plus1[11:0];   // L1As received at time of this event
  assign l1a_wdata_notmb[27:24] =  0;                            // Position of l1a in window
  assign l1a_wdata_notmb[28]    =  l1a_push_me;                  // L1A with TMB in window, and readouts enabled
  assign l1a_wdata_notmb[29]    =  l1a_notmb && l1a_allow_notmb; // L1A with no TMB in window, readout anyway
  assign l1a_wdata_notmb[30]    =  tmb_nol1a && l1a_allow_nol1a; // TMB with no L1A arrival, readout anyway
  assign l1a_wdata_notmb[31]    =  wr_buf_avail;                 // Buffer available at L1A match

//------------------------------------------------------------------------------------------------------------------
// Pipeline arrays for wr_buf_adr to coincide with in data valid:
//------------------------------------------------------------------------------------------------------------------
  wire [MXBADR-1:0] wr_adr_xpre  = wr_buf_adr;       // Buffer write address at pre-trigger
  reg  [MXBADR-1:0] wr_adr_xpre1 = 0;                // Buffer write address at pre-trigger+1bx
  wire [MXBADR-1:0] wr_adr_xtmb  = clct_wr_adr_xtmb; // Buffer write address after drift
  reg  [MXBADR-1:0] wr_adr_xtmb1 = 0;                // Buffer write address after drift+1bx
  wire [MXBADR-1:0] wr_adr_rtmb;                     // Buffer write address at tmb reply
  reg  [MXBADR-1:0] wr_adr_rtmb1 = 0;                // Buffer write address at tmb reply+1bx
  wire [MXBADR-1:0] wr_adr_xmpc;                     // Buffer write address at mpc transmit
  wire [MXBADR-1:0] wr_adr_rmpc;                     // Buffer write address at mpc receive
  wire [MXBADR-1:0] wr_adr_xl1a;                     // Buffer write address at l1a match

  wire wr_push_xpre  = clct_push_pretrig; // Buffer write strobe at pre-trigger
  reg  wr_push_xpre1 = 0;                 // Buffer write strobe at pre-trigger+1bx
  wire wr_push_xtmb  = clct_push_xtmb;    // Buffer write strobe after drift time
  reg  wr_push_xtmb1 = 0;                 // Buffer write strobe after drift time+1bx
  wire wr_push_rtmb;                      // Buffer write strobe at TMB matching time
  reg  wr_push_rtmb1 = 0;                 // Buffer write strobe at tmb reply+1bx
  wire wr_push_xmpc;                      // Buffer write strobe at MPC xmit to sequencer
  wire wr_push_rmpc;                      // Buffer write strobe at MPC received

  wire wr_avail_xpre  = wr_buf_avail;       // Buffer available at pre-trigger
  reg  wr_avail_xpre1 = 0;                  // Buffer available at pre-trigger+1bx
  wire wr_avail_xtmb  = clct_wr_avail_xtmb; // Buffer available after drift time
  reg  wr_avail_xtmb1 = 0;                  // Buffer available after drift time+1bx
  wire wr_avail_rtmb;                       // Buffer available at TMB matching time
  reg  wr_avail_rtmb1 = 0;                  // Buffer available at tmb reply+1bx
  wire wr_avail_xmpc;                       // Buffer available at MPC xmit to sequencer
  wire wr_avail_rmpc;                       // Buffer available at MPC received
//  wire wr_avail_xl1a;                     // Buffer available at L1A match

// Piplelines delays for locally predictable coincidences
  always @(posedge clock) begin      // 1 bx delay FFs
    wr_adr_xpre1   <= wr_adr_xpre;   // pretrig + 1bx
    wr_push_xpre1  <= wr_push_xpre;  // pretrig + 1bx
    wr_avail_xpre1 <= wr_avail_xpre; // pretrig + 1bx

    wr_adr_xtmb1   <= wr_adr_xtmb;   // to tmb + 1bx
    wr_push_xtmb1  <= wr_push_xtmb;  // to tmb + 1bx
    wr_avail_xtmb1 <= wr_avail_xtmb; // to tmb + 1bx

    wr_adr_rtmb1   <= wr_adr_rtmb;   // tmb reply + 1bx
    wr_push_rtmb1  <= wr_push_rtmb;  // tmb reply + 1bx
    wr_avail_rtmb1 <= wr_avail_rtmb; // tmb reply + 1bx
  end

// Qualify buffer write strobes [0]=strobe,[1]=buffer available for writing
  wire   wr_en_xpre  = (wr_push_xpre  || clct_wr_continuous) && wr_avail_xpre;
  wire   wr_en_xpre1 = (wr_push_xpre1 || clct_wr_continuous) && wr_avail_xpre1;
  wire   wr_en_xtmb  = (wr_push_xtmb  || clct_wr_continuous) && wr_avail_xtmb;
  wire   wr_en_xtmb1 = (wr_push_xtmb1 || clct_wr_continuous) && wr_avail_xtmb1;
  assign wr_en_rtmb  = (wr_push_rtmb  || clct_wr_continuous) && wr_avail_rtmb;
  wire   wr_en_rtmb1 = (wr_push_rtmb1 || clct_wr_continuous) && wr_avail_rtmb1;
  wire   wr_en_xmpc  = (wr_push_xmpc  || clct_wr_continuous) && wr_avail_xmpc;
  wire   wr_en_rmpc  = (wr_push_rmpc  || clct_wr_continuous) && wr_avail_rmpc;

//------------------------------------------------------------------------------------------------------------------
// Header storage RAMs
//------------------------------------------------------------------------------------------------------------------
  wire [MXBADR-1:0] rd_buf_adr;            // Block RAM header readout address
  wire [8:0]        dang;                  // Block RAM dangling output pins
  wire              rd_enb = !buf_q_empty; // Enable port b for reading when readout in progress

// Store Buffer data on pretrigger
  ramblock #(MXXPRE, MXBADR) uramblock0 (.clock(clock),.wr_wea(wr_en_xpre ),.wr_adra(wr_adr_xpre ),.wr_dataa(xpre_wdata ),.rd_enb(rd_enb),.rd_adrb(rd_buf_adr),.rd_datab(xpre_rdata ),.dang(dang[0]));

// Store Buffer data on pretrigger + 1bx
  ramblock #(MXXPRE1,MXBADR) uramblock1 (.clock(clock),.wr_wea(wr_en_xpre1),.wr_adra(wr_adr_xpre1),.wr_dataa(xpre1_wdata),.rd_enb(rd_enb),.rd_adrb(rd_buf_adr),.rd_datab(xpre1_rdata),.dang(dang[1]));

// Store CLCT data post-drift on xtmb
  ramblock #(MXXTMB, MXBADR) uramblock2 (.clock(clock),.wr_wea(wr_en_xtmb ),.wr_adra(wr_adr_xtmb ),.wr_dataa(xtmb_wdata ),.rd_enb(rd_enb),.rd_adrb(rd_buf_adr),.rd_datab(xtmb_rdata ),.dang(dang[2]));

// Store CLCT counter post-drift on xtmb+1bx
  ramblock #(MXXTMB1,MXBADR) uramblock3 (.clock(clock),.wr_wea(wr_en_xtmb1),.wr_adra(wr_adr_xtmb1),.wr_dataa(xtmb1_wdata),.rd_enb(rd_enb),.rd_adrb(rd_buf_adr),.rd_datab(xtmb1_rdata),.dang(dang[3]));

// Store TMB match data + ALCT data on tmb_trig_pulse
  ramblock #(MXRTMB, MXBADR) uramblock4 (.clock(clock),.wr_wea(wr_en_rtmb ),.wr_adra(wr_adr_rtmb ),.wr_dataa(rtmb_wdata ),.rd_enb(rd_enb),.rd_adrb(rd_buf_adr),.rd_datab(rtmb_rdata ),.dang(dang[4]));
  ramblock #(MXALCTD,MXBADR) uramblock5 (.clock(clock),.wr_wea(wr_en_rtmb ),.wr_adra(wr_adr_rtmb ),.wr_dataa(alct_wdata ),.rd_enb(rd_enb),.rd_adrb(rd_buf_adr),.rd_datab(alct_rdata ),.dang(dang[5]));

// Store TMB trig counter on tmb_trig_pulse +1bx
  ramblock #(MXRTMB1,MXBADR) uramblock6 (.clock(clock),.wr_wea(wr_en_rtmb1),.wr_adra(wr_adr_rtmb1),.wr_dataa(rtmb1_wdata),.rd_enb(rd_enb),.rd_adrb(rd_buf_adr),.rd_datab(rtmb1_rdata),.dang(dang[6]));

// Store MPC transmit data
  ramblock #(MXXMPC, MXBADR) uramblock7 (.clock(clock),.wr_wea(wr_en_xmpc ),.wr_adra(wr_adr_xmpc ),.wr_dataa(xmpc_wdata ),.rd_enb(rd_enb),.rd_adrb(rd_buf_adr),.rd_datab(xmpc_rdata ),.dang(dang[7]));

// Store MPC received data on mpc_response
  ramblock #(MXRMPC, MXBADR) uramblock8 (.clock(clock),.wr_wea(wr_en_rmpc ),.wr_adra(wr_adr_rmpc ),.wr_dataa(rmpc_wdata ),.rd_enb(rd_enb),.rd_adrb(rd_buf_adr),.rd_datab(rmpc_rdata ),.dang(dang[8]));

//------------------------------------------------------------------------------------------------------------------
// Level 1 Accept Request Section
//------------------------------------------------------------------------------------------------------------------
// Request level 1 accept from CCB on tmb_trig_pulse
  reg seq_trigger=0;

  always @(posedge clock) begin
    seq_trigger <= tmb_trig_pulse && (tmb_trig_keep || tmb_non_trig_keep) && !seq_trigger;
  end

// Scintillator Veto for FAST sites, Assert veto on l1a request, persist until clear on VME, copy to VME
  reg  scint_veto     = 0;
  reg  scint_veto_vme = 0;
  wire scint_veto_clr_os;
  wire scint_pretrig  = clct_pretrig;

  x_oneshot uveto (.d(scint_veto_clr), .clock(clock), .q(scint_veto_clr_os));

  always @(posedge clock) begin
    if (scint_veto_clr_os) begin
      scint_veto     <= 0;
      scint_veto_vme <= 0;
    end
    else begin
      scint_veto     <= (scint_pretrig | scint_veto);
      scint_veto_vme <= (scint_pretrig | scint_veto);
    end
  end

//------------------------------------------------------------------------------------------------------------------
// Level 1 Accept Processing Section
//------------------------------------------------------------------------------------------------------------------
// Adjust l1a_delay to compensate for internal delay, makes l1a window open l1a_delay clocks after pretrig in clct_status
  reg [MXL1DELAY-1:0]  l1a_delay_adj=8'hFF;

  wire l1a_delay_limit = (l1a_delay < L1ADLYOFFSET);  // Dont let some schmoe to set it below the minimum

  always @(posedge clock) begin
  if (l1a_delay_limit) l1a_delay_adj <= L1ADLYOFFSET;                // Enforce minimum l1a delay
  else                 l1a_delay_adj <= l1a_delay - L1ADLYOFFSET[MXL1DELAY-1:0];  // Standard l1a offset
  end

// L1A parallel shifter write address increments every cycle, read address is later in time by l1a_delay
  reg [7:0]  l1a_delay_wadr=0;  
  reg [7:0]  l1a_delay_radr=8'hFF;

  always @(posedge clock) begin
    l1a_delay_wadr = l1a_delay_wadr + 1'b1;
    l1a_delay_radr = l1a_delay_wadr - l1a_delay_adj;
  end

// On TMB trigger, store event record in L1A shifter, FF required to align data before RAM write
  wire [15:0] l1a_dia;          // Port A data pushed by TMB
  wire [15:0] l1a_dob;          // Port B data out after L1A delay

  wire tmb_push = tmb_trig_pulse && (tmb_trig_keep || tmb_non_trig_keep) && !no_daq && wr_avail_rtmb;

  assign l1a_dia[0]    = tmb_push;
  assign l1a_dia[11:1]  = wr_adr_rtmb[10:0];
  assign l1a_dia[12]    = wr_avail_rtmb;
  assign l1a_dia[13]    = tmb_alct_only;
  assign l1a_dia[15:14] = 2'h0;

// L1A parallel shifter dual port RAM
//  Port A wo 18-bit event data
//  Port B ro 18-bit event data delayed ~128bx

  initial $display("sequencer: generating Virtex6 RAMB18E1_S18_S18 ul1abs");

  RAMB18E1 #(                          // Virtex6
    .RAM_MODE            ("TDP"),        // SDP or TDP
    .READ_WIDTH_A        (0),            // 0,1,2,4,9,18,36 Read/write width per port
    .WRITE_WIDTH_A       (18),           // 0,1,2,4,9,18
    .READ_WIDTH_B        (18),           // 0,1,2,4,9,18
    .WRITE_WIDTH_B       (0),            // 0,1,2,4,9,18,36
    .WRITE_MODE_A        ("READ_FIRST"), // WRITE_FIRST, READ_FIRST, or NO_CHANGE
    .WRITE_MODE_B        ("READ_FIRST"),
    .SIM_COLLISION_CHECK ("ALL")         // ALL, WARNING_ONLY, GENERATE_X_ONLY or NONE)
  ) ul1abs (
    .WEA           (2'b11),         //  2-bit A port write enable input
    .ENARDEN       (1'b1),          //  1-bit A port enable/Read enable input
    .RSTRAMARSTRAM (1'b0),          //  1-bit A port set/reset input
    .RSTREGARSTREG (1'b0),          //  1-bit A port register set/reset input
    .REGCEAREGCE   (1'b0),          //  1-bit A port register enable/Register enable input
    .CLKARDCLK     (clock),         //  1-bit A port clock/Read clock input
    .ADDRARDADDR   ({2'h0,l1a_delay_wadr[7:0],4'hF}), // 14-bit A port address/Read address input 18b->[13:4]
    .DIADI         (l1a_dia[15:0]), // 16-bit A port data/LSB data input
    .DIPADIP       (),              //  2-bit A port parity/LSB parity input
    .DOADO         (),              // 16-bit A port data/LSB data output
    .DOPADOP       (),              //  2-bit A port parity/LSB parity output

    .WEBWE         (),              //  4-bit B port write enable/Write enable input
    .ENBWREN       (1'b1),          //  1-bit B port enable/Write enable input
    .REGCEB        (1'b0),          //  1-bit B port register enable input
    .RSTRAMB       (1'b0),          //  1-bit B port set/reset input
    .RSTREGB       (1'b0),          //  1-bit B port register set/reset input
    .CLKBWRCLK     (clock),         //  1-bit B port clock/Write clock input
    .ADDRBWRADDR   ({2'h0,l1a_delay_radr[7:0],4'hF}),  // 14-bit B port address/Write address input 18b->[13:4]
    .DIBDI         (),              // 16-bit B port data/MSB data input
    .DIPBDIP       (),              //  2-bit B port parity/MSB parity input
    .DOBDO         (l1a_dob[15:0]), // 16-bit B port data/MSB data output
    .DOPBDOP       ()               //  2-bit B port parity/MSB parity output
  );                

// After ~128bx L1A delay, unpack data stored in L1A parallel shifter
  wire        tmb_push_dly      =   l1a_dob[0];
  wire [10:0] wr_adr_rtmb_dly   =   l1a_dob[11:1];
  wire        wr_avail_rtmb_dly =   l1a_dob[12];
  wire        tmb_alct_only_dly =   l1a_dob[13];
  wire        l1a_dob_sump      = | l1a_dob[15:14];

// Push TMB event token into a 16-stage FF shift register for L1A matching
  reg [15:0] l1a_vpf_sr=0;

  always @(posedge clock) begin
    l1a_vpf_sr[15:0] <= {l1a_vpf_sr[14:0],tmb_push_dly};
  end

// Push event address into 16-stage SRL shifter
  wire [MXBADR-1+1:0] xl1a_wdata;
  wire [MXBADR-1+1:0] xl1a_rdata;
  reg  [MXL1WIND-1:0] winclosed=3;

  assign xl1a_wdata[10:0] = wr_adr_rtmb_dly;
  assign xl1a_wdata[11]   = wr_avail_rtmb_dly;

  srl16e_bbl #(MXBADR+1) usrl1a (.clock(clock),.ce(1'b1),.adr(winclosed),.d(xl1a_wdata),.q(xl1a_rdata));

  assign wr_adr_xl1a   = xl1a_rdata[10:0];
  assign wr_avail_xl1a = xl1a_rdata[11];

// FF buffer l1a_window index for fanout, points to 1st position window is closed 
  always @(posedge clock) begin
    winclosed <= l1a_window;
  end

// L1A window preset and clear ffs
  reg preset_sr = 0;
  reg clear_sr  = 0;

  always @(posedge clock) begin
    preset_sr <= l1a_preset_sr;
    clear_sr  <= ttc_resync;
  end

// Decode L1A window width setting to select which l1a_vpf_sr stages to include in l1a_window
  reg [15:0]  l1a_sr_include=0;
  integer i;

  always @(posedge clock) begin
    if      (preset_sr) l1a_sr_include <= 16'hFFFF;
    else if (clear_sr ) l1a_sr_include <= 0;

    else begin
      i=0;
      while (i<=15) begin
        if (l1a_window!=0)
          l1a_sr_include[i] <= (i<=l1a_window-1);  // l1a_window=3, enables sr stages 0,1,2
        else
          l1a_sr_include[i] <= 0;          // l1a_window=0, disables all sr stages
        i=i+1;
      end  // close while
    end  // close else
  end  // close clock

// Calculate dynamic L1A window center and positional priorities
  reg  [3:0] l1a_win_priority [15:0];
  wire [3:0] l1a_win_center = l1a_window/2;  // Gives priority to higher winbx for even widths

  always @(posedge clock) begin
    i=0;
    while (i<=15) begin
      if      (ttc_resync           ) l1a_win_priority[i] = 4'hF;
      else if (i>=l1a_window || i==0) l1a_win_priority[i] = 0;                  // i >  lastwin or i=0
      else if (i<=l1a_win_center    ) l1a_win_priority[i] = l1a_window-1'd1-((l1a_win_center-i[3:0])<<1);  // i <= center
      else                            l1a_win_priority[i] = l1a_window-1'd0-((i[3:0]-l1a_win_center)<<1);  // i >  center
      i=i+1;
    end
  end

// Window position delay for internal L1A, 0bx to 16bx for simulator
  wire [3:0] ldly = l1a_internal_dly[3:0];

  SRL16E usrlint (.CLK(clock),.CE(1'b1),.D(tmb_push_dly),.A0(ldly[0]),.A1(ldly[1]),.A2(ldly[2]),.A3(ldly[3]),.Q(l1a_internal_pulse));

// Construct L1A from CCB or internal, internal L1A disables CCB L1A, if internal l1a, delay pulse only for status displays
  wire   l1a_ccb      = ccb_l1accept && !l1a_internal;
  wire   l1a_int      = l1a_internal && l1a_internal_pulse;
  assign l1a_pulse    = l1a_ccb || l1a_int;
  assign l1a_received = l1a_pulse;
  
// L1A window matching register declarations
  reg [15:0] l1a_tag_sr = 0;    // Readout tag
  reg [3:0]  l1a_win_sr [15:0]; // L1A Window position at LCT*L1A coincidence, init=1 removes spurious warnings
  reg [11:0] l1a_cnt_sr [15:0]; // L1As received counter at LCT*L1A coincidence
  reg [11:0] l1a_bxn_sr [15:0]; // BXN counter at LCT*L1A coincidence
  reg [15:0] l1a_see_sr = 0;    // L1A seen by this event

// Generate table of enabled L1A windows and their priorities
  wire [15:0] win_ena;        // Table of enabled window positions
  wire [3:0]  win_pri [15:0]; // Table of window position priorities that are enabled

  generate              // Table window priorities multipled by window position enables
    for (j=0; j<=15; j=j+1) begin: genpri
      assign win_ena[j] = (l1a_sr_include[j]==1 && l1a_vpf_sr[j]==1 && l1a_tag_sr[j]==0);
      assign win_pri[j] = (l1a_win_priority[j]  & {4{win_ena[j]}});
    end
  endgenerate

// Tree encoder Finds best 4 of 16 window positions
  wire [0:0] win_s0  [7:0];
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

// Parallel encoder finds best 1-of-4 window positions
  reg  [3:0] win_s2 [0:0];
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

  wire [3:0] l1a_win_best = win_s2[0];
  wire [3:0] l1a_pri_best = pri_s2[0];

// Local copy of l1a window priorty mode give 6% speed increase in SR logic
  reg nl1a_win_pri_en=0;

  always @(posedge clock) begin
    nl1a_win_pri_en <= !l1a_win_pri_en;
  end

// L1A window lost events due to prioritizing
  always @(posedge clock) begin
    if      (preset_sr) l1a_see_sr <= 1;
    else if (clear_sr ) l1a_see_sr <= 0;

    else begin
      i=0;
      while (i<=14) begin
        if (l1a_match && l1a_vpf_sr[i] && l1a_sr_include[i] && !l1a_tag_sr[i]) l1a_see_sr[i+1] <= 1;
        else                                                                   l1a_see_sr[i+1] <= l1a_see_sr[i];
        i=i+1;
      end  // close while
    end  // close else
  end  // close clock

// L1A window matching shift registers
  always @(posedge clock) begin

    if (preset_sr) begin              // Sych preset 1st stage
      l1a_tag_sr          <= 1;       // Readout tag
      l1a_win_sr[0][3:0]  <= 4'hF;    // L1A Window position at LCT*L1A coincidence
      l1a_cnt_sr[0][11:0] <= 12'hFFF; // L1As received counter at LCT*L1A coincidence
      l1a_bxn_sr[0][11:0] <= 12'hFFF; // BXN counter  at LCT*L1A coincidence
    end

    else if (clear_sr) begin      // Sych reset all stages
      i=0;                // Loop over 15 window positions 0 to 15 
      while (i<=15) begin
        l1a_tag_sr          <= 0; // Readout tag
        l1a_win_sr[i][3:0]  <= 0; // L1A Window position at LCT*L1A coincidence
        l1a_cnt_sr[i][11:0] <= 0; // L1As received counter at LCT*L1A coincidence
        l1a_bxn_sr[i][11:0] <= 0; // BXN counter  at LCT*L1A coincidence
        i=i+1;
      end
    end

    else begin
      i=0;                // Loop over 15 window positions 0 to 14 
      while (i<=14) begin
        if (l1a_match && l1a_vpf_sr[i] && l1a_sr_include[i] && !l1a_tag_sr[i] && ((l1a_win_best==i) || nl1a_win_pri_en)) begin
          l1a_tag_sr[i+1]       <= 1;                          // Readout tag
          l1a_win_sr[i+1][3:0]  <= i[3:0];                     // L1A Window position at LCT*L1A coincidence
          l1a_cnt_sr[i+1][11:0] <= l1a_rx_counter_plus1[11:0]; // L1As received counter at LCT*L1A coincidence
          l1a_bxn_sr[i+1][11:0] <= bxn_counter_l1a[11:0];      // BXN counter at LCT*L1A coincidence, has separate offset
        end  // close if l1a_match

        else begin // Otherwise parallel shift all data left
          l1a_tag_sr[i+1] <= l1a_tag_sr[i];
          l1a_win_sr[i+1] <= l1a_win_sr[i];
          l1a_cnt_sr[i+1] <= l1a_cnt_sr[i];
          l1a_bxn_sr[i+1] <= l1a_bxn_sr[i];
        end  // close else

        i=i+1;
      end  // close while
    end  // close else
  end  // close clock

// Extract pushed counters and match results from sr stage after window closed
  assign tmb_push_sr   = l1a_vpf_sr[winclosed];      // TMB token emerges from last window position 1bx before tag
  assign l1a_push_me   = l1a_tag_sr[winclosed];      // Push this event into L1A queue as it exits last window bx
  assign l1a_match_win = l1a_win_sr[winclosed];
  assign l1a_cnt_win   = l1a_cnt_sr[winclosed];
  assign l1a_bxn_win   = l1a_bxn_sr[winclosed];
  assign l1a_see_win   = l1a_see_sr[winclosed];

// L1A window width is generated by a pulse propagating down the enabled l1a_vpf_sr stages  
  assign l1a_window_open    = |(l1a_vpf_sr & l1a_sr_include);
  assign l1a_window_haslcts = |(l1a_vpf_sr & l1a_sr_include & ~l1a_tag_sr);

// L1A Match results
  assign l1a_match   = l1a_pulse   &&  l1a_window_haslcts; // TMB trig_pulse matches L1A window, sent before window close
  assign l1a_notmb   = l1a_pulse   && !l1a_window_haslcts; // L1A arrived, but there was no TMB window open
  assign tmb_nol1a   = tmb_push_sr && !l1a_push_me;        // No L1A arrived in window, sent after window close
  assign l1a_los_win = l1a_see_win && !l1a_push_me;        // Event saw an L1A but was not pushed beco

// Diagnostic L1A cases force a readout without L1A matching, if enabled. Usually not enabled
  wire l1a_forced_notmb =(l1a_notmb && l1a_allow_notmb && !no_daq);  // L1A with no TMB in window, readout anyway
  wire l1a_forced_nol1a =(tmb_nol1a && l1a_allow_nol1a && !no_daq);  // TMB with no L1A arrival, readout anyway

  assign l1a_forced = l1a_forced_notmb || l1a_forced_nol1a;

// DAV signal to DMB is asserted as soon as L1A arrives, forced cases with no match are sent on window close
  assign l1a_keep = (tmb_push_sr && l1a_push_me && l1a_allow_match) || l1a_forced;// At window close
  assign dmb_dav  = (l1a_match && l1a_allow_match                 ) || l1a_forced;// At L1A match before window close

// Push event address into fence queue to protect raw hits and queue for readout to DMB
  reg [MXBADR-1:0]  buf_push_adr  = 0;          // Address of write buffer to allocate  
  reg [MXBDATA-1:0]  buf_push_data = 0;          // Data associated with push_adr

  assign buf_push  = l1a_keep;                // Allocate write buffer space for this event

  always @* begin
    if (l1a_forced_notmb) begin                     // No-tmb-trigger l1a-only readout
      buf_push_adr  <= wr_buf_adr-l1a_lookback;     // Address of write buffer to allocate is current-lookback
      buf_push_data <= l1a_wdata_notmb[MXL1AD-1:0]; // L1A data associated with push_adr when no tmb trigger
    end
    else begin                                 // Normal tmb-triggered readout
      buf_push_adr  <= wr_adr_xl1a;            // Address of write buffer to allocate
      buf_push_data  <= l1a_wdata[MXL1AD-1:0]; // L1A data associated with push_adr
    end
  end

// Pop event off of fence queue after readout completes
  assign buf_pop     = (read_sm == xpop) && !xpop_done;  // Specified buffer is to be released
  assign buf_pop_adr = buf_queue_adr;            // Address of read buffer to release
  assign rd_buf_adr  = buf_queue_adr;            // Current multi-buffer storage address for readout
  assign l1a_rdata   = buf_queue_data;          // L1A data associated with push_adr

// Save bxn at L1A regardless of match
  reg  [MXBXN-1:0] bxn_l1a_vme=0;

  always @(posedge clock) begin
    if (l1a_received) bxn_l1a_vme <= bxn_counter_l1a;
  end

// VME debug register latches
  reg  [MXBADR-1:0] deb_wr_buf_adr    = 0;
  reg [MXBADR-1:0]  deb_buf_push_adr  = 0;
  reg [MXBADR-1:0]  deb_buf_pop_adr   = 0;
  reg [MXBDATA-1:0] deb_buf_push_data = 0;
  reg [MXBDATA-1:0] deb_buf_pop_data  = 0;

  always @(posedge clock) begin
    if (clct_push_pretrig)
    deb_wr_buf_adr    <=  wr_buf_adr; // Buffer address at last pretrig
  end

  always @(posedge clock) begin
    if (buf_push) begin
      deb_buf_push_adr  <=  buf_push_adr;  // Address of write buffer to allocate at last push
      deb_buf_push_data <=  buf_push_data; // L1A data associated with push_adr at last push
    end
  end

  always @(posedge clock) begin
    if (buf_pop) begin
      deb_buf_pop_adr    <=  buf_pop_adr; // Buffer pop address at last xpop
      deb_buf_pop_data  <=  l1a_rdata;    // Buffer pop data at last xpop
    end
  end

//------------------------------------------------------------------------------------------------------------------
// Unpack multi-buffer storage for event header
//------------------------------------------------------------------------------------------------------------------
// Unpack Pre-trigger data from RAM mapping array
  wire [6:0]  r_active_feb       = xpre_rdata[6:0];   // Active FEB list sent to DAQMB
  wire [10:0] r_trig_source_vec  = xpre_rdata[17:7];  // Trigger source vector
  wire [11:0] r_bxn_counter      = xpre_rdata[29:18]; // Full Bunch Crossing number at pretrig
  wire [29:0] r_orbit_counter    = xpre_rdata[59:30]; // Orbit count at pre-trigger
  wire        r_sync_err         = xpre_rdata[60];    // BXN sync error
  wire [3:0]  r_alct_preClct_win = xpre_rdata[64:61]; // ALCT active_feb_flag position in pretrig window

  wire [10:0] r_wr_buf_adr       = xpre_rdata[75:65]; // Address of write buffer at pretrig
  wire [10:0] r_buf_fence_dist   = xpre_rdata[86:76]; // Distance to 1st fence address at pretrigger
  wire        r_wr_buf_avail     = xpre_rdata[87];    // Write buffer is ready or bypassed
  wire        r_wr_buf_ready     = xpre_rdata[88];    // Write buffer is ready
  wire        r_buf_stalled      = xpre_rdata[89];    // All buffer memory space is in use

// Unpack Pre-trigger +1bx data from RAM mapping array
  wire [29:0] r_pretrig_counter  = xpre1_rdata[29:0];  // Pre-trigger counter
  wire [29:0] r_alct_counter     = xpre1_rdata[59:30]; // ALCT counter at pre-trigger

// Unpack CLCT data sent to TMB from RAM mapping array
  wire [15:0] r_clct0_xtmb = xtmb_rdata[15:0];  // CLCT0 after drift
  wire [15:0] r_clct1_xtmb = xtmb_rdata[31:16]; // CLCT1 after drift
  wire [2:0]  r_clctc_xtmb = xtmb_rdata[34:32]; // CLCT common after drift
  wire [6:0]  r_clcta_xtmb = xtmb_rdata[41:35]; // CLCT aux after drift
  wire        r_clct0_invp = xtmb_rdata[42];    // CLCT0 had invalid pattern after drift delay
  wire        r_clct1_invp = xtmb_rdata[43];    // CLCT1 had invalid pattern after drift delay

  wire [5:0] r_layers_hit = r_clcta_xtmb[5:0]; // Layers hit
  wire       r_clct1_busy = r_clcta_xtmb[6];   // CLCT1 busy internal check

// Unpack CLCT counter from RAM mapping array
  wire [29:0] r_clct_counter = xtmb1_rdata[29:0]; // CLCTs sent to TMB section

// Unpack TMB match results from RAM mapping array
  wire       r_tmb_match     =  rtmb_rdata[0];   // ALCT and CLCT matched in time
  wire       r_tmb_alct_only =  rtmb_rdata[1];   // Only ALCT triggered
  wire       r_tmb_clct_only =  rtmb_rdata[2];   // Only CLCT triggered
  wire [3:0] r_tmb_match_win =  rtmb_rdata[6:3]; // Location of alct in clct window

  wire     r_tmb_no_alct    =  rtmb_rdata[7];    // No ALCT
  wire     r_tmb_one_alct    =  rtmb_rdata[8];    // One ALCT
  wire     r_tmb_one_clct    =  rtmb_rdata[9];    // One CLCT
  wire     r_tmb_two_alct    =  rtmb_rdata[10];    // Two ALCTs
  wire     r_tmb_two_clct    =  rtmb_rdata[11];    // Two CLCTs
  wire     r_tmb_dupe_alct    =  rtmb_rdata[12];    // ALCT0 copied into ALCT1 to make 2nd LCT
  wire     r_tmb_dupe_clct    =  rtmb_rdata[13];    // CLCT0 copied into CLCT1 to make 2nd LCT
  wire     r_tmb_rank_err    =  rtmb_rdata[14];    // LCT1 has higher quality than LCT0

  wire    r_tmb_match_ro    =  rtmb_rdata[15];    // ALCT and CLCT matched in time, non-triggering readout
  wire    r_tmb_alct_only_ro  =  rtmb_rdata[16];    // Only ALCT triggered, non-triggering readout
  wire    r_tmb_clct_only_ro  =  rtmb_rdata[17];    // Only CLCT triggered, non-triggering readout

  wire    r_tmb_trig_pulse  =  rtmb_rdata[18];    // TMB trig pulse agreed with rtmb_push
  wire    r_tmb_trig_keep    =  rtmb_rdata[19];    // TMB said keep triggering event
  wire    r_tmb_non_trig_keep  =  rtmb_rdata[20];    // TMB said keep non-triggering event

  wire    r_tmb_clct0_discard  =  rtmb_rdata[21];    // TMB discarded clct0 from ME1A
  wire    r_tmb_clct1_discard  =  rtmb_rdata[22];    // TMB discarded clct1 from ME1A

// Unpack ALCT + extra TMB trigger data from RAM mapping array
  wire [10:0]  r_tmb_alct0      =  alct_rdata[10:0];  // ALCT0
  wire [10:0]  r_tmb_alct1      =  alct_rdata[21:11];  // ALCT1
  wire [4:0]  r_tmb_alctb      =  alct_rdata[26:22];  // ALCT bxn
  wire [1:0]  r_tmb_alcte      =  alct_rdata[28:27];  // ALCT ecc error syndrome latched at trigger

  wire      r_alct0_valid  =  r_tmb_alct0[0];    // Valid pattern flag
  wire  [1:0]  r_alct0_quality  =  r_tmb_alct0[2:1];  // Pattern quality
  wire      r_alct0_amu    =  r_tmb_alct0[3];    // Accelerator muon
  wire  [6:0]  r_alct0_key    =  r_tmb_alct0[10:4];  // Key Wire Group

  wire      r_alct1_valid  =  r_tmb_alct1[0];    // Valid pattern flag
  wire  [1:0]  r_alct1_quality  =  r_tmb_alct1[2:1];  // Pattern quality
  wire      r_alct1_amu    =  r_tmb_alct1[3];    // Accelerator muon
  wire  [6:0]  r_alct1_key    =  r_tmb_alct1[10:4];  // Key Wire Group

  wire  [4:0]  r_alct_bxn    =  r_tmb_alctb[4:0];  // ALCT bunch crossing number
  wire  [1:0]  r_alct_ecc_err  =  r_tmb_alcte[1:0];  // ALCT ecc error syndrome code

// Unpack TMB match results from RAM mapping array that was delayed 1bx
  wire [29:0]  r_trig_counter    =  rtmb1_rdata[29:0];  // TMB trigger counter
  wire [6:0]  r_tmb_aff_list    =  rtmb1_rdata[36:30];  // Active cfeb list at TMB match, saves 1 ram

// Unpack MPC transmit frame data from RAM mapping array
  wire [15:0]  r_mpc0_frame0_ff  =  xmpc_rdata[15: 0];  // MPC muon 0 frame 0
  wire [15:0]  r_mpc0_frame1_ff  =  xmpc_rdata[31:16];  // MPC muon 0 frame 1
  wire [15:0]  r_mpc1_frame0_ff  =  xmpc_rdata[47:32];  // MPC muon 1 frame 0
  wire [15:0]  r_mpc1_frame1_ff  =  xmpc_rdata[63:48];  // MPC muon 1 frame 1

// Unpack MPC response data from RAM mapping array
  wire [1:0]  r_mpc_accept    =  rmpc_rdata[1:0];  // MPC muon accept response
  wire [1:0]  r_mpc_reserved    =  rmpc_rdata[3:2];  // MPC reserved

// Unpack L1A mach data from RAM mapping array
  wire [11:0]  r_l1a_bxn_win    =  l1a_rdata[11:0];  // BXN at L1A arrival
  wire [11:0]  r_l1a_cnt_win    =  l1a_rdata[23:12];  // L1As received at time of this event
  wire [3:0]  r_l1a_match_win    =  l1a_rdata[27:24];  // Position of l1a in window
  wire    r_l1a_push_me    =  l1a_rdata[28];    // L1A with TMB in window, and readouts enabled
  wire    r_l1a_notmb      =  l1a_rdata[29];    // L1A with no TMB in window, readout anyway
  wire    r_tmb_nol1a      =  l1a_rdata[30];    // TMB with no L1A arrival, readout anyway
  wire    r_l1a_match      =  r_l1a_push_me;    // Alias
  wire    r_wr_avail_xl1a    =  l1a_rdata[31];    // Buffer available at L1A match

// L1A pop type code indicates buffer data available for this L1A
  reg [1:0] l1a_type = 1;

  always @(posedge clock) begin
  if    (r_l1a_match)    l1a_type = 0;  // CLCT trig with buffers and L1A window match
  else if  (r_tmb_alct_only)  l1a_type = 1;  // ALCT-only trig, clct data is undefined
  else if (r_l1a_notmb)    l1a_type = 2;  // L1A-only, TMB did not trigger
  else if (r_tmb_nol1a)    l1a_type = 3;  // TMB trigger no L1A with buffers
  else            l1a_type = 1;  // Error
  end

// Readout type code depends on selected FIFO mode and whether event buffer data exists
  reg [1:0] readout_type = 0;          

  wire  r_has_buf    = r_wr_avail_xl1a;
  wire  r_has_hdr    = r_wr_avail_xl1a && (!r_l1a_notmb || clct_wr_continuous);

  wire  header_only    = (fifo_mode == 0) &&  r_has_buf;  // fifo_mode 0: dump: No  header: Full
  wire  full_dump    = (fifo_mode == 1) &&  r_has_buf;  // fifo_mode 1: dump: Full  header: Full
  wire  local_dump    = (fifo_mode == 2) &&  r_has_buf;  // fifo_mode 2: dump: Local  header: Full
  wire  short_header  = (fifo_mode == 3) || !r_has_buf;  // fifo_mode 3: dump: No  header: Short
  assign  no_daq      = (fifo_mode == 4);          // fifo_mode 4: dump: No  header: No
  wire  fifo_dump    = full_dump || local_dump;

  wire  sync_err_hdr  = (r_has_hdr) ? r_sync_err    : sync_err;
  wire  buf_stalled_hdr  = (r_has_hdr) ? r_buf_stalled : buf_stalled;
  
  always @(posedge clock) begin
  if    (!full_dump && !local_dump &&  header_only ) readout_type = 0;  // dump: No  header: Full
  else if  ( full_dump && !local_dump && !header_only ) readout_type = 1;  // dump: Full  header: Full
  else if (!full_dump &&  local_dump && !header_only ) readout_type = 2;  // dump: Local  header: Full
  else if (!full_dump && !local_dump &&  short_header) readout_type = 3;  // dump: No  header: Short
  else                         readout_type = 0;  // no daq
  end

// Determine active_feb list source, pretrig or at TMB match
  wire [MXCFEB-1:0] active_feb_mux;
  
  assign active_feb_mux = (active_feb_src) ? r_tmb_aff_list : r_active_feb;
  
// Latch FIFO list of hit FEBs, set all for full dump, clear all for no dump
  always @* begin
  if      (full_dump ) cfebs_read = {MXCFEB{1'b1}};
  else if (local_dump) cfebs_read = active_feb_mux[MXCFEB-1:0];
  else                 cfebs_read = 0;
  end

// Calculate number of CFEBs in readout, use ROM lookup instead of adders
  wire [MXCFEBB-1:0] ncfebs;

//  assign ncfebs =  cfebs_read[0]+cfebs_read[1]+cfebs_read[2]+cfebs_read[3]+cfebs_read[4]+cfebs_read[5]+cfebs_read[6];
  assign ncfebs =  count1sof7(cfebs_read[6:0]);

// Substitute short-header for non buffer events
  wire [NHBITS-1:0]  r_nheaders;
  wire [MXTBIN-1:0]  r_fifo_tbins_cfeb;
  wire [MXCFEBB-1:0]  r_ncfebs;
  wire        r_fifo_dump;
  wire [MXCFEB-1:0]  r_cfebs_read;
  wire [3:0]      eef;

  reg  [MXRPCB-1+1:0]  rd_nrpcs=0;
  wire [MXRPCB-1+1:0]  r_nrpcs_read;

  wire include_rawhits  = r_has_buf && (full_dump || local_dump);
  wire include_cfebs    = include_rawhits && (ncfebs!=0);
  wire include_rpcs    = include_rawhits && rpc_read_enable;

  assign r_nheaders    = (short_header ) ? MNHD[NHBITS-1:0]: MXHD[NHBITS-1:0];  // Number of header words
  assign eef        = (short_header ) ? 4'hE      : 4'h0;        // E0F if have buffers, EEF if no buffer

  assign r_fifo_tbins_cfeb= (include_cfebs) ? fifo_tbins_cfeb : 1'd0;  // Number of time bins in CLCT fifo dump
  assign r_ncfebs      = (include_cfebs) ? ncfebs        : 1'd0;  // Number of CFEBs read
  assign r_cfebs_read    = (include_cfebs) ? cfebs_read     : 1'd0;  // CFEBs in readout list
  assign r_nrpcs_read    = (include_rpcs ) ? rd_nrpcs    : 1'd0;  // RPCs  in readout list

  assign r_fifo_dump    = fifo_dump && (r_ncfebs!=0);        // No CFEB raw hits if no cfebs hit

//------------------------------------------------------------------------------------------------------------------
// Readout Sequencing Section
//------------------------------------------------------------------------------------------------------------------
// Header word counter
  wire [NHBITS-1:0]  last_header;
  wire        header_done;

  always @(posedge clock) begin
  if    (read_sm != xheader) header_cnt = 0;          // sync clear
  else if (read_sm == xheader) header_cnt = header_cnt + 1'b1;  // sync count
  end

  assign last_header = r_nheaders-1'b1;              // avoid underflow error if r_nheaders=0
  assign header_done = (header_cnt == last_header);

// DMB transmission frame counter
  reg [NFCBITS-1:0] frame_cnt=0;

  wire frame_cnt_ena = (read_sm != xckstack) && (read_sm !=xpop) && (read_sm != xhalt) ;

  always @(posedge clock) begin
  if    (read_sm == xdmb) frame_cnt = 1;            // sync load
  else if  (frame_cnt_ena  ) frame_cnt = frame_cnt + 1'b1;      // sync count
  end

// Add 6-word or 4-word trailer to make word count a multiple of 4
  wire mod4 = (frame_cnt[1:0] == 0);

// DMB transmission CRC calculation
  wire  [21:0]  crc;
  reg    [21:0]  crc_ff=0;
  wire  [15:0]  crc_data;
  wire      crc_reset;
  wire      crc_latch;

  assign crc_data[15:0]  = dmb_ff[15:0];          // TMB output frame
  assign crc_reset    = dmb_ff[18];          // _wr_fifo
  assign crc_latch    = (read_sm == xcrc0);      // Latch crc on 2nd frame before 1st crc word

  crc22a ucrc22a
  (
  .clock  (clock),
  .data  (crc_data[15:0]),
  .reset  (crc_reset),
  .crc  (crc[21:0])
  );

  always @(posedge clock) begin
  if    (crc_reset) crc_ff <= 0;
  else if  (crc_latch) crc_ff <= crc;
  end

// Fence queue pop wait 1bx for RAM access
  always @(posedge clock) begin
  if (read_sm != xpop) xpop_done <= 0;
  else         xpop_done <= 1;
  end

// Startup delay waits for buf_q_empty to update after a reset
  reg xstartup_done = 0;
  
  always @(posedge clock) begin
  xstartup_done <= (read_sm==xstartup);
  end

// Readout State Machine
  always @(posedge clock or posedge sm_reset) begin
  if    (sm_reset  ) read_sm = xstartup;
  else if  (ttc_resync) read_sm = xstartup;
  else begin
  case (read_sm)
  xstartup:              // Wait in startup for buf_q_empty to update after a reset
    if (xstartup_done)
    read_sm = xckstack;

  xckstack:              // Idling, waiting for stack data
    if (!buf_q_empty && !sync_err_stops_readout)
    read_sm = xdmb;          // Data available

  xdmb:                // Begin send to dmb
    read_sm = xheader;

// Header
  xheader:              // Send header to DMB
    if (header_done) begin
     if (short_header)
     read_sm = xe0f;
     else
     read_sm = xe0b;
    end

  xe0b:                // Send EOB marker at end of header
    if (r_fifo_dump)
    read_sm = xdump;        // Full or Local dump selected and ncfebs!=0
    else
    read_sm = xe0c;          // No dump selected or had no buffers

// CFEBs
  xdump:                // Send fifo dump to DMB
    if (fifo_read_done)  begin    // Wait for clct fifo done
     if (rpc_read_enable)
     read_sm = xb04;        // Read RPCs if enabled
     else if (scp_auto)
     read_sm = xb05;        // Skip to scope, if enabled
     else if (mini_read_enable)
     read_sm = xb07;        // Skip to miniscope, if enabled
     else if (bcb_read_enable)
     read_sm = xbcb;        // Skip blocked cfeb bits, if enabled
     else
     read_sm = xe0c;        // Otherwise go to eoc
    end

// RPCs
  xb04:                // Send b04 fram to begin RPC
    if (rpcs_all_empty)        // Don't read rpc fifo if all RPCs empty
    read_sm = xe04;
    else
    read_sm = xrpc;

  xrpc:                // Send RPC frames
    if (rpc_fifo_done)
    read_sm = xe04;

  xe04:                // Send e04 frame to end RPC
    if (scp_auto)
    read_sm = xb05;          // Skip to scope, if enabled
    else if (mini_read_enable)
    read_sm = xb07;          // Skip to miniscope, if enabled
    else if (bcb_read_enable)
    read_sm = xbcb;          // Skip blocked cfeb bits, if enabled
    else
    read_sm = xe0c;

// Scope
  xb05:                // Send B05 frame to begin scope
    if (scp_read_done)        // Scope had no data or did not trigger
    read_sm = xe05;
    else
    read_sm = xscope;        // Scope has data

  xscope:                // Send scope frames
    if (scp_read_done)
    read_sm = xe05;

  xe05:                // Send e05 frame to end scope
    if (mini_read_enable)
    read_sm = xb07;          // Skip to miniscope, if enabled
    else if (bcb_read_enable)
    read_sm = xbcb;          // Skip blocked cfeb bits, if enabled
    else
    read_sm = xe0c;

// Miniscope
  xb07:                // Send B07 frame to begin miniscope
    read_sm = xmini;

  xmini:                // Send miniscope frames
    if (mini_fifo_done)
    read_sm = xe07;

  xe07:                // Send e07 frame to end miniscope
    if (bcb_read_enable)
    read_sm = xbcb;          // Skip to blocked cfeb bits, if enabled
    else
    read_sm = xe0c;

// Blocked CFEB bits
  xbcb:                // Send BCB frame to begin blocked cfeb bits
    read_sm = xblkbit;

  xblkbit:              // Send blocked cfeb bits frames
    if (bcb_fifo_done)
    read_sm = xecb;

  xecb:                // Send ecb frame to end blocked cfeb bits
    read_sm = xe0c;

// Filler
  xe0c:                // Send E0C marker to force even word count
    if (mod4)            // Word count is already a multiple of 4
    read_sm = xe0f;
    else              // Word count is only even, need to add 2 frames
    read_sm = xmod40;

  xmod40:                // Send 1st of 2 frames to make wordcount multiple of 4  
    read_sm = xmod41;

  xmod41:                // Send 2nd of 2 frames to make wordcount multiple of 4  
    read_sm = xe0f;

// CRC
  xe0f:                // Send e0f frame
    read_sm = xcrc0;

  xcrc0:                // Send 1s of 2 crc frames
    read_sm = xcrc1;  

  xcrc1:                // Send 1s of 2 crc frames
    read_sm = xlast;  

// Trailer
  xlast:                // Send last word to DMB
    if (pretrig_halt)        // Pretrig_halt mode
    read_sm = xhalt;
    else              // Pop data off stack
    read_sm = xpop;          

  xpop:                // Pop data off stack, go back to idle
    if (xpop_done)
    read_sm = xckstack;

  xhalt:                // Halted, wait for resume
    if (!pretrig_halt)        // Resume arrived by toggling pretrig_halt dipswitch
    read_sm = xpop;

  default
    read_sm = xckstack;

  endcase
  end
  end

//------------------------------------------------------------------------------------------------------------------
// Readout Header Format Section
// Total number of header words must be even, and a multiple of 4, minus 2 (for e0b and e0c)
//------------------------------------------------------------------------------------------------------------------
  wire [2:0] ddu_code = 3'b101;                // DDU code for TMB/ALCT

// First 4 header words must conform to DDU specification
  assign  header00_[11:0]    =  12'hB0C;          // Beginning of Cathode record marker
  assign  header00_[14:12]  =  ddu_code[2:0];        // DDU code for TMB/ALCT
  assign  header00_[15]    =  1;              // DDU special
  assign  header00_[16]    =  0;              // DMB last
  assign  header00_[17]    =  1;              // DMB dav, dmbs copy is generated earlier at l1a
  assign  header00_[18]    =  0;              // DMB /wr

  assign  header01_[11:0]    =  r_l1a_bxn_win[11:0];     // BXN pushed on L1A stack at L1A arrival
  assign  header01_[14:12]  =  ddu_code[2:0];        // DDU code for TMB/ALCT
  assign  header01_[15]    =  1;              // DDU special
  assign  header01_[18:16]  =  0;              // DMB control flags

  assign  header02_[11:0]    =  r_l1a_cnt_win[11:0];    // L1As received and pushed on L1A stack
  assign  header02_[14:12]  =  ddu_code[2:0];        // DDU code for TMB/ALCT
  assign  header02_[15]    =  1;              // DDU special
  assign  header02_[18:16]  =  0;              // DMB control flags

  assign  header03_[11:0]    =  readout_counter[11:0];    // Readout counter
  assign  header03_[14:12]  =  ddu_code[2:0];        // DDU code for TMB/ALCT
  assign  header03_[15]    =  1;              // DDU special
  assign  header03_[18:16]  =  0;              // DMB control flags

// Next 4 words for short header mode
  assign  header04_[4:0]    =  board_id[4:0];        // TMB module ID number = VME slot
  assign  header04_[8:5]    =  csc_id[3:0];        // Chamber ID number
  assign  header04_[12:9]    =  run_id[3:0];        // Run info
  assign  header04_[13]    =  buf_q_ovf_err;        // Fence queue overflow error
  assign  header04_[14]    =  sync_err_hdr;        // BXN sync error
  assign  header04_[18:15]  =  0;              // DDU+DMB control flags

  assign  header05_[5:0]    =  r_nheaders[5:0];      // Number of header words
  assign  header05_[8:6]    =  fifo_mode[2:0];        // Trigger type and fifo mode
  assign  header05_[10:9]    =  readout_type[1:0];      // Readout type: dump,nodump, full header, short header
  assign  header05_[12:11]  =  l1a_type[1:0];        // L1A Pop type code: buffers, no buffers, clct/alct_only
  assign  header05_[13]    =  r_has_buf;          // Event has clct and rpc buffer data
  assign  header05_[14]    =  buf_stalled_hdr;      // Raw hits buffer was full at pretrigger
  assign  header05_[18:15]  =  0;              // DDU+DMB control flags

  assign  header06_[14:0]    =  bd_status[14:0];      // Board status summary
  assign  header06_[18:15]  =  0;              // DDU+DMB control flags

  assign  header07_[14:0]    =  revcode[14:0];        // Firmware version date code
  assign  header07_[18:15]  =  0;              // DDU+DMB control flags

// Full Header-mode words 8-to-EOB: Event Counters
  assign  header08_[11:0]    =  r_bxn_counter[11:0];    // CLCT Bunch Crossing number at pre-trig, 0-3563
  assign  header08_[12]    =  r_tmb_clct0_discard;    // TMB discarded clct0 from ME1A
  assign  header08_[13]    =  r_tmb_clct1_discard;    // TMB discarded clct1 from ME1A
  assign  header08_[14]    =  clock_lock_lost_err;    // Main DLL lost lock
  assign  header08_[18:15]  =  0;              // DDU+DMB control flags

  assign  header09_[14:0]    =  r_pretrig_counter[14:0];  // CLCT pre-trigger counter, stop on ovf
  assign  header09_[18:15]  =  0;              // DDU+DMB control flags

  assign  header10_[14:0]    =  r_pretrig_counter[29:15];  // CLCT pre-trigger counter
  assign  header10_[18:15]  =  0;              // DDU+DMB control flags

  assign  header11_[14:0]    =  r_clct_counter[14:0];    // CLCT post-drift counter, stop on ovf
  assign  header11_[18:15]  =  0;              // DDU+DMB control flags
  assign  header12_[14:0]    =  r_clct_counter[29:15];    // CLCT post-drift counter
  assign  header12_[18:15]  =  0;

  assign  header13_[14:0]    =  r_trig_counter[14:0];    // TMB trigger counter, stop on ovf
  assign  header13_[18:15]  =  0;              // DDU+DMB control flags
  assign  header14_[14:0]    =  r_trig_counter[29:15];    // TMB trigger counter
  assign  header14_[18:15]  =  0;              // DDU+DMB control flags

  assign  header15_[14:0]    =  r_alct_counter[14:0];    // Counts ALCTs received from ALCT board, stop on ovf
  assign  header15_[18:15]  =  0;              // DDU+DMB control flags
  assign  header16_[14:0]    =  r_alct_counter[29:15];
  assign  header16_[18:15]  =  0;              // DDU+DMB control flags

  assign  header17_[14:0]    =  r_orbit_counter[14:0];    // BX0s since last hard reset, stop on ovf
  assign  header17_[18:15]  =  0;              // DDU+DMB control flags
  assign  header18_[14:0]    =  r_orbit_counter[29:15];    // BX0s since last hard reset
  assign  header18_[18:15]  =  0;              // DDU+DMB control flags
  
// CLCT Raw Hits Size
  assign  header19_[2:0]    =  r_ncfebs[2:0];        // Number of CFEBs read out
  assign  header19_[7:3]    =  r_fifo_tbins_cfeb[4:0];    // Number of time bins per CFEB in dump
  assign  header19_[12:8]    =  fifo_pretrig_cfeb[4:0];    // # Time bins before pretrigger;
  assign  header19_[13]    =  scp_auto;          // Readout includes logic analyzer scope data
  assign  header19_[14]    =  mini_read_enable;      // Readout includes minicope data
  assign  header19_[18:15]  =  0;              // DDU+DMB control flags

// CLCT Configuration
  assign  header20_[2:0]    =  hit_thresh_pretrig[2:0];  // Hits on pattern template pre-trigger threshold
  assign  header20_[6:3]    =  pid_thresh_pretrig[3:0];  // Pattern shape ID pre-trigger threshold
  assign  header20_[9:7]    =  hit_thresh_postdrift[2:0];  // Hits on pattern  post-drift  threshold
  assign  header20_[13:10]  =  pid_thresh_postdrift[3:0];  // Pattern shape ID post-drift  threshold
  assign  header20_[14]    =  stagger_hs_csc;        // CSC Staggering ON
  assign  header20_[18:15]  =  0;              // DDU+DMB control flags

  assign  header21_[3:0]   =  triad_persist[3:0];      // CLCT Triad persistence
  assign  header21_[6:4]   =  dmb_thresh_pretrig[2:0]; // DMB pre-trigger threshold for active-feb
  assign  header21_[10:7]  =  alct_delay[3:0];         // Delay ALCT for CLCT match window
  assign  header21_[14:11] =  clct_window[3:0];        // CLCT match window width
  assign  header21_[18:15] =  0;                       // DDU+DMB control flags

// CLCT Trigger Status
  assign  header22_[8:0]    =  r_trig_source_vec[8:0];    // Trigger source vector
  assign  header22_[14:9]    =  r_layers_hit[5:0];      // CSC layers hit on layer trigger after drift
  assign  header22_[18:15]  =  0;              // DDU+DMB control flags

  assign  header23_[4:0]    =  active_feb_mux[4:0];    // Active CFEB list sent to DMB
  assign  header23_[9:5]    =  r_cfebs_read[4:0];      // CFEBs read out for this event
  assign  header23_[13:10]  =  r_l1a_match_win[3:0];    // Position of l1a in window
  assign  header23_[14]    =  active_feb_src;        // Active CFEB list source, 0=pretrig, 1=tmb match
  assign  header23_[18:15]  =  0;              // DDU+DMB control flags

// CLCT+ALCT Match Status
  assign  header24_[0]    =  r_tmb_match;        // ALCT and CLCT matched in time, pushed on L1A stack
  assign  header24_[1]    =  r_tmb_alct_only;      // Only ALCT triggered, pushed on L1a stack
  assign  header24_[2]    =  r_tmb_clct_only;      // Only CLCT triggered, pushed on L1A stack
  assign  header24_[6:3]    =  r_tmb_match_win[3:0];    // Location of alct in clct window, pushed on L1A stack
  assign  header24_[7]    =  r_tmb_no_alct;        // No ALCT
  assign  header24_[8]    =  r_tmb_one_alct;        // One ALCT
  assign  header24_[9]    =  r_tmb_one_clct;        // One CLCT
  assign  header24_[10]    =  r_tmb_two_alct;        // Two ALCTs
  assign  header24_[11]    =  r_tmb_two_clct;        // Two CLCTs
  assign  header24_[12]    =  r_tmb_dupe_alct;      // ALCT0 copied into ALCT1 to make 2nd LCT
  assign  header24_[13]    =  r_tmb_dupe_clct;      // CLCT0 copied into CLCT1 to make 2nd LCT
  assign  header24_[14]    =  r_tmb_rank_err;        // LCT1 has higher quality than LCT0
  assign  header24_[18:15]  =  0;              // DDU+DMB control flags

// CLCT Trigger Data
  assign  header25_[14:0]    =  r_clct0_xtmb[14:0];      // CLCT0 after drift lsbs
  assign  header25_[18:15]  =  0;              // DDU+DMB control flags

  assign  header26_[14:0]    =  r_clct1_xtmb[14:0];      // CLCT1 after drift lsbs
  assign  header26_[18:15]  =  0;              // DDU+DMB control flags

  assign  header27_[0]    =  r_clct0_xtmb[15];      // CLCT0 after drift msbs
  assign  header27_[1]    =  r_clct1_xtmb[15];      // CLCT1 after drift msbs
  assign  header27_[4:2]    =  r_clctc_xtmb[2:0];      // CLCT0/1 common after drift msbs
  assign  header27_[5]    =  r_clct0_invp;        // CLCT0 had invalid pattern after drift delay
  assign  header27_[6]    =  r_clct1_invp;        // CLCT1 had invalid pattern after drift delay
  assign  header27_[7]    =  r_clct1_busy;        // 2nd CLCT busy, logic error indicator
  assign  header27_[12:8]    =  perr_cfeb_ff[4:0];      // CFEB RAM parity error, latched
  assign  header27_[13]    =  perr_rpc_ff | perr_mini_ff;  // RPC  or Minicope RAM parity error, latched
  assign  header27_[14]    =  perr_ff;          // Parity error summary,  latched
  assign  header27_[18:15]  =  0;              // DDU+DMB control flags

// ALCT Trigger Data
  assign  header28_[0]    =  r_alct0_valid;        // ALCT0 valid pattern flag
  assign  header28_[2:1]    =  r_alct0_quality[1:0];    // ALCT0 quality
  assign  header28_[3]    =  r_alct0_amu;        // ALCT0 accelerator muon flag
  assign  header28_[10:4]    =  r_alct0_key[6:0];      // ALCT0 key wire group
  assign  header28_[14:11]  =  r_alct_preClct_win[3:0];  // ALCT active_feb_flag position in pretrig window
  assign  header28_[18:15]  =  0;              // DDU+DMB control flags

  assign  header29_[0]    =  r_alct1_valid;        // ALCT1 valid pattern flag
  assign  header29_[2:1]    =  r_alct1_quality[1:0];    // ALCT1 quality
  assign  header29_[3]    =  r_alct1_amu;        // ALCT1 accelerator muon flag
  assign  header29_[10:4]    =  r_alct1_key[6:0];      // ALCT1 key wire group
  assign  header29_[12:11]  =  drift_delay[1:0];      // CLCT drift delay
  assign  header29_[13]    =  bcb_read_enable;      // Enable blocked bits in readout
  assign  header29_[14]    =  hs_layer_trig;        // Layer-mode trigger
  assign  header29_[18:15]  =  0;              // DDU+DMB control flags

  assign  header30_[4:0]    =  r_alct_bxn[4:0];      // ALCT0/1 bxn
  assign  header30_[6:5]    =  r_alct_ecc_err[1:0];    // ALCT trigger path ECC error code
  assign  header30_[11:7]    =  cfeb_badbits_found[4:0];  // CFEB[n] has at least 1 bad bit
  assign  header30_[12]    =  cfeb_badbits_blocked;    // A CFEB had bad bits that were blocked
  assign  header30_[13]    =  alct_cfg_done;        // ALCT FPGA configuration done
  assign  header30_[14]    =  bx0_match;          // ALCT bx0 and CLCT bx0 match
  assign  header30_[18:15]  =  0;              // DDU+DMB control flags

// MPC Frames
  assign  header31_[14:0]    =  r_mpc0_frame0_ff[14:0];    // MPC muon 0 frame 0 LSBs
  assign  header31_[18:15]  =  0;              // DDU+DMB control flags

  assign  header32_[14:0]    =  r_mpc0_frame1_ff[14:0];    // MPC muon 0 frame 1 LSBs
  assign  header32_[18:15]  =  0;              // DDU+DMB control flags

  assign  header33_[14:0]    =  r_mpc1_frame0_ff[14:0];    // MPC muon 1 frame 0 LSBs
  assign  header33_[18:15]  =  0;              // DDU+DMB control flags

  assign  header34_[14:0]    =  r_mpc1_frame1_ff[14:0];    // MPC muon 1 frame 1 LSBs
  assign  header34_[18:15]  =  0;              // DDU+DMB control flags

  assign  header35_[0]    =  r_mpc0_frame0_ff[15];    // MPC muon 0 frame 0 MSB
  assign  header35_[1]    =  r_mpc0_frame1_ff[15];    // MPC muon 0 frame 1 MSB
  assign  header35_[2]    =  r_mpc1_frame0_ff[15];    // MPC muon 1 frame 0 MSB
  assign  header35_[3]    =  r_mpc1_frame1_ff[15];    // MPC muon 1 frame 1 MSB
  assign  header35_[7:4]    =  mpc_tx_delay[3:0];      // MPC transmit delay
  assign  header35_[9:8]    =  r_mpc_accept[1:0];      // MPC muon accept response
  assign  header35_[14:10]  =  cfeb_en[4:0];        // CFEBs enabled for triggering
  assign  header35_[18:15]  =  0;              // DDU+DMB control flags

// RPC Configuration
  assign  header36_[1:0]    =  rd_list_rpc[1:0];      // RPCs included in read out
  assign  header36_[3:2]    =  r_nrpcs_read[1:0];      // Number of RPCs in readout, 0,1,2, 0 if head-only event
  assign  header36_[4]    =  rpc_read_enable;      // RPC readout enabled
  assign  header36_[9:5]    =  fifo_tbins_rpc[4:0];    // Number RPC FIFO time bins to read out
  assign  header36_[14:10]  =  fifo_pretrig_rpc[4:0];    // Number RPC FIFO time bins before pretrigger
  assign  header36_[18:15]  =  0;              // DDU+DMB control flags

// Buffer Status
  assign  header37_[10:0]    =  r_wr_buf_adr[10:0];      // Buffer RAM write address at pretrigger
  assign  header37_[11]    =  r_wr_buf_ready;        // Write buffer was ready at pretrig
  assign  header37_[12]    =  wr_buf_ready;        // Write buffer ready now
  assign  header37_[13]    =  buf_q_full;          // All raw hits ram in use, ram writing must stop
  assign  header37_[14]    =  buf_q_empty;        // No fences remain on buffer stack
  assign  header37_[18:15]  =  0;              // DDU+DMB control flags

  assign  header38_[10:0]    =  r_buf_fence_dist[10:0];    // Distance to 1st fence address at pretrigger
  assign  header38_[11]    =  buf_q_ovf_err;        // Tried to push when stack full
  assign  header38_[12]    =  buf_q_udf_err;        // Tried to pop when stack empty
  assign  header38_[13]    =  buf_q_adr_err;        // Fence adr popped from stack doesnt match rls adr
  assign  header38_[14]    =  buf_stalled_once;      // Buffer write pointer hit a fence and stalled
  assign  header38_[18:15]  =  0;              // DDU+DMB control flags

// Spare Frames
  assign  header39_[11:0]    =  buf_fence_cnt[11:0];    // Number of fences in fence RAM currently
  assign  header39_[12]    =  reverse_hs_csc;        // 1=Reverse staggered CSC, non-me1
  assign  header39_[13]    =  reverse_hs_me1a;      // 1=ME1A hstrip order reversed
  assign  header39_[14]    =  reverse_hs_me1b;      // 1=ME1B hstrip order reversed
  assign  header39_[18:15]  =  0;              // DDU+DMB control flags

  assign  header40_[1:0]    =  active_feb_mux[6:5];    // Hdr23 Active CFEB list sent to DMB
  assign  header40_[3:2]    =  r_cfebs_read[6:5];      // Hdr23 CFEBs read out for this event
  assign  header40_[5:4]    =  perr_cfeb_ff[6:5];      // Hdr27 CFEB RAM parity error, latched
  assign  header40_[7:6]    =  cfeb_badbits_found[6:5];  // Hdr30 CFEB[n] has at least 1 bad bit
  assign  header40_[9:8]    =  cfeb_en[6:5];        // Hdr35 CFEBs enabled for triggering
  assign  header40_[10]    =  buf_fence_cnt_is_peak;    // Current fence is peak number of fences in RAM
  assign  header40_[11]    =  (MXCFEB==7);        // TMB has 7 DCFEBs so hdr40_[10:1] are active
  assign  header40_[12]    =  r_trig_source_vec[9];    // Pre-trigger was ME1A only
  assign  header40_[13]    =  r_trig_source_vec[10];    // Pre-trigger was ME1B only
  assign  header40_[14]    =  r_tmb_trig_pulse;      // TMB trig pulse coincident with rtmb_push
  assign  header40_[18:15]  =  0;              // DDU+DMB control flags

  assign  header41_[0]    =  tmb_allow_alct;        // Allow ALCT-only  tmb-matching trigger
  assign  header41_[1]    =  tmb_allow_clct;        // Allow CLCT-only  tmb-matching trigger
  assign  header41_[2]    =  tmb_allow_match;      // Allow Match-only tmb-matching trigger
  assign  header41_[3]    =  tmb_allow_alct_ro;      // Allow ALCT-only  tmb-matching readout only
  assign  header41_[4]    =  tmb_allow_clct_ro;      // Allow CLCT-only  tmb-matching readout only
  assign  header41_[5]    =  tmb_allow_match_ro;      // Allow Match-only tmb-matching readout only
  assign  header41_[6]    =  r_tmb_alct_only_ro;      // Only ALCT triggered, non-triggering readout
  assign  header41_[7]    =  r_tmb_clct_only_ro;      // Only CLCT triggered, non-triggering readout
  assign  header41_[8]    =  r_tmb_match_ro;        // ALCT and CLCT matched in time, non-triggering readout
  assign  header41_[9]    =  r_tmb_trig_keep;      // Triggering readout event
  assign  header41_[10]    =  r_tmb_non_trig_keep;    // Non-triggering readout event
  assign  header41_[13:11]  =  lyr_thresh_pretrig[2:0];  // Layer pre-trigger threshold
  assign  header41_[14]    =  layer_trig_en;        // Layer trigger mode enabled
  assign  header41_[18:15]  =  0;              // DDU+DMB control flags

// Store header in parallel shifter
  reg  [MXHW-1:0] header_bbl [MXHD-1:0];

  always @(posedge clock) begin: hdr_loop
  if (sm_reset) begin
  i=0;
  while (i<=MXHD-1) begin
  header_bbl[i] <= {MXHW{1'b1}};
  i=i+1;
  end
  end
  else
  if (read_sm == xdmb) begin            
  header_bbl[0]  <=  header00_;
  header_bbl[1]  <=  header01_;
  header_bbl[2]  <=  header02_;
  header_bbl[3]  <=  header03_;
  header_bbl[4]  <=  header04_;
  header_bbl[5]  <=  header05_;
  header_bbl[6]  <=  header06_;
  header_bbl[7]  <=  header07_;
  header_bbl[8]  <=  header08_;
  header_bbl[9]  <=  header09_;
  header_bbl[10]  <=  header10_;
  header_bbl[11]  <=  header11_;
  header_bbl[12]  <=  header12_;
  header_bbl[13]  <=  header13_;
  header_bbl[14]  <=  header14_;
  header_bbl[15]  <=  header15_;
  header_bbl[16]  <=  header16_;
  header_bbl[17]  <=  header17_;
  header_bbl[18]  <=  header18_;
  header_bbl[19]  <=  header19_;
  header_bbl[20]  <=  header20_;
  header_bbl[21]  <=  header21_;
  header_bbl[22]  <=  header22_;
  header_bbl[23]  <=  header23_;
  header_bbl[24]  <=  header24_;
  header_bbl[25]  <=  header25_;
  header_bbl[26]  <=  header26_;
  header_bbl[27]  <=  header27_;
  header_bbl[28]  <=  header28_;
  header_bbl[29]  <=  header29_;
  header_bbl[30]  <=  header30_;
  header_bbl[31]  <=  header31_;
  header_bbl[32]  <=  header32_;
  header_bbl[33]  <=  header33_;
  header_bbl[34]  <=  header34_;
  header_bbl[35]  <=  header35_;
  header_bbl[36]  <=  header36_;
  header_bbl[37]  <=  header37_;
  header_bbl[38]  <=  header38_;
  header_bbl[39]  <=  header39_;
  header_bbl[40]  <=  header40_;
  header_bbl[41]  <=  header41_;
  end

  if (read_sm == xheader) begin
  i=1;
  while (i<=MXHD-1) begin
  header_bbl[i-1]  <=  header_bbl[i];
  i=i+1;
  end
  end
  end

  wire [MXHW-1:0]  header_frame;
  assign header_frame = header_bbl[0];

//------------------------------------------------------------------------------------------------------------------
// Readout CLCT Raw Hits FIFO Controller Section
//------------------------------------------------------------------------------------------------------------------
// Send read start commands to FIFO controller
  assign rd_start_cfeb  = (read_sm == xheader) && header_done && r_fifo_dump && !no_daq;
  assign rd_abort_cfeb  = 0;
  assign rd_list_cfeb    = cfebs_read;
  assign rd_ncfebs    = ncfebs;
  assign rd_fifo_adr    = r_wr_buf_adr;

  assign fifo_read_done  = !cfeb_fifo_busy;    // CLCT FIFO signals completion

//------------------------------------------------------------------------------------------------------------------
// Readout RPC Raw Hits FIFO Controller Section
//------------------------------------------------------------------------------------------------------------------
  reg [MXRPC-1:0]  rd_list_rpc=0;

  assign rd_start_rpc  = (read_sm == xdump) && fifo_read_done && rpc_read_enable && !no_daq;// Start readout sequence, send fifo dump to DMB
  assign rd_abort_rpc  = 0;                                // Cancel readout
  assign rpc_fifo_done   = !rpc_fifo_busy;                        // Readout busy sending data to sequencer
  assign rd_rpc_offset = 0;                                // RAM address rd_fifo_adr offset for rpc read out

  always @(posedge clock) begin
  rd_list_rpc[MXRPC-1:0]  <= rpc_exists;                          // List of RPCs to read out
  rd_nrpcs[MXRPCB-1+1:0]  <= rpc_exists[0]+rpc_exists[1];                  // Number of RPCs in rpc_list (0 or 1-to-2 depending on CSC type)
  rpcs_all_empty      <= !(|rpc_exists);                        // At least 1 RPC to read
  end

//------------------------------------------------------------------------------------------------------------------
// Readout Miniscope FIFO Controller Section
//------------------------------------------------------------------------------------------------------------------
// Miniscope FIFO RAM write data
  wire [15:0] miniscope_data;
  wire [9:0]  miniscope_data_dly;

  assign miniscope_data[0]   = any_cfeb_hit;                // Any CFEB over threshold
  assign miniscope_data[3:1] = clct_sm_vec[2:0];            // Pre-trigger state machine
  assign miniscope_data[4]   = clct_push_xtmb && clct0_vpf; // CLCT vpf in TMB
  assign miniscope_data[5]   = clct_push_xtmb && clct1_vpf; // CLCT vpf in TMB
  assign miniscope_data[6]   = alct0_vpf_tprt;              // ALCT vpf in TMB after pipe delay, unbuffered real time
  assign miniscope_data[7]   = alct1_vpf_tprt;              // ALCT vpf in TMB after pipe delay, unbuffered real time
  assign miniscope_data[8]   = clct_window_tprt;            // CLCT matching window in TMB
  assign miniscope_data[9]   = wr_push_rtmb;                // Buffer write strobe at TMB matching time

  assign miniscope_data[10]  = tmb_push_dly;                // Event token from tmb matching
  assign miniscope_data[11]  = l1a_pulse;                   // L1A from ccb or internal
  assign miniscope_data[12]  = l1a_window_open;             // L1A dynamic window
  assign miniscope_data[13]  = l1a_push_me;                 // L1A match queued for readout

  assign miniscope_data[14]  = 0;                           // No readout for this bit, taken by weak unpacker
  assign miniscope_data[15]  = 0;                           // No readout for this bit, taken by ddu special

// Delay signals in pretrig region to come out at L1A time
  generate
    for (j=0; j<=9; j=j+1) begin: srlbit
      srl16e_bit #(8,256) usrlbit (.clock(clock),.adr(l1a_delay),.d(miniscope_data[j]),.q(miniscope_data_dly[j]));
    end
  endgenerate

  assign fifo_wdata_mini[9:0]   = miniscope_data_dly[9:0];    // Delayed pretrig region 
  assign fifo_wdata_mini[15:10] = miniscope_data[15:10];      // Prompt  L1A region

// Miniscope Readout
  wire mini_start_from_xdump = (read_sm == xdump) && fifo_read_done && !rpc_read_enable && !scp_auto;
  wire mini_start_from_xe04  = (read_sm == xe04)  && !scp_auto; 
  wire mini_start_from_xe05  = (read_sm == xe05);
  wire mini_start_lookahead  = (mini_start_from_xdump || mini_start_from_xe04 || mini_start_from_xe05);

  assign rd_start_mini  = mini_start_lookahead && mini_read_enable; // Start readout sequence, send fifo dump to DMB
  assign rd_abort_mini  = 0;                                        // Cancel readout
  assign mini_fifo_done = !mini_fifo_busy;                          // Readout busy sending data to sequencer
  assign rd_mini_offset = 0;                                        // RAM address offset for miniscope read
  assign wr_mini_offset = l1a_delay;                                // RAM address offset for miniscope write

//------------------------------------------------------------------------------------------------------------------
// Blocked CFEB triad bits readout
//------------------------------------------------------------------------------------------------------------------
  reg [MXCFEB-1:0]  rd_list_bcb   = 0;
  reg [MXCFEBB-1:0] rd_ncfebs_bcb = 0;

  always @* begin
    if (full_dump || local_dump) begin
      rd_list_bcb   = {MXCFEB{1'b1}}; // List of CFEBs to read out
      rd_ncfebs_bcb = MXCFEB;         // Number of CFEBs in bcb_list
    end
    else begin
      rd_list_bcb   = 0;
      rd_ncfebs_bcb = 0;
    end
  end

  assign rd_start_bcb  = (read_sm == xbcb);                  // Start readout sequence, send fifo dump to DMB
  assign rd_abort_bcb  = 0;                                  // Cancel readout
  assign bcb_fifo_done = !bcb_fifo_busy || !bcb_read_enable; // Readout busy sending data to sequencer

//------------------------------------------------------------------------------------------------------------------
// Readout Special Frames and Trailer Frames Section
//------------------------------------------------------------------------------------------------------------------
  wire  [MXHW-1:0]    e0b_frame;
  wire  [MXHW-1:0]    fifo_frame;
  wire  [MXHW-1:0]    e0c_frame;

  wire  [MXHW-1:0]    b04_frame;
  wire  [MXHW-1:0]    rpc_frame;
  wire  [MXHW-1:0]    e04_frame;

  wire  [MXHW-1:0]    b05_frame;
  wire  [MXHW-1:0]    scp_frame;
  wire  [MXHW-1:0]    e05_frame;

  wire  [MXHW-1:0]    b07_frame;
  wire  [MXHW-1:0]    mini_frame;
  wire  [MXHW-1:0]    e07_frame;

  wire  [MXHW-1:0]    bcb_frame;
  wire  [MXHW-1:0]    blkbit_frame;
  wire  [MXHW-1:0]    ecb_frame;

  wire  [MXHW-1:0]    mod40_frame;
  wire  [MXHW-1:0]    mod41_frame;

  wire  [MXHW-1:0]    crc0_frame;
  wire  [MXHW-1:0]    crc1_frame;

  wire  [MXHW-1:0]    e0f_frame;
  wire  [MXHW-1:0]    last_frame;
  wire  [MXHW-1:0]    nowrite_frame;

//------------------------------------------------------------------------------------------------------------------
// Construct Special DMB frames
//------------------------------------------------------------------------------------------------------------------
// Header
  assign e0b_frame[11:0]    =  12'hE0B;      // End of header block
  assign e0b_frame[14:12]    =  3'b110;        // Marker  
  assign e0b_frame[18:15]    =  0;          // DDU special + DMB control flags

// CFEB Raw hits
  assign fifo_frame[ 7: 0]  =  cfeb_rawhits[7:0];  // FIFO raw hits data
  assign fifo_frame[11: 8]  =  cfeb_tbin[3:0];    // Time bin LSBs
  assign fifo_frame[14:12]  =  cfeb_adr;      // CFEB ID
  assign fifo_frame[18:15]  =  0;          // DDU special + DMB control flags

// RPC Raw hits
  assign b04_frame[11:0]    =  12'hB04;      // Beginning of RPC block
  assign b04_frame[14:12]    =  3'b110;        // Marker  
  assign b04_frame[18:15]    =  0;          // DDU special + DMB control flag

  assign rpc_frame[7:0]    =  rpc_rawhits[7:0];  // RPC pad hits for DMB, 8 of 16 per cycle
  assign rpc_frame[11:8]    =  rpc_tbinbxn[3:0];  // RPC tbin or flag,bxn for DMB
  assign rpc_frame[13:12]    =  {1'b0,rpc_adr[0]};  // RPC ID tag for DMB
  assign rpc_frame[18:14]    =  0;          // DDU special + DMB control flags

  assign e04_frame[11:0]    =  12'hE04;      // End of RPC block
  assign e04_frame[14:12]    =  3'b110;        // Marker  
  assign e04_frame[18:15]    =  0;          // DDU special + DMB control flags

// Scope
  assign b05_frame[11:0]    =  12'hB05;      // Beginning of Scope block
  assign b05_frame[14:12]    =  3'b110;        // Marker  
  assign b05_frame[18:15]    =  0;          // DDU special + DMB control flags

  assign scp_frame[14:0]    =  scp_rdata[14:0];  // Scope data
  assign scp_frame[18:15]    =  0;          // DDU special + DMB control flags

  assign e05_frame[11:0]    =  12'hE05;      // End of Scope block
  assign e05_frame[14:12]    =  3'b110;        // Marker  
  assign e05_frame[18:15]    =  0;          // DDU special + DMB control flags

// Miniscope
  assign b07_frame[11:0]    =  12'hB07;      // Beginning of minicope block
  assign b07_frame[14:12]    =  3'b110;        // Marker  
  assign b07_frame[18:15]    =  0;          // DDU special + DMB control flags

  assign mini_frame[14:0]    =  mini_rdata[14:0];  // Miniscope data
  assign mini_frame[18:15]  =  0;          // DDU special + DMB control flags

  assign e07_frame[11:0]    =  12'hE07;      // End of miniscope block
  assign e07_frame[14:12]    =  3'b110;        // Marker  
  assign e07_frame[18:15]    =  0;          // DDU special + DMB control flags

// CFEB Blocked triad bits
  assign bcb_frame[11:0]    =  12'hBCB;      // Beginning of CFEB blocked bits list
  assign bcb_frame[14:12]    =  3'b110;        // Marker  
  assign bcb_frame[18:15]    =  0;          // DDU special + DMB control flag

  assign blkbit_frame[11:0]  =  bcb_blkbits[11:0];  // CFEB blocked bits list
  assign blkbit_frame[14:12]  =  bcb_cfeb_adr[2:0];  // CFEB ID  
  assign blkbit_frame[18:15]  =  0;          // DDU special + DMB control flag

  assign ecb_frame[11:0]    =  12'hECB;      // End of CFEB blccked bits list
  assign ecb_frame[14:12]    =  3'b110;        // Marker  
  assign ecb_frame[18:15]    =  0;          // DDU special + DMB control flags

// Fillers
  assign e0c_frame[11:0]    =  12'hE0C;      // End of Cathode
  assign e0c_frame[14:12]    =  3'b110;        // Marker
  assign e0c_frame[18:15]    =  0;          // DDU special + DMB control flags

  assign mod40_frame[14:0]  =  'h2AAA;        // Filler word
  assign mod40_frame[18:15]  =  0;          // DDU special + DMB control flags

  assign mod41_frame[14:0]  =  'h5555;        // Filler word
  assign mod41_frame[18:15]  =  0;          // DDU special + DMB control flags

// CRC
  assign crc0_frame[10:0]    =  11'h51A;      // Superfluous CRC mux code replaced in dly mux
  assign crc0_frame[11]    =  LCT_TYPE;      // 1=TMB, 0=ALCT
  assign crc0_frame[14:12]  =  3'b101;        // DDU code
  assign crc0_frame[15]    =  1;          // DDU special
  assign crc0_frame[16]    =  0;          // DMB last
  assign crc0_frame[17]    =  0;          // DMB first
  assign crc0_frame[18]    =  0;          // DMB /wr

  assign crc1_frame[10:0]    =  11'h52A;      // Superfluous CRC mux code replaced in dly mux
  assign crc1_frame[11]    =  LCT_TYPE;      // 1=TMB, 0=ALCT
  assign crc1_frame[14:12]  =  3'b101;        // DDU code
  assign crc1_frame[15]    =  1;          // DDU special
  assign crc1_frame[16]    =  0;          // DMB last
  assign crc1_frame[17]    =  0;          // DMB first
  assign crc1_frame[18]    =  0;          // DMB /wr

// Trailer Frames
  assign e0f_frame[11:0]    =  {4'hE,eef,4'hF};  // End of event, E0F if have buffers, EEF if no buffers
  assign e0f_frame[14:12]    =  3'b101;        // DDU code
  assign e0f_frame[15]    =  1;          // DDU special
  assign e0f_frame[16]    =  0;          // DMB last
  assign e0f_frame[17]    =  0;          // DMB first
  assign e0f_frame[18]    =  0;          // DMB /wr

  assign last_frame[10:0]    =  frame_cnt[10:0];  // Total frame count
  assign last_frame[11]    =  LCT_TYPE;      // 1=TMB, 0=ALCT
  assign last_frame[14:12]  =  3'b101;        // DDU code
  assign last_frame[15]    =  1;          // DDU special
  assign last_frame[16]    =  1;          // DMB last
  assign last_frame[17]    =  0;          // DMB first
  assign last_frame[18]    =  0;          // DMB /wr

// Empty Frames
  assign nowrite_frame[17:0]  =  0;          // Empty frames
  assign nowrite_frame[18]  =  1;          // The famous /wr_dmbfifo bit 1=don't write dmb fifo

//------------------------------------------------------------------------------------------------------------------
// Readout Output Multiplexer Section
//------------------------------------------------------------------------------------------------------------------
// DMB output frame mutiplexer
  wire wr_hdr    = (read_sm == xheader);
  wire wr_e0b    = (read_sm == xe0b   );
  wire wr_dmp    = (read_sm == xdump   );

  wire wr_b04    = (read_sm == xb04   );
  wire wr_rpc    = (read_sm == xrpc   );
  wire wr_e04    = (read_sm == xe04   );

  wire wr_b05    = (read_sm == xb05   );
  wire wr_scp    = (read_sm == xscope );
  wire wr_e05    = (read_sm == xe05   );

  wire wr_b07    = (read_sm == xb07   );
  wire wr_mini  = (read_sm == xmini  );
  wire wr_e07    = (read_sm == xe07   );

  wire wr_bcb    = (read_sm == xbcb   );
  wire wr_blkbit  = (read_sm == xblkbit);
  wire wr_ecb    = (read_sm == xecb   );

  wire wr_e0c    = (read_sm == xe0c   );
  wire wr_m40    = (read_sm == xmod40 );
  wire wr_m41    = (read_sm == xmod41 );
  wire wr_e0f    = (read_sm == xe0f   );
  wire wr_crc0  = (read_sm == xcrc0   );
  wire wr_crc1  = (read_sm == xcrc1   );
  wire wr_last  = (read_sm == xlast   );

  always @(posedge clock) begin
  if    (wr_hdr  )  dmb_ff  =  header_frame;  // header frames  
  else if (wr_e0b  )  dmb_ff  =  e0b_frame;    // e0b    frame
  else if (wr_dmp  )  dmb_ff  =  fifo_frame;    // fifo   frames

  else if (wr_b04  )  dmb_ff  =  b04_frame;    // b04    frame
  else if (wr_rpc )  dmb_ff  =  rpc_frame;    // rpc    frames
  else if (wr_e04 )  dmb_ff  =  e04_frame;    // e04    frame

  else if (wr_b05  )  dmb_ff  =  b05_frame;    // b05    frame
  else if (wr_scp )  dmb_ff  =  scp_frame;    // scope  frames
  else if (wr_e05 )  dmb_ff  =  e05_frame;    // e05    frame

  else if (wr_b07  )  dmb_ff  =  b07_frame;    // b07    frame
  else if (wr_mini)  dmb_ff  =  mini_frame;    // mini   frames
  else if (wr_e07 )  dmb_ff  =  e07_frame;    // e07    frame

  else if (wr_bcb  )  dmb_ff  =  bcb_frame;    // bcb    frame
  else if (wr_blkbit)  dmb_ff  =  blkbit_frame;  // blkbit frames
  else if (wr_ecb )  dmb_ff  =  ecb_frame;    // ecb    frame

  else if (wr_e0c  )  dmb_ff  =  e0c_frame;    // e0c    frame
  else if (wr_m40  )  dmb_ff  =  mod40_frame;  // mod40  frame
  else if (wr_m41  )  dmb_ff  =  mod41_frame;  // mod41  frame
  else if (wr_e0f  )  dmb_ff  =  e0f_frame;    // e0f    frame
  else if (wr_crc0)  dmb_ff  =  crc0_frame;    // crc0   frame
  else if (wr_crc1)  dmb_ff  =  crc1_frame;    // crc1   frame
  else if (wr_last)  dmb_ff  =  last_frame;    // last   frame
  else        dmb_ff  =  nowrite_frame;  // nowrite_frame
  end

// DMB FF delays DMB out 1 clock, inserts CRC
  reg xcrc0dly = 0;
  reg xcrc1dly = 0;
  reg  [MXHW-1:0]  dmb_ffdly = 0;

  always @(posedge clock) begin
  xcrc0dly <= (read_sm == xcrc0);
  xcrc1dly <= (read_sm == xcrc1);
  end

  always @(posedge clock) begin
  if     (xcrc0dly)  dmb_ffdly  = {crc0_frame[18:11],crc_ff[10:0]};    // 1st crc frame
  else if  (xcrc1dly)  dmb_ffdly  = {crc1_frame[18:11],crc_ff[21:11]};  // 2nd crc frame
  else        dmb_ffdly  = dmb_ff;
  end

// Output to DMB via IOB FFs, async load outputs nowrite mode until startup done, do not specify initial state else xst chokes
  reg [MXDMB-1:0] dmb_tx={8'h00,1'b1,6'h00,1'b1,33'h000000000}; // synthesis attribute IOB of dmb_tx is "true";

  always @(posedge clock or posedge startup_blank) begin
    if (startup_blank) begin     // async preset
      dmb_tx[14: 0] <= 0;        // CLCT data
      dmb_tx[29:15] <= 0;        // ALCT data
      dmb_tx[30]    <= 0;        // DDU special
      dmb_tx[31]    <= 0;        // DMB last
      dmb_tx[32]    <= 0;        // DMB first
      dmb_tx[33]    <= 1;        // DMB /wr
      dmb_tx[34]    <= 0;        // DMB active cfeb flag
      dmb_tx[39:35] <= 0;        // DMB active cfeb list
      dmb_tx[40]    <= 1;        // ALCT _wr_fifo
      dmb_tx[41]    <= 0;        // ALCT ddu_special
      dmb_tx[42]    <= 0;        // ALCT last frame
      dmb_tx[43]    <= 0;        // ALCT first frame
      dmb_tx[45:44] <= 0;        // DMB active cfeb list
      dmb_tx[48:46] <= 0;        // Unassigned
    end
    else begin          // if "BPI Active" then to "BPI Flash PROM Address connector", else to "DMB backplane connector"
      dmb_tx[1:0]   <= (bpi_active) ? bpi_ad_out[19:18] : dmb_ffdly[1:0];       // fifo data   ** 1,0
      dmb_tx[5:2]   <=                                    dmb_ffdly[5:2];       // fifo data
      dmb_tx[6]     <= (bpi_active) ? bpi_ad_out[1]     : dmb_ffdly[6];         // fifo data   ** YES: 7,6 -> 0,1
      dmb_tx[7]     <= (bpi_active) ? bpi_ad_out[0]     : dmb_ffdly[7];         // fifo data   ** YES: 7,6 -> 0,1
      dmb_tx[9:8]   <=                                    dmb_ffdly[9:8];       // fifo data
      dmb_tx[10]    <= (bpi_active) ? bpi_ad_out[17]    : dmb_ffdly[10];        // fifo data   **
      dmb_tx[11]    <= (bpi_active) ? bpi_ad_out[22]    : dmb_ffdly[11];        // fifo data   **
      dmb_tx[13:12] <=                                    dmb_ffdly[13:12];     // fifo data
      dmb_tx[14]    <= (bpi_active) ? bpi_ad_out[16]    : dmb_ffdly[14];        // fifo data   **
      dmb_tx[17:15] <=                                    alct_dmb[2:0];        // alct data
      dmb_tx[19:18] <= (bpi_active) ? bpi_ad_out[21:20] : alct_dmb[4:3];        // alct data   ** 4,3
      dmb_tx[21:20] <=                                    alct_dmb[6:5];        // alct data
      dmb_tx[22]    <= (bpi_active) ? bpi_ad_out[3]     : alct_dmb[7];          // alct data   **
      dmb_tx[25:23] <=                                    alct_dmb[10:8];       // alct data
      dmb_tx[26]    <= (bpi_active) ? bpi_ad_out[2]     : alct_dmb[11];         // alct data   **
      dmb_tx[29:27] <=                                    alct_dmb[14:12];      // alct data
      dmb_tx[30]    <= (bpi_active) ? bpi_ad_out[15]    : dmb_ffdly[15];        // DDU special **
      dmb_tx[31]    <= (bpi_active) ? bpi_ad_out[14]    : dmb_ffdly[16];        // DMB last    **
      dmb_tx[32]    <=                                    dmb_dav;              // DMB data available
      dmb_tx[33]    <=                                    dmb_ffdly[18];        // DMB /wr
      dmb_tx[34]    <= (bpi_active) ? bpi_ad_out[6]     : active_feb_flag;      // DMB active cfeb flag  **
      dmb_tx[35]    <= (bpi_active) ? bpi_ad_out[7]     : active_feb_list[0];   // DMB active cfeb list  **
      dmb_tx[36]    <= (bpi_active) ? bpi_ad_out[10]    : active_feb_list[1];   // DMB active cfeb list  **
      dmb_tx[37]    <= (bpi_active) ? bpi_ad_out[12]    : active_feb_list[2];   // DMB active cfeb list  **
      dmb_tx[38]    <= (bpi_active) ? bpi_ad_out[4]     : active_feb_list[3];   // DMB active cfeb list  **
      dmb_tx[39]    <= (bpi_active) ? bpi_ad_out[11]    : active_feb_list[4];   // DMB active cfeb list  **
      dmb_tx[40]    <=                                    alct_dmb[18];         // ALCT _wr_fifo
      dmb_tx[41]    <= (bpi_active) ? bpi_ad_out[13]    : alct_dmb[15];         // ALCT ddu_special  **
      dmb_tx[42]    <= (bpi_active) ? bpi_ad_out[5]     : alct_dmb[16];         // ALCT last frame   **
      dmb_tx[43]    <=                                    alct_dmb[17];         // ALCT first frame
      dmb_tx[45:44] <=                                    active_feb_list[6:5]; // DMB active cfeb list
      dmb_tx[46]    <= (bpi_active) ? bpi_ad_out[8]     : dmb_tx_reserved[0];   // Unassigned   **
      dmb_tx[47]    <= (bpi_active) ? bpi_ad_out[9]     : dmb_tx_reserved[1];   // Unassigned   **
      dmb_tx[48]    <=                                    dmb_tx_reserved[2];   // Unassigned
    end
  end

//------------------------------------------------------------------------------------------------------------------
// Scope Input Signals Section
//------------------------------------------------------------------------------------------------------------------
  wire [159:0] scp_ch;

// Pre-trigger to DMB
  assign scp_ch[0]   = clct_pretrig;         // Trigger alignment marker, scope triggers on this ch usually
  assign scp_ch[1]   = triad_tp[0];          // Triad test point at input to raw hits RAM
  assign scp_ch[2]   = any_cfeb_hit;         // Any CFEB over threshold
  assign scp_ch[3]   = active_feb_flag;      // Active feb flag to DMB
  assign scp_ch[8:4] = active_feb_list[4:0]; // Active feb list to DMB

// Pre-trigger CLCT*ALCT matching
  assign scp_ch[9]  = alct_active_feb;     // ALCT active feb flag, should precede alct0_vpf
  assign scp_ch[10] = alct_preClct_window; // ALCT*CLCT pretrigger matching window

// Pre-trigger Processing
  assign scp_ch[13:11] = clct_sm_vec[2:0];  // Pre-trigger state machine
  assign scp_ch[14]    = wr_buf_ready;      // Write buffer ready
  assign scp_ch[15]    = clct_pretrig;      // Skip channels 15,31,47,63,79,95,111,127,143,159
  assign scp_ch[27:16] = bxn_counter[11:0]; // BXN counter
  assign scp_ch[28]    = discard_nowrbuf;   // Event discard, no write buffer

// CLCT Pattern Finder Output
  assign scp_ch[29]    = 0;
  assign scp_ch[30]    = 0;
  assign scp_ch[31]    = clct_pretrig;      // Skip channels 15,31,47,63,79,95,111,127,143,159

  assign scp_ch[34:32]  = hs_hit_1st[2:0];  // CLCT0 number hits after drift
  assign scp_ch[38:35]  = hs_pid_1st[3:0];  // CLCT0 Pattern number
  assign scp_ch[46:39]  = hs_key_1st[7:0];  // CLCT0 1/2-strip ID number

  assign scp_ch[47]     = clct_pretrig;     // Skip channels 15,31,47,63,79,95,111,127,143,159

  assign scp_ch[50:48]  = hs_hit_2nd[2:0];  // CLCT1 number hits after drift
  assign scp_ch[54:51]  = hs_pid_2nd[3:0];  // CLCT1 Pattern number
  assign scp_ch[62:55]  = hs_key_2nd[7:0];  // CLCT1 1/2-strip ID number

  assign scp_ch[63]     = clct_pretrig;     // Skip channels 15,31,47,63,79,95,111,127,143,159

// CLCT Builder
  assign scp_ch[64]    = clct0_really_valid; // CLCT0 is over threshold, not forced by an external trigger
  assign scp_ch[65]    = clct0_vpf;          // CLCT0 vpf
  assign scp_ch[66]    = clct1_vpf;          // CLCT1 vpf
  assign scp_ch[67]    = clct_push_xtmb;     // CLCT sent to TMB matching
  assign scp_ch[68]    = discard_invp;       // CLCT discarded, below threshold after drift

// TMB Matching
  assign scp_ch[69]    = alct0_valid;        // ALCT0 vpf direct from 80MHz receiver, before alct_delay
  assign scp_ch[70]    = alct1_valid;        // ALCT1 vpf direct from 80MHz receiver, before alct_delay

  assign scp_ch[71]    = alct0_vpf_tprt;     // ALCT vpf in TMB after pipe delay, unbuffered real time
  assign scp_ch[72]    = clct_vpf_tprt;      // CLCT vpf in TMB
  assign scp_ch[73]    = clct_window_tprt;   // CLCT matching window in TMB
  assign scp_ch[77:74] = tmb_match_win[3:0]; // Location of alct in clct window
  assign scp_ch[78]    = tmb_alct_discard;   // ALCT pair was not used for LCT

  assign scp_ch[79]    = clct_pretrig;       // Skip channels 15,31,47,63,79,95,111,127,143,15

  assign scp_ch[80]    = tmb_clct_discard;   // CLCT pair was not used for LCT

// TMB Match Results
  assign scp_ch[81]    = tmb_trig_pulse;     // TMB Triggered on ALCT or CLCT or both
  assign scp_ch[82]    = tmb_trig_keep;      // ALCT or CLCT or both triggered, and trigger is allowed
  assign scp_ch[83]    = tmb_match;          // ALCT and CLCT matched in time
  assign scp_ch[84]    = tmb_alct_only;      // Only ALCT triggered
  assign scp_ch[85]    = tmb_clct_only;      // Only CLCT triggered
  assign scp_ch[86]    = discard_tmbreject;  // TMB discarded event

// MPC
  assign scp_ch[87]    = mpc_xmit_lct0;      // MPC LCT0 sent
  assign scp_ch[88]    = mpc_xmit_lct1;      // MPC LCT1 sent
  assign scp_ch[89]    = mpc_response_ff;    // MPC accept is ready
  assign scp_ch[91:90] = mpc_accept_ff[1:0]; // MPC muon accept response

// L1A
  assign scp_ch[92]    = l1a_pulse;        // L1A strobe from ccb or internal
  assign scp_ch[93]    = l1a_window_open;  // L1A window open duh
  assign scp_ch[94]    = l1a_match;        // L1A strobe match in window

  assign scp_ch[95]    = clct_pretrig;     // Skip channels 15,31,47,63,79,95,111,127,143,159

// Buffer push at L1A
  assign scp_ch[96]     = buf_push;          // Allocate write buffer space for this event
  assign scp_ch[103:97] = buf_push_adr[6:0]; // Address of write buffer to allocate

// DMB Readout
  assign scp_ch[104]     = dmb_dav;          // DAV to DMB
  assign scp_ch[105]     = dmb_busy;         // Readout in progress
  assign scp_ch[110:106] = read_sm_vec[4:0]; // Readout state machine

  assign scp_ch[111]    = clct_pretrig;      // Skip channels 15,31,47,63,79,95,111,127,143,159

  assign scp_ch[126:112] = seq_wdata[14:0];  // DMB dump image, very cool
  assign scp_ch[127]     = clct_pretrig;     // Skip channels 15,31,47,63,79,95,111,127,143,159
  assign scp_ch[128]     = seq_wdata[15];    // DMB dump image, very cool

// CLCT+TMB Pipelines
  assign scp_ch[132:129] = wr_buf_adr[3:0];  // Event address counter

  assign scp_ch[133]     = wr_push_xtmb;     // Buffer write strobe after drift time
  assign scp_ch[137:134] = wr_adr_xtmb[3:0]; // Buffer write address after drift time

  assign scp_ch[138]     = wr_push_rtmb;     // Buffer write strobe at TMB matching time
  assign scp_ch[142:139] = wr_adr_rtmb[3:0]; // Buffer write address at TMB matching time

  assign scp_ch[143]     = clct_pretrig;     // Skip channels 15,31,47,63,79,95,111,127,143,159

  assign scp_ch[144]     = wr_push_xmpc;     // Buffer write strobe at MPC xmit to sequencer
  assign scp_ch[148:145] = wr_adr_xmpc[3:0]; // Buffer write address at MPC xmit to sequencer

  assign scp_ch[149]     = wr_push_rmpc;     // Buffer write strobe at MPC received
  assign scp_ch[153:150] = wr_adr_rmpc[3:0]; // Buffer write address at MPC received

// Buffer pop at readout completion
  assign scp_ch[154]     = buf_pop;          // Specified buffer is to be released
  assign scp_ch[158:155] = buf_pop_adr[3:0]; // Address of read buffer to release

  assign scp_ch[159]    = clct_pretrig;      // Skip channels 15,31,47,63,79,95,111,127,143,159

//------------------------------------------------------------------------------------------------------------------
// Scope channel multiplexer overloads special inputs if selected
//------------------------------------------------------------------------------------------------------------------
  wire [159:0] scp_ch_mux;
  
  assign scp_ch_mux[103:0]   = scp_ch[103:0];                        // Channels not multiplexed
  assign scp_ch_mux[159:104] = (scp_ch_overlay) ? scp_alct_rx[55:0] : scp_ch[159:104];  // Channels multiplexed

//------------------------------------------------------------------------------------------------------------------
// Scope control
//------------------------------------------------------------------------------------------------------------------
  wire scp_read_busy;
  wire scp_trig_discard = discard_nowrbuf_cnt_en || discard_invp_cnt_en || discard_tmbreject_cnt_en || tmb_nol1a;
  wire scp_clear        = (scp_trig_discard && !scp_read_busy);
  wire scp_runstop_mux  = (scp_auto) ? !scp_clear : scp_runstop;  // Auto mode over-rides vme runstop
  wire scp_start_read   = (read_sm == xb05);

  scope160 uscope
  (
    .clock      (clock),               // In  40MHz system clock
    .ttc_resync (ttc_resync),          // In  Reset scope
    .ch         (scp_ch_mux[159:0]),   // In  Channel inputs
    .trigger_ch (scp_trigger_ch[7:0]), // In  Trigger channel 0-159
    .ch_trig_en (scp_ch_trig_en),      // In  Enable channel triggers
    .force_trig (scp_force_trig),      // In  Force a trigger
    .runstop    (scp_runstop_mux),     // In  1=run 0=stop
    .auto       (scp_auto),            // In  Sequencer readout mode
    .nowrite    (scp_nowrite),         // In  No-write mode preserves initial RAM contents
    .ram_sel    (scp_ram_sel[3:0]),    // In  RAM bank select in VME mode
    .tbins      (scp_tbins[2:0]),      // In  Time bins per channel code, actual tbins/ch = (tbins+1)*64
    .radr_vme   (scp_radr[8:0]),       // In  Channel data read address
    .start_read (scp_start_read),      // In  Start sequencer readout
    .waiting    (scp_waiting),         // Out  Waiting for trigger
    .trig_done  (scp_trig_done),       // Out  Trigger done, ready for readout 
    .rdata      (scp_rdata[15:0]),     // Out  Recorded channel data
    .read_busy  (scp_read_busy),       // Out  Readout busy sending data to sequencer
    .read_done  (scp_read_done)        // Out  Read done
  );

// Output calibration signals to help tune external L1A arrival time on CCB front panel
  reg stat_pretrig      = 0;
  reg stat_invpat       = 0;
  reg stat_tmb_flush    = 0;
  reg stat_tmb          = 0;
  reg stat_l1a_window   = 0;
  reg stat_l1a          = 0;
  reg stat_dmb          = 0;
  reg stat_seq_busy     = 0;
  reg  stat_nol1a_flush = 0;

  always @(posedge clock) begin
    stat_pretrig     <=  clct_pretrig;
    stat_invpat      <=  discard_invp;
    stat_tmb_flush   <=  tmb_trig_pulse && !(tmb_trig_keep || tmb_non_trig_keep);
    stat_tmb         <=  clct_push_xtmb;
    stat_l1a_window  <=  l1a_window_open;
    stat_l1a         <=  l1a_pulse;
    stat_dmb         <=  (read_sm != xckstack);
    stat_seq_busy    <=  (clct_sm != idle) || scint_pretrig;
    stat_nol1a_flush <=  (read_sm == xpop);
  end

  assign clct_status[0] = stat_pretrig;
  assign clct_status[1] = stat_seq_busy;
  assign clct_status[2] = stat_invpat;
  assign clct_status[3] = stat_dmb;
  assign clct_status[4] = stat_l1a_window;
  assign clct_status[5] = stat_l1a;
  assign clct_status[6] = stat_tmb;
  assign clct_status[7] = stat_tmb_flush;
  assign clct_status[8] = stat_nol1a_flush;

// Condense state machine vectors into binary encoding for diagnostic status readout  
  always @* begin
    case (clct_sm)
      startup:  clct_sm_vec <= 0;
      idle:     clct_sm_vec <= 1;
      pretrig:  clct_sm_vec <= 2;
      throttle: clct_sm_vec <= 3;
      flush:    clct_sm_vec <= 4;
      halt:     clct_sm_vec <= 5;
      default   clct_sm_vec <= 6;
    endcase
  end

  always @* begin
    case (read_sm)
      xstartup: read_sm_vec <= 0;
      xckstack: read_sm_vec <= 1;
      xdmb:     read_sm_vec <= 2;
      xheader:  read_sm_vec <= 3;
      xe0b:     read_sm_vec <= 4;
      xdump:    read_sm_vec <= 5;
      xb04:     read_sm_vec <= 6;
      xrpc:     read_sm_vec <= 7;
      xe04:     read_sm_vec <= 8;
      xb05:     read_sm_vec <= 9;
      xscope:   read_sm_vec <= 10;
      xe05:     read_sm_vec <= 11;
      xb07:     read_sm_vec <= 12;
      xmini:    read_sm_vec <= 13;
      xe07:     read_sm_vec <= 14;
      xbcb:     read_sm_vec <= 15;
      xblkbit:  read_sm_vec <= 16;
      xecb:     read_sm_vec <= 17;
      xe0c:     read_sm_vec <= 18;
      xmod40:   read_sm_vec <= 19;
      xmod41:   read_sm_vec <= 20;
      xe0f:     read_sm_vec <= 21;
      xcrc0:    read_sm_vec <= 22;
      xcrc1:    read_sm_vec <= 23;
      xlast:    read_sm_vec <= 24;
      xpop:     read_sm_vec <= 25;
      xhalt:    read_sm_vec <= 26;
      default   read_sm_vec <= 27;
    endcase
  end

// Sequencer Status for VME
  reg [11:0] sequencer_state=0;

  always @(posedge clock) begin
    sequencer_state[2:0] <= clct_sm_vec[2:0];
    sequencer_state[7:3] <= read_sm_vec[4:0];
    sequencer_state[8]   <= buf_q_full;    // All raw hits ram in use, ram writing must stop
    sequencer_state[9]   <= buf_q_empty;   // No fences remain on buffer stack
    sequencer_state[10]  <= buf_q_ovf_err; // Tried to push when stack full
    sequencer_state[11]  <= buf_q_adr_err; // Tried to pop when stack empty
  end

// LED status displays
  always @(posedge clock) begin
    led_hold           <=  (clct_sm == halt);            // Freeze display when halted
    led_lct_ff         <=  tmb_trig_pulse && tmb_match;  // TMB found ALCT + CLCT match
    led_alct_ff        <=  alct_pat_trig_os;             // ALCT active_feb
    led_clct_ff        <=  trig_clct_flash;              // CLCT or external trigger, not ALCT
    led_l1a_intime_ff  <=  l1a_keep;                     // L1A arrived in window or forced L1A
    led_invpat_ff      <=  discard_event_led;            // Invalid pattern after drift
    led_nol1a_flush_ff <=  tmb_nol1a;                    // L1A never arrived, event flushed
    led_nomatch_ff     <=  tmb_trig_pulse && !tmb_match; // Trigger but no match 
  end

// Front Panel: Normal Mode LED Digital pulse stretch for visual persistence
  x_flashsm #(19) uflashf0  (.trigger(led_lct_ff),        .hold(led_hold), .clock(clock), .out(led_lct_os)        );  // LED0  Blue  LCT  
  x_flashsm #(19) uflashf1  (.trigger(led_alct_ff),       .hold(led_hold), .clock(clock), .out(led_alct_os)       );  // LED1  Green  ALCT
  x_flashsm #(19) uflashf2  (.trigger(led_clct_ff),       .hold(led_hold), .clock(clock), .out(led_clct_os)       );  // LED2  Green  CLCT
  x_flashsm #(19) uflashf3  (.trigger(led_l1a_intime_ff), .hold(led_hold), .clock(clock), .out(led_l1a_intime_os) );  // LED3  Green  L1A
  x_flashsm #(19) uflashf4  (.trigger(led_invpat_ff),     .hold(led_hold), .clock(clock), .out(led_invpat_os)     );  // LED4  Amber  INVP
  x_flashsm #(19) uflashf5  (.trigger(led_nomatch_ff),    .hold(led_hold), .clock(clock), .out(led_nomatch_os)    );  // LED5  Amber  NMAT
  x_flashsm #(19) uflashf6  (.trigger(led_nol1a_flush_ff),.hold(led_hold), .clock(clock), .out(led_nol1a_flush_os));  // LED6  Red    NL1A
                                               // LED7  Green VME
  assign led_lct         = led_lct_os;         // LED0  Blue  LCT
  assign led_alct        = led_alct_os;        // LED1  Green ALCT
  assign led_clct        = led_clct_os;        // LED2  Green CLCT
  assign led_l1a_intime  = led_l1a_intime_os;  // LED3  Green L1A
  assign led_invpat      = led_invpat_os;      // LED4  Amber INVP
  assign led_nomatch     = led_nomatch_os;     // LED5  Amber NMAT
  assign led_nol1a_flush = led_nol1a_flush_os; // LED6  Red   NL1A

// Inboard display buffer space in-use bar graph
  assign led_bd[7:0] = buf_display[7:0];

//------------------------------------------------------------------------------------------------------------------
// Raw Hits RAM Section
//    Stores DMB raw hits dump while fifo write enable is low.
//    RAM address increments by 1 for each data word.
//    VME may read or write the RAM
//------------------------------------------------------------------------------------------------------------------
// DMB write address counter for VME readback
  reg  [MXRAMADR-1:0] wadr=0;

  wire   wadr_reset = (read_sm == xdmb) || (dmb_reset && (read_sm == xckstack)) || sm_reset;
  wire   wadr_cnten = ~dmb_ffdly[18];
  assign read_sm_xdmb = (read_sm == xdmb);

  always @(posedge clock) begin
  if    (wadr_reset) wadr = 0;
  else if (wadr_cnten) wadr = wadr + 1'b1;
  end

// Buffer DMB write address counter and data
  reg [MXRAMADR-1:0]  dmb_wdcnt = 0;
   reg  [MXRAMADR-1:0]  seq_wadr  = 0;
  reg          seq_wr    = 0;

  always @(posedge clock or posedge sm_reset) begin
  if (sm_reset) begin
  seq_wdata  <= 0;
  seq_wr    <= 0;
  seq_wadr  <= 0;
  dmb_wdcnt  <= 0;
  end
  else begin
  seq_wdata  <= dmb_ffdly[17:0];
  seq_wr    <= ~dmb_ffdly[18];
  seq_wadr  <= wadr;
  dmb_wdcnt  <= wadr;
  end
  end

  assign dmb_busy = seq_wr;

// Store DMB raw hits readout word stream: 
  wire [1:0]  seq_wea;
  wire [1:0]  dmb_web;
  wire [35:0] dmb_rdata_mux;
  wire [3:0]  seq_dopa;

  assign seq_wea[0]  = seq_wr & (seq_wadr[11]==0);
  assign seq_wea[1]  = seq_wr & (seq_wadr[11]==1);

  assign dmb_web[0]  = dmb_wr & (dmb_adr[11]==0);
  assign dmb_web[1]  = dmb_wr & (dmb_adr[11]==1);

  wire seq_ena = seq_wr;        // Only enable port A during sequencer writes
  wire dmb_enb = !seq_ena;      // Enable port B when A is not busy over-writing it

  genvar jdepth;
  genvar iwidth;

// Dual port Block RAM 18x4K built from 9x2K+9x2K cascaded to a second bank of 9x2K+9x2K
//  Port A wo written by sequencer
//  Port B rw read/write by VME
  
  initial $display("sequencer: generating Virtex6 RAMB18E1_S9_S9 dmb_bram");

  assign seq_dopa = 0;      // Port A dummy not needed for Virtex6
  wire [8:0] db [1:0][1:0]; // Port B dummy for Virtex6, does not need sump
  
  generate
  for (jdepth=0; jdepth<=1; jdepth=jdepth+1) begin: depth_2x2048
  for (iwidth=0; iwidth<=1; iwidth=iwidth+1) begin: width_2x9

  RAMB18E1 #(                         // Virtex6
    .RAM_MODE           ("TDP"),        // SDP or TDP
    .READ_WIDTH_A       (0),            // 0,1,2,4,9,18,36 Read/write width per port
    .WRITE_WIDTH_A      (9),            // 0,1,2,4,9,18
    .READ_WIDTH_B       (9),            // 0,1,2,4,9,18
    .WRITE_WIDTH_B      (9),            // 0,1,2,4,9,18,36
    .WRITE_MODE_A       ("READ_FIRST"), // WRITE_FIRST, READ_FIRST, or NO_CHANGE
    .WRITE_MODE_B       ("READ_FIRST"),
    .SIM_COLLISION_CHECK("ALL")         // ALL, WARNING_ONLY, GENERATE_X_ONLY or NONE)
  ) dmb_bram (
    .WEA           ({2{seq_wea[jdepth]}}),                   //  2-bit A port write enable input
    .ENARDEN       (seq_ena),                                //  1-bit A port enable/Read enable input
    .RSTRAMARSTRAM (1'b0),                                   //  1-bit A port set/reset input
    .RSTREGARSTREG (1'b0),                                   //  1-bit A port register set/reset input
    .REGCEAREGCE   (1'b0),                                   //  1-bit A port register enable/Register enable input
    .CLKARDCLK     (clock),                                  //  1-bit A port clock/Read clock input
    .ADDRARDADDR   ({seq_wadr[10:0],3'h7}),                  // 14-bit A port address/Read address input 9b->[13:3]
    .DIADI         ({8'h00,seq_wdata[7+9*iwidth:9*iwidth]}), // 16-bit A port data/LSB data input
    .DIPADIP       ({1'b0,seq_wdata[8+9*iwidth]}),           //  2-bit A port parity/LSB parity input
    .DOADO         (),                                       // 16-bit A port data/LSB data output
    .DOPADOP       (),                                       //  2-bit A port parity/LSB parity output

    .WEBWE         ({4{dmb_web[jdepth]}}),                   //  4-bit B port write enable/Write enable input
    .ENBWREN       (dmb_enb),                                //  1-bit B port enable/Write enable input
    .REGCEB        (1'b0),                                   //  1-bit B port register enable input
    .RSTRAMB       (1'b0),                                   //  1-bit B port set/reset input
    .RSTREGB       (1'b0),                                   //  1-bit B port register set/reset input
    .CLKBWRCLK     (clock),                                  //  1-bit B port clock/Write clock input
    .ADDRBWRADDR   ({dmb_adr[10:0],3'h7}),                   // 14-bit B port address/Write address input 9b->[13:3]
    .DIBDI         ({8'h00,dmb_wdata[7+9*iwidth:9*iwidth]}), // 16-bit B port data/MSB data input
    .DIPBDIP       ({1'b0,dmb_wdata[8+9*iwidth]}),           //  2-bit B port parity/MSB parity input
    .DOBDO         ({db[jdepth][iwidth][7:0],dmb_rdata_mux[(jdepth*18)+(7+9*iwidth):(jdepth*18)+(9*iwidth)]}), // 16-bit B port data/MSB data output
    .DOPBDOP       ({db[jdepth][iwidth][8],  dmb_rdata_mux[(jdepth*18)+(8+9*iwidth)]})                         //  2-bit B port parity/MSB parity output
  );
  end
  end
  endgenerate

// Multiplex 1st and 2nd RAM banks, delay adr msb 1bx to wait for RAM access
  reg dmb_adr11_ff=0;

  always @(posedge clock) begin
  dmb_adr11_ff <= dmb_adr[11];
  end

  assign dmb_rdata[17:0] = (dmb_adr11_ff) ? dmb_rdata_mux[35:18] : dmb_rdata_mux[17:0];

//-------------------------------------------------------------------------------------------------------------------
// Raw hits write-buffer auto-clear state machine, should be here only temporarily
//-------------------------------------------------------------------------------------------------------------------
// State machine declarations
  reg [3:0] cb_sm;          // synthesis attribute safe_implementation of cb_sm is "yes";
  parameter cb_startup = 0;
  parameter cb_idle    = 1;
  parameter cb_clear   = 2;
  parameter cb_wait    = 3;

  reg [0:0] cb_cnt=0;
  always @(posedge clock) begin
    if (cb_sm==cb_clear) cb_cnt <= cb_cnt+1'b1;
    else                 cb_cnt <= 0;
  end

  wire cb_full = (clct_sm==idle) && (read_sm==xckstack) && buf_stalled && wr_buf_autoclr_en;
  wire cb_done = (cb_cnt==0);

  assign buf_reset = (cb_sm==cb_clear) || !startup_done;

// Write-buffer auto-clear state machine
  always @(posedge clock or posedge sm_reset) begin
    if (sm_reset) cb_sm <= cb_startup;
    else begin
      case (cb_sm)
        cb_startup: if (startup_done) cb_sm <= cb_idle;
        cb_idle:    if (cb_full)      cb_sm <= cb_clear;
        cb_clear:                     cb_sm <= cb_wait;
        cb_wait:    if (cb_done)      cb_sm <= cb_idle;
        default                       cb_sm <= cb_idle;
      endcase
    end
  end

//-------------------------------------------------------------------------------------------------------------------
// Sump unused signals
//-------------------------------------------------------------------------------------------------------------------
  wire clct_sump = 
  cfeb_first_frame | cfeb_last_frame |
  rpc_first_frame  | rpc_last_frame  | 
  mini_first_frame | mini_last_frame |
  bcb_first_frame  | bcb_last_frame;

  wire header_sump=  
  (|r_mpc_reserved)  |
  r_wr_buf_avail    |
  rpc_tbinbxn[4]    |
  mini_rdata[15];

  wire scope_sump =
  (|scp_rpc0_bxn[2:0])  |  // RPC0 bunch crossing number
  (|scp_rpc1_bxn[2:0])  |  // RPC1 bunch crossing number
  (|scp_rpc0_nhits[3:0])  |  // RPC0 number of pads hit
  (|scp_rpc1_nhits[3:0]);    // RPC1 number of pads hit

  assign sequencer_sump = 
  (|tmb_match_pri[3:0])  |  // Priority of clct in clct window
  (|l1a_pri_best[3:0])  |
  (|dang)      |
  l1a_dob_sump  |
  mpc_frame_ff  |      // MPC frame latch strobe
  clct_sump    |
  cfeb_tbin[4]  |
  tmb_alct_only_dly  |    // Not sure how to implement this 4/28/08
  l1a_allow_alct_only  |    // Not sure how to implement this
  (|seq_dopa[3:0])  |    // Occupy block ram parity to avert dangling outputs warning
  (|triad_tp[6:0])  |    // Used sometimes for scope
  (|cfeb_layer_or[5:0])  |  // we dont use this here, its now in pattern finder section, maybe put in header
  (|hs_nlayers_hit[2:0])  |  // was for header, but is already included in pattern info
  scope_sump    |
  header_sump    |
  alct1_valid    |
  clct_vpf_tprt;

//------------------------------------------------------------------------------------------------------------------------
//  Prodcedural function to sum number of bits==1 into a binary value - LUT version
//  count1sof7 = (inp[6]+inp[5]+inp[4]+inp[3])+(inp[2]+inp[1]+inp[0]);
//
//  08/12/2010  Adder version for virtex6 because xst inferred read-only ram instead of luts
//  03/22/2013  Replace with ROM version for Virtex-6
//------------------------------------------------------------------------------------------------------------------------
  function [2:0] count1sof7;
  input   [6:0] bits;
  reg      [2:0] rom;
  begin
  case(bits[6:0])    // 128x3 ROM
  7'b0000000:  rom = 0;
  7'b0000001:  rom = 1;
  7'b0000010:  rom = 1;
  7'b0000011:  rom = 2;
  7'b0000100:  rom = 1;
  7'b0000101:  rom = 2;
  7'b0000110:  rom = 2;
  7'b0000111:  rom = 3;
  7'b0001000:  rom = 1;
  7'b0001001:  rom = 2;
  7'b0001010:  rom = 2;
  7'b0001011:  rom = 3;
  7'b0001100:  rom = 2;
  7'b0001101:  rom = 3;
  7'b0001110:  rom = 3;
  7'b0001111:  rom = 4;
  7'b0010000:  rom = 1;
  7'b0010001:  rom = 2;
  7'b0010010:  rom = 2;
  7'b0010011:  rom = 3;
  7'b0010100:  rom = 2;
  7'b0010101:  rom = 3;
  7'b0010110:  rom = 3;
  7'b0010111:  rom = 4;
  7'b0011000:  rom = 2;
  7'b0011001:  rom = 3;
  7'b0011010:  rom = 3;
  7'b0011011:  rom = 4;
  7'b0011100:  rom = 3;
  7'b0011101:  rom = 4;
  7'b0011110:  rom = 4;
  7'b0011111:  rom = 5;
  7'b0100000:  rom = 1;
  7'b0100001:  rom = 2;
  7'b0100010:  rom = 2;
  7'b0100011:  rom = 3;
  7'b0100100:  rom = 2;
  7'b0100101:  rom = 3;
  7'b0100110:  rom = 3;
  7'b0100111:  rom = 4;
  7'b0101000:  rom = 2;
  7'b0101001:  rom = 3;
  7'b0101010:  rom = 3;
  7'b0101011:  rom = 4;
  7'b0101100:  rom = 3;
  7'b0101101:  rom = 4;
  7'b0101110:  rom = 4;
  7'b0101111:  rom = 5;
  7'b0110000:  rom = 2;
  7'b0110001:  rom = 3;
  7'b0110010:  rom = 3;
  7'b0110011:  rom = 4;
  7'b0110100:  rom = 3;
  7'b0110101:  rom = 4;
  7'b0110110:  rom = 4;
  7'b0110111:  rom = 5;
  7'b0111000:  rom = 3;
  7'b0111001:  rom = 4;
  7'b0111010:  rom = 4;
  7'b0111011:  rom = 5;
  7'b0111100:  rom = 4;
  7'b0111101:  rom = 5;
  7'b0111110:  rom = 5;
  7'b0111111:  rom = 6;
  7'b1000000:  rom = 1;
  7'b1000001:  rom = 2;
  7'b1000010:  rom = 2;
  7'b1000011:  rom = 3;
  7'b1000100:  rom = 2;
  7'b1000101:  rom = 3;
  7'b1000110:  rom = 3;
  7'b1000111:  rom = 4;
  7'b1001000:  rom = 2;
  7'b1001001:  rom = 3;
  7'b1001010:  rom = 3;
  7'b1001011:  rom = 4;
  7'b1001100:  rom = 3;
  7'b1001101:  rom = 4;
  7'b1001110:  rom = 4;
  7'b1001111:  rom = 5;
  7'b1010000:  rom = 2;
  7'b1010001:  rom = 3;
  7'b1010010:  rom = 3;
  7'b1010011:  rom = 4;
  7'b1010100:  rom = 3;
  7'b1010101:  rom = 4;
  7'b1010110:  rom = 4;
  7'b1010111:  rom = 5;
  7'b1011000:  rom = 3;
  7'b1011001:  rom = 4;
  7'b1011010:  rom = 4;
  7'b1011011:  rom = 5;
  7'b1011100:  rom = 4;
  7'b1011101:  rom = 5;
  7'b1011110:  rom = 5;
  7'b1011111:  rom = 6;
  7'b1100000:  rom = 2;
  7'b1100001:  rom = 3;
  7'b1100011:  rom = 4;
  7'b1100100:  rom = 3;
  7'b1100101:  rom = 4;
  7'b1100110:  rom = 4;
  7'b1100111:  rom = 5;
  7'b1101000:  rom = 3;
  7'b1101001:  rom = 4;
  7'b1101010:  rom = 4;
  7'b1101011:  rom = 5;
  7'b1101100:  rom = 4;
  7'b1101101:  rom = 5;
  7'b1101110:  rom = 5;
  7'b1101111:  rom = 6;
  7'b1110000:  rom = 3;
  7'b1110001:  rom = 4;
  7'b1110010:  rom = 4;
  7'b1110011:  rom = 5;
  7'b1110100:  rom = 4;
  7'b1110101:  rom = 5;
  7'b1110110:  rom = 5;
  7'b1110111:  rom = 6;
  7'b1111000:  rom = 4;
  7'b1111001:  rom = 5;
  7'b1111010:  rom = 5;
  7'b1111011:  rom = 6;
  7'b1111100:  rom = 5;
  7'b1111101:  rom = 6;
  7'b1111110:  rom = 6;
  7'b1111111:  rom = 7;
  endcase

  count1sof7=rom;

  end
  endfunction

//-------------------------------------------------------------------------------------------------------------------
// Debug Simulation state machine display
//-------------------------------------------------------------------------------------------------------------------
`ifdef DEBUG_SEQUENCER
// DMB frame that looks like DDU data
  reg [15:0] deb_dmb_tx  = 0;
  reg        deb_dmb_nwr = 0;
  
  always @(posedge clock or posedge startup_blank) begin
    if (startup_blank) begin // async preset
      deb_dmb_tx[15:0]<= 0;  // fifo data
      deb_dmb_nwr    <= 1;
    end
    else begin                // sync load
      deb_dmb_tx[14:0] <= dmb_ffdly[14:0]; // fifo data  
      deb_dmb_tx[15]   <= dmb_ffdly[15];   // DDU special
      deb_dmb_nwr      <= dmb_ffdly[18];   // DMB /wr
    end
  end

// CLCT Sequencer State Declarations
  reg[63:0] clct_sm_dsp;

  always @* begin
    case (clct_sm)
      startup:  clct_sm_dsp <= "startup ";
      idle:     clct_sm_dsp <= "idle    ";
      pretrig:  clct_sm_dsp <= "pretrig ";
      throttle: clct_sm_dsp <= "throttle";
      flush:    clct_sm_dsp <= "flush   ";
      halt:     clct_sm_dsp <= "halt    ";
      default   clct_sm_dsp <= "default ";
    endcase
  end

// Readout State Declarations
  reg[63:0] read_sm_dsp;
  always @* begin
    case (read_sm)
      xstartup: read_sm_dsp  <= "xstartup";
      xckstack: read_sm_dsp <= "xckstack";
      xdmb:     read_sm_dsp <= "xdmb    ";
      xheader:  read_sm_dsp <= "xheader ";
      xe0b:     read_sm_dsp <= "xe0b    ";
      xdump:    read_sm_dsp <= "xdump   ";
      xb04:     read_sm_dsp <= "xb04er  ";
      xrpc:     read_sm_dsp <= "xrpc    ";
      xe04:     read_sm_dsp <= "xe04    ";
      xb05:     read_sm_dsp <= "xb05    ";
      xscope:   read_sm_dsp <= "xscope  ";
      xe05:     read_sm_dsp <= "xe05    ";
      xb07:     read_sm_dsp <= "xb07    ";
      xmini:    read_sm_dsp <= "xmini   ";
      xe07:     read_sm_dsp <= "xe07    ";
      xbcb:     read_sm_dsp <= "xbcb    ";
      xblkbit:  read_sm_dsp <= "xblkbit ";
      xecb:     read_sm_dsp <= "xecb    ";
      xmod40:   read_sm_dsp <= "xmod40  ";
      xmod41:   read_sm_dsp <= "xmod41  ";
      xe0f:     read_sm_dsp <= "xe0f    ";
      xcrc0:    read_sm_dsp <= "xcrc0   ";
      xcrc1:    read_sm_dsp <= "xcrc1   ";
      xlast:    read_sm_dsp <= "xlast   ";
      xpop:     read_sm_dsp <= "xpop    ";
      xhalt:    read_sm_dsp <= "xhalt   ";
      default   read_sm_dsp <= "default ";
    endcase
  end

// Write-buffer auto-clear state machine display
  reg[79:0] cb_sm_dsp;

  always @* begin
    case (cb_sm)
      cb_startup: cb_sm_dsp <= "cb_startup";
      cb_idle:    cb_sm_dsp <= "cb_idle   ";
      cb_clear:   cb_sm_dsp <= "cb_clear  ";
      cb_wait:    cb_sm_dsp <= "cb_wait   ";
      default     cb_sm_dsp <= "cb_startup";
    endcase
  end
`endif

//------------------------------------------------------------------------------------------------------------------
  endmodule
//------------------------------------------------------------------------------------------------------------------
