vlib work
vlog dvi_stimulate_tb.v
vlog ../verilog/dvi_stimulate.v
vsim -novopt work.dvi_stimulate_tb
do dvi_stimulate_wave.do
run 20000000
