vlib work
vlog ../fsm.v
vlog fsm_tb.v
vsim work.fsm_tb
do wave.do
run 10000
