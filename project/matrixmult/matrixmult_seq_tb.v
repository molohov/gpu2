module matrixmult_tb();

   	wire [15:0] row0_0;
	wire [15:0] row0_1;
	wire [15:0] row0_2;
	wire [15:0] row0_3;

	wire [15:0] row1_0;
	wire [15:0] row1_1;
	wire [15:0] row1_2;
	wire [15:0] row1_3;

	wire [15:0] row2_0;
	wire [15:0] row2_1;
	wire [15:0] row2_2;
	wire [15:0] row2_3;

	wire [15:0] row3_0;
	wire [15:0] row3_1;
	wire [15:0] row3_2;
	wire [15:0] row3_3;

	wire [15:0] pixelinT_0; 	//transpose of pixel
	wire [15:0] pixelinT_1;
	wire [15:0] pixelinT_2;
	wire [15:0] pixelinT_3;

	wire [31:0] pixelout_0;
	wire [31:0] pixelout_1;
	wire [31:0] pixelout_2;
	wire [31:0] pixelout_3;



   	assign row0_0 = 16'd1;
	assign row0_1 = 16'd1;
	assign row0_2 = 16'd2;
	assign row0_3 = 16'd3;

	assign row1_0 = 16'd5;
	assign row1_1 = 16'd6;
	assign row1_2 = 16'd7;
	assign row1_3 = 16'd3;

	assign row2_0 = 16'd1;
	assign row2_1 = 16'd2;
	assign row2_2 = 16'd3;
	assign row2_3 = 16'd2;

	assign row3_0 = 16'd4;
	assign row3_1 = 16'd5;
	assign row3_2 = 16'd3;
	assign row3_3 = 16'd5;

	assign pixelinT_0 = 16'd2; 	//transpose of pixel
	assign pixelinT_1 = 16'd5;
	assign pixelinT_2 = 16'd3;
	assign pixelinT_3 = 16'd1;


	reg clk, reset, inputs_ready; 
	wire done;
	reg [31:0] in1;
	reg [31:0] in2;
	wire [31:0] result0;
	wire [31:0] result1;
	wire [31:0] result2;
	wire [31:0] result3;



	initial
		clk <= 0;
	always @ (clk)
		clk <= #10 ~clk;

	initial begin
		reset <= 1'b1;
	@ (negedge clk);
		in1 <= row0_0;
		in2 <= pixelinT_0;
	@ (negedge clk);
		reset <= 1'b0;
		inputs_ready <= 1'b1;
	
	@ (negedge clk);
		inputs_ready <= 1'b0;
		in1 <= row0_1;
		in2 <= pixelinT_1;
	@ (negedge clk);
		inputs_ready <=1'b1;
	
	@ (negedge clk);
		inputs_ready <= 1'b0;
		in1 <= row0_2;
		in2 <= pixelinT_2;
	@ (negedge clk);
		inputs_ready <=1'b1;

	@ (negedge clk);
		inputs_ready <= 1'b0;
		in1 <= row0_3;
		in2 <= pixelinT_3;
	@ (negedge clk);
		inputs_ready <=1'b1;

	//should be done first element now
	//$display("should be done row0 now");

	@ (negedge clk);
		inputs_ready <= 1'b0;
		in1 <= row1_0;
		in2 <= pixelinT_0;
	@ (negedge clk);
		inputs_ready <=1'b1;
	
	@ (negedge clk);
		inputs_ready <= 1'b0;
		in1 <= row1_1;
		in2 <= pixelinT_1;
	@ (negedge clk);
		inputs_ready <=1'b1;
	
	@ (negedge clk);
		inputs_ready <= 1'b0;
		in1 <= row1_2;
		in2 <= pixelinT_2;
	@ (negedge clk);
		inputs_ready <=1'b1;

	@ (negedge clk);
		inputs_ready <= 1'b0;
		in1 <= row1_3;
		in2 <= pixelinT_3;
	@ (negedge clk);
		inputs_ready <=1'b1;

	//should be done first element now
	//$display("should be done row0 now");

	@ (negedge clk);
		inputs_ready <= 1'b0;
		in1 <= row2_0;
		in2 <= pixelinT_0;
	@ (negedge clk);
		inputs_ready <=1'b1;
	
	@ (negedge clk);
		inputs_ready <= 1'b0;
		in1 <= row2_1;
		in2 <= pixelinT_1;
	@ (negedge clk);
		inputs_ready <=1'b1;
	
	@ (negedge clk);
		inputs_ready <= 1'b0;
		in1 <= row2_2;
		in2 <= pixelinT_2;
	@ (negedge clk);
		inputs_ready <=1'b1;

	@ (negedge clk);
		inputs_ready <= 1'b0;
		in1 <= row2_3;
		in2 <= pixelinT_3;
	@ (negedge clk);
		inputs_ready <=1'b1;

	//should be done first element now
	//$display("should be done row0 now");

	@ (negedge clk);
		inputs_ready <= 1'b0;
		in1 <= row3_0;
		in2 <= pixelinT_0;
	@ (negedge clk);
		inputs_ready <=1'b1;
	
	@ (negedge clk);
		inputs_ready <= 1'b0;
		in1 <= row3_1;
		in2 <= pixelinT_1;
	@ (negedge clk);
		inputs_ready <=1'b1;
	
	@ (negedge clk);
		inputs_ready <= 1'b0;
		in1 <= row3_2;
		in2 <= pixelinT_2;
	@ (negedge clk);
		inputs_ready <=1'b1;

	@ (negedge clk);
		inputs_ready <= 1'b0;
		in1 <= row3_3;
		in2 <= pixelinT_3;
	@ (negedge clk);
		inputs_ready <=1'b1;
	


	end

	matrixmultiplier dut(
		.clk(clk),
		.reset(reset),
		.in1(in1),
		.in2(in2),
		.inputs_to_multiply_ready(inputs_ready),
		.result0(result0),
		.result1(result1),
		.result2(result2),
		.result3(result3),
		.done_matrixmult(done)
		);


	
endmodule
