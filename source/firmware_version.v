//---------------------------------------------------------------------------------------------------------------------------------------
//	OTMB_VIRTEX6 Virtex-6 Global Definitions
//---------------------------------------------------------------------------------------------------------------------------------------
// Firmware version global definitions
	`define FIRMWARE_TYPE		04'hC		// C=Normal CLCT/TMB, D=Debug PCB loopback version
	`define VERSION				04'hE		// Version revision number, A=TMB2004 and earlier, E=TMB2005E production
	`define MONTHDAY			16'h0604	// Version date
	`define YEAR				16'h2013	// Version date

	`define AUTO_VME			01'h1		// Automatically initialize VME registers from PROM data,   0=do not
	`define AUTO_JTAG			01'h1		// Automatically initialize JTAG chain from PROM data,      0=do not
	`define AUTO_PHASER			01'h1		// Automatically initialize PHASER machines from PROM data, 0=do not
	`define ALCT_MUONIC			01'h1		// Floats ALCT board  in clock-space with independent time-of-flight delay
	`define CFEB_MUONIC			01'h1		// Floats CFEB boards in clock-space with independent time-of-flight delay
	`define CCB_BX0_EMULATOR	01'h0		// Turns on bx0 emulator at power up, must be 0 for all CERN versions

	`define VIRTEX6				04'h6		// FPGA type is Virtex6
	`define MEZCARD				04'hD		// Mezzanine Card: D=Virtex6
	`define ISE_VERSION			16'h1450	// ISE Compiler version
//	`define FPGAID				16'h6195	// FPGA Type 6195 XC6VLX195T
	`define FPGAID				16'h6240	// FPGA Type 6240 XC6VLX240T

// Conditional compile flags: Enable only one CSC_TYPE
//	`define CSC_TYPE_C			04'hC		// Normal   ME1B: ME1B   chambers facing toward IR.    ME1B hs =!reversed, ME1A hs = reversed
	`define CSC_TYPE_D			04'hD		// Reversed ME1B: ME1B   chambers facing away from IR. ME1B hs = reversed, ME1A hs =!reversed

// Revision log
//	02/08/2013	Initial Virtex-6 specific
//	02/13/2013	Unfolded pattern finder
//	02/14/2013	Remove Virtex-2 sections
//	02/19/2013	Expanded pattern finder for 7 dcfebs
//	02/25/2013	Mod header40_[11:0] for 7 dcfebs, add event counters for cfeb[6:5]
//	02/27/2013	Mod alct rx tx ddr
//	03/04/2013	New cfeb and alct ddr
//	03/05/2013	New VME registers for 7 dcfebs
//	03/07/2013	Restore normal scope channel assigments
//	03/08/2013	Text cleanup
//	03/18/2013	Remove copper cfebs
//	03/21/2013	New pattern_unit ROM, remove cfeb muonic timing
//	03/23/2013	Replace count1s5 in sequencer with count1sof7 ROM
//	03/25/2013	Replace count1s  in pattern_finder layer trigger
//	04/04/2013	Fix pattern finder pre-trigger lookahead array pointers
//	04/12/2013	Use SmartXplorer to optimiz map an PAR settings to help ISE 12.4 converge
//	04/22/2013	Mod power_save in GTX core and switch to ISE 14.5
//	05/08/2013	Revert to Virtex-2 muonic logic for ALCT and MPC, updated to Virtex-6 DDR prims
//	06/04/2013	Restore n-bx delay to cfeb non-muonic stage
//---------------------------------------------------------------------------------------------------------------------------------------
//	End Global Definitions
//---------------------------------------------------------------------------------------------------------------------------------------
