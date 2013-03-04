//testbench for floating point operator generated using Xilinx coregen


module testbench();




floating_point_v6_1 dut(.ackl(),
								.s_axis_a_tvalid(),
								.s_axis_b_tvalid(),
								.m_axis_result_tready(),
								.s_axis_a_tready(),
								.s_axis_b_tready(),
								.m_axis_result_tvalid(),
								.s_axis_a_tdata(),
								.s_axis_b_tdata(),
								.m_axis_result_tdata();
								.m_axis_result_tuser()
							);




endmodule							
