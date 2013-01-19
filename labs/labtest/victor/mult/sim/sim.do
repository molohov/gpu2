vlib work
vlog ../src/*.v
vlog csmTest.v

vsim work.csmTest
add wave sim:/csmTest/*

force -freeze sim:/csmTest/SW 1111111101010101 0
run 1000
force -freeze sim:/csmTest/SW 0000000101110110 0
run 1000
force -freeze sim:/csmTest/SW 0000111100010001 0
run 1000
force -freeze sim:/csmTest/SW 0100111000010001 0
run 1000
