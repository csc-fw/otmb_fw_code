`timescale 1ns / 1ps
//`define DEBUG_PHASER = 1
//-----------------------------------------------------------------------------------------------------------------
//  DCM Digital phase shift State Machine
//-----------------------------------------------------------------------------------------------------------------
//  06/10/2009  Initial
//  06/11/2009  Change to continuous psclk
//  06/15/2009  Change to -32 to +31 phase range to span 25/4=6.25ns
//  09/11/2009  Add quadrant FF update strobe
//  09/13/2009  FF buffer update strobe
//  09/30/2010  Port to ISE 12
//  11/08/2010  Add virtex6 option for wider phase counter
//  11/18/2010  Correction to virtex2 bus width
//  02/13/2013  Virtex-6 only
//-----------------------------------------------------------------------------------------------------------------
  module phaser
  (
// Clocks
  clock,
  global_reset,

// DCM lock status ports
  lock_tmb,
  lock_dcm,

// DCM digital phase shift ports
  psen,
  psincdec,
  psdone,

// VME control/status ports
  fire,
  reset,
  phase,
  busy,
  dps_sm_vec

// Debug ports
  `ifdef DEBUG_PHASER
  ,current_phase
  ,dps_sm_dsp
  `endif
    );
//-----------------------------------------------------------------------------------------------------------------
// Firmware type determines phase port and counter widths
//-----------------------------------------------------------------------------------------------------------------
  parameter MXPHASE=11;
  initial  $display("phaser: MXPHASE=%d",MXPHASE);

//-----------------------------------------------------------------------------------------------------------------
// Ports
//-----------------------------------------------------------------------------------------------------------------
// Clocks
  input          clock;        // 40MHz global TMB clock 1x
  input          global_reset;    // Global reset, asserted until main DLL locks

// DCM lock status ports
  input          lock_tmb;      //  Lock state for TMB main clock DLL
  input          lock_dcm;      //  Lock state for this DCM

// DCM digital phase shift ports
  output          psen;        // Dps phase shift enable
  output          psincdec;      // Dps phase increment/decrement
  input          psdone;        // Dps done

// VME control/status ports
  input          fire;        // VME Set new phase
  input          reset;        // VME Reset current phase
  input  [MXPHASE-1:0]  phase;        // VME Phase to set, 0-63
  output          busy;        // VME Phase shifter busy
  output  [2:0]      dps_sm_vec;      // VME Phase shifter machine state

// Debug ports
  `ifdef DEBUG_PHASER
  output  [MCPHPASE-1:0]  current_phase;    // Current dcm phase
  output  [47:0]      dps_sm_dsp;      // State Machine ASCII display
  `endif

//-----------------------------------------------------------------------------------------------------------------
//  Digital phase shift State Machine
//-----------------------------------------------------------------------------------------------------------------
// State Machine declarations
  reg  [6:0] dps_sm;    // synthesis attribute safe_implementation of dps_sm is "yes";
  reg  [2:0] dps_sm_vec;

  parameter idle    =  7'h0;
  parameter wait_tmb  =  7'h1;
  parameter wait_dcm  =  7'h2;
  parameter init_dps  =  7'h3;
  parameter inc_dec  =  7'h4;
  parameter wait_dps  =  7'h5;
  parameter unfire  =  7'h6;

// Local
  wire inc_done;
  wire increment;
  wire phase_reset = global_reset || reset;

// State Machine
  always @(posedge clock) begin
  if (phase_reset)dps_sm = idle;
  else begin
  case (dps_sm)
  
  idle:                      // Idling, waiting for fire command
   if (fire)    dps_sm = wait_tmb;

  wait_tmb:                    // Wait for TMB main clock DLL to lock
   if (lock_tmb)  dps_sm = wait_dcm;

  wait_dcm:                    // Wait for this DCM to lock
   if (lock_dcm)  begin
   if (!inc_done)  dps_sm = init_dps;        // Start incrementing or decrementing
   else      dps_sm = unfire;        // Phase already at selected value
   end

  init_dps:    dps_sm = inc_dec;        // Assert dps signals

  inc_dec:    dps_sm = wait_dps;        // Pulse dcm clock 1 cycle
  
  wait_dps:                    // Wait for dcm to report done
   if (psdone) begin
   if (!inc_done)  dps_sm = inc_dec;        // Continue to increment or decrement
   else      dps_sm = unfire;        // Done incrementing/decrementing
   end

  unfire:
   if (!fire)    dps_sm = idle;          // Wait for unfire command to go away

  default      dps_sm = idle;
  endcase
  end
  end

// State Machine status vector
  always @(posedge clock) begin
  case (dps_sm)
  idle:    dps_sm_vec <= 4'h0;
  wait_tmb:  dps_sm_vec <= 4'h1;
  wait_dcm:  dps_sm_vec <= 4'h2;
  init_dps:  dps_sm_vec <= 4'h3;
  inc_dec:  dps_sm_vec <= 4'h4;
  wait_dps:  dps_sm_vec <= 4'h5;
  unfire:    dps_sm_vec <= 4'h6;
  default    dps_sm_vec <= 4'h0;
  endcase
  end

//-----------------------------------------------------------------------------------------------------------------
//  Digital phase shifter signals, FF buffered to eliminate LUT glitches
//-----------------------------------------------------------------------------------------------------------------
  reg psen    = 0;
  reg psincdec  = 0;

  always @(posedge clock) begin
  psen   <= (dps_sm == inc_dec);  // Psclk enable
  psincdec <= increment;        // 1=increment phase, 0=decrement
  end

// Track current phase value presumed inside DCM
  parameter phase_offset=0;      // Virtex6 PLL resets to 0 phase shift
  
  reg [MXPHASE-1:0] current_phase=phase_offset;

  wire   next_phase  = (dps_sm == inc_dec);
  assign busy        = (dps_sm != idle);
  assign increment   = (phase >  current_phase);
  assign inc_done    = (phase == current_phase);

  always @(posedge clock) begin
  if (phase_reset)  current_phase <= phase_offset;
  if (next_phase) begin
  if (increment)     current_phase <= current_phase+1'b1;
  else          current_phase <= current_phase-1'b1;
  end
  end

//-----------------------------------------------------------------------------------------------------------------
// Debug
//-----------------------------------------------------------------------------------------------------------------
`ifdef DEBUG_PHASER
// State Machine ASCII display
  reg [47:0] dps_sm_dsp;

  always @* begin
  case (dps_sm)
  idle:    dps_sm_dsp <= "idle  ";
  wait_tmb:  dps_sm_dsp <= "wtmb  ";
  wait_dcm:  dps_sm_dsp <= "wdcm  ";
  init_dps:  dps_sm_dsp <= "init  ";
  inc_dec:  dps_sm_dsp <= "incdec";
  wait_dps:  dps_sm_dsp <= "wdps  ";
  unfire:    dps_sm_dsp <= "unfire";
  default    dps_sm_dsp <= "idle  ";
  endcase
  end
`endif

//-----------------------------------------------------------------------------------------------------------------
  endmodule
//-----------------------------------------------------------------------------------------------------------------
