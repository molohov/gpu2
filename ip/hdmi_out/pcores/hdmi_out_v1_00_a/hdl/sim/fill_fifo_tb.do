vlib work
vlog ../verilog/fill_fifo_fsm.v
vlog fill_fifo_tb.v

vsim -novopt work.fill_fifo_tb

add wave -position insertpoint sim:/fill_fifo_tb/*

run 1000
