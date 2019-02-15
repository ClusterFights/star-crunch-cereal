/*
*****************************
* MODULE : ecp5_trellis_md5.v
*
* This module implements the md5
* hashing accelerator.
*
* Target Board: Lattice ECP5-5G Evaluation Board
*
* Modified by : Patrick Lloyd
* Original by : Brandon Blodget
* Create Date : 11/3/2018 
* 
* Updates:
* 01/25/2019 : Updated to support parallel 8 interface
* 02/04/2019 : Project modified to synthesize for ECP5
*
*****************************
*/

`include "spi_slave_buffer.v"

// Force error when implicit net has no type.
`default_nettype none


module ecp5_trellis_md5 #
(
    parameter integer NUM_LEDS = 8
)
(
    //input wire clk_12mhz,
    input wire reset_n,

    // rpi spi interface
    input wire spis_sck,
    inout wire spis_mosi,
    input wire spis_miso,
    input wire spis_ss,

    //output wire bus_done,
    //output wire bus_match,
    //output wire led0,
    //output wire led0_r,         // indicates reset pressed
    output wire [NUM_LEDS-1:0] led_n
);

/*
*****************************
* Signals & Assignments
*****************************
*/

wire reset;
wire [NUM_LEDS-1:0] led;

assign reset = ~reset_n;
assign led = ~led_n;

/*
*****************************
* Instantiations
*****************************
*/
/*
cross_domain_buffer #
(
    .DATA_WIDTH(NUM_LEDS)
)
cross_domain_buffer_inst0
(
    .clk(clk_100mhz),
    .data_in(spis_mosi),
    .save_cmd(spis_done),	
    .data_out(!!!leds),
    .save_complete(save_complete)
);
*/
spi_slave_buffer spi_slave_buffer_inst0(
    .reset(reset),
    .clk(spis_sck),
    .mosi(spis_mosi),
    .miso(spis_miso),
    .sel(spis_ss),
    .buffer(led)
);

/*
top_md5 #
(
    .NUM_LEDS(NUM_LEDS)
) top_md5_inst
(
    .clk(clk_100mhz),
    .reset(reset),
    .bus_clk(bus_clk),
    .bus_data(bus_data),
    .bus_rnw(bus_rnw),         // rpi/master perspective

    .bus_done(bus_done),
    .bus_match(bus_match),
    .match_led(led0_g),
    .led(led)
);
*/

endmodule

