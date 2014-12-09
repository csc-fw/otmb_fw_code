`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:10:16 03/09/2011 
// Design Name: 
// Module Name:    bpi_interface  -- JRG: calls BPI_intrf_FSM1; drives IO for 23 PromAdr, 16 PromDat, ~FCS, ~FWE, ~FOE, ~Latch
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
module bpi_interface(
    input CLK,                 // 40 MHz clock
    input RST,
    input [22:0] ADDR,         //Bank/Array Address -- JRG: comes from comes from BPI_CTRL
    input [15:0] CMD_DATA_OUT, //Command or Data being written to FLASH device -- JRG: comes from BPI_CTRL
    input [1:0]  OP,           //Operation: 00-standby, 01-write, 10-read, 11-not allowed(standby) -- JRG: comes from BPI_CTRL
    input EXECUTE,
    output [15:0] DATA_IN,      //Data read from FLASH device -- JRG: goes to BPI_CTRL
    output LOAD_DATA,           //Clock enable signal for capturing Data read from FLASH device -- JRG: goes to BPI_CTRL
    output BUSY,                //Operation in progress signal (not ready) -- JRG: goes to BPI_CTRL
  // signals for Dual purpose data lines
    input BPI_ACTIVE,           // set to 1 when data lines are for BPI communications -- JRG: comes from BPI_CTRL
    input [15:0] DUAL_DATA,     // Data provided for non BPI communications -- JRG: should probably come from TMB LED logic
   // external connections cooresponding to I/O pins
//    inout [22:0] BPI_AD,  // JRG, what is this?
    output [22:0] BPI_AD,   // JRG, this is the selected BPI address
    inout [15:0] CFG_DAT,  // JRG, what is this?  probably goes out to define IO pins at higher level (16 LED pins)
// JRG, not needed:   output RS0,
// JRG, not needed:   output RS1,
//    output FCS_B,
//    output FOE_B,
//    output FWE_B,
//    output FLATCH_B,
    output [3:0] FLASH_CTRL,   // goes up to carry ~fcs, ~foe, ~fwe, ~latch_add out of chip
    input  [2:0] FLASH_CTRL_DUALUSE    // JRG, in for MUX with FOE,FWE,FLATCH
    );

//  wire [22:0] bpi_ad_in;
  reg  [22:0] bpi_ad_out;
//  wire [22:0] bpi_dir;
  wire [15:0] data_dir;
  reg  [15:0] data_out;
  reg  [15:0] data_out_r;
  wire [15:0] data_out_i;
  reg  [15:0] data_dir_r;
//   wire rs0_out;
//   wire rs1_out;
  wire fcs,foe,fwe,flatch_addr;
  reg read;
  reg write;
  wire capture;
  wire [15:0] leds_out;
  wire clk100k;
  wire q15;
  wire LOAD_DATA_I;
  reg _fcs_r, _foe_r, _fwe_r, _flatch_r, bpi_active_r, LOAD_DATA_R;
;


// JRG:  was CMD_DATA  ->  data_out_r ->  data_out_i  -->  IOBUF
// JRG:  now CMD_DATA  ->  data_out ->  data_out_i  ->  data_out_r  -->  IOBUF
// JRG:  also added  data_dir  ->  data_dir_r  -->  IOBUF   (data_dir_r is new)



// JRG: bring TMB LED signals to the BPI, send out thru this IOBUF
  IOBUF #(.DRIVE(12),.IOSTANDARD("DEFAULT"),.SLEW("SLOW")) IOBUF_CFG_DAT[15:0] (.O(DATA_IN),.IO(CFG_DAT),.I(data_out_r),.T(data_dir_r));

// JRG: delete this IOBUF line,  but take the bpi_ad out to higher levels (Address will be driven in OTMB logic)
//  IOBUF #(.DRIVE(12),.IOSTANDARD("DEFAULT"),.SLEW("SLOW")) IOBUF_BPI_AD[22:0] (.O(bpi_ad_in),.IO(BPI_AD),.I(bpi_ad_out),.T(bpi_dir));
   assign BPI_AD = bpi_ad_out;
// JRG: for OTMB, RS0 & RS1 are Adr bits 21 & 22, but the RS's are not used not defined.  So omit these entirely.
//  OBUFT  #(.DRIVE(12),.IOSTANDARD("DEFAULT"),.SLEW("SLOW")) OBUF_RS0 (.O(RS0),.I(rs0_out),.T(1'b1)); //always tri-state for after programming finishes
//  OBUFT  #(.DRIVE(12),.IOSTANDARD("DEFAULT"),.SLEW("SLOW")) OBUF_RS1 (.O(RS1),.I(rs1_out),.T(1'b1)); //always tri-state for after programming finishes
/*
  OBUF #(.DRIVE(12),.IOSTANDARD("DEFAULT"),.SLEW("SLOW")) OBUF_FCS_B (.O(FCS_B),.I(_fcs_r)); // OTMB just drives it high; BPI code could drive it
  OBUF #(.DRIVE(12),.IOSTANDARD("DEFAULT"),.SLEW("SLOW")) OBUF_FOE_B (.O(FOE_B),.I(_foe_r)); // JRG: also used for ccb_tx14, slow is OK
  OBUF #(.DRIVE(12),.IOSTANDARD("DEFAULT"),.SLEW("SLOW")) OBUF_FWE_B (.O(FWE_B),.I(_fwe_r)); // JRG: also used for ccb_tx26, slow is OK
  OBUF #(.DRIVE(12),.IOSTANDARD("DEFAULT"),.SLEW("SLOW")) OBUF_FLATCH (.O(FLATCH_B),.I(_flatch_r)); // JRG: also used for ccb_tx3, slow is OK
*/

assign FLASH_CTRL[3:0] = (!_fcs_r | bpi_active_r) ? {_fcs_r, _foe_r, _fwe_r, _flatch_r} : {1'b1,FLASH_CTRL_DUALUSE[2:0]}; // {FCS_B, FOE_B, FWE_B, FLATCH_B}

// assign bpi_dir    = 23'h000000;  // always output the address lines
assign data_dir   = {16{foe}};   // Tristat fpga data outputs when the flash is output enable (foe)
// assign rs0_out    = 1'b0;
// assign rs1_out    = 1'b0;
assign data_out_i = (fcs | BPI_ACTIVE) ? data_out : DUAL_DATA;
assign LOAD_DATA   = LOAD_DATA_R;
   
   
always @(posedge CLK)
begin
   bpi_active_r <=  BPI_ACTIVE;
   data_out_r   <=  data_out_i;
   data_dir_r   <=  data_dir;
   LOAD_DATA_R    <=  LOAD_DATA_I; // this is Rdbk FIFO WEN, so delay by one clock because Prom Adr (and thus Prom data) is delayed by one
   _fcs_r <= ~fcs;
   _foe_r <= ~foe;
   _fwe_r <= ~fwe;
   _flatch_r <= ~flatch_addr;
   
   if(capture) begin
      bpi_ad_out   <= ADDR[22:0];
      data_out     <= CMD_DATA_OUT;
      write          <= OP[0];
      read           <= OP[1];
   end
end

   initial begin
      bpi_active_r = 0;
      data_out = 0;
      data_out_r = 0;
      data_dir_r = 0;
      LOAD_DATA_R = 0;
      _fcs_r = 1'b1;
      _foe_r = 1'b1;
      _fwe_r = 1'b1;
      _flatch_r = 1'b1;
   end
   
  
BPI_intrf_FSM BPI_intrf_FSM1(
  .BUSY(BUSY),
  .CAP(capture),
  .E(fcs),
  .G(foe),
  .L(flatch_addr),
  .LOAD(LOAD_DATA_I),
  .W(fwe),
  .CLK(CLK),
  .EXECUTE(EXECUTE),
  .READ(read),
  .RST(RST),
  .WRITE(write)
);

endmodule
