`timescale 1ns / 1ps
`include "../otmb_virtex6_fw_version.v"
//------------------------------------------------------------------------------------------------------------------
//  07/28/2015 Port from CFEB.v
//  10/15/2015 Modifications for 56 data bits
//  10/20/2015 Addition of GEM raw hits ram
//-------------------------------------------------------------------------------------------------------------------


//------------------------------------------------------------------------------------------------------------------
// Bus Widths
//------------------------------------------------------------------------------------------------------------------


module gem (
    // Clock
    input          clock,             // 40MHz TMB system clock
    input 	       clk_lock,          // In  40MHz TMB system clock MMCM locked
    input          clock_4x,          // 4*40MHz TMB system clock
    input          clock_gem_rxd,     // 40MHz iob ddr clock
    input          gem_rxd_posneg,    // CFEB cfeb-to-tmb inter-stage clock select 0 or 180 degrees
    input  [3:0]   gem_rxd_int_delay, // Interstage delay, integer bx

    // Global reset
    input          global_reset,      // 1=Reset everything
    input          ttc_resync,        // 1=Reset everything

    // Status
    output          gem_sump,        // Unused signals wot must be connected

    // SNAP12 optical receiver
    input          clock_160,        // 160 MHz from QPLL for GTX reference clock
    input          qpll_lock,        // QPLL was locked
    input          rxp,              // SNAP12+ fiber input for GTX
    input          rxn,              // SNAP12- fiber input for GTX

    // Optical receiver status
    input          gtx_rx_enable,        // Enable/Unreset GTX_RX optical input, disables copper SCSI
    input          gtx_rx_reset,         // Reset GTX receiver rx_sync module
    input          gtx_rx_reset_err_cnt, // Resets the PRBS test error counters
    input          gtx_rx_en_prbs_test,  // Select random input test data mode
  //output         gtx_rx_start,         // Set when the DCFEB Start Pattern is present
  //output         gtx_rx_fc,            // Flags when Rx sees "FC" code (sent by Tx) for latency measurement
    output reg     gtx_rx_nonzero,       // rdk all gtx_tx_data or'ed together
    output         gtx_rx_valid,         // Valid data detected on link output gtx_rx_match;
    // PRBS test data match detected, for PRBS tests, a VALID = "should have a match" such that !MATCH is an error
    output         gtx_rx_rst_done,      // This has to complete before rxsync can start
    output         gtx_rx_sync_done,     // Use these to determine gtx_ready
    output         gtx_rx_pol_swap,      // GTX 5,6 [ie dcfeb 4,5] have swapped rx board routes
    output         gtx_rx_err,           // PRBS test detects an error
    output  [15:0] gtx_rx_err_count,     // Error count on this fiber channel
    output         gtx_rx_sump,          // Unused signals

    output  [7:0]  k_char, // latched copy of the last k-char received

    output link_had_err, // link stability monitor: error happened at least once
    output link_good,    // link stability monitor: always good, no errors since last resync
    output link_bad,     // link stability monitor: errors happened over 100 times

    // Raw Hits FIFO RAM
    input  [9:0]    debug_fifo_radr,       // FIFO RAM read tbin address
    input  [1:0]    debug_fifo_sel,        // FIFO RAM read layer clusters 0-3
    output [13:0]   debug_fifo_rdata,      // FIFO RAM read data
    input           debug_fifo_reset,      // FIFO RAM read data

    // Raw Hits FIFO RAM
    input                  fifo_wen,   // 1=Write enable FIFO RAM
    input  [RAM_ADRB-1:0]  fifo_wadr,  // FIFO RAM write address
    input  [RAM_ADRB-1:0]  fifo_radr,  // FIFO RAM read tbin address
    input  [1:0]           fifo_sel,   // FIFO RAM read cluster address 0-7
    output [RAM_WIDTH-1:0] fifo_rdata, // FIFO RAM read data

    output [MXCLST-1:0] parity_err_gem,

    // GEM Outputs
    output [13:0] gem_cluster0,
    output [13:0] gem_cluster1,
    output [13:0] gem_cluster2,
    output [13:0] gem_cluster3,

    output gem_vpf0,
    output gem_vpf1,
    output gem_vpf2,
    output gem_vpf3
);

// Raw hits RAM parameters
parameter RAM_DEPTH  =  2048; // Storage bx depth
parameter RAM_ADRB   =  11;   // Address width=log2(ram_depth)
parameter RAM_WIDTH  =  14;   // Data width

// Gem Count
parameter IGEM     = 0;
parameter MXCLST   = 4;
parameter CLSTBITS = 14;


//-------------------------------------------------------------------------------------------------------------------
// State machine power-up reset + global reset
//-------------------------------------------------------------------------------------------------------------------

    wire [3:0] pdly   = 1;    // Power-up reset delay
    reg        ready  = 0;

    SRL16E upup (.CLK(clock),.CE(!power_up & clk_lock),.D(1'b1),.A0(pdly[0]),.A1(pdly[1]),.A2(pdly[2]),.A3(pdly[3]),.Q(power_up));

    always @(posedge clock) begin
        ready  <= power_up && !(global_reset || ttc_resync);
    end

    wire reset  = !ready;  // reset

//----------------------------------------------------------------------------------------------------------------------
// Virtex6 GEM optical receivers
//----------------------------------------------------------------------------------------------------------------------

    wire [55:0] gtx_rx_data;
    assign gtx_rx_pol_swap = 0;

    gem_gtx_optical_rx ugem_gtx_optical_rx (
        // Clocks
        .clock       (clock),          // In  40  MHz fabric clock
        .clock_4x    (clock_4x),       // In  4*40  MHz fabric clock
        .clock_iob   (clock_gem_rxd),  // In  40  MHZ iob clock
        .clock_160   (clock_160),      // In  160 MHz from QPLL for GTX reference clock
        .ttc_resync  (ttc_resync),     // use this to clear the link status monitor

        // Muonic
        .clear_sync  (~gtx_rx_enable),          // In  Clear sync stages, use this to put GTX_RX in Reset state
        .posneg      (gem_rxd_posneg),          // In  Select inter-stage clock 0 or 180 degrees
        .delay_is    (gem_rxd_int_delay[3:0]),  // In  Interstage delay

        // SNAP12 optical receiver
      //.clocks_rdy  (qpll_lock),            // In  QPLL & MMCM were locked after power-up... AND is done at top level in l_qpll_lock logic; was AND of real-time lock signals
        .clocks_rdy      (qpll_lock & clk_lock), // In  QPLL & MMCM are locked
        .rxp             (rxp),                  // In  SNAP12+ fiber input for GTX
        .rxn             (rxn),                  // In  SNAP12- fiber input for GTX
        .gtx_rx_pol_swap (gtx_rx_pol_swap),      // In  Inputs 5,6 [ie icfeb 4,5] have swapped rx board routes

        // Optical receiver status
        .gtx_rx_reset         (gtx_rx_reset),           // In   Reset GTX rx & sync module...
        .gtx_rx_reset_err_cnt (gtx_rx_reset_err_cnt),   // In   Resets the PRBS test error counters
        .gtx_rx_en_prbs_test  (gtx_rx_en_prbs_test),    // In   Select random input test data mode
        .gtx_rx_start         (gtx_rx_start),           // Out  Set when the DCFEB Start Pattern is present
        .gtx_rx_fc            (gtx_rx_fc),              // Out  Flags when Rx sees "FC" code (sent by Tx) for latency measurement
        .gtx_rx_valid         (gtx_rx_valid),           // Out  Valid data detected on link
        .gtx_rx_match         (gtx_rx_match),           // Out  PRBS test data match detected, for PRBS tests, a VALID = "should have a match" such that !MATCH is an error
        .gtx_rx_rst_done      (gtx_rx_rst_done),        // Out  These get set before rxsync
        .gtx_rx_sync_done     (gtx_rx_sync_done),       // Out  Use these to determine gtx_ready
        .gtx_rx_err           (gtx_rx_err),             // Out  PRBS test detects an error
        .gtx_rx_err_count     (gtx_rx_err_count[15:0]), // Out  Error count on this fiber channel
        .gtx_rx_data          (gtx_rx_data[55:0]),      // Out  GEM trigger data
        .link_had_err         (link_had_err),
        .link_good            (link_good),
        .link_bad             (link_bad),

        .k_char               (k_char),  // latched copy of the last k-char received

        .gtx_rx_sump          (gtx_rx_sump)             // Unused signals
    );

    assign gtx_sump = gtx_rx_start | gtx_rx_fc | gtx_rx_match | gtx_rx_match | gtx_rx_sump;

//------------------------------------------------------------------------------------------------------------------
// Decompose packed GEM data format
//------------------------------------------------------------------------------------------------------------------

  assign  gem_cluster0 = gtx_rx_data[13: 0];
  assign  gem_cluster1 = gtx_rx_data[27:14];
  assign  gem_cluster2 = gtx_rx_data[41:28];
  assign  gem_cluster3 = gtx_rx_data[55:42];

  wire [13:0] cluster [3:0];
  assign cluster[0] = gem_cluster0;
  assign cluster[1] = gem_cluster1;
  assign cluster[2] = gem_cluster2;
  assign cluster[3] = gem_cluster3;

//----------------------------------------------------------------------------------------------------------------------
// Decompose GEM Hits
//----------------------------------------------------------------------------------------------------------------------

  wire [11:0] adr [3:0];
  wire  [2:0] cnt [3:0];
  wire  [0:0] vpf [3:0];

  genvar iclst;
  generate
  for (iclst=0; iclst<4; iclst=iclst+1) begin: cluster_assignment
    assign adr[iclst] = cluster[iclst][10:0];
    assign cnt[iclst] = cluster[iclst][13:11];
    assign vpf[iclst] = ~(adr[iclst][10:9]==2'b11);
  end
  endgenerate

  always @(posedge clock) begin
      gtx_rx_nonzero    <= (|gtx_rx_data[55:0]);
  end

  wire gem_has_data = (vpf[0] | vpf[1] | vpf[2] | vpf[3]);

//----------------------------------------------------------------------------------------------------------------------
// GEM Raw Hits Dummy RAM
//----------------------------------------------------------------------------------------------------------------------

  // dummy ram controller
  //---------------------
  reg  [9:0] debug_ram_adr   = 10'd0;

  reg [2:0] debug_ram_sm = 2'd0;
  parameter RAM_READY    =  2'd0;
  parameter RAM_WRITING  =  2'd1;
  parameter RAM_READOUT  =  2'd2;

  always @(posedge clock) begin

    // global reset case
    if (reset)
      debug_ram_sm <= RAM_READY;
    else begin

    // gem raw hits ram SM
    case (debug_ram_sm)
      RAM_READY:    debug_ram_sm <= (gem_has_data)            ? RAM_WRITING : debug_ram_sm;
      RAM_WRITING:  debug_ram_sm <= (debug_ram_adr==10'd1023) ? RAM_READOUT : debug_ram_sm;
      RAM_READOUT:  debug_ram_sm <= (debug_fifo_reset)        ? RAM_READY   : debug_ram_sm;
    endcase

    end // not reset
  end // always @(posedge clock)

  // gem ram address
  //----------------------------------------
  always @ (posedge clock) begin
    // gem raw hits ram SM
    case (debug_ram_sm)
      RAM_READY:    debug_ram_adr <= 10'd0;
      RAM_WRITING:  debug_ram_adr <= debug_ram_adr+1'b1;
      RAM_READOUT:  debug_ram_adr <= 10'd1023;
    endcase
  end

  // rename for input to bram
  //--------------------------------------------------
  wire                  debug_fifo_wen;        // 1=Write enable FIFO RAM
  wire [10-1:0]   debug_fifo_wadr;       // FIFO RAM write address

  assign debug_fifo_wen  = debug_ram_sm==RAM_WRITING;
  assign debug_fifo_wadr = debug_ram_adr;

  // Calculate parity for raw hits RAM write data
  //---------------------------------------------
  wire [3:0] debug_parity_wr;
  wire [3:0] debug_parity_rd;

  assign debug_parity_wr[0] = ~(^cluster[0]);
  assign debug_parity_wr[1] = ~(^cluster[1]);
  assign debug_parity_wr[2] = ~(^cluster[2]);
  assign debug_parity_wr[3] = ~(^cluster[3]);

  wire [4:0] debug_db [3:0]; // Virtex6 dob dummy, no sump needed

  // Generate GEM Raw Hits Block Rams
  //---------------------------------
  wire [13:0] debug_fifo_rdata_clst [3:0];

  // depth = 1024
  generate
  for (iclst=0; iclst<4; iclst=iclst+1) begin: debug_ram
  RAMB18E1 #( // Virtex6
      .RAM_MODE            ("TDP"),        // SDP or TDP
      .READ_WIDTH_A        (0),            // 0,1,2,4,9,18,36 Read/write width per port
      .WRITE_WIDTH_A       (18),           // 0,1,2,4,9,18
      .READ_WIDTH_B        (18),           // 0,1,2,4,9,18
      .WRITE_WIDTH_B       (0),            // 0,1,2,4,9,18,36
      .WRITE_MODE_A        ("READ_FIRST"), // WRITE_FIRST, READ_FIRST, or NO_CHANGE
      .WRITE_MODE_B        ("READ_FIRST"),
      .SIM_COLLISION_CHECK ("ALL")         // ALL, WARNING_ONLY, GENERATE_X_ONLY or NONE)
  )
  rawhits_ram              (
      .WEA                 ({2{debug_fifo_wen}}),             // 2-bit  A port write enable input
      .ENARDEN             (1'b1),                            // 1-bit  A port enable/Read enable input
      .RSTRAMARSTRAM       (1'b0),                            // 1-bit  A port set/reset input
      .RSTREGARSTREG       (1'b0),                            // 1-bit  A port register set/reset input
      .REGCEAREGCE         (1'b0),                            // 1-bit  A port register enable/Register enable input
      .CLKARDCLK           (clock),                           // 1-bit  A port clock/Read clock input
      .ADDRARDADDR         ({debug_fifo_wadr[9:0], 4'b1111}), // 14-bit A port address/Read address input (10 bits used [13:4])

      .DIADI               ({2'h0,cluster[iclst]}),         // 16-bit A port data/LSB data input
      .DIPADIP             ({1'b0,debug_parity_wr[iclst]}), // 2-bit  A port parity/LSB parity input
      .DOADO               (),                               // 16-bit A port data/LSB data output
      .DOPADOP             (),                               // 2-bit  A port parity/LSB parity output

      .WEBWE               (),                                                      // 4-bit  B port write enable/Write enable input
      .ENBWREN             (1'b1),                                                  // 1-bit  B port enable/Write enable input
      .REGCEB              (1'b0),                                                  // 1-bit  B port register enable input
      .RSTRAMB             (1'b0),                                                  // 1-bit  B port set/reset input
      .RSTREGB             (1'b0),                                                  // 1-bit  B port register set/reset input
      .CLKBWRCLK           (clock),                                                 // 1-bit  B port clock/Write clock input
      .ADDRBWRADDR         ({debug_fifo_radr[9:0], 4'b1111}),                       // 14-bit B port address/Write address input 10b->[13:4]
      .DIBDI               (),                                                      // 16-bit B port data/MSB data input
      .DIPBDIP             (),                                                      // 2-bit  B port parity/MSB parity input
      .DOBDO               ({debug_db[iclst][1:0],debug_fifo_rdata_clst[iclst]}), // 16-bit B port data/MSB data output
      .DOPBDOP             ({debug_db[iclst][4],  debug_parity_rd[iclst]})        // 2-bit  B port parity/MSB parity output
  );
  end
  endgenerate

  // Compare read parity to write parity
  //------------------------------------
  wire [3:0] debug_parity_expect;

  assign debug_parity_expect[0] = ~(^debug_fifo_rdata_clst[0]);
  assign debug_parity_expect[1] = ~(^debug_fifo_rdata_clst[1]);
  assign debug_parity_expect[2] = ~(^debug_fifo_rdata_clst[2]);
  assign debug_parity_expect[3] = ~(^debug_fifo_rdata_clst[3]);

  wire [3:0] debug_parity_err_gem =  ~(debug_parity_rd ~^ debug_parity_expect);  // ~^ is bitwise equivalence operator

  // fifo data output multiplexer
  //-----------------------------
  assign debug_fifo_rdata = debug_fifo_rdata_clst[debug_fifo_sel];

//-------------------------------------------------------------------------------------------------------------------
// Raw hits RAM storage
//-------------------------------------------------------------------------------------------------------------------

  // Calculate parity for raw hits RAM write data
  wire [MXCLST-1:0] parity_wr;
  wire [MXCLST-1:0] parity_rd;

  assign parity_wr[0] = ~(^cluster[0]);
  assign parity_wr[1] = ~(^cluster[1]);
  assign parity_wr[2] = ~(^cluster[2]);
  assign parity_wr[3] = ~(^cluster[3]);

  // Raw hits RAM writes incoming hits into port A, reads out to DMB via port B
  wire [CLSTBITS-1:0] fifo_rdata_clst [MXCLST-1:0];

  initial $display("gem: generating Virtex6 RAMB18E1_S9_S9 raw.rawhits_ram");
  wire [3:0] db [MXCLST-1:0];                // Virtex6 dob dummy, no sump needed

  // Compare read parity to write parity
  wire [MXCLST-1:0] parity_expect;

  generate
  for (iclst=0; iclst<MXCLST; iclst=iclst+1) begin: raw

      RAMB18E1 #( // Virtex6
        .RAM_MODE            ( "TDP"),        // SDP or TDP
        .READ_WIDTH_A        ( 0),            // 0,1,2,4,9,18,36 Read/write width per port
        .WRITE_WIDTH_A       ( 9),            // 0,1,2,4,9,18
        .READ_WIDTH_B        ( 9),            // 0,1,2,4,9,18
        .WRITE_WIDTH_B       ( 0),            // 0,1,2,4,9,18,36
        .WRITE_MODE_A        ( "READ_FIRST"), // WRITE_FIRST, READ_FIRST, or NO_CHANGE
        .WRITE_MODE_B        ( "READ_FIRST"),
        .SIM_COLLISION_CHECK ( "ALL")         // ALL, WARNING_ONLY, GENERATE_X_ONLY or NONE)
      ) rawhits_ram (
        .WEA           ({2{fifo_wen}}),           // 2-bit  A port write enable input
        .ENARDEN       (1'b1),                    // 1-bit  A port enable/Read enable input
        .RSTRAMARSTRAM (1'b0),                    // 1-bit  A port set/reset input
        .RSTREGARSTREG (1'b0),                    // 1-bit  A port register set/reset input
        .REGCEAREGCE   (1'b0),                    // 1-bit  A port register enable/Register enable input
        .CLKARDCLK     (clock),                   // 1-bit  A port clock/Read clock input
        .ADDRARDADDR   ({fifo_wadr[10:0],3'h7}),  // 14-bit A port address/Read address input 9b->[13:3]
        .DIADI         ({2'h00,cluster[iclst]}),  // 16-bit A port data/LSB data input
        .DIPADIP       ({1'b0,parity_wr[iclst]}), // 2-bit  A port parity/LSB parity input
        .DOADO         (),                        // 16-bit A port data/LSB data output
        .DOPADOP       (),                        // 2-bit  A port parity/LSB parity output

        .WEBWE         (),                                        // 4-bit B port write enable/Write enable input
        .ENBWREN       (1'b1),                                    // 1-bit B port enable/Write enable input
        .REGCEB        (1'b0),                                    // 1-bit B port register enable input
        .RSTRAMB       (1'b0),                                    // 1-bit B port set/reset input
        .RSTREGB       (1'b0),                                    // 1-bit B port register set/reset input
        .CLKBWRCLK     (clock),                                   // 1-bit B port clock/Write clock input
        .ADDRBWRADDR   ({fifo_radr[10:0],3'hF}),                  // 14-bit B port address/Write address input 18b->[13:4]
        .DIBDI         (),                                        // 16-bit B port data/MSB data input
        .DIPBDIP       (),                                        // 2-bit B port parity/MSB parity input
        .DOBDO         ({db[iclst][1:0],fifo_rdata_clst[iclst]}), // 16-bit B port data/MSB data output
        .DOPBDOP       ({db[iclst][2],  parity_rd[iclst]})        // 2-bit B port parity/MSB parity output
      );

    assign parity_expect[iclst] = ~(^ fifo_rdata_clst[iclst]);

  end
  endgenerate

  assign parity_err_gem[3:0] = ~(parity_rd ~^ parity_expect);  // ~^ is bitwise equivalence operator

  // Multiplex Raw Hits FIFO RAM output data
  assign fifo_rdata = fifo_rdata_clst[fifo_sel];

//----------------------------------------------------------------------------------------------------------------------
// outputs
//----------------------------------------------------------------------------------------------------------------------

assign gem_vpf0 = vpf[0];
assign gem_vpf1 = vpf[1];
assign gem_vpf2 = vpf[2];
assign gem_vpf3 = vpf[3];

// Sump
assign gem_sump = gtx_sump | (|debug_parity_err_gem[3:0]);

//-------------------------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------------------------
