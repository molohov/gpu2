#
# This is to test the module bus_controller
#
# Paul Chow
# October 31, 2004
#
# $Id$
#
do busreset.do
#
# Test address that is not the device
force i68k_address 23'h400000
force i68k_rw 1
force i68k_as_b 0
run 100
force i68k_as_b 1
run 100
#
# Do a write to the Multiplier register
#
force i68k_address 23'h500002
force i68k_rw 0
force i68k_as_b 0
force io68k_data 16'habcd
run 100
do endbuscycle.do
#
# Do a read of the Multiplier register
#
force i68k_address 23'h500002
force i68k_rw 1
force i68k_as_b 0
run 100
do endbuscycle.do
#
# Do a write to the Multiplicand register
#
force i68k_address 23'h500003
force i68k_rw 0
force i68k_as_b 0
force io68k_data 16'habde
run 100
do endbuscycle.do
#
# Do a read of the Multiplicand register
#
force i68k_address 23'h500003
force i68k_rw 1
force i68k_as_b 0
run 100
do endbuscycle.do
#
# Do a write to the Product register
#
force i68k_address 23'h500004
force i68k_rw 0
force i68k_as_b 0
force io68k_data 16'hface
run 100
do endbuscycle.do
#
# Do a read of the Product register
# Should see a reset sent as well
#
force i68k_address 23'h500004
force i68k_rw 1
force i68k_as_b 0
run 100
do endbuscycle.do
#
# Do a write to the Control register
#
force i68k_address 23'h500005
force i68k_rw 0
force i68k_as_b 0
force io68k_data 16'h5554
run 100
do endbuscycle.do
#
# Do a read of the Control register
#
force i68k_address 23'h500005
force i68k_rw 1
force i68k_as_b 0
run 100
do endbuscycle.do
#
# Do a write to the Interrupt enable register
# Avoid turning on interrupt for now
#
force i68k_address 23'h500001
force i68k_rw 0
force i68k_as_b 0
force io68k_data 16'h7111
run 100
do endbuscycle.do
#
# Do a read of the Interrupt enable register
#
force i68k_address 23'h500001
force i68k_rw 1
force i68k_as_b 0
run 100
do endbuscycle.do
#
# Do a read of the Status register
# Note that you cannot write to this register from the bus
#
force i68k_address 23'h500000
force i68k_rw 1
force i68k_as_b 0
run 100
do endbuscycle.do
#
# Turn on the Done bit
# 
force iDone 1
run 100
#
# do a read of the Status register to see if Done comes on
#
force i68k_address 23'h500000
force i68k_rw 1
force i68k_as_b 0
run 100
do endbuscycle.do
#
# Turn on the Go bit in the Control register
#
force i68k_address 23'h500005
force i68k_rw 0
force i68k_as_b 0
force io68k_data 16'h0001
run 100
do endbuscycle.do
#
# Test interrupt request
# Turn off the Done bit
#
force iDone 0
run 100
# Turn on the interrupt enable
force i68k_address 23'h500001
force i68k_rw 0
force i68k_as_b 0
force io68k_data 16'h8000
run 100
do endbuscycle.do
# Generate a product input
force iProduct 16'hdade
run 100
# Turn on the Done bit
force iDone 1
run 100
# Should get an interrupt request
run 100
# Then do a read of the Product register
force i68k_address 23'h500004
force i68k_rw 1
force i68k_as_b 0
run 100
do endbuscycle.do
# Should see the reset and the Go bit turn off
# Turn off the Done bit
force iDone 0
run 100
# Interrupt request should go away
run 200
#
# Send a reset to the device by writing the Control register
# Should see the reset on for 2 clock pulses
#
force i68k_address 23'h500005
force i68k_rw 0
force i68k_as_b 0
force io68k_data 16'h0002
run 100
do endbuscycle.do
run 100
#
# Read the Control register to see the reset bit off
#
force i68k_address 23'h500005
force i68k_rw 1
force i68k_as_b 0
run 100
do endbuscycle.do
run 100
