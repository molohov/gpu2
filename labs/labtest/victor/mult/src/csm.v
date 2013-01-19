/* This is a top level module that connects the switches and the 7-segment hex displays
 * to your multiplier. This is the carry save multiplier.
 */

module csm(SW, HEX0, HEX1, HEX2, HEX3);
	input [15:0] SW;
	output [6:0] HEX0;
	output [6:0] HEX1;
	output [6:0] HEX2;
	output [6:0] HEX3;	

	wire [7:0] A;
	wire [7:0] B;
	wire [15:0] result;

	wire [7:0] s0;
	wire [7:0] s1;
	wire [7:0] s2;
	wire [7:0] s3;
	wire [7:0] s4;
	wire [7:0] s5;
	wire [7:0] s6;
	wire [7:0] s7;
	wire [7:0] c0;
	wire [7:0] c1;
	wire [7:0] c2;
	wire [7:0] c3;
	wire [7:0] c4;
	wire [7:0] c5;
	wire [7:0] c6;
	wire [7:0] c7;
	wire [5:0] carry;
	
	/* Connect switches to the multiplier. */
	assign A = SW[7:0];
	assign B = SW[15:8];
	
	/* Your multiplier circuit goes here. */
        carrySave csZero(8'b00000000, 8'b00000000, A, B[0], c0, s0);
        assign result[0] = s0[0];

        carrySave csOne(c0[7:0], {1'b0, s0[7:1]}, A, B[1], c1, s1);
        assign result[1] = s1[0];

        carrySave csTwo(c1[7:0], {1'b0, s1[7:1]}, A, B[2], c2, s2);
        assign result[2] = s2[0];

        carrySave csThree(c2[7:0], {1'b0, s2[7:1]}, A, B[3], c3, s3);
        assign result[3] = s3[0];

        carrySave csFour(c3[7:0], {1'b0, s3[7:1]}, A, B[4], c4, s4);
        assign result[4] = s4[0];

        carrySave csFive(c4[7:0], {1'b0, s4[7:1]}, A, B[5], c5, s5);
        assign result[5] = s5[0];

        carrySave csSix(c5[7:0], {1'b0, s5[7:1]}, A, B[6], c6, s6);
        assign result[6] = s6[0];

        carrySave csSeven(c6[7:0], {1'b0, s6[7:1]}, A, B[7], c7, s7);
        assign result[7] = s7[0];

        ha aZero(c7[0], s7[1], carry[0], result[8]);
        fa aOne(c7[1], s7[2], carry[0], carry[1], result[9]);
        fa aTwo(c7[2], s7[3], carry[1], carry[2], result[10]);
        fa aThree(c7[3], s7[4], carry[2], carry[3], result[11]);
        fa aFour(c7[4], s7[5], carry[3], carry[4], result[12]);
        fa aFive(c7[5], s7[6], carry[4], carry[5], result[13]);
        fa aSix(c7[6], s7[7], carry[5], result[15], result[14]);
	
	/* Multiplication result goes to HEX displays. */
	hex_digits h0(result[3:0], HEX0);
	hex_digits h1(result[7:4], HEX1);
	hex_digits h2(result[11:8], HEX2);
	hex_digits h3(result[15:12], HEX3);
	
endmodule

