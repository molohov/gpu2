/* A full adder
 */
module fa(A, B, C, carri, s);

input A, B, C;
output carri, s;

assign s = A ^ B ^ C;
assign carri = A & B | A & C | B & C;

endmodule
