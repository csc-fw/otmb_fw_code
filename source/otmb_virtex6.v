`timescale 1ns / 1ps

`include "otmb_virtex6_fw_version.v"
//`include "pattern_finder/pattern_params.v"

//`define DEBUG_OTMB_VIRTEX6 1
//-------------------------------------------------------------------------------------------------------------------
//  otmb_virtex6:  Top Level
//-------------------------------------------------------------------------------------------------------------------
//  09/10/2012  Move optical receiver to cfeb.v, keep qpll clocks in this top level
//  02/13/2013  Virtex-6 initial
//  02/19/2013  Expand 7 dcfeb pattern finder
//  02/20/2013  Expand 7 digital phase shifters
//  02/25/2013  Add 2 event counters for dcfeb[6:5]
//  04/12/2013  Produce the first stable, functional version for use at Cern (but Muonic timing disabled)
//  04/05/2016  Initial addition of GEM DAQ Readout Path and accompanying VME Registers
//
//-------------------------------------------------------------------------------------------------------------------
//  A note about clocks for the production OTMB:     (JRG, 12/2014)
//    from the PCB, signal "clock05p" = io_197 --> CCLK and pin B31, while "tmb_clock0" = io_600 --> QPLL gives LHC_CLK on A10/B10.
//    in the code, tmb_clock0 is really "tmb_clock05p" from pin B31, a stoppable clock from the CCB.
//    in the code, tmb_clock0 is the main clock that drives the mmcm's & the TMB "clock" used everywhere in the TMB logic
//    in the code, clk40 is the differential "LHC_CLK" from QPLL based on "tmb_clock0" but Not Used for any logic!
//    in the code, clk_160 is the 4x differential clock from QPLL based on "tmb_clock0" used for GTX references.
//    enabling the RPC clock on the baseboard DDD chip causes ALCT communication problems, so we keep it disabled.
//    in the code, we do not use these DDD clocks:
//      tmb_clock0d    // In  40MHz clock bypasses 3D3444, NOT CONNECTED, but functionally covered by clk40 from the QPLL
//      tmb_clock1     // In  40MHz clock with 3D3444 delay, UNUSED but available on pin K24
//      alct_rxclock   // In  40MHz clock with 3D3444 delay, UNUSED but available on pin L23 as alct_rxclk aka rx-clk
//      alct_rxclockd  // In  40MHz clock with 3D3444 delay, UNUSED but available on pin V23 as alct_rxclk1p aka rxclockd
//      mpc_clock      // In  40MHz clock with 3D3444 delay, UNUSED but available on pin K12 as mpc_clk
//      dcc_clock      // In  40MHz clock with 3D3444 delay, UNUSED but available on pin H28 as dcc-clk
//
//-------------------------------------------------------------------------------------------------------------------
//  Port Declarations
//-------------------------------------------------------------------------------------------------------------------
  module otmb_virtex6
  (
// CFEB
  cfeb0_rx,
  cfeb1_rx,
  cfeb2_rx,
  cfeb3_rx,
  cfeb4_rx,
  cfeb_clock_en,
  cfeb_oe,

// ALCT
  alct_rx,
  alct_txa,
  alct_txb,
  alct_clock_en,
  alct_rxoe,
  alct_txoe,
  alct_loop,

// DMB
  dmb_rx,
  dmb_tx,
  dmb_loop,
  _dmb_oe,

// MPC
  _mpc_tx,

// RPC
  rpc_rx,
  rpc_smbrx,
  rpc_dsn,
  rpc_loop,
  rpc_tx,

// CCB
  _ccb_rx,
  _ccb_tx,
  ccb_status_oe,
  _hard_reset_alct_fpga,
  _hard_reset_tmb_fpga,
  gtl_loop,

// VME
  vme_d,
  vme_a,
  vme_am,
  _vme_cmd,
  _vme_geo,
  vme_reply,

// JTAG
  jtag_usr,
  jtag_usr0_tdo,
  sel_usr,

// PROM
  prom_led,
  prom_ctrl,

// Clock
  tmb_clock0,
  tmb_clock1,
  alct_rxclock,
  alct_rxclockd,
  mpc_clock,
  dcc_clock,
  step,

// 3D3444
  ddd_clock,
  ddd_adr_latch,
  ddd_serial_in,
  ddd_serial_out,

// Status
  mez_done,
  vstat,
  _t_crit,
  tmb_sn,
  smb_data,
  mez_sn,
  adc_io,
  adc_io3_dout,
  smb_clk,
  mez_tp10_busy,
  led_fp,

// General Purpose
  gp_io0,gp_io1,gp_io2,gp_io3,
  gp_io4,gp_io5,gp_io6,gp_io7,

// These are 8 SMT LEDs on the Mez driven by the high-order Prom data bits d[15:8]
// The LEDs are labelled  "D1-D8" on te Mez board, with colors bgyrgyrg
  led_mezD1, // IO was meztp20
  led_mezD2, // IO was meztp21
  led_mezD3, // IO was meztp22
  led_mezD4, // IO was meztp23
  led_mezD5, // IO was meztp24
  led_mezD6, // IO was meztp25
  led_mezD7, // IO was meztp26
  led_mezD8, // IO was meztp27

// Switches & LEDS
  set_sw,
  mez_tp,
  reset,

// CERN QPLL
  clk40p,
  clk40n,

  clk160p,
  clk160n,

  qpll_lock,
  qpll_err,
  qpll_nrst,

// CCLD-033 Crystal
  clk125p,
  clk125n,

// SNAP12 transmitter serial interface
  t12_sclk,
  t12_sdat,
  t12_nfault,
  t12_rst,

// SNAP12 receiver serial interface
  r12_sclk,
  r12_sdat,
  r12_fok,

// SNAP12 receivers
  rxp,
  rxn,
  //xtrarxp,
  //xtrarxn,
  gemrxp,
  gemrxn,

// Finisar
  f_sclk,
  f_sdat,
  f_fok,

// BPI Flash PROM
  bpi_cs // BPI Flash PROM Chip Enable
  );
//-------------------------------------------------------------------------------------------------------------------
//  Array Size Declarations
//-------------------------------------------------------------------------------------------------------------------

// CFEB Constants
  parameter MXCFEB   = 7;           // Number of CFEBs  on CSC
  parameter MXCFEBB  = 3;           // Number of CFEB ID bits
  parameter MXLY     = 6;           // Number Layers in CSC
  parameter MXCELL   = 3;           // Pattern cell width in 1/2-strips
  parameter MXCELLSZ = MXCELL*MXLY; // Pattern cell area in 1/2-strips

  parameter MXMUX  = 24;          // Number of multiplexed CFEB bits
  parameter MXDS   = 8;           // Number of DiStrips   per layer
  parameter MXDSX  = MXCFEB*MXDS; // Number of DiStrips   per layer on 7 CFEBs
  parameter MXHS   = 32;          // Number of 1/2-Strips per layer
  parameter MXHSX  = MXCFEB*MXHS; // Number of 1/2-Strips per layer on 7 CFEBs
  parameter MXKEY  = MXHS;        // Number of Key 1/2-strips
  parameter MXKEYB = 5;           // Number of key bits
  parameter MXTR   = MXMUX*2;     // Number of Triad bits per CFEB

// CFEB Raw hits RAM parameters
  parameter RAM_DEPTH     = 2048; // Storage bx depth
  parameter RAM_ADRB      = 11;   // Address width=log2(ram_depth)
  parameter RAM_WIDTH     = 8;    // Data width
  parameter RAM_WIDTH_GEM = 14;   // Data width

// Raw hits buffer parameters
  parameter MXBADR   =  RAM_ADRB; // Header buffer data address bits
  parameter MXBDATA  =  32;       // Pushed data width
  parameter MXSTAT   =  3;        // Buffer status bits

// Pattern Finder Constants
  parameter MXKEYX   =  MXCFEB * MXHS; // Number of key 1/2-strips on 7 CFEBs
  parameter MXKEYBX  =  8;     // Number of 1/2-strip key bits on 7 CFEBs
  parameter MXPIDB   =  4;     // Pattern ID bits
  parameter MXHITB   =  3;     // Hits on pattern bits
  parameter MXPATB   =  3+4;   // Pattern bits
  parameter MXXKYB   = 10;            // Number of EightStrip key bits on 7 CFEBs
  
    //CCLUT
  //parameter MXSUBKEYBX = 10;            // Number of EightStrip key bits on 7 CFEBs, was 8 bits with traditional pattern finding
  //parameter MXPATC   = 11;                // Pattern Carry Bits
  parameter MXPATC   = 12;                // Pattern Carry Bits
  parameter MXOFFSB = 4;                 // Quarter-strip bits
  parameter MXBNDB  = 5;                 // Bend bits, 4bits for value, 1bit for sign
  
  parameter MXPID   = 11;                // Number of patterns
  parameter MXPAT   = 5;                 // Number of patterns


// Sequencer Constants
  parameter INJ_MXTBIN    =  5;  // Injector time bin counter width
  parameter INJ_LASTTBIN  =  31; // Injector last time bin
  parameter MXBDID        =  5;  // Number TMB Board ID bits
  parameter MXCSC         =  4;  // Number CSC Chamber ID bits, CSC chamber id in one sector
  parameter MXRID         =  4;  // Number Run ID bits
  parameter MXDMB         =  49; // Number DAQMB output bits, not including hardware dmb clock
  parameter MXDRIFT       =  2;  // Number drift delay bits
  parameter MXBXN         =  12; // Number BXN bits, LHC bunchs numbered 0 to 3563
  parameter MXFLUSH       =  4;  // Number bits needed for flush counter
  parameter MXTHROTTLE    =  8;  // Number bits needed for throttle counte
  parameter MXEXTDLY      =  4;  // Number CLCT external trigger delay counter bits

  parameter MXL1DELAY  =  8; // NUmber L1Acc delay counter bits
  parameter MXL1WIND   =  4; // Number L1Acc window width bits

  parameter MXBUF    =  8; // Number of buffers
  parameter MXBUFB   =  3; // Buffer address width
  parameter MXFMODE  =  3; // Number FIFO Mode bits
  parameter MXTBIN   =  5; // Number FIFO time bin bits
  parameter MXFIFO   =  8; // FIFO Slice data width

// ALCT RAM Constants
  parameter MXARAMADR   =  11; // Number ALCT Raw Hits RAM address bits
  parameter MXARAMDATA  =  18; // Number ALCT Raw Hits RAM data bits, does not include fifo wren

// DMB RAM Constants
  parameter MXRAMADR   =  12; // Number Raw Hits RAM address bits
  parameter MXRAMDATA  =  18; // Number Raw Hits RAM data bits, does not include fifo wren

// TMB Constants
  parameter MXCLCT     =  16; // Number bits per CLCT word
  parameter MXCLCTC    =  3;  // Number bits per CLCT common data word
  parameter MXALCT     =  16; // Number bits per ALCT word
  parameter MXMPCRX    =  2;  // Number bits from MPC
  parameter MXMPCTX    =  32; // Number bits sent to MPC
  parameter MXFRAME    =  16; // Number bits per muon frame
  parameter NHBITS     =  6;  // Number bits needed for header count
  parameter MXMPCDLY   =  4;  // MPC delay time bits

  parameter MXGEM      =  4;  // Number GEM FIBERS == 2x number of GEM chambers == 4x number of GEM superchambers
  parameter MXGEMB     =  2;  // Number GEM ID bits. 0=gemAfiber0, 1=gemAfiber1, 2=gemBfiber0, 3=gemBfiber1
  parameter MXCLST     =  4;        // Number of GEM Clusters Per Fiber
  parameter CLSTBITS   =  14; // Number bits per GEM cluster
  parameter WIREBITS     = 7; //wiregroup
  parameter MXCLUSTER_CHAMBER       = 8; // Num GEM clusters  per Chamber
  parameter MXCLUSTER_SUPERCHAMBER  = 16; //Num GEM cluster  per superchamber
  parameter MXGEMHCM   = 16;  // hot channel mask bits for one vfat
  parameter MXVFAT     = 24;  // VFAT number
  parameter INVALIDGEM = 11'd192;
  

// RPC Constants
  parameter MXRPC      =  2;  // Number RPCs
  parameter MXRPCB     =  1;  // Number RPC ID bits
  parameter MXRPCPAD   =  16; // Number RPC pads per link board
  parameter MXRPCDB    =  19; // Number RPC bits per link board
  parameter MXRPCRX    =  38; // Number RPC bits per phase from RAT module

// Counters
  parameter MXCNTVME   =  30; // VME counter width
  parameter MXORBIT    =  30; // Number orbit counter bits
  parameter MXL1ARX    =  12; // Number L1As received counter bits

  parameter MXHMTB     =  4;// bits for HMT
  parameter NHITCFEBB  =  6;
  parameter NHMTHITB   = 10;

//-------------------------------------------------------------------------------------------------------------------
// I/O Port Declarations
//-------------------------------------------------------------------------------------------------------------------
// CFEB
  input  [23:0]  cfeb0_rx;
  input  [23:0]  cfeb1_rx;
  input  [23:0]  cfeb2_rx;
  input  [23:0]  cfeb3_rx;
  input  [23:0]  cfeb4_rx;
  output  [4:0]  cfeb_clock_en;
  output         cfeb_oe;

// ALCT
  input  [28:1]  alct_rx;
  output [17:5]  alct_txa;  // alct_tx[18] no pin
  output [23:19] alct_txb;
  output         alct_clock_en;
  output         alct_rxoe;
  output         alct_txoe;
  output         alct_loop;

// DMB
  input  [5:0]   dmb_rx;
  output [48:0]  dmb_tx;
  output         dmb_loop;
  output        _dmb_oe;

// MPC
  output [31:0] _mpc_tx;

// RPC
  input  [37:0]  rpc_rx;
  input          rpc_smbrx;  // was rpc_rxalt[0]
  input          rpc_dsn;  // was rpc_rxalt[1]
  output         rpc_loop;
  output [3:0]   rpc_tx;

// CCB
  input  [50:0] _ccb_rx;
  output [26:0] _ccb_tx;
  output         ccb_status_oe;
  output        _hard_reset_alct_fpga;
  output        _hard_reset_tmb_fpga;
  output         gtl_loop;
  wire   [26:0] _ccb_tx_i;

  assign _ccb_tx[26]    = (bpi_active) ? flash_ctrl[1] : _ccb_tx_i[26]; // Dual use output: BPI Flash PROM Write Enable
  assign _ccb_tx[25:15] = _ccb_tx_i[25:15];
  assign _ccb_tx[14]    = (bpi_active) ? flash_ctrl[2] : _ccb_tx_i[14]; // Dual use output: BPI Flash PROM Output Enable
  assign _ccb_tx[13:4]  = _ccb_tx_i[13:4];
  assign _ccb_tx[2:0]   = _ccb_tx_i[2:0];
  assign _ccb_tx[3]     = (bpi_active) ? flash_ctrl[0] : _ccb_tx_i[3];  // Dual use output: BPI Flash PROM Latch Enable

// VME
  inout  [15:0]  vme_d;
  input  [23:1]  vme_a;
  input  [5:0]   vme_am;
  input  [10:0] _vme_cmd;
  input  [6:0]  _vme_geo;
  output [6:0]   vme_reply;

// JTAG
  inout  [3:1]   jtag_usr;
  input          jtag_usr0_tdo;
  inout  [3:0]   sel_usr;

// PROM
  inout  [7:0]   prom_led;
  output [5:0]   prom_ctrl;

// Clock
  input          tmb_clock0;
  input          tmb_clock1;
  input          alct_rxclock;
  input          alct_rxclockd;
  input          mpc_clock;
  input          dcc_clock;
  output [4:0]   step;

// 3D3444
  output         ddd_clock;
  output         ddd_adr_latch;
  output         ddd_serial_in;
  input          ddd_serial_out;

// Status
  input         mez_done;
  input  [3:0]  vstat;
  input        _t_crit;
  inout         tmb_sn;
  inout         smb_data;
  inout         mez_sn;
  output [2:0]  adc_io;
  input         adc_io3_dout;
  output        smb_clk;
  output        mez_tp10_busy; // "Mezanine busy" output to test point 10 (hole on mezanine board)

// General Purpose I/Os
  inout      gp_io0;  // jtag_fgpa0 tdo (out) shunted to gp_io1, usually
  inout      gp_io1;  // jtag_fpga1 tdi (in)
  inout      gp_io2;  // jtag_fpga2 tms
  inout      gp_io3;  // jtag_fpga3 tck
  input      gp_io4;  // rpc_done
  output     gp_io5;  // _init  on mezzanine card, use only as an FPGA output
  output     gp_io6;  // _write on mezzanine card, use only as an FPGA output
  output     gp_io7;  // _cs    on mezzanine card, use only as an FPGA outpu  t// General Purpose I/Os

// Mezzanine Test Points (JRG: used to be 8 outputs, now inout for BPI access to XCF128 Flash PROM)

  inout        led_mezD1;  // was meztp20
  inout        led_mezD2;  // was meztp21;
  inout        led_mezD3;  // was meztp22;
  inout        led_mezD4;  // was meztp23;
  inout        led_mezD5;  // was meztp24;
  inout        led_mezD6;  // was meztp25;
  inout        led_mezD7;  // was meztp26;
  inout        led_mezD8;  // was meztp27;

  wire  [15:0] led_tmb;                                  // goes to BPI logic
  assign led_tmb[15:0] = {mez_led[7:0],led_fp_tmb[7:0]}; // goes to BPI logic
//  wire  [15:0]  led_tmb_out; // comes from BPI logic  { meztp(8),led_fp(8) }

// Deprecated
  wire tmb_clock0d = clk40;  // Replaced by LHCLK_P|N
//  wire tmb_clock0d = !alct_rxclockd;  // Replaced by LHCLK_P|N

// Switches & LEDS
  input  [8:7]  set_sw;
  output  [9:1]  mez_tp;
  input      reset;
// JRG, orig:  output  [7:0]  led_fp;
  inout  [7:0]  led_fp;
  wire  [7:0]  led_fp_tmb;
  wire  [7:0]  mez_led;

// CERN QPLL
  input      clk40p;      // 40 MHz from QPLL
  input      clk40n;      // 40 MHz from QPLL

  input      clk160p;    // 160 MHz from QPLL for GTX reference clock
  input      clk160n;    // 160 MHz from QPLL for GTX reference clock

  input      qpll_lock;    // QPLL locked
  input      qpll_err;    // QPLL error, replaces _gtl_oe
  output      qpll_nrst;    // QPLL reset, low=reset, drive high

// CCLD-033 Crystal
  input      clk125p;    // Transmitter clock, not in final design
  input      clk125n;

// SNAP12 transmitter serial interface, not in final design
  output      t12_sclk;
  input      t12_sdat;
  input      t12_nfault;
  input      t12_rst;

// SNAP12 receiver serial interface
  output     r12_sclk;    // Serial interface clock, drive high
  input      r12_sdat;    // Serial interface data
  input      r12_fok;    // Serial interface status

// SNAP12 receivers
  input  [6:0]  rxp;          // SNAP12+ fiber comparator inputs for GTX
  input  [6:0]  rxn;          // SNAP12- fiber comparator inputs for GTX
  input  [MXGEM-1:0]  gemrxp; // SNAP12+ fiber comparator inputs for GEM GTX
  input  [MXGEM-1:0]  gemrxn; // SNAP12- fiber comparator inputs for GEM GTX
//input  [0:0]  xtrarxp;      // SNAP12+ fiber comparator inputs for
//input  [0:0]  xtrarxn;      // SNAP12- fiber comparator inputs for

// Finisar
  input      f_sclk;
  input      f_sdat;
  input      f_fok;

// BPI FLASH PROM
  output       bpi_cs;
  wire   [3:0] flash_ctrl;
  assign bpi_cs = flash_ctrl[3];

  wire   [22:0] bpi_ad_out;  // BPI Flash PROM Address: coming from vme, going to sequencer then sequencer connects it to dmb_tx if bpi_active
  wire          bpi_active;  // BPI Active set to 1 when data lines are for BPI communications: coming from vme, going to sequencer and to outside trough mez_tp[3]
  wire          bpi_dev;     // BPI Device Selected: going to outside through mez_tp[4]
  wire          bpi_rst;     // BPI Reset: going to outside through mez_tp[5]
  wire          bpi_dsbl;    // BPI Disable: going to outside through mez_tp[6]
  wire          bpi_enbl;    // BPI Enable: going to outside through mez_tp[7]
  wire          bpi_we;      // BPI Write Enable: going to outside through mez_tp[8]
  wire          bpi_dtack;   // BPI Data Acknowledge: coming from vme, going to outside through mez_tp[9]
  wire          bpi_rd_stat; // BPI Read interface status register command received: going to outside through mez_tp[1]
  wire          bpi_re;      // BPI Read-back FIFO read enable: currently not connected (connect to mez_tp[2]?)

//-------------------------------------------------------------------------------------------------------------------
// Display definitions in synth log
//-------------------------------------------------------------------------------------------------------------------
// Display
  `ifdef FIRMWARE_TYPE  initial $display ("FIRMWARE_TYPE %H", `FIRMWARE_TYPE);  `endif
  `ifdef VERSION        initial $display ("VERSION       %H", `VERSION      );  `endif
  `ifdef MONTHDAY       initial $display ("MONTHDAY      %H", `MONTHDAY     );  `endif
  `ifdef YEAR           initial $display ("YEAR          %H", `YEAR         );  `endif
  `ifdef FPGAID         initial $display ("FPGAID        %H", `FPGAID       );  `endif
  `ifdef ISE_VERSION    initial $display ("ISE_VERSION   %H", `ISE_VERSION  );  `endif
  `ifdef MEZCARD        initial $display ("MEZCARD       %H", `MEZCARD      );  `endif
  `ifdef VIRTEX6        initial $display ("VIRTEX6       %H", `VIRTEX6      );  `endif

  `ifdef AUTO_VME       initial $display ("AUTO_VME      %H", `AUTO_VME     );  `endif
  `ifdef AUTO_JTAG      initial $display ("AUTO_JTAG     %H", `AUTO_JTAG    );  `endif
  `ifdef AUTO_PHASER    initial $display ("AUTO_PHASER   %H", `AUTO_PHASER  );  `endif

  `ifdef ALCT_MUONIC    initial $display ("ALCT_MUONIC   %H", `ALCT_MUONIC  );  `endif
  `ifdef CFEB_MUONIC    initial $display ("CFEB_MUONIC   %H", `CFEB_MUONIC  );  `endif

  `ifdef CSC_TYPE_C     initial $display ("CSC_TYPE_C    %H", `CSC_TYPE_C   );  `endif
  `ifdef CSC_TYPE_D     initial $display ("CSC_TYPE_D    %H", `CSC_TYPE_D   );  `endif

  `ifdef CCLUT          initial $display ("CCLUT         %H", `CCLUT        );  `endif

  `ifdef VERSION_MAJOR  initial $display ("VERSION_MAJOR  %H", `VERSION_MAJOR );  `endif
  `ifdef VERSION_MINOR  initial $display ("VERSION_MINOR  %H", `VERSION_MINOR );  `endif
  `ifdef VERSION_FORMAT initial $display ("VERSION_FORMAT %H", `VERSION_FORMAT);  `endif
//-------------------------------------------------------------------------------------------------------------------
// Clock DCM Instantiation
//-------------------------------------------------------------------------------------------------------------------
// Phaser VME control/status ports
  //  parameter MXDPS=9;  // JRG: UCLA sets to 9, I prefer 4 to save BUFGs.  2 ALCT + 7 DCFEBs
  parameter MXDPS=11;  // JRG: UCLA set to 9, I prefer 4 to save BUFGs.  2 ALCT + 1 DCFEB(me1/1b)+ 1 DCFEB(me1/1a)  + 2GEM
                       // nota bene that this is not necessarily the actual number of DPSs (which is fewer and set inside clock ctrl)

  wire [MXDPS-1:0]  dps_fire;
  wire [MXDPS-1:0]  dps_reset;
  wire [MXDPS-1:0]  dps_busy;
  wire [MXDPS-1:0]  dps_lock;

  wire [7:0]      dps0_phase;
  wire [7:0]      dps1_phase;
  wire [7:0]      dps2_phase;
  wire [7:0]      dps3_phase;
  wire [7:0]      dps4_phase;
  wire [7:0]      dps5_phase;
  wire [7:0]      dps6_phase;
  wire [7:0]      dps7_phase;
  wire [7:0]      dps8_phase;
  wire [7:0]      dps9_phase;
  wire [7:0]      dps10_phase;

  wire [2:0]      dps0_sm_vec;
  wire [2:0]      dps1_sm_vec;
  wire [2:0]      dps2_sm_vec;
  wire [2:0]      dps3_sm_vec;
  wire [2:0]      dps4_sm_vec;
  wire [2:0]      dps5_sm_vec;
  wire [2:0]      dps6_sm_vec;
  wire [2:0]      dps7_sm_vec;
  wire [2:0]      dps8_sm_vec;
  wire [2:0]      dps9_sm_vec;
  wire [2:0]      dps10_sm_vec;

  wire [MXCFEB-1:0]  clock_cfeb_rxd;
  wire [1:0]          clock_gem_rxd;

  IBUFG uibufg_19p      (.I(tmb_clock0    ),.O(tmb_clock0_ibufg));
  clock_ctrl uclock_ctrl
  (
// Clock inputs
  .tmb_clock0_ibufg (tmb_clock0_ibufg),  // In  40MHz clock bypasses 3D3444 and loads Mez PROMs, chip bottom
  .tmb_clock0d      (tmb_clock0d),       // In  40MHz clock bypasses 3D3444 and loads Mez PROMs, chip top, UNUSED
  .tmb_clock1       (tmb_clock1),        // In  40MHz clock with 3D3444 delay, UNUSED
  .alct_rxclock     (alct_rxclock),      // In  40MHz ALCT receive data clock with 3D3444 delay, chip bottom, UNUSED
  .alct_rxclockd    (alct_rxclockd),     // In  40MHz ALCT receive data clock with 3D3444 delay, chip top, UNUSED
  .mpc_clock        (mpc_clock),         // In  40MHz MPC clock, UNUSED
  .dcc_clock        (dcc_clock),         // In  40MHz Duty cycle corrected clock with 3D3444 delay, UNUSED
  .rpc_sig          (gp_io4),            // In  40MHz Unused

// Main clock outputs
  .clock      (clock),       // Out  40MHz global TMB clock
  .clock_2x   (clock_2x),    // Out  80MHz commutator clock
  .clock_4x   (clock_4x),    // Out  160MHz = 4 * TMB clock for GTX_RXUSRCLK
  .clock_lac  (clock_lac),   // Out  40MHz logic accessible clock
  .clock_vme  (clock_vme),   // Out  10MHz global VME clock
  .clock_1mhz (clock_1mhz),  // Out  1MHz BPI_ctrl Timer clock

// Phase delayed clocks
  .clock_alct_txd  (clock_alct_txd),     // Out  40MHz ALCT transmit data clock 1x
  .clock_alct_rxd  (clock_alct_rxd),     // Out  40MHz ALCT receive  data clock 1x
  .clock_cfeb0_rxd (clock_cfeb_rxd[0]),  // Out  40MHz CFEB receive  data clock 1x
  .clock_cfeb1_rxd (clock_cfeb_rxd[1]),  // Out  40MHz CFEB receive  data clock 1x
  .clock_cfeb2_rxd (clock_cfeb_rxd[2]),  // Out  40MHz CFEB receive  data clock 1x
  .clock_cfeb3_rxd (clock_cfeb_rxd[3]),  // Out  40MHz CFEB receive  data clock 1x
  .clock_cfeb4_rxd (clock_cfeb_rxd[4]),  // Out  40MHz CFEB receive  data clock 1x
  .clock_cfeb5_rxd (clock_cfeb_rxd[5]),  // Out  40MHz CFEB receive  data clock 1x
  .clock_cfeb6_rxd (clock_cfeb_rxd[6]),  // Out  40MHz CFEB receive  data clock 1x

  .clock_gemA_rxd (clock_gem_rxd[0]),  // Out 40MHz GEM receive  data clock 1x
  .clock_gemB_rxd (clock_gem_rxd[1]),  // Out 40MHz GEM receive  data clock 1x
                                       // these clocks are ganged together inside of the clock control module

// Global reset
  .mmcm_reset          (1'b0),                 // In  PLL reset input for simulation
  .global_reset_en     (global_reset_en),      // In  Enable global reset on lock_lost.  JG: used to be ON by default
  .global_reset        (global_reset),         // Out  Global reset
  .clock_lock_lost_err (clock_lock_lost_err),  // Out  40MHz main clock lost lock

// Clock DCM lock status
  .lock_tmb_clock0    (lock_tmb_clock0),     // Out  DCM lock status
  .lock_tmb_clock0d   (lock_tmb_clock0d),    // Out  DCM lock status
  .lock_alct_rxclockd (lock_alct_rxclockd),  // Out  DCM lock status
  .lock_mpc_clock     (lock_mpc_clock),      // Out  DCM lock status
  .lock_dcc_clock     (lock_dcc_clock),      // Out  DCM lock status
  .lock_rpc_rxalt1    (lock_rpc_rxalt1),     // Out  DCM lock status
  .lock_tmb_clock1    (lock_tmb_clock1),     // Out  DCM lock status
  .lock_alct_rxclock  (lock_alct_rxclock),   // Out  DCM lock status

// Phaser VME control/status ports
  .dps_fire  ({dps_fire [9], dps_fire [3:0]}), // In  Set new phase ; take only the first 5 bits of these fields.. since the others are unused
  .dps_reset ({dps_reset[9], dps_reset[3:0]}), // In  VME Reset current phase
  .dps_busy  ({dps_busy [9], dps_busy [3:0]}), // Out  Phase shifter busy
  .dps_lock  ({dps_lock [9], dps_lock [3:0]}), // Out  PLL lock status

  .dps0_phase  (dps0_phase[7:0]),   // In  Phase to set, 0-255
  .dps1_phase  (dps1_phase[7:0]),   // In  Phase to set, 0-255
  .dps2_phase  (dps2_phase[7:0]),   // In  Phase to set, 0-255
  .dps3_phase  (dps3_phase[7:0]),   // In  Phase to set, 0-255
  .dps4_phase  (dps4_phase[7:0]),   // In  Phase to set, 0-255
  .dps5_phase  (dps5_phase[7:0]),   // In  Phase to set, 0-255
  .dps6_phase  (dps6_phase[7:0]),   // In  Phase to set, 0-255
  .dps7_phase  (dps7_phase[7:0]),   // In  Phase to set, 0-255
  .dps8_phase  (dps8_phase[7:0]),   // In  Phase to set, 0-255
  .dps9_phase  (dps9_phase[7:0]),   // In  Phase to set, 0-255
  .dps10_phase (dps10_phase[7:0]),  // In  Phase to set, 0-255

  .dps0_sm_vec  (dps0_sm_vec[2:0]),  // Out  Phase shifter machine state
  .dps1_sm_vec  (dps1_sm_vec[2:0]),  // Out  Phase shifter machine state
  .dps2_sm_vec  (dps2_sm_vec[2:0]),  // Out  Phase shifter machine state
  .dps3_sm_vec  (dps3_sm_vec[2:0]),  // Out  Phase shifter machine state
  .dps4_sm_vec  (dps4_sm_vec[2:0]),  // Out  Phase shifter machine state
  .dps5_sm_vec  (dps5_sm_vec[2:0]),  // Out  Phase shifter machine state
  .dps6_sm_vec  (dps6_sm_vec[2:0]),  // Out  Phase shifter machine state
  .dps7_sm_vec  (dps7_sm_vec[2:0]),  // Out  Phase shifter machine state
  .dps8_sm_vec  (dps8_sm_vec[2:0]),  // Out  Phase shifter machine state
  .dps9_sm_vec  (dps9_sm_vec[2:0]),  // Out  Phase shifter machine state
  .dps10_sm_vec (dps10_sm_vec[2:0]), // Out  Phase shifter machine state

  .clock_ctrl_sump (clock_ctrl_sump)
  );

//-------------------------------------------------------------------------------------------------------------------
// Optical receivers
//-------------------------------------------------------------------------------------------------------------------
// Clock input buffers
  IBUFGDS #(.DIFF_TERM("TRUE"),.IOSTANDARD("LVDS_25")) uclk40  (.I(clk40p ),.IB(clk40n ),.O(clk40 ));  //  40MHz from QPLL
  IBUFGDS #(.DIFF_TERM("FALSE"),.IOSTANDARD("DEFAULT")) uclk125 (.I(clk125p),.IB(clk125n),.O(clk125));  // 125MHz from xtal
  IBUFDS_GTXE1 uclk160 (.I(clk160p),.IB(clk160n),.O(clock_160),.ODIV2(),.CEB(1'b0));            // 160MHz from QPLL for GTX


  assign t12_sclk  = 1'b1;  // Snap12 Transmitter

//------------------------------------------------------------------------------------------------------------------
//  CCB Instantiation
//-------------------------------------------------------------------------------------------------------------------
// CCB Arrays
  wire  [8:0]           clct_status;
  wire  [8:0]           alct_status;
  wire  [5:0]           alct_state;
  wire  [7:0]           ccb_cmd;
  wire  [4:0]           ccb_reserved;
  wire  [1:0]           tmb_reserved;
  wire  [4:0]           tmb_reserved_in;
  wire  [2:0]           tmb_reserved_out;
  wire  [2:0]           dmb_cfeb_calibrate;
  wire  [4:0]           dmb_reserved_out;
  wire  [2:0]           dmb_reserved_in;
  wire  [5:0]           dmb_rx_ff;
  wire  [7:0]           l1a_delay_vme;
  wire  [7:0]           vme_ccb_cmd;
  wire  [2:0]           fmm_state;
  wire  [7:0]           ccb_ttcrx_lost_cnt;
  wire  [7:0]           ccb_qpll_lost_cnt;
  wire  [MXMPCRX-1:0]  _mpc_rx;          // Received by ccb GTL chip, passed to TMB section
  wire  [MXBXN-1:0]    lhc_cycle;

  wire fmm_trig_stop;

// CCB Local
  wire  alct_vpf_tp;
  wire  clct_vpf_tp;
  wire  scint_veto;

// CCB Front panel ECL outputs: ALCT shares with TMB signals
  assign alct_status[5:0] = alct_state[5:0];  // ALCT status signals
  assign alct_status[6]   = alct_vpf_tp;      // TMB ALCT Valid pattern flag
  assign alct_status[7]   = clct_vpf_tp;      // TMB CLCT Valid pattern flag
  assign alct_status[8]   = scint_veto;       // Fast Site scintillator veto

// CCB Instantiation
  ccb uccb
  (
// CCB I/O
  .clock        (clock),            // In  40MHz clock without DDD delay
  .global_reset (global_reset),     // In  Global reset
  ._ccb_rx      (_ccb_rx[50:0]),    // In  GTLP data from CCB, inverted
  ._ccb_tx      (_ccb_tx_i[26:0]),  // Out  GTLP data to   CCB, inverted

// VME Control Ports
  .ccb_ignore_rx        (ccb_ignore_rx),         // In  Ignore CCB backplane inputs
  .ccb_allow_ext_bypass (ccb_allow_ext_bypass),  // In  1=Allow clct_ext_trigger_ccb even if ccb_ignore_rx=1
  .ccb_disable_tx       (ccb_disable_tx),        // In  Disable CCB backplane outputs
  .ccb_int_l1a_en       (ccb_int_l1a_en),        // In  1=Enable CCB internal l1a emulator
  .ccb_ignore_startstop (ccb_ignore_startstop),  // In  1=ignore ttc trig_start/stop commands
  .alct_status_en       (alct_status_en),        // In  1=Enable status GTL outputs for alct
  .clct_status_en       (clct_status_en),        // In  1=Enable status GTL outputs for clct
  .gtl_loop_lcl         (gtl_loop_lcl),          // In  1=Enable gtl loop mode
  .ccb_status_oe_lcl    (ccb_status_oe_lcl),     // In  1=Enable status GTL outputs
  .lhc_cycle            (lhc_cycle[MXBXN-1:0]),  // In  LHC period, max BXN count+1

// TMB signals transmitted to CCB
  .clct_status     (clct_status[8:0]),      // In  CLCT status for CCB front panel(VME sets status_oe)
  .alct_status     (alct_status[8:0]),      // In  ALCT status for CCB front panel
  .tmb_cfg_done    (tmb_cfg_done),          // In  FPGA loaded
  .alct_cfg_done   (alct_cfg_done),         // In  FPGA loaded
  .tmb_reserved_in (tmb_reserved_in[4:0]),  // In  Unassigned

// TTC Command Word
  .ccb_cmd            (ccb_cmd[7:0]),        // Out  CCB command word
  .ccb_cmd_strobe     (ccb_cmd_strobe),      // Out  CCB command word strobe
  .ccb_data_strobe    (ccb_data_strobe),     // Out  CCB data word strobe
  .ccb_subaddr_strobe (ccb_subaddr_strobe),  // Out  CCB subaddress strobe

// TMB signals received from CCB
  .ccb_clock40_enable   (ccb_clock40_enable),     // Out  Enable 40MHz clock
  .ccb_reserved         (ccb_reserved[4:0]),      // Out  Unassigned
  .ccb_evcntres         (ccb_evcntres),           // Out  Event counter reset
  .ccb_bcntres          (ccb_bcntres),            // Out  Bunch crossing counter reset
  .ccb_bx0              (ccb_bx0),                // Out  Bunch crossing zero
  .ccb_l1accept         (ccb_l1accept),           // Out  Level 1 Accept
  .tmb_hard_reset       (tmb_hard_reset  ),       // Out  Reload TMB  FPGA
  .alct_hard_reset      (alct_hard_reset),        // Out  Reload ALCT FPGA
  .tmb_reserved         (tmb_reserved[1:0]),      // Out  Unassigned
  .alct_adb_pulse_sync  (alct_adb_pulse_sync),    // Out  ALCT synchronous  test pulse
  .alct_adb_pulse_async (alct_adb_pulse_async),   // Out  ALCT asynchronous test pulse
  .clct_ext_trig        (clct_ext_trig),          // Out  CLCT external trigger
  .alct_ext_trig        (alct_ext_trig),          // Out  ALCT external trigger
  .dmb_ext_trig         (dmb_ext_trig),           // Out  DMB  external trigger
  .tmb_reserved_out     (tmb_reserved_out[2:0]),  // Out  Unassigned
  .ccb_sump             (ccb_sump),               // Out  Unused signals

// Monitored DMB Signals
  .dmb_cfeb_calibrate (dmb_cfeb_calibrate[2:0]),  // Out  DMB calibration
  .dmb_l1a_release    (dmb_l1a_release),          // Out  DMB test
  .dmb_reserved_out   (dmb_reserved_out[4:0]),    // Out  DMB unassigned
  .dmb_reserved_in    (dmb_reserved_in[2:0]),     // Out  DMB unassigned

// DMB Received
  .dmb_rx    (dmb_rx[5:0]),     // In  DMB Received data
  .dmb_rx_ff (dmb_rx_ff[5:0]),  // Out  DMB latched for VME

// MPC GTL Received data
  .mpc_in (_mpc_rx[1:0]),  // Out  MPC muon accept reply, 80MHz

// Level 1 Accept Ports from VME and Sequencer
  .clct_ext_trig_l1aen (clct_ext_trig_l1aen),  // In  1=Request ccb l1a on clct ext_trig
  .alct_ext_trig_l1aen (alct_ext_trig_l1aen),  // In  1=Request ccb l1a on alct ext_trig
  .seq_trig_l1aen      (seq_trig_l1aen),       // In  1=Request ccb l1a on sequencer trigger
  .seq_trigger         (seq_trigger),          // In  Sequencer requests L1A from CCB

// Trigger Ports from VME
  .alct_ext_trig_vme (alct_ext_trig_vme),   // In  1=Fire alct_ext_trig oneshot
  .clct_ext_trig_vme (clct_ext_trig_vme),   // In  1=Fire clct_ext_trig oneshot
  .ext_trig_both     (ext_trig_both),       // In  1=clct_ext_trig fires alct and alct fires clct_trig, DC level
  .l1a_vme           (l1a_vme),             // In  1=fire ccb_l1accept oneshot
  .l1a_delay_vme     (l1a_delay_vme[7:0]),  // In  Internal L1A delay
  .l1a_inj_ram       (l1a_inj_ram),         // In  L1A injector RAM pulse
  .l1a_inj_ram_en    (l1a_inj_ram_en),      // In  L1A injector RAM enable
  .inj_ramout_busy   (inj_ramout_busy),     // In  Injector RAM busy

// TTC Decoded Commands
  .ttc_bx0         (ttc_bx0),          // Out  Bunch crossing zero
  .ttc_resync      (ttc_resync),       // Out  TTC resync
  .ttc_bxreset     (ttc_bxreset),      // Out  Reset bxn
  .ttc_mpc_inject  (ttc_mpc_inject),   // Out  Start MPC injector
  .ttc_orbit_reset (ttc_orbit_reset),  // Out  Reset orbit counter
  .fmm_trig_stop   (fmm_trig_stop),    // Out  Stop clct trigger sequencer

// VME
  .vme_ccb_cmd_enable     (vme_ccb_cmd_enable),      // In  Disconnect ccb_cmd_bpl, use vme_ccb_cmd;
  .vme_ccb_cmd            (vme_ccb_cmd[7:0]),        // In  CCB command word
  .vme_ccb_cmd_strobe     (vme_ccb_cmd_strobe),      // In  CCB command word strobe
  .vme_ccb_data_strobe    (vme_ccb_data_strobe),     // In  CCB data word strobe
  .vme_ccb_subaddr_strobe (vme_ccb_subaddr_strobe),  // In  CCB subaddress strobe
  .vme_evcntres           (vme_evcntres),            // In  Event counter reset, from VME
  .vme_bcntres            (vme_bcntres),             // In  Bunch crossing counter reset, from VME
  .vme_bx0                (vme_bx0),                 // In  Bunch crossing zero, from VME
  .vme_bx0_emu_en         (vme_bx0_emu_en),          // In  BX0 emulator enable
  .fmm_state              (fmm_state[2:0]),          // Out  FMM machine state

//  CCB TTC lock status
  .cnt_all_reset        (cnt_all_reset),            // In  Trigger/Readout counter reset
  .ccb_ttcrx_lock_never (ccb_ttcrx_lock_never),     // Out  Lock never achieved
  .ccb_ttcrx_lost_ever  (ccb_ttcrx_lost_ever),      // Out  Lock was lost at least once
  .ccb_ttcrx_lost_cnt   (ccb_ttcrx_lost_cnt[7:0]),  // Out  Number of times lock has been lost
  .ccb_qpll_lock_never  (ccb_qpll_lock_never),      // Out  Lock never achieved
  .ccb_qpll_lost_ever   (ccb_qpll_lost_ever),       // Out  Lock was lost at least once
  .ccb_qpll_lost_cnt    (ccb_qpll_lost_cnt[7:0])    // Out  Number of times lock has been lost
  );

//-------------------------------------------------------------------------------------------------------------------
//  ALCT Instantiation
//-------------------------------------------------------------------------------------------------------------------
// Local
  wire  [MXALCT-1:0]  alct0_tmb;
  wire  [MXALCT-1:0]  alct1_tmb;
  wire  [15:0]        alct0_vme;
  wire  [15:0]        alct1_vme;
  wire  [18:0]        alct_dmb;
  wire  [4:0]         bxn_alct_vme;      // ALCT bxn on last alct valid pattern flag
  wire  [1:0]         alct_ecc_err;      // ALCT ecc syndrome code
  wire  [3:0]         alct_seq_cmd;
  wire  [55:0]        scp_alct_rx;
  wire  [3:0]         alct_txd_int_delay;
  wire  [4:0]         alct_inj_delay;
  wire  [15:0]        alct0_inj;
  wire  [15:0]        alct1_inj;

// VME ALCT sync mode ports
  wire  [28:1]      alct_sync_rxdata_1st;  // Demux data for demux timing-in
  wire  [28:1]      alct_sync_rxdata_2nd;  // Demux data for demux timing-in
  wire  [28:1]      alct_sync_expect_1st;  // Expected demux data for demux timing-in
  wire  [28:1]      alct_sync_expect_2nd;  // Expected demux data for demux timing-in
  wire  [1:0]       alct_sync_ecc_err;     // ALCT sync mode ecc error syndrome

  wire  [9:0]      alct_sync_txdata_1st;  // ALCT sync mode data to send for loopback
  wire  [9:0]      alct_sync_txdata_2nd;  // ALCT sync mode data to send for loopback
  wire  [3:0]      alct_sync_rxdata_dly;  // ALCT sync mode delay pointer to valid data
  wire  [3:0]      alct_sync_rxdata_pre;  // ALCT sync mode delay pointer to valid data, fixed pre-delay

  wire  [MXARAMADR-1:0]  alct_raw_radr;
  wire  [MXARAMDATA-1:0]alct_raw_rdata;
  wire  [MXARAMADR-1:0]  alct_raw_wdcnt;

// ALCT Event Counters
  wire  [MXCNTVME-1:0]  event_counter0;
  wire  [MXCNTVME-1:0]  event_counter1;
  wire  [MXCNTVME-1:0]  event_counter2;
  wire  [MXCNTVME-1:0]  event_counter3; wire  [MXCNTVME-1:0]  event_counter4; wire  [MXCNTVME-1:0]  event_counter5; wire  [MXCNTVME-1:0]  event_counter6;
  wire  [MXCNTVME-1:0]  event_counter7;
  wire  [MXCNTVME-1:0]  event_counter8;
  wire  [MXCNTVME-1:0]  event_counter9;
  wire  [MXCNTVME-1:0]  event_counter10;
  wire  [MXCNTVME-1:0]  event_counter11;
  wire  [MXCNTVME-1:0]  event_counter12;

// CLCT Event Counters
  wire  [MXCNTVME-1:0]  event_counter13;
  wire  [MXCNTVME-1:0]  event_counter14;
  wire  [MXCNTVME-1:0]  event_counter15;
  wire  [MXCNTVME-1:0]  event_counter16;
  wire  [MXCNTVME-1:0]  event_counter17;
  wire  [MXCNTVME-1:0]  event_counter18;
  wire  [MXCNTVME-1:0]  event_counter19;
  wire  [MXCNTVME-1:0]  event_counter20;
  wire  [MXCNTVME-1:0]  event_counter21;
  wire  [MXCNTVME-1:0]  event_counter22;
  wire  [MXCNTVME-1:0]  event_counter23;
  wire  [MXCNTVME-1:0]  event_counter24;
  wire  [MXCNTVME-1:0]  event_counter25;
  wire  [MXCNTVME-1:0]  event_counter26;
  wire  [MXCNTVME-1:0]  event_counter27;
  wire  [MXCNTVME-1:0]  event_counter28;
  wire  [MXCNTVME-1:0]  event_counter29;
  wire  [MXCNTVME-1:0]  event_counter30;

// TMB Event Counters
  wire  [MXCNTVME-1:0]  event_counter31;
  wire  [MXCNTVME-1:0]  event_counter32;
  wire  [MXCNTVME-1:0]  event_counter33;
  wire  [MXCNTVME-1:0]  event_counter34;
  wire  [MXCNTVME-1:0]  event_counter35;
  wire  [MXCNTVME-1:0]  event_counter36;
  wire  [MXCNTVME-1:0]  event_counter37;
  wire  [MXCNTVME-1:0]  event_counter38;
  wire  [MXCNTVME-1:0]  event_counter39;
  wire  [MXCNTVME-1:0]  event_counter40;
  wire  [MXCNTVME-1:0]  event_counter41;
  wire  [MXCNTVME-1:0]  event_counter42;
  wire  [MXCNTVME-1:0]  event_counter43;
  wire  [MXCNTVME-1:0]  event_counter44;
  wire  [MXCNTVME-1:0]  event_counter45;
  wire  [MXCNTVME-1:0]  event_counter46;
  wire  [MXCNTVME-1:0]  event_counter47;
  wire  [MXCNTVME-1:0]  event_counter48;
  wire  [MXCNTVME-1:0]  event_counter49;
  wire  [MXCNTVME-1:0]  event_counter50;
  wire  [MXCNTVME-1:0]  event_counter51;
  wire  [MXCNTVME-1:0]  event_counter52;
  wire  [MXCNTVME-1:0]  event_counter53;
  wire  [MXCNTVME-1:0]  event_counter54;

// L1A Counters
  wire  [MXCNTVME-1:0]  event_counter55;
  wire  [MXCNTVME-1:0]  event_counter56;
  wire  [MXCNTVME-1:0]  event_counter57;
  wire  [MXCNTVME-1:0]  event_counter58;
  wire  [MXCNTVME-1:0]  event_counter59;
  wire  [MXCNTVME-1:0]  event_counter60;

// STAT Counters
  wire  [MXCNTVME-1:0]  event_counter61;
  wire  [MXCNTVME-1:0]  event_counter62;
  wire  [MXCNTVME-1:0]  event_counter63;
  wire  [MXCNTVME-1:0]  event_counter64;
  wire  [MXCNTVME-1:0]  event_counter65;

// ALCT Structure Error Counters
  wire  [7:0]      alct_err_counter0; // Error counter 1D remap
  wire  [7:0]      alct_err_counter1;
  wire  [7:0]      alct_err_counter2;
  wire  [7:0]      alct_err_counter3;
  wire  [7:0]      alct_err_counter4;
  wire  [7:0]      alct_err_counter5;

// CLCT pre-trigger coincidence counters
  wire  [MXCNTVME-1:0] preClct_l1a_counter;  // CLCT pre-trigger AND L1A coincidence counter
  wire  [MXCNTVME-1:0] preClct_alct_counter; // CLCT pre-trigger AND ALCT coincidence counter

// Active CFEB(s) counters
  wire  [MXCNTVME-1:0] active_cfebs_event_counter;       // Any CFEB active flag sent to DMB
  wire  [MXCNTVME-1:0] active_cfebs_me1a_event_counter;  // ME1a CFEB active flag sent to DMB
  wire  [MXCNTVME-1:0] active_cfebs_me1b_event_counter;  // ME1b CFEB active flag sent to DMB
  wire  [MXCNTVME-1:0] active_cfeb0_event_counter;       // CFEB0 active flag sent to DMB
  wire  [MXCNTVME-1:0] active_cfeb1_event_counter;       // CFEB1 active flag sent to DMB
  wire  [MXCNTVME-1:0] active_cfeb2_event_counter;       // CFEB2 active flag sent to DMB
  wire  [MXCNTVME-1:0] active_cfeb3_event_counter;       // CFEB3 active flag sent to DMB
  wire  [MXCNTVME-1:0] active_cfeb4_event_counter;       // CFEB4 active flag sent to DMB
  wire  [MXCNTVME-1:0] active_cfeb5_event_counter;       // CFEB5 active flag sent to DMB
  wire  [MXCNTVME-1:0] active_cfeb6_event_counter;       // CFEB6 active flag sent to DMB

  wire  [MXCNTVME-1:0] bx0_match_counter; // Out ALCT-CLCT BX0 match

  wire  [MXCNTVME-1:0]  hmt_counter0;
  wire  [MXCNTVME-1:0]  hmt_counter1;
  wire  [MXCNTVME-1:0]  hmt_counter2;
  wire  [MXCNTVME-1:0]  hmt_counter3;
  wire  [MXCNTVME-1:0]  hmt_counter4;
  wire  [MXCNTVME-1:0]  hmt_counter5;
  wire  [MXCNTVME-1:0]  hmt_counter6;
  wire  [MXCNTVME-1:0]  hmt_counter7;
  wire  [MXCNTVME-1:0]  hmt_counter8;
  wire  [MXCNTVME-1:0]  hmt_counter9;
  wire  [MXCNTVME-1:0]  hmt_counter10;
  wire  [MXCNTVME-1:0]  hmt_counter11;
  wire  [MXCNTVME-1:0]  hmt_counter12;
  wire  [MXCNTVME-1:0]  hmt_counter13;
  wire  [MXCNTVME-1:0]  hmt_counter14;
  wire  [MXCNTVME-1:0]  hmt_counter15;
  wire  [MXCNTVME-1:0]  hmt_counter16;
  wire  [MXCNTVME-1:0]  hmt_counter17;
  wire  [MXCNTVME-1:0]  hmt_counter18;
  wire  [MXCNTVME-1:0]  hmt_counter19;
  wire  [MXCNTVME-1:0]  hmt_trigger_counter;
  wire  [MXCNTVME-1:0]  hmt_readout_counter;
  wire  [MXCNTVME-1:0]  hmt_aff_counter;
  wire  [MXCNTVME-1:0]  buf_stall_counter;
  wire  [MXCNTVME-1:0]  new_counter0;
  wire  [MXCNTVME-1:0]  new_counter1;

// GEM Counters
  wire  [MXCNTVME-1:0]  gem_counter0;
  wire  [MXCNTVME-1:0]  gem_counter1;
  wire  [MXCNTVME-1:0]  gem_counter2;
  wire  [MXCNTVME-1:0]  gem_counter3;
  wire  [MXCNTVME-1:0]  gem_counter4;
  wire  [MXCNTVME-1:0]  gem_counter5;
  wire  [MXCNTVME-1:0]  gem_counter6;
  wire  [MXCNTVME-1:0]  gem_counter7;
  wire  [MXCNTVME-1:0]  gem_counter8;
  wire  [MXCNTVME-1:0]  gem_counter9;
  wire  [MXCNTVME-1:0]  gem_counter10;
  wire  [MXCNTVME-1:0]  gem_counter11;
  wire  [MXCNTVME-1:0]  gem_counter12;
  wire  [MXCNTVME-1:0]  gem_counter13;
  wire  [MXCNTVME-1:0]  gem_counter14;
  wire  [MXCNTVME-1:0]  gem_counter15;
  wire  [MXCNTVME-1:0]  gem_counter16;
  wire  [MXCNTVME-1:0]  gem_counter17;
  wire  [MXCNTVME-1:0]  gem_counter18;
  wire  [MXCNTVME-1:0]  gem_counter19;
  wire  [MXCNTVME-1:0]  gem_counter20;
  wire  [MXCNTVME-1:0]  gem_counter21;
  wire  [MXCNTVME-1:0]  gem_counter22;
  wire  [MXCNTVME-1:0]  gem_counter23;
  wire  [MXCNTVME-1:0]  gem_counter24;
  wire  [MXCNTVME-1:0]  gem_counter25;
  wire  [MXCNTVME-1:0]  gem_counter26;
  wire  [MXCNTVME-1:0]  gem_counter27;
  wire  [MXCNTVME-1:0]  gem_counter28;
  wire  [MXCNTVME-1:0]  gem_counter29;
  wire  [MXCNTVME-1:0]  gem_counter30;
  wire  [MXCNTVME-1:0]  gem_counter31;
  wire  [MXCNTVME-1:0]  gem_counter32;
  wire  [MXCNTVME-1:0]  gem_counter33;
  wire  [MXCNTVME-1:0]  gem_counter34;
  wire  [MXCNTVME-1:0]  gem_counter35;
  wire  [MXCNTVME-1:0]  gem_counter36;
  wire  [MXCNTVME-1:0]  gem_counter37;
  wire  [MXCNTVME-1:0]  gem_counter38;
  wire  [MXCNTVME-1:0]  gem_counter39;
  wire  [MXCNTVME-1:0]  gem_counter40;
  wire  [MXCNTVME-1:0]  gem_counter41;
  wire  [MXCNTVME-1:0]  gem_counter42;
  wire  [MXCNTVME-1:0]  gem_counter43;
  wire  [MXCNTVME-1:0]  gem_counter44;
  wire  [MXCNTVME-1:0]  gem_counter45;
  wire  [MXCNTVME-1:0]  gem_counter46;
  wire  [MXCNTVME-1:0]  gem_counter47;
  wire  [MXCNTVME-1:0]  gem_counter48;
  wire  [MXCNTVME-1:0]  gem_counter49;
  wire  [MXCNTVME-1:0]  gem_counter50;
  wire  [MXCNTVME-1:0]  gem_counter51;
  wire  [MXCNTVME-1:0]  gem_counter52;
  wire  [MXCNTVME-1:0]  gem_counter53;
  wire  [MXCNTVME-1:0]  gem_counter54;
  wire  [MXCNTVME-1:0]  gem_counter55;
  wire  [MXCNTVME-1:0]  gem_counter56;
  wire  [MXCNTVME-1:0]  gem_counter57;
  wire  [MXCNTVME-1:0]  gem_counter58;
  wire  [MXCNTVME-1:0]  gem_counter59;
  wire  [MXCNTVME-1:0]  gem_counter60;
  wire  [MXCNTVME-1:0]  gem_counter61;
  wire  [MXCNTVME-1:0]  gem_counter62;
  wire  [MXCNTVME-1:0]  gem_counter63;
  wire  [MXCNTVME-1:0]  gem_counter64;
  wire  [MXCNTVME-1:0]  gem_counter65;
  wire  [MXCNTVME-1:0]  gem_counter66;
  wire  [MXCNTVME-1:0]  gem_counter67;
  wire  [MXCNTVME-1:0]  gem_counter68;
  wire  [MXCNTVME-1:0]  gem_counter69;
  wire  [MXCNTVME-1:0]  gem_counter70;
  wire  [MXCNTVME-1:0]  gem_counter71;
  wire  [MXCNTVME-1:0]  gem_counter72;
  wire  [MXCNTVME-1:0]  gem_counter73;
  wire  [MXCNTVME-1:0]  gem_counter74;
  wire  [MXCNTVME-1:0]  gem_counter75;
  wire  [MXCNTVME-1:0]  gem_counter76;
  wire  [MXCNTVME-1:0]  gem_counter77;
  wire  [MXCNTVME-1:0]  gem_counter78;
  wire  [MXCNTVME-1:0]  gem_counter79;
  wire  [MXCNTVME-1:0]  gem_counter80;
  wire  [MXCNTVME-1:0]  gem_counter81;
  wire  [MXCNTVME-1:0]  gem_counter82;
  wire  [MXCNTVME-1:0]  gem_counter83;
  wire  [MXCNTVME-1:0]  gem_counter84;
  wire  [MXCNTVME-1:0]  gem_counter85;
  wire  [MXCNTVME-1:0]  gem_counter86;
  wire  [MXCNTVME-1:0]  gem_counter87;
  wire  [MXCNTVME-1:0]  gem_counter88;
  wire  [MXCNTVME-1:0]  gem_counter89;
  wire  [MXCNTVME-1:0]  gem_counter90;
  wire  [MXCNTVME-1:0]  gem_counter91;
  wire  [MXCNTVME-1:0]  gem_counter92;
  wire  [MXCNTVME-1:0]  gem_counter93;
  wire  [MXCNTVME-1:0]  gem_counter94;
  wire  [MXCNTVME-1:0]  gem_counter95;
  wire  [MXCNTVME-1:0]  gem_counter96;
  wire  [MXCNTVME-1:0]  gem_counter97;
  wire  [MXCNTVME-1:0]  gem_counter98;
  wire  [MXCNTVME-1:0]  gem_counter99;
  wire  [MXCNTVME-1:0]  gem_counter100;
  wire  [MXCNTVME-1:0]  gem_counter101;
  wire  [MXCNTVME-1:0]  gem_counter102;
  wire  [MXCNTVME-1:0]  gem_counter103;
  wire  [MXCNTVME-1:0]  gem_counter104;
  wire  [MXCNTVME-1:0]  gem_counter105;
  wire  [MXCNTVME-1:0]  gem_counter106;
  wire  [MXCNTVME-1:0]  gem_counter107;
  wire  [MXCNTVME-1:0]  gem_counter108;
  wire  [MXCNTVME-1:0]  gem_counter109;
  wire  [MXCNTVME-1:0]  gem_counter110;
  wire  [MXCNTVME-1:0]  gem_counter111;
  wire  [MXCNTVME-1:0]  gem_counter112;
  wire  [MXCNTVME-1:0]  gem_counter113;
  wire  [MXCNTVME-1:0]  gem_counter114;
  wire  [MXCNTVME-1:0]  gem_counter115;
  wire  [MXCNTVME-1:0]  gem_counter116;
  wire  [MXCNTVME-1:0]  gem_counter117;
  wire  [MXCNTVME-1:0]  gem_counter118;
  wire  [MXCNTVME-1:0]  gem_counter119;
  wire  [MXCNTVME-1:0]  gem_counter120;
  wire  [MXCNTVME-1:0]  gem_counter121;
  wire  [MXCNTVME-1:0]  gem_counter122;
  wire  [MXCNTVME-1:0]  gem_counter123;
  wire  [MXCNTVME-1:0]  gem_counter124;
  wire  [MXCNTVME-1:0]  gem_counter125;
  wire  [MXCNTVME-1:0]  gem_counter126;
  wire  [MXCNTVME-1:0]  gem_counter127;

// CFEB injector RAM map 2D arrays into 1D for ALCT
  wire  [MXCFEB-1:0]  inj_ramout_pulse;
  assign inj_ramout_busy=|inj_ramout_pulse;

  wire  [5:0]  inj_ramout [MXCFEB-1:0];
  wire  [41:0] inj_ramout_mux;

  assign inj_ramout_mux[5:0]   = inj_ramout[0][5:0];
  assign inj_ramout_mux[11:6]  = inj_ramout[1][5:0];
  assign inj_ramout_mux[17:12] = inj_ramout[2][5:0];
  assign inj_ramout_mux[23:18] = inj_ramout[3][5:0];
  assign inj_ramout_mux[29:24] = inj_ramout[4][5:0];
  assign inj_ramout_mux[35:30] = inj_ramout[5][5:0];
  assign inj_ramout_mux[41:36] = inj_ramout[6][5:0];

// ALCT Injectors
  wire   [10:0] alct0_inj_ram = inj_ramout_mux[10:0];  // Injector RAM ALCT0
  wire   [10:0] alct1_inj_ram = inj_ramout_mux[21:11]; // Injector RAM ALCT1
  wire   [4:0]  alctb_inj_ram = inj_ramout_mux[26:22]; // Injector RAM ALCT bxn
  assign        l1a_inj_ram   = inj_ramout_mux[27];    // Injector RAM L1A
  wire          inj_ram_sump  =|inj_ramout_mux[41:28]; // Injector RAM unused

  wire alct_ext_inject = alct_ext_trig; // CCB failed to implement this signal

  alct ualct
  (
// Clock Port
  .clock     (clock),      // In  40MHz TMB system clock
  .clock_2x  (clock_2x),   // In  80MHz commutator clock
  .clock_lac (clock_lac),  // In  40MHz logic accessible clock

// Phase delayed clocks
  .clock_alct_rxd  (clock_alct_rxd),   // In  ALCT rxd  40 MHz clock
  .clock_alct_txd  (clock_alct_txd),   // In  ALCT txd  40 MHz clock
  .alct_rxd_posneg (alct_rxd_posneg),  // In  Select inter-stage clock 0 or 180 degrees
  .alct_txd_posneg (alct_txd_posneg),  // In  Select inter-stage clock 0 or 180 degrees

// Global resets
  .global_reset (global_reset),  // In  Global reset
  .ttc_resync   (ttc_resync),    // In  TTC resync

// ALCT Ports
  .alct_rx  (alct_rx[28:1]),    // In  80MHz LVDS inputs  from ALCT, alct_rx[0] is JTAG TDO, non-mux'd
  .alct_txa (alct_txa[17:5]),   // Out  80MHz LVDS outputs
  .alct_txb (alct_txb[23:19]),  // Out  80MHz LVDS outputs

// TTC Command Word
  .ccb_cmd            (ccb_cmd[7:0]),        // In  TTC command word
  .ccb_cmd_strobe     (ccb_cmd_strobe),      // In  TTC command valid
  .ccb_data_strobe    (ccb_data_strobe),     // In  TTC data valid
  .ccb_subaddr_strobe (ccb_subaddr_strobe),  // In  TTC sub-addr valid

// CCB Ports
  .ccb_bx0             (ccb_bx0),              // In  TTC bx0
  .alct_ext_inject     (alct_ext_inject),      // In  External inject
  .alct_ext_trig       (alct_ext_trig),        // In  External trigger
  .ccb_l1accept        (ccb_l1accept),         // In  L1A
  .ccb_evcntres        (ccb_evcntres),         // In  Event counter reset
  .alct_adb_pulse_sync (alct_adb_pulse_sync),  // In  Synchronous test pulse (asyn pulse is on PCB)
  .alct_cfg_done       (alct_cfg_done),        // Out  ALCT reports FPGA configuration done
  .alct_state          (alct_state[5:0]),      // Out  ALCT state for CCB front panel ECL outputs

// Sequencer Ports
  .alct_active_feb (alct_active_feb),  // Out  ALCT has an active FEB
  .alct0_valid     (alct0_valid),      // Out  ALCT has valid LCT
  .alct1_valid     (alct1_valid),      // Out  ALCT has valid LCT
  .alct_dmb        (alct_dmb[18:0]),   // Out  ALCT to DMB
  .read_sm_xdmb    (read_sm_xdmb),     // In  TMB sequencer starting a readout

// TMB Ports
  .alct0_tmb       (alct0_tmb[MXALCT-1:0]),  // Out  ALCT best muon
  .alct1_tmb       (alct1_tmb[MXALCT-1:0]),  // Out  ALCT second best muon
  .alct_bx0_rx     (alct_bx0_rx),            // Out  ALCT bx0 received
  .alct_ecc_err    (alct_ecc_err[1:0]),      // Out  ALCT ecc syndrome code
  .alct_ecc_rx_err (alct_ecc_rx_err),        // Out  ALCT uncorrected ECC error in data ALCT received from TMB
  .alct_ecc_tx_err (alct_ecc_tx_err),        // Out  ALCT uncorrected ECC error in data ALCT transmitted to TMB

// VME Ports
  .alct_ecc_en        (alct_ecc_en),              // In  Enable ALCT ECC decoder, else do no ECC correction
  .alct_ecc_err_blank (alct_ecc_err_blank),       // In  Blank alcts with uncorrected ecc errors
  .alct_txd_int_delay (alct_txd_int_delay[3:0]),  // In  ALCT data transmit delay, integer bx
  .alct_clock_en_vme  (alct_clock_en_vme),        // In  Enable ALCT 40MHz clock
  .alct_seq_cmd       (alct_seq_cmd[3:0]),        // In  ALCT Sequencer command
  .event_clear_vme    (event_clear_vme),          // In  Event clear for aff,alct,clct,mpc vme diagnostic registers
  .alct0_vme          (alct0_vme[15:0]),          // Out  LCT latched last valid pattern
  .alct1_vme          (alct1_vme[15:0]),          // Out  LCT latched last valid pattern
  .bxn_alct_vme       (bxn_alct_vme),             // Out  ALCT bxn on last alct valid pattern flag

// VME ALCT sync mode ports
  .alct_sync_txdata_1st (alct_sync_txdata_1st[9:0]),  // In  ALCT sync mode data to send for loopback
  .alct_sync_txdata_2nd (alct_sync_txdata_2nd[9:0]),  // In  ALCT sync mode data to send for loopback
  .alct_sync_rxdata_dly (alct_sync_rxdata_dly[3:0]),  // In  ALCT sync mode delay pointer to valid data
  .alct_sync_rxdata_pre (alct_sync_rxdata_pre[3:0]),  // In  ALCT sync mode delay pointer to valid data, fixed pre-delay
  .alct_sync_tx_random  (alct_sync_tx_random),        // In  ALCT sync mode tmb transmits random data to alct
  .alct_sync_clr_err    (alct_sync_clr_err),          // In  ALCT sync mode clear rng error FFs

  .alct_sync_1st_err    (alct_sync_1st_err),       // Out  ALCT sync mode 1st-intime match ok, alct-to-tmb
  .alct_sync_2nd_err    (alct_sync_2nd_err),       // Out  ALCT sync mode 2nd-intime match ok, alct-to-tmb
  .alct_sync_1st_err_ff (alct_sync_1st_err_ff),    // Out  ALCT sync mode 1st-intime match ok, alct-to-tmb, latched
  .alct_sync_2nd_err_ff (alct_sync_2nd_err_ff),    // Out  ALCT sync mode 2nd-intime match ok, alct-to-tmb, latched
  .alct_sync_ecc_err    (alct_sync_ecc_err[1:0]),  // Out  ALCT sync mode ecc error syndrome

  .alct_sync_rxdata_1st (alct_sync_rxdata_1st[28:1]),  // Out  Demux data for demux timing-in
  .alct_sync_rxdata_2nd (alct_sync_rxdata_2nd[28:1]),  // Out  Demux data for demux timing-in
  .alct_sync_expect_1st (alct_sync_expect_1st[28:1]),  // Out  Expected demux data for demux timing-in
  .alct_sync_expect_2nd (alct_sync_expect_2nd[28:1]),  // Out  Expected demux data for demux timing-in

// VME ALCT Raw hits RAM Ports
  .alct_raw_reset (alct_raw_reset),                  // In  Reset raw hits write address and done flag
  .alct_raw_radr  (alct_raw_radr[MXARAMADR-1:0]),    // In  Raw hits RAM VME read address
  .alct_raw_rdata (alct_raw_rdata[MXARAMDATA-1:0]),  // Out  Raw hits RAM VME read data
  .alct_raw_busy  (alct_raw_busy),                   // Out  Raw hits RAM VME busy writing ALCT data
  .alct_raw_done  (alct_raw_done),                   // Out  Raw hits ready for VME readout
  .alct_raw_wdcnt (alct_raw_wdcnt[MXARAMADR-1:0]),   // Out  ALCT word count stored in FIFO

// TMB Control Ports
  .cfg_alct_ext_trig_en   (cfg_alct_ext_trig_en),    // In  1=Enable alct_ext_trig   from CCB
  .cfg_alct_ext_inject_en (cfg_alct_ext_inject_en),  // In  1=Enable alct_ext_inject from CCB
  .cfg_alct_ext_trig      (cfg_alct_ext_trig),       // In  1=Assert alct_ext_trig
  .cfg_alct_ext_inject    (cfg_alct_ext_inject),     // In  1=Assert alct_ext_inject
  .alct_clear             (alct_clear),              // In  1=Blank alct_rx inputs
  .alct_inject            (alct_inject),             // In  1=Start ALCT injector
  .alct_inj_ram_en        (alct_inj_ram_en),         // In  1=Link  ALCT injector to CFEB injector RAM
  .alct_inj_delay         (alct_inj_delay[4:0]),     // In  ALCT Injector delay
  .alct0_inj              (alct0_inj[15:0]),         // In  ALCT0 to inject
  .alct1_inj              (alct1_inj[15:0]),         // In  ALCT1 to inject
  .alct0_inj_ram          (alct0_inj_ram[10:0]),     // In  Injector RAM ALCT0
  .alct1_inj_ram          (alct1_inj_ram[10:0]),     // In  Injector RAM ALCT1
  .alctb_inj_ram          (alctb_inj_ram[4:0]),      // In  Injector RAM ALCT bxn
  .inj_ramout_busy        (inj_ramout_busy),         // In  Injector RAM busy

// Trigger/Readout Counter Ports
  .cnt_all_reset    (cnt_all_reset),     // In  Trigger/Readout counter reset
  .cnt_stop_on_ovf  (cnt_stop_on_ovf),   // In  Stop all counters if any overflows
  .cnt_alct_debug   (cnt_alct_debug),    // In  Enable ALCT debug lct error counter
  .cnt_any_ovf_alct (cnt_any_ovf_alct),  // Out  At least one alct counter overflowed
  .cnt_any_ovf_seq  (cnt_any_ovf_seq),   // In  At least one sequencer counter overflowed

  .event_counter0  (event_counter0[MXCNTVME-1:0]),  // Out  Event counters
  .event_counter1  (event_counter1[MXCNTVME-1:0]),  // Out
  .event_counter2  (event_counter2[MXCNTVME-1:0]),  // Out
  .event_counter3  (event_counter3[MXCNTVME-1:0]),  // Out
  .event_counter4  (event_counter4[MXCNTVME-1:0]),  // Out
  .event_counter5  (event_counter5[MXCNTVME-1:0]),  // Out
  .event_counter6  (event_counter6[MXCNTVME-1:0]),  // Out
  .event_counter7  (event_counter7[MXCNTVME-1:0]),  // Out
  .event_counter8  (event_counter8[MXCNTVME-1:0]),  // Out
  .event_counter9  (event_counter9[MXCNTVME-1:0]),  // Out
  .event_counter10 (event_counter10[MXCNTVME-1:0]) ,// Out
  .event_counter11 (event_counter11[MXCNTVME-1:0]) ,// Out
  .event_counter12 (event_counter12[MXCNTVME-1:0]) ,// Out

// ALCT Structure Error Counters
  .alct_err_counter0 (alct_err_counter0[7:0]),  // Out  Error counter 1D remap
  .alct_err_counter1 (alct_err_counter1[7:0]),  // Out
  .alct_err_counter2 (alct_err_counter2[7:0]),  // Out
  .alct_err_counter3 (alct_err_counter3[7:0]),  // Out
  .alct_err_counter4 (alct_err_counter4[7:0]),  // Out
  .alct_err_counter5 (alct_err_counter5[7:0]),  // Out

// Test Points
  .alct_wr_fifo_tp     (alct_wr_fifo_tp),      // Out  ALCT is writing to FIFO
  .alct_first_frame_tp (alct_first_frame_tp),  // Out  ALCT first frame flag
  .alct_last_frame_tp  (alct_last_frame_tp),   // Out  ALCT last frame flag
  .alct_crc_err_tp     (alct_crc_err_tp),      // Out  AKCT CRC Error test point for oscope trigger
  .scp_alct_rx         (scp_alct_rx[55:0]),    // Out  ALCT received signals to scope

// Sump
  .alct_sump (alct_sump)  // Out  Unused signals
  );

//-------------------------------------------------------------------------------------------------------------------
//  Common to all CFEBs
//-------------------------------------------------------------------------------------------------------------------
// CFEBs Instantiated
  wire [MXCFEB-1:0]  cfeb_exists;

// CFEB digital phase shifters
  wire [3:0]      cfeb_rxd_int_delay [MXCFEB-1:0];      // Interstage delay
  wire [MXCFEB-1:0] cfeb_rxd_posneg;
  wire        cfeb0_rxd_posneg;
  wire        cfeb1_rxd_posneg;
  wire        cfeb2_rxd_posneg;
  wire        cfeb3_rxd_posneg;
  wire        cfeb4_rxd_posneg;
  wire        cfeb5_rxd_posneg;
  wire        cfeb6_rxd_posneg;

  assign cfeb_rxd_posneg[0] = cfeb6_rxd_posneg;  // JGhere: use B-side value "cfeb6"
  assign cfeb_rxd_posneg[1] = cfeb6_rxd_posneg;  // another B-side
  assign cfeb_rxd_posneg[2] = cfeb6_rxd_posneg;  // another B-side
  assign cfeb_rxd_posneg[3] = cfeb6_rxd_posneg;  // another B-side
  assign cfeb_rxd_posneg[4] = cfeb5_rxd_posneg;  // JGhere: use A-side value "cfeb5"
  assign cfeb_rxd_posneg[5] = cfeb5_rxd_posneg;  // another A-side
  assign cfeb_rxd_posneg[6] = cfeb5_rxd_posneg;  // another A-side

// Injector Ports
  wire [MXCFEB-1:0]  mask_all;
  wire [MXCFEB-1:0]  inj_febsel;
  wire [MXCFEB-1:0]  injector_go_cfeb;
  wire [11:0]        inj_last_tbin;
  wire [2:0]         inj_wen;
  wire [9:0]         inj_rwadr;
  wire [17:0]        inj_wdata;
  wire [2:0]         inj_ren;

// Raw Hits FIFO RAM Ports
  wire          fifo_wen;
  wire  [RAM_ADRB-1:0]  fifo_wadr;               // FIFO RAM write address
  wire  [RAM_ADRB-1:0]  fifo_radr_cfeb;          // FIFO RAM read tbin address
  wire  [2:0]           fifo_sel_cfeb;           // FIFO RAM read layer address 0-5
  wire  [RAM_WIDTH-1:0] fifo_rdata [MXCFEB-1:0]; // FIFO RAM read data

// Hot Channel Masks
  wire [MXDS-1:0]    cfeb_ly0_hcm [MXCFEB-1:0];    // 1=enable DiStrip
  wire [MXDS-1:0]    cfeb_ly1_hcm [MXCFEB-1:0];    // 1=enable DiStrip
  wire [MXDS-1:0]    cfeb_ly2_hcm [MXCFEB-1:0];    // 1=enable DiStrip
  wire [MXDS-1:0]    cfeb_ly3_hcm [MXCFEB-1:0];    // 1=enable DiStrip
  wire [MXDS-1:0]    cfeb_ly4_hcm [MXCFEB-1:0];    // 1=enable DiStrip
  wire [MXDS-1:0]    cfeb_ly5_hcm [MXCFEB-1:0];    // 1=enable DiStrip

// Bad CFEB rx bit detection
  wire  [MXCFEB-1:0]     cfeb_badbits_reset;            // Reset bad cfeb bits FFs
  wire  [MXCFEB-1:0]     cfeb_badbits_block;            // Allow bad bits to block triads
  wire  [MXCFEB-1:0]     cfeb_badbits_found;            // CFEB[n] has at least 1 bad bit
  wire  [15:0]           cfeb_badbits_nbx;              // Cycles a bad bit must be continuously high
  wire  [MXDS*MXLY-1:0]  cfeb_blockedbits[MXCFEB-1:0];  // 1=CFEB rx bit blocked by hcm or went bad, packed

  wire  [MXDS-1:0]    cfeb_ly0_badbits[MXCFEB-1:0];  // 1=CFEB rx bit went bad
  wire  [MXDS-1:0]    cfeb_ly1_badbits[MXCFEB-1:0];  // 1=CFEB rx bit went bad
  wire  [MXDS-1:0]    cfeb_ly2_badbits[MXCFEB-1:0];  // 1=CFEB rx bit went bad
  wire  [MXDS-1:0]    cfeb_ly3_badbits[MXCFEB-1:0];  // 1=CFEB rx bit went bad
  wire  [MXDS-1:0]    cfeb_ly4_badbits[MXCFEB-1:0];  // 1=CFEB rx bit went bad
  wire  [MXDS-1:0]    cfeb_ly5_badbits[MXCFEB-1:0];  // 1=CFEB rx bit went bad

// Triad Decoder Ports
  wire  [3:0]      triad_persist;
  wire  [MXCFEB-1:0]  triad_skip;
  wire          triad_clr;

// Triad Decoder Outputs
  wire  [MXHS-1:0]    cfeb_ly0hs [MXCFEB-1:0];    // Decoded 1/2-strip pulses
  wire  [MXHS-1:0]    cfeb_ly1hs [MXCFEB-1:0];    // Decoded 1/2-strip pulses
  wire  [MXHS-1:0]    cfeb_ly2hs [MXCFEB-1:0];    // Decoded 1/2-strip pulses
  wire  [MXHS-1:0]    cfeb_ly3hs [MXCFEB-1:0];    // Decoded 1/2-strip pulses
  wire  [MXHS-1:0]    cfeb_ly4hs [MXCFEB-1:0];    // Decoded 1/2-strip pulses
  wire  [MXHS-1:0]    cfeb_ly5hs [MXCFEB-1:0];    // Decoded 1/2-strip pulses

  wire  [NHITCFEBB-1:0]         cfeb_nhits [MXCFEB-1:0];
  wire  [MXLY-1:0]    cfeb_layers_withhits[MXCFEB-1:0];
  
// Status Ports
  wire  [MXCFEB-1:0]  demux_tp_1st;
  wire  [MXCFEB-1:0]  demux_tp_2nd;
  wire  [MXCFEB-1:0]  triad_tp;            // Triad test point at raw hits RAM input
  wire  [MXLY-1:0]    parity_err_cfeb [MXCFEB-1:0];
  wire  [MXCFEB-1:0]  cfeb_sump;

// CFEB Injector data out multiplexler
  wire [17:0]  inj_rdata [MXCFEB-1:0];
  reg   [17:0] inj_rdata_mux;

  always @(inj_febsel or inj_rdata[0][0]) begin
  case (inj_febsel[6:0])
  7'b0000001:  inj_rdata_mux = inj_rdata[0][17:0];
  7'b0000010:  inj_rdata_mux = inj_rdata[1][17:0];
  7'b0000100:  inj_rdata_mux = inj_rdata[2][17:0];
  7'b0001000:  inj_rdata_mux = inj_rdata[3][17:0];
  7'b0010000:  inj_rdata_mux = inj_rdata[4][17:0];
  7'b0100000:  inj_rdata_mux = inj_rdata[5][17:0];
  7'b1000000:  inj_rdata_mux = inj_rdata[6][17:0];
  default    inj_rdata_mux = inj_rdata[0][17:0];
  endcase
  end

// CFEB data received on optical link = OR of all 48 bits for a given CFEB
  wire  [MXCFEB-1:0]  gtx_rx_data_bits_or; // CFEB data received on optical link

// Optical receiver status

  wire  [MXCFEB-1:0]  gtx_rx_enable;                 // In  Enable/Unreset GTX optical input, disables copper SCSI
  wire  [MXCFEB-1:0]  gtx_rx_reset;                  // In  Reset this GTX rx & sync module
  wire  [MXCFEB-1:0]  gtx_rx_reset_err_cnt;          // In  Resets the PRBS test error counters
  wire  [MXCFEB-1:0]  gtx_rx_en_prbs_test;           // In  Select random input test data mode
  wire  [MXCFEB-1:0]  gtx_rx_start;                  // Out  Set when the DCFEB Start Pattern is present
  wire  [MXCFEB-1:0]  gtx_rx_fc;                     // Out  Flags when Rx sees "FC" code (sent by Tx) for latency measurement
  wire  [MXCFEB-1:0]  gtx_rx_valid;                  // Out  Valid data detected on link
  wire  [MXCFEB-1:0]  gtx_rx_match;                  // Out  PRBS test data match detected, for PRBS tests, a VALID = "should have a match" such that !MATCH is an error
  wire  [MXCFEB-1:0]  gtx_rx_rst_done;               // Out  These get set before rxsync cycle begins
  wire  [MXCFEB-1:0]  gtx_rx_sync_done;              // Out  Use these to determine gtx_ready
  wire  [MXCFEB-1:0]  gtx_rx_pol_swap;               // Out  GTX 5,6 [ie dcfeb 4,5] have swapped rx board routes
  wire  [MXCFEB-1:0]  gtx_rx_err;                    // Out  PRBS test detects an error
  wire  [MXCFEB-1:0]  gtx_rx_sump;                   // Out  Unused signals
  wire  [15:0]        gtx_rx_err_count [MXCFEB-1:0]; // Out  Error count on this fiber channel
  wire  [15:0]        gtx_rx_kchar [MXCFEB-1:0]; // Out  Error count on this fiber channel
  wire  [MXCFEB-1:0]  link_had_err;                  // link stability monitor: error happened at least once
  wire  [MXCFEB-1:0]  link_good;                     // link stability monitor: always good, no errors since last resync
  wire  [MXCFEB-1:0]  link_bad;                      // link stability monitor: errors happened over 100 times
  wire  [MXCFEB-1:0]  ready_phaser;                  // phaser dps done and ready status

  wire  [MXCFEB-1:0]  gtx_rx_lt_trg_expect;
  wire  [MXCFEB-1:0]  gtx_rx_lt_trg;
  wire  [MXCFEB-1:0]  gtx_rx_lt_trg_err;
  wire  [15:0]        gtx_rx_notintable_count [MXCFEB-1:0]; // Out  Error count on this fiber channel
  wire  [15:0]        gtx_rx_disperr_count [MXCFEB-1:0]; // Out  Error count on this fiber channel

  wire  [MXCFEB-1:0]  cfeb_rx_nonzero;               // Out Flags when rx sees non-zero data

  wire  ready_phaser_a, ready_phaser_b, auto_gtx_reset;

  reg        gtx_wait       = 1'b1;
  reg [15:0] gtx_wait_count = 0;

  always @(posedge clock) // things that use lhc_clk wo/Reset
  begin
    if ( gtx_wait & (ready_phaser_a | ready_phaser_b) ) gtx_wait_count <= gtx_wait_count + 1'b1;
    gtx_wait <= !gtx_wait_count[14];  // goes to zero after 409 usec
  end

  assign  ready_phaser[0] = !gtx_wait & ready_phaser_b;
  assign  ready_phaser[1] = !gtx_wait & ready_phaser_b;
  assign  ready_phaser[2] = !gtx_wait & ready_phaser_b;
  assign  ready_phaser[3] = !gtx_wait & ready_phaser_b;
  assign  ready_phaser[4] = !gtx_wait & ready_phaser_a;
  assign  ready_phaser[5] = !gtx_wait & ready_phaser_a;
  assign  ready_phaser[6] = !gtx_wait & ready_phaser_a;

//-------------------------------------------------------------------------------------------------------------------
// CFEB Instantiation
//-------------------------------------------------------------------------------------------------------------------
 //     .auto_gtx_reset (auto_gtx_reset),   // new In
  genvar icfeb;
  generate
  for (icfeb=0; icfeb<=MXCFEB-1; icfeb=icfeb+1) begin: gencfeb
     assign cfeb_exists[icfeb] = 1;                // Existence flag

  cfeb #(.ICFEB(icfeb)) ucfeb
  (
// Clock
  .clock              (clock),                           // In  40MHz TMB system clock from MMCM
  .clk_lock           (lock_tmb_clock0),                 // In  40MHz TMB system clock MMCM locked
  .clock_4x           (clock_4x),                        // In  4*40MHz TMB system clock from MMCM
  .clock_cfeb_rxd     (clock_cfeb_rxd[icfeb]),           // In  CFEB cfeb-to-tmb inter-stage clock select 0 or 180 degrees
  .cfeb_rxd_posneg    (cfeb_rxd_posneg[icfeb]),          // In  CFEB cfeb-to-tmb inter-stage clock select 0 or 180 degrees
  .cfeb_rxd_int_delay (cfeb_rxd_int_delay[icfeb][3:0]),  // In  Interstage delay, integer bx
//.phaser_ready (ready_phaser[icfeb]),                   // new In

// Resets
  .global_reset (global_reset),     // In  Global reset
  .ttc_resync   (ttc_resync),       // In  TTC resync
  .mask_all     (mask_all[icfeb]),  // In  1=Enable, 0=Turn off all inputs

// Injector Ports
  .inj_febsel       (inj_febsel[icfeb]),        // In  1=Enable RAM write
  .inject           (injector_go_cfeb[icfeb]),  // In  1=Start pattern injector
  .inj_last_tbin    (inj_last_tbin[11:0]),      // In  Last tbin, may wrap past 1024 ram adr
  .inj_wen          (inj_wen[2:0]),             // In  1=Write enable injector RAM
  .inj_rwadr        (inj_rwadr[9:0]),           // In  Injector RAM read/write address
  .inj_wdata        (inj_wdata[17:0]),          // In  Injector RAM write data
  .inj_ren          (inj_ren[2:0]),             // In  1=Read enable Injector RAM
  .inj_rdata        (inj_rdata[icfeb][17:0]),   // Out  Injector RAM read data
  .inj_ramout       (inj_ramout[icfeb][5:0]),   // Out  Injector RAM read data for ALCT and L1A
  .inj_ramout_pulse (inj_ramout_pulse[icfeb]),  // Out  Injector RAM is injecting

// Raw Hits FIFO RAM Ports
  .fifo_wen   (fifo_wen),                          // In  1=Write enable FIFO RAM
  .fifo_wadr  (fifo_wadr[RAM_ADRB-1:0]),           // In  FIFO RAM write address
  .fifo_radr  (fifo_radr_cfeb[RAM_ADRB-1:0]),      // In  FIFO RAM read tbin address
  .fifo_sel   (fifo_sel_cfeb[2:0]),                // In  FIFO RAM read layer address 0-5
  .fifo_rdata (fifo_rdata[icfeb][RAM_WIDTH-1:0]),  // Out  FIFO RAM read data

// Hot Channel Mask Ports
  .ly0_hcm (cfeb_ly0_hcm[icfeb][MXDS-1:0]),  // In  1=enable DiStrip
  .ly1_hcm (cfeb_ly1_hcm[icfeb][MXDS-1:0]),  // In  1=enable DiStrip
  .ly2_hcm (cfeb_ly2_hcm[icfeb][MXDS-1:0]),  // In  1=enable DiStrip
  .ly3_hcm (cfeb_ly3_hcm[icfeb][MXDS-1:0]),  // In  1=enable DiStrip
  .ly4_hcm (cfeb_ly4_hcm[icfeb][MXDS-1:0]),  // In  1=enable DiStrip
  .ly5_hcm (cfeb_ly5_hcm[icfeb][MXDS-1:0]),  // In  1=enable DiStrip

// Bad CFEB rx bit detection
  .cfeb_badbits_reset (cfeb_badbits_reset[icfeb]),  // In  Reset bad cfeb bits FFs
  .cfeb_badbits_block (cfeb_badbits_block[icfeb]),  // In  Allow bad bits to block triads
  .cfeb_badbits_nbx   (cfeb_badbits_nbx[15:0]),     // In  Cycles a bad bit must be continuously high
  .cfeb_badbits_found (cfeb_badbits_found[icfeb]),  // Out  CFEB[n] has at least 1 bad bit
  .cfeb_blockedbits   (cfeb_blockedbits[icfeb]),    // Out  1=CFEB rx bit blocked by hcm or went bad, packed

  .ly0_badbits (cfeb_ly0_badbits[icfeb][MXDS-1:0]),  // Out  1=CFEB rx bit went bad
  .ly1_badbits (cfeb_ly1_badbits[icfeb][MXDS-1:0]),  // Out  1=CFEB rx bit went bad
  .ly2_badbits (cfeb_ly2_badbits[icfeb][MXDS-1:0]),  // Out  1=CFEB rx bit went bad
  .ly3_badbits (cfeb_ly3_badbits[icfeb][MXDS-1:0]),  // Out  1=CFEB rx bit went bad
  .ly4_badbits (cfeb_ly4_badbits[icfeb][MXDS-1:0]),  // Out  1=CFEB rx bit went bad
  .ly5_badbits (cfeb_ly5_badbits[icfeb][MXDS-1:0]),  // Out  1=CFEB rx bit went bad

// Triad Decoder Ports
  .triad_persist (triad_persist[3:0]),  // In  Triad 1/2-strip persistence
  .triad_clr     (triad_clr),           // In  Triad one-shot clear
  .triad_skip    (triad_skip[icfeb]),   // Out  Triads skipped

// Triad Decoder Outputs
  .ly0hs (cfeb_ly0hs[icfeb][MXHS-1:0]),  // Out  Decoded 1/2-strip pulses
  .ly1hs (cfeb_ly1hs[icfeb][MXHS-1:0]),  // Out  Decoded 1/2-strip pulses
  .ly2hs (cfeb_ly2hs[icfeb][MXHS-1:0]),  // Out  Decoded 1/2-strip pulses
  .ly3hs (cfeb_ly3hs[icfeb][MXHS-1:0]),  // Out  Decoded 1/2-strip pulses
  .ly4hs (cfeb_ly4hs[icfeb][MXHS-1:0]),  // Out  Decoded 1/2-strip pulses
  .ly5hs (cfeb_ly5hs[icfeb][MXHS-1:0]),  // Out  Decoded 1/2-strip pulses

  .nhits_per_cfeb (cfeb_nhits[icfeb][NHITCFEBB-1:0]),  // Out nhits per cfeb for HMT
  .layers_withhits_per_cfeb  (cfeb_layers_withhits[icfeb][MXLY-1:0]),// Out layers with hits for one cfeb
// CFEB data received on optical link
  .gtx_rx_data_bits_or (gtx_rx_data_bits_or[icfeb]), // Out  CFEB data received on optical link = OR of all 48 bits for a given CFEB

// Status
  .demux_tp_1st    (demux_tp_1st[icfeb]),               // Out  Demultiplexer test point first-in-time
  .demux_tp_2nd    (demux_tp_2nd[icfeb]),               // Out  Demultiplexer test point second-in-time
  .triad_tp        (triad_tp[icfeb]),                   // Out  Triad test point at raw hits RAM input
  .parity_err_cfeb (parity_err_cfeb[icfeb][MXLY-1:0]),  // Out  Raw hits RAM parity error detected
  .cfeb_sump       (cfeb_sump[icfeb]),                  // Out  Unused signals wot must be connected

// SNAP12 optical receiver
  .clock_160 (clock_160),                     // In  160 MHz from QPLL for GTX reference clock
//.qpll_lock (l_qpll_lock & l_tmbclk0_lock),  // In  QPLL has been locked, good to wait for startup-powerup... was real-time direct qpll_lock
  .qpll_lock (qpll_lock),                     // In  QPLL has been locked, good to wait for startup-powerup... was real-time direct qpll_lock
  .rxp       (rxp[icfeb]),                    // In  SNAP12+ fiber input for GTX
  .rxn       (rxn[icfeb]),                    // In  SNAP12- fiber input for GTX

// Optical receiver status
  .gtx_rx_enable        (gtx_rx_enable[icfeb] & ready_phaser[icfeb]),  // In  Enable/Unreset GTX optical input; disables copper SCSI? JRG, hold off enable until pds phaser is done and ready
//.gtx_rx_enable        (gtx_rx_enable[icfeb]),                        // In  Enable/Unreset GTX optical input; disables copper SCSI?
  .gtx_rx_reset         (gtx_rx_reset[icfeb] | auto_gtx_reset),        // In  Reset this GTX rx & sync module; auto reset all if any take too long to phase lock
//.gtx_rx_reset         (gtx_rx_reset[icfeb]),                         // In  Reset this GTX rx & sync module
  .gtx_rx_reset_err_cnt (gtx_rx_reset_err_cnt[icfeb]),                 // In  Resets the PRBS test error counters
  .gtx_rx_en_prbs_test  (gtx_rx_en_prbs_test[icfeb]),                  // In  Select random input test data mode
  .gtx_rx_start         (gtx_rx_start[icfeb]),                         // Out Set when the DCFEB Start Pattern is present
  .gtx_rx_fc            (gtx_rx_fc[icfeb]),                            // Out Flags when Rx sees "FC" code (sent by Tx) for latency measurement
  .gtx_rx_nonzero       (cfeb_rx_nonzero[icfeb]),                      // Out Flags when any non-zero data passes through CFEB link
  .gtx_rx_valid         (gtx_rx_valid[icfeb]),                         // Out Valid data detected on link
  .gtx_rx_match         (gtx_rx_match[icfeb]),                         // Out PRBS test data match detected, for PRBS tests, a VALID = "should have a match" such that !MATCH is an error
  .gtx_rx_rst_done      (gtx_rx_rst_done[icfeb]),                      // Out These get set before rxsync cycle begins
  .gtx_rx_sync_done     (gtx_rx_sync_done[icfeb]),                     // Out Use these to determine gtx_ready
  .gtx_rx_pol_swap      (gtx_rx_pol_swap[icfeb]),                      // Out GTX 5,6 [ie dcfeb 4,5] have swapped rx board routes
  .gtx_rx_err           (gtx_rx_err[icfeb]),                           // Out PRBS test detects an error
  .gtx_rx_err_count     (gtx_rx_err_count[icfeb][15:0]),               // Out Error count on this fiber channel
  .gtx_rx_kchar         (gtx_rx_kchar[icfeb][15:0]),                   // Out gtx kchar
  .link_had_err         (link_had_err[icfeb]),                         // Out Link stability monitor: error happened at least once
  .link_good            (link_good[icfeb]),                            // Out Link stability monitor: always good, no errors since last resync
  .link_bad             (link_bad[icfeb]),                             // Out Link stability monitor: errors happened over 100 times
  .gtx_rx_lt_trg_err        (gtx_rx_lt_trg_err[icfeb]),     // Out  Flags when Rx sees "FC" code (sent by Tx) for latency measurement
  .gtx_rx_lt_trg            (gtx_rx_lt_trg[icfeb]),     // Out  Flags when Rx sees "FC" code (sent by Tx) for latency measurement
  .gtx_rx_lt_trg_expect     (gtx_rx_lt_trg_expect[icfeb]),     // Out  Flags when Rx sees "FC" code (sent by Tx) for latency measurement
  .gtx_rx_notintable_count  (gtx_rx_notintable_count[icfeb][15:0]),               // Out Error count on this fiber channel
  .gtx_rx_disperr_count     (gtx_rx_disperr_count[icfeb][15:0]),               // Out Error count on this fiber channel
  .gtx_rx_sump          (gtx_rx_sump[icfeb])                           // Out Unused signals

// Debug Ports
  );
  end
  endgenerate


  wire cfebs_me1a_synced;
  wire cfebs_me1a_lostsync;
  wire cfebs_me1b_synced;
  wire cfebs_me1b_lostsync;
  csc_sync_mon ucsc_sync_mon
  (
  .clock              (clock),                           // In  40MHz TMB system clock from MMCM
  .clk_lock           (lock_tmb_clock0),                 // In  40MHz TMB system clock MMCM locked

// Resets
  .global_reset (global_reset),     // In  Global reset
  .ttc_resync   (ttc_resync),       // In  TTC resync

  .cfeb0_kchar  (gtx_rx_kchar[0][7:0]),//In CFEB0 kchar, 8bits
  .cfeb1_kchar  (gtx_rx_kchar[1][7:0]),//In CFEB0 kchar, 8bits
  .cfeb2_kchar  (gtx_rx_kchar[2][7:0]),//In CFEB0 kchar, 8bits
  .cfeb3_kchar  (gtx_rx_kchar[3][7:0]),//In CFEB0 kchar, 8bits
  .cfeb4_kchar  (gtx_rx_kchar[4][7:0]),//In CFEB0 kchar, 8bits
  .cfeb5_kchar  (gtx_rx_kchar[5][7:0]),//In CFEB0 kchar, 8bits
  .cfeb6_kchar  (gtx_rx_kchar[6][7:0]),//In CFEB0 kchar, 8bits

  .cfeb_rxd_int_delay         (cfeb_rxd_int_delay[0][3:0]),  // In  Interstage delay, integer bx
  .cfeb_rxd_int_delay_me1a    (cfeb_rxd_int_delay[4][3:0]),  // In  Interstage delay, integer bx
  .cfeb_fiber_enable     (mask_all[MXCFEB-1:0]),  // In  1=Enable, 0=Turn off all inputs
  .link_good             (link_good[MXCFEB-1:0]),   // In Link stability monitor: always good, no errors since last resync
  .cfeb_lt_trg_err       (gtx_rx_lt_trg_err[MXCFEB-1:0]),//In, all cfeb sync done or not
  .cfeb_sync_done        (gtx_rx_sync_done[MXCFEB-1:0]),//In, all cfeb sync done or not
  .cfebs_me1a_synced          (cfebs_me1a_synced), //out all cfebs are in sync
  .cfebs_me1a_lostsync        (cfebs_me1a_lostsync), //out all cfebs are in sync
  .cfebs_synced               (cfebs_me1b_synced), //out all cfebs are in sync
  .cfebs_lostsync             (cfebs_me1b_lostsync) //out all cfebs are in sync
  );


//-------------------------------------------------------------------------------------------------------------------
// GEM Instantiation
//-------------------------------------------------------------------------------------------------------------------

  wire  [MXGEM-1:0]     gem_exists;
  wire  [MXGEM-1:0]     gem_read_mask;                    // GEM readout list mask

  wire  [MXGEM-1:0]     gem_rx_enable;                 // In  Enable/Unreset GTX optical input, disables copper SCSI
  wire  [MXGEM-1:0]     gem_rx_reset;                  // In  Reset this GTX rx & sync module
  wire  [MXGEM-1:0]     gem_rx_reset_err_cnt;          // In  Resets the PRBS test error counters
  wire  [MXGEM-1:0]     gem_rx_en_prbs_test;           // In  Select random input test data mode
  wire  [MXGEM-1:0]     gem_rx_valid;                  // Out  Valid data detected on link
  wire  [MXGEM-1:0]     gem_rx_rst_done;               // Out  These get set before rxsync cycle begins
  wire  [MXGEM-1:0]     gem_rx_sync_done;              // Out  Use these to determine gem_ready
  wire  [MXGEM-1:0]     gem_rx_pol_swap;               // Out  GTX 5,6 [ie dcfeb 4,5] have swapped rx board routes
  wire  [MXGEM-1:0]     gem_rx_err;                    // Out  PRBS test detects an error
  wire  [MXGEM-1:0]     gem_sump;
  wire  [15:0]          gem_rx_err_count [MXGEM-1:0];  // Out  Error count on this fiber channel
  wire  [15:0]          gem_rx_notintable_count [MXGEM-1:0];  // Out  Error count on this fiber channel
  wire  [15:0]          gem_rx_disperr_count [MXGEM-1:0];  // Out  Error count on this fiber channel
  wire  [MXGEM-1:0]     gem_link_had_err;              // link stability monitor: error happened at least once
  wire  [MXGEM-1:0]     gem_link_good;                 // link stability monitor: always good, no errors since last resync
  wire  [MXGEM-1:0]     gem_link_bad;                  // link stability monitor: errors happened over 100 times


  //wire  [MXGEMHCM-1:0]    gemA_vfat_hcm[MXVFAT-1:0];
  //wire  [MXGEMHCM-1:0]    gemB_vfat_hcm[MXVFAT-1:0];
  wire [MXVFAT-1:0]    gemA_vfat_hcm;
  wire [MXVFAT-1:0]    gemB_vfat_hcm;

  wire gemA_rxd_posneg;
  wire gemB_rxd_posneg;

  wire [3:0] gemA_rxd_int_delay;
  wire [3:0] gemB_rxd_int_delay;

  // both fibers on gemA, and both fibers on gemB share posnegs and int_delays
  wire  [MXGEM-1:0]     gem_rxd_posneg;
  wire  [3:0]     gem_rxd_int_delay [MXGEM-1:0]; // reg [7:0] a[0:3] will give you a 4x8 bit array

  assign gem_rxd_posneg[0] = gemA_rxd_posneg;
  assign gem_rxd_posneg[1] = gemA_rxd_posneg;
  assign gem_rxd_posneg[2] = gemB_rxd_posneg;
  assign gem_rxd_posneg[3] = gemB_rxd_posneg;

  assign gem_rxd_int_delay[0][3:0] = gemA_rxd_int_delay[3:0];
  assign gem_rxd_int_delay[1][3:0] = gemA_rxd_int_delay[3:0];
  assign gem_rxd_int_delay[2][3:0] = gemB_rxd_int_delay[3:0];
  assign gem_rxd_int_delay[3][3:0] = gemB_rxd_int_delay[3:0];

  wire  [13:0] gem_debug_fifo_rdata [MXGEM-1:0];    // GEM FIFO RAM read data

  wire [13:0] gem_cluster0 [MXGEM-1:0]; // cluster0 in GEM coordinates (0-191 for pad num)
  wire [13:0] gem_cluster1 [MXGEM-1:0]; // cluster1 in GEM coordinates (0-191 for pad num)
  wire [13:0] gem_cluster2 [MXGEM-1:0]; // cluster2 in GEM coordinates (0-191 for pad num)
  wire [13:0] gem_cluster3 [MXGEM-1:0]; // cluster3 in GEM coordinates (0-191 for pad num)

  //wire [ 4:0] gem_cluster0_feb  [MXGEM-1:0]; // VFAT number 
  //wire [ 4:0] gem_cluster1_feb  [MXGEM-1:0]; // VFAT number 
  //wire [ 4:0] gem_cluster2_feb  [MXGEM-1:0]; // VFAT number 
  //wire [ 4:0] gem_cluster3_feb  [MXGEM-1:0]; // VFAT number 

  wire [ 2:0] gem_cluster0_roll [MXGEM-1:0]; // roll  number
  wire [ 2:0] gem_cluster1_roll [MXGEM-1:0]; // roll  number
  wire [ 2:0] gem_cluster2_roll [MXGEM-1:0]; // roll  number
  wire [ 2:0] gem_cluster3_roll [MXGEM-1:0]; // roll  number

  wire [ 7:0] gem_cluster0_pad  [MXGEM-1:0]; // pad number in one roll,0-191
  wire [ 7:0] gem_cluster1_pad  [MXGEM-1:0]; // pad number in one roll,0-191
  wire [ 7:0] gem_cluster2_pad  [MXGEM-1:0]; // pad number in one roll,0-191
  wire [ 7:0] gem_cluster3_pad  [MXGEM-1:0]; // pad number in one roll,0-191

  wire  [0:0]   gem_vpf0 [MXGEM-1:0]; // cluster0 valid flag
  wire  [0:0]   gem_vpf1 [MXGEM-1:0]; // cluster1 valid flag
  wire  [0:0]   gem_vpf2 [MXGEM-1:0]; // cluster2 valid flag
  wire  [0:0]   gem_vpf3 [MXGEM-1:0]; // cluster3 valid flag
  wire [23:0]   gem_active_feb_list[MXGEM-1:0];
  wire [23:0]   gemA_active_feb_list;
  wire [23:0]   gemB_active_feb_list;

  // join fibers together into the two GEM chambers
  wire [CLSTBITS-1:0] gemA_cluster [MXCLUSTER_CHAMBER-1:0] = {
    gem_cluster3[1],
    gem_cluster2[1],
    gem_cluster1[1],
    gem_cluster0[1],
    gem_cluster3[0],
    gem_cluster2[0],
    gem_cluster1[0],
    gem_cluster0[0]
  };

  wire [CLSTBITS-1:0] gemB_cluster [MXCLUSTER_CHAMBER-1:0] = {
    gem_cluster3[3],
    gem_cluster2[3],
    gem_cluster1[3],
    gem_cluster0[3],
    gem_cluster3[2],
    gem_cluster2[2],
    gem_cluster1[2],
    gem_cluster0[2]
  };

  wire [2:0] gemA_cluster_roll [MXCLUSTER_CHAMBER-1:0] = {
    gem_cluster3_roll[1],
    gem_cluster2_roll[1],
    gem_cluster1_roll[1],
    gem_cluster0_roll[1],
    gem_cluster3_roll[0],
    gem_cluster2_roll[0],
    gem_cluster1_roll[0],
    gem_cluster0_roll[0]
  };

  wire [2:0] gemB_cluster_roll [MXCLUSTER_CHAMBER-1:0] = {
    gem_cluster3_roll[3],
    gem_cluster2_roll[3],
    gem_cluster1_roll[3],
    gem_cluster0_roll[3],
    gem_cluster3_roll[2],
    gem_cluster2_roll[2],
    gem_cluster1_roll[2],
    gem_cluster0_roll[2]
  };

  wire [7:0] gemA_cluster_pad [MXCLUSTER_CHAMBER-1:0] = {
    gem_cluster3_pad[1],
    gem_cluster2_pad[1],
    gem_cluster1_pad[1],
    gem_cluster0_pad[1],
    gem_cluster3_pad[0],
    gem_cluster2_pad[0],
    gem_cluster1_pad[0],
    gem_cluster0_pad[0]
  };

  wire [7:0] gemB_cluster_pad [MXCLUSTER_CHAMBER-1:0] = {
    gem_cluster3_pad[3],
    gem_cluster2_pad[3],
    gem_cluster1_pad[3],
    gem_cluster0_pad[3],
    gem_cluster3_pad[2],
    gem_cluster2_pad[2],
    gem_cluster1_pad[2],
    gem_cluster0_pad[2]
    };

  wire [MXCLUSTER_CHAMBER-1:0] gemA_vpf = {
    gem_vpf3[1],
    gem_vpf2[1],
    gem_vpf1[1],
    gem_vpf0[1],
    gem_vpf3[0],
    gem_vpf2[0],
    gem_vpf1[0],
    gem_vpf0[0]
  };

  wire [MXCLUSTER_CHAMBER-1:0] gemB_vpf = {
    gem_vpf3[3],
    gem_vpf2[3],
    gem_vpf1[3],
    gem_vpf0[3],
    gem_vpf3[2],
    gem_vpf2[2],
    gem_vpf1[2],
    gem_vpf0[2]
  };

  wire gem_any = (|gemA_vpf) | (|gemB_vpf);
   
  //GEMA trigger match control
  //wire  gemA_match_enable;
  //wire  gemB_match_enable;
  wire [1:0]  gemA_fiber_enable;

  //GEMB trigger match control
  //wire [3:0]  match_gemB_alct_window;
  //wire [3:0]  match_gemB_clct_window;
  wire [1:0]  gemB_fiber_enable;

  wire [3:0] gem_fiber_enable = {gemB_fiber_enable, gemA_fiber_enable};
  wire gem_enable = (|gem_fiber_enable) && (gem_me1a_match_enable || gem_me1b_match_enable);

  //reg  [MXCLUSTER_CHAMBER-1:0] gemA_cluster_enable = 8'b0;
  //reg  [MXCLUSTER_CHAMBER-1:0] gemB_cluster_enable = 8'b0;
  //always @ (posedge clock ) begin
  //    gemA_cluster_enable <= {
  //    gemA_fiber_enable[1],
  //    gemA_fiber_enable[1],
  //    gemA_fiber_enable[1],
  //    gemA_fiber_enable[1],
  //    gemA_fiber_enable[0],
  //    gemA_fiber_enable[0],
  //    gemA_fiber_enable[0],
  //    gemA_fiber_enable[0]
  //    };
  //    gemB_cluster_enable <= {
  //    gemB_fiber_enable[1],
  //    gemB_fiber_enable[1],
  //    gemB_fiber_enable[1],
  //    gemB_fiber_enable[1],
  //    gemB_fiber_enable[0],
  //    gemB_fiber_enable[0],
  //    gemB_fiber_enable[0],
  //    gemB_fiber_enable[0]
  //    };
  //end

  wire [9:0]   gem_debug_fifo_adr;    // FIFO RAM read tbin address
  wire [1:0]   gem_debug_fifo_sel;    // FIFO RAM read layer clusters 0-3
  wire [1:0]   gem_debug_fifo_igem;   // FIFO RAM read chamber 0-3
  wire         gem_debug_fifo_reset;  // FIFO RAM read data

  wire [15:0]  gem_debug_fifo_data_vme = {2'b0,gem_debug_fifo_rdata[gem_debug_fifo_igem]};

  wire [9:0]   gem_inj_adr;      // FIFO RAM read tbin address
  wire [1:0]   gem_inj_sel;      // FIFO RAM read layer clusters 0-3
  wire [1:0]   gem_inj_igem;     // FIFO RAM read chamber 0-3
  wire [15:0]  gem_inj_data_vme; // FIFO RAM read chamber 0-3
  wire         gem_inj_wen;      // GEM Injector Write Enable
  wire         injector_go_gem;  // Start GEM injector

  wire       evenchamber;  // from VME register 0x198, 1 for even chamber and 0 for odd chamber
  wire [4:0]   gem_clct_deltahs_odd;
  wire [4:0]   gem_clct_deltahs_even;
  wire [2:0]   gem_alct_deltawire_odd;
  wire [2:0]   gem_alct_deltawire_even;
  reg  [4:0]   gem_clct_deltahs;
  reg  [2:0]   gem_alct_deltawire;
  always @(posedge clock) begin
      gem_clct_deltahs   = evenchamber ? gem_clct_deltahs_even   : gem_clct_deltahs_odd;
      gem_alct_deltawire = evenchamber ? gem_alct_deltawire_even : gem_alct_deltawire_odd;
  end
  

  wire       gem_me1a_match_enable;
  wire       gem_me1b_match_enable;

  wire       match_drop_lowqalct;     //drop low Q stub 
  wire       me1a_match_drop_lowqclct;//drop low Q stub 
  wire       me1b_match_drop_lowqclct;//drop low Q stub 
  wire       tmb_copad_alct_allow; // allow Copad+ALCT
  wire       tmb_copad_clct_allow; // allow Copad+CLCT
  //wire       gem_me1a_match_promotequal;
  //wire       gem_me1b_match_promotequal;
  //wire       gem_me1a_match_promotepat;
  //wire       gem_me1b_match_promotepat;

  // Raw Hits FIFO RAM Ports
  wire  [RAM_ADRB-1:0]      fifo_radr_gem;              // FIFO RAM read tbin address
  wire  [1:0]               fifo_sel_gem;               // FIFO RAM read cluster 0-3 from this fiber
  wire  [RAM_WIDTH_GEM-1:0] fifo_rdata_gem [MXGEM-1:0]; // FIFO RAM read data

  wire  [3:0] parity_err_gem [MXGEM-1:0];          // Raw hits RAM parity error detected

  wire  [7:0] gem_kchar [MXGEM-1:0];

  wire  [3:0] gem_overflow;
  wire  [3:0] gem_bc0marker;
  wire  [3:0] gem_resyncmarker;

  wire gemA_overflow = |gem_overflow[1:0];
  wire gemB_overflow = |gem_overflow[3:2];

  wire gemA_bc0marker = &gem_bc0marker[1:0];
  wire gemB_bc0marker = &gem_bc0marker[3:2];

  //wire gemA_bx0_rx    = |gem_bc0marker[1:0]; // both two GEMA fibers sending BC0 marker
  //wire gemB_bx0_rx    = |gem_bc0marker[3:2]; // both two GEMA fibers sending BC0 marker
  wire gemA_bx0_rx = gemA_bc0marker;
  wire gemB_bx0_rx = gemB_bc0marker;

  wire gemA_resyncmarker = &gem_resyncmarker[1:0];
  wire gemB_resyncmarker = &gem_resyncmarker[3:2];

  wire gemA_sync_done   = &gem_rx_sync_done[1:0];
  wire gemB_sync_done   = &gem_rx_sync_done[3:2];

  assign gemA_active_feb_list = (gem_active_feb_list[0] | gem_active_feb_list[1]);
  assign gemB_active_feb_list = (gem_active_feb_list[2] | gem_active_feb_list[3]);


// Main GEM Generate Loop
  genvar igem;
  generate
  for (igem=0; igem<MXGEM; igem=igem+1) begin: gengem

  assign gem_exists[igem] = 1;                // Existence flag

  gem #(.IGEM(igem)) ugem (

  // Clock
  .clock             (clock),                        // In  40MHz TMB system clock from MMCM
  .clk_lock          (lock_tmb_clock0),              // In  40MHz TMB system clock MMCM locked
  .clock_4x          (clock_4x),                     // In  4*40MHz clock for GTX Reference
  .clock_gem_rxd     (clock_gem_rxd[0]),             // In  GEM cfeb-to-tmb inter-stage clock select 0 or 180 degrees
  .gem_rxd_posneg    (gem_rxd_posneg[igem]),         // In  GEM cfeb-to-tmb inter-stage clock select 0 or 180 degrees
  .gem_rxd_int_delay (gem_rxd_int_delay[igem][3:0]), // In  Interstage delay, integer bx

  // Resets
  .global_reset (global_reset  ), // In  Global reset
  .ttc_resync   (ttc_resync    ), // In  TTC resync

  .gem_sump     (gem_sump[igem]), // Out  Unused signals wot must be connected

  // SNAP12 optical receiver
  .clock_160 (clock_160),     // In  160 MHz from QPLL for GTX reference clock
  .qpll_lock (qpll_lock),     // In  QPLL has been locked, good to wait for startup-powerup... was real-time direct qpll_lock
  .rxp       (gemrxp[igem]), // In  SNAP12+ fiber input for GEM GTX
  .rxn       (gemrxn[igem]), // In  SNAP12- fiber input for GEM GTX

  // Optical receiver status
  .gtx_rx_enable        (gem_rx_enable        [igem] & ready_phaser[0]), // In   Enable/Unreset GTX optical input; disables copper SCSI? JRG, hold off enable until pds phaser is done and ready
  .gtx_rx_reset         (gem_rx_reset         [igem] | auto_gtx_reset ), // In   Reset this GTX rx & sync module; auto reset all if any take too long to phase lock
  .gtx_rx_reset_err_cnt (gem_rx_reset_err_cnt [igem]                  ), // In   Resets the PRBS test error counters
  .gtx_rx_en_prbs_test  (gem_rx_en_prbs_test  [igem]                  ), // In   Select random input test data mode
  .gtx_rx_valid         (gem_rx_valid         [igem]                  ), // Out  Valid data detected on link
  .gtx_rx_rst_done      (gem_rx_rst_done      [igem]                  ), // Out  These get set before rxsync cycle begins
  .gtx_rx_sync_done     (gem_rx_sync_done     [igem]                  ), // Out  Use these to determine gtx_ready
  .gtx_rx_pol_swap      (gem_rx_pol_swap      [igem]                  ), // Out  GTX 5,6 [ie dcfeb 4,5] have swapped rx board routes
  .gtx_rx_err           (gem_rx_err           [igem]                  ), // Out  PRBS test detects an error
  .gtx_rx_err_count     (gem_rx_err_count     [igem][ 15:0]           ), // Out  Error count on this fiber channel
  .gtx_rx_notintable_count  (gem_rx_notintable_count     [igem][ 15:0]           ), // Out  Error count on this fiber channel
  .gtx_rx_disperr_count     (gem_rx_disperr_count     [igem][ 15:0]           ), // Out  Error count on this fiber channel
  .link_had_err         (gem_link_had_err     [igem]                  ), // Out  link stability monitor: error happened at least once
  .link_good            (gem_link_good        [igem]                  ), // Out  link stability monitor: always good, no errors since last resync
  .link_bad             (gem_link_bad         [igem]                  ), // Out  link stability monitor: errors happened over 100 times

  .k_char               (gem_kchar            [igem]                  ), // Out latched copy of last Received K-Char

  .overflow     (gem_overflow    [igem]), // GEM received cluster overflow
  .bc0marker    (gem_bc0marker   [igem]), // GEM received cluster BC0 marker
  .resyncmarker (gem_resyncmarker[igem]), // GEM received cluster resync marker

  // Debug Dummy FIFO Control Ports
  .debug_fifo_radr  (gem_debug_fifo_adr),         // In  FIFO RAM read tbin address
  .debug_fifo_sel   (gem_debug_fifo_sel),         // In  FIFO RAM read layer clusters 0-3
  .debug_fifo_reset (gem_debug_fifo_reset),       // In  FIFO RAM reset
  .debug_fifo_rdata (gem_debug_fifo_rdata[igem]), // Out FIFO RAM read data

  // GEM Ports: GEM Raw Hits Ram
  .inj_wen       (gem_inj_wen),         // In  GEM injector write enable
  .inj_rwadr     (gem_inj_adr),         // In  Select GEM injector Address
  .inj_sel       (gem_inj_sel),         // In  Select GEM Fiber Cluster 0-3
  .inj_igem      (gem_inj_igem),        // In  Select GEM Fiber 0-3
  .inj_wdata     (gem_inj_data_vme),    // In  GEM injector RAM data
  .inj_go_gem    (injector_go_gem),     // In  Start GEM injector
  .inj_last_tbin (inj_last_tbin[11:0]), //

  // Raw Hits FIFO RAM Ports
  .fifo_wen   (fifo_wen),                                // In  1=Write enable FIFO RAM
  .fifo_wadr  (fifo_wadr[RAM_ADRB-1:0]),                 // In  FIFO RAM write address
  .fifo_radr  (fifo_radr_gem[RAM_ADRB-1:0]),             // In  FIFO RAM read tbin address
  .fifo_sel   (fifo_sel_gem[1:0]),                       // In  FIFO RAM read cluster 0-3
  .fifo_rdata (fifo_rdata_gem[igem][RAM_WIDTH_GEM-1:0]), // Out FIFO RAM read data

  .parity_err_gem (parity_err_gem[igem]),  // RAW hits RAM parity error

  .gem_fiber_enable  (gem_fiber_enable[igem]), //
  .gemA_vfat_hcm     (gemA_vfat_hcm), // In GEM hot vfat mask
  .gemB_vfat_hcm     (gemB_vfat_hcm), // In GEM hot vfat mask

  //.gemA_vfat0_hcm    (gemA_vfat_hcm[ 0]), // In GEM Hot channel mask 
  //.gemA_vfat1_hcm    (gemA_vfat_hcm[ 1]), // In GEM Hot channel mask
  //.gemA_vfat2_hcm    (gemA_vfat_hcm[ 2]), // In GEM Hot channel mask
  //.gemA_vfat3_hcm    (gemA_vfat_hcm[ 3]), // In GEM Hot channel mask
  //.gemA_vfat4_hcm    (gemA_vfat_hcm[ 4]), // In GEM Hot channel mask
  //.gemA_vfat5_hcm    (gemA_vfat_hcm[ 5]), // In GEM Hot channel mask
  //.gemA_vfat6_hcm    (gemA_vfat_hcm[ 6]), // In GEM Hot channel mask
  //.gemA_vfat7_hcm    (gemA_vfat_hcm[ 7]), // In GEM Hot channel mask
  //.gemA_vfat8_hcm    (gemA_vfat_hcm[ 8]), // In GEM Hot channel mask
  //.gemA_vfat9_hcm    (gemA_vfat_hcm[ 9]), // In GEM Hot channel mask
  //.gemA_vfat10_hcm   (gemA_vfat_hcm[10]), // In GEM Hot channel mask
  //.gemA_vfat11_hcm   (gemA_vfat_hcm[11]), // In GEM Hot channel mask
  //.gemA_vfat12_hcm   (gemA_vfat_hcm[12]), // In GEM Hot channel mask
  //.gemA_vfat13_hcm   (gemA_vfat_hcm[13]), // In GEM Hot channel mask
  //.gemA_vfat14_hcm   (gemA_vfat_hcm[14]), // In GEM Hot channel mask
  //.gemA_vfat15_hcm   (gemA_vfat_hcm[15]), // In GEM Hot channel mask
  //.gemA_vfat16_hcm   (gemA_vfat_hcm[16]), // In GEM Hot channel mask
  //.gemA_vfat17_hcm   (gemA_vfat_hcm[17]), // In GEM Hot channel mask
  //.gemA_vfat18_hcm   (gemA_vfat_hcm[18]), // In GEM Hot channel mask
  //.gemA_vfat19_hcm   (gemA_vfat_hcm[19]), // In GEM Hot channel mask
  //.gemA_vfat20_hcm   (gemA_vfat_hcm[20]), // In GEM Hot channel mask
  //.gemA_vfat21_hcm   (gemA_vfat_hcm[21]), // In GEM Hot channel mask
  //.gemA_vfat22_hcm   (gemA_vfat_hcm[22]), // In GEM Hot channel mask
  //.gemA_vfat23_hcm   (gemA_vfat_hcm[23]), // In GEM Hot channel mask
  //.gemB_vfat0_hcm    (gemB_vfat_hcm[ 0]), // In GEM Hot channel mask
  //.gemB_vfat1_hcm    (gemB_vfat_hcm[ 1]), // In GEM Hot channel mask
  //.gemB_vfat2_hcm    (gemB_vfat_hcm[ 2]), // In GEM Hot channel mask
  //.gemB_vfat3_hcm    (gemB_vfat_hcm[ 3]), // In GEM Hot channel mask
  //.gemB_vfat4_hcm    (gemB_vfat_hcm[ 4]), // In GEM Hot channel mask
  //.gemB_vfat5_hcm    (gemB_vfat_hcm[ 5]), // In GEM Hot channel mask
  //.gemB_vfat6_hcm    (gemB_vfat_hcm[ 6]), // In GEM Hot channel mask
  //.gemB_vfat7_hcm    (gemB_vfat_hcm[ 7]), // In GEM Hot channel mask
  //.gemB_vfat8_hcm    (gemB_vfat_hcm[ 8]), // In GEM Hot channel mask
  //.gemB_vfat9_hcm    (gemB_vfat_hcm[ 9]), // In GEM Hot channel mask
  //.gemB_vfat10_hcm   (gemB_vfat_hcm[10]), // In GEM Hot channel mask
  //.gemB_vfat11_hcm   (gemB_vfat_hcm[11]), // In GEM Hot channel mask
  //.gemB_vfat12_hcm   (gemB_vfat_hcm[12]), // In GEM Hot channel mask
  //.gemB_vfat13_hcm   (gemB_vfat_hcm[13]), // In GEM Hot channel mask
  //.gemB_vfat14_hcm   (gemB_vfat_hcm[14]), // In GEM Hot channel mask
  //.gemB_vfat15_hcm   (gemB_vfat_hcm[15]), // In GEM Hot channel mask
  //.gemB_vfat16_hcm   (gemB_vfat_hcm[16]), // In GEM Hot channel mask
  //.gemB_vfat17_hcm   (gemB_vfat_hcm[17]), // In GEM Hot channel mask
  //.gemB_vfat18_hcm   (gemB_vfat_hcm[18]), // In GEM Hot channel mask
  //.gemB_vfat19_hcm   (gemB_vfat_hcm[19]), // In GEM Hot channel mask
  //.gemB_vfat20_hcm   (gemB_vfat_hcm[20]), // In GEM Hot channel mask
  //.gemB_vfat21_hcm   (gemB_vfat_hcm[21]), // In GEM Hot channel mask
  //.gemB_vfat22_hcm   (gemB_vfat_hcm[22]), // In GEM Hot channel mask
  //.gemB_vfat23_hcm   (gemB_vfat_hcm[23]), // In GEM Hot channel mask

  // GEM Cluster Outputs
  .cluster0 (gem_cluster0[igem]), // Out GEM Cluster
  .cluster1 (gem_cluster1[igem]), // Out GEM Cluster
  .cluster2 (gem_cluster2[igem]), // Out GEM Cluster
  .cluster3 (gem_cluster3[igem]), // Out GEM Cluster
  //VFAT number
  //.cluster0_feb (gem_cluster0_feb[igem]),//Out GEM vfat
  //.cluster1_feb (gem_cluster1_feb[igem]),//Out GEM vfat
  //.cluster2_feb (gem_cluster2_feb[igem]),
  //.cluster3_feb (gem_cluster3_feb[igem]),

  .cluster0_roll (gem_cluster0_roll[igem]),//Out eta partition number 
  .cluster1_roll (gem_cluster1_roll[igem]),
  .cluster2_roll (gem_cluster2_roll[igem]),
  .cluster3_roll (gem_cluster3_roll[igem]),

  .cluster0_pad (gem_cluster0_pad[igem]), //Out pad number in one roll, no VFAT boundary
  .cluster1_pad (gem_cluster1_pad[igem]),
  .cluster2_pad (gem_cluster2_pad[igem]),
  .cluster3_pad (gem_cluster3_pad[igem]),

  // GEM Valid Data Output Flags
  .vpf0 (gem_vpf0[igem]), // Out GEM valid data
  .vpf1 (gem_vpf1[igem]), // Out GEM valid data
  .vpf2 (gem_vpf2[igem]), // Out GEM valid data
  .vpf3 (gem_vpf3[igem]), // Out GEM valid data

  .active_feb_list(gem_active_feb_list[igem][23:0])
  );
  end
  endgenerate // end GEM

  //--------------------------------------------------------------------------------------------------------------------
  // GEM Fiber Synchronization Monitoring
  //--------------------------------------------------------------------------------------------------------------------

  gem_sync_mon u_gem_sync_mon (

    .clock(clock),              // 40 MHz Fabric Clock
    .clk_lock(lock_tmb_clock0), // 40 MHz MMCM Locked

    .global_reset (global_reset  ), // In  Global reset
    .ttc_resync   (ttc_resync    ), // In  TTC resync

    .gemA_overflow (gemA_overflow),
    .gemB_overflow (gemB_overflow),

    .gemA_bc0marker (gemA_bc0marker),
    .gemB_bc0marker (gemB_bc0marker),

    .gemA_resyncmarker (gemA_resyncmarker),
    .gemB_resyncmarker (gemB_resyncmarker),

    .gemA_sync_done (gemA_sync_done),
    .gemB_sync_done (gemB_sync_done),

    .gemA_rxd_int_delay (gemA_rxd_int_delay[3:0]), // in  Interstage delay
    .gemB_rxd_int_delay (gemB_rxd_int_delay[3:0]), // in  Interstage delay

    .gem_fiber_enable (gem_fiber_enable [MXGEM-1:0]),
    .link_good        (gem_link_good    [MXGEM-1:0]),

    .gem0_kchar(gem_kchar[0]), // In  Copy of GEM0 k-char
    .gem1_kchar(gem_kchar[1]), // In  Copy of GEM1 k-char
    .gem2_kchar(gem_kchar[2]), // In  Copy of GEM2 k-char
    .gem3_kchar(gem_kchar[3]), // In  Copy of GEM3 k-char

    .gemA_synced(gemA_synced),  // Out fibers from same OH are synced
    .gemB_synced(gemB_synced),  // Out fibers from same OH are synced

    .gems_synced(gems_synced),  // Out fibers from both GEM chambers are synched

    // latched copies that gems have lost sync in past
    .gemA_lostsync(gemA_lostsync), // Out
    .gemB_lostsync(gemB_lostsync), // Out
    .gems_lostsync(gems_lostsync)  // Out
  );

  reg gemA_overflow_ff = 1'b0;
  reg gemB_overflow_ff = 1'b0;
  //align with gemA_synced, gemB_synced, gems_synced
  always @ (posedge clock) begin
      gemA_overflow_ff <= gemA_overflow;
      gemB_overflow_ff <= gemB_overflow;
  end


  //--------------------------------------------------------------------------------------------------------------------
  // GEM Co-pad Matching
  // Assume Comparator hits and GEM hits arrived at OTMB at same BX
  // GEM copad vpf and GEM cluster after coordination conversion is at same BX, 1Bx after GEM cluster from receiver 
  // then CLCT is ~10BX later then GEM copad VPF
  //--------------------------------------------------------------------------------------------------------------------
  wire [7:0]  copad_match;
  wire [7:0]  gem_match_upper;
  wire [7:0]  gem_match_lower;
  wire        gem_any_match;//any copad
  wire [23:0] gemcopad_active_feb_list;
  reg  [CLSTBITS -1 :0] gem_copad_reg  [MXCLUSTER_CHAMBER-1:0];
  wire [CLSTBITS -1 :0] gem_copad      [MXCLUSTER_CHAMBER-1:0];
  wire [MXCLUSTER_CHAMBER-1:0] copad_A_B [MXCLUSTER_CHAMBER-1:0];
  reg  gem_any_copad_ff;

  wire [3:0] gem_match_deltaPad;

  copad u_copad (

    .clock(clock),

    // control whether to match on neighboring (+-1) clusters
    .match_neighborRoll(gem_match_neighborRoll),
    .match_neighborPad(gem_match_neighborPad),
    .match_deltaPad(gem_match_deltaPad),

    // gem chamber 0 clusters
    .gemA_cluster0_vpf (gemA_vpf[0]),
    .gemA_cluster1_vpf (gemA_vpf[1]),
    .gemA_cluster2_vpf (gemA_vpf[2]),
    .gemA_cluster3_vpf (gemA_vpf[3]),
    .gemA_cluster4_vpf (gemA_vpf[4]),
    .gemA_cluster5_vpf (gemA_vpf[5]),
    .gemA_cluster6_vpf (gemA_vpf[6]),
    .gemA_cluster7_vpf (gemA_vpf[7]),

    .gemA_cluster0_roll(gemA_cluster_roll[0]),
    .gemA_cluster1_roll(gemA_cluster_roll[1]),
    .gemA_cluster2_roll(gemA_cluster_roll[2]),
    .gemA_cluster3_roll(gemA_cluster_roll[3]),
    .gemA_cluster4_roll(gemA_cluster_roll[4]),
    .gemA_cluster5_roll(gemA_cluster_roll[5]),
    .gemA_cluster6_roll(gemA_cluster_roll[6]),
    .gemA_cluster7_roll(gemA_cluster_roll[7]),

    .gemA_cluster0_pad (gemA_cluster_pad[0]),
    .gemA_cluster1_pad (gemA_cluster_pad[1]),
    .gemA_cluster2_pad (gemA_cluster_pad[2]),
    .gemA_cluster3_pad (gemA_cluster_pad[3]),
    .gemA_cluster4_pad (gemA_cluster_pad[4]),
    .gemA_cluster5_pad (gemA_cluster_pad[5]),
    .gemA_cluster6_pad (gemA_cluster_pad[6]),
    .gemA_cluster7_pad (gemA_cluster_pad[7]),

    .gemA_cluster0_cnt (gemA_cluster[0][13:11]),
    .gemA_cluster1_cnt (gemA_cluster[1][13:11]),
    .gemA_cluster2_cnt (gemA_cluster[2][13:11]),
    .gemA_cluster3_cnt (gemA_cluster[3][13:11]),
    .gemA_cluster4_cnt (gemA_cluster[4][13:11]),
    .gemA_cluster5_cnt (gemA_cluster[5][13:11]),
    .gemA_cluster6_cnt (gemA_cluster[6][13:11]),
    .gemA_cluster7_cnt (gemA_cluster[7][13:11]),

    // gem chamber 1 clusters
    .gemB_cluster0_vpf (gemB_vpf[0]),
    .gemB_cluster1_vpf (gemB_vpf[1]),
    .gemB_cluster2_vpf (gemB_vpf[2]),
    .gemB_cluster3_vpf (gemB_vpf[3]),
    .gemB_cluster4_vpf (gemB_vpf[4]),
    .gemB_cluster5_vpf (gemB_vpf[5]),
    .gemB_cluster6_vpf (gemB_vpf[6]),
    .gemB_cluster7_vpf (gemB_vpf[7]),

    .gemB_cluster0_roll(gemB_cluster_roll[0]),
    .gemB_cluster1_roll(gemB_cluster_roll[1]),
    .gemB_cluster2_roll(gemB_cluster_roll[2]),
    .gemB_cluster3_roll(gemB_cluster_roll[3]),
    .gemB_cluster4_roll(gemB_cluster_roll[4]),
    .gemB_cluster5_roll(gemB_cluster_roll[5]),
    .gemB_cluster6_roll(gemB_cluster_roll[6]),
    .gemB_cluster7_roll(gemB_cluster_roll[7]),

    .gemB_cluster0_pad (gemB_cluster_pad[0]),
    .gemB_cluster1_pad (gemB_cluster_pad[1]),
    .gemB_cluster2_pad (gemB_cluster_pad[2]),
    .gemB_cluster3_pad (gemB_cluster_pad[3]),
    .gemB_cluster4_pad (gemB_cluster_pad[4]),
    .gemB_cluster5_pad (gemB_cluster_pad[5]),
    .gemB_cluster6_pad (gemB_cluster_pad[6]),
    .gemB_cluster7_pad (gemB_cluster_pad[7]),

    .gemB_cluster0_cnt (gemB_cluster[0][13:11]),
    .gemB_cluster1_cnt (gemB_cluster[1][13:11]),
    .gemB_cluster2_cnt (gemB_cluster[2][13:11]),
    .gemB_cluster3_cnt (gemB_cluster[3][13:11]),
    .gemB_cluster4_cnt (gemB_cluster[4][13:11]),
    .gemB_cluster5_cnt (gemB_cluster[5][13:11]),
    .gemB_cluster6_cnt (gemB_cluster[6][13:11]),
    .gemB_cluster7_cnt (gemB_cluster[7][13:11]),


    // 8 bit match flags
    .match(copad_match[7:0]),

    // 8 bit cluster match was found on upper/lower roll 
    .match_upper (gem_match_upper[7:0]),
    .match_lower (gem_match_lower[7:0]),

    // copad match matrix. copad_A_B[0][0] means whether cluster0 from gemA matches with cluster0 from gem B or not
    .copad_A0_B   (copad_A_B[0][MXCLUSTER_CHAMBER-1:0]),
    .copad_A1_B   (copad_A_B[1][MXCLUSTER_CHAMBER-1:0]),
    .copad_A2_B   (copad_A_B[2][MXCLUSTER_CHAMBER-1:0]),
    .copad_A3_B   (copad_A_B[3][MXCLUSTER_CHAMBER-1:0]),
    .copad_A4_B   (copad_A_B[4][MXCLUSTER_CHAMBER-1:0]),
    .copad_A5_B   (copad_A_B[5][MXCLUSTER_CHAMBER-1:0]),
    .copad_A6_B   (copad_A_B[6][MXCLUSTER_CHAMBER-1:0]),
    .copad_A7_B   (copad_A_B[7][MXCLUSTER_CHAMBER-1:0]),

    // 1 bit any match found
    .any_match(gem_any_match),
    

    // 24 bit active feb list
    //.active_feb_list_copad(gemcopad_active_feb_list[23:0]),

    .sump(copad_module_sump)
  );

  //simple way to find copad vfat
  assign gemcopad_active_feb_list = (gemA_active_feb_list & gemB_active_feb_list);


always @ (posedge clock) begin

  // ff copy the clusters from gemA to delay 1bx to lineup with copad output
  gem_copad_reg[0] <=  gemA_cluster[0];
  gem_copad_reg[1] <=  gemA_cluster[1];
  gem_copad_reg[2] <=  gemA_cluster[2];
  gem_copad_reg[3] <=  gemA_cluster[3];
  gem_copad_reg[4] <=  gemA_cluster[4];
  gem_copad_reg[5] <=  gemA_cluster[5];
  gem_copad_reg[6] <=  gemA_cluster[6];
  gem_copad_reg[7] <=  gemA_cluster[7];
  gem_any_copad_ff <=  gem_any;
end

  assign gem_copad[0] = copad_match[0] ? gem_copad_reg[0] : {3'd0,11'd255};
  assign gem_copad[1] = copad_match[1] ? gem_copad_reg[1] : {3'd0,11'd255};
  assign gem_copad[2] = copad_match[2] ? gem_copad_reg[2] : {3'd0,11'd255};
  assign gem_copad[3] = copad_match[3] ? gem_copad_reg[3] : {3'd0,11'd255};
  assign gem_copad[4] = copad_match[4] ? gem_copad_reg[4] : {3'd0,11'd255};
  assign gem_copad[5] = copad_match[5] ? gem_copad_reg[5] : {3'd0,11'd255};
  assign gem_copad[6] = copad_match[6] ? gem_copad_reg[6] : {3'd0,11'd255};
  assign gem_copad[7] = copad_match[7] ? gem_copad_reg[7] : {3'd0,11'd255};


  wire copad_sump =
      copad_module_sump

  | (|gem_copad[0])
  | (|gem_copad[1])
  | (|gem_copad[2])
  | (|gem_copad[3])
  | (|gem_copad[4])
  | (|gem_copad[5])
  | (|gem_copad[6])
  | (|gem_copad[7])

  | gemA_lostsync
  | gemB_lostsync
  | gems_lostsync

  | (|gem_match_upper) 
  | (|gem_match_lower);


  //Latch GEM clusters into VME register
  reg [CLSTBITS-1:0] gemA_cluster_vme [MXCLUSTER_CHAMBER-1:0];
  reg [CLSTBITS-1:0] gemB_cluster_vme [MXCLUSTER_CHAMBER-1:0];
  reg gemA_overflow_vme = 0;
  reg gemB_overflow_vme = 0;
  reg gemA_sync_vme     = 0;
  reg gemB_sync_vme     = 0;
  reg [CLSTBITS-1 :0] gem_copad_vme  [MXCLUSTER_CHAMBER-1:0];
  reg gems_sync_vme     = 0;

  //wire clear_gem_vme = event_clear_vme | clct_pretrig;
  wire clear_gem_vme = event_clear_vme;

  genvar icluster;
  generate
  for (icluster=0; icluster<MXCLUSTER_CHAMBER; icluster=icluster+1) begin: gen_gem_cluster
      initial begin
          gemA_cluster_vme[icluster]  <= {3'b0, 11'd255};//invalid GEM cluster
          gemB_cluster_vme[icluster]  <= {3'b0, 11'd255};
          gem_copad_vme[icluster]     <= {3'b0, 11'd255};
      end

      always @(posedge clock) begin
        if (clear_gem_vme) begin    // Clear clcts in case event gets flushed
          gemA_cluster_vme[icluster]  <= {3'b0, 11'd255};//invalid GEM cluster
          gemB_cluster_vme[icluster]  <= {3'b0, 11'd255};
          gem_copad_vme[icluster]     <= {3'b0, 11'd255};
        end
        else begin
            if (gem_any) begin
                gemA_cluster_vme[icluster]  <= gemA_vpf[icluster] ? gemA_cluster[icluster] : {3'b0, 11'd255}; 
                gemB_cluster_vme[icluster]  <= gemB_vpf[icluster] ? gemB_cluster[icluster] : {3'b0, 11'd255}; 
            end
            if (gem_any_copad_ff) begin
                gem_copad_vme[icluster]     <= gem_copad[icluster];
            end
        end
      end
  end
  endgenerate

  always @(posedge clock) begin
    if (clear_gem_vme) begin    // Clear clcts in case event gets flushed
      gemA_overflow_vme <= 0;
      gemB_overflow_vme <= 0;
      gemA_sync_vme     <= 0;
      gemB_sync_vme     <= 0;
      gems_sync_vme     <= 0;
    end
    else begin
        gemA_overflow_vme           <= gemA_overflow;
        gemA_sync_vme               <= gemA_synced;
        gemB_overflow_vme           <= gemB_overflow;
        gemB_sync_vme               <= gemB_synced;
        gems_sync_vme               <= gems_synced;
    end
  end

  //GEM clusters for GEM-CSC mathcing 
  wire [CLSTBITS-1:0] gemA_csc_cluster  [MXCLUSTER_CHAMBER-1:0];
  wire [CLSTBITS-1:0] gemB_csc_cluster  [MXCLUSTER_CHAMBER-1:0];
  //wire [2:0] gemA_csc_cluster_roll      [MXCLUSTER_CHAMBER-1:0];
  //wire [2:0] gemB_csc_cluster_roll      [MXCLUSTER_CHAMBER-1:0];
  //wire [7:0] gemA_csc_cluster_pad       [MXCLUSTER_CHAMBER-1:0];
  //wire [7:0] gemB_csc_cluster_pad       [MXCLUSTER_CHAMBER-1:0];
  //wire [2:0] gemA_csc_cluster_size      [MXCLUSTER_CHAMBER-1:0];
  //wire [2:0] gemB_csc_cluster_size      [MXCLUSTER_CHAMBER-1:0];
  wire [MXCLUSTER_CHAMBER-1:0]      gemA_csc_cluster_vpf;
  wire [MXCLUSTER_CHAMBER-1:0]      gemB_csc_cluster_vpf;

  wire [MXCLUSTER_CHAMBER-1:0]      gemA_csc_cluster_me1a;
  wire [MXCLUSTER_CHAMBER-1:0]      gemB_csc_cluster_me1a;

  wire gemA_anycluster_me1a = |(gemA_csc_cluster_me1a & gemA_csc_cluster_vpf);
  wire gemB_anycluster_me1a = |(gemB_csc_cluster_me1a & gemB_csc_cluster_vpf);
  wire gemA_anycluster_me1b = |(~gemA_csc_cluster_me1a & gemA_csc_cluster_vpf);
  wire gemB_anycluster_me1b = |(~gemB_csc_cluster_me1a & gemB_csc_cluster_vpf);

  wire [WIREBITS-1:0] gemA_csc_cluster_cscwire_lo[MXCLUSTER_CHAMBER-1:0];
  wire [WIREBITS-1:0] gemB_csc_cluster_cscwire_lo[MXCLUSTER_CHAMBER-1:0];
  wire [WIREBITS-1:0] gemA_csc_cluster_cscwire_hi[MXCLUSTER_CHAMBER-1:0];
  wire [WIREBITS-1:0] gemB_csc_cluster_cscwire_hi[MXCLUSTER_CHAMBER-1:0];
  wire [WIREBITS-1:0] gemA_csc_cluster_cscwire_mi[MXCLUSTER_CHAMBER-1:0];
  wire [WIREBITS-1:0] gemB_csc_cluster_cscwire_mi[MXCLUSTER_CHAMBER-1:0];
  //Tao, updated to CCLUT algorithm!!!, use 10 bits
  //wire [MXXKYB-1:0] gemA_csc_cluster_me1bxky_lo [MXCLUSTER_CHAMBER-1:0]; // ME1b keyHS from 0-127
  //wire [MXXKYB-1:0] gemB_csc_cluster_me1bxky_lo [MXCLUSTER_CHAMBER-1:0]; // ME1a keyHS from 128-223
  //wire [MXXKYB-1:0] gemA_csc_cluster_me1bxky_hi [MXCLUSTER_CHAMBER-1:0]; // 
  //wire [MXXKYB-1:0] gemB_csc_cluster_me1bxky_hi [MXCLUSTER_CHAMBER-1:0]; // 
  //wire [MXXKYB-1:0] gemA_csc_cluster_me1bxky_mi [MXCLUSTER_CHAMBER-1:0]; // 
  //wire [MXXKYB-1:0] gemB_csc_cluster_me1bxky_mi [MXCLUSTER_CHAMBER-1:0]; // 
  //wire [MXXKYB-1:0] gemA_csc_cluster_me1axky_lo [MXCLUSTER_CHAMBER-1:0]; // 
  //wire [MXXKYB-1:0] gemB_csc_cluster_me1axky_lo [MXCLUSTER_CHAMBER-1:0]; // 
  //wire [MXXKYB-1:0] gemA_csc_cluster_me1axky_hi [MXCLUSTER_CHAMBER-1:0]; // 
  //wire [MXXKYB-1:0] gemB_csc_cluster_me1axky_hi [MXCLUSTER_CHAMBER-1:0]; // 
  //wire [MXXKYB-1:0] gemA_csc_cluster_me1axky_mi [MXCLUSTER_CHAMBER-1:0]; // 
  //wire [MXXKYB-1:0] gemB_csc_cluster_me1axky_mi [MXCLUSTER_CHAMBER-1:0]; // 

  wire [MXXKYB-1:0] gemA_csc_cluster_xky_lo [MXCLUSTER_CHAMBER-1:0]; // 
  wire [MXXKYB-1:0] gemB_csc_cluster_xky_lo [MXCLUSTER_CHAMBER-1:0]; // 
  wire [MXXKYB-1:0] gemA_csc_cluster_xky_hi [MXCLUSTER_CHAMBER-1:0]; // 
  wire [MXXKYB-1:0] gemB_csc_cluster_xky_hi [MXCLUSTER_CHAMBER-1:0]; // 
  wire [MXXKYB-1:0] gemA_csc_cluster_xky_mi [MXCLUSTER_CHAMBER-1:0]; // 
  wire [MXXKYB-1:0] gemB_csc_cluster_xky_mi [MXCLUSTER_CHAMBER-1:0]; // 
  wire [MXXKYB-1:0] gemA_csc_cluster_xky_win [MXCLUSTER_CHAMBER-1:0]; // 
  wire [MXXKYB-1:0] gemB_csc_cluster_xky_win [MXCLUSTER_CHAMBER-1:0]; // 

  wire [MXCLUSTER_CHAMBER-1:0] gemA_gemtocsc_dummy;
  wire [MXCLUSTER_CHAMBER-1:0] gemB_gemtocsc_dummy;


  //wire [MXCFEB-1:0] gemA_csc_cluster_active_cfeb_list; //dummy signal!!
  //wire [MXCFEB-1:0] gemB_csc_cluster_active_cfeb_list;
  //wire [MXCFEB-1:0] gemcopad_csc_cluster_active_cfeb_list;
  //assign gemcopad_csc_cluster_active_cfeb_list = (gemA_csc_cluster_active_cfeb_list & gemB_csc_cluster_active_cfeb_list);

  genvar iclst_csc;
  generate
  for (iclst_csc=0; iclst_csc<MXCLUSTER_CHAMBER; iclst_csc=iclst_csc+1) begin: gen_gem_csc_cluster
      cluster_to_cscwirehalfstrip_rom #(.ICLST(iclst_csc)) ucluster_to_cscwirehalfstripA (
	.clock (clock),    //in clock

        .evenchamber       (evenchamber),   //in,  even pair or not
        //.gem_match_enable  (gemA_cluster_enable[iclst_csc]),//In enable GEMA for GEMCSC match or not, if not, vpf is invalid from here
        .gem_clct_deltahs  (gem_clct_deltahs), // In matching window in halfstrip direction
        .gem_alct_deltawire(gem_alct_deltawire), //In  matching window in wiregroup direction

        .gem_me1a_match_enable     (gem_me1a_match_enable),       //in gem-csc match in me1a
        .gem_me1b_match_enable     (gem_me1b_match_enable),       //in gem-csc match in me1b

        .cluster0      (gemA_cluster[iclst_csc]),//In gem cluster
        .cluster0_vpf  (gemA_vpf[iclst_csc]),// In, cluster valid or not
        .cluster0_roll (~gemA_cluster_roll[iclst_csc]), //In clsuter roll,  0-7; roll0 is in eta partition8, narrow end of GEM chamber
        .cluster0_pad  (gemA_cluster_pad[iclst_csc]), // In pad in a roll, from 0-191
        .cluster0_size (gemA_cluster[iclst_csc][13:11]), //In gem cluster size  from 0-7, 0 means 1 gem pad

        .cluster0_cscwire_lo (gemA_csc_cluster_cscwire_lo[iclst_csc]), //Out gem roll into wire, low
        .cluster0_cscwire_hi (gemA_csc_cluster_cscwire_hi[iclst_csc]), //Out gem roll into wire, high
        .cluster0_cscwire_mi (gemA_csc_cluster_cscwire_mi[iclst_csc]), // Out gem roll into wire, median
        .cluster0_cscxky_lo  (gemA_csc_cluster_xky_lo[iclst_csc]), // Out, gem pad into me1b hs, from 0-127
        .cluster0_cscxky_hi  (gemA_csc_cluster_xky_hi[iclst_csc]), // Out, gem pad into me1b hs from 0-127
        .cluster0_cscxky_mi  (gemA_csc_cluster_xky_mi[iclst_csc]), // Out, gem pad into me1b hs from 0-127
        .cluster0_cscxky_win (gemA_csc_cluster_xky_win[iclst_csc]), // Out, gem pad into me1b hs from 0-127
        .csc_cluster0_me1a   (gemA_csc_cluster_me1a[iclst_csc]),  //Out gem cluster in me1a or not

        .csc_cluster0      (gemA_csc_cluster[iclst_csc]),  // Out, aligned gem cluster 
        .csc_cluster0_vpf  (gemA_csc_cluster_vpf[iclst_csc]),// Out, valid or not
        //.csc_cluster0_roll (gemA_csc_cluster_roll[iclst_csc]), // Out, 0-7 
        //.csc_cluster0_pad  (gemA_csc_cluster_pad[iclst_csc]), // Out from 0-191
        //.csc_cluster0_size (gemA_csc_cluster_size[iclst_csc]), // Out from 0-7, 0 means 1 gem pad
        .cluster_to_cscdummy (gemA_gemtocsc_dummy[iclst_csc])

      );

      cluster_to_cscwirehalfstrip_rom #(.ICLST(iclst_csc)) ucluster_to_cscwirehalfstripB (
	.clock (clock),

        .evenchamber       (evenchamber),   // even pair or not
        //.gem_match_enable  (gemB_cluster_enable[iclst_csc]),
        .gem_clct_deltahs  (gem_clct_deltahs), // matching window in halfstrip direction
        .gem_alct_deltawire(gem_alct_deltawire), // matching window in wiregroup direction

        .gem_me1a_match_enable     (gem_me1a_match_enable),       //in gem-csc match in me1a
        .gem_me1b_match_enable     (gem_me1b_match_enable),       //in gem-csc match in me1b

        .cluster0      (gemB_cluster[iclst_csc]),
        .cluster0_vpf  (gemB_vpf[iclst_csc]),// valid or not
        .cluster0_roll (~gemB_cluster_roll[iclst_csc]), // 0-7 
        .cluster0_pad  (gemB_cluster_pad[iclst_csc]), // from 0-191
        .cluster0_size (gemB_cluster[iclst_csc][13:11]), // from 0-7, 0 means 1 gem pad

        .cluster0_cscwire_lo (gemB_csc_cluster_cscwire_lo[iclst_csc]),
        .cluster0_cscwire_hi (gemB_csc_cluster_cscwire_hi[iclst_csc]),
        .cluster0_cscwire_mi (gemB_csc_cluster_cscwire_mi[iclst_csc]),
        .cluster0_cscxky_lo  (gemB_csc_cluster_xky_lo[iclst_csc]), // from 0-127
        .cluster0_cscxky_hi  (gemB_csc_cluster_xky_hi[iclst_csc]), // from 0-127
        .cluster0_cscxky_mi  (gemB_csc_cluster_xky_mi[iclst_csc]), // from 0-127
        .cluster0_cscxky_win (gemB_csc_cluster_xky_win[iclst_csc]), // Out, gem pad into me1b hs from 0-127
        .csc_cluster0_me1a   (gemB_csc_cluster_me1a[iclst_csc]),

        .csc_cluster0      (gemB_csc_cluster[iclst_csc]),  
        .csc_cluster0_vpf  (gemB_csc_cluster_vpf[iclst_csc]),// valid or not
        //.csc_cluster0_roll (gemB_csc_cluster_roll[iclst_csc]), // 0-7 
        //.csc_cluster0_pad  (gemB_csc_cluster_pad[iclst_csc]), // from 0-191
        //.csc_cluster0_size (gemB_csc_cluster_size[iclst_csc]), // from 0-7, 0 means 1 gem pad
        .cluster_to_cscdummy (gemB_gemtocsc_dummy[iclst_csc])

      );

  end
  endgenerate

   wire gemtocsc_sump = (|gemA_gemtocsc_dummy) | (|gemB_gemtocsc_dummy) ;
    //-------------------------------------------------------------------------------------------------------------------
    // bidirection timing scan to find best delay value
    // Delay ALCT signal to find ALCT-GEM match
    // Delay GEM signal to find ALCT-GEM match
    //-------------------------------------------------------------------------------------------------------------------

      reg [7:0] alct_delay_forgem;
      always @(posedge clock)begin
       alct_delay_forgem = match_gem_alct_delay - 8'b1;
      end
      wire alct_vpf_forgem_srl;

      srl16e_bit #(8, 256) usrlbitalct (.clock(clock),.adr(alct_delay_forgem),.d(alct0_tmb[0]),.q(alct_vpf_forgem_srl));

      wire alct_vpf_forgem = (alct_delay_forgem == 8'b0) ? alct0_tmb[0] : alct_vpf_forgem_srl;

      wire delayalct_gemA_match_test = alct_vpf_forgem && (|gemA_csc_cluster_vpf);
      wire delayalct_gemB_match_test = alct_vpf_forgem && (|gemB_csc_cluster_vpf);

      wire gemA_vpf_test_srl, gemB_vpf_test_srl;
      srl16e_bit #(8, 256) usrlbitgema (.clock(clock),.adr(alct_delay_forgem),.d( |gemA_csc_cluster_vpf ),.q(gemA_vpf_test_srl));
      srl16e_bit #(8, 256) usrlbitgemb (.clock(clock),.adr(alct_delay_forgem),.d( |gemB_csc_cluster_vpf ),.q(gemB_vpf_test_srl));

      wire gemA_vpf_foralct = (alct_delay_forgem == 8'b0) ? (|gemA_csc_cluster_vpf) : gemA_vpf_test_srl;
      wire gemB_vpf_foralct = (alct_delay_forgem == 8'b0) ? (|gemB_csc_cluster_vpf) : gemB_vpf_test_srl;

      wire alct_delaygemA_match_test = gemA_vpf_foralct && alct0_tmb[0];
      wire alct_delaygemB_match_test = gemB_vpf_foralct && alct0_tmb[0];
    //-------------------------------------------------------------------------------------------------------------------
    // End of Delay ALCT signal to find ALCT-GEM match
    //-------------------------------------------------------------------------------------------------------------------


//-------------------------------------------------------------------------------------------------------------------
// Pattern Finder declarations, common to ME1A+ME1B+ME234
//-------------------------------------------------------------------------------------------------------------------
// Pre-Trigger Ports
  wire  [3:0]          csc_type;     // Firmware compile type;
  wire  [MXCFEB-1:0]   cfeb_en;      // Enables CFEBs for triggering and active feb flag
  wire  [MXKEYB-1+1:0] adjcfeb_dist; // Distance from key to cfeb boundary for marking adjacent cfeb as hit

  wire  [2:0] lyr_thresh_pretrig;
  wire  [2:0] hit_thresh_pretrig;
  wire  [3:0] pid_thresh_pretrig;
  wire  [2:0] dmb_thresh_pretrig;

// 2nd CLCT separation RAM Ports
  wire         clct_sep_src;       // CLCT separation source 1=vme, 0=ram
  wire  [7:0]  clct_sep_vme;       // CLCT separation from vme
  wire         clct_sep_ram_we;    // CLCT separation RAM write enable
  wire  [3:0]  clct_sep_ram_adr;   // CLCT separation RAM rw address VME
  wire  [15:0] clct_sep_ram_wdata; // CLCT separation RAM write data VME
  wire  [15:0] clct_sep_ram_rdata; // CLCT separation RAM read  data VME

//-------------------------------------------------------------------------------------------------------------------
// Pattern Finder instantiation
//-------------------------------------------------------------------------------------------------------------------
  wire  [MXCFEB-1:0]  cfeb_hit;         // This CFEB has a pattern over pre-trigger threshold
  wire  [MXCFEB-1:0]  cfeb_active;      // CFEBs marked for DMB readout
  wire  [MXLY-1:0]    cfeb_layer_or;    // OR of hstrips on each layer
  wire  [MXHITB-1:0]  cfeb_nlayers_hit; // Number of CSC layers hit

  wire  [MXHITB-1:0]  hs_hit_1st;
  wire  [MXPIDB-1:0]  hs_pid_1st;
  wire  [MXKEYBX-1:0] hs_key_1st;

  // 1st pattern lookup results, ccLUT,Tao
  wire [MXBNDB - 1   : 0] hs_bnd_1st; // new bending 
  wire [MXXKYB-1     : 0] hs_xky_1st; // new position with 1/8 precision
  wire [MXPATC-1     : 0] hs_carry_1st; // CC code 
  wire [MXPIDB - 1: 0]  hs_run2pid_1st; // 1st CLCT pattern ID
  wire [MXXKYB-1     : 0] hs_gemAxky_1st; // new position with 1/8 precision
  wire [MXXKYB-1     : 0] hs_gemBxky_1st; // new position with 1/8 precision

  wire  [MXHITB-1:0]  hs_hit_2nd;
  wire  [MXPIDB-1:0]  hs_pid_2nd;
  wire  [MXKEYBX-1:0] hs_key_2nd;
  wire                hs_bsy_2nd;

  // 2nd pattern lookup results, ccLUT,Tao
  wire [MXBNDB - 1   : 0] hs_bnd_2nd; // new bending 
  wire [MXXKYB-1     : 0] hs_xky_2nd; // new position with 1/8 precision
  wire [MXPATC-1     : 0] hs_carry_2nd; // CC code 
  wire [MXPIDB - 1: 0]  hs_run2pid_2nd; // 1st CLCT pattern ID
  wire [MXXKYB-1     : 0] hs_gemAxky_2nd; // new position with 1/8 precision
  wire [MXXKYB-1     : 0] hs_gemBxky_2nd; // new position with 1/8 precision

  reg reg_ccLUT_enable;
  //enable CCLUT, Tao
  `ifdef CCLUT
  initial reg_ccLUT_enable = 1'b1;
  `else
  initial reg_ccLUT_enable = 1'b0;
  `endif

   wire ccLUT_enable;
   assign ccLUT_enable = reg_ccLUT_enable;

   wire run3_trig_df; // Run3 trigger data format
   wire run3_daq_df;// Run3 daq data format
   wire run3_alct_df;// Run3 ALCT data format

  //CCLUT is off
  `ifndef CCLUT
   assign hs_bnd_1st[MXBNDB - 1   : 0] = hs_pid_1st;
   assign hs_xky_1st[MXXKYB - 1   : 0] = {hs_key_1st, 2'b10};
   assign hs_gemAxky_1st[MXXKYB - 1   : 0] = {hs_key_1st, 2'b10};
   assign hs_gemBxky_1st[MXXKYB - 1   : 0] = {hs_key_1st, 2'b10};
   assign hs_carry_1st[MXPATC - 1 : 0] = 0;
   assign hs_bnd_2nd[MXBNDB - 1   : 0] = hs_pid_2nd;
   assign hs_xky_2nd[MXXKYB - 1   : 0] = {hs_key_2nd, 2'b10};
   assign hs_gemAxky_2nd[MXXKYB - 1   : 0] = {hs_key_2nd, 2'b10};
   assign hs_gemBxky_2nd[MXXKYB - 1   : 0] = {hs_key_2nd, 2'b10};
   assign hs_carry_2nd[MXPATC - 1 : 0] = 0;
   assign hs_run2pid_1st[MXPIDB-1:0]   = hs_pid_1st;
   assign hs_run2pid_2nd[MXPIDB-1:0]   = hs_pid_2nd;
  `endif

  wire                hs_layer_trig;  // Layer triggered
  wire  [MXHITB-1:0]  hs_nlayers_hit; // Number of layers hit
  wire  [MXLY-1:0]    hs_layer_or;    // Layer ORs

  wire       algo2016_use_dead_time_zone;         // Dead time zone switch: 0 - "old" whole chamber is dead when pre-CLCT is registered, 1 - algo2016 only half-strips around pre-CLCT are marked dead
  wire [4:0] algo2016_dead_time_zone_size;        // Constant size of the dead time zone.NOT used. we used fixed dead time zone, with zone size 9 hs
  wire       algo2016_use_dynamic_dead_time_zone; // Dynamic dead time zone switch: 0 - dead time zone is set by algo2016_use_dynamic_dead_time_zone, 1 - dead time zone depends on pre-CLCT pattern ID.  NOT USED
  wire       algo2016_drop_used_clcts;            // Drop CLCTs from matching in ALCT-centric algorithm: 0 - algo2016 do NOT drop CLCTs, 1 - drop used CLCTs
  wire       algo2016_cross_bx_algorithm;         // LCT sorting using cross BX algorithm: 0 - "old" no cross BX algorithm used, 1 - algo2016 uses cross BX algorithm,  almost no effect, Tao
  wire       algo2016_clct_use_corrected_bx;      // NOT YET IMPLEMENTED: Use median of hits for CLCT timing: 0 - "old" no CLCT timing corrections, 1 - algo2016 CLCT timing calculated based on median of hits, NOT USED!!
  
  
// CCLUT, Tao
`ifdef CCLUT
  pattern_finder_ccLUT upattern_finder
  (
// Ports
  .clock      (clock),                // In  40MHz TMB main clock
  .global_reset  (global_reset),              // In  1=Reset everything

// CFEB Ports
  .cfeb0_ly0hs (cfeb_ly0hs[0][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb0_ly1hs (cfeb_ly1hs[0][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb0_ly2hs (cfeb_ly2hs[0][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb0_ly3hs (cfeb_ly3hs[0][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb0_ly4hs (cfeb_ly4hs[0][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb0_ly5hs (cfeb_ly5hs[0][MXHS-1:0]), // In  1/2-strip pulses

  .cfeb1_ly0hs (cfeb_ly0hs[1][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb1_ly1hs (cfeb_ly1hs[1][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb1_ly2hs (cfeb_ly2hs[1][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb1_ly3hs (cfeb_ly3hs[1][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb1_ly4hs (cfeb_ly4hs[1][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb1_ly5hs (cfeb_ly5hs[1][MXHS-1:0]), // In  1/2-strip pulses

  .cfeb2_ly0hs (cfeb_ly0hs[2][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb2_ly1hs (cfeb_ly1hs[2][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb2_ly2hs (cfeb_ly2hs[2][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb2_ly3hs (cfeb_ly3hs[2][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb2_ly4hs (cfeb_ly4hs[2][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb2_ly5hs (cfeb_ly5hs[2][MXHS-1:0]), // In  1/2-strip pulses

  .cfeb3_ly0hs (cfeb_ly0hs[3][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb3_ly1hs (cfeb_ly1hs[3][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb3_ly2hs (cfeb_ly2hs[3][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb3_ly3hs (cfeb_ly3hs[3][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb3_ly4hs (cfeb_ly4hs[3][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb3_ly5hs (cfeb_ly5hs[3][MXHS-1:0]), // In  1/2-strip pulses

  .cfeb4_ly0hs (cfeb_ly0hs[4][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb4_ly1hs (cfeb_ly1hs[4][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb4_ly2hs (cfeb_ly2hs[4][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb4_ly3hs (cfeb_ly3hs[4][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb4_ly4hs (cfeb_ly4hs[4][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb4_ly5hs (cfeb_ly5hs[4][MXHS-1:0]), // In  1/2-strip pulses

  .cfeb5_ly0hs (cfeb_ly0hs[5][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb5_ly1hs (cfeb_ly1hs[5][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb5_ly2hs (cfeb_ly2hs[5][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb5_ly3hs (cfeb_ly3hs[5][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb5_ly4hs (cfeb_ly4hs[5][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb5_ly5hs (cfeb_ly5hs[5][MXHS-1:0]), // In  1/2-strip pulses

  .cfeb6_ly0hs (cfeb_ly0hs[6][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb6_ly1hs (cfeb_ly1hs[6][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb6_ly2hs (cfeb_ly2hs[6][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb6_ly3hs (cfeb_ly3hs[6][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb6_ly4hs (cfeb_ly4hs[6][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb6_ly5hs (cfeb_ly5hs[6][MXHS-1:0]), // In  1/2-strip pulses

// CSC Orientation Ports
  .csc_type        (csc_type[3:0]),   // Out  Firmware compile type
  .csc_me1ab       (csc_me1ab),       // Out  1=ME1A or ME1B CSC type
  .stagger_hs_csc  (stagger_hs_csc),  // Out  1=Staggered CSC, 0=non-staggered
  .reverse_hs_csc  (reverse_hs_csc),  // Out  1=Reverse staggered CSC, non-me1
  .reverse_hs_me1a (reverse_hs_me1a), // Out  1=reverse me1a hstrips prior to pattern sorting
  .reverse_hs_me1b (reverse_hs_me1b), // Out  1=reverse me1b hstrips prior to pattern sorting
  .evenchamber     (evenchamber), //In even chamber = 1

// PreTrigger Ports
  .layer_trig_en      (layer_trig_en),                  // In  1=Enable layer trigger mode
  .lyr_thresh_pretrig (lyr_thresh_pretrig[MXHITB-1:0]), // In  Layers hit pre-trigger threshold
  .hit_thresh_pretrig (hit_thresh_pretrig[MXHITB-1:0]), // In  Hits on pattern template pre-trigger threshold
  .pid_thresh_pretrig (pid_thresh_pretrig[MXPIDB-1:0]), // In  Pattern shape ID pre-trigger threshold
  .dmb_thresh_pretrig (dmb_thresh_pretrig[MXHITB-1:0]), // In  Hits on pattern template DMB active-feb threshold
  .cfeb_en            (cfeb_en[MXCFEB-1:0]),            // In  1=Enable cfeb for pre-triggering
  .adjcfeb_dist       (adjcfeb_dist[MXKEYB-1+1:0]),     // In  Distance from key to cfeb boundary for marking adjacent cfeb as hit
  .clct_blanking      (clct_blanking),                  // In  clct_blanking=1 clears clcts with 0 hits

  .cfeb_hit    (cfeb_hit[MXCFEB-1:0]),    // Out  This CFEB has a pattern over pre-trigger threshold
  .cfeb_active (cfeb_active[MXCFEB-1:0]), // Out  CFEBs marked active for DMB readout

  .cfeb_layer_trig  (cfeb_layer_trig),              // Out  Layer pretrigger
  .cfeb_layer_or    (cfeb_layer_or[MXLY-1:0]),      // Out  OR of hstrips on each layer
  .cfeb_nlayers_hit (cfeb_nlayers_hit[MXHITB-1:0]), // Out  Number of CSC layers hit

//to add dead time feature in 2016Algo  
  .drift_delay        (drift_delay[MXDRIFT-1:0]),      // In  CSC Drift delay clocks
  .algo2016_use_dead_time_zone         (algo2016_use_dead_time_zone), // In Dead time zone switch: 0 - "old" whole chamber is dead when pre-CLCT is registered, 1 - algo2016 only half-strips around pre-CLCT are marked dead
  .algo2016_dead_time_zone_size        (algo2016_dead_time_zone_size[4:0]),   // In Constant size of the dead time zone

// 2nd CLCT separation RAM Ports
  .clct_sep_src       (clct_sep_src),             // In  CLCT separation source 1=vme, 0=ram
  .clct_sep_vme       (clct_sep_vme[7:0]),        // In  CLCT separation from vme
  .clct_sep_ram_we    (clct_sep_ram_we),          // In  CLCT separation RAM write enable
  .clct_sep_ram_adr   (clct_sep_ram_adr[3:0]),    // In  CLCT separation RAM rw address VME
  .clct_sep_ram_wdata (clct_sep_ram_wdata[15:0]), // In  CLCT separation RAM write data VME
  .clct_sep_ram_rdata (clct_sep_ram_rdata[15:0]), // Out  CLCT separation RAM read  data VME

// CLCT Pattern-finder results, with ccLUT
  .hs_hit_1st (hs_hit_1st[MXHITB-1:0]),  // Out  1st CLCT pattern hits
  .hs_pid_1st (hs_pid_1st[MXPIDB-1:0]),  // Out  1st CLCT pattern ID
  .hs_key_1st (hs_key_1st[MXKEYBX-1:0]), // Out  1st CLCT key 1/2-strip

  .hs_bnd_1st (hs_bnd_1st[MXBNDB - 1   : 0]),
  .hs_xky_1st (hs_xky_1st[MXXKYB-1 : 0]),
  .hs_car_1st (hs_carry_1st[MXPATC-1:0]),
  .hs_run2pid_1st (hs_run2pid_1st[MXPIDB-1:0]),  // Out  1st CLCT pattern ID
  .hs_gemAxky_1st (hs_gemAxky_1st[MXXKYB-1 : 0]), //Out 1st extrapolated CLCt location in gemA
  .hs_gemBxky_1st (hs_gemBxky_1st[MXXKYB-1 : 0]),

  .hs_hit_2nd (hs_hit_2nd[MXHITB-1:0]),  // Out  2nd CLCT pattern hits
  .hs_pid_2nd (hs_pid_2nd[MXPIDB-1:0]),  // Out  2nd CLCT pattern ID
  .hs_key_2nd (hs_key_2nd[MXKEYBX-1:0]), // Out  2nd CLCT key 1/2-strip
  .hs_bsy_2nd (hs_bsy_2nd),              // Out  2nd CLCT busy, logic error indicator

  .hs_bnd_2nd (hs_bnd_2nd[MXBNDB - 1   : 0]),
  .hs_xky_2nd (hs_xky_2nd[MXXKYB-1 : 0]),
  .hs_car_2nd (hs_carry_2nd[MXPATC-1:0]),
  .hs_run2pid_2nd (hs_run2pid_2nd[MXPIDB-1:0]),  // Out  1st CLCT pattern ID
  .hs_gemAxky_2nd (hs_gemAxky_2nd[MXXKYB-1 : 0]), //Out 1st extrapolated CLCt location in gemA
  .hs_gemBxky_2nd (hs_gemBxky_2nd[MXXKYB-1 : 0]),

  .hs_layer_trig  (hs_layer_trig),              // Out  Layer triggered
  .hs_nlayers_hit (hs_nlayers_hit[MXHITB-1:0]), // Out  Number of layers hit
  .hs_layer_or    (hs_layer_or[MXLY-1:0])       // Out  Layer ORs
  );

`else  // normal OTMB firmware with traditional pattern finding
  pattern_finder upattern_finder
  (
// Ports
  .clock      (clock),                // In  40MHz TMB main clock
  .global_reset  (global_reset),              // In  1=Reset everything

// CFEB Ports
  .cfeb0_ly0hs (cfeb_ly0hs[0][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb0_ly1hs (cfeb_ly1hs[0][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb0_ly2hs (cfeb_ly2hs[0][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb0_ly3hs (cfeb_ly3hs[0][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb0_ly4hs (cfeb_ly4hs[0][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb0_ly5hs (cfeb_ly5hs[0][MXHS-1:0]), // In  1/2-strip pulses

  .cfeb1_ly0hs (cfeb_ly0hs[1][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb1_ly1hs (cfeb_ly1hs[1][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb1_ly2hs (cfeb_ly2hs[1][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb1_ly3hs (cfeb_ly3hs[1][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb1_ly4hs (cfeb_ly4hs[1][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb1_ly5hs (cfeb_ly5hs[1][MXHS-1:0]), // In  1/2-strip pulses

  .cfeb2_ly0hs (cfeb_ly0hs[2][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb2_ly1hs (cfeb_ly1hs[2][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb2_ly2hs (cfeb_ly2hs[2][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb2_ly3hs (cfeb_ly3hs[2][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb2_ly4hs (cfeb_ly4hs[2][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb2_ly5hs (cfeb_ly5hs[2][MXHS-1:0]), // In  1/2-strip pulses

  .cfeb3_ly0hs (cfeb_ly0hs[3][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb3_ly1hs (cfeb_ly1hs[3][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb3_ly2hs (cfeb_ly2hs[3][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb3_ly3hs (cfeb_ly3hs[3][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb3_ly4hs (cfeb_ly4hs[3][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb3_ly5hs (cfeb_ly5hs[3][MXHS-1:0]), // In  1/2-strip pulses

  .cfeb4_ly0hs (cfeb_ly0hs[4][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb4_ly1hs (cfeb_ly1hs[4][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb4_ly2hs (cfeb_ly2hs[4][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb4_ly3hs (cfeb_ly3hs[4][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb4_ly4hs (cfeb_ly4hs[4][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb4_ly5hs (cfeb_ly5hs[4][MXHS-1:0]), // In  1/2-strip pulses

  .cfeb5_ly0hs (cfeb_ly0hs[5][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb5_ly1hs (cfeb_ly1hs[5][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb5_ly2hs (cfeb_ly2hs[5][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb5_ly3hs (cfeb_ly3hs[5][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb5_ly4hs (cfeb_ly4hs[5][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb5_ly5hs (cfeb_ly5hs[5][MXHS-1:0]), // In  1/2-strip pulses

  .cfeb6_ly0hs (cfeb_ly0hs[6][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb6_ly1hs (cfeb_ly1hs[6][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb6_ly2hs (cfeb_ly2hs[6][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb6_ly3hs (cfeb_ly3hs[6][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb6_ly4hs (cfeb_ly4hs[6][MXHS-1:0]), // In  1/2-strip pulses
  .cfeb6_ly5hs (cfeb_ly5hs[6][MXHS-1:0]), // In  1/2-strip pulses

// CSC Orientation Ports
  .csc_type        (csc_type[3:0]),   // Out  Firmware compile type
  .csc_me1ab       (csc_me1ab),       // Out  1=ME1A or ME1B CSC type
  .stagger_hs_csc  (stagger_hs_csc),  // Out  1=Staggered CSC, 0=non-staggered
  .reverse_hs_csc  (reverse_hs_csc),  // Out  1=Reverse staggered CSC, non-me1
  .reverse_hs_me1a (reverse_hs_me1a), // Out  1=reverse me1a hstrips prior to pattern sorting
  .reverse_hs_me1b (reverse_hs_me1b), // Out  1=reverse me1b hstrips prior to pattern sorting

// PreTrigger Ports
  .layer_trig_en      (layer_trig_en),                  // In  1=Enable layer trigger mode
  .lyr_thresh_pretrig (lyr_thresh_pretrig[MXHITB-1:0]), // In  Layers hit pre-trigger threshold
  .hit_thresh_pretrig (hit_thresh_pretrig[MXHITB-1:0]), // In  Hits on pattern template pre-trigger threshold
  .pid_thresh_pretrig (pid_thresh_pretrig[MXPIDB-1:0]), // In  Pattern shape ID pre-trigger threshold
  .dmb_thresh_pretrig (dmb_thresh_pretrig[MXHITB-1:0]), // In  Hits on pattern template DMB active-feb threshold
  .cfeb_en            (cfeb_en[MXCFEB-1:0]),            // In  1=Enable cfeb for pre-triggering
  .adjcfeb_dist       (adjcfeb_dist[MXKEYB-1+1:0]),     // In  Distance from key to cfeb boundary for marking adjacent cfeb as hit
  .clct_blanking      (clct_blanking),                  // In  clct_blanking=1 clears clcts with 0 hits

  .cfeb_hit    (cfeb_hit[MXCFEB-1:0]),    // Out  This CFEB has a pattern over pre-trigger threshold
  .cfeb_active (cfeb_active[MXCFEB-1:0]), // Out  CFEBs marked active for DMB readout

  .cfeb_layer_trig  (cfeb_layer_trig),              // Out  Layer pretrigger
  .cfeb_layer_or    (cfeb_layer_or[MXLY-1:0]),      // Out  OR of hstrips on each layer
  .cfeb_nlayers_hit (cfeb_nlayers_hit[MXHITB-1:0]), // Out  Number of CSC layers hit
//to add dead time feature in 2016Algo  
  .drift_delay        (drift_delay[MXDRIFT-1:0]),      // In  CSC Drift delay clocks
  .algo2016_use_dead_time_zone         (algo2016_use_dead_time_zone), // In Dead time zone switch: 0 - "old" whole chamber is dead when pre-CLCT is registered, 1 - algo2016 only half-strips around pre-CLCT are marked dead
  .algo2016_dead_time_zone_size        (algo2016_dead_time_zone_size[4:0]),   // In Constant size of the dead time zone

// 2nd CLCT separation RAM Ports
  .clct_sep_src       (clct_sep_src),             // In  CLCT separation source 1=vme, 0=ram
  .clct_sep_vme       (clct_sep_vme[7:0]),        // In  CLCT separation from vme
  .clct_sep_ram_we    (clct_sep_ram_we),          // In  CLCT separation RAM write enable
  .clct_sep_ram_adr   (clct_sep_ram_adr[3:0]),    // In  CLCT separation RAM rw address VME
  .clct_sep_ram_wdata (clct_sep_ram_wdata[15:0]), // In  CLCT separation RAM write data VME
  .clct_sep_ram_rdata (clct_sep_ram_rdata[15:0]), // Out  CLCT separation RAM read  data VME

// CLCT Pattern-finder results, traditional
  .hs_hit_1st (hs_hit_1st[MXHITB-1:0]),  // Out  1st CLCT pattern hits
  .hs_pid_1st (hs_pid_1st[MXPIDB-1:0]),  // Out  1st CLCT pattern ID
  .hs_key_1st (hs_key_1st[MXKEYBX-1:0]), // Out  1st CLCT key 1/2-strip

  .hs_hit_2nd (hs_hit_2nd[MXHITB-1:0]),  // Out  2nd CLCT pattern hits
  .hs_pid_2nd (hs_pid_2nd[MXPIDB-1:0]),  // Out  2nd CLCT pattern ID
  .hs_key_2nd (hs_key_2nd[MXKEYBX-1:0]), // Out  2nd CLCT key 1/2-strip
  .hs_bsy_2nd (hs_bsy_2nd),              // Out  2nd CLCT busy, logic error indicator

  .hs_layer_trig  (hs_layer_trig),              // Out  Layer triggered
  .hs_nlayers_hit (hs_nlayers_hit[MXHITB-1:0]), // Out  Number of layers hit
  .hs_layer_or    (hs_layer_or[MXLY-1:0])       // Out  Layer ORs
  );

`endif

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  HMT instantiation
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
  wire hmt_sump;

  wire  hmt_enable;
  wire  hmt_me1a_enable;

  wire  hmt_allow_cathode;
  wire  hmt_allow_anode;
  wire  hmt_allow_match;
  wire  hmt_allow_cathode_ro;
  wire  hmt_allow_anode_ro;
  wire  hmt_allow_match_ro;
  wire  hmt_outtime_check;

  wire [NHMTHITB-1:0] hmt_nhits_sig_ff; //for header
  wire [NHMTHITB-1:0] hmt_nhits_bx7;
  wire [NHMTHITB-1:0] hmt_nhits_sig;
  wire [NHMTHITB-1:0] hmt_nhits_bkg;
  wire [7:0] hmt_thresh1, hmt_thresh2, hmt_thresh3;

  wire [6:0] hmt_aff_thresh;
  wire [MXCFEB-1:0] hmt_active_feb;
  wire hmt_pretrig_match;
  wire hmt_fired_xtmb;
  wire hmt_wr_avail_xtmb;
  wire [MXBADR-1:0] hmt_wr_adr_xtmb;

  wire [3:0]  hmt_delay;
  wire [3:0]  hmt_alct_win_size;
  wire [3:0]  hmt_match_win;

  wire [MXHMTB-1:0] hmt_anode;
  wire [MXHMTB-1:0] hmt_cathode;

  wire [MXBADR-1:0] wr_adr_xpre_hmt;
  wire              wr_push_xpre_hmt;
  wire              wr_avail_xpre_hmt; 

  wire [MXBADR-1:0] wr_adr_xpre_hmt_pipe;
  wire              wr_push_mux_hmt;
  wire              wr_avail_xpre_hmt_pipe; 
  
  wire hmt_fired_cathode_only;
  wire hmt_fired_anode_only;
  wire hmt_fired_match;

  wire [MXHMTB-1:0] hmt_trigger_tmb;// results aligned with ALCT vpf
  wire [MXHMTB-1:0] hmt_trigger_tmb_ro;// results aligned with ALCT vpf

  hmt uhmt
  (
  .clock       (clock),          // In clock
  .ttc_resync  (ttc_resync),      // In
  .global_reset(global_reset),    // In

  .fmm_trig_stop (fmm_trig_stop), // In stop HMT when it is not ready
  .bx0_vpf_test  (bx0_vpf_test) ,  // In dynamic zero

  .nhit_cfeb0    (cfeb_nhits[0][NHITCFEBB-1: 0]),// In cfeb hit counter
  .nhit_cfeb1    (cfeb_nhits[1][NHITCFEBB-1: 0]),// In cfeb hit counter
  .nhit_cfeb2    (cfeb_nhits[2][NHITCFEBB-1: 0]),// In cfeb hit counter
  .nhit_cfeb3    (cfeb_nhits[3][NHITCFEBB-1: 0]),// In cfeb hit counter
  .nhit_cfeb4    (cfeb_nhits[4][NHITCFEBB-1: 0]),// In cfeb hit counter
  .nhit_cfeb5    (cfeb_nhits[5][NHITCFEBB-1: 0]),// In cfeb hit counter
  .nhit_cfeb6    (cfeb_nhits[6][NHITCFEBB-1: 0]),// In cfeb hit counter

  .layers_withhits_cfeb0 (cfeb_layers_withhits[0][MXLY-1:0]), // In layers with hits
  .layers_withhits_cfeb1 (cfeb_layers_withhits[1][MXLY-1:0]), // In layers with hits
  .layers_withhits_cfeb2 (cfeb_layers_withhits[2][MXLY-1:0]), // In layers with hits
  .layers_withhits_cfeb3 (cfeb_layers_withhits[3][MXLY-1:0]), // In layers with hits
  .layers_withhits_cfeb4 (cfeb_layers_withhits[4][MXLY-1:0]), // In layers with hits
  .layers_withhits_cfeb5 (cfeb_layers_withhits[5][MXLY-1:0]), // In layers with hits
  .layers_withhits_cfeb6 (cfeb_layers_withhits[6][MXLY-1:0]), // In layers with hits

  .hmt_enable         (hmt_enable) , // In hmt enabled 
  .hmt_me1a_enable    (hmt_me1a_enable) , // In hmt enabled 
  .hmt_thresh1   (hmt_thresh1[7:0]), // In hmt thresh1
  .hmt_thresh2   (hmt_thresh2[7:0]), // In hmt thresh2
  .hmt_thresh3   (hmt_thresh3[7:0]), // In hmt thresh3
  .hmt_aff_thresh(hmt_aff_thresh[6:0]),//In hmt thresh for active cfeb flag

  .hmt_delay          (hmt_delay[3:0]), // In hmt delay for matching
  .hmt_alct_win_size  (hmt_alct_win_size[3:0]),//In hmt-alct match window size
  .hmt_match_win      (hmt_match_win[3:0]),// In alct location in hmt window size

  .wr_adr_xpre_hmt        (wr_adr_xpre_hmt[MXBADR-1:0]),  //In wr_adr at pretrigger for hmt
  .wr_push_xpre_hmt       (wr_push_xpre_hmt), //In wr_push at pretrigger for hmt
  .wr_avail_xpre_hmt      (wr_avail_xpre_hmt),//In wr_avail at pretrigger for hmt 

  .wr_adr_xpre_hmt_pipe   (wr_adr_xpre_hmt_pipe[MXBADR-1:0]),  //Out wr_adr at rtmb-1 for hmt 
  .wr_push_mux_hmt        (wr_push_mux_hmt),       //Out wr_push at rtmb-1 for hmt
  .wr_avail_xpre_hmt_pipe (wr_avail_xpre_hmt_pipe),//Out wr_avail at rtmb-1 for hmt 

  //tmb port: input
  .alct_vpf_pipe     (alct_vpf_pipe),//In ALCT vpf after alct delay
  .hmt_anode         (hmt_anode[MXHMTB-1:0]),// In hmt bits from anode 

  .clct_pretrig     (clct_pretrig),//In clct pretrigger
  .clct_vpf_pipe    (clct_vpf_pipe),//In CLCT vpf after delay

  // vme port: input
  .cfeb_allow_hmt_ro   (cfeb_allow_hmt_ro), //Out read out CFEB when hmt is fired
  .hmt_allow_cathode   (hmt_allow_cathode),//In hmt allow to trigger on cathode 
  .hmt_allow_anode     (hmt_allow_anode),//In hmt allow to trigger on anode
  .hmt_allow_match     (hmt_allow_match),//In hmt allow to trigger on canode X anode match
  .hmt_allow_cathode_ro(hmt_allow_cathode_ro),//In hmt allow to readout on cathode
  .hmt_allow_anode_ro  (hmt_allow_anode_ro),//In hmt allow to readout on anode
  .hmt_allow_match_ro  (hmt_allow_match_ro),//In hmt allow to readout on match
  .hmt_outtime_check   (hmt_outtime_check),//In hmt fired shoudl check anode bg lower than threshold
  // sequencer port
  .hmt_fired_pretrig   (hmt_fired_pretrig),//out, hmt fired preCLCT bx
  .hmt_active_feb      (hmt_active_feb[MXCFEB-1:0]),//Out hmt active cfeb flags
  .hmt_pretrig_match   (hmt_pretrig_match),//out hmt & preCLCT
  .hmt_fired_xtmb      (hmt_fired_xtmb),//out, hmt fired preCLCT bx
  .hmt_wr_avail_xtmb   (hmt_wr_avail_xtmb),//Out hmt wr buf available
  .hmt_wr_adr_xtmb     (hmt_wr_adr_xtmb[MXBADR-1:0]),// Out hmt wr adr at CLCt bx

  //tmb port
  .hmt_nhits_bx7       (hmt_nhits_bx7     [NHMTHITB-1:0]),//Out hmt nhits for central bx
  .hmt_nhits_sig     (hmt_nhits_sig   [NHMTHITB-1:0]),//Out hmt nhits for in-time
  .hmt_nhits_bkg    (hmt_nhits_bkg  [NHMTHITB-1:0]),//Out hmt nhits for out-time
  .hmt_cathode_pipe    (hmt_cathode[MXHMTB-1:0]), //Out hmt bits in cathod 
  
  //.hmt_cathode_fired     (hmt_cathode_fired),// Out 
  //.hmt_anode_fired       (hmt_anode_fired),// Out 
  .hmt_anode_alct_match  (hmt_anode_alct_match),//Out
  .hmt_cathode_alct_match(hmt_cathode_alct_match),// Out 
  .hmt_cathode_clct_match(hmt_cathode_clct_match),// Out 
  .hmt_cathode_lct_match (hmt_cathode_lct_match),// Out
  
  .hmt_fired_cathode_only (hmt_fired_cathode_only),//Out hmt is fired for cathode only
  .hmt_fired_anode_only   (hmt_fired_anode_only),//Out hmt is fired for anode only
  .hmt_fired_match        (hmt_fired_match),//Out hmt is fired for match
  .hmt_fired_or           (hmt_fired_or),//Out hmt is fired for match

  .hmt_trigger_tmb    (hmt_trigger_tmb[MXHMTB-1:0]),// results aligned with ALCT vpf latched for ALCT-CLCT match
  .hmt_trigger_tmb_ro (hmt_trigger_tmb_ro[MXHMTB-1:0]),// results aligned with ALCT vpf latched for ALCT-CLCT match
  .hmt_sump  (hmt_sump)
);
  

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  Begin: Sequencer Signals
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
   wire [MXCFEBB-1:0]     cfeb_adr;
   wire [MXTBIN-1:0]      cfeb_tbin;
   wire [7:0]             cfeb_rawhits;
   
   wire [MXHMTB-1:0]             hmt_cathode_vme;

   wire [MXCLCT-1:0]      clct0_xtmb;
   wire [MXCLCT-1:0]      clct1_xtmb;
   wire [MXCLCTC-1:0]     clctc_xtmb; // Common to CLCT0/1 to TMB
   wire [MXCFEB-1:0]      clctf_xtmb; // Active cfeb list to TMB

   wire [MXBNDB - 1   : 0] clct0_bnd_xtmb; // new bending 
   wire [MXXKYB-1     : 0] clct0_xky_xtmb; // new position with 1/8 precision
   wire [MXXKYB-1     : 0] clct0_gemAxky_xtmb; // new position with 1/8 precision
   wire [MXXKYB-1     : 0] clct0_gemBxky_xtmb; // new position with 1/8 precision
   //wire [MXPATC-1     : 0] clct0_carry_xtmb; // CC code 
   wire [MXBNDB - 1   : 0] clct1_bnd_xtmb; // new bending 
   wire [MXXKYB-1     : 0] clct1_xky_xtmb; // new position with 1/8 precision
   wire [MXXKYB-1     : 0] clct1_gemAxky_xtmb; // new position with 1/8 precision
   wire [MXXKYB-1     : 0] clct1_gemBxky_xtmb; // new position with 1/8 precision
   //wire [MXPATC-1     : 0] clct1_carry_xtmb; // CC code 


   //GEM CSC match
   wire        gemA_alct_pulse_match; 
   wire        gemA_clct_pulse_match;
   wire        gemB_alct_pulse_match; 
   wire        gemB_clct_pulse_match;
   wire        gemcsc_match_extrapolate;
   wire        gemcsc_match_bend_correction;
   wire        gemcsc_match_tightwindow;
   wire        gemA_match_ignore_position;
   wire        gemB_match_ignore_position;
   wire        gemcsc_bend_enable;
   wire        gemcsc_ignore_bend_check;

   wire [7:0]  match_gem_alct_delay;
   wire [3:0]  match_gem_alct_window;
   wire [3:0]  match_gem_clct_window;
   wire [7:0]  gemA_forclct_real;
   wire [7:0]  gemB_forclct_real;
   wire [7:0]   copad_match_real;
   wire [3:0]  tmb_gem_clct_win;
   wire [2:0]  tmb_alct_gem_win;

   wire [3:0] tmb_hmt_match_win;

   wire [MXBADR-1:0]      wr_adr_xtmb; // Buffer write address to TMB
   wire [MXBADR-1:0]      wr_adr_rtmb; // Buffer write address at TMB matching time
   wire [MXBADR-1:0]      wr_adr_xmpc; // wr_adr at mpc xmit to sequencer
   wire [MXBADR-1:0]      wr_adr_rmpc; // wr_adr at mpc received

   wire [MXCFEB-1:0]      injector_mask_cfeb;
   wire [3:0]             inj_delay_rat; // CFEB/RPC Injector waits for RAT injector

   wire [MXBXN-1:0]       bxn_offset_pretrig;
   wire [MXBXN-1:0]       bxn_offset_l1a;
   wire [MXL1ARX-1:0]     l1a_offset;
   wire [MXDRIFT-1:0]     drift_delay;
   wire [MXHITB-1:0]      hit_thresh_postdrift;
   wire [MXPIDB-1:0]      pid_thresh_postdrift;
   wire [MXFLUSH-1:0]     clct_flush_delay;
   wire [MXTHROTTLE-1:0]  clct_throttle;

   wire [MXBDID-1:0]      board_id;
   wire [MXCSC-1:0]       csc_id;
   wire [MXRID-1:0]       run_id;

   wire [15:0]            uptime;    // Uptime since last hard reset
   wire [14:0]            bd_status; // Board status summary
   wire [2:0]             dmb_tx_reserved;

   wire [MXL1DELAY-1:0]   l1a_delay;
   wire [MXL1WIND-1:0]    l1a_window;
   wire [MXL1WIND-1:0]    l1a_internal_dly;
   wire [MXBADR-1:0]      l1a_lookback;

   wire [7:0]             led_bd;
   wire [11:0]            sequencer_state;
   wire [10:0]            trig_source_vme;
   wire [2:0]             nlayers_hit_vme;
   wire [MXBXN-1:0]       bxn_clct_vme; // CLCT BXN at pre-trigger
   wire [MXBXN-1:0]       bxn_l1a_vme;  // CLCT BXN at L1A
   wire [3:0]             alct_preClct_width;

   wire [MXEXTDLY-1:0]    alct_preClct_dly;
   wire [MXEXTDLY-1:0]    alct_pat_trig_dly;
   wire [MXEXTDLY-1:0]    adb_ext_trig_dly;
   wire [MXEXTDLY-1:0]    dmb_ext_trig_dly;
   wire [MXEXTDLY-1:0]    clct_ext_trig_dly;
   wire [MXEXTDLY-1:0]    alct_ext_trig_dly;

   wire [3:0]             l1a_preClct_width;
   wire [7:0]             l1a_preClct_dly;

   wire [9:0]             hmt_nhits_bx7_vme;
   wire [9:0]             hmt_nhits_sig_vme;
   wire [9:0]             hmt_nhits_bkg_vme;

   wire [MXCLCT-1:0]      clct0_vme;
   wire [MXCLCT-1:0]      clct1_vme;
   wire [MXCLCTC-1:0]     clctc_vme;
   wire [MXCFEB-1:0]      clctf_vme;

   wire [MXBNDB - 1   : 0] clct0_vme_bnd; // new bending 
   wire [MXXKYB-1     : 0] clct0_vme_xky; // new position with 1/8 precision
   wire [MXPATC-1:0]       clct0_vme_carry;
   wire [MXBNDB - 1   : 0] clct1_vme_bnd; // new bending 
   wire [MXXKYB-1     : 0] clct1_vme_xky; // new position with 1/8 precision
   wire [MXPATC-1:0]       clct1_vme_carry;

   wire [MXRAMADR-1:0]    dmb_adr;
   wire [MXRAMDATA-1:0]   dmb_wdata;
   wire [MXRAMDATA-1:0]   dmb_rdata;
   wire [MXRAMADR-1:0]    dmb_wdcnt;

   wire [3:0]             alct_delay;
   wire [3:0]             clct_window;
   wire [3:0]             algo2016_window;       // CLCT match window width (for ALCT-centric 2016 algorithm), not USED!
   wire                   algo2016_clct_to_alct; // ALCT-to-CLCT matching switch: 0 - "old" CLCT-centric algorithm, 1 - algo2016 ALCT-centric algorithm, not USED!
   wire [3:0]             alct_bx0_delay; // ALCT bx0 delay to mpc transmitter
   wire [3:0]             clct_bx0_delay; // CLCT bx0 delay to mpc transmitter

   wire [5:0]             gemA_bx0_delay;
   wire [5:0]             gemB_bx0_delay;

   wire [MXMPCDLY-1:0]    mpc_rx_delay;
   wire [MXMPCDLY-1:0]    mpc_tx_delay;
   wire [MXFRAME-1:0]     mpc0_frame0_ff;
   wire [MXFRAME-1:0]     mpc0_frame1_ff;
   wire [MXFRAME-1:0]     mpc1_frame0_ff;
   wire [MXFRAME-1:0]     mpc1_frame1_ff;

   wire [10:0]            tmb_alct0;
   wire [10:0]            tmb_alct1;
   wire [ 4:0]            tmb_alctb;
   wire [ 1:0]            tmb_alcte;
   wire  [MXHMTB-1:0] tmb_cathode_hmt;

   wire [1:0]             mpc_accept_ff;
   wire [1:0]             mpc_reserved_ff;
   wire [3:0]             tmb_match_win;
   wire [3:0]             tmb_match_pri;
   wire [MXCFEB-1:0]      tmb_aff_list; // Active CFEBs for CLCT used in TMB match

// Sequencer Buffer Arrays
   wire [MXFMODE-1:0]     fifo_mode;

   wire [MXTBIN-1:0]      fifo_tbins_cfeb; // Number FIFO time bins to read out
   wire [MXTBIN-1:0]      fifo_tbins_rpc;  // Number FIFO time bins to read out
   wire [MXTBIN-1:0]      fifo_tbins_gem;  // Number FIFO time bins to read out
   wire [MXTBIN-1:0]      fifo_tbins_mini; // Number FIFO time bins to read out

   wire [MXTBIN-1:0]      fifo_pretrig_cfeb; // Number FIFO time bins before pretrigger
   wire [MXTBIN-1:0]      fifo_pretrig_gem;  // Number FIFO time bins before pretrigger
   wire [MXTBIN-1:0]      fifo_pretrig_rpc;  // Number FIFO time bins before pretrigger
   wire [MXTBIN-1:0]      fifo_pretrig_mini; // Number FIFO time bins before pretrigger

   wire [MXBADR-1:0]      buf_pop_adr;   // Address of read buffer to release
   wire [MXBADR-1:0]      buf_push_adr;  // Address of write buffer to allocate
   wire [MXBDATA-1:0]     buf_push_data; // Data associated with push_adr
   wire [MXBADR-1:0]      wr_buf_adr;    // Current ddress of header write buffer

   wire [MXBADR-1:0]      buf_queue_adr;  // Buffer address of fence queued for readout
   wire [MXBDATA-1:0]     buf_queue_data; // Data associated with queue adr

   wire [MXBADR-1:0]      buf_fence_dist;     // Distance to 1st fence address
   wire [MXBADR-1+1:0]    buf_fence_cnt;      // Number of fences in fence RAM currently
   wire [MXBADR-1+1:0]    buf_fence_cnt_peak; // Peak number of fences in fence RAM
   wire [7:0]             buf_display;        // Buffer fraction in use display

// Sequencer GEM Sequencer Readout Control
   wire [MXGEM-1:0]       rd_list_gem;   // List of GEMs fibers to read out
   wire [MXGEMB-1+1:0]    rd_ngems;      // Number of GEMs fibers in gem_list
   wire [RAM_ADRB-1:0]    rd_gem_offset; // RAM address rd_fifo_adr offset for gem read out

   wire [MXGEMB-1:0]      gem_adr;     // FIFO dump GEM ID
   wire [13:0]            gem_rawhits; // FIFO dump GEM pad hits
   wire [0:0]             gem_id;      // FIFO dump GEM id (0,1)

// Sequencer RPC Sequencer Readout Control
   wire [MXRPC-1:0]       rpc_exists;    // RPC Readout list
   wire [MXRPC-1:0]       rd_list_rpc;   // List of RPCs to read out
   wire [MXRPCB-1+1:0]    rd_nrpcs;      // Number of RPCs in rpc_list (0 or 1-to-2 depending on CSC type)
   wire [RAM_ADRB-1:0]    rd_rpc_offset; // RAM address rd_fifo_adr offset for rpc read out

   wire [MXCFEBB-1:0]     rd_ncfebs;
   wire [MXCFEB-1:0]      rd_list_cfeb;
   wire [RAM_ADRB-1:0]    rd_fifo_adr;

   wire [MXRPCB-1:0]      rpc_adr;     // FIFO dump RPC ID
   wire [MXTBIN-1:0]      rpc_tbinbxn; // FIFO dump RPC tbin or bxn for DMB
   wire [7:0]             rpc_rawhits; // FIFO dump RPC pad hits, 8 of 16 per cycle

// Sequencer Scope
   wire [2:0]             scp_rpc0_bxn;   // RPC0 bunch crossing number
   wire [2:0]             scp_rpc1_bxn;   // RPC1 bunch crossing number
   wire [3:0]             scp_rpc0_nhits; // RPC0 number of pads hit
   wire [3:0]             scp_rpc1_nhits; // RPC1 number of pads hit

   wire [7:0]             scp_trigger_ch; // Trigger channel 0-159
   wire [3:0]             scp_ram_sel;    // Scope RAM select
   wire [2:0]             scp_tbins;      // Time bins per channel code, actual tbins/ch = (tbins+1)*64
   wire [8:0]             scp_radr;       // Extended to 512 addresses 7/23/2007
   wire [15:0]            scp_rdata;

// Sequencer Miniscope
   wire [RAM_WIDTH*2-1:0] mini_rdata;      // FIFO dump miniscope
   wire [RAM_WIDTH*2-1:0] fifo_wdata_mini; // FIFO RAM write data
   wire [RAM_ADRB-1:0]    rd_mini_offset;  // RAM address rd_fifo_adr offset for miniscope read out
   wire [RAM_ADRB-1:0]    wr_mini_offset;  // RAM address offset for miniscope write

// Sequencer Blockedbits
   wire [MXCFEB-1:0]      rd_list_bcb;   // List of CFEBs to read out
   wire [MXCFEBB-1:0]     rd_ncfebs_bcb; // Number of CFEBs in bcb_list (0 to 5)
   wire [11:0]            bcb_blkbits;   // CFEB blocked bits frame data
   wire [MXCFEBB-1:0]     bcb_cfeb_adr;  // CFEB ID

// Sequencer Header Counters
   wire [MXCNTVME-1:0]    pretrig_counter; // Pre-trigger counter
   wire [MXCNTVME-1:0]    seq_pretrig_counter;       // consecutive Pre-trigger counter (equential, 1 bx apart)
   wire [MXCNTVME-1:0]    almostseq_pretrig_counter; // Pre-triggers-2bx-apart counter
   wire [MXCNTVME-1:0]    clct_counter;    // CLCT counter
   wire [MXCNTVME-1:0]    trig_counter;    // TMB trigger counter
   wire [MXCNTVME-1:0]    alct_counter;    // ALCTs received counter
   wire [MXL1ARX-1:0]     l1a_rx_counter;  // L1As received from ccb counter
   wire [MXL1ARX-1:0]     readout_counter; // Readout counter
   wire [MXORBIT-1:0]     orbit_counter;   // Orbit counter

// Sequencer Revcode
   wire [14:0]            revcode;

// Sequencer Parity errors
   wire [MXCFEB-1:0]      perr_cfeb;
   wire [MXCFEB-1:0]      perr_cfeb_ff;
   wire [MXGEM-1:0]       perr_gem;
   wire [MXGEM-1:0]       perr_gem_ff;
   wire [64:0]            perr_ram_ff; // Mapped bad parity RAMs, 6x7=42 cfebs + 5 rpcs + 2 miniscope + 4*4 GEMs

// Sequencer VME debug register latches
   wire [MXBADR-1:0]      deb_wr_buf_adr;    // Buffer write address at last pretrig
   wire [MXBADR-1:0]      deb_buf_push_adr;  // Queue push address at last push
   wire [MXBADR-1:0]      deb_buf_pop_adr;   // Queue pop  address at last pop
   wire [MXBDATA-1:0]     deb_buf_push_data; // Queue push data at last push
   wire [MXBDATA-1:0]     deb_buf_pop_data;  // Queue pop  data at last pop

// -----------------------------------------------------------------------------
// End: Sequencer Module
// -----------------------------------------------------------------------------

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  Begin: Sequencer Module
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  sequencer usequencer (
// Sequencer CCB Ports
  .clock               (clock),               // In  40MHz TMB main clock
  .global_reset        (global_reset),        // In  Global reset
  .clock_lock_lost_err (clock_lock_lost_err), // In  40MHz main clock lost lock FF
  .ccb_l1accept        (ccb_l1accept),        // In  Level 1 Accept
  .ccb_evcntres        (ccb_evcntres),        // In  Event counter (L1A) reset command
  .ttc_bx0             (ttc_bx0),             // In  Bunch crossing 0 flag
  .ttc_resync          (ttc_resync),          // In  TTC resync
  .ttc_bxreset         (ttc_bxreset),         // In  Reset bxn
  .ttc_orbit_reset     (ttc_orbit_reset),     // In  Reset orbit counter
  .fmm_trig_stop       (fmm_trig_stop),       // In  Stop clct trigger sequencer
  .sync_err            (sync_err),            // In  Sync error OR of enabled error types
  .clct_bx0_sync_err   (clct_bx0_sync_err),   // Out TMB  clock pulse count err bxn!=0+offset at ttc_bx0 arrival

// Sequencer ALCT Ports
  .alct_active_feb (alct_active_feb), // In  ALCT Pattern trigger
  .alct0_valid     (alct0_valid),     // In  ALCT has valid LCT
  .alct1_valid     (alct1_valid),     // In  ALCT has valid LCT

// Sequencer GEM Ports
  .gem_any_match     (gem_any_match), // In  GEM co-pad match was found
  .copad_match       (copad_match),     // In  8 Bit GEM Match Flag
  .gemA_sync_err     (~gemA_synced),  // In  GEM0 has intra-chamber sync error
  .gemB_sync_err     (~gemB_synced),  // In  GEM1 has intra-chamber sync error
  .gems_sync_err     (~gems_synced),  // In  GEM Super Chamber has sync error

  .gemA_overflow     (gemA_overflow), // In  GEM A received overflow flag
  .gemB_overflow     (gemB_overflow), // In  GEM B received overflow flag

  .gemA_bc0marker (gemA_bc0marker),   // In GEMA bc0 marker
  .gemB_bc0marker (gemB_bc0marker),   // In GEMB bc0 marker
 
  .gemA_resyncmarker (gemA_resyncmarker), //In GEMA resync
  .gemB_resyncmarker (gemB_resyncmarker), //In GEMB resync

  .gemA_vpf          (gemA_vpf),      // In  8-bit mask of valid cluster received
  .gemB_vpf          (gemB_vpf),      // In  8-bit mask of valid cluster received

  .gemA_active_feb_list     (gemA_active_feb_list), //In active vfat in gemA
  .gemB_active_feb_list     (gemB_active_feb_list), //In active vfat in gemB
  .gemcopad_active_feb_list (gemcopad_active_feb_list), // active vfat with copad 

  .gemA_anycluster_me1a    (gemA_anycluster_me1a), //In any ME1a region or not by converting gemA clusters into key HS
  .gemB_anycluster_me1a    (gemB_anycluster_me1a), //In any ME1a region or not by converting gemA clusters into key HS
  .gemA_anycluster_me1b    (gemA_anycluster_me1b), //In any ME1a region or not by converting gemA clusters into key HS
  .gemB_anycluster_me1b    (gemB_anycluster_me1b), //In any ME1a region or not by converting gemA clusters into key HS

  //.gemA_csc_cluster_active_cfeb_list     (gemA_csc_cluster_active_cfeb_list),// In active CFEB by converting gemA clusters into CSC keyhs
  //.gemB_csc_cluster_active_cfeb_list     (gemB_csc_cluster_active_cfeb_list),// In active CFEB by converting gemA clusters into CSC keyhs
  //.gemcopad_csc_cluster_active_cfeb_list (gemcopad_csc_cluster_active_cfeb_list),// In active CFEB by converting gemA clusters into CSC keyhs

// Sequencer External Triggers
  .alct_adb_pulse_sync (alct_adb_pulse_sync), // In  ADB Test pulse trigger
  .dmb_ext_trig        (dmb_ext_trig),        // In  DMB Calibration trigger
  .clct_ext_trig       (clct_ext_trig),       // In  CLCT External trigger from CCB
  .alct_ext_trig       (alct_ext_trig),       // In  ALCT External trigger from CCB
  .vme_ext_trig        (vme_ext_trig),        // In  External trigger from VME
  .ext_trig_inject     (ext_trig_inject),     // In  Changes clct_ext_trig to fire pattern injector

// Sequencer External Trigger Enables
  .clct_pat_trig_en   (clct_pat_trig_en),                                                    // In  Allow CLCT Pattern pre-triggers
  .alct_pat_trig_en   (alct_pat_trig_en),                                                    // In  Allow ALCT Pattern pre-trigger
  .alct_match_trig_en (alct_match_trig_en),                                                  // In  Allow CLCT*ALCT Pattern pre-trigger
  .adb_ext_trig_en    (adb_ext_trig_en),                                                     // In  Allow ADB Test pulse pre-trigger
  .dmb_ext_trig_en    (dmb_ext_trig_en),                                                     // In  Allow DMB Calibration pre-trigger
  .clct_ext_trig_en   (clct_ext_trig_en),                                                    // In  Allow CLCT External pre-trigger from CCB
  .alct_ext_trig_en   (alct_ext_trig_en),                                                    // In  Allow ALCT External pre-trigger from CCB
  .layer_trig_en      (layer_trig_en),                                                       // In  Allow layer-wide pre-triggering
  .all_cfebs_active   (all_cfebs_active),                                                    // In  Make all CFEBs active when triggered
//.cfeb_en            (cfeb_en[MXCFEB-1:0]),                                                 // In  1=Enable this CFEB for triggering + sending active feb flag
  .cfeb_en            (cfeb_en[MXCFEB-1:0] & ~link_bad[MXCFEB-1:0] & link_good[MXCFEB-1:0]), // In  1=Enable this CFEB for triggering + sending active feb flag unless fiber link is bad
  .active_feb_src     (active_feb_src),                                                      // In  Active cfeb flag source, 0=pretrig, 1=tmb-matching ~8bx later

  .alct_preClct_width  (alct_preClct_width[3:0]), // In  ALCT (alct_active_feb flag) window width for ALCT*preCLCT overlap
  .wr_buf_required     (wr_buf_required),         // In  Require wr_buffer to pretrigger
  .wr_buf_autoclr_en   (wr_buf_autoclr_en),       // In  Enable frozen buffer auto clear
  .valid_clct_required (valid_clct_required),     // In  Require valid pattern after drift to trigger

  .sync_err_stops_pretrig  (sync_err_stops_pretrig), // In  Sync error stops CLCT pre-triggers
  .sync_err_stops_readout  (sync_err_stops_readout), // In  Sync error stops L1A readouts

// Sequencer External Trigger Delays
  .alct_preClct_dly  (alct_preClct_dly[MXEXTDLY-1:0]),  // In  ALCT (alct_active_feb flag) delay for ALCT*preCLCT overlap
  .alct_pat_trig_dly (alct_pat_trig_dly[MXEXTDLY-1:0]), // In  ALCT pattern  trigger delay
  .adb_ext_trig_dly  (adb_ext_trig_dly[MXEXTDLY-1:0]),  // In  ADB  external trigger delay
  .dmb_ext_trig_dly  (dmb_ext_trig_dly[MXEXTDLY-1:0]),  // In  DMB  external trigger delay
  .clct_ext_trig_dly (clct_ext_trig_dly[MXEXTDLY-1:0]), // In  CLCT external trigger delay
  .alct_ext_trig_dly (alct_ext_trig_dly[MXEXTDLY-1:0]), // In  ALCT external trigger delay

// Sequencer Ports: pre-CLCT modifiers for L1A*preCLCT overlap
  .l1a_preClct_width (l1a_preClct_width[3:0]), // In  pre-CLCT window width for L1A*preCLCT overlap
  .l1a_preClct_dly   (l1a_preClct_dly[7:0]),   // In  pre-CLCT delay for L1A*preCLCT overlap

// Sequencer CLCT/RPC/RAT Pattern Injector
  .inj_trig_vme       (inj_trig_vme),                   // In  Start pattern injector
  .injector_mask_cfeb (injector_mask_cfeb[MXCFEB-1:0]), // In  Enable CFEB(n) for injector trigger
  .injector_mask_rat  (injector_mask_rat),              // In  Enable RAT for injector trigger
  .injector_mask_rpc  (injector_mask_rpc),              // In  Enable RPC for injector trigger
  .injector_mask_gem  (injector_mask_gem),              // In  Enable GEM for injector trigger
  .inj_delay_rat      (inj_delay_rat[3:0]),             // In  CFEB/RPC Injector waits for RAT injector
  .injector_go_cfeb   (injector_go_cfeb[MXCFEB-1:0]),   // Out  Start CFEB(n) pattern injector
  .injector_go_rat    (injector_go_rat),                // Out  Start RAT     pattern injector
  .injector_go_rpc    (injector_go_rpc),                // Out  Start RPC     pattern injector
  .injector_go_gem    (injector_go_gem),                // Out  Start GEM     pattern injector

// Sequencer Status from CFEBs
  .triad_skip           (triad_skip[MXCFEB-1:0]),                                    // In  Triads skipped
  .triad_tp             (triad_tp[MXCFEB-1:0]),                                      // In  Triad test point at raw hits RAM input
//.cfeb_badbits_found   (cfeb_badbits_found[MXCFEB-1:0]),                            // In  CFEB[n] has at least 1 bad bit
  .cfeb_badbits_found   (cfeb_badbits_found[MXCFEB-1:0] | link_had_err[MXCFEB-1:0]), // In  CFEB[n] has at least 1 bad bit or fiber error detected
  .cfeb_badbits_blocked (cfeb_badbits_blocked),                                      // In  A CFEB had bad bits that were blocked

  .cfebs_me1b_syncerr   (~cfebs_me1b_synced),   // In, ME1b links synced
  .cfebs_me1a_syncerr   (~cfebs_me1a_synced),   // In, ME1b links synced
// Sequencer Pattern Finder PreTrigger Ports
  .cfeb_hit    (cfeb_hit[MXCFEB-1:0]),    // In  This CFEB has a pattern over pre-trigger threshold
  .cfeb_active (cfeb_active[MXCFEB-1:0]), // In  CFEBs marked for DMB readout

  .cfeb_layer_trig  (cfeb_layer_trig),              // In  Layer pretrigger
  .cfeb_layer_or    (cfeb_layer_or[MXLY-1:0]),      // In  OR of hstrips on each layer
  .cfeb_nlayers_hit (cfeb_nlayers_hit[MXHITB-1:0]), // In  Number of CSC layers hit

    //Sequencer HMT
  .cfeb_allow_hmt_ro   (cfeb_allow_hmt_ro), //Out read out CFEB when hmt is fired
  .hmt_fired_pretrig   (hmt_fired_pretrig),         //In, hmt fired preCLCT bx
  .hmt_active_feb      (hmt_active_feb[MXCFEB-1:0]),//In hmt active cfeb flags
  .hmt_pretrig_match   (hmt_pretrig_match),        //In hmt & preCLCT
  .hmt_anode        (hmt_anode[MXHMTB-1:0]),// In HMT nhits for trigger
  .hmt_cathode      (hmt_cathode[MXHMTB-1:0]),// In HMT nhits for trigger
  .hmt_fired_xtmb   (hmt_fired_xtmb),         //In, hmt fired preCLCT bx
  .hmt_wr_avail_xtmb   (hmt_wr_avail_xtmb),//In hmt wr buf available
  .hmt_wr_adr_xtmb     (hmt_wr_adr_xtmb[MXBADR-1:0]),// In hmt wr adr at CLCt bx
  //.hmt_cathode_fired     (hmt_cathode_fired),// In
  //.hmt_anode_fired       (hmt_anode_fired),// In
  .hmt_anode_alct_match  (hmt_anode_alct_match), //In
  .hmt_cathode_alct_match(hmt_cathode_alct_match),// In
  .hmt_cathode_clct_match(hmt_cathode_clct_match),// In
  .hmt_cathode_lct_match (hmt_cathode_lct_match),// In

  .hmt_fired_cathode_only (hmt_fired_cathode_only),//In hmt is fired for cathode only
  .hmt_fired_anode_only   (hmt_fired_anode_only),//In hmt is fired for anode only
  .hmt_fired_match        (hmt_fired_match),//In hmt is fired for match
  .hmt_fired_or           (hmt_fired_or),//In hmt is fired for match

  .wr_adr_xpre_hmt        (wr_adr_xpre_hmt[MXBADR-1:0]),  //Out wr_adr at pretrigger for hmt
  .wr_push_xpre_hmt       (wr_push_xpre_hmt), //Out wr_push at pretrigger for hmt
  .wr_avail_xpre_hmt      (wr_avail_xpre_hmt),//Out wr_avail at pretrigger for hmt 

// Sequencer Pattern Finder CLCT results
  .hs_hit_1st (hs_hit_1st[MXHITB-1:0]),  // In  1st CLCT pattern hits
  .hs_pid_1st (hs_pid_1st[MXPIDB-1:0]),  // In  1st CLCT pattern ID
  .hs_key_1st (hs_key_1st[MXKEYBX-1:0]), // In  1st CLCT key 1/2-strip

  .hs_bnd_1st (hs_bnd_1st[MXBNDB - 1   : 0]),
  .hs_xky_1st (hs_xky_1st[MXXKYB-1 : 0]),
  .hs_carry_1st (hs_carry_1st[MXPATC-1:0]),
  .hs_run2pid_1st (hs_run2pid_1st[MXPIDB-1:0]),  // In  1st CLCT pattern ID  
  .hs_gemAxky_1st (hs_gemAxky_1st[MXXKYB-1 : 0]), //In 1st extrapolated CLCt location in gemA
  .hs_gemBxky_1st (hs_gemBxky_1st[MXXKYB-1 : 0]),

  .hs_hit_2nd (hs_hit_2nd[MXHITB-1:0]),  // In  2nd CLCT pattern hits
  .hs_pid_2nd (hs_pid_2nd[MXPIDB-1:0]),  // In  2nd CLCT pattern ID
  .hs_key_2nd (hs_key_2nd[MXKEYBX-1:0]), // In  2nd CLCT key 1/2-strip
  .hs_bsy_2nd (hs_bsy_2nd),              // In  2nd CLCT busy, logic error indicator

  .hs_bnd_2nd (hs_bnd_2nd[MXBNDB - 1   : 0]),
  .hs_xky_2nd (hs_xky_2nd[MXXKYB-1 : 0]),
  .hs_carry_2nd (hs_carry_2nd[MXPATC-1:0]),
  .hs_run2pid_2nd (hs_run2pid_2nd[MXPIDB-1:0]),  // In  1st CLCT pattern ID
  .hs_gemAxky_2nd (hs_gemAxky_2nd[MXXKYB-1 : 0]), //In 1st extrapolated CLCt location in gemA
  .hs_gemBxky_2nd (hs_gemBxky_2nd[MXXKYB-1 : 0]),

  .hs_layer_trig  (hs_layer_trig),              // In  Layer triggered
  .hs_nlayers_hit (hs_nlayers_hit[MXHITB-1:0]), // In  Number of layers hit
  .hs_layer_or    (hs_layer_or[MXLY-1:0]),      // In  Layer ORs

// Sequencer DMB Ports
  .alct_dmb        (alct_dmb[18:0]),       // In  ALCT to DMB
  .dmb_tx_reserved (dmb_tx_reserved[2:0]), // In  DMB backplane reserved
  .dmb_tx          (dmb_tx[MXDMB-1:0]),    // Out if "BPI Active" then to "BPI Flash PROM Address connector", else to "DMB backplane connector": going to outside
  .bpi_ad_out      (bpi_ad_out),           // In  [22:0] BPI Flash PROM Address: coming from vme
  .bpi_active      (bpi_active),           // In  BPI Active: coming from vme

// Sequencer ALCT Status
  .alct_cfg_done (alct_cfg_done), // In  ALCT FPGA configuration done

// Sequencer CSC Orientation Ports
  .csc_me1ab       (csc_me1ab),       // In  1=ME1A or ME1B CSC type
  .stagger_hs_csc  (stagger_hs_csc),  // In  1=Staggered CSC, 0=non-staggered
  .reverse_hs_csc  (reverse_hs_csc),  // In  1=Reverse staggered CSC, non-me1
  .reverse_hs_me1a (reverse_hs_me1a), // In  1=reverse me1a hstrips prior to pattern sorting
  .reverse_hs_me1b (reverse_hs_me1b), // In  1=reverse me1b hstrips prior to pattern sorting

// Sequencer CLCT VME Configuration Ports
  .clct_blanking      (clct_blanking),                 // In  clct_blanking=1 clears clcts with 0 hits
  .bxn_offset_pretrig (bxn_offset_pretrig[MXBXN-1:0]), // In  BXN offset at reset, for pretrig bxn
  .bxn_offset_l1a     (bxn_offset_l1a[MXBXN-1:0]),     // In  BXN offset at reset, for L1A bxn
  .lhc_cycle          (lhc_cycle[MXBXN-1:0]),          // In  LHC period, max BXN count+1
  .l1a_offset         (l1a_offset[MXL1ARX-1:0]),       // In  L1A counter preset value
  .drift_delay        (drift_delay[MXDRIFT-1:0]),      // In  CSC Drift delay clocks
  .triad_persist      (triad_persist[3:0]),            // In  Triad 1/2-strip persistence

  .lyr_thresh_pretrig   (lyr_thresh_pretrig[MXHITB-1:0]),   // In  Layers hit pre-trigger threshold
  .hit_thresh_pretrig   (hit_thresh_pretrig[MXHITB-1:0]),   // In  Hits on pattern template pre-trigger threshold
  .pid_thresh_pretrig   (pid_thresh_pretrig[MXPIDB-1:0]),   // In  Pattern shape ID pre-trigger threshold
  .dmb_thresh_pretrig   (dmb_thresh_pretrig[MXHITB-1:0]),   // In  Hits on pattern template DMB active-feb threshold
  .hit_thresh_postdrift (hit_thresh_postdrift[MXHITB-1:0]), // In  Minimum pattern hits for a valid pattern
  .pid_thresh_postdrift (pid_thresh_postdrift[MXPIDB-1:0]), // In  Minimum pattern ID   for a valid pattern

  .clct_flush_delay   (clct_flush_delay[MXFLUSH-1:0]), // In  Trigger sequencer flush state timer
  .clct_throttle      (clct_throttle[MXTHROTTLE-1:0]), // In  Pre-trigger throttle to reduce trigger rate
  .clct_wr_continuous (clct_wr_continuous),            // In  1=allow continuous header buffer writing for invalid triggers

  .alct_delay  (alct_delay[3:0]),  // In  Delay ALCT for CLCT match window
  .clct_window (clct_window[3:0]), // In  CLCT match window width
  .algo2016_clct_window (algo2016_window[3:0]), // CLCT-centric matching window size
  .algo2016_clct_to_alct (algo2016_clct_to_alct), // switch to CLCT-centric matching window or not
   
  .algo2016_use_dead_time_zone         (algo2016_use_dead_time_zone),         // In Dead time zone switch: 0 - "old" whole chamber is dead when pre-CLCT is registered, 1 - algo2016 only half-strips around pre-CLCT are marked dead
  .algo2016_dead_time_zone_size        (algo2016_dead_time_zone_size[4:0]),   // In Constant size of the dead time zone
  .algo2016_use_dynamic_dead_time_zone (algo2016_use_dynamic_dead_time_zone), // In Dynamic dead time zone switch: 0 - dead time zone is set by algo2016_use_dynamic_dead_time_zone, 1 - dead time zone depends on pre-CLCT pattern ID

  .tmb_allow_alct  (tmb_allow_alct),  // In  Allow ALCT only
  .tmb_allow_clct  (tmb_allow_clct),  // In  Allow CLCT only
  .tmb_allow_match (tmb_allow_match), // In  Allow ALCT+CLCT match

  .tmb_allow_alct_ro  (tmb_allow_alct_ro),  // In  Allow ALCT only  readout, non-triggering
  .tmb_allow_clct_ro  (tmb_allow_clct_ro),  // In  Allow CLCT only  readout, non-triggering
  .tmb_allow_match_ro (tmb_allow_match_ro), // In  Allow Match only readout, non-triggering


  .gemcsc_bend_enable       (gemcsc_bend_enable),             //In GEMCSC bending angle enabled
  .match_gem_alct_delay      (match_gem_alct_delay[7:0]),  //In gem delay for gem-ALCT match
  .gemA_forclct_real         (gemA_forclct_real[7:0]),
  .gemB_forclct_real         (gemB_forclct_real[7:0]),
  .copad_match_real          ( copad_match_real[7:0]),
  .gemA_overflow_real        (gemA_overflow_real),//  IN, latched for headers
  .gemB_overflow_real        (gemB_overflow_real),
  .gemA_sync_err_real        (gemA_sync_err_real),
  .gemB_sync_err_real        (gemB_sync_err_real),
  .gems_sync_err_real        (gems_sync_err_real),
  .tmb_gem_clct_win          (tmb_gem_clct_win[3:0]), // In gem location in GEM-CLCT window
  .tmb_alct_gem_win          (tmb_alct_gem_win[2:0]), // In gem location in GEM-ALCT window
  .tmb_hmt_match_win         (tmb_hmt_match_win[3:0]), //In  alct/anode hmt in cathode hmt tagged window

  .mpc_tx_delay    (mpc_tx_delay[MXMPCDLY-1:0]), // In  MPC transmit delay
  .mpc_sel_ttc_bx0 (mpc_sel_ttc_bx0),            // In  MPC gets ttc_bx0 or bx0_local
  .pretrig_halt    (pretrig_halt),               // In  Pretrigger and halt until unhalt arrives

  .uptime    (uptime[15:0]),    // Out  Uptime since last hard reset
  .bd_status (bd_status[14:0]), // In  Board status summary

  .board_id (board_id[MXBDID-1:0]), // In  Board ID = VME Slot
  .csc_id   (csc_id[MXCSC-1:0]),    // In  CSC Chamber ID number
  .run_id   (run_id[MXRID-1:0]),    // In  Run ID

  .l1a_delay        (l1a_delay[MXL1DELAY-1:0]),       // In  Level1 Accept delay from pretrig status output
  .l1a_internal     (l1a_internal),                   // In  Generate internal Level 1, overrides external
  .l1a_internal_dly (l1a_internal_dly[MXL1WIND-1:0]), // In   Delay internal l1a to shift position in l1a match windwow
  .l1a_window       (l1a_window[MXL1WIND-1:0]),       // In  Level1 Accept window width after delay
  .l1a_win_pri_en   (l1a_win_pri_en),                 // In  Enable L1A window priority
  .l1a_lookback     (l1a_lookback[MXBADR-1:0]),       // In  Bxn to look back from l1a wr_buf_adr
  .l1a_preset_sr    (l1a_preset_sr),                  // In  Dummy VME bit to feign preset l1a sr group

  .l1a_allow_match     (l1a_allow_match),     // In  Readout allows tmb trig pulse in L1A window (normal mode)
  .l1a_allow_notmb     (l1a_allow_notmb),     // In  Readout allows no tmb trig pulse in L1A window
  .l1a_allow_nol1a     (l1a_allow_nol1a),     // In  Readout allows tmb trig pulse outside L1A window
  .l1a_allow_alct_only (l1a_allow_alct_only), // In  Allow alct_only events to readout at L1A

  .fifo_mode         (fifo_mode[MXFMODE-1:0]),        // In  FIFO Mode 0=no dump,1=full,2=local,3=sync
  .fifo_tbins_cfeb   (fifo_tbins_cfeb[MXTBIN-1:0]),   // In  Number CFEB FIFO time bins to read out
  .fifo_pretrig_cfeb (fifo_pretrig_cfeb[MXTBIN-1:0]), // In  Number CFEB FIFO time bins before pretrigger

  .seq_trigger     (seq_trigger),           // Out  Sequencer requests L1A from CCB
  .sequencer_state (sequencer_state[11:0]), // Out  Sequencer state for vme
  .seq_trigger_nodeadtime (seq_trigger_nodeadtime),  //In no dead time for seq-trigger

  .event_clear_vme (event_clear_vme),         // In  Event clear for aff,clct,mpc vme diagnostic registers
  .clct0_vme       (clct0_vme[MXCLCT-1:0]),   // Out  First  CLCT
  .clct1_vme       (clct1_vme[MXCLCT-1:0]),   // Out  Second CLCT
  .clctc_vme       (clctc_vme[MXCLCTC-1:0]),  // Out  Common to CLCT0/1 to TMB
  .clctf_vme       (clctf_vme[MXCFEB-1:0]),   // Out  Active cfeb list from TMB match
  .trig_source_vme (trig_source_vme[10:0]),   // Out  Trigger source readback
  .nlayers_hit_vme (nlayers_hit_vme[2:0]),    // Out  Number layers hit on layer trigger
  .bxn_clct_vme    (bxn_clct_vme[MXBXN-1:0]), // Out  CLCT BXN at pre-trigger
  .bxn_l1a_vme     (bxn_l1a_vme[MXBXN-1:0]),  // Out  CLCT BXN at L1A

  .clct0_vme_bnd   (clct0_vme_bnd[MXBNDB - 1   : 0]), // Out, clct0 new bending 
  .clct0_vme_xky   (clct0_vme_xky[MXXKYB-1 : 0]),     // Out, clct0 new position with 1/8 strip resolution
  .clct0_vme_carry (clct0_vme_carry[MXPATC-1   : 0]), // Out ,clct0 comparator code
  .clct1_vme_bnd   (clct1_vme_bnd[MXBNDB - 1   : 0]),  // out 
  .clct1_vme_xky   (clct1_vme_xky[MXXKYB-1 : 0]),     // out
  .clct1_vme_carry (clct1_vme_carry[MXPATC-1   : 0]),  // out
// Sequencer RPC VME Configuration Ports
  .rpc_exists       (rpc_exists[MXRPC-1:0]),        // In  RPC Readout list
  .rpc_read_enable  (rpc_read_enable),              // In  1 Enable RPC Readout
  .fifo_tbins_rpc   (fifo_tbins_rpc[MXTBIN-1:0]),   // In  Number RPC FIFO time bins to read out
  .fifo_pretrig_rpc (fifo_pretrig_rpc[MXTBIN-1:0]), // In  Number RPC FIFO time bins before pretrigger

// Sequencer GEM VME Configuration Ports
  .gem_read_enable   (gem_read_enable),              // In  1 Enable GEM Readout
  //.gem_exists        (gem_exists [MXGEM-1:0]),       // In  GEM Existence List
  .gem_read_mask     (gem_read_mask [MXGEM-1:0]),       // In  GEM Readout List
  .gem_zero_suppress (gem_zero_suppress),            // In  1 Enable GEM Readout
  .fifo_tbins_gem    (fifo_tbins_gem[MXTBIN-1:0]),   // In  Number GEM FIFO time bins to read out
  .fifo_pretrig_gem  (fifo_pretrig_gem[MXTBIN-1:0]), // In  Number GEM FIFO time bins before pretrigger

// Sequencer Status signals to CCB front panel
  .clct_status    (clct_status[8:0]),      // Out  Array of stat_ signals for CCB

// Sequencer Scintillator Veto
  .scint_veto_clr (scint_veto_clr), // In  Clear scintillator veto ff
  .scint_veto     (scint_veto),     // Out  Scintillator veto for FAST Sites
  .scint_veto_vme (scint_veto_vme), // Out  Scintillator veto for FAST Sites, VME copy

// Sequencer Front Panel CLCT LEDs:
  .led_lct         (led_lct),         // Out  LCT    Blue  LCT match
  .led_alct        (led_alct),        // Out  ALCT  Green  ALCT valid pattern
  .led_clct        (led_clct),        // Out  CLCT  Green  CLCT valid pattern
  .led_l1a_intime  (led_l1a_intime),  // Out  L1A    Green  Level 1 Accept from CCB or internal
  .led_invpat      (led_invpat),      // Out  INVP  Amber  Invalid pattern after drift delay
  .led_nomatch     (led_nomatch),     // Out  NMAT  Amber  ALCT or CLCT but no match
  .led_nol1a_flush (led_nol1a_flush), // Out  NL1A  Red    L1A did not arrive in window

// Sequencer On Board LEDs
  .led_bd      (led_bd[7:0]),        // Out  On-board LEDs

// Sequencer Buffer Write Control
  .buf_reset     (buf_reset),                  // Out  Free all buffer space
  .buf_push      (buf_push),                   // Out  Allocate write buffer
  .buf_push_adr  (buf_push_adr[MXBADR-1:0]),   // Out  Address of write buffer to allocate
  .buf_push_data (buf_push_data[MXBDATA-1:0]), // Out  Data associated with push_adr

  .wr_buf_ready (wr_buf_ready),           // In  Write buffer is ready
  .wr_buf_adr   (wr_buf_adr[MXBADR-1:0]), // In  Current address of header write buffer

// Sequencer Fence buffer adr and data at head of queue
  .buf_queue_adr  (buf_queue_adr[MXBADR-1:0]),   // In  Buffer address of fence queued for readout
  .buf_queue_data (buf_queue_data[MXBDATA-1:0]), // In  Data associated with queue adr

// Sequencer Buffer Read Control
  .buf_pop     (buf_pop),                 // Out  Specified buffer is to be released
  .buf_pop_adr (buf_pop_adr[MXBADR-1:0]), // Out  Address of read buffer to release

// Sequencer Buffer Status
  .buf_q_full         (buf_q_full),                       // In  All raw hits ram in use, ram writing must stop
  .buf_q_empty        (buf_q_empty),                      // In  No fences remain on buffer stack
  .buf_q_ovf_err      (buf_q_ovf_err),                    // In  Tried to push when stack full
  .buf_q_udf_err      (buf_q_udf_err),                    // In  Tried to pop when stack empty
  .buf_q_adr_err      (buf_q_adr_err),                    // In  Fence adr popped from stack doesnt match rls adr
  .buf_stalled        (buf_stalled),                      // In  Buffer write pointer hit a fence and is stalled now
  .buf_stalled_once   (buf_stalled_once),                 // In  Buffer stalled at least once since last resync
  .buf_fence_dist     (buf_fence_dist[MXBADR-1:0]),       // In  Current distance to next fence 0 to 2047
  .buf_fence_cnt      (buf_fence_cnt[MXBADR-1+1:0]),      // In  Number of fences in fence RAM currently
  .buf_fence_cnt_peak (buf_fence_cnt_peak[MXBADR-1+1:0]), // In  Peak number of fences in fence RAM
  .buf_display        (buf_display[7:0]),                 // In  Buffer fraction in use display

// Sequencer CFEB Sequencer Readout Control
  .rd_start_cfeb (rd_start_cfeb),             // Out  Initiates a FIFO readout
  .rd_abort_cfeb (rd_abort_cfeb),             // Out  Abort FIFO dump
  .rd_list_cfeb  (rd_list_cfeb[MXCFEB-1:0]),  // Out  List of CFEBs to read out
  .rd_ncfebs     (rd_ncfebs[MXCFEBB-1:0]),    // Out  Number of CFEBs in feb_list (4 or 5 depending on CSC type)
  .rd_fifo_adr   (rd_fifo_adr[RAM_ADRB-1:0]), // Out  RAM address at pre-trig, must be valid 1bx before rd_start

// Sequencer CFEB Blockedbits Readout Control
  .rd_start_bcb  (rd_start_bcb),               // Out  Start readout sequence
  .rd_abort_bcb  (rd_abort_bcb),               // Out  Cancel readout
  .rd_list_bcb   (rd_list_bcb[MXCFEB-1:0]),    // Out  List of CFEBs to read out
  .rd_ncfebs_bcb (rd_ncfebs_bcb[MXCFEBB-1:0]), // Out  Number of CFEBs in bcb_list (0 to 5)

// Sequencer RPC Sequencer Readout Control
  .rd_start_gem  (rd_start_gem),                // Out  Start readout sequence
  .rd_abort_gem  (rd_abort_gem),                // Out  Cancel readout
  .rd_list_gem   (rd_list_gem[MXGEM-1:0]),      // Out  List of GEMs to read out
  .rd_ngems      (rd_ngems[MXGEMB-1+1:0]),      // Out  Number of GEMs in gem_list (0 or 1-to-2 depending on CSC type)
  .rd_gem_offset (rd_gem_offset[RAM_ADRB-1:0]), // Out  RAM address rd_fifo_adr offset for gem read out

// Sequencer RPC Sequencer Readout Control
  .rd_start_rpc  (rd_start_rpc),                // Out  Start readout sequence
  .rd_abort_rpc  (rd_abort_rpc),                // Out  Cancel readout
  .rd_list_rpc   (rd_list_rpc[MXRPC-1:0]),      // Out  List of RPCs to read out
  .rd_nrpcs      (rd_nrpcs[MXRPCB-1+1:0]),      // Out  Number of RPCs in rpc_list (0 or 1-to-2 depending on CSC type)
  .rd_rpc_offset (rd_rpc_offset[RAM_ADRB-1:0]), // Out  RAM address rd_fifo_adr offset for rpc read out
  .clct_pretrig  (clct_pretrig),                // Out  Pre-trigger marker at (clct_sm==pretrig)

// Sequencer CFEB Sequencer Frame
  .cfeb_first_frame (cfeb_first_frame),      // In  First frame valid 2bx after rd_start
  .cfeb_last_frame  (cfeb_last_frame),       // In  Last frame valid 1bx after busy goes down
  .cfeb_adr         (cfeb_adr[MXCFEBB-1:0]), // In  FIFO dump CFEB ID
  .cfeb_tbin        (cfeb_tbin[MXTBIN-1:0]), // In  FIFO dump Time Bin #
  .cfeb_rawhits     (cfeb_rawhits[7:0]),     // In  Layer data from FIFO
  .cfeb_fifo_busy   (cfeb_fifo_busy),        // In  Readout busy sending data to sequencer, goes down 1bx

// Sequencer CFEB Blockedbits Frame
  .bcb_read_enable (bcb_read_enable),           // In  Enable blocked bits in readout
  .bcb_first_frame (bcb_first_frame),           // In  First frame valid 2bx after rd_start
  .bcb_last_frame  (bcb_last_frame),            // In  Last frame valid 1bx after busy goes down
  .bcb_blkbits     (bcb_blkbits[11:0]),         // In  CFEB blocked bits frame data
  .bcb_cfeb_adr    (bcb_cfeb_adr[MXCFEBB-1:0]), // In  CFEB ID
  .bcb_fifo_busy   (bcb_fifo_busy),             // In  Readout busy sending data to sequencer, goes down 1bx early

// Sequencer GEM Sequencer Frame
  .gem_first_frame (gem_first_frame),     // In  First frame valid 2bx after rd_start
  .gem_last_frame  (gem_last_frame),      // In  Last frame valid 1bx after busy goes down
  .gem_adr         (gem_adr[MXGEMB-1:0]), // In  FIFO dump GEM Fiber ID (0,1,2,3)
  .gem_id          (gem_id),              // In  FIFO dump GEM Chamber ID (0,1)
  .gem_rawhits     (gem_rawhits[13:0]),   // In  FIFO dump GEM pad hits
  .gem_fifo_busy   (gem_fifo_busy),       // In  Readout busy sending data to sequencer, goes down 1bx

// Sequencer RPC Sequencer Frame
  .rpc_first_frame (rpc_first_frame),         // In  First frame valid 2bx after rd_start
  .rpc_last_frame  (rpc_last_frame),          // In  Last frame valid 1bx after busy goes down
  .rpc_adr         (rpc_adr[MXRPCB-1:0]),     // In  FIFO dump RPC ID
  .rpc_tbinbxn     (rpc_tbinbxn[MXTBIN-1:0]), // In  FIFO dump RPC tbin or bxn for DMB
  .rpc_rawhits     (rpc_rawhits[7:0]),        // In  FIFO dump RPC pad hits, 8 of 16 per cycle
  .rpc_fifo_busy   (rpc_fifo_busy),           // In  Readout busy sending data to sequencer, goes down 1bx

// Sequencer CLCT Raw Hits RAM
  .dmb_wr       (dmb_wr),                   // In  Raw hits RAM VME write enable
  .dmb_reset    (dmb_reset),                // In  Raw hits RAM VME address reset
  .dmb_adr      (dmb_adr[MXRAMADR-1:0]),    // In  Raw hits RAM VME read/write address
  .dmb_wdata    (dmb_wdata[MXRAMDATA-1:0]), // In  Raw hits RAM VME write data
  .dmb_rdata    (dmb_rdata[MXRAMDATA-1:0]), // Out  Raw hits RAM VME read data
  .dmb_wdcnt    (dmb_wdcnt[MXRAMADR-1:0]),  // Out  Raw hits RAM VME word count
  .dmb_busy     (dmb_busy),                 // Out  Raw hits RAM VME busy writing DMB data
  .read_sm_xdmb (read_sm_xdmb),             // Out  TMB sequencer starting a readout

// Sequencer TMB-Sequencer Pipelines
  .wr_adr_xtmb (wr_adr_xtmb[MXBADR-1:0]), // Out  Buffer write address after drift time
  .wr_adr_rtmb (wr_adr_rtmb[MXBADR-1:0]), // In  Buffer write address at TMB matching time
  .wr_adr_xmpc (wr_adr_xmpc[MXBADR-1:0]), // In  Buffer write address at MPC xmit to sequencer
  .wr_adr_rmpc (wr_adr_rmpc[MXBADR-1:0]), // In  Buffer write address at MPC received

  .wr_push_xtmb (wr_push_xtmb), // Out  Buffer write strobe after drift time
  .wr_push_rtmb (wr_push_rtmb), // In  Buffer write strobe at TMB matching time
  .wr_push_xmpc (wr_push_xmpc), // In  Buffer write strobe at MPC xmit to sequencer
  .wr_push_rmpc (wr_push_rmpc), // In  Buffer write strobe at MPC received

  .wr_avail_xtmb (wr_avail_xtmb), // Out  Buffer available after drift time
  .wr_avail_rtmb (wr_avail_rtmb), // In  Buffer available at TMB matching time
  .wr_avail_xmpc (wr_avail_xmpc), // In  Buffer available at MPC xmit to sequencer
  .wr_avail_rmpc (wr_avail_rmpc), // In  Buffer available at MPC received

// Sequencer TMB LCT Match results
  .clct0_xtmb (clct0_xtmb[MXCLCT-1:0]),  // Out  First  CLCT
  .clct1_xtmb (clct1_xtmb[MXCLCT-1:0]),  // Out  Second CLCT
  .clctc_xtmb (clctc_xtmb[MXCLCTC-1:0]), // Out  Common to CLCT0/1 to TMB
  .clctf_xtmb (clctf_xtmb[MXCFEB-1:0]),  // Out  Active cfeb list to TMB
  .clct0_bnd_xtmb   (clct0_bnd_xtmb[MXBNDB - 1   : 0]),
  .clct0_xky_xtmb   (clct0_xky_xtmb[MXXKYB-1 : 0]),
  .clct0_gemAxky_xtmb   (clct0_gemAxky_xtmb[MXXKYB-1 : 0]),
  .clct0_gemBxky_xtmb   (clct0_gemBxky_xtmb[MXXKYB-1 : 0]),
  //.clct0_carry_xtmb (clct0_carry_xtmb[MXPATC-1:0]),  // Out  First  CLCT
  .clct1_bnd_xtmb   (clct1_bnd_xtmb[MXBNDB - 1   : 0]),
  .clct1_xky_xtmb   (clct1_xky_xtmb[MXXKYB-1 : 0]),
  .clct1_gemAxky_xtmb   (clct1_gemAxky_xtmb[MXXKYB-1 : 0]),
  .clct1_gemBxky_xtmb   (clct1_gemBxky_xtmb[MXXKYB-1 : 0]),
  //.clct1_carry_xtmb (clct1_carry_xtmb[MXPATC-1:0]),  // Out  Second CLCT
  .bx0_xmpc         (bx0_xmpc),                // Out  bx0 to tmb aligned with clct0/1
  .bx0_match        (bx0_match),               // In  ALCT bx0 and CLCT bx0 match in time
  .bx0_match2       (bx0_match2),               // In  ALCT bx0 and CLCT bx0 match in time
  .gemA_bx0_match   (gemA_bx0_match),      // In GEMA+CLCT BX0 match
  .gemA_bx0_match2  (gemA_bx0_match2),      // In GEMA+CLCT BX0 match
  .gemB_bx0_match   (gemB_bx0_match),      // In GEMA+CLCT BX0 match
  .gemB_bx0_match2  (gemB_bx0_match2),      // In GEMA+CLCT BX0 match

  .tmb_trig_pulse    (tmb_trig_pulse),           // In  ALCT or CLCT or both triggered
  .tmb_trig_keep     (tmb_trig_keep),            // In  ALCT or CLCT or both triggered, and trigger is allowed
  .tmb_non_trig_keep (tmb_non_trig_keep),        // In  Event did not trigger, but keep it for readout
  .tmb_match         (tmb_match),                // In  ALCT and CLCT matched in time
  .tmb_alct_only     (tmb_alct_only),            // In  Only ALCT triggered
  .tmb_clct_only     (tmb_clct_only),            // In  Only CLCT triggered
  .tmb_match_win     (tmb_match_win[3:0]),       // In  Location of alct in clct window
  .tmb_match_pri     (tmb_match_pri[3:0]),       // In  Priority of clct in clct window
  .tmb_alct_discard  (tmb_alct_discard),         // In  ALCT pair was not used for LCT
  .tmb_clct_discard  (tmb_clct_discard),         // In  CLCT pair was not used for LCT
  .tmb_clct0_discard (tmb_clct0_discard),        // In  CLCT0 was not used for LCT because from ME1A
  .tmb_clct1_discard (tmb_clct1_discard),        // In  CLCT1 was not used for LCT because from ME1A
  .tmb_aff_list      (tmb_aff_list[MXCFEB-1:0]), // In  Active CFEBs for CLCT used in TMB match
  .hmt_fired_tmb_ff  (hmt_fired_tmb_ff),         // In  hmt fired tmb
  .hmt_readout_tmb_ff(hmt_readout_tmb_ff),       // In hmt fired for readout
  .tmb_pulse_hmt_only(tmb_pulse_hmt_only),       // In tmb pulse is from HMT
  .tmb_keep_hmt_only (tmb_keep_hmt_only),        // In tmb keep is from HMT
 
  .tmb_match_ro     (tmb_match_ro),     // In  ALCT and CLCT matched in time, non-triggering readout
  .tmb_alct_only_ro (tmb_alct_only_ro), // In  Only ALCT triggered, non-triggering readout
  .tmb_clct_only_ro (tmb_clct_only_ro), // In  Only CLCT triggered, non-triggering readout

  .tmb_no_alct   (tmb_no_alct),   // In  No  ALCT
  .tmb_no_clct   (tmb_no_clct),   // In  No  CLCT
  .tmb_one_alct  (tmb_one_alct),  // In  One ALCT
  .tmb_one_clct  (tmb_one_clct),  // In  One CLCT
  .tmb_two_alct  (tmb_two_alct),  // In  Two ALCTs
  .tmb_two_clct  (tmb_two_clct),  // In  Two CLCTs
  .tmb_dupe_alct (tmb_dupe_alct), // In  ALCT0 copied into ALCT1 to make 2nd LCT
  .tmb_dupe_clct (tmb_dupe_clct), // In  CLCT0 copied into CLCT1 to make 2nd LCT
  .tmb_rank_err  (tmb_rank_err),  // In  LCT1 has higher quality than LCT0

  .tmb_alct0 (tmb_alct0[10:0]), // In  ALCT best muon latched at trigger
  .tmb_alct1 (tmb_alct1[10:0]), // In  ALCT second best muon latched at trigger
  .tmb_alctb (tmb_alctb[4:0]),  // In  ALCT bxn latched at trigger
  .tmb_alcte (tmb_alcte[1:0]),  // In  ALCT ecc error syndrome latched at trigger
  .tmb_cathode_hmt  (tmb_cathode_hmt[MXHMTB-1:0]),   //In cathode hmt
  .hmt_nhits_sig_ff (hmt_nhits_sig_ff[NHMTHITB-1:0]), // In hmt nhits for header

       //GEM-CSC match output, time_only
  .gem_enable           (gem_enable),
  .gemA_alct_pulse_match      (gemA_alct_pulse_match), // In Gem alct/clct match in timing only 
  .gemB_alct_pulse_match      (gemB_alct_pulse_match), // In Gem alct/clct match in timing only
  .gemA_clct_pulse_match      (gemA_clct_pulse_match), // In Gem alct/clct match in timing only
  .gemB_clct_pulse_match      (gemB_clct_pulse_match), // In Gem alct/clct match in timing only

  .alct_gem_pulse          (alct_gem_pulse), // Out GEM-CSC matching in timing only 
  .clct_gem_pulse          (clct_gem_pulse), // Out GEM-CSC matching in timing only
  .alct_clct_gemA_pulse    (alct_clct_gemA_pulse), // Out GEM-CSC matching in timing only
  .alct_clct_gemB_pulse    (alct_clct_gemB_pulse), // Out GEM-CSC matching in timing only
  .alct_clct_gem_pulse     (alct_clct_gem_pulse), // Out GEM-CSC matching in timing only
  .alct_gem_noclct_pulse   (alct_gem_noclct_pulse), // Out GEM-CSC matching in timing only
  .clct_gem_noalct_pulse   (alct_gem_noalct_pulse), // Out GEM-CSC matching in timing only
  .alct_copad_noclct_pulse (alct_copad_noclct_pulse), // Out GEM-CSC matching in timing only
  .clct_copad_noalct_pulse (clct_copad_noalct_pulse), // Out GEM-CSC matching in timing only

        //GEM-CSC match output, time_+ position
  .alct_gemA_match_pos       (alct_gemA_match_pos),// Out GEM-CSC matching in timing and position
  .alct_gemB_match_pos       (alct_gemB_match_pos),// Out GEM-CSC matching in timing and position
  .clct_gemA_match_pos       (clct_gemA_match_pos),// Out GEM-CSC matching in timing and position
  .clct_gemB_match_pos       (clct_gemB_match_pos),// Out GEM-CSC matching in timing and position
  .alct_copad_match_pos      (alct_copad_match_pos),// Out GEM-CSC matching in timing and position
  .clct_copad_match_pos      (clct_copad_match_pos),// Out GEM-CSC matching in timing and position
  .alct_clct_copad_match_pos (alct_clct_copad_match_pos),// Out GEM-CSC matching in timing and position  
  .alct_clct_gemA_match_pos  (alct_clct_gemA_match_pos),// Out GEM-CSC matching in timing and position
  .alct_clct_gemB_match_pos  (alct_clct_gemB_match_pos),// Out GEM-CSC matching in timing and position
  .tmb_dupe_alct_run3        (tmb_dupe_alct_run3),// Out GEMCSC match results  
  .tmb_dupe_clct_run3        (tmb_dupe_clct_run3),// Out GEMCSC match results  
  .alct0fromcopad_run3       (alct0fromcopad_run3),// Out GEMCSC match results 
  .alct1fromcopad_run3       (alct1fromcopad_run3),// Out GEMCSC match results 
  .clct0fromcopad_run3       (clct0fromcopad_run3),// Out GEMCSC match results 
  .clct1fromcopad_run3       (clct1fromcopad_run3),// Out GEMCSC match results 
  .alctclctcopad_swapped     (alctclctcopad_swapped), // in, ALCT/CLCT swapped from ACLT+CLCT+copad match
  .alctclctgem_swapped       (alctclctgem_swapped),   // in, ALCT/CLCT swapped from ACLT+CLCT+gem match
  .clctcopad_swapped         (clctcopad_swapped),          // in, CLCT swapped from CLCT+copad match
  .delayalct_gemA_match_test (delayalct_gemA_match_test), //In ALCT & GEM match for test
  .delayalct_gemB_match_test (delayalct_gemB_match_test), //In ALCT & GEM match for test
  .alct_delaygemA_match_test (alct_delaygemA_match_test), //In ALCT & GEM match for test
  .alct_delaygemB_match_test (alct_delaygemB_match_test), //In ALCT & GEM match for test

  .lct0_nogem        (lct0_nogem),     //In LCT0 without gem match found
  .lct0_with_gemA    (lct0_with_gemA), //In LCT0 with gem match 
  .lct0_with_gemB    (lct0_with_gemB), //In LCT0 with gem match
  .lct0_with_copad   (lct0_with_copad), //In LCT0 with gem match,
  .lct1_nogem        (lct1_nogem),     //In LCT1 without gem match found
  .lct1_with_gemA    (lct1_with_gemA), //In LCT1 with gem match
  .lct1_with_gemB    (lct1_with_gemB), //In LCT1 with gem match
  .lct1_with_copad   (lct1_with_copad), //In LCT1 with gem match,

  .ccLUT_enable  (ccLUT_enable),//In enabe CCLUT   
  .run3_trig_df  (run3_trig_df), //In
  .run3_daq_df   (run3_daq_df), // In
  .run3_alct_df  (run3_alct_df), // In
// Sequencer MPC Status
  .mpc_frame_ff   (mpc_frame_ff),                // In  MPC frame latch strobe
  .mpc0_frame0_ff (mpc0_frame0_ff[MXFRAME-1:0]), // In  MPC best muon 1st frame
  .mpc0_frame1_ff (mpc0_frame1_ff[MXFRAME-1:0]), // In  MPC best buon 2nd frame
  .mpc1_frame0_ff (mpc1_frame0_ff[MXFRAME-1:0]), // In  MPC second best muon 1st frame
  .mpc1_frame1_ff (mpc1_frame1_ff[MXFRAME-1:0]), // In  MPC second best buon 2nd frame

  .mpc_xmit_lct0 (mpc_xmit_lct0), // In  MPC LCT0 sent
  .mpc_xmit_lct1 (mpc_xmit_lct1), // In  MPC LCT1 sent

  .mpc_response_ff  (mpc_response_ff),      // In  MPC accept latch strobe
  .mpc_accept_ff    (mpc_accept_ff[1:0]),      // In  MPC muon accept response, latched
  .mpc_reserved_ff  (mpc_reserved_ff[1:0]),      // In  MPC reserved

// Sequencer TMB Status
  .alct0_vpf_tprt   (alct0_vpf_tprt),   // In  Timing test point, unbuffered real time for internal scope
  .alct1_vpf_tprt   (alct1_vpf_tprt),   // In  Timing test point
  .clct_vpf_tprt    (clct_vpf_tprt),    // In  Timing test point
  .clct_window_tprt (clct_window_tprt), // In  Timing test point

// Sequencer Firmware Version
  .revcode (revcode[14:0]), // In  Firmware revision code

// Sequencer RPC/ALCT Scope
  .scp_rpc0_bxn   (scp_rpc0_bxn[2:0]),   // In  RPC0 bunch crossing number
  .scp_rpc1_bxn   (scp_rpc1_bxn[2:0]),   // In  RPC1 bunch crossing number
  .scp_rpc0_nhits (scp_rpc0_nhits[3:0]), // In  RPC0 number of pads hit
  .scp_rpc1_nhits (scp_rpc1_nhits[3:0]), // In  RPC1 number of pads hit
  .scp_alct_rx    (scp_alct_rx[55:0]),   // In  ALCT received signals to scope

// Sequencer Scope
  .scp_runstop    (scp_runstop),         // In  1=run 0=stop
  .scp_auto       (scp_auto),            // In  Sequencer readout mode
  .scp_ch_trig_en (scp_ch_trig_en),      // In  Enable channel triggers
  .scp_trigger_ch (scp_trigger_ch[7:0]), // In  Trigger channel 0-159
  .scp_force_trig (scp_force_trig),      // In  Force a trigger
  .scp_ch_overlay (scp_ch_overlay),      // In  Channel source overlay
  .scp_ram_sel    (scp_ram_sel[3:0]),    // In  RAM bank select in VME mode
  .scp_tbins      (scp_tbins[2:0]),      // In  Time bins per channel code, actual tbins/ch = (tbins+1)*64
  .scp_radr       (scp_radr[8:0]),       // In  Channel data read address
  .scp_nowrite    (scp_nowrite),         // In  Preserves initial RAM contents for testing

  .scp_waiting   (scp_waiting),     // Out  Waiting for trigger
  .scp_trig_done (scp_trig_done),   // Out  Trigger done, ready for readout
  .scp_rdata     (scp_rdata[15:0]), // Out  Recorded channel data

// Sequencer Miniscope
  .mini_read_enable (mini_read_enable),                 // In  Enable Miniscope readout
  .mini_fifo_busy   (mini_fifo_busy),                   // In  Readout busy sending data to sequencer, goes down 1bx early
  .mini_first_frame (mini_first_frame),                 // In  First frame valid 2bx after rd_start
  .mini_last_frame  (mini_last_frame),                  // In  Last frame valid 1bx after busy goes down
  .mini_rdata       (mini_rdata[RAM_WIDTH*2-1:0]),      // In  FIFO dump miniscope
  .fifo_wdata_mini  (fifo_wdata_mini[RAM_WIDTH*2-1:0]), // Out  Miniscope FIFO RAM write data
  .wr_mini_offset   (wr_mini_offset[RAM_ADRB-1:0]),     // Out  RAM address offset for miniscope write

// Sequencer Mini Sequencer Readout Control
  .rd_start_mini  (rd_start_mini),                // Out  Start readout sequence
  .rd_abort_mini  (rd_abort_mini),                // Out  Cancel readout
  .rd_mini_offset (rd_mini_offset[RAM_ADRB-1:0]), // Out  RAM address rd_fifo_adr offset for miniscope read out

// Sequencer Trigger/Readout Counters
  .cnt_all_reset    (cnt_all_reset),    // In  Trigger/Readout counter reset
  .cnt_stop_on_ovf  (cnt_stop_on_ovf),  // In  Stop all counters if any overflows
  .cnt_non_me1ab_en (cnt_non_me1ab_en), // In  Allow clct pretrig counters count non me1ab
  .cnt_any_ovf_alct (cnt_any_ovf_alct), // In  At least one alct counter overflowed
  .cnt_any_ovf_seq  (cnt_any_ovf_seq),  // Out  At least one sequencer counter overflowed

  .event_counter13 (event_counter13[MXCNTVME-1:0]), // Out
  .event_counter14 (event_counter14[MXCNTVME-1:0]), // Out
  .event_counter15 (event_counter15[MXCNTVME-1:0]), // Out
  .event_counter16 (event_counter16[MXCNTVME-1:0]), // Out
  .event_counter17 (event_counter17[MXCNTVME-1:0]), // Out
  .event_counter18 (event_counter18[MXCNTVME-1:0]), // Out
  .event_counter19 (event_counter19[MXCNTVME-1:0]), // Out
  .event_counter20 (event_counter20[MXCNTVME-1:0]), // Out
  .event_counter21 (event_counter21[MXCNTVME-1:0]), // Out
  .event_counter22 (event_counter22[MXCNTVME-1:0]), // Out
  .event_counter23 (event_counter23[MXCNTVME-1:0]), // Out
  .event_counter24 (event_counter24[MXCNTVME-1:0]), // Out
  .event_counter25 (event_counter25[MXCNTVME-1:0]), // Out
  .event_counter26 (event_counter26[MXCNTVME-1:0]), // Out
  .event_counter27 (event_counter27[MXCNTVME-1:0]), // Out
  .event_counter28 (event_counter28[MXCNTVME-1:0]), // Out
  .event_counter29 (event_counter29[MXCNTVME-1:0]), // Out
  .event_counter30 (event_counter30[MXCNTVME-1:0]), // Out
  .event_counter31 (event_counter31[MXCNTVME-1:0]), // Out
  .event_counter32 (event_counter32[MXCNTVME-1:0]), // Out
  .event_counter33 (event_counter33[MXCNTVME-1:0]), // Out
  .event_counter34 (event_counter34[MXCNTVME-1:0]), // Out
  .event_counter35 (event_counter35[MXCNTVME-1:0]), // Out
  .event_counter36 (event_counter36[MXCNTVME-1:0]), // Out
  .event_counter37 (event_counter37[MXCNTVME-1:0]), // Out
  .event_counter38 (event_counter38[MXCNTVME-1:0]), // Out
  .event_counter39 (event_counter39[MXCNTVME-1:0]), // Out
  .event_counter40 (event_counter40[MXCNTVME-1:0]), // Out
  .event_counter41 (event_counter41[MXCNTVME-1:0]), // Out
  .event_counter42 (event_counter42[MXCNTVME-1:0]), // Out
  .event_counter43 (event_counter43[MXCNTVME-1:0]), // Out
  .event_counter44 (event_counter44[MXCNTVME-1:0]), // Out
  .event_counter45 (event_counter45[MXCNTVME-1:0]), // Out
  .event_counter46 (event_counter46[MXCNTVME-1:0]), // Out
  .event_counter47 (event_counter47[MXCNTVME-1:0]), // Out
  .event_counter48 (event_counter48[MXCNTVME-1:0]), // Out
  .event_counter49 (event_counter49[MXCNTVME-1:0]), // Out
  .event_counter50 (event_counter50[MXCNTVME-1:0]), // Out
  .event_counter51 (event_counter51[MXCNTVME-1:0]), // Out
  .event_counter52 (event_counter52[MXCNTVME-1:0]), // Out
  .event_counter53 (event_counter53[MXCNTVME-1:0]), // Out
  .event_counter54 (event_counter54[MXCNTVME-1:0]), // Out
  .event_counter55 (event_counter55[MXCNTVME-1:0]), // Out
  .event_counter56 (event_counter56[MXCNTVME-1:0]), // Out
  .event_counter57 (event_counter57[MXCNTVME-1:0]), // Out
  .event_counter58 (event_counter58[MXCNTVME-1:0]), // Out
  .event_counter59 (event_counter59[MXCNTVME-1:0]), // Out
  .event_counter60 (event_counter60[MXCNTVME-1:0]), // Out
  .event_counter61 (event_counter61[MXCNTVME-1:0]), // Out
  .event_counter62 (event_counter62[MXCNTVME-1:0]), // Out
  .event_counter63 (event_counter63[MXCNTVME-1:0]), // Out
  .event_counter64 (event_counter64[MXCNTVME-1:0]), // Out
  .event_counter65 (event_counter65[MXCNTVME-1:0]), // Out

// Active CFEB(s) counters
  .active_cfebs_event_counter      (active_cfebs_event_counter[MXCNTVME-1:0]),      // Out
  .active_cfebs_me1a_event_counter (active_cfebs_me1a_event_counter[MXCNTVME-1:0]), // Out
  .active_cfebs_me1b_event_counter (active_cfebs_me1b_event_counter[MXCNTVME-1:0]), // Out
  .active_cfeb0_event_counter      (active_cfeb0_event_counter[MXCNTVME-1:0]),      // Out
  .active_cfeb1_event_counter      (active_cfeb1_event_counter[MXCNTVME-1:0]),      // Out
  .active_cfeb2_event_counter      (active_cfeb2_event_counter[MXCNTVME-1:0]),      // Out
  .active_cfeb3_event_counter      (active_cfeb3_event_counter[MXCNTVME-1:0]),      // Out
  .active_cfeb4_event_counter      (active_cfeb4_event_counter[MXCNTVME-1:0]),      // Out
  .active_cfeb5_event_counter      (active_cfeb5_event_counter[MXCNTVME-1:0]),      // Out
  .active_cfeb6_event_counter      (active_cfeb6_event_counter[MXCNTVME-1:0]),      // Out

  .bx0_match_counter (bx0_match_counter), // Out ALCT-CLCT BX0 match

  .hmt_counter0  (hmt_counter0 [MXCNTVME-1:0]),  // Out
  .hmt_counter1  (hmt_counter1 [MXCNTVME-1:0]),  // Out
  .hmt_counter2  (hmt_counter2 [MXCNTVME-1:0]),  // Out
  .hmt_counter3  (hmt_counter3 [MXCNTVME-1:0]),  // Out
  .hmt_counter4  (hmt_counter4 [MXCNTVME-1:0]),  // Out
  .hmt_counter5  (hmt_counter5 [MXCNTVME-1:0]),  // Out
  .hmt_counter6  (hmt_counter6 [MXCNTVME-1:0]),  // Out
  .hmt_counter7  (hmt_counter7 [MXCNTVME-1:0]),  // Out
  .hmt_counter8  (hmt_counter8 [MXCNTVME-1:0]),  // Out
  .hmt_counter9  (hmt_counter9 [MXCNTVME-1:0]),  // Out
  .hmt_counter10 (hmt_counter10[MXCNTVME-1:0]),  // Out
  .hmt_counter11 (hmt_counter11[MXCNTVME-1:0]),  // Out
  .hmt_counter12 (hmt_counter12[MXCNTVME-1:0]),  // Out
  .hmt_counter13 (hmt_counter13[MXCNTVME-1:0]),  // Out
  .hmt_counter14 (hmt_counter14[MXCNTVME-1:0]),  // Out
  .hmt_counter15 (hmt_counter15[MXCNTVME-1:0]),  // Out
  .hmt_counter16 (hmt_counter16[MXCNTVME-1:0]),  // Out
  .hmt_counter17 (hmt_counter17[MXCNTVME-1:0]),  // Out
  .hmt_counter18 (hmt_counter18[MXCNTVME-1:0]),  // Out
  .hmt_counter19 (hmt_counter19[MXCNTVME-1:0]),  // Out
  .hmt_trigger_counter (hmt_trigger_counter[MXCNTVME-1:0]), //Out
  .hmt_readout_counter (hmt_readout_counter[MXCNTVME-1:0]), //out
  .hmt_aff_counter     (hmt_aff_counter[MXCNTVME-1:0]), //out
  .buf_stall_counter   (buf_stall_counter[MXCNTVME-1:0]),


  .new_counter0  (new_counter0 [MXCNTVME-1:0]),  // Out
  .new_counter1  (new_counter1 [MXCNTVME-1:0]),  // Out
// Sequencer Header Counters
  .hdr_clear_on_resync (hdr_clear_on_resync),           // In  Clear header counters on ttc_resync
  .pretrig_counter     (pretrig_counter[MXCNTVME-1:0]), // Out  Pre-trigger counter
  .seq_pretrig_counter (seq_pretrig_counter[MXCNTVME-1:0]), // Out  consecutive Pre-trigger counter (equential, 1 bx apart)
  .almostseq_pretrig_counter (almostseq_pretrig_counter[MXCNTVME-1:0]), // Out  Pre-triggers-2bx-apart counter
  .clct_counter        (clct_counter[MXCNTVME-1:0]),    // Out  CLCT counter
  .alct_counter        (alct_counter[MXCNTVME-1:0]),    // Out  ALCTs received counter
  .trig_counter        (trig_counter[MXCNTVME-1:0]),    // Out  TMB trigger counter
  .l1a_rx_counter      (l1a_rx_counter[MXL1ARX-1:0]),   // Out  L1As received from ccb counter
  .readout_counter     (readout_counter[MXL1ARX-1:0]),  // Out  Readout counter
  .orbit_counter       (orbit_counter[MXORBIT-1:0]),    // Out  Orbit counter

// GEM Sequencer Trigger/Readout Counters
  .gem_cnt_all_reset    (gem_cnt_all_reset),    // In  Trigger/Readout counter reset
  .gem_cnt_stop_on_ovf  (gem_cnt_stop_on_ovf),  // In  Stop all counters if any overflows
  .gem_cnt_any_ovf_seq  (gem_cnt_any_ovf_seq),  // Out  At least one sequencer counter overflowed

  .gem_counter0       (gem_counter0[MXCNTVME-1:0]),   // Out
  .gem_counter1       (gem_counter1[MXCNTVME-1:0]),   // Out
  .gem_counter2       (gem_counter2[MXCNTVME-1:0]),   // Out
  .gem_counter3       (gem_counter3[MXCNTVME-1:0]),   // Out
  .gem_counter4       (gem_counter4[MXCNTVME-1:0]),   // Out
  .gem_counter5       (gem_counter5[MXCNTVME-1:0]),   // Out
  .gem_counter6       (gem_counter6[MXCNTVME-1:0]),   // Out
  .gem_counter7       (gem_counter7[MXCNTVME-1:0]),   // Out
  .gem_counter8       (gem_counter8[MXCNTVME-1:0]),   // Out
  .gem_counter9       (gem_counter9[MXCNTVME-1:0]),   // Out
  .gem_counter10      (gem_counter10[MXCNTVME-1:0]),  // Out
  .gem_counter11      (gem_counter11[MXCNTVME-1:0]),  // Out
  .gem_counter12      (gem_counter12[MXCNTVME-1:0]),  // Out
  .gem_counter13      (gem_counter13[MXCNTVME-1:0]),  // Out
  .gem_counter14      (gem_counter14[MXCNTVME-1:0]),  // Out
  .gem_counter15      (gem_counter15[MXCNTVME-1:0]),  // Out
  .gem_counter16      (gem_counter16[MXCNTVME-1:0]),  // Out
  .gem_counter17      (gem_counter17[MXCNTVME-1:0]),  // Out
  .gem_counter18      (gem_counter18[MXCNTVME-1:0]),  // Out
  .gem_counter19      (gem_counter19[MXCNTVME-1:0]),  // Out
  .gem_counter20      (gem_counter20[MXCNTVME-1:0]),  // Out
  .gem_counter21      (gem_counter21[MXCNTVME-1:0]),  // Out
  .gem_counter22      (gem_counter22[MXCNTVME-1:0]),  // Out
  .gem_counter23      (gem_counter23[MXCNTVME-1:0]),  // Out
  .gem_counter24      (gem_counter24[MXCNTVME-1:0]),  // Out
  .gem_counter25      (gem_counter25[MXCNTVME-1:0]),  // Out
  .gem_counter26      (gem_counter26[MXCNTVME-1:0]),  // Out
  .gem_counter27      (gem_counter27[MXCNTVME-1:0]),  // Out
  .gem_counter28      (gem_counter28[MXCNTVME-1:0]),  // Out
  .gem_counter29      (gem_counter29[MXCNTVME-1:0]),  // Out
  .gem_counter30      (gem_counter30[MXCNTVME-1:0]),  // Out
  .gem_counter31      (gem_counter31[MXCNTVME-1:0]),  // Out
  .gem_counter32      (gem_counter32[MXCNTVME-1:0]),  // Out
  .gem_counter33      (gem_counter33[MXCNTVME-1:0]),  // Out
  .gem_counter34      (gem_counter34[MXCNTVME-1:0]),  // Out
  .gem_counter35      (gem_counter35[MXCNTVME-1:0]),  // Out
  .gem_counter36      (gem_counter36[MXCNTVME-1:0]),  // Out
  .gem_counter37      (gem_counter37[MXCNTVME-1:0]),  // Out
  .gem_counter38      (gem_counter38[MXCNTVME-1:0]),  // Out
  .gem_counter39      (gem_counter39[MXCNTVME-1:0]),  // Out
  .gem_counter40      (gem_counter40[MXCNTVME-1:0]),  // Out
  .gem_counter41      (gem_counter41[MXCNTVME-1:0]),  // Out
  .gem_counter42      (gem_counter42[MXCNTVME-1:0]),  // Out
  .gem_counter43      (gem_counter43[MXCNTVME-1:0]),  // Out
  .gem_counter44      (gem_counter44[MXCNTVME-1:0]),  // Out
  .gem_counter45      (gem_counter45[MXCNTVME-1:0]),  // Out
  .gem_counter46      (gem_counter46[MXCNTVME-1:0]),  // Out
  .gem_counter47      (gem_counter47[MXCNTVME-1:0]),  // Out
  .gem_counter48      (gem_counter48[MXCNTVME-1:0]),  // Out
  .gem_counter49      (gem_counter49[MXCNTVME-1:0]),  // Out
  .gem_counter50      (gem_counter50[MXCNTVME-1:0]),  // Out
  .gem_counter51      (gem_counter51[MXCNTVME-1:0]),  // Out
  .gem_counter52      (gem_counter52[MXCNTVME-1:0]),  // Out
  .gem_counter53      (gem_counter53[MXCNTVME-1:0]),  // Out
  .gem_counter54      (gem_counter54[MXCNTVME-1:0]),  // Out
  .gem_counter55      (gem_counter55[MXCNTVME-1:0]),  // Out
  .gem_counter56      (gem_counter56[MXCNTVME-1:0]),  // Out
  .gem_counter57      (gem_counter57[MXCNTVME-1:0]),  // Out
  .gem_counter58      (gem_counter58[MXCNTVME-1:0]),  // Out
  .gem_counter59      (gem_counter59[MXCNTVME-1:0]),  // Out
  .gem_counter60      (gem_counter60[MXCNTVME-1:0]),  // Out
  .gem_counter61      (gem_counter61[MXCNTVME-1:0]),  // Out
  .gem_counter62      (gem_counter62[MXCNTVME-1:0]),  // Out
  .gem_counter63      (gem_counter63[MXCNTVME-1:0]),  // Out
  .gem_counter64      (gem_counter64[MXCNTVME-1:0]),  // Out
  .gem_counter65      (gem_counter65[MXCNTVME-1:0]),  // Out
  .gem_counter66      (gem_counter66[MXCNTVME-1:0]),  // Out
  .gem_counter67      (gem_counter67[MXCNTVME-1:0]),  // Out
  .gem_counter68      (gem_counter68[MXCNTVME-1:0]),  // Out
  .gem_counter69      (gem_counter69[MXCNTVME-1:0]),  // Out
  .gem_counter70      (gem_counter70[MXCNTVME-1:0]),  // Out
  .gem_counter71      (gem_counter71[MXCNTVME-1:0]),  // Out
  .gem_counter72      (gem_counter72[MXCNTVME-1:0]),  // Out
  .gem_counter73      (gem_counter73[MXCNTVME-1:0]),  // Out
  .gem_counter74      (gem_counter74[MXCNTVME-1:0]),  // Out
  .gem_counter75      (gem_counter75[MXCNTVME-1:0]),  // Out
  .gem_counter76      (gem_counter76[MXCNTVME-1:0]),  // Out
  .gem_counter77      (gem_counter77[MXCNTVME-1:0]),  // Out
  .gem_counter78      (gem_counter78[MXCNTVME-1:0]),  // Out
  .gem_counter79      (gem_counter79[MXCNTVME-1:0]),  // Out
  .gem_counter80      (gem_counter80[MXCNTVME-1:0]),  // Out
  .gem_counter81      (gem_counter81[MXCNTVME-1:0]),  // Out
  .gem_counter82      (gem_counter82[MXCNTVME-1:0]),  // Out
  .gem_counter83      (gem_counter83[MXCNTVME-1:0]),  // Out
  .gem_counter84      (gem_counter84[MXCNTVME-1:0]),  // Out
  .gem_counter85      (gem_counter85[MXCNTVME-1:0]),  // Out
  .gem_counter86      (gem_counter86[MXCNTVME-1:0]),  // Out
  .gem_counter87      (gem_counter87[MXCNTVME-1:0]),  // Out
  .gem_counter88      (gem_counter88[MXCNTVME-1:0]),  // Out
  .gem_counter89      (gem_counter89[MXCNTVME-1:0]),  // Out
  .gem_counter90      (gem_counter90[MXCNTVME-1:0]),  // Out
  .gem_counter91      (gem_counter91[MXCNTVME-1:0]),  // Out
  .gem_counter92      (gem_counter92[MXCNTVME-1:0]),  // Out
  .gem_counter93      (gem_counter93[MXCNTVME-1:0]),  // Out
  .gem_counter94      (gem_counter94[MXCNTVME-1:0]),  // Out
  .gem_counter95      (gem_counter95[MXCNTVME-1:0]),  // Out
  .gem_counter96      (gem_counter96[MXCNTVME-1:0]),  // Out
  .gem_counter97      (gem_counter97[MXCNTVME-1:0]),  // Out
  .gem_counter98      (gem_counter98[MXCNTVME-1:0]),  // Out
  .gem_counter99      (gem_counter99[MXCNTVME-1:0]),  // Out
  .gem_counter100     (gem_counter100[MXCNTVME-1:0]), // Out
  .gem_counter101     (gem_counter101[MXCNTVME-1:0]), // Out
  .gem_counter102     (gem_counter102[MXCNTVME-1:0]), // Out
  .gem_counter103     (gem_counter103[MXCNTVME-1:0]), // Out
  .gem_counter104     (gem_counter104[MXCNTVME-1:0]), // Out
  .gem_counter105     (gem_counter105[MXCNTVME-1:0]), // Out
  .gem_counter106     (gem_counter106[MXCNTVME-1:0]), // Out
  .gem_counter107     (gem_counter107[MXCNTVME-1:0]), // Out
  .gem_counter108     (gem_counter108[MXCNTVME-1:0]), // Out
  .gem_counter109     (gem_counter109[MXCNTVME-1:0]), // Out
  .gem_counter110     (gem_counter110[MXCNTVME-1:0]), // Out
  .gem_counter111     (gem_counter111[MXCNTVME-1:0]), // Out
  .gem_counter112     (gem_counter112[MXCNTVME-1:0]), // Out
  .gem_counter113     (gem_counter113[MXCNTVME-1:0]), // Out
  .gem_counter114     (gem_counter114[MXCNTVME-1:0]), // Out
  .gem_counter115     (gem_counter115[MXCNTVME-1:0]), // Out
  .gem_counter116     (gem_counter116[MXCNTVME-1:0]), // Out
  .gem_counter117     (gem_counter117[MXCNTVME-1:0]), // Out
  .gem_counter118     (gem_counter118[MXCNTVME-1:0]), // Out
  .gem_counter119     (gem_counter119[MXCNTVME-1:0]), // Out
  .gem_counter120     (gem_counter120[MXCNTVME-1:0]), // Out
  .gem_counter121     (gem_counter121[MXCNTVME-1:0]), // Out
  .gem_counter122     (gem_counter122[MXCNTVME-1:0]), // Out
  .gem_counter123     (gem_counter123[MXCNTVME-1:0]), // Out
  .gem_counter124     (gem_counter124[MXCNTVME-1:0]), // Out
  .gem_counter125     (gem_counter125[MXCNTVME-1:0]), // Out
  .gem_counter126     (gem_counter126[MXCNTVME-1:0]), // Out
  .gem_counter127     (gem_counter127[MXCNTVME-1:0]), // Out

// CLCT pre-trigger coincidence counters
  .preClct_l1a_counter   (preClct_l1a_counter[MXCNTVME-1:0]),  // Out
  .preClct_alct_counter  (preClct_alct_counter[MXCNTVME-1:0]), // Out

// Sequencer Parity Errors
  .perr_pulse   (perr_pulse),               // In  Parity error pulse for counting
  .perr_cfeb_ff (perr_cfeb_ff[MXCFEB-1:0]), // In  CFEB RAM parity error, latched
  .perr_rpc_ff  (perr_rpc_ff),              // In  RPC  RAM parity error, latched
  .perr_gem_ff  (perr_gem_ff),              // In  GEM  RAM parity error, latched
  .perr_mini_ff (perr_mini_ff),             // In  Mini RAM parity error, latched
  .perr_ff      (perr_ff),                  // In  Parity error summary,  latched

// Sequencer VME debug register latches
  .deb_wr_buf_adr    (deb_wr_buf_adr[MXBADR-1:0]),     // Out  Buffer write address at last pretrig
  .deb_buf_push_adr  (deb_buf_push_adr[MXBADR-1:0]),   // Out  Queue push address at last push
  .deb_buf_pop_adr   (deb_buf_pop_adr[MXBADR-1:0]),    // Out  Queue pop  address at last pop
  .deb_buf_push_data (deb_buf_push_data[MXBDATA-1:0]), // Out  Queue push data at last push
  .deb_buf_pop_data  (deb_buf_pop_data[MXBDATA-1:0]),  // Out  Queue pop  data at last pop

  .gemA_bxn_counter (gemA_bxn_counter[15:0]),      // out GEMA Bc0 bxn counter
  .gemB_bxn_counter (gemB_bxn_counter[15:0]),     // out GEMB BC0 bxn counter
// Sequencer Sump
  .sequencer_sump    (sequencer_sump)      // Out  Unused signals
  );

//gemA/B bc0 bxn counter, for test
wire [15:0] gemA_bxn_counter;
wire [15:0] gemB_bxn_counter;
// -----------------------------------------------------------------------------
// End: Sequencer Module
// -----------------------------------------------------------------------------


//-------------------------------------------------------------------------------------------------------------------
//  RPC Instantiation
//-------------------------------------------------------------------------------------------------------------------

// RPC Injector
  wire  [MXRPC-1:0]    rpc_inj_wen;   // 1=Write enable injector RAM
  wire  [9:0]          rpc_inj_rwadr; // Injector RAM read/write address
  wire  [MXRPCDB-1:0]  rpc_inj_wdata; // Injector RAM write data
  wire  [MXRPC-1:0]    rpc_inj_ren;   // 1=Read enable Injector RAM
  wire  [MXRPCDB-1:0]  rpc_inj_rdata; // Injector RAM read data

// RPC raw hits delay
  wire  [3:0] rpc0_delay;
  wire  [3:0] rpc1_delay;

// Raw Hits FIFO RAM Ports
  wire  [RAM_ADRB-1:0]    fifo_radr_rpc;   // FIFO RAM read tbin address
  wire  [0:0]             fifo_sel_rpc;    // FIFO RAM read layer address 0-1
  wire  [RAM_WIDTH-1+4:0] fifo0_rdata_rpc; // FIFO RAM read data
  wire  [RAM_WIDTH-1+4:0] fifo1_rdata_rpc; // FIFO RAM read data

// RPC Raw hits VME Readback
  wire  [MXRPCB-1:0]  rpc_bank;            // RPC bank address
  wire  [15:0]      rpc_rdata;            // RPC RAM read data
  wire  [2:0]      rpc_rbxn;            // RPC RAM read bxn

// RPC Hot Channel Mask
  wire  [MXRPCPAD-1:0]  rpc0_hcm;            // 1=enable RPC pad
  wire  [MXRPCPAD-1:0]  rpc1_hcm;            // 1=enable RPC pad

// RPC Bxn Offset
  wire  [3:0]      rpc_bxn_offset;          // RPC bunch crossing offset
  wire  [3:0]      rpc0_bxn_diff;          // RPC - offset
  wire  [3:0]      rpc1_bxn_diff;          // RPC - offset

// Status
  wire  [4:0]      parity_err_rpc;          // Raw hits RAM parity error detected

  rpc  urpc
  (
// RAT Module Signals
  .clock        (clock),        // In  40MHz TMB main
  .global_reset (global_reset), // In  Global reset
  .rpc_rx       (rpc_rx[37:0]), // In  RPC data inputs 80MHz DDR
  .rpc_smbrx    (rpc_smbrx),    // In  SMB receive data
  .rpc_tx       (rpc_tx[3:0]),  // Out  RPC control output

// RAT Control
  .rpc_sync     (rpc_sync),     // In  Sync mode
  .rpc_posneg   (rpc_posneg),   // In  Clock phase
  .rpc_loop_tmb (rpc_loop_tmb), // In  Loop mode (loops in RAT Spartan)
  .rpc_free_tx0 (rpc_free_tx0), // In  Unassigned
  .smb_data_rat (smb_data_rat), // Out  RAT smb_data

// RPC Ports: RAT 3D3444 Delay Signals
  .dddr_clock     (dddr_clock),     // In  DDDR clock      / rpc_sync
  .dddr_adr_latch (dddr_adr_latch), // In  DDDR address latch  / rpc_posneg
  .dddr_serial_in (dddr_serial_in), // In  DDDR serial in    / rpc_loop_tmb
  .dddr_busy      (dddr_busy),      // In  DDDR busy      / rpc_free_tx0

// RAT Serial Number
  .rat_sn_out (rat_sn_out), // In  RAT serial number, out = rpc_posneg
  .rat_dsn_en (rat_dsn_en), // In  RAT dsn enable

// RPC Injector
  .mask_all        (rpc_mask_all),               // In  1=Enable, 0=Turn off all RPC inputs
  .injector_go_rpc (injector_go_rpc),            // In  1=Start RPC pattern injector
  .injector_go_rat (injector_go_rat),            // In  1=Start RAT pattern injector
  .inj_last_tbin   (inj_last_tbin[11:0]),        // In  Last tbin, may wrap past 1024 ram adr
  .rpc_tbins_test  (rpc_tbins_test),             // In  Set write_data=address
  .inj_wen         (rpc_inj_wen[MXRPC-1:0]),     // In  1=Write enable injector RAM
  .inj_rwadr       (rpc_inj_rwadr[9:0]),         // In  Injector RAM read/write address
  .inj_wdata       (rpc_inj_wdata[MXRPCDB-1:0]), // In  Injector RAM write data
  .inj_ren         (rpc_inj_ren[MXRPC-1:0]),     // In  1=Read enable Injector RAM
  .inj_rdata       (rpc_inj_rdata[MXRPCDB-1:0]), // Out  Injector RAM read data

// RPC raw hits delay
  .rpc0_delay        (rpc0_delay[3:0]),        /// In  RPC0 raw hits delay
  .rpc1_delay        (rpc1_delay[3:0]),        /// In  RPC1 raw hits delay

// Raw Hits FIFO RAM Ports
  .fifo_wen    (fifo_wen),                         // In  1=Write enable FIFO RAM
  .fifo_wadr   (fifo_wadr[RAM_ADRB-1:0]),          // In  FIFO RAM write address
  .fifo_radr   (fifo_radr_rpc[RAM_ADRB-1:0]),      // In  FIFO RAM read address
  .fifo_sel    (fifo_sel_rpc[0:0]),                // In  FIFO RAM select bank 0-4
  .fifo0_rdata (fifo0_rdata_rpc[RAM_WIDTH-1+4:0]), // Out  FIFO RAM read data
  .fifo1_rdata (fifo1_rdata_rpc[RAM_WIDTH-1+4:0]), // Out  FIFO RAM read data

// RPC Scope
  .scp_rpc0_bxn   (scp_rpc0_bxn[2:0]),   // Out  RPC0 bunch crossing number
  .scp_rpc1_bxn   (scp_rpc1_bxn[2:0]),   // Out  RPC1 bunch crossing number
  .scp_rpc0_nhits (scp_rpc0_nhits[3:0]), // Out  RPC0 number of pads hit
  .scp_rpc1_nhits (scp_rpc1_nhits[3:0]), // Out  RPC1 number of pads hit

// RPC Raw hits VME Readback Ports
  .rpc_bank  (rpc_bank[MXRPCB-1:0]), // In  RPC bank address
  .rpc_rdata (rpc_rdata[15:0]),      // Out  RPC RAM read data
  .rpc_rbxn  (rpc_rbxn[2:0]),        // Out  RPC RAM read bxn

// RPC Hot Channel Mask Ports
  .rpc0_hcm (rpc0_hcm[MXRPCPAD-1:0]), // In  1=enable RPC pad
  .rpc1_hcm (rpc1_hcm[MXRPCPAD-1:0]), // In  1=enable RPC pad

// RPC Bxn Offset
  .rpc_bxn_offset (rpc_bxn_offset[3:0]), // In  RPC bunch crossing offset
  .rpc0_bxn_diff  (rpc0_bxn_diff[3:0]),  // Out  RPC - offset
  .rpc1_bxn_diff  (rpc1_bxn_diff[3:0]),  // Out  RPC - offset

// Status Ports
  .clct_pretrig   (clct_pretrig),        // In  Pre-trigger marker at (clct_sm==pretrig)
  .parity_err_rpc (parity_err_rpc[4:0]), // Out  Raw hits RAM parity error detected

    // Sump
  .rpc_sump        (rpc_sump)            // Out  Unused signals
  );

//-------------------------------------------------------------------------------------------------------------------
//  Miniscope Instantiation
//-------------------------------------------------------------------------------------------------------------------
  wire  [RAM_ADRB-1:0]    fifo_wadr_mini;          // FIFO RAM write tbin address
  wire  [RAM_ADRB-1:0]    fifo_radr_mini;          // FIFO RAM read tbin address
  wire  [RAM_WIDTH*2-1:0]  fifo_rdata_mini;        // FIFO RAM read data
  wire  [1:0]        parity_err_mini;        // Miniscope RAM parity error detected

  assign fifo_wadr_mini = fifo_wadr-wr_mini_offset;      // FIFO RAM read tbin address

  miniscope uminiscope
  (
// Clock
  .clock (clock), // In  40MHz TMB main

// Raw Hits FIFO RAM Ports
  .fifo_wen        (fifo_wen),                         // In  1=Write enable FIFO RAM
  .fifo_wadr_mini  (fifo_wadr_mini[RAM_ADRB-1:0]),     // In  FIFO RAM write address
  .fifo_radr_mini  (fifo_radr_mini[RAM_ADRB-1:0]),     // In  FIFO RAM read address
  .fifo_wdata_mini (fifo_wdata_mini[RAM_WIDTH*2-1:0]), // In  FIFO RAM write data
  .fifo_rdata_mini (fifo_rdata_mini[RAM_WIDTH*2-1:0]), // Out  FIFO RAM read data

// Status Ports
  .mini_tbins_test (mini_tbins_test),      // In  Miniscope data=address for testing
  .parity_err_mini (parity_err_mini[1:0]), // Out  Miniscope RAM parity error detected

// Sump
  .mini_sump (mini_sump) // Out  Unused signals
  );

//-------------------------------------------------------------------------------------------------------------------
//  Buffer Write Control Instantiation:  Controls CLCT + RPC raw hits RAM write-mode logic
//-------------------------------------------------------------------------------------------------------------------
  buffer_write_ctrl ubuffer_write_ctrl
  (
// CCB Ports
  .clock      (clock),      // In  40MHz TMB main clock
  .ttc_resync (ttc_resync), // In  TTC resync

// CFEB Raw Hits FIFO RAM Ports
  .fifo_wen  (fifo_wen),                // Out  1=Write enable FIFO RAM
  .fifo_wadr (fifo_wadr[RAM_ADRB-1:0]), // Out  FIFO RAM write address

// CFEB VME Configuration Ports
  .fifo_pretrig_cfeb (fifo_pretrig_cfeb[MXTBIN-1:0]), // In  Number FIFO time bins before pretrigger
  .fifo_no_raw_hits  (fifo_no_raw_hits),              // In  1=do not wait to store raw hits

// RPC VME Configuration Ports
  .fifo_pretrig_rpc  (fifo_pretrig_rpc[MXTBIN-1:0]),    // In  Number FIFO time bins before pretrigger

// GEM VME Configuration Ports
  .fifo_pretrig_gem  (fifo_pretrig_gem[MXTBIN-1:0]),    // In  Number FIFO time bins before pretrigger

// Sequencer Buffer Write Control
  .buf_reset     (buf_reset),                  // In  Free all buffer space
  .buf_push      (buf_push),                   // In  Allocate write buffer
  .buf_push_adr  (buf_push_adr[MXBADR-1:0]),   // In  Address of write buffer to allocate
  .buf_push_data (buf_push_data[MXBDATA-1:0]), // In  Data associated with push_adr

  .wr_buf_ready (wr_buf_ready),           // Out  Write buffer is ready
  .wr_buf_adr   (wr_buf_adr[MXBADR-1:0]), // Out  Current address of header write buffer

// Fence buffer adr and data at head of queue
  .buf_queue_adr  (buf_queue_adr[MXBADR-1:0]),   // Out  Buffer address of fence queued for readout
  .buf_queue_data (buf_queue_data[MXBDATA-1:0]), // Out  Data associated with queue adr

// Sequencer Buffer Read Control
  .buf_pop     (buf_pop),                 // In  Specified buffer is to be released
  .buf_pop_adr (buf_pop_adr[MXBADR-1:0]), // In  Address of read buffer to release

// Sequencer Buffer Status
  .buf_q_full         (buf_q_full),                       // Out  All raw hits ram in use, ram writing must stop
  .buf_q_empty        (buf_q_empty),                      // Out  No fences remain on buffer stack
  .buf_q_ovf_err      (buf_q_ovf_err),                    // Out  Tried to push when stack full
  .buf_q_udf_err      (buf_q_udf_err),                    // Out  Tried to pop when stack empty
  .buf_q_adr_err      (buf_q_adr_err),                    // Out  Fence adr popped from stack doesnt match rls adr
  .buf_stalled        (buf_stalled),                      // Out  Buffer write pointer hit a fence and is stalled now
  .buf_stalled_once   (buf_stalled_once),                 // Out  Buffer stalled at least once since last resync
  .buf_fence_dist     (buf_fence_dist[MXBADR-1:0]),       // Out  Current distance to next fence 0 to 2047
  .buf_fence_cnt      (buf_fence_cnt[MXBADR-1+1:0]),      // Out  Number of fences in fence RAM currently
  .buf_fence_cnt_peak (buf_fence_cnt_peak[MXBADR-1+1:0]), // Out  Peak number of fences in fence RAM
  .buf_display        (buf_display[7:0]),                 // Out  Buffer fraction in use display
  .buf_sump           (buf_sump)                          // Out  Unused signals
  );

//-------------------------------------------------------------------------------------------------------------------
//  Buffer Read Control Instantiation:  Controls CLCT + RPC raw hits readout
//-------------------------------------------------------------------------------------------------------------------
  buffer_read_ctrl ubuffer_read_ctrl
  (
// CCB Ports
  .clock      (clock),      // In  40MHz TMB main clock
  .ttc_resync (ttc_resync), // In  TTC resync

// CLCT Raw Hits FIFO RAM Ports
  .fifo_radr_cfeb (fifo_radr_cfeb[RAM_ADRB-1:0]), // Out  FIFO RAM read address
  .fifo_sel_cfeb  (fifo_sel_cfeb[2:0]),           // Out  FIFO RAM read layer address 0-5

// GEM Raw Hits FIFO RAM Ports
  .fifo_radr_gem (fifo_radr_gem[RAM_ADRB-1:0]), // Out  FIFO RAM read address
  .fifo_sel_gem  (fifo_sel_gem[1:0]),           // Out  FIFO RAM read cluster 0-3

// RPC Raw Hits FIFO RAM Ports
  .fifo_radr_rpc (fifo_radr_rpc[RAM_ADRB-1:0]), // Out  FIFO RAM read tbin address
  .fifo_sel_rpc  (fifo_sel_rpc[0:0]),           // Out  FIFO RAM read slice address 0-1

// Miniscpe FIFO RAM Ports
  .fifo_radr_mini (fifo_radr_mini[RAM_ADRB-1:0]), // Out  FIFO RAM read address

// CFEB Raw Hits Data Ports
  .fifo0_rdata_cfeb (fifo_rdata[0][RAM_WIDTH-1:0]), // In  FIFO RAM read data
  .fifo1_rdata_cfeb (fifo_rdata[1][RAM_WIDTH-1:0]), // In  FIFO RAM read data
  .fifo2_rdata_cfeb (fifo_rdata[2][RAM_WIDTH-1:0]), // In  FIFO RAM read data
  .fifo3_rdata_cfeb (fifo_rdata[3][RAM_WIDTH-1:0]), // In  FIFO RAM read data
  .fifo4_rdata_cfeb (fifo_rdata[4][RAM_WIDTH-1:0]), // In  FIFO RAM read data
  .fifo5_rdata_cfeb (fifo_rdata[5][RAM_WIDTH-1:0]), // In  FIFO RAM read data
  .fifo6_rdata_cfeb (fifo_rdata[6][RAM_WIDTH-1:0]), // In  FIFO RAM read data


// CFEB Blockedbits Data Ports
  .cfeb0_blockedbits (cfeb_blockedbits[0]), // In  1=CFEB rx bit blocked by hcm or went bad, packed
  .cfeb1_blockedbits (cfeb_blockedbits[1]), // In  1=CFEB rx bit blocked by hcm or went bad, packed
  .cfeb2_blockedbits (cfeb_blockedbits[2]), // In  1=CFEB rx bit blocked by hcm or went bad, packed
  .cfeb3_blockedbits (cfeb_blockedbits[3]), // In  1=CFEB rx bit blocked by hcm or went bad, packed
  .cfeb4_blockedbits (cfeb_blockedbits[4]), // In  1=CFEB rx bit blocked by hcm or went bad, packed
  .cfeb5_blockedbits (cfeb_blockedbits[5]), // In  1=CFEB rx bit blocked by hcm or went bad, packed
  .cfeb6_blockedbits (cfeb_blockedbits[6]), // In  1=CFEB rx bit blocked by hcm or went bad, packed

// GEM Raw Hits Data Ports
  .fifo0_rdata_gem (fifo_rdata_gem[0][RAM_WIDTH_GEM-1:0]), // In  GEM Fiber0 FIFO RAM read data
  .fifo1_rdata_gem (fifo_rdata_gem[1][RAM_WIDTH_GEM-1:0]), // In  GEM Fiber1 FIFO RAM read data
  .fifo2_rdata_gem (fifo_rdata_gem[2][RAM_WIDTH_GEM-1:0]), // In  GEM Fiber2 FIFO RAM read data
  .fifo3_rdata_gem (fifo_rdata_gem[3][RAM_WIDTH_GEM-1:0]), // In  GEM Fiber3 FIFO RAM read data

// RPC Raw hits Data Ports
  .fifo0_rdata_rpc (fifo0_rdata_rpc[RAM_WIDTH-1+4:0]), // In  FIFO RAM read data, rpc
  .fifo1_rdata_rpc (fifo1_rdata_rpc[RAM_WIDTH-1+4:0]), // In  FIFO RAM read data, rpc

// Miniscope Data Ports
  .fifo_rdata_mini (fifo_rdata_mini[RAM_WIDTH*2-1:0]), // In  FIFO RAM read data

// CLCT VME Configuration Ports
  .fifo_tbins_cfeb   (fifo_tbins_cfeb[MXTBIN-1:0]),   // In  Number CFEB FIFO time bins to read out
  .fifo_pretrig_cfeb (fifo_pretrig_cfeb[MXTBIN-1:0]), // In  Number CFEB FIFO time bins before pretrigger

// RPC VME Configuration Ports
  .fifo_tbins_rpc   (fifo_tbins_rpc[MXTBIN-1:0]),   // In  Number RPC  FIFO time bins to read out
  .fifo_pretrig_rpc (fifo_pretrig_rpc[MXTBIN-1:0]), // In  Number RPC  FIFO time bins before pretrigger

// GEM VME Configuration Ports
  .fifo_tbins_gem    (fifo_tbins_gem[MXTBIN-1:0]),   // In  Number GEM  FIFO time bins to read out
  .fifo_pretrig_gem  (fifo_pretrig_gem[MXTBIN-1:0]), // In  Number GEM  FIFO time bins before pretrigger
  .gem_zero_suppress (gem_zero_suppress),            // In  GEM zero suppress enable
  .gem_read_mask     (gem_read_mask [MXGEM-1:0]),       // out  GEM Readout List

// Miniscope VME Configuration Ports
  .mini_tbins_word   (mini_tbins_word),               // In  Insert tbins and pretrig tbins in 1st word
  .fifo_tbins_mini   (fifo_tbins_mini[MXTBIN-1:0]),   // In  Number Mini FIFO time bins to read out
  .fifo_pretrig_mini (fifo_pretrig_mini[MXTBIN-1:0]), // In  Number Mini FIFO time bins before pretrigger

// CFEB Sequencer Readout Control
  .rd_start_cfeb (rd_start_cfeb),             // In  Initiates a FIFO readout
  .rd_abort_cfeb (rd_abort_cfeb),             // In  Abort FIFO dump
  .rd_list_cfeb  (rd_list_cfeb[MXCFEB-1:0]),  // In  List of CFEBs to read out
  .rd_ncfebs     (rd_ncfebs[MXCFEBB-1:0]),    // In  Number of CFEBs in feb_list (4 or 5 depending on CSC type)
  .rd_fifo_adr   (rd_fifo_adr[RAM_ADRB-1:0]), // In  RAM address at pre-trig, must be valid 1bx before rd_start

// CFEB Blockedbits Readout Control
  .rd_start_bcb  (rd_start_bcb),               // In  Start readout sequence
  .rd_abort_bcb  (rd_abort_bcb),               // In  Cancel readout
  .rd_list_bcb   (rd_list_bcb[MXCFEB-1:0]),    // In  List of CFEBs to read out
  .rd_ncfebs_bcb (rd_ncfebs_bcb[MXCFEBB-1:0]), // In  Number of CFEBs in bcb_list (0 to 5)

// GEM Sequencer Readout Control
  .rd_start_gem  (rd_start_gem),                // In  Start readout sequence
  .rd_abort_gem  (rd_abort_gem),                // In  Cancel readout
  .rd_list_gem   (rd_list_gem[MXGEM-1:0]),      // In  List of GEM fibers to read out
  .rd_ngems      (rd_ngems[MXGEMB-1+1:0]),      // In  Number of GEM fibers in gem_list
  .rd_gem_offset (rd_gem_offset[RAM_ADRB-1:0]), // In  RAM address rd_fifo_adr offset for gem read out

// RPC Sequencer Readout Control
  .rd_start_rpc  (rd_start_rpc),                // In  Start readout sequence
  .rd_abort_rpc  (rd_abort_rpc),                // In  Cancel readout
  .rd_list_rpc   (rd_list_rpc[MXRPC-1:0]),      // In  List of RPCs to read out
  .rd_nrpcs      (rd_nrpcs[MXRPCB-1+1:0]),      // In  Number of RPCs in rpc_list (0 or 1-to-2 depending on CSC type)
  .rd_rpc_offset (rd_rpc_offset[RAM_ADRB-1:0]), // In  RAM address rd_fifo_adr offset for rpc read out

// Mini Sequencer Readout Control
  .rd_start_mini  (rd_start_mini),                // In  Start readout sequence
  .rd_abort_mini  (rd_abort_mini),                // In  Cancel readout
  .rd_mini_offset (rd_mini_offset[RAM_ADRB-1:0]), // In  RAM address rd_fifo_adr offset for miniscope read out

// CFEB Sequencer Frame Output
  .cfeb_first_frame (cfeb_first_frame),      // Out  First frame valid 2bx after rd_start
  .cfeb_last_frame  (cfeb_last_frame),       // Out  Last frame valid 1bx after busy goes down
  .cfeb_adr         (cfeb_adr[MXCFEBB-1:0]), // Out  FIFO dump CFEB ID
  .cfeb_tbin        (cfeb_tbin[MXTBIN-1:0]), // Out  FIFO dump Time Bin #
  .cfeb_rawhits     (cfeb_rawhits[7:0]),     // Out  Layer data from FIFO
  .cfeb_fifo_busy   (cfeb_fifo_busy),        // Out  Readout busy sending data to sequencer, goes down 1bx early

// CFEB Blockedbits Frame Output
  .bcb_first_frame (bcb_first_frame),           // Out  First frame valid 2bx after rd_start
  .bcb_last_frame  (bcb_last_frame),            // Out  Last frame valid 1bx after busy goes down
  .bcb_blkbits     (bcb_blkbits[11:0]),         // Out  CFEB blocked bits frame data
  .bcb_cfeb_adr    (bcb_cfeb_adr[MXCFEBB-1:0]), // Out  CFEB ID
  .bcb_fifo_busy   (bcb_fifo_busy),             // Out  Readout busy sending data to sequencer, goes down 1bx early

// GEM Sequencer Frame Output
  .gem_first_frame (gem_first_frame),     // Out  First frame valid 2bx after rd_start
  .gem_last_frame  (gem_last_frame),      // Out  Last frame valid 1bx after busy goes down
  .gem_adr         (gem_adr[MXGEMB-1:0]), // Out  FIFO dump GEM ID
  .gem_id          (gem_id[0:0]),         // Out  FIFO dump GEM id
  .gem_rawhits     (gem_rawhits[13:0]),   // Out  FIFO dump GEM pad hits
  .gem_fifo_busy   (gem_fifo_busy),       // Out  Readout busy sending data to sequencer, goes down 1bx early

// RPC Sequencer Frame Output
  .rpc_first_frame (rpc_first_frame),         // Out  First frame valid 2bx after rd_start
  .rpc_last_frame  (rpc_last_frame),          // Out  Last frame valid 1bx after busy goes down
  .rpc_adr         (rpc_adr[MXRPCB-1:0]),     // Out  FIFO dump RPC ID
  .rpc_tbinbxn     (rpc_tbinbxn[MXTBIN-1:0]), // Out  FIFO dump RPC tbin or bxn for DMB
  .rpc_rawhits     (rpc_rawhits[7:0]),        // Out  FIFO dump RPC pad hits, 8 of 16 per cycle
  .rpc_fifo_busy   (rpc_fifo_busy),           // Out  Readout busy sending data to sequencer, goes down 1bx early

// Mini Sequencer Frame Output
  .mini_first_frame (mini_first_frame),            // Out  First frame valid 2bx after rd_start
  .mini_last_frame  (mini_last_frame),             // Out  Last frame valid 1bx after busy goes down
  .mini_rdata       (mini_rdata[RAM_WIDTH*2-1:0]), // Out  FIFO dump miniscope
  .mini_fifo_busy   (mini_fifo_busy)               // Out  Readout busy sending data to sequencer, goes down 1bx early
  );

//-------------------------------------------------------------------------------------------------------------------
//  Raw Hits RAM Parity Check Instantiation
//-------------------------------------------------------------------------------------------------------------------
  parity uparity
  (
// Clock
  .clock        (clock),        // In  40MHz TMB main clock
  .global_reset (global_reset), // In  Global reset
  .perr_reset   (perr_reset),   // In  Parity error reset

// Parity inputs
  .parity_err_cfeb0  (parity_err_cfeb[0][MXLY-1:0]), // In  CFEB raw hits RAM parity errors
  .parity_err_cfeb1  (parity_err_cfeb[1][MXLY-1:0]), // In  CFEB raw hits RAM parity errors
  .parity_err_cfeb2  (parity_err_cfeb[2][MXLY-1:0]), // In  CFEB raw hits RAM parity errors
  .parity_err_cfeb3  (parity_err_cfeb[3][MXLY-1:0]), // In  CFEB raw hits RAM parity errors
  .parity_err_cfeb4  (parity_err_cfeb[4][MXLY-1:0]), // In  CFEB raw hits RAM parity errors
  .parity_err_cfeb5  (parity_err_cfeb[5][MXLY-1:0]), // In  CFEB raw hits RAM parity errors
  .parity_err_cfeb6  (parity_err_cfeb[6][MXLY-1:0]), // In  CFEB raw hits RAM parity errors
  .parity_err_gem0   (parity_err_gem [0][3:0]),      // In  gem raw hits RAM parity errors
  .parity_err_gem1   (parity_err_gem [1][3:0]),      // In  gem raw hits RAM parity errors
  .parity_err_gem2   (parity_err_gem [2][3:0]),      // In  gem raw hits RAM parity errors
  .parity_err_gem3   (parity_err_gem [3][3:0]),      // In  gem raw hits RAM parity errors
  .parity_err_rpc    (parity_err_rpc [4:0]),         // In  RPC  raw hits RAM parity errors
  .parity_err_mini   (parity_err_mini[1:0]),         // In  Miniscope     RAM parity errors

// Raw hits RAM control
  .fifo_wen      (fifo_wen),            // In  1=Write enable FIFO RAM

// Parity summary to VME
  .perr_cfeb    (perr_cfeb[MXCFEB-1:0]),    // Out  CFEB RAM parity error
  .perr_gem     (perr_gem [MXGEM -1:0]),    // Out  GEM  RAM parity error
  .perr_rpc     (perr_rpc),                 // Out  RPC  RAM parity error
  .perr_mini    (perr_mini),                // Out  Mini RAM parity error
  .perr_en      (perr_en),                  // Out  Parity error latch enabled
  .perr         (perr),                     // Out  Parity error summary
  .perr_pulse   (perr_pulse),               // Out  Parity error pulse for counting
  .perr_cfeb_ff (perr_cfeb_ff[MXCFEB-1:0]), // Out  CFEB RAM parity error, latched
  .perr_gem_ff  (perr_gem_ff[MXGEM-1:0]),   // Out  GEM RAM parity error,  latched
  .perr_rpc_ff  (perr_rpc_ff),              // Out  RPC  RAM parity error, latched
  .perr_mini_ff (perr_mini_ff),             // Out  Mini RAM parity error, latched
  .perr_ff      (perr_ff),                  // Out  Parity error summary,  latched
  .perr_ram_ff  (perr_ram_ff[64:0])         // Out  Mapped bad parity RAMs, 6x7=42 cfebs + 5 rpcs + 2 miniscope
  );

//-------------------------------------------------------------------------------------------------------------------
//  TMB Instantiation
//    Sends 80MHz data from ALCT and Sequencer to MPC
//    Outputs ALCT+CLCT match results for Sequencer header
//    Receives 80MHz MPC desision result, sends de-muxed to Sequencer
//-------------------------------------------------------------------------------------------------------------------
// Local

  ////injected lct
  //wire  [7:0] lct_inj_hs;
  //wire  [6:0] lct_inj_wg;
  //wire        lct_inj_enable;


  wire  [1:0]      tmb_sync_err_en;
  wire  [7:0]      mpc_nframes;
  wire  [3:0]      mpc_wen;
  wire  [3:0]      mpc_ren;
  wire  [7:0]      mpc_adr;
  wire  [15:0]     mpc_wdata;
  wire  [15:0]     mpc_rdata;
  wire  [3:0]      mpc_accept_rdata;

  wire  [MXFRAME-1:0]  mpc0_frame0_vme;
  wire  [MXFRAME-1:0]  mpc0_frame1_vme;
  wire  [MXFRAME-1:0]  mpc1_frame0_vme;
  wire  [MXFRAME-1:0]  mpc1_frame1_vme;
  wire  [1:0]      mpc_accept_vme;
  wire  [1:0]      mpc_reserved_vme;

  wire  [31:0] gemcscmatch_cluster0_vme;
  wire  [31:0] gemcscmatch_cluster1_vme;

  //GEMCSC match

  wire [7:0] copad_match_forgemcsc = (copad_match & gemA_csc_cluster_vpf);//gemA_csc_cluster_vpf with gem_fiber_enable && gem_me1b_match_enable || csc_cluster0_me1a

  wire gem_foralct_vpf_tp;
  wire gem_forclct_vpf_tp;
  wire gem_alct_window_hasgem_tp;
  wire keep_gem_tp;
  

  tmb utmb
  (
// Clock
  .clock      (clock),      // In  40MHz TMB main clock
  .ttc_resync (ttc_resync), // In  TTC resync

  .evenchamber  (evenchamber),
// ALCT
  .alct0_tmb    (alct0_tmb[MXALCT-1:0]), // In  ALCT best muon
  .alct1_tmb    (alct1_tmb[MXALCT-1:0]), // In  ALCT second best muon
  .alct_bx0_rx  (alct_bx0_rx),           // In  ALCT bx0 received
  .alct_ecc_err (alct_ecc_err[1:0]),     // In  ALCT ecc syndrome code

  .alct_vpf_pipe (alct_vpf_pipe), //Out alct vpf after delay_
  .hmt_anode     (hmt_anode[MXHMTB-1:0]), //Out alct vpf after delay_
  .clct_vpf_pipe (clct_vpf_pipe), //Out alct vpf after delay_

  //hmt port
  .hmt_enable         (hmt_enable) , // In hmt enabled 
  .hmt_outtime_check   (hmt_outtime_check),//In hmt fired shoudl check anode bg lower than threshold
  .hmt_nhits_bx7       (hmt_nhits_bx7     [NHMTHITB-1:0]),//In hmt nhits for central bx
  .hmt_nhits_sig     (hmt_nhits_sig   [NHMTHITB-1:0]),//In hmt nhits for in-time
  .hmt_nhits_bkg    (hmt_nhits_bkg  [NHMTHITB-1:0]),//In hmt nhits for out-time
  .hmt_cathode_pipe    (hmt_cathode[MXHMTB-1:0]), //In hmt bits in cathod

  .hmt_match_win      (hmt_match_win[3:0]),// In alct location in hmt window size
  .hmt_trigger_tmb    (hmt_trigger_tmb[MXHMTB-1:0]),//  In results aligned with ALCT vpf latched for ALCT-CLCT match
  .hmt_trigger_tmb_ro (hmt_trigger_tmb_ro[MXHMTB-1:0]),//In results aligned with ALCT vpf latched for ALCT-CLCT match

  .wr_adr_xpre_hmt_pipe   (wr_adr_xpre_hmt_pipe[MXBADR-1:0]),  //In wr_adr at rtmb-1 for hmt 
  .wr_push_mux_hmt        (wr_push_mux_hmt),       //In wr_push at rtmb-1 for hmt
  .wr_avail_xpre_hmt_pipe (wr_avail_xpre_hmt_pipe),//In wr_avail at rtmb-1 for hmt 
// GEM
  //.gemA_vpf          (gemA_vpf[7:0]),
  //.gemB_vpf          (gemB_vpf[7:0]),
  .gemA_overflow       (gemA_overflow_ff),// In
  .gemB_overflow       (gemB_overflow_ff),
  .gemA_sync_err       (~gemA_synced),
  .gemB_sync_err       (~gemB_synced),
  .gems_sync_err       (~gems_synced),
  .gemA_vpf                  (gemA_csc_cluster_vpf[7:0]), //In gem cluster vpf
  .gemA_cluster0             (gemA_csc_cluster[0]),// In GEM cluster
  .gemA_cluster1             (gemA_csc_cluster[1]),// In GEM cluster
  .gemA_cluster2             (gemA_csc_cluster[2]),// In GEM cluster
  .gemA_cluster3             (gemA_csc_cluster[3]),// In GEM cluster
  .gemA_cluster4             (gemA_csc_cluster[4]),// In GEM cluster
  .gemA_cluster5             (gemA_csc_cluster[5]),// In GEM cluster
  .gemA_cluster6             (gemA_csc_cluster[6]),// In GEM cluster
  .gemA_cluster7             (gemA_csc_cluster[7]),// In GEM cluster
  .gemA_cluster0_cscxky_lo   (gemA_csc_cluster_xky_lo[0]),// IN CSC xky mapped from GEM pad
  .gemA_cluster1_cscxky_lo   (gemA_csc_cluster_xky_lo[1]),// IN CSC xky mapped from GEM pad
  .gemA_cluster2_cscxky_lo   (gemA_csc_cluster_xky_lo[2]),// IN CSC xky mapped from GEM pad
  .gemA_cluster3_cscxky_lo   (gemA_csc_cluster_xky_lo[3]),// IN CSC xky mapped from GEM pad
  .gemA_cluster4_cscxky_lo   (gemA_csc_cluster_xky_lo[4]),// IN CSC xky mapped from GEM pad
  .gemA_cluster5_cscxky_lo   (gemA_csc_cluster_xky_lo[5]),// IN CSC xky mapped from GEM pad
  .gemA_cluster6_cscxky_lo   (gemA_csc_cluster_xky_lo[6]),// IN CSC xky mapped from GEM pad
  .gemA_cluster7_cscxky_lo   (gemA_csc_cluster_xky_lo[7]),// IN CSC xky mapped from GEM pad
  .gemA_cluster0_cscxky_mi   (gemA_csc_cluster_xky_mi[0]),// IN CSC xky mapped from GEM pad
  .gemA_cluster1_cscxky_mi   (gemA_csc_cluster_xky_mi[1]),// IN CSC xky mapped from GEM pad
  .gemA_cluster2_cscxky_mi   (gemA_csc_cluster_xky_mi[2]),// IN CSC xky mapped from GEM pad
  .gemA_cluster3_cscxky_mi   (gemA_csc_cluster_xky_mi[3]),// IN CSC xky mapped from GEM pad
  .gemA_cluster4_cscxky_mi   (gemA_csc_cluster_xky_mi[4]),// IN CSC xky mapped from GEM pad
  .gemA_cluster5_cscxky_mi   (gemA_csc_cluster_xky_mi[5]),// IN CSC xky mapped from GEM pad
  .gemA_cluster6_cscxky_mi   (gemA_csc_cluster_xky_mi[6]),// IN CSC xky mapped from GEM pad
  .gemA_cluster7_cscxky_mi   (gemA_csc_cluster_xky_mi[7]),// IN CSC xky mapped from GEM pad
  .gemA_cluster0_cscxky_hi   (gemA_csc_cluster_xky_hi[0]),// IN CSC xky mapped from GEM pad
  .gemA_cluster1_cscxky_hi   (gemA_csc_cluster_xky_hi[1]),// IN CSC xky mapped from GEM pad
  .gemA_cluster2_cscxky_hi   (gemA_csc_cluster_xky_hi[2]),// IN CSC xky mapped from GEM pad
  .gemA_cluster3_cscxky_hi   (gemA_csc_cluster_xky_hi[3]),// IN CSC xky mapped from GEM pad
  .gemA_cluster4_cscxky_hi   (gemA_csc_cluster_xky_hi[4]),// IN CSC xky mapped from GEM pad
  .gemA_cluster5_cscxky_hi   (gemA_csc_cluster_xky_hi[5]),// IN CSC xky mapped from GEM pad
  .gemA_cluster6_cscxky_hi   (gemA_csc_cluster_xky_hi[6]),// IN CSC xky mapped from GEM pad
  .gemA_cluster7_cscxky_hi   (gemA_csc_cluster_xky_hi[7]),// IN CSC xky mapped from GEM pad
  .gemA_cluster0_cscxky_win  (gemA_csc_cluster_xky_win[0]),// IN CSC xky mapped from GEM pad
  .gemA_cluster1_cscxky_win  (gemA_csc_cluster_xky_win[1]),// IN CSC xky mapped from GEM pad
  .gemA_cluster2_cscxky_win  (gemA_csc_cluster_xky_win[2]),// IN CSC xky mapped from GEM pad
  .gemA_cluster3_cscxky_win  (gemA_csc_cluster_xky_win[3]),// IN CSC xky mapped from GEM pad
  .gemA_cluster4_cscxky_win  (gemA_csc_cluster_xky_win[4]),// IN CSC xky mapped from GEM pad
  .gemA_cluster5_cscxky_win  (gemA_csc_cluster_xky_win[5]),// IN CSC xky mapped from GEM pad
  .gemA_cluster6_cscxky_win  (gemA_csc_cluster_xky_win[6]),// IN CSC xky mapped from GEM pad
  .gemA_cluster7_cscxky_win  (gemA_csc_cluster_xky_win[7]),// IN CSC xky mapped from GEM pad
  .gemA_cluster0_cscwire_lo  (gemA_csc_cluster_cscwire_lo[0]),// In CSC wire group mapped from GEM pad
  .gemA_cluster1_cscwire_lo  (gemA_csc_cluster_cscwire_lo[1]),// In CSC wire group mapped from GEM pad
  .gemA_cluster2_cscwire_lo  (gemA_csc_cluster_cscwire_lo[2]),// In CSC wire group mapped from GEM pad
  .gemA_cluster3_cscwire_lo  (gemA_csc_cluster_cscwire_lo[3]),// In CSC wire group mapped from GEM pad
  .gemA_cluster4_cscwire_lo  (gemA_csc_cluster_cscwire_lo[4]),// In CSC wire group mapped from GEM pad
  .gemA_cluster5_cscwire_lo  (gemA_csc_cluster_cscwire_lo[5]),// In CSC wire group mapped from GEM pad
  .gemA_cluster6_cscwire_lo  (gemA_csc_cluster_cscwire_lo[6]),// In CSC wire group mapped from GEM pad
  .gemA_cluster7_cscwire_lo  (gemA_csc_cluster_cscwire_lo[7]),// In CSC wire group mapped from GEM pad
  .gemA_cluster0_cscwire_mi  (gemA_csc_cluster_cscwire_mi[0]),// In CSC wire group mapped from GEM pad
  .gemA_cluster1_cscwire_mi  (gemA_csc_cluster_cscwire_mi[1]),// In CSC wire group mapped from GEM pad
  .gemA_cluster2_cscwire_mi  (gemA_csc_cluster_cscwire_mi[2]),// In CSC wire group mapped from GEM pad
  .gemA_cluster3_cscwire_mi  (gemA_csc_cluster_cscwire_mi[3]),// In CSC wire group mapped from GEM pad
  .gemA_cluster4_cscwire_mi  (gemA_csc_cluster_cscwire_mi[4]),// In CSC wire group mapped from GEM pad
  .gemA_cluster5_cscwire_mi  (gemA_csc_cluster_cscwire_mi[5]),// In CSC wire group mapped from GEM pad
  .gemA_cluster6_cscwire_mi  (gemA_csc_cluster_cscwire_mi[6]),// In CSC wire group mapped from GEM pad
  .gemA_cluster7_cscwire_mi  (gemA_csc_cluster_cscwire_mi[7]),// In CSC wire group mapped from GEM pad
  .gemA_cluster0_cscwire_hi  (gemA_csc_cluster_cscwire_hi[0]),// In CSC wire group mapped from GEM pad
  .gemA_cluster1_cscwire_hi  (gemA_csc_cluster_cscwire_hi[1]),// In CSC wire group mapped from GEM pad
  .gemA_cluster2_cscwire_hi  (gemA_csc_cluster_cscwire_hi[2]),// In CSC wire group mapped from GEM pad
  .gemA_cluster3_cscwire_hi  (gemA_csc_cluster_cscwire_hi[3]),// In CSC wire group mapped from GEM pad
  .gemA_cluster4_cscwire_hi  (gemA_csc_cluster_cscwire_hi[4]),// In CSC wire group mapped from GEM pad
  .gemA_cluster5_cscwire_hi  (gemA_csc_cluster_cscwire_hi[5]),// In CSC wire group mapped from GEM pad
  .gemA_cluster6_cscwire_hi  (gemA_csc_cluster_cscwire_hi[6]),// In CSC wire group mapped from GEM pad
  .gemA_cluster7_cscwire_hi  (gemA_csc_cluster_cscwire_hi[7]),// In CSC wire group mapped from GEM pad

  //GEMB trigger match control
  .gemB_vpf                  (gemB_csc_cluster_vpf[7:0]),
  .gemB_cluster0             (gemB_csc_cluster[0]),// In GEM cluster
  .gemB_cluster1             (gemB_csc_cluster[1]),// In GEM cluster
  .gemB_cluster2             (gemB_csc_cluster[2]),// In GEM cluster
  .gemB_cluster3             (gemB_csc_cluster[3]),// In GEM cluster
  .gemB_cluster4             (gemB_csc_cluster[4]),// In GEM cluster
  .gemB_cluster5             (gemB_csc_cluster[5]),// In GEM cluster
  .gemB_cluster6             (gemB_csc_cluster[6]),// In GEM cluster
  .gemB_cluster7             (gemB_csc_cluster[7]),// In GEM cluster
  .gemB_cluster0_cscxky_lo   (gemB_csc_cluster_xky_lo[0]),// IN CSC xky mapped from GEM pad
  .gemB_cluster1_cscxky_lo   (gemB_csc_cluster_xky_lo[1]),// IN CSC xky mapped from GEM pad
  .gemB_cluster2_cscxky_lo   (gemB_csc_cluster_xky_lo[2]),// IN CSC xky mapped from GEM pad
  .gemB_cluster3_cscxky_lo   (gemB_csc_cluster_xky_lo[3]),// IN CSC xky mapped from GEM pad
  .gemB_cluster4_cscxky_lo   (gemB_csc_cluster_xky_lo[4]),// IN CSC xky mapped from GEM pad
  .gemB_cluster5_cscxky_lo   (gemB_csc_cluster_xky_lo[5]),// IN CSC xky mapped from GEM pad
  .gemB_cluster6_cscxky_lo   (gemB_csc_cluster_xky_lo[6]),// IN CSC xky mapped from GEM pad
  .gemB_cluster7_cscxky_lo   (gemB_csc_cluster_xky_lo[7]),// IN CSC xky mapped from GEM pad
  .gemB_cluster0_cscxky_mi   (gemB_csc_cluster_xky_mi[0]),// IN CSC xky mapped from GEM pad
  .gemB_cluster1_cscxky_mi   (gemB_csc_cluster_xky_mi[1]),// IN CSC xky mapped from GEM pad
  .gemB_cluster2_cscxky_mi   (gemB_csc_cluster_xky_mi[2]),// IN CSC xky mapped from GEM pad
  .gemB_cluster3_cscxky_mi   (gemB_csc_cluster_xky_mi[3]),// IN CSC xky mapped from GEM pad
  .gemB_cluster4_cscxky_mi   (gemB_csc_cluster_xky_mi[4]),// IN CSC xky mapped from GEM pad
  .gemB_cluster5_cscxky_mi   (gemB_csc_cluster_xky_mi[5]),// IN CSC xky mapped from GEM pad
  .gemB_cluster6_cscxky_mi   (gemB_csc_cluster_xky_mi[6]),// IN CSC xky mapped from GEM pad
  .gemB_cluster7_cscxky_mi   (gemB_csc_cluster_xky_mi[7]),// IN CSC xky mapped from GEM pad
  .gemB_cluster0_cscxky_hi   (gemB_csc_cluster_xky_hi[0]),// IN CSC xky mapped from GEM pad
  .gemB_cluster1_cscxky_hi   (gemB_csc_cluster_xky_hi[1]),// IN CSC xky mapped from GEM pad
  .gemB_cluster2_cscxky_hi   (gemB_csc_cluster_xky_hi[2]),// IN CSC xky mapped from GEM pad
  .gemB_cluster3_cscxky_hi   (gemB_csc_cluster_xky_hi[3]),// IN CSC xky mapped from GEM pad
  .gemB_cluster4_cscxky_hi   (gemB_csc_cluster_xky_hi[4]),// IN CSC xky mapped from GEM pad
  .gemB_cluster5_cscxky_hi   (gemB_csc_cluster_xky_hi[5]),// IN CSC xky mapped from GEM pad
  .gemB_cluster6_cscxky_hi   (gemB_csc_cluster_xky_hi[6]),// IN CSC xky mapped from GEM pad
  .gemB_cluster7_cscxky_hi   (gemB_csc_cluster_xky_hi[7]),// IN CSC xky mapped from GEM pad
  .gemB_cluster0_cscxky_win  (gemB_csc_cluster_xky_win[0]),// IN CSC xky mapped from GEM pad
  .gemB_cluster1_cscxky_win  (gemB_csc_cluster_xky_win[1]),// IN CSC xky mapped from GEM pad
  .gemB_cluster2_cscxky_win  (gemB_csc_cluster_xky_win[2]),// IN CSC xky mapped from GEM pad
  .gemB_cluster3_cscxky_win  (gemB_csc_cluster_xky_win[3]),// IN CSC xky mapped from GEM pad
  .gemB_cluster4_cscxky_win  (gemB_csc_cluster_xky_win[4]),// IN CSC xky mapped from GEM pad
  .gemB_cluster5_cscxky_win  (gemB_csc_cluster_xky_win[5]),// IN CSC xky mapped from GEM pad
  .gemB_cluster6_cscxky_win  (gemB_csc_cluster_xky_win[6]),// IN CSC xky mapped from GEM pad
  .gemB_cluster7_cscxky_win  (gemB_csc_cluster_xky_win[7]),// IN CSC xky mapped from GEM pad
  .gemB_cluster0_cscwire_lo  (gemB_csc_cluster_cscwire_lo[0]),// In CSC wire group mapped from GEM pad
  .gemB_cluster1_cscwire_lo  (gemB_csc_cluster_cscwire_lo[1]),// In CSC wire group mapped from GEM pad
  .gemB_cluster2_cscwire_lo  (gemB_csc_cluster_cscwire_lo[2]),// In CSC wire group mapped from GEM pad
  .gemB_cluster3_cscwire_lo  (gemB_csc_cluster_cscwire_lo[3]),// In CSC wire group mapped from GEM pad
  .gemB_cluster4_cscwire_lo  (gemB_csc_cluster_cscwire_lo[4]),// In CSC wire group mapped from GEM pad
  .gemB_cluster5_cscwire_lo  (gemB_csc_cluster_cscwire_lo[5]),// In CSC wire group mapped from GEM pad
  .gemB_cluster6_cscwire_lo  (gemB_csc_cluster_cscwire_lo[6]),// In CSC wire group mapped from GEM pad
  .gemB_cluster7_cscwire_lo  (gemB_csc_cluster_cscwire_lo[7]),// In CSC wire group mapped from GEM pad
  .gemB_cluster0_cscwire_mi  (gemB_csc_cluster_cscwire_mi[0]),// In CSC wire group mapped from GEM pad
  .gemB_cluster1_cscwire_mi  (gemB_csc_cluster_cscwire_mi[1]),// In CSC wire group mapped from GEM pad
  .gemB_cluster2_cscwire_mi  (gemB_csc_cluster_cscwire_mi[2]),// In CSC wire group mapped from GEM pad
  .gemB_cluster3_cscwire_mi  (gemB_csc_cluster_cscwire_mi[3]),// In CSC wire group mapped from GEM pad
  .gemB_cluster4_cscwire_mi  (gemB_csc_cluster_cscwire_mi[4]),// In CSC wire group mapped from GEM pad
  .gemB_cluster5_cscwire_mi  (gemB_csc_cluster_cscwire_mi[5]),// In CSC wire group mapped from GEM pad
  .gemB_cluster6_cscwire_mi  (gemB_csc_cluster_cscwire_mi[6]),// In CSC wire group mapped from GEM pad
  .gemB_cluster7_cscwire_mi  (gemB_csc_cluster_cscwire_mi[7]),// In CSC wire group mapped from GEM pad
  .gemB_cluster0_cscwire_hi  (gemB_csc_cluster_cscwire_hi[0]),// In CSC wire group mapped from GEM pad
  .gemB_cluster1_cscwire_hi  (gemB_csc_cluster_cscwire_hi[1]),// In CSC wire group mapped from GEM pad
  .gemB_cluster2_cscwire_hi  (gemB_csc_cluster_cscwire_hi[2]),// In CSC wire group mapped from GEM pad
  .gemB_cluster3_cscwire_hi  (gemB_csc_cluster_cscwire_hi[3]),// In CSC wire group mapped from GEM pad
  .gemB_cluster4_cscwire_hi  (gemB_csc_cluster_cscwire_hi[4]),// In CSC wire group mapped from GEM pad
  .gemB_cluster5_cscwire_hi  (gemB_csc_cluster_cscwire_hi[5]),// In CSC wire group mapped from GEM pad
  .gemB_cluster6_cscwire_hi  (gemB_csc_cluster_cscwire_hi[6]),// In CSC wire group mapped from GEM pad
  .gemB_cluster7_cscwire_hi  (gemB_csc_cluster_cscwire_hi[7]),// In CSC wire group mapped from GEM pad

  .copad_match   (copad_match_forgemcsc[7:0]),
  // copad match matrix. copad_A_B[0][0] means whether cluster0 from gemA matches with cluster0 from gem B or not
  .copad_A0_B   (copad_A_B[0][MXCLUSTER_CHAMBER-1:0]),
  .copad_A1_B   (copad_A_B[1][MXCLUSTER_CHAMBER-1:0]),
  .copad_A2_B   (copad_A_B[2][MXCLUSTER_CHAMBER-1:0]),
  .copad_A3_B   (copad_A_B[3][MXCLUSTER_CHAMBER-1:0]),
  .copad_A4_B   (copad_A_B[4][MXCLUSTER_CHAMBER-1:0]),
  .copad_A5_B   (copad_A_B[5][MXCLUSTER_CHAMBER-1:0]),
  .copad_A6_B   (copad_A_B[6][MXCLUSTER_CHAMBER-1:0]),
  .copad_A7_B   (copad_A_B[7][MXCLUSTER_CHAMBER-1:0]),

  .match_gem_alct_delay   (match_gem_alct_delay[7:0]),  //In gem delay for gem-ALCT match
  .match_gem_alct_window  (match_gem_alct_window[3:0]), //In gem-alct match window
  .match_gem_clct_window  (match_gem_clct_window[3:0]), //In gem-clct match window

  //.gemA_match_enable      (gemA_match_enable),             //In gemA+ALCT match
  .gemA_alct_pulse_match        (gemA_alct_pulse_match),             //Out gemA+ALCT match
  .gemA_clct_pulse_match        (gemA_clct_pulse_match),             //Out gemA+CLCT match
  .gemA_fiber_enable      (gemA_fiber_enable[1:0]),     //In gemA two fibers enabled or not
  //.gemB_match_enable      (gemB_match_enable),             //IN gemB+ALCT match
  .gemB_alct_pulse_match        (gemB_alct_pulse_match),       // Out gemB+ALCT match or not
  .gemB_clct_pulse_match        (gemB_clct_pulse_match),      // Out gemB+CLCT match or not
  .gemB_fiber_enable      (gemB_fiber_enable[1:0]),    //In gemB two fibers enabled or not

  //GEM-CSC match control
  .gem_me1a_match_enable     (gem_me1a_match_enable),       //IN gem-csc match in me1a
  .gem_me1b_match_enable     (gem_me1b_match_enable),       //IN gem-csc match in me1b

  .gemcsc_match_extrapolate    (gemcsc_match_extrapolate),    //In enable GEMCSC match using extrapolation
  .gemcsc_match_bend_correction(gemcsc_match_bend_correction),//In correct bending angle with GEMCSC bending
  .gemcsc_match_tightwindow    (gemcsc_match_tightwindow),    //In use tight window when extrapolation is used

  .match_drop_lowqalct     (match_drop_lowqalct),               //IN gem-csc match drop lowQ stub 
  .me1a_match_drop_lowqclct     (me1a_match_drop_lowqclct),     //IN gem-csc match drop lowQ stub 
  .me1b_match_drop_lowqclct     (me1b_match_drop_lowqclct),     //IN gem-csc match drop lowQ stub 
  .tmb_copad_alct_allow_ro      (tmb_copad_alct_allow_ro),       //In gem-csc match, allow ALCT+copad match for readout
  .tmb_copad_clct_allow_ro      (tmb_copad_clct_allow_ro),       //In gem-csc match, allow CLCT+copad match for readout
  .tmb_copad_alct_allow      (tmb_copad_alct_allow),       //In gem-csc match, allow ALCT+copad match for triggering
  .tmb_copad_clct_allow      (tmb_copad_clct_allow),       //In gem-csc match, allow CLCT+copad match for triggering
  .gemA_match_ignore_position     (gemA_match_ignore_position),             //In GEMCSC match, no position match
  .gemB_match_ignore_position     (gemB_match_ignore_position),             //In GEMCSC match, no position match
  .gemcsc_bend_enable        (gemcsc_bend_enable),             //In GEMCSC bending angle enabled
  .gemcsc_ignore_bend_check  (gemcsc_ignore_bend_check),             //In GEMCSC ignore GEMCSC bending direction and CSC bend direction check

  .gemA_forclct_real         (gemA_forclct_real[7:0]),
  .gemB_forclct_real         (gemB_forclct_real[7:0]),
  .copad_match_real          ( copad_match_real[7:0]),
  .gemA_overflow_real        (gemA_overflow_real),//  Out, latched for headers
  .gemB_overflow_real        (gemB_overflow_real),
  .gemA_sync_err_real        (gemA_sync_err_real),
  .gemB_sync_err_real        (gemB_sync_err_real),
  .gems_sync_err_real        (gems_sync_err_real),
  .tmb_gem_clct_win          (tmb_gem_clct_win[3:0]), // In gem location in GEM-CLCT window
  .tmb_alct_gem_win          (tmb_alct_gem_win[2:0]), // In gem location in GEM-ALCT window
  .tmb_hmt_match_win         (tmb_hmt_match_win[3:0]), //In  alct/anode hmt in cathode hmt tagged window

// TMB-Sequencer Pipelines
  .wr_adr_xtmb (wr_adr_xtmb[MXBADR-1:0]), // In  Buffer write address after drift time
  .wr_adr_rtmb (wr_adr_rtmb[MXBADR-1:0]), // Out  Buffer write address at TMB matching time
  .wr_adr_xmpc (wr_adr_xmpc[MXBADR-1:0]), // Out  Buffer write address at MPC xmit to sequencer
  .wr_adr_rmpc (wr_adr_rmpc[MXBADR-1:0]), // Out  Buffer write address at MPC received

  .wr_push_xtmb (wr_push_xtmb), // In  Buffer write strobe after drift time
  .wr_push_rtmb (wr_push_rtmb), // Out  Buffer write strobe at TMB matching time
  .wr_push_xmpc (wr_push_xmpc), // Out  Buffer write strobe at MPC xmit to sequencer
  .wr_push_rmpc (wr_push_rmpc), // Out  Buffer write strobe at MPC received

  .wr_avail_xtmb (wr_avail_xtmb), // In  Buffer available after drift time
  .wr_avail_rtmb (wr_avail_rtmb), // Out  Buffer available at TMB matching time
  .wr_avail_xmpc (wr_avail_xmpc), // Out  Buffer available at MPC xmit to sequencer
  .wr_avail_rmpc (wr_avail_rmpc), // Out  Buffer available at MPC received

// Sequencer
  .clct0_xtmb (clct0_xtmb[MXCLCT-1:0]),  // In  First  CLCT
  .clct1_xtmb (clct1_xtmb[MXCLCT-1:0]),  // In  Second CLCT
  .clctc_xtmb (clctc_xtmb[MXCLCTC-1:0]), // In  Common to CLCT0/1 to TMB
  .clctf_xtmb (clctf_xtmb[MXCFEB-1:0]),  // In  Active cfeb list to TMB
  .clct0_bnd_xtmb   (clct0_bnd_xtmb[MXBNDB - 1   : 0]), //In
  .clct0_xky_xtmb   (clct0_xky_xtmb[MXXKYB-1 : 0]),    //In
  .clct0_gemAxky_xtmb   (clct0_gemAxky_xtmb[MXXKYB-1 : 0]),
  .clct0_gemBxky_xtmb   (clct0_gemBxky_xtmb[MXXKYB-1 : 0]),
  //.clct0_carry_xtmb (clct0_carry_xtmb[MXPATC-1:0]),  // In  First  CLCT
  .clct1_bnd_xtmb   (clct1_bnd_xtmb[MXBNDB - 1   : 0]),  // In
  .clct1_xky_xtmb   (clct1_xky_xtmb[MXXKYB-1 : 0]),   // In 
  .clct1_gemAxky_xtmb   (clct1_gemAxky_xtmb[MXXKYB-1 : 0]),
  .clct1_gemBxky_xtmb   (clct1_gemBxky_xtmb[MXXKYB-1 : 0]),
  //.clct1_carry_xtmb (clct1_carry_xtmb[MXPATC-1:0]),  // In  Second CLCT
  .bx0_xmpc   (bx0_xmpc),                // In  bx0 to mpc

  .tmb_trig_pulse    (tmb_trig_pulse),           // Out  ALCT or CLCT or both triggered
  .tmb_trig_keep     (tmb_trig_keep),            // Out  ALCT or CLCT or both triggered, and trigger is allowed
  .tmb_non_trig_keep (tmb_non_trig_keep),        // Out  Event did not trigger, but keep it for readout
  .tmb_match         (tmb_match),                // Out  ALCT and CLCT matched in time
  .tmb_alct_only     (tmb_alct_only),            // Out  Only ALCT triggered
  .tmb_clct_only     (tmb_clct_only),            // Out  Only CLCT triggered
  .tmb_match_win     (tmb_match_win[3:0]),       // Out  Location of alct in clct window
  .tmb_match_pri     (tmb_match_pri[3:0]),       // Out  Priority of clct in clct window
  .tmb_alct_discard  (tmb_alct_discard),         // Out  ALCT pair was not used for LCT
  .tmb_clct_discard  (tmb_clct_discard),         // Out  CLCT pair was not used for LCT
  .tmb_clct0_discard (tmb_clct0_discard),        // Out  CLCT0 was not used for LCT because from ME1A
  .tmb_clct1_discard (tmb_clct1_discard),        // Out  CLCT1 was not used for LCT because from ME1A
  .tmb_aff_list      (tmb_aff_list[MXCFEB-1:0]), // Out  Active CFEBs for CLCT used in TMB match
  .hmt_fired_tmb_ff  (hmt_fired_tmb_ff),         // Out  hmt fired tmb
  .hmt_readout_tmb_ff(hmt_readout_tmb_ff),       // Out hmt fired for readout
  .tmb_pulse_hmt_only(tmb_pulse_hmt_only),       // Out tmb pulse is from HMT
  .tmb_keep_hmt_only (tmb_keep_hmt_only),        // Out tmb keep is from HMT

  .tmb_match_ro     (tmb_match_ro),     // Out  ALCT and CLCT matched in time, non-triggering readout
  .tmb_alct_only_ro (tmb_alct_only_ro), // Out  Only ALCT triggered, non-triggering readout
  .tmb_clct_only_ro (tmb_clct_only_ro), // Out  Only CLCT triggered, non-triggering readout

  .tmb_no_alct   (tmb_no_alct),   // Out  No  ALCT
  .tmb_no_clct   (tmb_no_clct),   // Out  No  CLCT
  .tmb_one_alct  (tmb_one_alct),  // Out  One ALCT
  .tmb_one_clct  (tmb_one_clct),  // Out  One CLCT
  .tmb_two_alct  (tmb_two_alct),  // Out  Two ALCTs
  .tmb_two_clct  (tmb_two_clct),  // Out  Two CLCTs
  .tmb_dupe_alct (tmb_dupe_alct), // Out  ALCT0 copied into ALCT1 to make 2nd LCT
  .tmb_dupe_clct (tmb_dupe_clct), // Out  CLCT0 copied into CLCT1 to make 2nd LCT
  .tmb_rank_err  (tmb_rank_err),  // Out  LCT1 has higher quality than LCT0

  .tmb_alct0 (tmb_alct0[10:0]), // Out  ALCT best muon latched at trigger
  .tmb_alct1 (tmb_alct1[10:0]), // Out  ALCT second best muon latched at trigger
  .tmb_alctb (tmb_alctb[4:0]),  // Out  ALCT bxn latched at trigger
  .tmb_alcte (tmb_alcte[1:0]),  // Out  ALCT ecc error syndrome latched at trigger
  .tmb_cathode_hmt  (tmb_cathode_hmt[MXHMTB-1:0]),   //Out cathode hmt
  .hmt_nhits_sig_ff (hmt_nhits_sig_ff[NHMTHITB-1:0]), // Out hmt nhits for header

  //GEM-CSC match output, time_only
  .alct_gem_pulse          (alct_gem_pulse), // Out GEM-CSC matching in timing only 
  .clct_gem_pulse          (clct_gem_pulse), // Out GEM-CSC matching in timing only
  .alct_clct_gemA_pulse    (alct_clct_gemA_pulse), // Out GEM-CSC matching in timing only
  .alct_clct_gemB_pulse    (alct_clct_gemB_pulse), // Out GEM-CSC matching in timing only
  .alct_clct_gem_pulse     (alct_clct_gem_pulse), // Out GEM-CSC matching in timing only
  .alct_gem_noclct_pulse   (alct_gem_noclct_pulse), // Out GEM-CSC matching in timing only
  .clct_gem_noalct_pulse   (alct_gem_noalct_pulse), // Out GEM-CSC matching in timing only
  .alct_copad_noclct_pulse (alct_copad_noclct_pulse), // Out GEM-CSC matching in timing only
  .clct_copad_noalct_pulse (clct_copad_noalct_pulse), // Out GEM-CSC matching in timing only

  //GEM-CSC match output, time_+ position
  .alct_gemA_match_pos       (alct_gemA_match_pos),// Out GEM-CSC matching in timing and position
  .alct_gemB_match_pos       (alct_gemB_match_pos),// Out GEM-CSC matching in timing and position
  .clct_gemA_match_pos       (clct_gemA_match_pos),// Out GEM-CSC matching in timing and position
  .clct_gemB_match_pos       (clct_gemB_match_pos),// Out GEM-CSC matching in timing and position
  .alct_copad_match_pos      (alct_copad_match_pos),// Out GEM-CSC matching in timing and position
  .clct_copad_match_pos      (clct_copad_match_pos),// Out GEM-CSC matching in timing and position
  .alct_clct_copad_match_pos (alct_clct_copad_match_pos),// Out GEM-CSC matching in timing and position  
  .alct_clct_gemA_match_pos  (alct_clct_gemA_match_pos),// Out GEM-CSC matching in timing and position
  .alct_clct_gemB_match_pos  (alct_clct_gemB_match_pos),// Out GEM-CSC matching in timing and position

  .tmb_dupe_alct_run3        (tmb_dupe_alct_run3),// Out GEMCSC match results  
  .tmb_dupe_clct_run3        (tmb_dupe_clct_run3),// Out GEMCSC match results  
  .alct0fromcopad_run3       (alct0fromcopad_run3),// Out GEMCSC match results 
  .alct1fromcopad_run3       (alct1fromcopad_run3),// Out GEMCSC match results 
  .clct0fromcopad_run3       (clct0fromcopad_run3),// Out GEMCSC match results 
  .clct1fromcopad_run3       (clct1fromcopad_run3),// Out GEMCSC match results 
  .alctclctcopad_swapped     (alctclctcopad_swapped), // out, ALCT/CLCT swapped from ACLT+CLCT+copad match
  .alctclctgem_swapped       (alctclctgem_swapped),   // out, ALCT/CLCT swapped from ACLT+CLCT+gem match
  .clctcopad_swapped         (clctcopad_swapped),          // out, CLCT swapped from CLCT+copad match

  .lct0_nogem        (lct0_nogem),     //Out LCT0 without gem match found
  .lct0_with_gemA    (lct0_with_gemA), //Out LCT0 with gem match 
  .lct0_with_gemB    (lct0_with_gemB), //Out LCT0 with gem match
  .lct0_with_copad   (lct0_with_copad), //Out LCT0 with gem match,
  .lct1_nogem        (lct1_nogem),     //Out LCT1 without gem match found
  .lct1_with_gemA    (lct1_with_gemA), //Out LCT1 with gem match
  .lct1_with_gemB    (lct1_with_gemB), //Out LCT1 with gem match
  .lct1_with_copad   (lct1_with_copad), //Out LCT1 with gem match,

  .run3_trig_df   (run3_trig_df),  //In  enable Run3 trigger data format
  .run3_daq_df   (run3_daq_df), //In enable run3 daq format
  .run3_alct_df  (run3_alct_df), //In enable run3 ALCT format

// MPC Status
  .mpc_frame_ff   (mpc_frame_ff),                // Out  MPC frame latch strobe
  .mpc0_frame0_ff (mpc0_frame0_ff[MXFRAME-1:0]), // Out  MPC best muon 1st frame
  .mpc0_frame1_ff (mpc0_frame1_ff[MXFRAME-1:0]), // Out  MPC best buon 2nd frame
  .mpc1_frame0_ff (mpc1_frame0_ff[MXFRAME-1:0]), // Out  MPC second best muon 1st frame
  .mpc1_frame1_ff (mpc1_frame1_ff[MXFRAME-1:0]), // Out  MPC second best buon 2nd frame

  .mpc_xmit_lct0 (mpc_xmit_lct0), // Out  MPC LCT0 sent
  .mpc_xmit_lct1 (mpc_xmit_lct1), // Out  MPC LCT1 sent

  .mpc_response_ff (mpc_response_ff),      // Out  MPC accept latch strobe
  .mpc_accept_ff   (mpc_accept_ff[1:0]),   // Out  MPC muon accept response
  .mpc_reserved_ff (mpc_reserved_ff[1:0]), // Out  MPC reserved

// MPC
  ._mpc_rx (_mpc_rx[MXMPCRX-1:0]), // In  MPC 80MHz tx data
  ._mpc_tx (_mpc_tx[MXMPCTX-1:0]), // Out  MPC 80MHz rx data

// VME Configuration
  .alct_delay            (alct_delay[3:0]),  // In  Delay ALCT for CLCT match window
  .clct_window_in        (clct_window[3:0]), // In  CLCT match window width
  .algo2016_window       (algo2016_window[3:0]),  // In CLCT match window width (for ALCT-centric 2016 algorithm)
  .algo2016_clct_to_alct (algo2016_clct_to_alct), // In ALCT-to-CLCT matching switch: 0 - "old" CLCT-centric algorithm, 1 - algo2016 ALCT-centric algorithm

  .tmb_sync_err_en (tmb_sync_err_en[1:0]), // In  Allow sync_err to MPC for either muon
  .tmb_allow_alct  (tmb_allow_alct),       // In  Allow ALCT only
  .tmb_allow_clct  (tmb_allow_clct),       // In  Allow CLCT only
  .tmb_allow_match (tmb_allow_match),      // In  Allow ALCT+CLCT match

  .tmb_allow_alct_ro  (tmb_allow_alct_ro),  // In  Allow ALCT only  readout, non-triggering
  .tmb_allow_clct_ro  (tmb_allow_clct_ro),  // In  Allow CLCT only  readout, non-triggering
  .tmb_allow_match_ro (tmb_allow_match_ro), // In  Allow Match only readout, non-triggering
  
  .algo2016_drop_used_clcts(algo2016_drop_used_clcts),             // In Drop CLCTs from matching in ALCT-centric algorithm: 0 - algo2016 do NOT drop CLCTs, 1 - drop used CLCTs
  .algo2016_cross_bx_algorithm(algo2016_cross_bx_algorithm),       // In LCT sorting using cross BX algorithm: 0 - "old" no cross BX algorithm used, 1 - algo2016 uses cross BX algorithm
  .algo2016_clct_use_corrected_bx(algo2016_clct_use_corrected_bx), // In Use median of hits for CLCT timing: 0 - "old" no CLCT timing corrections, 1 - algo2016 CLCT timing calculated based on median of hits NOT YET IMPLEMENTED:

  .csc_id          (csc_id[MXCSC-1:0]),   // In  CSC station number
  .csc_me1ab       (csc_me1ab),           // In  1=ME1A or ME1B CSC type
  .alct_bx0_delay  (alct_bx0_delay[3:0]), // In  ALCT bx0 delay to mpc transmitter
  .clct_bx0_delay  (clct_bx0_delay[3:0]), // In  CLCT bx0 delay to mpc transmitter
  .alct_bx0_enable (alct_bx0_enable),     // In  Enable using alct bx0, else copy clct bx0
  .bx0_vpf_test    (bx0_vpf_test),        // In  Sets clct_bx0=lct0_vpf for bx0 alignment tests
  .bx0_match       (bx0_match),           // Out  ALCT bx0 and CLCT bx0 match in time
  .bx0_match2      (bx0_match2),           // Out  ALCT bx0 and CLCT bx0 match in time

  .gemA_bx0_rx     (gemA_bx0_rx),         // In GEMA BX0 received
  .gemA_bx0_delay  (gemA_bx0_delay[5:0]), // In GEMA BX0 delay value
  .gemA_bx0_enable (gemA_bx0_enable),     // IN enable GEMA BX0 delay
  .gemA_bx0_match  (gemA_bx0_match),      // out match with CLCT_BX0
  .gemA_bx0_match2 (gemA_bx0_match2),      // out match with CLCT_BX0
  .gemB_bx0_rx     (gemB_bx0_rx),         // IN GEMB BX0 received
  .gemB_bx0_delay  (gemB_bx0_delay[5:0]), // IN GEMB BX0 delay
  .gemB_bx0_enable (gemB_bx0_enable),     // IN enable GEMB BX0 delay
  .gemB_bx0_match  (gemB_bx0_match),      // out match with CLCT_BX0
  .gemB_bx0_match2 (gemB_bx0_match2),      // out match with CLCT_BX0

  .mpc_rx_delay        (mpc_rx_delay[MXMPCDLY-1:0]), // In  MPC response delay
  .mpc_tx_delay        (mpc_tx_delay[MXMPCDLY-1:0]), // In  MPC transmit delay
  .mpc_idle_blank      (mpc_idle_blank),             // In  Blank mpc output except on trigger, block bx0 too
  .mpc_me1a_block      (mpc_me1a_block),             // In  Block ME1A LCTs from MPC, but still queue for L1A readout
  .mpc_oe              (mpc_oe),                     // In  MPC output enable, 1=en
  .sync_err_blanks_mpc (sync_err_blanks_mpc),        // In  Sync error blanks LCTs to MPC

// VME Status
  .event_clear_vme  (event_clear_vme),              // In  Event clear for aff,clct,mpc vme diagnostic registers
  .hmt_nhits_bx7_vme    (hmt_nhits_bx7_vme   [NHMTHITB-1:0]),//In  HMT nhits for trigger
  .hmt_nhits_sig_vme  (hmt_nhits_sig_vme [NHMTHITB-1:0]),//In  HMT nhits for trigger
  .hmt_nhits_bkg_vme (hmt_nhits_bkg_vme[NHMTHITB-1:0]),//In  HMT nhits for trigger
  .hmt_cathode_vme      (hmt_cathode_vme[MXHMTB-1:0]),  //In  HMT trigger results

  .mpc_frame_vme    (mpc_frame_vme),                // Out MPC frame latch strobe for VME
  .mpc0_frame0_vme  (mpc0_frame0_vme[MXFRAME-1:0]), // Out  MPC best muon 1st frame
  .mpc0_frame1_vme  (mpc0_frame1_vme[MXFRAME-1:0]), // Out  MPC best buon 2nd frame
  .mpc1_frame0_vme  (mpc1_frame0_vme[MXFRAME-1:0]), // Out  MPC second best muon 1st frame
  .mpc1_frame1_vme  (mpc1_frame1_vme[MXFRAME-1:0]), // Out  MPC second best buon 2nd frame
  .mpc_accept_vme   (mpc_accept_vme[1:0]),          // Out  MPC accept latched for VME
  .mpc_reserved_vme (mpc_reserved_vme[1:0]),        // Out  MPC reserved latched for VME

  .gemcscmatch_cluster0_vme  (gemcscmatch_cluster0_vme[31:0]), // Out, 1st cluster for LCT0 from GEMCSC match
  .gemcscmatch_cluster1_vme  (gemcscmatch_cluster1_vme[31:0]), // Out, 2nd cluster for LCT1 from GEMCSC match

// MPC Injector
  .mpc_inject       (mpc_inject),            // In  Start MPC test pattern injector, VME
  .ttc_mpc_inject   (ttc_mpc_inject),        // In  Start MPC injector, ttc command
  .ttc_mpc_inj_en   (ttc_mpc_inj_en),        // In  Enable ttc_mpc_inject
  .mpc_nframes      (mpc_nframes[7:0]),      // In  Number frames to inject
  .mpc_wen          (mpc_wen[3:0]),          // In  Select RAM to write
  .mpc_ren          (mpc_ren[3:0]),          // In  Select RAM to read
  .mpc_adr          (mpc_adr[7:0]),          // In  Injector RAM read/write address
  .mpc_wdata        (mpc_wdata[15:0]),       // In  Injector RAM write data
  .mpc_rdata        (mpc_rdata[15:0]),       // Out  Injector RAM read  data
  .mpc_accept_rdata (mpc_accept_rdata[3:0]), // Out  MPC response stored in RAM
  .mpc_inj_alct_bx0 (mpc_inj_alct_bx0),      // In  ALCT bx0 injector
  .mpc_inj_clct_bx0 (mpc_inj_clct_bx0),      // In  CLCT bx0 injector

// Status
  .alct_vpf_tp    (alct_vpf_tp),    // Out  Timing test point, FF buffered for IOBs
  .clct_vpf_tp    (clct_vpf_tp),    // Out  Timing test point
  .clct_window_tp (clct_window_tp), // Out  Timing test point

  .alct0_vpf_tprt   (alct0_vpf_tprt),   // Out  Timing test point, unbuffered real time for internal scope
  .alct1_vpf_tprt   (alct1_vpf_tprt),   // Out  Timing test point
  .clct_vpf_tprt    (clct_vpf_tprt),    // Out  Timing test point
  .clct_window_tprt (clct_window_tprt), // Out  Timing test point

  .gem_foralct_vpf_tp       (gem_foralct_vpf_tp),// Out, gem for gem-alct match, from pipeline
  .gem_forclct_vpf_tp       (gem_forclct_vpf_tp),// Out, gem for gem-clct match, from pipeline
  .gem_alct_window_hasgem_tp(gem_alct_window_hasgem_tp),
  .keep_gem_tp              (keep_gem_tp), 

  .tmb_sump      (tmb_sump)            // Out  Unused signals
  );

//-------------------------------------------------------------------------------------------------------------------
//  General Purpose I/O Pin Assigments
//-------------------------------------------------------------------------------------------------------------------
  reg  [3:0]  gp_io_;            // Circumvent xst's inability to reg an inout signal
  wire        jsm_busy;          // JTAG State machine busy writing
  wire        tck_fpga = gp_io3; // TCK from FPGA JTAG chain
  wire        sel_fpga_chain;    // sel_usr[3:0]==4'hC

  wire float_gpio=jsm_busy || (sel_fpga_chain); // Float GPIO[3:0] while state machine running or fpga chain C selected

  always @* begin
  if (float_gpio) begin
  gp_io_[0]  <= 1'bz;
  gp_io_[1]  <= 1'bz;
  gp_io_[2]  <= 1'bz;
  gp_io_[3]  <= 1'bz;
  end
  else begin
  gp_io_[0]  <= rat_sn_out;      // Out  RAT dsn for debug     jtag_fgpa0 tdo (out) shunted to gp_io1, usually
  gp_io_[1]  <= alct_crc_err_tp; // Out  CRC Error test point  jtag_fpga1 tdi (in)
  gp_io_[2]  <= alct_vpf_tp;     // Out  Timing test point     jtag_fpga2 tms (in)
  gp_io_[3]  <= clct_window_tp;  // Out  Timing test point     jtag_fpga3 tck (in)
  end
  end

  assign gp_io0  = gp_io_[0];
  assign gp_io1  = gp_io_[1];
  assign gp_io2  = gp_io_[2];
  assign gp_io3  = gp_io_[3];
//assign gp_io4  = alct_wr_fifo_tp;                          // In  RPC_done
  assign gp_io5  = alct_first_frame_tp | alct_last_frame_tp; // Out  ALCT first+last frame flag
  assign gp_io6  = alct_wr_fifo_tp;                          // Out  ALCT fifo writing
  assign gp_io7  = |(demux_tp_1st | demux_tp_2nd);           // Out  CFEB Demux triad

  wire rpc_done = gp_io4;

//-------------------------------------------------------------------------------------------------------------------
// Mezzanine Test Points
//-------------------------------------------------------------------------------------------------------------------
  wire sump;              // Unused signals defined at end of module
  wire alct_startup_msec; // Msec pulse
  wire alct_wait_dll;     // Waiting for TMB DLL lock
  wire alct_wait_vme;     // Waiting for TMB VME load from user PROM
  wire alct_wait_cfg;     // Waiting for ALCT FPGA to configure from mez PROM
  wire alct_startup_done; // ALCT FPGA should be configured by now


   reg        l_tmbclk0_lock = 0;
   reg        l_qpll_lock = 0;
   reg        tmbmmcm_locklost = 0;
   reg  [7:0] tmbmmcm_locklost_cnt = 8'h00;
   reg        qpll_locklost = 0;
   reg  [7:0] qpll_locklost_cnt = 8'h00;

   always @(posedge clock or posedge ttc_resync) // things that use lhc_clk w/Reset
     begin
  if (ttc_resync || cnt_all_reset) begin // added OR with counter reset
     l_tmbclk0_lock <= 0;    // JRG, Coment this? use lhc_clk to monitor tmbclk0_lock
     tmbmmcm_locklost <= 0;
     tmbmmcm_locklost_cnt <= 8'h00;
     l_qpll_lock <= 0;    // JRG, Coment this? use lhc_clk to monitor qpll_lock
     qpll_locklost <= 0;
     qpll_locklost_cnt <= 8'h00;
  end
  else begin
     if (lock_tmb_clock0) l_tmbclk0_lock <= 1'b1;
     if (l_tmbclk0_lock & (!lock_tmb_clock0)) begin
        tmbmmcm_locklost <= 1'b1;
        if (!(&tmbmmcm_locklost_cnt[7:2])) tmbmmcm_locklost_cnt <= tmbmmcm_locklost_cnt + 1'b1; // count errors "up to FC"
     end
     if (qpll_lock) l_qpll_lock <= 1'b1;  // wait for startup-powerup
     if (l_qpll_lock & (!qpll_lock)) begin
        qpll_locklost <= 1'b1;
        if (!(&qpll_locklost_cnt[7:2])) qpll_locklost_cnt <= qpll_locklost_cnt + 1'b1; // count errors "up to FC"
     end
  end
     end // always @ (posedge clock or posedge ttc_resync)


     assign mez_tp10_busy = (raw_mez_busy | alct_startup_msec | alct_wait_dll | alct_startup_done | alct_wait_vme | alct_wait_cfg);

// JRG: if set_sw8 & 7 are both low, put BPI debug signals on the mezanine test points
    assign mez_tp[9] = (!set_sw[7] ? bpi_dtack       : (|link_bad) || ((set_sw == 2'b01) && sump));
    assign mez_tp[8] = (!set_sw[7] ? bpi_we          : (&link_good || ((set_sw == 2'b01) && alct_wait_cfg)));

    assign mez_tp[7] =   set_sw[8] ? alct_txd_posneg : (!set_sw[7] ? bpi_enbl : link_good[6]);
    assign mez_tp[6] = (!set_sw[7] ? bpi_dsbl        :                          link_good[5]);
    assign mez_tp[5] =   set_sw[8] ? alct_rxd_posneg : (!set_sw[7] ? bpi_rst  : link_good[4]);
    assign mez_tp[4] = (!set_sw[7] ? bpi_dev         :                          link_good[3]);
    
    //debugging the FC signal from cfeb gtx 
    // for debuging GEMCSC OTMB firmware, go back to above setting for normal OTMB firmware 
    //assign mez_tp[9]  = keep_gem_tp; //CLCT window for  CLCT-ALCT and CLCT-GEM
    //assign mez_tp[8]  = gem_alct_window_hasgem_tp;//gem window for gem-ALCT
    //assign mez_tp[7]  = alct0_vpf_tprt; // ALCT vpf signal
    //assign mez_tp[6]  = wr_push_xtmb; // CLCT vpf signal
    //assign mez_tp[6]  = clct_window_tprt; // CLCT vpf signal after pipeline 
    //assign mez_tp[5]  = hmt_nhits_sig >= hmt_nhits_bkg+10'h3;
    //assign mez_tp[4]  = gem_forclct_vpf_tp;//pulse width=2BX???? why????
    //assign mez_tp[5]  = (|gemA_csc_cluster_vpf) || (|gemB_csc_cluster_vpf);// gemA or gemB vpf signal
    //assign mez_tp[4]  = |copad_match; // gem copad vpf signal

//    reg  [3:1]  testled_r;
//    assign mez_tp[3] = link_good[2] || ((set_sw == 2'b01) && clock_alct_txd);
//    assign mez_tp[2] = link_good[1] || ((set_sw == 2'b01) && clock_alct_rxd);
//    assign mez_tp[1] = link_good[0] || ((set_sw == 2'b01) && clock);
//    assign mez_tp[3:1] = testled_r[3:1];


  ODDR #(
    .DDR_CLK_EDGE ("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE"
    .INIT         (1'b0),            // Initial value of Q: 1'b0 or 1'b1
    .SRTYPE       ("SYNC")           // Set/Reset type: "SYNC" or "ASYNC"
  ) test_led_3    (
  .C              (clock_alct_txd),                                              // In  1-bit clock input
  .CE             (1'b1),                                                        // In  1-bit clock enable input
  .S              (1'b0),                                                        // In  1-bit set
  .R              (1'b0),                                                        // In  1-bit reset
  .D1             (set_sw[8] ? 1'b1 : (!set_sw[7] ? bpi_active : link_good[2])), // In  1-bit data input tx on positive edge
  .D2             (set_sw[8] ? 1'b0 : (!set_sw[7] ? bpi_active : link_good[2])), // In  1-bit data input tx on negative edge
  .Q              (mez_tp[3]));                                                  // Out  1-bit DDR output


  ODDR #(
  .DDR_CLK_EDGE ("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE"
  .INIT         (1'b0),            // Initial value of Q: 1'b0 or 1'b1
  .SRTYPE       ("SYNC")           // Set/Reset type: "SYNC" or "ASYNC"
  ) test_led_2  (
//.C            (clock_alct_rxd),                  // In  1-bit clock input
  .C            (clock_gem_rxd[0]),                // In  1-bit clock input... 1MHz is for BPI_ctrl Timer
  .CE           (1'b1),                            // In  1-bit clock enable input
  .S            (1'b0),                            // In  1-bit set
  .R            (1'b0),                            // In  1-bit reset
//.D1           (set_sw[8] ? 1'b1 : link_good[1]), // In  1-bit data input tx on positive edge
//.D2           (set_sw[8] ? 1'b0 : link_good[1]), // In  1-bit data input tx on negative edge
  .D1           (1'b1),                            // In  1-bit data input tx on positive edge
  .D2           (1'b0),                            // In  1-bit data input tx on negative edge
  .Q            (mez_tp[2]));                      // Out  1-bit DDR output


  ODDR #(
  .DDR_CLK_EDGE ("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE"
  .INIT         (1'b0),            // Initial value of Q: 1'b0 or 1'b1
  .SRTYPE       ("SYNC")           // Set/Reset type: "SYNC" or "ASYNC"
  ) test_led_1  (
  .C            (clock),                                                        // In  1-bit clock input
  .CE           (1'b1),                                                         // In  1-bit clock enable input
  .S            (1'b0),                                                         // In  1-bit set
  .R            (1'b0),                                                         // In  1-bit reset
  .D1           (set_sw[8] ? 1'b1 : (!set_sw[7] ? bpi_rd_stat : link_good[0])), // In   1-bit data input tx on positive edge
  .D2           (set_sw[8] ? 1'b0 : (!set_sw[7] ? bpi_rd_stat : link_good[0])), // In   1-bit data input tx on negative edge
  .Q            (mez_tp[1]));                                                   // Out  1-bit DDR output


  x_flashsm #(22) uflash_blink_cfeb_led (.trigger(|cfeb_rx_nonzero ),    .hold(1'b0), .clock(clock), .out(blink_cfeb_led));
  x_flashsm #(22) uflash_blink_gem_led  (.trigger(gem_any),              .hold(1'b0), .clock(clock), .out(blink_gem_led));

  assign mez_led[0] = ~|link_had_err ^ blink_gem_led;   // blue OFF.  was ~alct_wait_cfg
  assign mez_led[1] = ~l_tmbclk0_lock ^ blink_cfeb_led; // green
  assign mez_led[2] =  lock_tmb_clock0;                 // yellow
  assign mez_led[3] = ~tmbmmcm_locklost;                // red
  assign mez_led[4] = ~l_qpll_lock;                     // green
  assign mez_led[5] = qpll_lock;                        // yellow
  assign mez_led[6] = ~qpll_locklost;                   // red
  assign mez_led[7] = ~|link_good;                      // green DIM.  --NAND this later?  was sump

//  assign meztp20 = alct_startup_msec;
//  assign meztp21 = alct_wait_dll;
//  assign meztp22 = alct_startup_done;
//  assign meztp23 = alct_wait_vme;
//  assign meztp24 = alct_wait_cfg;
//  assign meztp25 = lock_tmb_clock0;
//  assign meztp26 = 0;
//  assign meztp27 = sump;

//-------------------------------------------------------------------------------------------------------------------
//  Sync Error Control Instantiation
//-------------------------------------------------------------------------------------------------------------------
  sync_err_ctrl usync_err_ctrl
  (
// Clock
  .clock          (clock),          // In  Main 40MHz clock
  .ttc_resync     (ttc_resync),     // In  TTC resync command
  .sync_err_reset (sync_err_reset), // In  VME sync error reset

// Sync error sources
  .clct_bx0_sync_err   (clct_bx0_sync_err),   // In  TMB  clock pulse count err bxn!=0+offset at ttc_bx0 arrival
  .alct_ecc_rx_err     (alct_ecc_rx_err),     // In  ALCT uncorrected ECC error in data ALCT received from TMB
  .alct_ecc_tx_err     (alct_ecc_tx_err),     // In  ALCT uncorrected ECC error in data ALCT transmitted to TMB
  .bx0_match_err       (!bx0_match),          // In  ALCT alct_bx0 != clct_bx0
  .clock_lock_lost_err (clock_lock_lost_err), // In  40MHz main clock lost lock

// Sync error source enables
  .clct_bx0_sync_err_en   (clct_bx0_sync_err_en),   // In  TMB  clock pulse count err bxn!=0+offset at ttc_bx0 arrival
  .alct_ecc_rx_err_en     (alct_ecc_rx_err_en),     // In  ALCT uncorrected ECC error in data ALCT received from TMB
  .alct_ecc_tx_err_en     (alct_ecc_tx_err_en),     // In  ALCT uncorrected ECC error in data ALCT transmitted to TMB
  .bx0_match_err_en       (bx0_match_err_en),       // In  ALCT alct_bx0 != clct_bx0
  .clock_lock_lost_err_en (clock_lock_lost_err_en), // In  40MHz main clock lost lock

// Sync error action enables
  .sync_err_blanks_mpc_en    (sync_err_blanks_mpc_en),    // In  Sync error blanks LCTs to MPC
  .sync_err_stops_pretrig_en (sync_err_stops_pretrig_en), // In  Sync error stops CLCT pre-triggers
  .sync_err_stops_readout_en (sync_err_stops_readout_en), // In  Sync error stops L1A readouts
  .sync_err_forced           (sync_err_forced),           // In  Force sync_err=1

// Sync error types latched for VME readout
  .sync_err               (sync_err),               // Out  Sync error OR of enabled types of error
  .alct_ecc_rx_err_ff     (alct_ecc_rx_err_ff),     // Out  ALCT uncorrected ECC error in data ALCT received from TMB
  .alct_ecc_tx_err_ff     (alct_ecc_tx_err_ff),     // Out  ALCT uncorrected ECC error in data ALCT transmitted to TMB
  .bx0_match_err_ff       (bx0_match_err_ff),       // Out  ALCT alct_bx0 != clct_bx0
  .clock_lock_lost_err_ff (clock_lock_lost_err_ff), // Out  40MHz main clock lost lock FF

// Sync error actions
  .sync_err_blanks_mpc    (sync_err_blanks_mpc),    // Out  Sync error blanks LCTs to MPC
  .sync_err_stops_pretrig (sync_err_stops_pretrig), // Out  Sync error stops CLCT pre-triggers
  .sync_err_stops_readout (sync_err_stops_readout)  // Out  Sync error stops L1A readouts
  );

//-----------------------------------------------------------------------
// ODMB device
//-----------------------------------------------------------------------

   wire odmb_sel, bd_sel;
   wire [15:0] odmb_data;

   `ifdef ODMB_DEVICE_EN
   wire [48:0] dmb_tx_odmb;
   odmb_device odmb_device_pm (
      .clock        (clock),        // In  TMB 40MHz clock
      .clock_vme    (clock_vme),    // In  VME 10MHz clock
      .global_reset (global_reset), // In  Global reset

      .ccb_l1accept (1'b0), // this is unused; tie it off to squelch ISE
      .ccb_evcntres (1'b0), // this is unused; tie it off to squelch ISE

      .vme_address (vme_a),       // In  VME address
      .vme_data    (vme_d),       // In  VME data
      .is_read     (_vme_cmd[2]), // In  1 if read, 0 if write
      .bd_sel      (bd_sel),      // In  Board selected

      .odmb_sel  (odmb_sel),  // Out ODMB mode selected
      .odmb_data (odmb_data), // Out ODMB data

      .dmb_tx_odmb (dmb_tx_odmb),

      .sump (odmb_sump)
      );
  `else
    assign odmb_sel    = 1'b0;
    assign odmb_data   = 16'd0;
  `endif

//------------------------------------------------------------------------------------------------------------
//  VME Interface Instantiation
//------------------------------------------------------------------------------------------------------------

   defparam uvme.FIRMWARE_TYPE    = `FIRMWARE_TYPE;    // C=Normal TMB, D=Debug PCB loopback version
   defparam uvme.VERSION          = `VERSION;          // Version revision number
   defparam uvme.MONTHDAY         = `MONTHDAY;         // Version date
   defparam uvme.YEAR             = `YEAR;             // Version date
   defparam uvme.FPGAID           = `FPGAID;           // FPGA Type XCVnnnn
   defparam uvme.ISE_VERSION      = `ISE_VERSION;      // ISE Compiler version
   defparam uvme.AUTO_VME         = `AUTO_VME;         // Auto init vme registers
   defparam uvme.AUTO_JTAG        = `AUTO_JTAG;        // Auto init jtag chain
   defparam uvme.AUTO_PHASER      = `AUTO_PHASER;      // Auto init digital phase shifters
   defparam uvme.ALCT_MUONIC      = `ALCT_MUONIC;      // Floats ALCT board  in clock-space with independent time-of-flight delay
   defparam uvme.CFEB_MUONIC      = `CFEB_MUONIC;      // Floats CFEB boards in clock-space with independent time-of-flight delay
   defparam uvme.CCB_BX0_EMULATOR = `CCB_BX0_EMULATOR; // Turns on bx0 emulator at power up, must be 0 for all CERN versions

   defparam uvme.VERSION_FORMAT   = `VERSION_FORMAT;
   defparam uvme.VERSION_MAJOR    = `VERSION_MAJOR;
   defparam uvme.VERSION_MINOR    = `VERSION_MINOR;

   wire        raw_mez_busy;

   vme uvme
     (
      // Clock
      .clock               (clock),               // In  TMB 40MHz clock
      .clock_vme           (clock_vme),           // In  VME 10MHz clock
      .clock_1mhz          (clock_1mhz),          // In  1MHz BPI_ctrl Timer clock
      .tmb_clock0_ibufg    (tmb_clock0_ibufg),    // In  Raw 40MHz clock from CCB
      .clock_lock_lost_err (clock_lock_lost_err), // In  40MHz main clock lost lock FF
      .ttc_resync          (ttc_resync),          // In  TTC resync
      .global_reset        (global_reset),        // In  Global reset
      .global_reset_en     (global_reset_en),     // Out Enable global reset on lock_lost.  JG: used to be ON by default

      // Firmware version
      .cfeb_exists (cfeb_exists[MXCFEB-1:0]), // In  CFEBs instantiated in this version
      .revcode     (revcode[14:0]),           // Out Firmware revision code

      // ODMB device
      .bd_sel    (bd_sel),    // Out Board selected
      .odmb_sel  (odmb_sel),  // In  ODMB mode selected
      .odmb_data (odmb_data), // In  ODMB data

      // VME Bus Input
      .d_vme     (vme_d[15:0]),   // Bi  VME data D16
      .a         (vme_a[23:1]),   // In  VME Address A24
      .am        (vme_am[5:0]),   // In  Address modifier
      ._lword    (_vme_cmd[0]),   // In  Long word
      ._as       (_vme_cmd[1]),   // In  Address Strobe
      ._write    (_vme_cmd[2]),   // In  Write strobe
      ._ds1      (_vme_cmd[3]),   // In  Data Strobe
      ._sysclk   (_vme_cmd[4]),   // In  VME System clock
      ._ds0      (_vme_cmd[5]),   // In  Data Strobe
      ._sysfail  (_vme_cmd[6]),   // In  System fail
      ._sysreset (_vme_cmd[7]),   // In  System reset
      ._acfail   (_vme_cmd[8]),   // In  AC power fail
      ._iack     (_vme_cmd[9]),   // In  Interrupt acknowledge
      ._iackin   (_vme_cmd[10]),  // In  Interrupt in, daisy chain
      ._ga       (_vme_geo[4:0]), // In  Geographic address
      ._gap      (_vme_geo[5]),   // In  Geographic address parity
      ._local    (_vme_geo[6]),   // In  Local Addressing: 0=using HexSw, 1=using backplane /GA

      // VME Bus Output
      ._oe     (vme_reply[0]), // Out Output enable: 0=D16 drives out to VME backplane
      .dir     (vme_reply[1]), // Out Data Direction: 0=read from backplane, 1=write to backplane
      .dtack   (vme_reply[2]), // Out Data acknowledge
      .iackout (vme_reply[3]), // Out Interrupt out daisy chain
      .berr    (vme_reply[4]), // Out Bus error
      .irq     (vme_reply[5]), // Out Interrupt request
      .ready   (vme_reply[6]), // Out Ready: 1=FPGA logic is up, disconnects bootstrap logic hardware

      // Loop-Back Control
      .cfeb_oe      (cfeb_oe),      // Out 1=Enable CFEB LVDS drivers
      .alct_loop    (alct_loop),    // Out 1=ALCT loopback mode
      .alct_rxoe    (alct_rxoe),    // Out 1=Enable RAT ALCT LVDS receivers
      .alct_txoe    (alct_txoe),    // Out 1=Enable RAT ALCT LVDS drivers
      .rpc_loop     (rpc_loop),     // Out 1=RPC loopback mode no   RAT
      .rpc_loop_tmb (rpc_loop_tmb), // Out 1=RPC loopback mode with RAT
      .dmb_loop     (dmb_loop),     // Out 1=DMB loopback mode
      ._dmb_oe      (_dmb_oe),      // Out 0=Enable DMB drivers
      .gtl_loop     (gtl_loop),     // Out 1=GTL loopback mode
      ._gtl_oe      (_gtl_oe),      // Out 0=Enable GTL drivers
      .gtl_loop_lcl (gtl_loop_lcl), // Out copy for ccb.v

      // User JTAG
      .tck_usr        (jtag_usr[3]),    // IO  User JTAG tck
      .tms_usr        (jtag_usr[2]),    // IO  User JTAG tms
      .tdi_usr        (jtag_usr[1]),    // IO  User JTAG tdi
      .tdo_usr        (jtag_usr0_tdo),  // In  User JTAG tdo
      .sel_usr        (sel_usr[3:0]),   // IO  Select JTAG chain: 00=ALCT, 01=Mez FPGA+PROMs, 10=User PROMs, 11=Readback
      .sel_fpga_chain (sel_fpga_chain), // Out sel_usr[3:0]==4'hC

      // PROM
      .prom_led  (prom_led[7:0]), // Out Bi  PROM data, shared with 2 PROMs and on-board LEDs
      .prom0_clk (prom_ctrl[0]),  // Out PROM 0 clock
      .prom0_oe  (prom_ctrl[1]),  // Out 1=Output enable, 0= Reset address
      ._prom0_ce (prom_ctrl[2]),  // Out 0=Chip enable
      .prom1_clk (prom_ctrl[3]),  // Out PROM 1 clock
      .prom1_oe  (prom_ctrl[4]),  // Out 1=Output enable, 0= Reset address
      ._prom1_ce (prom_ctrl[5]),  // Out 0=Chip enable
      .jsm_busy  (jsm_busy),      // Out State machine busy writing
      .tck_fpga  (tck_fpga),      // Out TCK from FPGA JTAG chain

      // VME BPI Flash PROM
      .flash_ctrl         (flash_ctrl[3:0]), // out [3:0] JRG, goes up for I/O match to UCF with FCS,FOE,FWE,FLATCH = bpi_cs,_ccb_tx14,_ccb_tx26,_ccb_tx3
      .flash_ctrl_dualuse ({ alct_status[5], // in  [2:0] JRG, goes down to bpi_interface for MUX with FOE,FWE,FLATCH
                             tmb_reserved_in[4],
                             clct_status[3]}),
      .bpi_ad_out  (bpi_ad_out),  // Out [22:0] BPI Flash PROM Address: going to sequencer
      .bpi_active  (bpi_active),  // Out BPI Active: going to sequencer and to outside through mez_tp[3]
      .bpi_dev     (bpi_dev),     // Out BPI Device Selected: going to outside through mez_tp[4]
      .bpi_rst     (bpi_rst),     // Out BPI Reset: going to outside through mez_tp[5]
      .bpi_dsbl    (bpi_dsbl),    // Out BPI Disable: going to outside through mez_tp[6]
      .bpi_enbl    (bpi_enbl),    // Out BPI Enable: going to outside through mez_tp[7]
      .bpi_we      (bpi_we),      // Out BPI Write Enable: going to outside through mez_tp[8]
      .bpi_dtack   (bpi_dtack),   // Out BPI Data Acknowledge: going to outside through mez_tp[9]
      .bpi_rd_stat (bpi_rd_stat), // Out "Read BPI interface status register command received": going to outside through mez_tp[1]
      .bpi_re      (bpi_re),      // Out "BPI Read-back FIFO read enable": currently not connected

      // 3D3444
      .ddd_clock      (ddd_clock),      // Out  ddd clock
      .ddd_adr_latch  (ddd_adr_latch),  // Out  ddd address latch
      .ddd_serial_in  (ddd_serial_in),  // Out  ddd serial data
      .ddd_serial_out (ddd_serial_out), // In  ddd serial readback

      // Clock Single Step
      .step_alct     (step[0]),            // Out Single step ALCT clock
      .step_dmb      (step[1]),            // Out Single step DMB  clock
      .step_rpc      (step[2]),            // Out Single step RPC  clock
      .step_cfeb     (step[3]),            // Out Single step CFEB clock
      .step_run      (step[4]),            // Out 1= Single step clocks, 0 = 40MHz clocks
      .cfeb_clock_en (cfeb_clock_en[4:0]), // Out 1=Enable CFEB LVDS clock drivers
      .alct_clock_en (alct_clock_en),      // Out 1=Enable ALCT LVDS clock driver

      // Hard Resets
      ._hard_reset_alct_fpga (_hard_reset_alct_fpga), // Out Hard Reset ALCT
      ._hard_reset_tmb_fpga  (_hard_reset_tmb_fpga),  // Out Hard Reset TMB (wire-or with power-on-reset chip)

      // Status: LED
      .led_fp_lct                    (led_lct),                                                                                       // In  LCT    Blue  CLCT + ALCT match
      .led_fp_alct                   (led_alct),                                                                                      // In  ALCT  Green  ALCT valid pattern
      .led_fp_clct                   (led_clct),                                                                                      // In  CLCT  Green  CLCT valid pattern
      .led_fp_l1a                    (led_l1a_intime),                                                                                // In  L1A    Green  Level 1 Accept from CCB or internal
      .led_fp_invp                   (led_invpat),                                                                                    // In  INVP  Amber  Invalid pattern after drift delay
      .led_fp_nmat                   (led_nomatch),                                                                                   // In  NMAT  Amber  ALCT or CLCT but no match
      .led_fp_nl1a                   (led_nol1a_flush),                                                                               // In  NL1A  Red    L1A did not arrive in window
      .led_bd_in                     (led_bd[7:0]),                                                                                   // In  On-Board LEDs
      // JRG, orig:      .led_fp_out (led_fp[7:0]),                                                                                   // Out  Front Panel LEDs (on board LEDs are connected to prom_led)
      .led_fp_out                    (led_fp_tmb[7:0]),                                                                               // Out  Front Panel LEDs (on board LEDs are connected to prom_led)
      .led_tmb                       (led_tmb[15:0]),                                                                                 // In goes to BPI logic
      .led_tmb_out                   ({led_mezD8,led_mezD7,led_mezD6,led_mezD5,led_mezD4,led_mezD3,led_mezD2,led_mezD1,led_fp[7:0]}), // IO comes from BPI logic
    //.led_tmb_out                   ({meztp27,meztp26,meztp25,meztp24,meztp23,meztp22,meztp21,meztp20,led_fp[7:0]}),                 // IO comes from BPI logic

      // Status: Power Supply Comparator
      .vstat_5p0v (vstat[0]), // In  Voltage Comparator +5.0V, 1=OK
      .vstat_3p3v (vstat[1]), // In  Voltage Comparator +3.3V, 1=OK
      .vstat_1p8v (vstat[2]), // In  Voltage Comparator +1.8V, 1=OK
      .vstat_1p5v (vstat[3]), // In  Voltage Comparator +1.5V, 1=OK

      // Status: Power Supply ADC
      .adc_sclock (adc_io[0]),    // Out  ADC serial clock
      .adc_din    (adc_io[1]),    // Out  ADC serial data in
      ._adc_cs    (adc_io[2]),    // Out  ADC chip select
      .adc_dout   (adc_io3_dout), // In  Serial data from ADC

      // Status: Temperature ADC
      ._t_crit      (_t_crit),      // In  Temperature ADC Tcritical
      .smb_data     (smb_data),     // Bi  Temperature ADC serial data
      .smb_clk      (smb_clk),      // Out  Temperature ADC serial clock
      .smb_data_rat (smb_data_rat), // In  Temperature ADC on RAT module

      // Status: Digital Serial Numbers
      .mez_sn     (mez_sn),     // Bi  Mezzanine serial number
      .tmb_sn     (tmb_sn),     // Bi  TMB serial number
      .rpc_dsn    (rpc_dsn),    // In  RAT serial number, in  = rpc_dsn;
      .rat_sn_out (rat_sn_out), // Out  RAT serial number, out = rpc_posneg
      .rat_dsn_en (rat_dsn_en), // Out  RAT dsn enable

      // Clock DCM lock status
      .lock_tmb_clock0      (lock_tmb_clock0),    // In  DCM lock status
      .lock_tmb_clock0d     (lock_tmb_clock0d),   // In  DCM lock status
      .lock_alct_rxclockd   (lock_alct_rxclockd), // In  DCM lock status
      .lock_mpc_clock       (lock_mpc_clock),     // In  DCM lock status
      .lock_dcc_clock       (lock_dcc_clock),     // In  DCM lock status
      .lock_rpc_rxalt1      (lock_rpc_rxalt1),    // In  DCM lock status
      .lock_tmb_clock1      (lock_tmb_clock1),    // In  DCM lock status
      .lock_alct_rxclock    (lock_alct_rxclock),  // In  DCM lock status
      .tmbmmcm_locklost     (tmbmmcm_locklost),   // MMCM lock-lost history
      .tmbmmcm_locklost_cnt (tmbmmcm_locklost_cnt),
      .qpll_locklost        (qpll_locklost),          // QPLL lock-lost history
      .qpll_locklost_cnt    (qpll_locklost_cnt),

      // Status: Configuration State
      .tmb_cfg_done      (tmb_cfg_done),      // Out  TMB reports ready
      .alct_cfg_done     (alct_cfg_done),     // In  ALCT FPGA reports ready
      .mez_done          (mez_done),          // In  Mezzanine FPGA done loading
      .mez_busy          (raw_mez_busy),      // Out  FPGA busy (asserted during config), user I/O after config
      .alct_startup_msec (alct_startup_msec), // Out  Msec pulse
      .alct_wait_dll     (alct_wait_dll),     // Out  Waiting for TMB DLL lock
      .alct_wait_vme     (alct_wait_vme),     // Out  Waiting for TMB VME load from user PROM
      .alct_wait_cfg     (alct_wait_cfg),     // Out  Waiting for ALCT FPGA to configure from mez PROM
      .alct_startup_done (alct_startup_done), // Out  ALCT FPGA should be configured by now

      // CCB Ports: Status/Configuration
      .ccb_cmd              (ccb_cmd[7:0]),          // In  CCB command word
      .ccb_clock40_enable   (ccb_clock40_enable),    // In  Enable 40MHz clock
      .ccb_bcntres          (ccb_bcntres),           // In  Bunch crossing counter reset
      .ccb_bx0              (ccb_bx0),               // In  Bunch crossing zero
      .ccb_reserved         (ccb_reserved[4:0]),     // In  Unassigned
      .tmb_reserved         (tmb_reserved[1:0]),     // In  Unassigned
      .tmb_reserved_out     (tmb_reserved_out[2:0]), // In  Unassigned
      .tmb_hard_reset       (tmb_hard_reset  ),      // In  Reload TMB  FPGA
      .alct_hard_reset      (alct_hard_reset),       // In  Reload ALCT FPGA
      .alct_adb_pulse_sync  (alct_adb_pulse_sync),   // In  ALCT synchronous  test pulse
      .alct_adb_pulse_async (alct_adb_pulse_async),  // In  ALCT asynchronous test pulse
      .fmm_trig_stop        (fmm_trig_stop),         // In  Stop clct trigger sequencer
      .ccb_ignore_rx        (ccb_ignore_rx),         // Out  1=Ignore CCB backplane inputs
      .ccb_allow_ext_bypass (ccb_allow_ext_bypass),  // Out  1=Allow clct_ext_trigger_ccb even if ccb_ignore_rx=1
      .ccb_disable_tx       (ccb_disable_tx),        // Out  Disable CCB backplane outputs
      .ccb_int_l1a_en       (ccb_int_l1a_en),        // Out  1=Enable CCB internal l1a emulator
      .ccb_ignore_startstop (ccb_ignore_startstop),  // Out  1=ignore ttc trig_start/stop commands
      .alct_status_en       (alct_status_en),        // Out  1=Enable status GTL outputs
      .clct_status_en       (clct_status_en),        // Out  1=Enable status GTL outputs
      .ccb_status_oe        (ccb_status_oe),         // Out  1=Enable ALCT+CLCT CCB status for CCB front panel
      .ccb_status_oe_lcl    (ccb_status_oe_lcl),     // Out  copy for ccb.v logic
      .tmb_reserved_in      (tmb_reserved_in[4:0]),  // Out  CCB reserved signals from TMB

      // CCB Ports: VME TTC Command
      .vme_ccb_cmd_enable     (vme_ccb_cmd_enable),     // Out  Disconnect ccb_cmd_bpl, use vme_ccb_cmd;
      .vme_ccb_cmd            (vme_ccb_cmd[7:0]),       // Out  CCB command word
      .vme_ccb_cmd_strobe     (vme_ccb_cmd_strobe),     // Out  CCB command word strobe
      .vme_ccb_data_strobe    (vme_ccb_data_strobe),    // Out  CCB data word strobe
      .vme_ccb_subaddr_strobe (vme_ccb_subaddr_strobe), // Out  CCB subaddress strobe
      .vme_evcntres           (vme_evcntres),           // Out  Event counter reset, from VME
      .vme_bcntres            (vme_bcntres),            // Out  Bunch crossing counter reset, from VME
      .vme_bx0                (vme_bx0),                // Out  Bunch crossing zero, from VME
      .vme_bx0_emu_en         (vme_bx0_emu_en),         // Out  BX0 emulator enable
      .fmm_state              (fmm_state[2:0]),         // In  FMM machine state

      //  CCB TTC lock status
      .ccb_ttcrx_lock_never (ccb_ttcrx_lock_never),    // In  Lock never achieved
      .ccb_ttcrx_lost_ever  (ccb_ttcrx_lost_ever),     // In  Lock was lost at least once
      .ccb_ttcrx_lost_cnt   (ccb_ttcrx_lost_cnt[7:0]), // In  Number of times lock has been lost

      .ccb_qpll_lock_never (ccb_qpll_lock_never),    // In  Lock never achieved
      .ccb_qpll_lost_ever  (ccb_qpll_lost_ever),     // In  Lock was lost at least once
      .ccb_qpll_lost_cnt   (ccb_qpll_lost_cnt[7:0]), // In  Number of times lock has been lost

      // CCB Ports: Trigger Control
      .clct_ext_trig_l1aen (clct_ext_trig_l1aen), // Out  1=Request ccb l1a on clct ext_trig
      .alct_ext_trig_l1aen (alct_ext_trig_l1aen), // Out  1=Request ccb l1a on alct ext_trig
      .seq_trig_l1aen      (seq_trig_l1aen),      // Out  1=Request ccb l1a on sequencer trigger
      .alct_ext_trig_vme   (alct_ext_trig_vme),   // Out  1=Fire alct_ext_trig oneshot
      .clct_ext_trig_vme   (clct_ext_trig_vme),   // Out  1=Fire clct_ext_trig oneshot
      .ext_trig_both       (ext_trig_both),       // Out  1=clct_ext_trig fires alct and alct fires clct_trig, DC level
      .l1a_vme             (l1a_vme),             // Out  1=fire ccb_l1accept oneshot
      .l1a_delay_vme       (l1a_delay_vme[7:0]),  // Out  Internal L1A delay
      .l1a_inj_ram_en      (l1a_inj_ram_en),      // Out  L1A injector RAM enable

      // ALCT Ports: Trigger Control
      .cfg_alct_ext_trig_en   (cfg_alct_ext_trig_en),   // Out  1=Enable alct_ext_trig   from CCB
      .cfg_alct_ext_inject_en (cfg_alct_ext_inject_en), // Out  1=Enable alct_ext_inject from CCB
      .cfg_alct_ext_trig      (cfg_alct_ext_trig),      // Out  1=Assert alct_ext_trig
      .cfg_alct_ext_inject    (cfg_alct_ext_inject),    // Out  1=Assert alct_ext_inject
      .alct_clear             (alct_clear),             // Out  1=Blank alct_rx inputs
      .alct_inject            (alct_inject),            // Out  1=Start ALCT injector
      .alct_inj_ram_en        (alct_inj_ram_en),        // Out  1=Link  ALCT injector to CFEB injector RAM
      .alct_inj_delay         (alct_inj_delay[4:0]),    // Out  ALCT Injector delay
      .alct0_inj              (alct0_inj[15:0]),        // Out  ALCT0 to inject
      .alct1_inj              (alct1_inj[15:0]),        // Out  ALCT1 to inject

      // ALCT Ports: Sequencer Control/Status
      .alct0_vme          (alct0_vme[15:0]),         // In  ALCT latched at last valid pattern
      .alct1_vme          (alct1_vme[15:0]),         // In  ALCT latched at last valid pattern
      .alct_ecc_en        (alct_ecc_en),             // Out  Enable ALCT ECC decoder, else do no ECC correction
      .alct_ecc_err_blank (alct_ecc_err_blank),      // Out  Blank alcts with uncorrected ecc errors
      .alct_txd_int_delay (alct_txd_int_delay[3:0]), // Out  ALCT data transmit delay, integer bx
      .alct_clock_en_vme  (alct_clock_en_vme),       // Out  Enable ALCT 40MHz clock
      .alct_seq_cmd       (alct_seq_cmd[3:0]),       // Out  ALCT Sequencer command

      // VME ALCT sync mode ports
      .alct_sync_txdata_1st (alct_sync_txdata_1st[9:0]), // Out  ALCT sync mode data to send for loopback
      .alct_sync_txdata_2nd (alct_sync_txdata_2nd[9:0]), // Out  ALCT sync mode data to send for loopback
      .alct_sync_rxdata_dly (alct_sync_rxdata_dly[3:0]), // Out  ALCT sync mode lfsr delay pointer to valid data
      .alct_sync_rxdata_pre (alct_sync_rxdata_pre[3:0]), // Out  ALCT sync mode delay pointer to valid data, fixed pre-delay
      .alct_sync_tx_random  (alct_sync_tx_random),       // Out  ALCT sync mode tmb transmits random data to alct
      .alct_sync_clr_err    (alct_sync_clr_err),         // Out  ALCT sync mode clear rng error FFs

      .alct_sync_1st_err    (alct_sync_1st_err),      // In  ALCT sync mode 1st-intime match ok, alct-to-tmb
      .alct_sync_2nd_err    (alct_sync_2nd_err),      // In  ALCT sync mode 2nd-intime match ok, alct-to-tmb
      .alct_sync_1st_err_ff (alct_sync_1st_err_ff),   // In  ALCT sync mode 1st-intime match ok, alct-to-tmb, latched
      .alct_sync_2nd_err_ff (alct_sync_2nd_err_ff),   // In  ALCT sync mode 2nd-intime match ok, alct-to-tmb, latched
      .alct_sync_ecc_err    (alct_sync_ecc_err[1:0]), // In  ALCT sync mode ecc error syndrome

      .alct_sync_rxdata_1st    (alct_sync_rxdata_1st[28:1]),  // In  Demux data for demux timing-in
      .alct_sync_rxdata_2nd    (alct_sync_rxdata_2nd[28:1]),  // In  Demux data for demux timing-in
      .alct_sync_expect_1st    (alct_sync_expect_1st[28:1]),  // In  Expected demux data for demux timing-in
      .alct_sync_expect_2nd    (alct_sync_expect_2nd[28:1]),  // In  Expected demux data for demux timing-in

      // ALCT Raw hits RAM Ports
      .alct_raw_reset (alct_raw_reset),                 // Out  Reset raw hits write address and done flag
      .alct_raw_radr  (alct_raw_radr[MXARAMADR-1:0]),   // Out  Raw hits RAM VME read address
      .alct_raw_rdata (alct_raw_rdata[MXARAMDATA-1:0]), // In  Raw hits RAM VME read data
      .alct_raw_busy  (alct_raw_busy),                  // In  Raw hits RAM VME busy writing ALCT data
      .alct_raw_done  (alct_raw_done),                  // In  Raw hits ready for VME readout
      .alct_raw_wdcnt (alct_raw_wdcnt[MXARAMADR-1:0]),  // In  ALCT word count stored in FIFO

      // DMB Ports: Monitored Backplane Signals
      .dmb_cfeb_calibrate (dmb_cfeb_calibrate[2:0]), // In  DMB calibration
      .dmb_l1a_release    (dmb_l1a_release),         // In  DMB test
      .dmb_reserved_out   (dmb_reserved_out[4:0]),   // In  DMB unassigned
      .dmb_reserved_in    (dmb_reserved_in[2:0]),    // In  DMB unassigned
      .dmb_rx_ff          (dmb_rx_ff[5:0]),          // In  DMB received
      .dmb_tx_reserved    (dmb_tx_reserved[2:0]),    // Out  DMB backplane reserved

      // CFEB Ports: Injector Control
      .mask_all        (mask_all[MXCFEB-1:0]),   // Out  1=Enable, 0=Turn off all CFEB inputs
      .inj_last_tbin   (inj_last_tbin[11:0]),    // Out  Last tbin, may wrap past 1024 ram adr
      .inj_febsel      (inj_febsel[MXCFEB-1:0]), // Out  1=Select CFEBn for RAM read/write
      .inj_wen         (inj_wen[2:0]),           // Out  1=Write enable injector RAM
      .inj_rwadr       (inj_rwadr[9:0]),         // Out  Injector RAM read/write address
      .inj_wdata       (inj_wdata[17:0]),        // Out  Injector RAM write data
      .inj_ren         (inj_ren[2:0]),           // Out  1=Read enable Injector RAM
      .inj_rdata       (inj_rdata_mux[17:0]),    // In  Injector RAM read data
      .inj_ramout_busy (inj_ramout_busy),        // In  Injector busy

      // CFEB Triad Decoder Ports
      .triad_persist (triad_persist[3:0]), // Out  Triad 1/2-strip persistence
      .triad_clr     (triad_clr),          // Out  Triad one-shot clear

      // CFEB PreTrigger Ports
      .lyr_thresh_pretrig (lyr_thresh_pretrig[MXHITB-1:0]), // Out  Layers hit pre-trigger threshold
      .hit_thresh_pretrig (hit_thresh_pretrig[MXHITB-1:0]), // Out  Hits on pattern template pre-trigger threshold
      .pid_thresh_pretrig (pid_thresh_pretrig[MXPIDB-1:0]), // Out  Pattern shape ID pre-trigger threshold
      .dmb_thresh_pretrig (dmb_thresh_pretrig[MXHITB-1:0]), // Out  Hits on pattern template DMB active-feb threshold
      .adjcfeb_dist       (adjcfeb_dist[MXKEYB-1+1:0]),     // Out  Distance from key to cfeb boundary for marking adjacent cfeb as hit
      //Enable CCLUT or not
      .ccLUT_enable       (ccLUT_enable),  // In
      .run3_trig_df       (run3_trig_df), // output, enable run3 trigger format or not
      .run3_daq_df        (run3_daq_df),  // output, enable run3 daq format or not
      .run3_alct_df       (run3_alct_df), // Out enable run3 ALCT format

      // CFEB Ports: Hot Channel Mask
      .cfeb0_ly0_hcm (cfeb_ly0_hcm[0][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb0_ly1_hcm (cfeb_ly1_hcm[0][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb0_ly2_hcm (cfeb_ly2_hcm[0][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb0_ly3_hcm (cfeb_ly3_hcm[0][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb0_ly4_hcm (cfeb_ly4_hcm[0][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb0_ly5_hcm (cfeb_ly5_hcm[0][MXDS-1:0]), // Out  1=enable DiStrip

      .cfeb1_ly0_hcm (cfeb_ly0_hcm[1][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb1_ly1_hcm (cfeb_ly1_hcm[1][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb1_ly2_hcm (cfeb_ly2_hcm[1][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb1_ly3_hcm (cfeb_ly3_hcm[1][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb1_ly4_hcm (cfeb_ly4_hcm[1][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb1_ly5_hcm (cfeb_ly5_hcm[1][MXDS-1:0]), // Out  1=enable DiStrip

      .cfeb2_ly0_hcm (cfeb_ly0_hcm[2][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb2_ly1_hcm (cfeb_ly1_hcm[2][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb2_ly2_hcm (cfeb_ly2_hcm[2][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb2_ly3_hcm (cfeb_ly3_hcm[2][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb2_ly4_hcm (cfeb_ly4_hcm[2][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb2_ly5_hcm (cfeb_ly5_hcm[2][MXDS-1:0]), // Out  1=enable DiStrip

      .cfeb3_ly0_hcm (cfeb_ly0_hcm[3][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb3_ly1_hcm (cfeb_ly1_hcm[3][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb3_ly2_hcm (cfeb_ly2_hcm[3][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb3_ly3_hcm (cfeb_ly3_hcm[3][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb3_ly4_hcm (cfeb_ly4_hcm[3][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb3_ly5_hcm (cfeb_ly5_hcm[3][MXDS-1:0]), // Out  1=enable DiStrip

      .cfeb4_ly0_hcm (cfeb_ly0_hcm[4][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb4_ly1_hcm (cfeb_ly1_hcm[4][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb4_ly2_hcm (cfeb_ly2_hcm[4][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb4_ly3_hcm (cfeb_ly3_hcm[4][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb4_ly4_hcm (cfeb_ly4_hcm[4][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb4_ly5_hcm (cfeb_ly5_hcm[4][MXDS-1:0]), // Out  1=enable DiStrip

      .cfeb5_ly0_hcm (cfeb_ly0_hcm[5][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb5_ly1_hcm (cfeb_ly1_hcm[5][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb5_ly2_hcm (cfeb_ly2_hcm[5][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb5_ly3_hcm (cfeb_ly3_hcm[5][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb5_ly4_hcm (cfeb_ly4_hcm[5][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb5_ly5_hcm (cfeb_ly5_hcm[5][MXDS-1:0]), // Out  1=enable DiStrip

      .cfeb6_ly0_hcm (cfeb_ly0_hcm[6][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb6_ly1_hcm (cfeb_ly1_hcm[6][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb6_ly2_hcm (cfeb_ly2_hcm[6][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb6_ly3_hcm (cfeb_ly3_hcm[6][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb6_ly4_hcm (cfeb_ly4_hcm[6][MXDS-1:0]), // Out  1=enable DiStrip
      .cfeb6_ly5_hcm (cfeb_ly5_hcm[6][MXDS-1:0]), // Out  1=enable DiStrip

      // Bad CFEB rx bit detection
      .bcb_read_enable      (bcb_read_enable),                // Out  Enable blocked bits in readout
      .cfeb_badbits_reset   (cfeb_badbits_reset[MXCFEB-1:0]), // Out  Reset bad cfeb bits FFs
      .cfeb_badbits_block   (cfeb_badbits_block[MXCFEB-1:0]), // Out  Allow bad bits to block triads
      .cfeb_badbits_found   (cfeb_badbits_found[MXCFEB-1:0]), // In  CFEB[n] has at least 1 bad bit
      .cfeb_badbits_blocked (cfeb_badbits_blocked),           // Out  A CFEB had bad bits that were blocked
      .cfeb_badbits_nbx     (cfeb_badbits_nbx[15:0]),         // Out  Cycles a bad bit must be continuously high

      .cfeb0_ly0_badbits    (cfeb_ly0_badbits[0][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb0_ly1_badbits    (cfeb_ly1_badbits[0][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb0_ly2_badbits    (cfeb_ly2_badbits[0][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb0_ly3_badbits    (cfeb_ly3_badbits[0][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb0_ly4_badbits    (cfeb_ly4_badbits[0][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb0_ly5_badbits    (cfeb_ly5_badbits[0][MXDS-1:0]),  // In  1=CFEB rx bit went bad

      .cfeb1_ly0_badbits    (cfeb_ly0_badbits[1][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb1_ly1_badbits    (cfeb_ly1_badbits[1][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb1_ly2_badbits    (cfeb_ly2_badbits[1][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb1_ly3_badbits    (cfeb_ly3_badbits[1][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb1_ly4_badbits    (cfeb_ly4_badbits[1][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb1_ly5_badbits    (cfeb_ly5_badbits[1][MXDS-1:0]),  // In  1=CFEB rx bit went bad

      .cfeb2_ly0_badbits    (cfeb_ly0_badbits[2][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb2_ly1_badbits    (cfeb_ly1_badbits[2][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb2_ly2_badbits    (cfeb_ly2_badbits[2][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb2_ly3_badbits    (cfeb_ly3_badbits[2][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb2_ly4_badbits    (cfeb_ly4_badbits[2][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb2_ly5_badbits    (cfeb_ly5_badbits[2][MXDS-1:0]),  // In  1=CFEB rx bit went bad

      .cfeb3_ly0_badbits    (cfeb_ly0_badbits[3][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb3_ly1_badbits    (cfeb_ly1_badbits[3][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb3_ly2_badbits    (cfeb_ly2_badbits[3][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb3_ly3_badbits    (cfeb_ly3_badbits[3][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb3_ly4_badbits    (cfeb_ly4_badbits[3][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb3_ly5_badbits    (cfeb_ly5_badbits[3][MXDS-1:0]),  // In  1=CFEB rx bit went bad

      .cfeb4_ly0_badbits    (cfeb_ly0_badbits[4][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb4_ly1_badbits    (cfeb_ly1_badbits[4][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb4_ly2_badbits    (cfeb_ly2_badbits[4][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb4_ly3_badbits    (cfeb_ly3_badbits[4][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb4_ly4_badbits    (cfeb_ly4_badbits[4][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb4_ly5_badbits    (cfeb_ly5_badbits[4][MXDS-1:0]),  // In  1=CFEB rx bit went bad

      .cfeb5_ly0_badbits    (cfeb_ly0_badbits[5][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb5_ly1_badbits    (cfeb_ly1_badbits[5][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb5_ly2_badbits    (cfeb_ly2_badbits[5][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb5_ly3_badbits    (cfeb_ly3_badbits[5][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb5_ly4_badbits    (cfeb_ly4_badbits[5][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb5_ly5_badbits    (cfeb_ly5_badbits[5][MXDS-1:0]),  // In  1=CFEB rx bit went bad

      .cfeb6_ly0_badbits    (cfeb_ly0_badbits[6][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb6_ly1_badbits    (cfeb_ly1_badbits[6][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb6_ly2_badbits    (cfeb_ly2_badbits[6][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb6_ly3_badbits    (cfeb_ly3_badbits[6][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb6_ly4_badbits    (cfeb_ly4_badbits[6][MXDS-1:0]),  // In  1=CFEB rx bit went bad
      .cfeb6_ly5_badbits    (cfeb_ly5_badbits[6][MXDS-1:0]),  // In  1=CFEB rx bit went bad

      // Sequencer Ports: External Trigger Enables
      .clct_pat_trig_en   (clct_pat_trig_en),    // Out  Allow CLCT Pattern pre-triggers
      .alct_pat_trig_en   (alct_pat_trig_en),    // Out  Allow ALCT Pattern pre-trigger
      .alct_match_trig_en (alct_match_trig_en),  // Out  Allow ALCT*CLCT Pattern pre-trigger
      .adb_ext_trig_en    (adb_ext_trig_en),     // Out  Allow ADB Test pulse pre-trigger
      .dmb_ext_trig_en    (dmb_ext_trig_en),     // Out  Allow DMB Calibration pre-trigger
      .clct_ext_trig_en   (clct_ext_trig_en),    // Out  Allow CLCT External pre-trigger from CCB
      .alct_ext_trig_en   (alct_ext_trig_en),    // Out  Allow ALCT External pre-trigger from CCB
      .layer_trig_en      (layer_trig_en),       // Out  Allow layer-wide pre-triggering
      .all_cfebs_active   (all_cfebs_active),    // Out  Make all CFEBs active when pre-triggered
      .vme_ext_trig       (vme_ext_trig),        // Out  External pre-trigger from VME
      .cfeb_en            (cfeb_en[MXCFEB-1:0]), // Out  Enables CFEBs for triggering and active feb flag
      .active_feb_src     (active_feb_src),      // Out  Active cfeb flag source, 0=pretrig, 1=tmb-matching ~8bx later

      // Sequencer Ports: Trigger Modifiers
      .clct_flush_delay    (clct_flush_delay[MXFLUSH-1:0]), // Out  Trigger sequencer flush state timer
      .clct_throttle       (clct_throttle[MXTHROTTLE-1:0]), // Out  Pre-trigger throttle to reduce trigger rate
      .clct_wr_continuous  (clct_wr_continuous),            // Out  1=allow continuous header buffer writing for invalid triggers
      .alct_preClct_width  (alct_preClct_width[3:0]),       // Out  ALCT (alct_active_feb flag) window width for ALCT*preCLCT overlap
      .wr_buf_required     (wr_buf_required),               // Out  Require wr_buffer to pretrigger
      .wr_buf_autoclr_en   (wr_buf_autoclr_en),             // Out  Enable frozen buffer auto clear
      .valid_clct_required (valid_clct_required),           // Out  Require valid pattern after drift to trigger

      // Sequencer Ports: External Trigger Delays
      .alct_preClct_dly  (alct_preClct_dly[MXEXTDLY-1:0]),  // Out  ALCT (alct_active_feb flag) delay for ALCT*preCLCT overlap
      .alct_pat_trig_dly (alct_pat_trig_dly[MXEXTDLY-1:0]), // Out  ALCT pattern  trigger delay
      .adb_ext_trig_dly  (adb_ext_trig_dly[MXEXTDLY-1:0]),  // Out  ADB  external trigger delay
      .dmb_ext_trig_dly  (dmb_ext_trig_dly[MXEXTDLY-1:0]),  // Out  DMB  external trigger delay
      .clct_ext_trig_dly (clct_ext_trig_dly[MXEXTDLY-1:0]), // Out  CLCT external trigger delay
      .alct_ext_trig_dly (alct_ext_trig_dly[MXEXTDLY-1:0]), // Out  ALCT external trigger delay

      // Sequencer Ports: pre-CLCT modifiers for L1A*preCLCT overlap
      .l1a_preClct_width (l1a_preClct_width[3:0]), // Out  pre-CLCT window width for L1A*preCLCT overlap
      .l1a_preClct_dly   (l1a_preClct_dly[7:0]),   // Out  pre-CLCT delay for L1A*preCLCT overlap

      // Sequencer Ports: CLCT/RPC/RAT Pattern Injector
      .inj_trig_vme       (inj_trig_vme),                   // Out  Start pattern injector
      .injector_mask_cfeb (injector_mask_cfeb[MXCFEB-1:0]), // Out  Enable CFEB(n) for injector trigger
      .ext_trig_inject    (ext_trig_inject),                // Out  Changes clct_ext_trig to fire pattern injector
      .injector_mask_rat  (injector_mask_rat),              // Out  Enable RAT for injector trigger
      .injector_mask_rpc  (injector_mask_rpc),              // Out  Enable RPC for injector trigger
      .injector_mask_gem  (injector_mask_gem),              // Out  Enable GEM for injector trigger
      .inj_delay_rat      (inj_delay_rat[3:0]),             // Out  CFEB/RPC Injector waits for RAT injector
      .rpc_tbins_test     (rpc_tbins_test),                 // Out  Set write_data=address

      // Sequencer Ports: CLCT Processing
      .sequencer_state      (sequencer_state[11:0]),            // In  Sequencer state for vme
      .scint_veto_vme       (scint_veto_vme),                   // In  Scintillator veto for FAST Sites
      .drift_delay          (drift_delay[MXDRIFT-1:0]),         // Out  CSC Drift delay clocks
      .hit_thresh_postdrift (hit_thresh_postdrift[MXHITB-1:0]), // Out  Minimum pattern hits for a valid pattern
      .pid_thresh_postdrift (pid_thresh_postdrift[MXPIDB-1:0]), // Out  Minimum pattern ID   for a valid pattern
      .pretrig_halt         (pretrig_halt),                     // Out  Pretrigger and halt until unhalt arrives
      .scint_veto_clr       (scint_veto_clr),                   // Out  Clear scintillator veto ff
      .seq_trigger_nodeadtime (seq_trigger_nodeadtime),  //Out no dead time for seq-trigger

      .fifo_mode         (fifo_mode[MXFMODE-1:0]),        // Out  FIFO Mode 0=no dump,1=full,2=local,3=sync
      .fifo_tbins_cfeb   (fifo_tbins_cfeb[MXTBIN-1:0]),   // Out  Number CFEB FIFO time bins to read out
      .fifo_pretrig_cfeb (fifo_pretrig_cfeb[MXTBIN-1:0]), // Out  Number CFEB FIFO time bins before pretrigger
      .fifo_no_raw_hits  (fifo_no_raw_hits),              // Out  1=do not wait to store raw hits

      .l1a_delay        (l1a_delay[MXL1DELAY-1:0]),       // Out  Level1 Accept delay from pretrig status output
      .l1a_internal     (l1a_internal),                   // Out  Generate internal Level 1, overrides external
      .l1a_internal_dly (l1a_internal_dly[MXL1WIND-1:0]), // Out   Delay internal l1a to shift position in l1a match window
      .l1a_window       (l1a_window[MXL1WIND-1:0]),       // Out  Level1 Accept window width after delay
      .l1a_win_pri_en   (l1a_win_pri_en),                 // Out  Enable L1A window priority
      .l1a_lookback     (l1a_lookback[MXBADR-1:0]),       // Out  Bxn to look back from l1a wr_buf_adr
      .l1a_preset_sr    (l1a_preset_sr),                  // Out  Dummy VME bit to feign preset l1a sr group

      .l1a_allow_match     (l1a_allow_match),     // Out  Readout allows tmb trig pulse in L1A window (normal mode)
      .l1a_allow_notmb     (l1a_allow_notmb),     // Out  Readout allows no tmb trig pulse in L1A window
      .l1a_allow_nol1a     (l1a_allow_nol1a),     // Out  Readout allows tmb trig pulse outside L1A window
      .l1a_allow_alct_only (l1a_allow_alct_only), // Out  Allow alct_only events to readout at L1A

      .board_id           (board_id[MXBDID-1:0]),          // Out  Board ID = VME Slot
      .csc_id             (csc_id[MXCSC-1:0]),             // Out  CSC Chamber ID number
      .run_id             (run_id[MXRID-1:0]),             // Out  Run ID
      .bxn_offset_pretrig (bxn_offset_pretrig[MXBXN-1:0]), // Out  BXN offset at reset, for pretrig bxn
      .bxn_offset_l1a     (bxn_offset_l1a[MXBXN-1:0]),     // Out  BXN offset at reset, for l1a bxn
      .lhc_cycle          (lhc_cycle[MXBXN-1:0]),          // Out  LHC period, max BXN count+1
      .l1a_offset          (l1a_offset[MXL1ARX-1:0]),      // Out  L1A counter preset value

      .hmt_enable         (hmt_enable),        // In ME1a enable or not in HMT
      .hmt_me1a_enable    (hmt_me1a_enable),        // out ME1a enable or not in HMT
      .hmt_nhits_bx7_vme    (hmt_nhits_bx7_vme   [NHMTHITB-1:0]),//In  HMT nhits for trigger
      .hmt_nhits_sig_vme  (hmt_nhits_sig_vme [NHMTHITB-1:0]),//In  HMT nhits for trigger
      .hmt_nhits_bkg_vme (hmt_nhits_bkg_vme[NHMTHITB-1:0]),//In  HMT nhits for trigger
      .hmt_cathode_vme           (hmt_cathode_vme[MXHMTB-1:0]), // In HMT trigger results, cathode
      .hmt_thresh1        (hmt_thresh1[7:0]), // out, loose HMT thresh
      .hmt_thresh2        (hmt_thresh2[7:0]), // out, loose HMT thresh
      .hmt_thresh3        (hmt_thresh3[7:0]), // out, loose HMT thresh
      .cfeb_allow_hmt_ro  (cfeb_allow_hmt_ro), //Out read out CFEB when hmt is fired
      .hmt_aff_thresh      (hmt_aff_thresh[6:0]),    //Out hmt thresh
      .hmt_delay          (hmt_delay[3:0]),        //Out hmt delay for matching
      .hmt_alct_win_size  (hmt_alct_win_size[3:0]),//Out hmt-alct match window size
      .hmt_allow_cathode   (hmt_allow_cathode),//Out hmt allow to trigger on cathode
      .hmt_allow_anode     (hmt_allow_anode),  //Out hmt allow to trigger on anode
      .hmt_allow_match     (hmt_allow_match),  //Out hmt allow to trigger on canode X anode match
      .hmt_allow_cathode_ro(hmt_allow_cathode_ro), //Out hmt allow to readout on cathode
      .hmt_allow_anode_ro  (hmt_allow_anode_ro),   //Out hmt allow to readout on anode
      .hmt_allow_match_ro  (hmt_allow_match_ro),   //Out hmt allow to readout on match
      .hmt_outtime_check   (hmt_outtime_check),//In hmt fired shoudl check anode bg lower than threshold

      // Sequencer Ports: Latched CLCTs + Status
      .event_clear_vme   (event_clear_vme),         // Out  Event clear for vme diagnostic registers
      .clct0_vme         (clct0_vme[MXCLCT-1:0]),   // In  First  CLCT
      .clct1_vme         (clct1_vme[MXCLCT-1:0]),   // In  Second CLCT
      .clctc_vme         (clctc_vme[MXCLCTC-1:0]),  // In  Common to CLCT0/1 to TMB
      .clctf_vme         (clctf_vme[MXCFEB-1:0]),   // In  Active cfeb list at TMB match
      .trig_source_vme   (trig_source_vme[10:0]),   // In  Trigger source vector readback
      .nlayers_hit_vme   (nlayers_hit_vme[2:0]),    // In  Number layers hit on layer trigger
      .bxn_clct_vme      (bxn_clct_vme[MXBXN-1:0]), // In  CLCT BXN at pre-trigger
      .bxn_l1a_vme       (bxn_l1a_vme[MXBXN-1:0]),  // In  CLCT BXN at L1A
      .bxn_alct_vme      (bxn_alct_vme[4:0]),       // In  ALCT BXN at alct valid pattern flag
      .clct_bx0_sync_err (clct_bx0_sync_err),       // In  Sync error: BXN counter==0 did not match bx0

      //CCLUT, Tao 
      .clct0_vme_bnd   (clct0_vme_bnd[MXBNDB - 1   : 0]), // In clct0 new bending 
      .clct0_vme_xky   (clct0_vme_xky[MXXKYB-1 : 0]),     // In clct0 new key position with 1/8 strip resolution
      .clct0_vme_carry (clct0_vme_carry[MXPATC-1   : 0]), // In clct0 Comparator code
      .clct1_vme_bnd   (clct1_vme_bnd[MXBNDB - 1   : 0]), // In 
      .clct1_vme_xky   (clct1_vme_xky[MXXKYB-1 : 0]),    // IN 
      .clct1_vme_carry (clct1_vme_carry[MXPATC-1   : 0]),  // in

      // Sequencer Ports: Raw Hits Ram
      .dmb_wr    (dmb_wr),                   // Out  Raw hits RAM VME write enable
      .dmb_reset (dmb_reset),                // Out  Raw hits RAM VME address reset
      .dmb_adr   (dmb_adr[MXRAMADR-1:0]),    // Out  Raw hits RAM VME read/write address
      .dmb_wdata (dmb_wdata[MXRAMDATA-1:0]), // Out  Raw hits RAM VME write data
      .dmb_rdata (dmb_rdata[MXRAMDATA-1:0]), // In  Raw hits RAM VME read data
      .dmb_wdcnt (dmb_wdcnt[MXRAMADR-1:0]),  // In  Raw hits RAM VME word count
      .dmb_busy  (dmb_busy),                 // In  Raw hits RAM VME busy writing DMB data

      // GEM Ports: GEM Raw Hits Ram
      .gem_debug_fifo_reset (gem_debug_fifo_reset),     // Out Re-arm GEM debug FIFO for triggering
      .gem_debug_fifo_adr   (gem_debug_fifo_adr),       // Out Select GEM Debug FIFO Address
      .gem_debug_fifo_sel   (gem_debug_fifo_sel),       // Out Select GEM Fiber Cluster 0-3
      .gem_debug_fifo_igem  (gem_debug_fifo_igem[1:0]), // Out Select GEM Fiber 0-3
      .gem_debug_fifo_data  (gem_debug_fifo_data_vme),  // In  Multiplexed GEM Debug RAM Data

      // GEM Ports: GEM Raw Hits Ram
      .gem_inj_wen   (gem_inj_wen),      // Out GEM injector write enable
      .gem_inj_adr   (gem_inj_adr),      // Out Select GEM injector Address
      .gem_inj_sel   (gem_inj_sel),      // Out Select GEM Fiber Cluster 0-3
      .gem_inj_igem  (gem_inj_igem),     // Out Select GEM Fiber 0-3
      .gem_inj_data  (gem_inj_data_vme), // Out GEM injector RAM data

      // GEM Ports: GEM copad control
      .gem_match_neighborRoll  (gem_match_neighborRoll),  // Out copad matching with neighboring roll enable
      .gem_match_neighborPad   (gem_match_neighborPad),   // out copad matching with neighboring pad enable
      .gem_match_deltaPad      (gem_match_deltaPad[3:0]),      // Out max pad difference between two GEM chamber in copad matching

      // Sequencer Ports: Buffer Status
      .wr_buf_ready     (wr_buf_ready),                      // In  Write buffer is ready
      .wr_buf_adr       (wr_buf_adr[MXBADR-1:0]),            // In  Current address of header write buffer
      .buf_q_full       (buf_q_full),                        // In  All raw hits ram in use, ram writing must stop
      .buf_q_empty      (buf_q_empty),                       // In  No fences remain on buffer stack
      .buf_q_ovf_err    (buf_q_ovf_err),                     // In  Tried to push when stack full
      .buf_q_udf_err    (buf_q_udf_err),                     // In  Tried to pop when stack empty
      .buf_q_adr_err    (buf_q_adr_err),                     // In  Fence adr popped from stack doesnt match rls adr
      .buf_stalled      (buf_stalled),                       // In  Buffer write pointer hit a fence and is stalled now
      .buf_stalled_once (buf_stalled_once),                  // In  Buffer stalled at least once since last resync
      .buf_fence_dist   (buf_fence_dist[MXBADR-1:0]),        // In  Current distance to next fence 0 to 2047
      .buf_fence_cnt    (buf_fence_cnt[MXBADR-1+1:0]),       // In  Number of fences in fence RAM currently
      .buf_fence_cnt_peak(buf_fence_cnt_peak[MXBADR-1+1:0]), // In  Peak number of fences in fence RAM
      .buf_display       (buf_display[7:0]),                 // In  Buffer fraction in use display

      // Sequence Ports: Board Status
      .uptime    (uptime[15:0]),    // In  Uptime since last hard reset
      .bd_status (bd_status[14:0]), // Out  Board status summary

      // Sequencer Ports: Scope
      .scp_runstop    (scp_runstop),         // Out  1=run 0=stop
      .scp_auto       (scp_auto),            // Out  Sequencer readout mode
      .scp_ch_trig_en (scp_ch_trig_en),      // Out  Enable channel triggers
      .scp_trigger_ch (scp_trigger_ch[7:0]), // Out  Trigger channel 0-159
      .scp_force_trig (scp_force_trig),      // Out  Force a trigger
      .scp_ch_overlay (scp_ch_overlay),      // Out  Channel source overlay
      .scp_ram_sel    (scp_ram_sel[3:0]),    // Out  RAM bank select in VME mode
      .scp_tbins      (scp_tbins[2:0]),      // Out  Time bins per channel code, actual tbins/ch = (tbins+1)*64
      .scp_radr       (scp_radr[8:0]),       // Out  Channel data read address
      .scp_nowrite    (scp_nowrite),         // Out  Preserves initial RAM contents for testing
      .scp_waiting    (scp_waiting),         // In  Waiting for trigger
      .scp_trig_done  (scp_trig_done),       // In  Trigger done, ready for readout
      .scp_rdata      (scp_rdata[15:0]),     // In  Recorded channel data

      //  Sequencer Ports: Miniscope
      .mini_read_enable  (mini_read_enable),              // Out  Enable Miniscope readout
      .mini_tbins_test   (mini_tbins_test),               // Out  Miniscope data=address for testing
      .mini_tbins_word   (mini_tbins_word),               // Out  Insert tbins and pretrig tbins in 1st word
      .fifo_tbins_mini   (fifo_tbins_mini[MXTBIN-1:0]),   // Out  Number Mini FIFO time bins to read out
      .fifo_pretrig_mini (fifo_pretrig_mini[MXTBIN-1:0]), // Out  Number Mini FIFO time bins before pretrigger

      // TMB Ports: Configuration
      .alct_delay  (alct_delay[3:0]),  // Out  Delay ALCT for CLCT match window
      .clct_window (clct_window[3:0]), // Out  CLCT match window width
      .algo2016_window       (algo2016_window[3:0]),  // Out CLCT match window width (for ALCT-centric 2016 algorithm)
      .algo2016_clct_to_alct (algo2016_clct_to_alct), // Out ALCT-to-CLCT matching switch: 0 - "old" CLCT-centric algorithm, 1 - algo2016 ALCT-centric algorithm

      .tmb_sync_err_en (tmb_sync_err_en[1:0]), // Out  Allow sync_err to MPC for either muon
      .tmb_allow_alct  (tmb_allow_alct),       // Out  Allow ALCT only
      .tmb_allow_clct  (tmb_allow_clct),       // Out  Allow CLCT only
      .tmb_allow_match (tmb_allow_match),      // Out  Allow ALCT+CLCT match

      .tmb_allow_alct_ro  (tmb_allow_alct_ro),  // Out  Allow ALCT only  readout, non-triggering
      .tmb_allow_clct_ro  (tmb_allow_clct_ro),  // Out  Allow CLCT only  readout, non-triggering
      .tmb_allow_match_ro (tmb_allow_match_ro), // Out  Allow Match only readout, non-triggering
      
      .algo2016_use_dead_time_zone         (algo2016_use_dead_time_zone),         // Out Dead time zone switch: 0 - "old" whole chamber is dead when pre-CLCT is registered, 1 - algo2016 only half-strips around pre-CLCT are marked dead
      .algo2016_dead_time_zone_size        (algo2016_dead_time_zone_size[4:0]),   // Out Constant size of the dead time zone
      .algo2016_use_dynamic_dead_time_zone (algo2016_use_dynamic_dead_time_zone), // Out Dynamic dead time zone switch: 0 - dead time zone is set by algo2016_use_dynamic_dead_time_zone, 1 - dead time zone depends on pre-CLCT pattern ID
      .algo2016_drop_used_clcts            (algo2016_drop_used_clcts),            // Out Drop CLCTs from matching in ALCT-centric algorithm: 0 - algo2016 do NOT drop CLCTs, 1 - drop used CLCTs
      .algo2016_cross_bx_algorithm         (algo2016_cross_bx_algorithm),         // Out LCT sorting using cross BX algorithm: 0 - "old" no cross BX algorithm used, 1 - algo2016 uses cross BX algorithm
      .algo2016_clct_use_corrected_bx      (algo2016_clct_use_corrected_bx),      // Out Use median of hits for CLCT timing: 0 - "old" no CLCT timing corrections, 1 - algo2016 CLCT timing calculated based on median of hits NOT YET IMPLEMENTED:
      .evenchamber                         (evenchamber),   // evenodd parity. 1 for even chamber and 0 for odd chamber

      .alct_bx0_delay  (alct_bx0_delay[3:0]), // Out  ALCT bx0 delay to mpc transmitter
      .clct_bx0_delay  (clct_bx0_delay[3:0]), // Out  CLCT bx0 delay to mpc transmitter
      .alct_bx0_enable (alct_bx0_enable),     // Out  Enable using alct bx0, else copy clct bx0
      .bx0_vpf_test    (bx0_vpf_test),        // Out  Sets clct_bx0=lct0_vpf for bx0 alignment tests
      .bx0_match       (bx0_match),           // In  ALCT bx0 and CLCT bx0 match in time

      .gemA_bx0_delay  (gemA_bx0_delay[5:0]), // Out GEMA bx0 delay
      .gemA_bx0_enable (gemA_bx0_enable),     // Out GEMA bx0 enable. 1: use gemA_bx0_delay for GEMA, 0: use clct bx0
      .gemA_bx0_match  (gemA_bx0_match),      // In GEMA+CLCT BX0 match
      .gemB_bx0_delay  (gemB_bx0_delay[5:0]), // Out GEMA bx0 delay
      .gemB_bx0_enable (gemB_bx0_enable),     // Out GEMA bx0 enable. 1: use gemA_bx0_delay for GEMA, 0: use clct bx0
      .gemB_bx0_match  (gemB_bx0_match),      // In GEMA+CLCT BX0 match

      //GEMA trigger match control
      .match_gem_alct_delay   (match_gem_alct_delay[7:0]),  //Out gemA delay for gemA-ALCT match
      .match_gem_alct_window  (match_gem_alct_window[3:0]), //Out gemA-alct match window
      .match_gem_clct_window  (match_gem_clct_window[3:0]), //Out gemA-clct match window
      .gemA_fiber_enable      (gemA_fiber_enable[1:0]),     //Out gemA two fibers enabled or not

      //GEMB trigger match control
      //.match_gemB_alct_window (match_gemB_alct_window[3:0]),  //Out gemB-alct match window
      //.match_gemB_clct_window (match_gemB_clct_window[3:0]),  //Out gem-clct match window
      .gemB_fiber_enable      (gemB_fiber_enable[1:0]),    // Out gemB two fibers enabled or not

      .gemA_vfat_hcm       (gemA_vfat_hcm),   //Out GEMA hot vfat mask
      .gemB_vfat_hcm       (gemB_vfat_hcm),   //Out GEMA hot vfat mask

      .gemA_bxn_counter (gemA_bxn_counter[15:0]),  // In GEMA BC0 BXN counter
      .gemB_bxn_counter (gemB_bxn_counter[15:0]),   //In GEMB BC0 bxn counter
//GEM Hot channel mask
      //.gemA_vfat0_hcm    (gemA_vfat_hcm[ 0]), // Out GEM Hot channel mask 
      //.gemA_vfat1_hcm    (gemA_vfat_hcm[ 1]), // Out GEM Hot channel mask
      //.gemA_vfat2_hcm    (gemA_vfat_hcm[ 2]), // Out GEM Hot channel mask
      //.gemA_vfat3_hcm    (gemA_vfat_hcm[ 3]), // Out GEM Hot channel mask
      //.gemA_vfat4_hcm    (gemA_vfat_hcm[ 4]), // Out GEM Hot channel mask
      //.gemA_vfat5_hcm    (gemA_vfat_hcm[ 5]), // Out GEM Hot channel mask
      //.gemA_vfat6_hcm    (gemA_vfat_hcm[ 6]), // Out GEM Hot channel mask
      //.gemA_vfat7_hcm    (gemA_vfat_hcm[ 7]), // Out GEM Hot channel mask
      //.gemA_vfat8_hcm    (gemA_vfat_hcm[ 8]), // Out GEM Hot channel mask
      //.gemA_vfat9_hcm    (gemA_vfat_hcm[ 9]), // Out GEM Hot channel mask
      //.gemA_vfat10_hcm   (gemA_vfat_hcm[10]), // Out GEM Hot channel mask
      //.gemA_vfat11_hcm   (gemA_vfat_hcm[11]), // Out GEM Hot channel mask
      //.gemA_vfat12_hcm   (gemA_vfat_hcm[12]), // Out GEM Hot channel mask
      //.gemA_vfat13_hcm   (gemA_vfat_hcm[13]), // Out GEM Hot channel mask
      //.gemA_vfat14_hcm   (gemA_vfat_hcm[14]), // Out GEM Hot channel mask
      //.gemA_vfat15_hcm   (gemA_vfat_hcm[15]), // Out GEM Hot channel mask
      //.gemA_vfat16_hcm   (gemA_vfat_hcm[16]), // Out GEM Hot channel mask
      //.gemA_vfat17_hcm   (gemA_vfat_hcm[17]), // Out GEM Hot channel mask
      //.gemA_vfat18_hcm   (gemA_vfat_hcm[18]), // Out GEM Hot channel mask
      //.gemA_vfat19_hcm   (gemA_vfat_hcm[19]), // Out GEM Hot channel mask
      //.gemA_vfat20_hcm   (gemA_vfat_hcm[20]), // Out GEM Hot channel mask
      //.gemA_vfat21_hcm   (gemA_vfat_hcm[21]), // Out GEM Hot channel mask
      //.gemA_vfat22_hcm   (gemA_vfat_hcm[22]), // Out GEM Hot channel mask
      //.gemA_vfat23_hcm   (gemA_vfat_hcm[23]), // Out GEM Hot channel mask
      //.gemB_vfat0_hcm    (gemB_vfat_hcm[ 0]), // Out GEM Hot channel mask
      //.gemB_vfat1_hcm    (gemB_vfat_hcm[ 1]), // Out GEM Hot channel mask
      //.gemB_vfat2_hcm    (gemB_vfat_hcm[ 2]), // Out GEM Hot channel mask
      //.gemB_vfat3_hcm    (gemB_vfat_hcm[ 3]), // Out GEM Hot channel mask
      //.gemB_vfat4_hcm    (gemB_vfat_hcm[ 4]), // Out GEM Hot channel mask
      //.gemB_vfat5_hcm    (gemB_vfat_hcm[ 5]), // Out GEM Hot channel mask
      //.gemB_vfat6_hcm    (gemB_vfat_hcm[ 6]), // Out GEM Hot channel mask
      //.gemB_vfat7_hcm    (gemB_vfat_hcm[ 7]), // Out GEM Hot channel mask
      //.gemB_vfat8_hcm    (gemB_vfat_hcm[ 8]), // Out GEM Hot channel mask
      //.gemB_vfat9_hcm    (gemB_vfat_hcm[ 9]), // Out GEM Hot channel mask
      //.gemB_vfat10_hcm   (gemB_vfat_hcm[10]), // Out GEM Hot channel mask
      //.gemB_vfat11_hcm   (gemB_vfat_hcm[11]), // Out GEM Hot channel mask
      //.gemB_vfat12_hcm   (gemB_vfat_hcm[12]), // Out GEM Hot channel mask
      //.gemB_vfat13_hcm   (gemB_vfat_hcm[13]), // Out GEM Hot channel mask
      //.gemB_vfat14_hcm   (gemB_vfat_hcm[14]), // Out GEM Hot channel mask
      //.gemB_vfat15_hcm   (gemB_vfat_hcm[15]), // Out GEM Hot channel mask
      //.gemB_vfat16_hcm   (gemB_vfat_hcm[16]), // Out GEM Hot channel mask
      //.gemB_vfat17_hcm   (gemB_vfat_hcm[17]), // Out GEM Hot channel mask
      //.gemB_vfat18_hcm   (gemB_vfat_hcm[18]), // Out GEM Hot channel mask
      //.gemB_vfat19_hcm   (gemB_vfat_hcm[19]), // Out GEM Hot channel mask
      //.gemB_vfat20_hcm   (gemB_vfat_hcm[20]), // Out GEM Hot channel mask
      //.gemB_vfat21_hcm   (gemB_vfat_hcm[21]), // Out GEM Hot channel mask
      //.gemB_vfat22_hcm   (gemB_vfat_hcm[22]), // Out GEM Hot channel mask
      //.gemB_vfat23_hcm   (gemB_vfat_hcm[23]), // Out GEM Hot channel mask

      .mpc_rx_delay    (mpc_rx_delay[MXMPCDLY-1:0]), // Out  MPC response delay
      .mpc_tx_delay    (mpc_tx_delay[MXMPCDLY-1:0]), // Out  MPC transmit delay
      .mpc_sel_ttc_bx0 (mpc_sel_ttc_bx0),            // Out  MPC gets ttc_bx0 or bx0_local
      .mpc_me1a_block  (mpc_me1a_block),             // Out  Block ME1A LCTs from MPC, but still queue for L1A readout
      .mpc_idle_blank  (mpc_idle_blank),             // Out  Blank mpc output except on trigger, block bx0 too
      .mpc_oe          (mpc_oe),                     // Out  MPC output enable, 1=en

      // TMB Ports: Status
      .mpc_frame_vme    (mpc_frame_vme),                // In MPC frame latch strobe for VME
      .mpc0_frame0_vme  (mpc0_frame0_vme[MXFRAME-1:0]), // In  MPC best muon 1st frame
      .mpc0_frame1_vme  (mpc0_frame1_vme[MXFRAME-1:0]), // In  MPC best buon 2nd frame
      .mpc1_frame0_vme  (mpc1_frame0_vme[MXFRAME-1:0]), // In  MPC second best muon 1st frame
      .mpc1_frame1_vme  (mpc1_frame1_vme[MXFRAME-1:0]), // In  MPC second best buon 2nd frame
      .mpc_accept_vme   (mpc_accept_vme[1:0]),          // In  MPC accept response
      .mpc_reserved_vme (mpc_reserved_vme[1:0]),        // In  MPC reserved response

      // TMB Ports: MPC Injector Control
      .mpc_inject       (mpc_inject),            // Out  Start MPC test pattern injector
      .ttc_mpc_inj_en   (ttc_mpc_inj_en),        // Out  Enable ttc_mpc_inject
      .mpc_nframes      (mpc_nframes[7:0]),      // Out  Number frames to inject
      .mpc_wen          (mpc_wen[3:0]),          // Out  Select RAM to write
      .mpc_ren          (mpc_ren[3:0]),          // Out  Select RAM to read
      .mpc_adr          (mpc_adr[7:0]),          // Out  Injector RAM read/write address
      .mpc_wdata        (mpc_wdata[15:0]),       // Out  Injector RAM write data
      .mpc_rdata        (mpc_rdata[15:0]),       // In  Injector RAM read  data
      .mpc_accept_rdata (mpc_accept_rdata[3:0]), // In  MPC response stored in RAM
      .mpc_inj_alct_bx0 (mpc_inj_alct_bx0),      // Out  ALCT bx0 injector
      .mpc_inj_clct_bx0 (mpc_inj_clct_bx0),      // Out  CLCT bx0 injector

      // CFEB data received on optical link
      .gtx_rx_data_bits_or(|gtx_rx_data_bits_or), // In  CFEB data received on optical link = OR of all bits for ALL CFEBs

      // RPC VME Configuration Ports
      .rpc_done         (rpc_done),                     // In  rpc_done
      .rpc_exists       (rpc_exists[MXRPC-1:0]),        // Out  RPC Readout list
      .rpc_read_enable  (rpc_read_enable),              // Out  1 Enable RPC Readout
      .fifo_tbins_rpc   (fifo_tbins_rpc[MXTBIN-1:0]),   // Out  Number RPC FIFO time bins to read out
      .fifo_pretrig_rpc (fifo_pretrig_rpc[MXTBIN-1:0]), // Out  Number RPC FIFO time bins before pretrigger

      // GEM VME Configuration Ports
      .gem_read_enable     (gem_read_enable),              // Out  1 = Enable GEM Readout
      //.gem_exists          (gem_exists[MXGEM-1:0]),        // In   GEM existence flags
      .gem_read_mask       (gem_read_mask[MXGEM-1:0]),        // Out  GEM enable flags
      .gem_zero_suppress   (gem_zero_suppress),            // Out  1 = Enable GEM Readout Zero-suppression
      .fifo_tbins_gem      (fifo_tbins_gem[MXTBIN-1:0]),   // Out  Number GEM FIFO time bins to read out
      .fifo_pretrig_gem    (fifo_pretrig_gem[MXTBIN-1:0]), // Out  Number GEM FIFO time bins before pretrigger

      //GEM-CSC match window, deltahs, deltawire
      .gem_clct_deltahs_odd      (gem_clct_deltahs_odd[4:0]),               // Out  GEM GEM-CSC match window, deltahs, the final window is deltahs*2+1
      .gem_clct_deltahs_even     (gem_clct_deltahs_even[4:0]),               // Out  GEM GEM-CSC match window, deltahs, the final window is deltahs*2+1
      .gem_alct_deltawire_odd    (gem_alct_deltawire_odd[2:0]),               // Out GEM-CSC match window, deltawire, final window is deltawire*2+1
      .gem_alct_deltawire_even   (gem_alct_deltawire_even[2:0]),               // Out GEM-CSC match window, deltawire, final window is deltawire*2+1

      //GEM-CSC match control
      .gem_me1a_match_enable     (gem_me1a_match_enable),       //Out gem-csc match in me1a
      .gem_me1b_match_enable     (gem_me1b_match_enable),       //Out gem-csc match in me1b

      .gemcsc_match_extrapolate    (gemcsc_match_extrapolate),    //Out enable GEMCSC match using extrapolation
      .gemcsc_match_bend_correction(gemcsc_match_bend_correction),//Out correct bending angle with GEMCSC bending
      .gemcsc_match_tightwindow    (gemcsc_match_tightwindow),    //Out use tight window when extrapolation is used
    
      .match_drop_lowqalct         (match_drop_lowqalct),       //Out gem-csc match drop lowQ stub 
      .me1a_match_drop_lowqclct    (me1a_match_drop_lowqclct),       //Out gem-csc match drop lowQ stub 
      .me1b_match_drop_lowqclct    (me1b_match_drop_lowqclct),       //Out gem-csc match drop lowQ stub 
      .tmb_copad_alct_allow_ro      (tmb_copad_alct_allow_ro),       //In gem-csc match, allow ALCT+copad match for readout
      .tmb_copad_clct_allow_ro      (tmb_copad_clct_allow_ro),       //In gem-csc match, allow CLCT+copad match for readout
      .tmb_copad_alct_allow      (tmb_copad_alct_allow),       //In gem-csc match, allow ALCT+copad match for triggering
      .tmb_copad_clct_allow      (tmb_copad_clct_allow),       //In gem-csc match, allow CLCT+copad match for triggering
      //.gem_me1a_match_promotequal  (gem_me1a_match_promotequal),     //Out promote quality or not for match in ME1a region, 
      //.gem_me1b_match_promotequal  (gem_me1b_match_promotequal),     //Out promote quality or not for match in ME1b region 
      //.gem_me1a_match_promotepat   (gem_me1a_match_promotepat),     //Out promote pattern or not for match in ME1a region, 
      //.gem_me1b_match_promotepat   (gem_me1b_match_promotepat),     //Out promote pattern or not for match in ME1b region 
      //.gemA_match_enable           (gemA_match_enable),         // out enable GEMA for match
      //.gemB_match_enable           (gemB_match_enable),         // out enable GEMB for match
      .gemA_match_ignore_position     (gemA_match_ignore_position),             //out GEMCSC match, no position match
      .gemB_match_ignore_position     (gemB_match_ignore_position),             //out GEMCSC match, no position match
      .gemcsc_bend_enable          (gemcsc_bend_enable),         // out enable GEMCSC bending angle for match
      .gemcsc_ignore_bend_check    (gemcsc_ignore_bend_check),             //In GEMCSC ignore GEMCSC bending direction and CSC bend direction check

      .gemcscmatch_cluster0_vme  (gemcscmatch_cluster0_vme[31:0]), // in, 1st cluster for LCT0 from GEMCSC match
      .gemcscmatch_cluster1_vme  (gemcscmatch_cluster1_vme[31:0]), // in, 2nd cluster for LCT1 from GEMCSC match

      // RPC Ports: RAT Control                                                                                      
      .rpc_sync     (rpc_sync),     // Out  Sync mode
      .rpc_posneg   (rpc_posneg),   // Out  Clock phase
      .rpc_free_tx0 (rpc_free_tx0), // Out  Unassigned

      // RPC Ports: RAT 3D3444 Delay Signals
      .dddr_clock     (dddr_clock),     // Out  DDDR clock      / rpc_sync
      .dddr_adr_latch (dddr_adr_latch), // Out  DDDR address latch  / rpc_posneg
      .dddr_serial_in (dddr_serial_in), // Out  DDDR serial in    / rpc_loop_tmb
      .dddr_busy      (dddr_busy),      // Out  DDDR busy      / rpc_free_tx0

      // RPC Raw Hits Delay Ports
      .rpc0_delay (rpc0_delay[3:0]), // Out  RPC data delay value
      .rpc1_delay (rpc1_delay[3:0]), // Out  RPC data delay value

      // RPC Injector Ports
      .rpc_mask_all  (rpc_mask_all),               // Out  1=Enable, 0=Turn off all RPC inputs
      .rpc_inj_sel   (rpc_inj_sel),                // Out  1=Enable RAM write
      .rpc_inj_wen   (rpc_inj_wen[MXRPC-1:0]),     // Out  1=Write enable injector RAM
      .rpc_inj_rwadr (rpc_inj_rwadr[9:0]),         // Out  Injector RAM read/write address
      .rpc_inj_wdata (rpc_inj_wdata[MXRPCDB-1:0]), // Out  Injector RAM write data
      .rpc_inj_ren   (rpc_inj_ren[MXRPC-1:0]),     // Out  1=Read enable Injector RAM
      .rpc_inj_rdata (rpc_inj_rdata[MXRPCDB-1:0]), // In  Injector RAM read data

      // RPC Ports: Raw Hits RAM
      .rpc_bank  (rpc_bank[MXRPCB-1:0]), // Out  RPC bank address
      .rpc_rdata (rpc_rdata[15:0]),      // In  RPC RAM read data
      .rpc_rbxn  (rpc_rbxn[2:0]),        // In  RPC RAM read bxn

      // RPC Hot Channel Mask Ports
      .rpc0_hcm (rpc0_hcm[MXRPCPAD-1:0]), // Out  1=enable RPC pad
      .rpc1_hcm (rpc1_hcm[MXRPCPAD-1:0]), // Out  1=enable RPC pad

      // RPC Bxn Offset
      .rpc_bxn_offset (rpc_bxn_offset[3:0]), // Out  RPC bunch crossing offset
      .rpc0_bxn_diff  (rpc0_bxn_diff[3:0]),  // In  RPC - offset
      .rpc1_bxn_diff  (rpc1_bxn_diff[3:0]),  // In  RPC - offset

      // ALCT Trigger/Readout Counter Ports
      .cnt_all_reset    (cnt_all_reset),    // Out  Trigger/Readout counter reset
      .cnt_stop_on_ovf  (cnt_stop_on_ovf),  // Out  Stop all counters if any overflows
      .cnt_non_me1ab_en (cnt_non_me1ab_en), // Out  Allow clct pretrig counters count non me1ab
      .cnt_alct_debug   (cnt_alct_debug),   // Out  Enable alct lct error counter
      .cnt_any_ovf_alct (cnt_any_ovf_alct), // In  At least one alct counter overflowed
      .cnt_any_ovf_seq  (cnt_any_ovf_seq),  // In  At least one sequencer counter overflowed

      // ALCT Event Counters
      .event_counter0  (event_counter0[MXCNTVME-1:0]),  // In  ALCT event counters
      .event_counter1  (event_counter1[MXCNTVME-1:0]),  // In
      .event_counter2  (event_counter2[MXCNTVME-1:0]),  // In
      .event_counter3  (event_counter3[MXCNTVME-1:0]),  // In
      .event_counter4  (event_counter4[MXCNTVME-1:0]),  // In
      .event_counter5  (event_counter5[MXCNTVME-1:0]),  // In
      .event_counter6  (event_counter6[MXCNTVME-1:0]),  // In
      .event_counter7  (event_counter7[MXCNTVME-1:0]),  // In
      .event_counter8  (event_counter8[MXCNTVME-1:0]),  // In
      .event_counter9  (event_counter9[MXCNTVME-1:0]),  // In
      .event_counter10 (event_counter10[MXCNTVME-1:0]), // In
      .event_counter11 (event_counter11[MXCNTVME-1:0]), // In
      .event_counter12 (event_counter12[MXCNTVME-1:0]), // In

      // TMB+CLCT Event Counters
      .event_counter13 (event_counter13[MXCNTVME-1:0]), // In  TMB event counters
      .event_counter14 (event_counter14[MXCNTVME-1:0]), // In
      .event_counter15 (event_counter15[MXCNTVME-1:0]), // In
      .event_counter16 (event_counter16[MXCNTVME-1:0]), // In
      .event_counter17 (event_counter17[MXCNTVME-1:0]), // In
      .event_counter18 (event_counter18[MXCNTVME-1:0]), // In
      .event_counter19 (event_counter19[MXCNTVME-1:0]), // In
      .event_counter20 (event_counter20[MXCNTVME-1:0]), // In
      .event_counter21 (event_counter21[MXCNTVME-1:0]), // In
      .event_counter22 (event_counter22[MXCNTVME-1:0]), // In
      .event_counter23 (event_counter23[MXCNTVME-1:0]), // In
      .event_counter24 (event_counter24[MXCNTVME-1:0]), // In
      .event_counter25 (event_counter25[MXCNTVME-1:0]), // In
      .event_counter26 (event_counter26[MXCNTVME-1:0]), // In
      .event_counter27 (event_counter27[MXCNTVME-1:0]), // In
      .event_counter28 (event_counter28[MXCNTVME-1:0]), // In
      .event_counter29 (event_counter29[MXCNTVME-1:0]), // In
      .event_counter30 (event_counter30[MXCNTVME-1:0]), // In
      .event_counter31 (event_counter31[MXCNTVME-1:0]), // In
      .event_counter32 (event_counter32[MXCNTVME-1:0]), // In
      .event_counter33 (event_counter33[MXCNTVME-1:0]), // In
      .event_counter34 (event_counter34[MXCNTVME-1:0]), // In
      .event_counter35 (event_counter35[MXCNTVME-1:0]), // In
      .event_counter36 (event_counter36[MXCNTVME-1:0]), // In
      .event_counter37 (event_counter37[MXCNTVME-1:0]), // In
      .event_counter38 (event_counter38[MXCNTVME-1:0]), // In
      .event_counter39 (event_counter39[MXCNTVME-1:0]), // In
      .event_counter40 (event_counter40[MXCNTVME-1:0]), // In
      .event_counter41 (event_counter41[MXCNTVME-1:0]), // In
      .event_counter42 (event_counter42[MXCNTVME-1:0]), // In
      .event_counter43 (event_counter43[MXCNTVME-1:0]), // In
      .event_counter44 (event_counter44[MXCNTVME-1:0]), // In
      .event_counter45 (event_counter45[MXCNTVME-1:0]), // In
      .event_counter46 (event_counter46[MXCNTVME-1:0]), // In
      .event_counter47 (event_counter47[MXCNTVME-1:0]), // In
      .event_counter48 (event_counter48[MXCNTVME-1:0]), // In
      .event_counter49 (event_counter49[MXCNTVME-1:0]), // In
      .event_counter50 (event_counter50[MXCNTVME-1:0]), // In
      .event_counter51 (event_counter51[MXCNTVME-1:0]), // In
      .event_counter52 (event_counter52[MXCNTVME-1:0]), // In
      .event_counter53 (event_counter53[MXCNTVME-1:0]), // In
      .event_counter54 (event_counter54[MXCNTVME-1:0]), // In
      .event_counter55 (event_counter55[MXCNTVME-1:0]), // In
      .event_counter56 (event_counter56[MXCNTVME-1:0]), // In
      .event_counter57 (event_counter57[MXCNTVME-1:0]), // In
      .event_counter58 (event_counter58[MXCNTVME-1:0]), // In
      .event_counter59 (event_counter59[MXCNTVME-1:0]), // In
      .event_counter60 (event_counter60[MXCNTVME-1:0]), // In
      .event_counter61 (event_counter61[MXCNTVME-1:0]), // In
      .event_counter62 (event_counter62[MXCNTVME-1:0]), // In
      .event_counter63 (event_counter63[MXCNTVME-1:0]), // In
      .event_counter64 (event_counter64[MXCNTVME-1:0]), // In
      .event_counter65 (event_counter65[MXCNTVME-1:0]), // In

      // Header Counter Ports
      .hdr_clear_on_resync (hdr_clear_on_resync),           // Out  Clear header counters on ttc_resync
      .pretrig_counter     (pretrig_counter[MXCNTVME-1:0]), // In  Pre-trigger counter
      .seq_pretrig_counter (seq_pretrig_counter[MXCNTVME-1:0]), // Out  consecutive Pre-trigger counter (equential, 1 bx apart)
      .almostseq_pretrig_counter (almostseq_pretrig_counter[MXCNTVME-1:0]), // Out  Pre-triggers-2bx-apart counter
      .clct_counter        (clct_counter[MXCNTVME-1:0]),    // In  CLCT counter
      .trig_counter        (trig_counter[MXCNTVME-1:0]),    // In  TMB trigger counter
      .alct_counter        (alct_counter[MXCNTVME-1:0]),    // In  ALCTs received counter
      .l1a_rx_counter      (l1a_rx_counter[MXL1ARX-1:0]),   // In  L1As received from ccb counter
      .readout_counter     (readout_counter[MXL1ARX-1:0]),  // In  Readout counter
      .orbit_counter       (orbit_counter[MXORBIT-1:0]),    // In  Orbit counter

      // ALCT Structure Error Counters
      .alct_err_counter0    (alct_err_counter0[7:0]),      // In  Error counter 1D remap
      .alct_err_counter1    (alct_err_counter1[7:0]),      // In
      .alct_err_counter2    (alct_err_counter2[7:0]),      // In
      .alct_err_counter3    (alct_err_counter3[7:0]),      // In
      .alct_err_counter4    (alct_err_counter4[7:0]),      // In
      .alct_err_counter5    (alct_err_counter5[7:0]),      // In

      // CLCT pre-trigger coincidence counters
      .preClct_l1a_counter  (preClct_l1a_counter[MXCNTVME-1:0]),  // In
      .preClct_alct_counter (preClct_alct_counter[MXCNTVME-1:0]), // In

      // Active CFEB(s) counters
      .active_cfebs_event_counter      (active_cfebs_event_counter[MXCNTVME-1:0]),      // In
      .active_cfebs_me1a_event_counter (active_cfebs_me1a_event_counter[MXCNTVME-1:0]), // In
      .active_cfebs_me1b_event_counter (active_cfebs_me1b_event_counter[MXCNTVME-1:0]), // In
      .active_cfeb0_event_counter      (active_cfeb0_event_counter[MXCNTVME-1:0]),      // In
      .active_cfeb1_event_counter      (active_cfeb1_event_counter[MXCNTVME-1:0]),      // In
      .active_cfeb2_event_counter      (active_cfeb2_event_counter[MXCNTVME-1:0]),      // In
      .active_cfeb3_event_counter      (active_cfeb3_event_counter[MXCNTVME-1:0]),      // In
      .active_cfeb4_event_counter      (active_cfeb4_event_counter[MXCNTVME-1:0]),      // In
      .active_cfeb5_event_counter      (active_cfeb5_event_counter[MXCNTVME-1:0]),      // In
      .active_cfeb6_event_counter      (active_cfeb6_event_counter[MXCNTVME-1:0]),      // In

      .bx0_match_counter (bx0_match_counter), // IN ALCT-CLCT BX0 match

      .hmt_counter0  (hmt_counter0[MXCNTVME-1:0]),  //In 
      .hmt_counter1  (hmt_counter1[MXCNTVME-1:0]),  //In 
      .hmt_counter2  (hmt_counter2[MXCNTVME-1:0]),  //In 
      .hmt_counter3  (hmt_counter3[MXCNTVME-1:0]),  //In 
      .hmt_counter4  (hmt_counter4[MXCNTVME-1:0]),  //In 
      .hmt_counter5  (hmt_counter5[MXCNTVME-1:0]),  //In 
      .hmt_counter6  (hmt_counter6[MXCNTVME-1:0]),  //In 
      .hmt_counter7  (hmt_counter7[MXCNTVME-1:0]),  //In 
      .hmt_counter8  (hmt_counter8[MXCNTVME-1:0]),  //In 
      .hmt_counter9  (hmt_counter9[MXCNTVME-1:0]),  //In 
      .hmt_counter10 (hmt_counter10[MXCNTVME-1:0]),  //In
      .hmt_counter11 (hmt_counter11[MXCNTVME-1:0]),  //In
      .hmt_counter12 (hmt_counter12[MXCNTVME-1:0]),  //In
      .hmt_counter13 (hmt_counter13[MXCNTVME-1:0]),  //In
      .hmt_counter14 (hmt_counter14[MXCNTVME-1:0]),  //In
      .hmt_counter15 (hmt_counter15[MXCNTVME-1:0]),  //In
      .hmt_counter16 (hmt_counter16[MXCNTVME-1:0]),  //In
      .hmt_counter17 (hmt_counter17[MXCNTVME-1:0]),  //In
      .hmt_counter18 (hmt_counter18[MXCNTVME-1:0]),  //In
      .hmt_counter19 (hmt_counter19[MXCNTVME-1:0]),  //In
      .hmt_trigger_counter (hmt_trigger_counter[MXCNTVME-1:0]), //in
      .hmt_readout_counter (hmt_readout_counter[MXCNTVME-1:0]), //in
      .hmt_aff_counter     (hmt_aff_counter[MXCNTVME-1:0]), //In
      .buf_stall_counter   (buf_stall_counter[MXCNTVME-1:0]),//In
      
      .new_counter0  (new_counter0 [MXCNTVME-1:0]),  //In 
      .new_counter1  (new_counter1 [MXCNTVME-1:0]),  //In 
      // GEM Trigger/Readout Counter Ports
      .gem_cnt_all_reset    (gem_cnt_all_reset),     // Out  Trigger/Readout counter reset
      .gem_cnt_stop_on_ovf  (gem_cnt_stop_on_ovf),   // Out  Stop all counters if any overflows
      .gem_cnt_any_ovf_seq  (gem_cnt_any_ovf_seq),   // In   At least one gem sequencer counter overflowed

      .gem_counter0   (gem_counter0),
      .gem_counter1   (gem_counter1),
      .gem_counter2   (gem_counter2),
      .gem_counter3   (gem_counter3),
      .gem_counter4   (gem_counter4),
      .gem_counter5   (gem_counter5),
      .gem_counter6   (gem_counter6),
      .gem_counter7   (gem_counter7),
      .gem_counter8   (gem_counter8),
      .gem_counter9   (gem_counter9),
      .gem_counter10  (gem_counter10),
      .gem_counter11  (gem_counter11),
      .gem_counter12  (gem_counter12),
      .gem_counter13  (gem_counter13),
      .gem_counter14  (gem_counter14),
      .gem_counter15  (gem_counter15),
      .gem_counter16  (gem_counter16),
      .gem_counter17  (gem_counter17),
      .gem_counter18  (gem_counter18),
      .gem_counter19  (gem_counter19),
      .gem_counter20  (gem_counter20),
      .gem_counter21  (gem_counter21),
      .gem_counter22  (gem_counter22),
      .gem_counter23  (gem_counter23),
      .gem_counter24  (gem_counter24),
      .gem_counter25  (gem_counter25),
      .gem_counter26  (gem_counter26),
      .gem_counter27  (gem_counter27),
      .gem_counter28  (gem_counter28),
      .gem_counter29  (gem_counter29),
      .gem_counter30  (gem_counter30),
      .gem_counter31  (gem_counter31),
      .gem_counter32  (gem_counter32),
      .gem_counter33  (gem_counter33),
      .gem_counter34  (gem_counter34),
      .gem_counter35  (gem_counter35),
      .gem_counter36  (gem_counter36),
      .gem_counter37  (gem_counter37),
      .gem_counter38  (gem_counter38),
      .gem_counter39  (gem_counter39),
      .gem_counter40  (gem_counter40),
      .gem_counter41  (gem_counter41),
      .gem_counter42  (gem_counter42),
      .gem_counter43  (gem_counter43),
      .gem_counter44  (gem_counter44),
      .gem_counter45  (gem_counter45),
      .gem_counter46  (gem_counter46),
      .gem_counter47  (gem_counter47),
      .gem_counter48  (gem_counter48),
      .gem_counter49  (gem_counter49),
      .gem_counter50  (gem_counter50),
      .gem_counter51  (gem_counter51),
      .gem_counter52  (gem_counter52),
      .gem_counter53  (gem_counter53),
      .gem_counter54  (gem_counter54),
      .gem_counter55  (gem_counter55),
      .gem_counter56  (gem_counter56),
      .gem_counter57  (gem_counter57),
      .gem_counter58  (gem_counter58),
      .gem_counter59  (gem_counter59),
      .gem_counter60  (gem_counter60),
      .gem_counter61  (gem_counter61),
      .gem_counter62  (gem_counter62),
      .gem_counter63  (gem_counter63),
      .gem_counter64  (gem_counter64),
      .gem_counter65  (gem_counter65),
      .gem_counter66  (gem_counter66),
      .gem_counter67  (gem_counter67),
      .gem_counter68  (gem_counter68),
      .gem_counter69  (gem_counter69),
      .gem_counter70  (gem_counter70),
      .gem_counter71  (gem_counter71),
      .gem_counter72  (gem_counter72),
      .gem_counter73  (gem_counter73),
      .gem_counter74  (gem_counter74),
      .gem_counter75  (gem_counter75),
      .gem_counter76  (gem_counter76),
      .gem_counter77  (gem_counter77),
      .gem_counter78  (gem_counter78),
      .gem_counter79  (gem_counter79),
      .gem_counter80  (gem_counter80),
      .gem_counter81  (gem_counter81),
      .gem_counter82  (gem_counter82),
      .gem_counter83  (gem_counter83),
      .gem_counter84  (gem_counter84),
      .gem_counter85  (gem_counter85),
      .gem_counter86  (gem_counter86),
      .gem_counter87  (gem_counter87),
      .gem_counter88  (gem_counter88),
      .gem_counter89  (gem_counter89),
      .gem_counter90  (gem_counter90),
      .gem_counter91  (gem_counter91),
      .gem_counter92  (gem_counter92),
      .gem_counter93  (gem_counter93),
      .gem_counter94  (gem_counter94),
      .gem_counter95  (gem_counter95),
      .gem_counter96  (gem_counter96),
      .gem_counter97  (gem_counter97),
      .gem_counter98  (gem_counter98),
      .gem_counter99  (gem_counter99),
      .gem_counter100 (gem_counter100),
      .gem_counter101 (gem_counter101),
      .gem_counter102 (gem_counter102),
      .gem_counter103 (gem_counter103),
      .gem_counter104 (gem_counter104),
      .gem_counter105 (gem_counter105),
      .gem_counter106 (gem_counter106),
      .gem_counter107 (gem_counter107),
      .gem_counter108 (gem_counter108),
      .gem_counter109 (gem_counter109),
      .gem_counter110 (gem_counter110),
      .gem_counter111 (gem_counter111),
      .gem_counter112 (gem_counter112),
      .gem_counter113 (gem_counter113),
      .gem_counter114 (gem_counter114),
      .gem_counter115 (gem_counter115),
      .gem_counter116 (gem_counter116),
      .gem_counter117 (gem_counter117),
      .gem_counter118 (gem_counter118),
      .gem_counter119 (gem_counter119),
      .gem_counter120 (gem_counter120),
      .gem_counter121 (gem_counter121),
      .gem_counter122 (gem_counter122),
      .gem_counter123 (gem_counter123),
      .gem_counter124 (gem_counter124),
      .gem_counter125 (gem_counter125),
      .gem_counter126 (gem_counter126),
      .gem_counter127 (gem_counter127),

      //latched GEM clusters by pretrigger
      .gemA_cluster0_vme  (gemA_cluster_vme[0]),
      .gemA_cluster1_vme  (gemA_cluster_vme[1]),
      .gemA_cluster2_vme  (gemA_cluster_vme[2]),
      .gemA_cluster3_vme  (gemA_cluster_vme[3]),
      .gemA_cluster4_vme  (gemA_cluster_vme[4]),
      .gemA_cluster5_vme  (gemA_cluster_vme[5]),
      .gemA_cluster6_vme  (gemA_cluster_vme[6]),
      .gemA_cluster7_vme  (gemA_cluster_vme[7]),
      .gemA_overflow_vme  (gemA_overflow_vme),
      .gemA_sync_vme      (gemA_sync_vme),
      .gemB_cluster0_vme  (gemB_cluster_vme[0]),
      .gemB_cluster1_vme  (gemB_cluster_vme[1]),
      .gemB_cluster2_vme  (gemB_cluster_vme[2]),
      .gemB_cluster3_vme  (gemB_cluster_vme[3]),
      .gemB_cluster4_vme  (gemB_cluster_vme[4]),
      .gemB_cluster5_vme  (gemB_cluster_vme[5]),
      .gemB_cluster6_vme  (gemB_cluster_vme[6]),
      .gemB_cluster7_vme  (gemB_cluster_vme[7]),
      .gemB_overflow_vme  (gemB_overflow_vme),
      .gemB_sync_vme      (gemB_sync_vme),
      .gem_copad0_vme     (gem_copad_vme[0]),
      .gem_copad1_vme     (gem_copad_vme[1]),
      .gem_copad2_vme     (gem_copad_vme[2]),
      .gem_copad3_vme     (gem_copad_vme[3]),
      .gem_copad4_vme     (gem_copad_vme[4]),
      .gem_copad5_vme     (gem_copad_vme[5]),
      .gem_copad6_vme     (gem_copad_vme[6]),
      .gem_copad7_vme     (gem_copad_vme[7]),
      .gems_sync_vme      (gems_sync_vme),

      // CSC Orientation Ports
      .csc_type        (csc_type[3:0]),   // In  Firmware compile type
      .csc_me1ab       (csc_me1ab),       // In  1=ME1A or ME1B CSC type
      .stagger_hs_csc  (stagger_hs_csc),  // In  1=Staggered CSC, 0=non-staggered
      .reverse_hs_csc  (reverse_hs_csc),  // In  1=Reverse staggered CSC, non-me1
      .reverse_hs_me1a (reverse_hs_me1a), // In  1=reverse me1a hstrips prior to pattern sorting
      .reverse_hs_me1b (reverse_hs_me1b), // In  1=reverse me1b hstrips prior to pattern sorting

      // Pattern Finder Ports
      .clct_blanking      (clct_blanking),          // Out  clct_blanking clears clcts with 0 hits

      // 2nd CLCT separation RAM Ports
      .clct_sep_src       (clct_sep_src),             // Out  CLCT separation source 1=vme, 0=ram
      .clct_sep_vme       (clct_sep_vme[7:0]),        // Out  CLCT separation from vme
      .clct_sep_ram_we    (clct_sep_ram_we),          // Out  CLCT separation RAM write enable
      .clct_sep_ram_adr   (clct_sep_ram_adr[3:0]),    // Out  CLCT separation RAM rw address VME
      .clct_sep_ram_wdata (clct_sep_ram_wdata[15:0]), // Out  CLCT separation RAM write data VME
      .clct_sep_ram_rdata (clct_sep_ram_rdata[15:0]), // In  CLCT separation RAM read  data VME

      // Parity summary
      .perr_reset   (perr_reset),               // Out  Reset parity errors
      .perr_cfeb    (perr_cfeb[MXCFEB-1:0]),    // In  CFEB RAM parity error
      .perr_gem     (perr_gem [MXGEM-1:0]),     // In  GEM RAM parity error
      .perr_rpc     (perr_rpc),                 // In  RPC  RAM parity error
      .perr_mini    (perr_mini),                // In  Mini RAM parity error
      .perr_en      (perr_en),                  // In  Parity error latch enabled
      .perr         (perr),                     // In  Parity error summary
      .perr_cfeb_ff (perr_cfeb_ff[MXCFEB-1:0]), // In  CFEB RAM parity error, latched
      .perr_gem_ff  (perr_gem_ff[MXGEM-1:0]),   // In  GEM RAM parity error,  latched
      .perr_rpc_ff  (perr_rpc_ff),              // In  RPC  RAM parity error, latched
      .perr_mini_ff (perr_mini_ff),             // In  Mini RAM parity error, latched
      .perr_ff      (perr_ff),                  // In  Parity error summary,  latched
      .perr_ram_ff  (perr_ram_ff[64:0]),        // In  Mapped bad parity RAMs, 6x7=42 cfebs + 5 rpcs + 2 miniscope

      // VME debug register latches
      .deb_wr_buf_adr    (deb_wr_buf_adr[MXBADR-1:0]),     // In  Buffer write address at last pretrig
      .deb_buf_push_adr  (deb_buf_push_adr[MXBADR-1:0]),   // In  Queue push address at last push
      .deb_buf_pop_adr   (deb_buf_pop_adr[MXBADR-1:0]),    // In  Queue pop  address at last pop
      .deb_buf_push_data (deb_buf_push_data[MXBDATA-1:0]), // In  Queue push data at last push
      .deb_buf_pop_data  (deb_buf_pop_data[MXBDATA-1:0]),  // In  Queue pop  data at last pop

      // DDR Ports: Posnegs
      .alct_rxd_posneg  (alct_rxd_posneg),  // Out  40MHz  ALCT alct-to-tmb inter-stage clock select 0 or 180 degrees
      .alct_txd_posneg  (alct_txd_posneg),  // Out  40MHz  ALCT tmb-to-alct inter-stage clock select 0 or 180 degrees
      .cfeb0_rxd_posneg (cfeb0_rxd_posneg), // Out  CFEB cfeb-to-tmb inter-stage clock select 0 or 180 degrees
      .cfeb1_rxd_posneg (cfeb1_rxd_posneg), // Out  CFEB cfeb-to-tmb inter-stage clock select 0 or 180 degrees
      .cfeb2_rxd_posneg (cfeb2_rxd_posneg), // Out  CFEB cfeb-to-tmb inter-stage clock select 0 or 180 degrees
      .cfeb3_rxd_posneg (cfeb3_rxd_posneg), // Out  CFEB cfeb-to-tmb inter-stage clock select 0 or 180 degrees
      .cfeb4_rxd_posneg (cfeb4_rxd_posneg), // Out  CFEB cfeb-to-tmb inter-stage clock select 0 or 180 degrees
      .cfeb5_rxd_posneg (cfeb5_rxd_posneg), // Out  CFEB cfeb-to-tmb inter-stage clock select 0 or 180 degrees
      .cfeb6_rxd_posneg (cfeb6_rxd_posneg), // Out  CFEB cfeb-to-tmb inter-stage clock select 0 or 180 degrees
      .gemA_rxd_posneg  (gemA_rxd_posneg),  // Out  GEM  gem-to-tmb inter-stage clock select 0 or 180 degrees
      .gemB_rxd_posneg  (gemB_rxd_posneg),  // Out  GEM  gem-to-tmb inter-stage clock select 0 or 180 degrees

      // Phaser VME control/status ports
      .dps_fire  (dps_fire [MXDPS-1:0]), // Out  Set new phase
      .dps_reset (dps_reset[MXDPS-1:0]), // Out  VME Reset current phase
      .dps_busy  (dps_busy [MXDPS-1:0]), // In  Phase shifter busy
      .dps_lock  (dps_lock [MXDPS-1:0]), // In  PLL lock status

      .dps0_phase  (dps0_phase[7:0]),  // Out  Phase to set, 0-255
      .dps1_phase  (dps1_phase[7:0]),  // Out  Phase to set, 0-255
      .dps2_phase  (dps2_phase[7:0]),  // Out  Phase to set, 0-255
      .dps3_phase  (dps3_phase[7:0]),  // Out  Phase to set, 0-255
      .dps4_phase  (dps4_phase[7:0]),  // Out  Phase to set, 0-255
      .dps5_phase  (dps5_phase[7:0]),  // Out  Phase to set, 0-255
      .dps6_phase  (dps6_phase[7:0]),  // Out  Phase to set, 0-255
      .dps7_phase  (dps7_phase[7:0]),  // Out  Phase to set, 0-255
      .dps8_phase  (dps8_phase[7:0]),  // Out  Phase to set, 0-255
      .dps9_phase  (dps9_phase[7:0]),  // Out  Phase to set, 0-255
      .dps10_phase (dps10_phase[7:0]), // Out  Phase to set, 0-255

      .dps0_sm_vec  (dps0_sm_vec[2:0]),  // In  Phase shifter machine state
      .dps1_sm_vec  (dps1_sm_vec[2:0]),  // In  Phase shifter machine state
      .dps2_sm_vec  (dps2_sm_vec[2:0]),  // In  Phase shifter machine state
      .dps3_sm_vec  (dps3_sm_vec[2:0]),  // In  Phase shifter machine state
      .dps4_sm_vec  (dps4_sm_vec[2:0]),  // In  Phase shifter machine state
      .dps5_sm_vec  (dps5_sm_vec[2:0]),  // In  Phase shifter machine state
      .dps6_sm_vec  (dps6_sm_vec[2:0]),  // In  Phase shifter machine state
      .dps7_sm_vec  (dps7_sm_vec[2:0]),  // In  Phase shifter machine state
      .dps8_sm_vec  (dps8_sm_vec[2:0]),  // In  Phase shifter machine state
      .dps9_sm_vec  (dps9_sm_vec[2:0]),  // In  Phase shifter machine state
      .dps10_sm_vec (dps10_sm_vec[2:0]), // In  Phase shifter machine state

      // Interstage delays
      .cfeb0_rxd_int_delay (cfeb_rxd_int_delay[0][3:0]), // Out  Interstage delay
      .cfeb1_rxd_int_delay (cfeb_rxd_int_delay[1][3:0]), // Out  Interstage delay
      .cfeb2_rxd_int_delay (cfeb_rxd_int_delay[2][3:0]), // Out  Interstage delay
      .cfeb3_rxd_int_delay (cfeb_rxd_int_delay[3][3:0]), // Out  Interstage delay
      .cfeb4_rxd_int_delay (cfeb_rxd_int_delay[4][3:0]), // Out  Interstage delay
      .cfeb5_rxd_int_delay (cfeb_rxd_int_delay[5][3:0]), // Out  Interstage delay
      .cfeb6_rxd_int_delay (cfeb_rxd_int_delay[6][3:0]), // Out  Interstage delay

      .gemA_rxd_int_delay (gemA_rxd_int_delay[3:0]), // Out  Interstage delay
      .gemB_rxd_int_delay (gemB_rxd_int_delay[3:0]), // Out  Interstage delay

      // Sync error source enables
      .sync_err_reset         (sync_err_reset),         // Out  VME sync error reset
      .clct_bx0_sync_err_en   (clct_bx0_sync_err_en),   // Out  TMB  clock pulse count err bxn!=0+offset at ttc_bx0 arrival
      .alct_ecc_rx_err_en     (alct_ecc_rx_err_en),     // Out  ALCT uncorrected ECC error in data ALCT received from TMB
      .alct_ecc_tx_err_en     (alct_ecc_tx_err_en),     // Out  ALCT uncorrected ECC error in data ALCT transmitted to TMB
      .bx0_match_err_en       (bx0_match_err_en),       // Out  ALCT alct_bx0 != clct_bx0
      .clock_lock_lost_err_en (clock_lock_lost_err_en), // Out  40MHz main clock lost lock

      // Sync error action enables
      .sync_err_blanks_mpc_en    (sync_err_blanks_mpc_en),    // Out  Sync error blanks LCTs to MPC
      .sync_err_stops_pretrig_en (sync_err_stops_pretrig_en), // Out  Sync error stops CLCT pre-triggers
      .sync_err_stops_readout_en (sync_err_stops_readout_en), // Out  Sync error stops L1A readouts
      .sync_err_forced           (sync_err_forced),           // Out  Force sync_err=1

      // Sync error types latched for VME readout
      .sync_err               (sync_err),               // In  Sync error OR of enabled types of error
      .alct_ecc_rx_err_ff     (alct_ecc_rx_err_ff),     // In  ALCT uncorrected ECC error in data ALCT received from TMB
      .alct_ecc_tx_err_ff     (alct_ecc_tx_err_ff),     // In  ALCT uncorrected ECC error in data ALCT transmitted to TMB
      .bx0_match_err_ff       (bx0_match_err_ff),       // In  ALCT alct_bx0 != clct_bx0
      .clock_lock_lost_err_ff (clock_lock_lost_err_ff), // In  40MHz main clock lost lock FF

      // Virtex-6 QPLL
      .qpll_lock (qpll_lock), // In  QPLL locked status
      .qpll_err  (qpll_err),  // In  QPLL error status
      .qpll_nrst (qpll_nrst), // Out  Reset QPLL

      // SNAP12 receiver serial interface
      .r12_sclk (r12_sclk), // Out  Serial interface clock, drive high
      .r12_sdat (r12_sdat), // In  Serial interface data
      .r12_fok  (r12_fok),  // In  Serial interface status

      // Virtex-6 GTX receiver
      .gtx_rx_enable        (gtx_rx_enable[MXCFEB-1:0]),        // Out  Enable/Unreset GTX optical input, disables copper SCSI
      .gtx_rx_reset         (gtx_rx_reset[MXCFEB-1:0]),         // Out  Reset this GTX rx & sync module
      .gtx_rx_reset_err_cnt (gtx_rx_reset_err_cnt[MXCFEB-1:0]), // Out  Resets the PRBS test error counters
      .gtx_rx_en_prbs_test  (gtx_rx_en_prbs_test[MXCFEB-1:0]),  // Out  Select random input test data mode
      .gtx_rx_start         (gtx_rx_start[MXCFEB-1:0]),         // In  Set when the DCFEB Start Pattern is present
      .gtx_rx_fc            (gtx_rx_fc[MXCFEB-1:0]),            // In  Flags when Rx sees "FC" code (sent by Tx) for latency measurement
      .gtx_rx_valid         (gtx_rx_valid[MXCFEB-1:0]),         // In  Valid data detected on link
      .gtx_rx_match         (gtx_rx_match[MXCFEB-1:0]),         // In  PRBS test data match detected, for PRBS tests, a VALID = "should have a match" such that !MATCH is an error
      .gtx_rx_rst_done      (gtx_rx_rst_done[MXCFEB-1:0]),      // In  These get set before rxsync cycle begins
      .gtx_rx_sync_done     (gtx_rx_sync_done[MXCFEB-1:0]),     // In  Use these to determine gtx_ready
      .gtx_rx_pol_swap      (gtx_rx_pol_swap[MXCFEB-1:0]),      // In  GTX 5,6 [ie dcfeb 4,5] have swapped rx board routes
      .gtx_rx_err           (gtx_rx_err[MXCFEB-1:0]),           // In  PRBS test detects an error
      .gtx_link_had_err     (link_had_err[MXCFEB-1:0]),         // link stability monitor: error happened at least once
      .gtx_link_good        (link_good[MXCFEB-1:0]),            // link stability monitor: always good, no errors since last resync
      .gtx_link_bad         (link_bad[MXCFEB-1:0]),             // link stability monitor: errors happened over 100 times

      // Virtex-6 GTX error counters
      .gtx_rx_err_count0 (gtx_rx_err_count[0][15:0]), // In  Error count on this fiber channel
      .gtx_rx_err_count1 (gtx_rx_err_count[1][15:0]), // In  Error count on this fiber channel
      .gtx_rx_err_count2 (gtx_rx_err_count[2][15:0]), // In  Error count on this fiber channel
      .gtx_rx_err_count3 (gtx_rx_err_count[3][15:0]), // In  Error count on this fiber channel
      .gtx_rx_err_count4 (gtx_rx_err_count[4][15:0]), // In  Error count on this fiber channel
      .gtx_rx_err_count5 (gtx_rx_err_count[5][15:0]), // In  Error count on this fiber channel
      .gtx_rx_err_count6 (gtx_rx_err_count[6][15:0]), // In  Error count on this fiber channel

      // Virtex-6 GTX error counters: disperr/notintable
      .gtx_rx_notintable_count0 (gtx_rx_notintable_count[0][15:0]), // In  Error count on this fiber channel
      .gtx_rx_notintable_count1 (gtx_rx_notintable_count[1][15:0]), // In  Error count on this fiber channel
      .gtx_rx_notintable_count2 (gtx_rx_notintable_count[2][15:0]), // In  Error count on this fiber channel
      .gtx_rx_notintable_count3 (gtx_rx_notintable_count[3][15:0]), // In  Error count on this fiber channel
      .gtx_rx_notintable_count4 (gtx_rx_notintable_count[4][15:0]), // In  Error count on this fiber channel
      .gtx_rx_notintable_count5 (gtx_rx_notintable_count[5][15:0]), // In  Error count on this fiber channel
      .gtx_rx_notintable_count6 (gtx_rx_notintable_count[6][15:0]), // In  Error count on this fiber channel
      .gtx_rx_disperr_count0 (gtx_rx_disperr_count[0][15:0]), // In  Error count on this fiber channel
      .gtx_rx_disperr_count1 (gtx_rx_disperr_count[1][15:0]), // In  Error count on this fiber channel
      .gtx_rx_disperr_count2 (gtx_rx_disperr_count[2][15:0]), // In  Error count on this fiber channel
      .gtx_rx_disperr_count3 (gtx_rx_disperr_count[3][15:0]), // In  Error count on this fiber channel
      .gtx_rx_disperr_count4 (gtx_rx_disperr_count[4][15:0]), // In  Error count on this fiber channel
      .gtx_rx_disperr_count5 (gtx_rx_disperr_count[5][15:0]), // In  Error count on this fiber channel
      .gtx_rx_disperr_count6 (gtx_rx_disperr_count[6][15:0]), // In  Error count on this fiber channel

      .comp_phaser_a_ready (ready_phaser_a), // Out
      .comp_phaser_b_ready (ready_phaser_b), // Out
      .auto_gtx_reset      (auto_gtx_reset), // Out

      // GEM GTX receiver
      .gem_rx_enable        (gem_rx_enable        [MXGEM-1:0]), // Out  Enable/Unreset GTX optical input, disables copper SCSI
      .gem_rx_reset         (gem_rx_reset         [MXGEM-1:0]), // Out  Reset this GTX rx & sync module
      .gem_rx_reset_err_cnt (gem_rx_reset_err_cnt [MXGEM-1:0]), // Out  Resets the PRBS test error counters
      .gem_rx_en_prbs_test  (gem_rx_en_prbs_test  [MXGEM-1:0]), // Out  Select random input test data mode
      .gem_rx_valid         (gem_rx_valid         [MXGEM-1:0]), // In  Valid data detected on link
      .gem_rx_rst_done      (gem_rx_rst_done      [MXGEM-1:0]), // In  These get set before rxsync cycle begins
      .gem_rx_sync_done     (gem_rx_sync_done     [MXGEM-1:0]), // In  Use these to determine gem_ready
      .gem_rx_pol_swap      (gem_rx_pol_swap      [MXGEM-1:0]), // In  GTX 5,6 [ie dcfeb 4,5] have swapped rx board routes
      .gem_rx_err           (gem_rx_err           [MXGEM-1:0]), // In  PRBS test detects an error
      .gem_link_had_err     (gem_link_had_err     [MXGEM-1:0]), // In  link stability monitor: error happened at least once
      .gem_link_good        (gem_link_good        [MXGEM-1:0]), // In  link stability monitor: always good, no errors since last resync
      .gem_link_bad         (gem_link_bad         [MXGEM-1:0]), // In  link stability monitor: errors happened over 100 times

      // GEM GTX error counters
      .gem_rx_err_count0 (gem_rx_err_count[0][15:0]), // In  Error count on this GEM fiber channel
      .gem_rx_err_count1 (gem_rx_err_count[1][15:0]), // In  Error count on this GEM fiber channel
      .gem_rx_err_count2 (gem_rx_err_count[2][15:0]), // In  Error count on this GEM fiber channel
      .gem_rx_err_count3 (gem_rx_err_count[3][15:0]), // In  Error count on this GEM fiber channel
      // GEM GTX error counters: notintable+disperr
      .gem_rx_notintable_count0 (gem_rx_notintable_count[0][15:0]), // In  Error count on this GEM fiber channel
      .gem_rx_notintable_count1 (gem_rx_notintable_count[1][15:0]), // In  Error count on this GEM fiber channel
      .gem_rx_notintable_count2 (gem_rx_notintable_count[2][15:0]), // In  Error count on this GEM fiber channel
      .gem_rx_notintable_count3 (gem_rx_notintable_count[3][15:0]), // In  Error count on this GEM fiber channel
      .gem_rx_disperr_count0 (gem_rx_disperr_count[0][15:0]), // In  Error count on this GEM fiber channel
      .gem_rx_disperr_count1 (gem_rx_disperr_count[1][15:0]), // In  Error count on this GEM fiber channel
      .gem_rx_disperr_count2 (gem_rx_disperr_count[2][15:0]), // In  Error count on this GEM fiber channel
      .gem_rx_disperr_count3 (gem_rx_disperr_count[3][15:0]), // In  Error count on this GEM fiber channel

      // Sump
      .vme_sump      (vme_sump)              // Out  Unused signals
      );

   //-------------------------------------------------------------------------------------------------------------------
   // Unused Signal Sump
   //-------------------------------------------------------------------------------------------------------------------
   wire    cfeb_rx_sump     =
         (|cfeb0_rx[23:0])  |
         (|cfeb1_rx[23:0])  |
         (|cfeb2_rx[23:0])  |
         (|cfeb3_rx[23:0])  |
         (|cfeb4_rx[23:0]);

  // sump more unused cfeb signals
  wire cfeb_signal_sump = (cfeb0_rxd_posneg) | (cfeb1_rxd_posneg) | (cfeb2_rxd_posneg) | (cfeb3_rxd_posneg) | (cfeb4_rxd_posneg) | (|gtx_rx_reset_err_cnt);

   wire  virtex6_sump      =
            |        alct_startup_msec
            |        alct_wait_dll
            |        alct_startup_done
            |        alct_wait_vme
            |      (|gtx_rx_sump) // | (|set_sw) | (|mez_tp)
            |        reset
            |        clk125
            |        t12_sdat
            |        t12_nfault
            |        t12_rst
            |        f_sclk
            |        f_sdat
            |        f_fok
            |       _gtl_oe
            |       bpi_re
    ;

   //wire lut_sump = (|hs_bnd_1st) | (|hs_xky_1st) | (|hs_bnd_2nd) | (|hs_xky_2nd);
   // Sump
   assign sump =
     ccb_sump
  // | lut_sump
   | copad_sump
   | alct_sump
   | rpc_sump
   | sequencer_sump
   | tmb_sump
   | buf_sump
   | clock_ctrl_sump
   | vme_sump
   | rpc_inj_sel
   | mini_sump
   | (|cfeb_sump)
   | cfeb_signal_sump
   | inj_ram_sump
   | virtex6_sump
   | cfeb_rx_sump
   | (|gem_sump);



   //-------------------------------------------------------------------------------------------
endmodule
  //-------------------------------------------------------------------------------
