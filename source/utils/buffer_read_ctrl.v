`timescale 1ns / 1ps
//`define DEBUG_BUFFER_READ_CTRL 1
//------------------------------------------------------------------------------------------------------------------
//  buffer_read_ctrl
//
//  Controls CFEB and RPC Raw Hits, and Miniscope RAM Readout to Sequencer
//------------------------------------------------------------------------------------------------------------------
//   02/22/2002  Initial
//  02/25/2002  Invert fifo_wen
//  02/26/2002  Pipeline delays for RAM readout
//  02/26/2002  Fixed pretrig read address
//  02/27/2002  Fixed tbin counter
//  02/28/2002  Tuned RAM read data pipelines
//  02/28/2002  Fixed tbin_done calculation
//  02/28/2002  Fixed bank switch delay calculation
//  03/02/2002  Changed fifo_rdata to non-tristate, added mux here
//  03/08/2002  Increased header count bits
//  03/11/2002  FFd fifo_rdata before layer mux, added s3 stage, increased header offset from 7 to 8
//  03/12/2002  Removed debug ports
//  12/11/2002  Multi-buffer write section
//  12/12/2002  Dual ported buffer manager so tmb rejection deletes a buffer entry
//  12/16/2002  Various fixes, added infer mux to buf_sm to stop warning message
//  12/17/2002  Buffer available continuous output for pretrigger enable
//  02/19/2003  Start local read
//  02/21/2003  Changed reset FF to SRL, added prestore counter to prevent new triggers while storing raw hits
//  02/24/2003  Local readout added
//  02/26/2003  Removed FF on ready, its FFd in sequencer
//  02/27/2003  No progress, delayed by OSU and Hauser
//  02/28/2003  Advanced wr_buf_pretrig to switch buffers in minimum time, removed fifo_wadr FF for speed
//  03/01/2003  Reduce busy time count to minimum needed to prestore raw hits before trigger, added turbo bypass
//  03/05/2003  Change hold_fifo so sequencer sees buffers full for the next event, not the currrent event
//  03/10/2003  Tuned header delay, clear prestore counter on wr_buf_reset for faster startup
//  03/11/2003  Fix bufswitch delay > to >= so it works with 7 tbins after pretrig
//  05/12/2004  Add hold_fifo output for RPC
//  05/13/2004  Add first read addr out for RPC
//  05/18/2004  Moved first read addr calc to rpc.v
//  09/11/2006  Mod for xst compiler
//  09/21/2006  More xst mods, add layer_id to output, but sump it in top level
//  09/22/2006  Mod priority encoder to explice else-if structure
//  09/22/2006  Remove count1s function on nbufs because it makes a combinatorial loop, apparent xst bug
//  10/05/2006  Replace for-loops with while-loops for xst
//  08/23/2007  Increase nhbits
//  09/17/2007  Begin bufferless mods
//  09/19/2007  More bufferless mods
//  09/25/2007  Add rpc
//  09/26/2007  Mods for cfeb and rpc to co-exist in same module
//  09/27/2007  Unify name convention, remove header counter
//  09/28/2007  Accelerate cfeb readout 1bx
//  10/01/2007  Conform rpc section to match cfeb section timing
//  10/03/2007  Remove fifo output stage ffs for speed
//  10/04/2007  Subtract read address offset from fifo ram read address to compensate for pre-trigger latency
//  10/11/2007  Delay cfeb adr increment by 2bx to fix early switch issue
//  10/12/2007  Delay rpc  adr increment by 2bx to fix early switch issue, reduce 1st and last word marker delays 1bx
//  10/15/2007  Add 2bx delay to slice_cnt to align bxn/tbin mux switching
//  11/02/2007  Remove buffer status outputs
//  12/12/2007  Move buffer control logic to a separate module
//  12/13/2007  Rename from clct_fifo
//  04/18/2008  Rename resync
//  04/22/2008  Tune read_adr_offset for new pre-trigger state machine
//  04/24/2009  Add recovery states
//  04/30/2009  Add miniscope readout
//  05/08/2009  Add clct pretrigger marker to rpc RAM
//  05/08/2009  Remove miniscope and rpc ram address fixed offsets
//  05/11/2009  Add miniscope 1st word option
//  03/06/2010  Add cfeb blockedbits readout
//  03/07/2010  Tune timing for blocked bits readout to sequencer
//  12/01/2010  Port to ise 12
//  12/01/2010  Remove prefixes from blocked bits slices
//  05/27/2011  Shorten cfeb_slice_cnt_bcb[2:0] to [1:0], as it never counts past 3
//  02/21/2013  Expand to 7 cfebs
//------------------------------------------------------------------------------------------------------------------
  module  buffer_read_ctrl
  (
// CCB Ports
  clock,
  ttc_resync,

// CFEB Raw Hits FIFO RAM Ports
  fifo_radr_cfeb,
  fifo_sel_cfeb,

// RPC Raw Hits FIFO RAM Ports
  fifo_radr_rpc,
  fifo_sel_rpc,

// Miniscpe FIFO RAM Ports
  fifo_radr_mini,

// CFEB Raw Hits Data Ports
  fifo0_rdata_cfeb,
  fifo1_rdata_cfeb,
  fifo2_rdata_cfeb,
  fifo3_rdata_cfeb,
  fifo4_rdata_cfeb,
  fifo5_rdata_cfeb,
  fifo6_rdata_cfeb,

// CFEB blockedbits Data Ports
  cfeb0_blockedbits,
  cfeb1_blockedbits,
  cfeb2_blockedbits,
  cfeb3_blockedbits,
  cfeb4_blockedbits,
  cfeb5_blockedbits,
  cfeb6_blockedbits,

// RPC Raw hits Data Ports
  fifo0_rdata_rpc,
  fifo1_rdata_rpc,

// Miniscope Data Ports
  fifo_rdata_mini,

// CFEB VME Configuration Ports
  fifo_tbins_cfeb,
  fifo_pretrig_cfeb,

// RPC VME Configuration Ports
  fifo_tbins_rpc,
  fifo_pretrig_rpc,

// Minisocpe VME Configuration Ports
  mini_tbins_word,
  fifo_tbins_mini,
  fifo_pretrig_mini,

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

// Mini Sequencer Readout Control
  rd_start_mini,
  rd_abort_mini,
  rd_mini_offset,

// CFEB Sequencer Frame Output
  cfeb_first_frame,
  cfeb_last_frame,
  cfeb_adr,
  cfeb_tbin,
  cfeb_rawhits,
  cfeb_fifo_busy,

// CFEB Blockedbits Frame Output
  bcb_first_frame,
  bcb_last_frame,
  bcb_blkbits,
  bcb_cfeb_adr,
  bcb_fifo_busy,

// RPC Sequencer Frame Output
  rpc_first_frame,
  rpc_last_frame,
  rpc_adr,
  rpc_tbinbxn,
  rpc_rawhits,
  rpc_fifo_busy,

// Mini Sequencer Frame Output
  mini_first_frame,
  mini_last_frame,
  mini_rdata,
  mini_fifo_busy

// Debug
`ifdef DEBUG_BUFFER_READ_CTRL
  ,fifo_wen
  ,read_csm_dsp
  ,read_bcb_dsp
  ,read_rsm_dsp
  ,read_msm_dsp

  ,cfeb_ram_rdata
  ,cfeb_ram_rdata_ff

  ,rpc_ram_rdata
  ,rpc_ram_rdata_ff

  ,cfeb_done
  ,cfeb_tbin_done
  ,cfeb_layer_done

  ,cfeb_cnt
  ,cfeb_tbin_cnt
  ,cfeb_layer_cnt

  ,cfeb_cnt_clr
  ,cfeb_tbin_cnt_clr
  ,cfeb_layer_cnt_clr

  ,cfeb_cnt_bcb
  ,cfeb_blockedbits
  ,cfeb_slice_cnt_bcb
  ,cfeb_sel_bcb

  ,bcb_done
  ,bcb_slice_done
  ,bcb_reset
  ,cfeb_cnt_bcb_clr
  ,cfeb_slice_cnt_bcb_clr
  ,bcb_data_valid
  ,rd_bcb_busy

  ,rpc_done
  ,rpc_tbin_done
  ,rpc_slice_done

  ,rpc_cnt
  ,rpc_tbin_cnt
  ,rpc_slice_cnt

  ,rpc_cnt_clr
  ,rpc_tbin_cnt_clr
  ,rpc_slice_cnt_clr

  ,bxn0_mux
  ,bxn1_mux
  ,rpc_slice_cnt_dly
`endif
  );

  initial $display($time, " buffer_read_ctrl begin");

//------------------------------------------------------------------------------------------------------------------
// Constants
//------------------------------------------------------------------------------------------------------------------
  parameter MXCFEB        = 7;      // Number CFEBs
  parameter MXCFEBB        = 3;      // Number CFEB ID bits
  parameter MXTBIN        = 5;      // Time bin address width
  parameter MXLY          = 6;      // Number Layers in CSC
  parameter MXDS          = 8;      // Number of DiStrips per layer
  parameter MXRPC          = 2;      // Number RPCs
  parameter MXRPCB        = 1;      // Number RPC ID bits
  parameter READ_ADR_OFFSET    = 11'd6;    // Number clocks from first address to pretrigger adr latch, trial 04/22/08
  parameter READ_ADR_OFFSET_RPC  = 11'd0;    // Number clocks from first address to pretrigger
  parameter READ_ADR_OFFSET_MINI  = 11'd0;    // Number clocks from first address to pretrigger

// Raw hits RAM parameters
  parameter RAM_DEPTH        = 2048;      // Storage bx depth
  parameter RAM_ADRB        = 11;      // Address width=log2(ram_depth)
  parameter RAM_WIDTH        = 8;      // Data width

//------------------------------------------------------------------------------------------------------------------
// Ports
//------------------------------------------------------------------------------------------------------------------
// CCB
  input            clock;        // 40MHz TMB main clock
  input            ttc_resync;      // Resync TMB

// CFEB Raw Hits FIFO RAM
  output  [RAM_ADRB-1:0]    fifo_radr_cfeb;    // FIFO RAM read tbin address
  output  [2:0]        fifo_sel_cfeb;    // FIFO RAM read layer address 0-5

// RPC Raw Hits FIFO RAM
  output  [RAM_ADRB-1:0]    fifo_radr_rpc;    // FIFO RAM read tbin address
  output  [0:0]        fifo_sel_rpc;    // FIFO RAM read slice address 0-1

// Miniscpe FIFO RAM
  output  [RAM_ADRB-1:0]    fifo_radr_mini;    // Mini RAM read address

// CFEB Raw Hits Data
  input  [RAM_WIDTH-1:0]    fifo0_rdata_cfeb;  // FIFO RAM read data
  input  [RAM_WIDTH-1:0]    fifo1_rdata_cfeb;  // FIFO RAM read data
  input  [RAM_WIDTH-1:0]    fifo2_rdata_cfeb;  // FIFO RAM read data
  input  [RAM_WIDTH-1:0]    fifo3_rdata_cfeb;  // FIFO RAM read data
  input  [RAM_WIDTH-1:0]    fifo4_rdata_cfeb;  // FIFO RAM read data
  input  [RAM_WIDTH-1:0]    fifo5_rdata_cfeb;  // FIFO RAM read data
  input  [RAM_WIDTH-1:0]    fifo6_rdata_cfeb;  // FIFO RAM read data

// CFEB Blockedbits Data
  input  [MXDS*MXLY-1:0]    cfeb0_blockedbits;  // 1=CFEB rx bit blocked by hcm or went bad, packed
  input  [MXDS*MXLY-1:0]    cfeb1_blockedbits;  // 1=CFEB rx bit blocked by hcm or went bad, packed
  input  [MXDS*MXLY-1:0]    cfeb2_blockedbits;  // 1=CFEB rx bit blocked by hcm or went bad, packed
  input  [MXDS*MXLY-1:0]    cfeb3_blockedbits;  // 1=CFEB rx bit blocked by hcm or went bad, packed
  input  [MXDS*MXLY-1:0]    cfeb4_blockedbits;  // 1=CFEB rx bit blocked by hcm or went bad, packed
  input  [MXDS*MXLY-1:0]    cfeb5_blockedbits;  // 1=CFEB rx bit blocked by hcm or went bad, packed
  input  [MXDS*MXLY-1:0]    cfeb6_blockedbits;  // 1=CFEB rx bit blocked by hcm or went bad, packed

// RPC Raw hits Data
  input  [RAM_WIDTH-1+4:0]  fifo0_rdata_rpc;  // FIFO RAM read data, rpc
  input  [RAM_WIDTH-1+4:0]  fifo1_rdata_rpc;  // FIFO RAM read data, rpc

// Miniscope Data
  input  [RAM_WIDTH*2-1:0]  fifo_rdata_mini;  // FIFO RAM read data, miniscope

// CFEB VME Configuration
  input  [MXTBIN-1:0]    fifo_tbins_cfeb;  // Number CFEB FIFO time bins to read out
  input  [MXTBIN-1:0]    fifo_pretrig_cfeb;  // Number CFEB FIFO time bins before pretrigger

// RPC VME Configuration
  input  [MXTBIN-1:0]    fifo_tbins_rpc;    // Number RPC FIFO time bins to read out
  input  [MXTBIN-1:0]    fifo_pretrig_rpc;  // Number RPC FIFO time bins before pretrigger

// Minisocpe VME Configuration
  input            mini_tbins_word;  // Insert tbins and pretrig tbins in 1st word
  input  [MXTBIN-1:0]    fifo_tbins_mini;  // Number Mini FIFO time bins to read out
  input  [MXTBIN-1:0]    fifo_pretrig_mini;  // Number Mini FIFO time bins before pretrigger

// CFEB Sequencer Readout Control
  input            rd_start_cfeb;    // Initiates a FIFO readout
  input            rd_abort_cfeb;    // Abort FIFO dump
  input  [MXCFEB-1:0]     rd_list_cfeb;    // List of CFEBs to read out
  input  [MXCFEBB-1:0]    rd_ncfebs;      // Number of CFEBs in feb_list (4 or 7 depending on CSC type)
  input  [RAM_ADRB-1:0]    rd_fifo_adr;    // RAM address at pre-trig, must be valid 1bx before rd_start

// CFEB Blockedbits Readout Control
  input            rd_start_bcb;    // Start readout sequence
  input            rd_abort_bcb;    // Cancel readout
  input  [MXCFEB-1:0]     rd_list_bcb;    // List of CFEBs to read out
  input  [MXCFEBB-1:0]    rd_ncfebs_bcb;    // Number of CFEBs in bcb_list (0 to 7)

// RPC Sequencer Readout Control
  input            rd_start_rpc;    // Start readout sequence
  input            rd_abort_rpc;    // Cancel readout
  input  [MXRPC-1:0]     rd_list_rpc;    // List of RPCs to read out
  input  [MXRPCB-1+1:0]    rd_nrpcs;      // Number of RPCs in rpc_list (0 or 1-to-2 depending on CSC type)
  input  [RAM_ADRB-1:0]    rd_rpc_offset;    // RAM address rd_fifo_adr offset for rpc read out

// Mini Sequencer Readout Control
  input            rd_start_mini;    // Start readout sequence
  input            rd_abort_mini;    // Cancel readout
  input  [RAM_ADRB-1:0]    rd_mini_offset;    // RAM address rd_fifo_adr offset for miniscope read out

// CFEB Sequencer Frame Output
  output            cfeb_first_frame;  // First frame valid 2bx after rd_start
  output            cfeb_last_frame;  // Last frame valid 1bx after busy goes down
  output  [MXCFEBB-1:0]    cfeb_adr;      // FIFO dump CFEB ID
  output  [MXTBIN-1:0]    cfeb_tbin;      // FIFO dump Time Bin #
  output  [7:0]        cfeb_rawhits;    // Layer data from FIFO
  output            cfeb_fifo_busy;    // Readout busy sending data to sequencer, goes down 1bx early

// CFEB Blockedbits Frame Output
  output            bcb_first_frame;  // First frame valid 2bx after rd_start
  output            bcb_last_frame;    // Last frame valid 1bx after busy goes down
  output  [11:0]        bcb_blkbits;    // CFEB blocked bits frame data
  output  [MXCFEBB-1:0]    bcb_cfeb_adr;    // CFEB ID  
  output            bcb_fifo_busy;    // Readout busy sending data to sequencer, goes down 1bx early

// RPC Sequencer Frame Output
  output            rpc_first_frame;  // First frame valid 2bx after rd_start
  output            rpc_last_frame;    // Last frame valid 1bx after busy goes down
  output  [MXRPCB-1:0]    rpc_adr;      // FIFO dump RPC ID
  output  [MXTBIN-1:0]    rpc_tbinbxn;    // FIFO dump RPC tbin or bxn for DMB
  output  [7:0]        rpc_rawhits;    // FIFO dump RPC pad hits, 8 of 16 per cycle
  output            rpc_fifo_busy;    // Readout busy sending data to sequencer, goes down 1bx early

// Mini Sequencer Frame Output
  output            mini_first_frame;  // First frame valid 2bx after rd_start
  output            mini_last_frame;  // Last frame valid 1bx after busy goes down
  output  [RAM_WIDTH*2-1:0]  mini_rdata;      // FIFO dump miniscope
  output            mini_fifo_busy;    // Readout busy sending data to sequencer, goes down 1bx early

// Debug
`ifdef DEBUG_BUFFER_READ_CTRL
  input          fifo_wen;
  output  [63:0]      read_csm_dsp;
  output  [63:0]      read_bcb_dsp;
  output  [63:0]       read_rsm_dsp;
  output  [63:0]       read_msm_dsp;

  output  [7:0]      cfeb_ram_rdata;
  output  [7:0]      cfeb_ram_rdata_ff;

  output  [7:0]      rpc_ram_rdata;
  output  [7:0]      rpc_ram_rdata_ff;
  
  output          cfeb_done;
  output          cfeb_tbin_done;
  output          cfeb_layer_done;

  output  [MXCFEBB-1:0]  cfeb_cnt;
  output  [MXTBIN-1:0]  cfeb_tbin_cnt;
  output  [2:0]       cfeb_layer_cnt;

  output          cfeb_cnt_clr;
  output          cfeb_tbin_cnt_clr;
  output          cfeb_layer_cnt_clr;

  output  [MXCFEBB-1:0]  cfeb_cnt_bcb;
  output  [MXDS*MXLY-1:0]  cfeb_blockedbits;
  output  [1:0]      cfeb_slice_cnt_bcb;
  output  [MXCFEBB-1:0]  cfeb_sel_bcb;

  output          bcb_done;
  output          bcb_slice_done;
  output          bcb_reset;
  output          cfeb_cnt_bcb_clr;
  output          cfeb_slice_cnt_bcb_clr;
  output          bcb_data_valid;
  output          rd_bcb_busy;

  output          rpc_done;
  output          rpc_tbin_done;
  output          rpc_slice_done;

  output  [MXRPCB-1:0]  rpc_cnt;
  output  [MXTBIN-1:0]  rpc_tbin_cnt;
  output  [0:0]       rpc_slice_cnt;

  output          rpc_cnt_clr;
  output          rpc_tbin_cnt_clr;
  output          rpc_slice_cnt_clr;

  output [MXTBIN-1:0]    bxn0_mux;
  output [MXTBIN-1:0]    bxn1_mux;
  output  [0:0]      rpc_slice_cnt_dly;
`endif

//------------------------------------------------------------------------------------------------------------------
// CFEB FIFO Read Section:
//------------------------------------------------------------------------------------------------------------------
// Counter done flags
  wire cfeb_done;
  wire cfeb_tbin_done;
  wire cfeb_layer_done;

// CFEB FIFO Read State Machine
  reg  [1:0] read_csm;      // synthesis attribute safe_implementation of read_csm is "yes";
  parameter csm_idle  =  0;  // Waiting for start_read
  parameter csm_read  =  1;  // Raw hits readout in progress

  initial read_csm = csm_idle;
  
  wire csm_reset = (ttc_resync || rd_abort_cfeb);

  always @(posedge clock) begin
  if (csm_reset) 
    read_csm = csm_idle;
  else begin
  case (read_csm)
  csm_idle:
    if (rd_start_cfeb)
    read_csm = csm_read;
  csm_read:
    if (cfeb_done)
    read_csm = csm_idle;
  default
    read_csm = csm_idle;
  endcase
  end
  end

// CFEB read-address counter, sequencer should not issue a read start if rd_ncfebs = 0
  reg [MXCFEBB-1:0] cfeb_cnt=0;

  wire cfeb_cnt_clr = cfeb_done || (read_csm != csm_read);

  always @(posedge clock) begin
  if    (cfeb_cnt_clr  ) cfeb_cnt =0;
  else if (cfeb_tbin_done) cfeb_cnt=cfeb_cnt+1'b1;
  end

  assign cfeb_done = ((cfeb_cnt == (rd_ncfebs-1)) || (rd_ncfebs == 0)) && cfeb_tbin_done;
  
// Time bin read-address counter
  reg  [MXTBIN-1:0] cfeb_tbin_cnt=0;
  wire [MXTBIN-1:0] cfeb_tbin_last;

  wire cfeb_tbin_cnt_clr = cfeb_tbin_done || (read_csm != csm_read) && !rd_start_cfeb; // accelerate startup with rd_start

  always @(posedge clock) begin
  if    (cfeb_tbin_cnt_clr) cfeb_tbin_cnt = 0;
  else if  (cfeb_layer_done  ) cfeb_tbin_cnt = cfeb_tbin_cnt+1'b1;
  end

  assign cfeb_tbin_last = fifo_tbins_cfeb - 1'b1;  // Calculate separately from tbin_done else fails for 0
  assign cfeb_tbin_done = (cfeb_tbin_cnt == cfeb_tbin_last) && cfeb_layer_done;

// Layer data read-address counter
  reg [2:0] cfeb_layer_cnt=0;

  wire cfeb_layer_cnt_clr = cfeb_layer_done || (read_csm != csm_read) && !rd_start_cfeb; // accelerate startup with rd_start

  always @(posedge clock) begin
  if (cfeb_layer_cnt_clr)  cfeb_layer_cnt = 0;
  else          cfeb_layer_cnt = cfeb_layer_cnt+1'b1;
  end

  assign cfeb_layer_done = (cfeb_layer_cnt == 5);

// Readout sequence map selects CFEB order according to FEB hit list, ie 11111 reads out 0,1,2,3,4 and 00001 reads 0 
  reg [2:0] cfebptr [MXCFEB-1:0];
  integer i;
  integer n;

  always @* begin
  i=0;
  n=0;
  while (i<=MXCFEB-1) begin
  cfebptr[i]=0;
  if (rd_list_cfeb[i]) begin
   cfebptr[n]=i[2:0];
   n=n+1;
   end
   i=i+1;
  end
  end

  wire [MXCFEBB-1:0] cfeb_sel = cfebptr[cfeb_cnt];

// Delay cfeb_sel to compensate for RAM access
  reg [MXCFEBB-1:0] cfeb_sel_ff [1:0];
  
  always @(posedge clock) begin
  cfeb_sel_ff[0] <= cfeb_sel;
  cfeb_sel_ff[1] <= cfeb_sel_ff[0];
  end

  wire [MXCFEBB-1:0] cfeb_sel_dly = cfeb_sel_ff[1];

// Calculate first RAM read address, arithmetic is pipelined, but values are really static 
  reg  [RAM_ADRB-1:0] first_read_adr_cfeb=0;

  always @(posedge clock) begin
  first_read_adr_cfeb  <=  rd_fifo_adr-fifo_pretrig_cfeb - READ_ADR_OFFSET;  // compensate for pre-trig latency
  end

// Construct outgoing RAM read-address and layer mux select, RAM access takes 1bx
  reg [RAM_ADRB-1:0]  fifo_radr_cfeb   = 0;
  reg [2:0]      fifo_sel_cfeb_s0 = 0;
  reg [2:0]      fifo_sel_cfeb    = 0;

  always @(posedge clock) begin
  fifo_radr_cfeb    <= cfeb_tbin_cnt + first_read_adr_cfeb;  // FF buffer the add operation beco it has wide fanout
  fifo_sel_cfeb_s0  <= cfeb_layer_cnt;
  fifo_sel_cfeb    <= fifo_sel_cfeb_s0;          // Delay CFEB layer mux select 1bx for RAM access time
  end

// Multiplex incoming RAM data from 7 CFEBs, delays 1bx
  reg  [RAM_WIDTH-1:0] cfeb_rawhits;

  always @* begin
  case (cfeb_sel_dly)
  3'h0:  cfeb_rawhits <= fifo0_rdata_cfeb;
  3'h1:  cfeb_rawhits <= fifo1_rdata_cfeb;
  3'h2:  cfeb_rawhits <= fifo2_rdata_cfeb;
  3'h3:  cfeb_rawhits <= fifo3_rdata_cfeb;
  3'h4:  cfeb_rawhits <= fifo4_rdata_cfeb;
  3'h5:  cfeb_rawhits <= fifo5_rdata_cfeb;
  3'h6:  cfeb_rawhits <= fifo6_rdata_cfeb;
  default  cfeb_rawhits <= fifo0_rdata_cfeb;
  endcase
  end

// Delay cfeb, tbin, and layer markers 2bx to coincide with incoming RAM data
  wire [MXCFEBB-1:0]  cfeb_adr_dly;
  wire [MXTBIN-1:0]  cfeb_tbin_dly;
  wire        cfeb_busy_dly;

  wire [3:0] dly0=0;
  wire [3:0] dly1=1;

  srl16e_bbl #(MXCFEBB)usrlc0 (.clock(clock),.ce(1'b1),.adr(dly1),.d(cfeb_sel     ),.q(cfeb_adr_dly ));
  srl16e_bbl #(MXTBIN) usrlc1 (.clock(clock),.ce(1'b1),.adr(dly1),.d(cfeb_tbin_cnt),.q(cfeb_tbin_dly));

// Accelerate busy out to go high when rd_start arrives, then go low 1bx before end of readout
  wire rd_cfeb_busy   = (read_csm == csm_read);
  wire cfeb_busy_fast = rd_start_cfeb || rd_cfeb_busy || cfeb_busy_dly;

  srl16e_bbl #(1) usrlc2 (.clock(clock),.ce(1'b1),.adr(dly0),.d(rd_cfeb_busy ),.q(cfeb_busy_dly));

// First frame valid 2bx after rd_start, last frame 1bx after busy goes down
  srl16e_bbl #(1) usrlc3 (.clock(clock),.ce(1'b1),.adr(dly1),.d(rd_start_cfeb),.q(cfeb_first_frame));
  srl16e_bbl #(1) usrlc4 (.clock(clock),.ce(1'b1),.adr(dly1),.d(cfeb_done    ),.q(cfeb_last_frame ));

// Assert data markers, alignment FFs, signals valid 2bx after rd_start arrives
  assign cfeb_adr      = cfeb_adr_dly;
  assign cfeb_tbin    = cfeb_tbin_dly;
  assign cfeb_fifo_busy = cfeb_busy_fast; 

//------------------------------------------------------------------------------------------------------------------
// CFEB Blockebits Read Section:
//------------------------------------------------------------------------------------------------------------------
// Counter done flags
  wire bcb_done;
  wire bcb_slice_done;

// CFEB Blockedbits Read State Machine
  reg  [1:0] read_bcb;      // synthesis attribute safe_implementation of read_bcb is "yes";
  parameter bcb_idle  =  0;  // Waiting for start_read
  parameter bcb_read  =  1;  // Raw hits readout in progress

  initial read_bcb = bcb_idle;
  
  wire bcb_reset = (ttc_resync || rd_abort_bcb);

  always @(posedge clock) begin
  if (bcb_reset) 
    read_bcb <= bcb_idle;
  else begin
  case (read_bcb)
  bcb_idle:
    if (rd_start_bcb)
    read_bcb <= bcb_read;
  bcb_read:
    if (bcb_done)
    read_bcb <= bcb_idle;
  default
    read_bcb <= bcb_idle;
  endcase
  end
  end

// CFEB read-address counter, sequencer should not issue a read start if rd_ncfebs_bcb = 0
  reg [MXCFEBB-1:0] cfeb_cnt_bcb=0;

  wire cfeb_cnt_bcb_clr = bcb_done || (read_bcb != bcb_read);

  always @(posedge clock) begin
  if    (cfeb_cnt_bcb_clr) cfeb_cnt_bcb <= 0;
  else if (bcb_slice_done  ) cfeb_cnt_bcb <= cfeb_cnt_bcb+1'b1;
  end

  assign bcb_done = ((cfeb_cnt_bcb == (rd_ncfebs_bcb-1)) || (rd_ncfebs_bcb == 0)) && bcb_slice_done;
  
// Readout slice counter points to slices 0-3 for packed blockedbits data
  parameter cfeb_slice_last_bcb = 4-1;
  reg [1:0] cfeb_slice_cnt_bcb  = 0;

  wire cfeb_slice_cnt_bcb_clr = bcb_slice_done || (read_bcb != bcb_read) && !rd_start_bcb; // accelerate startup with rd_start

  always @(posedge clock) begin
  if (cfeb_slice_cnt_bcb_clr) cfeb_slice_cnt_bcb = 0;
  else                        cfeb_slice_cnt_bcb = cfeb_slice_cnt_bcb+1'b1;
  end

  assign bcb_slice_done = (cfeb_slice_cnt_bcb == cfeb_slice_last_bcb);

// Readout sequence map selects CFEB order according to CFEB enabled list, ie 11111 reads out CFEB0,1,2,3,4 and 00001 reads CFEB0 
  reg  [MXCFEBB-1:0] cfebptr_bcb [MXCFEB-1:0];
  wire [MXCFEBB-1:0] cfeb_sel_bcb;

  integer ip;
  integer np;

  always @* begin
  ip=0;
  np=0;
  while (ip<=MXCFEB-1) begin
  cfebptr_bcb[ip]=0;
  if (rd_list_bcb[ip]) begin
   cfebptr_bcb[np]=ip[2:0];
   np=np+1;
   end
   ip=ip+1;
  end
  end

  assign cfeb_sel_bcb = cfebptr_bcb[cfeb_cnt_bcb];

// Block frame data when not reading out
  wire   bcb_data_valid  = bcb_fifo_busy;

// Multiplex incoming RAM data from 7 CFEBs
  reg  [MXDS*MXLY-1:0] cfeb_blockedbits;

  always @* begin
  if (bcb_data_valid) begin
  case (cfeb_sel_bcb)
  3'h0:  cfeb_blockedbits <= cfeb0_blockedbits;
  3'h1:  cfeb_blockedbits <= cfeb1_blockedbits;
  3'h2:  cfeb_blockedbits <= cfeb2_blockedbits;
  3'h3:  cfeb_blockedbits <= cfeb3_blockedbits;
  3'h4:  cfeb_blockedbits <= cfeb4_blockedbits;
  3'h5:  cfeb_blockedbits <= cfeb5_blockedbits;
  3'h6:  cfeb_blockedbits <= cfeb6_blockedbits;
  default  cfeb_blockedbits <= cfeb0_blockedbits;
  endcase
  end 
  else  cfeb_blockedbits <= 12'hBEF;
  end

// Divide blocked bits into 4 banks for sequential readout
  wire [11:0] cfeb_blockedbits_slice [3:0];

  assign cfeb_blockedbits_slice[0] = cfeb_blockedbits[11: 0];
  assign cfeb_blockedbits_slice[1] = cfeb_blockedbits[23:12];
  assign cfeb_blockedbits_slice[2] = cfeb_blockedbits[35:24];
  assign cfeb_blockedbits_slice[3] = cfeb_blockedbits[47:36];

// Point to slice within 1 CFEB array
  reg [11:0]        bcb_blkbits  = 0;
  reg [MXCFEBB-1:0] bcb_cfeb_adr = 0;

  always @(posedge clock) begin
  if (bcb_reset) begin
  bcb_blkbits  <= 12'hFED;
  bcb_cfeb_adr <= 3'h3;
  end
  else begin
  bcb_blkbits  <= cfeb_blockedbits_slice[cfeb_slice_cnt_bcb];
  bcb_cfeb_adr <= cfeb_cnt_bcb;
  end
  end

// Accelerate busy out to go high when rd_start arrives, then go low 1bx before end of readout
  wire bcb_last_frame;

  wire   rd_bcb_busy   = (read_bcb == bcb_read);
  assign bcb_fifo_busy = rd_start_bcb || rd_bcb_busy;

// First frame valid 1bx after rd_start, last frame 1bx after busy goes down
  srl16e_bbl #(1) usrlbcb0 (.clock(clock),.ce(1'b1),.adr(dly0),.d(rd_start_bcb),.q(bcb_first_frame));
  srl16e_bbl #(1) usrlbcb1 (.clock(clock),.ce(1'b1),.adr(dly0),.d(bcb_done    ),.q(bcb_last_frame ));

//------------------------------------------------------------------------------------------------------------------
// RPC FIFO Read Section:
//------------------------------------------------------------------------------------------------------------------
// Counter done flags
  wire rpc_done;
  wire rpc_tbin_done;
  wire rpc_slice_done;

// RPC FIFO Read State Machine
  reg  [1:0] read_rsm;      // synthesis attribute safe_implementation of read_rsm is "yes";
  parameter rsm_idle  =  0;  // Waiting for start_read
  parameter rsm_read  =  1;  // Raw hits readout in progress

  initial read_rsm = rsm_idle;

  wire rsm_reset = (ttc_resync || rd_abort_rpc);

  always @(posedge clock) begin
  if (rsm_reset) 
    read_rsm = rsm_idle;
  else begin
  case (read_rsm)
  rsm_idle:
    if (rd_start_rpc)
    read_rsm = rsm_read;
  rsm_read:
    if (rpc_done)
    read_rsm = rsm_idle;
  default
    read_rsm = rsm_idle;
  endcase
  end
  end

// RPC read-address counter, sequencer should not issue a read start if rd_nrpcs = 0
  reg [MXRPCB-1:0] rpc_cnt=0;

  wire rpc_cnt_clr = rpc_done || (read_rsm != rsm_read);

  always @(posedge clock) begin
  if    (rpc_cnt_clr  ) rpc_cnt = 0;
  else if (rpc_tbin_done) rpc_cnt = rpc_cnt+1'b1;
  end

  assign rpc_done = ((rpc_cnt == (rd_nrpcs-1)) || (rd_nrpcs == 0)) && rpc_tbin_done;

// Time bin read-address counter
  reg  [MXTBIN-1:0] rpc_tbin_cnt=0;
  wire [MXTBIN-1:0] rpc_tbin_last;

  wire rpc_tbin_cnt_clr = rpc_tbin_done || (read_rsm != rsm_read)&& !rd_start_rpc; // accelerate startup with rd_start

  always @(posedge clock) begin
  if    (rpc_tbin_cnt_clr) rpc_tbin_cnt = 0;
  else if  (rpc_slice_done  ) rpc_tbin_cnt = rpc_tbin_cnt+1'b1;
  end

  assign rpc_tbin_last = fifo_tbins_rpc - 1'b1;  // Calculate separately from tbin_done else fails for 0
  assign rpc_tbin_done = (rpc_tbin_cnt == rpc_tbin_last) && rpc_slice_done;

// Slice data read-address counter
  reg [0:0] rpc_slice_cnt=0;

  wire rpc_slice_cnt_clr = rpc_slice_done || (read_rsm != rsm_read) && !rd_start_rpc; // accelerate startup with rd_start

  always @(posedge clock) begin
  if (rpc_slice_cnt_clr)  rpc_slice_cnt = 0;
  else          rpc_slice_cnt = rpc_slice_cnt+1'b1;
  end

  assign rpc_slice_done = (rpc_slice_cnt == 1);

// Readout sequence map selects RPC order according to RPC hit list, ie 11 reads out RPCs 0,1 and 01 reads 0 
  reg [MXRPCB-1:0] rpcptr [MXRPC-1:0];
  
  integer i_test;
  integer n_test;
  
  integer j;
	initial j=0;
  always @* begin
    i_test=0;
    n_test=0;
    j=j+1;
//    $display($time, " buffer_read_ctrl MXRPC = %d", MXRPC);
    while (i_test<=MXRPC-1) begin
      rpcptr[i_test]=0;
      $display($time, " buffer_read_ctrl j=%d, MXRPC = %d, i_test = %d, rd_list_rpc[i_test] = %d", j, MXRPC, i_test, rd_list_rpc[i_test]);
      if (rd_list_rpc[i_test]) begin
        rpcptr[n_test]=i_test[0];
        n_test=n_test+1;
      end
      i_test=i_test+1;
    end
  end
  
  
//  integer j;
//	initial j=0;
//  always @* begin
//    i=0;
//    n=0;
//    j=j+1;
////    $display($time, " buffer_read_ctrl MXRPC = %d", MXRPC);
//    while (i<=MXRPC-1) begin
//      rpcptr[i]=0;
//      $display($time, " buffer_read_ctrl j=%d, MXRPC = %d, i = %d, rd_list_rpc[i] = %d", j, MXRPC, i, rd_list_rpc[i]);
//      if (rd_list_rpc[i]) begin
//        rpcptr[n]=i[0];
//        n=n+1;
//      end
//      i=i+1;
//    end
//  end

  wire [MXRPCB-1:0] rpc_sel = rpcptr[rpc_cnt];

// Delay rpc_sel to compensate for RAM access
  reg [MXRPCB-1:0] rpc_sel_ff [1:0];
  
  always @(posedge clock) begin
  rpc_sel_ff[0] <= rpc_sel;
  rpc_sel_ff[1] <= rpc_sel_ff[0];
  end

  wire [MXRPCB-1:0] rpc_sel_dly = rpc_sel_ff[1];

// Calculate first RAM read address, arithmetic is pipelined, but values are really static 
  reg  [RAM_ADRB-1:0] first_read_adr_rpc=0;

  always @(posedge clock) begin
  first_read_adr_rpc  <=  rd_fifo_adr-fifo_pretrig_rpc-rd_rpc_offset-READ_ADR_OFFSET_RPC;
  end

// Construct outgoing RAM read-address and slice mux select, RAM access takes 1bx
  reg [RAM_ADRB-1:0]  fifo_radr_rpc   = 0;
  reg [0:0]      fifo_sel_rpc_s0 = 0;
  reg [0:0]      fifo_sel_rpc    = 0;

  always @(posedge clock) begin
  fifo_radr_rpc  <= rpc_tbin_cnt + first_read_adr_rpc;  // FF buffer the add operation beco it has wide fanout
  fifo_sel_rpc_s0  <= rpc_slice_cnt;
  fifo_sel_rpc  <= fifo_sel_rpc_s0;            // Delay RPC slice mux select 1bx for RAM access time
  end

// Delay slice counter 2bx to compensate for RAM access and RPC slice mux
  wire [0:0] rpc_slice_cnt_dly;
  srl16e_bbl #(1) usrlr5 (.clock(clock),.ce(1'b1),.adr(dly1),.d(rpc_slice_cnt),.q(rpc_slice_cnt_dly));

// Multiplex incoming RPC bxn with local tbin counter for alternate slices
  wire [MXTBIN-1:0]  rpc_tbin_dly;
  wire [MXTBIN-1-4:0] pad0s = 0;

  wire [2:0] rpc0_bxn  = fifo0_rdata_rpc[10:8];
  wire [2:0] rpc1_bxn  = fifo1_rdata_rpc[10:8];

  wire       rpc0_flag = fifo0_rdata_rpc[11];
  wire       rpc1_flag = fifo1_rdata_rpc[11];

  wire [MXTBIN-1:0] bxn0_mux  = (rpc_slice_cnt_dly) ? {pad0s,rpc0_flag,rpc0_bxn} : rpc_tbin_dly;
  wire [MXTBIN-1:0] bxn1_mux  = (rpc_slice_cnt_dly) ? {pad0s,rpc1_flag,rpc1_bxn} : rpc_tbin_dly;

// Multiplex incoming RAM data from 2 RPCs, delays 1bx
  reg  [RAM_WIDTH-1:0] rpc_rawhits;
  reg  [MXTBIN-1:0]  rpc_tbinbxn;

  always @* begin
  case (rpc_sel_dly)
  1'h0:  {rpc_tbinbxn,rpc_rawhits} <= {bxn0_mux,fifo0_rdata_rpc[7:0]};
  1'h1:  {rpc_tbinbxn,rpc_rawhits} <= {bxn1_mux,fifo1_rdata_rpc[7:0]};
  endcase
  end

// Delay rpc, tbin, and slice markers 2bx to coincide with incoming RAM data
  wire [MXRPCB-1:0]  rpc_adr_dly;
  wire        rpc_busy_dly;

  srl16e_bbl #(MXRPCB) usrlr0 (.clock(clock),.ce(1'b1),.adr(dly1),.d(rpc_sel     ),.q(rpc_adr_dly ));
  srl16e_bbl #(MXTBIN) usrlr1 (.clock(clock),.ce(1'b1),.adr(dly1),.d(rpc_tbin_cnt),.q(rpc_tbin_dly));

// Accelerate busy out to go high when rd_start arrives, then go low 1bx before end of readout
  wire rd_rpc_busy   = (read_rsm == rsm_read);
  wire rpc_busy_fast = rd_start_rpc || rd_rpc_busy || rpc_busy_dly;

  srl16e_bbl #(1) usrlr2 (.clock(clock),.ce(1'b1),.adr(dly0),.d(rd_rpc_busy ),.q(rpc_busy_dly));

// First frame valid 1bx after rd_start, last frame 1bx after busy goes down
  srl16e_bbl #(1) usrlr3 (.clock(clock),.ce(1'b1),.adr(dly1),.d(rd_start_rpc),.q(rpc_first_frame));
  srl16e_bbl #(1) usrlr4 (.clock(clock),.ce(1'b1),.adr(dly1),.d(rpc_done    ),.q(rpc_last_frame ));

// Assert data markers, alignment FFs, signals valid 2bx after rd_start arrives
  assign rpc_adr     = rpc_adr_dly;
  assign rpc_fifo_busy = rpc_busy_fast;

//------------------------------------------------------------------------------------------------------------------
// Miniscope FIFO Read Section:
//------------------------------------------------------------------------------------------------------------------
// Counter done flags
  wire mini_done;
  wire mini_tbin_done;

// Miniscope FIFO Read State Machine
  reg  [1:0] read_msm;      // synthesis attribute safe_implementation of read_msm is "yes";
  parameter msm_idle  =  0;  // Waiting for start_read
  parameter msm_read  =  1;  // Readout in progress

  initial read_msm = msm_idle;

  wire msm_reset = (ttc_resync || rd_abort_mini);

  always @(posedge clock) begin
  if (msm_reset) 
    read_msm = msm_idle;
  else begin
  case (read_msm)
  msm_idle:
    if (rd_start_mini)
    read_msm = msm_read;
  msm_read:
    if (mini_done)
    read_msm = msm_idle;
  default
    read_msm = msm_idle;
  endcase
  end
  end

// Time bin read-address counter
  reg  [MXTBIN-1:0] mini_tbin_cnt=0;
  wire [MXTBIN-1:0] mini_tbin_last;
  
  wire mini_tbin_cnt_clr = mini_tbin_done || (read_msm != msm_read) && !rd_start_mini; // accelerate startup with rd_start

  always @(posedge clock) begin
  if (mini_tbin_cnt_clr)  mini_tbin_cnt = 0;
  else           mini_tbin_cnt = mini_tbin_cnt+1'b1;
  end

  assign mini_tbin_last = fifo_tbins_mini - 1'b1;  // Calculate separately from tbin_done else fails for 0
  assign mini_tbin_done = (mini_tbin_cnt == mini_tbin_last);
  assign mini_done      = mini_tbin_done;      // miniscope has no ram mux

// Calculate first RAM read address, arithmetic is pipelined, but values are really static 
  reg  [RAM_ADRB-1:0] first_read_adr_mini=0;

  always @(posedge clock) begin
  first_read_adr_mini  <=  rd_fifo_adr-fifo_pretrig_mini-rd_mini_offset-READ_ADR_OFFSET_MINI;
  end

// Construct outgoing RAM read-address, RAM access takes 1bx
  reg [RAM_ADRB-1:0]  fifo_radr_mini=0;

  always @(posedge clock) begin
  fifo_radr_mini  <= mini_tbin_cnt + first_read_adr_mini;  // FF buffer the add operation beco it has wide fanout
  end

// Accelerate busy out to go high when rd_start arrives, then go low 1bx before end of readout
  wire mini_busy_dly;
  wire mini_last_frame;

  wire rd_mini_busy   = (read_msm == msm_read);
  wire mini_fifo_busy = rd_start_mini || rd_mini_busy || mini_busy_dly;

  srl16e_bbl #(1) usrlm0 (.clock(clock),.ce(1'b1),.adr(dly0),.d(rd_mini_busy ),.q(mini_busy_dly));

// First frame valid 1bx after rd_start, last frame 1bx after busy goes down
  srl16e_bbl #(1) usrlm1 (.clock(clock),.ce(1'b1),.adr(dly1),.d(rd_start_mini),.q(mini_first_frame));
  srl16e_bbl #(1) usrlm2 (.clock(clock),.ce(1'b1),.adr(dly1),.d(mini_done    ),.q(mini_last_frame ));

// Multiplex tbins and pretrig tbins with first frame
  wire [RAM_WIDTH*2-1:0]  first_word_mini;
  wire [RAM_WIDTH*2-1:0]  fifo_rdata_mini_mux;

  assign first_word_mini    = {{3'h0,fifo_pretrig_mini[4:0]},{3'h0,fifo_tbins_mini[4:0]}};
  wire   insert_word_mini    =  mini_tbins_word & mini_first_frame;
  assign fifo_rdata_mini_mux  = (insert_word_mini) ? first_word_mini : fifo_rdata_mini;

// Block miniscope data when not reading out
  wire   mini_data_valid = mini_fifo_busy || mini_last_frame;
  assign mini_rdata      = (mini_data_valid) ? fifo_rdata_mini_mux : 16'hBEEF;

//-------------------------------------------------------------------------------------------------------------------
// Debug Simulation state machine display
//-------------------------------------------------------------------------------------------------------------------
`ifdef DEBUG_BUFFER_READ_CTRL
// CFEB FIFO Read State Machine
  reg[63:0] read_csm_dsp;

  always @* begin
  case (read_csm)
  csm_idle:  read_csm_dsp <= "csm_idle";
  csm_read:  read_csm_dsp <= "csm_read";
  default    read_csm_dsp <= "csm_idle";
  endcase
  end

// CFEB Blockedbits Read State Machine
  reg[63:0] read_bcb_dsp;

  always @* begin
  case (read_bcb)
  bcb_idle:  read_bcb_dsp <= "bcb_idle";
  bcb_read:  read_bcb_dsp <= "bcb_read";
  default    read_bcb_dsp <= "bcb_idle";
  endcase
  end

// RPC FIFO Read State Machine
  reg[63:0] read_rsm_dsp;

  always @* begin
  case (read_rsm)
  rsm_idle:  read_rsm_dsp <= "rsm_idle";
  rsm_read:  read_rsm_dsp <= "rsm_read";
  default    read_rsm_dsp <= "rsm_idle";
  endcase
  end

// Miniscope FIFO Read State Machine
  reg[63:0] read_msm_dsp;

  always @* begin
  case (read_msm)
  msm_idle:  read_msm_dsp <= "msm_idle";
  msm_read:  read_msm_dsp <= "msm_read";
  default    read_msm_dsp <= "msm_idle";
  endcase
  end

//-------------------------------------------------------------------------------------------------------------------
// Temporary CFEB RAM to check readout timing
//-------------------------------------------------------------------------------------------------------------------
  wire [7:0] cfeb_ramout [6-1:0];  // 8 bits by 6 layers on 1 cfeb

  genvar ily;
  generate
  for (ily=0; ily<=5; ily=ily+1) begin: ram
  RAMB16_S9_S9 #(
  .WRITE_MODE_A     ("WRITE_FIRST"),  // WRITE_FIRST, READ_FIRST or NO_CHANGE
  .WRITE_MODE_B     ("WRITE_FIRST"),  // WRITE_FIRST, READ_FIRST or NO_CHANGE
  .SIM_COLLISION_CHECK ("WARNING_ONLY")  // "NONE", "WARNING_ONLY", "GENERATE_X_ONLY", "ALL"
  ) cfeb (
  .WEA  (fifo_wen),            // Port A Write Enable Input
  .ENA  (1'b0),              // Port A RAM Enable Input
  .SSRA  (1'b0),              // Port A Synchronous Set/Reset Input
  .CLKA  (clock),            // Port A Clock
  .ADDRA  (11'h7FF),            // Port A 11-bit Address Input
  .DIA  (8'hAB),            // Port A 8-bit Data Input
  .DIPA  (1'b0),              // Port A 1-bit parity Input
  .DOA  (),                // Port A 8-bit Data Output
  .DOPA  (),                // Port A 1-bit Parity Output

  .WEB  (1'b0),              // Port B Write Enable Input
  .ENB  (1'b1),              // Port B RAM Enable Input
  .SSRB  (1'b0),              // Port B Synchronous Set/Reset Input
  .CLKB  (clock),            // Port B Clock
  .ADDRB  (fifo_radr_cfeb[RAM_ADRB-1:0]),  // Port B 11-bit Address Input
  .DIB  ({8{1'b0}}),          // Port B 8-bit Data Input
  .DIPB  (1'b0),              // Port B 1-bit parity Input
  .DOB  (cfeb_ramout[ily][7:0]),    // Port B 8-bit Data Output
  .DOPB  ());              // Port B 1-bit Parity Output
  end
  endgenerate

// Initialize Injector RAMs, INIT values contain preset test pattern, 2 layers x 16 tbins per line
// Key layer 2: 6 hits on key 5 + 5 hits on key 26
// Tbin                                FFFFEEEEDDDDCCCCBBBBAAAA9999888877776666555544443333222211110000;
  defparam ram[0].cfeb.INIT_00 =256'h00000000000000000000000000000000000F0E0D0C0B0A090807060504030201;
  defparam ram[1].cfeb.INIT_00 =256'h00000000000000000000000000000000001F1E1D1C1B1A191817161514131211;
  defparam ram[2].cfeb.INIT_00 =256'h00000000000000000000000000000000002F2E2D2C2B2A292827262524232221;
  defparam ram[3].cfeb.INIT_00 =256'h00000000000000000000000000000000003F3E3D3C3B3A393837363534333231;
  defparam ram[4].cfeb.INIT_00 =256'h00000000000000000000000000000000004F4E4D4C4B4A494847464544434241;
  defparam ram[5].cfeb.INIT_00 =256'h00000000000000000000000000000000005F5E5D5C5B5A595857565554535251;

// Multiplex Injector RAM output data, tri-state output if CFEB is not selected
  reg [7:0] cfeb_ram_rdata;

  always @(cfeb_ramout[0]or fifo_sel_cfeb) begin
  case (fifo_sel_cfeb[2:0])
  3'h0:  cfeb_ram_rdata <= cfeb_ramout[0];
  3'h1:  cfeb_ram_rdata <= cfeb_ramout[1];
  3'h2:  cfeb_ram_rdata <= cfeb_ramout[2];
  3'h3:  cfeb_ram_rdata <= cfeb_ramout[3];
  3'h4:  cfeb_ram_rdata <= cfeb_ramout[4];
  3'h5:  cfeb_ram_rdata <= cfeb_ramout[5];
  default  cfeb_ram_rdata <= cfeb_ramout[0];
  endcase
  end

// Align ramout with tbin and cfeb markers
  reg [7:0] cfeb_ram_rdata_ff;

  always @(posedge clock) begin
  cfeb_ram_rdata_ff  <= cfeb_ram_rdata;
  end

//-------------------------------------------------------------------------------------------------------------------
// Temporary RPC RAM to check readout timing
//-------------------------------------------------------------------------------------------------------------------
  wire [7:0] rpc_ramout [2-1:0];  // 8 bits by 2 slices on 1 rpc

  generate
  for (ily=0; ily<=1; ily=ily+1) begin: ramr
  RAMB16_S9_S9 #(
  .WRITE_MODE_A     ("WRITE_FIRST"),  // WRITE_FIRST, READ_FIRST or NO_CHANGE
  .WRITE_MODE_B     ("WRITE_FIRST"),  // WRITE_FIRST, READ_FIRST or NO_CHANGE
  .SIM_COLLISION_CHECK ("WARNING_ONLY")  // "NONE", "WARNING_ONLY", "GENERATE_X_ONLY", "ALL"
  ) rpc (
  .WEA  (fifo_wen),            // Port A Write Enable Input
  .ENA  (1'b0),              // Port A RAM Enable Input
  .SSRA  (1'b0),              // Port A Synchronous Set/Reset Input
  .CLKA  (clock),            // Port A Clock
  .ADDRA  (11'h7FF),            // Port A 11-bit Address Input
  .DIA  (8'hAB),            // Port A 8-bit Data Input
  .DIPA  (1'b0),              // Port A 1-bit parity Input
  .DOA  (),                // Port A 8-bit Data Output
  .DOPA  (),                // Port A 1-bit Parity Output

  .WEB  (1'b0),              // Port B Write Enable Input
  .ENB  (1'b1),              // Port B RAM Enable Input
  .SSRB  (1'b0),              // Port B Synchronous Set/Reset Input
  .CLKB  (clock),            // Port B Clock
  .ADDRB  (fifo_radr_rpc[RAM_ADRB-1:0]),  // Port B 11-bit Address Input
  .DIB  ({8{1'b0}}),          // Port B 8-bit Data Input
  .DIPB  (1'b0),              // Port B 1-bit parity Input
  .DOB  (rpc_ramout[ily][7:0]),      // Port B 8-bit Data Output
  .DOPB  ());              // Port B 1-bit Parity Output
  end
  endgenerate

// Initialize Injector RAMs, slice 0 rpc0 bxn[2:0],pads[7:0],  slice 1 rpc0 bxn[2:0],pads[15:8]
// Tbin                                FFFFEEEEDDDDCCCCBBBBAAAA9999888877776666555544443333222211110000;
  defparam ramr[0].rpc.INIT_00 =256'h00000000000000000000000000000000000F0E0D0C0B0A090807060504030201;
  defparam ramr[1].rpc.INIT_00 =256'h00000000000000000000000000000000001F1E1D1C1B1A191817161514131211;

// Multiplex Injector RAM output data, tri-state output if CFEB is not selected
  reg [7:0] rpc_ram_rdata;

  always @(rpc_ramout[0]or fifo_sel_rpc) begin
  case (fifo_sel_rpc[0:0])
  3'h0:  rpc_ram_rdata <= rpc_ramout[0];
  3'h1:  rpc_ram_rdata <= rpc_ramout[1];
  endcase
  end

// Align ramout with tbin and rpc markers
  reg [7:0] rpc_ram_rdata_ff;

  always @(posedge clock) begin
  rpc_ram_rdata_ff <= rpc_ram_rdata;
  end
`endif

  initial $display($time, " buffer_read_ctrl end");

//------------------------------------------------------------------------------------------------------------------
  endmodule
//------------------------------------------------------------------------------------------------------------------
