`timescale 1ns / 1ps
`include "../otmb_virtex6_fw_version.v"
//------------------------------------------------------------------------------------------------------------------
//  07/28/2015 Port from CFEB.v
//  10/15/2015 Modifications for 56 data bits
//  10/20/2015 Addition of GEM raw hits ram
//  12/09/2016 Addition of GEM Injector RAMS
//-------------------------------------------------------------------------------------------------------------------


//------------------------------------------------------------------------------------------------------------------
// Bus Widths
//------------------------------------------------------------------------------------------------------------------


module gem (
    // Clock
    input          clock,             // 40MHz TMB system clock
    input          clk_lock,          // In  40MHz TMB system clock MMCM locked
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
    output         gtx_rx_valid,         // Valid data detected on link output gtx_rx_match;
    // PRBS test data match detected, for PRBS tests, a VALID = "should have a match" such that !MATCH is an error
    output         gtx_rx_rst_done,      // This has to complete before rxsync can start
    output         gtx_rx_sync_done,     // Use these to determine gtx_ready
    output         gtx_rx_pol_swap,      // GTX 5,6 [ie dcfeb 4,5] have swapped rx board routes
    output         gtx_rx_err,           // PRBS test detects an error
    output  [15:0] gtx_rx_err_count,     // Error count on this fiber channel

    output  [7:0]  k_char, // latched copy of the last k-char received

    output link_had_err, // link stability monitor: error happened at least once
    output link_good,    // link stability monitor: always good, no errors since last resync
    output link_bad,     // link stability monitor: errors happened over 100 times

    // Debug Raw Hits FIFO RAM
    input  [9:0]    debug_fifo_radr,       // FIFO RAM read tbin address
    input  [1:0]    debug_fifo_sel,        // FIFO RAM read layer clusters 0-3
    output [13:0]   debug_fifo_rdata,      // FIFO RAM read data
    input           debug_fifo_reset,      // FIFO RAM read data

    // GEM Injector RAM
    input  [9:0]    inj_rwadr,      // Injector RAM read tbin address
    input  [1:0]    inj_sel,        // Injector RAM read layer clusters 0-3
    input  [1:0]    inj_igem,       // Injector RAM GEM ID 0-3
    input  [15:0]   inj_wdata,      // Injector RAM read data
    input           inj_wen,        // Injector RAM read data
    input           inj_go_gem,     // Start Injection (from Sequencer)
    input  [11:0]   inj_last_tbin , //

    // Raw Hits FIFO RAM
    input                  fifo_wen,   // 1=Write enable FIFO RAM
    input  [RAM_ADRB-1:0]  fifo_wadr,  // FIFO RAM write address
    input  [RAM_ADRB-1:0]  fifo_radr,  // FIFO RAM read tbin address
    input  [1:0]           fifo_sel,   // FIFO RAM read cluster address 0-7
    output [RAM_WIDTH-1:0] fifo_rdata, // FIFO RAM read data

    output [MXCLST-1:0]    parity_err_gem,

    output overflow,
    output bc0marker, // BC0 marker, 1C
    output resyncmarker,// resync marker, 3C

    // GEM Outputs
    //output [MXPAD-1:0] gemhit_roll0;
    //output [MXPAD-1:0] gemhit_roll1;
    //output [MXPAD-1:0] gemhit_roll2;
    //output [MXPAD-1:0] gemhit_roll3;
    //output [MXPAD-1:0] gemhit_roll4;
    //output [MXPAD-1:0] gemhit_roll5;
    //output [MXPAD-1:0] gemhit_roll6;
    //output [MXPAD-1:0] gemhit_roll7;
    output [13:0] cluster0, // cluster0 in GEM coordinates (0-1535)
    output [13:0] cluster1, // cluster1 in GEM coordinates (0-1535)
    output [13:0] cluster2, // cluster2 in GEM coordinates (0-1535)
    output [13:0] cluster3, // cluster3 in GEM coordinates (0-1535)

    output [ 4:0] cluster0_feb,
    output [ 4:0] cluster1_feb,
    output [ 4:0] cluster2_feb,
    output [ 4:0] cluster3_feb,

    output [ 2:0] cluster0_roll,// eta partition number 
    output [ 2:0] cluster1_roll,
    output [ 2:0] cluster2_roll,
    output [ 2:0] cluster3_roll,

    output [ 7:0] cluster0_pad, // pad number in one roll, no VFAT boundary
    output [ 7:0] cluster1_pad,
    output [ 7:0] cluster2_pad,
    output [ 7:0] cluster3_pad,

    output vpf0, // cluster0 valid flag
    output vpf1, // cluster1 valid flag
    output vpf2, // cluster2 valid flag
    output vpf3,  // cluster3 valid flag
    output reg [MXFEB-1:0] active_feb_list  // 24 bit register of active FEBs. Can be used e.g. in GEM only self-trigger

);

// Raw hits RAM parameters
parameter RAM_DEPTH = 2048; // Storage bx depth
parameter RAM_ADRB  = 11;   // Address width=log2(ram_depth)
parameter RAM_WIDTH = 14;   // Data width

// Gem Count
parameter IGEM     = 0;
parameter MXCLST   = 4;
parameter CLSTBITS = 14;
parameter MXPAD    = 192;
parameter MXROLL   = 8;
parameter MXFEB    = 24;

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

        .overflow             (overflow),
        .bc0marker            (bc0marker),
        .resyncmarker          (resyncmarker),

        .gtx_rx_sump          (gtx_rx_sump)             // Unused signals
    );

    wire gtx_sump = gtx_rx_start | gtx_rx_fc | gtx_rx_match | gtx_rx_match | gtx_rx_sump;

//------------------------------------------------------------------------------------------------------------------
// Decompose packed GEM data format
//------------------------------------------------------------------------------------------------------------------

  wire [13:0] cluster     [3:0];
  wire [13:0] cluster_raw [3:0];
  wire [15:0] gem_inj     [3:0];
  wire [13:0] cluster_inj [3:0];
  wire [11:0] adr         [3:0];
  wire [ 2:0] cnt         [3:0];
  wire [ 0:0] vpf         [3:0];
  //add vfat, roll,pad in a roll
  reg [ 4:0] cluster_feb [3:0];       
  reg [ 2:0] cluster_roll[3:0];       
  reg [ 7:0] cluster_pad [3:0];       

  //wire [MXPAD-1:0] gemhit_roll0 = 0;
  //wire [MXPAD-1:0] gemhit_roll1 = 0;
  //wire [MXPAD-1:0] gemhit_roll2 = 0;
  //wire [MXPAD-1:0] gemhit_roll3 = 0;
  //wire [MXPAD-1:0] gemhit_roll4 = 0;
  //wire [MXPAD-1:0] gemhit_roll5 = 0;
  //wire [MXPAD-1:0] gemhit_roll6 = 0;
  //wire [MXPAD-1:0] gemhit_roll7 = 0;
  //wire [MXPAD*MXROLL-1:0] hits = 0;
  //wire [MXPAD*MXROLL-1:0] hits_cluster [3:0];

  reg pass_ff=1; // pass raw data or use injector ?

  genvar iclst;
  generate
  for (iclst=0; iclst<4; iclst=iclst+1) begin: cluster_assignment
    assign cluster     [iclst] = (pass_ff) ? cluster_raw [iclst] : cluster_inj [iclst];
    assign cluster_raw [iclst] = gtx_rx_data[(iclst+1)*14-1 : iclst*14];
    assign cluster_inj [iclst] = gem_inj[iclst][13:0];
    assign adr         [iclst] = cluster[iclst][10:0];
    assign cnt         [iclst] = cluster[iclst][13:11];
    assign vpf         [iclst] = ~(adr[iclst][10:9]==2'b11);
    //assign hits_cluster[iclst] = (vpf[iclst] ? {(1536-cnt[iclst]-1-adr[iclst])*{0},(cnt[iclst]+1)*{1}, adr[iclst]*{0}} : 0);

   always @(*) begin
   case (adr[iclst][10:6]) // adr[10:6] is the "natural" vfatid
     5'd0:    begin  cluster_feb[iclst] <= 5'd0 ;  cluster_roll[iclst] <= 3'd0; cluster_pad[iclst] <= {2'b00,adr[iclst][5:0]}; end
     5'd1:    begin  cluster_feb[iclst] <= 5'd8 ;  cluster_roll[iclst] <= 3'd0; cluster_pad[iclst] <= {2'b01,adr[iclst][5:0]}; end
     5'd2:    begin  cluster_feb[iclst] <= 5'd16;  cluster_roll[iclst] <= 3'd0; cluster_pad[iclst] <= {2'b10,adr[iclst][5:0]}; end
     5'd3:    begin  cluster_feb[iclst] <= 5'd1 ;  cluster_roll[iclst] <= 3'd1; cluster_pad[iclst] <= {2'b00,adr[iclst][5:0]}; end
     5'd4:    begin  cluster_feb[iclst] <= 5'd9 ;  cluster_roll[iclst] <= 3'd1; cluster_pad[iclst] <= {2'b01,adr[iclst][5:0]}; end
     5'd5:    begin  cluster_feb[iclst] <= 5'd17;  cluster_roll[iclst] <= 3'd1; cluster_pad[iclst] <= {2'b10,adr[iclst][5:0]}; end
     5'd6:    begin  cluster_feb[iclst] <= 5'd2 ;  cluster_roll[iclst] <= 3'd2; cluster_pad[iclst] <= {2'b00,adr[iclst][5:0]}; end
     5'd7:    begin  cluster_feb[iclst] <= 5'd10;  cluster_roll[iclst] <= 3'd2; cluster_pad[iclst] <= {2'b01,adr[iclst][5:0]}; end
     5'd8:    begin  cluster_feb[iclst] <= 5'd18;  cluster_roll[iclst] <= 3'd2; cluster_pad[iclst] <= {2'b10,adr[iclst][5:0]}; end
     5'd9:    begin  cluster_feb[iclst] <= 5'd3 ;  cluster_roll[iclst] <= 3'd3; cluster_pad[iclst] <= {2'b00,adr[iclst][5:0]}; end
     5'd10:   begin  cluster_feb[iclst] <= 5'd11;  cluster_roll[iclst] <= 3'd3; cluster_pad[iclst] <= {2'b01,adr[iclst][5:0]}; end
     5'd11:   begin  cluster_feb[iclst] <= 5'd19;  cluster_roll[iclst] <= 3'd3; cluster_pad[iclst] <= {2'b10,adr[iclst][5:0]}; end
     5'd12:   begin  cluster_feb[iclst] <= 5'd4 ;  cluster_roll[iclst] <= 3'd4; cluster_pad[iclst] <= {2'b00,adr[iclst][5:0]}; end
     5'd13:   begin  cluster_feb[iclst] <= 5'd12;  cluster_roll[iclst] <= 3'd4; cluster_pad[iclst] <= {2'b01,adr[iclst][5:0]}; end
     5'd14:   begin  cluster_feb[iclst] <= 5'd20;  cluster_roll[iclst] <= 3'd4; cluster_pad[iclst] <= {2'b10,adr[iclst][5:0]}; end
     5'd15:   begin  cluster_feb[iclst] <= 5'd5 ;  cluster_roll[iclst] <= 3'd5; cluster_pad[iclst] <= {2'b00,adr[iclst][5:0]}; end
     5'd16:   begin  cluster_feb[iclst] <= 5'd13;  cluster_roll[iclst] <= 3'd5; cluster_pad[iclst] <= {2'b01,adr[iclst][5:0]}; end
     5'd17:   begin  cluster_feb[iclst] <= 5'd21;  cluster_roll[iclst] <= 3'd5; cluster_pad[iclst] <= {2'b10,adr[iclst][5:0]}; end
     5'd18:   begin  cluster_feb[iclst] <= 5'd6 ;  cluster_roll[iclst] <= 3'd6; cluster_pad[iclst] <= {2'b00,adr[iclst][5:0]}; end
     5'd19:   begin  cluster_feb[iclst] <= 5'd14;  cluster_roll[iclst] <= 3'd6; cluster_pad[iclst] <= {2'b01,adr[iclst][5:0]}; end
     5'd20:   begin  cluster_feb[iclst] <= 5'd22;  cluster_roll[iclst] <= 3'd6; cluster_pad[iclst] <= {2'b10,adr[iclst][5:0]}; end
     5'd21:   begin  cluster_feb[iclst] <= 5'd7 ;  cluster_roll[iclst] <= 3'd7; cluster_pad[iclst] <= {2'b00,adr[iclst][5:0]}; end
     5'd22:   begin  cluster_feb[iclst] <= 5'd15;  cluster_roll[iclst] <= 3'd7; cluster_pad[iclst] <= {2'b01,adr[iclst][5:0]}; end
     5'd23:   begin  cluster_feb[iclst] <= 5'd23;  cluster_roll[iclst] <= 3'd7; cluster_pad[iclst] <= {2'b10,adr[iclst][5:0]}; end
     default: begin  cluster_feb[iclst] <= 5'd24;  cluster_roll[iclst] <= 3'd0; cluster_pad[iclst] <=                   8'd192; end  //invalid case
   endcase
   end

  end
  endgenerate



  wire gem_has_data = (vpf[0]|vpf[1]|vpf[2]|vpf[3]);


  // form a 24 bit list of active febs, based on presence of cluster in gemA
  genvar ifeb;
  generate
  for (ifeb=0; ifeb<MXFEB; ifeb=ifeb+1)     begin:   active_feb_loop
    always @(posedge clock) begin
    active_feb_list [ifeb] <= (cluster_feb[0]==ifeb && vpf[0]) |
                              (cluster_feb[1]==ifeb && vpf[1]) |
                              (cluster_feb[2]==ifeb && vpf[2]) |
                              (cluster_feb[3]==ifeb && vpf[3]);
    end
  end
  endgenerate

//----------------------------------------------------------------------------------------------------------------------
// outputs
//----------------------------------------------------------------------------------------------------------------------

assign vpf0 = vpf[0];
assign vpf1 = vpf[1];
assign vpf2 = vpf[2];
assign vpf3 = vpf[3];

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

      .WEBWE               (),                                                    // 4-bit  B port write enable/Write enable input
      .ENBWREN             (1'b1),                                                // 1-bit  B port enable/Write enable input
      .REGCEB              (1'b0),                                                // 1-bit  B port register enable input
      .RSTRAMB             (1'b0),                                                // 1-bit  B port set/reset input
      .RSTREGB             (1'b0),                                                // 1-bit  B port register set/reset input
      .CLKBWRCLK           (clock),                                               // 1-bit  B port clock/Write clock input
      .ADDRBWRADDR         ({debug_fifo_radr[9:0], 4'b1111}),                     // 14-bit B port address/Write address input 10b->[13:4]
      .DIBDI               (),                                                    // 16-bit B port data/MSB data input
      .DIPBDIP             (),                                                    // 2-bit  B port parity/MSB parity input
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
  wire [MXCLST-1:0] parity_wr_lower;
  wire [MXCLST-1:0] parity_wr_upper;

  wire [MXCLST-1:0] parity_rd_lower;
  wire [MXCLST-1:0] parity_rd_upper;

  assign parity_wr_lower[0] = ~(^cluster[0][6:0]);
  assign parity_wr_lower[1] = ~(^cluster[1][6:0]);
  assign parity_wr_lower[2] = ~(^cluster[2][6:0]);
  assign parity_wr_lower[3] = ~(^cluster[3][6:0]);

  assign parity_wr_upper[0] = ~(^cluster[0][13:7]);
  assign parity_wr_upper[1] = ~(^cluster[1][13:7]);
  assign parity_wr_upper[2] = ~(^cluster[2][13:7]);
  assign parity_wr_upper[3] = ~(^cluster[3][13:7]);

  // Raw hits RAM writes incoming hits into port A, reads out to DMB via port B
  wire [CLSTBITS-1:0] fifo_rdata_clst [MXCLST-1:0];

  initial $display("gem: generating Virtex6 RAMB18E1_S9_S9 raw.rawhits_ram");
  wire [16-7:0] db [MXCLST-1:0];                // Virtex6 dob dummy, no sump needed

  // Compare read parity to write parity
  wire [MXCLST-1:0] parity_expect_lower;
  wire [MXCLST-1:0] parity_expect_upper;

  // ram is natively 9x2048, or we can cascade paired rams to produce an 18x1024 bit ram.
  // but we need an 18x2048 bit ram. we can achieve this either by cascading two 18x1024 bit rams,
  // or by concatenating two 9x2048 bit rams.
  // here I have elected to choose the latter option, of concatenating two parallel rams.

  generate
  for (iclst=0; iclst<MXCLST; iclst=iclst+1) begin: raw

    // ram for the lower 7 bits.
    //------------------------------------------------------------------------------------------------------------------

      RAMB18E1 #( // Virtex6
        .RAM_MODE            ("TDP"),        // SDP or TDP
        .READ_WIDTH_A        (0),            // 0,1,2,4,9,18,36 Read/write width per port
        .WRITE_WIDTH_A       (9),            // 0,1,2,4,9,18
        .READ_WIDTH_B        (9),            // 0,1,2,4,9,18
        .WRITE_WIDTH_B       (0),            // 0,1,2,4,9,18,36
        .WRITE_MODE_A        ("READ_FIRST"), // WRITE_FIRST, READ_FIRST, or NO_CHANGE
        .WRITE_MODE_B        ("READ_FIRST"),
        .SIM_COLLISION_CHECK ("ALL")         // ALL, WARNING_ONLY, GENERATE_X_ONLY or NONE)
      ) rawhits_ram_lower (
        .WEA           ({2{fifo_wen}}),                 // 2-bit  A port write enable input
        .ENARDEN       (1'b1),                          // 1-bit  A port enable/Read enable input
        .RSTRAMARSTRAM (1'b0),                          // 1-bit  A port set/reset input
        .RSTREGARSTREG (1'b0),                          // 1-bit  A port register set/reset input
        .REGCEAREGCE   (1'b0),                          // 1-bit  A port register enable/Register enable input
        .CLKARDCLK     (clock),                         // 1-bit  A port clock/Read clock input
        .ADDRARDADDR   ({fifo_wadr[10:0],3'h7}),        // 14-bit A port address/Read address input 9b->[13:3]
        .DIADI         ({9'h0,cluster[iclst][6:0]}),    // 16-bit A port data/LSB data input
        .DIPADIP       ({1'b0,parity_wr_lower[iclst]}), // 2-bit  A port parity/LSB parity input
        .DOADO         (),                              // 16-bit A port data/LSB data output
        .DOPADOP       (),                              // 2-bit  A port parity/LSB parity output

        .WEBWE         (),                                             // 4-bit B port write enable/Write enable input
        .ENBWREN       (1'b1),                                         // 1-bit B port enable/Write enable input
        .REGCEB        (1'b0),                                         // 1-bit B port register enable input
        .RSTRAMB       (1'b0),                                         // 1-bit B port set/reset input
        .RSTREGB       (1'b0),                                         // 1-bit B port register set/reset input
        .CLKBWRCLK     (clock),                                        // 1-bit B port clock/Write clock input
        .ADDRBWRADDR   ({fifo_radr[10:0],3'hF}),                       // 14-bit B port address/Write address input 18b->[13:4]
        .DIBDI         (),                                             // 16-bit B port data/MSB data input
        .DIPBDIP       (),                                             // 2-bit B port parity/MSB parity input
        .DOBDO         ({db[iclst][8:0],fifo_rdata_clst[iclst][6:0]}), // 16-bit B port data/MSB data output
        .DOPBDOP       ({db[iclst][9],  parity_rd_lower[iclst]})       // 2-bit B port parity/MSB parity output
      );

    // ram for the upper 7 bits.
    //------------------------------------------------------------------------------------------------------------------

      RAMB18E1 #( // Virtex6
        .RAM_MODE            ("TDP"),        // SDP or TDP
        .READ_WIDTH_A        (0),            // 0,1,2,4,9,18,36 Read/write width per port
        .WRITE_WIDTH_A       (9),            // 0,1,2,4,9,18
        .READ_WIDTH_B        (9),            // 0,1,2,4,9,18
        .WRITE_WIDTH_B       (0),            // 0,1,2,4,9,18,36
        .WRITE_MODE_A        ("READ_FIRST"), // WRITE_FIRST, READ_FIRST, or NO_CHANGE
        .WRITE_MODE_B        ("READ_FIRST"),
        .SIM_COLLISION_CHECK ("ALL")         // ALL, WARNING_ONLY, GENERATE_X_ONLY or NONE)
      ) rawhits_ram_upper (
        .WEA           ({2{fifo_wen}}),                 // 2-bit  A port write enable input
        .ENARDEN       (1'b1),                          // 1-bit  A port enable/Read enable input
        .RSTRAMARSTRAM (1'b0),                          // 1-bit  A port set/reset input
        .RSTREGARSTREG (1'b0),                          // 1-bit  A port register set/reset input
        .REGCEAREGCE   (1'b0),                          // 1-bit  A port register enable/Register enable input
        .CLKARDCLK     (clock),                         // 1-bit  A port clock/Read clock input
        .ADDRARDADDR   ({fifo_wadr[10:0],3'h7}),        // 14-bit A port address/Read address input 9b->[13:3]
        .DIADI         ({9'h0,cluster[iclst][13:7]}),   // 16-bit A port data/LSB data input
        .DIPADIP       ({1'b0,parity_wr_upper[iclst]}), // 2-bit  A port parity/LSB parity input
        .DOADO         (),                              // 16-bit A port data/LSB data output
        .DOPADOP       (),                              // 2-bit  A port parity/LSB parity output

        .WEBWE         (),                                              // 4-bit B port write enable/Write enable input
        .ENBWREN       (1'b1),                                          // 1-bit B port enable/Write enable input
        .REGCEB        (1'b0),                                          // 1-bit B port register enable input
        .RSTRAMB       (1'b0),                                          // 1-bit B port set/reset input
        .RSTREGB       (1'b0),                                          // 1-bit B port register set/reset input
        .CLKBWRCLK     (clock),                                         // 1-bit B port clock/Write clock input
        .ADDRBWRADDR   ({fifo_radr[10:0],3'hF}),                        // 14-bit B port address/Write address input 18b->[13:4]
        .DIBDI         (),                                              // 16-bit B port data/MSB data input
        .DIPBDIP       (),                                              // 2-bit B port parity/MSB parity input
        .DOBDO         ({db[iclst][8:0],fifo_rdata_clst[iclst][13:7]}), // 16-bit B port data/MSB data output
        .DOPBDOP       ({db[iclst][9],  parity_rd_upper[iclst]})        // 2-bit B port parity/MSB parity output
      );

    assign parity_expect_lower[iclst] = ~(^ fifo_rdata_clst[iclst][6:0]);
    assign parity_expect_upper[iclst] = ~(^ fifo_rdata_clst[iclst][13:7]);

  end
  endgenerate

  assign parity_err_gem[3:0] = ~(parity_rd_lower ~^ parity_expect_lower) | ~(parity_rd_upper ~^ parity_expect_upper);
  // ~^ is bitwise equivalence operator

  // Multiplex Raw Hits FIFO RAM output data
  assign fifo_rdata = fifo_rdata_clst[fifo_sel];


  // Sump
  assign gem_sump = gtx_sump | (|debug_parity_err_gem[3:0]);

  //----------------------------------------------------------------------------------------------------------------------
  // GEM Raw Hits Injector
  //----------------------------------------------------------------------------------------------------------------------
  reg [1:0] inj_sm; // synthesis attribute safe_implementation of inj_sm is "yes"

  parameter pass      = 0;
  parameter injecting = 1;

  wire inj_tbin_cnt_done;

  wire sm_reset = global_reset;
  always @(posedge clock) begin
    if (sm_reset)
      inj_sm <= pass;

    else begin
      case (inj_sm)
        pass:      if (inj_go_gem)        inj_sm <= injecting;
        injecting: if (inj_tbin_cnt_done) inj_sm <= pass;
        default                           inj_sm <= pass;
      endcase
    end
  end

  // Injector Time Bin Counter
  reg [11:0] inj_tbin_cnt; // 0-4095
  wire [9:0] inj_tbin_adr; // 0-1023

  always @(posedge clock) begin
    if      (inj_sm==pass)      inj_tbin_cnt <= 0; // Sync load
    else if (inj_sm==injecting) inj_tbin_cnt <= inj_tbin_cnt + 1'b1;
  end

  assign inj_tbin_cnt_done = (inj_tbin_cnt==inj_last_tbin); // counter can wraparound the RAM
  assign inj_tbin_adr[9:0] = inj_tbin_cnt[9:0];

  always @(posedge clock) begin
    if (sm_reset) pass_ff <= 1;
    else          pass_ff <= (inj_sm==pass);
  end

  // Injector RAM: RPC Pads
  // Port A: rw 16 bits x 1024 tbins, read/write via VME
  // Port B: ro 16 bits via injector SM
  wire [15:0] inj_rdataa [3:0];

  wire [3:0] wen;
  wire wen_os;

  x_oneshot uwen (inj_wen, clock, wen_os);

  generate
  for (iclst=0; iclst<4; iclst=iclst+1) begin: inj_ram

    assign wen[iclst] = (wen_os) && (inj_igem==IGEM) && (inj_sel==iclst);

    initial $display("gem: generating Virtex6 RAMB18E1_S18_S18 ram.uinjpads");

    RAMB18E1 #(        // Virtex6
      .INIT_00             (256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF),
      .RAM_MODE            ("TDP"),        // SDP or TDP
      .READ_WIDTH_A        (18),           // 0,1,2,4,9,18,36 Read/write width per port
      .WRITE_WIDTH_A       (18),           // 0,1,2,4,9,18
      .READ_WIDTH_B        (18),           // 0,1,2,4,9,18
      .WRITE_WIDTH_B       (0),            // 0,1,2,4,9,18,36
      .WRITE_MODE_A        ("READ_FIRST"), // Must be same for both ports in SDP mode:
      .WRITE_MODE_B        ("READ_FIRST"), // WRITE_FIRST, READ_FIRST, or NO_CHANGE)
      .SIM_COLLISION_CHECK ("ALL")         // ALL, WARNING_ONLY, GENERATE_X_ONLY or NONE)
    )
    uinjpads0 (
      .WEA           ({2{wen[iclst]}}),          // 2-bit  A port write enable input
      .ENARDEN       (1'b1),                     // 1-bit  A port enable/Read enable input
      .RSTRAMARSTRAM (1'b0),                     // 1-bit  A port set/reset input
      .RSTREGARSTREG (1'b0),                     // 1-bit  A port register set/reset input
      .REGCEAREGCE   (1'b0),                     // 1-bit  A port register enable/Register enable input
      .CLKARDCLK     (clock),                    // 1-bit  A port clock/Read clock input
      .ADDRARDADDR   ({inj_rwadr[9:0],4'hF}),    // 14-bit A port address/Read address input 18b->[13:4]
      .DIADI         (inj_wdata[15:0]),          // 16-bit A port data/LSB data input
      .DIPADIP       (),                         // 2-bit  A port parity/LSB parity input
      .DOADO         (inj_rdataa[iclst][15:0]),  // 16-bit A port data/LSB data output
      .DOPADOP       (),                         // 2-bit  A port parity/LSB parity output

      .WEBWE         (),                         // 4-bit  B port write enable/Write enable input
      .ENBWREN       (1'b1),                     // 1-bit  B port enable/Write enable input
      .REGCEB        (1'b0),                     // 1-bit  B port register enable input
      .RSTRAMB       (1'b0),                     // 1-bit  B port set/reset input
      .RSTREGB       (1'b0),                     // 1-bit  B port register set/reset input
      .CLKBWRCLK     (clock),                    // 1-bit  B port clock/Write clock input
      .ADDRBWRADDR   ({inj_tbin_adr[9:0],4'hF}), // 14-bit B port address/Write address input 18b->[13:4]
      .DIBDI         (),                         // 16-bit B port data/MSB data input
      .DIPBDIP       (),                         // 2-bit  B port parity/MSB parity input
      .DOBDO         (gem_inj[iclst][15:0]),     // 16-bit B port data/MSB data output
      .DOPBDOP       ()                          // 2-bit  B port parity/MSB parity output
    );

  end
  endgenerate

//----------------------------------------------------------------------------------------------------------------------
//
//----------------------------------------------------------------------------------------------------------------------

  assign  cluster0      = cluster [0];
  assign  cluster1      = cluster [1];
  assign  cluster2      = cluster [2];
  assign  cluster3      = cluster [3];
  assign  cluster0_feb  = cluster_feb[0];
  assign  cluster1_feb  = cluster_feb[1];
  assign  cluster2_feb  = cluster_feb[2];
  assign  cluster3_feb  = cluster_feb[3];
  assign  cluster0_roll = cluster_roll[0];
  assign  cluster1_roll = cluster_roll[1];
  assign  cluster2_roll = cluster_roll[2];
  assign  cluster3_roll = cluster_roll[3];
  assign  cluster0_pad  = cluster_pad[0];
  assign  cluster1_pad  = cluster_pad[1];
  assign  cluster2_pad  = cluster_pad[2];
  assign  cluster3_pad  = cluster_pad[3];

//-------------------------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------------------------
