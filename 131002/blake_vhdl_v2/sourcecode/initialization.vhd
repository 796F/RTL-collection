library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.blakePkg.all;

entity initialization is
  port (
    HxDI  : in  std_logic_vector(WWIDTH*8-1 downto 0);
    SxDI  : in  std_logic_vector(WWIDTH*4-1 downto 0);
    TxDI  : in  std_logic_vector(WWIDTH*2-1 downto 0);
    VxDO  : out std_logic_vector(WWIDTH*16-1 downto 0)
    );

end initialization;

architecture hash of initialization is

begin  -- hash

  VxDO(WWIDTH*16-1 downto WWIDTH*8) <= HxDI;

  VxDO(WWIDTH*8-1 downto WWIDTH*7) <= SxDI(WWIDTH*4-1 downto WWIDTH*3) xor C(0);
  VxDO(WWIDTH*7-1 downto WWIDTH*6) <= SxDI(WWIDTH*3-1 downto WWIDTH*2) xor C(1);
  VxDO(WWIDTH*6-1 downto WWIDTH*5) <= SxDI(WWIDTH*2-1 downto WWIDTH)   xor C(2);
  VxDO(WWIDTH*5-1 downto WWIDTH*4) <= SxDI(WWIDTH-1 downto 0)          xor C(3);

  VxDO(WWIDTH*4-1 downto WWIDTH*3) <= TxDI(WWIDTH*2-1 downto WWIDTH) xor C(4);
  VxDO(WWIDTH*3-1 downto WWIDTH*2) <= TxDI(WWIDTH*2-1 downto WWIDTH) xor C(5);
  VxDO(WWIDTH*2-1 downto WWIDTH)   <= TxDI(WWIDTH-1 downto 0)        xor C(6);
  VxDO(WWIDTH-1 downto 0)          <= TxDI(WWIDTH-1 downto 0)        xor C(7);
  
end hash;
