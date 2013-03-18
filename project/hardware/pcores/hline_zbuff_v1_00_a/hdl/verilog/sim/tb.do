vlib work
vlog ../fsm.v
vlog fsm_tb.v
vsim -novopt work.fsm_tb
do wave.do
run 30000
