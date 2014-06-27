`timescale 1ns / 1ps
//-------------------------------------------------------------------------------------------------------------------
//
// Virtex6: Pseudo-random bit signaling
//
//-------------------------------------------------------------------------------------------------------------------
//  09/05/2012  Port from TAMU PRBS_rx_c160.v
//  09/12/2012  Conform module names
//-------------------------------------------------------------------------------------------------------------------

module gtx_prbs_rx_c160
  (
   REC_CLK,
   CE1,
   CE3,
   RST,
   RCV_DATA,
   STRT_MTCH,
   VALID,
   MATCH
   );

   //-------------------------------------------------------------------------------------------------------------------
   // Generic
   //-------------------------------------------------------------------------------------------------------------------
   parameter start_pattern = 48'hFFFFFF000000;

   //-------------------------------------------------------------------------------------------------------------------
   // Ports
   //-------------------------------------------------------------------------------------------------------------------
   // Inputs
   input      REC_CLK;
   input      CE1;
   input      CE3;
   input      RST;
   input [47:0]     RCV_DATA;

   // Outputs
   output      STRT_MTCH;
   output      VALID;
   output      MATCH;

   // Output registers
   reg         VALID = 0;
   reg         MATCH = 0;

   //-------------------------------------------------------------------------------------------------------------------
   // Local
   //-------------------------------------------------------------------------------------------------------------------
   reg [47:0]       pipe1;
   reg [47:0]       pipe2;
   reg [47:0]       expct;
   wire [23:0]       lfsr;
   reg [23:0]       lfsr_a;
   reg [23:0]       lfsr_b;
   reg         start_pat;
   reg         valid_ena;
   reg         vld1,vld2;
   wire       ce80;

   //-------------------------------------------------------------------------------------------------------------------
   // Logic
   //-------------------------------------------------------------------------------------------------------------------
   assign ce80 = CE1 | CE3;
   assign STRT_MTCH = (RCV_DATA == start_pattern);

   always @(posedge REC_CLK or posedge RST) begin
      if      (RST)     valid_ena <= 1'b0;
      else if (start_pat)  valid_ena <= 1'b1;
      else        valid_ena <= valid_ena;
   end
   
   always @(posedge REC_CLK) begin
      if(ce80) begin
   start_pat  <= STRT_MTCH;
   vld1    <= !start_pat && valid_ena;
      end
   end

   //-------------------------------------------------------------------------------------------------------------------
   // Linear Feedback Shift Register
   // [24,23,22,17] Fibonacci Implementation
   //-------------------------------------------------------------------------------------------------------------------
   gtx_lfsr_r24_c160 #(.init_fill(24'h83B62E)) ugtx_lfsr_r24_c160
     (
      .CLK  (REC_CLK),    // In
      .CE    (ce80),      // In
      .RST  (start_pat),  // In
      .LFSR  (lfsr)      // Out
      );

   always @(posedge REC_CLK) begin
      if(CE3) lfsr_a <= lfsr;
   end

   always @(posedge REC_CLK) begin
      if(CE1) lfsr_b <= lfsr;
   end

   always @(posedge REC_CLK) begin
      if(CE3) begin
   pipe1  <= RCV_DATA;
   pipe2  <= pipe1;
   expct  <= {lfsr_a,lfsr_b};
   MATCH  <= (pipe2 == expct);
   vld2  <= vld1;
   VALID  <= vld2;
      end
   end

endmodule
