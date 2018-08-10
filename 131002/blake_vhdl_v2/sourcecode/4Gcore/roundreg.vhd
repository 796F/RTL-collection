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
    ICNTxSI  : in  unsigned(0 downto 0);
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

  signal G0MxD, G0KxD                    : std_logic_vector(WWIDTH*2-1 downto 0);
  signal G1MxD, G1KxD                    : std_logic_vector(WWIDTH*2-1 downto 0);
  signal G2MxD, G2KxD                    : std_logic_vector(WWIDTH*2-1 downto 0);
  signal G3MxD, G3KxD                    : std_logic_vector(WWIDTH*2-1 downto 0);

  signal G0AxD, G0BxD, G0CxD, G0DxD      : std_logic_vector(WWIDTH-1 downto 0);
  signal G1AxD, G1BxD, G1CxD, G1DxD      : std_logic_vector(WWIDTH-1 downto 0);
  signal G2AxD, G2BxD, G2CxD, G2DxD      : std_logic_vector(WWIDTH-1 downto 0);
  signal G3AxD, G3BxD, G3CxD, G3DxD      : std_logic_vector(WWIDTH-1 downto 0);

  signal G0AOxD, G0BOxD, G0COxD, G0DOxD  : std_logic_vector(WWIDTH-1 downto 0);
  signal G1AOxD, G1BOxD, G1COxD, G1DOxD  : std_logic_vector(WWIDTH-1 downto 0);
  signal G2AOxD, G2BOxD, G2COxD, G2DOxD  : std_logic_vector(WWIDTH-1 downto 0);
  signal G3AOxD, G3BOxD, G3COxD, G3DOxD  : std_logic_vector(WWIDTH-1 downto 0);
  
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
  p_inmem: process (G0AOxD, G0BOxD, G0COxD, G0DOxD, G1AOxD, G1BOxD, G1COxD,
                    G1DOxD, G2AOxD, G2BOxD, G2COxD, G2DOxD, G3AOxD, G3BOxD,
                    G3COxD, G3DOxD, VxDI, VxDP, WEIxSI, ICNTxSI)
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
                                                  
      VxDN(IMATRIX(to_integer(ICNTxSI),  4)) <= G1AOxD;
      VxDN(IMATRIX(to_integer(ICNTxSI),  5)) <= G1BOxD;
      VxDN(IMATRIX(to_integer(ICNTxSI),  6)) <= G1COxD;
      VxDN(IMATRIX(to_integer(ICNTxSI),  7)) <= G1DOxD;
                                                  
      VxDN(IMATRIX(to_integer(ICNTxSI),  8)) <= G2AOxD;
      VxDN(IMATRIX(to_integer(ICNTxSI),  9)) <= G2BOxD;
      VxDN(IMATRIX(to_integer(ICNTxSI), 10)) <= G2COxD;
      VxDN(IMATRIX(to_integer(ICNTxSI), 11)) <= G2DOxD;
                                                  
      VxDN(IMATRIX(to_integer(ICNTxSI), 12)) <= G3AOxD;
      VxDN(IMATRIX(to_integer(ICNTxSI), 13)) <= G3BOxD;
      VxDN(IMATRIX(to_integer(ICNTxSI), 14)) <= G3COxD;
      VxDN(IMATRIX(to_integer(ICNTxSI), 15)) <= G3DOxD; 
   
    end if;
  end process p_inmem;

  -----------------------------------------------------------------------------
  -- G INPUTS
  -----------------------------------------------------------------------------
  p_outmem: process (MxD, ROUNDxSI, VxDP, ICNTxSI)
    variable IND : integer;
  begin  -- process p_outmem

    IND := (to_integer(ROUNDxSI))mod 10;

    G0AxD <= VxDP(IMATRIX(to_integer(ICNTxSI), 0));
    G0BxD <= VxDP(IMATRIX(to_integer(ICNTxSI), 1));
    G0CxD <= VxDP(IMATRIX(to_integer(ICNTxSI), 2));
    G0DxD <= VxDP(IMATRIX(to_integer(ICNTxSI), 3));
    G0MxD <=  MxD(PMATRIX(IND, to_integer(ICNTxSI)*8)) &
              MxD(PMATRIX(IND, to_integer(ICNTxSI)*8+1));
    G0KxD <=    C(PMATRIX(IND, to_integer(ICNTxSI)*8+1)) &
                C(PMATRIX(IND, to_integer(ICNTxSI)*8));
    
          
    G1AxD <= VxDP(IMATRIX(to_integer(ICNTxSI), 4));
    G1BxD <= VxDP(IMATRIX(to_integer(ICNTxSI), 5));
    G1CxD <= VxDP(IMATRIX(to_integer(ICNTxSI), 6));
    G1DxD <= VxDP(IMATRIX(to_integer(ICNTxSI), 7));
    G1MxD <=  MxD(PMATRIX(IND, to_integer(ICNTxSI)*8+2)) &
              MxD(PMATRIX(IND, to_integer(ICNTxSI)*8+3));
    G1KxD <=    C(PMATRIX(IND, to_integer(ICNTxSI)*8+3)) &
                C(PMATRIX(IND, to_integer(ICNTxSI)*8+2));
               
    G2AxD <= VxDP(IMATRIX(to_integer(ICNTxSI),  8));
    G2BxD <= VxDP(IMATRIX(to_integer(ICNTxSI),  9));
    G2CxD <= VxDP(IMATRIX(to_integer(ICNTxSI), 10));
    G2DxD <= VxDP(IMATRIX(to_integer(ICNTxSI), 11));
    G2MxD <=  MxD(PMATRIX(IND, to_integer(ICNTxSI)*8+4)) &
              MxD(PMATRIX(IND, to_integer(ICNTxSI)*8+5));
    G2KxD <=    C(PMATRIX(IND, to_integer(ICNTxSI)*8+5)) &
                C(PMATRIX(IND, to_integer(ICNTxSI)*8+4));
               
    G3AxD <= VxDP(IMATRIX(to_integer(ICNTxSI), 12));
    G3BxD <= VxDP(IMATRIX(to_integer(ICNTxSI), 13));
    G3CxD <= VxDP(IMATRIX(to_integer(ICNTxSI), 14));
    G3DxD <= VxDP(IMATRIX(to_integer(ICNTxSI), 15));
    G3MxD <=  MxD(PMATRIX(IND, to_integer(ICNTxSI)*8+6)) &
              MxD(PMATRIX(IND, to_integer(ICNTxSI)*8+7));
    G3KxD <=    C(PMATRIX(IND, to_integer(ICNTxSI)*8+7)) &
                C(PMATRIX(IND, to_integer(ICNTxSI)*8+6));

  end process p_outmem;  

  -----------------------------------------------------------------------------
  -- G BLOCKS
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

  u_gcomp1: gcomp
    port map (
      AxDI => G1AxD,
      BxDI => G1BxD,
      CxDI => G1CxD,
      DxDI => G1DxD,
      MxDI => G1MxD,
      KxDI => G1KxD,
      AxDO => G1AOxD,
      BxDO => G1BOxD,
      CxDO => G1COxD,
      DxDO => G1DOxD
      );

  u_gcomp2: gcomp
    port map (
      AxDI => G2AxD,
      BxDI => G2BxD,
      CxDI => G2CxD,
      DxDI => G2DxD,
      MxDI => G2MxD,
      KxDI => G2KxD,
      AxDO => G2AOxD,
      BxDO => G2BOxD,
      CxDO => G2COxD,
      DxDO => G2DOxD
      );

  u_gcomp3: gcomp
    port map (
      AxDI => G3AxD,
      BxDI => G3BxD,
      CxDI => G3CxD,
      DxDI => G3DxD,
      MxDI => G3MxD,
      KxDI => G3KxD,
      AxDO => G3AOxD,
      BxDO => G3BOxD,
      CxDO => G3COxD,
      DxDO => G3DOxD
      );

  -----------------------------------------------------------------------------
  -- v MEMORY
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
