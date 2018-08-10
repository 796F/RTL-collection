library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.blakePkg.all;

entity gcomp is
  port (
    AxDI    : in  std_logic_vector(WWIDTH-1 downto 0);
    BxDI    : in  std_logic_vector(WWIDTH-1 downto 0);
    CxDI    : in  std_logic_vector(WWIDTH-1 downto 0);
    DxDI    : in  std_logic_vector(WWIDTH-1 downto 0);
    MxDI    : in  std_logic_vector(WWIDTH*2-1 downto 0);
    KxDI    : in  std_logic_vector(WWIDTH*2-1 downto 0);
    AxDO    : out std_logic_vector(WWIDTH-1 downto 0);
    BxDO    : out std_logic_vector(WWIDTH-1 downto 0);
    CxDO    : out std_logic_vector(WWIDTH-1 downto 0);
    DxDO    : out std_logic_vector(WWIDTH-1 downto 0)
    );
  
end gcomp;

architecture hash of gcomp is

  signal T1, T4, T7, T10  : unsigned(WWIDTH-1 downto 0);
  signal T2, T3, T5, T6   : std_logic_vector(WWIDTH-1 downto 0);
  signal T8, T9, T11, T12 : std_logic_vector(WWIDTH-1 downto 0);
  signal TK1, TK2         : std_logic_vector(WWIDTH-1 downto 0);

begin  -- hash

    TK1 <= MxDI(WWIDTH*2-1 downto WWIDTH) xor KxDI(WWIDTH*2-1 downto WWIDTH);
    T1  <= unsigned(AxDI) + unsigned(BxDI) + unsigned(TK1);  
    T2  <= std_logic_vector(T1) xor DxDI;
    T3  <= T2(31 downto 0) & T2(WWIDTH-1 downto 32);
        
    T4  <= unsigned(CxDI) + unsigned(T3);
    T5  <= std_logic_vector(T4) xor BxDI;
    T6  <= T5(24 downto 0) & T5(WWIDTH-1 downto 25);

    ---------------------------------------------------------------------------

    TK2 <= MxDI(WWIDTH-1 downto 0) xor KxDI(WWIDTH-1 downto 0);
    T7  <= T1 + unsigned(T6) + unsigned(TK2);
    T8  <= std_logic_vector(T7) xor T3;
    T9  <= T8(15 downto 0) & T8(WWIDTH-1 downto 16);
        
    T10 <= T4 + unsigned(T9);
    T11 <= std_logic_vector(T10) xor T6;
    T12 <= T11(10 downto 0) & T11(WWIDTH-1 downto 11);

    AxDO <= std_logic_vector(T7);
    BxDO <= T12;
    CxDO <= std_logic_vector(T10);
    DxDO <= T9;
  

end hash;
