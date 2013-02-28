onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /hdmi_core_tb/hsync
add wave -noupdate /hdmi_core_tb/vsync
add wave -noupdate -radix hexadecimal /hdmi_core_tb/red
add wave -noupdate -radix hexadecimal /hdmi_core_tb/green
add wave -noupdate -radix hexadecimal /hdmi_core_tb/blue
add wave -noupdate /hdmi_core_tb/ve
add wave -noupdate /hdmi_core_tb/read_go
add wave -noupdate /hdmi_core_tb/read_line
add wave -noupdate /hdmi_core_tb/read_chunk
add wave -noupdate /hdmi_core_tb/read_done
add wave -noupdate /hdmi_core_tb/read_fifo
add wave -noupdate /hdmi_core_tb/clock
add wave -noupdate /hdmi_core_tb/reset
add wave -noupdate /hdmi_core_tb/start
add wave -noupdate /hdmi_core_tb/dut/hcnt
add wave -noupdate /hdmi_core_tb/dut/vcnt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {53 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 335
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {2100 ps}
