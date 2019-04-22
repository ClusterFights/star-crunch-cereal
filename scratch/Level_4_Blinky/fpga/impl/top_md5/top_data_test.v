/*
*****************************
* MODULE : top_data_test
*
* This module test receiving data from the RPI
* over the parallel interface.  It expects
* 256 sequential bytes, starting at 0.
* After 256 bytes if they are all in order
* it turn on 1 green led (LD2) to indicate success.
*
* It then send 256 bytes back to the rpi.
*
* Author : Brandon Bloodget
* Create Date : 1/21/2019
*
*****************************
*/

// Force error when implicit net has no type.
`default_nettype none

module top_data_test
(
    input wire clk_100mhz,
    input wire reset_n,

    // rpi parallel bus
    input wire bus_clk,
    inout wire [7:0] bus_data,
    input wire bus_rnw,         // rpi/master perspective

    output reg [3:0] led_out,
    output wire led0_r,         // indicates reset pressed
    output reg led0_g,         // indicates match
    output reg led1_r         // indicates not match
);


/*
*****************************
* Signals & Assignments
*****************************
*/

wire reset;

// bus_data out (read)
wire [7:0] bus_data_out;

wire [7:0] rxd_data;
wire rxd_data_ready;

reg [7:0] txd_data;
reg txd_valid;
wire trans_ready_next;

assign bus_data = (bus_rnw==1) ? bus_data_out : 8'bz;
assign reset = ~reset_n;
assign led0_r = reset;

/*
*****************************
* Instantiation
*****************************
*/

par8_receiver par8_receiver_inst
(
    .clk(clk_100mhz),     // fast, like 100mhz
    .reset(reset),

    // parallel bus
    .bus_clk(bus_clk),
    .bus_data(bus_data),
    .bus_rnw(bus_rnw),     // rpi/master perspective

    // output
    .rxd_data(rxd_data),  // valid for one clock cycle when rxd_data_ready is asserted.
    .rxd_data_ready(rxd_data_ready)
);

par8_transmitter par8_transmitter_inst
(
    .clk(clk_100mhz),     // fast, like 100mhz
    .reset(reset),

    // Data to send
    .txd_data(txd_data),
    .valid(txd_valid),

    // parallel bus
    .bus_clk(bus_clk),
    .bus_rnw(bus_rnw),     // rpi/master perspective

    // output
    .bus_data(bus_data_out),
    .ready_next(trans_ready_next)
);


/*
*****************************
* Main
*****************************
*/

// States
localparam IDLE             = 0;
localparam CHECK            = 1;
localparam RECV_DONE        = 2;
localparam SEND_CHECK       = 3;
localparam SEND_DONE        = 4;

reg [3:0] state;
reg [7:0] expected_val;
reg [3:0] led_val;
reg [7:0] send_count;

always @ (posedge clk_100mhz)
begin
    if (reset) begin
        state <= IDLE;
        expected_val <= 0;
        led_val <= 0;
        led_out <= 0;
        led0_g <= 0;
        led1_r <= 0;
        txd_data <= 0;
        txd_valid <= 0;
    end else begin
        case (state)
            IDLE : begin
                led_val <= 1;  // assume pass
                expected_val <= 0;
                state <= CHECK;
            end
            CHECK : begin
                if (rxd_data_ready) begin
                    led_out <= rxd_data[3:0];
                    if (rxd_data != expected_val) begin
                        led_val <= 0;  // nope, fail
                        led1_r <= led1_r + 1;
                    end else begin
                        // match
                        led0_g <= led0_g + 1;
                    end

                    if (expected_val == 255) begin
                        led_out[3:0] <= led_val[3:0];
                        state <= RECV_DONE;
                    end else begin
                        expected_val <= expected_val + 1;
                        state <= CHECK;
                    end
                end
            end
            RECV_DONE : begin
                send_count <= 0; 
                txd_valid <= 0;
                state <= SEND_CHECK;
            end
            SEND_CHECK : begin
                if (trans_ready_next) begin
                    txd_data <= send_count;
                    txd_valid <= 1;
                    send_count <= send_count + 1;
                    if (send_count == 255) begin
                        state <= SEND_DONE;
                    end
                end else begin
                    txd_valid <= 0;
                end
            end
            SEND_DONE : begin
                led_out[1] <= 1;
                state <= SEND_DONE;
            end
            default : begin
                state <= IDLE;
            end
        endcase
    end
end


endmodule

