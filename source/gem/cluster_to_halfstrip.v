// used to translate two GEM clusters (0-1535) into flattened GEM "strip" coordinates (0-191)
// why 2 clusters? b/c we have a dualport RAM that can access 2 memory locations simultaneously. 
// why 0-191 ? can consider using csc h/s or strip or arbitrary units.. could
// just divide the chamber in thirds for example.. which would simplify this
// matching considerably but at what cost? 

module cluster_to_halfstrip (
		input                     clock,

		input      [13:0]         cluster0,  // save block ram resources by doing 2 lookups from each RAM in parallel
		input      [13:0]         cluster1, 

		output [DATABITS-1:0] halfstrip0,
		output [DATABITS-1:0] halfstrip1
);

parameter FALLING_EDGE = 0;

parameter ADDRBITS  = 11;  // cluster address
parameter DATABITS  = 8;  // halfstrip 
parameter ROMLENGTH = 1 << ADDRBITS;

reg [DATABITS-1:0] rom [ROMLENGTH-1:0];
reg [DATABITS-1:0] rom_port0, rom_port1; 

wire we = 0;
wire [DATABITS-1:0] din = 0;

wire logic_clock;
generate
if (FALLING_EDGE)
  assign logic_clock = ~clock;
else
  assign logic_clock = clock;
endgenerate

always @(posedge logic_clock) begin
		if (we)      rom[cluster0[ADDRBITS-1:0]]<=din;  // dummy write to help Xilinx infer a dual port block RAM 

		rom_port0 <= rom[cluster0[ADDRBITS-1:0]];
		rom_port1 <= rom[cluster1[ADDRBITS-1:0]];
end

assign halfstrip0 = rom_port0[DATABITS-1:0];
assign halfstrip1 = rom_port1[DATABITS-1:0];

genvar istrip; 
generate
  for (istrip=0; istrip<1536; istrip=istrip+1) begin: striploop
    // just use a rough static mapping for now
    initial rom[istrip] = ((istrip % 192) * 128) / 192;
  end
endgenerate

endmodule
