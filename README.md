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


### Version control 

master branch code is used for Run2 operation and the compiled date is 2016-03-16. the ISE for compiling could be 14.7

Andrew took over the OTMB fw to add GEM related features and then created gem_devel branch.  Andrew's gem_devel branch added 4 GEM fibers, added GEM data read out in DAQ path and added some codes in tmb.v to use GEM hits in LCT construction (https://github.com/andrewpeck/otmb_fw_code/tree/gem_devel) 

Andrew's gem_devel should be tested at bat.904 during ~2017. 

In parallel, Yuriy, Jason and Tao were working on implementing new OTMB algo which is prepared for high lumi LHC. the branch 2018OTMBfw was created to include all changes:
   - localized dead time zone in cathode pretriggering
   - CLCT reuse in ALCT-CLCT matching


the 2018OTMBfw version code was tested bat.904, gif++, and Point 5 by Tao and CSC group


In 2019, Tao checked out Andrew' gem_devel branch and created a branched GE11_ME11_fw to include new features in 2018OTMBfw. And finally GE11_ME11_fw will also include full GEM+CSC algorithm and be commissioned for GE1/1-ME1/1 integrated local triggering. 


#### branch GE11_2018ME11_CCLUT_v1
it is a special version for TAMU test.  It included:
    - part GEMCSC match features
    - HMT 
    - part new format 
    - fake ALCT generated with valid CLCT vpf
    - update DAQ format with new headers
    - the only missing part for final GEMCSC algorithm is the GEMCSC matching in tmb.v file

### Simulation
The folder source/simulation contains a test bench, as well as a
file handler and VME emulator, for the OTMB firmware simulation.
