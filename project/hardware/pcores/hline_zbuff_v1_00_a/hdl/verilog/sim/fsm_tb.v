module fsm_tb ();

reg clk, start, reset;
reg axi_done; 
reg [31:0] fb_addr, zbuff_addr, z1, z_fifo_in, f_fifo_in, slope, err, rem, dx, rgbx;

wire [31:0] addr, z_out, f_out, z_sum_out;
wire rd_req, wr_req, done, axi_bus_to_z_fifo, axi_bus_to_f_fifo, read_in_fifos, write_out_fifos, read_z_out_fifo, read_f_out_fifo; 
wire [3:0] curr_state;

initial clk = 0;
always #10 clk = ~clk;

initial
begin
    @ (negedge clk)
    reset = 1;
    @ (negedge clk)
    reset = 0;
    start = 1;
    dx = 256;
    z1 = 0;
    slope = 32'h00ffffff; //ffffffff / 256
    fb_addr = 32'h00000000;
    zbuff_addr = 32'h10000000;
    rem = 32'd255;
    err = 32'd128; // (256 + 1) / 2
    z_fifo_in = 32'h7fffffff; // this is -1 / 2, which means that first half of interpolated z is the only part that is replaced
    f_fifo_in = 32'hBEADEDAB;
    rgbx = 32'hDEADBEEF;
    // first read request (zbuff)
    @ (posedge rd_req)
    // fake an axi signal 
    axi_done = 1;
    # 1280;
    @ (negedge clk)
    axi_done = 0;
    @ (negedge clk)
    // second read request (fbuff)
    @ (negedge clk)
    axi_done = 1;
    # 1280;
    @ (negedge clk)
    axi_done = 0;
    // first write request (zbuff) 
    @ (posedge wr_req)
    axi_done = 1;
    @ (negedge clk)
    @ (negedge clk)
    axi_done = 0;
    @ (negedge clk)
    // second write request (fbuff)
    @ (negedge clk)
    axi_done = 1;
    @ (negedge clk)
    @ (negedge clk)
    axi_done = 0;
    //end transaction
    @ (negedge clk)
    reset = 1;
    @ (negedge clk)
    reset = 0;
    start = 1;
    dx = 512;
    z1 = 0;
    slope = 32'h007fffff; //ffffffff / 256
    fb_addr = 32'h00000000;
    zbuff_addr = 32'h10000000;
    rem = 32'd511;
    err = 32'd256; // (512 + 1) / 2
    z_fifo_in = 32'h7fffffff; // this is -1 / 2, which means that first half of interpolated z is the only part that is replaced
    f_fifo_in = 32'hBEADEDAB;
    rgbx = 32'hDEADBEEF;
    // first read request (zbuff)
    @ (posedge rd_req)
    // fake an axi signal 
    axi_done = 1;
    # 1280;
    @ (negedge clk)
    axi_done = 0;
    @ (negedge clk)
    // second read request (fbuff)
    @ (negedge clk)
    axi_done = 1;
    # 1280;
    @ (negedge clk)
    axi_done = 0;
    // first write request (zbuff) 
    @ (posedge wr_req)
    axi_done = 1;
    @ (negedge clk)
    @ (negedge clk)
    axi_done = 0;
    @ (negedge clk)
    // second write request (fbuff)
    @ (negedge clk)
    axi_done = 1;
    @ (negedge clk)
    axi_done = 0;
    // first read request (zbuff)
    @ (posedge rd_req)
    // fake an axi signal 
    axi_done = 1;
    # 1280;
    @ (negedge clk)
    axi_done = 0;
    @ (negedge clk)
    // second read request (fbuff)
    @ (negedge clk)
    axi_done = 1;
    # 1280;
    @ (negedge clk)
    axi_done = 0;
    // first write request (zbuff) 
    @ (posedge wr_req)
    axi_done = 1;
    @ (negedge clk)
    @ (negedge clk)
    axi_done = 0;
    @ (negedge clk)
    // second write request (fbuff)
    @ (negedge clk)
    axi_done = 1;
    @ (negedge clk)
    @ (negedge clk)
    axi_done = 0;
    //end transaction
end

fsm fsm_dut (
    .clk (clk),
    .nreset (!reset),
    .start (start),
    .fb_addr (fb_addr),
    .zbuff_addr (zbuff_addr),
    .dx (dx),
    .slope (slope),
    .z1 (z1),
    .rem (rem),
    .err (err),
    .rgbx (rgbx),
    .z_fifo_in (z_fifo_in),
    .f_fifo_in (f_fifo_in),
    .axi_done (axi_done),

    .curr_state (curr_state),
    .start_out (start_out),
    .rd_req (rd_req),
    .wr_req (wr_req),
    .addr (addr),
    .done (done),
    .axi_bus_to_z_fifo (axi_bus_to_z_fifo),
    .axi_bus_to_f_fifo (axi_bus_to_f_fifo),
    .read_in_fifos (read_in_fifos),
    .write_out_fifos (write_out_fifos),
    .read_z_out_fifo (read_z_out_fifo),
    .read_f_out_fifo (read_f_out_fifo),
    .z_out (z_out),
    .f_out (f_out),
    .z_sum_out (z_sum_out)
    );

endmodule
