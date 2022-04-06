`timescale 1ns / 1ps
//-------------------------------------------------------------------------------------------------------------------
//
// Virtex6: Instantiate 1 DCFEB optical receiver with muonic sync stages
//
//-------------------------------------------------------------------------------------------------------------------
//  09/10/2012  Initial port from x_demux_ddr_cfeb_muonic
//  09/11/2012  Put iob clock back in for muonic timing
//  09/12/2012  Conform sub module names
//  10/08/2012  Remove muonic timing
//  02/21/2013  Put it back
//  03/07/2013  Remove scope channels
//  06/04/2013  Restore n-bx delay, remove muonic logic, variable rx phase is irrelevant for gtx
//-------------------------------------------------------------------------------------------------------------------
  module gtx_optical_rx
  (
// Clocks
  clock,
  clock_4x,
  clock_iob,
  clock_160,
  ttc_resync,    // use this to clear the link status monitor

// Muonic
  clear_sync,
  posneg,
  delay_is,

// SNAP12 optical receiver
  clocks_rdy,
  rxn,
  rxp,
  gtx_rx_pol_swap,

// Optical receiver status
  gtx_rx_reset,
  gtx_rx_reset_err_cnt,   // Resets the PRBS error counters... not needed, DISABLED by JRG
  gtx_rx_en_prbs_test,
  gtx_rx_start,
  gtx_rx_fc,
  gtx_rx_valid,
  gtx_rx_match,
  gtx_rx_rst_done,
  gtx_rx_sync_done,
  gtx_rx_err,
  gtx_rx_err_count, // switch between  link_errcount or prbs_errcount if it's enabled
  gtx_rx_data,
        link_had_err,
        link_good,
  link_bad,

// Sump
  gtx_rx_sump
  );

//-------------------------------------------------------------------------------------------------------------------
// Ports
//-------------------------------------------------------------------------------------------------------------------
// Clocks
  input    clock;      //  40 MHz fabric clock
  input    clock_4x;   //  4*40 MHz fabric clock
  input    clock_iob;  //  40 MHZ iob clock from phaser
  input    clock_160;  // 160 MHz from QPLL for GTX reference clock
  input    ttc_resync; // use this to clear the link status monitor

// Muonic
  input    clear_sync; // Clear sync stages, use this to put GTX in Reset state
  input    posneg;     // Select inter-stage clock 0 or 180 degrees
  input  [3:0]  delay_is; // Interstage delay

// SNAP12 optical receiver
  input      clocks_rdy;    // QPLL & MMCM locked 
  input      rxp;      // SNAP12+ fiber input for GTX
  input      rxn;      // SNAP12- fiber input for GTX
  input      gtx_rx_pol_swap;  // Inputs 5,6 [ie dcfeb 4,5] have swapped rx board routes

// Optical receiver status
  input      gtx_rx_reset;    // Reset GTX
  input      gtx_rx_reset_err_cnt;  // Resets the PRBS test error counters... DISABLED by JRG
  input      gtx_rx_en_prbs_test;  // Select random input test data mode
  output      gtx_rx_start;    // Set when the DCFEB Start Pattern is present
  output      gtx_rx_fc;    // Flags when Rx sees "FC" code (sent by Tx) for latency measurement
  output      gtx_rx_valid;    // Valid data detected on link
  output      gtx_rx_match;    // PRBS test data match detected, for PRBS tests, a VALID = "should have a match" such that !MATCH is an error
  output      gtx_rx_rst_done;  // This has to complete before rxsync can begin
  output      gtx_rx_sync_done; // Use these to determine gtx_ready
  output      gtx_rx_err;    // PRBS test detects an error
  output  [15:0]  gtx_rx_err_count;    // Error count on this fiber channel (link errors or PRBS test errors if it's enabled)
  output  [47:0]  gtx_rx_data;      // DCFEB comparator data
  output      link_had_err;
  output      link_good;
  output      link_bad;
// Sump
  output      gtx_rx_sump;    // Unused signals

//-------------------------------------------------------------------------------------------------------------------
// Instantiate TAMU SNAP12 optical receiver logic
//-------------------------------------------------------------------------------------------------------------------
// GTX resets
  assign gtx_rx_rst_done = rx_rst_done;
  wire rx_sync_done;
  wire gtx_ready = clocks_rdy & rx_sync_done;
  wire rst       = gtx_rx_reset | !clocks_rdy;   // use this to reset GTX_RX_SYNC module... JRG, will soon use for GTX_RX Reset as well

// Received clock time domain
  wire [3:0]  cew;
  wire [3:1]  nonzero_word;
  wire [47:0]  comp_dat;
  wire [47:0]  prompt_dat;

// GTX instance
  gtx_comp_fiber_in ugtx_comp_fiber_in
  (
  .RST         (rst),       // In  use this to reset GTX_RX & SYNC module... 
  .GTX_DISABLE (clear_sync | !clocks_rdy),  // In  use this to put GTX_RX in Reset state
  .CLOCK_4X    (clock_4x),  // In  4 * global TMB clock
  .ttc_resync  (ttc_resync),  // use this to clear the link status monitor
  .CMP_RX_N    (rxn),         // In  SNAP12- fiber input for GTX
  .CMP_RX_P    (rxp),         // In  SNAP12+ fiber input for GTX
  .CMP_RX_REFCLK     (clock_160),       // In  QPLL 160 via GTX Clock
  .RX_POLARITY_SWAP  (gtx_rx_pol_swap), // In  Inputs 5 & 6 have swapped rx board routes
  .CMP_RX_CLK160     (rx_clk160), // Out  Rx recovered clock out.  Use for internal Logic Fabric clock. Needed to sync all 7 CFEBs with Fabric clock
  .STRT_MTCH   (rx_start),        // Out  Gets set when the Start Pattern is present, N/A for me.  To TP for debug only.  --sw8,7
  .VALID       (rx_valid),        // Out  Send this output to TP (only valid after StartMtch has come by)
  .MATCH       (rx_match),        // Out  Send this output to TP  AND use for counting errors. VALID="should match" when true, !MATCH is an error
  .RCV_DATA    (comp_dat[47:0]),  // Out  48 bit comp. data output; stable for 25ns
  .PROMPT_DATA (prompt_dat[47:0]),// Out  48 bit comp. data output, but 6.25ns sooner; only good for 6.25ns though!
  .NONZERO_WORD(nonzero_word[3:1]),  // Out
  .CEW0        (cew[0]),    // Out  Access four phases of 40 MHz cycle, frame separated output from GTX
  .CEW1        (cew[1]),    // Out
  .CEW2        (cew[2]),    // Out
  .CEW3        (cew[3]),    // Out  On CEW3_r (== CEW3 + 1) the RCV_DATA is valid, use to clock into pipeline
  .LTNCY_TRIG  (rx_fc),     // Out  Flags when RX sees "FC" for latency measurement.  Send raw to TP or LED
  .RX_RST_DONE (rx_rst_done),  // Out  set when gtx_reset is complete, then the rxsync cycle can begin
  .RX_SYNC_DONE(rx_sync_done), // Out  set when gtx_rxsync is complete (after gtx_reset)
  .errcount    (link_errcount[7:0]),
  .link_had_err(link_had_err),
  .link_good   (link_good),
  .link_bad    (link_bad),
  .sump     (sump_comp_fiber)    // Out  Unused signals
  );


//-------------------------------------------------------------------------------------------------------------------
// 160 MHz snap rx USR clock time domain
//-------------------------------------------------------------------------------------------------------------------
// Signals to bring into fabric clock domain
  reg  [15:0] prbs_errcount = 0;
  reg         err       = 0;

// Signals in received clock domain
  reg  [47:0]  comp_dat_r    = 0;
  reg     rst_errcount_r  = 0;

        wire [7:0]  link_errcount;
   
  assign snap_wait = !(rx_sync_done & clocks_rdy);  // Allow pattern checks when RX is ready

  always @(posedge rx_clk160 or posedge gtx_rx_reset or posedge snap_wait)
  begin

// Reset case
     if (gtx_rx_reset | snap_wait) begin
        comp_dat_r <= 0;
        rst_errcount_r <= 1;
        prbs_errcount <= 0;
        err <= 0;
     end

// Not Reset case
     else begin            
// JRG        rst_errcount_r <= gtx_rx_reset_err_cnt;
        rst_errcount_r <= 0;

        if (cew[0]) begin      // Store comparator data using received fiber clock
     comp_dat_r <= comp_dat;  // JRG: could we save a BX here by using PROMPT_DAT to load this reg on CEW3?
        end     // JRG:  ...probably not.  Using comp_dat directly is likely the best we can do; skip comp_dat_r?

        if (rst_errcount_r) begin    // Error counter reset
     prbs_errcount <= 0;
     err  <= 0;
        end

        else if (gtx_rx_en_prbs_test & cew[0] & !snap_wait & gtx_ready) begin  // Wait 3000 clocks after Reset
     if (!rx_match & rx_valid ) begin
        err      <= 1'b1;  // Take this to testLEDs for monitoring on scope
        prbs_errcount  <= prbs_errcount + 1'b1;  // This goes to Results Reg for software monitoring
     end
     else
       err     <= 0;
        end

     end    // close not reset case
  end    // close always

// -------------------------------------------------------------------------------------------------------------------
// Fabric clock time domain transition WITHOUT muonic timing
// -------------------------------------------------------------------------------------------------------------------
  reg  [47:0]  gtx_rx_data_raw  = 0;
  reg    gtx_rx_start  = 0;
  reg    gtx_rx_fc  = 0;
  reg    gtx_rx_valid  = 0;
  reg    gtx_rx_match  = 0;
  reg    gtx_rx_sync_done= 0;
  reg    gtx_rx_err  = 0;
  reg  [15:0]  gtx_rx_err_count = 0;
         reg             posneg_ff = 0;
   
  always @(posedge clock) begin
     if (clear_sync) begin  // JRG:  OR gtx_rx_reset??
        gtx_rx_data_raw[47:0] <= 0;
        gtx_rx_start  <= 0;
        gtx_rx_fc    <= 0;
        gtx_rx_valid  <= 0;
        gtx_rx_match  <= 0;
        gtx_rx_sync_done  <= 0;
        gtx_rx_err  <= 0;
        gtx_rx_err_count  <= 0;
     end
     else begin
        gtx_rx_data_raw[47:0] <= comp_dat_r[47:0];  // JRG: for optimal timing use comp_dat, not gtx_rx_data_raw
        gtx_rx_start  <= rx_start;
        gtx_rx_fc    <= rx_fc;
        gtx_rx_valid  <= rx_valid;
        gtx_rx_match  <= rx_match;
        gtx_rx_sync_done  <= rx_sync_done;
        gtx_rx_err  <= err;
        gtx_rx_err_count[15:0] <= (gtx_rx_en_prbs_test) ? prbs_errcount[15:0] : {8'h00,link_errcount[7:0]};
//        if (gtx_rx_en_prbs_test) gtx_rx_err_count[15:0] <= prbs_errcount[15:0];
//        else gtx_rx_err_count[15:0] <= {8'h00,link_errcount[7:0]};
     end // else: !if(clear_sync)
  end // always @ (posedge clock)


// Delay data n-bx to compensate for osu cable length error
  wire [47:0] gtx_rx_data_srl;
  wire [47:0] comp_dat_mux;
  reg  [47:0] comp_dat_180;
  reg  [47:0] comp_dat_phaser;
  reg  [3:0]  idly=0;  // JRG, simple phase delay selector
  reg  [3:0]  dly=0;   // JRG, complex phase delay selector
  reg         dly_is_0=0;
  
  always @(negedge clock) begin // JRG: comp data goes out on FALLING LHC_CLOCK edge (~clock) to save .5BX latency
     idly     <=  delay_is;  // Pointer to clct SRL, integer 1-16 clock delay for comparator data
     dly      <=  delay_is-4'd1;  // Pointer to clct SRL data that accounts for SLR 1bx minimum (0-15 bx)
     dly_is_0 <= (delay_is == 0);  // may use direct input if delay is 0; 1st SRL output has 1bx overhead
     posneg_ff <= posneg;
  end

  wire ignore_link = !link_good | link_bad; // jghere: this is new, to keep bad links from contaminating the triads == hot comps
   
// JRG: add custom muonic CLCT logic. Note that comparator data leaves this module on FALLING LHC_CLOCK edge (~clock)
  always @(posedge clock_iob) begin  // JRG, comment this for test with no recclk or phaser clocks in use
     if (!ignore_link) comp_dat_phaser[47:0] <= comp_dat[47:0];  // JRG: bring data into phase-tuned time domain
     else comp_dat_phaser[47:0] <= 0;  // JRG: bring data into phase-tuned time domain
  end

  always @(posedge clock) begin
     comp_dat_180[47:0] <= comp_dat_phaser[47:0];  // JRG: push data to opposite lhc clock edge (if needed) for SRL
  end
  assign comp_dat_mux[47:0] = (posneg_ff) ? comp_dat_180[47:0] : comp_dat_phaser[47:0];


//  JRG: for muonic timing use comp_dat_r, not gtx_rx_data_raw; also force a minimum single clock delay (no zero bypass)
// old  srl16e_bbl #(48) udcfebdly (.clock(clock),.ce(1'b1),.adr(dly),.d(gtx_rx_data_raw[47:0]),.q(gtx_rx_data_srl[47:0]));
// old  assign gtx_rx_data[47:0] = (dly_is_0) ? gtx_rx_data_raw[47:0] : gtx_rx_data_srl[47:0];
  srl16e_bbl #(48) udcfebdly (.clock(~clock),.ce(1'b1),.adr(idly),.d(comp_dat_mux[47:0]),.q(gtx_rx_data[47:0])); // JRG: comp data leaves module on FALLING LHC_CLOCK edge (~clock)


// Unused muonic signals
  reg muonic_sump=0;
  
  always @(posedge clock_iob) begin
  muonic_sump <= posneg;
  end

//-------------------------------------------------------------------------------------------------------------------
// Sump unused signals
//-------------------------------------------------------------------------------------------------------------------
  assign gtx_rx_sump =
  sump_comp_fiber  &
  (|nonzero_word[3:1]) |
  (|cew[3:1])          |
  muonic_sump
  ;

//------------------------------------------------------------------------------------------------------------------
  endmodule
//------------------------------------------------------------------------------------------------------------------
