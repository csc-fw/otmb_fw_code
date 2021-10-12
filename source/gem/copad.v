// `define debug_copad
//----------------------------------------------------------------------------------------------------------------------
// copad.v
//
// simple co-pad finder---matches exact addresses and sets a flag when there is a successful match. Probably only useful
// for vfat2 slice test.
//
// A more sophisticated matching scheme can and should be used for vfat3 matching, where cluster sizes are not fixed and
// resolution is smaller
//
// set match_neighbors high to enable matching with +/1 one pad. Otherwise requires exact match.
//
// n.b. PLEASE realize that this module WILL NOT WORK with VFAT-3 data. This is designed completely around expecting
// that every cluster has size=7, and clusters will only occur in partitions 0, 8, 16
//
// copad matching with VFAT2 data is in copad_vfat2.v
//
// 2019-07-30: start to work with VFAT3 data [size=3bits, position=11bits], position is from 0-1535
// coincidence pad matching: delta pad = 1, detal roll = 1 by default and should be configurable!
// No matching window in timing for copad!!!!
//
//----------------------------------------------------------------------------------------------------------------------

module copad (

    input clock, // 40MHz fabric clock

    input match_neighborRoll,
    input match_neighborPad, // set high for the copad finder to match on neighboring (+/- one) pads
    input [3:0] match_deltaPad, //0-15


    // 8 clusters from gemA
    input gemA_cluster0_vpf,
    input gemA_cluster1_vpf,
    input gemA_cluster2_vpf,
    input gemA_cluster3_vpf,
    input gemA_cluster4_vpf,
    input gemA_cluster5_vpf,
    input gemA_cluster6_vpf,
    input gemA_cluster7_vpf,

    input [2:0] gemA_cluster0_roll,
    input [2:0] gemA_cluster1_roll,
    input [2:0] gemA_cluster2_roll,
    input [2:0] gemA_cluster3_roll,
    input [2:0] gemA_cluster4_roll,
    input [2:0] gemA_cluster5_roll,
    input [2:0] gemA_cluster6_roll,
    input [2:0] gemA_cluster7_roll,

    input [7:0] gemA_cluster0_pad,
    input [7:0] gemA_cluster1_pad,
    input [7:0] gemA_cluster2_pad,
    input [7:0] gemA_cluster3_pad,
    input [7:0] gemA_cluster4_pad,
    input [7:0] gemA_cluster5_pad,
    input [7:0] gemA_cluster6_pad,
    input [7:0] gemA_cluster7_pad,

    input [2:0] gemA_cluster0_cnt,
    input [2:0] gemA_cluster1_cnt,
    input [2:0] gemA_cluster2_cnt,
    input [2:0] gemA_cluster3_cnt,
    input [2:0] gemA_cluster4_cnt,
    input [2:0] gemA_cluster5_cnt,
    input [2:0] gemA_cluster6_cnt,
    input [2:0] gemA_cluster7_cnt,
    

    // 8 clusters from gemB
    input gemB_cluster0_vpf,
    input gemB_cluster1_vpf,
    input gemB_cluster2_vpf,
    input gemB_cluster3_vpf,
    input gemB_cluster4_vpf,
    input gemB_cluster5_vpf,
    input gemB_cluster6_vpf,
    input gemB_cluster7_vpf,

    input [2:0] gemB_cluster0_roll,
    input [2:0] gemB_cluster1_roll,
    input [2:0] gemB_cluster2_roll,
    input [2:0] gemB_cluster3_roll,
    input [2:0] gemB_cluster4_roll,
    input [2:0] gemB_cluster5_roll,
    input [2:0] gemB_cluster6_roll,
    input [2:0] gemB_cluster7_roll,

    input [7:0] gemB_cluster0_pad,
    input [7:0] gemB_cluster1_pad,
    input [7:0] gemB_cluster2_pad,
    input [7:0] gemB_cluster3_pad,
    input [7:0] gemB_cluster4_pad,
    input [7:0] gemB_cluster5_pad,
    input [7:0] gemB_cluster6_pad,
    input [7:0] gemB_cluster7_pad,

    input [2:0] gemB_cluster0_cnt,
    input [2:0] gemB_cluster1_cnt,
    input [2:0] gemB_cluster2_cnt,
    input [2:0] gemB_cluster3_cnt,
    input [2:0] gemB_cluster4_cnt,
    input [2:0] gemB_cluster5_cnt,
    input [2:0] gemB_cluster6_cnt,
    input [2:0] gemB_cluster7_cnt,


    // ff'd copies (1bx delay) of the gemA inputs
    //output reg vpf0,
    //output reg vpf1,
    //output reg vpf2,
    //output reg vpf3,
    //output reg vpf4,
    //output reg vpf5,
    //output reg vpf6,
    //output reg vpf7,

    //output reg [2:0] cluster0_roll,
    //output reg [2:0] cluster1_roll,
    //output reg [2:0] cluster2_roll,
    //output reg [2:0] cluster3_roll,
    //output reg [2:0] cluster4_roll,
    //output reg [2:0] cluster5_roll,
    //output reg [2:0] cluster6_roll,
    //output reg [2:0] cluster7_roll,

    //output reg [7:0] cluster0_pad,
    //output reg [7:0] cluster1_pad,
    //output reg [7:0] cluster2_pad,
    //output reg [7:0] cluster3_pad,
    //output reg [7:0] cluster4_pad,
    //output reg [7:0] cluster5_pad,
    //output reg [7:0] cluster6_pad,
    //output reg [7:0] cluster7_pad,

    //output reg [2:0] cluster0_cnt,
    //output reg [2:0] cluster1_cnt,
    //output reg [2:0] cluster2_cnt,
    //output reg [2:0] cluster3_cnt,
    //output reg [2:0] cluster4_cnt,
    //output reg [2:0] cluster5_cnt,
    //output reg [2:0] cluster6_cnt,
    //output reg [2:0] cluster7_cnt,

    output  [MXCLUSTER_CHAMBER-1:0] match,
    output  [MXCLUSTER_CHAMBER-1:0] match_upper,
    output  [MXCLUSTER_CHAMBER-1:0] match_lower,

    output  [MXCLUSTER_CHAMBER-1:0] copad_A0_B,
    output  [MXCLUSTER_CHAMBER-1:0] copad_A1_B,
    output  [MXCLUSTER_CHAMBER-1:0] copad_A2_B,
    output  [MXCLUSTER_CHAMBER-1:0] copad_A3_B,
    output  [MXCLUSTER_CHAMBER-1:0] copad_A4_B,
    output  [MXCLUSTER_CHAMBER-1:0] copad_A5_B,
    output  [MXCLUSTER_CHAMBER-1:0] copad_A6_B,
    output  [MXCLUSTER_CHAMBER-1:0] copad_A7_B,

    output  any_match, // Output: 1 bit, any match was found

    //output reg [MXFEB-1:0] active_feb_list_copad,  // 24 bit register of active FEBs. Can be used e.g. in GEM only self-trigger

    output sump
);


parameter MXFEB      = 24;
parameter MXCLUSTER_CHAMBER = 8;
parameter MXADRB     = 11;
parameter MXCNTB     = 3;
parameter MXCLSTB    = 14;

//----------------------------------------------------------------------------------------------------------------------
// unpack and vectorize the inputs
//----------------------------------------------------------------------------------------------------------------------

 // insert ff for correct simulation standalone synthesis timing
 `ifdef debug_copad
    reg [2:0] gemA_cluster_roll [MXCLUSTER_CHAMBER-1:0];// 8-elements array 
    reg [7:0] gemA_cluster_pad  [MXCLUSTER_CHAMBER-1:0];// 8-elements array 
    reg [2:0] gemA_cluster_cnt  [MXCLUSTER_CHAMBER-1:0];// 8-elements array 
    reg [2:0] gemB_cluster_roll [MXCLUSTER_CHAMBER-1:0];// 8-elements array 
    reg [7:0] gemB_cluster_pad  [MXCLUSTER_CHAMBER-1:0];// 8-elements array 
    reg [2:0] gemB_cluster_cnt  [MXCLUSTER_CHAMBER-1:0];// 8-elements array 
    reg gemA_vpf[7:0];
    reg gemB_vpf[7:0];

    always @(posedge clock) begin
      gemA_vpf[0]          <= gemA_cluster0_vpf;
      gemA_vpf[1]          <= gemA_cluster1_vpf;
      gemA_vpf[2]          <= gemA_cluster2_vpf;
      gemA_vpf[3]          <= gemA_cluster3_vpf;
      gemA_vpf[4]          <= gemA_cluster4_vpf;
      gemA_vpf[5]          <= gemA_cluster5_vpf;
      gemA_vpf[6]          <= gemA_cluster6_vpf;
      gemA_vpf[7]          <= gemA_cluster7_vpf;

      gemA_cluster_roll[0] <= gemA_cluster0_roll;
      gemA_cluster_roll[1] <= gemA_cluster1_roll;
      gemA_cluster_roll[2] <= gemA_cluster2_roll;
      gemA_cluster_roll[3] <= gemA_cluster3_roll;
      gemA_cluster_roll[4] <= gemA_cluster4_roll;
      gemA_cluster_roll[5] <= gemA_cluster5_roll;
      gemA_cluster_roll[6] <= gemA_cluster6_roll;
      gemA_cluster_roll[7] <= gemA_cluster7_roll;

      gemA_cluster_pad[0]  <= gemA_cluster0_pad;
      gemA_cluster_pad[1]  <= gemA_cluster1_pad;
      gemA_cluster_pad[2]  <= gemA_cluster2_pad;
      gemA_cluster_pad[3]  <= gemA_cluster3_pad;
      gemA_cluster_pad[4]  <= gemA_cluster4_pad;
      gemA_cluster_pad[5]  <= gemA_cluster5_pad;
      gemA_cluster_pad[6]  <= gemA_cluster6_pad;
      gemA_cluster_pad[7]  <= gemA_cluster7_pad;

      gemA_cluster_cnt[0]  <= gemA_cluster0_cnt;
      gemA_cluster_cnt[1]  <= gemA_cluster1_cnt;
      gemA_cluster_cnt[2]  <= gemA_cluster2_cnt;
      gemA_cluster_cnt[3]  <= gemA_cluster3_cnt;
      gemA_cluster_cnt[4]  <= gemA_cluster4_cnt;
      gemA_cluster_cnt[5]  <= gemA_cluster5_cnt;
      gemA_cluster_cnt[6]  <= gemA_cluster6_cnt;
      gemA_cluster_cnt[7]  <= gemA_cluster7_cnt;

      gemB_vpf[0]          <= gemB_cluster0_vpf;
      gemB_vpf[1]          <= gemB_cluster1_vpf;
      gemB_vpf[2]          <= gemB_cluster2_vpf;
      gemB_vpf[3]          <= gemB_cluster3_vpf;
      gemB_vpf[4]          <= gemB_cluster4_vpf;
      gemB_vpf[5]          <= gemB_cluster5_vpf;
      gemB_vpf[6]          <= gemB_cluster6_vpf;
      gemB_vpf[7]          <= gemB_cluster7_vpf;

      gemB_cluster_roll[0] <= gemB_cluster0_roll;
      gemB_cluster_roll[1] <= gemB_cluster1_roll;
      gemB_cluster_roll[2] <= gemB_cluster2_roll;
      gemB_cluster_roll[3] <= gemB_cluster3_roll;
      gemB_cluster_roll[4] <= gemB_cluster4_roll;
      gemB_cluster_roll[5] <= gemB_cluster5_roll;
      gemB_cluster_roll[6] <= gemB_cluster6_roll;
      gemB_cluster_roll[7] <= gemB_cluster7_roll;

      gemB_cluster_pad[0]  <= gemB_cluster0_pad;
      gemB_cluster_pad[1]  <= gemB_cluster1_pad;
      gemB_cluster_pad[2]  <= gemB_cluster2_pad;
      gemB_cluster_pad[3]  <= gemB_cluster3_pad;
      gemB_cluster_pad[4]  <= gemB_cluster4_pad;
      gemB_cluster_pad[5]  <= gemB_cluster5_pad;
      gemB_cluster_pad[6]  <= gemB_cluster6_pad;
      gemB_cluster_pad[7]  <= gemB_cluster7_pad;

      gemB_cluster_cnt[0]  <= gemB_cluster0_cnt;
      gemB_cluster_cnt[1]  <= gemB_cluster1_cnt;
      gemB_cluster_cnt[2]  <= gemB_cluster2_cnt;
      gemB_cluster_cnt[3]  <= gemB_cluster3_cnt;
      gemB_cluster_cnt[4]  <= gemB_cluster4_cnt;
      gemB_cluster_cnt[5]  <= gemB_cluster5_cnt;
      gemB_cluster_cnt[6]  <= gemB_cluster6_cnt;
      gemB_cluster_cnt[7]  <= gemB_cluster7_cnt;

    end
 `else
    wire gemA_vpf[7:0];
    wire gemB_vpf[7:0];
    wire [2:0] gemA_cluster_roll [MXCLUSTER_CHAMBER-1:0];// 8-elements array , each element is a 3 bits wire
    wire [7:0] gemA_cluster_pad  [MXCLUSTER_CHAMBER-1:0];// 8-elements array 
    wire [2:0] gemA_cluster_cnt  [MXCLUSTER_CHAMBER-1:0];// 8-elements array 
    wire [2:0] gemB_cluster_roll [MXCLUSTER_CHAMBER-1:0];// 8-elements array 
    wire [7:0] gemB_cluster_pad  [MXCLUSTER_CHAMBER-1:0];// 8-elements array 
    wire [2:0] gemB_cluster_cnt  [MXCLUSTER_CHAMBER-1:0];// 8-elements array 

    assign  gemA_vpf[0]          = gemA_cluster0_vpf;
    assign  gemA_vpf[1]          = gemA_cluster1_vpf;
    assign  gemA_vpf[2]          = gemA_cluster2_vpf;
    assign  gemA_vpf[3]          = gemA_cluster3_vpf;
    assign  gemA_vpf[4]          = gemA_cluster4_vpf;
    assign  gemA_vpf[5]          = gemA_cluster5_vpf;
    assign  gemA_vpf[6]          = gemA_cluster6_vpf;
    assign  gemA_vpf[7]          = gemA_cluster7_vpf;

    assign  gemA_cluster_roll[0] = gemA_cluster0_roll;
    assign  gemA_cluster_roll[1] = gemA_cluster1_roll;
    assign  gemA_cluster_roll[2] = gemA_cluster2_roll;
    assign  gemA_cluster_roll[3] = gemA_cluster3_roll;
    assign  gemA_cluster_roll[4] = gemA_cluster4_roll;
    assign  gemA_cluster_roll[5] = gemA_cluster5_roll;
    assign  gemA_cluster_roll[6] = gemA_cluster6_roll;
    assign  gemA_cluster_roll[7] = gemA_cluster7_roll;

    assign  gemA_cluster_pad[0]  = gemA_cluster0_pad;
    assign  gemA_cluster_pad[1]  = gemA_cluster1_pad;
    assign  gemA_cluster_pad[2]  = gemA_cluster2_pad;
    assign  gemA_cluster_pad[3]  = gemA_cluster3_pad;
    assign  gemA_cluster_pad[4]  = gemA_cluster4_pad;
    assign  gemA_cluster_pad[5]  = gemA_cluster5_pad;
    assign  gemA_cluster_pad[6]  = gemA_cluster6_pad;
    assign  gemA_cluster_pad[7]  = gemA_cluster7_pad;

    assign  gemA_cluster_cnt[0]  = gemA_cluster0_cnt;
    assign  gemA_cluster_cnt[1]  = gemA_cluster1_cnt;
    assign  gemA_cluster_cnt[2]  = gemA_cluster2_cnt;
    assign  gemA_cluster_cnt[3]  = gemA_cluster3_cnt;
    assign  gemA_cluster_cnt[4]  = gemA_cluster4_cnt;
    assign  gemA_cluster_cnt[5]  = gemA_cluster5_cnt;
    assign  gemA_cluster_cnt[6]  = gemA_cluster6_cnt;
    assign  gemA_cluster_cnt[7]  = gemA_cluster7_cnt;

    assign  gemB_vpf[0]          = gemB_cluster0_vpf;
    assign  gemB_vpf[1]          = gemB_cluster1_vpf;
    assign  gemB_vpf[2]          = gemB_cluster2_vpf;
    assign  gemB_vpf[3]          = gemB_cluster3_vpf;
    assign  gemB_vpf[4]          = gemB_cluster4_vpf;
    assign  gemB_vpf[5]          = gemB_cluster5_vpf;
    assign  gemB_vpf[6]          = gemB_cluster6_vpf;
    assign  gemB_vpf[7]          = gemB_cluster7_vpf;

    assign  gemB_cluster_roll[0] = gemB_cluster0_roll;
    assign  gemB_cluster_roll[1] = gemB_cluster1_roll;
    assign  gemB_cluster_roll[2] = gemB_cluster2_roll;
    assign  gemB_cluster_roll[3] = gemB_cluster3_roll;
    assign  gemB_cluster_roll[4] = gemB_cluster4_roll;
    assign  gemB_cluster_roll[5] = gemB_cluster5_roll;
    assign  gemB_cluster_roll[6] = gemB_cluster6_roll;
    assign  gemB_cluster_roll[7] = gemB_cluster7_roll;

    assign  gemB_cluster_pad[0]  = gemB_cluster0_pad;
    assign  gemB_cluster_pad[1]  = gemB_cluster1_pad;
    assign  gemB_cluster_pad[2]  = gemB_cluster2_pad;
    assign  gemB_cluster_pad[3]  = gemB_cluster3_pad;
    assign  gemB_cluster_pad[4]  = gemB_cluster4_pad;
    assign  gemB_cluster_pad[5]  = gemB_cluster5_pad;
    assign  gemB_cluster_pad[6]  = gemB_cluster6_pad;
    assign  gemB_cluster_pad[7]  = gemB_cluster7_pad;

    assign  gemB_cluster_cnt[0]  = gemB_cluster0_cnt;
    assign  gemB_cluster_cnt[1]  = gemB_cluster1_cnt;
    assign  gemB_cluster_cnt[2]  = gemB_cluster2_cnt;
    assign  gemB_cluster_cnt[3]  = gemB_cluster3_cnt;
    assign  gemB_cluster_cnt[4]  = gemB_cluster4_cnt;
    assign  gemB_cluster_cnt[5]  = gemB_cluster5_cnt;
    assign  gemB_cluster_cnt[6]  = gemB_cluster6_cnt;
    assign  gemB_cluster_cnt[7]  = gemB_cluster7_cnt;

 `endif

  /*
  *  14 bit hit format encoding
  *   hit[10:0]  = starting address
  *   hit[13:11] = n additional pads hit  up to 7
  */


//----------------------------------------------------------------------------------------------------------------------
//GEM geometry:
//roll0: pad0, pad1, pad2 ..... pad190, pad191
//roll1: pad0, pad1, pad2 ..... pad190, pad191
//roll2: pad0, pad1, pad2 ..... pad190, pad191
//roll3: pad0, pad1, pad2 ..... pad190, pad191
//roll4: pad0, pad1, pad2 ..... pad190, pad191
//roll5: pad0, pad1, pad2 ..... pad190, pad191
//roll6: pad0, pad1, pad2 ..... pad190, pad191
//roll7: pad0, pad1, pad2 ..... pad190, pad191
//----------------------------------------------------------------------------------------------------------------------

wire [MXCLUSTER_CHAMBER-1:0] match_AB_c [MXCLUSTER_CHAMBER-1:0]; // same roll
wire [MXCLUSTER_CHAMBER-1:0] match_AB_u [MXCLUSTER_CHAMBER-1:0]; //upper roll, 
wire [MXCLUSTER_CHAMBER-1:0] match_AB_l [MXCLUSTER_CHAMBER-1:0]; //lower roll
wire [MXCLUSTER_CHAMBER-1:0] match_AB  [MXCLUSTER_CHAMBER-1:0]; //or of all matches

//wire [2:0] match_c_iclst[MXCLUSTER_CHAMBER-1:0];//iclst
//wire [2:0] match_u_iclst[MXCLUSTER_CHAMBER-1:0];//iclst
//wire [2:0] match_l_iclst[MXCLUSTER_CHAMBER-1:0];//iclst

reg [MXCLUSTER_CHAMBER-1:0] match_c;
reg [MXCLUSTER_CHAMBER-1:0] match_u;
reg [MXCLUSTER_CHAMBER-1:0] match_l;

reg [MXCLUSTER_CHAMBER-1:0] copad_A_B [MXCLUSTER_CHAMBER-1:0];
//reg [MXCLUSTER_CHAMBER-1:0] matchB_c;
//reg [MXCLUSTER_CHAMBER-1:0] matchB_u;
//reg [MXCLUSTER_CHAMBER-1:0] matchB_l;

reg [2:0] match_iclst [MXCLUSTER_CHAMBER-1:0];

wire [0:0] gemApad_at_left_edge  [MXCLUSTER_CHAMBER-1:0];
wire [0:0] gemApad_at_right_edge [MXCLUSTER_CHAMBER-1:0];
wire [7:0] minpad_match      [MXCLUSTER_CHAMBER-1:0];
wire [7:0] maxpad_match      [MXCLUSTER_CHAMBER-1:0];

wire [7:0] match_deltapad_8bits = match_neighborPad ? {4'b0, match_deltaPad} : 8'b0;

wire padmatch_Acluster_Bcluster [MXCLUSTER_CHAMBER-1:0][MXCLUSTER_CHAMBER-1:0];

genvar iclst;
genvar iclstB;
generate
for (iclst=0; iclst<MXCLUSTER_CHAMBER; iclst=iclst+1) begin: clust_match_loop

  assign gemApad_at_left_edge  [iclst] = gemA_vpf[iclst] & (gemA_cluster_pad[iclst] < match_deltapad_8bits);
  assign gemApad_at_right_edge [iclst] = gemA_vpf[iclst] & ((gemA_cluster_pad[iclst] + match_deltapad_8bits + gemA_cluster_cnt[iclst]) > 8'd191);

  assign minpad_match [iclst] = gemApad_at_left_edge[iclst]  ? (8'd0)   : (gemA_cluster_pad[iclst] - match_deltapad_8bits);
  assign maxpad_match [iclst] = gemApad_at_right_edge[iclst] ? (8'd191) : (gemA_cluster_pad[iclst] + gemA_cluster_cnt[iclst] + match_deltapad_8bits);


  for (iclstB=0; iclstB<MXCLUSTER_CHAMBER; iclstB=iclstB+1) begin: clustAB_match_loop2
      //check whether pad in gemB cluster is within the match range derived from gemA cluster
      assign padmatch_Acluster_Bcluster[iclst][iclstB]  = (gemB_cluster_pad[iclstB] >= minpad_match[iclst] & gemB_cluster_pad[iclstB] <= maxpad_match[iclst]) | ((gemB_cluster_pad[iclstB] + gemB_cluster_cnt[iclstB]) >= minpad_match[iclst] & (gemB_cluster_pad[iclstB] + gemB_cluster_cnt[iclstB]) <= maxpad_match[iclst]);

      assign match_AB_c [iclst][iclstB] =  gemA_vpf[iclst] & gemB_vpf[iclstB] &  gemA_cluster_roll[iclst] == gemB_cluster_roll[iclstB] & padmatch_Acluster_Bcluster[iclst][iclstB];
      assign match_AB_u [iclst][iclstB] = (gemA_cluster_roll[iclst] == 3'd0) ? 1'b0 : (gemA_vpf[iclst] & gemB_vpf[iclstB] &  gemA_cluster_roll[iclst] == gemB_cluster_roll[iclstB]+3'd1 & padmatch_Acluster_Bcluster[iclst][iclstB] & match_neighborRoll);
      assign match_AB_l [iclst][iclstB] = (gemA_cluster_roll[iclst] == 3'd7) ? 1'b0 : (gemA_vpf[iclst] & gemB_vpf[iclstB] &  gemA_cluster_roll[iclst]+3'd1 == gemB_cluster_roll[iclstB] & padmatch_Acluster_Bcluster[iclst][iclstB] & match_neighborRoll);
      
      assign match_AB   [iclst][iclstB] = match_AB_c [iclst][iclstB] | match_AB_u [iclst][iclstB] | match_AB_l [iclst][iclstB];
  end // end of clustAB_match_loop2

  //assign match_c_iclst[iclst] = index1ofbus8(match_AB_c [iclst]);
  //assign match_u_iclst[iclst] = index1ofbus8(match_AB_u [iclst]);
  //assign match_l_iclst[iclst] = index1ofbus8(match_AB_l [iclst]);


  always @ (posedge clock) begin
       match_c[iclst] <= | match_AB_c[iclst];
       match_u[iclst] <= | match_AB_u[iclst];
       match_l[iclst] <= | match_AB_l[iclst];
       //match_iclst[iclst] <= ((| match_AB_c[iclst]) ? match_c_iclst[iclst] : ((| match_AB_u[iclst]) ? match_u_iclst[iclst] : match_l_iclst[iclst]);
       //matchB_c[iclst] <= match_AB_c[0][iclst] | match_AB_c[1][iclst] | match_AB_c[2][iclst] | match_AB_c[3][iclst] | match_AB_c[4][iclst] | match_AB_c[5][iclst] | match_AB_c[6][iclst] | match_AB_c[7][iclst];
       //matchB_l[iclst] <= match_AB_u[0][iclst] | match_AB_u[1][iclst] | match_AB_u[2][iclst] | match_AB_u[3][iclst] | match_AB_u[4][iclst] | match_AB_u[5][iclst] | match_AB_u[6][iclst] | match_AB_u[7][iclst];
       //matchB_u[iclst] <= match_AB_l[0][iclst] | match_AB_l[1][iclst] | match_AB_l[2][iclst] | match_AB_l[3][iclst] | match_AB_l[4][iclst] | match_AB_l[5][iclst] | match_AB_l[6][iclst] | match_AB_l[7][iclst];
       copad_A_B[iclst]   <= match_AB[iclst];
  end

end// end of clust_match_loop
endgenerate

wire [MXCLUSTER_CHAMBER-1:0] match_full  =   match_c   // full cluster match
                                    | match_u 
                                    | match_l; 

//wire any_match_full = (|match_full);

assign any_match                    = (|match_full);
assign match      [MXCLUSTER_CHAMBER-1:0]  = match_full;
assign match_upper[MXCLUSTER_CHAMBER-1:0]  = match_u;
assign match_lower[MXCLUSTER_CHAMBER-1:0]  = match_l;

//assign copad0_iclstB     = match_iclst[0];
//assign copad1_iclstB     = match_iclst[1];
//assign copad2_iclstB     = match_iclst[2];
//assign copad3_iclstB     = match_iclst[3];
//assign copad4_iclstB     = match_iclst[4];
//assign copad5_iclstB     = match_iclst[5];
//assign copad6_iclstB     = match_iclst[6];
//assign copad7_iclstB     = match_iclst[7];

assign copad_A0_B     = copad_A_B[0];
assign copad_A1_B     = copad_A_B[1];
assign copad_A2_B     = copad_A_B[2];
assign copad_A3_B     = copad_A_B[3];
assign copad_A4_B     = copad_A_B[4];
assign copad_A5_B     = copad_A_B[5];
assign copad_A6_B     = copad_A_B[6];
assign copad_A7_B     = copad_A_B[7];

assign sump =
              (|gemA_cluster_cnt[0])
            | (|gemA_cluster_cnt[1])
            | (|gemA_cluster_cnt[2])
            | (|gemA_cluster_cnt[3])
            | (|gemA_cluster_cnt[4])
            | (|gemA_cluster_cnt[5])
            | (|gemA_cluster_cnt[6])
            | (|gemA_cluster_cnt[7])
            | (|gemB_cluster_cnt[0])
            | (|gemB_cluster_cnt[1])
            | (|gemB_cluster_cnt[2])
            | (|gemB_cluster_cnt[3])
            | (|gemB_cluster_cnt[4])
            | (|gemB_cluster_cnt[5])
            | (|gemB_cluster_cnt[6])
            | (|gemB_cluster_cnt[7]);


//------------------------------------------------------------------------------------------------------------------------
// 10/10/2021  find 1st non zero bit index,  ROM version for Virtex-6
//------------------------------------------------------------------------------------------------------------------------
function [2:0] index1ofbus8;
input    [7:0] bits;
reg      [2:0] rom;
begin
  casex(bits[7:0])    // 128x3 ROM
  8'b00000000:  rom = 0;
  8'bxxxxxxx1:  rom = 0;
  8'bxxxxxx10:  rom = 1;
  8'bxxxxx100:  rom = 2;
  8'bxxxx1000:  rom = 3;
  8'bxxx10000:  rom = 4;
  8'bxx100000:  rom = 5;
  8'bx1000000:  rom = 6;
  8'b10000000:  rom = 7;
  endcase
  index1ofbus8=rom;
end
endfunction


//----------------------------------------------------------------------------------------------------------------------
endmodule
//----------------------------------------------------------------------------------------------------------------------
