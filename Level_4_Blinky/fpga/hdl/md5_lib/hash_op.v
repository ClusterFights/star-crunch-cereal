/*
*****************************
* MODULE : hash_op
*
* This module implements one MD5 operation.
* MD5 consists of 64 of these operations,
* grouped in four rounds of 16 operations.
*
* It has been optimized for the ClustFight 
* competition which has fixed length strings
* of 19 characters.
* 
* For more info about the algorithm see:
* https://en.wikipedia.org/wiki/MD5
*
* Target Board: iCE40HX-8K Breakout Board.
*
* Author : Brandon Bloodget
* Create Date: 10/14/2018
*
* Update:
* 01/29/2019 : Allow variables sized messages.
*****************************
*/

// Force error when implicit net has no type.
`default_nettype none

module hash_op #
(
    parameter integer index = 0,
    parameter integer s = 0,
    parameter integer k = 0
)
(
    input wire clk,
    input wire reset,
    input wire en,

    input wire [31:0] a, b, c, d,
    input wire [511:0] m_in,
    input wire valid_in,

    output wire [31:0] a_out, b_out, c_out, d_out,
    output wire [511:0] m_out,
    output wire valid_out
);

/*
*****************************
* Signals
*****************************
*/

// Break the message (m_in) into sixteen
// 32-bit words m[j] 0 <= j <= 15
wire [31:0] m [15:0];

// Used to hold the full message
wire [511:0] msg_full;


/*
*****************************
* Assignments
*****************************
*/

// Generate the assignments to break
// message (mesg) into sixteen 32-bit words.
// Will be indexed by the g funciton.
// The only place we use the message is in stage2.
// So we use the stage 1 (m1) message
assign msg_full[511:0] = m1[511:0];
genvar gi;
generate
    for (gi=0; gi<16; gi=gi+1) begin: sig_gi
        assign m[gi] = msg_full[32*(15-gi) +: 32];
    end
endgenerate


/*
*****************************
* Assignments
*****************************
*/

assign a_out = a6;
assign b_out = b6;
assign c_out = c6;
assign d_out = d6;
assign m_out = m6;
assign valid_out = valid6;

/*
*****************************
* Functions
*****************************
*/

function[31:0] f;
input [31:0] i, b, c, d;
begin
    if (i<16)
        f = (b & c) | ((~b) & d);
    else if (i<32)
        f = (d & b) | ((~d) & c);
    else if (i<48)
        f =  b ^ c ^ d;
    else
        f = c ^ (b | (~d));
end
endfunction

function[31:0] g;
input [31:0] i;
begin
    if (i<16)
        g = i;
    else if (i<32)
        g = (5*i + 1) % 16;
    else if (i<48)
        g = (3*i + 5) % 16;
    else
        g = (7*i) % 16;
end
endfunction

function[31:0] leftrotate;
input [31:0] x, c;
begin
    leftrotate= (x<<c) | (x >> (32-c));
end
endfunction

function [31:0] swap_endian_32b;
input [32:0] in;
begin
    swap_endian_32b = {in[0+:8], in[8+:8], in[16+:8], in[24+:8]};
end
endfunction

/*
*****************************
* Main
*****************************
*/

// Stage 1
reg [31:0] a1, b1, c1, d1;
reg [511:0] m1;
reg  valid1;
always @ (posedge clk)
begin
    if (reset) begin
        a1 <= 0;
        b1 <= 0;
        c1 <= 0;
        d1 <= 0;
        m1 <= 0;
        valid1 <= 0;
    end else begin
        if (en) begin
            a1 <= a + f(index,b,c,d);
            b1 <= b;
            c1 <= c;
            d1 <= d;
            m1 <= m_in;
            valid1 <= valid_in;
        end
    end
end

// Stage 2
reg [31:0] a2, b2, c2, d2;
reg [511:0] m2;
reg valid2;
always @ (posedge clk)
begin
    if (reset) begin
        a2 <= 0;
        b2 <= 0;
        c2 <= 0;
        d2 <= 0;
        m2 <= 0;
        valid2 <= 0;
    end else begin
        if (en) begin
            a2 <= a1 + swap_endian_32b(m[g(index)]);
            b2 <= b1;
            c2 <= c1;
            d2 <= d1;
            m2 <= m1;
            valid2 <= valid1;
        end
    end
end

// Stage 3
reg [31:0] a3, b3, c3, d3;
reg [511:0] m3;
reg valid3;
always @ (posedge clk)
begin
    if (reset) begin
        a3 <= 0;
        b3 <= 0;
        c3 <= 0;
        d3 <= 0;
        m3 <= 0;
        valid3 <= 0;
    end else begin
        if (en) begin
            a3 <= a2 + k;
            b3 <= b2;
            c3 <= c2;
            d3 <= d2;
            m3 <= m2;
            valid3 <= valid2;
        end
    end
end

// Stage 4
reg [31:0] a4, b4, c4, d4;
reg [511:0] m4;
reg valid4;
always @ (posedge clk)
begin
    if (reset) begin
        a4 <= 0;
        b4 <= 0;
        c4 <= 0;
        d4 <= 0;
        m4 <= 0;
        valid4 <= 0;
    end else begin
        if (en) begin
            a4 <= leftrotate(a3,s);
            b4 <= b3;
            c4 <= c3;
            d4 <= d3;
            m4 <= m3;
            valid4 <= valid3;
        end
    end
end

// Stage 5
reg [31:0] a5, b5, c5, d5;
reg [511:0] m5;
reg valid5;
always @ (posedge clk)
begin
    if (reset) begin
        a5 <= 0;
        b5 <= 0;
        c5 <= 0;
        d5 <= 0;
        m5 <= 0;
        valid5 <= 0;
    end else begin
        if (en) begin
            a5 <= a4 + b4;
            b5 <= b4;
            c5 <= c4;
            d5 <= d4;
            m5 <= m4;
            valid5 <= valid4;
        end
    end
end

// Stage 6
reg [31:0] a6, b6, c6, d6;
reg [511:0] m6;
reg valid6;
always @ (posedge clk)
begin
    if (reset) begin
        a6 <= 0;
        b6 <= 0;
        c6 <= 0;
        d6 <= 0;
        m6 <= 0;
        valid6 <= 0;
    end else begin
        if (en) begin
            a6 <= d5;
            b6 <= a5;
            c6 <= b5;
            d6 <= c5;
            m6 <= m5;
            valid6 <= valid5;
        end
    end
end


endmodule

