onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /dvi_stimulate_tb/hsync
add wave -noupdate /dvi_stimulate_tb/vsync
add wave -noupdate /dvi_stimulate_tb/ve
add wave -noupdate /dvi_stimulate_tb/clock
add wave -noupdate /dvi_stimulate_tb/reset
add wave -noupdate /dvi_stimulate_tb/start
add wave -noupdate /dvi_stimulate_tb/dut/hcounter
add wave -noupdate /dvi_stimulate_tb/dut/state
add wave -noupdate /dvi_stimulate_tb/dut/vcounter
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
