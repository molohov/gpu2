module hdmi_core_tb (
	output hsync,
	output vsync,
    output ve,
    output read_go,
    output read_line,
    output read_chunk,
    output read_done,
    output read_fifo,
    output [7:0] red,
    output [7:0] green, 
    output [7:0] blue 
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
    .color (32'hF102A39E), //when concatenated with 0's, should see alternating |F0|20|10| and |A0|70|F0|
    .num_bytes_per_pixel(1'b0),
    .red (red),
    .green (green),
    .blue (blue),
    .hsync (hsync),
    .vsync (vsync),
    .ve (ve),
    .read_fifo(read_fifo),
    .read_go(read_go),
    .read_next_line(read_line),
    .read_next_chunk(read_chunk),
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
