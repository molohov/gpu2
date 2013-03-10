vlib work
vlog floating_point_v6_1.v
vcom tb_floating_point_v6_1.vhd
vsim -novopt +notimingchecks -t ps -L xilinxcorelib_ver -L secureip -L unisims_ver -L unisim work.tb_floating_point_v6_1 work.glbl


add wave -position insertpoint  \
sim:/tb_floating_point_v6_1/sim_phase \
sim:/tb_floating_point_v6_1/aclk \
sim:/tb_floating_point_v6_1/s_axis_a_tvalid \
sim:/tb_floating_point_v6_1/s_axis_a_tready \
sim:/tb_floating_point_v6_1/s_axis_a_tdata \
sim:/tb_floating_point_v6_1/s_axis_b_tvalid \
sim:/tb_floating_point_v6_1/s_axis_b_tready \
sim:/tb_floating_point_v6_1/s_axis_b_tdata \
sim:/tb_floating_point_v6_1/m_axis_result_tvalid \
sim:/tb_floating_point_v6_1/m_axis_result_tready \
sim:/tb_floating_point_v6_1/m_axis_result_tdata \
sim:/tb_floating_point_v6_1/m_axis_result_tuser \
sim:/tb_floating_point_v6_1/s_axis_a_tdata_real \
sim:/tb_floating_point_v6_1/s_axis_a_tdata_special \
sim:/tb_floating_point_v6_1/s_axis_a_tdata_sign \
sim:/tb_floating_point_v6_1/s_axis_a_tdata_exp \
sim:/tb_floating_point_v6_1/s_axis_a_tdata_mant \
sim:/tb_floating_point_v6_1/s_axis_b_tdata_real \
sim:/tb_floating_point_v6_1/s_axis_b_tdata_special \
sim:/tb_floating_point_v6_1/s_axis_b_tdata_sign \
sim:/tb_floating_point_v6_1/s_axis_b_tdata_exp \
sim:/tb_floating_point_v6_1/s_axis_b_tdata_mant \
sim:/tb_floating_point_v6_1/m_axis_result_tdata_real \
sim:/tb_floating_point_v6_1/m_axis_result_tdata_special \
sim:/tb_floating_point_v6_1/m_axis_result_tdata_sign \
sim:/tb_floating_point_v6_1/m_axis_result_tdata_exp \
sim:/tb_floating_point_v6_1/m_axis_result_tdata_mant \
sim:/tb_floating_point_v6_1/m_axis_result_tuser_underflow \
sim:/tb_floating_point_v6_1/m_axis_result_tuser_overflow \
sim:/tb_floating_point_v6_1/m_axis_result_tuser_invalid_op \
sim:/tb_floating_point_v6_1/CLOCK_PERIOD \
sim:/tb_floating_point_v6_1/T_HOLD \
sim:/tb_floating_point_v6_1/T_STROBE \
sim:/tb_floating_point_v6_1/DUT_DELAY

run 1ms

