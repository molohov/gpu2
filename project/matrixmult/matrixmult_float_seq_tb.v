`timescale 1 ns / 1 ns

module matrixmult_tb();

   	wire [31:0] row0_0;
	wire [31:0] row0_1;
	wire [31:0] row0_2;
	wire [31:0] row0_3;

	wire [31:0] row1_0;
	wire [31:0] row1_1;
	wire [31:0] row1_2;
	wire [31:0] row1_3;

	wire [31:0] row2_0;
	wire [31:0] row2_1;
	wire [31:0] row2_2;
	wire [31:0] row2_3;

	wire [31:0] row3_0;
	wire [31:0] row3_1;
	wire [31:0] row3_2;
	wire [31:0] row3_3;

	wire [31:0] pixelinT_0; 	//transpose of pixel
	wire [31:0] pixelinT_1;
	wire [31:0] pixelinT_2;
	wire [31:0] pixelinT_3;

	wire [31:0] pixelout_0;
	wire [31:0] pixelout_1;
	wire [31:0] pixelout_2;
	wire [31:0] pixelout_3;


   	assign row0_0 = 32'h4124CCCD; //10.3
	assign row0_1 = 32'h40C80000; //6.25
	assign row0_2 = 32'h40A9999A; //5.3000002
	assign row0_3 = 32'h3C4CCCCD; //0.0125

	assign row1_0 = 32'h40600000; //3.5
	assign row1_1 = 32'h40980000; //4.75
	assign row1_2 = 32'h4111999A; //9.1
	assign row1_3 = 32'h43164CCD; //150.3

	assign row2_0 = 32'hBF07AE14; //-0.53
	assign row2_1 = 32'h4141999A; //12.1
	assign row2_2 = 32'hC1691EB8; //-14.57
	assign row2_3 = 32'h4040A3D7; //3.01

	assign row3_0 = 32'h3C4CCCCD; //0.0125
	assign row3_1 = 32'h40A9999A; //5.3000002
	assign row3_2 = 32'h40C80000; //6.25
	assign row3_3 = 32'h4124CCCD; //10.3

	assign pixelinT_0 = 32'hBF07AE14; //-0.53
	assign pixelinT_1 = 32'h4141999A; //12.1
	assign pixelinT_2 = 32'hC1691EB8; //-14.57
	assign pixelinT_3 = 32'h4040A3D7; //3.01


	reg clk, reset, inputs_ready; 
	wire done;
	reg [31:0] in1;
	reg [31:0] in2;
	wire [31:0] result0;
	wire [31:0] result1;
	wire [31:0] result2;
	wire [31:0] result3;

	wire [31:0] expected_result0;
	wire [31:0] expected_result1;
	wire [31:0] expected_result2;
	wire [31:0] expected_result3;

	assign expected_result0 = 32'hC0E08E56; //-7.017375
	assign expected_result1 = 32'h43BBB7CF; //375.436
	assign expected_result2 = 32'h43B80498; //368.0359
	assign expected_result3 = 32'h4082161E; //4.0652;

	//generate input signals
	initial
		clk <= 0;
	always @ (clk)
		clk <= #50 ~clk;

	initial begin
		reset <= 1'b1;
	@ (negedge clk);
		in1 <= row0_0;
		in2 <= pixelinT_0;
	@ (negedge clk);
		reset <= 1'b0;
		inputs_ready <= 1'b1;
	
	@ (negedge clk);
	@ (negedge clk);
		in1 <= row0_1;
		in2 <= pixelinT_1;
	
	@ (negedge clk);
		in1 <= row0_2;
		in2 <= pixelinT_2;

	@ (negedge clk);
		in1 <= row0_3;
		in2 <= pixelinT_3;

	//should be done first element now
	//$display("should be done row0 now");

	@ (negedge clk);
		in1 <= row1_0;
		in2 <= pixelinT_0;
	
	@ (negedge clk);
		in1 <= row1_1;
		in2 <= pixelinT_1;
	
	@ (negedge clk);
		in1 <= row1_2;
		in2 <= pixelinT_2;

	@ (negedge clk);
		in1 <= row1_3;
		in2 <= pixelinT_3;

	//should be done first element now
	//$display("should be done row0 now");

	@ (negedge clk);
		in1 <= row2_0;
		in2 <= pixelinT_0;
	
	@ (negedge clk);
		in1 <= row2_1;
		in2 <= pixelinT_1;
	
	@ (negedge clk);
		in1 <= row2_2;
		in2 <= pixelinT_2;

	@ (negedge clk);
		in1 <= row2_3;
		in2 <= pixelinT_3;

	//should be done first element now
	//$display("should be done row0 now");

	@ (negedge clk);
		in1 <= row3_0;
		in2 <= pixelinT_0;
	
	@ (negedge clk);
		in1 <= row3_1;
		in2 <= pixelinT_1;
	
	@ (negedge clk);
		in1 <= row3_2;
		in2 <= pixelinT_2;

	@ (negedge clk);
		in1 <= row3_3;
		in2 <= pixelinT_3;
		


	end
	
	matrixmultiplier dut(
		.clk(clk),
		.reset(reset),
		.a(in1),
		.b(in2),
		.a_tvalid(inputs_ready),
		.b_tvalid(inputs_ready),
		.result0(result0),
		.result1(result1),
		.result2(result2),
		.result3(result3),
		.done_matrixmult(done)
		);


	
endmodule

