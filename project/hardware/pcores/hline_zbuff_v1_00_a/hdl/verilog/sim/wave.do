onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /fsm_tb/clk
add wave -noupdate /fsm_tb/start
add wave -noupdate /fsm_tb/reset
add wave -noupdate -radix hexadecimal /fsm_tb/fb_addr
add wave -noupdate -radix hexadecimal /fsm_tb/zbuff_addr
add wave -noupdate -radix hexadecimal /fsm_tb/y
add wave -noupdate -radix hexadecimal /fsm_tb/x1
add wave -noupdate -radix hexadecimal /fsm_tb/x2
add wave -noupdate -radix hexadecimal /fsm_tb/z1
add wave -noupdate -radix hexadecimal /fsm_tb/z2
add wave -noupdate -radix hexadecimal /fsm_tb/rem
add wave -noupdate -radix hexadecimal /fsm_tb/err
add wave -noupdate -radix hexadecimal /fsm_tb/slope
add wave -noupdate -radix hexadecimal /fsm_tb/z_out
add wave -noupdate /fsm_tb/zfifo_in
add wave -noupdate -radix hexadecimal /fsm_tb/addr
add wave -noupdate /fsm_tb/rd_req
add wave -noupdate /fsm_tb/wr_req
add wave -noupdate /fsm_tb/read_zfifo
add wave -noupdate /fsm_tb/write_zfifo
add wave -noupdate /fsm_tb/read_zbuffout_fifo
add wave -noupdate /fsm_tb/read_be_fifo
add wave -noupdate /fsm_tb/byteenable
add wave -noupdate /fsm_tb/zread_empty
add wave -noupdate /fsm_tb/axi_done
add wave -noupdate /fsm_tb/fsm_dut/state
add wave -noupdate -radix unsigned /fsm_tb/fsm_dut/xcnt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1653 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 317
configure wave -valuecolwidth 176
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {10500 ps}
