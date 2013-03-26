onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /fsm_tb/clk
add wave -noupdate /fsm_tb/start
add wave -noupdate /fsm_tb/reset
add wave -noupdate /fsm_tb/axi_done
add wave -noupdate -radix hexadecimal /fsm_tb/fb_addr
add wave -noupdate -radix hexadecimal /fsm_tb/zbuff_addr
add wave -noupdate -radix hexadecimal /fsm_tb/z1
add wave -noupdate -radix hexadecimal /fsm_tb/z_fifo_in
add wave -noupdate -radix hexadecimal /fsm_tb/f_fifo_in
add wave -noupdate -radix hexadecimal /fsm_tb/slope
add wave -noupdate -radix hexadecimal /fsm_tb/err
add wave -noupdate -radix hexadecimal /fsm_tb/rem
add wave -noupdate -radix hexadecimal /fsm_tb/dx
add wave -noupdate -radix hexadecimal /fsm_tb/rgbx
add wave -noupdate -radix hexadecimal /fsm_tb/addr
add wave -noupdate -radix hexadecimal /fsm_tb/z_out
add wave -noupdate -radix hexadecimal /fsm_tb/f_out
add wave -noupdate -radix hexadecimal /fsm_tb/z_sum_out
add wave -noupdate /fsm_tb/rd_req
add wave -noupdate /fsm_tb/wr_req
add wave -noupdate /fsm_tb/done
add wave -noupdate /fsm_tb/axi_bus_to_z_fifo
add wave -noupdate /fsm_tb/axi_bus_to_f_fifo
add wave -noupdate /fsm_tb/read_in_fifos
add wave -noupdate /fsm_tb/write_out_fifos
add wave -noupdate /fsm_tb/read_z_out_fifo
add wave -noupdate /fsm_tb/read_f_out_fifo
add wave -noupdate -radix unsigned /fsm_tb/curr_state
add wave -noupdate /fsm_tb/start_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 249
configure wave -valuecolwidth 218
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {28180 ns}
