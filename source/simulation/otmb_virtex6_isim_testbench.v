`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:37:24 06/06/2014
// Design Name:   otmb_virtex6
// Module Name:   /home/pakhotin/Work/CMS_My_Service_Work/CSC/TMB_Firmware/2014-06-05_OTMB_BPI_Interface_Debug/otmb_fw_code/source/simulation/otmb_virtex6_isim_testbench.v
// Project Name:  otmb_virtex6
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: otmb_virtex6
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module otmb_virtex6_isim_testbench;

  // Inputs to the Unit Under Test (UUT): otmb_virtex6
  reg [23:0] cfeb0_rx;
  reg [23:0] cfeb1_rx;
  reg [23:0] cfeb2_rx;
  reg [23:0] cfeb3_rx;
  reg [23:0] cfeb4_rx;
  reg [28:1] alct_rx;
  reg [5:0] dmb_rx;
  reg [37:0] rpc_rx;
  reg rpc_smbrx;
  reg rpc_dsn;
  reg [50:0] _ccb_rx;
//  reg [23:1] vme_a; // this is now wire connection between VME_sim_master and OTMB
  wire [23:1] vme_a;
//  reg [5:0] vme_am;
  wire [5:0] vme_am; // this is now wire connection between VME_sim_master and OTMB
  reg [10:0] _vme_cmd;
  wire [10:0] _vme_cmd_wire;
  assign _vme_cmd_wire[10] = _vme_cmd[10]; //  _iackin   (_vme_cmd[10]),     // In to VME Interrupt in, daisy chain
//  assign _vme_cmd_wire[9]  = _vme_cmd[9];  //  _iack     (_vme_cmd[9]),      // In to VME Interrupt acknowledge
  assign _vme_cmd_wire[8]  = _vme_cmd[8];  //  _acfail   (_vme_cmd[8]),      // In to VME AC power fail
  assign _vme_cmd_wire[7]  = _vme_cmd[7];  //  _sysreset (_vme_cmd[7]),      // In to VME System reset
//  assign _vme_cmd_wire[6]  = _vme_cmd[6];  //  _sysfail  (_vme_cmd[6]),      // In to VME System fail
//  assign _vme_cmd_wire[5]  = _vme_cmd[5];  //  _ds0      (_vme_cmd[5]),      // In to VME Data Strobe
  assign _vme_cmd_wire[4]  = _vme_cmd[4];  //  _sysclk   (_vme_cmd[4]),      // In to VME VME System clock
//  assign _vme_cmd_wire[3]  = _vme_cmd[3];  //  _ds1      (_vme_cmd[3]),      // In to VME Data Strobe
//  assign _vme_cmd_wire[2]  = _vme_cmd[2];  //  _write    (_vme_cmd[2]),      // In to VME Write strobe
//  assign _vme_cmd_wire[1]  = _vme_cmd[1];  //  _as       (_vme_cmd[1]),      // In to VME Address Strobe
//  assign _vme_cmd_wire[0]  = _vme_cmd[0];  //  _lword    (_vme_cmd[0]),      // In to VME Long word
  
//  reg [6:0] _vme_geo; // this is now wire connection between VME_sim_master and OTMB
  wire [6:0] _vme_geo;
  reg jtag_usr0_tdo;
  reg tmb_clock0;
  reg tmb_clock1;
  reg alct_rxclock;
  reg alct_rxclockd;
  reg mpc_clock;
  reg dcc_clock;
  reg ddd_serial_out;
  reg mez_done;
  reg [3:0] vstat;
  reg _t_crit;
  reg adc_io3_dout;
  reg gp_io4;
  reg [8:7] set_sw;
  reg reset;
  reg clk40p;
  reg clk40n;
  reg clk160p;
  reg clk160n;
  reg qpll_lock;
  reg qpll_err;
  reg clk125p;
  reg clk125n;
  reg t12_sdat;
  reg t12_nfault;
  reg t12_rst;
  reg r12_sdat;
  reg r12_fok;
  reg [6:0] rxp;
  reg [6:0] rxn;
  reg f_sclk;
  reg f_sdat;
  reg f_fok;

  // Outputs from the Unit Under Test (UUT): otmb_virtex6
  wire [4:0] cfeb_clock_en;
  wire cfeb_oe;
  wire [17:5] alct_txa;
  wire [23:19] alct_txb;
  wire alct_clock_en;
  wire alct_rxoe;
  wire alct_txoe;
  wire alct_loop;
  wire [48:0] dmb_tx;
  wire dmb_loop;
  wire _dmb_oe;
  wire [31:0] _mpc_tx;
  wire rpc_loop;
  wire [3:0] rpc_tx;
  wire [26:0] _ccb_tx;
  wire ccb_status_oe;
  wire _hard_reset_alct_fpga;
  wire _hard_reset_tmb_fpga;
  wire gtl_loop;
  wire [6:0] vme_reply;
  wire [5:0] prom_ctrl;
  wire [4:0] step;
  wire ddd_clock;
  wire ddd_adr_latch;
  wire ddd_serial_in;
  wire [2:0] adc_io;
  wire smb_clk;
  wire mez_tp10_busy;
  wire gp_io5;
  wire gp_io6;
  wire gp_io7;
  wire [9:1] mez_tp;
  wire qpll_nrst;
  wire t12_sclk;
  wire r12_sclk;
  wire bpi_cs;

  // Bidirs
  wire [15:0] vme_d;
  wire [3:1] jtag_usr;
  wire [3:0] sel_usr;
  wire [7:0] prom_led;
  wire tmb_sn;
  wire smb_data;
  wire mez_sn;
  wire [7:0] led_fp;
  wire gp_io0;
  wire gp_io1;
  wire gp_io2;
  wire gp_io3;
  wire led_mezD1;
  wire led_mezD2;
  wire led_mezD3;
  wire led_mezD4;
  wire led_mezD5;
  wire led_mezD6;
  wire led_mezD7;
  wire led_mezD8;
	
  // Instantiate the Unit Under Test (UUT)
  otmb_virtex6 uut (
    .cfeb0_rx(cfeb0_rx), 
    .cfeb1_rx(cfeb1_rx), 
    .cfeb2_rx(cfeb2_rx), 
    .cfeb3_rx(cfeb3_rx), 
    .cfeb4_rx(cfeb4_rx), 
    .cfeb_clock_en(cfeb_clock_en), 
    .cfeb_oe(cfeb_oe), 
    .alct_rx(alct_rx), 
    .alct_txa(alct_txa), 
    .alct_txb(alct_txb), 
    .alct_clock_en(alct_clock_en), 
    .alct_rxoe(alct_rxoe), 
    .alct_txoe(alct_txoe), 
    .alct_loop(alct_loop), 
    .dmb_rx(dmb_rx), 
    .dmb_tx(dmb_tx), 
    .dmb_loop(dmb_loop), 
    ._dmb_oe(_dmb_oe), 
    ._mpc_tx(_mpc_tx), 
    .rpc_rx(rpc_rx), 
    .rpc_smbrx(rpc_smbrx), 
    .rpc_dsn(rpc_dsn), 
    .rpc_loop(rpc_loop), 
    .rpc_tx(rpc_tx), 
    ._ccb_rx(_ccb_rx), 
    ._ccb_tx(_ccb_tx), 
    .ccb_status_oe(ccb_status_oe), 
    ._hard_reset_alct_fpga(_hard_reset_alct_fpga), 
    ._hard_reset_tmb_fpga(_hard_reset_tmb_fpga), 
    .gtl_loop(gtl_loop), 
    .vme_d(vme_d), 
    .vme_a(vme_a),         // input from VME sim master
    .vme_am(vme_am),       // input from VME sim master
//    ._vme_cmd(_vme_cmd), // now the input pertially coming from VME sim master
    ._vme_cmd(_vme_cmd_wire), // input (partially) from VME sim master
    ._vme_geo(_vme_geo),   // input from VME sim master
    .vme_reply(vme_reply), // vme_reply[2] output to VME sim master
    .jtag_usr(jtag_usr), 
    .jtag_usr0_tdo(jtag_usr0_tdo), 
    .sel_usr(sel_usr), 
    .prom_led(prom_led), 
    .prom_ctrl(prom_ctrl), 
    .tmb_clock0(tmb_clock0), 
    .tmb_clock1(tmb_clock1), 
    .alct_rxclock(alct_rxclock), 
    .alct_rxclockd(alct_rxclockd), 
    .mpc_clock(mpc_clock), 
    .dcc_clock(dcc_clock), 
    .step(step), 
    .ddd_clock(ddd_clock), 
    .ddd_adr_latch(ddd_adr_latch), 
    .ddd_serial_in(ddd_serial_in), 
    .ddd_serial_out(ddd_serial_out), 
    .mez_done(mez_done), 
    .vstat(vstat), 
    ._t_crit(_t_crit), 
    .tmb_sn(tmb_sn), 
    .smb_data(smb_data), 
    .mez_sn(mez_sn), 
    .adc_io(adc_io), 
    .adc_io3_dout(adc_io3_dout), 
    .smb_clk(smb_clk), 
    .mez_tp10_busy(mez_tp10_busy), 
    .led_fp(led_fp), 
    .gp_io0(gp_io0), 
    .gp_io1(gp_io1), 
    .gp_io2(gp_io2), 
    .gp_io3(gp_io3), 
    .gp_io4(gp_io4), 
    .gp_io5(gp_io5), 
    .gp_io6(gp_io6), 
    .gp_io7(gp_io7), 
    .led_mezD1(led_mezD1), 
    .led_mezD2(led_mezD2), 
    .led_mezD3(led_mezD3), 
    .led_mezD4(led_mezD4), 
    .led_mezD5(led_mezD5), 
    .led_mezD6(led_mezD6), 
    .led_mezD7(led_mezD7), 
    .led_mezD8(led_mezD8), 
    .set_sw(set_sw), 
    .mez_tp(mez_tp), 
    .reset(reset), 
    .clk40p(clk40p), 
    .clk40n(clk40n), 
    .clk160p(clk160p), 
    .clk160n(clk160n), 
    .qpll_lock(qpll_lock), 
    .qpll_err(qpll_err), 
    .qpll_nrst(qpll_nrst), 
    .clk125p(clk125p), 
    .clk125n(clk125n), 
    .t12_sclk(t12_sclk), 
    .t12_sdat(t12_sdat), 
    .t12_nfault(t12_nfault), 
    .t12_rst(t12_rst), 
    .r12_sclk(r12_sclk), 
    .r12_sdat(r12_sdat), 
    .r12_fok(r12_fok), 
    .rxp(rxp), 
    .rxn(rxn), 
    .f_sclk(f_sclk), 
    .f_sdat(f_sdat), 
    .f_fok(f_fok), 
    .bpi_cs(bpi_cs)
  );

	// Additional buses for sim units
	reg         clk;
	reg         rst;
	wire        rstn = ~rst;
	reg         go;
	reg         stop;
	reg         mode;
	reg [9:0]   cmd_n;
	// Connection between VME and test_controller
	wire        vme_cmd;     // from test_controller to VME
	wire        vme_cmd_rd;  // from VME to test_controller
	wire [23:1] vme_addr;    // from test_controller to VME
	wire        vme_wr;      // from test_controller to VME
	wire [15:0] vme_wr_data; // from test_controller to VME
	wire        vme_rd;      // from test_controller to VME
	wire [15:0] vme_rd_data; // from VME to test_controller
	// Connection between file_handler and test_controller
	wire        start;            // from file_handler to test_controller
	wire [31:0] vme_cmd_reg;      // from file_handler to test_controller
	wire [31:0] vme_dat_reg_in;   // from file_handler to test_controller
	wire [31:0] vme_dat_mem_in;   // from test_controller to file_handler
	wire        vme_mem_rden;     // from test_controller to file_handler
	wire        vme_dat_mem_wren; // from test_controller to file_handler
	//Connection between VME and OTMB
	wire [15:0] indata;  // from OTMB to VME
  wire [15:0] outdata; // from VME to OTMB
  wire oe_b;
  IOBUF #(.DRIVE(12),.IOSTANDARD("DEFAULT"),.SLEW("SLOW")) IOBUF_VME_D[15:0] (.O(outdata),.IO(vme_d),.I(indata),.T(oe_b));
  
  // Instantiate vme_sim_master module
  vme_sim_master uvme_sim_master (
  	.clk(clk),      // input 25 ns
  	.rstn(rstn),    // input
  	.sw_reset(rst), // input
  	// to/from test_controller
  	.vme_cmd(vme_cmd),         // input from test_controller
  	.vme_cmd_rd(vme_cmd_rd),   // output to test_controller
  	.vme_addr(vme_addr),       // input from test_controller
  	.vme_wr(vme_wr),           // input from test_controller
  	.vme_wr_data(vme_wr_data), // input from test_controller
  	.vme_rd(vme_rd),           // input from test_controller
  	.vme_rd_data(vme_rd_data), // output to test_controller
  	// to/from OTMB
  	.dtack(vme_reply[2]),       // input from OTMB
  	.oe_b(oe_b),                // trigger direction of data to/from OTMB
  	.data_in(outdata),          // input from OTMB
  	.data_out(indata),          // output to OTMB
  	.addr(vme_a),               // output to OTMB
  	.ga(_vme_geo),              // output to OTMB
  	.am(vme_am),                // output to OTMB
  	.lword(_vme_cmd_wire[0]),   // output to OTMB
  	.as(_vme_cmd_wire[1]),      // output to OTMB
  	.write_b(_vme_cmd_wire[2]), // output to OTMB
  	.ds1(_vme_cmd_wire[3]),     // output to OTMB
  	.ds0(_vme_cmd_wire[5]),     // output to OTMB
  	.sysfail(_vme_cmd_wire[6]), // output to OTMB
  	.iack(_vme_cmd_wire[9])     // output to OTMB
  );
  
  // Instantiate file_handler module
  file_handler ufile_handler (
    .clk(clk), // input 25 ns
    // to/from test_controller
    .start(start),                    // output to test_controller
    .vme_cmd_reg(vme_cmd_reg),        // output to test_controller
    .vme_dat_reg_in(vme_dat_reg_in),  // output to test_controller
    .vme_dat_reg_out(vme_dat_mem_in), // input from test_controller
    .vme_cmd_rd(vme_mem_rden),        // input from test_controller
    .vme_dat_wr(vme_dat_mem_wren)     // input from test_controller
  );
  
  // Instantiate test_controller module
  test_controller utest_controller (
  	.clk(clk),      // input 25 ns
  	.rstn(rstn),    // input
  	.sw_reset(rst), // input
  	.tc_enable(go), // input
  	.stop(stop),    // input
  	.mode(mode),    // input "1" = read commands from file
  	.cmd_n(cmd_n),  // input "0000000000"
  	// to/from VME
  	.vme_cmd(vme_cmd),         // output to VME
  	.vme_cmd_rd(vme_cmd_rd),   // input from VME
  	.vme_addr(vme_addr),       // output to VME
  	.vme_wr(vme_wr),           // output to VME
  	.vme_wr_data(vme_wr_data), // output to VME
  	.vme_rd(vme_rd),           // output to VME
  	.vme_rd_data(vme_rd_data), // input from VME
  	// to/from file_handler
  	.start(start),                      // input from file_handler
  	.vme_cmd_reg(vme_cmd_reg),          // input from file_handler
  	.vme_cmd_mem_out(vme_cmd_reg),      // input from file_handler
  	.vme_dat_reg_in(vme_dat_reg_in),    // input from file_handler
  	.vme_dat_mem_out(vme_dat_reg_in),   // input from file_handler
  	.vme_dat_mem_in(vme_dat_mem_in),    // output to file_handler
  	.vme_mem_rden(vme_mem_rden),        // output to file_handler
  	.vme_dat_mem_wren(vme_dat_mem_wren) // output to file_handler
  );
  
  // PROM communication
//	reg        prom_we_b;
	wire        prom_we_b     = _ccb_tx[26];
  wire        prom_cs_b     = bpi_cs;
  wire        prom_oe_b     = _ccb_tx[14];
  wire        prom_le_b     = _ccb_tx[3];
  wire [22:0] prom_addr;
  assign      prom_addr[0]  = dmb_tx[7];
  assign      prom_addr[1]  = dmb_tx[6];
  assign      prom_addr[2]  = dmb_tx[26];
  assign      prom_addr[3]  = dmb_tx[22];
  assign      prom_addr[4]  = dmb_tx[38];
  assign      prom_addr[5]  = dmb_tx[42];
  assign      prom_addr[6]  = dmb_tx[34];
  assign      prom_addr[7]  = dmb_tx[35];
  assign      prom_addr[8]  = dmb_tx[46];
  assign      prom_addr[9]  = dmb_tx[47];
  assign      prom_addr[10] = dmb_tx[36];
  assign      prom_addr[11] = dmb_tx[39];
  assign      prom_addr[12] = dmb_tx[37];
  assign      prom_addr[13] = dmb_tx[41];
  assign      prom_addr[14] = dmb_tx[31];
  assign      prom_addr[15] = dmb_tx[30];
  assign      prom_addr[16] = dmb_tx[14];
  assign      prom_addr[17] = dmb_tx[10];
  assign      prom_addr[18] = dmb_tx[0];
  assign      prom_addr[19] = dmb_tx[1];
  assign      prom_addr[20] = dmb_tx[18];
  assign      prom_addr[21] = dmb_tx[19];
  assign      prom_addr[22] = dmb_tx[11];
  wire [15:0] prom_data;
  assign      prom_data[0]  = led_fp[0];
  assign      prom_data[1]  = led_fp[1];
  assign      prom_data[2]  = led_fp[2];
  assign      prom_data[3]  = led_fp[3];
  assign      prom_data[4]  = led_fp[4];
  assign      prom_data[5]  = led_fp[5];
  assign      prom_data[6]  = led_fp[6];
  assign      prom_data[7]  = led_fp[7];
  assign      prom_data[8]  = led_mezD1;
  assign      prom_data[9]  = led_mezD2;
  assign      prom_data[10] = led_mezD3;
  assign      prom_data[11] = led_mezD4;
  assign      prom_data[12] = led_mezD5;
  assign      prom_data[13] = led_mezD6;
  assign      prom_data[14] = led_mezD7;
  assign      prom_data[15] = led_mezD8;
  
  // Instantiate prom_sim module
  prom_sim uprom_sim (
  	.clk(clk),
    .rst(rst),
    // to/from OTMB
    .we_b(prom_we_b), // input from OTMB
    .cs_b(prom_cs_b), // input from OTMB
    .oe_b(prom_oe_b), // input from OTMB
    .le_b(prom_le_b), // input from OTMB
    .addr(prom_addr), // input from OTMB
    .data(prom_data)  // input/output from/to OTMB
  );
  
  always
		#12.5 clk = ~clk; // 25 ns -> 40 MHz Clock for additional sim units
  
  always
		#12.5 tmb_clock0 = ~tmb_clock0; // 25 ns -> 40 MHz
	
	always
		#12.5 tmb_clock1 = ~tmb_clock1; // 25 ns -> 40 MHz
	
	always
		#12.5 alct_rxclock = ~alct_rxclock; // 25 ns -> 40 MHz
	
	always
		#12.5 alct_rxclockd = ~alct_rxclockd; // 25 ns -> 40 MHz
	
	always
		#12.5 mpc_clock = ~mpc_clock; // 25 ns -> 40 MHz
	
	always
		#12.5 dcc_clock = ~dcc_clock; // 25 ns -> 40 MHz
	
  initial begin
    $display($time, " Starting the Initialization");
    
    // Initialize Inputs
    cfeb0_rx = 0;
    cfeb1_rx = 0;
    cfeb2_rx = 0;
    cfeb3_rx = 0;
    cfeb4_rx = 0;
    alct_rx = 0;
    dmb_rx = 0;
    rpc_rx = 0;
    rpc_smbrx = 0;
    rpc_dsn = 0;
    _ccb_rx = 0;
    
    // VME cmd - inverted logic
    _vme_cmd[10] = 1; //  _iackin    (_vme_cmd[10]),     // In to VME Interrupt in, daisy chain
//  _vme_cmd[9]  = 0;  //  _iack     (_vme_cmd[9]),      // In to VME Interrupt acknowledge     <-- coming from vme_sim_master
    _vme_cmd[8]  = 1;  //  _acfail   (_vme_cmd[8]),      // In to VME AC power fail
    _vme_cmd[7]  = 1;  //  _sysreset (_vme_cmd[7]),      // In to VME System reset
//  _vme_cmd[6]  = 0;  //  _sysfail  (_vme_cmd[6]),      // In to VME System fail               <-- coming from vme_sim_master
//  _vme_cmd[5]  = 0;  //  _ds0      (_vme_cmd[5]),      // In to VME Data Strobe               <-- coming from vme_sim_master
    _vme_cmd[4]  = 1;  //  _sysclk   (_vme_cmd[4]),      // In to VME VME System clock
//  _vme_cmd[3]  = 0;  //  _ds1      (_vme_cmd[3]),      // In to VME Data Strobe               <-- coming from vme_sim_master
//  _vme_cmd[2]  = 0;  //  _write    (_vme_cmd[2]),      // In to VME Write strobe              <-- coming from vme_sim_master
//  _vme_cmd[1]  = 0;  //  _as       (_vme_cmd[1]),      // In to VME Address Strobe            <-- coming from vme_sim_master
//  _vme_cmd[0]  = 0;  //  _lword    (_vme_cmd[0]),      // In to VME Long word                 <-- coming from vme_sim_master
    
    jtag_usr0_tdo = 0;
    
    clk           = 1; // set all initial clocks to 1 to avoid 12.5 ns delay at start
    tmb_clock0    = 1;
    tmb_clock1    = 1;
    alct_rxclock  = 1;
    alct_rxclockd = 1;
    mpc_clock     = 1;
    dcc_clock     = 1;
    
    ddd_serial_out = 0;
    mez_done = 0;
    vstat = 0;
    _t_crit = 0;
    adc_io3_dout = 0;
    gp_io4 = 0;
    
    // switches on board to connect mezanine board test points (labelled holes D1-D8) to BPI signals
    set_sw[7] = 0;
    set_sw[8] = 0;
    
    reset = 0;
    
    clk40p = 0;
    clk40n = 0;
    clk160p = 0;
    clk160n = 0;
    qpll_lock = 0;
    qpll_err = 0;
    clk125p = 0;
    clk125n = 0;
    t12_sdat = 0;
    t12_nfault = 0;
    t12_rst = 0;
    r12_sdat = 0;
    r12_fok = 0;
    rxp = 0;
    rxn = 0;
    f_sclk = 0;
    f_sdat = 0;
    f_fok = 0;
    
    $display($time, " Finishing the Initialization");
    
//    @( posedge tmb_clock0 );
//    $display($time, "  1 display tmb_clock0 = %b", tmb_clock0);
    
//    $stop;
  end
  
  // Stimulus to reset units
  initial begin
  	// Reset units
  	rst = 0;
  	#200;
  	$display($time, " Starting the Reset");
  	rst = 1;
  	#3000;
  	rst = 0;
  	$display($time, " Finishing the Reset");
  end
  
  // Stimulus for test_controller to go and stop
  initial begin
  	go    = 0;
  	stop  = 0;
  	mode  = 1; // "1" = read commands from file
  	cmd_n = 10'b0000000000; // all zeroes - some default value
  	
  	#4000; // in original UCSB code it is 15us (yes, microseconds)
  	$display($time, " Starting the Sequence of Commands");
  	go = 1;
  end
  
//  initial begin
//    $monitor($time, "  monitor tmb_clock0 = %b", tmb_clock0);
//  end
      
endmodule

