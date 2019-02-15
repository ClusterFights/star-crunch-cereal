/*
*****************************
* MODULE : parallel_bus_tb
*
* Testbench for the parallel_bus module.
*
* Author : Brandon Bloodget
* Create Date : 01/24/2019
*
*****************************
*/

// Force error when implicit net has no type.
`default_nettype none

`timescale 1 ns / 1 ps

`define TESTBENCH

module parallel_bus_tb;

// Inputs (registers)
reg clk_100mhz;
reg reset;
reg [7:0] txd_data;
reg valid;
reg bus_clk;
reg bus_rnw;


// Outputs (wires)
wire [7:0] bus_data;
wire ready_next;


// Internal wires

/*
*****************************
* Instantiations
*****************************
*/

par8_transmitter par8_transmitter_inst
(
    .clk(clk_100mhz),     // fast, like 100mhz
    .reset(reset),

    // Data to send
    .txd_data(txd_data),
    .valid(valid),

    // parallel bus
    .bus_clk(bus_clk),
    .bus_rnw(bus_rnw),     // rpi/master perspective

    // output
    .bus_data(bus_data),
    .ready_next(ready_next)
);


/*
*****************************
* Main
*****************************
*/
initial begin
    $dumpfile("parallel_bus.vcd");
    $dumpvars(0, parallel_bus_tb);

    clk_100mhz = 0;
    reset = 0;
    txd_data = 0;
    valid = 0;
    bus_clk = 0;
    bus_rnw = 1;

    // Wait 100ns
    #100;
    // Add stimulus here
    @(posedge clk_100mhz);
    reset = 1;
    @(posedge clk_100mhz);
    @(posedge clk_100mhz);
    reset = 0;
    @(posedge clk_100mhz);
    @(posedge clk_100mhz);
end


// Generate a 100mhz clk
always begin
    #5 clk_100mhz <= ~clk_100mhz;
end

// Generate bus_clk at ~10mhz
always begin
    #54 bus_clk <= ~bus_clk;
end

reg [7:0] count;
always @ (posedge clk_100mhz)
begin
    if (reset) begin
        count <= 0;
        txd_data <= 0;
        valid <= 0;
    end else begin
        if (ready_next) begin
            txd_data <= count;
            count <= count + 1;
            valid <= 1;
            if (count == 255) begin
                $finish;
            end
        end else begin
            valid <= 0;
        end
    end
end


endmodule


