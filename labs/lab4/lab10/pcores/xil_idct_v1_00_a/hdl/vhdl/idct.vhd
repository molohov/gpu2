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
use IEEE.numeric_std.all;

library unisim;
use unisim.all;

entity iDCT is
  port (
    Clk            : in  std_logic;
    Reset          : in  std_logic;
    Data_In        : in  std_logic_vector(15 downto 0);
    Data_In_Valid  : in  std_logic;
    Read_Data_In   : out std_logic;
    Data_Out_Full  : in  std_logic;
    Data_Out       : out std_logic_vector(31 downto 0);
    Data_Out_Valid : out std_logic);  
end entity iDCT;



architecture IMP of iDCT is

  component FDE is
    port (
      Q  : out std_logic;
      C  : in  std_logic;
      CE : in  std_logic;
      D  : in  std_logic);
  end component FDE;


  component RAM16x1S is
    port (
      WE   : in  std_logic;
      D    : in  std_logic;
      WClk : in  std_logic;
      A0   : in  std_logic;
      A1   : in  std_logic;
      A2   : in  std_logic;
      A3   : in  std_logic;
      O    : out std_logic);
  end component RAM16x1S;

  component MULT18x18S is
    port (
      A  : in  std_logic_vector(17 downto 0);
      B  : in  std_logic_vector(17 downto 0);
      C  : in  std_logic;
      CE : in  std_logic;
      R  : in  std_logic;
      P  : out std_logic_vector(35 downto 0));
  end component MULT18x18S;
  
  subtype COEFF_TYPE is signed(15 downto 0);
  type    COEFF_ARRAY_TYPE is array (natural range 0 to 7) of COEFF_TYPE;
  type    COEFF_MATRIX_TYPE is array (natural range 0 to 7) of COEFF_ARRAY_TYPE;

  constant Coeff_T : COEFF_MATRIX_TYPE := (
    0 => (
      to_signed(16384, COEFF_TYPE'length),
      to_signed(22725, COEFF_TYPE'length),
      to_signed(21407, COEFF_TYPE'length),
      to_signed(19266, COEFF_TYPE'length),
      to_signed(16384, COEFF_TYPE'length),
      to_signed(12873, COEFF_TYPE'length),
      to_signed(8867, COEFF_TYPE'length),
      to_signed(4520, COEFF_TYPE'length)
      ),
    1 => (
      to_signed(16384, COEFF_TYPE'length),
      to_signed(19266, COEFF_TYPE'length),
      to_signed(8867, COEFF_TYPE'length),
      to_signed(-4521, COEFF_TYPE'length),
      to_signed(-16384, COEFF_TYPE'length),
      to_signed(-22726, COEFF_TYPE'length),
      to_signed(-21407, COEFF_TYPE'length),
      to_signed(-12873, COEFF_TYPE'length)
      ),
    2 => (
      to_signed(16384, COEFF_TYPE'length),
      to_signed(12873, COEFF_TYPE'length),
      to_signed(-8867, COEFF_TYPE'length),
      to_signed(-22726, COEFF_TYPE'length),
      to_signed(-16385, COEFF_TYPE'length),
      to_signed(4520, COEFF_TYPE'length),
      to_signed(21407, COEFF_TYPE'length),
      to_signed(19266, COEFF_TYPE'length)
      ),
    3 => (
      to_signed(16384, COEFF_TYPE'length),
      to_signed(4520, COEFF_TYPE'length),
      to_signed(-21407, COEFF_TYPE'length),
      to_signed(-12873, COEFF_TYPE'length),
      to_signed(16384, COEFF_TYPE'length),
      to_signed(19266, COEFF_TYPE'length),
      to_signed(-8867, COEFF_TYPE'length),
      to_signed(-22726, COEFF_TYPE'length)
      ),
    4 => (
      to_signed(16384, COEFF_TYPE'length),
      to_signed(-4521, COEFF_TYPE'length),
      to_signed(-21407, COEFF_TYPE'length),
      to_signed(12873, COEFF_TYPE'length),
      to_signed(16384, COEFF_TYPE'length),
      to_signed(-19266, COEFF_TYPE'length),
      to_signed(-8867, COEFF_TYPE'length),
      to_signed(22725, COEFF_TYPE'length)
      ),
    5 => (
      to_signed(16384, COEFF_TYPE'length),
      to_signed(-12873, COEFF_TYPE'length),
      to_signed(-8867, COEFF_TYPE'length),
      to_signed(22725, COEFF_TYPE'length),
      to_signed(-16384, COEFF_TYPE'length),
      to_signed(-4521, COEFF_TYPE'length),
      to_signed(21407, COEFF_TYPE'length),
      to_signed(-19266, COEFF_TYPE'length)
      ),
    6 => (
      to_signed(16384, COEFF_TYPE'length),
      to_signed(-19266, COEFF_TYPE'length),
      to_signed(8867, COEFF_TYPE'length),
      to_signed(4520, COEFF_TYPE'length),
      to_signed(-16385, COEFF_TYPE'length),
      to_signed(22725, COEFF_TYPE'length),
      to_signed(-21407, COEFF_TYPE'length),
      to_signed(12873, COEFF_TYPE'length)
      ),
    7 => (
      to_signed(16384, COEFF_TYPE'length),
      to_signed(-22726, COEFF_TYPE'length),
      to_signed(21407, COEFF_TYPE'length),
      to_signed(-19266, COEFF_TYPE'length),
      to_signed(16384, COEFF_TYPE'length),
      to_signed(-12873, COEFF_TYPE'length),
      to_signed(8867, COEFF_TYPE'length),
      to_signed(-4521, COEFF_TYPE'length)
      )
    );

  signal move_pipeline     : std_logic;
  signal move_in_pipeline  : std_logic;
  signal move_out_pipeline : std_logic;

  signal Index         : natural range 0 to 7;
  signal Index_1       : natural range 0 to 7;
  signal Index_2       : natural range 0 to 7;
  signal Word          : natural range 0 to 7;
  signal Word_1        : natural range 0 to 7;
  signal First_Cycle   : std_logic;
  signal First_Cycle_1 : std_logic;
  signal Last_Cycle    : std_logic;

  subtype MAC_RESULT_TYPE is std_logic_vector(31 downto 0);

  signal MAC_Result          : MAC_RESULT_TYPE;
  signal New_MAC_Result      : MAC_RESULT_TYPE;
--  signal Wr_New_MAC_Result_i : std_logic;
  signal Wr_New_MAC_Result   : std_logic;
  signal Wr_New_MAC_Result_1 : std_logic;
  signal Wr_New_MAC_Result_2 : std_logic;

  signal Writing_Result   : std_logic;
  signal Writing_Result_i : std_logic;

  signal mul_op_a : std_logic_vector(Data_In'range);
  signal mul_op_b : COEFF_TYPE;
  
  signal mult_op_a : std_logic_vector(17 downto 0);
  signal mult_op_b : std_logic_vector(17 downto 0);
  signal mult_res  : std_logic_vector(35 downto 0);
  signal mult_en   : std_logic;
  
  signal last_cycle_1 : std_logic;
  signal last_cycle_2 : std_logic;

  subtype MUL_RESULT_TYPE is std_logic_vector(31 downto 0);
  signal  MUL_Result : MUL_RESULT_TYPE;

  signal ram_addr : std_logic_vector(2 downto 0);

  signal Data_Out_Valid_i : std_logic;
  signal write_out_phase  : std_logic;
  
  
begin  -- architecture IMP


  Index_Handle : process (Clk, Reset) is
  begin  -- process Index_Handle
    if Reset = '1' then                 -- asynchronous reset (active high)
      Index   <= 0;
      Index_1 <= 0;
    elsif Clk'event and Clk = '1' then  -- rising clock edge
      if (move_in_pipeline = '1') then
        Index   <= (Index + 1) mod 8;
        Index_1 <= Index;
      end if;
    end if;
  end process Index_Handle;


  Word_Handle : process (Clk, Reset) is
  begin  -- process Word_Handle
    if Reset = '1' then                 -- asynchronous reset (active high)
      Word   <= 0;
      Word_1 <= 0;
    elsif Clk'event and Clk = '1' then  -- rising clock edge
      if (move_in_pipeline = '1') and (Index = 7) then
        Word <= (Word + 1) mod 8;
      end if;
      Word_1 <= Word;
    end if;
  end process Word_Handle;

  First_Cycle <= '1' when (Word = 0)                          else '0';
  Last_Cycle  <= '1' when (Index = 7) and move_in_pipeline = '1' else '0';

  Read_Data_In <= Last_Cycle;

  Control_Pipeline : process (write_out_phase, Index, Data_In_Valid, Data_Out_Full) is
  begin  -- process Control_Pipeline
    if ((write_out_phase = '1')) then
      move_in_pipeline <= Data_In_Valid and not Data_Out_Full;
      move_out_pipeline <= not Data_Out_Full;
    else
      if (Index = 0) then
        move_in_pipeline <= Data_In_Valid;
        move_out_pipeline <= '0';
      else
        move_in_pipeline <= '1';
        move_out_pipeline <= '0';
      end if;
    end if;
  end process Control_Pipeline;

  Clk_Mul_Inputs : process (Clk, Reset) is
    variable Wr_New_MAC_Result_i : std_logic;
  begin  -- process Clk_Mul_Inputs
    if Reset = '1' then                 -- asynchronous reset (active high)
      mul_op_a            <= (others => '0');
      mul_op_b            <= (others => '0');
      First_Cycle_1       <= '0';
      Wr_New_MAC_Result_i := '0';
      Wr_New_MAC_Result   <= '0';
    elsif Clk'event and Clk = '1' then  -- rising clock edge
      Wr_New_MAC_Result <= '0';
      if (index = 0) then
        Wr_New_MAC_Result_i := Data_In_Valid;
      end if;
      if (move_in_pipeline = '1') then
        First_Cycle_1 <= First_Cycle;
        mul_op_a      <= Data_In;
        mul_op_b      <= Coeff_T(Index)(Word);
        if (word /= 7) then
          Wr_New_MAC_Result <= Wr_New_MAC_Result_i;
        end if;
      end if;
    end if;
  end process Clk_Mul_Inputs;

  Mul_DFF: process (Clk) is
  begin  -- process Mul_DFF
    if Clk'event and Clk = '1' then  -- rising clock edge
      Wr_New_MAC_Result_1 <= Wr_New_MAC_Result;
      Wr_New_MAC_Result_2 <= Wr_New_MAC_Result_1;
      if (mult_en = '1') then
        index_2 <= index_1;
        ram_addr <= std_logic_vector(to_unsigned(Index_2, 3));
      end if;
      last_cycle_1 <= last_cycle;
      last_cycle_2 <= last_cycle_1;
    end if;
  end process Mul_DFF;

  mult_en <= move_out_pipeline when Writing_Result = '1' else move_in_pipeline or last_cycle_1 or last_cycle_2;
  
  mult_op_a <= mul_op_a(mul_op_a'left) & mul_op_a(mul_op_a'left) & mul_op_a;
  mult_op_b <= mul_op_b(mul_op_b'left) & mul_op_b(mul_op_b'left) & std_logic_vector(mul_op_b);
  
  MULT18x18S_I1 : MULT18x18S
    port map (
      A  => mult_op_a,                  -- [in  std_logic_vector(17 downto 0)]
      B  => mult_op_b,                  -- [in  std_logic_vector(17 downto 0)]
      C  => Clk,                        -- [in  std_logic]
      CE => mult_en,                    -- [in  std_logic]
      R  => reset,                      -- [in  std_logic]
      P  => mult_res);                  -- [out std_logic_vector(35 downto 0)]

  Mult_Res_DFF: process (Clk) is

  begin  -- process Mult_Res_DFF
    if Clk'event and Clk = '1' then  -- rising clock edge
      if (mult_en = '1') then
        MUL_Result <= mult_res(MUL_Result'range);
      end if;
    end if;
  end process Mult_Res_DFF;
  
  MAC_Operation : process (MUL_Result, MAC_Result, First_Cycle_1) is
    variable Oper2 : MAC_RESULT_TYPE;
    variable tmp   : MAC_RESULT_TYPE;
  begin  -- process MAC_Operation
    for J in MAC_RESULT_TYPE'range loop
      Oper2(J) := MAC_Result(J) and not First_Cycle_1;
    end loop;
    tmp                        := (others => MUL_Result(MUL_RESULT_TYPE'high));
    tmp(MUL_RESULT_TYPE'range) := MUL_Result;
    New_MAC_Result             <= std_logic_vector(unsigned(Oper2) + unsigned(tmp));
  end process MAC_Operation;


  All_MAC_Result_Bits : for I in MAC_RESULT_TYPE'range generate
    RAM16x1_I : RAM16x1S
      port map (
        WE   => Wr_New_MAC_Result_2,    -- [in  std_logic]
        D    => New_MAC_Result(I),      -- [in  std_logic]
        WClk => Clk,                    -- [in  std_logic]
        A0   => ram_addr(0),            -- [in  std_logic]
        A1   => ram_addr(1),            -- [in  std_logic]
        A2   => ram_addr(2),            -- [in  std_logic]
        A3   => '0',                    -- [in  std_logic]
        O    => MAC_Result(I));         -- [out std_logic]
  end generate All_MAC_Result_Bits;

  Out_Data_Control : process (Clk, Reset) is
    variable Writing_Result_1 : std_logic;
    variable no_words         : natural range 0 to 8;
  begin  -- process Out_Data_Control
    if Reset = '1' then                 -- asynchronous reset (active high)
      Data_Out_Valid_i <= '0';
      Writing_Result_1 := '0';
      no_words         := 0;
      Writing_Result   <= '0';
      write_out_phase  <= '0';
    elsif Clk'event and Clk = '1' then  -- rising clock edge
      Data_Out_Valid_i <= Writing_Result_1;
      if ((word = 7) and (index_2 = 0) and (Data_In_Valid = '1')) then
        no_words := 8;
      end if;
      if (move_out_pipeline = '1') then
        Writing_Result_1 := Writing_Result;
      end if;
      if ((no_words /= 0)) then
        if (Data_Out_Valid_i and move_out_pipeline) = '1' then
          no_words := no_words - 1;
        end if;
      end if;
      if ((no_words /= 0)) then
        write_out_phase <= '1';
        Writing_Result <= '1';
      else
        Writing_Result   <= '0';
        Writing_Result_1 := '0';
        Data_Out_Valid_i <= '0';
        write_out_phase  <= '0';
      end if;
    end if;
  end process Out_Data_Control;

  Data_Out_Valid <= Data_Out_Valid_i and move_out_pipeline;

  Out_Data : process (Clk, Reset) is
    variable Writing_Result_1 : std_logic;
    variable New_MAC_Result_1 : std_logic_vector(New_MAC_Result'range);
    variable tmp              : std_logic_vector(31 downto 0);
    variable tmp2             : std_logic_vector(20 downto 0);
    variable no_words         : natural range 0 to 8;
  begin  -- process Out_Data
    if Reset = '1' then                 -- asynchronous reset (active high)
      Data_Out         <= (others => '0');
      New_MAC_Result_1 := (others => '0');
    elsif Clk'event and Clk = '1' then  -- rising clock edge
      if (move_out_pipeline = '1') then
        tmp2             := std_logic_vector(signed(New_MAC_Result_1(31 downto 11)) + 1);
        tmp              := (others => tmp2(20));
        tmp(19 downto 0) := tmp2(20 downto 1);
        Data_Out         <= tmp;
        New_MAC_Result_1 := New_MAC_Result;
      end if;
    end if;
  end process Out_Data;
  
end architecture IMP;
