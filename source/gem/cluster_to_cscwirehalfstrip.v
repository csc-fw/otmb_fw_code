// used to translate two GEM clusters (0-1535) into flattened GEM "strip" coordinates (0-191)
// why 2 clusters? b/c we have a dualport RAM that can access 2 memory locations simultaneously. 
// why 0-191 ? can consider using csc h/s or strip or arbitrary units.. could
// just divide the chamber in thirds for example.. which would simplify this
// matching considerably but at what cost? 
//  LUT table reference file: cmssw/L1Trigger/CSCTriggerPrimitives/src/CSCUpgradeMotherboardLUT.cc
// 1.gem roll+pad to wiregroup
// 2.gem pad to key HS in ME1A
// 3.gem pad to key HS in ME1B


module cluster_to_cscwirehalfstrip (
	input                     clock,

        input                     evenchamber,   // even pair or not
        input      [4:0]          gem_clct_deltahs, // matching window in halfstrip direction
        input      [2:0]          gem_alct_deltawire, // matching window in wiregroup direction

        input     [13:0]          cluster0,
        input                     cluster0_vpf,// valid or not
        input      [2:0]          cluster0_roll, // 0-7 
        input      [7:0]          cluster0_pad, // from 0-191
        input      [2:0]          cluster0_size, // from 0-7, 0 means 1 gem pad

        output     [WIREBITS-1:0]          cluster0_cscwire_lo,
        output     [WIREBITS-1:0]          cluster0_cscwire_hi,
        output     [WIREBITS-1:0]          cluster0_cscwire_mi,//middle
        output     [STRIPBITS-1:0]         cluster0_me1bhs_lo, // from 0-127
        output     [STRIPBITS-1:0]         cluster0_me1bhs_hi, // from 0-127
        output     [STRIPBITS-1:0]         cluster0_me1bhs_mi, // from 128-223, middle
        output     [STRIPBITS-1:0]         cluster0_me1ahs_lo, // from 128-223
        output     [STRIPBITS-1:0]         cluster0_me1ahs_hi, // from 128-223
        output     [STRIPBITS-1:0]         cluster0_me1ahs_mi, // from 128-223, middle
        output                    csc_cluster0_me1a,
        output     [13:0]         csc_cluster0,  
        output                    csc_cluster0_vpf,// valid or not
        output      [2:0]         csc_cluster0_roll, // 0-7 
        output      [7:0]         csc_cluster0_pad, // from 0-191
        output      [2:0]         csc_cluster0_size // from 0-7, 0 means 1 gem pad


	//input      [13:0]         cluster0,  // save block ram resources by doing 2 lookups from each RAM in parallel
	//input      [13:0]         cluster1, 

	//output [DATABITS-1:0] halfstrip0,
	//output [DATABITS-1:0] halfstrip1
       //output                    cluster0_cschs_vpf, // whether a CSC hs could be mapped from gem pad or not, 
);

parameter FALLING_EDGE = 0;

parameter MXCFEB       = 7;

parameter STRIPBITS    = 8;  // strip 
parameter WIREBITS     = 7; //wiregroup
parameter MAXWIRE      = 7'd47; //counting from0, max is 47, in total=48
parameter MINKEYHSME1B = 8'd0;
parameter MAXKEYHSME1B = 8'd127;
parameter MINKEYHSME1A = 8'd128;
parameter MAXKEYHSME1A = 8'd223;

//counter
parameter ICLST        = 0;

//reg [DATABITS-1:0] rom [ROMLENGTH-1:0];
//reg [STRIPBITS-1:0] me1a_hs_lo, me1a_hs_hi, me1b_hs_lo, me1b_hs_hi; 
//reg [WIREBITS-1:0]  wire_lo, wire_hi;

wire [STRIPBITS-1:0] me1a_hs_lo, me1a_hs_hi, me1b_hs_lo, me1b_hs_hi; 
wire [WIREBITS-1:0]  wire_lo, wire_hi;

wire we = 0;
wire [7:0] w_adr1;
wire [2:0] w_adr2;
wire [STRIPBITS-1:0] din1 = 0;
wire [WIREBITS-1:0] din2 = 0;

wire logic_clock;
generate
if (FALLING_EDGE)
  assign logic_clock = ~clock;
else
  assign logic_clock = clock;
endgenerate

//ME1a and ME1b seperation is at Eta2.1
wire [7:0] cluster0_pad_lo;
wire [7:0] cluster0_pad_hi;
assign cluster0_pad_lo    = cluster0_vpf ? cluster0_pad : 8'b0;
assign cluster0_pad_hi    = cluster0_vpf ? (cluster0_pad + cluster0_size) : 8'b0;
 
//GEM-CSC map, gempad to CSC keyhs

gem_pad_to_csc_hs_lut upad_to_hs(

   .clock(logic_clock),
   .wen(we), // write enable
   .w_adr(w_adr1), // write address
   .w_data(din1), // write data

   .renodd (~evenchamber),
   .reneven(evenchamber),

   .me1a_r_adr1  (cluster0_pad_lo), 
   .me1a_r_data1 (me1a_hs_lo), 
   .me1a_r_adr2  (cluster0_pad_hi), 
   .me1a_r_data2 (me1a_hs_hi), 
   .me1b_r_adr1  (cluster0_pad_lo), 
   .me1b_r_data1 (me1b_hs_lo), 
   .me1b_r_adr2  (cluster0_pad_hi), 
   .me1b_r_data2 (me1b_hs_hi) 
   );

// GEM-CSC map, gem roll to CSC wire
  
gem_roll_to_csc_wg_lut uroll_to_wire(
    .clock  (logic_clock),
    .wen    (we),
    .w_adr  (w_adr2),
    .w_data (din2),
    .renodd (~evenchamber),
    .reneven(evenchamber),
    .r_adr1 (cluster0_roll),
    .r_data1(wire_lo),
    .r_adr2 (cluster0_roll),
    .r_data2(wire_hi)
  );




reg [13:0]    reg_cluster0;
reg           reg_cluster0_vpf;// valid or not
reg [2:0]     reg_cluster0_roll; // 0-7 
reg [7:0]     reg_cluster0_pad; // from 0-191
reg [2:0]     reg_cluster0_size; // from 0-7, 0 means 1 gem pad


//`include "gem_pad_to_csc_hs_lut.v"
//`include "gem_roll_to_csc_wg_lut.v"


always @(posedge logic_clock) begin
    //if (we)   begin
    //    gem_pad_to_csc_hs_me1a_odd[0]   <= din;  // dummy write to help Xilinx infer a dual port block RAM 
    //    gem_pad_to_csc_hs_me1a_even[0]  <= din;  // dummy write to help Xilinx infer a dual port block RAM 
    //    gem_pad_to_csc_hs_me1b_odd[0]   <= din;  // dummy write to help Xilinx infer a dual port block RAM 
    //    gem_pad_to_csc_hs_me1b_even[0]  <= din;  // dummy write to help Xilinx infer a dual port block RAM 
    //    gem_roll_to_csc_wg_odd_low  [0]       <= din2;
    //    gem_roll_to_csc_wg_odd_high [0]       <= din2;
    //    gem_roll_to_csc_wg_even_low [0]       <= din2;
    //    gem_roll_to_csc_wg_even_high[0]       <= din2;
    //end
    //me1a_hs_lo   <=  (evenchamber ? gem_pad_to_csc_hs_me1a_even[cluster0_pad_lo] : gem_pad_to_csc_hs_me1a_odd[cluster0_pad_lo]);
    //me1a_hs_hi   <=  (evenchamber ? gem_pad_to_csc_hs_me1a_even[cluster0_pad_hi] : gem_pad_to_csc_hs_me1a_odd[cluster0_pad_hi]);
    //me1b_hs_lo   <=  (evenchamber ? gem_pad_to_csc_hs_me1b_even[cluster0_pad_lo] : gem_pad_to_csc_hs_me1b_odd[cluster0_pad_lo]);
    //me1b_hs_hi   <=  (evenchamber ? gem_pad_to_csc_hs_me1b_even[cluster0_pad_hi] : gem_pad_to_csc_hs_me1b_odd[cluster0_pad_hi]);

    //wire_lo      <=  (evenchamber ? gem_roll_to_csc_wg_even_low [cluster0_roll] : gem_roll_to_csc_wg_odd_low [cluster0_roll]);
    //wire_hi      <=  (evenchamber ? gem_roll_to_csc_wg_even_high[cluster0_roll] : gem_roll_to_csc_wg_odd_high[cluster0_roll]);

    //also add cluster_pad, roll, vpf here to align them in timing!!!
    reg_cluster0           <= cluster0;
    reg_cluster0_vpf       <= cluster0_vpf;
    reg_cluster0_roll      <= cluster0_roll;
    reg_cluster0_pad       <= cluster0_pad;
    reg_cluster0_size      <= cluster0_size;

end

wire [WIREBITS-1:0] wire_real_lo, wire_real_hi;
assign wire_real_lo = (wire_lo < wire_hi) ? wire_lo : wire_hi; // in case of low and high values swapped
assign wire_real_hi = (wire_lo > wire_hi) ? wire_lo : wire_hi; // in case of low and high values swapped

wire [STRIPBITS-1:0] me1a_hs_real_lo, me1a_hs_real_hi, me1b_hs_real_lo, me1b_hs_real_hi;
assign me1a_hs_real_lo = (me1a_hs_lo < me1a_hs_hi) ? me1a_hs_lo : me1a_hs_hi;
assign me1a_hs_real_hi = (me1a_hs_lo > me1a_hs_hi) ? me1a_hs_lo : me1a_hs_hi;
assign me1b_hs_real_lo = (me1b_hs_lo < me1b_hs_hi) ? me1b_hs_lo : me1b_hs_hi;
assign me1b_hs_real_hi = (me1b_hs_lo > me1b_hs_hi) ? me1b_hs_lo : me1b_hs_hi;

// adding matching window
assign cluster0_cscwire_lo  = (wire_real_lo > gem_alct_deltawire) ? wire_real_lo-gem_alct_deltawire : 7'd0;
assign cluster0_cscwire_hi  = (wire_real_hi + gem_alct_deltawire < MAXWIRE) ? wire_real_hi+gem_alct_deltawire : 7'd47;

assign cluster0_me1bhs_lo   = (csc_cluster0_me1a) ? 8'd224 : ((me1b_hs_real_lo > MINKEYHSME1B+gem_clct_deltahs) ? me1b_hs_real_lo-gem_clct_deltahs : MINKEYHSME1B); //if not in Me1b region, give it an invalid value
assign cluster0_me1bhs_hi   = (csc_cluster0_me1a) ? 8'd224 : ((me1b_hs_real_hi+gem_clct_deltahs > MAXKEYHSME1B) ? MAXKEYHSME1B : me1b_hs_real_hi+gem_clct_deltahs);

assign cluster0_me1ahs_lo   = (csc_cluster0_me1a) ? ((me1a_hs_real_lo > MINKEYHSME1A+gem_clct_deltahs) ? me1a_hs_real_lo-gem_clct_deltahs : MINKEYHSME1A) : 8'd224; //if not in Me1a region, give it an invalid value
assign cluster0_me1ahs_hi   = (csc_cluster0_me1a) ? ((me1a_hs_real_hi+gem_clct_deltahs > MAXKEYHSME1A) ? MAXKEYHSME1A : me1a_hs_real_hi+gem_clct_deltahs) : 8'd224;

assign cluster0_cscwire_mi = cluster0_cscwire_lo[WIREBITS-1:1] + cluster0_cscwire_hi[WIREBITS-1:1] + (cluster0_cscwire_lo[0] | cluster0_cscwire_hi[0]);
assign cluster0_me1ahs_mi  = cluster0_me1ahs_lo[STRIPBITS-1:1] + cluster0_me1ahs_hi[STRIPBITS-1:1] + (cluster0_me1ahs_lo[0] | cluster0_me1ahs_hi[0]);
assign cluster0_me1bhs_mi  = cluster0_me1bhs_lo[STRIPBITS-1:1] + cluster0_me1bhs_hi[STRIPBITS-1:1] + (cluster0_me1bhs_lo[0] | cluster0_me1bhs_hi[0]);

assign csc_cluster0       = reg_cluster0;
assign csc_cluster0_vpf   = reg_cluster0_vpf;// valid or not
assign csc_cluster0_roll  = reg_cluster0_roll; // 0-7 
assign csc_cluster0_pad   = reg_cluster0_pad; // from 0-191
assign csc_cluster0_size  = reg_cluster0_size; // from 0-7, 0 means 1 gem pad

assign csc_cluster0_me1a  = (reg_cluster0_roll == 3'd7); // only roll7 is matchd to ME1a, 1 for ME1a, 0 for ME1b


endmodule
