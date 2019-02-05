/*
*****************************
* MODULE : cmd_parser
*
* This module receives a stream of
* characters and parses the incoming commands.
* Implements a state-machine that 
* executes the commands.  There are three
* commands:
*
* 1. Set target hash.
* 2. Process 'n' characters for md5 processing.
* 3. Return match position and string.
*
* Multi-byte parameters and return values are
* send MSB first (big endian/network order).
*
* Target Board: iCE40HX-8K Breakout Board.
* Status: In development.
*
* Author : Brandon Bloodget
*
* Updates:
* 01/25/2019 : changed port txd_busy to txd_ready_next, to be compatible with
*               par8_transmitter.
* 01/30/2019 : Added set STR_LEN command.
*
*****************************
*/

// Force error when implicit net has no type.
`default_nettype none

module cmd_parser #
(
    parameter integer NUM_LEDS = 8
)
(
    input wire clk,
    input wire reset,

    // uart_rx (receive)
    input wire [7:0] rxd_data,
    input wire rxd_data_ready,

    // uart_tx (transmit)
    input wire txd_ready_next,
    output reg txd_start,
    output reg [7:0] txd_data,

    // char_buff (process)
    input wire proc_done,
    input wire proc_match,
    input wire [15:0] proc_byte_pos,
    input wire [7:0] proc_match_char,
    output reg proc_start,
    output wire [15:0] proc_num_bytes,
    output reg [7:0] proc_data,
    output reg proc_data_valid,
    output reg proc_match_char_next,
    output wire [127:0] proc_target_hash,
    output wire [15:0] proc_str_len,    // big endian

    output reg cmd_done,
    output reg cmd_match,

    // feedback/debug
    output wire [NUM_LEDS-1:0] led
);

/*
*****************************
* Assignments
*****************************
*/

assign led[NUM_LEDS-1:0] = cmd_state[NUM_LEDS-1:0];
assign proc_target_hash[127:0] = target_hash[127:0];
assign proc_num_bytes[15:0] = num_bytes[15:0];
assign proc_str_len[15:0] = str_len[15:0];

/*
*****************************
* Parameters
*****************************
*/

// States
localparam IDLE             = 0;
localparam SET_HASH         = 1;
localparam PROC_CHARS1      = 2;
localparam PROC_CHARS2      = 3;
localparam PROC_CHARS3      = 4;
localparam RET_CHARS1       = 5;
// XXX localparam RET_CHARS1_WAIT  = 6;
// XXX localparam RET_CHARS1_WAIT2 = 7;
localparam RET_CHARS2       = 6;
// XXX localparam RET_CHARS2_WAIT  = 9;
localparam TEST             = 7;
localparam TEST2            = 8;
localparam ACK              = 9;
localparam STR_LEN          = 10;

// Character constants
localparam SET_CMD      = 8'h01;
localparam PROC_CMD     = 8'h02;
localparam RET_CMD      = 8'h03;
localparam TEST_CMD     = 8'h04;
localparam STR_LEN_CMD  = 8'h05;

/*
*****************************
* Main
*****************************
*/

reg [7:0] cmd_state;
reg [15:0] char_count;
reg [127:0] target_hash;
reg [15:0] num_bytes;
reg [15:0] str_len;
always @ (posedge clk)
begin
    if (reset) begin
        cmd_state   <= IDLE;
            proc_data <= 0;
            proc_data_valid <= 0;
        char_count  <= 0;
        txd_data <= 0;
        txd_start <= 0;
        target_hash <= 0;
        proc_data <= 0;
        proc_data_valid <= 0;
        proc_start <= 0;
        proc_match_char_next <= 0;
        num_bytes <= 0;
        // 8*19=152=0x98. Default 19 chars
        str_len <= 16'h98;
        cmd_done <= 0;
    end else begin
        case (cmd_state)
            IDLE : begin
                char_count <= 0;
                txd_data <= 0;
                txd_start <= 0;
                proc_data <= 0;
                proc_data_valid <= 0;
                proc_start <= 0;
                proc_match_char_next <= 0;
                num_bytes <= 0;
                // Waiting for a command byte
                if (rxd_data_ready) begin
                    if (rxd_data == SET_CMD) begin
                        cmd_state <= SET_HASH;
                    end else if (rxd_data == PROC_CMD) begin
                        cmd_state <= PROC_CHARS1;
                    end else if (rxd_data == RET_CMD) begin
                        cmd_state <= RET_CHARS1;
                    end else if (rxd_data == TEST_CMD) begin
                        char_count <= 10;
                        cmd_state <= TEST;
                    end else if (rxd_data == STR_LEN_CMD) begin
                        char_count <= 2;
                        cmd_state <= STR_LEN;
                    end
                end
            end
            SET_HASH : begin
                cmd_done <= 0;
                if (rxd_data_ready) begin
                    target_hash[127:0] <= {target_hash[119:0],rxd_data};
                    char_count <= char_count + 1;
                    if (char_count == 15) begin
                        cmd_state <= ACK;
                    end
                end
            end
            PROC_CHARS1 : begin
                cmd_done <= 0;
                // Read the number of bytes
                if (rxd_data_ready) begin
                    num_bytes[15:0] <= {num_bytes[7:0],rxd_data};
                    char_count <= char_count + 1;
                    if (char_count == 1) begin
                        char_count <= 0;
                        proc_start <= 1;
                        cmd_state <= PROC_CHARS2;
                    end
                end
            end
            PROC_CHARS2 : begin
                proc_start <= 0;
                // Read in the characters to process.
                if (rxd_data_ready) begin
                    proc_data <= rxd_data;
                    proc_data_valid <= 1;
                    char_count <= char_count + 1;
                end else begin
                    proc_data_valid <= 0;
                end
                if (char_count == num_bytes) begin
                    proc_data_valid <= 0;
                    cmd_state <= PROC_CHARS3;
                end
            end
            PROC_CHARS3 : begin
                // Wait for hash to complete.
                if (proc_done) begin
                    cmd_match <= proc_match;
                    cmd_state <= ACK;
                end
            end
            RET_CHARS1 : begin
                cmd_done <= 0;
                // Return match byte position
                if (txd_ready_next) begin
                    txd_data <= (char_count==0) ? proc_byte_pos[15:8] :
                        proc_byte_pos[7:0];
                    txd_start <= 1;
                    char_count <= char_count + 1;
                    // XXX cmd_state <= RET_CHARS1_WAIT;
                    if (char_count == 1) begin
                        char_count <= 0;
                        cmd_state <= RET_CHARS2;
                    end
                end else begin
                    txd_start <= 0;
                end
            end
            RET_CHARS2 : begin
                // Return the matched string
                if (txd_ready_next) begin
                    txd_data <= proc_match_char;
                    proc_match_char_next <= 1;
                    txd_start <= 1;
                    char_count <= char_count + 1;
                    // XXX cmd_state <= RET_CHARS2_WAIT;
                    if (char_count == (str_len>>3)) begin
                        proc_match_char_next <= 0;
                        txd_start <= 0;
                        cmd_state <= ACK;
                    end
                end else begin
                    proc_match_char_next <= 0;
                    txd_start <= 0;
                end
            end
            TEST : begin
                // Return test countdown 10..1
                if (txd_ready_next) begin
                    txd_data <= char_count[7:0];
                    $display("TEST count: %d",txd_data);
                    txd_start <= 1;
                    char_count <= char_count - 1;
                    if (char_count == 1) begin
                        cmd_state <= TEST2;
                    end
                end else begin
                    txd_start <= 0;
                end
            end
            TEST2 : begin
                txd_start <= 0;
                cmd_state <= ACK;
                $display("TEST2: done.");
            end
            ACK : begin
                cmd_done <= 1;
                cmd_state <= IDLE;
            end
            STR_LEN : begin
                if (rxd_data_ready) begin
                    str_len[15:0] <= {str_len[7:0],rxd_data};
                    char_count <= char_count - 1;
                    if (char_count == 1) begin
                        cmd_state <= ACK;
                    end
                end
            end
            default : begin
                cmd_state <= IDLE;
            end
        endcase
    end
end

endmodule


