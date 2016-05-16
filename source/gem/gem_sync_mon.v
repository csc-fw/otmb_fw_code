module gem_sync_mon (

  input clock,

  input global_reset,
  input ttc_resync,

  input [7:0] gem0_kchar,
  input [7:0] gem1_kchar,
  input [7:0] gem2_kchar,
  input [7:0] gem3_kchar,

  output reg gemA_synced,  // fibers from same OH are desynced
  output reg gemB_synced,  // fibers from same OH are desynced
  output reg gems_synced,  // fibers from both GEM chambers are synched

  // latched copies that gems have lost sync in past
  output reg gemA_lostsync,
  output reg gemB_lostsync,
  output reg gems_lostsync
);

//----------------------------------------------------------------------------------------------------------------------
// state machine power-up reset + global reset
//----------------------------------------------------------------------------------------------------------------------

  wire [3:0] pdly   = 1;    // Power-up reset delay
  reg        ready  = 0;

  SRL16E upup (.CLK(clock),.CE(!power_up & clk_lock),.D(1'b1),.A0(pdly[0]),.A1(pdly[1]),.A2(pdly[2]),.A3(pdly[3]),.Q(power_up));

  always @(posedge clock) begin
      ready  <= power_up && !(global_reset || ttc_resync);
  end

  wire reset  = !ready;  // reset

//----------------------------------------------------------------------------------------------------------------------
//
//----------------------------------------------------------------------------------------------------------------------

wire [1:0] gem_sync;
wire       gems_sync;

assign gem_sync [0] = (gem0_kchar==gem1_kchar);  // two fibers from gem chamber 1 are synced to eachother
assign gem_sync [1] = (gem2_kchar==gem3_kchar);  // two fibers from gem chamber 2 are synced to eachother
assign gems_sync    = (gem0_kchar==gem2_kchar) && (&gem_sync[1:0]); // gem super chamber is synced


initial gemA_synced = 1'b1;
initial gemB_synced = 1'b1;
initial gems_synced = 1'b1;

initial gemA_lostsync = 1'b0;
initial gemB_lostsync = 1'b0;
initial gems_lostsync = 1'b0;


always @(posedge clock) begin
  if (reset)  begin
    gemA_synced     <= 1'b1;
    gemB_synced     <= 1'b1;
    gems_synced     <= 1'b1;

    gemA_lostsync   <= 1'b0;
    gemB_lostsync   <= 1'b0;
    gems_lostsync   <= 1'b0;
  end
  else begin
    gemA_synced <= gem_sync [0];
    gemB_synced <= gem_sync [1];
    gems_synced <= gems_sync;

    gemA_lostsync <= gemA_lostsync | ~gem_sync[0];
    gemB_lostsync <= gemB_lostsync | ~gem_sync[1];
    gems_lostsync <= gems_lostsync | ~gems_synced;

  end
end


endmodule
