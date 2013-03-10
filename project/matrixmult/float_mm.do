vlog floating_point_v6_1.v
vlog floating_point_testbench.v
vsim -novopt +notimingchecks -t ps -L xilinxcorelib_ver -L secureip -L unisims_ver -L unisim work.floating_point_testbench work.glbl


