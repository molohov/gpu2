vlib work
vlog ../fsm.v
vlog fsm_tb.v
vlog ../user_logic.v
vsim -novopt work.fsm_tb
do wave.do
run 30000
