library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity latchblockfinal is
  generic (
    SIZE : integer := 32
    );
  port (
    ClkxCI  : in  std_logic;
    DxDI    : in  std_logic_vector(SIZE-1 downto 0);
    DxDO    : out std_logic_vector(SIZE-1 downto 0)
    );
end latchblockfinal;

architecture rtl of latchblockfinal is

begin  -- rtl

  p_mem: process (ClkxCI, DxDI)
  begin  -- process p_mem
    if ClkxCI = '1' then  -- rising clock edge
      DxDO <= DxDI;
      
    end if;
  end process p_mem;
  
end rtl;
