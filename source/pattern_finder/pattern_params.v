parameter MXCFEB     = 5;             // Number of CFEBs on CSC
parameter MXLY       = 6;             // Number of layers in CSC
parameter MXDS       = 8;             // Number of DiStrips per layer on 1 CFEB
parameter MXDSX      = MXCFEB * MXDS; // Number of DiStrips per layer on 7 CFEBs
parameter MXHS       = 32;            // Number of HalfStrips per layer on 1 CFEB
parameter MXHSX      = MXCFEB * MXHS; // Number of HalfStrips per layer on 7 CFEBs
parameter MXKEY      = MXHS;          // Number of key HalfSrips on 1 CFEB
parameter MXKEYB     = 5;             // Number of HalfSrip key bits on 1 CFEB
parameter MXKEYX     = MXCFEB * MXHS; // Number of key HalfSrips on 7 CFEBs
parameter MXKEYBX    = 8;             // Number of HalfSrip key bits on 7 CFEBs
parameter MXXKYB     = 10;            // Number of EightStrip key bits on 7 CFEBs

parameter MXPIDB  = 4;                 // Pattern ID bits
parameter MXHITB  = 3;                 // Hits on pattern bits
parameter MXPATB  = MXHITB + MXPIDB;   // Pattern bits

parameter MXPATC  = 12;                // Pattern Carry Bits

//parameter MXSUBKEYBX = 10;            // Number of EightStrip key bits on 7 CFEBs, was 8 bits with traditional pattern finding
parameter MXOFFSB = 4;                 // Quarter-strip bits
parameter MXQLTB  = 9;                 // Fit quality bits
parameter MXBNDB  = 4;                 // Bend bits

parameter MXPID   = 11;                // Number of patterns
parameter MXPAT   = 5;                 // Number of patterns

parameter PATLUT = 1;         // 1=use pattern_lut; 0=use traditional pattern finding
parameter SORT_ON_PATLUT = 0; // 1=best1of7 sorting on pattern_lut; 0=use traditional pattern sorting

parameter A=10;
parameter B=11;
parameter C=12;
parameter D=13;
parameter E=14;
parameter F=15;

parameter PRETRIG_SOURCE = 0;          // 0=pretrig, 1=post-fit

parameter [MXPID-1:2] pat_en = { 1'b1, // A
                                 1'b1, // 9
                                 1'b1, // 8
                                 1'b1, // 7
                                 1'b1, // 6
                                 1'b0, // 5
                                 1'b0, // 4
                                 1'b0, // 3
                                 1'b0  // 2
                               };
