//CCLUT, Tao
parameter [17:0] pat_maskA = 18'h3f5ff; // 11 1111 0101 1111 1111
parameter [17:0] pat_mask9 = 18'h3f5ff;
parameter [17:0] pat_mask8 = 18'h3f5ff;
parameter [17:0] pat_mask7 = 18'h3f5ff;
parameter [17:0] pat_mask6 = 18'h3f5ff;
 // Pattern A                                                    0123456789A
 //  parameter [17:0] pat_maskA = {1'b1 , 1'b1, 1'b1        // ly0 ----xxx----
 //                               ,1'b1 , 1'b1, 1'b1        // ly1 ----xxx----
 //                               ,1'b0 , 1'b1, 1'b0        // ly2 -----k-----
 //                               ,1'b1 , 1'b1, 1'b1        // ly3 ----xxx----
 //                               ,1'b1 , 1'b1, 1'b1        // ly4 ----xxx----
 //                               ,1'b1 , 1'b1, 1'b1};      // ly5 ----xxx----


 //// Pattern 9                                                              0123456789A
 //  parameter [17:0] pat_mask9 = {1'b1,  1'b1,  1'b1                 // ly0 --xxx-------
 //                               ,1'b1,  1'b1,  1'b1                 // ly1 ---xxx------
 //                               ,       1'b0,  1'b1,  1'b0          // ly2 -----k------
 //                               ,       1'b1,  1'b1,  1'b1          // ly3 -----xxx----
 //                               ,              1'b1,  1'b1,  1'b1   // ly4 ------xxx---
 //                               ,              1'b1,  1'b1,  1'b1}; // ly5 -------xxx--

 //// Pattern 8                                                         //     0123456789A
 //  parameter [17:0] pat_mask8 = {              1'b1,  1'b1,  1'b1     // ly0 ------xxx--
 //                               ,              1'b1,  1'b1,  1'b0     // ly1 -----xxx---
 //                               ,       1'b0,  1'b1,  1'b0            // ly2 -----k-----
 //                               ,       1'b1,  1'b1,  1'b1            // ly3 ---xxx-----
 //                               ,1'b1,  1'b1,  1'b1                   // ly4 --xxx------
 //                               ,1'b1,  1'b1,  1'b1};                 // ly5 -xxx-------

 //// Pattern 7                                                                            0123456789A
 //  parameter [17:0] pat_mask7 = {1'b1,  1'b1,  1'b1                               // ly0 xxx-----------
 //                               ,       1'b1,  1'b1,  1'b1                        // ly1 --xxx---------
 //                               ,              1'b0,  1'b1,  1'b0                 // ly2 -----k--------
 //                               ,              1'b1,  1'b1,  1'b1                 // ly3 ------xxx-----
 //                               ,                     1'b1,  1'b1,  1'b1          // ly4 --------xxx---
 //                               ,                            1'b1,  1'b1,  1'b1}; // ly5 ---------xxx--

 //// Pattern 6                                                                          0123456789A
 //  parameter [17:0] pat_mask6 = {                            1'b1,  1'b1,  1'b1 // ly0 ----------xxx--
 //                               ,                     1'b1,  1'b1,  1'b1        // ly1 --------xxx---
 //                               ,              1'b0,  1'b1,  1'b0               // ly2 -------k-----
 //                               ,              1'b1,  1'b1,  1'b1               // ly3 ----xxx-----
 //                               ,       1'b1,  1'b1,  1'b1                      // ly4 --xxx------
 //                               ,1'b1,  1'b1,  1'b1};                           // ly5 -xxx------



//parameter [17:0] pat_maskA = 18'h3ffff;
//parameter [17:0] pat_mask9 = 18'h3ffff;
//parameter [17:0] pat_mask8 = 18'h3ffff;
//parameter [17:0] pat_mask7 = 18'h3ffff;
//parameter [17:0] pat_mask6 = 18'h3ffff;

// // Pattern A                                                    0123456789A
//   parameter [17:0] pat_maskA = {1'b1 , 1'b1, 1'b1        // ly0 ----xxx----
//                                ,1'b0 , 1'b1, 1'b0        // ly1 -----x-----
//                                ,1'b0 , 1'b1, 1'b0        // ly2 -----k-----
//                                ,1'b0 , 1'b1, 1'b0        // ly3 -----x-----
//                                ,1'b1 , 1'b1, 1'b1        // ly4 ----xxx----
//                                ,1'b1 , 1'b1, 1'b1};      // ly5 ----xxx----
//
//
// // Pattern 9                                                              0123456789A
//   parameter [17:0] pat_mask9 = {1'b1,  1'b1,  1'b1                 // ly0 ---xxx-----
//                                ,1'b0,  1'b1,  1'b1                 // ly1 ----xx-----
//                                ,       1'b0,  1'b1,  1'b0          // ly2 -----k-----
//                                ,       1'b0,  1'b1,  1'b1          // ly3 -----xx----
//                                ,              1'b1,  1'b1,  1'b1   // ly4 -----xxx---
//                                ,              1'b1,  1'b1,  1'b1}; // ly5 -----xxx---
//
// // Pattern 8                                                         //     0123456789A
//   parameter [17:0] pat_mask8 = {              1'b1,  1'b1,  1'b1     // ly0 -----xxx---
//                                ,              1'b1,  1'b1,  1'b0     // ly1 -----xx----
//                                ,       1'b0,  1'b1,  1'b0            // ly2 -----x-----
//                                ,       1'b1,  1'b1,  1'b0            // ly3 ----xx-----
//                                ,1'b1,  1'b1,  1'b1                   // ly4 ---xxx-----
//                                ,1'b1,  1'b1,  1'b1};                 // ly5 ---xxx-----
//
// // Pattern 7                                                                            0123456789A
//   parameter [17:0] pat_mask7 = {1'b1,  1'b1,  1'b1                               // ly0 --xxx------
//                                ,       1'b0,  1'b1,  1'b1                        // ly1 ----xx-----
//                                ,              1'b0,  1'b1,  1'b0                 // ly2 -----k-----
//                                ,              1'b0,  1'b1,  1'b1                 // ly3 -----xx----
//                                ,                     1'b0,  1'b1,  1'b1          // ly4 ------xx---
//                                ,                            1'b1,  1'b1,  1'b1}; // ly5 ------xxx--
//
// // Pattern 6                                                                          0123456789A
//   parameter [17:0] pat_mask6 = {                            1'b1,  1'b1,  1'b1 // ly0 ------xxx--
//                                ,                     1'b1,  1'b1,  1'b0        // ly1 -----xx----
//                                ,              1'b0,  1'b1,  1'b0               // ly2 -----k-----
//                                ,              1'b1,  1'b1,  1'b0               // ly3 ----xx-----
//                                ,       1'b1,  1'b1,  1'b0                      // ly4 ---xx------
//                                ,1'b1,  1'b1,  1'b1};                           // ly5 --xxx------
//
// // Pattern 5                                                                                   0123456789A
//   parameter [17:0] pat_mask5 = {1'b1,  1'b1,  1'b1                                             // ly0 -xxx-------
//                                ,       1'b0,  1'b1,  1'b1                                      // ly1 ---xx------
//                                ,                     1'b0,  1'b1,  1'b0                        // ly2 -----k-----
//                                ,                            1'b0,  1'b1,  1'b1                 // ly3 ------xx---
//                                ,                                          1'b1,  1'b1,  1'b1   // ly4 -------xxx-
//                                ,                                          1'b1,  1'b1,  1'b1}; // ly5 -------xxx-
//
// // Pattern 4                                                                                   0123456789A
//   parameter [17:0] pat_mask4 = {                                          1'b1,  1'b1,  1'b1 // ly0 -------xxx-
//                                ,                                   1'b1,  1'b1,  1'b0        // ly1 ------xx---
//                                ,                     1'b0,  1'b1,  1'b0                      // ly2 -----k-----
//                                ,              1'b1,  1'b1,  1'b0                             // ly3 ---xx------
//                                ,1'b1,  1'b1,  1'b1                                           // ly4 -xxx-------
//                                ,1'b1,  1'b1,  1'b1};                                         // ly5 -xxx-------
//
// // Pattern 3                                                                                                 0123456789A
//   parameter [17:0] pat_mask3 = {1'b1,  1'b1,  1'b1                                                    // ly0 xxx--------
//                                ,              1'b0,  1'b1,  1'b1                                      // ly1 ---xx------
//                                ,                     1'b0,  1'b1,  1'b0                               // ly2 -----k-----
//                                ,                            1'b1,  1'b1,  1'b1                        // ly3 -----xxx---
//                                ,                                          1'b1,  1'b1,  1'b1          // ly4 -------xxx-
//                                ,                                                 1'b1,  1'b1,  1'b1}; // ly5 --------xxx
//
// // Pattern 2                                                                                               0123456789A
//   parameter [17:0] pat_mask2 = {                                                 1'b1,  1'b1,  1'b1 // ly0 --------xxx
//                                ,                                   1'b1,  1'b1,  1'b0               // ly1 ------xx---
//                                ,                     1'b0,  1'b1,  1'b0                             // ly2 -----k-----
//                                ,              1'b1,  1'b1,  1'b1                                    // ly3 ---xxx-----
//                                ,       1'b1,  1'b1,  1'b1                                           // ly4 -xxx-------
//                                ,1'b1,  1'b1,  1'b1};                                                // ly5 xxx--------
//
//
// proposed 10

// ly0 ----xxx----
// ly1 ----xxx----
// ly2 ----xxx----
// ly3 ----xxx----
// ly4 ----xxx----
// ly5 ----xxx----

// proposed 8/9

// ly0 -----xxx---
// ly1 -----xxx---
// ly2 ----xxx----
// ly3 ----xxx----
// ly4 ---xxx-----
// ly5 ---xxx-----

// proposed 6/7

// ly0 ------xxx--
// ly1 ------xxx--
// ly2 -----xxx---
// ly3 ---xxx-----
// ly4 --xxx------
// ly5 --xxx------

// proposed 4/5
// ly0 -------xxx-
// ly1 ------xxx--
// ly2 -----xxx---
// ly3 ---xxx-----
// ly4 --xxx------
// ly5 -xxx-------

// proposed 2/3
// ly0 --------xxx
// ly1 -------xxx-
// ly2 -----xxx---
// ly3 --xxx------
// ly4 -xxx-------
// ly5 xxx--------
