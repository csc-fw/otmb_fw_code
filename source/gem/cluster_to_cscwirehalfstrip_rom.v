// used to translate two GEM clusters (0-1535) into flattened GEM "strip" coordinates (0-191)
// why 2 clusters? b/c we have a dualport RAM that can access 2 memory locations simultaneously. 
// why 0-191 ? can consider using csc h/s or strip or arbitrary units.. could
// just divide the chamber in thirds for example.. which would simplify this
// matching considerably but at what cost? 
// 1.gem roll+pad to wiregroup
// 2.gem pad to key HS in ME1A
// 3.gem pad to key HS in ME1B
// LUT files: 
//The most LUT files(rom_patA.mem etc) are taken from https://github.com/cms-data/L1Trigger-CSCTriggerPrimitives and the current firmware is using the version from 2021 April


module cluster_to_cscwirehalfstrip_rom (
	input                     clock,

        input                     evenchamber,   // even pair or not
        input                     gem_match_enable,
        input      [4:0]          gem_clct_deltahs, // matching window in halfstrip direction
        input      [2:0]          gem_alct_deltawire, // matching window in wiregroup direction
        input                     gem_me1a_match_enable,
        input                     gem_me1b_match_enable,

        input     [13:0]          cluster0,
        input                     cluster0_vpf,// valid or not
        input      [2:0]          cluster0_roll, // 0-7 
        input      [7:0]          cluster0_pad, // from 0-191
        input      [2:0]          cluster0_size, // from 0-7, 0 means 1 gem pad

        output     [WIREBITS-1:0] cluster0_cscwire_lo,
        output     [WIREBITS-1:0] cluster0_cscwire_hi,
        output     [WIREBITS-1:0] cluster0_cscwire_mi,//middle
        output     [MXXKYB-1:0]   cluster0_cscxky_lo, // from 0-127 for halfstrip, later replaced by xky resolution
        output     [MXXKYB-1:0]   cluster0_cscxky_hi, // from 0-127
        output     [MXXKYB-1:0]   cluster0_cscxky_mi, // from 128-223, middle
        output                    csc_cluster0_me1a,
        output     [13:0]         csc_cluster0,  
        output                    csc_cluster0_vpf,// valid or not
        //output      [2:0]         csc_cluster0_roll, // 0-7 
        //output      [7:0]         csc_cluster0_pad, // from 0-191
        //output      [2:0]         csc_cluster0_size, // from 0-7, 0 means 1 gem pad

        output  cluster_to_cscdummy
);

parameter FALLING_EDGE = 0;

parameter MXCFEB       = 7;

parameter MXXKYB       = 10;            // Number of EightStrip key bits on 7 CFEBs
parameter WIREBITS     = 7; //wiregroup
parameter MAXWIRE      = 7'd47; //counting from0, max is 47, in total=48
parameter MINKEYHSME1B = 10'd0;
parameter MAXKEYHSME1B = 10'd511;
parameter MINKEYHSME1A = 10'd512;
parameter MAXKEYHSME1A = 10'd895;

//counter
parameter ICLST        = 0;

//reg [DATABITS-1:0] rom [ROMLENGTH-1:0];
//reg [MXXKYB-1:0] me1a_xky_lo, me1a_xky_hi, me1b_xky_lo, me1b_xky_hi; 
//reg [WIREBITS-1:0]  wire_lo, wire_hi;
wire [6:0] gem_clct_deltaxky = {gem_clct_deltahs, 2'b00};// convert HS level window to 1/8 strip level window


wire [MXXKYB-1:0] me1a_xky_lo_even, me1a_xky_lo_odd, 
                  me1a_xky_hi_even, me1a_xky_hi_odd, 
                  me1b_xky_lo_even, me1b_xky_lo_odd, 
                  me1b_xky_hi_even, me1b_xky_hi_odd; 

wire [WIREBITS-1:0]  wire_lo_even, wire_lo_odd, 
                     wire_hi_even, wire_hi_odd;

wire [MXXKYB-1:0] me1a_xky_lo, me1a_xky_hi, me1b_xky_lo, me1b_xky_hi; 
wire [WIREBITS-1:0]  wire_lo, wire_hi;


assign me1a_xky_lo = evenchamber ? me1a_xky_lo_even : me1a_xky_lo_odd;
assign me1a_xky_hi = evenchamber ? me1a_xky_hi_even : me1a_xky_hi_odd;
assign me1b_xky_lo = evenchamber ? me1b_xky_lo_even : me1b_xky_lo_odd;
assign me1b_xky_hi = evenchamber ? me1b_xky_hi_even : me1b_xky_hi_odd;

assign wire_lo = evenchamber ? wire_lo_even : wire_lo_odd;
assign wire_hi = evenchamber ? wire_hi_even : wire_hi_odd;

wire we = 0;
wire [7:0] w_adr1;
wire [2:0] w_adr2;
wire [MXXKYB-1:0] din1 = 0;
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

//gem_pad_to_csc_xky_lut upad_to_hs(
//
//   .clock(logic_clock),
//   .wen(we), // write enable
//   .w_adr(w_adr1), // write address
//   .w_data(din1), // write data
//
//   .renodd (~evenchamber),
//   .reneven(evenchamber),
//
//   .me1a_r_adr1  (cluster0_pad_lo), 
//   .me1a_r_data1 (me1a_xky_lo), 
//   .me1a_r_adr2  (cluster0_pad_hi), 
//   .me1a_r_data2 (me1a_xky_hi), 
//   .me1b_r_adr1  (cluster0_pad_lo), 
//   .me1b_r_data1 (me1b_xky_lo), 
//   .me1b_r_adr2  (cluster0_pad_hi), 
//   .me1b_r_data2 (me1b_xky_hi) 
//   );
rom_pad_es #(
  .ROM_FILE("GEMCSCLUT_pad_es_ME1a_odd.mem")
) romme1aodd (
  .clock(clock),
  .adr0(cluster0_pad_lo),
  .adr1(cluster0_pad_hi),
  .rd0 (me1a_xky_lo_odd),
  .rd1 (me1a_xky_hi_odd)
);

rom_pad_es #(
  .ROM_FILE("GEMCSCLUT_pad_es_ME1a_even.mem")
) romme1aeven (
  .clock(clock),
  .adr0(cluster0_pad_lo),
  .adr1(cluster0_pad_hi),
  .rd0 (me1a_xky_lo_even),
  .rd1 (me1a_xky_hi_even)
);

rom_pad_es #(
  .ROM_FILE("GEMCSCLUT_pad_es_ME1b_odd.mem")
) romme1bodd (
  .clock(clock),
  .adr0(cluster0_pad_lo),
  .adr1(cluster0_pad_hi),
  .rd0 (me1b_xky_lo_odd),
  .rd1 (me1b_xky_hi_odd)
);

rom_pad_es #(
  .ROM_FILE("GEMCSCLUT_pad_es_ME1b_even.mem")
) romme1beven (
  .clock(clock),
  .adr0(cluster0_pad_lo),
  .adr1(cluster0_pad_hi),
  .rd0 (me1b_xky_lo_even),
  .rd1 (me1b_xky_hi_even)
);



// GEM-CSC map, gem roll to CSC wire
  
//gem_roll_to_csc_wg_lut uroll_to_wire(
//    .clock  (logic_clock),
//    .wen    (we),
//    .w_adr  (w_adr2),
//    .w_data (din2),
//    .renodd (~evenchamber),
//    .reneven(evenchamber),
//    .r_adr1 (cluster0_roll),
//    .r_data1(wire_lo),
//    .r_adr2 (cluster0_roll),
//    .r_data2(wire_hi)
//  );

//use layer1 LUT
rom_roll_wg #(
  .ROM_FILE("GEMCSCLUT_roll_l1_min_wg_ME11_odd.mem")
) romwgminodd (
  .clock(clock),
  .adr0(cluster0_roll),
  .rd0 (wire_lo_odd)
);

rom_roll_wg #(
  .ROM_FILE("GEMCSCLUT_roll_l1_max_wg_ME11_odd.mem")
) romwgmaxodd (
  .clock(clock),
  .adr0(cluster0_roll),
  .rd0 (wire_hi_odd)
);


rom_roll_wg #(
  .ROM_FILE("GEMCSCLUT_roll_l1_min_wg_ME11_even.mem")
) romwgmineven (
  .clock(clock),
  .adr0(cluster0_roll),
  .rd0 (wire_lo_even)
);

rom_roll_wg #(
  .ROM_FILE("GEMCSCLUT_roll_l1_max_wg_ME11_odd.mem")
) romwgmaxeven (
  .clock(clock),
  .adr0(cluster0_roll),
  .rd0 (wire_hi_even)
);



reg [13:0]    reg_cluster0;
reg           reg_cluster0_vpf;// valid or not
//reg [2:0]     reg_cluster0_roll; // 0-7 
//reg [7:0]     reg_cluster0_pad; // from 0-191
//reg [2:0]     reg_cluster0_size; // from 0-7, 0 means 1 gem pad
reg           reg_cluster0_me1a;




always @(posedge logic_clock) begin

    //also add cluster_pad, roll, vpf here to align them in timing!!!
    reg_cluster0           <= cluster0;
    reg_cluster0_vpf       <= cluster0_vpf && gem_match_enable && (gem_me1b_match_enable || ((cluster0_roll== 3'd7) && gem_me1a_match_enable));
    //reg_cluster0_roll      <= cluster0_roll;
    //reg_cluster0_pad       <= cluster0_pad;
    //reg_cluster0_size      <= cluster0_size;
    reg_cluster0_me1a      <= (cluster0_roll== 3'd7) && gem_me1a_match_enable;

end

wire [WIREBITS-1:0] wire_real_lo, wire_real_hi;
assign wire_real_lo = (wire_lo < wire_hi) ? wire_lo : wire_hi; // in case of low and high values swapped
assign wire_real_hi = (wire_lo > wire_hi) ? wire_lo : wire_hi; // in case of low and high values swapped

wire [MXXKYB-1:0] me1a_xky_real_lo, me1a_xky_real_hi, me1b_xky_real_lo, me1b_xky_real_hi;
assign me1a_xky_real_lo = (me1a_xky_lo < me1a_xky_hi) ? me1a_xky_lo : me1a_xky_hi;//even or odd, CSC strip arrangement are different 
assign me1a_xky_real_hi = (me1a_xky_lo > me1a_xky_hi) ? me1a_xky_lo : me1a_xky_hi;
assign me1b_xky_real_lo = (me1b_xky_lo < me1b_xky_hi) ? me1b_xky_lo : me1b_xky_hi;
assign me1b_xky_real_hi = (me1b_xky_lo > me1b_xky_hi) ? me1b_xky_lo : me1b_xky_hi;

// adding matching window
assign cluster0_cscwire_lo  = (wire_real_lo > gem_alct_deltawire)             ? (wire_real_lo-gem_alct_deltawire) : 7'd0;
assign cluster0_cscwire_hi  = ((wire_real_hi + gem_alct_deltawire) < MAXWIRE) ? (wire_real_hi+gem_alct_deltawire) : 7'd47;
assign cluster0_cscwire_mi = wire_real_lo[WIREBITS-1:1] + wire_real_hi[WIREBITS-1:1] + (wire_real_lo[0] | wire_real_hi[0]);

wire [MXXKYB-1:0]  cluster0_me1axky_lo  = (me1a_xky_real_lo > (MINKEYHSME1A+gem_clct_deltaxky)) ? (me1a_xky_real_lo-gem_clct_deltaxky) : MINKEYHSME1A; 
wire [MXXKYB-1:0]  cluster0_me1bxky_lo  = (me1b_xky_real_lo > (MINKEYHSME1B+gem_clct_deltaxky)) ? (me1b_xky_real_lo-gem_clct_deltaxky) : MINKEYHSME1B;
wire [MXXKYB-1:0]  cluster0_me1axky_hi  = ((me1a_xky_real_hi+gem_clct_deltaxky) > MAXKEYHSME1A) ? MAXKEYHSME1A : (me1a_xky_real_hi+gem_clct_deltaxky);
wire [MXXKYB-1:0]  cluster0_me1bxky_hi  = ((me1b_xky_real_hi+gem_clct_deltaxky) > MAXKEYHSME1B) ? MAXKEYHSME1B : (me1b_xky_real_hi+gem_clct_deltaxky);
wire [MXXKYB-1:0]  cluster0_me1axky_mi  = me1a_xky_real_lo[MXXKYB-1:1]+me1a_xky_real_hi[MXXKYB-1:1]+(me1a_xky_real_lo[0] | me1a_xky_real_hi[0]);
wire [MXXKYB-1:0]  cluster0_me1bxky_mi  = me1b_xky_real_lo[MXXKYB-1:1]+me1b_xky_real_hi[MXXKYB-1:1]+(me1b_xky_real_lo[0] | me1b_xky_real_hi[0]);

assign cluster0_cscxky_lo = (csc_cluster0_me1a) ? cluster0_me1axky_lo : cluster0_me1bxky_lo;
assign cluster0_cscxky_hi = (csc_cluster0_me1a) ? cluster0_me1axky_hi : cluster0_me1bxky_hi;
assign cluster0_cscxky_mi = (csc_cluster0_me1a) ? cluster0_me1axky_mi : cluster0_me1bxky_mi;


//assign cluster0_cscxky_lo = (csc_cluster0_me1a) ? ((me1a_xky_real_lo > MINKEYHSME1A+gem_clct_deltaxky) ? me1a_xky_real_lo-gem_clct_deltaxky : MINKEYHSME1A) : ((me1b_xky_real_lo > MINKEYHSME1B+gem_clct_deltaxky) ? me1b_xky_real_lo-gem_clct_deltaxky : MINKEYHSME1B);
//assign cluster0_cscxky_hi = (csc_cluster0_me1a) ? ((me1a_xky_real_hi+gem_clct_deltaxky > MAXKEYHSME1A) ? MAXKEYHSME1A : me1a_xky_real_hi+gem_clct_deltaxky) : ((me1b_xky_real_hi+gem_clct_deltaxky > MAXKEYHSME1B) ? MAXKEYHSME1B : me1b_xky_real_hi+gem_clct_deltaxky);
//assign cluster0_cscxky_mi = (csc_cluster0_me1a) ? (me1a_xky_real_lo[MXXKYB-1:1]+me1a_xky_real_hi[MXXKYB-1:1]+(me1a_xky_real_lo[0] | me1a_xky_real_hi[0])) : (me1b_xky_real_lo[MXXKYB-1:1]+me1b_xky_real_hi[MXXKYB-1:1]+(me1b_xky_real_lo[0] | me1b_xky_real_hi[0]));

assign csc_cluster0       = reg_cluster0;
assign csc_cluster0_vpf   = reg_cluster0_vpf;// valid or not
//assign csc_cluster0_roll  = reg_cluster0_roll; // 0-7 
//assign csc_cluster0_pad   = reg_cluster0_pad; // from 0-191
//assign csc_cluster0_size  = reg_cluster0_size; // from 0-7, 0 means 1 gem pad
assign csc_cluster0_me1a  = reg_cluster0_me1a; // only roll7 is matchd to ME1a, 1 for ME1a, 0 for ME1b

assign cluster_to_cscdummy = 1'b0;

endmodule