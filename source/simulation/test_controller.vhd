---------------------------------------------------------------------------------------------------
--
-- Title       : tx_ctrl_v2_0
-- Design      : 
-- Author      : Guido Magazzù
-- Company     : elvis
--
---------------------------------------------------------------------------------------------------
--
-- Description : tx_ctrl RAM FLF
--
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.STD_LOGIC_1164.all;

entity test_controller is
   port(
  
   clk : in std_logic;
   rstn : in std_logic;
   sw_reset : in std_logic;
   tc_enable : in std_logic;

	-- From/To SLV_MGT Module

   start : in std_logic;
   start_res : out std_logic;
   stop : in std_logic;
   stop_res : out std_logic;
   mode : in std_logic;
   cmd_n : in std_logic_vector(9 downto 0);
	 busy : out std_logic;
	
   vme_cmd_reg : in std_logic_vector(31 downto 0);
   vme_dat_reg_in : in std_logic_vector(31 downto 0);
   vme_dat_reg_out : out std_logic_vector(31 downto 0);

-- To/From VME Master

   vme_cmd : out std_logic;
   vme_cmd_rd : in std_logic;
	
	 vme_addr : out std_logic_vector(23 downto 1); 
   vme_wr : out std_logic;
	 vme_wr_data : out std_logic_vector(15 downto 0); 
   vme_rd : out std_logic;
	 vme_rd_data : in std_logic_vector(15 downto 0); 
 	 
-- From/To VME_CMD Memory and VME_DAT Memory

   vme_mem_addr : out std_logic_vector(9 downto 0);
   vme_mem_rden : out std_logic;
   vme_cmd_mem_out : in std_logic_vector(31 downto 0);
   vme_dat_mem_out : in std_logic_vector(31 downto 0);
   vme_dat_mem_wren : out std_logic;
   vme_dat_mem_in : out std_logic_vector(31 downto 0)

	);

end test_controller;

--}} End of automatically maintained section

architecture test_ctrl_architecture of test_controller is

type state_type is (IDLE, CMD_READ, CMD_START, CMD_RUN, CMD_END);
    
signal next_state, current_state: state_type;

signal int_vme_wr : std_logic;
signal int_vme_rd : std_logic;
signal addr_cnt_en, addr_cnt_res : std_logic;
signal addr_cnt_out : std_logic_vector(9 downto 0);

signal vme_dat_reg_wren : std_logic;

begin

-- Assignments
	
vme_mux: process (mode, vme_cmd_reg, vme_dat_reg_in, vme_cmd_mem_out, vme_dat_mem_out)

	begin
	
	if (mode = '0') then
		int_vme_wr <= vme_cmd_reg(24);
		vme_wr <= vme_cmd_reg(24);
		int_vme_rd <= vme_cmd_reg(25);
		vme_rd <= vme_cmd_reg(25);
		vme_addr(23 downto 1) <= vme_cmd_reg(23 downto 1); 
		vme_wr_data(15 downto 0) <= vme_dat_reg_in(15 downto 0);
	else
		int_vme_wr <= vme_cmd_mem_out(24);
		vme_wr <= vme_cmd_mem_out(24);
		int_vme_rd <= vme_cmd_mem_out(25);
		vme_rd <= vme_cmd_mem_out(25);
		vme_addr(23 downto 1) <= vme_cmd_mem_out(23 downto 1); 
		vme_wr_data(15 downto 0) <= vme_dat_mem_out(15 downto 0);
	end if;

end process;
	
-- Address Counter
	
addr_cnt: process (clk, addr_cnt_en, addr_cnt_res, rstn, sw_reset)

variable addr_cnt_data : std_logic_vector(9 downto 0);

begin

	if ((rstn = '0') or (sw_reset = '1')) then
		addr_cnt_data := (OTHERS => '0');
	elsif (rising_edge(clk)) then
		if (addr_cnt_res = '1') then
			addr_cnt_data := (OTHERS => '0');
		elsif (addr_cnt_en = '1') then    
			addr_cnt_data := addr_cnt_data + 1;
		end if;              
	end if; 

	addr_cnt_out <= addr_cnt_data;
	
end process;

vme_mem_addr <= addr_cnt_out;		

-- Read Data Register 
	
vme_dat_reg: process (int_vme_rd, vme_rd_data, vme_dat_reg_wren, rstn, sw_reset, clk)

begin
	if ((rstn = '0') or (sw_reset = '1')) then
		vme_dat_reg_out <= (OTHERS => '0');
	elsif rising_edge(clk) and (vme_dat_reg_wren = '1') then
		vme_dat_reg_out(31) <= int_vme_rd;
		vme_dat_reg_out(30 downto 16) <= (OTHERS => '0');
		vme_dat_reg_out(15 downto 0) <= vme_rd_data;
	end if;

end process;

vme_dat_mem_in(31) <= int_vme_rd;
vme_dat_mem_in(30 downto 16) <= (OTHERS => '0');
vme_dat_mem_in(15 downto 0) <= vme_rd_data;

-- FSM 
	
fsm_regs: process (next_state, rstn, sw_reset, clk)

begin
	if ((rstn = '0') or (sw_reset = '1')) then
		current_state <= IDLE;
	elsif rising_edge(clk) then
		current_state <= next_state;	      	
	end if;

end process;

fsm_logic : process (tc_enable, start, stop, mode, int_vme_wr, vme_cmd_rd, current_state, addr_cnt_out)
	
begin
				
	case current_state is
		
		when IDLE =>
			
			start_res <= '0';
			stop_res <= '0';
			addr_cnt_en <= '0';
			addr_cnt_res <= '0';
			vme_dat_reg_wren <= '0';
			vme_dat_mem_wren <= '0';
			vme_cmd <= '0';
			busy <= '0';
			vme_mem_rden <= '0';
			if (tc_enable = '1') then
				next_state <= CMD_READ;
			else
				next_state <= IDLE;
			end if;
			
		when CMD_READ =>
			
			start_res <= '0';
			stop_res <= '0';
			addr_cnt_en <= '0';
			addr_cnt_res <= '0';
			vme_dat_reg_wren <= '0';
			vme_dat_mem_wren <= '0';
			busy <= '0';
	    if (mode = '0') then
			  vme_mem_rden <= '0';
			else
			  vme_mem_rden <= '1';
			end if;  
			if (start = '1') then
			  vme_cmd <= '1';
				next_state <= CMD_START;
			else
			  vme_cmd <= '0';
				next_state <= CMD_READ;
			end if;
			
		when CMD_START =>

			start_res <= '1';
			stop_res <= '0';
			addr_cnt_en <= '0';
			addr_cnt_res <= '0';
			vme_dat_reg_wren <= '0';
			vme_dat_mem_wren <= '0';
			vme_mem_rden <= '0';
			vme_cmd <= '0';
			busy <= '1';
			next_state <= CMD_RUN;

		when CMD_RUN =>

			start_res <= '0';
			stop_res <= '0';
			addr_cnt_res <= '0';
			vme_mem_rden <= '0';
			vme_cmd <= '0';
			busy <= '1';
			if (vme_cmd_rd = '1') then
				if (mode = '1') then
					addr_cnt_en <= '1';
					vme_dat_reg_wren <= '0';
					if (int_vme_wr = '1') then
						vme_dat_mem_wren <= '0';
					else
						vme_dat_mem_wren <= '1';
					end if;
				else
					addr_cnt_en <= '0';
					vme_dat_mem_wren <= '0';
					if (int_vme_wr = '1') then
						vme_dat_reg_wren <= '0';
					else
						vme_dat_reg_wren <= '1';
					end if;
				end if;
				next_state <= CMD_END;
			else
				addr_cnt_en <= '0';
				vme_dat_reg_wren <= '0';
				vme_dat_mem_wren <= '0';
				next_state <= CMD_RUN;
			end if;

		when CMD_END =>

			start_res <= '0';
			vme_dat_reg_wren <= '0';
			vme_dat_mem_wren <= '0';
			vme_cmd <= '0';
			busy <= '1';
			vme_mem_rden <= '0';
			if ((stop = '1') or (mode = '0') or ((mode = '1') and (addr_cnt_out = cmd_n))) then
				stop_res <= '1';
				addr_cnt_en <= '1';
				addr_cnt_res <= '1';
				next_state <= IDLE;
			else
				stop_res <= '0';
				addr_cnt_en <= '1';
				addr_cnt_res <= '0';
				next_state <= CMD_READ;
			end if;


			
		when others =>

			start_res <= '0';
			stop_res <= '0';
			addr_cnt_en <= '0';
			addr_cnt_res <= '0';
			vme_dat_reg_wren <= '0';
			vme_dat_mem_wren <= '0';
			vme_mem_rden <= '0';
			vme_cmd <= '0';
			busy <= '0';
			next_state <= IDLE;
				
		end case;
			
	end process;
		
end test_ctrl_architecture;
