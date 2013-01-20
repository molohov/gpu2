// N-bit shift regsiter
// Shifts bits from right to left or left to right
// Initialize to zero on reset
module shiftreg # (parameter N = 16)
                  (input clk,
                   input enable,
				   input shift_right,
                   input reset,
                   input [N-1:0] in,
                   output reg [N-1:0] q);
                   
  always @ (posedge clk, posedge reset)
    begin
      if (reset)        		q <= 'b0;
	  else if (enable) 			q <= in;
	  else if (shift_right) 	q <= {0, q[N-1:1]};
    end  
	
endmodule


module adder (	input [15:0] in1,
				input [15:0] in2,
				output [16:0] sum);

	assign sum = in1 + in2; //note: not sure how this works with carry --> test it!!!!!

endmodule

// N-bit wide synchronous counter 
module counter #(parameter N = 2) 
                (input              clk, 
                 input              reset, 
                 input              enable, 
                 output reg [N-1:0] count); 
 
  always @(posedge clk, posedge reset) 
    begin 
      if (reset)      count <= 'b0; 
      else if (enable) count <= count +  1;  
    end           
    
endmodule 
