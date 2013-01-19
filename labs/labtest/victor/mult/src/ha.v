/* A half adder
 */
module ha(A, B, carry, s);

input A, B;
output carry, s;

assign carry = A & B;
assign s = A ^ B;

endmodule
