module fill_fifo_fsm( input Bus2IP_Clk,
					  input reset_fill_fifo,	
					  input start_fill_fifo,
					  input hsync,							//obtain hsync and vsync from hdmi_core
					  input vsync,
					  input half_full,
					  input [31:0] FRAME_BASE_ADDR,			//obtain these from software (slv_reg in user_logic)
					  input [31:0] LINE_STRIDE,
					  input [31:0] NUM_PIXELS_PER_LINE,
					  input	[31:0] NUM_BYTES_PER_PIXEL,
					  output reg [31:0] ddr_addr_to_read,
					  output reg 		go_fill_fifo);		//use to control FIFO write_xfer signal in user_logic
					


 ///////////////////////////////
 //parameters
 parameter 	RESET_fill_fifo 	= 3'b000;
 parameter 	BEGIN_fill_fifo 	= 3'b001;
 parameter 	IDLE_fill_fifo 		= 3'b010;
 parameter 	DONE_HALF_fill_fifo = 3'b011;
 parameter 	DONE_LINE_fill_fifo = 3'b100;
 
 //signals
 reg		[2:0] fill_fifo_fsm_state;
 reg 		[2:0] fill_fifo_fsm_nextstate;
 //reg		[31:0] ddr_addr_to_read;
 reg		[31:0] addr_inc;
 //wire		half_full;
 //assign 	half_full = !(hsync%'d64); //if hdmi_core reading 64th word, we have filled up half the buffer
 ///////////////////////////////

 
  //combinational logic
  always @ (Bus2IP_Clk)
	begin
		if (reset_fill_fifo) 
			begin
			fill_fifo_fsm_state <= RESET_fill_fifo;
			//ddr_addr_to_read <= 32'b0;
			end
		else 
			begin
			fill_fifo_fsm_state <= fill_fifo_fsm_nextstate;
			 	  if (fill_fifo_fsm_state == RESET_fill_fifo) ddr_addr_to_read <= 32'b0; //reset address register when in reset state
     	    else	ddr_addr_to_read <= ddr_addr_to_read + addr_inc; //otherwise, increment address reg by addr_inc (value depends on state)
			end
	end
	
	always @ (Bus2IP_Clk)
	begin
		if (reset_fill_fifo) 
			fill_fifo_fsm_state <= RESET_fill_fifo;
		else fill_fifo_fsm_state <= fill_fifo_fsm_nextstate;
	end
  
  //next state logic
  always @ (*)
	begin
		case (fill_fifo_fsm_state)
			RESET_fill_fifo:
											fill_fifo_fsm_nextstate = (start_fill_fifo) ? BEGIN_fill_fifo : RESET_fill_fifo;
			BEGIN_fill_fifo:
											fill_fifo_fsm_nextstate = IDLE_fill_fifo;
			IDLE_fill_fifo:
				begin
					if (vsync) 				      fill_fifo_fsm_nextstate = RESET_fill_fifo; 		//done frame, go back to reset state
					else if (hsync) 		   fill_fifo_fsm_nextstate = DONE_LINE_fill_fifo; 	
					else if (half_full)		fill_fifo_fsm_nextstate = DONE_HALF_fill_fifo;
					else					           fill_fifo_fsm_nextstate = IDLE_fill_fifo;
				end
			DONE_HALF_fill_fifo:
											fill_fifo_fsm_nextstate = IDLE_fill_fifo;
			DONE_LINE_fill_fifo:
											fill_fifo_fsm_nextstate = IDLE_fill_fifo;
			default:
											fill_fifo_fsm_nextstate = 3'b111; //error, should not go to default
		endcase
	end
	
  //output logic
  always @ (*)
	begin
		case (fill_fifo_fsm_state)
			RESET_fill_fifo:
				begin
				addr_inc			= 32'b0;
				go_fill_fifo 		= 1'b0;
				end
			BEGIN_fill_fifo:
				begin
				addr_inc		 	= FRAME_BASE_ADDR; //start reading from beginning of frame -->this will actually be from slv_reg (Software)
				go_fill_fifo 		= 1'b1;
				end							
			IDLE_fill_fifo:
				begin
				addr_inc		 	= 32'b0; 
				go_fill_fifo 		= 1'b0;
				end
			DONE_HALF_fill_fifo:
				begin
				addr_inc		 	= 32'd256; //64 words * 4 bytes/word = 256 bytes = half fifo
				go_fill_fifo 		= 1'b1;
				end
			DONE_LINE_fill_fifo:
				begin
				addr_inc		 	= LINE_STRIDE - (NUM_PIXELS_PER_LINE *NUM_BYTES_PER_PIXEL); //stride - (#pixels)(#bytes/pixel) --> will get info from slv_reg (Software)
				go_fill_fifo 		= 1'b1;
				end
			default:
				begin
				addr_inc			= 32'b0;
				go_fill_fifo 		= 1'b0;
				end			
		endcase
	end
 

endmodule
