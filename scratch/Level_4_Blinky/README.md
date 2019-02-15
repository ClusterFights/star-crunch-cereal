# Level 4 : Blinky
![level3_Blinky](../images/level4_Blinky.png)

## Description

Level 4 Munchman Blinky, is using the same hardware has Level 3 MiniWheat.
It is in the (<$250) weight class.  This cluster has two
computing components a [Raspberry Pi 3 Model B V1.2](https://www.raspberrypi.org/products/raspberry-pi-3-model-b/)
($35) and the Digilent [Arty S7-50T: Spartan-7 FPGA
Board](https://reference.digilentinc.com/reference/programmable-logic/arty-s7/start) ($119).

The main goal of Level 4 is to update the Verilog md5 core to support variable length
strings. Another goal is to increase the communication speed between the raspberry pi
and the ArtyS7 fpga board.  I have a few ideas on how to do this, including upgrading
from an 8-bit bus to a 16-bit bus.

## Parallel Interface Update

This interface is an 8-bit parallel, synchronous, master interface.
The RPI is the master and controls the clock.  Data must be valid on the
rising edge of the clock.  In this update we add two more wires, a
**done** signal and a **match** signal.  These signals are outputs from
the FPGA and inputs to the RPI.  This way we do not have to change
the direction of the data bus to get an acknowledge.

The following table shows the connections between the RPI and the ArtyS7 board.

| Signal Name   | RPI GPIO  | ArtyS7     |
| ------------- |:---------:| ----------:|
| data0         | 21        | JC(1) U15  |
| data1         | 20        | JC(2) V16  |
| data2         | 16        | JC(3) U17  |
| data3         | 12        | JC(4) U18  |
| data4         | 25        | JC(7) U16  |
| data5         | 24        | JC(8) P13  |
| data6         | 23        | JC(9) R13  |
| data7         | 18        | JC(10) V14 |
| r/w           | 26        | JD(1) V15  |
| clk           | 19        | JD(2) U12  |
| done          | 13        | JD(7) T13  |
| match         | 6         | JD(8) R11  |


## TODO

* **[DONE]** Add support for variable length strings to md5core.

Supports hashing variables length strings from 2 to 55 characters.

* **[DONE]** Add a dedicated Done and Match signals to the 8-bit bus.

This change really improved the throughput on the bus. It
used to run at about 5MB/sec now it is about 20MB/sec!

* **[DONE]** Add quite mode to disable printing book titles.

Saves about a second over the whole dataset

* Disregard sending strings that contain newlines.
* Add **close** command to disconnect from parallel bus
* Expand parallel bus to 16-bits.
* Switch to shielded cable between RPI and FPGA.
* Experiment with the -Os optimization flag.
* Switch from RPI 3 Model B to RPI Model B+

