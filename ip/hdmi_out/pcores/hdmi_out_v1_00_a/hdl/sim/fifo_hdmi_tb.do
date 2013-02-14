vlib work
vlog ../verilog/fill_fifo_fsm.v
vlog ../verilog/pulse_gen.v
vlog ../verilog/hdmi_core.v
vlog fifo_hdmi_tb.v

vsim -novopt work.fifo_hdmi_tb

add wave -position insertpoint sim:/fifo_hdmi_tb/*

run 26000000
