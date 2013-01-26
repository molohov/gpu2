/* A full adder
 */
module fa(A, B, C, carry, s);

input A, B, C;
output carry, s;

assign s = A ^ B ^ C;
assign carry = A & B | A & C | B & C;

endmodule
