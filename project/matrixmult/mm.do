vlog floating_point_v6_1.v
vcom tb_floating_point_v6_1.vhd
vsim -novopt +notimingchecks -t ps -L xilinxcorelib_ver -L secureip -L unisims_ver -L unisim work.tb_floating_point_v6_1 work.glbl

