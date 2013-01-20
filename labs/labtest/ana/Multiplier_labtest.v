module sequential_mult(	input clk,
						input reset,
						input [15:0] mer,
						input [15:0] mand,
						input go,
						output reg [31:0] product,
						output reg done);

  wire [15:0] mand_wire;
  wire [15:0] mer_wire;
  reg shift_mer;
  wire [16:0] sum;
  reg enable_product; 
  reg shift_product;
  wire [4:0] count;
  reg enable_counter;
  reg reset_counter;
  reg enable_mand;
  reg enable_mer;
  
  //instantiate 16bit register to store mand 
  shiftreg # (.N(16))        mandReg(.clk(clk),
                                         .reset(reset),
                                         .enable(enable_mand),
										 .shift_right(0),
										 .MSBin(0),
										 .in(mand),
                                         .q(mand_wire));
  //instantiate 16bit shift register to store mer
  shiftreg # (.N(16))        merReg(.clk(clk),
                                         .reset(reset),
                                         .enable(enable_mer),
										 .shift_right(shift_mer),
										 .MSBin(0),
										 .in(mer),
                                         .q(mer_wire));
										 
  //instantiate 32bit shift register to store product
  shiftreg_withMSB # (.N(32))        prodcutReg(.clk(clk),
                                         .reset(go),
                                         .enable(enable_product),
										 .shift_right(shift_product),
										 .MSBin(sum[16]);
										 .in({sum[15:0], product[15:0]}),
                                         .q(product));
  
  //instantiate 16-bit adder
  adder	 running_sum(	.in1(mand),
						.in2(product[31:16],
						.out(sum));
						
  
  //instantiate 5-bit wide counter 
  counter #(.N(5))	iter_count(	.clk(clk),
								.reset(reset_counter),
								.enable(enable_counter),
								.count(count));
  
  reg [2:0] state, nextstate; 
 
  //state encoding 
  parameter stateA = 3'b000; 
  parameter stateB = 3'b001; 
  parameter stateC = 3'b010; 
  parameter stateD = 3'b011; 
  parameter stateE = 3'b100; 
  parameter stateF = 3'b101; 
  //parameter stateG = 3'b110;
  //parameter stateH = 3'b111;
  
  //state register
  always @(posedge clk, posedge reset) 
    begin 
       if (reset) state <= stateA; 
       else  state <= nextstate; 
    end    
 
  //next state logic 
  always @(*) 
      begin 
          case (state) 
              stateA: nextstate = (go == 1) 	? stateB : stateA; 
              stateB: nextstate = (mer[0] == 1) ? stateC : stateD;  
              stateC: nextstate = stateD; 
              stateD: nextstate = stateE; 
              stateE: nextstate = (count == 16) ? stateF : stateB;
              stateF: nextstate = stateF; //done! 
              //stateG: nextstate = stateG;
              default: nextstate = stateA; 
          endcase  
       end  
   
  //output logic  
  always @(*)  
      begin  
         case (state)  
              stateA: begin  
                      enable_mand 		= 1'b1;
					  enable_mer 		= 1'b1;
					  shift_mer 		= 1'b0;
					  reset_counter 	= 1'b1;
					  enable_counter 	= 1'b0;
					  reset_product 	= 1'b1;
					  enable_product 	= 1'b0;
					  shift_product 	= 1'b0;
					  done				= 1'b0;
                      end  
              stateB: begin 
					  enable_mand 		= 1'b0;
					  enable_mer 		= 1'b0;
					  shift_mer 		= 1'b0;
					  reset_counter 	= 1'b0;
					  enable_counter 	= 1'b1;
					  reset_product 	= 1'b0;
					  enable_product 	= 1'b0;
					  shift_product 	= 1'b0;
					  done				= 1'b0;
					  end
			  stateC: begin 
					  enable_mand 		= 1'b0;
					  enable_mer 		= 1'b0;
					  shift_mer 		= 1'b0;
					  reset_counter 	= 1'b0;
					  enable_counter 	= 1'b0;
					  reset_product 	= 1'b0;
					  enable_product 	= 1'b1;
					  shift_product 	= 1'b0;
					  done				= 1'b0;
					  end
			  stateD: begin 
					  enable_mand 		= 1'b0;
					  enable_mer 		= 1'b0;
					  shift_mer 		= 1'b0;
					  reset_counter 	= 1'b0;
					  enable_counter 	= 1'b0;
					  reset_product 	= 1'b0;
					  enable_product 	= 1'b0;
					  shift_product 	= 1'b1;
					  done				= 1'b0;
					  end					  
			  stateE: begin
					  enable_mand 		= 1'b0;
					  enable_mer 		= 1'b0;
					  shift_mer 		= 1'b1;
					  reset_counter 	= 1'b0;
					  enable_counter 	= 1'b0;
					  reset_product 	= 1'b0;
					  enable_product 	= 1'b0;
					  shift_product 	= 1'b0;
					  done				= 1'b0;
					  end
			  stateF: begin
					  enable_mand 		= 1'b0;
					  enable_mer 		= 1'b0;
					  shift_mer 		= 1'b0;
					  reset_counter 	= 1'b0;
					  enable_counter 	= 1'b0;
					  reset_product 	= 1'b0;
					  enable_product 	= 1'b0;
					  shift_product 	= 1'b0;
					  done				= 1'b1;
					  end
			  default: begin
				      enable_mand 		= 1'b1;
					  enable_mer 		= 1'b1;
					  shift_mer 		= 1'b0;
					  reset_counter 	= 1'b1;
					  enable_counter 	= 1'b0;
					  reset_product 	= 1'b1;
					  enable_product 	= 1'b0;
					  shift_product 	= 1'b0;
					  done				= 1'b0;
					  end
      	  endcase
			  
	end
				
endmodule
			