// Assuming the inputs are read from user slave registers, turn a toggle into a one-cycle pulse

module fill_fifo_stimulate_tb (
);

  //wire fill_half_fifo_O;
  //wire hsync_O, vsync_O;
  parameter FRAME_BASE_ADDR = ??;
  parameter LINE_STRIDE = ??;
  parameter NUM_PIXELS_PER_LINE = ??;
  parameter NUM_BYTES_PER_PIXEL = ??;
  
  wire [31:0] ddr_addr_to_read;
  wire go_fill_fifo;
  
  
  reg clk, reset, start;
  reg fill_half_fifo_I; //hmm Victor, what was this signal intended for?
  reg hsync_I, vsync_I;

  //fill_fifo_stimulate fill_fifo_stimulate_inst(clk, fill_half_fifo_I, hsync_I, vsync_I, fill_half_fifo_O, hsync_O, vsync_O);

  fill_fifo_fsm fill_fifo_stimulate(clk, reset, start, hsync_I, vsync_I, 
									FRAME_BASE_ADDR, LINE_STRIDE, NUM_PIXELS_PER_LINE, NUM_BYTES_PER_LINE, 
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
    @ (negedge clk)
    fill_half_fifo_I = ~fill_half_fifo_I;
    @ (negedge clk) ;
    @ (negedge clk)
    hsync_I = ~hsync_I;
    @ (negedge clk) ;
    @ (negedge clk)
    vsync_I = ~vsync_I;
    @ (negedge clk) ;
    @ (negedge clk)
    fill_half_fifo_I = ~fill_half_fifo_I;
    @ (negedge clk) ;
    @ (negedge clk)
    hsync_I = ~hsync_I;
    @ (negedge clk) ;
    @ (negedge clk)
    vsync_I = ~vsync_I;
    @ (negedge clk) ;
  end

endmodule
