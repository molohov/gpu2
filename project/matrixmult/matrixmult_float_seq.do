vlib work

# Point these to your Xilinx installation and uncomment them the first time
# vlog /media/c/xilinx/14.2/ISE_DS/ISE/verilog/src/glbl.v
# vlog /media/c/xilinx/14.2/ISE_DS/ISE/verilog/src/unisims/*.v

vlog matrixmult_float_seq_tb.v
vlog matrixmult_float_seq.v
vlog floating_point_add_sub_v6_1.v
vlog floating_point_v6_1.v
vsim work.matrixmult_tb work.glbl

add wave -position insertpoint  \
-radix hexadecimal sim:/matrixmult_tb/* \
-radix hexadecimal sim:/matrixmult_tb/dut/*
run 2000 ns
