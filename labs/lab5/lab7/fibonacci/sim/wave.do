onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider fibonacci
add wave -noupdate -format Logic -label clk -radix hexadecimal /fibonacci_tb/my_fibonacci/clk
add wave -noupdate -format Logic -label reset -radix hexadecimal /fibonacci_tb/my_fibonacci/reset
add wave -noupdate -format Literal -label slowdown -radix hexadecimal /fibonacci_tb/my_fibonacci/slowdown
add wave -noupdate -format Logic -label change -radix hexadecimal /fibonacci_tb/my_fibonacci/change
add wave -noupdate -format Literal -label fibonacci_out -radix hexadecimal /fibonacci_tb/my_fibonacci/fibonacci_out
add wave -noupdate -format Literal -label reg1 -radix hexadecimal /fibonacci_tb/my_fibonacci/reg1
add wave -noupdate -format Literal -label reg2 -radix hexadecimal /fibonacci_tb/my_fibonacci/reg2
add wave -noupdate -format Literal -label temp -radix hexadecimal /fibonacci_tb/my_fibonacci/temp
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2375000 ps} 0}
configure wave -namecolwidth 210
configure wave -valuecolwidth 157
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
update
WaveRestoreZoom {0 ps} {21 us}
