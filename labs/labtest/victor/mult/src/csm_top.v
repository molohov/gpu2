/* This is a top level module that connects the switches and the 7-segment hex displays
 * to your multiplier. This is the carry save multiplier.
 */

module csm_top(mer, mand, product, reset, clk, go, done);
	input [15:0] mer;
	input [15:0] mand;
	output [31:0] product;

	input clk;
	input reset;

	input go;
	output reg done;

	wire [15:0] s0;
	wire [15:0] s1;
	wire [15:0] s2;
	wire [15:0] s3;
	wire [15:0] s4;
	wire [15:0] s5;
	wire [15:0] s6;
	wire [15:0] s7;
	wire [15:0] s8;
	wire [15:0] s9;
	wire [15:0] s10;
	wire [15:0] s11;
	wire [15:0] s12;
	wire [15:0] s13;
	wire [15:0] s14;
	wire [15:0] s15;
	wire [15:0] c0;
	wire [15:0] c1;
	wire [15:0] c2;
	wire [15:0] c3;
	wire [15:0] c4;
	wire [15:0] c5;
	wire [15:0] c6;
	wire [15:0] c7;
	wire [15:0] c8;
	wire [15:0] c9;
	wire [15:0] c10;
	wire [15:0] c11;
	wire [15:0] c12;
	wire [15:0] c13;
	wire [15:0] c14;
	wire [15:0] c15;
	wire [13:0] carry;

	always@(posedge clk)
	        done = go;

	
	/* Your multiplier circuit goes here. */
        carrySave cs0(16'h0000, 16'h0000, mer, mand[0], c0, s0);
        assign product[0] = s0[0];

        carrySave cs1(c0, {1'b0, s0[15:1]}, mer, mand[1], c1, s1);
        assign product[1] = s1[0];

        carrySave cs2(c1, {1'b0, s1[15:1]}, mer, mand[2], c2, s2);
        assign product[2] = s2[0];

        carrySave cs3(c2, {1'b0, s2[15:1]}, mer, mand[3], c3, s3);
        assign product[3] = s3[0];

        carrySave cs4(c3, {1'b0, s3[15:1]}, mer, mand[4], c4, s4);
        assign product[4] = s4[0];

        carrySave cs5(c4, {1'b0, s4[15:1]}, mer, mand[5], c5, s5);
        assign product[5] = s5[0];

        carrySave cs6(c5, {1'b0, s5[15:1]}, mer, mand[6], c6, s6);
        assign product[6] = s6[0];

        carrySave cs7(c6, {1'b0, s6[15:1]}, mer, mand[7], c7, s7);
        assign product[7] = s7[0];

        carrySave cs8(c7, {1'b0, s7[15:1]}, mer, mand[7], c8, s8);
        assign product[8] = s8[0];

        carrySave cs9(c8, {1'b0, s8[15:1]}, mer, mand[7], c9, s9);
        assign product[9] = s9[0];

        carrySave cs10(c9, {1'b0, s9[15:1]}, mer, mand[7], c10, s10);
        assign product[10] = s10[0];

        carrySave cs11(c10, {1'b0, s10[15:1]}, mer, mand[7], c11, s11);
        assign product[11] = s11[0];

        carrySave cs12(c11, {1'b0, s11[15:1]}, mer, mand[7], c12, s12);
        assign product[12] = s12[0];

        carrySave cs13(c12, {1'b0, s12[15:1]}, mer, mand[7], c13, s13);
        assign product[13] = s13[0];

        carrySave cs14(c13, {1'b0, s13[15:1]}, mer, mand[7], c14, s14);
        assign product[14] = s14[0];

        carrySave cs15(c14, {1'b0, s14[15:1]}, mer, mand[7], c15, s15);
        assign product[15] = s15[0];

        ha a0(c15[0], s15[1], carry[0], product[16]);
        fa a1(c15[1], s15[2], carry[0], carry[1], product[17]);
        fa a2(c15[2], s15[3], carry[1], carry[2], product[18]);
        fa a3(c15[3], s15[4], carry[2], carry[3], product[19]);
        fa a4(c15[4], s15[5], carry[3], carry[4], product[20]);
        fa a5(c15[5], s15[6], carry[4], carry[5], product[21]);
        fa a6(c15[6], s15[7], carry[5], carry[6], product[22]);
        fa a7(c15[7], s15[8], carry[6], carry[7], product[23]);
        fa a8(c15[8], s15[9], carry[7], carry[8], product[24]);
        fa a9(c15[9], s15[10], carry[8], carry[9], product[25]);
        fa aa(c15[10], s15[11], carry[9], carry[10], product[26]);
        fa ab(c15[11], s15[12], carry[10], carry[11], product[27]);
        fa ac(c15[12], s15[13], carry[11], carry[12], product[28]);
        fa ad(c15[13], s15[14], carry[12], carry[13], product[29]);
        fa ae(c15[14], s15[15], carry[13], product[31], product[30]);
	
endmodule

