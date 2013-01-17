onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal -radix hexadecimal /bus_controller/i68k_address
add wave -noupdate -format Literal -radix hexadecimal /bus_controller/io68k_data
add wave -noupdate -format Logic /bus_controller/i68k_clk
add wave -noupdate -format Logic /bus_controller/i68k_as_b
add wave -noupdate -format Logic /bus_controller/i68k_rw
add wave -noupdate -format Logic /bus_controller/my_address
add wave -noupdate -format Logic /bus_controller/read_reg
add wave -noupdate -format Logic /bus_controller/write_reg
add wave -noupdate -format Literal -radix hexadecimal /bus_controller/read_data
add wave -noupdate -format Logic /bus_controller/o68k_dtack_b
add wave -noupdate -format Logic /bus_controller/i68k_reset_b
add wave -noupdate -format Logic /bus_controller/o68k_irq6_b
add wave -noupdate -format Literal -radix hexadecimal /bus_controller/reg_multiplier
add wave -noupdate -format Literal -radix hexadecimal /bus_controller/oMultiplier
add wave -noupdate -format Literal -radix hexadecimal /bus_controller/oMultiplicand
add wave -noupdate -format Literal -radix hexadecimal /bus_controller/iProduct
add wave -noupdate -format Logic /bus_controller/oGo
add wave -noupdate -format Logic /bus_controller/iDone
add wave -noupdate -format Logic /bus_controller/oDevReset_b
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {400 ns} 0}
WaveRestoreZoom {1023 ns} {2315 ns}
configure wave -namecolwidth 188
configure wave -valuecolwidth 40
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
