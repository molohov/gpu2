/* This is a mid level module for the carry save multiplier.
 * It computes a whole row of multiplication addition.
 */

module carriSave(carriIn, sumIn, A, B, carriOut, sumOut);

input [7:0] carriIn;
input [7:0] sumIn;
input [7:0] A;
input B;
output [7:0] carriOut;
output [7:0] sumOut;

fa zero (carriIn[0], sumIn[0], A[0] & B, carriOut[0], sumOut[0]);
fa one (carriIn[1], sumIn[1], A[1] & B, carriOut[1], sumOut[1]);
fa two (carriIn[2], sumIn[2], A[2] & B, carriOut[2], sumOut[2]);
fa three (carriIn[3], sumIn[3], A[3] & B, carriOut[3], sumOut[3]);
fa four (carriIn[4], sumIn[4], A[4] & B, carriOut[4], sumOut[4]);
fa five (carriIn[5], sumIn[5], A[5] & B, carriOut[5], sumOut[5]);
fa six (carriIn[6], sumIn[6], A[6] & B, carriOut[6], sumOut[6]);
fa seven (carriIn[7], sumIn[7], A[7] & B, carriOut[7], sumOut[7]);

endmodule

