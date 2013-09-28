`timescale 1ns / 1ps
//-------------------------------------------------------------------------------------------------------------------
//
// Virtex6: Instantiate 1 DCFEB optical receiver with muonic sync stages
//
//-------------------------------------------------------------------------------------------------------------------
//	09/10/2012	Initial port from x_demux_ddr_cfeb_muonic
//	09/11/2012	Put iob clock back in for muonic timing
//	09/12/2012	Conform sub module names
//	10/08/2012	Remove muonic timing
//	02/21/2013	Put it back
//	03/07/2013	Remove scope channels
//	06/04/2013	Restore n-bx delay, remove muonic logic, variable rx phase is irrelevant for gtx
//-------------------------------------------------------------------------------------------------------------------
module gtx_optical_rx
  (
   // Clocks
   clock,
   clock_iob,
   clock_160,

   // Muonic
   clear_sync,
   posneg,
   delay_is,

   // SNAP12 optical receiver
   qpll_lock,
   rxn,
   rxp,
   gtx_rx_pol_swap,

   // Optical receiver status
   gtx_rx_reset,
   gtx_rx_reset_err_cnt,
   gtx_rx_en_prbs_test,
   gtx_rx_start,
   gtx_rx_fc,
   gtx_rx_valid,
   gtx_rx_match,
   gtx_rx_sync_done,
   gtx_rx_err,
   gtx_rx_err_count,
   gtx_rx_data,

   // Sump
   gtx_rx_sump
   );

   //-------------------------------------------------------------------------------------------------------------------
   // Ports
   //-------------------------------------------------------------------------------------------------------------------
   // Clocks
   input			clock;					//  40 MHz fabric clock
   input			clock_iob;				//  40 MHZ iob clock
   input			clock_160;				// 160 MHz from QPLL for GTX reference clock

   // Muonic
   input			clear_sync;				// Clear sync stages
   input			posneg;					// Select inter-stage clock 0 or 180 degrees
   input [3:0] 			delay_is;				// Interstage delay

   // SNAP12 optical receiver
   input			qpll_lock;				// QPLL locked 
   input			rxp;					// SNAP12+ fiber input for GTX
   input			rxn;					// SNAP12- fiber input for GTX
   input			gtx_rx_pol_swap;		// Inputs 5,6 [ie dcfeb 4,5] have swapped rx board routes

   // Optical receiver status
   input			gtx_rx_reset;			// Reset GTX
   input			gtx_rx_reset_err_cnt;	// Resets the PRBS test error counters
   input			gtx_rx_en_prbs_test;	// Select random input test data mode

   output			gtx_rx_start;			// Set when the DCFEB Start Pattern is present
   output			gtx_rx_fc;				// Flags when Rx sees "FC" code (sent by Tx) for latency measurement
   output			gtx_rx_valid;			// Valid data detected on link
   output			gtx_rx_match;			// PRBS test data match detected, for PRBS tests, a VALID = "should have a match" such that !MATCH is an error
   output			gtx_rx_sync_done;		// Use these to determine gtx_ready
   output			gtx_rx_err;				// PRBS test detects an error
   output [15:0] 		gtx_rx_err_count;		// Error count on this fiber channel
   output [47:0] 		gtx_rx_data;			// DCFEB comparator data

   // Sump
   output			gtx_rx_sump;			// Unused signals

   //-------------------------------------------------------------------------------------------------------------------
   // Instantiate TAMU SNAP12 optical receiver logic
   //-------------------------------------------------------------------------------------------------------------------
   // GTX resets
   wire 			rx_sync_done;

   wire 			gtx_ready = qpll_lock && rx_sync_done;
   wire 			rst       = gtx_rx_reset || !gtx_ready;

   // Received clock time domain
   wire [3:0] 			cew;
   wire [3:1] 			nonzero_word;
   wire [47:0] 			comp_dat;

   // GTX instance
   gtx_comp_fiber_in ugtx_comp_fiber_in
     (
      .RST		(rst),			// In	GTX reset
      .CMP_RX_N		(rxn),			// In	SNAP12- fiber input for GTX
      .CMP_RX_P		(rxp),			// In	SNAP12+ fiber input for GTX
      .CMP_RX_REFCLK	(clock_160),		// In	QPLL 160 via GTX Clock
      .RX_POLARITY_SWAP	(gtx_rx_pol_swap),	// In	Inputs 5 & 6 have swapped rx board routes
      .CMP_RX_CLK160	(rx_clk160),		// Out	Rx recovered clock out.  Use for internal Logic Fabric clock. Needed to sync all 7 CFEBs with Fabric clock
      .STRT_MTCH	(rx_start),		// Out	Gets set when the Start Pattern is present, N/A for me.  To TP for debug only.  --sw8,7
      .VALID		(rx_valid),		// Out	Send this output to TP (only valid after StartMtch has come by)
      .MATCH		(rx_match),		// Out	Send this output to TP  AND use for counting errors. VALID="should match" when true, !MATCH is an error
      .RCV_DATA		(comp_dat[47:0]),	// Out	48 bit comp. data output
      .NONZERO_WORD	(nonzero_word[3:1]),	// Out
      .CEW0		(cew[0]),		// Out	Access four phases of 40 MHz cycle, frame separated output from GTX
      .CEW1		(cew[1]),		// Out
      .CEW2		(cew[2]),		// Out
      .CEW3		(cew[3]),		// Out	On CEW3_r (== CEW3 + 1) the RCV_DATA is valid, use to clock into pipeline
      .LTNCY_TRIG	(rx_fc),		// Out	Flags when RX sees "FC" for latency measurement.  Send raw to TP or LED
      .RX_SYNC_DONE	(rx_sync_done),		// Out	Inverse of this goes into GTX Reset
      .sump		(sump_comp_fiber)	// Out	Unused signals
      );

   //-------------------------------------------------------------------------------------------------------------------
   // 160 MHz snap rx USR clock time domain
   //-------------------------------------------------------------------------------------------------------------------
   // Signals to bring into fabric clock domain
   reg [15:0] 			err_count = 0;
   reg 				err       = 0;

   // Signals in received clock domain
   reg [47:0] 			comp_dat_r		= 0;
   reg 				rst_errcount_r	= 0;

   assign snap_wait = !(rx_sync_done & qpll_lock);	// Allow pattern checks when RX is ready

   always @(posedge rx_clk160 or posedge gtx_rx_reset or posedge snap_wait)
     begin

	// Reset case
	if (gtx_rx_reset | snap_wait) begin
	   comp_dat_r		<= 0;
	   rst_errcount_r	<= 1;
	end

	// Not Reset case
	else begin						
	   rst_errcount_r <= gtx_rx_reset_err_cnt;

	   if (cew[0]) begin					// Store comparator data using received fiber clock
	      comp_dat_r   <= comp_dat;
	   end

	   if (rst_errcount_r) begin			// Error counter reset
	      err_count	<= 0;
	      err			<= 0;
	   end

	   else if (gtx_rx_en_prbs_test & cew[0] & !snap_wait & gtx_ready) begin  // Wait 3000 clocks after Reset
	      if (!rx_match & rx_valid ) begin
		 err			<= 1'b1;				// Take this to testLEDs for monitoring on scope
		 err_count	<= err_count + 1'b1;	// This goes to Results Reg for software monitoring
	      end
	      else
		err 		<= 0;
	   end

	end		// close not reset case
     end		// close always

   //-------------------------------------------------------------------------------------------------------------------
   // Fabric clock time domain transition WITHOUT muonic timing
   //-------------------------------------------------------------------------------------------------------------------
   reg	[47:0]	gtx_rx_data_raw		= 0;
   reg 		gtx_rx_start		= 0;
   reg 		gtx_rx_fc			= 0;
   reg 		gtx_rx_valid		= 0;
   reg 		gtx_rx_match		= 0;
   reg 		gtx_rx_sync_done	= 0;
   reg 		gtx_rx_err			= 0;
   reg [15:0] 	gtx_rx_err_count	= 0;
   
   always @(posedge clock) begin
      if (clear_sync) begin
	 gtx_rx_data_raw[47:0]	<= 0;
	 gtx_rx_start			<= 0;
	 gtx_rx_fc				<= 0;
	 gtx_rx_valid			<= 0;
	 gtx_rx_match			<= 0;
	 gtx_rx_sync_done		<= 0;
	 gtx_rx_err				<= 0;
	 gtx_rx_err_count		<= 0;
      end
      else begin
	 gtx_rx_data_raw[47:0]	<= comp_dat_r[47:0];
	 gtx_rx_start			<= rx_start;
	 gtx_rx_fc				<= rx_fc;
	 gtx_rx_valid			<= rx_valid;
	 gtx_rx_match			<= rx_match;
	 gtx_rx_sync_done		<= rx_sync_done;
	 gtx_rx_err				<= err;
	 gtx_rx_err_count[15:0]	<= err_count[15:0];
      end
   end

   // Delay data n-bx to compensate for osu cable length error
   wire [47:0] gtx_rx_data_srl;
   reg [3:0]   dly=0;
   reg         dly_is_0=0;
   
   always @(posedge clock) begin
      dly      <=  delay_is-4'd1;		// Pointer to clct SRL data accounts for SLR 1bx latency
      dly_is_0 <= (delay_is == 0);	// Use direct input if delay is 0 beco 1st SRL output has 1bx overhead
   end

   srl16e_bbl #(48) udcfebdly (.clock(clock),.ce(1'b1),.adr(dly),.d(gtx_rx_data_raw[47:0]),.q(gtx_rx_data_srl[47:0]));

   assign gtx_rx_data[47:0] = (dly_is_0) ? gtx_rx_data_raw[47:0] : gtx_rx_data_srl[47:0];

   // Unused muonic signals
   reg muonic_sump=0;
   
   always @(posedge clock_iob) begin
      muonic_sump <= posneg;
   end

   //-------------------------------------------------------------------------------------------------------------------
   // Sump unused signals
   //-------------------------------------------------------------------------------------------------------------------
   assign gtx_rx_sump =
		       sump_comp_fiber	&
		       (|nonzero_word[3:1]) |
		       (|cew[3:1])          |
		       muonic_sump
		       ;

   //------------------------------------------------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------------------------------------------
