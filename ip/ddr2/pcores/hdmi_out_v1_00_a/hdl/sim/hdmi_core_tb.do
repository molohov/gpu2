vlib work
vlog hdmi_core_tb.v
vlog ../verilog/pulse_gen.v
vlog ../verilog/hdmi_core.v
vsim -novopt work.hdmi_core_tb
do hdmi_core_wave.do
run 26000000
