library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.blakePkg.all;

entity roundreg is
  port (
    CLKxCI   : in  std_logic;
    RSTxRBI  : in  std_logic;
    WEIxSI   : in  std_logic;
    ICNTxSI  : in  unsigned(3 downto 0);
    ROUNDxSI : in  unsigned(3 downto 0);
    VxDI     : in  std_logic_vector(WWIDTH*16-1 downto 0);
    MxDI     : in  std_logic_vector(WWIDTH*16-1 downto 0);
    VxDO     : out std_logic_vector(WWIDTH*16-1 downto 0)
    );

end roundreg;

architecture hash of roundreg is
  
  component gcomp
    port (
      AxDI : in  std_logic_vector(WWIDTH-1 downto 0);
      BxDI : in  std_logic_vector(WWIDTH-1 downto 0);
      CxDI : in  std_logic_vector(WWIDTH-1 downto 0);
      DxDI : in  std_logic_vector(WWIDTH-1 downto 0);
      MxDI : in  std_logic_vector(WWIDTH*2-1 downto 0);
      KxDI : in  std_logic_vector(WWIDTH*2-1 downto 0);
      AxDO : out std_logic_vector(WWIDTH-1 downto 0);
      BxDO : out std_logic_vector(WWIDTH-1 downto 0);
      CxDO : out std_logic_vector(WWIDTH-1 downto 0);
      DxDO : out std_logic_vector(WWIDTH-1 downto 0)
      );
  end component;

  type SUBT16 is array (15 downto 0) of std_logic_vector(WWIDTH-1 downto 0);

  signal VxDN, VxDP, MxD                 : SUBT16;
  
  signal G0AxD, G0BxD, G0CxD, G0DxD      : std_logic_vector(WWIDTH-1 downto 0);
  signal G0MxD, G0KxD                    : std_logic_vector(WWIDTH*2-1 downto 0);
  signal G0AOxD, G0BOxD, G0COxD, G0DOxD  : std_logic_vector(WWIDTH-1 downto 0);
  
  
begin  -- hash

  p_unform: for i in 15 downto 0 generate
    MxD(15-i) <= MxDI(WWIDTH*(i+1)-1 downto WWIDTH*i);
  end generate p_unform;

  VxDO <= VxDP(0)  & VxDP(1)  & VxDP(2)  & VxDP(3)  &
          VxDP(4)  & VxDP(5)  & VxDP(6)  & VxDP(7)  &
          VxDP(8)  & VxDP(9)  & VxDP(10) & VxDP(11) &
          VxDP(12) & VxDP(13) & VxDP(14) & VxDP(15);
  
  -----------------------------------------------------------------------------
  -- MEMORY INPUTS
  -----------------------------------------------------------------------------
  p_inmem: process (G0AOxD, G0BOxD, G0COxD, G0DOxD, VxDI, VxDP, WEIxSI, ICNTxSI)
  begin  -- process p_inmem

    VxDN <= VxDP;

    if WEIxSI = '1' then
      for i in 15 downto 0 loop
        VxDN(15-i) <= VxDI(WWIDTH*(i+1)-1 downto WWIDTH*i);
        
      end loop;

    else
      VxDN(IMATRIX(to_integer(ICNTxSI),  0)) <= G0AOxD;
      VxDN(IMATRIX(to_integer(ICNTxSI),  1)) <= G0BOxD;
      VxDN(IMATRIX(to_integer(ICNTxSI),  2)) <= G0COxD;
      VxDN(IMATRIX(to_integer(ICNTxSI),  3)) <= G0DOxD;
   
    end if;
  end process p_inmem;

  -----------------------------------------------------------------------------
  -- G INPUTS
  -----------------------------------------------------------------------------
  p_outmem: process (ICNTxSI, MxD, ROUNDxSI, VxDP)
  begin  -- process p_outmem

    G0AxD <= VxDP(IMATRIX(to_integer(ICNTxSI), 0));
    G0BxD <= VxDP(IMATRIX(to_integer(ICNTxSI), 1));
    G0CxD <= VxDP(IMATRIX(to_integer(ICNTxSI), 2));
    G0DxD <= VxDP(IMATRIX(to_integer(ICNTxSI), 3));
    G0MxD <=  MxD(PMATRIX((to_integer(ROUNDxSI))mod 10, to_integer(ICNTxSI)*2)) &
              MxD(PMATRIX((to_integer(ROUNDxSI))mod 10, to_integer(ICNTxSI)*2+1));
    G0KxD <=    C(PMATRIX((to_integer(ROUNDxSI))mod 10, to_integer(ICNTxSI)*2+1)) &
                C(PMATRIX((to_integer(ROUNDxSI))mod 10, to_integer(ICNTxSI)*2));

  end process p_outmem;  

  -----------------------------------------------------------------------------
  -- G BLOCK
  -----------------------------------------------------------------------------
  
  u_gcomp0: gcomp
    port map (
      AxDI => G0AxD,
      BxDI => G0BxD,
      CxDI => G0CxD,
      DxDI => G0DxD,
      MxDI => G0MxD,
      KxDI => G0KxD,
      AxDO => G0AOxD,
      BxDO => G0BOxD,
      CxDO => G0COxD,
      DxDO => G0DOxD
      );

  
  -----------------------------------------------------------------------------
  -- V MEMORY
  -----------------------------------------------------------------------------
  p_mem: process (CLKxCI, RSTxRBI)
  begin  -- process p_vmem
    if RSTxRBI = '0' then               -- asynchronous reset (active low)
      VxDP <= (others => (others => '0'));
      
    elsif CLKxCI'event and CLKxCI = '1' then  -- rising clock edge
      VxDP <= VxDN;

    end if;
  end process p_mem;
  
end hash;
