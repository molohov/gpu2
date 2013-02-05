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
initial start = 0;

always #10 clock = ~clock;

hdmi_core dut (
	.clock (clock),
	.reset (reset),
	.start (start),
    .hres (11'd800),
    .vres (10'd600),
    .color (24'h112233),
    .red (red),
    .blue (blue),
    .green (green),
	.hsync (hsync),
	.vsync (vsync),
    .ve (ve)
	);

initial
begin
	@ (negedge clock)
	start = 1;
end

endmodule
