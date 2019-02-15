/*
*****************************
* MODULE : sim_top_tb
*
* Testbench for the cmd_parser,
* string_process_match and md5core modules
* all working together.
*
* Author : Brandon Bloodget
* Create Date : 10/25/2018
* Status : Developoment
*
*****************************
*/

// Force error when implicit net has no type.
`default_nettype none

`timescale 1 ns / 1 ns

`define TESTBENCH
`define NULL    0
`define STR_LEN 23

module sim_top_tb;

/*
*****************************
* Inputs (registers)
*****************************
*/

// top_md5
reg clk_100mhz;
reg reset;

// par8 bus
reg [7:0] bus_data_in;
reg bus_clk;
reg bus_rnw;
/*
*****************************
* inout (wires)
*****************************
*/

wire [7:0] bus_data;

assign bus_data = (bus_rnw) ? 8'bz : bus_data_in;

/*
*****************************
* Outputs (wires)
*****************************
*/

// top_md5
wire serial_out;
wire match_led;
wire [3:0] led;

wire bus_done;
wire bus_match;

/*
*****************************
* Internal (wires)
*****************************
*/

integer file, r;    // file handler
integer i,j,k;      // loop counters

reg finished;
reg done;
reg ret;
reg ack;

// version for send_file
reg sf_done=0;
reg [7:0] sf_ack=0;
integer sf_i;
integer sf_j=0;
integer sf_k=0;

reg match;
reg[15:0] match_pos;
reg[`STR_LEN*8:0] match_str;

reg [7:0] rchar;

/*
*****************************
* Parameters
*****************************
*/

parameter NUM_LEDS = 4;
parameter FILE_SIZE_IN_BYTES = 163_185;  // +1 (alice30.txt)
// XXX parameter FILE_SIZE_IN_BYTES = 254;  // +1 (test.txt)


parameter CMD_SET_HASH_OP       = 8'h01;
parameter CMD_SEND_TEXT_OP      = 8'h02;
parameter CMD_READ_MATCH_OP     = 8'h03;
parameter CMD_TEST_OP           = 8'h04;
parameter CMD_STR_LEN           = 8'h05;

parameter BUFFER_SIZE           = 200;

/*
******************************************
* Testbench memories
******************************************
*/

// tv_mem holds bytes from the
// sample text file alice30.txt
reg [7:0] tv_mem [0:FILE_SIZE_IN_BYTES-1];

// the target hash

// file: alice30.txt
// byte_offset: 800
// byte_str: b"\nAlice's Adventures"
// reg [127:0] target_hash = 128'h1d5468d37f38dc34dca0692c3a6f2c83;

// file: alice30.txt
// byte_offset: 100
// byte_str: b"ed alice30.txt or a"
// str_len: 19*8=152 bits
// XXX reg [15:0] str_len = 19*8;
// XXX reg [127:0] target_hash = 128'h7e2ba776cc7b346f3592bfedb41b18bd;

// file: alice30.txt
// byte_offset: 100
// byte_str: b"ed alice30.txt or alice"
// str_len: 23*8=184 bits
reg [15:0] str_len = `STR_LEN*8;
reg [127:0] target_hash = 128'h0a4db18ed352b277c1292e9ef323d450;

// file: test.txt
// byte_offset: 233
// byte_str: b"123456789ABCDEF0123"
// reg [127:0] target_hash = 128'hccfa4ae8ea9d1e44d22f73b9c53c844c;

// Buffer for the text to be sent to FPGA.
reg [(BUFFER_SIZE*8)-1:0] text_str;

/*
*****************************
* Instantiations (DUT)
*****************************
*/


top_md5 #
(
    .NUM_LEDS(NUM_LEDS)
) top_md5_inst
(
    .clk(clk_100mhz),
    .reset(reset),

    // rpi parallel bus
    .bus_clk(bus_clk),
    .bus_data(bus_data),
    .bus_rnw(bus_rnw),         // rpi/master perspective

    .bus_done(bus_done),
    .bus_match(bus_match),

    .match_led(match_led),
    .led(led)
);


/*
*****************************
* Main
*****************************
*/

// Main testbench
initial begin
    // For viewer
    $dumpfile("sim_top.vcd");
    $dumpvars;

    // initialize memories
    file = $fopen("alice30.txt", "rb");
    // XXX file = $fopen("test.txt", "rb");
    if (file == `NULL)
    begin
        $display("data_file handle was NULL");
        $finish;
    end
    r = $fread(tv_mem, file);
    $display("r: ",r);
    $display("feof: ",$feof(file));
    $fclose(file);

    // initialize registers
    clk_100mhz      = 0;
    reset           = 0;
    text_str        = 0;
    match_pos       = 0;
    match_str       = 0;
    match           = 0;
    bus_data_in     = 0;
    bus_rnw         = 0;
    rchar           = 0;

    // Wait 100 ns for global reset to finish
    #100;
    // Add stimulus here
    @(posedge clk_100mhz);
    reset   = 1;
    @(posedge clk_100mhz);
    @(posedge clk_100mhz);
    reset   = 0;
    @(posedge clk_100mhz);
    @(posedge clk_100mhz);
    @(posedge clk_100mhz);
    sync_bus;
    @(posedge clk_100mhz);
    @(posedge clk_100mhz);
    @(posedge clk_100mhz);
    cmd_str_len(str_len,ret);    // set the string length
    $display("%t: ***cmd_str_len ret %x",$time,ret);
    @(posedge clk_100mhz);
    @(posedge clk_100mhz);
    @(posedge clk_100mhz);
    // XXX cmd_test;
    cmd_set_hash(ret);
    @(posedge clk_100mhz);
    @(posedge clk_100mhz);
    // XXX cmd_send_text(BUFFER_SIZE);

    send_file(match);
    @(posedge clk_100mhz);
    if (match == 1)
    begin
        cmd_read_match;
    end

//    @(posedge finished);
    @(posedge clk_100mhz);
    @(posedge clk_100mhz);
    @(posedge clk_100mhz);
    $finish;
end


// Test reading from tv_mem
/*
reg [15:0] count;
always @ (posedge clk_100mhz)
begin
    if (reset) begin
        count <= 0;
        finished <= 0;
    end else begin
        count <= count + 1;
        $display("%d %c",count, tv_mem[count]);
        if (count == 50) begin
            finished <= 1;
        end
    end
end
*/

// Sync the par8 bus
task sync_bus;
begin
    // make sure the clock is high
    bus_clk = 1;
    @ (posedge clk_100mhz);
    @ (posedge clk_100mhz);
    @ (posedge clk_100mhz);

    // send the first sync word
    $display("%t: Send 1st sync workd ",$time);
    bus_data_in = 8'hB8;
    @ (posedge clk_100mhz);
    @ (posedge clk_100mhz);
    @ (posedge clk_100mhz);

    // send the 2nd sync word
    $display("%t: Send 2nd sync workd ",$time);
    bus_data_in = 8'h8B;
    @ (posedge clk_100mhz);
    @ (posedge clk_100mhz);
    @ (posedge clk_100mhz);

end
endtask

// Task to send a character
task send_char;
    input [7:0] char;
begin
    // make sure bus_rnw is in write mode
    bus_rnw = 0;
    @ (posedge clk_100mhz);
    @ (posedge clk_100mhz);
    @ (posedge clk_100mhz);

    // drive bus_clk low and set data
    bus_clk = 0;
    @ (posedge clk_100mhz);
    @ (posedge clk_100mhz);
    @ (posedge clk_100mhz);
    bus_data_in = char;
    @ (posedge clk_100mhz);
    @ (posedge clk_100mhz);
    @ (posedge clk_100mhz);

    // drive bus_clk high now that data is set
    bus_clk = 1;
    @ (posedge clk_100mhz);
    @ (posedge clk_100mhz);
    @ (posedge clk_100mhz);
    @ (posedge clk_100mhz);
    @ (posedge clk_100mhz);
    @ (posedge clk_100mhz);

end
endtask

// Read a char
task read_char;
    output [7:0] char;
begin
    // make sure bus_rnw is in read mode
    bus_rnw = 1;
    @ (posedge clk_100mhz);
    @ (posedge clk_100mhz);
    @ (posedge clk_100mhz);

    // drive the clock low
    bus_clk = 0;
    @ (posedge clk_100mhz);
    @ (posedge clk_100mhz);
    @ (posedge clk_100mhz);

    // drive the clock high
    bus_clk = 1;
    @ (posedge clk_100mhz);
    @ (posedge clk_100mhz);
    @ (posedge clk_100mhz);

    // read the value
    char = bus_data;
end
endtask


// Task to send test cmd.
task cmd_test;
begin
    $display("\n%t: BEGIN cmd_test",$time);
    // Send the command
    send_char(CMD_TEST_OP);

    // Read back test data
    for (i=0; i<10; i++)
    begin
        read_char(rchar);
        $display("%t: %d val=%d",$time,i,rchar);
    end

    // wait for bus_done go high
    while(!bus_done)
    begin
        @(posedge clk_100mhz);
    end

    $display("\n%t: END cmd_test",$time);
end
endtask

// Task to send target hash
task cmd_set_hash;
    output [7:0] ack;
begin
    $display("\n%t: BEGIN cmd_set_hash",$time);

    // Send the command
    send_char(CMD_SET_HASH_OP);

    // Send the 16 target hash bytes
    for (i=15; i>=0; i=i-1)
    begin
        send_char(target_hash[8*i +: 8]);
        // XXX $display("%t: %d hash_byte:%2x",$time,i,bus_data);
    end

    // wait for bus_done go high
    while(!bus_done)
    begin
        @(posedge clk_100mhz);
    end

    // Print value.
    $display("%t cmd_state=%x",$time,top_md5_inst.cmd_parser_inst.cmd_state);
    $display("%t target_hash=%x",$time,top_md5_inst.cmd_parser_inst.target_hash);
    $display("%t: END cmd_set_hash",$time);
end
endtask


// Task to send a block of text
task cmd_send_text;
    input [15:0] text_str_len;
    output [7:0] ack;
begin
    $display("\n%t: BEGIN cmd_send_text",$time);

    // Send the command
    send_char(CMD_SEND_TEXT_OP);

    // Send the number of bytes to be sent
    // Send MSB first
    send_char(text_str_len[15:8]);
    $display("%t: MSB len=%x",$time,bus_data);
    // Send LSB second
    send_char(text_str_len[7:0]);
    $display("%t: LSB len=%x",$time,bus_data);

    // Send the characters
    $display("");
    for (i=0; i <text_str_len; i++)
    begin
        send_char(text_str[8*i +: 8]);
        // XXX $display("%t: %d char=%c",$time,i,bus_data);
        $write("%c",bus_data);
    end
    $display("\n");

    // wait for bus_done go high
    while(!bus_done)
    begin
        @(posedge clk_100mhz);
    end

    ack = bus_match;

    $display("%t: END cmd_send_text",$time);
end
endtask

// Task to send test file
task send_file;
    output match;
begin
    $display("\n%t: BEGIN send_file",$time);
    match = 0;

    sf_done=0; sf_i=0; sf_j=0; sf_k=0; sf_ack=0;
    while(!sf_done)
    begin
        if (sf_i+BUFFER_SIZE-1 > FILE_SIZE_IN_BYTES)
        begin
            // last transfer
            sf_j= FILE_SIZE_IN_BYTES -sf_i;
            $display("%t: last transfer: %d:%d %d",$time,sf_i,FILE_SIZE_IN_BYTES-1,sf_j);

            // Copy into text_str
            for (sf_k=0; sf_k<sf_j; sf_k=sf_k+1)
            begin
                text_str[sf_k*8 +: 8] = tv_mem[sf_i];
                sf_i=sf_i+1;
            end
            // Send to device
            cmd_send_text(sf_j,sf_ack);

            // Check if match found
            if (sf_ack == 1)
            begin
                $display("%t: MATCH FOUND!!",$time);
                match = 1;
            end
            else
            begin
                $display("%t: MATCH NOT found",$time);
            end
            sf_i=sf_j;
            sf_done = 1;
        end
        else
        begin
            // full transfer
            sf_j= sf_i + BUFFER_SIZE;
            $display("%t: full transfer: %d:%d",$time,sf_i,sf_j-1);
            // Copy into text_str
            for (sf_k=0; sf_k<BUFFER_SIZE; sf_k=sf_k+1)
            begin
                text_str[sf_k*8 +: 8] = tv_mem[sf_i];
                sf_i=sf_i+1;
            end
            // Send to device
            cmd_send_text(BUFFER_SIZE,sf_ack);
            
            // Check if match found
            if (sf_ack == 1)
            begin
                $display("%t: MATCH FOUND!!",$time);
                match = 1;
                sf_done = 1;
            end
            else
            begin
                $display("%t: MATCH NOT found",$time);
            end
        end
    end // while

    $display("%t: END send_file",$time);
end
endtask

// Task read match info
task cmd_read_match;
begin
    $display("\n%t: BEGIN cmd_read_match",$time);

    // Send the command
    send_char(CMD_READ_MATCH_OP);

    // Read the the match byte position
    // Read MSB
    $display("%t: Read byte position",$time);
    read_char(match_pos[15:8]);
    // Read LSB
    read_char(match_pos[7:0]);
    match_pos = match_pos - (`STR_LEN-1);

    // Read the match string
    $display("%t: Read match string",$time);
    for (j=(`STR_LEN-1); j>=0; j=j-1)
    begin
        read_char(match_str[j*8 +: 8]);
    end

    // wait for bus_done go high
    while(!bus_done)
    begin
        @(posedge clk_100mhz);
    end

    $display("%t: match_pos: %d",$time,match_pos);
    $display("%t: match_str: '%s'",$time,match_str);

    $display("%t: END cmd_read_match",$time);
end
endtask

// Task to send target hash
task cmd_str_len;
    input [15:0] length;
    output [7:0] ack;
begin
    $display("\n%t: BEGIN cmd_str_len",$time);
    $display("%t: set str char length=%d",$time,(length>>3));
    $display("%t: set str bit length=0x%x",$time,length);

    // Send the command
    send_char(CMD_STR_LEN);

    // Send the two length bytes.  MSB first.
    send_char(length[15:8]);
    send_char(length[7:0]);

    // wait for bus_done go high
    while(!bus_done)
    begin
        @(posedge clk_100mhz);
    end

    // Print value.
    $display("%t cmd_state=%x",$time,top_md5_inst.cmd_parser_inst.cmd_state);
    $display("%t target_hash=%x",$time,top_md5_inst.cmd_parser_inst.target_hash);
    $display("%t: END cmd_str_len",$time);
end
endtask

// Generate a 100mhz clk
always begin
    #5 clk_100mhz <= ~clk_100mhz;
end

endmodule

