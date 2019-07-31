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
//----------------------------------------------------------------------------------------------------------------------

module copad (

    input clock, // 40MHz fabric clock

    input match_neighbors, // set high for the copad finder to match on neighboring (+/- one) pads

    // 8 clusters from gemA
    input [13:0] gemA_cluster0,
    input [13:0] gemA_cluster1,
    input [13:0] gemA_cluster2,
    input [13:0] gemA_cluster3,
    input [13:0] gemA_cluster4,
    input [13:0] gemA_cluster5,
    input [13:0] gemA_cluster6,
    input [13:0] gemA_cluster7,

    // 8 clusters from gemB
    input [13:0] gemB_cluster0,
    input [13:0] gemB_cluster1,
    input [13:0] gemB_cluster2,
    input [13:0] gemB_cluster3,
    input [13:0] gemB_cluster4,
    input [13:0] gemB_cluster5,
    input [13:0] gemB_cluster6,
    input [13:0] gemB_cluster7,


    // ff'd copies (1bx delay) of the gemA inputs
    output reg [MXCLSTB-1:0] cluster0,
    output reg [MXCLSTB-1:0] cluster1,
    output reg [MXCLSTB-1:0] cluster2,
    output reg [MXCLSTB-1:0] cluster3,
    output reg [MXCLSTB-1:0] cluster4,
    output reg [MXCLSTB-1:0] cluster5,
    output reg [MXCLSTB-1:0] cluster6,
    output reg [MXCLSTB-1:0] cluster7,

    // 8 bit ff'd register of matches found, with respect to the address in gemA
    output reg [MXCLUSTERS-1:0] match,

    output reg [MXCLUSTERS-1:0] match_right, // 8 bit flag that the match was found on the rhs of gemA adr
    output reg [MXCLUSTERS-1:0] match_left,  // 8 bit flag that the match was found on the lhs of gemA adr

    output reg any_match, // Output: 1 bit, any match was found

    output reg [MXFEB-1:0] active_feb_list,  // 24 bit register of active FEBs. Can be used e.g. in GEM only self-trigger

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
    reg [MXCLSTB-1:0] gem_cluster [1:0][7:0];

    always @(posedge clock) begin
      gem_cluster[0][0] <= gemA_cluster0;
      gem_cluster[0][1] <= gemA_cluster1;
      gem_cluster[0][2] <= gemA_cluster2;
      gem_cluster[0][3] <= gemA_cluster3;
      gem_cluster[0][4] <= gemA_cluster4;
      gem_cluster[0][5] <= gemA_cluster5;
      gem_cluster[0][6] <= gemA_cluster6;
      gem_cluster[0][7] <= gemA_cluster7;

      gem_cluster[1][0] <= gemB_cluster0;
      gem_cluster[1][1] <= gemB_cluster1;
      gem_cluster[1][2] <= gemB_cluster2;
      gem_cluster[1][3] <= gemB_cluster3;
      gem_cluster[1][4] <= gemB_cluster4;
      gem_cluster[1][5] <= gemB_cluster5;
      gem_cluster[1][6] <= gemB_cluster6;
      gem_cluster[1][7] <= gemB_cluster7;
    end
 `else
    wire [MXCLSTB-1:0] gem_cluster [1:0][7:0];

    assign gem_cluster[0][0] = gemA_cluster0;
    assign gem_cluster[0][1] = gemA_cluster1;
    assign gem_cluster[0][2] = gemA_cluster2;
    assign gem_cluster[0][3] = gemA_cluster3;
    assign gem_cluster[0][4] = gemA_cluster4;
    assign gem_cluster[0][5] = gemA_cluster5;
    assign gem_cluster[0][6] = gemA_cluster6;
    assign gem_cluster[0][7] = gemA_cluster7;

    assign gem_cluster[1][0] = gemB_cluster0;
    assign gem_cluster[1][1] = gemB_cluster1;
    assign gem_cluster[1][2] = gemB_cluster2;
    assign gem_cluster[1][3] = gemB_cluster3;
    assign gem_cluster[1][4] = gemB_cluster4;
    assign gem_cluster[1][5] = gemB_cluster5;
    assign gem_cluster[1][6] = gemB_cluster6;
    assign gem_cluster[1][7] = gemB_cluster7;

 `endif

  /*
  *  14 bit hit format encoding
  *   hit[10:0]  = starting address
  *   hit[13:11] = n additional pads hit  up to 7
  */

  wire [MXADRB-1:0] adr    [1:0][MXCLUSTERS-1:0];
  wire [MXADRB-1:0] adr0_p      [MXCLUSTERS-1:0]; // adr+1
  wire [MXADRB-1:0] adr0_m      [MXCLUSTERS-1:0]; // adr-1

  wire [MXCNTB-1:0] cnt    [1:0][MXCLUSTERS-1:0];
  wire              vpf    [1:0][MXCLUSTERS-1:0];

  // unpack the cnts and adrs here; cnts are used, but save them for later (probably useful with vfat3)

  assign {cnt[0][0], adr[0][0]} = gem_cluster[0][0];
  assign {cnt[0][1], adr[0][1]} = gem_cluster[0][1];
  assign {cnt[0][2], adr[0][2]} = gem_cluster[0][2];
  assign {cnt[0][3], adr[0][3]} = gem_cluster[0][3];
  assign {cnt[0][4], adr[0][4]} = gem_cluster[0][4];
  assign {cnt[0][5], adr[0][5]} = gem_cluster[0][5];
  assign {cnt[0][6], adr[0][6]} = gem_cluster[0][6];
  assign {cnt[0][7], adr[0][7]} = gem_cluster[0][7];

  assign {cnt[1][0], adr[1][0]} = gem_cluster[1][0];
  assign {cnt[1][1], adr[1][1]} = gem_cluster[1][1];
  assign {cnt[1][2], adr[1][2]} = gem_cluster[1][2];
  assign {cnt[1][3], adr[1][3]} = gem_cluster[1][3];
  assign {cnt[1][4], adr[1][4]} = gem_cluster[1][4];
  assign {cnt[1][5], adr[1][5]} = gem_cluster[1][5];
  assign {cnt[1][6], adr[1][6]} = gem_cluster[1][6];
  assign {cnt[1][7], adr[1][7]} = gem_cluster[1][7];

  // make a copy of the span of address + 8
  assign adr0_p [0] = adr[0][0] + 4'd8;
  assign adr0_p [1] = adr[0][1] + 4'd8;
  assign adr0_p [2] = adr[0][2] + 4'd8;
  assign adr0_p [3] = adr[0][3] + 4'd8;
  assign adr0_p [4] = adr[0][4] + 4'd8;
  assign adr0_p [5] = adr[0][5] + 4'd8;
  assign adr0_p [6] = adr[0][6] + 4'd8;
  assign adr0_p [7] = adr[0][7] + 4'd8;

  // make a copy of the span of address - 8
  assign adr0_m [0] = adr[0][0] - 4'd8;
  assign adr0_m [1] = adr[0][1] - 4'd8;
  assign adr0_m [2] = adr[0][2] - 4'd8;
  assign adr0_m [3] = adr[0][3] - 4'd8;
  assign adr0_m [4] = adr[0][4] - 4'd8;
  assign adr0_m [5] = adr[0][5] - 4'd8;
  assign adr0_m [6] = adr[0][6] - 4'd8;
  assign adr0_m [7] = adr[0][7] - 4'd8;

  // extract valid cluster flags
  genvar i;
  genvar j;
  generate
  for (i=0; i<2; i=i+1) begin: i_loop
  for (j=0; j<8; j=j+1) begin: j_loop
    // if bits 10 and 9 are both 1, then we are in address space > 1535 signifying a blank cluster
    assign vpf[i][j] = ~(&adr[i][j][10:9]);
  end
  end
  endgenerate

//----------------------------------------------------------------------------------------------------------------------
//
//----------------------------------------------------------------------------------------------------------------------

wire [7:0] match_c;
wire [7:0] match_r;
wire [7:0] match_l;

wire [0:0] adr_at_left_edge  [MXCLUSTERS-1:0];
wire [0:0] adr_at_right_edge [MXCLUSTERS-1:0];

genvar iclst;
generate
for (iclst=0; iclst<MXCLUSTERS; iclst=iclst+1) begin: clust_match_loop

  // we don't want to form left matches at the left edge of the chamber
  assign adr_at_left_edge [iclst] = (adr[0][iclst] == 0    )|
                                    (adr[0][iclst] == 192  )|
                                    (adr[0][iclst] == 384  )|
                                    (adr[0][iclst] == 576  )|
                                    (adr[0][iclst] == 768  )|
                                    (adr[0][iclst] == 960  )|
                                    (adr[0][iclst] == 1152 )|
                                    (adr[0][iclst] == 1344 );

  // we don't want to form right matches at the right edge of the chamber
  assign adr_at_right_edge [iclst] = (adr[0][iclst] == 191  - 7) |
                                     (adr[0][iclst] == 383  - 7) |
                                     (adr[0][iclst] == 575  - 7) |
                                     (adr[0][iclst] == 767  - 7) |
                                     (adr[0][iclst] == 959  - 7) |
                                     (adr[0][iclst] == 1151 - 7) |
                                     (adr[0][iclst] == 1535 - 7);

  // match is in the center of gemA cluster (full match)
  assign match_c  [iclst] =  vpf[0][iclst] &            // gemA cluster is valid
                           ( adr[0][iclst] == adr[1][0] // full match to gemB cluster0
                           | adr[0][iclst] == adr[1][1] // full match to gemB cluster1
                           | adr[0][iclst] == adr[1][2] // full match to gemB cluster2
                           | adr[0][iclst] == adr[1][3] // full match to gemB cluster3
                           | adr[0][iclst] == adr[1][4] // full match to gemB cluster4
                           | adr[0][iclst] == adr[1][5] // full match to gemB cluster5
                           | adr[0][iclst] == adr[1][6] // full match to gemB cluster6
                           | adr[0][iclst] == adr[1][7] // full match to gemB cluster7
                          );                            // gemB cluster automatically valid if there is a match

  // match is on the left side of gemA cluster
  assign match_l [iclst] = !adr_at_left_edge[iclst] & // don't form matches at right edge
                            vpf[0][iclst] &           // gemA cluster is valid
                          ( adr0_m[iclst]==adr[1][0]  // left side match to gemB cluster0
                          | adr0_m[iclst]==adr[1][1]  // left side match to gemB cluster1
                          | adr0_m[iclst]==adr[1][2]  // left side match to gemB cluster2
                          | adr0_m[iclst]==adr[1][3]  // left side match to gemB cluster3
                          | adr0_m[iclst]==adr[1][4]  // left side match to gemB cluster4
                          | adr0_m[iclst]==adr[1][5]  // left side match to gemB cluster5
                          | adr0_m[iclst]==adr[1][6]  // left side match to gemB cluster6
                          | adr0_m[iclst]==adr[1][7]  // left side match to gemB cluster7
                          );                          // gemB cluster automatically valid if there is a match

  // match is on the right side of gemA cluster
  assign match_r [iclst] = !adr_at_right_edge[iclst] & // don't form matches at right edge
                            vpf[0][iclst] &            // gemA cluster is valid
                          ( adr0_p[iclst]==adr[1][0]   // right side match to gemB cluster0
                          | adr0_p[iclst]==adr[1][1]   // right side match to gemB cluster1
                          | adr0_p[iclst]==adr[1][2]   // right side match to gemB cluster2
                          | adr0_p[iclst]==adr[1][3]   // right side match to gemB cluster3
                          | adr0_p[iclst]==adr[1][4]   // right side match to gemB cluster4
                          | adr0_p[iclst]==adr[1][5]   // right side match to gemB cluster5
                          | adr0_p[iclst]==adr[1][6]   // right side match to gemB cluster6
                          | adr0_p[iclst]==adr[1][7]   // right side match to gemB cluster7
                          );                           // gemB cluster automatically valid if there is a match
end
endgenerate

wire [7:0] match_fast  =   match_c   // full cluster match
                          | ({8{match_neighbors}} & match_r )
                          | ({8{match_neighbors}} & match_l );

wire any_match_fast = (|match_fast);

always @ (posedge clock) begin
  any_match           <= any_match_fast;
  match         [7:0] <= match_fast;
  match_left    [7:0] <= match_l;
  match_right   [7:0] <= match_r;

  // ff copy the clusters from gemA to delay 1bx to lineup with output
  cluster0 <= gem_cluster[0][0];
  cluster1 <= gem_cluster[0][1];
  cluster2 <= gem_cluster[0][2];
  cluster3 <= gem_cluster[0][3];
  cluster4 <= gem_cluster[0][4];
  cluster5 <= gem_cluster[0][5];
  cluster6 <= gem_cluster[0][6];
  cluster7 <= gem_cluster[0][7];
end



// form a list of 8 Active FEBs with clusters in gemA
//wire [4:0] cluster_feb [MXCLUSTERS-1:0];
reg [4:0] cluster_feb [MXCLUSTERS-1:0];
generate
for (iclst=0; iclst<MXCLUSTERS; iclst=iclst+1) begin: feb_assign_loop
  // assign cluster_feb[iclst] = adr[0][iclst] >> 6;  // shr6 is a floored div64, which gives us the 5 bit VFAT-ID of the cluster

  // chamber looks like this  (for dumb reasons that can't be helped)
  //  0  8  16
  //  1  9  17
  //  2  10 18
  //  3  11 19
  //  4  12 20
  //  5  13 21
  //  6  14 22
  //  7  15 23
  //
  // the upper 5 bits of the address need to be mapped to VFAT-IDs..
  // but naturally the upper 5-bits produce a map like
  //  0   1    2
  //  3   4    5
  //  6   7    8
  //  9   10   11
  //  12  13   14
  //  15  16   17
  //  18  19   20
  //  21  22   23

  always @(*) begin
  case (adr[0][iclst][10:6]) // adr[10:6] is the "natural" vfatid
    5'd0:    cluster_feb[iclst] = 5'd0;
    5'd1:    cluster_feb[iclst] = 5'd8;
    5'd2:    cluster_feb[iclst] = 5'd16;
    5'd3:    cluster_feb[iclst] = 5'd1;
    5'd4:    cluster_feb[iclst] = 5'd9;
    5'd5:    cluster_feb[iclst] = 5'd17;
    5'd6:    cluster_feb[iclst] = 5'd2;
    5'd7:    cluster_feb[iclst] = 5'd10;
    5'd8:    cluster_feb[iclst] = 5'd18;
    5'd9:    cluster_feb[iclst] = 5'd3;
    5'd10:   cluster_feb[iclst] = 5'd11;
    5'd11:   cluster_feb[iclst] = 5'd19;
    5'd12:   cluster_feb[iclst] = 5'd4;
    5'd13:   cluster_feb[iclst] = 5'd12;
    5'd14:   cluster_feb[iclst] = 5'd20;
    5'd15:   cluster_feb[iclst] = 5'd5;
    5'd16:   cluster_feb[iclst] = 5'd13;
    5'd17:   cluster_feb[iclst] = 5'd21;
    5'd18:   cluster_feb[iclst] = 5'd6;
    5'd19:   cluster_feb[iclst] = 5'd14;
    5'd20:   cluster_feb[iclst] = 5'd22;
    5'd21:   cluster_feb[iclst] = 5'd7;
    5'd22:   cluster_feb[iclst] = 5'd15;
    5'd23:   cluster_feb[iclst] = 5'd23;
    default: cluster_feb[iclst] = 5'd24;
  endcase
  end

end
endgenerate

// form a 24 bit list of active febs, based on presence of cluster in gemA
genvar ifeb;
generate
for (ifeb=0; ifeb<MXFEB; ifeb=ifeb+1)     begin:   feb_match_loop
  always @(posedge clock) begin
  active_feb_list [ifeb] <= (cluster_feb[0]==ifeb && match_fast[0]) |
                            (cluster_feb[1]==ifeb && match_fast[1]) |
                            (cluster_feb[2]==ifeb && match_fast[2]) |
                            (cluster_feb[3]==ifeb && match_fast[3]) |
                            (cluster_feb[4]==ifeb && match_fast[4]) |
                            (cluster_feb[5]==ifeb && match_fast[5]) |
                            (cluster_feb[6]==ifeb && match_fast[6]) |
                            (cluster_feb[7]==ifeb && match_fast[7]);
  end
end
endgenerate

assign sump =
              (|cnt[0][0])
            | (|cnt[0][1])
            | (|cnt[0][2])
            | (|cnt[0][3])
            | (|cnt[0][4])
            | (|cnt[0][5])
            | (|cnt[0][6])
            | (|cnt[0][7])
            | (|cnt[1][0])
            | (|cnt[1][1])
            | (|cnt[1][2])
            | (|cnt[1][3])
            | (|cnt[1][4])
            | (|cnt[1][5])
            | (|cnt[1][6])
            | (|cnt[1][7]);

//----------------------------------------------------------------------------------------------------------------------
endmodule
//----------------------------------------------------------------------------------------------------------------------
