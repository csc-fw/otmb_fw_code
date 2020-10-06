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
