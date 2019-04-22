/*
*****************************
* MODULE : top_gpio_out
*
* This module is to test a RPi driving
* input and displaying those input on 
* LEDs.
*
* Author : Brandon Bloodget
*
*****************************
*/

// Force error when implicit net has no type.
`default_nettype none

module top_gpio_out
(
    input wire clk_100mhz,
    input wire reset_n,

    // rpi parallel bus
    input wire bus_clk,
    inout wire [7:0] bus_data,
    input wire bus_rnw,         // rpi/master perspective

    output wire [3:0] led_out,
    output wire led0_r,         // indicates reset pressed
    output wire led0_g,         // indicates match
    output wire led1_r         // indicates not match
);

assign led_out[3:0] = bus_data[3:0];

assign led0_r = ~reset_n;
assign led0_g = 0;
assign led1_r = 0;

endmodule

