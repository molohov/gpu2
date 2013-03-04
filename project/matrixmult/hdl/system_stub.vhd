-------------------------------------------------------------------------------
-- system_stub.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity system_stub is
  port (
    CLK_N : in std_logic;
    CLK_P : in std_logic
  );
end system_stub;

architecture STRUCTURE of system_stub is

  component system is
    port (
      CLK_N : in std_logic;
      CLK_P : in std_logic
    );
  end component;

  attribute BOX_TYPE : STRING;
  attribute BOX_TYPE of system : component is "user_black_box";

begin

  system_i : system
    port map (
      CLK_N => CLK_N,
      CLK_P => CLK_P
    );

end architecture STRUCTURE;

