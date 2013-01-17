
module fibonacci 
  (
   // inputs
   clk,
   reset,
   
   // outputs
   fibonacci_out
   );
   
   //inputs
   input clk;
   input reset;
   
   // outputs
   output [15:0] fibonacci_out;

   // wires and registers
   reg [15:00]   reg1, reg2;
   wire [15:00]         temp;
   reg [01:00]   slowdown;
   wire           change;
   
   always @(posedge clk or negedge reset)
     begin
        if (reset == 1'b0) begin
           slowdown <= 1;
           reg1 <= 16'h0001;
           reg2 <= 16'h0001;
        end
        else begin
           slowdown <= slowdown+1;
           if (change == 1'b1) begin
              reg2 <= reg1;
              reg1 <= temp;
           end
        end // else: !if(reset == 1'b0)
     end // always @ (posedge clk or negedge reset)

   assign temp = reg1 + reg2;
   assign change = (slowdown == 2'b00);

   assign fibonacci_out = reg2;
   
   
endmodule // fibonacci
