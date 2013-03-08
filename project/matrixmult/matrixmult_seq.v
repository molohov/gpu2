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

//product becomes available one cycle after provide inputs and assert inputs_ready
module multiply (
		input clk,
		input reset,
		input [31:0] in1,
		input [31:0] in2,
		input inputs_ready,
		output reg [31:0] product,
		output reg product_ready
		);

	always @(posedge clk)
	begin
		if (reset || product_ready)	//????????????product ready???????????????->only want it on for one cycle!!! 
			begin
			product <= 32'b0;
			product_ready <= 1'b0;
			end
		else if (inputs_ready) 
			begin
			product <= in1[15:0] * in2[15:0]; //compute product using 16 lower bits of inputs, result is 32 bit
			product_ready <= 1'b1; 
			end
	end
endmodule


//this module computes the running sum of inputs (which are products)
//therefore computes one element of final matrix
//when count reaches N, you know you have completed the number of additions required 
//need to reset to start new element/row computation
module sum_matrixmult_1element(
		input clk,
		input reset,
		input [31:0] in1, 		//this will be a product from multiply module
		input in_ready,			//assert this for one cycle when providing module with fresh input
		output reg [31:0] running_sum,	//this will be the running sum
		output done			//this is asserted when counter reaches N (ie: added all the products for this element of matrix)
		);

	parameter N = 4; 	//number of rows in matrix (number of additions required to generate one element of matrix result)
	parameter log2N = 2;

	reg [log2N:0] count;

	assign done = (count == N) ? 1'b1 : 1'b0;

	always @ (posedge clk)
	begin
		if (reset || done) //done???????????????????????????????????????? --> only want done on for 1 cycle!!!
			begin
				running_sum <= 32'b0;
				count <= 'b0;
			end
		else if (in_ready && !done) //don't keep adding if done
			begin
				running_sum <= running_sum + in1;
				count <= count + 1'b1;
			end
	end
endmodule

//latch matrix result elements and count up to 4 (then you have all elements of result matrix ready)
module latch_matrixmult(
		input clk,
		input reset,
		input [31:0] element_in,
		input new_element,	//need to pulse for one cycle only
		output reg [31:0] element0,
		output reg [31:0] element1,
		output reg [31:0] element2,
		output reg [31:0] element3,
		output reg done_matrix

	);

	reg [2:0] count;

	always @ (posedge clk)
	begin
		if (reset)
			begin 
			element0 <= 32'b0;
			element1 <= 32'b0;
			element2 <= 32'b0;
			element3 <= 32'b0;
			done_matrix <= 1'b0;
			count <= 3'b0;
			end
		else if (new_element && count == 0)	
			begin
			element0 <= element_in;
			count <= count + 1'b1;
			done_matrix <= 1'b0;
			end
		else if (new_element && count == 1)	
			begin
			element1 <= element_in;
			count <= count + 1'b1;
			done_matrix <= 1'b0;
			end
		else if (new_element && count == 2)	
			begin
			element2 <= element_in;
			count <= count + 1'b1;
			done_matrix <= 1'b0;
			end
		else if (new_element && count == 3)	
			begin
			element3 <= element_in;
			count <= count + 1'b1;
			done_matrix <= 1'b1;
			end
	


	end


endmodule

//provide 2 inputs at a time and assert inputs_ready to start, then keep going
module matrixmultiplier (
		input clk,
		input reset,
		input [31:0] in1,
		input [31:0] in2,
		input inputs_to_multiply_ready,
		output [31:0] result0,
		output [31:0] result1,
		output [31:0] result2,
		output [31:0] result3,
		output done_matrixmult
		);


	wire [31:0] product;
	wire product_ready;
	wire [31:0] element;
	wire element_ready;

	multiply mul (.clk(clk),
		.reset(reset),
		.in1(in1),
		.in2(in2),
		.inputs_ready(inputs_to_multiply_ready),
		.product(product),
		.product_ready(product_ready)
		);
	
	sum_matrixmult_1element add(
		.clk(clk),
		.reset(reset),
		.in1(product), 		//this will be a product from multiply module
		.in_ready(product_ready),//assert this for one cycle when providing module with fresh input
		.running_sum(element),	//this will be the running sum
		.done(element_ready)
		);

 	latch_matrixmult latch(
		.clk(clk),
		.reset(reset),
		.element_in(element),
		.new_element(element_ready),	//need to pulse for one cycle only
		.element0(result0),
		.element1(result1),
		.element2(result2),
		.element3(result3),
		.done_matrix(done_matrixmult)
		);

endmodule

////////////////////////////////////////////////////////




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

