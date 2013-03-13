`timescale 1 ns / 1 ns

module counter_shift_reg_tb();

	reg clk, reset, inputs_ready; 
	wire shift_reg_done, counter_done;

	//generate input signals
	initial
		clk <= 0;
	always @ (clk)
		clk <= #50 ~clk;

	initial begin
		reset <= 1'b1;
		inputs_ready = 1'b0;
	@ (negedge clk);
	@ (negedge clk);
		reset <= 1'b0;
	@ (negedge clk);
		inputs_ready = 1'b1;
	@ (negedge clk);
	@ (negedge clk);
	@ (negedge clk);
	@ (negedge clk);
	@ (negedge clk);
	@ (negedge clk);
	@ (negedge clk);
	@ (negedge clk);
	@ (negedge clk);
	@ (negedge clk);
	@ (negedge clk);
	@ (negedge clk);
		inputs_ready = 1'b0;
	@ (negedge clk);
	@ (negedge clk);
		inputs_ready = 1'b1;
	@ (negedge clk);
	end

	shift_reg #(.N(11)) sr(
		.clk(clk),
		.reset(reset),
		.in(inputs_ready),
		.out(shift_reg_done)
		);

	counter #(.N(11)) ct(
		.clk(clk),
		.reset(reset),
		.in_ready(inputs_ready),
		.done(counter_done),
		.count()
	);
	
endmodule

