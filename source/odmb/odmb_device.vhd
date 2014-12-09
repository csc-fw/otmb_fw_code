-- ODMB_DEVICE: If ODMB mode is selected, this module generates the DMB_TX signals and
-- provides other ODMB functionalities.

library ieee;
library unisim;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use unisim.vcomponents.all;

entity odmb_device is
  port (
    clock        : in std_logic;
    clock_vme    : in std_logic;
    global_reset : in std_logic;
    ccb_l1accept : in std_logic;
    ccb_evcntres : in std_logic;

    vme_address : in std_logic_vector(23 downto 1);
    vme_data    : in std_logic_vector(15 downto 0);
    is_read     : in std_logic;
    bd_sel      : in std_logic;

    dmb_rx : in std_logic_vector(5 downto 0);

    dmb_tx_odmb : out std_logic_vector(48 downto 0);
    odmb_sel    : out std_logic;
    odmb_data   : out std_logic_vector(15 downto 0)
    );
  attribute IOB                : string;
  attribute IOB of dmb_tx_odmb : signal is "True";
end odmb_device;

architecture odmb_device_arch of odmb_device is

  component alct_otmb_data_gen is
    port(
      clk            : in std_logic;
      rst            : in std_logic;
      l1a            : in std_logic;
      alct_l1a_match : in std_logic;
      otmb_l1a_match : in std_logic;
      nwords_dummy   : in std_logic_vector(15 downto 0);

      alct_dv   : out std_logic;
      alct_data : out std_logic_vector(15 downto 0);
      otmb_dv   : out std_logic;
      otmb_data : out std_logic_vector(15 downto 0));
  end component;

  component EOFGEN is
    port(
      clk : in std_logic;
      rst : in std_logic;

      dv_in   : in std_logic;
      data_in : in std_logic_vector(15 downto 0);

      dv_out   : out std_logic;
      data_out : out std_logic_vector(17 downto 0)
      );
  end component;

  component PULSE_EDGE is
    port (
      DOUT   : out std_logic;
      PULSE1 : out std_logic;
      CLK    : in  std_logic;
      RST    : in  std_logic;
      NPULSE : in  integer;
      DIN    : in  std_logic
      );
  end component;

  signal otmb_data, alct_data         : std_logic_vector(15 downto 0);
  signal eof_otmb_data, eof_alct_data : std_logic_vector(17 downto 0) := (others => '1');

  signal dmb_tx_reserved    : std_logic_vector(2 downto 0) := "101";
  signal otmb_dav, alct_dav : std_logic;

  signal otmb_data_valid, alct_data_valid             : std_logic;
  signal eof_otmb_data_valid, eof_alct_data_valid     : std_logic;
  signal eof_otmb_data_valid_b, eof_alct_data_valid_b : std_logic;

  signal lct : std_logic_vector(7 downto 0) := (others => '1');

  signal cmddev : unsigned(16 downto 0);

  signal odmb_sel_inner         : std_logic;
  signal w_odmb_sel, r_odmb_sel : std_logic;
  signal out_odmb_sel           : std_logic_vector(15 downto 0) := (others => '0');
  signal dmb_tx_odmb_inner           : std_logic_vector(48 downto 0) := (others => '0');

  signal w_data_rqst     : std_logic;
  signal pulse_data_rqst : std_logic;

  signal l1a       : std_logic;
  signal l1a_match : std_logic_vector(9 downto 8);

  constant nwords_dummy_def                                 : std_logic_vector(15 downto 0) := x"0008";
  signal   nwords_dummy, nwords_dummy_rst, nwords_dummy_pre : std_logic_vector(15 downto 0);
  signal   w_nwords_dummy, r_nwords_dummy                   : std_logic;

  constant logich   : std_logic                    := '1';
  constant otmb_dly : std_logic_vector(4 downto 0) := "00100";
  constant alct_dly : std_logic_vector(4 downto 0) := "01000";
begin

  -- General VME commands
  cmddev         <= unsigned(bd_sel & vme_address(15 downto 1) & "0");
  w_odmb_sel     <= '1' when (cmddev = x"101EE" and is_read = '0') else '0';
  r_odmb_sel     <= '1' when (cmddev = x"101EE" and is_read = '1') else '0';
  w_data_rqst    <= '1' when (cmddev = x"111EE" and is_read = '0') else '0';
  w_nwords_dummy <= '1' when (cmddev = x"121EE" and is_read = '0') else '0';
  r_nwords_dummy <= '1' when (cmddev = x"121EE" and is_read = '1') else '0';

  odmb_data <= out_odmb_sel when r_odmb_sel = '1' else
               nwords_dummy when r_nwords_dummy = '1' else
               x"DBDB";

  -- ODMB_SEL
  FD_ODMB_SEL : FDC port map(odmb_sel_inner, w_odmb_sel, global_reset, vme_data(0));
  out_odmb_sel(15 downto 1) <= (others => '0');
  out_odmb_sel(0)           <= odmb_sel_inner;
  odmb_sel                  <= odmb_sel_inner;

  -- NWORDS_DUMMY
  GEN_NWORDS_DUMMY : for I in 15 downto 0 generate
  begin
    nwords_dummy_pre(I) <= global_reset when nwords_dummy_def(I) = '1' else '0';
    nwords_dummy_rst(I) <= global_reset when nwords_dummy_def(I) = '0' else '0';
    FD_W_NWORDS_DUMMY : FDCP port map(nwords_dummy(I), w_nwords_dummy,
                                      nwords_dummy_rst(I), vme_data(I), nwords_dummy_pre(I));
  end generate GEN_NWORDS_DUMMY;

  -- Data generation
  PULSE_DATARQST : PULSE_EDGE port map(pulse_data_rqst, open, clock, global_reset, 1, w_data_rqst);
  l1a          <= dmb_rx(3) or pulse_data_rqst;
  l1a_match(8) <= dmb_rx(4) or pulse_data_rqst;
  l1a_match(9) <= dmb_rx(5) or pulse_data_rqst;

  SRL32_OTMBDAV : SRLC32E port map(otmb_dav, open, otmb_dly, logich, clock, l1a_match(8));
  SRL32_ALCTDAV : SRLC32E port map(alct_dav, open, alct_dly, logich, clock, l1a_match(9));

  dmb_tx_odmb_inner <= dmb_tx_reserved & lct(7 downto 6) & alct_dav & eof_alct_data(16 downto 15) &
                 eof_alct_data_valid_b & lct(5 downto 0) & eof_otmb_data_valid_b & otmb_dav &
                 eof_otmb_data(16 downto 15) & eof_alct_data(14 downto 0) &
                 eof_otmb_data(14 downto 0);

  GEN_DMB_TX : for I in 48 downto 0 generate
    FDDMBTX : FD port map(dmb_tx_odmb(I), clock, dmb_tx_odmb_inner(I));
  end generate GEN_DMB_TX;
  
  eof_otmb_data_valid_b <= not eof_otmb_data_valid;
  eof_alct_data_valid_b <= not eof_alct_data_valid;


  ALCT_OTMB_DATA_GEN_PM : alct_otmb_data_gen
    port map(
      clk            => clock,
      rst            => global_reset,
      l1a            => l1a,
      alct_l1a_match => l1a_match(9),
      otmb_l1a_match => l1a_match(8),
      nwords_dummy   => nwords_dummy,

      alct_dv   => alct_data_valid,
      alct_data => alct_data,
      otmb_dv   => otmb_data_valid,
      otmb_data => otmb_data
      );

  ALCT_EOFGEN_PM : EOFGEN
    port map (
      clk => clock,
      rst => global_reset,

      dv_in   => alct_data_valid,
      data_in => alct_data,

      dv_out   => eof_alct_data_valid,
      data_out => eof_alct_data
      );

  OTMB_EOFGEN_PM : EOFGEN
    port map (
      clk => clock,
      rst => global_reset,

      dv_in   => otmb_data_valid,
      data_in => otmb_data,

      dv_out   => eof_otmb_data_valid,
      data_out => eof_otmb_data
      );


end odmb_device_arch;
