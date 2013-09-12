-- PULSE_EDGE: Creates a pulse one clock cycle long if rising edge

library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all;

entity PULSE_EDGE is
  port (
    DOUT   : out std_logic;
    PULSE1 : out std_logic;
    CLK    : in  std_logic;
    RST    : in  std_logic;
    NPULSE : in  integer;
    DIN    : in  std_logic
    );
end PULSE_EDGE;

architecture PULSE_EDGE_Arch of PULSE_EDGE is

-- Guido - Aug 9
  constant LOGIC1 : std_logic := '1';

  signal PULSE1_INNER, PULSE1_D : std_logic := '0';
  signal PULSE1_B               : std_logic := '1';

  signal pulse_cnt                             : integer   := 0;
  signal pulse_cnt_rst, pulse_cnt_en           : std_logic := '0';
  signal reset_q, clk_pulse                    : std_logic := '0';
  type   pulse_state_type is (PULSE_IDLE, PULSE_COUNTING);
  signal pulse_next_state, pulse_current_state : pulse_state_type;

begin  --Architecture

-- Guido - Aug 9
--  FDDIN    : FDC port map(PULSE1_D, DIN, PULSE1_INNER, PULSE1_B);
--  FDPULSE1 : FD port map(PULSE1_INNER, CLK, PULSE1_D);
--  PULSE1_B <= not PULSE1_INNER;
--  PULSE1   <= PULSE1_INNER;

  FDDIN    : FDC port map(PULSE1_D, DIN, PULSE1_B, LOGIC1);
  FDPULSE1_A : FDC port map(PULSE1_INNER, CLK, PULSE1_B, PULSE1_D);
  FDPULSE1_B : FD port map(PULSE1_B, CLK, PULSE1_INNER);
  PULSE1   <= PULSE1_INNER;

  pulse_cnt_proc : process (clk, pulse_cnt_en, rst)
    variable pulse_cnt_data : integer := 0;
  begin
    if (rst = '1') then
      pulse_cnt_data := 0;
    elsif (rising_edge(clk)) then
      if pulse_cnt_rst = '1' then
        pulse_cnt_data := 0;
      elsif(pulse_cnt_en = '1') then
        pulse_cnt_data := pulse_cnt_data + 1;
      end if;
    end if;

    pulse_cnt <= pulse_cnt_data;
  end process;


  pulse_fsm_regs : process (clk, pulse_next_state, rst)
  begin
    if (rst = '1') then
      pulse_current_state <= PULSE_IDLE;
    elsif rising_edge(clk) then
      pulse_current_state <= pulse_next_state;
    end if;
  end process;

  pulse_fsm_logic : process (pulse1_inner, pulse_current_state, pulse_cnt, npulse)
  begin
    case pulse_current_state is
      when PULSE_IDLE =>
        pulse_cnt_en <= '0';
        if (pulse1_inner = '1') then
          pulse_next_state <= PULSE_COUNTING;
          pulse_cnt_rst    <= '1';
          dout             <= '1';
        else
          pulse_next_state <= PULSE_IDLE;
          pulse_cnt_rst    <= '0';
          dout             <= '0';
        end if;
        
      when PULSE_COUNTING =>
        pulse_cnt_rst <= '0';
        if (pulse_cnt >= npulse-1) then
          pulse_next_state <= PULSE_IDLE;
          pulse_cnt_en     <= '0';
          dout             <= '0';
        else
          pulse_next_state <= PULSE_COUNTING;
          pulse_cnt_en     <= '1';
          dout             <= '1';
        end if;

      when others =>
        pulse_next_state <= PULSE_IDLE;
        dout             <= '0';
        pulse_cnt_rst    <= '1';
        pulse_cnt_en     <= '0';
        
    end case;
  end process;



end PULSE_EDGE_Arch;
