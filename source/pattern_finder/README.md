* Convention for 12-bits comparator code

|  field   | layer |
|----------|-------|
|  [1:0]   |   1   |
|  [3:2]   |   2   |
|  [5:4]   |   3   |
|  [7:6]   |   4   |
|  [9:8]   |   5   |
|  [11:10] |   6   |

* Convention of LUT output:  18bits

|  field   |  name           |
|----------|-----------------|
| [8:0]    | quality (all 0) |
| [12:9]   | abs slope       |
| [13]     | slope sign      |
| [17:14]  | position offset |


* Convention for 4-bit position offset word:

| Value | Half-Strip Offset  | Delta Half-Strip  | Quarter-Strip Bit  | Eighth-Strip Bit |
|-------|--------------------|-------------------|--------------------|------------------|
|   0   |   -7/4             |   -2              |   0                |   1              |
|   1   |   -3/2             |   -2              |   1                |   0              |
|   2   |   -5/4             |   -2              |   1                |   1              |
|   3   |   -1               |   -1              |   0                |   0              |
|   4   |   -3/4             |   -1              |   0                |   1              |
|   5   |   -1/2             |   -1              |   1                |   0              |
|   6   |   -1/4             |   -1              |   1                |   1              |
|   7   |   0                |   0               |   0                |   0              |
|   8   |   1/4              |   0               |   0                |   1              |
|   9   |   1/2              |   0               |   1                |   0              |
|   10  |   3/4              |   0               |   1                |   1              |
|   11  |   1                |   1               |   0                |   0              |
|   12  |   5/4              |   1               |   0                |   1              |
|   13  |   3/2              |   1               |   1                |   0              |
|   14  |   7/4              |   1               |   1                |   1              |
|   15  |   2                |   2               |   0                |   0              |

* Convention of LUT for FW and patterns 

pattern A, also it is pattern 4 in CMSSW   
  | ly  | 0123456789A | 
  | ly0 | ----xxx---- | 
  | ly1 | ----xxx---- | 
  | ly2 | ----xkx---- | 
  | ly3 | ----xxx---- | 
  | ly4 | ----xxx---- | 
  | ly5 | ----xxx---- | 

pattern 9, also it is pattern 3 in CMSSW   
  | ly  | 0123456789A | 
  | ly0 | --xxx------ | 
  | ly1 | ---xxx----- | 
  | ly2 | ----xkx---- | 
  | ly3 | ----xxx---- | 
  | ly4 | -----xxx--- | 
  | ly5 | ------xxx-- | 

pattern 8 , also it is pattern 2 in CMSSW   
       0123456789A
   ly0 ------xxx--
   ly1 -----xxx---
   ly2 ----xkx----
   ly3 ----xxx----
   ly4 ---xxx-----
   ly5 --xxx------

pattern 7, , also it is pattern 1 in CMSSW   
       0123456789ABC
   ly0 xxx--------
   ly1 -xxx-------
   ly2 ---xxk-----
   ly3 -----xxx---
   ly4 -------xxx-
   ly5 --------xxx

pattern 6, also it is pattern 0 in CMSSW
       0123456789ABC
   ly0 --------xxx--
   ly1 -------xxx---
   ly2 -----kxx-----
   ly3 ---xxx-------
   ly4 -xxx---------
   ly5 xxx----------


rom_patA.mem is the LUT for the straight pattern A and the index is the comparator code and value in mem file is the 18bits output, similar for other patterns

