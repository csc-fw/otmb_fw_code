`timescale 1ns / 1ps

module test_controller(
  clk,
  rstn,
  sw_reset,
  tc_enable,
  start,
  start_res,
  stop,
  stop_res,
  mode,
  cmd_n,
  busy,
  vme_cmd_reg,
  vme_dat_reg_in,
  vme_dat_reg_out,
  vme_cmd,
  vme_cmd_rd,
  vme_addr,
  vme_wr,
  vme_wr_data,
  vme_rd,
  vme_rd_data,
  vme_mem_addr,
  vme_mem_rden,
  vme_cmd_mem_out,
  vme_dat_mem_out,
  vme_dat_mem_wren,
  vme_dat_mem_in
);

  input clk;
  input rstn;
  input sw_reset;
  input tc_enable;
  
  // From/To SLV_MGT Module
  input  start;
  output start_res;
  input  stop;
  output stop_res;
  input  mode;
  output busy;
  input [9:0] cmd_n;
  
  
  input  [31:0] vme_cmd_reg;
  input  [31:0] vme_dat_reg_in;
  output [31:0] vme_dat_reg_out;
  
  // To/From VME Master
  output        vme_cmd;
  input         vme_cmd_rd;
  output [23:1] vme_addr;
  output        vme_wr;
  output [15:0] vme_wr_data;
  output        vme_rd;
  input  [15:0] vme_rd_data;
  
  // From/To VME_CMD Memory and VME_DAT Memory
  output [9:0]  vme_mem_addr;
  output        vme_mem_rden;
  input [31:0]  vme_cmd_mem_out;
  input [31:0]  vme_dat_mem_out;
  output        vme_dat_mem_wren;
  output [31:0] vme_dat_mem_in;
  
  reg        int_vme_wr;
  reg        vme_wr;
  reg        int_vme_rd;
  reg        vme_rd;
  reg [23:1] vme_addr;
  reg [15:0] vme_wr_data;
  reg [9:0]  addr_cnt_out;
  reg [31:0] vme_dat_reg_out;
  
  reg start_res;
  reg stop_res;
  reg addr_cnt_en;
  reg addr_cnt_res;
  reg vme_dat_reg_wren;
  reg vme_dat_mem_wren;
  reg vme_cmd;
  reg busy;
  reg vme_mem_rden;
  
  reg [2:0] current_state;
  reg [2:0] next_state;
  
  localparam IDLE      = 3'b000;
  localparam CMD_READ  = 3'b001;
  localparam CMD_START = 3'b010;
  localparam CMD_RUN   = 3'b011;
  localparam CMD_END   = 3'b100;
  
  // Assignments
  always @ ( mode or vme_cmd_reg or vme_dat_reg_in or vme_cmd_mem_out or vme_dat_mem_out )
  begin : vme_mux
    if ( mode == 1'b0 ) 
    begin
      int_vme_wr        <= vme_cmd_reg[24];
      vme_wr            <= vme_cmd_reg[24];
      int_vme_rd        <= vme_cmd_reg[25];
      vme_rd            <= vme_cmd_reg[25];
      vme_addr[23:1]    <= vme_cmd_reg[23:1];
      vme_wr_data[15:0] <= vme_dat_reg_in[15:0];
    end
    else
    begin 
      int_vme_wr        <= vme_cmd_mem_out[24];
      vme_wr            <= vme_cmd_mem_out[24];
      int_vme_rd        <= vme_cmd_mem_out[25];
      vme_rd            <= vme_cmd_mem_out[25];
      vme_addr[23:1]    <= vme_cmd_mem_out[23:1];
      vme_wr_data[15:0] <= vme_dat_mem_out[15:0];
    end
  end
  
  // Address Counter
  always @ ( posedge clk or addr_cnt_en or addr_cnt_res or rstn or sw_reset )
  begin : addr_cnt
    reg [9:0]addr_cnt_data;
    if ( ( rstn == 1'b0 ) | ( sw_reset == 1'b1 ) ) 
    begin
      addr_cnt_data = { 1'b0 };
    end
    else
    begin 
      if ( clk ) 
      begin
        if ( addr_cnt_res == 1'b1 ) 
        begin
          addr_cnt_data = { 1'b0 };
        end
        else
        begin 
          if ( addr_cnt_en == 1'b1 ) 
          begin
            addr_cnt_data = ( addr_cnt_data + 1 );
          end
        end
      end
    end
    addr_cnt_out <= addr_cnt_data;
  end
  
  assign vme_mem_addr = addr_cnt_out;
  
  // Read Data Register
  always @ ( int_vme_rd or vme_rd_data or vme_dat_reg_wren or rstn or sw_reset or clk)
  begin : vme_dat_reg
    if ( ( rstn == 1'b0 ) | ( sw_reset == 1'b1 ) ) 
    begin
      vme_dat_reg_out <= { 1'b0 };
    end
    else
    begin 
      if ( clk & ( vme_dat_reg_wren == 1'b1 ) ) 
      begin
        vme_dat_reg_out[31]    <= int_vme_rd;
        vme_dat_reg_out[30:16] <= { 1'b0 };
        vme_dat_reg_out[15:0]  <= vme_rd_data;
      end
    end
  end
  
  assign vme_dat_mem_in[31]  = int_vme_rd;
  assign vme_dat_mem_in[30:16] = { 1'b0 };
  assign vme_dat_mem_in[15:0] = vme_rd_data;
  
  // FSM
  always @ ( next_state or rstn or sw_reset or clk)
  begin : fsm_regs
    if ( ( rstn == 1'b0 ) | ( sw_reset == 1'b1 ) ) 
    begin
      current_state <= IDLE;
    end
    else
    begin 
      if ( clk ) 
      begin
        current_state <= next_state;
      end
    end
  end
  
  always @ ( tc_enable or start or stop or mode or int_vme_wr or vme_cmd_rd or current_state or addr_cnt_out )
  begin : fsm_logic
    case ( current_state ) 
    
    IDLE:
    begin
      start_res        <= 1'b0;
      stop_res         <= 1'b0;
      addr_cnt_en      <= 1'b0;
      addr_cnt_res     <= 1'b0;
      vme_dat_reg_wren <= 1'b0;
      vme_dat_mem_wren <= 1'b0;
      vme_cmd          <= 1'b0;
      busy             <= 1'b0;
      vme_mem_rden     <= 1'b0;
      if ( tc_enable == 1'b1 ) 
      begin
        next_state <= CMD_READ;
      end
      else
      begin 
        next_state <= IDLE;
      end
    end
    
    CMD_READ:
    begin
      start_res        <= 1'b0;
      stop_res         <= 1'b0;
      addr_cnt_en      <= 1'b0;
      addr_cnt_res     <= 1'b0;
      vme_dat_reg_wren <= 1'b0;
      vme_dat_mem_wren <= 1'b0;
      busy             <= 1'b0;
      if ( mode == 1'b0 ) 
      begin
        vme_mem_rden <= 1'b0;
      end
      else
      begin 
        vme_mem_rden <= 1'b1;
      end
      if ( start == 1'b1 ) 
      begin
        vme_cmd    <= 1'b1;
        next_state <= CMD_START;
      end
      else
      begin 
        vme_cmd    <= 1'b0;
        next_state <= CMD_READ;
      end
    end
    
    CMD_START:
    begin
      start_res        <= 1'b1;
      stop_res         <= 1'b0;
      addr_cnt_en      <= 1'b0;
      addr_cnt_res     <= 1'b0;
      vme_dat_reg_wren <= 1'b0;
      vme_dat_mem_wren <= 1'b0;
      vme_mem_rden     <= 1'b0;
      vme_cmd          <= 1'b0;
      busy             <= 1'b1;
      next_state       <= 2'b11;
    end
    
    CMD_RUN:
    begin
      start_res    <= 1'b0;
      stop_res     <= 1'b0;
      addr_cnt_res <= 1'b0;
      vme_mem_rden <= 1'b0;
      vme_cmd      <= 1'b0;
      busy         <= 1'b1;
      if ( vme_cmd_rd == 1'b1 ) 
      begin
        if ( mode == 1'b1 ) 
        begin
          addr_cnt_en      <= 1'b1;
          vme_dat_reg_wren <= 1'b0;
          if ( int_vme_wr == 1'b1 ) 
          begin
            vme_dat_mem_wren <= 1'b0;
          end
          else
          begin 
            vme_dat_mem_wren <= 1'b1;
          end
        end
        else
        begin 
          addr_cnt_en      <= 1'b0;
          vme_dat_mem_wren <= 1'b0;
          if ( int_vme_wr == 1'b1 ) 
          begin
            vme_dat_reg_wren <= 1'b0;
          end
          else
          begin 
            vme_dat_reg_wren <= 1'b1;
          end
        end
       next_state <= CMD_END;
      end
      else
      begin 
        addr_cnt_en      <= 1'b0;
        vme_dat_reg_wren <= 1'b0;
        vme_dat_mem_wren <= 1'b0;
        next_state       <= CMD_RUN;
      end
    end
  
    CMD_END:
    begin
      start_res        <= 1'b0;
      vme_dat_reg_wren <= 1'b0;
      vme_dat_mem_wren <= 1'b0;
      vme_cmd          <= 1'b0;
      busy             <= 1'b1;
      vme_mem_rden     <= 1'b0;
      if ( ( ( stop == 1'b1 ) | ( mode == 1'b0 ) ) | ( ( mode == 1'b1 ) & ( addr_cnt_out == cmd_n ) ) ) 
      begin
        stop_res     <= 1'b1;
        addr_cnt_en  <= 1'b1;
        addr_cnt_res <= 1'b1;
        next_state   <= IDLE;
      end
      else
      begin 
        stop_res     <= 1'b0;
        addr_cnt_en  <= 1'b1;
        addr_cnt_res <= 1'b0;
        next_state   <= CMD_READ;
      end
    end
  
    default:
    begin
      start_res        <= 1'b0;
      stop_res         <= 1'b0;
      addr_cnt_en      <= 1'b0;
      addr_cnt_res     <= 1'b0;
      vme_dat_reg_wren <= 1'b0;
      vme_dat_mem_wren <= 1'b0;
      vme_mem_rden     <= 1'b0;
      vme_cmd          <= 1'b0;
      busy             <= 1'b0;
      next_state       <= IDLE;
    end
    
    endcase
  end
endmodule 
