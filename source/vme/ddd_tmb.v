`timescale 1ns / 1ps
//`define DEBUG_DDD_TMB 1
//-----------------------------------------------------------------------------------------------------------
// Programs Data Delay Devices 3D3444 clock delays on power-up
//
//  09/26/2003  Initial
//  10/03/2003  Power_up now comes from vme
//  10/13/2003  Enabled all chip outputs
//  12/11/2003  Add global reset
//  12/16/2003  OE now programmable
//  05/18/2004  Rename global reset
//  08/07/2006  Mod ddd to wait for vme state machine to finish
//  08/28/2006  Change module name
//  09/22/2006  Increase machine state vector width so xst recognizes fsm
//  09/28/2006  Mod shift register to remove integer i
//  04/27/2009  Add safe implementation to state machine
//  08/23/2010  Port to ISE 12, change to non blocking operators, add state machine display
//-----------------------------------------------------------------------------------------------------------
  module ddd_tmb
  (
  clock,
  global_reset,
  power_up,
  vme_ready,
  start,
  autostart_en,
  oe,

  delay_ch0,
  delay_ch1,
  delay_ch2,
  delay_ch3,

  delay_ch4,
  delay_ch5,
  delay_ch6,
  delay_ch7,

  delay_ch8,
  delay_ch9,
  delay_ch10,
  delay_ch11,

  serial_clock,
  serial_out,
  adr_latch,
  serial_in,

  busy,
  verify_ok

`ifdef DEBUG_DDD_TMB
  ,ddd_sm_dsp
  ,check_enable
  ,compare
  ,serial_in_ff
  ,shiftout_ff1
`endif
  );

// I/O Ports
  input      clock;        // Delay chip data clock
  input      global_reset;    // Global reset
  input      power_up;      // DLL clock lock, we wait for it
  input      vme_ready;      // VME registers loaded from prom
  input      start;        // Cycle start command
  input      autostart_en;    // Enable automatic power-up
  input  [11:0]  oe;         // Output enables 12'hFFF=enable all

  input  [3:0]  delay_ch0;      // Channel  0 delay steps
  input  [3:0]  delay_ch1;      // Channel  1 delay steps
  input  [3:0]  delay_ch2;      // Channel  2 delay steps
  input  [3:0]  delay_ch3;      // Channel  3 delay steps

  input  [3:0]  delay_ch4;      // Channel  4 delay steps
  input  [3:0]  delay_ch5;      // Channel  5 delay steps
  input  [3:0]  delay_ch6;      // Channel  6 delay steps
  input  [3:0]  delay_ch7;      // Channel  7 delay steps

  input  [3:0]  delay_ch8;      // Channel  8 delay steps
  input  [3:0]  delay_ch9;      // Channel  9 delay steps
  input  [3:0]  delay_ch10;      // Channel 10 delay steps
  input  [3:0]  delay_ch11;      // Channel 11 delay steps

  output      serial_clock;    // 3D3444 clock
  output      serial_out;      // 3D3444 data
  output      adr_latch;      // 3D3444 adr strobe
  input      serial_in;      // 3D3444 verify

  output      busy;        // State machine busy writing
  output      verify_ok;      // Data readback verified OK

`ifdef DEBUG_DDD_TMB
  output  [71:0]  ddd_sm_dsp;
  output      check_enable;
  output      compare;
  output      serial_in_ff;
  output      shiftout_ff1;
`endif

// State Machine declarations
  reg  [7:0] ddd_sm;  // synthesis attribute safe_implementation of ddd_sm is "yes";

  parameter wait_fpga    =  0;
  parameter wait_powerup  =  1;
  parameter idle      =  2;
  parameter init      =  3;
  parameter write      =  4;
  parameter latch      =  5;
  parameter verify    =  6;
  parameter unstart    =  7;

// FF buffer state machine trigger inputs
  reg power_up_ff  = 0;
  reg vme_ready_ff = 0;
  reg  start_ff     = 0;
  reg  autostart_ff = 0;

  always @(posedge clock) begin
  power_up_ff  <= power_up;
  vme_ready_ff <= vme_ready;
  start_ff     <= start;
  autostart_ff <= autostart_en;
  end

// Serial data template DDD chip 2 (U3 last in chain, first to send)
  wire  [59:0]  tx_bit;

  assign  tx_bit[ 0]  = oe[11];      // Output Enables
  assign  tx_bit[ 1]  = oe[10];
  assign  tx_bit[ 2]  = oe[ 9];
  assign  tx_bit[ 3]  = oe[ 8];

  assign  tx_bit[ 4]  = delay_ch8[3];    // Delay Channel 8
  assign  tx_bit[ 5]  = delay_ch8[2];
  assign  tx_bit[ 6]  = delay_ch8[1];
  assign  tx_bit[ 7]  = delay_ch8[0];

  assign  tx_bit[ 8]  = delay_ch9[3];    // Delay Channel 9
  assign  tx_bit[ 9]  = delay_ch9[2];
  assign  tx_bit[10]  = delay_ch9[1];
  assign  tx_bit[11]  = delay_ch9[0];

  assign  tx_bit[12]  = delay_ch10[3];  // Delay Channel 10
  assign  tx_bit[13]  = delay_ch10[2];
  assign  tx_bit[14]  = delay_ch10[1];
  assign  tx_bit[15]  = delay_ch10[0];

  assign  tx_bit[16]  = delay_ch11[3];  // Delay Channel 11
  assign  tx_bit[17]  = delay_ch11[2];
  assign  tx_bit[18]  = delay_ch11[1];
  assign  tx_bit[19]  = delay_ch11[0];

// Serial data template DDD chip 1 (U2 middle of chain)
  assign  tx_bit[20]  = oe[ 7];      // Output Enables
  assign  tx_bit[21]  = oe[ 6];
  assign  tx_bit[22]  = oe[ 5];
  assign  tx_bit[23]  = oe[ 4];

  assign  tx_bit[24]  = delay_ch4[3];    // Delay Channel 4
  assign  tx_bit[25]  = delay_ch4[2];
  assign  tx_bit[26]  = delay_ch4[1];
  assign  tx_bit[27]  = delay_ch4[0];

  assign  tx_bit[28]  = delay_ch5[3];    // Delay Channel 5
  assign  tx_bit[29]  = delay_ch5[2];
  assign  tx_bit[30]  = delay_ch5[1];
  assign  tx_bit[31]  = delay_ch5[0];

  assign  tx_bit[32]  = delay_ch6[3];    // Delay Channel 6
  assign  tx_bit[33]  = delay_ch6[2];
  assign  tx_bit[34]  = delay_ch6[1];
  assign  tx_bit[35]  = delay_ch6[0];

  assign  tx_bit[36]  = delay_ch7[3];    // Delay Channel 7
  assign  tx_bit[37]  = delay_ch7[2];
  assign  tx_bit[38]  = delay_ch7[1];
  assign  tx_bit[39]  = delay_ch7[0];

// Serial data template DDD chip 0 (U1 first in chain, last to send)
  assign  tx_bit[40]  = oe[ 3];      // Output Enables
  assign  tx_bit[41]  = oe[ 2];
  assign  tx_bit[42]  = oe[ 1];
  assign  tx_bit[43]  = oe[ 0];

  assign  tx_bit[44]  = delay_ch0[3];    // Delay Channel 0
  assign  tx_bit[45]  = delay_ch0[2];
  assign  tx_bit[46]  = delay_ch0[1];
  assign  tx_bit[47]  = delay_ch0[0];

  assign  tx_bit[48]  = delay_ch1[3];    // Delay Channel 1
  assign  tx_bit[49]  = delay_ch1[2];
  assign  tx_bit[50]  = delay_ch1[1];
  assign  tx_bit[51]  = delay_ch1[0];

  assign  tx_bit[52]  = delay_ch2[3];    // Delay Channel 2
  assign  tx_bit[53]  = delay_ch2[2];
  assign  tx_bit[54]  = delay_ch2[1];
  assign  tx_bit[55]  = delay_ch2[0];

  assign  tx_bit[56]  = delay_ch3[3];    // Delay Channel 3
  assign  tx_bit[57]  = delay_ch3[2];
  assign  tx_bit[58]  = delay_ch3[1];
  assign  tx_bit[59]  = delay_ch3[0];

// Serial clock runs at 1/2 clock speed to meet 3D4444 set up timing
  reg clock_half=0;

  always @(posedge clock) begin
  clock_half  <= ~clock_half & (ddd_sm == write || ddd_sm == verify);
  end

// Write Serial data counter  
  reg  [6:0] write_cnt=0;

  wire write_cnt_clr  = !((ddd_sm == write) || (ddd_sm == verify)); 
  wire write_cnt_en  =  ((ddd_sm == write) || (ddd_sm == verify)) && (clock_half == 1);

  always @(posedge clock) begin
  if    (write_cnt_clr) write_cnt <= 0;
  else if  (write_cnt_en ) write_cnt <= write_cnt + 1'b1;
  end

  wire write_done  = (write_cnt == 'd59) && (clock_half == 1);
  wire verify_done= (write_cnt == 'd59) && (clock_half == 1);

// Serial data shift register
  reg [59:0] shift_reg=0;

  wire shift_en  = ((ddd_sm == write) || (ddd_sm == verify)) && (clock_half == 1);  // Shift between serial_clock edges
  wire shift_load  =  (ddd_sm == init ) || (ddd_sm == latch);
   
  always @(posedge clock) begin
  if    (shift_load) shift_reg[59:0] <= tx_bit[59:0];    // sync load
  else if (shift_en  ) shift_reg[58:0] <= shift_reg[59:1];  // shift right
  end

  wire shiftout = shift_reg[0];

// Compare readback to expected data, latches 0 on any error, resets on init
  reg serial_in_ff = 0;
  reg  shiftout_ff0 = 0;
  reg shiftout_ff1 = 0;
  reg compare      = 0;
  reg check_enable = 0;

  always @(posedge clock) begin
  serial_in_ff <= serial_in;
  shiftout_ff0 <= shiftout;
  shiftout_ff1 <= shiftout_ff0;
  check_enable <= (ddd_sm == verify) && (clock_half == 1);
  end

  always @(posedge clock) begin
  if      (ddd_sm == init) compare <= 1;
  else if (check_enable  ) compare <= compare & (serial_in_ff == shiftout_ff1);
  end

// Hold adr latch high, serial data out and clock low when not shifting out data, FF'd to remove LUT glitches
  reg serial_clock = 0;
  reg serial_out   = 0;
  reg adr_latch    = 1;
  reg busy         = 0;
  reg verify_ok    = 0;
  
  wire sm_init = !power_up;

  always @(posedge clock) begin
  if (sm_init) begin
  serial_clock  <= 1'b0;
  serial_out    <= 1'b0;
  adr_latch    <= 1'b1;
  busy      <= 1'b0;
  verify_ok    <= 1'b0;
  end
  else begin
  serial_clock  <= clock_half;
  serial_out    <= shiftout & ((ddd_sm == write) || (ddd_sm == verify));
  adr_latch    <= ~(ddd_sm == latch);
  busy      <= ddd_sm != idle;
  verify_ok    <= compare;
  end
  end

// DDD State machine
  always @(posedge clock) begin
  if(global_reset)  ddd_sm <= wait_fpga;
  else begin
  case (ddd_sm)
  
  wait_fpga:                    // Wait for FPGA DLLs to lock
   if (power_up_ff)  ddd_sm <= wait_powerup;    // FPGA is ready

  wait_powerup:                  // Wait for TMB board to power-up
   if (vme_ready_ff)                // VME registers loaded from prom
   begin
   if (autostart_ff)  ddd_sm <= init;        // Start cycle if autostart enabled
   else        ddd_sm <= idle;        // Otherwise stay idle
   end

  idle:                      // Wait for VME command to program
   if (start_ff)    ddd_sm <= init;        // Start arrived

  init:        ddd_sm <= write;      // Initialize

  write:                      // Transmit clock and serial data
   if (write_done)  ddd_sm <= latch;      // All data sent

  latch:        ddd_sm <= verify;      // Address latch

  verify:                      // Read back data
   if (verify_done)  ddd_sm <= unstart;      // All data compared
  
  unstart:
   if(!start_ff)    ddd_sm <= idle;        // Wait for VME write command to go away

  default        ddd_sm <= wait_fpga;
  endcase
  end
  end

//-----------------------------------------------------------------------------------------------------------------
// Debug
//-----------------------------------------------------------------------------------------------------------------
`ifdef DEBUG_DDD_TMB
// State Machine ASCII display
  reg [71:0] ddd_sm_dsp;

  always @* begin
  case (ddd_sm)
  wait_fpga:    ddd_sm_dsp <= "wait_fpga";
  wait_powerup:  ddd_sm_dsp <= "wait_pwr ";
  idle:      ddd_sm_dsp <= "idle     ";
  init:      ddd_sm_dsp <= "init     ";
  write:      ddd_sm_dsp <= "write    ";
  latch:      ddd_sm_dsp <= "latch    ";
  verify:      ddd_sm_dsp <= "verify   ";
  unstart:    ddd_sm_dsp <= "unstart  ";
  default      ddd_sm_dsp <= "ERROR!   ";
  endcase
  end
`endif

//-----------------------------------------------------------------------------------------------------------------
  endmodule
//-----------------------------------------------------------------------------------------------------------------
