 OTMB_VIRTEX6
 
 Original author: Jonathan Kubik (UCLA)
 Current developers: Yuriy Pakhotin (Texas A&M), Jason Gilmore (Texas A&M)
 
======================================================================

Official firmware for the Optical Trigger MotherBoard (OTMB) for
the ME1/1 station of the CMS muon endcap detector.

This repository contains the source code and 4 ISE project files:
- otmb_virtex6.xise: Production, ISE 14.5
- otmb_preprod_145/otmb_prod_145.xise: Pre-production, ISE 14.5
- otmb_prod_124/otmb_prod_124.xise: Production, ISE 12.4
- otmb_preprod_124/otmb_prod_124.xise: Pre-production, ISE 12.4

The difference between production and pre-production firmware is
the .UCF file included in the project. 
- For pre-production: dmb_tx40 -> pin C9,  dmb_tx39 -> pin W32
- For production:     dmb_tx40 -> pin W32, dmb_tx39 -> pin C9

The difference between the ISE 14.5 and 12.4 projects is in the file
gtx_rx_buf_bypass.v, where they have different values for the
parameter GTX_POWER_SAVE. 
ISE 14.5 allows to bypass the RX Delay Aligner, thus saving some
power consumption.

### Simulation
The file otmb_virtex6.mpf is a ModelSim project file.
The folder source/simulation contains a test bench, as well as a
file handler and VME emulator, for the OTMB firmware simulation.
