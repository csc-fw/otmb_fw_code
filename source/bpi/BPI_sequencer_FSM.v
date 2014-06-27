
// Created by fizzim.pl version 4.41 on 2013:01:30 at 11:41:49 (www.fizzim.com)

module BPI_sequencer_FSM (
  output reg check_PEC,
  output reg check_buf,
  output reg check_stat,
  output reg cnfrm_lk,
  output reg [4:0] command,
  output reg read_es_state,
  output reg rpt_error,
  output reg seq_cmplt,
  output reg seqr_idle,
  output reg set_asynch,
  output wire [4:0] OUT_STATE,
  input CLK,
  input RST,
  input ack,
  input buf_prog,
  input error,
  input lk_ok,
  input lk_unlk,
  input noop_seq,
  input pec_busy,
  input wire [4:0] seq_cmnd,
  input seq_done,
  input simple_cmd,
  input std_seq 
);
  
  // Inserted from attribute insert_at_top_of_module:
  localparam // commands 
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
    Load_Address    = 5'h17, 
    Unassigned      = 5'h18, 
    Start_Timer     = 5'h19, 
    Stop_Timer      = 5'h1A, 
    Reset_Timer     = 5'h1B, 
    Clr_BPI_Status  = 5'h1C; 
  
  // state bits
  parameter 
  Reset         = 5'b00000, 
  Buf_Prg_Cnf   = 5'b00001, 
  Buf_Prog      = 5'b00010, 
  Buf_Prog_n    = 5'b00011, 
  Check_Buf     = 5'b00100, 
  Check_PEC     = 5'b00101, 
  Check_Stat    = 5'b00110, 
  Clr_SR        = 5'b00111, 
  Cnfrm_LK      = 5'b01000, 
  Complete      = 5'b01001, 
  Idle          = 5'b01010, 
  Issue_Cmd     = 5'b01011, 
  Issue_LK_UnLK = 5'b01100, 
  NoOp1         = 5'b01101, 
  NoOp2         = 5'b01110, 
  NoOp3         = 5'b01111, 
  NoOp4         = 5'b10000, 
  NoOp5         = 5'b10001, 
  NoOp6         = 5'b10010, 
  NoOp7         = 5'b10011, 
  RES_mode      = 5'b10100, 
  Rd_Array_Mode = 5'b10101, 
  Read_Buf_Stat = 5'b10110, 
  Read_ES       = 5'b10111, 
  Read_Status   = 5'b11000, 
  Rpt_Error     = 5'b11001, 
  Set_Asynch    = 5'b11010, 
  Simple_Cmd    = 5'b11011, 
  Write_n_Wrds  = 5'b11100; 
  
  reg [4:0] state;
  assign OUT_STATE = state;
  reg [4:0] nextstate;
  
  // comb always block
  always @* begin
    nextstate = 5'bxxxxx; // default to x because default_state_is_x is set
    check_PEC = 0; // default
    check_buf = 0; // default
    check_stat = 0; // default
    cnfrm_lk = 0; // default
    read_es_state = 0; // default
    rpt_error = 0; // default
    seq_cmplt = 0; // default
    seqr_idle = 0; // default
    set_asynch = 0; // default
    case (state)
      Reset        :                  nextstate = Set_Asynch;
      Buf_Prg_Cnf  : if (seq_done)    nextstate = NoOp5;
                     else             nextstate = Buf_Prg_Cnf;
      Buf_Prog     : if (seq_done)    nextstate = NoOp2;
                     else             nextstate = Buf_Prog;
      Buf_Prog_n   : if (seq_done)    nextstate = NoOp3;
                     else             nextstate = Buf_Prog_n;
      Check_Buf    : begin
                                      check_buf = 1;
        if              (pec_busy)    nextstate = Buf_Prog;
        else                          nextstate = Buf_Prog_n;
      end
      Check_PEC    : begin
                                      check_PEC = 1;
        if              (pec_busy)    nextstate = Read_Status;
        else                          nextstate = Check_Stat;
      end
      Check_Stat   : begin
                                      check_stat = 1;
        if              (error)       nextstate = Rpt_Error;
        else                          nextstate = NoOp1;
      end
      Clr_SR       : if (seq_done)    nextstate = NoOp1;
                     else             nextstate = Clr_SR;
      Cnfrm_LK     : begin
                                      cnfrm_lk = 1;
        if              (lk_ok)       nextstate = NoOp1;
        else                          nextstate = Issue_LK_UnLK;
      end
      Complete     : begin
                                      seq_cmplt = 1;
        if              (noop_seq)    nextstate = Idle;
        else                          nextstate = Complete;
      end
      Idle         : begin
                                      seqr_idle = 1;
        if              (lk_unlk)     nextstate = Issue_LK_UnLK;
        else if         (buf_prog)    nextstate = Buf_Prog;
        else if         (std_seq)     nextstate = Issue_Cmd;
        else if         (simple_cmd)  nextstate = Simple_Cmd;
        else                          nextstate = Idle;
      end
      Issue_Cmd    : if (seq_done)    nextstate = NoOp5;
                     else             nextstate = Issue_Cmd;
      Issue_LK_UnLK: if (seq_done)    nextstate = NoOp6;
                     else             nextstate = Issue_LK_UnLK;
      NoOp1        :                  nextstate = Rd_Array_Mode;
      NoOp2        :                  nextstate = Read_Buf_Stat;
      NoOp3        :                  nextstate = Write_n_Wrds;
      NoOp4        :                  nextstate = Buf_Prg_Cnf;
      NoOp5        :                  nextstate = Read_Status;
      NoOp6        :                  nextstate = RES_mode;
      NoOp7        :                  nextstate = Read_ES;
      RES_mode     : if (seq_done)    nextstate = NoOp7;
                     else             nextstate = RES_mode;
      Rd_Array_Mode: if (seq_done)    nextstate = Complete;
                     else             nextstate = Rd_Array_Mode;
      Read_Buf_Stat: if (seq_done)    nextstate = Check_Buf;
                     else             nextstate = Read_Buf_Stat;
      Read_ES      : begin
                                      read_es_state = 1;
        if              (seq_done)    nextstate = Cnfrm_LK;
        else                          nextstate = Read_ES;
      end
      Read_Status  : if (seq_done)    nextstate = Check_PEC;
                     else             nextstate = Read_Status;
      Rpt_Error    : begin
                                      rpt_error = 1;
        if              (ack)         nextstate = Clr_SR;
        else                          nextstate = Rpt_Error;
      end
      Set_Asynch   : begin
                                      set_asynch = 1;
        if              (seq_done)    nextstate = NoOp1;
        else                          nextstate = Set_Asynch;
      end
      Simple_Cmd   : if (seq_done)    nextstate = Complete;
                     else             nextstate = Simple_Cmd;
      Write_n_Wrds : if (seq_done)    nextstate = NoOp4;
                     else             nextstate = Write_n_Wrds;
    endcase
  end
  
  // Assign reg'd outputs to state bits
  
  // sequential always block
  always @(posedge CLK or posedge RST) begin
    if (RST)
      state <= Reset;
    else
      state <= nextstate;
  end
  
  // datapath sequential always block
  always @(posedge CLK or posedge RST) begin
    if (RST)     command[4:0] <= 5'b00000;
    else begin
      command[4:0] <= 5'b00000; // default
      case (nextstate)
        Buf_Prg_Cnf  : command[4:0] <= Buf_Prog_Conf;
        Buf_Prog     : command[4:0] <= Buffer_Program;
        Buf_Prog_n   : command[4:0] <= Buf_Prog_Wrt_n;
        Clr_SR       : command[4:0] <= Clr_Status_Reg;
        Issue_Cmd    : command[4:0] <= seq_cmnd;
        Issue_LK_UnLK: command[4:0] <= seq_cmnd;
        RES_mode     : command[4:0] <= Read_Elec_Sig;
        Rd_Array_Mode: command[4:0] <= Read_Array;
        Read_Buf_Stat: command[4:0] <= Read_1;
        Read_ES      : command[4:0] <= Read_1;
        Read_Status  : command[4:0] <= Read_1;
        Set_Asynch   : command[4:0] <= Set_Cnfg_Reg;
        Simple_Cmd   : command[4:0] <= seq_cmnd;
        Write_n_Wrds : command[4:0] <= Write_n;
      endcase
    end
  end
  
  // This code allows you to see state names in simulation
  `ifndef SYNTHESIS
  reg [103:0] statename;
  always @* begin
    case (state)
      Reset        : statename = "Reset";
      Buf_Prg_Cnf  : statename = "Buf_Prg_Cnf";
      Buf_Prog     : statename = "Buf_Prog";
      Buf_Prog_n   : statename = "Buf_Prog_n";
      Check_Buf    : statename = "Check_Buf";
      Check_PEC    : statename = "Check_PEC";
      Check_Stat   : statename = "Check_Stat";
      Clr_SR       : statename = "Clr_SR";
      Cnfrm_LK     : statename = "Cnfrm_LK";
      Complete     : statename = "Complete";
      Idle         : statename = "Idle";
      Issue_Cmd    : statename = "Issue_Cmd";
      Issue_LK_UnLK: statename = "Issue_LK_UnLK";
      NoOp1        : statename = "NoOp1";
      NoOp2        : statename = "NoOp2";
      NoOp3        : statename = "NoOp3";
      NoOp4        : statename = "NoOp4";
      NoOp5        : statename = "NoOp5";
      NoOp6        : statename = "NoOp6";
      NoOp7        : statename = "NoOp7";
      RES_mode     : statename = "RES_mode";
      Rd_Array_Mode: statename = "Rd_Array_Mode";
      Read_Buf_Stat: statename = "Read_Buf_Stat";
      Read_ES      : statename = "Read_ES";
      Read_Status  : statename = "Read_Status";
      Rpt_Error    : statename = "Rpt_Error";
      Set_Asynch   : statename = "Set_Asynch";
      Simple_Cmd   : statename = "Simple_Cmd";
      Write_n_Wrds : statename = "Write_n_Wrds";
      default      : statename = "XXXXXXXXXXXXX";
    endcase
  end
  `endif

endmodule

