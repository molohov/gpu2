vopt +acc my_top -o my_top_debug
vsim my_top_debug
do waves.do
do setclk.do
do busreset.do

