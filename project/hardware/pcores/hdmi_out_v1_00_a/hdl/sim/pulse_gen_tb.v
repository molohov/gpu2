module pulse_gen_tb (
);

  parameter NUM = 3;

  reg            clk;
  reg  [NUM-1:0] in;

  wire [NUM-1:0] toggle_O;
  wire [NUM-1:0] posedge_O;
  wire [NUM-1:0] negedge_O;

  pulse_gen #(3) pulse_gen_inst (clk, in, toggle_O, posedge_O, negedge_O);
  
  initial clk = 0;

  always #10 clk = ~clk;

  initial
  begin
    @ (negedge clk)
    in = {NUM{1'b0}};
    @ (negedge clk)
    in[0] = 1'b1;
    @ (negedge clk) ;
    @ (negedge clk)
    in[1] = 1'b1;
    @ (negedge clk) ;
    @ (negedge clk)
    in[2] = 1'b1;
    @ (negedge clk) ;
    @ (negedge clk)
    in[2] = 1'b0;
    @ (negedge clk) ;
    @ (negedge clk)
    in[1] = 1'b0;
    @ (negedge clk) ;
    @ (negedge clk)
    in[0] = 1'b0;
    @ (negedge clk) ;
  end

endmodule
