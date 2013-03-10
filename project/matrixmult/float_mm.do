vlog floating_point_v6_1.v
vlog floating_point_testbench.v
vsim -novopt +notimingchecks -t ps -L xilinxcorelib_ver -L secureip -L unisims_ver -L unisim work.floating_point_testbench work.glbl

add wave -position insertpoint  \
sim:/floating_point_testbench/clk \
sim:/floating_point_testbench/s_axis_a_tvalid \
sim:/floating_point_testbench/s_axis_b_tvalid \
sim:/floating_point_testbench/m_axis_result_tready \
sim:/floating_point_testbench/s_axis_a_tdata \
sim:/floating_point_testbench/s_axis_b_tdata \
sim:/floating_point_testbench/expected_output \
sim:/floating_point_testbench/s_axis_a_tready \
sim:/floating_point_testbench/s_axis_b_tready \
sim:/floating_point_testbench/m_axis_result_tvalid \
sim:/floating_point_testbench/m_axis_result_tdata \
sim:/floating_point_testbench/m_axis_result_tuser

run 10000000

