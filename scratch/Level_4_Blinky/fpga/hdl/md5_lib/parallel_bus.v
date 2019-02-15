/*
*****************************
* FILE : parallel_bus
*
* This file implements an 8-bit parallel
* bus for communicating with an FPGA.
* The goal is to use this interface for
* communication between a raspberry pi
* and an ArtyS7 dev board.
* It implements two modules par8_receiver
* and par8_transmitter
*
* Author : Brandon Bloodget
* Creation Date : 01/23/2019
*
*****************************
*/

// Force error when implicit net has no type.
`default_nettype none

/*
***************************************
* MODULE: par8_receiver
***************************************
*/

module par8_receiver
(
    input wire clk,     // fast, like 100mhz
    input wire reset,

    // parallel bus
    input wire bus_clk,
    input wire [7:0] bus_data,
    input wire bus_rnw,     // rpi/master perspective

    // output
    output reg [7:0] rxd_data,  // valid for one clock cycle when rxd_data_ready is asserted.
    output reg rxd_data_ready
);

/*
*****************************
* Signals
*****************************
*/

reg synced;

/*
*****************************
* Main
*****************************
*/

// register the parallel bus
reg bus_clk_reg1;
reg bus_rnw_reg1;
reg [7:0] bus_data_reg1;

reg bus_clk_reg2;
reg bus_rnw_reg2;
reg [7:0] bus_data_reg2;

always @ (posedge clk)
begin
    if (reset) begin
        bus_clk_reg1 <= 0;
        bus_rnw_reg1 <= 0;
        bus_data_reg1 <= 0;

        bus_clk_reg2 <= 0;
        bus_rnw_reg2 <= 0;
        bus_data_reg2 <= 0;
    end else begin
        bus_clk_reg1 <= bus_clk;
        bus_rnw_reg1 <= bus_rnw;
        bus_data_reg1 <= bus_data;

        bus_clk_reg2 <= bus_clk_reg1;
        bus_rnw_reg2 <= bus_rnw_reg1;
        bus_data_reg2 <= bus_data_reg1;
    end
end

// output logic
always @ (posedge clk)
begin
    if (reset) begin
        rxd_data <= 0;
        rxd_data_ready <= 0;
    end else begin
        // Check for positive edge on bus_clk and write direction
        if (bus_clk_reg1 && !bus_clk_reg2 && !bus_rnw_reg1 && synced) begin
            rxd_data <= bus_data_reg1;
            rxd_data_ready <= 1;
        end else begin
            rxd_data_ready <= 0;
        end
    end
end

// Handle the initial sync
reg [1:0] sync_state;
// States
localparam SYNC1            = 0;
localparam SYNC2            = 1;
localparam DONE             = 2;

localparam SYNC_BYTE1       = 8'hB8;
localparam SYNC_BYTE2       = 8'h8B;

always @ (posedge clk)
begin
    if (reset) begin
        sync_state <= SYNC1;
        synced <= 0;
    end else begin
        case (sync_state)
            SYNC1 : begin
                if (bus_data_reg1 == SYNC_BYTE1) begin
                    sync_state <= SYNC2;
                end
            end
            SYNC2 : begin
                if (bus_data_reg1 == SYNC_BYTE2) begin
                    sync_state <= DONE;
                end
            end
            DONE : begin
                synced <= 1;
                sync_state <= DONE;
            end
            default : begin
                sync_state <= SYNC1;
            end
        endcase
    end
end


endmodule

/*
***************************************
* MODULE: par8_transmitter
***************************************
*/

module par8_transmitter
(
    input wire clk,     // fast, like 100mhz
    input wire reset,

    // Data to send
    input wire [7:0] txd_data,
    input wire valid,

    // parallel bus
    input wire bus_clk,
    input wire bus_rnw,     // rpi/master perspective

    // output
    output reg [7:0] bus_data,
    output wire ready_next      // will be ready next clock cycle for data
);

/*
*****************************
* Signals & Assignment
*****************************
*/

reg busy;

assign ready_next = bus_rnw_reg & ~busy &~valid;

/*
*****************************
* Main
*****************************
*/

// register the parallel bus
reg bus_clk_reg;
reg bus_rnw_reg;

always @ (posedge clk)
begin
    if (reset) begin
        bus_clk_reg <= 0;
        bus_rnw_reg <= 0;
    end else begin
        bus_clk_reg <= bus_clk;
        bus_rnw_reg <= bus_rnw;
    end
end

// State machine to send the data
reg [3:0] trans_state;

localparam IDLE                     = 0;
localparam TRANS_WAIT_CLOCK_LOW     = 1;
localparam TRANS_WAIT_CLOCK_HIGH    = 2;


reg [7:0] txd_data_reg;

always @ (posedge clk)
begin
    if (reset) begin
        trans_state <= IDLE;
        busy <= 0;
        txd_data_reg <= 0;
        bus_data <= 0;
    end else begin
        case (trans_state)
            IDLE : begin
                busy <= 0;
                if (bus_rnw_reg & valid) begin
                    // latch data and start send
                    txd_data_reg <= txd_data;
                    busy <= 1;
                    trans_state <= TRANS_WAIT_CLOCK_LOW;
                end
            end
            TRANS_WAIT_CLOCK_LOW : begin
                if (bus_clk_reg == 0) begin
                    // Set the data
                    bus_data <= txd_data_reg;
                    trans_state <= TRANS_WAIT_CLOCK_HIGH;
                end
            end
            TRANS_WAIT_CLOCK_HIGH : begin
                if (bus_clk_reg == 1) begin
                    trans_state <= IDLE;
                end
            end
            default : begin
                trans_state <= IDLE;
            end
        endcase
    end
end


endmodule

