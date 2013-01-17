#
# This is to test the top level module my_top by doing some simple mults
#
# Paul Chow
# November 1, 2004
#
# $Id$
#
do busreset.do
#
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
# Test address that is not the device
#
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
force io68k_data 16'h0001
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
force io68k_data 16'habcd
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
# No interrupts at first
# Set the Go bit
#
force i68k_address 23'h500005
force i68k_rw 0
force i68k_as_b 0
force io68k_data 16'h0001
run 100
do endbuscycle.do
# Run a bit till the Done bit comes on
# Should see the Go bit go off
run 600
#
# Do a read of the Status register to see the Done bit on
#
force i68k_address 23'h500000
force i68k_rw 1
force i68k_as_b 0
run 100
do endbuscycle.do
#
# Read the Control register to see the Reset bit is off and Go is still on
#
force i68k_address 23'h500005
force i68k_rw 1
force i68k_as_b 0
run 100
do endbuscycle.do
#
# Do a read of the Product register
# Should see a reset sent as well and the Done bit go off
#
force i68k_address 23'h500004
force i68k_rw 1
force i68k_as_b 0
run 100
do endbuscycle.do
#
# Read the Control register to see the Go bit is off
#
force i68k_address 23'h500005
force i68k_rw 1
force i68k_as_b 0
run 100
do endbuscycle.do
#
#
# Change the Multiplier
#
force i68k_address 23'h500002
force i68k_rw 0
force i68k_as_b 0
force io68k_data 16'h0040
run 100
do endbuscycle.do
#
# Change the Multiplicand
#
force i68k_address 23'h500003
force i68k_rw 0
force i68k_as_b 0
force io68k_data 16'h1234
run 100
do endbuscycle.do
#
# Turn on the interrupt enable
#
force i68k_address 23'h500001
force i68k_rw 0
force i68k_as_b 0
force io68k_data 16'h8000
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
# Run a bit
# Should get an interrupt request
run 600
# Then do a read of the Product register
force i68k_address 23'h500004
force i68k_rw 1
force i68k_as_b 0
run 100
do endbuscycle.do
# Should see the reset and the Go bit turn off
# Interrupt request should go away
run 200
#
# Read the Control register to see the Reset and Go bits off
#
force i68k_address 23'h500005
force i68k_rw 1
force i68k_as_b 0
run 100
do endbuscycle.do
run 100
