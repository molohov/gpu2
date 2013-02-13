// Assuming the inputs are read from user slave registers, turn a toggle into a one-cycle pulse

module fill_fifo_tb (
);

  parameter FRAME_BASE_ADDR = 32'ha8000000;
  parameter LINE_STRIDE = 32'h00000500;
  parameter NUM_PIXELS_PER_LINE = 32'h00000040;
  parameter NUM_BYTES_PER_PIXEL = 32'h00000004;
  
  wire [31:0] ddr_addr_to_read;
  wire go_fill_fifo;
  
  reg clk, reset, start;
  reg fill_half_fifo_I;
  reg hsync_I, vsync_I;

  fill_fifo_fsm fill_fifo_stimulate(clk, reset, start, hsync_I, vsync_I, fill_half_fifo_I,
									FRAME_BASE_ADDR, LINE_STRIDE, NUM_PIXELS_PER_LINE, NUM_BYTES_PER_PIXEL, 
									ddr_addr_to_read, go_fill_fifo);			
  
  initial clk = 0;

  always #10 clk = ~clk;

  initial
  begin
    @ (negedge clk)
	reset = 1;
	start = 0;
    fill_half_fifo_I = 0;
    hsync_I = 0;
    vsync_I = 0;
    @ (negedge clk) ;
	reset = 0;
	start = 1;
    @ (negedge clk) ;
    @ (negedge clk)
    hsync_I = 1;
    @ (negedge clk)
    hsync_I = 0;
    @ (negedge clk) ;
    @ (negedge clk)
    hsync_I = 1;
    @ (negedge clk)
    hsync_I = 0;
    @ (negedge clk) ;
    @ (negedge clk)
    hsync_I = 1;
    @ (negedge clk)
    hsync_I = 0;
    @ (negedge clk) ;
    @ (negedge clk)
    hsync_I = 1;
    @ (negedge clk)
    hsync_I = 0;
    @ (negedge clk) ;
    @ (negedge clk)
    hsync_I = 1;
    @ (negedge clk)
    hsync_I = 0;
    @ (negedge clk) ;
    @ (negedge clk)
    hsync_I = 1;
    @ (negedge clk)
    hsync_I = 0;
    @ (negedge clk) ;
    @ (negedge clk)
    hsync_I = 1;
    @ (negedge clk)
    hsync_I = 0;
    @ (negedge clk) ;
    @ (negedge clk)
    vsync_I = 1;
    @ (negedge clk)
    vsync_I = 0;
  end

endmodule
