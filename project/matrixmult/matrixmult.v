//note: assumes unsigned numbers, if signed need to sign extend


	
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




	matrixmult dut(
			.row0_0(row0_0),
			.row0_1(row0_1),
			.row0_2(row0_2),
			.row0_3(row0_3),

			.row1_0(row1_0),
			.row1_1(row1_1),
			.row1_2(row1_2),
			.row1_3(row1_3),

			.row2_0(row2_0),
			.row2_1(row2_1),
			.row2_2(row2_2),
			.row2_3(row2_3),

			.row3_0(row3_0),
			.row3_1(row3_1),
			.row3_2(row3_2),
			.row3_3(row3_3),

			.pixelinT_0(pixelinT_0),
			.pixelinT_1(pixelinT_1),
			.pixelinT_2(pixelinT_2),
			.pixelinT_3(pixelinT_3),

			.pixelout_0(pixelout_0),
			.pixelout_1(pixelout_1),
			.pixelout_2(pixelout_2),
			.pixelout_3(pixelout_3)

		);

endmodule
	
	
module matrixmult 
(
	input [15:0] row0_0,
	input [15:0] row0_1,
	input [15:0] row0_2,
	input [15:0] row0_3,

	input [15:0] row1_0,
	input [15:0] row1_1,
	input [15:0] row1_2,
	input [15:0] row1_3,
	
	input [15:0] row2_0,
	input [15:0] row2_1,
	input [15:0] row2_2,
	input [15:0] row2_3,
	
	input [15:0] row3_0,
	input [15:0] row3_1,
	input [15:0] row3_2,
	input [15:0] row3_3,

	input [15:0] pixelinT_0, 	//transpose of pixel
	input [15:0] pixelinT_1,
	input [15:0] pixelinT_2,
	input [15:0] pixelinT_3,

	output [31:0] pixelout_0,
	output [31:0] pixelout_1,
	output [31:0] pixelout_2,
	output [31:0] pixelout_3

	
);


assign pixelout_0 = (row0_3 * pixelinT_3) + (row0_2 * pixelinT_2) + (row0_1 * pixelinT_1) + (row0_0 * pixelinT_0);
assign pixelout_1 = (row1_3 * pixelinT_3) + (row1_2 * pixelinT_2) + (row1_1 * pixelinT_1) + (row1_0 * pixelinT_0);
assign pixelout_2 = (row2_3 * pixelinT_3) + (row2_2 * pixelinT_2) + (row2_1 * pixelinT_1) + (row2_0 * pixelinT_0);
assign pixelout_3 = (row3_3 * pixelinT_3) + (row3_2 * pixelinT_2) + (row3_1 * pixelinT_1) + (row3_0 * pixelinT_0);


endmodule
