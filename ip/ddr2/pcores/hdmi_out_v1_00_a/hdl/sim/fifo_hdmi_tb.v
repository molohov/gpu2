// Assuming the inputs are read from user slave registers, turn a toggle into a one-cycle pulse

module fifo_hdmi_tb (
);

  parameter FRAME_BASE_ADDR = 32'h80000000;
  parameter LINE_STRIDE = 32'd1280;
  parameter NUM_PIXELS_PER_LINE = 32'd64;
  parameter NUM_BYTES_PER_PIXEL = 32'd4;
  
  wire [31:0] ddr_addr_to_read;
  wire fifo_write_go;
  
  reg clk, reset_fifo, start_fifo;
  reg reset_hdmi, start_hdmi;
  
  wire                                      hsync;
  wire                                      vsync;
  wire                                      ve;
  wire                                      read_go;
  wire                                      read_next_line;
  wire                                      read_next_chunk;
  wire                                      read_done;

 wire [31:0] fifo_out_data; //output data of fifo
 
 reg [31:0] fifo_in_data;  //data to write to fifo
 reg mst_fifo_valid_write_xfer; //tell fifo to start writing data 
 reg bus2ip_Reset; //reset for xilinx fifo
 
  
fill_fifo_fsm fill_fifo(
			.Bus2IP_Clk(clk),
			.reset_fill_fifo(reset_fifo),	
			.start_fill_fifo(start_fifo | read_go),
			.hsync(read_next_line),			//obtain hsync and vsync from hdmi_core
			.vsync(read_done),
			.half_full(read_next_chunk),
			.FRAME_BASE_ADDR(FRAME_BASE_ADDR),		//obtain these from software (slv_reg in user_logic)
			.LINE_STRIDE(LINE_STRIDE),
			.NUM_PIXELS_PER_LINE(NUM_PIXELS_PER_LINE),
			.NUM_BYTES_PER_PIXEL(NUM_BYTES_PER_PIXEL),
			.ddr_addr_to_read(ddr_addr_to_read /*{mst_reg[7], mst_reg[6], mst_reg[5], mst_reg[4]}*/),
			.go_fill_fifo(fifo_write_go /*mst_reg[0][0]*/) //control bit that will drive master burst read request		
		      	);		
			

/*
//this module stimulates signals because fill_fifo_fsm expects hsync, vsync, and half_full to last only one clk cycle
pulse_gen #(3) stimulate_signals4_fifo_fsm(
  			.clk(clk),
			.sig_I(slv_reg0[30:28]),
			.toggle_O({vsync_fifo, hsync_fifo, half_full_fifo}),
			.posedge_O(),
			.negedge_O()
			);
*/

  hdmi_core hdmi_core_inst (
    .reset(reset_hdmi),
    .start(start_hdmi),
    .clock(clk), //note: assuming same clock for bus2ip and PXL_CLK_X1!!! is that a valid assumption...?
    .hres(11'd1280),
    .vres(10'd720),
    .color(fifo_out_data /*slv_reg1[23:0]*/),
    .red(),
    .blue(),
    .green(),
    .hsync(hsync),
    .vsync(vsync),
    .read_go(read_go),
    .read_next_line(read_next_line),
    .read_next_chunk(read_next_chunk),
    .read_done(read_done),
    .ve(ve)
    );
 
  // FIFO depth is 128 words. User can modify the depth based on their requirement.
   srl_fifo_f #(
     .C_DWIDTH(32),
     .C_DEPTH(128))
   DATA_CAPTURE_FIFO_I (
     .Clk(clk),
     .Reset(bus2ip_Reset),
     .FIFO_Write(mst_fifo_valid_write_xfer | fifo_write_go), //note: fifo_write_go is not used in this way in user_logic
     .Data_In(fifo_in_data),
     .FIFO_Read(ve /*mst_fifo_valid_read_xfer*/),
     .Data_Out(fifo_out_data),
     .FIFO_Full(),
     .FIFO_Empty(),
     .Addr()); // DATA_CAPTURE_FIFO_I
		
  
  initial clk = 0;

  always #10 clk = ~clk;

  initial
  begin
    @ (negedge clk)
	reset_fifo = 1;
	start_fifo = 0;
    reset_hdmi = 1;
    start_hdmi = 0;
    mst_fifo_valid_write_xfer = 1; //give fifo head start to fill up data
	fifo_in_data = 32'h000000ff;
	bus2ip_Reset = 0;
    @ (negedge clk) ;
	reset_fifo = 0;
	reset_hdmi = 0;
	mst_fifo_valid_write_xfer = 0; //does this signal need to stay high? probably not (we can test this)
    @ (negedge clk) ;
    @ (negedge clk) ;
    @ (negedge clk) ;
	@ (negedge clk) ;
	@ (negedge clk) ;
    @ (negedge clk) ;
    @ (negedge clk) ;
	start_fifo = 1;					//start fifo fsm
	fifo_in_data = 32'h0000ff00;	//new data ready
	start_hdmi = 1;
    @ (negedge clk) ;
	start_fifo = 0;					//this should not need to stay high
	start_hdmi = 0;					//what about start signal for hdmi?
    @ (negedge clk) ;
    @ (negedge clk) ;
    @ (negedge clk) ;
    @ (negedge clk) ;
    @ (negedge clk) ;
	fifo_in_data = 32'h00ff0000;	//new data available to write to fifo
	@ (negedge clk) ;
    @ (negedge clk) ;
    @ (negedge clk) ;
    @ (negedge clk) ;
    @ (negedge clk) ;
	fifo_in_data = 32'h000000aa;
  end

endmodule

