`timescale 1 ns/1 ps

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

	wire [31:0] pixelout;
	wire        pixelout_valid;


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
	reg [31:0] in;


	initial
		clk <= 0;
	always @ (clk)
		clk <= #10 ~clk;

	initial begin
		reset <= 1'b1;
		inputs_ready <= 1'b0;
		in <= 32'd0;
	@ (negedge clk);
	@ (negedge clk);
		reset <= 1'b0;
	@ (negedge clk);
		inputs_ready <= 1'b1;
		in <= row0_0;
	@ (negedge clk);
		in <= pixelinT_0;
	@ (negedge clk);
		in <= row0_1;
	@ (negedge clk);
		in <= pixelinT_1;
	@ (negedge clk);
		in <= row0_2;
	@ (negedge clk);
		in <= pixelinT_2;
	@ (negedge clk);
		in <= row0_3;
	@ (negedge clk);
		in <= pixelinT_3;
	@ (negedge clk);
		in <= row1_0;
	@ (negedge clk);
		in <= pixelinT_0;
	@ (negedge clk);
		in <= row1_1;
	@ (negedge clk);
		in <= pixelinT_1;
	@ (negedge clk);
		in <= row1_2;
	@ (negedge clk);
		in <= pixelinT_2;
	@ (negedge clk);
		in <= row1_3;
	@ (negedge clk);
		in <= pixelinT_3;
	@ (negedge clk);
		in <= row2_0;
	@ (negedge clk);
		in <= pixelinT_0;
	@ (negedge clk);
		in <= row2_1;
	@ (negedge clk);
		in <= pixelinT_1;
	@ (negedge clk);
		in <= row2_2;
	@ (negedge clk);
		in <= pixelinT_2;
	@ (negedge clk);
		in <= row2_3;
	@ (negedge clk);
		in <= pixelinT_3;
	@ (negedge clk);
		in <= row3_0;
	@ (negedge clk);
		in <= pixelinT_0;
	@ (negedge clk);
		in <= row3_1;
	@ (negedge clk);
		in <= pixelinT_1;
	@ (negedge clk);
		in <= row3_2;
	@ (negedge clk);
		in <= pixelinT_2;
	@ (negedge clk);
		in <= row3_3;
	@ (negedge clk);
		in <= pixelinT_3;
	@ (negedge clk);
		inputs_ready <= 1'b0;
	end

	matrixmult dut(
		.FSL_Clk(clk),
		.FSL_Rst(reset),
		.FSL_S_Clk(1'b0),
		.FSL_S_Read(),
		.FSL_S_Data(in),
		.FSL_S_Control(1'b0),
		.FSL_S_Exists(inputs_ready),
		.FSL_M_Clk(1'b0),
		.FSL_M_Write(pixelout_valid),
		.FSL_M_Data(pixelout),
		.FSL_M_Control(),
		.FSL_M_Full(1'b0)
		);

	always @ (posedge clk)
		if (pixelout_valid)
			$display("Output: %x\n", pixelout);

	/* Expected Results (approximate):
		32'hC0E08E56 = -7.017375
		32'h43BBB7CF = 375.436
		32'h43B80498 = 368.0359
		32'h4082161E = 4.0652;
	*/

	
endmodule
