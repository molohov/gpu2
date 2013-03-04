-------------------------------------------------------------------------------
-- system.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity system is
  port (
    CLK_N : in std_logic;
    CLK_P : in std_logic
  );
end system;

architecture STRUCTURE of system is

  component system_clock_generator_0_wrapper is
    port (
      CLKIN : in std_logic;
      CLKOUT0 : out std_logic;
      CLKOUT1 : out std_logic;
      CLKOUT2 : out std_logic;
      CLKOUT3 : out std_logic;
      CLKOUT4 : out std_logic;
      CLKOUT5 : out std_logic;
      CLKOUT6 : out std_logic;
      CLKOUT7 : out std_logic;
      CLKOUT8 : out std_logic;
      CLKOUT9 : out std_logic;
      CLKOUT10 : out std_logic;
      CLKOUT11 : out std_logic;
      CLKOUT12 : out std_logic;
      CLKOUT13 : out std_logic;
      CLKOUT14 : out std_logic;
      CLKOUT15 : out std_logic;
      CLKFBIN : in std_logic;
      CLKFBOUT : out std_logic;
      PSCLK : in std_logic;
      PSEN : in std_logic;
      PSINCDEC : in std_logic;
      PSDONE : out std_logic;
      RST : in std_logic;
      LOCKED : out std_logic
    );
  end component;

  component system_reset_0_wrapper is
    port (
      Slowest_sync_clk : in std_logic;
      Ext_Reset_In : in std_logic;
      Aux_Reset_In : in std_logic;
      MB_Debug_Sys_Rst : in std_logic;
      Core_Reset_Req_0 : in std_logic;
      Chip_Reset_Req_0 : in std_logic;
      System_Reset_Req_0 : in std_logic;
      Core_Reset_Req_1 : in std_logic;
      Chip_Reset_Req_1 : in std_logic;
      System_Reset_Req_1 : in std_logic;
      Dcm_locked : in std_logic;
      RstcPPCresetcore_0 : out std_logic;
      RstcPPCresetchip_0 : out std_logic;
      RstcPPCresetsys_0 : out std_logic;
      RstcPPCresetcore_1 : out std_logic;
      RstcPPCresetchip_1 : out std_logic;
      RstcPPCresetsys_1 : out std_logic;
      MB_Reset : out std_logic;
      Bus_Struct_Reset : out std_logic_vector(0 to 0);
      Peripheral_Reset : out std_logic_vector(0 to 0);
      Interconnect_aresetn : out std_logic_vector(0 to 0);
      Peripheral_aresetn : out std_logic_vector(0 to 0)
    );
  end component;

  component IBUFGDS is
    port (
      I : in std_logic;
      IB : in std_logic;
      O : out std_logic
    );
  end component;

  -- Internal signals

  signal CLK : std_logic;
  signal clock_generator_0_LOCKED_0 : std_logic;
  signal net_gnd0 : std_logic;

  attribute BOX_TYPE : STRING;
  attribute BOX_TYPE of system_clock_generator_0_wrapper : component is "user_black_box";
  attribute BOX_TYPE of system_reset_0_wrapper : component is "user_black_box";

begin

  -- Internal assignments

  net_gnd0 <= '0';

  clock_generator_0 : system_clock_generator_0_wrapper
    port map (
      CLKIN => CLK,
      CLKOUT0 => open,
      CLKOUT1 => open,
      CLKOUT2 => open,
      CLKOUT3 => open,
      CLKOUT4 => open,
      CLKOUT5 => open,
      CLKOUT6 => open,
      CLKOUT7 => open,
      CLKOUT8 => open,
      CLKOUT9 => open,
      CLKOUT10 => open,
      CLKOUT11 => open,
      CLKOUT12 => open,
      CLKOUT13 => open,
      CLKOUT14 => open,
      CLKOUT15 => open,
      CLKFBIN => net_gnd0,
      CLKFBOUT => open,
      PSCLK => net_gnd0,
      PSEN => net_gnd0,
      PSINCDEC => net_gnd0,
      PSDONE => open,
      RST => net_gnd0,
      LOCKED => clock_generator_0_LOCKED_0
    );

  reset_0 : system_reset_0_wrapper
    port map (
      Slowest_sync_clk => net_gnd0,
      Ext_Reset_In => net_gnd0,
      Aux_Reset_In => net_gnd0,
      MB_Debug_Sys_Rst => net_gnd0,
      Core_Reset_Req_0 => net_gnd0,
      Chip_Reset_Req_0 => net_gnd0,
      System_Reset_Req_0 => net_gnd0,
      Core_Reset_Req_1 => net_gnd0,
      Chip_Reset_Req_1 => net_gnd0,
      System_Reset_Req_1 => net_gnd0,
      Dcm_locked => clock_generator_0_LOCKED_0,
      RstcPPCresetcore_0 => open,
      RstcPPCresetchip_0 => open,
      RstcPPCresetsys_0 => open,
      RstcPPCresetcore_1 => open,
      RstcPPCresetchip_1 => open,
      RstcPPCresetsys_1 => open,
      MB_Reset => open,
      Bus_Struct_Reset => open,
      Peripheral_Reset => open,
      Interconnect_aresetn => open,
      Peripheral_aresetn => open
    );

  ibufgds_0 : IBUFGDS
    port map (
      I => CLK_P,
      IB => CLK_N,
      O => CLK
    );

end architecture STRUCTURE;

