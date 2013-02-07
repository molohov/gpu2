// Assuming the inputs are read from user slave registers, turn a toggle into a one-cycle pulse

module fill_fifo_stimulate (
  input clk,
  input fill_half_fifo_I,
  input hsync_I,
  input vsync_I,
  output reg fill_half_fifo_O,
  output reg hsync_O,
  output reg vsync_O
);

  reg prev_fill_half_fifo;
  reg prev_hsync;
  reg prev_vsync;

  always @(posedge clk)
  begin
    prev_fill_half_fifo <= fill_half_fifo_I;
    prev_hsync <= hsync_I;
    prev_vsync <= vsync_I;
    fill_half_fifo_O <= (fill_half_fifo_I != prev_fill_half_fifo);
    hsync_O <= (hsync_I != prev_hsync);
    vsync_O <= (vsync_I != prev_vsync);
  end

endmodule
