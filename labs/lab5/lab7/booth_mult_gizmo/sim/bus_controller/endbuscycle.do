#
# This is for testing the module bus_controller
# End a bus cycle
#
# Paul Chow
# October 31, 2004
#
# $Id$
#
force i68k_as_b 1
run 100
force i68k_rw 1
noforce io68k_data
force i68k_address 23'h40000f
run 200
