module tb (
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
	.hsync_out (hsync),
	.vsync_out (vsync),
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
