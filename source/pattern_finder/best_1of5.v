`timescale 1ns / 1ps
//-------------------------------------------------------------------------------------------------------------------
// Finds best 1 of 5 1/2-strip patterns comparing all patterns simultaneously
//
//	11/08/06	Initial
//	12/13/06 Non-busy version
//	12/20/06 Replace envelope hits with pattern ids
//	12/22/06 Sort based on 6-bit patterns instead of just number of hits
//	01/10/07 Increase pattern bits to 3 hits + 4 bends
//	02/01/07 Revert from sorting on patterns to sorting on hits
//	02/20/07 Go back to sorting on pattern numbers
//	05/08/07 Change pattern numbers 1-9 to 0-8 so lsb now implies bend direction, ignore lsb during sort
//	08/11/10 Port to ise 12
//-------------------------------------------------------------------------------------------------------------------
	module best_1of5
	(
	pat0, pat1, pat2, pat3, pat4,
	key0, key1, key2, key3, key4,
	best_pat,
	best_key
	);

// Constants
	parameter MXPIDB		=	4;				// Pattern ID bits
	parameter MXHITB		=	3;				// Hits on pattern bits
	parameter MXPATB		=	3+4;			// Pattern bits
	parameter MXKEYB		=	5;				// Number of 1/2-strip key bits on 1 CFEB
	parameter MXKEYBX		=	8;				// Number of 1/2-strip key bits on 5 CFEBs

// Ports	
	input	[MXPATB-1:0]	pat0, pat1, pat2, pat3, pat4;
	input	[MXKEYB-1:0]	key0, key1, key2, key3, key4;
	
	output	[MXPATB-1:0]	best_pat;
	output	[MXKEYBX-1:0]	best_key;
	
// Stage 3: Best 1 of 5
	reg	[MXPATB-1:0]	best_pat;
	reg	[MXKEYBX-1:0]	best_key;

	always @* begin
	if 	   ((pat4[6:1] > pat3[6:1]) &&
			(pat4[6:1] > pat2[6:1]) &&
			(pat4[6:1] > pat1[6:1]) &&
			(pat4[6:1] > pat0[6:1]))
			begin
			best_pat	= pat4;
			best_key	= {3'd4,key4};
			end

	else if((pat3[6:1] > pat2[6:1]) &&
			(pat3[6:1] > pat1[6:1]) &&
			(pat3[6:1] > pat0[6:1]))
			begin
			best_pat	= pat3;
			best_key	= {3'd3,key3};
			end

	else if((pat2[6:1] > pat1[6:1]) &&
			(pat2[6:1] > pat0[6:1]))
			begin
			best_pat	= pat2;
			best_key	= {3'd2,key2};
			end

	else if(pat1[6:1] > pat0[6:1])
			begin
			best_pat	= pat1;
			best_key	= {3'd1,key1};
			end

	else
			begin
			best_pat	= pat0;
			best_key	= {3'd0,key0};
			end
	end

	endmodule
