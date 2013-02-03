module tb (
	output [7:0] red,
	output [7:0] green,
	output [7:0] blue,
	output hsync,
	output vsync,
        output ve
);

reg clock;
reg reset;
reg start;

initial clock = 0;

always #10 clock = ~clock;

dvi_stimulate dut (
	.clock (clock),
	.reset (reset),
	.start (start),
	.red (red),
	.green (green),
	.blue (blue),
	.hsync (hsync),
	.vsync (vsync),
        .ve (ve)
	);

initial
begin
	@ (negedge clock)
	reset = 1;
	@ (negedge clock)
	reset = 0;
	start = 1;
end

endmodule
