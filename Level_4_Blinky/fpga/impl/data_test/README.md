# impl/data_test

## Description

This directory implements the data_test project on the
[Arty S7-50T](https://reference.digilentinc.com/reference/programmable-logic/arty-s7/start) board from Digilent.
This design test the 8-bit parallel interface from the rpi.  It expects the bytes 0..255
to be sent sequentially.  It checks that the bytes are sent correctly and returns
1 for success and 0 for failure.

It is implemented using the Xilinx Vivado 2018.2 tools running
on Ubuntu 16.04 OS.

## Results 

The data_test.c in the sw directory was used to test
this firmware.

Testing show that the 8-bit interface can send data from the RPI
to the ArtyS7 at a speed of 8-16MB per second.  It varies from
run to run. 

The ArtyS7 is able to send data back to the RPI at about 4-5MB per second.

## Building the Project

You need to have the [Vivado Digilent board files](https://reference.digilentinc.com/reference/software/vivado/board-files?redirect=1)
installed.  You can get these from this [repo](https://github.com/Digilent/vivado-boards) 
on github.

Instead of storing the whole Vivado project in github
we store only a Tcl script which can generate the Vivado
project.  For more information see

[Version control for Vivado project](http://www.fpgadeveloper.com/2014/08/version-control-for-vivado-projects.html)

Here are the steps to build the project and start vivado on a
Linux system.

```
> source /opt/Xilinx/Vivado/2018.2/settings64.sh
> cd vivado_prj
> ./build.sh
> vivado project_1/project_1.xpr
```

__NOTE__ : This builds a project for the arty_s7 with the XC7S50 part.  If you have the arty_s7
with an XC7S25, you will have to update target board under Settings->General->Project device.

Once you have generated a bitstream you can open the Hardware Manager.  You should be able
to download the bitstream or write the bin file to the flash.  To write the bin file you
need to add "Add Configuration Memory Device" by right clicking on xc7s50 in the hardware window.
The spi-flash you need to add is "s25fl128sxxxxxx0-spi-x1_x2_x4".  Refer to the 
[Arty S7 Reference manual](https://reference.digilentinc.com/reference/programmable-logic/arty-s7/reference-manual) 
for more information.


