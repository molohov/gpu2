vlib work
vlog ../verilog/fill_fifo_stimulate.v
vlog fill_fifo_stimulate_tb.v

vsim work.fill_fifo_stimulate_tb

add wave -position insertpoint sim:/fill_fifo_stimulate_tb/*

run 400
