vlog floating_point_add_sub_v6_1.v
vlog floating_point_add_testbench.v
vsim -novopt +notimingchecks -t ps -L xilinxcorelib_ver -L secureip -L unisims_ver -L unisim work.floating_point_add_testbench work.glbl

add wave -position insertpoint  \
sim:/floating_point_add_testbench/clk \
sim:/floating_point_add_testbench/s_axis_a_tvalid \
sim:/floating_point_add_testbench/s_axis_b_tvalid \
sim:/floating_point_add_testbench/m_axis_result_tready \
sim:/floating_point_add_testbench/s_axis_operation_tvalid \
sim:/floating_point_add_testbench/s_axis_a_tdata \
sim:/floating_point_add_testbench/s_axis_b_tdata \
sim:/floating_point_add_testbench/expected_output \
sim:/floating_point_add_testbench/s_axis_a_tready \
sim:/floating_point_add_testbench/s_axis_b_tready \
sim:/floating_point_add_testbench/m_axis_result_tvalid \
sim:/floating_point_add_testbench/s_axis_operation_tready \
sim:/floating_point_add_testbench/m_axis_result_tdata \
sim:/floating_point_add_testbench/m_axis_result_tuser \
sim:/floating_point_add_testbench/s_axis_operation_tdata

run 10000000

