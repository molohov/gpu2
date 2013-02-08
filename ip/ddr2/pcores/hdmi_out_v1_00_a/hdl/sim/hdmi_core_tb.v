module hdmi_core_tb (
	output hsync,
	output vsync,
        output ve,
        output read_go,
        output read_line,
        output read_done
);

reg clock;
reg reset;
reg start;

initial clock = 0;

always #10 clock = ~clock;

hdmi_core dut (
	.clock (clock),
	.reset (reset),
	.start (start),
        .hres (11'd1280),
        .vres (10'd720),
        .color (24'hffffff),
        .red (),
        .green (),
        .blue (),
	.hsync (hsync),
	.vsync (vsync),
        .ve (ve),
        .read_go(read_go),
        .read_next_line(read_line),
        .read_done(read_done)
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
