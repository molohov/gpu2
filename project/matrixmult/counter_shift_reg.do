vlib work
vlog matrixmult_float_seq.v
vlog counter_shift_reg_tb.v
vsim work.counter_shift_reg_tb
add wave -position insertpoint  \
sim:/counter_shift_reg_tb/clk \
sim:/counter_shift_reg_tb/reset \
sim:/counter_shift_reg_tb/inputs_ready \
sim:/counter_shift_reg_tb/shift_reg_done \
sim:/counter_shift_reg_tb/counter_done
run 5000
