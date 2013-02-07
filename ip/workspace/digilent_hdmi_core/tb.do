vlib work
vcom *.vhd
vlog tb.v
vsim -novopt work.tb

run 20000000
