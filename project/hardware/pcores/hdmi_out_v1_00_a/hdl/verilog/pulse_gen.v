// Assuming the inputs are read from user slave registers, generate pulses on a toggle, posedge, or negedge

module pulse_gen (
  clk,
  sig_I,
  toggle_O,
  posedge_O,
  negedge_O
);

  parameter NUM = 1;

  input                clk;
  input      [NUM-1:0] sig_I;
  output reg [NUM-1:0] toggle_O;
  output reg [NUM-1:0] posedge_O;
  output reg [NUM-1:0] negedge_O;

  reg [NUM-1:0] prev;

  always @(posedge clk)
  begin
    prev <= sig_I;
    toggle_O <= prev ^ sig_I;
    posedge_O <= ~prev & sig_I;
    negedge_O <= prev & ~sig_I;
  end

endmodule
