`include "counter.v"


module test;
	initial begin
		//$dumpfile("counter_tb.vcd");
		$dumpvars(0, test);
	end
	
	/* Make a reset that pulses once. */
	reg reset = 0;
	initial begin
		# 17 reset = 1;
		# 11 reset = 0;
		# 29 reset = 1;
		# 11 reset = 0;
		//# 100 $stop;
		#100 $finish;
	end

	/* Make a regular pulsing clock */
	reg clk = 0;
	always #5 clk = !clk;

	wire [7:0] value;
	counter c1 (value, clk, reset);

	initial begin
		$monitor("At time %t, value = %h (%0d)", $time, value, value);
	end

endmodule // test
