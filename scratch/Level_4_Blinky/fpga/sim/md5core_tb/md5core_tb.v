/*
*****************************
* MODULE : md5core_tb
*
* Testbench for the md5core module.
*
* Author : Brandon Bloodget
* Create Date : 10/16/2018
*
*****************************
*/

// Force error when implicit net has no type.
`default_nettype none

`timescale 1 ns / 1 ps

`define TESTBENCH

module md5core_tb;

// Inputs (registers)
reg clk_12mhz;
reg reset;
reg en;
reg valid_in;
reg [151:0] mesg;


// Outputs (wires)
wire [31:0] a_out;
wire [31:0] b_out;
wire [31:0] c_out;
wire [31:0] d_out;
wire [511:0] m_out;
wire valid_out;

// Define the message
// mesg1="The quick brown fox"
wire [151:0] mesg1 = 152'h54686520_71756963_6b206272_6f776e20_666f78;
wire [127:0] hash1 = 128'ha2004f37_730b9445_670a738f_a0fc9ee5;

// mesg2="Hello World 1234567"
wire [151:0] mesg2 = 152'h48656c6c_6f20576f_726c6420_31323334_353637;
wire [127:0] hash2 = 128'hac98cf84_ae657376_cea165e6_729ddb39;

// mesg3="This is a test. 123"
wire [151:0] mesg3 = 152'h54686973_20697320_61207465_73742e20_313233;
wire [127:0] hash3 = 128'hcaea4868_5020e1b5_11a454f6_60943eaa;

localparam[295:0] msg_pad = 360'h80_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000;

wire [15:0]  length  = 16'h98;
/*
*****************************
* Instantiation (DUT)
*****************************
*/

md5core md5core_inst
(
    .clk(clk_12mhz),
    .reset(reset),
    .en(en),

    .m_in({mesg,msg_pad}),
    .length(length),
    .valid_in(valid_in),

    .a_out(a_out),
    .b_out(b_out),
    .c_out(c_out),
    .d_out(d_out),
    .m_out(m_out),
    .valid_out(valid_out)
);

/*
*****************************
* Main
*****************************
*/
initial begin
    $dumpfile("md5core.vcd");
    $dumpvars;
    clk_12mhz = 0;
    reset = 0;
    en = 0;

    // Wait 100ns
    #100;
    // Add stimulus here
    @(posedge clk_12mhz);
    reset = 1;
    @(posedge clk_12mhz);
    @(posedge clk_12mhz);
    reset = 0;
    @(posedge clk_12mhz);
    @(posedge clk_12mhz);
    en = 1;
    @(posedge clk_12mhz);
    @(posedge clk_12mhz);
    @(posedge clk_12mhz);
    @(posedge clk_12mhz);
    @(posedge clk_12mhz);
    @(posedge clk_12mhz);
    @(posedge clk_12mhz);
end


// Generate a ~12mhz clk
always begin
    #41 clk_12mhz <= ~clk_12mhz;
end


// Run simulation for some number of cycles then finish
reg [9:0] sim_count;
always @ (posedge clk_12mhz)
begin
    if (reset) begin
        sim_count <= 0;
        valid_in <= 0;
        mesg <= 0;
    end else begin
        if (en) begin
            sim_count <= sim_count + 1;
            if (sim_count == 420) begin
                $finish;
            end

            case (sim_count)
                5 : begin
                    mesg <= mesg1;
                    valid_in <= 1;
                end
                6 : begin
                    mesg <= mesg2;
                    valid_in <= 1;
                end
                7 : begin
                    mesg <= mesg3;
                    valid_in <= 1;
                end
                default : begin
                    mesg <= 0;
                    valid_in <= 0;
                end
            endcase

        end
    end
end

// Check the results
reg [9:0] result_count;
reg pass;
always @ (posedge clk_12mhz)
begin
    if (reset) begin
        result_count <= 0;
        pass <= 0;
    end else begin
        pass <= 0; // default
        if (en && valid_out) begin
            result_count <= result_count + 1;
            case (result_count)
                0 : begin
                    if (  (a_out[31:0] == hash1[127:96]) &&
                          (b_out[31:0] == hash1[95:64]) &&
                          (c_out[31:0] == hash1[63:32]) &&
                          (d_out[31:0] == hash1[31:0]) ) begin
                        pass <= 1;
                        $display("msg1 PASS");
                    end else begin
                        $display("msg1 FAIL");
                    end
                end
                1 : begin
                    if (  (a_out[31:0] == hash2[127:96]) &&
                          (b_out[31:0] == hash2[95:64]) &&
                          (c_out[31:0] == hash2[63:32]) &&
                          (d_out[31:0] == hash2[31:0]) ) begin
                        pass <= 1;
                        $display("msg2 PASS");
                    end else begin
                        $display("msg2 FAIL");
                    end
                end
                2 : begin
                    if (  (a_out[31:0] == hash3[127:96]) &&
                          (b_out[31:0] == hash3[95:64]) &&
                          (c_out[31:0] == hash3[63:32]) &&
                          (d_out[31:0] == hash3[31:0]) ) begin
                        pass <= 1;
                        $display("msg3 PASS");
                    end else begin
                        $display("msg3 FAIL");
                    end
                end
            endcase
        end
    end
end


endmodule

