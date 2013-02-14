// Assuming the inputs are read from user slave registers, turn a toggle into a one-cycle pulse

module fifo_hdmi_tb (
);

  parameter FRAME_BASE_ADDR = 32'ha8000000;
  parameter LINE_STRIDE = 32'd1280;
  parameter NUM_BYTES_PER_PIXEL = 32'd4;
  
  wire [31:0] ddr_addr_to_read;
  wire fifo_write_go;
  
  reg clk, reset_fifo, start_fifo;
  reg reset_hdmi, start_hdmi;
  
  wire hsync;
  wire vsync;
  wire ve;
  wire read_fifo;
  wire read_go;
  wire read_next_line;
  wire read_next_chunk;
  wire read_done;
  wire [7:0] red;
  wire [7:0] green;
  wire [7:0] blue;

  reg [31:0] fifo_out_data = 32'h80808000; //output data of fifo

fill_fifo_fsm fill_fifo(
            .Bus2IP_Clk(clk),
            .reset_fill_fifo(reset_fifo),
            .start_fill_fifo(start_fifo | read_go),
            .hsync(read_next_line), //obtain hsync and vsync from hdmi_core
            .vsync(read_done),
            .half_full(1'b0 /*read_next_chunk*/), //unused for now
            .FRAME_BASE_ADDR(FRAME_BASE_ADDR), //obtain these from software (slv_reg in user_logic)
            .LINE_STRIDE(LINE_STRIDE),
            .NUM_BYTES_PER_PIXEL(NUM_BYTES_PER_PIXEL),
            .ddr_addr_to_read(ddr_addr_to_read),
            .go_fill_fifo(fifo_write_go) //control bit that will drive master burst read request
);

hdmi_core hdmi_core_inst (
    .reset(reset_hdmi),
    .start(start_hdmi),
    .clock(clk), //note: assuming same clock for bus2ip and PXL_CLK_X1!!! is that a valid assumption...?
    .hres(11'd1280),
    .color(fifo_out_data),
    .red(red),
    .green(green),
    .blue(blue),
    .hsync(hsync),
    .vsync(vsync),
    .read_fifo(read_fifo),
    .read_go(read_go),
    .read_next_line(read_next_line),
    .read_next_chunk(read_next_chunk),
    .read_done(read_done),
    .ve(ve)
);

// simulate a FIFO, with ve as the read signal
always @ (posedge clk)
begin
  if (read_fifo)
    fifo_out_data = fifo_out_data + 32'h100;
end

  initial clk = 0;

  always #10 clk = ~clk;

  initial
  begin
    @ (negedge clk)
    reset_fifo = 1;
    start_fifo = 0;
    reset_hdmi = 1;
    start_hdmi = 0;
    @ (negedge clk) ;
    @ (negedge clk)
    reset_fifo = 0;
    reset_hdmi = 0;
    start_hdmi = 1;
  end

endmodule

