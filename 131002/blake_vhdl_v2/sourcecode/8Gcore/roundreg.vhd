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

  signal G0MxD, G0KxD, G4MxD, G4KxD      : std_logic_vector(WWIDTH*2-1 downto 0);
  signal G1MxD, G1KxD, G5MxD, G5KxD      : std_logic_vector(WWIDTH*2-1 downto 0);
  signal G2MxD, G2KxD, G6MxD, G6KxD      : std_logic_vector(WWIDTH*2-1 downto 0);
  signal G3MxD, G3KxD, G7MxD, G7KxD      : std_logic_vector(WWIDTH*2-1 downto 0);

  signal G0AOxD, G0BOxD, G0COxD, G0DOxD  : std_logic_vector(WWIDTH-1 downto 0);
  signal G1AOxD, G1BOxD, G1COxD, G1DOxD  : std_logic_vector(WWIDTH-1 downto 0);
  signal G2AOxD, G2BOxD, G2COxD, G2DOxD  : std_logic_vector(WWIDTH-1 downto 0);
  signal G3AOxD, G3BOxD, G3COxD, G3DOxD  : std_logic_vector(WWIDTH-1 downto 0);

  signal G4AOxD, G4BOxD, G4COxD, G4DOxD  : std_logic_vector(WWIDTH-1 downto 0);
  signal G5AOxD, G5BOxD, G5COxD, G5DOxD  : std_logic_vector(WWIDTH-1 downto 0);
  signal G6AOxD, G6BOxD, G6COxD, G6DOxD  : std_logic_vector(WWIDTH-1 downto 0);
  signal G7AOxD, G7BOxD, G7COxD, G7DOxD  : std_logic_vector(WWIDTH-1 downto 0);
  
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
  p_inmem: process (G4AOxD, G4BOxD, G4COxD, G4DOxD, G5AOxD, G5BOxD, G5COxD,
                    G5DOxD, G6AOxD, G6BOxD, G6COxD, G6DOxD, G7AOxD, G7BOxD,
                    G7COxD, G7DOxD, VxDI, VxDP, WEIxSI)
  begin  -- process p_inmem

    VxDN <= VxDP;

    if WEIxSI = '1' then
      for i in 15 downto 0 loop
        VxDN(15-i) <= VxDI(WWIDTH*(i+1)-1 downto WWIDTH*i);
        
      end loop;

    else
      VxDN(0)  <= G4AOxD;
      VxDN(5)  <= G4BOxD;
      VxDN(10) <= G4COxD;
      VxDN(15) <= G4DOxD;
                  
      VxDN(1)  <= G5AOxD;
      VxDN(6)  <= G5BOxD;
      VxDN(11) <= G5COxD;
      VxDN(12) <= G5DOxD;
                  
      VxDN(2)  <= G6AOxD;
      VxDN(7)  <= G6BOxD;
      VxDN(8)  <= G6COxD;
      VxDN(13) <= G6DOxD;
                  
      VxDN(3)  <= G7AOxD;
      VxDN(4)  <= G7BOxD;
      VxDN(9)  <= G7COxD;
      VxDN(14) <= G7DOxD; 
   
    end if;
  end process p_inmem;

  -----------------------------------------------------------------------------
  -- G INPUTS
  -----------------------------------------------------------------------------
  p_outmem: process (MxD, ROUNDxSI)
    variable IND : integer;
  begin  -- process p_outmem
    
    IND := (to_integer(ROUNDxSI))mod 10;

    G0MxD <= MxD(PMATRIX(IND,  0)) & MxD(PMATRIX(IND,  1));    
    G1MxD <= MxD(PMATRIX(IND,  2)) & MxD(PMATRIX(IND,  3));
    G2MxD <= MxD(PMATRIX(IND,  4)) & MxD(PMATRIX(IND,  5));
    G3MxD <= MxD(PMATRIX(IND,  6)) & MxD(PMATRIX(IND,  7));
    G4MxD <= MxD(PMATRIX(IND,  8)) & MxD(PMATRIX(IND,  9));    
    G5MxD <= MxD(PMATRIX(IND, 10)) & MxD(PMATRIX(IND, 11));
    G6MxD <= MxD(PMATRIX(IND, 12)) & MxD(PMATRIX(IND, 13));
    G7MxD <= MxD(PMATRIX(IND, 14)) & MxD(PMATRIX(IND, 15));

    G0KxD <= C(PMATRIX(IND,  1)) & C(PMATRIX(IND,  0));
    G1KxD <= C(PMATRIX(IND,  3)) & C(PMATRIX(IND,  2));
    G2KxD <= C(PMATRIX(IND,  5)) & C(PMATRIX(IND,  4));
    G3KxD <= C(PMATRIX(IND,  7)) & C(PMATRIX(IND,  6));
    G4KxD <= C(PMATRIX(IND,  9)) & C(PMATRIX(IND,  8));
    G5KxD <= C(PMATRIX(IND, 11)) & C(PMATRIX(IND, 10));
    G6KxD <= C(PMATRIX(IND, 13)) & C(PMATRIX(IND, 12));
    G7KxD <= C(PMATRIX(IND, 15)) & C(PMATRIX(IND, 14));

  end process p_outmem;  

  -----------------------------------------------------------------------------
  -- G BLOCKS
  -----------------------------------------------------------------------------

  u_gcomp0: gcomp
    port map (
      AxDI => VxDP(0),
      BxDI => VxDP(4),
      CxDI => VxDP(8),
      DxDI => VxDP(12),
      MxDI => G0MxD,
      KxDI => G0KxD,
      AxDO => G0AOxD,
      BxDO => G0BOxD,
      CxDO => G0COxD,
      DxDO => G0DOxD
      );

  u_gcomp1: gcomp
    port map (
      AxDI => VxDP(1),
      BxDI => VxDP(5),
      CxDI => VxDP(9),
      DxDI => VxDP(13),
      MxDI => G1MxD,
      KxDI => G1KxD,
      AxDO => G1AOxD,
      BxDO => G1BOxD,
      CxDO => G1COxD,
      DxDO => G1DOxD
      );

  u_gcomp2: gcomp
    port map (
      AxDI => VxDP(2),
      BxDI => VxDP(6),
      CxDI => VxDP(10),
      DxDI => VxDP(14),
      MxDI => G2MxD,
      KxDI => G2KxD,
      AxDO => G2AOxD,
      BxDO => G2BOxD,
      CxDO => G2COxD,
      DxDO => G2DOxD
      );

  u_gcomp3: gcomp
    port map (
      AxDI => VxDP(3),
      BxDI => VxDP(7),
      CxDI => VxDP(11),
      DxDI => VxDP(15),
      MxDI => G3MxD,
      KxDI => G3KxD,
      AxDO => G3AOxD,
      BxDO => G3BOxD,
      CxDO => G3COxD,
      DxDO => G3DOxD
      );

  -----------------------
  
  u_gcomp4: gcomp
    port map (
      AxDI => G0AOxD,
      BxDI => G1BOxD,
      CxDI => G2COxD,
      DxDI => G3DOxD,
      MxDI => G4MxD,
      KxDI => G4KxD,
      AxDO => G4AOxD,
      BxDO => G4BOxD,
      CxDO => G4COxD,
      DxDO => G4DOxD
      );

  u_gcomp5: gcomp
    port map (
      AxDI => G1AOxD,
      BxDI => G2BOxD,
      CxDI => G3COxD,
      DxDI => G0DOxD,
      MxDI => G5MxD,
      KxDI => G5KxD,
      AxDO => G5AOxD,
      BxDO => G5BOxD,
      CxDO => G5COxD,
      DxDO => G5DOxD
      );

  u_gcomp6: gcomp
    port map (
      AxDI => G2AOxD,
      BxDI => G3BOxD,
      CxDI => G0COxD,
      DxDI => G1DOxD,
      MxDI => G6MxD,
      KxDI => G6KxD,
      AxDO => G6AOxD,
      BxDO => G6BOxD,
      CxDO => G6COxD,
      DxDO => G6DOxD
      );

  u_gcomp7: gcomp
    port map (
      AxDI => G3AOxD,
      BxDI => G0BOxD,
      CxDI => G1COxD,
      DxDI => G2DOxD,
      MxDI => G7MxD,
      KxDI => G7KxD,
      AxDO => G7AOxD,
      BxDO => G7BOxD,
      CxDO => G7COxD,
      DxDO => G7DOxD
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
