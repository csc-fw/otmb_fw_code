`timescale 1ns / 1ps
//`define DEBUG_DDD_RAT 1
//-----------------------------------------------------------------------------------------------------------
//  Programs Data Delay Devices 3D3444 clock delays on power-up
//
//  09/26/2003  Initial
//  10/03/2003  Power_up now comes from vme
//  10/13/2003  Enabled all chip outputs
//  12/11/2003  Add global reset
//  12/16/2003  OE now programmable
//  09/22/2005  Mod for ISE 7.1i
//  10/07/2005  Copy from bdtest_v5
//  10/17/2005  Mod to run with only 1 3d chip
//  11/29/2005  Make verify OK go low on startup
//  08/18/2006  Add vme_ready state
//  08/22/2006  Remove power_up counter
//  08/25/2006  Add verify delay
//  08/28/2006  Delay check signal to match serial delay 
//  09/22/2006  Increase machine state vector width so xst recognizes fsm
//  01/12/2009  Mod for ISE 10.1i
//  04/27/2009  Add safe implementation to state machine
//  08/20/2010  Port to ise 12, replace blocking with non-blocking operators
//  08/23/2010  Add reg inits, remove async ff
//-----------------------------------------------------------------------------------------------------------
  module ddd_rat
  (
  clock,
  global_reset,
  vme_ready,
  power_up,
  start,
  autostart_en,
  oe,
  verify_dly,

  delay_ch0,
  delay_ch1,
  delay_ch2,
  delay_ch3,

  serial_clock,
  serial_out,
  adr_latch,
  serial_in,

  busy,
  verify_ok

`ifdef DEBUG_DDD_RAT
  ,ddd_sm_dsp
  ,check_enable
  ,dcheck_enable
  ,compare
  ,serial_in_ff
  ,shiftout_dly
`endif
  );

// I/O Ports
  input      clock;        // Delay chip data clock
  input      global_reset;    // Global reset
  input      power_up;      // DLL clock lock, we wait for it
  input      vme_ready;      // VME registers loaded
  input      start;        // Cycle start command
  input      autostart_en;    // Enable automatic power-up
  input  [3:0]  oe;         // Output enables 4'hF=enable all
  input  [1:0]  verify_dly;      // Delay before latching verify data

  input  [3:0]  delay_ch0;      // Channel  0 delay steps
  input  [3:0]  delay_ch1;      // Channel  1 delay steps
  input  [3:0]  delay_ch2;      // Channel  2 delay steps
  input  [3:0]  delay_ch3;      // Channel  3 delay steps

  output      serial_clock;    // 3D3444 clock
  output      serial_out;      // 3D3444 data
  output      adr_latch;      // 3D3444 adr strobe
  input      serial_in;      // 3D3444 verify

  output      busy;        // State machine busy writing
  output      verify_ok;      // Data readback verified OK

`ifdef DEBUG_DDD_RAT
  output  [71:0]  ddd_sm_dsp;
  output      check_enable;
  output      dcheck_enable;
  output      compare;
  output      serial_in_ff;
  output      shiftout_dly;
`endif

// State Machine declarations
  reg [7:0] ddd_sm;  // synthesis attribute safe_implementation of ddd_sm is "yes";

  parameter wait_fpga    =  3'd0;
  parameter wait_powerup  =  3'd1;
  parameter idle      =  3'd2;
  parameter init      =  3'd3;
  parameter write      =  3'd4;
  parameter latch      =  3'd5;
  parameter verify    =  3'd6;
  parameter unstart    =  3'd7;

  // synthesis attribute safe_implementation of ddd_sm is "yes";
  // synthesis attribute init                of ddd_sm is wait_fpga;

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

// Serial data template
  wire  [19:0]  tx_bit;

  assign  tx_bit[ 0]  = oe[3];      // Output Enables
  assign  tx_bit[ 1]  = oe[2];
  assign  tx_bit[ 2]  = oe[1];
  assign  tx_bit[ 3]  = oe[0];

  assign  tx_bit[ 4]  = delay_ch0[3];    // Delay Channel 0
  assign  tx_bit[ 5]  = delay_ch0[2];
  assign  tx_bit[ 6]  = delay_ch0[1];
  assign  tx_bit[ 7]  = delay_ch0[0];

  assign  tx_bit[ 8]  = delay_ch1[3];    // Delay Channel 1
  assign  tx_bit[ 9]  = delay_ch1[2];
  assign  tx_bit[10]  = delay_ch1[1];
  assign  tx_bit[11]  = delay_ch1[0];

  assign  tx_bit[12]  = delay_ch2[3];    // Delay Channel 2
  assign  tx_bit[13]  = delay_ch2[2];
  assign  tx_bit[14]  = delay_ch2[1];
  assign  tx_bit[15]  = delay_ch2[0];

  assign  tx_bit[16]  = delay_ch3[3];    // Delay Channel 3
  assign  tx_bit[17]  = delay_ch3[2];
  assign  tx_bit[18]  = delay_ch3[1];
  assign  tx_bit[19]  = delay_ch3[0];

// Serial clock runs at 1/2 clock speed to meet 3D4444 set up timing
  reg clock_half=0;

  always @(posedge clock) begin
  clock_half  <= ~clock_half & (ddd_sm == write || ddd_sm == verify);
  end

// Write Serial data counter  
  reg  [4:0] write_cnt=0;

  wire write_cnt_clr  = !((ddd_sm == write) || (ddd_sm == verify)); 
  wire write_cnt_en  =  ((ddd_sm == write) || (ddd_sm == verify)) && (clock_half == 1);

  always @(posedge clock) begin
  if    (write_cnt_clr) write_cnt <= 0;
  else if  (write_cnt_en ) write_cnt <= write_cnt + 1'b1;
  end

  wire write_done  = (write_cnt == 'd19) && (clock_half == 1);
  wire verify_done = (write_cnt == 'd19) && (clock_half == 1);

// Serial data shift register
  reg [19:0] shift_reg=0;

  wire sin        = 1'b0;
  wire shift_en  = ((ddd_sm == write) || (ddd_sm == verify)) && (clock_half == 1);  // Shift between serial_clock edges
  wire shift_load  =  (ddd_sm == init ) || (ddd_sm == latch );
   
  always @(posedge clock) begin
  if    (shift_load) shift_reg[19:0] <= tx_bit[19:0];      // sync load
  else if (shift_en  ) shift_reg[19:0] <= {sin,shift_reg[19:1]};  // shift right
  end

  wire shiftout = shift_reg[0];

// Compare readback to expected data, latches 0 on any error, resets on init
  reg serial_in_ff = 0;
  reg compare      = 0;
  reg check_enable = 0;

  always @(posedge clock) begin
  serial_in_ff <= serial_in;
  check_enable <= (ddd_sm == verify) && (clock_half == 1);
  end

  wire [3:0] rdly = {2'b00,verify_dly[1:0]};    //  delay extra cycles for RAT fpga+buffer ICs
  SRL16E dlysdo (.CLK(clock),.CE(1'b1),.D(shiftout),.A0(rdly[0]),.A1(rdly[1]),.A2(rdly[2]),.A3(rdly[3]),.Q(shiftout_dly));

  wire [3:0] cdly = {2'b00,verify_dly[1:0]-1};  //  delay extra cycles for RAT fpga+buffer ICs
  SRL16E dlychk (.CLK(clock),.CE(1'b1),.D(check_enable),.A0(cdly[0]),.A1(cdly[1]),.A2(cdly[2]),.A3(cdly[3]),.Q(dcheck_enable));

  always @(posedge clock) begin
  if    (ddd_sm == init) compare <= 1;
  else if  (dcheck_enable ) compare <= compare & (serial_in_ff == shiftout_dly);
  end
  
// Hold adr latch high, serial data out and clock low when not shifting out data, FF'd to remove LUT glitches
  reg serial_clock = 0;
  reg serial_out   = 0;
  reg  adr_latch    = 1;
  reg  busy         = 0;

  wire sm_init = !power_up;

  always @(posedge clock) begin
  if (sm_init) begin
  serial_clock  <= 1'b0;
  serial_out    <= 1'b0;
  adr_latch    <= 1'b1;
  busy      <= 1'b0;
  end
  else begin
  serial_clock  <= clock_half;
  serial_out    <= shiftout & ((ddd_sm == write) || (ddd_sm == verify));
  adr_latch    <= ~(ddd_sm == latch);
  busy      <= ddd_sm != idle;
  end
  end

// Verify OK ff, clears on power up, or start, and latchs after readback
  reg  verify_ok=0;

  always @(posedge clock) begin
  if    (sm_init)      verify_ok <= 1'b0;
  else if (ddd_sm == init)  verify_ok <= 1'b0;
  else if (ddd_sm == unstart)  verify_ok <= compare;
  end

// DDD State machine
  always @(posedge clock) begin
  if (global_reset)  ddd_sm <= wait_fpga;
  else begin
  case (ddd_sm)
  
  wait_fpga:                    // Wait for FPGA DLLs to lock
   if (power_up_ff)  ddd_sm <= wait_powerup;    // FPGA is ready

  wait_powerup:                  // Wait for TMB board to power-up
   if (vme_ready_ff)                // VME registers are loaded
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
`ifdef DEBUG_DDD_RAT
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
