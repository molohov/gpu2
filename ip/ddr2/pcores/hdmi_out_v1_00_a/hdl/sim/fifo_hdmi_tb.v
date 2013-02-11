// Assuming the inputs are read from user slave registers, turn a toggle into a one-cycle pulse

module fifo_hdmi_tb (
);

  parameter FRAME_BASE_ADDR = 32'h80000000;
  parameter LINE_STRIDE = 32'h00004000;
  parameter NUM_PIXELS_PER_LINE = 32'h00000100;
  parameter NUM_BYTES_PER_PIXEL = 32'h00000004;
  
  wire [31:0] ddr_addr_to_read;
  wire go_fill_fifo;
  
  reg clk, reset, start;
  reg fill_half_fifo_I;
  reg hsync_I, vsync_I;

fill_fifo_fsm fill_fifo(
			.Bus2IP_Clk(clk),
			.reset_fill_fifo(reset_fifo),	
			.start_fill_fifo(start_fifo),
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
			


//this module stimulates signals because fill_fifo_fsm expects hsync, vsync, and half_full to last only one clk cycle
pulse_gen #(3) stimulate_signals4_fifo_fsm(
  			.clk(clk),
			.sig_I(slv_reg0[30:28]),
			.toggle_O({vsync_fifo, hsync_fifo, half_full_fifo}),
			.posedge_O(),
			.negedge_O()
			);

  hdmi_core hdmi_core_inst (
    .reset(reset_hdmi),
    .start(start_hdmi),
    .clock(PXL_CLK_X1),
    .hres(11'd1280),
    .vres(10'd720),
    .color(ip2bus_mstwr_d /*slv_reg1[23:0]*/),
    .red(red),
    .blue(blue),
    .green(green),
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
     .C_DWIDTH(C_MST_NATIVE_DATA_WIDTH),
     .C_DEPTH(128))
   DATA_CAPTURE_FIFO_I (
     .Clk(clk),
     .Reset(bus2ip_Reset),
     .FIFO_Write(mst_fifo_valid_write_xfer),
     .Data_In(bus2ip_mstrd_d),
     .FIFO_Read(ve/*mst_fifo_valid_read_xfer*/),
     .Data_Out(ip2bus_mstwr_d),
     .FIFO_Full(),
     .FIFO_Empty(),
     .Addr()); // DATA_CAPTURE_FIFO_I
		
  
  initial clk = 0;

  always #10 clk = ~clk;

  initial
  begin
    @ (negedge clk)
	reset = 1;
	start = 0;
    fill_half_fifo_I = 0;
    hsync_I = 0;
    vsync_I = 0;
    @ (negedge clk) ;
	reset = 0;
	start = 1;
    @ (negedge clk) ;
    @ (negedge clk) ;
    @ (negedge clk) ;
    @ (negedge clk) ;
    @ (negedge clk)
    fill_half_fifo_I = 1;
    @ (negedge clk)
    fill_half_fifo_I = 0;
    @ (negedge clk)
    fill_half_fifo_I = 1;
    @ (negedge clk)
    fill_half_fifo_I = 0;
    @ (negedge clk)
    fill_half_fifo_I = 1;
    @ (negedge clk)
    fill_half_fifo_I = 0;
    @ (negedge clk) ;
    @ (negedge clk) ;
    @ (negedge clk)
    hsync_I = 1;
    @ (negedge clk)
    hsync_I = 0;
    @ (negedge clk) ;
    @ (negedge clk) ;
    @ (negedge clk) ;
    @ (negedge clk) ;
    @ (negedge clk)
    fill_half_fifo_I = 1;
    @ (negedge clk)
    fill_half_fifo_I = 0;
    @ (negedge clk)
    fill_half_fifo_I = 1;
    @ (negedge clk)
    fill_half_fifo_I = 0;
    @ (negedge clk)
    fill_half_fifo_I = 1;
    @ (negedge clk)
    fill_half_fifo_I = 0;
    @ (negedge clk) ;
    @ (negedge clk) ;
    @ (negedge clk)
    hsync_I = 1;
    @ (negedge clk)
    hsync_I = 0;
    @ (negedge clk) ;
    @ (negedge clk) ;
    @ (negedge clk) ;
    @ (negedge clk) ;
    @ (negedge clk)
    fill_half_fifo_I = 1;
    @ (negedge clk)
    fill_half_fifo_I = 0;
    @ (negedge clk)
    fill_half_fifo_I = 1;
    @ (negedge clk)
    fill_half_fifo_I = 0;
    @ (negedge clk)
    fill_half_fifo_I = 1;
    @ (negedge clk)
    fill_half_fifo_I = 0;
    @ (negedge clk) ;
    @ (negedge clk) ;
    @ (negedge clk)
    vsync_I = 1;
    @ (negedge clk)
    vsync_I = 0;
  end

endmodule

