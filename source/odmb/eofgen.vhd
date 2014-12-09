
library IEEE;
use IEEE.STD_LOGIC_UNSIGNED.all;
--use IEEE.STD_LOGIC_INTEGER.all;
use IEEE.STD_LOGIC_1164.all;
library UNISIM;
use UNISIM.vcomponents.all;
library UNIMACRO;
use UNIMACRO.vcomponents.all;
library hdlmacro; use hdlmacro.hdlmacro.all;

entity eofgen is
  port(

    clk : in std_logic;
    rst : in std_logic;

    dv_in : in std_logic;
    data_in : in std_logic_vector(15 downto 0);

    dv_out : out std_logic;
    data_out : out std_logic_vector(17 downto 0)
    );

end eofgen;


architecture eofgen_architecture of eofgen is

-- Guido - Aug 6
--  signal reg_data : std_logic_vector(15 downto 0);
--  signal reg_dv : std_logic;
  signal reg1_data, reg2_data : std_logic_vector(15 downto 0);
  signal reg1_dv, reg2_dv : std_logic;
  
  type fsm_state_type is (IDLE, RX);
  signal next_state, current_state : fsm_state_type;
  signal eof : std_logic;

begin

-- Guido - Aug 6
--  data_dv_regs : process (data_in, dv_in, rst, clk)

--  begin
--    if (rst = '1') then
--      reg_data <= (others => '0');
--      reg_dv <= '0';
--    elsif rising_edge(clk) then
--      reg_data <= data_in;
--      reg_dv <= dv_in;
--    end if;
    
--  end process;

  data_dv_regs : process (data_in, dv_in, rst, clk)

  begin
    if (rst = '1') then
      reg1_data <= (others => '0');
      reg1_dv <= '0';
      reg2_data <= (others => '0');
      reg2_dv <= '0';
    elsif rising_edge(clk) then
      reg1_data <= data_in;
      reg1_dv <= dv_in;
      reg2_data <= reg1_data;
      reg2_dv <= reg1_dv;
    end if;
  
  end process;

  fsm_regs : process (next_state, rst, clk)

  begin
    if (rst = '1') then
      current_state <= IDLE;
    elsif rising_edge(clk) then
      current_state <= next_state;
    end if;
    
  end process;

  fsm_logic : process (current_state, dv_in)
  begin
    
    case current_state is
      
      when IDLE =>
	eof <= '0';
        if (dv_in = '1') then
          next_state <= RX;
        else
          next_state <= IDLE;
        end if;
        
      when RX =>
        if (dv_in = '0') then
	  eof <= '1';
          next_state <= IDLE;
        else
	  eof <= '0';
          next_state <= RX;
        end if;

      when others =>
        eof <= '0';
        next_state <= IDLE;
        
    end case;
    
  end process;

-- Guido - Aug 6
--  data_out <= eof & eof & reg_data ;
--  dv_out <= reg_dv;
  data_out <= eof & eof & reg2_data ;
  dv_out <= reg2_dv;
  
end eofgen_architecture;
