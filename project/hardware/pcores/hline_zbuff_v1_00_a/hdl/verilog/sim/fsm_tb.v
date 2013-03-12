module fsm_tb ();

reg clk, start, reset;
reg zread_empty, axi_done; 
reg [31:0] fb_addr, zbuff_addr, y, z1, z2, zfifo_in, slope, err, rem;
reg [15:0] x1, x2;

wire [31:0] addr, z_out;
wire rd_req, wr_req, read_zfifo, write_zfifo, read_zbuffout_fifo, read_be_fifo;
wire [1:0] byteenable;

initial clk = 0;
always #10 clk = ~clk;

initial
begin
    @ (negedge clk)
    reset = 1;
    @ (negedge clk)
    reset = 0;
    start = 1;
    y = 32'h00001234;
    x1 = 0;
    x2 = 256;
    z1 = 0;
    z2 = 32'hffffffff;
    slope = 32'h00ffffff; //ffffffff / 256
    fb_addr = 32'h00000000;
    zbuff_addr = 32'h10000000;
    zread_empty = 1'b0;
    rem = 32'd255;
    err = 32'd128; // (256 + 1) / 2
    @ (posedge read_zbuffout_fifo)
    // fake an axi signal 
    axi_done = 1;
    @ (negedge clk)
    @ (negedge clk)
    axi_done = 0;
    @ (negedge clk)
    @ (negedge clk)
    axi_done = 1;
    //end transaction
end

fsm fsm_dut (
    .clk (clk),
    .nreset (!reset),
    .start (start),
    .fb_addr (fb_addr),
    .zbuff_addr (zbuff_addr),
    .y (y),
    .x1 (x1),
    .x2 (x2),
    .slope (slope),
    .z1 (z1),
    .z2 (z2),
    .zread_empty (zread_empty),
    .zfifo_in (zfifo_in),
    .rem (rem),
    .err (err),
    .axi_done (axi_done),

    .rd_req (rd_req),
    .wr_req (wr_req),
    .addr (addr),
    .byteenable (byteenable),
    .read_zfifo (read_zfifo),
    .write_zfifo (write_zfifo),
    .z_out (z_out),
    .read_zbuffout_fifo (read_zbuffout_fifo),
    .read_be_fifo (read_be_fifo)
    );

endmodule
