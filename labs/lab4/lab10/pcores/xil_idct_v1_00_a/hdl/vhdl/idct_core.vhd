-------------------------------------------------------------------------------
--
--       XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"
--       AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND
--       SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,
--       OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,
--       APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION
--       THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,
--       AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE
--       FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY
--       WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE
--       IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR
--       REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF
--       INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
--       FOR A PARTICULAR PURPOSE.
--
--       (c) Copyright 2002 Xilinx Inc.
--       All rights reserved.
--
------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x" 
--      reset signals:                          "rst", "rst_n" 
--      generics:                               "C_*" 
--      user defined types:                     "*_TYPE" 
--      state machine next state:               "*_ns" 
--      state machine current state:            "*_cs" 
--      combinatorial signals:                  "*_com" 
--      pipelined or register delay signals:    "*_d#" 
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce" 
--      internal version of output port         "*_i"
--      device pins:                            "*_pin" 
--      ports:                                  - Names begin with Uppercase 
--      processes:                              "*_PROCESS" 
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity IDCT_Core is

  generic (
    C_DWIDTH : integer := 32
    );

  port (
    Clk   : in std_logic;
    Reset : in std_logic;

    In_Data_FIFO   : in  std_logic_vector(0 to C_DWIDTH-1);
    In_Data_Exists : in  std_logic;
    in_FIFO_Read   : out std_logic;

    Out_Data_FIFO  : out std_logic_vector(0 to C_DWIDTH-1);
    Out_FIFO_Full  : in  std_logic;
    Out_FIFO_Write : out std_logic);

end entity IDCT_Core;

library ieee;
use ieee.numeric_std.all;

library xil_idct_v1_00_a;
use xil_idct_v1_00_a.all;

architecture IMP of IDCT_Core is
  
  constant IDCT_IN_BITS : integer := 16;

  component idct
  port (
    Clk            : in  std_logic;
    Reset          : in  std_logic;
    Data_In        : in  std_logic_vector(15 downto 0);
    Data_In_Valid  : in  std_logic;
    Read_Data_In   : out std_logic;
    Data_Out_Full  : in  std_logic;
    Data_Out       : out std_logic_vector(31 downto 0);
    Data_Out_Valid : out std_logic
    );                                  -- \]
  end component idct;

begin  -- architecture IMP

  idct_instance : idct
    port map (
      Clk => Clk,
      Reset => Reset,
      Data_In => In_Data_FIFO(16 to 31),
      Data_In_Valid => In_Data_Exists,
      Read_Data_In => In_FIFO_Read,
      Data_Out_Full => Out_FIFO_Full,
      Data_Out => Out_Data_FIFO,
      Data_Out_Valid => Out_FIFO_Write);
end architecture IMP;
