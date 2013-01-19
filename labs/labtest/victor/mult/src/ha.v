/* A half adder
 */
module ha(A, B, carri, s);

input A, B;
output carri, s;

assign carri = A & B;
assign s = A ^ B;

endmodule
