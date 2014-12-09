module otmb_testbench(
        error
    );
    output error;
    wire [23:0]cfeb0_rx;
    wire [23:0]cfeb1_rx;
    wire [23:0]cfeb2_rx;
    wire [23:0]cfeb3_rx;
    wire [23:0]cfeb4_rx;
    wire [4:0]cfeb_clock_en;
    wire cfeb_oe;
    wire [28:1]alct_rx;
    wire [17:5]alct_txa;
    wire [23:19]alct_txb;
    wire alct_clock_en;
    wire alct_rxoe;
    wire alct_txoe;
    wire alct_loop;
    wire [5:0]dmb_rx = { 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 };
    wire [48:0]dmb_tx;
    wire dmb_loop;
    wire p_dmb_oe;
    wire [31:0]p_mpc_tx;
    wire [37:0]rpc_rx;
    wire rpc_smbrx;
    wire rpc_dsn;
    wire rpc_loop;
    wire [3:0]rpc_tx;
    wire [50:0]p_ccb_rx = { 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1 };
    wire [26:0]p_ccb_tx = { 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1 };
    wire ccb_status_oe;
    wire p_hard_reset_alct_fpga;
    wire p_hard_reset_tmb_fpga;
    wire gtl_loop;
    wire [15:0]vme_d;
    wire [23:1]vme_a;
    wire [5:0]vme_am;
    wire [10:0]p_vme_cmd;
    wire [6:0]p_vme_geo;
    wire [6:0]vme_reply;
    wire [3:1]jtag_usr;
    wire jtag_usr0_tdo;
    wire [3:0]sel_usr;
    wire [7:0]prom_led;
    wire [5:0]prom_ctrl;
    wire tmb_clock0 = 1'b0;
    wire tmb_clock1 = 1'b0;
    wire alct_rxclock = 1'b0;
    wire alct_rxclockd = 1'b0;
    wire mpc_clock = 1'b0;
    wire dcc_clock = 1'b0;
    wire [4:0]step;
    wire ddd_clock;
    wire ddd_adr_latch;
    wire ddd_serial_in;
    wire ddd_serial_out;
    wire mez_done;
    wire [3:0]vstat;
    wire p_t_crit;
    wire tmb_sn;
    wire smb_data;
    wire mez_sn;
    wire [2:0]adc_io;
    wire adc_io3_dout;
    wire smb_clk;
    wire mez_busy;
    wire [7:0]led_fp;
    wire gp_io0;
    wire gp_io1;
    wire gp_io2;
    wire gp_io3;
    wire gp_io4;
    wire gp_io5;
    wire gp_io6;
    wire gp_io7;
    wire meztp20;
    wire meztp21;
    wire meztp22;
    wire meztp23;
    wire meztp24;
    wire meztp25;
    wire meztp26;
    wire meztp27;
    wire [8:7]set_sw;
    wire [9:1]testled;
    wire reset;
    wire clk40p = 1'b0;
    wire clk40n = 1'b1;
    wire clk160p = 1'b0;
    wire clk160n = 1'b1;
    wire qpll_lock;
    wire qpll_err;
    wire qpll_nrst;
    wire clk125p = 1'b0;
    wire clk125n = 1'b1;
    wire t12_sclk;
    wire t12_sdat;
    wire t12_nfault;
    wire t12_rst;
    wire r12_sclk;
    wire r12_sdat;
    wire r12_fok;
    wire [6:0]rxp;
    wire [6:0]rxn;
    wire f_sclk = 1'b0;
    wire f_sdat;
    wire f_fok;
    wire fcs;
    wire clk = 1'b0;
    wire rst = 1'b0;
    wire rstn = 1'b1;
    wire go = 1'b0;
    wire [31:0]vme_cmd_reg;
    wire [31:0]vme_dat_reg_in;
    wire [31:0]vme_dat_reg_out;
    wire [9:0]vme_mem_addr;
    wire vme_mem_rden;
    wire [31:0]vme_cmd_mem_out;
    wire [31:0]vme_dat_mem_out;
    wire vme_dat_mem_wren;
    wire [31:0]vme_dat_mem_in;
    wire vme_cmd;
    wire vme_cmd_rd;
    wire [23:1]vme_addr;
    wire vme_wr;
    wire [15:0]vme_wr_data;
    wire vme_rd;
    wire [15:0]vme_rd_data;
    wire [15:0]vme_data;
    wire start;
    wire start_res;
    wire stop;
    wire stop_res;
    wire mode = 1'b1;
    wire [9:0]cmd_n = 10'b0000000000;
    wire busy;
    wire as;
    wire [1:0]ds;
    wire lword;
    wire write_b;
    wire iack;
    wire sysfail;
    wire [5:0]am;
    wire [5:0]ga;
    wire [23:1]adr;
    wire oe_b;
    wire dtack;
    wire [15:0]indata;
    wire [15:0]outdata;
    wire berr;
    otmb_virtex6 otmb_virtex6_top (
            .\_ccb_rx\(p_ccb_rx),
            .\_t_crit\(p_t_crit),
            .\_vme_cmd\(p_vme_cmd),
            .\_vme_geo\(p_vme_geo),
            .adc_io3_dout(adc_io3_dout),
            .alct_rx(alct_rx),
            .alct_rxclock(alct_rxclock),
            .alct_rxclockd(alct_rxclockd),
            .cfeb0_rx(cfeb0_rx),
            .cfeb1_rx(cfeb1_rx),
            .cfeb2_rx(cfeb2_rx),
            .cfeb3_rx(cfeb3_rx),
            .cfeb4_rx(cfeb4_rx),
            .clk125n(clk125n),
            .clk125p(clk125p),
            .clk160n(clk160n),
            .clk160p(clk160p),
            .clk40n(clk40n),
            .clk40p(clk40p),
            .dcc_clock(dcc_clock),
            .ddd_serial_out(ddd_serial_out),
            .dmb_rx(dmb_rx),
            .f_fok(f_fok),
            .f_sclk(f_sclk),
            .f_sdat(f_sdat),
            .gp_io4(gp_io4),
            .jtag_usr0_tdo(jtag_usr0_tdo),
            .mez_done(mez_done),
            .mpc_clock(mpc_clock),
            .qpll_err(qpll_err),
            .qpll_lock(qpll_lock),
            .r12_fok(r12_fok),
            .r12_sdat(r12_sdat),
            .reset(reset),
            .rpc_dsn(rpc_dsn),
            .rpc_rx(rpc_rx),
            .rpc_smbrx(rpc_smbrx),
            .rxn(rxn),
            .rxp(rxp),
            .set_sw(set_sw),
            .t12_nfault(t12_nfault),
            .t12_rst(t12_rst),
            .t12_sdat(t12_sdat),
            .testled(testled),
            .tmb_clock0(tmb_clock0),
            .tmb_clock1(tmb_clock1),
            .vme_a(adr),
            .vme_am(am),
            .vstat(vstat),
            .\_ccb_tx\(p_ccb_tx),
            .\_dmb_oe\(p_dmb_oe),
            .\_hard_reset_alct_fpga\(p_hard_reset_alct_fpga),
            .\_hard_reset_tmb_fpga\(p_hard_reset_tmb_fpga),
            .\_mpc_tx\(p_mpc_tx),
            .adc_io(adc_io),
            .alct_clock_en(alct_clock_en),
            .alct_loop(alct_loop),
            .alct_rxoe(alct_rxoe),
            .alct_txa(alct_txa),
            .alct_txb(alct_txb),
            .alct_txoe(alct_txoe),
            .ccb_status_oe(ccb_status_oe),
            .cfeb_clock_en(cfeb_clock_en),
            .cfeb_oe(cfeb_oe),
            .ddd_adr_latch(ddd_adr_latch),
            .ddd_clock(ddd_clock),
            .ddd_serial_in(ddd_serial_in),
            .dmb_loop(dmb_loop),
            .dmb_tx(dmb_tx),
            .fcs(fcs),
            .gp_io5(gp_io5),
            .gp_io6(gp_io6),
            .gp_io7(gp_io7),
            .gtl_loop(gtl_loop),
            .led_fp(led_fp),
            .mez_busy(mez_busy),
            .meztp20(meztp20),
            .meztp21(meztp21),
            .meztp22(meztp22),
            .meztp23(meztp23),
            .meztp24(meztp24),
            .meztp25(meztp25),
            .meztp26(meztp26),
            .meztp27(meztp27),
            .prom_ctrl(prom_ctrl),
            .qpll_nrst(qpll_nrst),
            .r12_sclk(r12_sclk),
            .rpc_loop(rpc_loop),
            .rpc_tx(rpc_tx),
            .smb_clk(smb_clk),
            .step(step),
            .t12_sclk(t12_sclk),
            .vme_reply(vme_reply),
            .gp_io0(gp_io0),
            .gp_io1(gp_io1),
            .gp_io2(gp_io2),
            .gp_io3(gp_io3),
            .jtag_usr(jtag_usr),
            .mez_sn(mez_sn),
            .prom_led(prom_led),
            .sel_usr(sel_usr),
            .smb_data(smb_data),
            .tmb_sn(tmb_sn),
            .vme_d(vme_data)
        );
    vme_master vme_master_pm (
            .clk(clk),
            .data_in(outdata),
            .dtack(dtack),
            .rstn(rstn),
            .sw_reset(rst),
            .vme_cmd_rd(vme_cmd_rd),
            .vme_rd_data(vme_rd_data),
            .addr(adr),
            .am(am),
            .as(as),
            .berr(berr),
            .data_out(indata),
            .ds0(ds[0]),
            .ds1(ds[1]),
            .ga(ga),
            .iack(iack),
            .lword(lword),
            .oe_b(oe_b),
            .sysfail(sysfail),
            .vme_addr(vme_addr),
            .vme_cmd(vme_cmd),
            .vme_rd(vme_rd),
            .vme_wr(vme_cmd),
            .vme_wr_data(vme_wr_data),
            .write_b(write_b)
        );
    file_handler file_handler_pm (
            .clk(clk),
            .start(start),
            .vme_cmd_rd(vme_mem_rden),
            .vme_cmd_reg(vme_cmd_reg),
            .vme_dat_reg_in(vme_dat_reg_in),
            .vme_dat_wr(vme_dat_mem_wren),
            .vme_dat_reg_out(vme_dat_mem_in)
        );
    test_controller test_controller_pm (
            .clk(clk),
            .cmd_n(cmd_n),
            .mode(mode),
            .rstn(rstn),
            .start(start),
            .stop(stop),
            .sw_reset(rst),
            .tc_enable(go),
            .vme_cmd_mem_out(vme_cmd_mem_out),
            .vme_cmd_rd(vme_cmd_rd),
            .vme_cmd_reg(vme_cmd_reg),
            .vme_dat_mem_out(vme_dat_mem_out),
            .vme_dat_reg_in(vme_dat_reg_in),
            .vme_rd_data(vme_rd_data),
            .busy(busy),
            .start_res(start_res),
            .stop_res(stop_res),
            .vme_addr(vme_addr),
            .vme_cmd(vme_cmd),
            .vme_dat_mem_in(vme_dat_mem_in),
            .vme_dat_mem_wren(vme_dat_mem_wren),
            .vme_dat_reg_out(vme_dat_reg_out),
            .vme_mem_addr(vme_mem_addr),
            .vme_mem_rden(vme_mem_rden),
            .vme_rd(vme_rd),
            .vme_wr(vme_wr),
            .vme_wr_data(vme_wr_data)
        );
    assign vme_cmd_mem_out = vme_cmd_reg;
    assign vme_dat_mem_out = vme_dat_reg_in;
    assign error = 1'b0;
    assign rst = 1'b0;
    assign rstn =  ~( rst);
    assign tmb_clock0 =  ~( tmb_clock0);
    assign tmb_clock1 =  ~( tmb_clock1);
    assign alct_rxclock =  ~( alct_rxclock);
    assign alct_rxclockd =  ~( alct_rxclockd);
    assign mpc_clock =  ~( mpc_clock);
    assign dcc_clock =  ~( dcc_clock);
    assign clk40p =  ~( clk40p);
    assign clk40n =  ~( clk40n);
    assign clk160p =  ~( clk160p);
    assign clk160n =  ~( clk160n);
    assign clk125p =  ~( clk125p);
    assign clk125n =  ~( clk125n);
    assign f_sclk =  ~( f_sclk);
    assign clk =  ~( clk);
    assign go = 1'b1;
    assign p_vme_cmd[10:0] = { 1'b1, lword };
    assign p_vme_geo[6:0] = { 1'b1, ga };
    assign dtack = vme_reply[2];
    assign berr = vme_reply[4];
    iobuf vme_d00_buf (
            .i(indata[0]),
            .io(vme_data[0]),
            .o(outdata[0]),
            .t(oe_b)
        );
    iobuf vme_d01_buf (
            .i(indata[1]),
            .io(vme_data[1]),
            .o(outdata[1]),
            .t(oe_b)
        );
    iobuf vme_d02_buf (
            .i(indata[2]),
            .io(vme_data[2]),
            .o(outdata[2]),
            .t(oe_b)
        );
    iobuf vme_d03_buf (
            .i(indata[3]),
            .io(vme_data[3]),
            .o(outdata[3]),
            .t(oe_b)
        );
    iobuf vme_d04_buf (
            .i(indata[4]),
            .io(vme_data[4]),
            .o(outdata[4]),
            .t(oe_b)
        );
    iobuf vme_d05_buf (
            .i(indata[5]),
            .io(vme_data[5]),
            .o(outdata[5]),
            .t(oe_b)
        );
    iobuf vme_d06_buf (
            .i(indata[6]),
            .io(vme_data[6]),
            .o(outdata[6]),
            .t(oe_b)
        );
    iobuf vme_d07_buf (
            .i(indata[7]),
            .io(vme_data[7]),
            .o(outdata[7]),
            .t(oe_b)
        );
    iobuf vme_d08_buf (
            .i(indata[8]),
            .io(vme_data[8]),
            .o(outdata[8]),
            .t(oe_b)
        );
    iobuf vme_d09_buf (
            .i(indata[9]),
            .io(vme_data[9]),
            .o(outdata[9]),
            .t(oe_b)
        );
    iobuf vme_d10_buf (
            .i(indata[10]),
            .io(vme_data[10]),
            .o(outdata[10]),
            .t(oe_b)
        );
    iobuf vme_d11_buf (
            .i(indata[11]),
            .io(vme_data[11]),
            .o(outdata[11]),
            .t(oe_b)
        );
    iobuf vme_d12_buf (
            .i(indata[12]),
            .io(vme_data[12]),
            .o(outdata[12]),
            .t(oe_b)
        );
    iobuf vme_d13_buf (
            .i(indata[13]),
            .io(vme_data[13]),
            .o(outdata[13]),
            .t(oe_b)
        );
    iobuf vme_d14_buf (
            .i(indata[14]),
            .io(vme_data[14]),
            .o(outdata[14]),
            .t(oe_b)
        );
    iobuf vme_d15_buf (
            .i(indata[15]),
            .io(vme_data[15]),
            .o(outdata[15]),
            .t(oe_b)
        );
endmodule 
