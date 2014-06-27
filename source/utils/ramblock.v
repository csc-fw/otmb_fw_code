`timescale 1ns / 1ps
//-------------------------------------------------------------------------------------------------------------------
// Dual port Block RAM for header data
//  Port A: write-only
//  Port B: read-only
//
//  Uses library RAMB16_S9_S9 instead of inferred RAM,
//  because XST issues spurious warnings for unconnected Port A parity bits.
//  
//  10/26/2007  Initial
//  11/01/2007  Add port b enable to prevent port a address collisions when not reading port b
//  09/13/2010  Port to ISE 12, limit return data width to callers parameter
//  09/15/2010  Add passed parameter display
//  09/27/2010  Add name to display
//  09/28/2010  Add virtex 6 ram option
//  09/29/2010  Remove unconnected v6 ports from dang
//  10/05/2010  Add read_first collision avoidance
//  10/15/2010  Add read_first to all ports to mollify xst 12 map phase
//  02/14/2013  Virtex-6 only
//-------------------------------------------------------------------------------------------------------------------
  module ramblock
  (
  clock,
  wr_wea,
  wr_adra,
  wr_dataa,
  rd_enb,
  rd_adrb,
  rd_datab,
  dang
  );
//-------------------------------------------------------------------------------------------------------------------
// Generics caller may override
//-------------------------------------------------------------------------------------------------------------------
  parameter RAM_WIDTH = 9;              // Data width+parity
  parameter RAM_ADRB   = 11;              // Address bits

  initial  $display("ramblock: RAM_WIDTH=%d",RAM_WIDTH);
  initial  $display("ramblock: RAM_ADRB =%d",RAM_ADRB );

//-------------------------------------------------------------------------------------------------------------------
// Ports
//-------------------------------------------------------------------------------------------------------------------
  input          clock;            // Write clock

  input          wr_wea;            // Write enable      port A
  input  [RAM_ADRB-1:0]  wr_adra;          // Read/Write address  port A
  input  [RAM_WIDTH-1:0]  wr_dataa;          // Write data       port A

  input          rd_enb;            // Read enable      port B
  input  [RAM_ADRB-1:0]  rd_adrb;          // Read/Write address  port B
  output  [RAM_WIDTH-1:0]  rd_datab;          // Read  data      port B
  output          dang;            // Dangling pin sump  port A/B

//-------------------------------------------------------------------------------------------------------------------
// Expand data bus widths for an integer number of S9 RAMs
//-------------------------------------------------------------------------------------------------------------------
  parameter s9    = 9;                // Bits per RAM
  parameter nrams = (RAM_WIDTH-1)/s9+1;        // Number of RAMs needed for that many bits
  parameter nbits = nrams*s9;              // Number of bits to span those RAMs
  parameter ndang = nbits-RAM_WIDTH;          // Number of dangling outputs

  initial $display("ramblock: width= %d",RAM_WIDTH);
  initial $display("ramblock: nrams= %d",nrams);
  initial $display("ramblock: nbits= %d",nbits);
  initial $display("ramblock: ndang= %d",ndang);

// Extend input arrays to be integer multiples of s9
  wire [nbits-1:0] wr_dataax;              // Extended 1D array with leading 0s
  wire [nbits-1:0] rd_databx;              // Extended 1D array with leading 0s
  wire [s9-1:0]    wr_dataax2d [nrams-1:0];      // Extended 2D array for gen loop
  wire [s9-1:0]    rd_databx2d [nrams-1:0];      // Extended 2D array for gen loop

  assign wr_dataax=wr_dataa;              // Add leading 0s to incoming array
  
// Generate 2Kx9 Block RAMs, avoids xst issues for inferred rams with unconnected doa and dopa
  initial $display("ramblock: generating Virtex6 RAMB18E1_S9_S9 uram");
  wire [8:0] dob [nrams-1:0];                // Unconnected ports

  genvar i;
  generate
  for (i=0; i<=nrams-1; i=i+1) begin: ram
  assign wr_dataax2d[i] = wr_dataax[i*s9+s9-1:i*s9];    // Map incoming 1D array to 2D for loop

  RAMB18E1 #(                        // Virtex6
  .RAM_MODE      ("TDP"),              // SDP or TDP
   .READ_WIDTH_A    (0),                // 0,1,2,4,9,18,36 Read/write width per port
  .READ_WIDTH_B    (9),                // 0,1,2,4,9,18
  .WRITE_WIDTH_A    (9),                // 0,1,2,4,9,18
  .WRITE_WIDTH_B    (0),                // 0,1,2,4,9,18,36
  .WRITE_MODE_A    ("READ_FIRST"),            // Value on output upon a write (WRITE_FIRST, READ_FIRST, or NO_CHANGE)
  .WRITE_MODE_B    ("READ_FIRST"),
  .SIM_COLLISION_CHECK("ALL")                // Colision check: Values (ALL, WARNING_ONLY, GENERATE_X_ONLY or NONE)
  ) uram (
  .WEA        ({2{wr_wea}}),            //  2-bit A port write enable input
  .ENARDEN      (1'b1),                //  1-bit A port enable/Read enable input
  .RSTRAMARSTRAM    (1'b0),                //  1-bit A port set/reset input
  .RSTREGARSTREG    (1'b0),                //  1-bit A port register set/reset input
  .REGCEAREGCE    (1'b0),                //  1-bit A port register enable/Register enable input
  .CLKARDCLK      (clock),              //  1-bit A port clock/Read clock input
  .ADDRARDADDR    ({wr_adra,3'h7}),          // 14-bit A port address/Read address input 9b->[13:3]
  .DIADI        ({8'h00,wr_dataax2d[i][7:0]}),    // 16-bit A port data/LSB data input
  .DIPADIP      ({1'b0,wr_dataax2d[i][8]}),      //  2-bit A port parity/LSB parity input
  .DOADO        (),                  // 16-bit A port data/LSB data output
  .DOPADOP      (),                  //  2-bit A port parity/LSB parity output

  .WEBWE        (4'h0),                //  4-bit B port write enable/Write enable input
  .ENBWREN      (rd_enb),              //  1-bit B port enable/Write enable input
  .REGCEB        (1'b0),                //  1-bit B port register enable input
  .RSTRAMB      (1'b0),                //  1-bit B port set/reset input
  .RSTREGB      (1'b0),                //  1-bit B port register set/reset input
  .CLKBWRCLK      (clock),              //  1-bit B port clock/Write clock input
  .ADDRBWRADDR    ({rd_adrb,3'h7}),          // 14-bit B port address/Write address input 9b->[13:3]
  .DIBDI        (),                  // 16-bit B port data/MSB data input
  .DIPBDIP      (),                  //  2-bit B port parity/MSB parity input
  .DOBDO        ({dob[i][7:0],rd_databx2d[i][7:0]}),// 16-bit B port data/MSB data output
  .DOPBDOP      ({dob[i][8],rd_databx2d[i][8]})    //  2-bit B port parity/MSB parity output
  );

// Map outgoing 2D array back to 1D
  assign rd_databx[i*s9+s9-1:i*s9]=rd_databx2d[i];
  end
  endgenerate

  assign rd_datab = rd_databx[RAM_WIDTH-1:0];        // De-scope extended array to trim leading 0s

// Sump dangling pins
  wire dang = rd_databx[nbits-1:nbits-ndang-1];      // Left over port b pins

//-------------------------------------------------------------------------------------------------------------------
  endmodule
//-------------------------------------------------------------------------------------------------------------------
