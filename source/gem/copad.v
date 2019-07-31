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
//
//----------------------------------------------------------------------------------------------------------------------

module copad (

    input clock, // 40MHz fabric clock

    input match_neighborRoll,
    input match_neighborPad, // set high for the copad finder to match on neighboring (+/- one) pads
    input [3:0] match_deltaPad, //0-15


    // 8 clusters from gemA
    input gemA_cluster0_vpf;
    input gemA_cluster1_vpf;
    input gemA_cluster2_vpf;
    input gemA_cluster3_vpf;
    input gemA_cluster4_vpf;
    input gemA_cluster5_vpf;
    input gemA_cluster6_vpf;
    input gemA_cluster7_vpf;

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
    input gemB_cluster0_vpf;
    input gemB_cluster1_vpf;
    input gemB_cluster2_vpf;
    input gemB_cluster3_vpf;
    input gemB_cluster4_vpf;
    input gemB_cluster5_vpf;
    input gemB_cluster6_vpf;
    input gemB_cluster7_vpf;

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
    output reg vpf0;
    output reg vpf1;
    output reg vpf2;
    output reg vpf3;
    output reg vpf4;
    output reg vpf5;
    output reg vpf6;
    output reg vpf7;

    output reg [2:0] cluster0_roll,
    output reg [2:0] cluster1_roll,
    output reg [2:0] cluster2_roll,
    output reg [2:0] cluster3_roll,
    output reg [2:0] cluster4_roll,
    output reg [2:0] cluster5_roll,
    output reg [2:0] cluster6_roll,
    output reg [2:0] cluster7_roll,

    output reg [7:0] cluster0_pad,
    output reg [7:0] cluster1_pad,
    output reg [7:0] cluster2_pad,
    output reg [7:0] cluster3_pad,
    output reg [7:0] cluster4_pad,
    output reg [7:0] cluster5_pad,
    output reg [7:0] cluster6_pad,
    output reg [7:0] cluster7_pad,

    output reg [2:0] cluster0_cnt,
    output reg [2:0] cluster1_cnt,
    output reg [2:0] cluster2_cnt,
    output reg [2:0] cluster3_cnt,
    output reg [2:0] cluster4_cnt,
    output reg [2:0] cluster5_cnt,
    output reg [2:0] cluster6_cnt,
    output reg [2:0] cluster7_cnt,

    // 8 bit ff'd register of matches found, with respect to the address in gemA
    output reg [MXCLUSTERS-1:0] match,
    output reg [MXCLUSTERS-1:0] match_upper,
    output reg [MXCLUSTERS-1:0] match_lower,

    output reg any_match, // Output: 1 bit, any match was found

    output reg [MXFEB-1:0] active_feb_list_copad,  // 24 bit register of active FEBs. Can be used e.g. in GEM only self-trigger

    output sump
);


parameter MXFEB      = 24;
parameter MXCLUSTERS = 8;
parameter MXADRB     = 11;
parameter MXCNTB     = 3;
parameter MXCLSTB    = 14;

//----------------------------------------------------------------------------------------------------------------------
// unpack and vectorize the inputs
//----------------------------------------------------------------------------------------------------------------------

 // insert ff for correct simulation standalone synthesis timing
 `ifdef debug_copad
    reg [2:0] gemA_cluster_roll [7:0];// 8-elements array 
    reg [7:0] gemA_cluster_pad  [7:0];// 8-elements array 
    reg [2:0] gemA_cluster_cnt  [7:0];// 8-elements array 
    reg [2:0] gemB_cluster_roll [7:0];// 8-elements array 
    reg [7:0] gemB_cluster_pad  [7:0];// 8-elements array 
    reg [2:0] gemB_cluster_cnt  [7:0];// 8-elements array 
    reg gemA_vpf[7:0];
    reg gemB_vpf[7:0];

    always @(posedge clock) begin
      gemA_vpf[0]          <= gemA_vpf0;
      gemA_vpf[1]          <= gemA_vpf1;
      gemA_vpf[2]          <= gemA_vpf2;
      gemA_vpf[3]          <= gemA_vpf3;
      gemA_vpf[4]          <= gemA_vpf4;
      gemA_vpf[5]          <= gemA_vpf5;
      gemA_vpf[6]          <= gemA_vpf6;
      gemA_vpf[7]          <= gemA_vpf7;

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

      gemB_vpf[0]          <= gemB_vpf0;
      gemB_vpf[1]          <= gemB_vpf1;
      gemB_vpf[2]          <= gemB_vpf2;
      gemB_vpf[3]          <= gemB_vpf3;
      gemB_vpf[4]          <= gemB_vpf4;
      gemB_vpf[5]          <= gemB_vpf5;
      gemB_vpf[6]          <= gemB_vpf6;
      gemB_vpf[7]          <= gemB_vpf7;

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
    wire [2:0] gemA_cluster_roll [7:0];// 8-elements array , each element is a 3 bits wire
    wire [7:0] gemA_cluster_pad  [7:0];// 8-elements array 
    wire [2:0] gemA_cluster_cnt  [7:0];// 8-elements array 
    wire [2:0] gemB_cluster_roll [7:0];// 8-elements array 
    wire [7:0] gemB_cluster_pad  [7:0];// 8-elements array 
    wire [2:0] gemB_cluster_cnt  [7:0];// 8-elements array 

    assign  gemA_vpf[0]          = gemA_vpf0;
    assign  gemA_vpf[1]          = gemA_vpf1;
    assign  gemA_vpf[2]          = gemA_vpf2;
    assign  gemA_vpf[3]          = gemA_vpf3;
    assign  gemA_vpf[4]          = gemA_vpf4;
    assign  gemA_vpf[5]          = gemA_vpf5;
    assign  gemA_vpf[6]          = gemA_vpf6;
    assign  gemA_vpf[7]          = gemA_vpf7;

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

    assign  gemB_vpf[0]          = gemB_vpf0;
    assign  gemB_vpf[1]          = gemB_vpf1;
    assign  gemB_vpf[2]          = gemB_vpf2;
    assign  gemB_vpf[3]          = gemB_vpf3;
    assign  gemB_vpf[4]          = gemB_vpf4;
    assign  gemB_vpf[5]          = gemB_vpf5;
    assign  gemB_vpf[6]          = gemB_vpf6;
    assign  gemB_vpf[7]          = gemB_vpf7;

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

wire [7:0] match_AB_c [MXCLUSTERS-1:0]; // same roll
wire [7:0] match_AB_u [MXCLUSTERS-1:0]; //upper roll, 
wire [7:0] match_AB_l [MXCLUSTERS-1:0]; //lower roll

wire [7:0] match_c;
wire [7:0] match_u;
wire [7:0] match_l;


wire [0:0] gemApad_at_left_edge  [MXCLUSTERS-1:0];
wire [0:0] gemApad_at_right_edge [MXCLUSTERS-1:0];
wire [7:0] minpad_match      [MXCLUSTERS-1:0];
wire [7:0] maxpad_match      [MXCLUSTERS-1:0];

wire [7:0] match_deltapad_8bits = match_neighborPad ? {4'b0, match_deltaPad} : 8'b0;

wire padmatch_Acluster_Bcluster [MXCLUSTERS-1:0][MXCLUSTERS-1:0];

genvar iclst;
generate
for (iclst=0; iclst<MXCLUSTERS; iclst=iclst+1) begin: clust_match_loop

  assign gemApad_at_left_edge  [iclst] = gemA_vpf[iclst] & (gemA_cluster_pad[iclst] < match_deltapad_8bits)
  assign gemApad_at_right_edge [iclst] = gemA_vpf[iclst] & ((gemA_cluster_pad[iclst] + match_deltapad_8bits + gemA_cluster_cnt[iclst]) > 8'd191)

  assign minpad_match [iclst] = gemApad_at_left_edge[iclst]  ? (8'd0)   : (gemA_cluster_pad[iclst] - match_deltapad_8bits);
  assign maxpad_match [iclst] = gemApad_at_right_edge[iclst] ? (8'd191) : (gemA_cluster_pad[iclst] + gemA_cluster_cnt[iclst] + match_deltapad_8bits);


  genvar iclstB;
  generate 
  for (iclstB=0; iclstB<MXCLUSTERS; iclstB+1) begin: clust_match_looop2
      //check whether pad in gemB cluster is within the match range derived from gemA cluster
      assign padmatch_Acluster_Bcluster[iclst][iclstB]  = (gemB_cluster_pad[iclstB] >= minpad_match[iclst] & gemB_cluster_pad[iclstB] <= maxpad_match[iclst]) | (gemB_cluster_pad[iclstB] + gemB_cluster_cnt[iclstB] >= minpad_match[iclst] & gemB_cluster_pad[iclstB] + gemB_cluster_cnt[iclstB] <= maxpad_match[iclst]);

      assign match_AB_c [iclst][iclstB] =  gemA_vpf[iclst] & gemB_vpf[iclstB] &  gemA_cluster_roll[iclst] == gemB_cluster_roll[iclstB] & padmatch_Acluster_Bcluster[iclst][iclstB];
      assign match_AB_u [iclst][iclstB]  = (gemA_cluster_roll[iclst] == 0) ? 1'b0 : (gemA_vpf[iclst] & gemB_vpf[iclstB] &  gemA_cluster_roll[iclst]-3'd1 == gemB_cluster_roll[iclstB] & padmatch_Acluster_Bcluster[iclst][iclstB]) : 1'b0
      assign match_AB_l [iclst][iclstB]  = (gemA_cluster_roll[iclst] == 7) ? 1'b0 : (gemA_vpf[iclst] & gemB_vpf[iclstB] &  gemA_cluster_roll[iclst]+3'd1 == gemB_cluster_roll[iclstB] & padmatch_Acluster_Bcluster[iclst][iclstB]);
      
  end 
  endgenerate

  assign match_c[iclst] = | match_AB_c[iclst];
  assign match_u[iclst] = | match_AB_u[iclst];
  assign match_l[iclst] = | match_AB_l[iclst];
end
endgenerate

wire [7:0] match_full  =   match_c   // full cluster match
                          | ({8{match_neighroll}} & match_u )
                          | ({8{match_neighroll}} & match_l );

wire any_match_full = (|match_full);

always @ (posedge clock) begin
  any_match            <= any_match_full;
  match         [7:0]  <= match_full;
  match_upper   [7:0]  <= match_u;
  match_lower   [7:0]  <= match_l;

end


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

//----------------------------------------------------------------------------------------------------------------------
endmodule
//----------------------------------------------------------------------------------------------------------------------
