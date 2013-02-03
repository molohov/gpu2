CAUTION: 
This Tactical Update is intended as a fast response for the following
customer issue only. The risk inherent in this fast response is that there
is not enough time or resources available for the full regression testing
that is done for the Service Pack Updates and there is a higher risk of
introducing new problems. It is recommended that customers always install
the latest Service Pack Update, but only install Tactical Updates when needed
to resolve specific issues. This Tactical Update may not be compatible with
other Tactical Updates made available by Xilinx.

DESCRIPTION:
Xilinx Answer #37425
http://www.xilinx.com/support/answers/37425.htm

12.3 EDK, 12.3 ISE - How do I create a custom AXI IP core? 

How do I create a custom AXI IP core? The EDK Create IP Wizard will not have examples until EDK 13.1.

A collection of verilog AXI4 master and AXI4 slave, and  VHDL AXI4-Stream master/slave example templates can be downloaded from:
 
For EDK designs, the AXI4 templates contain the MPD file parameters to configure an connected AXI Interconnect block. This includes services such as register pipelining, clock domain crossing, width conversion, and FIFOs. All examples are complete EDK pcores.  To use, extract the above .zip file to the project pcores/ directory and choose Project->Rescan User Repositories.

For non-EDK designs, the HDL files from the axi_<corename>/hdl/verilog axi_<corename>/hdl/vhdl or directory can be added as a HDL source.

COMPATIBILITY:
These cores were synthesized in EDK 12.4.

Last Updated:
7/8/2012
