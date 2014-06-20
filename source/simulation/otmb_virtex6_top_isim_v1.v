`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:37:24 06/06/2014
// Design Name:   otmb_virtex6
// Module Name:   /home/pakhotin/Work/CMS_My_Service_Work/CSC/TMB_Firmware/2014-06-05_OTMB_BPI_Interface_Debug/otmb_fw_code/source/simulation/otmb_virtex6_top_isim_v1.v
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

module otmb_virtex6_top_isim_v1;

	// Inputs
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
	reg [23:1] vme_a;
	reg [5:0] vme_am;
	reg [10:0] _vme_cmd;
	reg [6:0] _vme_geo;
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

	// Outputs
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
	wire mez_busy;
	wire gp_io5;
	wire gp_io6;
	wire gp_io7;
	wire [9:1] testled;
	wire qpll_nrst;
	wire t12_sclk;
	wire r12_sclk;
	wire fcs;

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
	wire meztp20;
	wire meztp21;
	wire meztp22;
	wire meztp23;
	wire meztp24;
	wire meztp25;
	wire meztp26;
	wire meztp27;

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
		.vme_a(vme_a), 
		.vme_am(vme_am), 
		._vme_cmd(_vme_cmd), 
		._vme_geo(_vme_geo), 
		.vme_reply(vme_reply), 
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
		.mez_busy(mez_busy), 
		.led_fp(led_fp), 
		.gp_io0(gp_io0), 
		.gp_io1(gp_io1), 
		.gp_io2(gp_io2), 
		.gp_io3(gp_io3), 
		.gp_io4(gp_io4), 
		.gp_io5(gp_io5), 
		.gp_io6(gp_io6), 
		.gp_io7(gp_io7), 
		.meztp20(meztp20), 
		.meztp21(meztp21), 
		.meztp22(meztp22), 
		.meztp23(meztp23), 
		.meztp24(meztp24), 
		.meztp25(meztp25), 
		.meztp26(meztp26), 
		.meztp27(meztp27), 
		.set_sw(set_sw), 
		.testled(testled), 
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
		.fcs(fcs)
	);
	
	always
			#25 tmb_clock0 = ~tmb_clock0; // 25 ns -> 40 MHz
	
	initial begin
		$display($time, "<< Starting the Simulation >>");
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
		vme_a = 0;
		vme_am = 0;
		_vme_cmd = 0;
		_vme_geo = 0;
		jtag_usr0_tdo = 0;
		tmb_clock0 = 0;
		tmb_clock1 = 0;
		alct_rxclock = 0;
		alct_rxclockd = 0;
		mpc_clock = 0;
		dcc_clock = 0;
		ddd_serial_out = 0;
		mez_done = 0;
		vstat = 0;
		_t_crit = 0;
		adc_io3_dout = 0;
		gp_io4 = 0;
		set_sw = 0;
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
		
		// Wait 100 ns for global reset to finish
//		#100;
        
		// Add stimulus here
		
		$display($time, "<< Finishing the Simulation >>");
	end
	
	initial begin
		$monitor($time, "  tmb_clock0 = %b", tmb_clock0);
	end
      
endmodule

