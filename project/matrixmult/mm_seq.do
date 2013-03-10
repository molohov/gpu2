vlib work
vlog matrixmult_seq.v
vlog matrixmult_seq_tb.v
vsim -novopt work.matrixmult_tb
add wave -position insertpoint -radix decimal \
sim:/matrixmult_tb/*
run 800
