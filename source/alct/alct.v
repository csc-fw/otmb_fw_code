`timescale 1ns / 1ps
//`define DEBUG_ALCT 1
//-----------------------------------------------------------------------------------------------------------------
// ALCT 80MHz Receiver / Demultiplexer
//
// Demultiplexes 80MHz ALCT signals 1:2 to 40MHz
// Maps ALCT rxnn signal names
//------------------------------------------------------------------------------------------------------------------
//  11/26/2001  Initial
//  12/03/2001  Replaced local demux logic with x_demux
//  12/20/2001  Added transmit mux
//  12/28/2001  Added valid_pattern_flag output
//  01/15/2002  Added ext inject and trigger enables from cfg register
//  01/28/2002  Added transmitter sync, now rx with tmb clock, tx with alct clock
//  02/06/2002  Added aclr to demux
//  03/02/2002  Replaced library calls with behavioral code
//  03/03/2002  Added sequencer RAM
//  03/12/2002  Added CCB front panel status
//  03/14/2002  Added alct0_vme
//  03/18/2002  Special version: transmits on 40MHz falling edge, does not use alct_clock or alct_clock_2x
//  03/20/2002  Added alct_clear to blank received data, added alct injector
//  03/21/2002  Injector now waits for start to clear before re-arming
//  03/27/2002  Alct_clear now prevents ram writing for alct-less running
//  03/28/2002  Add word count to vme and timing test points
//  03/29/2002  Change wadr reset to sequencer signal, was on l1a before
//  04/24/2002  Changed alct_status assignments to share with tmb signals
//  06/03/2002  Active feb flag now comes from alct0, as flag is not implemented on ALCT board
//  06/07/2002  Fixed active feb to work with injector
//  06/24/2002  Active FEB flag finally implemented on ALCT board, add it here, and modify injector
//  10/15/2002  Revert to clock_alct and 2x for ALCT transmitter
//  01/09/2003  ALCT raw hits now go directly to DMB backplane
//  01/22/2003  Remove alct_active_feb ff to speed it up 1 clock, add VME readout of ALCT raw hits
//  02/04/2003  Add aset to x_mux
//  04/22/2003  Mod alct_clear to keep wr_fifo high
//  05/07/2003  Add alct_2nd_valid for scope
//  05/14/2003  Add fifo controls to sync vme readout with clct
//  03/12/2004  Change to ddr inputs to avoid clock sharing conflict with rpc
//  03/15/2004  Change to ddr outputs
//  04/19/2004  Clear alct ram word count on vme reset
//  04/19/2004  Revert alct_rx from DDR to 80MHz, had sync err on 1/2 the bits for some unknown reason
//  04/20/2004  Revert all DDR to 80MHz
//  06/07/2004  Change to x_demux_v2 which has aset for mpc
//  07/30/2004  Add crc error detection
//  08/02/2004  Add alct event counters
//  08/03/2004  Add evcnt_reset to event counters
//  08/09/2004  Add oneshot to ext_trig and ext_inject
//  08/23/2004  Add alct registers for alct board debug firmware
//  08/25/2004  Add vme xor to ccb_clock_enable
//  08/26/2004  Add stop on any counter overflowed
//  08/30/2004  Add lct compare for alct debug firmware
//  10/05/2004  Add crc error test point for oscope trigger
//  03/03/2006  Fix spelling, no logic changes
//  08/30/2006  Store full alct bxn for vme readout
//  09/11/2006  Mods for xstetc to 
//  09/19/2006  Change to virtex 2 rams, mod alct_sync_mode mux to send 1s in high order alct_txa/b
//  10/10/2006  Replace 80mhz mux and demux with 40mhz ddr
//  04/27/2007  Remove rx sync stage, shifts rx clock 12.5ns
//  07/16/2007  Replace 9 8kx2 RAMs with 2 2kx9, mod wr_fifo=1 at power-up to block spurious ram writes
//  07/16/2007  Add reset to injector state machine so xst can recognize it
//  07/18/2007  Add dopa sump to avoid spurious parity bit warning
//  08/23/2007  Mod crc calc for new trailer format, increase mxalct to carry full bxn
//  08/31/2007  Expand vme counter width
//  09/04/2007  Consolidate counter widths
//  09/07/2007  Fix injector wait state
//  09/10/2007  Mod alct err
//  09/14/2007  Injected alct now counts as alct received
//  10/10/2007  Remove unused delay state in injector sm
//  10/11/2007  Conform crc logic to ddu, skip de0d marker because ddu logic fails to include it
//  12/21/2007  Add prefix to seu and seq status
//  01/31/2008  Removed 2bx FF delay in ALCT trigger path, send alcts to sequencer instead of tmb.v
//  04/25/2008  Add alct_bx0
//  04/28/2008  Reorganize event counters
//  04/29/2008  Convert to 2D counter arrays
//  05/19/2008  Mod alct stucture error detection to exclude wg=amu=q=bxn=0
//  05/29/2008  Subdivide alct structure error counter to count each error type, remove readout sync machine
//  06/03/2008  Add scope signals
//  08/12/2008  Add programmable alct data tx delay
//  08/12/2008  Add 0 inits to all FFs
//  01/13/2009  Expand alct_seq_cmd to 4 bits, take 1 from alct_reserved_in[4]
//  01/16/2009  Add alct cable loopback test logic
//  01/21/2009  Add rng comparison latch
//  01/26/2009  Rebuild alct transmit data mux to ensure 40MHz clock alignment, add sync_mode error latch
//  01/30/2009  Enable alct transmitter lfsr with alct_sync_tx_random
//  02/05/2009  Add received data blanking during alct_sync_mode
//  02/24/2009  Add ECC to received data
//  03/02/2009  Add ECC enable, add ECC result to randoms pipeline, add ECC result to alct's lct
//  03/03/2009  Add ECC to transmit data, remove dmb signals from ecc, add FF to receive data ecc stage
//  03/11/2009  Add counters for all ecc syndrome cases
//  03/12/2009  Add alct bx0 counter
//  03/16/2009  Add 1bx to alct trigger path to buffer ecc decoding
//  03/20/2009  Redesign alct.v x_mux sync stage to improve alct_rx_clock window
//  03/24/2009  Add buffer ffs before iobs in 80mhz mux
//  03/26/2009  Move alct tx FFs into sync mux sub design
//  03/30/2009  Add interstage to alct transmitter
//  04/06/2009  Remove mux ffs replaced by sync-stage FFs in x_mux
//  04/07/2009  Put mux ffs back, they improve rx tx good spots
//  04/22/2009  Shorten ALCT raw hits storage from 2048 to 1024bx to free up a block ram
//  04/23/2009  Revert alct raw hits word counter to 2048, but keep ram storage at 1024, alc672 uses 924 words
//  05/08/2009  Add pre-delay to random pattern delay pipeline to span 8-23bx instead of 0-15bx
//  05/12/2009  Add alct trigger path blanking option if ecc cannot correct an error, add counter for blocked alcts
//  05/12/2009  Remove seq_status[1:0], seu_status[1:0], reserved_out[3:0], reserved_in[3:0] from VME
//  05/27/2009  Change to alct receive data muonic timing to float ALCT board in clock-space
//  05/28/2009  Connect muonic timing clocks from bufmuxg
//  06/12/2009  Replace txd rxd interstages with lac clock
//  06/16/2009  Remove digital phase shift half cycle
//  07/10/2009  Replace rx mux with cfeb version but with internal iob true attribute enabled
//  07/22/2009  Remove delay and posneg from alct receiver sync stage
//  08/05/2009  a;ct_rx: Remove interstage delay SRL and iob async clear, add final stage sync clear
//  08/05/2009  alct_tx: Move timing constraints to ucf, remove async clear, add sync clear to IOB ffs
//  08/13/2009  Put alct rxd posneg back
//  08/14/2009  Mod for new posneg structure
//  08/14/2009  Take alct posneg back out, can not pass timing in par
//  08/17/2009  Put alct posneg back in, with 2x clock interstage, and new alct rx locs in par
//  09/03/2009  Change alct_txd_delay name
//  09/14/2009  Add ecc rx tx error outputs to sync err module
//  10/14/2009  Add error counter for 2-identical alct muons
//  10/15/2009  Add ff pipe for alct structure errors
//  02/26/2010  Add event clear for alct vme diagnostic registers
//  06/30/2010  Mod injector RAM for alct and l1a bits
//  07/23/2010  Replace DDR sub-modules
//  07/26/2010  Port to ise 12
//  08/05/2010  Add power up holdoff on alct_dmb_ff to wait for alct_rx muonic to initialize
//  08/05/2010  Invert logic on _wr_fifo at alct_2nd_ff[17]
//  10/15/2010  Add virtex 6 RAM option
//  02/13/2013  Virtex-6 only
//  05/02/2013  Port ALCT DDR rx tx from Virtex-2
//-----------------------------------------------------------------------------------------------------------------
  module alct
  (
// Clock Port
  clock,
  clock_2x,
  clock_lac,

// Phase delayed clocks
  clock_alct_rxd,
  clock_alct_txd,
  alct_rxd_posneg,
  alct_txd_posneg,

// Global clocks
  global_reset,
  ttc_resync,

// ALCT Ports
  alct_rx,
  alct_txa,
  alct_txb,

// TTC Command Ports
  ccb_cmd,
  ccb_cmd_strobe,
  ccb_data_strobe,
  ccb_subaddr_strobe,

// CCB Ports
  ccb_bx0,
  alct_ext_inject,
  alct_ext_trig,
  ccb_l1accept,
  ccb_evcntres,
  alct_adb_pulse_sync,
  alct_cfg_done,
  alct_state,

// Sequencer Ports
  alct_active_feb,
  alct0_valid,
  alct1_valid,
  alct_dmb,
  read_sm_xdmb,

// TMB Ports
  alct0_tmb,
  alct1_tmb,
  alct_bx0_rx,
  alct_ecc_err,
  alct_ecc_rx_err,
  alct_ecc_tx_err,

// VME Control/Status Ports
  alct_ecc_en,
  alct_ecc_err_blank,
  alct_txd_int_delay,
  alct_clock_en_vme,
  alct_seq_cmd,
  event_clear_vme,
  alct0_vme,
  alct1_vme,
  bxn_alct_vme,

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

// VME ALCT Raw hits RAM Ports
  alct_raw_reset,
  alct_raw_radr,
  alct_raw_rdata,
  alct_raw_busy,
  alct_raw_done,
  alct_raw_wdcnt,

// TMB Control Ports
  cfg_alct_ext_trig_en,
  cfg_alct_ext_inject_en,
  cfg_alct_ext_trig,
  cfg_alct_ext_inject,
  alct_clear,
  alct_inject,
  alct_inj_delay,
  alct_inj_ram_en,
  alct0_inj,
  alct1_inj,
  alct0_inj_ram,
  alct1_inj_ram,
  alctb_inj_ram,
  inj_ramout_busy,

// Trigger/Readout Counter Ports
  cnt_all_reset,
  cnt_stop_on_ovf,
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

// ALCT Structure Error Counters
  alct_err_counter0,
  alct_err_counter1,
  alct_err_counter2,
  alct_err_counter3,
  alct_err_counter4,
  alct_err_counter5,

// Test Points
  alct_wr_fifo_tp,
  alct_first_frame_tp,
  alct_last_frame_tp,
  alct_crc_err_tp,
  scp_alct_rx,

// Sump
  alct_sump
  
// Debug
`ifdef DEBUG_ALCT
  ,sm_reset
  ,inj_sm_dsp
  ,alct_sync_mode
  ,alct_sync_teventodd
  ,alct_sync_random_loop
  ,alct_sync_adr
  ,alct_sync_random
  ,alct_txa_1st_mux
  ,alct_txa_2nd_mux
  ,alct_txb_1st_mux
  ,alct_txb_2nd_mux
  ,alct_dmb_ff
  ,alct_1st_ff
  ,alct_2nd_ff
  ,alct_dec_in
  ,alct_dec_out
  ,enc_in
  ,parity_out
  ,alct_ecc_err_rx
  ,alct_sent_bxn
  ,alct_wdata
  ,alct_adr
  ,alct_wr
`endif
  );
//-----------------------------------------------------------------------------------------------------------------
// Constants
//-----------------------------------------------------------------------------------------------------------------
  parameter MXALCT     =  16; // Number bits per ALCT word
  parameter MXARAMADR  =  11; // Number ALCT Raw Hits RAM address bits
  parameter MXARAMDATA =  18; // Number ALCT Raw Hits RAM data bits, does not include fifo wren
  parameter MXCNTVME   =  30; // VME counter width
  parameter MXASERR    =  6;  // Number of ALCT structure error counters

//-----------------------------------------------------------------------------------------------------------------
// Ports
//-----------------------------------------------------------------------------------------------------------------
// Clock Ports
  input          clock;     // 40MHz TMB system clock
  input          clock_2x;  // 80MHz commutator clock
  input          clock_lac; // 40MHz logic accessible clock

// Phase delayed clocks
  input          clock_alct_rxd;  // ALCT rxd  40 MHz clock
  input          clock_alct_txd;  // ALCT rxd  40 MHz clock
  input          alct_rxd_posneg; // Select inter-stage clock 0 or 180 degrees
  input          alct_txd_posneg; // Select inter-stage clock 0 or 180 degrees

// Global reset
  input          global_reset; // 1=Reset everything
  input          ttc_resync;   // 1=Reset everything

// ALCT Ports
  input  [28:1]  alct_rx;  // 80MHz LVDS inputs  from ALCT, alct_rx[0] is JTAG TDO, non-mux'd
  output [17:5]  alct_txa; // 80MHz LVDS outputs
  output [23:19] alct_txb; // 80MHz LVDS outputs

// TTC Command Word
  input [7:0] ccb_cmd;            // TTC command word
  input       ccb_cmd_strobe;     // TTC command valid
  input       ccb_data_strobe;    // TTC data valid
  input       ccb_subaddr_strobe; // TTC sub-addr valid

// CCB Ports
  input        ccb_bx0;             // TTC bx0
  input        alct_ext_inject;     // External inject
  input        alct_ext_trig;       // External trigger
  input        ccb_l1accept;        // L1A
  input        ccb_evcntres;        // Event counter reset
  input        alct_adb_pulse_sync; // Synchronous test pulse (asyn pulse is on PCB)
  output       alct_cfg_done;       // ALCT reports FPGA configuration done
  output [5:0] alct_state;          // ALCT state for CCB front panel ECL outputs

// Sequencer Ports
  output        alct_active_feb; // ALCT has an active FEB, faster than alct_1st_valid
  output        alct0_valid;     // ALCT has valid LCT
  output        alct1_valid;     // ALCT has valid LCT
  output [18:0] alct_dmb;        // ALCT to DMB
  input         read_sm_xdmb;    // TMB sequencer starting a readout

// TMB Ports
  output [MXALCT-1:0] alct0_tmb;       // ALCT best muon
  output [MXALCT-1:0] alct1_tmb;       // ALCT second best muon
  output              alct_bx0_rx;     // ALCT bx0 received
  output [1:0]        alct_ecc_err;    // ALCT ecc syndrome code
  output              alct_ecc_rx_err; // ALCT uncorrected ECC error in data ALCT received from TMB
  output              alct_ecc_tx_err; // ALCT uncorrected ECC error in data ALCT transmitted to TMB

// VME Control/Status Ports
  input         alct_ecc_en;        // Enable ALCT ECC decoder, else do no ECC correction
  input         alct_ecc_err_blank; // Blank alcts with uncorrected ecc errors
  input  [3:0]  alct_txd_int_delay; // ALCT data transmit delay, integer bx
  input         alct_clock_en_vme;  // Enable ALCT 40MHz clock
  input  [3:0]  alct_seq_cmd;       // ALCT Sequencer command
  input         event_clear_vme;    // Event clear for aff,alct,clct,mpc vme diagnostic registers
  output [15:0] alct0_vme;          // Latched 1st best muon on last valid pattern
  output [15:0] alct1_vme;          // Latched 2nd best muon on last valid pattern
  output [4:0]  bxn_alct_vme;       // ALCT bxn on last alct valid pattern flag

// VME ALCT sync mode ports
  input [9:0] alct_sync_txdata_1st; // ALCT sync mode data to send for loopback
  input [9:0] alct_sync_txdata_2nd; // ALCT sync mode data to send for loopback
  input [3:0] alct_sync_rxdata_dly; // ALCT sync mode delay pointer to valid data
  input [3:0] alct_sync_rxdata_pre; // ALCT sync mode delay pointer to valid data, fixed pre-delay

  input         alct_sync_tx_random;  // ALCT sync mode tmb transmits random data to alct
  input         alct_sync_clr_err;    // ALCT sync mode clear rng error FFs

  output        alct_sync_1st_err;    // ALCT sync mode 1st-intime match ok, alct-to-tmb
  output        alct_sync_2nd_err;    // ALCT sync mode 2nd-intime match ok, alct-to-tmb
  output        alct_sync_1st_err_ff; // ALCT sync mode 1st-intime match ok, alct-to-tmb, latched
  output        alct_sync_2nd_err_ff; // ALCT sync mode 2nd-intime match ok, alct-to-tmb, latched
  output [1:0]  alct_sync_ecc_err;    // ALCT sync mode ecc error syndrome
  
  output [28:1] alct_sync_rxdata_1st; // Received demux data for demux timing-in
  output [28:1] alct_sync_rxdata_2nd; // Received demux data for demux timing-in
  output [28:1] alct_sync_expect_1st; // Expected demux data for demux timing-in
  output [28:1] alct_sync_expect_2nd; // Expected demux data for demux timing-in
  
// VME ALCT Raw hits RAM Ports
  input                   alct_raw_reset; // Reset raw hits write address and done flag
  input  [MXARAMADR-1:0]  alct_raw_radr;  // Raw hits RAM VME read address
  output [MXARAMDATA-1:0] alct_raw_rdata; // Raw hits RAM VME read data
  output                  alct_raw_busy;  // Raw hits RAM VME busy writing ALCT data
  output                  alct_raw_done;  // Raw hits ready for VME readout
  output [MXARAMADR-1:0]  alct_raw_wdcnt; // ALCT word count stored in FIFO

// TMB Control Ports
  input        cfg_alct_ext_trig_en;   // 1=Enable alct_ext_trig   from CCB
  input        cfg_alct_ext_inject_en; // 1=Enable alct_ext_inject from CCB
  input        cfg_alct_ext_trig;      // 1=Assert alct_ext_trig
  input        cfg_alct_ext_inject;    // 1=Assert alct_ext_inject
  input        alct_clear;             // 1=Blank received data
  input        alct_inject;            // 1=Start ALCT injector
  input        alct_inj_ram_en;        // 1=Link  ALCT injector to CFEB injector RAM
  input [4:0]  alct_inj_delay;         // Injector delay
  input [15:0] alct0_inj;              // Injected ALCT0
  input [15:0] alct1_inj;              // Injected ALCT1
  input [10:0] alct0_inj_ram;          // Injector RAM ALCT0
  input [10:0] alct1_inj_ram;          // Injector RAM ALCT1
  input [4:0]  alctb_inj_ram;          // Injector RAM ALCT bxn
  input        inj_ramout_busy;        // Injector RAM busy

// Trigger/Readout Counter Ports
  input  cnt_all_reset;    // Trigger/Readout counter reset
  input  cnt_stop_on_ovf;  // Stop all counters if any overflows
  input  cnt_alct_debug;   // Enable ALCT debug lct error counter
  output cnt_any_ovf_alct; // At least one alct counter overflowed
  input  cnt_any_ovf_seq;  // At least one sequencer counter overflowed

  output  [MXCNTVME-1:0]  event_counter0;      // Event counter 1D remap
  output  [MXCNTVME-1:0]  event_counter1;
  output  [MXCNTVME-1:0]  event_counter2;
  output  [MXCNTVME-1:0]  event_counter3;
  output  [MXCNTVME-1:0]  event_counter4;
  output  [MXCNTVME-1:0]  event_counter5;
  output  [MXCNTVME-1:0]  event_counter6;
  output  [MXCNTVME-1:0]  event_counter7;
  output  [MXCNTVME-1:0]  event_counter8;
  output  [MXCNTVME-1:0]  event_counter9;
  output  [MXCNTVME-1:0]  event_counter10;
  output  [MXCNTVME-1:0]  event_counter11;
  output  [MXCNTVME-1:0]  event_counter12;

// ALCT Structure Error Counters
  output  [7:0] alct_err_counter0;    // Error counter 1D remap
  output  [7:0] alct_err_counter1;
  output  [7:0] alct_err_counter2;
  output  [7:0] alct_err_counter3;
  output  [7:0] alct_err_counter4;
  output  [7:0] alct_err_counter5;

// Test Points
  output        alct_wr_fifo_tp;     // ALCT is writing to FIFO
  output        alct_first_frame_tp; // ALCT first frame flag
  output        alct_last_frame_tp;  // ALCT last frame flag
  output        alct_crc_err_tp;     // CRC Error test point for oscope trigger
  output [55:0] scp_alct_rx;         // ALCT received signals to scope

// Sump
  output alct_sump; // Unused signals

// Debug
`ifdef DEBUG_ALCT
  output                  sm_reset;              // Power-up reset
  output [71:0]           inj_sm_dsp;            // Injector state machine ascii states
  output                  alct_sync_mode;        // ALCT loopback mode
  output                  alct_sync_teventodd;
  output                  alct_sync_random_loop;
  output [1:0]            alct_sync_adr;
  output                  alct_sync_random;      // Enable local lfsr
  output [17:5 ]          alct_txa_1st_mux;
  output [17:5 ]          alct_txa_2nd_mux;
  output [23:19]          alct_txb_1st_mux;
  output [23:19]          alct_txb_2nd_mux;
  output [18:0]           alct_dmb_ff;
  output [28:1]           alct_1st_ff;
  output [28:1]           alct_2nd_ff;
  output [31:0]           alct_dec_in;
  output [29:0]           alct_dec_out;
  output [15:0]           enc_in;                // Data to encode
  output [5:0]            parity_out;            // ECC parity for input data
  output [1:0]            alct_ecc_err_rx;
  output                  alct_sent_bxn;
  output [MXARAMDATA-1:0] alct_wdata;
  output [MXARAMADR-1:0]  alct_adr;
  output                  alct_wr;
`endif

//-----------------------------------------------------------------------------------------------------------------
// Local
//-----------------------------------------------------------------------------------------------------------------
// ALCT signal name decodes
  wire  [15:0]  alct0;
  wire  [15:0]  alct1;

  wire      first_valid,    rx_first_valid;
  wire      first_amu,      rx_first_amu;
  wire  [1:0]  first_quality,    rx_first_quality;
  wire  [6:0]  first_key,      rx_first_key;

  wire      second_valid,    rx_second_valid;  
  wire      second_amu,      rx_second_amu;
  wire  [1:0]  second_quality,    rx_second_quality;
  wire  [6:0]  second_key,      rx_second_key;

  wire  [4:0]  bxn,        rx_bxn;
  wire      active_feb_flag,  rx_active_feb_flag;
  wire      cfg_done,      rx_cfg_done;  
  wire      alct_bx0_rx,    rx_alct_bx0_rx;
  wire      first_frame;
  wire      last_frame;

  wire  [13:0]  daq_data;
  wire      lct_special;
  wire      ddu_special;
  wire      _wr_fifo;

  wire  [1:0]  seq_status;
  wire  [1:0]  seu_status;
  wire  [3:0]  reserved_out;

// Local
  wire  [17:5 ]  alct_txa_1st;
  wire  [17:5 ]  alct_txa_2nd;
  wire  [23:19]  alct_txb_1st;
  wire  [23:19]  alct_txb_2nd;
  wire      inj_active_feb_flag;

  wire      alct_ecc_err_tx_1bit;
  wire      alct_ecc_err_tx_2bit;
  wire      alct_ecc_err_tx_nbit;

  wire      alct_ecc_err_rx_1bit;
  wire      alct_ecc_err_rx_2bit;
  wire      alct_ecc_err_rx_nbit;

// Local name changes
  wire  [7:0]  ccb_brcst;
  wire      brcst_str1;
  wire      subaddr_str;
  wire      dout_str;
  wire      bx0;
  wire      ext_inject;
  wire      ext_trig;
  wire      level1_accept;
  wire      sync_adb_pulse;
  wire  [3:0]  seq_cmd;
  wire  [3:0]  seq_cmd_mux;
  wire  [3:0]  seq_cmd_ecc;
  wire  [3:0]  reserved_in;
  wire      clock_en;

//-----------------------------------------------------------------------------------------------------------------
// State machine power-up reset + global reset
//-----------------------------------------------------------------------------------------------------------------
  wire [3:0] pdly = 1;      // Power-up reset delay
  reg powerup_ff  = 0;

  SRL16E upup (.CLK(clock),.CE(!powerupq),.D(1'b1),.A0(pdly[0]),.A1(pdly[1]),.A2(pdly[2]),.A3(pdly[3]),.Q(powerupq));

  always @(posedge clock) begin
  powerup_ff <= powerupq && !(global_reset || ttc_resync);
  end

  wire sm_reset  = !powerup_ff;  // injector state machine reset

//-----------------------------------------------------------------------------------------------------------------
//  ALCT Receiver Section:
//    Latch 80MHz inputs
//    Demultiplex 1-to-2 at 40MHz
//    Map signal names
//    Output LCT to TMB
//    Output Raw hits to Sequencer
//-----------------------------------------------------------------------------------------------------------------
//  Buffer control signals
  reg alct_clear_ff  = 0;
  reg alct_inject_ff = 0;

  always @(posedge clock) begin
  alct_clear_ff  <= alct_clear;
  alct_inject_ff <= alct_inject;
  end

// Latch 80 MHz multiplexed inputs in DDR IOB FFs, 80MHz 1st in time is aligned with 40MHz falling edge
  wire  [28:1]  alct_1st_ff;
  wire  [28:1]  alct_2nd_ff;

  x_demux_ddr_alct_muonic #(28) ux_demux_alct (
  .clock    (clock),          // In  40MHz TMB main clock
  .clock_2x  (clock_2x),          // In  80MHz commutator clock
  .clock_lac  (clock_lac),        // In  40MHz logic accessible clock  .clock_iob  (clock_alct_rxd),      // In  40MHZ iob ddr clock
  .clock_iob  (clock_alct_rxd),      // In  40MHZ iob ddr clock
  .posneg    (alct_rxd_posneg),      // In  Select inter-stage clock 0 or 180 degrees
  .clr    (alct_clear_ff),      // In  Sync clear
  .din    (alct_rx[28:1]),      // In  80MHz data from ALCT
  .dout1st  (alct_1st_ff[28:1]),    // Out  Data de-multiplexed 1st in time
  .dout2nd  (alct_2nd_ff[28:1]));    // Out  Data de-multiplexed 2nd in time

// Copy ALCT rx data for VME readout, for use with alct debug firmware in sync mode
  reg [28:1] alct_sync_rxdata_1st = 0;
  reg [28:1] alct_sync_rxdata_2nd = 0;

  always @(posedge clock) begin
  alct_sync_rxdata_1st[28:1] <= alct_1st_ff[28:1];
  alct_sync_rxdata_2nd[28:1] <= alct_2nd_ff[28:1];
  end

// Determine ALCT sync mode set by seq_cmd
  wire [1:0] alct_sync_adr;

  wire   alct_sync_mode      = (seq_cmd[2] | seq_cmd[0]);  // alct_rx[13] in both 1st and 2nd phase beco its DC level
  wire   alct_sync_teventodd   = (seq_cmd[2] & seq_cmd[0]);  // alct_rx[13] in both 1st and 2nd phase asserts teven/todd mode
  wire   alct_sync_random_loop = (seq_cmd[2] &!seq_cmd[0]);  // alct_rx[13] in just 2nd phase asserts pseudo random loopback
  assign alct_sync_adr     = {seq_cmd[3] , seq_cmd[1]};  // alct_rx[14] in both 1st and 2nd phase multiplexed
  wire   alct_sync_random     = (seq_cmd[3] & seq_cmd[1]) && alct_sync_mode;  // Engage lfsr random generator

// Determine expected ALCT sync mode response to seq_cmd
  reg  [28:1]  alct_sync_expect_1st=0;
  reg  [28:1]  alct_sync_expect_2nd=0;
  wire [28:1]  alct_rng_1st;
  wire [28:1]  alct_rng_2nd;
  wire [9:0]  alct_rx_1st_tpat;
  wire [9:0]  alct_rx_2nd_tpat;
  wire [16:5] alct_tx_1st_tpat;
  wire [16:5] alct_tx_2nd_tpat;
  
  assign alct_rx_1st_tpat[9:0] = {alct_tx_1st_tpat[16:15],alct_tx_1st_tpat[12:5]};  // Skip over pairs 13,14 wot carry seq_cmd
  assign alct_rx_2nd_tpat[9:0] = {alct_tx_2nd_tpat[16:15],alct_tx_2nd_tpat[12:5]};  // Skip over pairs 13,14 wot carry seq_cmd

  always @(posedge clock) begin
  if (alct_sync_mode     ) begin              // Only if in loopback mode
  if (alct_sync_teventodd) begin              // Teven/Tod Mode:
  alct_sync_expect_1st[28:01] <= 28'hAAAAAAA;        //   Load 1010 Teven in all banks
  alct_sync_expect_2nd[28:01] <= 28'h5555555;        //   Load 0101 Todd  in all banks
  end
  else if (alct_sync_random_loop) begin          // Random loopbback
  alct_sync_expect_1st[10:01] <=  alct_rx_1st_tpat[9:0];  //   1st 10 bits are Randoms from TMB
  alct_sync_expect_1st[20:11] <= ~alct_rx_1st_tpat[9:0];  //   2nd 10 bits are complemented Randoms from TMB
  alct_sync_expect_1st[28:21] <=  alct_rx_1st_tpat[7:0];  //   Last 8 bits are duplicated Randoms from TMB
  alct_sync_expect_2nd[10:01] <=  alct_rx_2nd_tpat[9:0];  //   1st 10 bits are Randoms from TMB
  alct_sync_expect_2nd[20:11] <= ~alct_rx_2nd_tpat[9:0];  //   2nd 10 bits are complemented Randoms from TMB
  alct_sync_expect_2nd[28:21] <=  alct_rx_2nd_tpat[7:0];  //   Last 8 bits are duplicated Randoms from TMB
  end
  else begin
  case (alct_sync_adr[1:0])                // Load 1 of 3 banks at a time
  2'h0: begin
  alct_sync_expect_1st[10:01] <= alct_rx_1st_tpat[9:0];  // Load 1st bank of 10, retains other banks 
  alct_sync_expect_2nd[10:01] <= alct_rx_2nd_tpat[9:0];
  end
  2'h1: begin
  alct_sync_expect_1st[20:11] <= alct_rx_1st_tpat[9:0];  // Load 2nd bank of 10, retains other banks 
  alct_sync_expect_2nd[20:11] <= alct_rx_2nd_tpat[9:0];
  end
  2'h2: begin
  alct_sync_expect_1st[28:21] <= alct_rx_1st_tpat[7:0];  // Load 3rd bank of  8, retains other banks 
  alct_sync_expect_2nd[28:21] <= alct_rx_2nd_tpat[7:0];
  end
  2'h3: begin
  alct_sync_expect_1st[28:01] <= alct_rng_1st[28:1];    // Load Random+ECC in all banks
  alct_sync_expect_2nd[28:01] <= alct_rng_2nd[28:1];
  end
  endcase
  end
  end
  end

// Assign random bits to alct signals for alct_sync_adr=3 mode
  wire [48:0]  alct_lfsr;

  wire     rnd_first_valid    = alct_lfsr[0];    // First LCT
  wire     rnd_first_amu    = alct_lfsr[1];
  wire [1:0]  rnd_first_quality  = alct_lfsr[3:2];
  wire [6:0]  rnd_first_key    = alct_lfsr[10:4];

  wire     rnd_second_valid  = alct_lfsr[11];  // Second LCT
  wire     rnd_second_amu    = alct_lfsr[12];
  wire [1:0]  rnd_second_quality  = alct_lfsr[14:13];
  wire [6:0]  rnd_second_key    = alct_lfsr[21:15];

  wire [4:0]  rnd_bxn        = alct_lfsr[26:22];  // Common to both LCTs

  wire     rnd_active_feb    = alct_lfsr[27];  // Non trigger path signals
  wire     rnd_alct_bx0    = alct_lfsr[28];
  wire     rnd_cfg_done    = alct_lfsr[29];

  wire     rnd_first_frame    = alct_lfsr[30];  // DMB signals are not covered by ECC
  wire     rnd_last_frame    = alct_lfsr[31];
  wire [13:0]  rnd_daq_data    = alct_lfsr[45:32];
  wire     rnd_ddu_special    = alct_lfsr[46];
  wire     rnd_lct_special    = alct_lfsr[47];
  wire     rnd_nwr_fifo    = alct_lfsr[48];

// Apply ECC to random alct signals for alct_sync_adr=3 mode
  wire [6:0]  rnd_parity_out;
  wire [31:0] rnd_enc_in;

  assign rnd_enc_in[29:0]  = alct_lfsr[29:0];
  assign rnd_enc_in[31:30] = 2'b00;  // TMB only decodes 29:0 to allow 1bx FF on alct trigger path

  ecc32_encoder uecc32_rnd (      // ECC encode
  .enc_in    (rnd_enc_in[31:0]),    // In
  .parity_out  (rnd_parity_out[6:0]));  // Out

// Pack random signals+ECC for transmission to TMB
  assign alct_rng_1st[1]  = rnd_parity_out[4];  // was reserved_out[0];
  assign alct_rng_2nd[1]  = rnd_parity_out[6];  // was reserved_out[2];

  assign alct_rng_1st[2]  = rnd_parity_out[5];  // was reserved_out[1];
  assign alct_rng_2nd[2]  = rnd_alct_bx0;

  assign alct_rng_1st[3]  = rnd_active_feb;
  assign alct_rng_2nd[3]  = rnd_cfg_done;

  assign alct_rng_1st[4]  = rnd_first_valid;
  assign alct_rng_2nd[4]  = rnd_second_valid;

  assign alct_rng_1st[5]  = rnd_first_amu;
  assign alct_rng_2nd[5]  = rnd_second_amu;

  assign alct_rng_1st[6]  = rnd_first_quality[0];
  assign alct_rng_2nd[6]  = rnd_second_quality[0];

  assign alct_rng_1st[7]  = rnd_first_quality[1];
  assign alct_rng_2nd[7]  = rnd_second_quality[1];

  assign alct_rng_1st[8]  = rnd_first_key[0];
  assign alct_rng_2nd[8]  = rnd_second_key[0];

  assign alct_rng_1st[9]  = rnd_first_key[1];
  assign alct_rng_2nd[9]  = rnd_second_key[1];

  assign alct_rng_1st[10]  = rnd_first_key[2];
  assign alct_rng_2nd[10]  = rnd_second_key[2];

  assign alct_rng_1st[11]  = rnd_first_key[3];
  assign alct_rng_2nd[11]  = rnd_second_key[3];

  assign alct_rng_1st[12]  = rnd_first_key[4];
  assign alct_rng_2nd[12]  = rnd_second_key[4];

  assign alct_rng_1st[13]  = rnd_first_key[5];
  assign alct_rng_2nd[13]  = rnd_second_key[5];

  assign alct_rng_1st[14]  = rnd_first_key[6];
  assign alct_rng_2nd[14]  = rnd_second_key[6];

  assign alct_rng_1st[15]  = rnd_bxn[0];
  assign alct_rng_2nd[15]  = rnd_bxn[3];

  assign alct_rng_1st[16]  = rnd_bxn[1];
  assign alct_rng_2nd[16]  = rnd_bxn[4];

  assign alct_rng_1st[17]  = rnd_bxn[2];
  assign alct_rng_2nd[17]  = rnd_nwr_fifo;

  assign alct_rng_1st[18]  = rnd_daq_data[0];
  assign alct_rng_2nd[18]  = rnd_daq_data[7];

  assign alct_rng_1st[19]  = rnd_daq_data[1];
  assign alct_rng_2nd[19]  = rnd_daq_data[8];

  assign alct_rng_1st[20]  = rnd_daq_data[2];
  assign alct_rng_2nd[20]  = rnd_daq_data[9];

  assign alct_rng_1st[21]  = rnd_daq_data[3];
  assign alct_rng_2nd[21]  = rnd_daq_data[10];

  assign alct_rng_1st[22]  = rnd_daq_data[4];
  assign alct_rng_2nd[22]  = rnd_daq_data[11];

  assign alct_rng_1st[23]  = rnd_daq_data[5];
  assign alct_rng_2nd[23]  = rnd_daq_data[12];

  assign alct_rng_1st[24]  = rnd_daq_data[6];
  assign alct_rng_2nd[24]  = rnd_daq_data[13];

  assign alct_rng_1st[25]  = rnd_lct_special;
  assign alct_rng_2nd[25]  = rnd_first_frame;

  assign alct_rng_1st[26]  = rnd_parity_out[0];  // was seq_status[0];
  assign alct_rng_2nd[26]  = rnd_parity_out[2];  // was seu_status[0];

  assign alct_rng_1st[27]  = rnd_parity_out[1];  // was seq_status[1];
  assign alct_rng_2nd[27]  = rnd_parity_out[3];  // was seu_status[1];

  assign alct_rng_1st[28]  = rnd_ddu_special;
  assign alct_rng_2nd[28]  = rnd_last_frame;

// Delay transmitted data for later comparison with received data, spans 8bx to 23bx
  wire [28:1] alct_sync_expect_1st_predly, alct_sync_expect_1st_dly;
  wire [28:1] alct_sync_expect_2nd_predly, alct_sync_expect_2nd_dly;

  srl16e_bbl #(28) usyncpre1st (.clock(clock),.ce(alct_sync_mode),.adr(alct_sync_rxdata_pre),.d(alct_sync_expect_1st[28:1]),.q(alct_sync_expect_1st_predly[28:1]));
  srl16e_bbl #(28) usyncpre2st (.clock(clock),.ce(alct_sync_mode),.adr(alct_sync_rxdata_pre),.d(alct_sync_expect_2nd[28:1]),.q(alct_sync_expect_2nd_predly[28:1]));

  srl16e_bbl #(28) usyncdly1st (.clock(clock),.ce(alct_sync_mode),.adr(alct_sync_rxdata_dly),.d(alct_sync_expect_1st_predly),.q(alct_sync_expect_1st_dly[28:1]));
  srl16e_bbl #(28) usyncdly2st (.clock(clock),.ce(alct_sync_mode),.adr(alct_sync_rxdata_dly),.d(alct_sync_expect_2nd_predly),.q(alct_sync_expect_2nd_dly[28:1]));

// Compare received data to transmitted data at the selected delay depth
  reg alct_sync_1st_err    = 0;
  reg alct_sync_2nd_err    = 0;
  reg alct_sync_1st_err_ff  = 0;
  reg alct_sync_2nd_err_ff  = 0;
  reg [1:0] alct_sync_ecc_err  = 0;

  always @(posedge clock) begin  // Current match state
  alct_sync_1st_err <= (alct_sync_rxdata_1st[28:1] != alct_sync_expect_1st_dly[28:1]);
  alct_sync_2nd_err <= (alct_sync_rxdata_2nd[28:1] != alct_sync_expect_2nd_dly[28:1]);
  alct_sync_ecc_err <= (alct_ecc_err[1:0]);
  end

  always @(posedge clock) begin  // Latch errors
  if (alct_sync_clr_err) begin
  alct_sync_1st_err_ff <= 0;
  alct_sync_2nd_err_ff <= 0;
  end
  else begin
  alct_sync_1st_err_ff <= alct_sync_1st_err || alct_sync_1st_err_ff;
  alct_sync_2nd_err_ff <= alct_sync_2nd_err || alct_sync_2nd_err_ff;
  end
  end
  
// Map ALCT Signal names into demultiplexed names, rx_=before ECC error correction
  assign  reserved_out[0]      = alct_1st_ff[1];
  assign  reserved_out[2]      = alct_2nd_ff[1];
  
  assign  reserved_out[1]      = alct_1st_ff[2];
  assign  reserved_out[3]      = alct_2nd_ff[2];

  assign  rx_active_feb_flag   = alct_1st_ff[3];
  assign  rx_cfg_done          = alct_2nd_ff[3];
  
  assign  rx_first_valid       = alct_1st_ff[4];
  assign  rx_second_valid      = alct_2nd_ff[4];
  
  assign  rx_first_amu         = alct_1st_ff[5];
  assign  rx_second_amu        = alct_2nd_ff[5];
  
  assign  rx_first_quality[0]  = alct_1st_ff[6];
  assign  rx_second_quality[0] = alct_2nd_ff[6];

  assign  rx_first_quality[1]  = alct_1st_ff[7];
  assign  rx_second_quality[1] = alct_2nd_ff[7];

  assign  rx_first_key[0]      = alct_1st_ff[8];
  assign  rx_second_key[0]     = alct_2nd_ff[8];
  
  assign  rx_first_key[1]      = alct_1st_ff[9];
  assign  rx_second_key[1]     = alct_2nd_ff[9];

  assign  rx_first_key[2]      = alct_1st_ff[10];
  assign  rx_second_key[2]     = alct_2nd_ff[10];

  assign  rx_first_key[3]      = alct_1st_ff[11];
  assign  rx_second_key[3]     = alct_2nd_ff[11];
  
  assign  rx_first_key[4]      = alct_1st_ff[12];
  assign  rx_second_key[4]     = alct_2nd_ff[12];
  
  assign  rx_first_key[5]      = alct_1st_ff[13];
  assign  rx_second_key[5]     = alct_2nd_ff[13];
  
  assign  rx_first_key[6]      = alct_1st_ff[14];
  assign  rx_second_key[6]     = alct_2nd_ff[14];

  assign  rx_bxn[0]            = alct_1st_ff[15];
  assign  rx_bxn[3]            = alct_2nd_ff[15];

  assign  rx_bxn[1]            = alct_1st_ff[16];
  assign  rx_bxn[4]            = alct_2nd_ff[16];

  assign  rx_bxn[2]            = alct_1st_ff[17];
  assign  _wr_fifo             = alct_2nd_ff[17] || alct_clear || sm_reset;

  assign  daq_data[ 0]         = alct_1st_ff[18];
  assign  daq_data[ 7]         = alct_2nd_ff[18];

  assign  daq_data[ 1]         = alct_1st_ff[19];
  assign  daq_data[ 8]         = alct_2nd_ff[19];

  assign  daq_data[ 2]         = alct_1st_ff[20];
  assign  daq_data[ 9]         = alct_2nd_ff[20];

  assign  daq_data[ 3]         = alct_1st_ff[21];
  assign  daq_data[10]         = alct_2nd_ff[21];

  assign  daq_data[ 4]         = alct_1st_ff[22];
  assign  daq_data[11]         = alct_2nd_ff[22];

  assign  daq_data[5]          = alct_1st_ff[23];
  assign  daq_data[12]         = alct_2nd_ff[23];

  assign  daq_data[6]          = alct_1st_ff[24];
  assign  daq_data[13]         = alct_2nd_ff[24];

  assign  lct_special          = alct_1st_ff[25];
  assign  first_frame          = alct_2nd_ff[25];

  assign  seq_status[0]        = alct_1st_ff[26];
  assign  seu_status[0]        = alct_2nd_ff[26];

  assign  seq_status[1]        = alct_1st_ff[27];
  assign  seu_status[1]        = alct_2nd_ff[27];

  assign  ddu_special          = alct_1st_ff[28];
  assign  last_frame           = alct_2nd_ff[28];

// Re-map ALCT parity to TMB internal names
  wire [6:0] alct_parity_out;

  assign alct_parity_out[0] = seq_status[0];
  assign alct_parity_out[1] = seq_status[1];
  assign alct_parity_out[2] = seu_status[0];
  assign alct_parity_out[3] = seu_status[1];
  assign alct_parity_out[4] = reserved_out[0];
  assign alct_parity_out[5] = reserved_out[1];
  assign alct_parity_out[6] = reserved_out[2];
  assign rx_alct_bx0_rx     = reserved_out[3];

// Apply Error Correcting Code bits to trigger-path data from ALCT
  wire [31:0] alct_dec_in;
  reg  [29:0] alct_dec_out = 0;
  wire [31:0] dec_out;
  reg  [1:0]  alct_ecc_err = 0;
  wire [1:0]  ecc_err;

  assign alct_dec_in[0]    = rx_first_valid;      // First LCT
  assign alct_dec_in[1]    = rx_first_amu;
  assign alct_dec_in[3:2]  = rx_first_quality[1:0];
  assign alct_dec_in[10:4] = rx_first_key[6:0];

  assign alct_dec_in[11]    = rx_second_valid;    // Second LCT
  assign alct_dec_in[12]    = rx_second_amu;
  assign alct_dec_in[14:13] = rx_second_quality[1:0];
  assign alct_dec_in[21:15] = rx_second_key[6:0];

  assign alct_dec_in[26:22]  = rx_bxn[4:0];       // Common to both LCTs

  assign alct_dec_in[27]    = rx_active_feb_flag; // Non trigger path signals
  assign alct_dec_in[28]    = rx_alct_bx0_rx;
  assign alct_dec_in[29]    = rx_cfg_done;
  assign alct_dec_in[30]    = 0;
  assign alct_dec_in[31]    = 0;

  ecc32_decoder uecc32_decoder (
    .dec_in    (alct_dec_in[31:0]),    // In  Data from sender 
    .parity_in (alct_parity_out[6:0]), // In  Parity from sender
    .ecc_en    (alct_ecc_en),          // In  Enable ECC correction
    .dec_out   (dec_out[31:0]),        // Out  Corrected data or just pass thru if >1 error
    .error     (ecc_err[1:0])
  );    // Out  Error code: 0=no errors, 1=corrected 1-bit error, 2=double-bit error, 3=other error

// FF Buffer 1bx ECC output and err code, blank bad ALCTs having code 2 or 3 uncorrected data
  wire   alct_ecc_blank  = ecc_err[1] & alct_ecc_err_blank & alct_ecc_en;

  always @(posedge clock) begin
    if (alct_ecc_blank) alct_dec_out[29:0] <= 0;
    else                alct_dec_out[29:0] <= dec_out[29:0];
  end

  always @(posedge clock) begin
    alct_ecc_err[1:0] <= ecc_err[1:0];
  end

  assign alct_ecc_err_tx_1bit = (alct_ecc_err == 1);  // err = 1:  1-bit corrected
  assign alct_ecc_err_tx_2bit = (alct_ecc_err == 2);  // err = 2:  2-bits uncorrected
  assign alct_ecc_err_tx_nbit = (alct_ecc_err == 3);  // err = 3: >2-bits uncorrected
  assign alct_ecc_tx_err      = ecc_err[1] & alct_ecc_en;  // ALCT ECC error in data ALCT transmitted to TMB

// Corrected ALCT data
  assign first_valid        = alct_dec_out[0];    // First LCT
  assign first_amu          = alct_dec_out[1];
  assign first_quality[1:0] = alct_dec_out[3:2];
  assign first_key[6:0]     = alct_dec_out[10:4];

  assign second_valid        = alct_dec_out[11];    // Second LCT
  assign second_amu          = alct_dec_out[12];
  assign second_quality[1:0] = alct_dec_out[14:13];
  assign second_key[6:0]     = alct_dec_out[21:15];

  assign bxn[4:0] = alct_dec_out[26:22];  // Common to both LCTs

  assign active_feb_flag = alct_dec_out[27];    // Non trigger path signals
  assign alct_bx0_rx     = alct_dec_out[28];
  assign cfg_done        = alct_dec_out[29];

// Map ALCT trigger word signal names
  assign  alct0[ 0] = first_valid;
  assign  alct0[ 1] = first_quality[0];
  assign  alct0[ 2] = first_quality[1];
  assign  alct0[ 3] = first_amu;
  assign  alct0[ 4] = first_key[0];
  assign  alct0[ 5] = first_key[1];
  assign  alct0[ 6] = first_key[2];
  assign  alct0[ 7] = first_key[3];
  assign  alct0[ 8] = first_key[4];
  assign  alct0[ 9] = first_key[5];
  assign  alct0[10] = first_key[6];
  assign  alct0[11] = bxn[0];
  assign  alct0[12] = bxn[1];
  assign  alct0[13] = bxn[2];
  assign  alct0[14] = bxn[3];
  assign  alct0[15] = bxn[4];

  assign  alct1[ 0] = second_valid;
  assign  alct1[ 1] = second_quality[0];
  assign  alct1[ 2] = second_quality[1];
  assign  alct1[ 3] = second_amu;
  assign  alct1[ 4] = second_key[0];
  assign  alct1[ 5] = second_key[1];
  assign  alct1[ 6] = second_key[2];
  assign  alct1[ 7] = second_key[3];
  assign  alct1[ 8] = second_key[4];
  assign  alct1[ 9] = second_key[5];
  assign  alct1[10] = second_key[6];
  assign  alct1[11] = bxn[0];
  assign  alct1[12] = bxn[1];
  assign  alct1[13] = bxn[2];
  assign  alct1[14] = bxn[3];
  assign  alct1[15] = bxn[4];

// Map ALCT signals into scope channels
  assign  scp_alct_rx[0]     = active_feb_flag;
  assign  scp_alct_rx[1]     = first_valid;
  assign  scp_alct_rx[2]     = first_amu;
  assign  scp_alct_rx[4:3]   = first_quality[1:0];
  assign  scp_alct_rx[11:5]  = first_key[6:0];
  assign  scp_alct_rx[12]    = second_valid;
  assign  scp_alct_rx[13]    = second_amu;
  assign  scp_alct_rx[15:14] = second_quality[1:0];
  assign  scp_alct_rx[22:16] = second_key[6:0];
  assign  scp_alct_rx[27:23] = bxn[4:0];
  assign  scp_alct_rx[28]    = _wr_fifo;
  assign  scp_alct_rx[29]    = first_frame;
  assign  scp_alct_rx[43:30] = daq_data[13:0];
  assign  scp_alct_rx[44]    = lct_special;
  assign  scp_alct_rx[45]    = ddu_special;
  assign  scp_alct_rx[46]    = last_frame;
  assign  scp_alct_rx[48:47] = seq_status[1:0];
  assign  scp_alct_rx[50:49] = seu_status[1:0];
  assign  scp_alct_rx[54:51] = reserved_out[3:0];
  assign  scp_alct_rx[55]    = cfg_done;

// Select injector ALCTs from VME or from CFEB injector RAM
  reg  [15:0]  alct0_inj_ff = 0;
  reg  [15:0]  alct1_inj_ff = 0;

  wire [15:0] alct0_inj_ramfull = {alctb_inj_ram[4:0],alct0_inj_ram[10:0]};
  wire [15:0] alct1_inj_ramfull = {alctb_inj_ram[4:0],alct1_inj_ram[10:0]};

  always @(posedge clock) begin
  alct0_inj_ff <= (alct_inj_ram_en) ? alct0_inj_ramfull : alct0_inj;
  alct1_inj_ff <= (alct_inj_ram_en) ? alct1_inj_ramfull : alct1_inj;
  end

  wire inj_ram_now = alct_inj_ram_en & inj_ramout_busy;

// Merge ALCT with injector, blank alct when in sync mode
  wire [MXALCT-1:0] alct0_rx;
  wire [MXALCT-1:0] alct1_rx;
  wire [MXALCT-1:0] alct0_mux;
  wire [MXALCT-1:0] alct1_mux;
  reg               pass_ff = 0;

  assign alct0_rx = (alct_sync_mode) ? 1'b0 : alct0;
  assign alct1_rx = (alct_sync_mode) ? 1'b0 : alct1;
  
  wire   active_feb_flag_rx = (alct_sync_mode) ? 0 : active_feb_flag;

  assign alct0_mux =  (pass_ff) ? alct0_rx : alct0_inj_ff;
  assign alct1_mux =  (pass_ff) ? alct1_rx : alct1_inj_ff;

  assign alct0_valid        = alct0_mux[0];
  assign alct1_valid        = alct1_mux[0];
  
  assign alct0_tmb[MXALCT-1:0]  = alct0_mux[MXALCT-1:0];
  assign alct1_tmb[MXALCT-1:0]  = alct1_mux[MXALCT-1:0];

  assign alct_active_feb   = active_feb_flag_rx | inj_active_feb_flag;

// Latch full alct bxn for vme readout
  reg [4:0] bxn_alct_vme=0;

  always @(posedge clock) begin
    if (alct0_valid)            // alct_1st_valid
      bxn_alct_vme[4:0] <= alct0_mux[15:11];  // bxn[4:0]
  end

// Check ALCT data integrity
  wire [MXASERR-1:0] alct_struct_err;
  reg                alct_lct_err=0;

  reg [10:0] alct0_sff = 0;
  reg [10:0] alct1_sff = 0;
  
  always @(posedge clock) begin
    alct0_sff <= alct0_mux[10:0];
    alct1_sff <= alct1_mux[10:0];
  end

  assign alct_struct_err[0] = !alct0_sff[0] &&  (|alct0_sff[10:1]);                  // expect all zero bits if alct0_vpf is 0
  assign alct_struct_err[1] = !alct1_sff[0] &&  (|alct1_sff[10:1]);                  // expect all zero bits if alct1_vpf is 0
  assign alct_struct_err[2] = !alct0_sff[0] &&    alct1_sff[0];                      // expect alct0_vpf=1 if alct1_vpf=1
  assign alct_struct_err[3] =  alct0_sff[0] && !(|alct0_sff[10:1]);                  // expect some non-zero bits if vpf is 1
  assign alct_struct_err[4] =  alct1_sff[0] && !(|alct1_sff[10:1]);                  // expect some non-zero bits if vpf is 1
  assign alct_struct_err[5] =  alct0_sff[0] &&   (alct0_sff[10:0]==alct1_sff[10:0]); // expect alct0!=alct1 if vpf is 1

  always @(posedge clock) begin
    alct_lct_err <= (|alct_struct_err) && cnt_alct_debug;
  end

// Latch LCTs for VME readout
  reg [15:0] alct0_vme = 0;
  reg [15:0] alct1_vme = 0;

  always @(posedge clock) begin
    if (event_clear_vme) begin
      alct0_vme <= 0;
      alct1_vme <= 0;
    end
    else if (alct0_valid) begin
      alct0_vme <= alct0_mux;
      alct1_vme <= alct1_mux;
    end
  end

// Buffer test points for clock alignment tests
  reg  alct_wr_fifo_tp    = 1;
  reg alct_first_frame_tp = 0;
  reg alct_last_frame_tp  = 0;

  always @(posedge clock) begin
    alct_wr_fifo_tp     <= _wr_fifo;
    alct_first_frame_tp <= first_frame;
    alct_last_frame_tp  <= last_frame;
  end

//-----------------------------------------------------------------------------------------------------------------
// ALCT Injector State Machine
//-----------------------------------------------------------------------------------------------------------------
// ALCT Injector State Machine Declarations
  reg [5:0] inj_sm;    // synthesis attribute safe_implementation of inj_sm is "yes";
  parameter pass      = 0;
  parameter wait_clct = 1;
  parameter active    = 2;
  parameter wait_alct = 3;
  parameter injecting = 4;
  parameter  wait_vme = 5;

// Local
  wire inj_clct_cnt_done;
  wire inj_alct_cnt_done;

  assign inj_active_feb_flag  = (inj_sm==active);

// Injector State Machine
  initial inj_sm = pass;

  always @(posedge clock) begin
    if(sm_reset) begin
      inj_sm <= pass;
    end
    else begin
      case (inj_sm)
        pass:                 // Wait for inject command
          if (alct_inject_ff) inj_sm  <= wait_clct;

        wait_clct:            // Wait for CLCT
          if (inj_clct_cnt_done) inj_sm  <= active;

        active:               // Fire alct_active_feb
          inj_sm  <= wait_alct;

        wait_alct:            // Emulate ALCT active_feb_flag -to- alct[] delay
          if (inj_alct_cnt_done) inj_sm  <= injecting;

        injecting:            // Inject ALCT[] data into stream
          inj_sm  <= wait_vme;

        wait_vme:            // Wait for VME command to go away
          if(!alct_inject_ff) inj_sm  <= pass;

        default
          inj_sm  <= pass;
      endcase
    end
  end

// Injector CLCT Delay Counter, compensates for CLCT injector and pattern finding delay
  reg [4:0] inj_clct_cnt=0;

  always @(posedge clock) begin
    if      (inj_sm!=wait_clct) inj_clct_cnt <= alct_inj_delay;      // Sync  load
    else if (inj_sm==wait_clct) inj_clct_cnt <= inj_clct_cnt - 1'b1; // Sync  count
  end

  assign inj_clct_cnt_done= inj_clct_cnt == 0;

// Injector ALCT Delay Counter, compensates for 4-clocks ALCT board active_feb -to- alct[] delay
  reg  [1:0] inj_alct_cnt=0;

  always @(posedge clock) begin
    if      (inj_sm!=wait_alct) inj_alct_cnt <= 0;                   // Sync  load
    else if (inj_sm==wait_alct) inj_alct_cnt <= inj_alct_cnt - 1'b1; // Sync  count
  end

  assign inj_alct_cnt_done= inj_alct_cnt == 0;

// Pass state FF delays output mux 1 cycle
  always @(posedge clock) begin
    pass_ff <= (inj_sm != injecting) || inj_ram_now;
  end

//-----------------------------------------------------------------------------------------------------------------
// Raw Hits RAM Section
//    Write ALCT raw hits data to RAM port A while fifo write enable is low.
//    RAM address increments by 1 for each data word.
//-----------------------------------------------------------------------------------------------------------------
// Map ALCT raw hits signal names, insert crc match result in ALCT data[11] for last frame, heh heh heh
  wire [18:0] alct_dmb_mux;
  wire [18:0] alct_dmb;
  wire        insert;
  wire        crc_match_ins;

  assign  alct_dmb_mux[10:0]  = daq_data[10:0];
  assign  alct_dmb_mux[11]    = (insert) ? crc_match_ins : daq_data[11];  // crc match calculated below
  assign  alct_dmb_mux[13:12] = daq_data[13:12];

  assign  alct_dmb_mux[14]  = lct_special;
  assign  alct_dmb_mux[15]  = ddu_special;
  assign  alct_dmb_mux[16]  = last_frame;
  assign  alct_dmb_mux[17]  = first_frame;
  assign  alct_dmb_mux[18]  = _wr_fifo;

// Blank DMB signals during alct sync mode
  assign alct_dmb[18:0] = (alct_sync_mode) ? 19'h0 : alct_dmb_mux[18:0];

// Latch DMB data for local raw hits RAM fanout
  reg  [18:0] alct_dmb_ff = (1 << 18); // Power up with wr_fifo bit=1

  always @(posedge clock) begin
    if (powerup_ff) alct_dmb_ff <= alct_dmb;
  end

// Calculate CRC on incoming ALCT DMB data stream
  wire [15:0] crc_data  = alct_dmb[15:0]; // ALCT output frame
  wire [21:0] crc;                        // CRC result
  wire        crc_reset = _wr_fifo;       // ~write enable

  crc22a ucrc22alct (
    .clock (clock),
    .data  (crc_data[15:0]),
    .reset (crc_reset),
    .crc   (crc[21:0])
  );

// Delay calculated CRC to match embedded CRC, as embedded crc frames are not included in the crc
  reg [21:0] crc_ff [1:0];  

  always @(posedge clock) begin
    crc_ff[0] <= crc;       // delay 1bx to de0d marker
    crc_ff[1] <= crc_ff[0]; // delay 2bx to skip back before de0d marker beco ddu fails to include de0d
  end

// Compare calculated CRC to embedded CRC, lsbs come at word n, msbs at n+1
  wire [21:0] crc_embedded;
  reg  [10:0] crc_lsb=0;
  wire [10:0] crc_msb;
  wire        crc_match;

  always @(posedge clock) begin
    crc_lsb[10:0] <= alct_dmb[10:0];
  end

  assign crc_msb      = alct_dmb[10:0];
  assign crc_embedded = {crc_msb[10:0],crc_lsb[10:0]};
  assign crc_match    = (crc_ff[1][21:0] == crc_embedded[21:0]) && !_wr_fifo;

// Delay crc match result to insert in last alct frame
  reg [0:0] crc_match_dly=0;  // delay 1 for new eof, crc0,crc1,wdcnt format

  always @(posedge clock) begin
    crc_match_dly[0]  <= crc_match;
  end

  assign crc_match_ins = crc_match_dly[0];
  assign insert        = last_frame;
  wire   alct_crc_err  = insert & !crc_match_ins;

// CRC Error test point for oscope trigger
  reg  alct_crc_err_tp=0;

  always @(posedge clock) begin
    alct_crc_err_tp  <= alct_crc_err;
  end

//-----------------------------------------------------------------------------------------------------------------
// Count ALCT crc + ecc errors, L1A transmissions, LCTs
//-----------------------------------------------------------------------------------------------------------------
// Counter registers
  parameter          N=12;
  reg [MXCNTVME-1:0] cnt [N:0]; // ALCT counter array, remaining counters are in sequencer.v
  reg [N:0]          cnt_en=0;  // Counter increment enables

// Counter enable strobes
  always @(posedge clock) begin
    cnt_en[0] <= alct0_valid;          // ALCT alct0 received
    cnt_en[1] <= alct1_valid;          // ALCT alct1 received
    cnt_en[2] <= alct_lct_err;         // ALCT alct structure error

    cnt_en[3] <= alct_ecc_err_tx_1bit; // ALCT  trigger data to TMB ecc    1-bit error, corrected
    cnt_en[4] <= alct_ecc_err_tx_2bit; // ALCT  trigger data to TMB ecc    2-bit error, not corrected
    cnt_en[5] <= alct_ecc_err_tx_nbit; // ALCT  trigger data to TMB ecc >  2-bit error, not corrected
    cnt_en[6] <= alct_ecc_blank;       // ALCT trigger data to TMB ecc >= 2-bit error, ALCT blanked

    cnt_en[7] <= alct_ecc_err_rx_1bit; // ALCT reply to ccb data from TMB ecc  1-bit err corrected
    cnt_en[8] <= alct_ecc_err_rx_2bit; // ALCT reply to ccb data from TMB ecc  2-bit err detected, not corrected
    cnt_en[9] <= alct_ecc_err_rx_nbit; // ALCT reply to ccb data from TMB ecc >2-bit err detected, not corrected

    cnt_en[10] <= first_frame;         // ALCT  raw hits readout
    cnt_en[11] <= alct_crc_err;        // ALCT  raw hits readout crc error
    cnt_en[12] <= alct_bx0_rx;         // ALCT sent bx0 to TMB
  end

// Counter overflow disable
  wire [MXCNTVME-1:0] cnt_fullscale = {MXCNTVME{1'b1}};
  wire [N:0]          cnt_nof;

  genvar j;
  generate
    for (j=0; j<=N; j=j+1) begin: gennof
      assign cnt_nof[j] = (cnt[j] < cnt_fullscale);  // 1=counter j not overflowed
    end
  endgenerate

  wire cnt_any_ovf_alct = !(&cnt_nof);      // 1 or more counters overflowed

  reg cnt_en_all=0;
  always @(posedge clock) begin
    cnt_en_all <= !((cnt_any_ovf_alct || cnt_any_ovf_seq) && cnt_stop_on_ovf);
  end

// Counting
  wire vme_cnt_reset = ccb_evcntres || cnt_all_reset;
  wire cnt_fatzero   = {MXCNTVME{1'b0}};

  generate
    for (j=0; j<=N; j=j+1) begin: gencnt
      always @(posedge clock) begin
        if (vme_cnt_reset) begin
          cnt[j] <= cnt_fatzero; // Clear counter j
        end
        else if (cnt_en_all) begin
          if(cnt_en[j] && cnt_nof[j]) cnt[j] <= cnt[j]+1'b1; // Increment counter j if it has not overflowed
        end
      end
    end
  endgenerate

// Map 2D counter array to 1D for IO ports
  assign event_counter0  = cnt[0];
  assign event_counter1  = cnt[1];
  assign event_counter2  = cnt[2];
  assign event_counter3  = cnt[3];
  assign event_counter4  = cnt[4];
  assign event_counter5  = cnt[5];
  assign event_counter6  = cnt[6];
  assign event_counter7  = cnt[7];
  assign event_counter8  = cnt[8];
  assign event_counter9  = cnt[9];
  assign event_counter10 = cnt[10];
  assign event_counter11 = cnt[11];
  assign event_counter12 = cnt[12];

// ALCT Structure Error Counters
  reg   [7:0]         errcnt [MXASERR-1:0];
  reg  [MXASERR-1:0] errcnt_en=0;
  wire [MXASERR-1:0] errcnt_nof;
  wire [7:0]         errcnt_fullscale=8'hFF;

  always @(posedge clock) begin
    errcnt_en <= alct_struct_err;
  end

  generate
    for (j=0; j<=MXASERR-1; j=j+1) begin: genenof
      assign errcnt_nof[j] = (errcnt[j] < errcnt_fullscale);  // 1=counter j not overflowed
    end
  endgenerate

  generate
    for (j=0; j<=MXASERR-1; j=j+1) begin: genecnt
      always @(posedge clock) begin
        if (vme_cnt_reset) begin
          errcnt[j] <= 0;
        end
        else begin
          if(errcnt_en[j] && errcnt_nof[j]) errcnt[j] <= errcnt[j]+1'b1;
        end
      end
    end
  endgenerate

// Map 2D counter array to 1D for IO ports
  assign alct_err_counter0 = errcnt[0];
  assign alct_err_counter1 = errcnt[1];
  assign alct_err_counter2 = errcnt[2];
  assign alct_err_counter3 = errcnt[3];
  assign alct_err_counter4 = errcnt[4];
  assign alct_err_counter5 = errcnt[5];

//-----------------------------------------------------------------------------------------------------------------
// ALCT raw hits storage
//-----------------------------------------------------------------------------------------------------------------
// ALCT write address counter, clears on VME, increments on alct fifo write
  reg [MXARAMADR-1:0]  wadr=0;

  wire wadr_reset = read_sm_xdmb || alct_raw_reset || sm_reset;
  wire wadr_cnten = ~alct_dmb_ff[18];

  always @(posedge clock) begin
    if      (wadr_reset) wadr <= 0;           // sync clear
    else if (wadr_cnten) wadr <= wadr + 1'b1; // sync count
  end

// Buffer DMB write address counter and data
  reg [MXARAMDATA-1:0] alct_wdata = 0;
  reg [MXARAMADR-1:0]  alct_adr   = 0;
  reg                  alct_wr    = 0;

  always @(posedge clock) begin
    alct_wdata <=  alct_dmb_ff[17:0];
    alct_wr    <= ~alct_dmb_ff[18];
    alct_adr   <=  wadr;
  end

// Latch ALCT word count for VME
  reg [MXARAMADR-1:0]  alct_raw_wdcnt=0;

  always @(posedge clock) begin
    if      (alct_raw_reset) alct_raw_wdcnt  <= 0;
    else if (alct_wr       ) alct_raw_wdcnt  <= wadr;
  end

// VME signals
  wire  [MXARAMDATA-1:0] vme_wdata;
  wire  [MXARAMDATA-1:0] vme_rdata;
  wire  [MXARAMADR-1:0]  vme_adr;

  wire   vme_wr         = 1'b0;          // VME never writes
  assign vme_wdata      = 0;             // VME write data always 0
  assign vme_adr        = alct_raw_radr; // VME read address
  assign alct_raw_rdata = vme_rdata;     // VME read data
  assign alct_raw_busy  = alct_wr;       // Raw hits RAM VME busy writing ALCT data

  assign alct_raw_done = !alct_wr && (alct_raw_wdcnt !=0) ;  // Raw hits ready for VME readout

// RAM Instantiation 18 bits x 1024 addresses
//  Port A: ALCT write, no read
//  Port B: VME read+write
  wire [1:0] dopa;           // Dummy
  wire alct_ena = alct_wr;   // Only enable port A during alct writes
  wire vme_enb  = !alct_ena; // Enable port B when A is not busy over-writing it

  initial $display("alct: generating Virtex6 RAMB18E1_S18_S18 u0");
  assign dopa=0;

  RAMB18E1 #(                              // Virtex6
    .RAM_MODE           ("TDP"),           // SDP or TDP
    .READ_WIDTH_A       (0),               // 0,1,2,4,9,18,36 Read/write width per port
    .WRITE_WIDTH_A      (18),              // 0,1,2,4,9,18
    .READ_WIDTH_B       (18),              // 0,1,2,4,9,18
    .WRITE_WIDTH_B      (18),              // 0,1,2,4,9,18,36
    .WRITE_MODE_A       ("READ_FIRST"),    // WRITE_FIRST, READ_FIRST, or NO_CHANGE
    .WRITE_MODE_B       ("READ_FIRST"),
    .SIM_COLLISION_CHECK("ALL")            // ALL, WARNING_ONLY, GENERATE_X_ONLY or NONE)
  ) u0 (
    .WEA           ({2{alct_wr}}),         //  2-bit A port write enable input
    .ENARDEN       (alct_ena),             //  1-bit A port enable/Read enable input
    .RSTRAMARSTRAM (1'b0),                 //  1-bit A port set/reset input
    .RSTREGARSTREG (1'b0),                 //  1-bit A port register set/reset input
    .REGCEAREGCE   (1'b0),                 //  1-bit A port register enable/Register enable input
    .CLKARDCLK     (clock),                //  1-bit A port clock/Read clock input
    .ADDRARDADDR   ({alct_adr[9:0],4'hF}), // 14-bit A port address/Read address input 18b->[13:4]
    .DIADI         (alct_wdata[15:0]),     // 16-bit A port data/LSB data input
    .DIPADIP       (alct_wdata[17:16]),    //  2-bit A port parity/LSB parity input
    .DOADO         (),                     // 16-bit A port data/LSB data output
    .DOPADOP       (),                     //  2-bit A port parity/LSB parity output

    .WEBWE         ({4{vme_wr}}),         //  4-bit B port write enable/Write enable input
    .ENBWREN       (vme_enb),             //  1-bit B port enable/Write enable input
    .REGCEB        (1'b0),                //  1-bit B port register enable input
    .RSTRAMB       (1'b0),                //  1-bit B port set/reset input
    .RSTREGB       (1'b0),                //  1-bit B port register set/reset input
    .CLKBWRCLK     (clock),               //  1-bit B port clock/Write clock input
    .ADDRBWRADDR   ({vme_adr[9:0],4'hF}), // 14-bit B port address/Write address input 18b->[13:4]
    .DIBDI         (vme_wdata[15:0]),     // 16-bit B port data/MSB data input
    .DIPBDIP       (vme_wdata[17:16]),    //  2-bit B port parity/MSB parity input
    .DOBDO         (vme_rdata[15:0]),     // 16-bit B port data/MSB data output
    .DOPBDOP       (vme_rdata[17:16])     //  2-bit B port parity/MSB parity output
  );

//-----------------------------------------------------------------------------------------------------------------
//  ALCT Transmitter Section:
//    Map signal names
//    Multiplex 2-to-1 at 80MHz
//-----------------------------------------------------------------------------------------------------------------
// Oneshot VME trigger commands
  x_oneshot uextinj (.d(cfg_alct_ext_inject),.clock(clock),.q(cfg_alct_ext_inject_os));
  x_oneshot uextrig (.d(cfg_alct_ext_trig  ),.clock(clock),.q(cfg_alct_ext_trig_os  ));

// Map ccb signal names to ALCT cable wire names
  assign ccb_brcst[7:0] = ccb_cmd[7:0];
  assign brcst_str1     = ccb_cmd_strobe;
  assign dout_str       = ccb_data_strobe;
  assign subaddr_str    = ccb_subaddr_strobe;
  assign bx0            = ccb_bx0;
  assign ext_inject     = (alct_ext_inject & cfg_alct_ext_inject_en) |cfg_alct_ext_inject_os;
  assign ext_trig       = (alct_ext_trig   & cfg_alct_ext_trig_en  ) |cfg_alct_ext_trig_os;

  assign level1_accept  = ccb_l1accept;
  assign sync_adb_pulse = alct_adb_pulse_sync;
  assign seq_cmd[3:0]   = alct_seq_cmd[3:0];
  assign clock_en       = alct_clock_en_vme;
  assign alct_cfg_done  = cfg_done;

//----------------------------------------------------------------------------------------------------------------
// ECC parity for outgoing signals
//----------------------------------------------------------------------------------------------------------------
// Map signals to ECC encoder input
  wire [15:0] enc_in;
  wire [5:0]  parity_out;

  assign enc_in[0]  = ccb_brcst[0];
  assign enc_in[1]  = ccb_brcst[1];
  assign enc_in[2]  = ccb_brcst[2];
  assign enc_in[3]  = ccb_brcst[3];
  assign enc_in[4]  = ccb_brcst[4];
  assign enc_in[5]  = ccb_brcst[5];
  assign enc_in[6]  = ccb_brcst[6];
  assign enc_in[7]  = ccb_brcst[7];
  assign enc_in[8]  = brcst_str1;
  assign enc_in[9]  = subaddr_str;
  assign enc_in[10] = dout_str;
  assign enc_in[11] = bx0;
  assign enc_in[12] = ext_inject;
  assign enc_in[13] = ext_trig;
  assign enc_in[14] = level1_accept;
  assign enc_in[15] = sync_adb_pulse;

// ECC error detect for signals from TMB
  ecc16_encoder uecc16_encoder (
    .enc_in     (enc_in[15:0]),      // In  Data to encode
    .parity_out (parity_out[5:0])
  ); // Out  ECC parity for input data

// Overload seq_cmd[3,1] to carry ECC parity to ALCT when not in alct_sync_mode
  assign seq_cmd_ecc[0]  = 0;
  assign seq_cmd_ecc[2]  = 0;

  assign seq_cmd_mux[3:0] = (alct_sync_mode) ? seq_cmd[3:0] : seq_cmd_ecc[3:0];

// Map ECC parity to outgoing signals
  assign reserved_in[0]  = parity_out[0];
  assign reserved_in[1]  = parity_out[1];
  assign reserved_in[2]  = parity_out[2];
  assign reserved_in[3]  = parity_out[3];
  assign seq_cmd_ecc[1]  = parity_out[4];  // seq_cmd[3,1] carry parity[5:4] when not in alct_sync_mode
  assign seq_cmd_ecc[3]  = parity_out[5];

// ECC error reply from ALCTs ECC decoder is overloaded on bxn when there are no alcts arriving
  wire [1:0] alct_ecc_err_rx;

  wire   alct_sent_bxn   = (first_valid || second_valid || active_feb_flag) && !alct_sync_mode;
  assign alct_ecc_err_rx = (alct_sent_bxn) ? 2'b00 : bxn[4:3]; // Maybe put other status in bxn_mux[1:0] someday

  assign alct_ecc_err_rx_1bit = (alct_ecc_err_rx == 1); // err = 1:  1-bit corrected
  assign alct_ecc_err_rx_2bit = (alct_ecc_err_rx == 2); // err = 2:  2-bits uncorrected
  assign alct_ecc_err_rx_nbit = (alct_ecc_err_rx == 3); // err = 3: >2-bits uncorrected
  assign alct_ecc_rx_err      =  alct_ecc_err_rx[1];    // ALCT uncorrected ECC error in data ALCT received from TMB

// Map ALCT transmit signal names to 2-to-1 mux ALCT array, note:tx[4:0],tx[18] are hard-wired on the PCB
  assign alct_txa_1st[ 5]  = ccb_brcst[0];
  assign alct_txa_2nd[ 5]  = ccb_brcst[4];

  assign alct_txa_1st[ 6]  = ccb_brcst[1];
  assign alct_txa_2nd[ 6]  = ccb_brcst[5];

  assign alct_txa_1st[ 7]  = ccb_brcst[2];
  assign alct_txa_2nd[ 7]  = ccb_brcst[6];

  assign alct_txa_1st[ 8]  = ccb_brcst[3];
  assign alct_txa_2nd[ 8]  = ccb_brcst[7];

  assign alct_txa_1st[ 9]  = brcst_str1;
  assign alct_txa_2nd[ 9]  = subaddr_str;

  assign alct_txa_1st[10]  = dout_str;
  assign alct_txa_2nd[10]  = bx0;

  assign alct_txa_1st[11]  = ext_inject;
  assign alct_txa_2nd[11]  = ext_trig;

  assign alct_txa_1st[12]  = level1_accept;
  assign alct_txa_2nd[12]  = sync_adb_pulse;

  assign alct_txa_1st[13]  = seq_cmd_mux[0];
  assign alct_txa_2nd[13]  = seq_cmd_mux[2];

  assign alct_txa_1st[14]  = seq_cmd_mux[1];  // seq_cmd[3,1] carry parity[5:4] when not in alct_sync_mode
  assign alct_txa_2nd[14]  = seq_cmd_mux[3];

  assign alct_txa_1st[15]  = reserved_in[0];
  assign alct_txa_2nd[15]  = reserved_in[2];

  assign alct_txa_1st[16]  = reserved_in[1];
  assign alct_txa_2nd[16]  = reserved_in[3];

  assign alct_txa_1st[17]  = 1'b0;        // aync_adb_pulse Not mux'd
  assign alct_txa_2nd[17]  = 1'b0;

  assign alct_txb_1st[19]  = clock_en;      // Not mux'd
  assign alct_txb_2nd[19]  = clock_en;

  assign alct_txb_1st[20]  = 1'b0;        // Not connected to ALCT board, used for loopback
  assign alct_txb_2nd[20]  = 1'b0;

  assign alct_txb_1st[21]  = 1'b0;        // Not connected to ALCT board, used for loopback  
  assign alct_txb_2nd[21]  = 1'b0;  

  assign alct_txb_1st[22]  = 1'b0;        // Not connected to ALCT board, used for loopback
  assign alct_txb_2nd[22]  = 1'b0;

  assign alct_txb_1st[23]  = 1'b0;        // Not connected to ALCT board, used for loopback
  assign alct_txb_2nd[23]  = 1'b0;  

// Delay ALCT transmit data
  wire [17:5 ] alct_txa_1st_srl, alct_txa_1st_dly;
  wire [17:5 ] alct_txa_2nd_srl, alct_txa_2nd_dly;
  wire [23:19] alct_txb_1st_srl, alct_txb_1st_dly;
  wire [23:19] alct_txb_2nd_srl, alct_txb_2nd_dly;

  reg  [3:0] alct_srl_adr            = 0;
  reg        alct_txd_int_delay_is_0 = 0;

  always @(posedge clock) begin
    alct_srl_adr            <= (alct_txd_int_delay -  1'b1);
    alct_txd_int_delay_is_0 <= (alct_txd_int_delay == 0   );  // Use direct input if SRL address is 0, 1st SRL output has 1bx overhead
  end

  srl16e_bbl #(13) udlya1st (.clock(clock),.ce(1'b1),.adr(alct_srl_adr),.d(alct_txa_1st),.q(alct_txa_1st_srl));
  srl16e_bbl #(13) udlya2nd (.clock(clock),.ce(1'b1),.adr(alct_srl_adr),.d(alct_txa_2nd),.q(alct_txa_2nd_srl));
  srl16e_bbl #( 5) udlyb1st (.clock(clock),.ce(1'b1),.adr(alct_srl_adr),.d(alct_txb_1st),.q(alct_txb_1st_srl));
  srl16e_bbl #( 5) udlyb2nd (.clock(clock),.ce(1'b1),.adr(alct_srl_adr),.d(alct_txb_2nd),.q(alct_txb_2nd_srl));

  assign alct_txa_1st_dly = (alct_txd_int_delay_is_0) ? alct_txa_1st : alct_txa_1st_srl;
  assign alct_txa_2nd_dly = (alct_txd_int_delay_is_0) ? alct_txa_2nd : alct_txa_2nd_srl;
  assign alct_txb_1st_dly = (alct_txd_int_delay_is_0) ? alct_txb_1st : alct_txb_1st_srl;
  assign alct_txb_2nd_dly = (alct_txd_int_delay_is_0) ? alct_txb_2nd : alct_txb_2nd_srl;

// Multiplex alct sync mode test pattern with normal alct data
  assign alct_tx_1st_tpat[12:05] = (alct_sync_tx_random) ? alct_lfsr[07:00] : alct_sync_txdata_1st[7:0];
  assign alct_tx_1st_tpat[14:13] = seq_cmd[1:0];
  assign alct_tx_1st_tpat[16:15] = (alct_sync_tx_random) ? alct_lfsr[09:08] : alct_sync_txdata_1st[9:8];

  assign alct_tx_2nd_tpat[12:05] = (alct_sync_tx_random) ? alct_lfsr[17:10] : alct_sync_txdata_2nd[7:0];
  assign alct_tx_2nd_tpat[14:13] = seq_cmd[3:2];
  assign alct_tx_2nd_tpat[16:15] = (alct_sync_tx_random) ? alct_lfsr[19:18] : alct_sync_txdata_2nd[9:8];

  wire alct_lfsr_en = alct_sync_random || alct_sync_random_loop || alct_sync_tx_random;

  alct_lfsr_rng #(49) ualct_lfsr_rng (  // Random sequence generator
    .clock (clock),          // 40 Mhz clock
    .ce    (alct_lfsr_en),   // Clock enable
    .reset (!alct_lfsr_en),  // Restart series
    .lfsr  (alct_lfsr[48:0]) // Random series
  );

// Multiplex ALCT transmit data
  reg  [17:05]  alct_txa_1st_mux=0;
  reg  [17:05]  alct_txa_2nd_mux=0;
  reg  [23:19]  alct_txb_1st_mux=0;
  reg  [23:19]  alct_txb_2nd_mux=0;

  always @(posedge clock) begin
    if(alct_sync_mode) begin
      alct_txa_1st_mux[16:05] <= alct_tx_1st_tpat[16:05];  // Sync mode pattern
      alct_txa_1st_mux[17]    <= alct_txa_1st[17];
      alct_txb_1st_mux[23:19] <= alct_txb_1st[23:19];
      alct_txa_2nd_mux[16:05] <= alct_tx_2nd_tpat[16:05];
      alct_txa_2nd_mux[17]    <= alct_txa_2nd[17];
      alct_txb_2nd_mux[23:19] <= alct_txb_2nd[23:19];
    end
    else begin
      alct_txa_1st_mux[17:05] <= alct_txa_1st_dly[17:05];  // Normal data
      alct_txb_1st_mux[23:19] <= alct_txb_1st_dly[23:19];
      alct_txa_2nd_mux[17:05] <= alct_txa_2nd_dly[17:05];
      alct_txb_2nd_mux[23:19] <= alct_txb_2nd_dly[23:19];
    end
  end

// Multiplex ALCT transmit data, latch in FDCE IOB FFs, 80MHz 1st in time is aligned with 40MHz rising edge
  x_mux_ddr_alct_muonic #(5+13) ux_mux_alct
  (
    .clock     (clock),                                            // In  40MHz TMB main clock
    .clock_2x  (clock_2x),                                         // In  80MHz commutator clock
    .clock_lac (clock_lac),                                        // In  40MHz logic accessible clock
    .clock_iob (clock_alct_txd),                                   // In  ALCT rx  40 MHz clock
    .clock_en  (1'b1),                                             // In  Clock enable
    .posneg    (alct_txd_posneg),                                  // In  Select inter-stage clock 0 or 180 degrees
    .clr       (1'b0),                                             // In  Sync clear
    .din1st    ({alct_txb_1st_mux[23:19],alct_txa_1st_mux[17:5]}), // In  Input data 1st-in-time
    .din2nd    ({alct_txb_2nd_mux[23:19],alct_txa_2nd_mux[17:5]}), // In  Input data 2nd-in-time
    .dout      ({alct_txb[23:19],alct_txa[17:5]})                  // Out Output data multiplexed 2-to-1
  );

// CCB Front Panel Status Signals
  assign alct_state[0] = active_feb_flag;
  assign alct_state[1] = first_valid;  
  assign alct_state[2] = second_valid;
  assign alct_state[3] = first_amu;
  assign alct_state[4] = second_amu;
  assign alct_state[5] = !_wr_fifo;  

// Sump
  assign alct_sump =
  vme_adr[10]  |     // downsized alct raw hits ram but kept full address width
  alct_adr[10] |     // downsized alct raw hits ram but kept full address width
  (|dopa)      |     // prevent dangling block ram warnings
  (|dec_out[31:30]); // future ecc bits

//-----------------------------------------------------------------------------------------------------------------
// Debug
//-----------------------------------------------------------------------------------------------------------------
`ifdef DEBUG_ALCT
// Injector state machine ASCII display
  reg[71:0] inj_sm_dsp;
  always @* begin
    case (inj_sm)
      pass:      inj_sm_dsp <= "pass     ";
      wait_clct: inj_sm_dsp <= "wait_clct";
      active:    inj_sm_dsp <= "active   ";
      wait_alct: inj_sm_dsp <= "wait_alct";
      injecting: inj_sm_dsp <= "injecting";
      wait_vme:  inj_sm_dsp <= "wait_vme ";
      default    inj_sm_dsp <= "pass     ";
    endcase
  end
`endif

//-----------------------------------------------------------------------------------------------------------------
  endmodule
//-----------------------------------------------------------------------------------------------------------------
