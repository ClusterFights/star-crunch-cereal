module spi_slave_buffer
(
    input wire reset,
    input wire clk,
    input wire mosi,
    output reg miso,
    input wire sel,
    output reg [7:0] buffer
);


always @ (posedge clk or posedge reset)
begin
    if (reset)
    begin
        buffer  <= 8'h00;
        miso    <= 1'b0;
    end
    else if (sel)
    begin
        buffer          <= buffer << 1;
        buffer[0]       <= mosi;
        miso            <= 1'b1;
    end
end

endmodule
