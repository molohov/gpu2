vlib work
vlog ../rtl/fibonacci.v
vlog ./fibonacci_tb.v
# vopt +acc fibonacci_tb -o fibonacci_tb_debug
vsim -do "do wave.do; run 20 us" fibonacci_tb
