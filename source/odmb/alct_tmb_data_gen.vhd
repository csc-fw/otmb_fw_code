-- ALCT_OTMB_DATA_GEN: Generates packets of dummy ALCT and OTMB data

library ieee;
library unisim;
library unimacro;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;
use unisim.vcomponents.all;
use unimacro.vcomponents.all;

entity alct_otmb_data_gen is
  port(
    clk            : in  std_logic;
    rst            : in  std_logic;
    l1a            : in  std_logic;
    alct_l1a_match : in  std_logic;
    otmb_l1a_match : in  std_logic;
    nwords_dummy : in std_logic_vector(15 downto 0);

    alct_dv        : out std_logic;
    alct_data      : out std_logic_vector(15 downto 0);
    otmb_dv        : out std_logic;
    otmb_data      : out std_logic_vector(15 downto 0)
    );
end alct_otmb_data_gen;

architecture alct_otmb_data_gen_architecture of alct_otmb_data_gen is

  type state_type is (IDLE, HEADER, TX_DATA);

  signal alct_next_state, alct_current_state : state_type;
  signal otmb_next_state, otmb_current_state : state_type;

  signal   alct_dw_cnt_en, alct_dw_cnt_rst  : std_logic;
  signal   otmb_dw_cnt_en, otmb_dw_cnt_rst  : std_logic;
  signal   l1a_cnt_out                      : std_logic_vector(23 downto 0);
  signal   alct_dw_cnt_out                  : std_logic_vector(15 downto 0);
  signal   otmb_dw_cnt_out                  : std_logic_vector(15 downto 0);
  signal   alct_tx_start, otmb_tx_start     : std_logic;
  signal   alct_tx_start_d, otmb_tx_start_d : std_logic;

  signal l1a_cnt_l_fifo_in : std_logic_vector(17 downto 0);
  signal l1a_cnt_h_fifo_in : std_logic_vector(17 downto 0);

  signal alct_l1a_cnt_l_fifo_out   : std_logic_vector(17 downto 0);
  signal alct_l1a_cnt_l_fifo_wrc   : std_logic_vector(9 downto 0);
  signal alct_l1a_cnt_l_fifo_rdc   : std_logic_vector(9 downto 0);
  signal alct_l1a_cnt_l_fifo_empty : std_logic;
  signal alct_l1a_cnt_l_fifo_full  : std_logic;
  signal alct_l1a_cnt_h_fifo_out   : std_logic_vector(17 downto 0);
  signal alct_l1a_cnt_h_fifo_wrc   : std_logic_vector(9 downto 0);
  signal alct_l1a_cnt_h_fifo_rdc   : std_logic_vector(9 downto 0);
  signal alct_l1a_cnt_h_fifo_empty : std_logic;
  signal alct_l1a_cnt_h_fifo_full  : std_logic;
  signal alct_l1a_cnt_fifo_wr_en   : std_logic;
  signal alct_l1a_cnt_fifo_rd_en   : std_logic;

  signal otmb_l1a_cnt_l_fifo_out   : std_logic_vector(17 downto 0);
  signal otmb_l1a_cnt_l_fifo_wrc   : std_logic_vector(9 downto 0);
  signal otmb_l1a_cnt_l_fifo_rdc   : std_logic_vector(9 downto 0);
  signal otmb_l1a_cnt_l_fifo_empty : std_logic;
  signal otmb_l1a_cnt_l_fifo_full  : std_logic;
  signal otmb_l1a_cnt_h_fifo_out   : std_logic_vector(17 downto 0);
  signal otmb_l1a_cnt_h_fifo_wrc   : std_logic_vector(9 downto 0);
  signal otmb_l1a_cnt_h_fifo_rdc   : std_logic_vector(9 downto 0);
  signal otmb_l1a_cnt_h_fifo_empty : std_logic;
  signal otmb_l1a_cnt_h_fifo_full  : std_logic;
  signal otmb_l1a_cnt_fifo_wr_en   : std_logic;
  signal otmb_l1a_cnt_fifo_rd_en   : std_logic;

begin

  -- L1A counter
  l1a_cnt : process (clk, l1a, rst)
    variable l1a_cnt_data : std_logic_vector(23 downto 0);
  begin
    if (rst = '1') then
      l1a_cnt_data := (others => '0');
    elsif (rising_edge(clk)) then
      if (l1a = '1') then
        l1a_cnt_data := l1a_cnt_data + 1;
      end if;
    end if;

    l1a_cnt_out <= l1a_cnt_data;
  end process;

  l1a_cnt_l_fifo_in <= "000000" & l1a_cnt_out(11 downto 0);
  l1a_cnt_h_fifo_in <= "000000" & l1a_cnt_out(23 downto 12);

  l1a_cnt_fifo_ctrl : process (clk, alct_l1a_match, otmb_l1a_match, rst)
  begin
    if (rst = '1') then
      alct_l1a_cnt_fifo_wr_en <= '0';
      otmb_l1a_cnt_fifo_wr_en <= '0';
    elsif (rising_edge(clk)) then
      if (alct_l1a_match = '1') then
        alct_l1a_cnt_fifo_wr_en <= '1';
      else
        alct_l1a_cnt_fifo_wr_en <= '0';
      end if;
      if (otmb_l1a_match = '1') then
        otmb_l1a_cnt_fifo_wr_en <= '1';
      else
        otmb_l1a_cnt_fifo_wr_en <= '0';
      end if;
    end if;
  end process;

  -- Data word counters
  alct_dw_cnt : process (clk, alct_dw_cnt_en, alct_dw_cnt_rst, rst)
    variable alct_dw_cnt_data : std_logic_vector(15 downto 0);
  begin
    if (rst = '1') then
      alct_dw_cnt_data := (others => '0');
    elsif (rising_edge(clk)) then
      if (alct_dw_cnt_rst = '1') then
        alct_dw_cnt_data := (others => '0');
      elsif (alct_dw_cnt_en = '1') then
        alct_dw_cnt_data := alct_dw_cnt_data + 1;
      end if;
    end if;

    alct_dw_cnt_out <= alct_dw_cnt_data + 1;
  end process;

  otmb_dw_cnt : process (clk, otmb_dw_cnt_en, otmb_dw_cnt_rst, rst)
    variable otmb_dw_cnt_data : std_logic_vector(15 downto 0);
  begin

    if (rst = '1') then
      otmb_dw_cnt_data := (others => '0');
    elsif (rising_edge(clk)) then
      if (otmb_dw_cnt_rst = '1') then
        otmb_dw_cnt_data := (others => '0');
      elsif (otmb_dw_cnt_en = '1') then
        otmb_dw_cnt_data := otmb_dw_cnt_data + 1;
      end if;
    end if;

    otmb_dw_cnt_out <= otmb_dw_cnt_data + 1;
  end process;

  alct_l1a_cnt_l_fifo : FIFO_DUALCLOCK_MACRO
    generic map (
      DEVICE                  => "VIRTEX6",  -- Target Device: "VIRTEX5", "VIRTEX6" 
      ALMOST_FULL_OFFSET      => X"0080",    -- Sets almost full threshold
      ALMOST_EMPTY_OFFSET     => X"0080",    -- Sets the almost empty threshold
      DATA_WIDTH              => 18,  -- Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
      FIFO_SIZE               => "18Kb",     -- Target BRAM, "18Kb" or "36Kb" 
      FIRST_WORD_FALL_THROUGH => false)  -- Sets the FIFO FWFT to TRUE or FALSE

    port map (
      ALMOSTEMPTY => open,                       -- Output almost empty 
      ALMOSTFULL  => open,                       -- Output almost full
      DO          => alct_l1a_cnt_l_fifo_out,    -- Output data
      EMPTY       => alct_l1a_cnt_l_fifo_empty,  -- Output empty
      FULL        => alct_l1a_cnt_l_fifo_full,   -- Output full
      RDCOUNT     => alct_l1a_cnt_l_fifo_rdc,    -- Output read count
      RDERR       => open,                       -- Output read error
      WRCOUNT     => alct_l1a_cnt_l_fifo_wrc,    -- Output write count
      WRERR       => open,                       -- Output write error
      DI          => l1a_cnt_l_fifo_in,          -- Input data
      RDCLK       => clk,                        -- Input read clock
      RDEN        => alct_l1a_cnt_fifo_rd_en,    -- Input read enable
      RST         => rst,                        -- Input reset
      WRCLK       => clk,                        -- Input write clock
      WREN        => alct_l1a_cnt_fifo_wr_en     -- Input write enable
      );

  alct_l1a_cnt_h_fifo : FIFO_DUALCLOCK_MACRO
    generic map (
      DEVICE                  => "VIRTEX6",  -- Target Device: "VIRTEX5", "VIRTEX6" 
      ALMOST_FULL_OFFSET      => X"0080",    -- Sets almost full threshold
      ALMOST_EMPTY_OFFSET     => X"0080",    -- Sets the almost empty threshold
      DATA_WIDTH              => 18,  -- Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
      FIFO_SIZE               => "18Kb",     -- Target BRAM, "18Kb" or "36Kb" 
      FIRST_WORD_FALL_THROUGH => false)  -- Sets the FIFO FWFT to TRUE or FALSE

    port map (
      ALMOSTEMPTY => open,                       -- Output almost empty 
      ALMOSTFULL  => open,                       -- Output almost full
      DO          => alct_l1a_cnt_h_fifo_out,    -- Output data
      EMPTY       => alct_l1a_cnt_h_fifo_empty,  -- Output empty
      FULL        => alct_l1a_cnt_h_fifo_full,   -- Output full
      RDCOUNT     => alct_l1a_cnt_h_fifo_rdc,    -- Output read count
      RDERR       => open,                       -- Output read error
      WRCOUNT     => alct_l1a_cnt_h_fifo_wrc,    -- Output write count
      WRERR       => open,                       -- Output write error
      DI          => l1a_cnt_h_fifo_in,          -- Input data
      RDCLK       => clk,                        -- Input read clock
      RDEN        => alct_l1a_cnt_fifo_rd_en,    -- Input read enable
      RST         => rst,                        -- Input reset
      WRCLK       => clk,                        -- Input write clock
      WREN        => alct_l1a_cnt_fifo_wr_en     -- Input write enable
      );

  otmb_l1a_cnt_l_fifo : FIFO_DUALCLOCK_MACRO
    generic map (
      DEVICE                  => "VIRTEX6",  -- Target Device: "VIRTEX5", "VIRTEX6" 
      ALMOST_FULL_OFFSET      => X"0080",    -- Sets almost full threshold
      ALMOST_EMPTY_OFFSET     => X"0080",    -- Sets the almost empty threshold
      DATA_WIDTH              => 18,  -- Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
      FIFO_SIZE               => "18Kb",     -- Target BRAM, "18Kb" or "36Kb" 
      FIRST_WORD_FALL_THROUGH => false)  -- Sets the FIFO FWFT to TRUE or FALSE

    port map (
      ALMOSTEMPTY => open,                       -- Output almost empty 
      ALMOSTFULL  => open,                       -- Output almost full
      DO          => otmb_l1a_cnt_l_fifo_out,    -- Output data
      EMPTY       => otmb_l1a_cnt_l_fifo_empty,  -- Output empty
      FULL        => otmb_l1a_cnt_l_fifo_full,   -- Output full
      RDCOUNT     => otmb_l1a_cnt_l_fifo_rdc,    -- Output read count
      RDERR       => open,                       -- Output read error
      WRCOUNT     => otmb_l1a_cnt_l_fifo_wrc,    -- Output write count
      WRERR       => open,                       -- Output write error
      DI          => l1a_cnt_l_fifo_in,          -- Input data
      RDCLK       => clk,                        -- Input read clock
      RDEN        => otmb_l1a_cnt_fifo_rd_en,    -- Input read enable
      RST         => rst,                        -- Input reset
      WRCLK       => clk,                        -- Input write clock
      WREN        => otmb_l1a_cnt_fifo_wr_en     -- Input write enable
      );

  otmb_l1a_cnt_h_fifo : FIFO_DUALCLOCK_MACRO
    generic map (
      DEVICE                  => "VIRTEX6",  -- Target Device: "VIRTEX5", "VIRTEX6" 
      ALMOST_FULL_OFFSET      => X"0080",    -- Sets almost full threshold
      ALMOST_EMPTY_OFFSET     => X"0080",    -- Sets the almost empty threshold
      DATA_WIDTH              => 18,  -- Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
      FIFO_SIZE               => "18Kb",     -- Target BRAM, "18Kb" or "36Kb" 
      FIRST_WORD_FALL_THROUGH => false)  -- Sets the FIFO FWFT to TRUE or FALSE

    port map (
      ALMOSTEMPTY => open,                       -- Output almost empty 
      ALMOSTFULL  => open,                       -- Output almost full
      DO          => otmb_l1a_cnt_h_fifo_out,    -- Output data
      EMPTY       => otmb_l1a_cnt_h_fifo_empty,  -- Output empty
      FULL        => otmb_l1a_cnt_h_fifo_full,   -- Output full
      RDCOUNT     => otmb_l1a_cnt_h_fifo_rdc,    -- Output read count
      RDERR       => open,                       -- Output read error
      WRCOUNT     => otmb_l1a_cnt_h_fifo_wrc,    -- Output write count
      WRERR       => open,                       -- Output write error
      DI          => l1a_cnt_h_fifo_in,          -- Input data
      RDCLK       => clk,                        -- Input read clock
      RDEN        => otmb_l1a_cnt_fifo_rd_en,    -- Input read enable
      RST         => rst,                        -- Input reset
      WRCLK       => clk,                        -- Input write clock
      WREN        => otmb_l1a_cnt_fifo_wr_en     -- Input write enable
      );


-- FSM 
  alct_tx_start_d <= not alct_l1a_cnt_h_fifo_empty;
  otmb_tx_start_d <= not otmb_l1a_cnt_h_fifo_empty;
  FDALCT_START : FD port map(alct_tx_start, CLK, alct_tx_start_d);
  FDOTMB_START : FD port map(otmb_tx_start, CLK, otmb_tx_start_d);


  fsm_regs : process (alct_next_state, otmb_next_state, rst, clk)
  begin
    if (rst = '1') then
      alct_current_state <= IDLE;
      otmb_current_state <= IDLE;
    elsif rising_edge(clk) then
      alct_current_state <= alct_next_state;
      otmb_current_state <= otmb_next_state;
    end if;
  end process;

  alct_fsm_logic : process (alct_tx_start, l1a_cnt_out, alct_dw_cnt_out, alct_current_state)
  begin
    case alct_current_state is
      when IDLE =>
        alct_data       <= (others => '0');
        alct_dv         <= '0';
        alct_dw_cnt_en  <= '0';
        alct_dw_cnt_rst <= '1';
        if (alct_tx_start = '1') then
          alct_l1a_cnt_fifo_rd_en <= '1';
          alct_next_state         <= HEADER;
        else
          alct_l1a_cnt_fifo_rd_en <= '0';
          alct_next_state         <= IDLE;
        end if;
        
      when HEADER =>
        alct_l1a_cnt_fifo_rd_en <= '0';
        alct_data               <= (others => '0');
        alct_dv                 <= '0';
        alct_dw_cnt_en          <= '0';
        alct_dw_cnt_rst         <= '1';
        alct_next_state         <= TX_DATA;
        
      when TX_DATA =>
        alct_l1a_cnt_fifo_rd_en <= '0';
        alct_data               <= x"D" & alct_l1a_cnt_l_fifo_out(7 downto 0) & alct_dw_cnt_out(3 downto 0);
        alct_dv                 <= '1';
        if (alct_dw_cnt_out = nwords_dummy) then
          alct_dw_cnt_en  <= '0';
          alct_dw_cnt_rst <= '1';
          alct_next_state <= IDLE;
        else
          alct_dw_cnt_en  <= '1';
          alct_dw_cnt_rst <= '0';
          alct_next_state <= TX_DATA;
        end if;

      when others =>
        alct_l1a_cnt_fifo_rd_en <= '0';
        alct_data               <= (others => '0');
        alct_dv                 <= '0';
        alct_dw_cnt_en          <= '0';
        alct_dw_cnt_rst         <= '1';
        alct_next_state         <= IDLE;
        
    end case;
  end process;

  otmb_fsm_logic : process (otmb_tx_start, l1a_cnt_out, otmb_dw_cnt_out, otmb_current_state)
  begin
    case otmb_current_state is
      when IDLE =>
        otmb_data       <= (others => '0');
        otmb_dv         <= '0';
        otmb_dw_cnt_en  <= '0';
        otmb_dw_cnt_rst <= '1';
        if (otmb_tx_start = '1') then
          otmb_next_state         <= HEADER;
          otmb_l1a_cnt_fifo_rd_en <= '1';
        else
          otmb_next_state         <= IDLE;
          otmb_l1a_cnt_fifo_rd_en <= '0';
        end if;
        
      when HEADER =>
        otmb_l1a_cnt_fifo_rd_en <= '0';
        otmb_data               <= (others => '0');
        otmb_dv                 <= '0';
        otmb_dw_cnt_en          <= '0';
        otmb_dw_cnt_rst         <= '1';
        otmb_next_state         <= TX_DATA;
        
      when TX_DATA =>
        otmb_l1a_cnt_fifo_rd_en <= '0';
        otmb_data               <= x"B" & otmb_l1a_cnt_l_fifo_out(7 downto 0) & otmb_dw_cnt_out(3 downto 0);
        otmb_dv                 <= '1';
        if (otmb_dw_cnt_out = nwords_dummy) then
          otmb_dw_cnt_en  <= '0';
          otmb_dw_cnt_rst <= '1';
          otmb_next_state <= IDLE;
        else
          otmb_dw_cnt_en  <= '1';
          otmb_dw_cnt_rst <= '0';
          otmb_next_state <= TX_DATA;
        end if;

      when others =>
        otmb_l1a_cnt_fifo_rd_en <= '0';
        otmb_data               <= (others => '0');
        otmb_dv                 <= '0';
        otmb_dw_cnt_en          <= '0';
        otmb_dw_cnt_rst         <= '1';
        otmb_next_state         <= IDLE;
        
    end case;
  end process;
  
end alct_otmb_data_gen_architecture;
