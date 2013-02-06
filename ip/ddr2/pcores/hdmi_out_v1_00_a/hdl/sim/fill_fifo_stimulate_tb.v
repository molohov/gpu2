// Assuming the inputs are read from user slave registers, turn a toggle into a one-cycle pulse

module fill_fifo_stimulate_tb (
);

  wire fill_half_fifo_O;
  wire hsync_O, vsync_O;

  reg clk;
  reg fill_half_fifo_I;
  reg hsync_I, vsync_I;

  fill_fifo_stimulate fill_fifo_stimulate_inst(clk, fill_half_fifo_I, hsync_I, vsync_I, fill_half_fifo_O, hsync_O, vsync_O);

  initial clk = 0;

  always #10 clk = ~clk;

  initial
  begin
    @ (negedge clk)
    fill_half_fifo_I = 0;
    hsync_I = 0;
    vsync_I = 0;
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
