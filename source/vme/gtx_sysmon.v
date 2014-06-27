`timescale 1ns / 1ps
//-----------------------------------------------------------------------------------------------------------------------//
//
//  Virtex 6 SYSMON ADC
//
//  adc_adr  adc_data    Conversion
//  -------  -----------    -----------
//  0    Temperature    Degrees C = ((ADCcode × 503.975)/1024) - 273.15
//  1    VccINT      Volts    = (ADC Code / 1024) x 3V
//  2    VccAUX      Volts    = (ADC Code / 1024) x 3V
//  4    Vref  1.25V    Volts    = (ADC Code / 1024) x 3V
//  5    Vzero 0.00V    Volts    = (ADC Code / 1024) x 3V
//
//-----------------------------------------------------------------------------------------------------------------------//
//
//  09/22/2012  Initial
//  12/04/2012  Connect RAM SPO outputs
//
//-----------------------------------------------------------------------------------------------------------------------//
  module gtx_sysmon
  (
  clock,
  reset,
  adc_adr,
  adc_data,
  adc_valid,
  adc_sump
  );

//-----------------------------------------------------------------------------------------------------------------------//
// Ports
//-----------------------------------------------------------------------------------------------------------------------//
  input      clock;          // 40 MHz main
  input      reset;          // Active-high reset
  input  [4:0]  adc_adr;        // ADC channel
  output  [9:0]  adc_data;        // ADC data
  output      adc_valid;        // ADC data valid
  output      adc_sump;        /// Unused signals

//-----------------------------------------------------------------------------------------------------------------------//
// Local
//-----------------------------------------------------------------------------------------------------------------------//
  wire  [4:0]  channel;        // Channel selection
  wire  [6:0]  daddr;          // DRP address
  wire  [15:0]  dout;          // DRP output data bus
  wire      drdy;          // DRP data ready signal
  wire      eoc;          // DRP input enable signal
  wire  [9:0]  spo;          

  assign adc_sump = |spo;

//-----------------------------------------------------------------------------------------------------------------------//
// RAM data storage
//-----------------------------------------------------------------------------------------------------------------------//
// Distributed RAM instances preclude inferred RAM warnings
  genvar i;
  generate
  for (i=0; i<10; i=i+1) begin: gen_ram
  RAM32X1D #
  (.INIT  (32'h00000000)  // Initial RAM contents
  ) uram32x1d (
  .WCLK  (clock),    // Write clock   input
  .WE    (drdy),      // Write enable  input
  .A0    (channel[0]),  // RW address[0] input bit
  .A1    (channel[1]),  // RW address[1] input bit
  .A2    (channel[2]),  // RW address[2] input bit
  .A3    (channel[3]),  // RW address[3] input bit
  .A4    (channel[4]),  // RW address[4] input bit
  .D    (dout[i+6]),  // Write 1-bit data input
  .SPO  (spo[i]),    // Read  1-bit data output
  .DPRA0  (adc_adr[0]),  // Read-only address[0] input bit
  .DPRA1  (adc_adr[1]),  // Read-only address[1] input bit
  .DPRA2  (adc_adr[2]),  // Read-only address[2] input bit
  .DPRA3  (adc_adr[3]),  // Read-only address[3] input bit
  .DPRA4  (adc_adr[4]),  // Read-only address[4] input bit
   .DPO  (adc_data[i])  // Read-only 1-bit data output
  );
  end
  endgenerate

// RAM data valid flag
  reg [4:0] adc_ch_done = 0;

  always @(posedge clock) begin
  if      (reset) adc_ch_done[4:0]     <= 0;
  else if (drdy ) adc_ch_done[channel] <= 1;
  end

  assign adc_valid = adc_ch_done[adc_adr];

//-----------------------------------------------------------------------------------------------------------------------//
// ADC Instance
//-----------------------------------------------------------------------------------------------------------------------//
  assign daddr[6:0] = {2'b00,channel[4:0]};

  SYSMON #
  (
  .INIT_40      (16'h1000),      // Configuration register 0
  .INIT_41      (16'h20C7),      // Configuration register 1
  .INIT_42      (16'h0800),      // Configuration register 2

  .INIT_43      (16'h0000),      // Test register 0 do not edit
  .INIT_44      (16'h0000),      // Test register 1 do not edit
  .INIT_45      (16'h0000),      // Test register 2 do not edit
  .INIT_46      (16'h0000),      // Test register 3 do not edit
  .INIT_47      (16'h0000),      // Test register 4 do not edit

  .INIT_48      (16'h3701),      // Sequence register 0
  .INIT_49      (16'h0000),      // Sequence register 1
  .INIT_4A      (16'h3701),      // Sequence register 2
  .INIT_4B      (16'h0000),      // Sequence register 3
  .INIT_4C      (16'h0000),      // Sequence register 4
  .INIT_4D      (16'h0000),      // Sequence register 5
  .INIT_4E      (16'h0000),      // Sequence register 6
  .INIT_4F      (16'h0000),      // Sequence register 7

  .INIT_50      (16'h0000),      // Alarm register 0
  .INIT_51      (16'h0000),      // Alarm register 1
  .INIT_52      (16'h0000),      // Alarm register 2
  .INIT_53      (16'h0000),      // Alarm register 3
  .INIT_54      (16'h0000),      // Alarm register 4
  .INIT_55      (16'h0000),      // Alarm register 5
  .INIT_56      (16'h0000),      // Alarm register 6
  .INIT_57      (16'h0000),      // Alarm register 7

  .SIM_DEVICE      ("VIRTEX6"),    // Must be set to VIRTEX6
  .SIM_MONITOR_FILE  ("../source/vme/gtx_sysmon.txt")  // Analog simulation data file name

  ) usysmon (

  .CONVST        (1'b0),        // In   1-bit Convert start
  .CONVSTCLK      (1'b0),        // In   1-bit Convert start
  .RESET        (reset),      // In   1-bit Active-high reset

  .DCLK        (clock),      // In   1-bit DRP clock input
  .DADDR        (daddr[6:0]),    // In   7-bit DRP input address bus
  .DEN        (eoc),        // In   1-bit DRP input enable signal
  .DWE        (1'b0),        // In   1-bit DRP write enable signal
  .DI          (16'h0),      // In  16-bit DRP input  data bus
  .DO          (dout[15:0]),    // Out  16-bit DRP output data bus
  .DRDY        (drdy),        // Out   1-bit DRP data ready signal

  .BUSY        (),          // Out   1-bit ADC busy
  .CHANNEL      (channel[4:0]),    // Out   5-bit Channel selection
  .EOC        (eoc),        // Out   1-bit End of Conversion
  .EOS        (),          // Out   1-bit End of Sequence
  .ALM        (),          // Out   3-bit alarm for temp, Vccint and Vccaux
  .OT          (),         // Out   1-bit over-Temperature alarm

  .JTAGBUSY      (),          // Out   1-bit JTAG DRP transaction in progress
  .JTAGLOCKED      (),          // Out   1-bit JTAG requested DRP port lock
  .JTAGMODIFIED    (),          // Out   1-bit JTAG Write to the DRP has occurred

  .VAUXN        (16'h0),      // In  16-bit N-side auxiliary analog input
  .VAUXP        (16'h0),      // In  16-bit P-side auxiliary analog input
  .VN          (1'b0),        // In   1-bit N-side analog input
  .VP          (1'b0)        // In   1-bit P-side analog input
   );  
      
//-----------------------------------------------------------------------------------------------------------------------//
  endmodule
//-----------------------------------------------------------------------------------------------------------------------//
