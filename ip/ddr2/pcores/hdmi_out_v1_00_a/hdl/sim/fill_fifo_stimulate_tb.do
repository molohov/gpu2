vlib work
vlog ../verilog/fill_fifo_fsm.v
vlog fill_fifo_stimulate_tb.v

vsim -novopt work.fill_fifo_stimulate_tb

add wave -position insertpoint sim:/fill_fifo_stimulate_tb/*

run 400
