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

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity XIL_IDCT is
  generic (
    C_DWIDTH      : integer := 32
  );
  port (
    -- Global signals
    Clk   : in std_logic;
    Reset : in std_logic;

    -- Slave FSL Signals
    FSL_S_Clk     : out std_logic;
    FSL_S_Read    : out std_logic;
    FSL_S_Data    : in  std_logic_vector(0 to C_DWIDTH-1);
    FSL_S_Control : in  std_logic;
    FSL_S_Exists  : in  std_logic;

    -- Master FSL Signals
    FSL_M_Clk     : out std_logic;
    FSL_M_Write   : out std_logic;
    FSL_M_Data    : out std_logic_vector(0 to C_DWIDTH-1);
    FSL_M_Control : out std_logic;
    FSL_M_Full    : in  std_logic
    );

end entity XIL_IDCT;

library unisim;
use unisim.all;

library xil_idct_v1_00_a;
use xil_idct_v1_00_a.idct_core;

architecture IMP of XIL_IDCT is
  
  component IDCT_Core is
    generic (
      C_DWIDTH : integer := 32
      );
    port (
      Clk   : in std_logic;
      Reset : in std_logic;
      
      In_Data_FIFO   : in  std_logic_vector(0 to C_DWIDTH-1);    -- FSL0_S_Data bus --> read the data from the FSL FIFO
      In_Data_Exists : in  std_logic;                            -- if 0 the FSL fifo is empty --> no valid data on idct core
      in_FIFO_Read   : out std_logic;                            -- finish if the slave side has finished reading the data --> FSL_S_read = 1
      
      Out_Data_FIFO  : out std_logic_vector(0 to C_DWIDTH-1);    -- if FSL_M_Write = 1 data and control signal are pushed onto the FIFO
      Out_FIFO_Full  : in  std_logic;				 -- FSL1_M_Full, FIFO is full
      Out_FIFO_Write : out std_logic				 -- FSL_M_Write
      );
  end component IDCT_Core;
  
begin  -- architecture IMP

-----------------------------------------------------------------------------
-- Instanciating the IDCT core
-----------------------------------------------------------------------------
  IDCT_Core_I : IDCT_Core
    generic map (
      C_DWIDTH => C_DWIDTH              -- [integer]
      )
    port map (
      Clk            => Clk,            -- [in  std_logic]
      Reset          => Reset,            -- [in  std_logic]
      In_Data_FIFO   => FSL_S_Data,  -- [in  std_logic_vector(0 to C_DWIDTH-1)]
      In_Data_Exists => FSL_S_Exists,  -- [in  std_logic]
      in_FIFO_Read   => FSL_S_Read,    -- [out std_logic]      
      Out_Data_FIFO  => FSL_M_Data,  -- [out std_logic_vector(0 to C_DWIDTH-1)]
      Out_FIFO_Full  => FSL_M_Full,    -- [in  std_logic]
      Out_FIFO_Write => FSL_M_Write);  -- [out std_logic]

end architecture IMP;
