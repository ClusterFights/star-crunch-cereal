# sim/top_tb

## Status

__GOOD__ : The 'make run' target works.  The 'make view'
waveform is out of date but you can add the signals
you want to see.

## Description

This directory basically simulates the whole top_md5
design.  The testbench contains task which implement
the cmd_set_hash, cmd_send_text, and cmd_read_match.
It also has a task, send_file, which breaks the text
file alice30.txt into chunks and sends it into the
design. The size of the chunks are determined by the
parameter BUFFER_SIZE.

The testbench has a uart which converts the
streaming char bytes into a serial stream.  Likewise
it reads the output serial stream into bytes.

* __compile__ : Default target. Compiles without running the simulation.  Good way to
  test for syntax errors.
* __run__ : Runs the simulation. Outputs PASS or FAIL to standard out.
  Generates a waveform vcd file.
* __view__ : Runs gtkwave and displays the waveform.
* __clean__ : Remove the generated files
* __help__ : Displays iverilog help

## Output

```
vvp sim_top.vvp
VCD info: dumpfile sim_top.vcd opened for output.
r:      159331
feof:          1
                 185: Send 1st sync workd 
                 215: Send 2nd sync workd 

                 275: BEGIN cmd_str_len
                 275: set str char length=   23
                 275: set str bit length=0x00b8
                 725 cmd_state=00
                 725 target_hash=00000000000000000000000000000000
                 725: END cmd_str_len
                 725: ***cmd_str_len ret x

                 755: BEGIN cmd_set_hash
                3305 cmd_state=00
                3305 target_hash=0a4db18ed352b277c1292e9ef323d450
                3305: END cmd_set_hash

                3325: BEGIN send_file
                3325: full transfer:           0:        199

                3325: BEGIN cmd_send_text
                3625: MSB len=00
                3775: LSB len=c8

***This is the Project Gutenberg Etext of Alice in Wonderland***
*This 30th edition should be labeled alice30.txt or alice30.zip.
***This Edition Is Being Officially Released On March 8, 1994***
**In 

               37645: END cmd_send_text
               37645: MATCH FOUND!!
               37645: END send_file

               37655: BEGIN cmd_read_match
               37805: Read byte position
               37985: Read match string
               40085: match_pos:    99
               40085: match_str: ' ed alice30.txt or alice'
               40085: END cmd_read_match
```

