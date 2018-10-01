# Star Crunch Cereal
_Made with real FPGA clusters!_

## Description
Star Crunch Cereal is a clusterfighter based on multiple MKR VIDOR 4000 boards from Arduino. The VIDOR boards are a delicious combination of the following:

* SAMD21 32-bit ARM Cortex M0+ microcontroller 
* Cyclone 10 FPGA
* 8 MB SRAM
* 2 MB QSPI Flash
* U-BLOX NINA W10
* Micro HDMI connector
* MIPI camera connector
* Mini PCI Express connector.

## Architecture
### Hardware
The MKR VIDOR is itself a mini-cluster capable of competing in the Super Micro price class, but the whole purpose of clustering is to scale arbitrarily (within the limits of the class). Star Crunch will consist of one or more MKR VIDOR 4000 boards sitting on a backplane and connected together using the exposed PCIe edge connector on the bottom of the board.

### Software / Firmware
It seems like the intention of the MKR VIDOR 4000 is to have the SAMD21 as a sort of "master" device and use the FPGA for acceleration of tasks. In the case of the MD5 Challenge, the SAMD21 will be responsible for chunking up the data and then streaming it to the FPGA for calculation of the MD5 sums. We'd like to make this "accelerator" concept as generic as possible such that the system can be (a) adapted easily to different tasks and (b) allow for an arbitrary number of new boards to be added (including custom boards).
