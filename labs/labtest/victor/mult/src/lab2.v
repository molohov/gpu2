/* This is a top level module that connects the switches and the 7-segment hex displays
 * to your multiplier.
 */
module lab2(SW, HEX0, HEX1, HEX2, HEX3);
	input [15:0] SW;
	output [6:0] HEX0;
	output [6:0] HEX1;
	output [6:0] HEX2;
	output [6:0] HEX3;	

	wire [7:0] A;
	wire [7:0] B;
	wire [15:0] result;
	wire [15:0] s0;
	wire [15:0] s1;
	wire [15:0] s2;
	wire [15:0] s3;
	wire [15:0] s4;
	wire [15:0] s5;
	wire [15:0] s6;
	wire [15:0] s7;
	
	/* Connect switches to the multiplier. */
	assign A = SW[7:0];
	assign B = SW[15:8];
	
	/* Your multiplier circuit goes here. */
	boothRow br0(B[0], 1'b0, 16'b0000000000000000, A, s0);
	assign result[0] = s0[0];

	boothRow br1(B[1], B[0], {1'b0, s0[15:1]}, A, s1);
	assign result[1] = s1[0];

	boothRow br2(B[2], B[1], {2'b00, s1[14:1]}, A, s2);
	assign result[2] = s2[0];

	boothRow br3(B[3], B[2], {3'b000, s2[13:1]}, A, s3);
	assign result[3] = s3[0];

	boothRow br4(B[4], B[3], {4'b0000, s3[12:1]}, A, s4);
	assign result[4] = s4[0];

	boothRow br5(B[5], B[4], {5'b00000, s4[11:1]}, A, s5);
	assign result[5] = s5[0];

	boothRow br6(B[6], B[5], {6'b000000, s5[10:1]}, A, s6);
	assign result[6] = s6[0];

	boothRow br7(B[7], B[6], {7'b0000000, s6[9:1]}, A, s7);
	assign result[7] = s7[0];
	assign result[8] = s7[1];
	assign result[9] = s7[2];
	assign result[10] = s7[3];
	assign result[11] = s7[4];
	assign result[12] = s7[5];
	assign result[13] = s7[6];
	assign result[14] = s7[7];
	assign result[15] = s7[8];

	/* Multiplication result goes to HEX displays. */
	hex_digits h0(result[3:0], HEX0);
	hex_digits h1(result[7:4], HEX1);
	hex_digits h2(result[11:8], HEX2);
	hex_digits h3(result[15:12], HEX3);
	
endmodule

