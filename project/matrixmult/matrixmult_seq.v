//note: assumes unsigned numbers, if signed need to sign extend

//divide matrix multiplication into multiplication and sum modules
//multiplication can be fixed point for now, later floating point using IP
//
//multiplication part (fixed point for now):
//make inputs and outputs 32 bits but strip away upper bits of input
//and only use 16 lower bits of inputs for multiplication
//
//for matrix part (addition): 
//input to module are products
//buffer inputs and accumulate sum of products
//signal row_ready when have added 4 products (for 4x4 times 4x1 case)
//signal done when all four rows computed (keep all rows latched until get new start signal)
//
//Signals for matrix part:
//INPUTS--
//start_new: assert when want to clear outputs and start new matrix mult
//[31:0] data_in1:
//[31:0] data_in2:
//[31:0] data_in3:
//[31:0] data_in4:
//last_for_row: last product to add (when finish this addition, done_row)
//have internal counter (to 4) which increments every last_for_row and then decides when you
//are done whole matrix
//whenever data_in toggles, add it to current running sum ??? 
//how to do you keep track of which row you are at??   --> should this module be in charge of that
//internally or should it be control input coming from microblaze, for ex??
//OUTPUTS:
//[31:0] row0_out, [31:0] row1_out, [31:0] row2_out, [31:0] row3_out
//done_row: done one coordinate of pixel (one row)
//done_matrixmult: done all rows (completed matrix multiplication)
//
//

	
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
