// used to translate two GEM clusters (0-1535) into flattened GEM "strip" coordinates (0-191)
// why 2 clusters? b/c we have a dualport RAM that can access 2 memory locations simultaneously. 
// why 0-191 ? can consider using csc h/s or strip or arbitrary units.. could
// just divide the chamber in thirds for example.. which would simplify this
// matching considerably but at what cost? 

module cluster_to_halfstrip_size (
		input                     clock,

		input      [13:0]         cluster0,  // save block ram resources by doing 2 lookups from each RAM in parallel
		input      [13:0]         cluster1, 

    output [2:0]          size0,
    output [2:0]          size1
);

parameter FALLING_EDGE = 0;

parameter ADDRBITS  = 8; // 5 bits VFAT ID + 3 bits size
parameter DATABITS  = 3;  // strip

parameter ROMLENGTH = 1 << ADDRBITS;

reg [DATABITS-1:0] rom [ROMLENGTH-1:0];
reg [DATABITS-1:0] rom_port0, rom_port1; 

wire we = 0;
wire [DATABITS-1:0] din = 0;

//----------------------------------------------------------------------------------------------------------------------
// Clock
//----------------------------------------------------------------------------------------------------------------------

wire logic_clock;
generate
if (FALLING_EDGE)
  assign logic_clock = ~clock;
else
  assign logic_clock = clock;
endgenerate

//----------------------------------------------------------------------------------------------------------------------
// Input Mappings
//----------------------------------------------------------------------------------------------------------------------

wire [4:0] vfat_id_natural0 = cluster0[10:6];
wire [4:0] vfat_id_natural1 = cluster1[10:6];

wire [2:0] cluster_size0    = cluster0[13:11];
wire [2:0] cluster_size1    = cluster1[13:11];

wire [ADDRBITS-1:0] adr0 = {cluster_size0, vfat_id_natural0};
wire [ADDRBITS-1:0] adr1 = {cluster_size1, vfat_id_natural1};

always @(posedge logic_clock) begin
		if (we)      rom[adr0]<=din;  // dummy write to help Xilinx infer a dual port block RAM

		rom_port0 <= rom[adr0];
		rom_port1 <= rom[adr1];
end

assign size0 = rom_port0[DATABITS-1:0];
assign size1 = rom_port1[DATABITS-1:0];

//----------------------------------------------------------------------------------------------------------------------
// Fill the RAM
//----------------------------------------------------------------------------------------------------------------------
genvar ivfat;
genvar isize;
generate
  for (ivfat=0; ivfat<24; ivfat=ivfat+1) begin: romloopvfat
  for (isize=0; isize<8;  isize=isize+1) begin: romloopsize


    initial rom[{isize[2:0], ivfat[4:0]}] = gemtocsc(isize);

  end
  end

endgenerate

function [2: 0] gemtocsc;
  input [2: 0] gemstrips;
  reg   [2: 0] halfstrips;

  begin
    case (gemstrips[2: 0])
      3'd0: halfstrips = 0;
      3'd1: halfstrips = 0;
      3'd2: halfstrips = 1;
      3'd3: halfstrips = 2;
      3'd4: halfstrips = 2;
      3'd5: halfstrips = 3;
      3'd6: halfstrips = 4;
      3'd7: halfstrips = 4;
    endcase

    gemtocsc = halfstrips;
  end

endfunction

endmodule
