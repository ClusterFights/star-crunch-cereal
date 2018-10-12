module Counter
(
	input		wire 			wClk,
	input		wire			wRst,
	output	reg	[7:0]	rOutCount
);

// Counter register that counts up to pCompareVal and whose width is dynamically adjustable
//reg rCounter[$bits(pCompareVal) - 1 : 0] = 0;
reg [31:0] rCounter = 32'b0;

always @(posedge (wClk) or posedge(wRst)) begin
	if (wRst)
	begin
		rCounter 	<= 0;
		rOutCount	<= 8'b11111111;
	end
	else
	begin
		//if (rCounter[31:0] & 32'b11110000111100001111000011110000) //not sure what this means, it will never count with this if statement
		//begin
			rOutCount <= rOutCount + 1;
		//end
	end
end

endmodule



module counter_tb;

	reg wClk, wRst;
	wire [7:0] rOutCount;
	
	parameter delay = 5;
	
Counter DUT(wClk, wRst, rOutCount);

initial
begin

wClk = 0; wRst = 0;
#50 wRst = 1;
#delay wRst = 0;
#200;
end

always
begin
#delay wClk = 1;
#delay wClk = 0;
#delay wClk = 1;
#delay wClk = 0;
#delay wClk = 1;
#delay wClk = 0;
#delay wClk = 1;
#delay wClk = 0;
#delay wClk = 1;
#delay wClk = 0;
#delay wClk = 1;
#delay wClk = 0;
#delay wClk = 1;
#delay wClk = 0;
#delay wClk = 1;
#delay wClk = 0;
#delay wClk = 1;
#delay wClk = 0;
#delay wClk = 1;
#delay wClk = 0;
#delay wClk = 1;
#delay wClk = 0;
#delay wClk = 1;
#delay wClk = 0;

end
 
	
endmodule
