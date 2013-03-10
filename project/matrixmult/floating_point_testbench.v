`timescale 1 ns / 1 ns

//testbench for floating point operator generated using Xilinx coregen


module floating_point_testbench();

	//core inputs
	reg clk, s_axis_a_tvalid, s_axis_b_tvalid, m_axis_result_tready;
	reg [31:0] s_axis_a_tdata, s_axis_b_tdata;
	reg [31:0] expected_output;

	//core outputs
	wire s_axis_a_tready, s_axis_b_tready, m_axis_result_tvalid; //outputs of FP unit
	wire [31:0] m_axis_result_tdata;
	wire [2:0] m_axis_result_tuser;

	//instantiate FP unit
	floating_point_v6_1 dut (
	  .aclk(clk), // input aclk
	  .s_axis_a_tvalid(s_axis_a_tvalid), // input s_axis_a_tvalid
	  .s_axis_a_tready(s_axis_a_tready), // output s_axis_a_tready
	  .s_axis_a_tdata(s_axis_a_tdata), // input [31 : 0] s_axis_a_tdata
	  .s_axis_b_tvalid(s_axis_b_tvalid), // input s_axis_b_tvalid
	  .s_axis_b_tready(s_axis_b_tready), // output s_axis_b_tready
	  .s_axis_b_tdata(s_axis_b_tdata), // input [31 : 0] s_axis_b_tdata
	  .m_axis_result_tvalid(m_axis_result_tvalid), // output m_axis_result_tvalid
	  .m_axis_result_tready(m_axis_result_tready), // input m_axis_result_tready
	  .m_axis_result_tdata(m_axis_result_tdata), // output [31 : 0] m_axis_result_tdata
	  .m_axis_result_tuser(m_axis_result_tuser) // output [2 : 0] m_axis_result_tuser
	);

	//generate input signals
	initial
		clk <= 0;
	always @ (clk)
		clk <= #50 ~clk;

	initial begin
		s_axis_a_tvalid <= 1'b0;
		s_axis_b_tvalid <= 1'b0;
		m_axis_result_tready <= 1'b0;
		s_axis_a_tdata <= 32'b01000011011011000000000000000000; //0 10000110 11011000000000000000000 = 236
		s_axis_b_tdata <= 32'b10111110001000000000000000000000; //1 01111100 01000000000000000000000 = -0.15625
		expected_output <= 32'hC2138000; //36.875

		@ (negedge clk);
		s_axis_a_tvalid <= 1'b1;
		s_axis_b_tvalid <= 1'b1;
		m_axis_result_tready <= 1'b1;

		@ (negedge clk);
		@ (negedge clk);
		s_axis_a_tdata <= 32'b10111110001000000000000000000000; //1 01111100 01000000000000000000000 = -0.15625
		s_axis_b_tdata <= 32'b10111110001000000000000000000000; //1 01111100 01000000000000000000000 = -0.15625
		expected_output <= 32'h3CC80000; //0.0244140625

		@ (negedge clk);
		s_axis_a_tdata <= 32'h3F47AE14; //0.78
		s_axis_b_tdata <= 32'h42C7C7AE; //99.89
		expected_output <= 32'h429BD412; //77.9142

		@ (negedge clk);
		s_axis_a_tdata <= 32'b01000011011011000000000000000000; //0 10000110 11011000000000000000000 = 236
		s_axis_b_tdata <= 32'b10111110001000000000000000000000; //1 01111100 01000000000000000000000 = -0.15625
		expected_output <= 32'hC2138000; //36.875

	end





endmodule							
