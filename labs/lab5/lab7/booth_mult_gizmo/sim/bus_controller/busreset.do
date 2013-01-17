#
# This is for testing the module bus_controller.
# Does a reset of the bus
#
# Paul Chow
# October 31, 2004
#
# $Id$
#
force i68k_reset_b 0
force i68k_address 23'h400000
force i68k_rw 1
force i68k_as_b 1
run 300
force i68k_reset_b 1
run 300

