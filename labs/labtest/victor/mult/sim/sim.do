vlib work
vlog ../src/*.v

vsim work.csm_tb
add wave sim:/csm_tb/*

run 3000
