## OTMB_VIRTEX6
 
 Original author: Jonathan Kubik (UCLA)
 
 Current developers: Yuriy Pakhotin (Texas A&M), Jason Gilmore (Texas A&M)
 
======================================================================

Official firmware for the Optical Trigger MotherBoard (OTMB) for
the ME1/1 station of the CMS muon endcap detector.

This repository contains the source code and default ISE project file:

- otmb_virtex6.xise: Production, ISE 14.5

The difference between "Production" and "Pre-Production" versions is
in the file ./source/otmb_pinout.ucf, where different values for the
parameters "dmb_tx<39>" and "dmb_tx<40>" might be set:

- NET "dmb_tx<40>"	LOC = "W32"; # Production:     I/O_440
- NET "dmb_tx<39>"	LOC = "C9";  # Production:     I/O_441

- NET "dmb_tx<40>"	LOC = "C9";  # Pre-production: I/O_440
- NET "dmb_tx<39>"	LOC = "W32"; # Pre-production: I/O_441

Default version is "Production".

The difference between the ISE 14.5 and 12.4 versions is in the file
./source/cfeb/gtx_rx_buf_bypass.v, where different values for the
parameter "GTX_POWER_SAVE" might be set:

- .GTX_POWER_SAVE (10'b0000010000)  // For ISE 12.4: do not bypass the RX Delay Aligner
- .GTX_POWER_SAVE (10'b0000110000)  // For ISE 14.5: bypass the RX Delay Aligner
 
Default version is ISE 14.5 which allows to bypass the RX Delay Aligner,
thus saving some power consumption.

### version control
Starting from 2016, Yuriy, Jason, Andrew and Tao worked on improving OTMB fw performance and several key new features were added:
 - localized dead time zone in cathode pretriggering 
 - CLCT reuse in ALCT-CLCT matching
the branch of this version firmware is renamed to 2018OTMBfw on Tao's github


In addition, starting from 2016, ISE 14.7 is used for compiling 

On 2019 Feb. 14, A new branch called ME21ME31ME41fw_2019 is created on top of 2018OTMBfw:
  - Removed ME1a related thing and changed 7DCEFBs to 5 DCFEBs
  - in pattern finder, add stagger correction
  - in pattern finder, find valid pattern in whole chamber simultaneously with 40MHz
  - to sychronize 5 DCFEBs phase, the old code for ME1b is adopted:  dps3 and corresponding register setting for ME234

Now the ME21ME31ME41fw_2019 branch still used type C for normal CSC and type D for reversed CSC,  and ucf file is not changed yet. 

the ME21ME31ME41 version is expceted to be commissioned for ME21 at begining of Run3 and ME3141 since Run3. First compilation on 2019 Feb 19 without error.

Update on March 21, 2019: 
  - fixed a few bugs in code and made it finally work
  - tested all 5 fiber inputs and all are working fine
  - later move 5 input fiber positions to 1,2,3,4,5 (nominal operation setting) in otmb_virtex6_pinout_MEX1.ucf and used it as the defaul ucf in project file
  - change the condition of swapping rxn and rxp (namely gtx_rx_pol_swap) in source/cfeb/cfeb.v 
  - next: test the new ME234/1 OTMB fw with changed fiber positions

Update on March 24, 2019
  - create otmb_virtex6_pinout_MEX1.ucf file to move input fiber positions to 1,2,3,4,5




### Simulation
The folder source/simulation contains a test bench, as well as a
file handler and VME emulator, for the OTMB firmware simulation.


## Branch description
MEX1 OTMB firwmar with legacy Run2 algorithm 
