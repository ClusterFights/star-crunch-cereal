module Counter
(
	input		wire 			wClk,
	input		wire			wRst,
	output	reg	[7:0]	rOutCount
);

// Counter register that counts up to pCompareVal and whose width is dynamically adjustable
//reg rCounter[$bits(pCompareVal) - 1 : 0] = 0;
reg [31:0] rCounter = 32'b0;

always @(posedge (wClk), posedge(wRst)) begin
	if (wRst == 1'b1)
	begin
		rCounter[31:0] <= 32'b0;
		rOutCount[7:0]	<= 8'b11111111;
	end
	else
	begin
		if (rCounter[31:0] & 32'b11110000111100001111000011110000)
		begin
			rOutCount[7:0] <= rOutCount[7:0] + 1;
		end
	end
end

endmodule