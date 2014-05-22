
// Created by fizzim.pl version 4.41 on 2013:01:29 at 14:24:02 (www.fizzim.com)

module BPI_ctrl_FSM (
  output reg CYCLE2,
  output reg DECR,
  output reg EXECUTE,
  output reg LOAD_N,
  output reg NEXT,
  output reg SEQ_DONE,
  output wire [3:0] OUT_STATE,
  input BUSY,
  input CLK,
  input LD_DAT,
  input MT,
  input NOOP,
  input OTHER,
  input RDY,
  input READ_1,
  input READ_N,
  input RST,
  input TERM_CNT,
  input TWO_CYCLE,
  input WRITE_N 
);
  
  // state bits
  parameter 
  Idle           = 4'b0000, 
  Decr           = 4'b0001, 
  Ex_2nd_Cycle   = 4'b0010, 
  Ex_First_Cycle = 4'b0011, 
  Ex_RW          = 4'b0100, 
  Load_n         = 4'b0101, 
  Next           = 4'b0110, 
  Seq_Done       = 4'b0111, 
  Wait4Data      = 4'b1000, 
  Wait4Rdy1      = 4'b1001, 
  Wait4Rdy2      = 4'b1010, 
  Wait4RdyRW     = 4'b1011; 
  
  reg [3:0] state;
  assign OUT_STATE = state;
  reg [3:0] nextstate;
  
  // comb always block
  always @* begin
    nextstate = 4'bxxxx; // default to x because default_state_is_x is set
    CYCLE2 = 0; // default
    DECR = 0; // default
    EXECUTE = 0; // default
    LOAD_N = 0; // default
    NEXT = 0; // default
    SEQ_DONE = 0; // default
    case (state)
      Idle          : if      (WRITE_N || READ_N)     nextstate = Load_n;
                      else if (OTHER)                 nextstate = Wait4Rdy1;
                      else                            nextstate = Idle;
      Decr          : begin
                                                      DECR = 1;
                                                      nextstate = Next;
      end
      Ex_2nd_Cycle  : begin
                                                      CYCLE2 = 1;
                                                      EXECUTE = 1;
        if                    (BUSY)                  nextstate = Seq_Done;
        else                                          nextstate = Ex_2nd_Cycle;
      end
      Ex_First_Cycle: begin
                                                      EXECUTE = 1;
        if                    (BUSY && TWO_CYCLE)     nextstate = Wait4Rdy2;
        else if               (BUSY && READ_1)        nextstate = Wait4Data;
        else if               (BUSY)                  nextstate = Seq_Done;
        else                                          nextstate = Ex_First_Cycle;
      end
      Ex_RW         : begin
                                                      EXECUTE = 1;
        if                    (BUSY && READ_N)        nextstate = Wait4Data;
        else if               (BUSY)                  nextstate = Decr;
        else                                          nextstate = Ex_RW;
      end
      Load_n        : begin
                                                      LOAD_N = 1;
                                                      nextstate = Wait4RdyRW;
      end
      Next          : begin
                                                      NEXT = 1;
        if                    (TERM_CNT)              nextstate = Seq_Done;
        else                                          nextstate = Wait4RdyRW;
      end
      Seq_Done      : begin
                                                      SEQ_DONE = 1;
        if                    (NOOP)                  nextstate = Idle;
        else                                          nextstate = Seq_Done;
      end
      Wait4Data     : if      (LD_DAT && READ_N)      nextstate = Decr;
                      else if (LD_DAT && READ_1)      nextstate = Seq_Done;
                      else                            nextstate = Wait4Data;
      Wait4Rdy1     : if      (RDY)                   nextstate = Ex_First_Cycle;
                      else                            nextstate = Wait4Rdy1;
      Wait4Rdy2     : begin
                                                      CYCLE2 = 1;
        if                    (RDY)                   nextstate = Ex_2nd_Cycle;
        else                                          nextstate = Wait4Rdy2;
      end
      Wait4RdyRW    : if      (RDY && READ_N)         nextstate = Ex_RW;
                      else if (RDY & WRITE_N && !MT)  nextstate = Ex_RW;
                      else                            nextstate = Wait4RdyRW;
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
  reg [111:0] statename;
  always @* begin
    case (state)
      Idle          : statename = "Idle";
      Decr          : statename = "Decr";
      Ex_2nd_Cycle  : statename = "Ex_2nd_Cycle";
      Ex_First_Cycle: statename = "Ex_First_Cycle";
      Ex_RW         : statename = "Ex_RW";
      Load_n        : statename = "Load_n";
      Next          : statename = "Next";
      Seq_Done      : statename = "Seq_Done";
      Wait4Data     : statename = "Wait4Data";
      Wait4Rdy1     : statename = "Wait4Rdy1";
      Wait4Rdy2     : statename = "Wait4Rdy2";
      Wait4RdyRW    : statename = "Wait4RdyRW";
      default       : statename = "XXXXXXXXXXXXXX";
    endcase
  end
  `endif

endmodule

