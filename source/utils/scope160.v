`timescale 1ns / 1ps
//`define DEBUG_SCOPE     1    // Uncomment to enable debug io ports
//--------------------------------------------------------------------------------------------------------------------
//
//  Logic Analyzer Module
//
//  Records 160 channels of digital data in 256 time bins
//
//  01/23/2003  Initial
//  01/23/2003  Mod for pre-trigger readout
//  01/24/2003  Add prestore delay to insure valid data before trigger
//  02/06/2003  Add force trigger
//  02/07/2003  Add programmable trigger source
//  03/15/2003  Buffered VME address for speed
//  04/18/2003  Expanded to 32 channels, automatic readout for DMB data stream
//  04/21/2003  Separated sequencer readout from writing, added power-up RAM contents
//  04/23/2003  mux delay mods
//  05/07/2003  Expanded to 64 channels, removed programmable trigger source
//  05/13/2003  Expanded to 96 channels, is there no end in sight?
//  05/16/2003  Mods for automatic readout
//  05/16/2003  Delayed read_done to push last word into sequencer mux
//  05/20/2003  Fix ram mux in auto mode
//  05/10/2004  Copy from scope96
//  05/10/2004  Change nrams to lastram
//  06/17/2004  Add programmable trigger source channel
//  09/12/2006  Mods for xst
//  10/06/2006  Restructure auto_cnt math to prevent adder warning in xst
//  07/20/2007  Change to virtex2 rams, add ascii states
//  07/23/2007  Extend storage to 512
//  09/17/2008  Mod last_ram to infer number of tbins per channel
//  09/18/2008  Tune ram output mux timing, add ram init with data=adr
//  09/19/2008  Remove FF from ram output mux to gain 1bx speed
//  09/23/2008  Re-time ram mux ff
//  09/24/2008  Port from scope128ct, needed more channels hoser
//  09/25/2008  Mod counters to span 160 channels x 512 tbins =5120 frames, needing 13 bit counters
//  09/30/2008  Fix auto mode ram addressing
//  04/24/2009  Add recovery to state machine
//  09/16/2010  Port to ise 12
//  09/29/2010  Add virtex 6 ram option, requires firemware version include
//  10/01/2010  Move ram init file to isim test bench, swap ram ports to conform to virtex6 sdp
//  10/05/2010  Check non-blocking operators in sm, add read_first to dual port RAM
//  11/18/2010  Fix missed read first
//  02/14/2013  Virtex-6 only
//--------------------------------------------------------------------------------------------------------------------
// VME Scope Control Register
//  [0]    RW  scp_runstop      Run/Stop 1=run 0=stop
//  [1]    RW  scp_force_trig    Force a trigger
//  [4:2]  RW  scp_ram_sel[2:0]  RAM bank select in VME mode
//  [5]    RW  scp_auto      Sequencer controls readout
//  [6]    R  scp_waiting      Waiting for trigger
//  [7]    R  scp_done      Trigger done, ready for readout
//  [15:8]  RW  scp_radr[7:0]    Channel data read address
//
// Sequencer Handshake
//      In  scp_ch_trigger    Trigger scope
//      In  scp_start_read    Start readout sequence
//      Out  scp_read_busy    Readout busy sending data to sequencer
//      Out  scp_read_done    Read done
//--------------------------------------------------------------------------------------------------------------------
  module scope160
  (
// Clock
  clock,
  ttc_resync,

// Signal Channels
  trigger_ch,
  ch,

// VME Control
  runstop,
  auto,
  ch_trig_en,
  force_trig,
  ram_sel,
  radr_vme,
  nowrite,
  tbins,

// VME Status
  waiting,
  trig_done,
  rdata,

// Sequencer Auto
  start_read,
  read_busy,
  read_done

// Debug
`ifdef DEBUG_SCOPE
  ,inject
  ,sm_dsp
  ,ram_mux_ff
  ,radr_mux
  ,wadr

  ,auto_read
  ,auto_cnt_en
  ,auto_cnt_done
  ,radr_prestore
  ,auto_radr
  ,auto_tbins

  ,auto_tbin_cnt
  ,auto_bank_sel
  ,next_ch_bank
  ,auto_tbin_clr
  ,doa
  ,ch_ff

  ,predone
  ,trigger
  ,wrdone
  ,web
`endif
  );
//--------------------------------------------------------------------------------------------------------------------
// Generic
//--------------------------------------------------------------------------------------------------------------------
  parameter  MXCH    = 160;  // Number of scope channels
  parameter  MXCHB    = 8;  // Bits to span MXCH
  parameter  MXBANK    = 10;  // Number of 16bit RAM banks = 2x number of 32-bit RAMs
  parameter  NPRESTORE  = 16;  // Prestore Time bins before trigger, must be a power of 2
  parameter  NPRESTOREB  = 4;  // Prestore bits

  initial  $display("scope160: MXCH      =%d",MXCH);
  initial  $display("scope160: MXCHB     =%d",MXCHB);
  initial  $display("scope160: MXBANK    =%d",MXBANK);
  initial  $display("scope160: NPRESTORE =%d",NPRESTORE);
  initial  $display("scope160: NPRESTOREB=%d",NPRESTOREB);

//--------------------------------------------------------------------------------------------------------------------
// Ports
//--------------------------------------------------------------------------------------------------------------------
// Clock
  input        clock;      // 40MHz system clock
  input        ttc_resync;    // Reset scope

// Signal Channels
  input  [MXCHB-1:0]  trigger_ch;    // Channel to trigger on
  input  [MXCH-1:0]  ch;        // Channel inputs

// VME Control
  input        runstop;    // 1=run 0=stop
  input        auto;      // Sequencer readout mode 
  input        ch_trig_en;    // Enable channel triggers
  input        force_trig;    // Force a trigger
  input  [3:0]    ram_sel;    // RAM bank select in VME mode
  input  [8:0]    radr_vme;    // Channel data read address
  input        nowrite;    // No-write mode preserves initial RAM contents for simulator
  input  [2:0]    tbins;      // Time bins per channel code, actual tbins/ch = (tbins+1)*64

// VME Status
  output        waiting;    // Waiting for trigger
  output        trig_done;    // Trigger done, ready for readout 
  output  [15:0]    rdata;      // Recorded channel data

// Sequencer Auto
  input        start_read;    // Start readout sequence
  output        read_busy;    // Readout busy sending data to sequencer
  output        read_done;    // Read done

`ifdef DEBUG_SCOPE
  input        inject;      // Fire debug pattern injector
  output  [71:0]    sm_dsp;      // Scope state machine ASCII display
  output  [3:0]    ram_mux_ff;
  output  [8:0]    radr_mux;
  output  [8:0]    wadr;

  output        auto_read;
  output        auto_cnt_en;
  output        auto_cnt_done;
  output  [8:0]    radr_prestore;
  output  [8:0]    auto_radr;
  output  [8:0]    auto_tbins;
  
  output  [8:0]    auto_tbin_cnt;
  output  [3:0]    auto_bank_sel;
  output        next_ch_bank;
  output        auto_tbin_clr;

  output  [MXCH-1:0]  doa;
  output  [MXCH-1:0]  ch_ff;

  output        predone;
  output        trigger;
  output        wrdone;
  output        web;
`endif

//--------------------------------------------------------------------------------------------------------------------
// State machine declarations
//--------------------------------------------------------------------------------------------------------------------
  reg [4:0] sm;      // synthesis attribute safe_implementation of sm is "yes";
  parameter idle    =  5'b00001;
  parameter prestore  =  5'b00010;
  parameter wait_trig  =  5'b00100;
  parameter store    =  5'b01000;
  parameter readout  =  5'b10000;

//--------------------------------------------------------------------------------------------------------------------
//  Power up reset
//--------------------------------------------------------------------------------------------------------------------
  wire [3:0] dly = 0;

  SRL16E upup (.CLK(clock),.CE(~power_up),.D(1'b1),.A0(dly[0]),.A1(dly[1]),.A2(dly[2]),.A3(dly[3]),.Q(power_up));

  wire reset = ttc_resync || !power_up;

//--------------------------------------------------------------------------------------------------------------------
// Register channel inputs, intermediate stage is for trigger mux, last stage is for RAMs
//--------------------------------------------------------------------------------------------------------------------
  reg  [MXCH-1:0]  ch_ff       = 0;
  reg  [MXCH-1:0]  trig_src_ff = 0;

  always @(posedge clock) begin
  if (reset) begin
  trig_src_ff  <= {MXCH{1'b1}};  // Init values to prevent always-0 warnings 
  ch_ff    <= {MXCH{1'b1}};
  end
  `ifdef DEBUG_SCOPE        // Enable injector in debug mode
  else if(inject) begin
  trig_src_ff  <= {MXCH{1'b1}};
  ch_ff    <= {MXCH{1'b0}};
  end
  `endif
  else begin
  trig_src_ff  <= ch;        // FF buffer latches incoming signals
  ch_ff    <= trig_src_ff;
  end
  end

// Trigger channel mux
  reg [MXCHB-1:0] trigger_ch_ff=0;

  always @(posedge clock) begin
  trigger_ch_ff <= trigger_ch;
  end

  wire ch_trigger = trig_src_ff[trigger_ch_ff];

// Trigger on channel or VME forced trigger
  wire force_trig_os;

  x_oneshot uscpos (.d(force_trig),.clock(clock),.q(force_trig_os));

  wire trigger = (ch_trigger & ch_trig_en & (sm == wait_trig) ) | force_trig_os; 

//--------------------------------------------------------------------------------------------------------------------
// Storage RAM address counter runs continuosly after run start
//--------------------------------------------------------------------------------------------------------------------
  reg [8:0] wadr=0;
  wire wadr_cnt_en = (sm == prestore) ||(sm == wait_trig) || (sm == store);

  always @(posedge clock) begin
  if     (sm == idle ) wadr <= 0;      // Sync reset
  else if  (wadr_cnt_en) wadr <= wadr + 1'b1;  // Sync count
  end

  wire predone = wadr[NPRESTOREB] && (sm == prestore);

// On trigger, latch current write address
  reg  [8:0] trig_adr=0;

  always @(posedge clock) begin
  if (trigger) trig_adr <= wadr;
  end

// On trigger, count number of tbins to store
  reg [8:0] wr_cnt=0;

  always @(posedge clock) begin
  if    (sm == idle ) wr_cnt <= 0;
  else if  (sm == store) wr_cnt <= wr_cnt+1'b1;
  end

  wire wrdone = (wr_cnt == 511-NPRESTORE);
  wire web  = ((sm == prestore) || (sm == store) || (sm == wait_trig)) && !nowrite && power_up;

//--------------------------------------------------------------------------------------------------------------------
// Sequencer auto mode
//--------------------------------------------------------------------------------------------------------------------
// Sequencer readout FF
  reg  auto_read=0;
  wire auto_done;

  always @(posedge clock) begin
  if    (!auto        )  auto_read <= 0;
  else if  (start_read && auto )  auto_read <= 1;
  else if  (auto_done      )  auto_read <= 0;
  end

  assign read_busy = auto_read;

// Calculate number of RAM words to read out in auto mode
  reg  [8:0] auto_tbins=0;          // Number of tbins decoded from vme register
  wire [8:0] user_tbins = ((tbins+1)*64)-1;

  always @(posedge clock) begin
  if (!auto) auto_tbins <= 0;          // Suppress warnings for constant FFs
  else       auto_tbins <= user_tbins;    // tbins=7 reads 512 tbins, ending in tbin 511
  end

// Point to 1st RAM address
  reg  [8:0] radr_offset=0;
  wire [8:0] prestore_offset = (NPRESTORE-1);

  always @(posedge clock) begin
  radr_offset <= trig_adr-prestore_offset;
  end

// Increment channel block pointer after reading tbins
  reg  [8:0] auto_tbin_cnt=0;
  reg  [3:0] auto_bank_sel=0;
  wire [8:0] auto_radr;

  wire auto_cnt_en;
  wire auto_cnt_done;
  wire next_ch_bank;
  wire auto_tbin_clr;
  wire auto_bank_clr;

  assign auto_cnt_en   = auto_read || (start_read && auto) && ((sm == readout) || (sm == store));
  assign auto_cnt_done = (auto_tbin_cnt == auto_tbins) && (auto_bank_sel==MXBANK-1) && next_ch_bank;
  assign next_ch_bank  = (auto_tbin_cnt==auto_tbins);
  assign auto_tbin_clr = next_ch_bank || !auto_cnt_en;
  assign auto_bank_clr = !auto_cnt_en || auto_cnt_done;

  always @(posedge clock) begin
  if (auto_tbin_clr) auto_tbin_cnt <= 0;
  else         auto_tbin_cnt <= auto_tbin_cnt+1'b1;
  end

  always @(posedge clock) begin
  if      (auto_bank_clr) auto_bank_sel <= 0;
  else if (next_ch_bank ) auto_bank_sel <= auto_bank_sel+1'b1;
  end

  assign auto_radr = (nowrite) ? auto_tbin_cnt : auto_tbin_cnt+radr_offset;

// On read, subtract trigger address
  reg  [8:0]  radr_prestore=0;
  wire [8:0]  radr_mux;
  wire [3:0]  ram_mux;
  
  always @(posedge clock) begin
  radr_prestore[8:0] <= radr_vme-prestore_offset+trig_adr;
  end

  assign radr_mux[8:0]= (auto) ? auto_radr[8:0]     : radr_prestore[8:0];
  assign ram_mux[3:0]  = (auto) ? auto_bank_sel[3:0] : ram_sel[3:0];

// Delay RAM chip select 1 clock to be in time with output data
  reg [3:0] ram_mux_ff=0;

  always @(posedge clock) begin
  ram_mux_ff <= ram_mux;
  end

// Status signals
  reg waiting   = 0;
  reg trig_done = 0;

  always @(posedge clock) begin
  waiting    <= (sm == prestore) || (sm == wait_trig) ||  (sm == store);
  trig_done <= (sm == readout );
  end

// Report done to sequencer after sending all data, or if never triggered, or if not auto mode
  reg  read_done=0;

  assign auto_done = auto_cnt_done || !auto || !((sm == store) || (sm == readout));
  wire   auto_stop = auto && auto_cnt_done;

  always @(posedge clock) begin
  read_done <= auto_done;
  end

//--------------------------------------------------------------------------------------------------------------------
// Scope State Machine
//--------------------------------------------------------------------------------------------------------------------
  always @(posedge clock) begin
  if    (reset)    sm <= idle;
  else if (!runstop)  sm <= idle;
 
  else begin
   case (sm)

  idle:
   if (runstop)  sm <= prestore;

  prestore:
   if (predone)  sm <= wait_trig;

  wait_trig:
   if (trigger)  sm <= store;
  
  store:
   if (wrdone)  sm <= readout;

  readout:
   if (auto_stop)  sm <= idle;

  default      sm <= idle;
  endcase
  end
  end

//--------------------------------------------------------------------------------------------------------------------
// Scope RAM: VME reads port A, scope writes port B
//--------------------------------------------------------------------------------------------------------------------
  wire [MXCH-1:0] doa;
  genvar i;

  initial $display("scope160: generating Virtex6 RAMB18E1");
  generate
  for (i=0; i<MXCH; i=i+32) begin: ram

  RAMB18E1 #(                  // Virtex6
  .RAM_MODE      ("SDP"),        // SDP or TDP
   .READ_WIDTH_A    (36),          // 0,1,2,4,9,18,36 Read/write width per port
  .READ_WIDTH_B    (0),          // 0,1,2,4,9,18
  .WRITE_WIDTH_A    (0),          // 0,1,2,4,9,18
  .WRITE_WIDTH_B    (36),          // 0,1,2,4,9,18,36
  .WRITE_MODE_A    ("READ_FIRST"),      // Must be same for both ports in SDP mode: WRITE_FIRST, READ_FIRST, or NO_CHANGE)
  .WRITE_MODE_B    ("READ_FIRST"),
  .SIM_COLLISION_CHECK("ALL")          // Colision check: Values (ALL, WARNING_ONLY, GENERATE_X_ONLY or NONE)
  ) uram (
  .WEA        (),            //  2-bit A port write enable input
  .ENARDEN      (1'b1),          //  1-bit A port enable/Read enable input
  .RSTRAMARSTRAM    (1'b0),          //  1-bit A port set/reset input
  .RSTREGARSTREG    (1'b0),          //  1-bit A port register set/reset input
  .REGCEAREGCE    (1'b0),          //  1-bit A port register enable/Register enable input
  .CLKARDCLK      (clock),        //  1-bit A port clock/Read clock input
  .ADDRARDADDR    ({radr_mux[8:0],5'h1F}),// 14-bit A port address/Read address input
  .DIADI        (ch_ff[i+15:i]),    // 16-bit A port data/LSB data input
  .DIPADIP      (),            //  2-bit A port parity/LSB parity input
  .DOADO        (doa[i+15:i]),      // 16-bit A port data/LSB data output
  .DOPADOP      (),            //  2-bit A port parity/LSB parity output

  .WEBWE        ({4{web}}),        //  4-bit B port write enable/Write enable input
  .ENBWREN      (1'b1),          //  1-bit B port enable/Write enable input
  .REGCEB        (1'b0),          //  1-bit B port register enable input
  .RSTRAMB      (1'b0),          //  1-bit B port set/reset input
  .RSTREGB      (1'b0),          //  1-bit B port register set/reset input
  .CLKBWRCLK      (clock),        //  1-bit B port clock/Write clock input
  .ADDRBWRADDR    ({wadr[8:0],5'h1F}),  // 14-bit B port address/Write address input
  .DIBDI        (ch_ff[i+31:i+16]),    // 16-bit B port data/MSB data input
  .DIPBDIP      (),            //  2-bit B port parity/MSB parity input
  .DOBDO        (doa[i+31:i+16]),    // 16-bit B port data/MSB data output
  .DOPBDOP      ()            //  2-bit B port parity/MSB parity output
  );
  end
  endgenerate

// Multiplex RAM output data
  reg [15:0] rdata;

  always @* begin
  case (ram_mux_ff[3:0])
  4'h0:  rdata[15:0] <= doa[15:0];
  4'h1:  rdata[15:0] <= doa[31:16];
  4'h2:  rdata[15:0] <= doa[47:32];
  4'h3:  rdata[15:0] <= doa[63:48];
  4'h4:  rdata[15:0] <= doa[79:64];
  4'h5:  rdata[15:0] <= doa[95:80];
  4'h6:  rdata[15:0] <= doa[111:96];
  4'h7:  rdata[15:0] <= doa[127:112];
  4'h8:  rdata[15:0] <= doa[143:128];
  4'h9:  rdata[15:0] <= doa[159:144];
  default:rdata[15:0] <= doa[15:0];
  endcase
  end

//--------------------------------------------------------------------------------------------------------------------
// Debug
//--------------------------------------------------------------------------------------------------------------------
`ifdef DEBUG_SCOPE
// Injector state machine ASCII display
  reg[71:0] sm_dsp;
  always @* begin
  case (sm)
  idle:    sm_dsp <= "idle     ";
  prestore:  sm_dsp <= "prestore ";
  wait_trig:  sm_dsp <= "wait_trig";
  store:    sm_dsp <= "store    ";
  readout:  sm_dsp <= "readout  ";
  default    sm_dsp <= "idle     ";
  endcase
  end
`endif

//--------------------------------------------------------------------------------------------------------------------
  endmodule
//--------------------------------------------------------------------------------------------------------------------
