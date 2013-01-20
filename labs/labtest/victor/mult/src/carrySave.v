/* This is a mid level module for the carry save multiplier.
 * It computes a whole row of multiplication addition.
 */

module carrySave(carryIn, sumIn, A, B, carryOut, sumOut);

input [15:0] carryIn;
input [15:0] sumIn;
input [15:0] A;
input B;
output [15:0] carryOut;
output [15:0] sumOut;

fa f0 (carryIn[0], sumIn[0], A[0] & B, carryOut[0], sumOut[0]);
fa f1 (carryIn[1], sumIn[1], A[1] & B, carryOut[1], sumOut[1]);
fa f2 (carryIn[2], sumIn[2], A[2] & B, carryOut[2], sumOut[2]);
fa f3 (carryIn[3], sumIn[3], A[3] & B, carryOut[3], sumOut[3]);
fa f4 (carryIn[4], sumIn[4], A[4] & B, carryOut[4], sumOut[4]);
fa f5 (carryIn[5], sumIn[5], A[5] & B, carryOut[5], sumOut[5]);
fa f6 (carryIn[6], sumIn[6], A[6] & B, carryOut[6], sumOut[6]);
fa f7 (carryIn[7], sumIn[7], A[7] & B, carryOut[7], sumOut[7]);
fa f8 (carryIn[8], sumIn[8], A[8] & B, carryOut[8], sumOut[8]);
fa f9 (carryIn[9], sumIn[9], A[9] & B, carryOut[9], sumOut[9]);
fa f10 (carryIn[10], sumIn[10], A[10] & B, carryOut[10], sumOut[10]);
fa f11 (carryIn[11], sumIn[11], A[11] & B, carryOut[11], sumOut[11]);
fa f12 (carryIn[12], sumIn[12], A[12] & B, carryOut[12], sumOut[12]);
fa f13 (carryIn[13], sumIn[13], A[13] & B, carryOut[13], sumOut[13]);
fa f14 (carryIn[14], sumIn[14], A[14] & B, carryOut[14], sumOut[14]);
fa f15 (carryIn[15], sumIn[15], A[15] & B, carryOut[15], sumOut[15]);

endmodule

