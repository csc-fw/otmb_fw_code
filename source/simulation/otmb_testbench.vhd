-- OTMB_TESTBENCH: Test bench for the OTMB firmware

library ieee;
library unisim;
use ieee.std_logic_1164.all;
use unisim.vcomponents.all;

entity OTMB_TESTBENCH is
  port (
    error : out std_logic);
end OTMB_TESTBENCH;


architecture OTMB_TESTBENCH_arch of OTMB_TESTBENCH is

  component otmb_virtex6 is
    port (
      -- CFEB
      cfeb0_rx      : in  std_logic_vector(23 downto 0);
      cfeb1_rx      : in  std_logic_vector(23 downto 0);
      cfeb2_rx      : in  std_logic_vector(23 downto 0);
      cfeb3_rx      : in  std_logic_vector(23 downto 0);
      cfeb4_rx      : in  std_logic_vector(23 downto 0);
      cfeb_clock_en : out std_logic_vector(4 downto 0);
      cfeb_oe       : out std_logic;

      -- ALCT
      alct_rx       : in  std_logic_vector(28 downto 1);
      alct_txa      : out std_logic_vector(17 downto 5);  -- alct_tx[18] no pin
      alct_txb      : out std_logic_vector(23 downto 19);
      alct_clock_en : out std_logic;
      alct_rxoe     : out std_logic;
      alct_txoe     : out std_logic;
      alct_loop     : out std_logic;

      -- DMB
      dmb_rx    : in  std_logic_vector(5 downto 0);
      dmb_tx    : out std_logic_vector(48 downto 0);
      dmb_loop  : out std_logic;
      \_dmb_oe\ : out std_logic;

      -- MPC
      \_mpc_tx\ : out std_logic_vector(31 downto 0);

      -- RPC
      rpc_rx    : in  std_logic_vector(37 downto 0);
      rpc_smbrx : in  std_logic;        -- was rpc_rxalt[0]
      rpc_dsn   : in  std_logic;        -- was rpc_rxalt[1]
      rpc_loop  : out std_logic;
      rpc_tx    : out std_logic_vector(3 downto 0);

      -- CCB
      \_ccb_rx\               : in  std_logic_vector(50 downto 0);
      \_ccb_tx\               : out std_logic_vector(26 downto 0);
      ccb_status_oe           : out std_logic;
      \_hard_reset_alct_fpga\ : out std_logic;
      \_hard_reset_tmb_fpga\  : out std_logic;
      gtl_loop                : out std_logic;

      -- VME
      vme_d      : inout std_logic_vector(15 downto 0);
      vme_a      : in    std_logic_vector(23 downto 1);
      vme_am     : in    std_logic_vector(5 downto 0);
      \_vme_cmd\ : in    std_logic_vector(10 downto 0);
      \_vme_geo\ : in    std_logic_vector(6 downto 0);
      vme_reply  : out   std_logic_vector(6 downto 0);

      -- JTAG
      jtag_usr      : inout std_logic_vector(3 downto 1);
      jtag_usr0_tdo : in    std_logic;
      sel_usr       : inout std_logic_vector(3 downto 0);

      -- PROM
      prom_led  : inout std_logic_vector(7 downto 0);
      prom_ctrl : out   std_logic_vector(5 downto 0);

      -- Clock
      tmb_clock0    : in  std_logic;
      tmb_clock1    : in  std_logic;
      alct_rxclock  : in  std_logic;
      alct_rxclockd : in  std_logic;
      mpc_clock     : in  std_logic;
      dcc_clock     : in  std_logic;
      step          : out std_logic_vector(4 downto 0);

      -- 3D3444
      ddd_clock      : out std_logic;
      ddd_adr_latch  : out std_logic;
      ddd_serial_in  : out std_logic;
      ddd_serial_out : in  std_logic;

      -- Status
      mez_done     : in    std_logic;
      vstat        : in    std_logic_vector(3 downto 0);
      \_t_crit\    : in    std_logic;
      tmb_sn       : inout std_logic;
      smb_data     : inout std_logic;
      mez_sn       : inout std_logic;
      adc_io       : out   std_logic_vector(2 downto 0);
      adc_io3_dout : in    std_logic;
      smb_clk      : out   std_logic;
      mez_busy     : out   std_logic;
      led_fp       : out   std_logic_vector(7 downto 0);

      -- General Purpose I/Os
      gp_io0 : inout std_logic;  -- jtag_fgpa0 tdo (out) shunted to gp_io1, usually
      gp_io1 : inout std_logic;         -- jtag_fpga1 tdi (in)
      gp_io2 : inout std_logic;         -- jtag_fpga2 tms
      gp_io3 : inout std_logic;         -- jtag_fpga3 tck
      gp_io4 : in    std_logic;         -- rpc_done
      gp_io5 : out   std_logic;  -- _init on mezzanine card, use only as an FPGA output
      gp_io6 : out   std_logic;  -- _write on mezzanine card, use only as an FPGA output
      gp_io7 : out   std_logic;  -- _cs on mezzanine card, use only as an FPGA output-- General Purpose I/Os

      -- Mezzanine Test Points
      meztp20 : out std_logic;
      meztp21 : out std_logic;
      meztp22 : out std_logic;
      meztp23 : out std_logic;
      meztp24 : out std_logic;
      meztp25 : out std_logic;
      meztp26 : out std_logic;
      meztp27 : out std_logic;

      -- Switches & LEDS
      set_sw  : in std_logic_vector(8 downto 7);
      testled : in std_logic_vector(9 downto 1);
      reset   : in std_logic;

      -- CERN QPLL
      clk40p : in std_logic;            -- 40 MHz from QPLL
      clk40n : in std_logic;            -- 40 MHz from QPLL

      clk160p : in std_logic;  -- 160 MHz from QPLL for GTX reference clock
      clk160n : in std_logic;  -- 160 MHz from QPLL for GTX reference clock

      qpll_lock : in  std_logic;        -- QPLL locked
      qpll_err  : in  std_logic;        -- QPLL error, replaces _gtl_oe
      qpll_nrst : out std_logic;        -- QPLL reset, low = reset, drive high

      -- CCLD-033 Crystal
      clk125p : in std_logic;  -- Transmitter clock, not in final design
      clk125n : in std_logic;

      -- SNAP12 transmitter serial interface, not in final design
      t12_sclk   : out std_logic;
      t12_sdat   : in  std_logic;
      t12_nfault : in  std_logic;
      t12_rst    : in  std_logic;

      -- SNAP12 receiver serial interface
      r12_sclk : out std_logic;         -- Serial interface clock, drive high
      r12_sdat : in  std_logic;         -- Serial interface data
      r12_fok  : in  std_logic;         -- Serial interface status

      -- SNAP12 receivers
      rxp : in std_logic_vector(6 downto 0);  -- SNAP12+ fiber comparator inputs for GTX
      rxn : in std_logic_vector(6 downto 0);  -- SNAP12- fiber comparator inputs for GTX

      -- Finisar
      f_sclk : in std_logic;
      f_sdat : in std_logic;
      f_fok  : in std_logic;

      -- PROM
      fcs : out std_logic


      );
  end component;

  component vme_master is
    
    port (
      clk      : in std_logic;
      rstn     : in std_logic;
      sw_reset : in std_logic;

      vme_cmd    : in  std_logic;
      vme_cmd_rd : out std_logic;

      vme_addr    : in  std_logic_vector(23 downto 1);
      vme_wr      : in  std_logic;
      vme_wr_data : in  std_logic_vector(15 downto 0);
      vme_rd      : in  std_logic;
      vme_rd_data : out std_logic_vector(15 downto 0);

      ga   : out std_logic_vector(5 downto 0);
      addr : out std_logic_vector(23 downto 1);
      am   : out std_logic_vector(5 downto 0);

      as      : out std_logic;
      ds0     : out std_logic;
      ds1     : out std_logic;
      lword   : out std_logic;
      write_b : out std_logic;
      iack    : out std_logic;
      berr    : out std_logic;
      sysfail : out std_logic;
      dtack   : in  std_logic;

      data_in  : in  std_logic_vector(15 downto 0);
      data_out : out std_logic_vector(15 downto 0);
      oe_b     : out std_logic

      );

  end component;

  component file_handler is
    port (
      clk             : in  std_logic;
      start           : out std_logic;
      vme_cmd_reg     : out std_logic_vector(31 downto 0);
      vme_dat_reg_in  : out std_logic_vector(31 downto 0);
      vme_dat_reg_out : in  std_logic_vector(31 downto 0);
      vme_cmd_rd      : in  std_logic;
      vme_dat_wr      : in  std_logic
      );

  end component;

  component test_controller is

    port(

      clk       : in std_logic;
      rstn      : in std_logic;
      sw_reset  : in std_logic;
      tc_enable : in std_logic;

-- From/To SLV_MGT Module

      start     : in  std_logic;
      start_res : out std_logic;
      stop      : in  std_logic;
      stop_res  : out std_logic;
      mode      : in  std_logic;
      cmd_n     : in  std_logic_vector(9 downto 0);
      busy      : out std_logic;

      vme_cmd_reg     : in  std_logic_vector(31 downto 0);
      vme_dat_reg_in  : in  std_logic_vector(31 downto 0);
      vme_dat_reg_out : out std_logic_vector(31 downto 0);

-- To/From VME Master FSM

      vme_cmd    : out std_logic;
      vme_cmd_rd : in  std_logic;

      vme_addr    : out std_logic_vector(23 downto 1);
      vme_wr      : out std_logic;
      vme_wr_data : out std_logic_vector(15 downto 0);
      vme_rd      : out std_logic;
      vme_rd_data : in  std_logic_vector(15 downto 0);

-- From/To VME_CMD Memory and VME_DAT Memory

      vme_mem_addr     : out std_logic_vector(9 downto 0);
      vme_mem_rden     : out std_logic;
      vme_cmd_mem_out  : in  std_logic_vector(31 downto 0);
      vme_dat_mem_out  : in  std_logic_vector(31 downto 0);
      vme_dat_mem_wren : out std_logic;
      vme_dat_mem_in   : out std_logic_vector(31 downto 0)

      );

  end component;

  signal cfeb0_rx               : std_logic_vector(23 downto 0);
  signal cfeb1_rx               : std_logic_vector(23 downto 0);
  signal cfeb2_rx               : std_logic_vector(23 downto 0);
  signal cfeb3_rx               : std_logic_vector(23 downto 0);
  signal cfeb4_rx               : std_logic_vector(23 downto 0);
  signal cfeb_clock_en          : std_logic_vector(4 downto 0);
  signal cfeb_oe                : std_logic;
  signal alct_rx                : std_logic_vector(28 downto 1);
  signal alct_txa               : std_logic_vector(17 downto 5);
  signal alct_txb               : std_logic_vector(23 downto 19);
  signal alct_clock_en          : std_logic;
  signal alct_rxoe              : std_logic;
  signal alct_txoe              : std_logic;
  signal alct_loop              : std_logic;
  signal dmb_rx                 : std_logic_vector(5 downto 0) := (others => '0');
  signal dmb_tx                 : std_logic_vector(48 downto 0);
  signal dmb_loop               : std_logic;
  signal p_dmb_oe               : std_logic;
  signal p_mpc_tx               : std_logic_vector(31 downto 0);
  signal rpc_rx                 : std_logic_vector(37 downto 0);
  signal rpc_smbrx              : std_logic;
  signal rpc_dsn                : std_logic;
  signal rpc_loop               : std_logic;
  signal rpc_tx                 : std_logic_vector(3 downto 0);
  signal p_ccb_rx               : std_logic_vector(50 downto 0) := (others => '1');
  signal p_ccb_tx               : std_logic_vector(26 downto 0) := (others => '1');
  signal ccb_status_oe          : std_logic;
  signal p_hard_reset_alct_fpga : std_logic;
  signal p_hard_reset_tmb_fpga  : std_logic;
  signal gtl_loop               : std_logic;
  signal vme_d                  : std_logic_vector(15 downto 0);
  signal vme_a                  : std_logic_vector(23 downto 1);
  signal vme_am                 : std_logic_vector(5 downto 0);
  signal p_vme_cmd              : std_logic_vector(10 downto 0);
  signal p_vme_geo              : std_logic_vector(6 downto 0);
  signal vme_reply              : std_logic_vector(6 downto 0);
  signal jtag_usr               : std_logic_vector(3 downto 1);
  signal jtag_usr0_tdo          : std_logic;
  signal sel_usr                : std_logic_vector(3 downto 0);
  signal prom_led               : std_logic_vector(7 downto 0);
  signal prom_ctrl              : std_logic_vector(5 downto 0);
  signal tmb_clock0             : std_logic := '0';
  signal tmb_clock1             : std_logic := '0';
  signal alct_rxclock           : std_logic := '0';
  signal alct_rxclockd          : std_logic := '0';
  signal mpc_clock              : std_logic := '0';
  signal dcc_clock              : std_logic := '0';
  signal step                   : std_logic_vector(4 downto 0);
  signal ddd_clock              : std_logic;
  signal ddd_adr_latch          : std_logic;
  signal ddd_serial_in          : std_logic;
  signal ddd_serial_out         : std_logic;
  signal mez_done               : std_logic;
  signal vstat                  : std_logic_vector(3 downto 0);
  signal p_t_crit               : std_logic;
  signal tmb_sn                 : std_logic;
  signal smb_data               : std_logic;
  signal mez_sn                 : std_logic;
  signal adc_io                 : std_logic_vector(2 downto 0);
  signal adc_io3_dout           : std_logic;
  signal smb_clk                : std_logic;
  signal mez_busy               : std_logic;
  signal led_fp                 : std_logic_vector(7 downto 0);
  signal gp_io0                 : std_logic;
  signal gp_io1                 : std_logic;
  signal gp_io2                 : std_logic;
  signal gp_io3                 : std_logic;
  signal gp_io4                 : std_logic;
  signal gp_io5                 : std_logic;
  signal gp_io6                 : std_logic;
  signal gp_io7                 : std_logic;
  signal meztp20                : std_logic;
  signal meztp21                : std_logic;
  signal meztp22                : std_logic;
  signal meztp23                : std_logic;
  signal meztp24                : std_logic;
  signal meztp25                : std_logic;
  signal meztp26                : std_logic;
  signal meztp27                : std_logic;
  signal set_sw                 : std_logic_vector(8 downto 7);
  signal testled                : std_logic_vector(9 downto 1);
  signal reset                  : std_logic;
  signal clk40p                 : std_logic := '0';
  signal clk40n                 : std_logic := '1';
  signal clk160p                : std_logic := '0';
  signal clk160n                : std_logic := '1';
  signal qpll_lock              : std_logic;
  signal qpll_err               : std_logic;
  signal qpll_nrst              : std_logic;
  signal clk125p                : std_logic := '0';
  signal clk125n                : std_logic := '1';
  signal t12_sclk               : std_logic;
  signal t12_sdat               : std_logic;
  signal t12_nfault             : std_logic;
  signal t12_rst                : std_logic;
  signal r12_sclk               : std_logic;
  signal r12_sdat               : std_logic;
  signal r12_fok                : std_logic;
  signal rxp                    : std_logic_vector(6 downto 0);
  signal rxn                    : std_logic_vector(6 downto 0);
  signal f_sclk                 : std_logic := '0';
  signal f_sdat                 : std_logic;
  signal f_fok                  : std_logic;
  signal fcs                    : std_logic;

  --Signals to/from test controller
  signal clk  : std_logic := '0';
  signal rst  : std_logic := '0';
  signal rstn : std_logic := '1';
  signal go   : std_logic := '0';


  --vme_cnd AND vme_DAT MEMORY
  signal vme_cmd_reg      : std_logic_vector(31 downto 0);
  signal vme_dat_reg_in   : std_logic_vector(31 downto 0);
  signal vme_dat_reg_out  : std_logic_vector(31 downto 0);
  signal vme_mem_addr     : std_logic_vector(9 downto 0);
  signal vme_mem_rden     : std_logic;
  signal vme_cmd_mem_out  : std_logic_vector(31 downto 0);
  signal vme_dat_mem_out  : std_logic_vector(31 downto 0);
  signal vme_dat_mem_wren : std_logic;
  signal vme_dat_mem_in   : std_logic_vector(31 downto 0);

  -- signals between test_controller and vme_master_fsm and command_module
  signal vme_cmd     : std_logic;
  signal vme_cmd_rd  : std_logic;
  signal vme_addr    : std_logic_vector(23 downto 1);
  signal vme_wr      : std_logic;
  signal vme_wr_data : std_logic_vector(15 downto 0);
  signal vme_rd      : std_logic;
  signal vme_rd_data : std_logic_vector(15 downto 0);
  signal vme_data    : std_logic_vector(15 downto 0);

  signal start     : std_logic;
  signal start_res : std_logic;
  signal stop      : std_logic;
  signal stop_res  : std_logic;
  signal mode      : std_logic                    := '1';  -- read commands from file
  signal cmd_n     : std_logic_vector(9 downto 0) := "0000000000";
  signal busy      : std_logic;

  --signals between vme_master and top
  signal as      : std_logic;
  signal ds      : std_logic_vector(1 downto 0);
  signal lword   : std_logic;
  signal write_b : std_logic;
  signal iack    : std_logic;
  signal sysfail : std_logic;
  signal am      : std_logic_vector(5 downto 0);
  signal ga      : std_logic_vector(5 downto 0);
  signal adr     : std_logic_vector(23 downto 1);
  signal oe_b    : std_logic;

  --signals between vme_master_fsm and cfebjtag and lvdbmon modules
  signal dtack   : std_logic;
  signal indata  : std_logic_vector(15 downto 0);
  signal outdata : std_logic_vector(15 downto 0);

  signal berr : std_logic;

begin
  otmb_virtex6_TOP : otmb_virtex6
    port map (
      cfeb0_rx                => cfeb0_rx,
      cfeb1_rx                => cfeb1_rx,
      cfeb2_rx                => cfeb2_rx,
      cfeb3_rx                => cfeb3_rx,
      cfeb4_rx                => cfeb4_rx,
      cfeb_clock_en           => cfeb_clock_en,
      cfeb_oe                 => cfeb_oe,
      alct_rx                 => alct_rx,
      alct_txa                => alct_txa,
      alct_txb                => alct_txb,
      alct_clock_en           => alct_clock_en,
      alct_rxoe               => alct_rxoe,
      alct_txoe               => alct_txoe,
      alct_loop               => alct_loop,
      dmb_rx                  => dmb_rx,
      dmb_tx                  => dmb_tx,
      dmb_loop                => dmb_loop,
      \_dmb_oe\               => p_dmb_oe,
      \_mpc_tx\               => p_mpc_tx,
      rpc_rx                  => rpc_rx,
      rpc_smbrx               => rpc_smbrx,
      rpc_dsn                 => rpc_dsn,
      rpc_loop                => rpc_loop,
      rpc_tx                  => rpc_tx,
      \_ccb_rx\               => p_ccb_rx,
      \_ccb_tx\               => p_ccb_tx,
      ccb_status_oe           => ccb_status_oe,
      \_hard_reset_alct_fpga\ => p_hard_reset_alct_fpga,
      \_hard_reset_tmb_fpga\  => p_hard_reset_tmb_fpga,
      gtl_loop                => gtl_loop,
      vme_d                   => vme_data,
      vme_a                   => adr,
      vme_am                  => am,
      \_vme_cmd\              => p_vme_cmd,
      \_vme_geo\              => p_vme_geo,
      vme_reply               => vme_reply,
      jtag_usr                => jtag_usr,
      jtag_usr0_tdo           => jtag_usr0_tdo,
      sel_usr                 => sel_usr,
      prom_led                => prom_led,
      prom_ctrl               => prom_ctrl,
      tmb_clock0              => tmb_clock0,
      tmb_clock1              => tmb_clock1,
      alct_rxclock            => alct_rxclock,
      alct_rxclockd           => alct_rxclockd,
      mpc_clock               => mpc_clock,
      dcc_clock               => dcc_clock,
      step                    => step,
      ddd_clock               => ddd_clock,
      ddd_adr_latch           => ddd_adr_latch,
      ddd_serial_in           => ddd_serial_in,
      ddd_serial_out          => ddd_serial_out,
      mez_done                => mez_done,
      vstat                   => vstat,
      \_t_crit\               => p_t_crit,
      tmb_sn                  => tmb_sn,
      smb_data                => smb_data,
      mez_sn                  => mez_sn,
      adc_io                  => adc_io,
      adc_io3_dout            => adc_io3_dout,
      smb_clk                 => smb_clk,
      mez_busy                => mez_busy,
      led_fp                  => led_fp,
      gp_io0                  => gp_io0,
      gp_io1                  => gp_io1,
      gp_io2                  => gp_io2,
      gp_io3                  => gp_io3,
      gp_io4                  => gp_io4,
      gp_io5                  => gp_io5,
      gp_io6                  => gp_io6,
      gp_io7                  => gp_io7,
      meztp20                 => meztp20,
      meztp21                 => meztp21,
      meztp22                 => meztp22,
      meztp23                 => meztp23,
      meztp24                 => meztp24,
      meztp25                 => meztp25,
      meztp26                 => meztp26,
      meztp27                 => meztp27,
      set_sw                  => set_sw,
      testled                 => testled,
      reset                   => reset,
      clk40p                  => clk40p,
      clk40n                  => clk40n,
      clk160p                 => clk160p,
      clk160n                 => clk160n,
      qpll_lock               => qpll_lock,
      qpll_err                => qpll_err,
      qpll_nrst               => qpll_nrst,
      clk125p                 => clk125p,
      clk125n                 => clk125n,
      t12_sclk                => t12_sclk,
      t12_sdat                => t12_sdat,
      t12_nfault              => t12_nfault,
      t12_rst                 => t12_rst,
      r12_sclk                => r12_sclk,
      r12_sdat                => r12_sdat,
      r12_fok                 => r12_fok,
      rxp                     => rxp,
      rxn                     => rxn,
      f_sclk                  => f_sclk,
      f_sdat                  => f_sdat,
      f_fok                   => f_fok,
      fcs                     => fcs
      );

  vme_master_pm : vme_master
    port map (
      clk      => clk,
      rstn     => rstn,
      sw_reset => rst,

      vme_cmd     => vme_cmd,
      vme_cmd_rd  => vme_cmd_rd,
      vme_wr      => vme_cmd,
      vme_addr    => vme_addr,
      vme_wr_data => vme_wr_data,
      vme_rd      => vme_rd,
      vme_rd_data => vme_rd_data,

      ga   => ga,
      addr => adr,
      am   => am,

      as      => as,
      ds0     => ds(0),
      ds1     => ds(1),
      lword   => lword,
      write_b => write_b,
      iack    => iack,
      berr    => berr,
      sysfail => sysfail,
      dtack   => dtack,

      oe_b     => oe_b,
      data_in  => outdata,
      data_out => indata
      );

  file_handler_PM : file_handler
    port map(
      clk             => clk,
      start           => start,
      vme_cmd_reg     => vme_cmd_reg,
      vme_dat_reg_in  => vme_dat_reg_in,
      vme_dat_reg_out => vme_dat_mem_in,
      vme_cmd_rd      => vme_mem_rden,
      vme_dat_wr      => vme_dat_mem_wren
      );

  test_controller_PM : test_controller
    port map(
      clk       => clk,
      rstn      => rstn,
      sw_reset  => rst,
      tc_enable => go,

      -- From/To SLV_MGT Module
      start     => start,
      start_res => start_res,
      stop      => stop,
      stop_res  => stop_res,
      mode      => mode,
      cmd_n     => cmd_n,
      busy      => busy,

      vme_cmd_reg     => vme_cmd_reg,
      vme_dat_reg_in  => vme_dat_reg_in,
      vme_dat_reg_out => vme_dat_reg_out,

-- To/From VME Master
      vme_cmd    => vme_cmd,
      vme_cmd_rd => vme_cmd_rd,

      vme_addr    => vme_addr,
      vme_wr      => vme_wr,
      vme_wr_data => vme_wr_data,
      vme_rd      => vme_rd,
      vme_rd_data => vme_rd_data,

-- From/To VME_CMD Memory and VME_DAT Memory
      vme_mem_addr     => vme_mem_addr,
      vme_mem_rden     => vme_mem_rden,
      vme_cmd_mem_out  => vme_cmd_mem_out,
      vme_dat_mem_out  => vme_dat_mem_out,
      vme_dat_mem_wren => vme_dat_mem_wren,
      vme_dat_mem_in   => vme_dat_mem_in
      );

  vme_cmd_mem_out <= vme_cmd_reg;
  vme_dat_mem_out <= vme_dat_reg_in;

  error <= '0';

  rst  <= '0', '1' after 200 ns, '0' after 13000 ns;
  rstn <= not rst;

  tmb_clock0    <= not tmb_clock0    after 12.5 ns;
  tmb_clock1    <= not tmb_clock1    after 12.5 ns;
  alct_rxclock  <= not alct_rxclock  after 12.5 ns;
  alct_rxclockd <= not alct_rxclockd after 12.5 ns;
  mpc_clock     <= not mpc_clock     after 12.5 ns;
  dcc_clock     <= not dcc_clock     after 12.5 ns;

  clk40p  <= not clk40p  after 12.5 ns;
  clk40n  <= not clk40n  after 12.5 ns;
  clk160p <= not clk160p after 3.125 ns;
  clk160n <= not clk160n after 3.125 ns;

  clk125p <= not clk125p after 4 ns;
  clk125n <= not clk125n after 4 ns;

  f_sclk <= not f_sclk after 12.5 ns;   --?

  clk <= not clk after 12.5 ns;
  go  <= '1'     after 10 us;

  p_vme_cmd(10 downto 0) <= '1' & iack & "11" & sysfail & ds(0) & '0' & ds(1) & write_b & as & lword;
  p_vme_geo(6 downto 0) <= '1' & ga;
  dtack                  <= vme_reply(2);
  berr                   <= vme_reply(4);

  vme_d00_buf : IOBUF port map (O => outdata(0), IO => vme_data(0), I => indata(0), T => oe_b);
  vme_d01_buf : IOBUF port map (O => outdata(1), IO => vme_data(1), I => indata(1), T => oe_b);
  vme_d02_buf : IOBUF port map (O => outdata(2), IO => vme_data(2), I => indata(2), T => oe_b);
  vme_d03_buf : IOBUF port map (O => outdata(3), IO => vme_data(3), I => indata(3), T => oe_b);
  vme_d04_buf : IOBUF port map (O => outdata(4), IO => vme_data(4), I => indata(4), T => oe_b);
  vme_d05_buf : IOBUF port map (O => outdata(5), IO => vme_data(5), I => indata(5), T => oe_b);
  vme_d06_buf : IOBUF port map (O => outdata(6), IO => vme_data(6), I => indata(6), T => oe_b);
  vme_d07_buf : IOBUF port map (O => outdata(7), IO => vme_data(7), I => indata(7), T => oe_b);
  vme_d08_buf : IOBUF port map (O => outdata(8), IO => vme_data(8), I => indata(8), T => oe_b);
  vme_d09_buf : IOBUF port map (O => outdata(9), IO => vme_data(9), I => indata(9), T => oe_b);
  vme_d10_buf : IOBUF port map (O => outdata(10), IO => vme_data(10), I => indata(10), T => oe_b);
  vme_d11_buf : IOBUF port map (O => outdata(11), IO => vme_data(11), I => indata(11), T => oe_b);
  vme_d12_buf : IOBUF port map (O => outdata(12), IO => vme_data(12), I => indata(12), T => oe_b);
  vme_d13_buf : IOBUF port map (O => outdata(13), IO => vme_data(13), I => indata(13), T => oe_b);
  vme_d14_buf : IOBUF port map (O => outdata(14), IO => vme_data(14), I => indata(14), T => oe_b);
  vme_d15_buf : IOBUF port map (O => outdata(15), IO => vme_data(15), I => indata(15), T => oe_b);
end OTMB_TESTBENCH_arch;
