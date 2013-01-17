#
# This is to set up the clock
#
# Paul Chow
# October 31, 2004
#
# $Id$
#
force i68k_clk 1 50 -r 100
force i68k_clk 0 100 -r 100
# align the clock to a rising edge where things change
run 50