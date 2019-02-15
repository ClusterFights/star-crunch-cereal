# impl/top_md5

## Description

This directory holds the top level design for the Level 4 Blinky
FPGA implementation.

## Status

Completed the following:
* Added support for variable length strings
* Added support for bus_done and bus_match signals


## Block Diagram

Here is a block diagram of the FPGA architecture.

![FPGA_Architecture](images/MiniWheat_FPGA_Architecture.png)

## Commands

The cmd_parser module receives 1 byte commands from the
usb to serial interface.  Parameters (multi-byte values) are sent MSB first 
(big endian/network order).
Here is a summary of the commands:

* 0x01 target_hash[127:0] : Set the target hash.  Bytes are sent MSB first. **Asserts Done when complete.**
* 0x02 num[15:0] [byte0, byte1 .. byte[num-1]] : Process 'num' characters/bytes. **Asserts Done when complete.
Asserts match if match found.**
  hash found else (0x00).
* 0x03 : Returns byte_pos[15:0] that matched hash followed by the matched string. So STR_LEN+2 bytes in total.
  **Asserts done when complete.**
* 0x04 : Test command.  Returns ten bytes 10, 9, 8, 7, ... 1. **Asserts done when complete.**
* 0x05 : Set STR_LEN command.  Send 2 bytes.  Set the string length in bits.
**Asserts done when complete.**


## Implementation Report Summary


![Report Summary](images/report_summary.png)

