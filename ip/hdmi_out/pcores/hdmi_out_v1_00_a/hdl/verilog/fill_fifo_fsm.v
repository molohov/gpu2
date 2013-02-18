module fill_fifo_fsm( input Bus2IP_Clk,
					  input reset_fill_fifo,	
					  input start_fill_fifo,
					  input hsync,							//obtain hsync and vsync from hdmi_core
					  input vsync,
					  input half_full,
					  input [31:0] FRAME_BASE_ADDR,			//obtain these from software (slv_reg in user_logic)
					  input [31:0] LINE_STRIDE,
					  //input	[31:0] NUM_BYTES_PER_PIXEL,
					  output reg [31:0] ddr_addr_to_read,
					  output reg 		go_fill_fifo);		//use to control FIFO write_xfer signal in user_logic
					


 ///////////////////////////////
 //parameters

parameter NUM_BYTES_PER_PIXEL = 32'd4;


parameter 	RESET_fill_fifo 	= 3'b000;
 parameter 	BEGIN_fill_fifo 	= 3'b001;
 parameter 	IDLE_fill_fifo 		= 3'b010;
 parameter 	DONE_HALF_fill_fifo = 3'b011;
 parameter 	DONE_LINE_fill_fifo = 3'b100;

 parameter      HALF_FIFO = 32'h100;
 
 //signals
 reg            start_fill_fifo_reg;
 reg            hsync_reg;
 reg            vsync_reg;
 reg            half_full_reg;

 reg		[2:0] fill_fifo_fsm_state;
 reg 		[2:0] fill_fifo_fsm_nextstate;
 reg		[31:0] addr_inc;
 reg            go_fill_fifo_next;
 ///////////////////////////////

  always @ (posedge Bus2IP_Clk)
	begin
		start_fill_fifo_reg <= start_fill_fifo;
		hsync_reg <= hsync;
		vsync_reg <= vsync;
		half_full_reg <= half_full;
	end
 
  //combinational logic
  always @ (posedge Bus2IP_Clk)
	begin
		go_fill_fifo <= go_fill_fifo_next;
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
	
	always @ (posedge Bus2IP_Clk)
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
											fill_fifo_fsm_nextstate = (start_fill_fifo_reg) ? BEGIN_fill_fifo : RESET_fill_fifo;
			BEGIN_fill_fifo:
											fill_fifo_fsm_nextstate = IDLE_fill_fifo;
			IDLE_fill_fifo:
				begin
					if (vsync_reg) 				      fill_fifo_fsm_nextstate = RESET_fill_fifo; 		//done frame, go back to reset state
					else if (hsync_reg) 		   fill_fifo_fsm_nextstate = DONE_LINE_fill_fifo; 	
					else if (half_full_reg)		fill_fifo_fsm_nextstate = DONE_HALF_fill_fifo;
					else					           fill_fifo_fsm_nextstate = IDLE_fill_fifo;
				end
			DONE_HALF_fill_fifo:
											fill_fifo_fsm_nextstate = IDLE_fill_fifo;
			DONE_LINE_fill_fifo:
											fill_fifo_fsm_nextstate = IDLE_fill_fifo;
			default:
											fill_fifo_fsm_nextstate = RESET_fill_fifo; //error, should not go to default
		endcase
	end
	
  //output logic
  always @ (*)
	begin
		case (fill_fifo_fsm_state)
			RESET_fill_fifo:
				begin
				addr_inc			= 32'b0;
				go_fill_fifo_next 		= 1'b0;
				end
			BEGIN_fill_fifo:
				begin
				addr_inc		 	= FRAME_BASE_ADDR; //start reading from beginning of frame -->this will actually be from slv_reg (Software)
				go_fill_fifo_next 		= 1'b1;
				end							
			IDLE_fill_fifo:
				begin
				addr_inc		 	= 32'b0; 
				go_fill_fifo_next 		= 1'b0;
				end
			DONE_HALF_fill_fifo:
				begin
				addr_inc		 	= HALF_FIFO; //64 words * 4 bytes/word = 256 bytes = half fifo
				go_fill_fifo_next 		= 1'b1;
				end
			DONE_LINE_fill_fifo:
				begin
				addr_inc		 	= NUM_BYTES_PER_PIXEL*(LINE_STRIDE); //(stride in pixels)(#bytes/pixel)
				go_fill_fifo_next 		= 1'b1;
				end
			default:
				begin
				addr_inc			= 32'b0;
				go_fill_fifo_next 		= 1'b0;
				end			
		endcase
	end
 

endmodule
