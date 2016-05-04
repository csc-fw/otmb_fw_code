module gem_sync_mon (

  input clock,

  input global_reset,
  input ttc_resync,

  input [7:0] gem0_kchar,
  input [7:0] gem1_kchar,
  input [7:0] gem2_kchar,
  input [7:0] gem3_kchar,

  output reg gem0_synced,  // fibers from same OH are desynced
  output reg gem1_synced,  // fibers from same OH are desynced
  output reg gems_synced,  // fibers from both GEM chambers are synched

  // latched copies that gems have lost sync in past
  output reg gem0_lostsync,
  output reg gem1_lostsync,
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


initial gem0_synced = 1'b1;
initial gem1_synced = 1'b1;
initial gems_synced = 1'b1;

initial gem0_lostsync = 1'b0;
initial gem1_lostsync = 1'b0;
initial gems_lostsync = 1'b0;


always @(posedge clock) begin
  if (reset)  begin
    gem0_synced     <= 1'b1;
    gem1_synced     <= 1'b1;
    gems_synced     <= 1'b1;

    gem0_lostsync   <= 1'b0;
    gem1_lostsync   <= 1'b0;
    gems_lostsync   <= 1'b0;
  end
  else begin
    gem0_synced <= gem_sync [0];
    gem1_synced <= gem_sync [1];
    gems_synced <= gems_sync;

    gem0_lostsync <= gem0_lostsync | ~gem_sync[0];
    gem1_lostsync <= gem1_lostsync | ~gem_sync[1];
    gems_lostsync <= gems_lostsync | ~gems_synced;

  end
end


endmodule
