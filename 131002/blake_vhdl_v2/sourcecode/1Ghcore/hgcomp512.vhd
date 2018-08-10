library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.blakePkg.all;

entity hgcomp is
  port (
    JCNTxSI : in  std_logic;
    AxDI    : in  std_logic_vector(WWIDTH-1 downto 0);
    BxDI    : in  std_logic_vector(WWIDTH-1 downto 0);
    CxDI    : in  std_logic_vector(WWIDTH-1 downto 0);
    DxDI    : in  std_logic_vector(WWIDTH-1 downto 0);
    MxDI    : in  std_logic_vector(WWIDTH-1 downto 0);
    KxDI    : in  std_logic_vector(WWIDTH-1 downto 0);
    AxDO    : out std_logic_vector(WWIDTH-1 downto 0);
    BxDO    : out std_logic_vector(WWIDTH-1 downto 0);
    CxDO    : out std_logic_vector(WWIDTH-1 downto 0);
    DxDO    : out std_logic_vector(WWIDTH-1 downto 0)
    );
  
end hgcomp;

architecture hash of hgcomp is
  
  signal T1, T4         : unsigned(WWIDTH-1 downto 0);
  signal T2, T3, T5, T6 : std_logic_vector(WWIDTH-1 downto 0);
  signal TK1            : std_logic_vector(WWIDTH-1 downto 0);
  
begin

  TK1 <= MxDI xor KxDI;
  T1  <= unsigned(AxDI) + unsigned(BxDI) + unsigned(TK1);
      
  T2  <= std_logic_vector(T1) xor DxDI;

  T4  <= unsigned(CxDI) + unsigned(T3);
      
  T5  <= std_logic_vector(T4) xor BxDI;

  process (JCNTxSI, T2, T5)
  begin  -- process

    if JCNTxSI = '0' then
      T3  <= T2(31 downto 0) & T2(WWIDTH-1 downto 32);
      T6  <= T5(24 downto 0) & T5(WWIDTH-1 downto 25);
    else
      T3  <= T2(15 downto 0) & T2(WWIDTH-1 downto 16);
      T6  <= T5(10 downto 0) & T5(WWIDTH-1 downto 11);
    end if;
    
  end process;

  AxDO <= std_logic_vector(T1);
  BxDO <= T6;
  CxDO <= std_logic_vector(T4);
  DxDO <= T3;
  
end hash;
