
// Created by fizzim.pl version 4.41 on 2013:01:30 at 11:47:11 (www.fizzim.com)

module BPI_cmd_parser_FSM (
  output reg ACK,
  output reg DECODE,
  output reg ENABLE_CMD,
  output reg IDLE,
  output reg LD_CNTS,
  output reg LD_FULL,
  output reg LD_STATUS,
  output reg LD_USR,
  output reg READ_FF,
  output wire [3:0] OUT_STATE,
  input BUF_PROG,
  input CLK,
  input CNT_CMD,
  input DATA,
  input ENABLE,
  input LOCAL,
  input LOOP_DONE,
  input MT,
  input PASS,
  input READ_N,
  input RPT_ERROR,
  input RST,
  input SEQR_IDLE,
  input SEQ_CMPLT,
  input XTRA_WORD 
);
  
  // state bits
  parameter 
  Idle          = 4'b0000, 
  Ack           = 4'b0001, 
  Dcd_n_Ld      = 4'b0010, 
  Exec_1Data    = 4'b0011, 
  Exec_Buf32    = 4'b0100, 
  Exec_Local    = 4'b0101, 
  Exec_Pass     = 4'b0110, 
  Load_Cmd      = 4'b0111, 
  Load_Cnts     = 4'b1000, 
  Load_Full     = 4'b1001, 
  Read_FF       = 4'b1010, 
  Update_Status = 4'b1011, 
  Wait4Seq      = 4'b1100; 
  
  reg [3:0] state;
  assign OUT_STATE = state;
  reg [3:0] nextstate;
  
  // comb always block
  always @* begin
    nextstate = 4'bxxxx; // default to x because default_state_is_x is set
    ACK = 0; // default
    DECODE = 0; // default
    ENABLE_CMD = 0; // default
    IDLE = 0; // default
    LD_CNTS = 0; // default
    LD_FULL = 0; // default
    LD_STATUS = 0; // default
    LD_USR = 0; // default
    READ_FF = 0; // default
    case (state)
      Idle         : begin
                                                                    IDLE = 1;
        if                   (!MT && ENABLE && SEQR_IDLE)           nextstate = Load_Cmd;
        else                                                        nextstate = Idle;
      end
      Ack          : begin
                                                                    ACK = 1;
        if                   (!RPT_ERROR)                           nextstate = Wait4Seq;
        else                                                        nextstate = Ack;
      end
      Dcd_n_Ld     : begin
                                                                    DECODE = 1;
        if                   (PASS)                                 nextstate = Exec_Pass;
        else if              (CNT_CMD)                              nextstate = Load_Full;
        else if              (DATA && !MT)                          nextstate = Exec_1Data;
        else if              (LOCAL && !XTRA_WORD)                  nextstate = Exec_Local;
        else if              (LOCAL && XTRA_WORD && !MT)            nextstate = Exec_Local;
        else if              (!DATA && !LOCAL)                      nextstate = Idle;
        else                                                        nextstate = Dcd_n_Ld;
      end
      Exec_1Data   : begin
                                                                    ENABLE_CMD = 1;
        if                   (RPT_ERROR)                            nextstate = Update_Status;
        else if              (SEQ_CMPLT)                            nextstate = Read_FF;
        else                                                        nextstate = Exec_1Data;
      end
      Exec_Buf32   : begin
                                                                    ENABLE_CMD = 1;
        if                   (RPT_ERROR)                            nextstate = Update_Status;
        else if              (SEQ_CMPLT && LOOP_DONE)               nextstate = Idle;
        else if              (SEQ_CMPLT)                            nextstate = Load_Cnts;
        else                                                        nextstate = Exec_Buf32;
      end
      Exec_Local   : begin
                                                                    ENABLE_CMD = 1;
        if                   (XTRA_WORD)                            nextstate = Read_FF;
        else                                                        nextstate = Idle;
      end
      Exec_Pass    : begin
                                                                    ENABLE_CMD = 1;
        if                   (RPT_ERROR)                            nextstate = Update_Status;
        else if              (SEQ_CMPLT)                            nextstate = Idle;
        else                                                        nextstate = Exec_Pass;
      end
      Load_Cmd     : begin
                                                                    LD_USR = 1;
                                                                    READ_FF = 1;
                                                                    nextstate = Dcd_n_Ld;
      end
      Load_Cnts    : begin
                                                                    LD_CNTS = 1;
                                                                    nextstate = Exec_Buf32;
      end
      Load_Full    : begin
                                                                    LD_FULL = 1;
        if                   (READ_N)                               nextstate = Exec_Pass;
        else                                                        nextstate = Load_Cnts;
      end
      Read_FF      : begin
                                                                    READ_FF = 1;
                                                                    nextstate = Idle;
      end
      Update_Status: begin
                                                                    LD_STATUS = 1;
                                                                    nextstate = Ack;
      end
      Wait4Seq     : if      (SEQ_CMPLT && BUF_PROG && !LOOP_DONE)  nextstate = Load_Cnts;
                     else if (SEQ_CMPLT && XTRA_WORD)               nextstate = Read_FF;
                     else if (SEQ_CMPLT)                            nextstate = Idle;
                     else                                           nextstate = Wait4Seq;
    endcase
  end
  
  // Assign reg'd outputs to state bits
  
  // sequential always block
  always @(posedge CLK or posedge RST) begin
    if (RST)
      state <= Idle;
    else
      state <= nextstate;
  end
  
  // This code allows you to see state names in simulation
  `ifndef SYNTHESIS
  reg [103:0] statename;
  always @* begin
    case (state)
      Idle         : statename = "Idle";
      Ack          : statename = "Ack";
      Dcd_n_Ld     : statename = "Dcd_n_Ld";
      Exec_1Data   : statename = "Exec_1Data";
      Exec_Buf32   : statename = "Exec_Buf32";
      Exec_Local   : statename = "Exec_Local";
      Exec_Pass    : statename = "Exec_Pass";
      Load_Cmd     : statename = "Load_Cmd";
      Load_Cnts    : statename = "Load_Cnts";
      Load_Full    : statename = "Load_Full";
      Read_FF      : statename = "Read_FF";
      Update_Status: statename = "Update_Status";
      Wait4Seq     : statename = "Wait4Seq";
      default      : statename = "XXXXXXXXXXXXX";
    endcase
  end
  `endif

endmodule

