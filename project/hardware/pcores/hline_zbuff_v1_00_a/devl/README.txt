TABLE OF CONTENTS
  1) Peripheral Summary
  2) Description of Generated Files
  3) Location to documentation of dependent libraries
================================================================================
*                             1) Peripheral Summary                            *
================================================================================
Peripheral Summary:

  XPS project / EDK repository               : C:\cygwin\home\Maximus\gpu2\project\hardware
  logical library name                       : hline_zbuff_v1_00_a
  top name                                   : hline_zbuff
  version                                    : 1.00.a
  type                                       : AXI4 master slave
  features                                   : slave attachment
                                               master attachment
                                               mir/rst register
                                               user s/w registers
                                               user master model
  Note: Current Implementation does not support master & slave interfaces connected to different clock frequencies. Please make sure they are connected to same clock frequency.

Address Block for User Logic and IPIF Predefined Services

  user logic slave space                     : C_BASEADDR + 0x00000000
                                             : C_BASEADDR + 0x000000FF
  user logic master space                    : C_BASEADDR + 0x00000100
                                             : C_BASEADDR + 0x000001FF
  software reset space                       : C_BASEADDR + 0x00000200
                                             : C_BASEADDR + 0x000002FF


================================================================================
*                          2) Description of Generated Files                   *
================================================================================
- HDL source file(s)

  hdl/vhdl/hline_zbuff.vhd

    This is the template file for your peripheral's top design entity. It
    configures and instantiates the corresponding design units in the way you
    indicated in the wizard GUI and hooks it up to the stub user logic where
    the actual functionalites should get implemented. You are not expected to
    modify this template file except certain marked places for adding user
    specific generics and ports.

  verilog/user_logic.v

    This is the template file for the stub user logic design entity, either in
    VHDL or Verilog, where the actual functionalities should get implemented.
    Some sample code snippet may be provided for demonstration purpose.

- XPS interface file(s)

  data/hline_zbuff_v2_1_0.mpd

    This Microprocessor Peripheral Description file contains information of the
    interface of your peripheral, so that other EDK tools can recognize your
    peripheral.

  data/hline_zbuff_v2_1_0.pao

    This Peripheral Analysis Order file defines the analysis order of all the HDL
    source files that are used to compile your peripheral.

- Other misc file(s)

  devl/ipwiz.opt

    This is the option setting file for the wizard batch mode, which should
    generate the same result as the wizard GUI mode.

  devl/README.txt

    This README file for your peripheral.

  devl/ipwiz.log

    This is the log file by operating on this wizard.


================================================================================
*          3) Location to documentation of dependent libraries                 *
*                                                                              *
*   In general, the documentation is located under:                            *
*   $XILINX_EDK/hw/XilinxProcessorIPLib/pcores/$libName/doc                    *
*                                                                              *
================================================================================
proc_common_v3_00_a
	No documentation for this library

axi_lite_ipif_v1_01_a
	C:\cygwin\home\Maximus\gpu2\project\hardware\C:\Xilinx\14.2\ISE_DS\EDK\hw\XilinxProcessorIPLib\pcores\axi_lite_ipif_v1_01_a\doc\axi_lite_ipif_ds765.pdf

axi_master_burst_v1_00_a
	C:\cygwin\home\Maximus\gpu2\project\hardware\C:\Xilinx\14.2\ISE_DS\EDK\hw\XilinxProcessorIPLib\pcores\axi_master_burst_v1_00_a\doc\ds844_axi_master_burst.pdf

