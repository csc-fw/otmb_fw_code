`timescale 1ns / 1ps

//------------------------------------------------------------------------------------------------------------------------
// Select triad decode version
//------------------------------------------------------------------------------------------------------------------------
  `define triad_decode_1srl    0  // Uncomment to instantiate 1 SRL version, compact, but cant re-fire or pulse-extend
//  `define triad_decode_4counter  0  // Uncomment to instantiate 4 Counter version, zero deadtime, with pulse extend

//------------------------------------------------------------------------------------------------------------------------
// Debug port map
//------------------------------------------------------------------------------------------------------------------------
//  `define triad_decode_debug     0  // Uncomment to insert triad input flip-flop stage for simulation

  `ifdef  triad_decode_debug
  `define triad_sm_dsp_debug  ,triad_sm_dsp
  `else
  `define triad_sm_dsp_debug   
  `endif

//------------------------------------------------------------------------------------------------------------------------
`ifdef triad_decode_1srl  
//------------------------------------------------------------------------------------------------------------------------
//
//  1 SRL version: Fast combinatorial output stage with 1bx flip-flop option, skipped-triad detection, 1-wide pulse capable
//
//------------------------------------------------------------------------------------------------------------------------
//
//  Decodes 1 Triad:
//    Receives a 3-bit serial triad of time-multiplexed DiStrip/Strip/HStrip data
//    Outputs 4 half-strip pulses
//
//  Programmable persistence output pulses range 1-to-16 bx, 25ns to 400ns  
//
//  11/30/06  Initial
//  12/01/06 Add zero-deadtime triad decoder state machine
//  12/04/06 Prevent simultaneous set+clear on output FFs
//  12/05/06 Replace delay SRLs with 4-bit counters, because SRLs cannot clear to allow pulse-extending
//  03/16/07 Reduce to only 1 4-bit counter to save FPGA space, can no longer have multiple hstrips firing at same time
//  03/21/07 Replace counter with SRL, remove pgmlut input
//  03/29/07 Replace output sync FFs with async-set FFs
//  04/02/07 Give up on async FFs, too many glitch issues, add combinatorial bypass instead, speeds up output by 1 clock
//  04/11/07 Replace bypass with transparent FFs beco bypass logic added 2 more slices, 30% of the total
//  04/13/07 Revert to d-type output FFs, transparent latch version fails when triads come close in time
//  04/16/07 Remove output FFs, instead latch strip and 1/2 strip, then output through a 1-of-4 mux, uses less logic
//  04/17/07 Separate FFs for state machine busy and pulse duration
//  04/18/07 Add sm busy to block triads that arrive while holding output pulse
//  04/19/06 Move sm busy FF into new state machine skip state
//  08/04/10 Port to ise 12
//  08/04/10 Add state machine display
//  08/04/10 Change to non-blocking operators
//  08/06/10 Integer truncation for ise 12
//  08/19/10 Replace * with &
//------------------------------------------------------------------------------------------------------------------------
  module triad_decode(clock,reset,persist,persist1,triad,h_strip,triad_skip `triad_sm_dsp_debug);

// Version
  initial $display ("triad_decode: Instantiating 1-SRL Version");

// Ports
  input      clock;        // 40MHz system clock
  input      reset;        // State machine to idle
  input  [3:0]  persist;      // Output persistence-1, ie 5 gives 6-clk width
  input      persist1;      // Output persistence is 1, use with  persist=0
  input      triad;        // 3-bit serial triad
  output  [3:0]  h_strip;      // 4-bit parallel 1/2-strips
  output      triad_skip;      // Triad was skipped while busy with previus triad

// Triad Decode State Machine declarations
  parameter NSTATEB  =  2;      // number of state vector bits
  reg  [NSTATEB-1:0] triad_sm;      // synthesis attribute safe_implementation of triad_sm is yes;
  parameter idle    =  2'b00;    // synthesis attribute fsm_encoding        of triad_sm is gray;
  parameter lstrip  =  2'b01;
  parameter lhstrip  =  2'b11;
  parameter skip    =  2'b10;

// FF Buffer triad input stream for simulation only, needed for correct simulation of combinatorial fast h_strip output
  `ifdef triad_decode_debug
  initial $display ("triad_decode: Inserting simulation flip-flop on triad input signal !!!!");
  
  reg triad_ff=0;
  always @(posedge clock) begin        // FF triad input stream only for simulation
  triad_ff <= triad;
  end

  `else
  initial $display ("triad_decode: Using direct triad input signal");
  wire triad_ff = triad;            // take direct triad stream for synthesis
  `endif

// Triad Decode State Machine
  reg  busy_hs_ff=0;
  wire srl_out;

  wire skip_sm = busy_hs_ff && !srl_out;    // skips latching new triad if busy with previous triad

  always @(posedge clock) begin
  if(reset)         triad_sm <= idle;
  else begin
  case (triad_sm)
  idle:  if (triad_ff) triad_sm <= lstrip;  // start bit arrived
  lstrip:  if (skip_sm ) triad_sm <= skip;    // skip it if busy with last triad
          else      triad_sm <= lhstrip;  // not busy, so latch strip bit
  lhstrip:        triad_sm <= idle;    // not busy, so latch 1/2 strip bit
  skip:          triad_sm <= idle;    // triad skipped
  endcase
  end
  end

  assign triad_skip = (triad_sm==skip);    // triad was skipped

// Store strip and 1/2-strip bits, when not busy with previous hs
  reg  strip=0;
  reg  hstrip_ff=0;
  wire busy_hs;

  wire busy_sm      = ((triad_sm==lstrip ) &&  busy_hs_ff && !srl_out) || (triad_sm==skip);
  wire latch_strip  =  (triad_sm==lstrip ) && !skip_sm;
  wire latch_hstrip =  (triad_sm==lhstrip);
  wire hstrip       = ((triad_sm==lhstrip) && !busy_sm && triad_ff) || hstrip_ff;  // fast output of hs saves 1bx

  always @(posedge clock) begin            // latch strip bit from triad string
  if (latch_strip) strip <= triad_ff;
  end

  always @(posedge clock) begin            // latch 1/2-strip bit from triad string
  if    (latch_strip ) hstrip_ff <= 0;        // clear 1/2-strip while loading strip bit, so hstrip OR is correct
  else if (latch_hstrip) hstrip_ff <= triad_ff;
  end

// Pulse-width persistence SRL
  wire fire_hs  = (triad_sm==lhstrip);        // fire the decoded hstrip
  wire clear_hs = (srl_out || reset ) && !fire_hs;  // unfire it, unless 2nd triad arrived at same time
  wire srl_in    = latch_strip;

  always @(posedge clock or posedge persist1) begin
  if (persist1) busy_hs_ff <= 0;            // never go busy if pulse width is 1
  else begin
  if (clear_hs) busy_hs_ff <= 0;            // go unbusy next bx
  if (fire_hs ) busy_hs_ff <= 1;            // go busy next bx
  end
  end

  assign busy_hs = busy_hs_ff || fire_hs;        // asserts decoded h_strip outputs

  SRL16E usrl (.CLK(clock),.CE(1'b1),.D(srl_in),.A0(persist[0]),.A1(persist[1]),.A2(persist[2]),.A3(persist[3]),.Q(srl_out));

// Decode triad 1/2-strip, blank outputs when idle
  reg  [3:0] h_strip;
  wire [1:0] adr;

  assign adr = {strip,hstrip};

  always @(posedge clock) begin
  casex ({!busy_hs,adr})
  3'b000: h_strip <= 4'b0001;
  3'b001: h_strip <= 4'b0010;
  3'b010: h_strip <= 4'b0100; 
  3'b011: h_strip <= 4'b1000;
  3'b1xx: h_strip <= 4'b0000;
  endcase
  end

// Debug
   `ifdef triad_decode_debug
  output reg [31:0] triad_sm_dsp;

  always @* begin
  case (triad_sm)
  idle:    triad_sm_dsp <= "idle";  // start bit arrived
  lstrip:  triad_sm_dsp <= "str ";  // skip it if busy with last triad
  lhstrip: triad_sm_dsp <= "hstr";  // not busy, so latch 1/2 strip bit
  skip:    triad_sm_dsp <= "skip";  // triad skipped
  default: triad_sm_dsp <= "wtf ";  // undefined
  endcase
  end
   `endif

  endmodule

`endif

//------------------------------------------------------------------------------------------------------------------------
`ifdef triad_decode_4counter
//------------------------------------------------------------------------------------------------------------------------
//
// 4 Counter Version:  Independent counters for each 1/2-strip, never skips triads, does not use persist1 or triad_skip
//
//------------------------------------------------------------------------------------------------------------------------
//  Decodes 1 Triad:
//    Receives a 3-bit serial triad of time-multiplexed DiStrip/Strip/HStrip data
//    Outputs 4 half-strip pulses
//
//  Programmable persistence output pulses range 1-to-16 bx, 25ns to 400ns  
//  A 2nd triad arriving during an hstrip pulse extends the pulse width by restarting its counter
//
//  11/30/06  Initial
//  12/01/06 Add zero-deadtime triad decoder state machine
//  12/04/06 Prevent simultaneous set+clear on output FFs
//  12/05/06 Replace delay SRLs with 4-bit counters, because SRLs cannot clear to allow pulse-extending
//  04/26/07 Copy from tmb2005e folder
//  08/04/10 Port to ise 12
//  08/04/10 Add state machine display
//  08/04/10 Change to non-blocking operators
//  08/06/10 Integer truncation for ise 12
//------------------------------------------------------------------------------------------------------------------------
  module triad_decode(clock,reset,persist,triad,h_strip `triad_sm_dsp_debug);

// Version
  initial $display ("triad_decode: Instantiating 4-Counter Version");

// Ports
  input      clock;        // 40MHz system clock
  input      reset;        // State machine to idle
  input  [3:0]  persist;      // Output persistence-1, ie 5 gives 6-clk width
  input      triad;        // 3-bit serial triad
  output  [3:0]  h_strip;      // 4-bit parallel 1/2-strips

// Triad Decode State Machine declarations
  parameter NSTATES  =  3;
  reg  [NSTATES-1:0] triad_sm;      // synthesis attribute safe_implementation of triad_sm is "yes";
  parameter idle    =  2'h0;
  parameter lstrip  =  2'h1;
  parameter lhstrip  =  2'h2;

// FF Buffer triad input stream for simulation only, needed for correct simulation of combinatorial fast h_strip output
  `ifdef triad_decode_debug
  initial $display ("triad_decode: Inserting simulation flip-flop on triad input signal !!!!");
  
  reg triad_ff=0;
  always @(posedge clock) begin    // FF triad input stream only for simulation
  triad_ff <= triad;
  end

  `else
  initial $display ("triad_decode: Using direct triad input signal");
  wire triad_ff = triad;        // take direct triad stream for synthesis
  `endif

// Triad Decode State Machine
  always @(posedge clock) begin
  if(reset)       triad_sm <= idle;
  else begin
  case (triad_sm)
  idle: if (triad_ff)  triad_sm <= lstrip;
  lstrip:        triad_sm <= lhstrip;
  lhstrip:      triad_sm <= idle;
  endcase
  end
  end

// Store strip bit
  reg strip;
  
  always @(posedge clock) begin
  if (triad_sm == lstrip ) strip  <= triad_ff;
  end

  wire hstrip = triad_ff;

// hstrip decoder ROM
  reg  [3:0] hs;
  wire [1:0] adr;
  
  assign adr = {strip,hstrip};

  always @* begin
  case (adr)
  2'h0: hs <= 4'b0001; 
  2'h1: hs <= 4'b0010; 
  2'h2: hs <= 4'b0100; 
  2'h3: hs <= 4'b1000;
  endcase
  end

// Pulse-width persistence counters
  reg  [3:0] width_cnt [3:0];
  wire [3:0] fire_hs;
  wire [3:0] busy_hs;
  integer ihs;

  assign busy_hs[0] = width_cnt[0]!=0; 
  assign busy_hs[1] = width_cnt[1]!=0; 
  assign busy_hs[2] = width_cnt[2]!=0; 
  assign busy_hs[3] = width_cnt[3]!=0; 

//!  assign fire_hs[3:0] = hs[3:0]*(triad_sm==lhstrip);
  assign fire_hs[3:0] = hs[3:0] & {4 {(triad_sm==lhstrip)}};
  
  always @(posedge clock) begin
  ihs=0;
  while (ihs <=3) begin
  if    (reset)      width_cnt[ihs] <= 0;          // clear on reset
  else if (fire_hs[ihs])  width_cnt[ihs] <= persist[3:0];      // load persistence count
  else if (busy_hs[ihs])  width_cnt[ihs] <= width_cnt[ihs]-1'b1;  // decrement count down to 0
  ihs=ihs+1;
  end
  end

// hstrip pulse output flip-flops
  reg [3:0] h_strip;

  always @(posedge clock) begin
  if    (reset ) h_strip[3:0] <= 0;                // synchronous reset clears hstrips
  else       h_strip[3:0] <= busy_hs[3:0] | fire_hs[3:0];  // fire i-th hstrip
  end

// Debug
   `ifdef triad_decode_debug
  output reg [31:0] triad_sm_dsp;

  always @* begin
  case (triad_sm)
  idle:    triad_sm_dsp <= "idle";  // start bit arrived
  lstrip:  triad_sm_dsp <= "str ";  // skip it if busy with last triad
  lhstrip: triad_sm_dsp <= "hstr";  // not busy, so latch 1/2 strip bit
  default: triad_sm_dsp <= "wtf ";  // undefined
  endcase
  end
   `endif

  endmodule

`endif
//------------------------------------------------------------------------------------------------------------------------
// End triad_decode.v
//------------------------------------------------------------------------------------------------------------------------
