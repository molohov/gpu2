/* This is a mid level module for the carry save multiplier.
 * It computes a whole row of multiplication addition.
 */

module carrySave(carryIn, sumIn, A, B, carryOut, sumOut);

input [7:0] carryIn;
input [7:0] sumIn;
input [7:0] A;
input B;
output [7:0] carryOut;
output [7:0] sumOut;

fa zero (carryIn[0], sumIn[0], A[0] & B, carryOut[0], sumOut[0]);
fa one (carryIn[1], sumIn[1], A[1] & B, carryOut[1], sumOut[1]);
fa two (carryIn[2], sumIn[2], A[2] & B, carryOut[2], sumOut[2]);
fa three (carryIn[3], sumIn[3], A[3] & B, carryOut[3], sumOut[3]);
fa four (carryIn[4], sumIn[4], A[4] & B, carryOut[4], sumOut[4]);
fa five (carryIn[5], sumIn[5], A[5] & B, carryOut[5], sumOut[5]);
fa six (carryIn[6], sumIn[6], A[6] & B, carryOut[6], sumOut[6]);
fa seven (carryIn[7], sumIn[7], A[7] & B, carryOut[7], sumOut[7]);

endmodule

