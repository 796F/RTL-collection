library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.blakePkg.all;

entity finalization is
  port (
    VxDI   : in  std_logic_vector(WWIDTH*16-1 downto 0);
    HxDI   : in  std_logic_vector(WWIDTH*8-1 downto 0);
    SxDI   : in  std_logic_vector(WWIDTH*4-1 downto 0);
    HxDO   : out std_logic_vector(WWIDTH*8-1 downto 0)
    );

end finalization;

architecture hash of finalization is

  type SUB4 is array (3 downto 0) of std_logic_vector(WWIDTH-1 downto 0);
  type SUB8 is array (7 downto 0) of std_logic_vector(WWIDTH-1 downto 0);
  type SUB16 is array (15 downto 0) of std_logic_vector(WWIDTH-1 downto 0);

  signal SINxD         : SUB4;
  signal HINxD, HOUTxD : SUB8;
  signal VxD           : SUB16;
  
begin  -- hash

  p_unform4: for i in 0 to 3 generate
    SINxD(i) <= SxDI(WWIDTH*(i+1)-1 downto WWIDTH*i);
  end generate p_unform4;

  p_unform8: for i in 0 to 7 generate
    HINxD(i) <= HxDI(WWIDTH*(i+1)-1 downto WWIDTH*i);
    HxDO(WWIDTH*(i+1)-1 downto WWIDTH*i) <= HOUTxD(i);
  end generate p_unform8;

  p_unform16: for i in 0 to 15 generate
    VxD(i) <= VxDI(WWIDTH*(i+1)-1 downto WWIDTH*i);
  end generate p_unform16;

  HOUTxD(0) <= HINxD(0) xor VxD(0) xor VxD(8)  xor SINxD(0);
  HOUTxD(1) <= HINxD(1) xor VxD(1) xor VxD(9)  xor SINxD(1);
  HOUTxD(2) <= HINxD(2) xor VxD(2) xor VxD(10) xor SINxD(2);
  HOUTxD(3) <= HINxD(3) xor VxD(3) xor VxD(11) xor SINxD(3);
  HOUTxD(4) <= HINxD(4) xor VxD(4) xor VxD(12) xor SINxD(0);
  HOUTxD(5) <= HINxD(5) xor VxD(5) xor VxD(13) xor SINxD(1);
  HOUTxD(6) <= HINxD(6) xor VxD(6) xor VxD(14) xor SINxD(2);
  HOUTxD(7) <= HINxD(7) xor VxD(7) xor VxD(15) xor SINxD(3);
  
end hash;
