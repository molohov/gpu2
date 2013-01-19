vlib work
vlog ../src/*.v

vsim work.csm_top
add wave sim:/csm_top/*

force -freeze sim:/csm_top/mer  1111111111111111 0
force -freeze sim:/csm_top/mand 0000000001010101 0
run 1000
force -freeze sim:/csm_top/mer  0000000000000001 0
force -freeze sim:/csm_top/mand 0000000001110110 0
run 1000
force -freeze sim:/csm_top/mer  0000000000001111 0
force -freeze sim:/csm_top/mand 0000000000010001 0
run 1000
force -freeze sim:/csm_top/mer  0000000001001110 0
force -freeze sim:/csm_top/mand 0000000000010001 0
run 1000
