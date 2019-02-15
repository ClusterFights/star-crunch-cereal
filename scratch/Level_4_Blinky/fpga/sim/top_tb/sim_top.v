/*
*****************************
* MODULE : sim_top
*
* This module instantiates the cmd_parser,
* string_process_match and md5 modules for
* simulation purposes
*
* Target : Simulation
*
* Author : Brandon Bloodget
* Create Date : 10/25/2018
* Status: Development
*
*****************************
*/

// Force error when implicit net has no type.
`default_nettype none

module sim_top
(
    input wire clk,
    input wire reset,

    // uart_rx (receive)
    input wire [7:0] rxd_data,
    input wire rxd_data_ready,

    // uart_tx (transmit)
    input wire txd_busy,
    output wire txd_start,
    output wire [7:0] txd_data,


    output wire [7:0] led
);

/*
*****************************
* Signals
*****************************
*/

wire proc_start;
wire [15:0] proc_num_bytes;
wire [7:0] proc_data;
wire proc_data_valid;
wire proc_match_char_next;
wire [127:0] proc_target_hash;

wire proc_done;
wire proc_match;
wire [15:0] proc_byte_pos;
wire [7:0] proc_match_char;

wire [31:0] a_ret;
wire [31:0] b_ret;
wire [31:0] c_ret;
wire [31:0] d_ret;
wire [151:0] md5_msg_ret;
wire md5_msg_ret_valid;

wire [151:0] md5_msg;
wire md5_msg_valid;

/*
*****************************
* Instantiations
*****************************
*/

cmd_parser cmd_parser_inst
(
    .clk(clk),
    .reset(reset),

    // uart_rx (receive)
    .rxd_data(rxd_data), // [7:0]
    .rxd_data_ready(rxd_data_ready),

    // uart_tx (transmit)
    .txd_busy(txd_busy),
    .txd_start(txd_start),
    .txd_data(txd_data), // [7:0]

    // char_buff (process)
    .proc_done(proc_done),
    .proc_match(proc_match),
    .proc_byte_pos(proc_byte_pos), // [15:0] 
    .proc_match_char(proc_match_char), // [7:0] 

    .proc_start(proc_start),
    .proc_num_bytes(proc_num_bytes), // [15:0] 
    .proc_data(proc_data), // [7:0] 
    .proc_data_valid(proc_data_valid),
    .proc_match_char_next(proc_match_char_next),
    .proc_target_hash(proc_target_hash), // [127:0] 

    // feedback/debug
    .led(led)    //    [7:0]
);


string_process_match string_process_match_inst
(
    .clk(clk),
    .reset(reset),

    // cmd_parser
    .proc_start(proc_start),
    .proc_num_bytes(proc_num_bytes), // [15:0] 
    .proc_data(proc_data),      // [7:0] 
    .proc_data_valid(proc_data_valid),
    .proc_match_char_next(proc_match_char_next),
    .proc_target_hash(proc_target_hash),   // [127:0] 

    .proc_done(proc_done),
    .proc_match(proc_match),
    .proc_byte_pos(proc_byte_pos),      // [15:0] 
    .proc_match_char(proc_match_char),    // [7:0] 

    // MD5 core
    .a_ret(a_ret), // [31:0] 
    .b_ret(b_ret),
    .c_ret(c_ret),
    .d_ret(d_ret),
    .md5_msg_ret(md5_msg_ret),    // [151:0] 
    .md5_msg_ret_valid(md5_msg_ret_valid),

    .md5_msg(md5_msg),        // [151:0] 
    .md5_msg_valid(md5_msg_valid)
);

md5core md5core_inst
(
    .clk(clk),
    .reset(reset),
    .en(1'b1),

    .m_in(md5_msg),   // [151:0] 
    .valid_in(md5_msg_valid),

    .a_out(a_ret),  // [31:0] 
    .b_out(b_ret),
    .c_out(c_ret),
    .d_out(d_ret),
    .m_out(md5_msg_ret),  // [151:0] 
    .valid_out(md5_msg_ret_valid)
);

endmodule

