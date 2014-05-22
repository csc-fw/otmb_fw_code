
// Created by fizzim.pl version 4.41 on 2014:01:20 at 13:16:14 (www.fizzim.com)

module BPI_intrf_FSM (
  output reg BUSY,
  output reg CAP,
  output reg E,
  output reg G,
  output reg L,
  output reg LOAD,
  output reg W,
  input CLK,
  input EXECUTE,
  input READ,
  input RST,
  input WRITE 
);
  
  // state bits
  parameter 
  Standby    = 4'b0000, 
  Capture    = 4'b0001, 
  Latch_Addr = 4'b0010, 
  Load       = 4'b0011, 
  WE1        = 4'b0100, 
  WE2        = 4'b0101, 
  Wait1      = 4'b0110, 
  Wait2      = 4'b0111, 
  Wait3      = 4'b1000, 
  Wait4      = 4'b1001; 
  
  reg [3:0] state;
  reg [3:0] nextstate;
  
  // comb always block
  always @* begin
    nextstate = 4'bxxxx; // default to x because default_state_is_x is set
    case (state)
      Standby   : if      (EXECUTE)          nextstate = Capture;
                  else                       nextstate = Standby;
      Capture   :                            nextstate = Latch_Addr;
      Latch_Addr: if      (READ && WRITE)    nextstate = Standby;
                  else if (WRITE)            nextstate = WE1;
                  else if (READ)             nextstate = Wait1;
                  else if (!READ && !WRITE)  nextstate = Standby;
      Load      :                            nextstate = Wait4;
      WE1       :                            nextstate = WE2;
      WE2       :                            nextstate = Standby;
      Wait1     :                            nextstate = Wait2;
      Wait2     :                            nextstate = Wait3;
      Wait3     :                            nextstate = Load;
      Wait4     :                            nextstate = Standby;
    endcase
  end
  
  // Assign reg'd outputs to state bits
  
  // sequential always block
  always @(posedge CLK or posedge RST) begin
    if (RST)
      state <= Standby;
    else
      state <= nextstate;
  end
  
  // datapath sequential always block
  always @(posedge CLK or posedge RST) begin
    if (RST) begin
      BUSY <= 0;
      CAP <= 0;
      E <= 0;
      G <= 0;
      L <= 0;
      LOAD <= 0;
      W <= 0;
    end
    else begin
      BUSY <= 1; // default
      CAP <= 0; // default
      E <= 0; // default
      G <= 0; // default
      L <= 0; // default
      LOAD <= 0; // default
      W <= 0; // default
      case (nextstate)
        Standby   :        BUSY <= 0;
        Capture   :        CAP <= 1;
        Latch_Addr: begin
                           E <= 1;
                           L <= 1;
        end
        Load      : begin
                           E <= 1;
                           G <= 1;
                           LOAD <= 1;
        end
        WE1       : begin
                           E <= 1;
                           W <= 1;
        end
        WE2       : begin
                           E <= 1;
                           W <= 1;
        end
        Wait1     : begin
                           E <= 1;
                           G <= 1;
        end
        Wait2     : begin
                           E <= 1;
                           G <= 1;
        end
        Wait3     : begin
                           E <= 1;
                           G <= 1;
        end
        Wait4     : begin
                           E <= 1;
                           G <= 1;
        end
      endcase
    end
  end
  
  // This code allows you to see state names in simulation
  `ifndef SYNTHESIS
  reg [79:0] statename;
  always @* begin
    case (state)
      Standby   : statename = "Standby";
      Capture   : statename = "Capture";
      Latch_Addr: statename = "Latch_Addr";
      Load      : statename = "Load";
      WE1       : statename = "WE1";
      WE2       : statename = "WE2";
      Wait1     : statename = "Wait1";
      Wait2     : statename = "Wait2";
      Wait3     : statename = "Wait3";
      Wait4     : statename = "Wait4";
      default   : statename = "XXXXXXXXXX";
    endcase
  end
  `endif

endmodule

