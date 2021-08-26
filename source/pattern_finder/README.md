
### CCLUT v1: 12bits comparator code and 18bits output from LUT
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

### CCLUT v2: 11bits comparator code and 9bits output from LUT
* Convention for 12-bits comparator code
|  field   | layer |
|----------|-------|
|  [1:0]   |   1   |
|  [3:2]   |   2   |
|  [4:4]   |   3   |
|  [6:5]   |   4   |
|  [8:7]   |   5   |
|  [10:9]  |   6   |

* Convention of LUT output:  9bits

|  field   |  name           |
|----------|-----------------|
| [3:0]    | abs slope       |
| [4]      | slope sign      |
| [8:5]    | position offset |

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

pattern 4   
| ly  | 0123456789A | 
|-----|-------------|
| ly0 | ----xxx---- | 
| ly1 | ----xxx---- | 
| ly2 | -----k----- | 
| ly3 | ----xxx---- | 
| ly4 | ----xxx---- | 
| ly5 | ----xxx---- | 

pattern 3   
| ly  | 0123456789A | 
|-----|-------------|
| ly0 | --xxx------ | 
| ly1 | ---xxx----- | 
| ly2 | -----k----- | 
| ly3 | ----xxx---- | 
| ly4 | -----xxx--- | 
| ly5 | ------xxx-- | 

pattern 2    
|     | 0123456789A |
|-----|-------------|
| ly0 | ------xxx-- |
| ly1 | -----xxx--- |
| ly2 | -----k----- |
| ly3 | ----xxx---- |
| ly4 | ---xxx----- |
| ly5 | --xxx------ |

pattern 1   
|     | 0123456789A | 
|-----|-------------|
| ly0 | xxx-------- | 
| ly1 | -xxx------- | 
| ly2 | -----k----- | 
| ly3 | -----xxx--- | 
| ly4 | -------xxx- | 
| ly5 | --------xxx | 

pattern 0
|     | 0123456789ABC | 
|-----|---------------|
| ly0 | --------xxx-- |
| ly1 | -------xxx--- |
| ly2 | -----k------- |
| ly3 | ---xxx------- |
| ly4 | -xxx--------- |
| ly5 | xxx---------- |



The most LUT files(rom_pat[4-0].mem etc) are taken from https://github.com/cms-data/L1Trigger-CSCTriggerPrimitives
