`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:20:27 09/22/2011 
// Design Name: 
// Module Name:    BPI_ctrl  -- JRG: this is BPI bus control; calls BPI_cmd_parser_FSM  &  BPI_sequencer_FSM  &  BPI_ctrl_FSM
//                           -- has two FIFOs; has calls for vio & la (not used)
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module BPI_ctrl #(
  parameter USE_CHIPSCOPE = 0
)
(
  // Chip Scope Pro control signals
  inout [35:0]      BPI_VIO_CNTRL,
  inout [35:0]      BPI_LA_CNTRL,
  input             CLK,               // 40 MHz clock
  input             CLK1MHZ,           //  1 MHz clock for timers
  input             RST,
  // Interface Signals to/from VME interface
  input [15:0]      BPI_CMD_FIFO_DATA, // Data for command FIFO
  input             BPI_WE,            // Command FIFO write enable  (pulse one clock cycle for one write)
  input             BPI_RE,            // Read back FIFO read enable  (pulse one clock cycle for one read)
  input             BPI_DSBL,          // Disable parsing of BPI commands in the command FIFO (while being filled)
  input             BPI_ENBL,          // Enable  parsing of BPI commands in the command FIFO
  output [15:0]     BPI_RBK_FIFO_DATA, // Data on output of the Read back FIFO
  output [10:0]     BPI_RBK_WRD_CNT,   // Word count of the Read back FIFO (number of available reads)
  output reg [15:0] BPI_STATUS,        // FIFO status bits and latest value of the PROM status register. 
  output reg [31:0] BPI_TIMER,         // General timer
  // Signals to/from low level BPI interface
  input             BPI_BUSY,
  input [15:0]      BPI_DATA_FROM,
  input             BPI_LOAD_DATA,
  output            BPI_ACTIVE,
  output [1:0]      BPI_OP,
  output [22:0]     BPI_ADDR,
  output [15:0]     BPI_DATA_TO,
  output            BPI_EXECUTE
);
   
   //
   // Declaration of commands used throughout the BPI interface
   //
localparam 
// commands for the PROM
  NoOp            = 5'h00,
  Write_1         = 5'h01,
  Read_1          = 5'h02,
  Write_n         = 5'h03,
  Read_n          = 5'h04,
  Read_Array      = 5'h05,
  Read_Status_Reg = 5'h06,
  Read_Elec_Sig   = 5'h07,
  Read_CFI_Qry    = 5'h08,
  Clr_Status_Reg  = 5'h09,
  Block_Erase     = 5'h0A,
  Program         = 5'h0B,
  Buffer_Program  = 5'h0C,
  Buf_Prog_Wrt_n  = 5'h0D,
  Buf_Prog_Conf   = 5'h0E,
  PE_Susp         = 5'h0F,
  PE_Resume       = 5'h10,
  Prot_Reg_Prog   = 5'h11,
  Set_Cnfg_Reg    = 5'h12,
  Block_Lock      = 5'h13,
  Block_UnLock    = 5'h14,
  Block_Lock_Down = 5'h15,
  Blank_Check     = 5'h16,
// commands for local control
  Load_Address    = 5'h17,
  Unassigned      = 5'h18,
  Start_Timer     = 5'h19,
  Stop_Timer      = 5'h1A,
  Reset_Timer     = 5'h1B,
  Clr_BPI_Status  = 5'h1C;

localparam // Read modes (Array, Status Register, Electronic Signature, or Common Flash Interface Query)
   Rd_Array        = 2'd0,
   Rd_SR           = 2'd1,
   Rd_ESig         = 2'd2,
   Rd_CFIQ         = 2'd3;
  
localparam // Operational modes (synchronous or asynchronous)
   CRD_Sync        = 16'h3DDF,
   CRD_ASync       = 16'hBDDF;


//signals from BPI_sequencer_FSM 
// outputs
wire check_PEC;
wire check_buf;
wire check_stat;
wire cnfrm_lk;
wire [4:0] command;
wire read_es_state;
wire rpt_error;
wire seqr_idle;
wire seq_cmplt;
wire set_asynch;
// inputs
reg [4:0] seq_cmnd;
reg  noop_seq;
wire buf_prog;
reg  simple_cmd;
reg  lk_unlk;
reg  std_seq; 
wire seq_done;
wire ack;
wire pec_busy;
reg error;
reg lk_ok;
// end of FSM signals

// BPI_cmd_parser_FSM signals
wire decode;
wire enable_cmd;
wire parser_idle;
wire ld_cnts;
wire ld_full;
wire ld_status;
wire ld_usr;
wire read_ff;
reg  cnt_cmd;
reg  has_data;
reg  local;
reg  pass;
reg  xtra_word;
reg  bpi_enable;
reg  parser_active;
reg  parser_active_r;
wire trl_edge_pa;
wire p_tmr_rst;
reg [19:0] parser_inactive_tmr;

wire [3:0] ctrl_state;
wire [4:0] seq_state;
wire [3:0] parse_state;

// BPI command FIFO signals
wire bpi_cmd_amt;
wire bpi_cmd_afl;
wire bpi_cmd_mt;
wire bpi_cmd_full;
wire bpi_wrena;
wire [10:0] bpi_wrtcnt;
wire bpi_wrterr;
wire bpi_rdena;
wire [10:0] bpi_rdcnt;
wire bpi_rderr;
wire [15:0] data_fifo;     // command FIFO data output
wire [15:0] bpi_wrt_data;  // command FIFO data input
reg [10:0] bpi_cmd_cnt;       // words in FIFO
// BPI read FIFO signals
wire bpi_rbk_amt;
wire bpi_rbk_afl;
wire bpi_rbk_empty;
wire bpi_rbk_full;
wire [10:0] bpi_rbk_wrtcnt;
wire bpi_rbk_wrterr;
wire [10:0] bpi_rbk_rdcnt;
wire bpi_rbk_rderr;
wire bpi_rbk_wena;
reg [10:0] bpi_rbk_cnt;       // words in FIFO

// chip scope signals
wire [6:0]  csp_base_address;
wire [15:0] csp_start_offset;
wire [15:0] csp_data;
wire [15:0] csp_ncnt;
wire [4:0]  csp_usr_cmnd;
wire csp_rbk_cnt_rst;
wire csp_load_offset;
wire csp_load_count;
wire csp_man_rst;
wire csp_bpi_wrena;
wire csp_ctrl;
wire csp_fifo_src;
wire csp_ack;
wire csp_bpi_enbl;
wire csp_bpi_dsbl;

// FIFO source signals
reg  [6:0]  ff_base_address;
reg  [15:0] ff_start_offset;
reg  [10:0] ff_n_minus_1;
reg  [4:0]  ff_usr_cmnd;
reg  [10:0] ff_ba_cnt;
wire ff_load_offset;
wire start_tmr;
wire stop_tmr;
wire rst_tmr;
reg  incr_tmr;
wire clr_error_bits;

// mux out signals
wire [6:0]  base_address;
wire [15:0] start_offset;
wire [4:0]  n_minus_1;
wire [15:0] ncnt;
wire [4:0]  usr_cmnd;
wire load_offset;

wire ld_n32;
wire ld_remainder;
wire fsm_ack;
reg [15:0] count_mux;
reg [15:0] full_count;


wire rbk_cnt_rst;

wire local_rst;
reg  local_rst_1;
reg  local_rst_2;
reg  local_rst_3;
wire local_rst_long;

reg  [22:0] addr;
wire [22:0] waddr;
reg  [22:0] block_addr;
wire [22:0] bank_addr;
wire [22:0] lk_stat_addr;
wire [22:0] prot_reg_addr;
reg  [15:0] data1;
reg  [15:0] data2;
reg  [15:0] prog_data;
reg  [15:0] cngf_reg_data;
wire [15:0] prot_reg_data;
reg [4:0] bcount;
reg [15:0] count;
reg [15:0] rbk_count;
reg [15:0] adr_offset;
wire [8:0]  pra_offset;
reg [1:0] read_mode = 2'b00;
reg  two_cycle;
wire intf_busy;
wire intf_rdy;
wire noop;
wire other;
wire read_1;
wire read_n;
wire write_n;
wire usr_read_req;

wire cycle2;
wire decr;
wire load_n;
wire next;
wire term_cnt;
wire loop_done;

reg [15:0] rbk_reg;
reg [7:0] sr_reg;
reg [15:0] esig_reg;
reg [15:0] cfiq_reg;
reg [15:0] rbkbuf0,rbkbuf1,rbkbuf2,rbkbuf3,rbkbuf4,rbkbuf5,rbkbuf6,rbkbuf7;
reg pe_in_suspense;

initial begin
  sr_reg[7:0] = 8'h00;
end

assign local_rst = RST || csp_man_rst;
always @(posedge CLK)
begin
  local_rst_1        <= local_rst;
  local_rst_2        <= local_rst_1;
end

assign local_rst_long = local_rst || local_rst_1 || local_rst_2;

assign rbk_cnt_rst = csp_rbk_cnt_rst || local_rst;
assign usr_cmnd     = csp_ctrl ? csp_usr_cmnd     : ((enable_cmd && !local) ? ff_usr_cmnd : 5'h00);
assign base_address = csp_ctrl ? csp_base_address : ff_base_address;
assign start_offset = csp_ctrl ? csp_start_offset : ff_start_offset;
assign n_minus_1    = csp_ctrl ? (csp_ncnt[4:0]-1'b1): ff_n_minus_1[4:0];
assign ncnt         = csp_ctrl ? csp_ncnt         : ff_n_minus_1 + 1'b1;
assign bpi_wrt_data = csp_fifo_src ? csp_data         : BPI_CMD_FIFO_DATA;
assign ff_load_offset = enable_cmd && (ff_usr_cmnd == Load_Address);
assign start_tmr      = enable_cmd && (ff_usr_cmnd == Start_Timer);
assign stop_tmr       = enable_cmd && (ff_usr_cmnd == Stop_Timer);
assign rst_tmr        = enable_cmd && (ff_usr_cmnd == Reset_Timer);
assign clr_error_bits     = enable_cmd && (ff_usr_cmnd == Clr_BPI_Status);
assign load_offset  = csp_load_offset || ff_load_offset;
assign ld_n32 = |full_count[15:5];
assign ld_remainder = !ld_n32;
assign ack = fsm_ack || csp_ack;

assign pra_offset = adr_offset[8:0];
assign waddr = {base_address,adr_offset};
assign bank_addr = waddr & 23'h780000;
assign lk_stat_addr = block_addr | 23'h000002;
assign prot_reg_addr = bank_addr + pra_offset;
assign prot_reg_data = 16'hFFFF;
assign intf_busy =  BPI_BUSY;
assign intf_rdy  = !BPI_BUSY;
assign usr_read_req = (usr_cmnd == Read_1) || (usr_cmnd == Read_n);
assign noop = (command == NoOp);
assign read_1 = (command == Read_1);
assign read_n = (command == Read_n);
assign write_n = (command == Write_n);
assign other = !noop && !read_n && !write_n;
assign BPI_OP = (read_1 || read_n) ? 2'b10 : 2'b01;
assign BPI_ADDR = addr;
assign BPI_DATA_TO = cycle2 ? data2 : data1;
assign term_cnt = (count == 16'h0000);
assign loop_done = (full_count == 16'h0000);
assign pec_busy = (check_PEC || check_buf) && !sr_reg[7];
assign bpi_rdena = (next && write_n) || read_ff;
assign bpi_wrena = csp_bpi_wrena || BPI_WE;
assign bpi_rbk_wena = usr_read_req && BPI_LOAD_DATA;

assign buf_prog        = (usr_cmnd == Buffer_Program);

assign BPI_ACTIVE   = csp_ctrl || csp_fifo_src || parser_active;
assign trl_edge_pa  = ~parser_active & parser_active_r;
assign p_tmr_rst    = local_rst || ~parser_idle || trl_edge_pa;
assign BPI_RBK_WRD_CNT = bpi_rbk_cnt;

always @(posedge CLK or posedge local_rst)
begin
  if(local_rst)
    parser_active <= 1'b0;
  else
    if(~parser_idle)
      parser_active <= 1'b1;
    else if(parser_inactive_tmr == 20'h7A120)
       parser_active <= 1'b0;
    else
      parser_active <= parser_active;
end
always @(posedge CLK)
begin
   parser_active_r <= parser_active;
end
always @(posedge CLK1MHZ or posedge p_tmr_rst)
begin
  if(p_tmr_rst)  
    parser_inactive_tmr <= 20'h00000;
  else
    if(parser_active && parser_idle)
      parser_inactive_tmr <= parser_inactive_tmr + 1'b1;
    else
      parser_inactive_tmr <= parser_inactive_tmr;
end

always @* begin
  if(waddr > 23'h7EFFFF)
    block_addr = waddr & 23'h7FC000; // for 16 KWord parameter blocks
  else
    block_addr = waddr & 23'h7F0000; // for 64 KWord blocks
end

always @* begin
  case(ff_usr_cmnd)
    Read_1, Read_Array, Read_Status_Reg, Read_Elec_Sig, Read_CFI_Qry, Clr_Status_Reg, Block_Erase,
    PE_Susp, PE_Resume, Block_Lock, Block_UnLock, Block_Lock_Down, Blank_Check:
          pass   = 1;
    default: pass   = 0;
  endcase
  case(ff_usr_cmnd)
    Program, Prot_Reg_Prog, Set_Cnfg_Reg:
          has_data   = 1;
    default: has_data   = 0;
  endcase
  case(ff_usr_cmnd)
    Load_Address, Program, Prot_Reg_Prog, Set_Cnfg_Reg:
          xtra_word   = 1;
    default: xtra_word   = 0;
  endcase
  case(ff_usr_cmnd)
    Read_n, Buffer_Program:
          cnt_cmd   = 1;
    default: cnt_cmd   = 0;
  endcase
  case(ff_usr_cmnd)
    Load_Address, Start_Timer, Stop_Timer, Reset_Timer, Clr_BPI_Status:
          local   = 1;
    default: local   = 0;
  endcase
end

always @* begin
  case(usr_cmnd)
    NoOp, Write_n, Buf_Prog_Wrt_n, Buf_Prog_Conf:
          noop_seq   = 1;
    default: noop_seq   = 0;
  endcase
  case(usr_cmnd)
    Read_1, Read_n, Write_1, Read_Array, Read_Status_Reg, Read_Elec_Sig, Read_CFI_Qry, PE_Resume, Set_Cnfg_Reg, Clr_Status_Reg:
          simple_cmd   = 1;
    default: simple_cmd   = 0;
  endcase
  case(usr_cmnd)
    Block_Erase, Program, PE_Susp, Prot_Reg_Prog, Blank_Check:
          std_seq   = 1;
    default: std_seq   = 0;
  endcase
  case(usr_cmnd)
    Block_Lock, Block_UnLock, Block_Lock_Down: 
          lk_unlk   = 1;
    default: lk_unlk   = 0;
  endcase
  case(usr_cmnd)
    Read_1, Read_n, Write_1, Read_Array, Read_Status_Reg, Read_Elec_Sig, Read_CFI_Qry,
    PE_Resume, Set_Cnfg_Reg, Clr_Status_Reg,
    Block_Erase, Program, PE_Susp, Prot_Reg_Prog, Blank_Check,
    Block_Lock, Block_UnLock, Block_Lock_Down: 
          seq_cmnd   = usr_cmnd;
    default: seq_cmnd   = NoOp;
  endcase
  case(usr_cmnd)
    Block_Lock:
      lk_ok = (cnfrm_lk) && ((esig_reg & 16'hFFFD)== 16'h0001);
    Block_UnLock:
      lk_ok = (cnfrm_lk) && ((esig_reg & 16'hFFFD)== 16'h0000);
    Block_Lock_Down:
      lk_ok = (cnfrm_lk) && ((esig_reg & 16'hFFFE)== 16'h0002);
    default:
      lk_ok = 0;
  endcase
  case(usr_cmnd)
    Block_Erase:
      error = (check_stat) &&  |(sr_reg & 8'h2A);
    Program, Buffer_Program, Prot_Reg_Prog:
      error = (check_stat) && |(sr_reg & 8'h1A);
    PE_Susp:
      error = 0;
    Blank_Check:
      error = (check_stat) && sr_reg[5];
    default:
      error = 0;
  endcase
  case(usr_cmnd)
    Buffer_Program:
      prog_data = data_fifo;
    default:
      prog_data = csp_ctrl ? csp_data : data_fifo;
  endcase
end
  
always @(posedge CLK or posedge local_rst) begin
  if(local_rst)
     pe_in_suspense <= 0;
  else
    case(usr_cmnd)
      PE_Susp:
        pe_in_suspense <= (check_stat) && |(sr_reg & 8'h44);
      PE_Resume:
        pe_in_suspense <= 0;
      default:
        pe_in_suspense <= pe_in_suspense;
    endcase
end

generate
if(USE_CHIPSCOPE==1) 
begin : chipscope_bpi
wire [127:0] bpi_vio_async_in;
wire [59:0]  bpi_vio_async_out;
wire [79:0] bpi_vio_sync_in;
wire [12:0]  bpi_vio_sync_out;
wire [163:0] bpi_la_data;
wire [7:0]  bpi_la_trig;

wire [3:0] dummy_asigs;
wire [3:0] dummy_ssigs;

  bpi_vio bpi_vio_i (
     .CONTROL(BPI_VIO_CNTRL), // INOUT BUS [35:0]
     .CLK(CLK),
     .ASYNC_IN(bpi_vio_async_in), // IN BUS [127:0]
     .ASYNC_OUT(bpi_vio_async_out), // OUT BUS [59:0]
     .SYNC_IN(bpi_vio_sync_in), // IN BUS [79:0]
     .SYNC_OUT(bpi_vio_sync_out) // OUT BUS [12:0]
  );


//     ASYNC_IN [127:0]
  assign bpi_vio_async_in[127:0]     = {rbkbuf0,rbkbuf1,rbkbuf2,rbkbuf3,rbkbuf4,rbkbuf5,rbkbuf6,rbkbuf7};
     
//     ASYNC_OUT [59:0]
  assign csp_start_offset    = bpi_vio_async_out[15:0];
  assign csp_data            = bpi_vio_async_out[31:16];
  assign csp_ncnt            = bpi_vio_async_out[47:32];
  assign csp_base_address    = bpi_vio_async_out[54:48];
  assign csp_ctrl            = bpi_vio_async_out[55];
  assign csp_fifo_src        = bpi_vio_async_out[56];
  assign dummy_asigs[2:0]    = bpi_vio_async_out[59:57];

//     SYNC_IN [79:0]
  assign bpi_vio_sync_in[4:0]     = seq_state; // seq_state
  assign bpi_vio_sync_in[9:5]     = command;
  assign bpi_vio_sync_in[10]      = rpt_error;
  assign bpi_vio_sync_in[11]      = seq_cmplt;
  assign bpi_vio_sync_in[12]      = error;
  assign bpi_vio_sync_in[22:13]   = bpi_cmd_cnt[9:0];
  assign bpi_vio_sync_in[23]      = bpi_cmd_mt;
  assign bpi_vio_sync_in[31:24]   = rbk_count[7:0];
  assign bpi_vio_sync_in[39:32]   = sr_reg;
  assign bpi_vio_sync_in[55:40]   = esig_reg;
  assign bpi_vio_sync_in[71:56]   = cfiq_reg;
  assign bpi_vio_sync_in[73:72]   = read_mode;
  assign bpi_vio_sync_in[74]      = bpi_enable;
  assign bpi_vio_sync_in[75]      = BPI_ACTIVE;
  assign bpi_vio_sync_in[76]      = parser_active;
  assign bpi_vio_sync_in[79:77]   = 3'b000;

//     SYNC_OUT [12:0]
  assign csp_usr_cmnd        = bpi_vio_sync_out[4:0];
  assign csp_ack             = bpi_vio_sync_out[5];
  assign csp_bpi_wrena       = bpi_vio_sync_out[6];
  assign csp_rbk_cnt_rst     = bpi_vio_sync_out[7];
  assign csp_load_offset     = bpi_vio_sync_out[8];
  assign csp_man_rst         = bpi_vio_sync_out[9];
  assign csp_load_count      = bpi_vio_sync_out[10];
  assign csp_bpi_enbl        = bpi_vio_sync_out[11];
  assign csp_bpi_dsbl        = bpi_vio_sync_out[12];

  bpi_la bpi_la_i (
     .CONTROL(BPI_LA_CNTRL),
     .CLK(CLK),
     .DATA(bpi_la_data), // IN BUS [163:0]
     .TRIG0(bpi_la_trig) // IN BUS [7:0]
  );
  
// LA Data [163:0]
  assign bpi_la_data[4:0]    = seq_state; // seq_state
  assign bpi_la_data[9:5]    = command;
  assign bpi_la_data[10]     = rpt_error;
  assign bpi_la_data[11]     = seq_cmplt;
  assign bpi_la_data[12]     = check_PEC;
  assign bpi_la_data[13]     = check_buf;
  assign bpi_la_data[14]     = check_stat;
  assign bpi_la_data[15]     = cnfrm_lk;
  assign bpi_la_data[16]     = lk_ok;
  assign bpi_la_data[17]     = lk_unlk;
  assign bpi_la_data[18]     = noop_seq;
  assign bpi_la_data[19]     = buf_prog;
  assign bpi_la_data[20]     = simple_cmd;
  assign bpi_la_data[21]     = std_seq;
  assign bpi_la_data[22]     = seq_done;
  assign bpi_la_data[23]     = pec_busy;
  assign bpi_la_data[24]     = error;
  assign bpi_la_data[25]     = ack;
  assign bpi_la_data[27:26]  = read_mode;
  assign bpi_la_data[28]     = load_n;
  assign bpi_la_data[29]     = BPI_BUSY;
  assign bpi_la_data[30]     = BPI_EXECUTE;
  assign bpi_la_data[31]     = BPI_LOAD_DATA;
  assign bpi_la_data[47:32]  = BPI_DATA_FROM;
  assign bpi_la_data[63:48]  = BPI_DATA_TO;
  assign bpi_la_data[65:64]  = BPI_OP;
  assign bpi_la_data[88:66]  = BPI_ADDR;
  assign bpi_la_data[89]     = cycle2;
  assign bpi_la_data[90]     = decr;
  assign bpi_la_data[91]     = next;
  assign bpi_la_data[92]     = term_cnt;
  assign bpi_la_data[93]     = two_cycle;
  assign bpi_la_data[94]     = local_rst;
  assign bpi_la_data[95]     = read_n;
  assign bpi_la_data[99:96]  = ctrl_state;
  assign bpi_la_data[104:100]= usr_cmnd;
  assign bpi_la_data[120:105]= data_fifo;
  assign bpi_la_data[124:121]= parse_state;
  assign bpi_la_data[125]    = bpi_cmd_mt;
  assign bpi_la_data[126]    = bpi_rdena;
  assign bpi_la_data[127]    = bpi_wrena;
  assign bpi_la_data[143:128]= bpi_wrt_data;
  assign bpi_la_data[144]    = bpi_rbk_empty;
  assign bpi_la_data[145]    = usr_read_req;
  assign bpi_la_data[146]    = bpi_rbk_wena;
  assign bpi_la_data[147]    = BPI_RE;
  assign bpi_la_data[163:148]= BPI_RBK_FIFO_DATA;

// LA Trigger [7:0]
  assign bpi_la_trig[0]      = local_rst;
  assign bpi_la_trig[1]      = noop_seq;
  assign bpi_la_trig[2]      = BPI_EXECUTE;
  assign bpi_la_trig[3]      = bpi_rdena;
  assign bpi_la_trig[4]      = bpi_wrena;
  assign bpi_la_trig[5]      = bpi_rbk_empty;
  assign bpi_la_trig[6]      = bpi_rbk_wena;
  assign bpi_la_trig[7]      = BPI_RE;

end
else
begin : no_chipscope_bpi
  assign csp_start_offset    = 16'h0000;
  assign csp_data            = 16'h0000;
  assign csp_ncnt            = 16'h0000;
  assign csp_base_address    = 7'h00;
  assign csp_ctrl            = 0;
  assign csp_fifo_src        = 0;
  
  assign csp_usr_cmnd        = 5'h00;
  assign csp_ack             = 0;
  assign csp_bpi_wrena       = 0;
  assign csp_rbk_cnt_rst     = 0;
  assign csp_load_offset     = 0;
  assign csp_man_rst         = 0;
  assign csp_load_count      = 0;
end
endgenerate


always @*
begin
  case(command)
    NoOp:
      begin
        addr = bank_addr;
        data1 = 16'h0000;
        data2 = 16'h0000;
        two_cycle = 0;
      end
    Write_1, Write_n:
      begin
        addr = waddr;
        data1 = prog_data;
        data2 = 16'h0000;
        two_cycle = 0;
      end
    Read_1, Read_n:
      begin
        addr = read_es_state ? lk_stat_addr : waddr;   // seq_state
        data1 = 16'h0000;
        data2 = 16'h0000;
        two_cycle = 0;
      end
    Read_Array:
      begin
        addr = bank_addr;
        data1 = 16'h00FF;
        data2 = 16'h0000;
        two_cycle = 0;
      end
    Read_Status_Reg:
      begin
        addr = bank_addr;
        data1 = 16'h0070;
        data2 = 16'h0000;
        two_cycle = 0;
      end
    Read_Elec_Sig:
      begin
        addr = bank_addr;
        data1 = 16'h0090;
        data2 = 16'h0000;
        two_cycle = 0;
      end
    Read_CFI_Qry:
      begin
        addr = bank_addr;
        data1 = 16'h0098;
        data2 = 16'h0000;
        two_cycle = 0;
      end
    Clr_Status_Reg:
      begin
        addr = bank_addr;
        data1 = 16'h0050;
        data2 = 16'h0000;
        two_cycle = 0;
      end
    Block_Erase:
      begin
        addr = block_addr;
        data1 = 16'h0020;
        data2 = 16'h00D0;
        two_cycle = 1;
      end
    Program:
      begin
        addr = waddr;
        data1 = 16'h0040;
        data2 = prog_data;
        two_cycle = 1;
      end
    Buffer_Program:
      begin
        addr = block_addr;
        data1 = 16'h00E8;
        data2 = 16'h0000;
        two_cycle = 0;
      end
    Buf_Prog_Wrt_n:
      begin
        addr = block_addr;
        data1 = {11'h000,bcount};
        data2 = 16'h0000;
        two_cycle = 0;
      end
    Buf_Prog_Conf:
      begin
        addr = bank_addr;
        data1 = 16'h00D0;
        data2 = 16'h0000;
        two_cycle = 0;
      end
    PE_Susp:
      begin
        addr = bank_addr;
        data1 = 16'h00B0;
        data2 = 16'h0070;  // set status register read mode
        two_cycle = 1;
      end
    PE_Resume:
      begin
        addr = bank_addr;
        data1 = 16'h00D0;
        data2 = 16'h0000;
        two_cycle = 0;
      end
    Prot_Reg_Prog:
      begin
        addr = prot_reg_addr;
        data1 = 16'h00C0;
        data2 = prot_reg_data;
        two_cycle = 1;
      end
    Set_Cnfg_Reg:
      begin
        addr = {7'h00,cngf_reg_data};
        data1 = 16'h0060;
        data2 = 16'h0003;
        two_cycle = 1;
      end
    Block_Lock:
      begin
        addr = block_addr;
        data1 = 16'h0060;
        data2 = 16'h0001;
        two_cycle = 1;
      end
    Block_UnLock:
      begin
        addr = block_addr;
        data1 = 16'h0060;
        data2 = 16'h00D0;
        two_cycle = 1;
      end
    Block_Lock_Down:
      begin
        addr = block_addr;
        data1 = 16'h0060;
        data2 = 16'h002F;
        two_cycle = 1;
      end
    Blank_Check:
      begin
        addr = block_addr;
        data1 = 16'h00BC;
        data2 = 16'h00CB;
        two_cycle = 1;
      end
    default:
      begin
        addr = bank_addr;
        data1 = 16'h0000;
        data2 = 16'h0000;
        two_cycle = 0;
      end
  endcase
end

always @(posedge CLK)
begin
  case(command)
    Read_Array       : read_mode <= Rd_Array;
    Read_Status_Reg  : read_mode <= Rd_SR;
    Read_Elec_Sig    : read_mode <= Rd_ESig;
    Read_CFI_Qry     : read_mode <= Rd_CFIQ;
    Block_Erase,
    Program,
    Buffer_Program,
    Buf_Prog_Conf,
    PE_Susp,
    Prot_Reg_Prog,
    Set_Cnfg_Reg,
    Blank_Check      : read_mode <= Rd_SR;
    default          : read_mode <= read_mode;  //no change
  endcase
end

always @(posedge CLK)
begin
  if(BPI_LOAD_DATA ) begin
    if(read_mode == Rd_Array) begin
      if(rbk_count[2:0] == 3'd0) rbkbuf0 <= BPI_DATA_FROM;
      else rbkbuf0  <= rbkbuf0;
      if(rbk_count[2:0] == 3'd1) rbkbuf1 <= BPI_DATA_FROM;
      else rbkbuf1  <= rbkbuf1;
      if(rbk_count[2:0] == 3'd2) rbkbuf2 <= BPI_DATA_FROM;
      else rbkbuf2  <= rbkbuf2;
      if(rbk_count[2:0] == 3'd3) rbkbuf3 <= BPI_DATA_FROM;
      else rbkbuf3  <= rbkbuf3;
      if(rbk_count[2:0] == 3'd4) rbkbuf4 <= BPI_DATA_FROM;
      else rbkbuf4  <= rbkbuf4;
      if(rbk_count[2:0] == 3'd5) rbkbuf5 <= BPI_DATA_FROM;
      else rbkbuf5  <= rbkbuf5;
      if(rbk_count[2:0] == 3'd6) rbkbuf6 <= BPI_DATA_FROM;
      else rbkbuf6  <= rbkbuf6;
      if(rbk_count[2:0] == 3'd7) rbkbuf7 <= BPI_DATA_FROM;
      else rbkbuf7  <= rbkbuf7;
    end
    if(read_mode == Rd_SR) sr_reg     <= BPI_DATA_FROM[7:0];
    else sr_reg   <= sr_reg;
    if(read_mode == Rd_ESig) esig_reg <= BPI_DATA_FROM;
    else esig_reg <= esig_reg;
    if(read_mode == Rd_CFIQ) cfiq_reg <= BPI_DATA_FROM;
    else cfiq_reg <= cfiq_reg;
  end
end

always @(posedge CLK)
begin
   if(ld_usr) begin
    ff_usr_cmnd <= data_fifo[4:0];
    ff_ba_cnt   <= data_fifo[15:5];
  end
  else begin
    ff_usr_cmnd <= ff_usr_cmnd;
    ff_ba_cnt   <= ff_ba_cnt;
  end
end

always @(posedge CLK)
begin
  if((ff_usr_cmnd == Load_Address) && decode && !bpi_cmd_mt) begin
    ff_base_address <= ff_ba_cnt[6:0];
    ff_start_offset <= data_fifo;
  end
  else begin
    ff_base_address <= ff_base_address;
    ff_start_offset <= ff_start_offset;
  end
end
always @(posedge CLK)
begin
  if(cnt_cmd && decode) ff_n_minus_1 <= ff_ba_cnt;
  else             ff_n_minus_1 <= ff_n_minus_1;
  if((ff_usr_cmnd == Set_Cnfg_Reg) && decode && !bpi_cmd_mt) cngf_reg_data <= data_fifo;
  else  if(set_asynch)                  cngf_reg_data <= CRD_ASync;
  else                            cngf_reg_data <= cngf_reg_data;
end

always @(posedge CLK)
begin
  if(ld_cnts && ld_n32) begin
    count_mux <= 16'h0020;
    bcount <= 5'h1F;
  end
  else if(ld_cnts && ld_remainder) begin
    count_mux <= full_count;
    bcount <= n_minus_1[4:0];
  end
  else if((ld_full && (ff_usr_cmnd == Read_n)) || csp_load_count) begin
    count_mux <= ncnt;
    bcount <= n_minus_1[4:0];
  end
  else begin
    count_mux <= count_mux;
    bcount <= bcount;
  end
end

always @(posedge CLK or posedge local_rst)
begin
  if(local_rst)
    count <= 16'h0000;
  else
    if(load_n)
      count <= count_mux;
    else if(decr)
      count <= count - 1;
    else
      count <= count;
end
always @(posedge CLK or posedge local_rst)
begin
  if(local_rst)
    full_count <= 16'h0000;
  else
    if(ld_full || csp_load_count)
      full_count <= ncnt;
    else if(decr)
      full_count <= full_count - 1;
    else
      full_count <= full_count;
end
always @(posedge CLK or posedge rbk_cnt_rst)
begin
  if(rbk_cnt_rst)
    rbk_count <= 16'h0000;
  else
    if(next && (read_mode == Rd_Array))
      rbk_count <= rbk_count + 1;
    else
      rbk_count <= rbk_count;
end

always @(posedge CLK or posedge local_rst)
begin
  if(local_rst)
    adr_offset <= 16'h0000;
  else
    if(load_offset)
      adr_offset <= start_offset;
    else if(next)
      adr_offset <= adr_offset + 1;
    else
      adr_offset <= adr_offset;
end

// BPI status register: BEGIN ***************************************************
// - high 8 bits Ben                   0x8880 0x8000 0x000e
//      15 - rbk fifo empty              1      1      0
//      14 - rbk fifo full               0      0      0
//      13 - rbk fifo read error         0      0      0
//      12 - rbk fifo write error        0      0      0
//      11 - cmd fifo empty              1      0      0
//      10 - cmd fifo full               0      0      0
//       9 - cmd fifo read error         0      0      0
//       8 - cmd fifo write error        0      0      0
// - low 8 bits XLINK
//       7 - P.E.C. Status               1      0      0
//       6 - erase/suspend status        0      0      0
//       5 - erase/blank check status    0      0      0
//       4 - program status              0      0      0
//       3 - vpp status                  0      0      1
//       2 - program suspend status      0      0      1
//       1 - block protection status     0      0      1
//       0 - blank write status/multiple 0      0      0
//           work program status

always @(posedge CLK or posedge local_rst)
begin
  if(local_rst)
    BPI_STATUS <= 16'h0000;
  else
    if(ld_status)
    	begin
      	// BPI_STATUS <= {bpi_rbk_empty, bpi_rbk_full, bpi_rbk_rderr | BPI_STATUS[13], bpi_rbk_wrterr | BPI_STATUS[12], bpi_cmd_mt, bpi_cmd_full, bpi_rderr | BPI_STATUS[9], bpi_wrterr | BPI_STATUS[8], sr_reg};
      
      	BPI_STATUS[15]  <= bpi_rbk_empty;
      	BPI_STATUS[14]  <= bpi_rbk_full;
      	BPI_STATUS[13]  <= bpi_rbk_rderr  | BPI_STATUS[13];
      	BPI_STATUS[12]  <= bpi_rbk_wrterr | BPI_STATUS[12];
      	BPI_STATUS[11]  <= bpi_cmd_mt;
      	BPI_STATUS[10]  <= bpi_cmd_full;
      	BPI_STATUS[9]   <= bpi_rderr  | BPI_STATUS[9];
      	BPI_STATUS[8]   <= bpi_wrterr | BPI_STATUS[8];
      	BPI_STATUS[7:0] <= sr_reg;
      
      end
    else if(clr_error_bits)
    	begin
      	// BPI_STATUS <= {bpi_rbk_empty, bpi_rbk_full, 1'b0, 1'b0, bpi_cmd_mt, bpi_cmd_full, 1'b0, 1'b0, sr_reg[7:6], 3'b000, sr_reg[2], 1'b0, sr_reg[0]};
      	BPI_STATUS[15]  <= bpi_rbk_empty;
      	BPI_STATUS[14]  <= bpi_rbk_full;
      	BPI_STATUS[13]  <= 1'b0;
      	BPI_STATUS[12]  <= 1'b0;
      	BPI_STATUS[11]  <= bpi_cmd_mt;
      	BPI_STATUS[10]  <= bpi_cmd_full;
      	BPI_STATUS[9]   <= 1'b0;
      	BPI_STATUS[8]   <= 1'b0;
      	BPI_STATUS[7:6] <= sr_reg[7:6];
      	BPI_STATUS[5:3] <= 3'b000;
      	BPI_STATUS[2]   <= sr_reg[2];
      	BPI_STATUS[1]   <= 1'b0;
      	BPI_STATUS[0]   <= sr_reg[0];
      end
    else
    	begin
      	// BPI_STATUS <= {bpi_rbk_empty, bpi_rbk_full, bpi_rbk_rderr | BPI_STATUS[13], bpi_rbk_wrterr | BPI_STATUS[12], bpi_cmd_mt, bpi_cmd_full, bpi_rderr | BPI_STATUS[9], bpi_wrterr | BPI_STATUS[8], sr_reg[7:6], BPI_STATUS[5:3], sr_reg[2], BPI_STATUS[1], sr_reg[0]};
      	
      	                                                     // 
      	BPI_STATUS[15]  <= bpi_rbk_empty;                    // 
      	BPI_STATUS[14]  <= bpi_rbk_full;                     // 
      	BPI_STATUS[13]  <= bpi_rbk_rderr  | BPI_STATUS[13];  // 
      	BPI_STATUS[12]  <= bpi_rbk_wrterr | BPI_STATUS[12];  // 
      	BPI_STATUS[11]  <= bpi_cmd_mt;                       // 
      	BPI_STATUS[10]  <= bpi_cmd_full;                     // 
      	BPI_STATUS[9]   <= bpi_rderr  | BPI_STATUS[9];       // 
      	BPI_STATUS[8]   <= bpi_wrterr | BPI_STATUS[8];       // 
      	BPI_STATUS[7:6] <= sr_reg[7:6];                      // 
      	BPI_STATUS[5:3] <= BPI_STATUS[5:3];                  // 
      	BPI_STATUS[2]   <= sr_reg[2];                        // 
      	BPI_STATUS[1]   <= BPI_STATUS[1];                    // 
      	BPI_STATUS[0]   <= sr_reg[0];                        // 
      end
end

// BPI status register: END *****************************************************

always @(posedge CLK)
begin
    if(stop_tmr || rst_tmr)
      incr_tmr <= 0;
    else if(start_tmr)
      incr_tmr <= 1;
    else
      incr_tmr <= incr_tmr;
end
always @(posedge CLK1MHZ or posedge rst_tmr)
begin
  if(rst_tmr)  
    BPI_TIMER <= 32'h00000000;
  else
    if(incr_tmr)
      BPI_TIMER <= BPI_TIMER + 1;
    else
      BPI_TIMER <= BPI_TIMER;
end
always @(posedge CLK or posedge local_rst)
begin
  if(local_rst)
    bpi_enable <= 0;
  else
    if(csp_fifo_src)
      if(csp_bpi_enbl)
        bpi_enable <= 1;
      else if(csp_bpi_dsbl)
        bpi_enable <= 0;
      else
        bpi_enable <= bpi_enable;
    else
      if(BPI_ENBL)
        bpi_enable <= 1;
      else if(BPI_DSBL)
        bpi_enable <= 0;
      else
        bpi_enable <= bpi_enable;
end

//
// Command FIFO word counter
//
always @(posedge CLK or posedge local_rst)
begin
  if(local_rst)
    bpi_cmd_cnt <= 11'h000;
  else
    casex ({bpi_cmd_mt,bpi_cmd_full,bpi_wrena,bpi_rdena})
      4'b01x1,4'b0001:  bpi_cmd_cnt <= bpi_cmd_cnt - 1; // count down
      4'b101x,4'b0010:  bpi_cmd_cnt <= bpi_cmd_cnt + 1; // count up
      default:          bpi_cmd_cnt <= bpi_cmd_cnt;     // hold
    endcase
end  

//
// Readback FIFO word counter
//
always @(posedge CLK or posedge local_rst)
begin
  if(local_rst)
    bpi_rbk_cnt <= 11'h000;
  else
    casex ({bpi_rbk_empty,bpi_rbk_full,bpi_rbk_wena,BPI_RE})
      4'b01x1,4'b0001:  bpi_rbk_cnt <= bpi_rbk_cnt - 1; // count down
      4'b101x,4'b0010:  bpi_rbk_cnt <= bpi_rbk_cnt + 1; // count up
      default:          bpi_rbk_cnt <= bpi_rbk_cnt;     // hold
    endcase
end  
   /////////////////////////////////////////////////////////////////
   // DATA_WIDTH | FIFO_SIZE | FIFO Depth | RDCOUNT/WRCOUNT Width //
   // ===========|===========|============|=======================//
   //   37-72    |  "36Kb"   |     512    |         9-bit         //
   //   19-36    |  "36Kb"   |    1024    |        10-bit         //
   //   19-36    |  "18Kb"   |     512    |         9-bit         //
   //   10-18    |  "36Kb"   |    2048    |        11-bit         //
   //   10-18    |  "18Kb"   |    1024    |        10-bit         //
   //    5-9     |  "36Kb"   |    4096    |        12-bit         //
   //    5-9     |  "18Kb"   |    2048    |        11-bit         //
   //    1-4     |  "36Kb"   |    8192    |        13-bit         //
   //    1-4     |  "18Kb"   |    4096    |        12-bit         //
   /////////////////////////////////////////////////////////////////
  
  //
  // BPI Command FIFO  (holds commands to be executed -- either local or for the BPI PROM)
  //                    disable the parsing of commands while FIFO is being filled
   //

   FIFO_DUALCLOCK_MACRO  #(
      .ALMOST_EMPTY_OFFSET(11'h040),    // Sets the almost empty threshold
      .ALMOST_FULL_OFFSET(11'h080),     // Sets almost full threshold
      .DATA_WIDTH(16),                  // Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
      .DEVICE("VIRTEX6"),               // Target device: "VIRTEX5", "VIRTEX6" 
      .FIFO_SIZE ("36Kb"),              // Target BRAM: "18Kb" or "36Kb" 
      .FIRST_WORD_FALL_THROUGH ("TRUE") // Sets the FIFO FWFT to "TRUE" or "FALSE" 
   ) BPI_CMD_FIFO_i (
      .ALMOSTEMPTY(bpi_cmd_amt), // 1-bit output almost empty
      .ALMOSTFULL(bpi_cmd_afl),  // 1-bit output almost full
      .DO(data_fifo),            // Output data, width defined by DATA_WIDTH parameter
      .EMPTY(bpi_cmd_mt),        // 1-bit output empty
      .FULL(bpi_cmd_full),       // 1-bit output full
      .RDCOUNT(bpi_rdcnt),       // Output read count, width determined by FIFO depth
      .RDERR(bpi_rderr),         // 1-bit output read error
      .WRCOUNT(bpi_wrtcnt),      // Output write count, width determined by FIFO depth
      .WRERR(bpi_wrterr),        // 1-bit output write error
      .DI(bpi_wrt_data),         // Input data, width defined by DATA_WIDTH parameter
      .RDCLK(CLK),               // 1-bit input read clock
      .RDEN(bpi_rdena),          // 1-bit input read enable
//      .RST(local_rst),           // 1-bit input reset
      .RST(local_rst_long),           // 1-bit input reset
      .WRCLK(CLK),               // 1-bit input write clock
      .WREN(bpi_wrena)           // 1-bit input write enable
   );
  
  //
  // BPI Readback FIFO (holds data read back from the BPI PROM until read by VME)
  //

   FIFO_DUALCLOCK_MACRO  #(
      .ALMOST_EMPTY_OFFSET(11'h040),    // Sets the almost empty threshold
      .ALMOST_FULL_OFFSET(11'h080),     // Sets almost full threshold
      .DATA_WIDTH(16),                  // Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
      .DEVICE("VIRTEX6"),               // Target device: "VIRTEX5", "VIRTEX6" 
      .FIFO_SIZE ("36Kb"),              // Target BRAM: "18Kb" or "36Kb" 
      .FIRST_WORD_FALL_THROUGH ("TRUE") // Sets the FIFO FWFT to "TRUE" or "FALSE" 
   ) BPI_rbk_FIFO_data_i (
      .ALMOSTEMPTY(bpi_rbk_amt), // 1-bit output almost empty
      .ALMOSTFULL(bpi_rbk_afl),  // 1-bit output almost full
      .DO(BPI_RBK_FIFO_DATA),    // Output data, width defined by DATA_WIDTH parameter
      .EMPTY(bpi_rbk_empty),     // 1-bit output empty
      .FULL(bpi_rbk_full),       // 1-bit output full
      .RDCOUNT(bpi_rbk_rdcnt),   // Output read count, width determined by FIFO depth
      .RDERR(bpi_rbk_rderr),     // 1-bit output read error
      .WRCOUNT(bpi_rbk_wrtcnt),  // Output write count, width determined by FIFO depth
      .WRERR(bpi_rbk_wrterr),    // 1-bit output write error
      .DI(BPI_DATA_FROM),        // Input data, width defined by DATA_WIDTH parameter
      .RDCLK(CLK),               // 1-bit input read clock
      .RDEN(BPI_RE),             // 1-bit input read enable
//      .RST(local_rst),           // 1-bit input reset
      .RST(local_rst_long),           // 1-bit input reset
      .WRCLK(CLK),               // 1-bit input write clock
      .WREN(bpi_rbk_wena)        // 1-bit input write enable
   );


BPI_cmd_parser_FSM BPI_cmd_parser_FSM_i(
  .ACK(fsm_ack),
  .DECODE(decode),
  .ENABLE_CMD(enable_cmd),
  .IDLE(parser_idle),
  .LD_CNTS(ld_cnts),
  .LD_FULL(ld_full),
  .LD_STATUS(ld_status),
  .LD_USR(ld_usr),
  .READ_FF(read_ff),
  .OUT_STATE(parse_state),
  //
  .BUF_PROG(buf_prog),
  .CLK(CLK),
  .CNT_CMD(cnt_cmd),
  .ENABLE(!csp_ctrl && bpi_enable),
  .DATA(has_data),
  .LOCAL(local),
  .LOOP_DONE(loop_done),
  .MT(bpi_cmd_mt),
  .PASS(pass),
  .READ_N(read_n),
  .RPT_ERROR(rpt_error),
  .RST(local_rst),
  .SEQR_IDLE(seqr_idle),
  .SEQ_CMPLT(seq_cmplt),
  .XTRA_WORD(xtra_word)
);

BPI_sequencer_FSM BPI_sequencer_FSM_i(
   .check_PEC(check_PEC),
   .check_buf(check_buf),
   .check_stat(check_stat),
   .cnfrm_lk(cnfrm_lk),
   .command(command),
   .read_es_state(read_es_state),
   .rpt_error(rpt_error),
   .seq_cmplt(seq_cmplt),
   .seqr_idle(seqr_idle),
   .set_asynch(set_asynch),
   .OUT_STATE(seq_state),
   .CLK(CLK),
   .RST(local_rst),
   .ack(ack),
   .buf_prog(buf_prog),
   .error(error),
   .lk_ok(lk_ok),
   .lk_unlk(lk_unlk),
   .noop_seq(noop_seq),
   .pec_busy(pec_busy),
  .seq_cmnd(seq_cmnd),
   .seq_done(seq_done),
   .simple_cmd(simple_cmd),
   .std_seq(std_seq)
);

BPI_ctrl_FSM BPI_ctrl_FSM_i(
  .CYCLE2(cycle2),
  .DECR(decr),
  .EXECUTE(BPI_EXECUTE),
  .LOAD_N(load_n),
  .NEXT(next),
  .SEQ_DONE(seq_done),
  .OUT_STATE(ctrl_state),
  //
  .BUSY(intf_busy),
  .CLK(CLK),
  .LD_DAT(BPI_LOAD_DATA),
  .MT(bpi_cmd_mt),
  .NOOP(noop),
  .OTHER(other),
  .RDY(intf_rdy),
  .READ_1(read_1),
  .READ_N(read_n),
  .RST(local_rst),
  .TERM_CNT(term_cnt),
  .TWO_CYCLE(two_cycle),
  .WRITE_N(write_n)
);

endmodule
