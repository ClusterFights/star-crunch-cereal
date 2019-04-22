// Patrick Lloyd

`include "spi_slave.v"
`include "lcd_line_writer.v"
`include "pll_12_50.v"
`include "cross_domain_buffer.v"
`include "liquid_crystal_display.v"
`include "md5_brute_forcer.v"

module fpga_md5(
    input wire          clk_12,       // 12mhz ftdi clock for PLL
    input wire          btn,
    output wire          spis_miso,         
    input wire          spis_mosi,
    input wire          spis_sck,
    input wire          spis_ss,
    output wire  [7:4]   lcd_db,
    output wire          lcd_en,
    output wire          lcd_rs,
    output wire  [7:0]   led
);

// intermediate wires

wire	clk_50;

wire	[31:0] SYNTHESIZED_WIRE_0;
wire	SYNTHESIZED_WIRE_14;
wire	SYNTHESIZED_WIRE_2;
wire	[31:0] SYNTHESIZED_WIRE_3;
wire	SYNTHESIZED_WIRE_5;
wire	SYNTHESIZED_WIRE_6;
wire	[7:0] SYNTHESIZED_WIRE_7;
wire	SYNTHESIZED_WIRE_9;
wire	[31:0] SYNTHESIZED_WIRE_10;
wire	SYNTHESIZED_WIRE_12;
wire	[127:0] SYNTHESIZED_WIRE_13;

pll_12_50 pll_12_50_inst0(
    .clki(clk_12),
    .clko(clk_50)
);

//defparam spis_inst0.BufferSize = 32;
spi_slave spi_slave_inst0(
    .sck(spis_sck),
    .ss(spis_ss),
    .mosi(spis_mosi),
    .misoBuffer(SYNTHESIZED_WIRE_0),
    .miso(spis_miso),
    .shiftComplete(SYNTHESIZED_WIRE_9),
    .mosiBuffer(SYNTHESIZED_WIRE_10)
);



md5_brute_forcer md5_brute_forcer_inst0(
    .clk(clk_50),
    .hasReceived(SYNTHESIZED_WIRE_2),
    .dataIn(SYNTHESIZED_WIRE_3),
    .hasMatched(led[7]),
    .resetGenerator(led[0]),
    .dataOut(SYNTHESIZED_WIRE_0),
    .text(SYNTHESIZED_WIRE_13)
);


//liquid_crystal_display liquid_crystal_display_inst0(
//    .clk(clk_12),
//    .writeChar(SYNTHESIZED_WIRE_5),
//    .home(SYNTHESIZED_WIRE_6),
//    .char(SYNTHESIZED_WIRE_7),
//    .db4(lcd_db[4]),
//    .db5(lcd_db[5]),
//    .db6(lcd_db[6]),
//    .db7(lcd_db[7]),
//    .rs(lcd_rs),
//    .enable(lcd_en),
//    .ready(SYNTHESIZED_WIRE_12)
//);


cross_domain_buffer cross_domain_buffer_inst0(
    .clk(clk_50),
    .save(SYNTHESIZED_WIRE_9),
    .in(SYNTHESIZED_WIRE_10),
    .saved(SYNTHESIZED_WIRE_2),
    .out(SYNTHESIZED_WIRE_3)
);

/*
lcd_line_writer lcd_line_writer_inst0(
    .clk(clk_12),
    .ready(SYNTHESIZED_WIRE_12),
    .line(SYNTHESIZED_WIRE_13),
    .writeChar(SYNTHESIZED_WIRE_5),
    .home(SYNTHESIZED_WIRE_6),
    .char(SYNTHESIZED_WIRE_7)
);
*/

endmodule
