vlib work
vlog ../verilog/pulse_gen.v
vlog pulse_gen_tb.v

vsim -novopt work.pulse_gen_tb

add wave -position insertpoint sim:/pulse_gen_tb/*

run 400
