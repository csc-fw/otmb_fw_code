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

parameter MXPATC  = 11;                // Pattern Carry Bits

parameter MXPIDB  = 4;                 // Pattern ID bits
parameter MXHITB  = 3;                 // Hits on pattern bits
parameter MXPATB  = MXHITB + MXPIDB;   // Pattern bits

parameter MXPID   = 4;                // Number of patterns
parameter MIPID   = 0;                  
parameter MXPAT   = 5;                 // Number of patterns


//parameter MXSUBKEYBX = 10;            // Number of EightStrip key bits on 7 CFEBs, was 8 bits with traditional pattern finding
parameter MXOFFSB = 4;                 // Quarter-strip bits
parameter MXQLTB  = 9;                 // Fit quality bits
parameter MXBNDB  = 5;                 // Bend bits

parameter PATLUT = 1;         // 1=use pattern_lut; 0=use traditional pattern finding
parameter SORT_ON_PATLUT = 0; // 1=best1of7 sorting on pattern_lut; 0=use traditional pattern sorting

parameter A=10;
parameter B=11;
parameter C=12;
parameter D=13;
parameter E=14;
parameter F=15;

parameter PRETRIG_SOURCE = 0;          // 0=pretrig, 1=post-fit

