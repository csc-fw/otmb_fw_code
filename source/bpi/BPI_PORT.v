`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The Ohio State University
// Engineer: Ben Bylsma
// 
// Create Date:    11:48:23 03/12/2013 
// Design Name: 
// Module Name:    BPI_PORT  -- JRG: this is the VME interface for the BPI engine
// Project Name:   ODMB
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
//  VME commands for BPI interface
//  Address  Command   Description
//  -----------------------------------
//   0x020      8     Reset BPI interface state machines (no data)
//   0x024      9     Disable parsing commands in the command FIFO (while filling FIFO with commands) (no data)
//   0x028     10     Enable parsing commands in the command FIFO (no data)
//   0x02C     11     Write one word to command FIFO (16 bits)
//   0x030     12     Read one word from readback FIFO (16 bits)
//   0x034     13     Read word count of words remaining in readback FIFO (11 bits)
//   0x038     14     Read BPI interface status register (16 bits)
//   0x03C     15     Read timer low order bits 15:0
//   0x040     16     Read timer high order bits 31:16
// Commands written into FIFO.... 19, 1A, 1B, 1C:  timer_start, timer_stop, timer_reset, clear_status
//   load_adr (17),  prom_unlock (14),  block_erase (0A)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module BPI_PORT(
  input CLK,                       // 40MHz clock
  input RST,                       // system reset
   // VME selection/control
  input DEVICE,                    // 1 bit indicating this device has been selected... JRG: choose any available OTMB adr range: 28000h base
  input STROBE,                    // Data strobe synchronized to rising or falling edge of clock and asynchronously cleared
  input [9:0] COMMAND,             // command portion of VME address... JRG: assume it is address bits 11:2?
  input WRITE_B,                   // read/write_bar
  input [15:0] INDATA,             // data from VME writes to be provided to BPI interface
  output reg [15:0] OUTDATA,       // data from BPI interface to VME buss for reads
  output DTACK,                    // DTACK
   // BPI controls
  output reg BPI_RST,                  // Resets BPI interface state machines
  output reg [15:0] BPI_CMD_FIFO_DATA, // Data for command FIFO
  output reg BPI_WE,                   // Command FIFO write enable  (pulse one clock cycle for one write)
  output reg BPI_RE,                   // Read back FIFO read enable  (pulse one clock cycle for one read)
  output reg BPI_DSBL,                 // Disable parsing of BPI commands in the command FIFO (while being filled)
  output reg BPI_ENBL,                 // Enable  parsing of BPI commands in the command FIFO
  output reg BPI_RD_STATUS,            // Read BPI interface status register command received
  input [15:0] BPI_RBK_FIFO_DATA,  // Data on output of the Read back FIFO
  input [10:0] BPI_RBK_WRD_CNT,    // Word count of the Read back FIFO (number of available reads)
  input [15:0] BPI_STATUS,         // FIFO status bits and latest value of the PROM status register. 
  input [31:0] BPI_TIMER           // General timer
);

wire active_write;
wire active_read;
reg  dtack;
wire busy;
reg  busy_1;
reg  busy_2;
wire lead_0;
reg  lead_1;
wire trail_0;

assign DTACK      = (busy || busy_2) ? dtack : 1'b0;
assign busy         = (DEVICE && STROBE);
assign active_write = (DEVICE && !WRITE_B);
assign active_read  = (DEVICE && WRITE_B);
assign lead_0       = busy && !busy_1;
assign trail_0      = !busy && busy_1;

always @(posedge CLK or posedge RST)
begin
  if(RST)
    OUTDATA <= 16'h0000;
  else
    if(active_read && lead_0)
      begin
      case(COMMAND)
        10'h00C :                        // VME address 0x04030; command 12 -- Read one word from readback FIFO
          OUTDATA <= BPI_RBK_FIFO_DATA;
        10'h00D :                        // VME address 0x04034; command 13 -- Read words left in readback FIFO
          OUTDATA <= {5'b00000,BPI_RBK_WRD_CNT};
        10'h00E :                        // VME address 0x04038; command 14 -- Read interface status register
          OUTDATA <= BPI_STATUS;
        10'h00F :                        // VME address 0x0403C; command 15 -- Read timer, low order
          OUTDATA <= BPI_TIMER[15:0];
        10'h010 :                        // VME address 0x04040; command 16 -- Read timer, high order
          OUTDATA <= BPI_TIMER[31:16];
        default :
          OUTDATA <= 16'h0000;
      endcase
      end
    else
      OUTDATA <= OUTDATA;
end


always @(posedge CLK or posedge RST)
begin
  if(RST)
    BPI_CMD_FIFO_DATA <= 16'h0000;
  else
    if(active_write && lead_0)
      case(COMMAND)
        10'h00B :                        // VME address 0x0402C; command 11 -- Write one word to command FIFO
          BPI_CMD_FIFO_DATA <= INDATA;
        default :
          BPI_CMD_FIFO_DATA <= 16'h0000;
      endcase
    else
      BPI_CMD_FIFO_DATA <= BPI_CMD_FIFO_DATA;
end



always @(posedge CLK)
begin
  busy_1        <= busy;
  busy_2        <= busy_1;
  lead_1        <= lead_0;
  BPI_RST       <= lead_0 && (COMMAND == 10'h008);
  BPI_DSBL      <= lead_0 && (COMMAND == 10'h009);
  BPI_ENBL      <= lead_0 && (COMMAND == 10'h00A);
  BPI_WE        <= lead_0 && (COMMAND == 10'h00B);
  BPI_RE        <= lead_0 && (COMMAND == 10'h00C);
  BPI_RD_STATUS <= lead_0 && (COMMAND == 10'h00E);
end

always @(posedge CLK or posedge RST)
begin
  if(RST)
    dtack <= 1'b0;
  else
    if((active_read && lead_1) || (active_write && lead_0))
      dtack <= 1'b1;
    else if(trail_0)
      dtack <= 1'b0;
    else
      dtack <= dtack;
end


endmodule
