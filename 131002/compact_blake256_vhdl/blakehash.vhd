library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.blakePkg.all;

entity blake is
  port (
    CLKxCI  : in  std_logic;
    RSTxRBI : in  std_logic;
    DxDI    : in  std_logic_vector(31 downto 0);
    DxDO    : out std_logic_vector(31 downto 0);
    IExEI   : in  std_logic;
    OExEO   : out std_logic
    );
end blake;

architecture rtl of blake is

  component latchmem16x32
    port (
      CLKxCI  : in  std_logic;
      RSTxRBI : in  std_logic;
      WADDxDI : in  unsigned(3 downto 0);
      RADDxDI : in  unsigned(3 downto 0);
      DxDI    : in  std_logic_vector(31 downto 0);
      WExEI   : in  std_logic;
      DxDO    : out std_logic_vector(31 downto 0));
  end component;

  component latchmem8x32
    port (
      CLKxCI  : in  std_logic;
      RSTxRBI : in  std_logic;
      WADDxDI : in  unsigned(2 downto 0);
      RADDxDI : in  unsigned(2 downto 0);
      DxDI    : in  std_logic_vector(31 downto 0);
      WExEI   : in  std_logic;
      DxDO    : out std_logic_vector(31 downto 0));
  end component;

  component latchmem4x32
    port (
      CLKxCI  : in  std_logic;
      RSTxRBI : in  std_logic;
      WADDxDI : in  unsigned(1 downto 0);
      RADDxDI : in  unsigned(1 downto 0);
      DxDI    : in  std_logic_vector(31 downto 0);
      WExEI   : in  std_logic;
      DxDO    : out std_logic_vector(31 downto 0));
  end component;

  component latchmem2x32
    port (
      CLKxCI  : in  std_logic;
      RSTxRBI : in  std_logic;
      WADDxDI : in  std_logic;
      RADDxDI : in  std_logic;
      DxDI    : in  std_logic_vector(31 downto 0);
      WExEI   : in  std_logic;
      DxDO    : out std_logic_vector(31 downto 0));
  end component;

  component controller
    port (
      CLKxCI    : in  std_logic;
      RSTxRBI   : in  std_logic;
      IExEI     : in  std_logic;
      OExEO     : out std_logic;
      MUXselxSO : out std_logic_vector(9 downto 0);
      VWADDxDO  : out unsigned(3 downto 0);
      VRADDxDO  : out unsigned(3 downto 0);
      VWExEO    : out std_logic;
      MWADDxDO  : out unsigned(3 downto 0);
      MRADDxDO  : out unsigned(3 downto 0);
      MWExEO    : out std_logic;
      HWADDxDO  : out unsigned(2 downto 0);
      HRADDxDO  : out unsigned(2 downto 0);
      HWExEO    : out std_logic;
      SWADDxDO  : out unsigned(1 downto 0);
      SRADDxDO  : out unsigned(1 downto 0);
      SWExEO    : out std_logic;
      TWADDxDO  : out std_logic;
      TRADDxDO  : out std_logic;
      TWExEO    : out std_logic;
      CNTxDO    : out unsigned(3 downto 0);
      GCNTxDO   : out unsigned(2 downto 0);
      RCNTxDO   : out unsigned(3 downto 0));
  end component;

  signal MUXselxS            : std_logic_vector(9 downto 0);
  signal VWExE, MWExE, HWExE : std_logic;
  signal SWExE, TWExE        : std_logic;
  signal TRADDxD, TWADDxD    : std_logic;
  signal MWADDxD, MRADDxD    : unsigned(3 downto 0);
  signal VWADDxD, VRADDxD    : unsigned(3 downto 0);
  signal HWADDxD, HRADDxD    : unsigned(2 downto 0);
  signal SWADDxD, SRADDxD    : unsigned(1 downto 0);
  signal VIxD, HIxD          : std_logic_vector(31 downto 0);
  signal VOxD, MOxD, HOxD    : std_logic_vector(31 downto 0);
  signal TOxD, SOxD          : std_logic_vector(31 downto 0);
  signal GCNTxD              : unsigned(2 downto 0);
  signal RCNTxD, CNTxD       : unsigned(3 downto 0);
  signal Rot2xD, INXonexD    : std_logic_vector(31 downto 0);
  signal OUTregxD, INregxD   : std_logic_vector(31 downto 0);
  signal INmu0xD, INmu1xD    : std_logic_vector(31 downto 0);
  signal INmu2xD, STopxD     : std_logic_vector(31 downto 0);
  signal SECaddxD, CMxorxD   : std_logic_vector(31 downto 0);
  signal CxD, STCxorxD, HsxD : std_logic_vector(31 downto 0);
  signal MIxD, TIxD, SIxD    : std_logic_vector(31 downto 0);

  signal BlaxS : std_logic;


-------------------------------------------------------------------------------
-- BEGIN
-------------------------------------------------------------------------------
begin  -- rtl

  MIxD <= DxDI;
  SIxD <= DxDI;
  TIxD <= DxDI;

  -----------------------------------------------------------------------------
  -- MEMORY
  -----------------------------------------------------------------------------
  u_latchmemV : latchmem16x32
    port map (
      CLKxCI  => CLKxCI,
      RSTxRBI => RSTxRBI,
      WADDxDI => VWADDxD,
      RADDxDI => VRADDxD,
      DxDI    => VIxD,
      WExEI   => VWExE,
      DxDO    => VOxD);  

  u_latchmemM : latchmem16x32
    port map (
      CLKxCI  => CLKxCI,
      RSTxRBI => RSTxRBI,
      WADDxDI => MWADDxD,
      RADDxDI => MRADDxD,
      DxDI    => MIxD,
      WExEI   => MWExE,
      DxDO    => MOxD);  

  u_latchmemH : latchmem8x32
    port map (
      CLKxCI  => CLKxCI,
      RSTxRBI => RSTxRBI,
      WADDxDI => HWADDxD,
      RADDxDI => HRADDxD,
      DxDI    => HIxD,
      WExEI   => HWExE,
      DxDO    => HOxD);  

  u_latchmemS : latchmem4x32
    port map (
      CLKxCI  => CLKxCI,
      RSTxRBI => RSTxRBI,
      WADDxDI => SWADDxD,
      RADDxDI => SRADDxD,
      DxDI    => SIxD,
      WExEI   => SWExE,
      DxDO    => SOxD);  

  u_latchmemT : latchmem2x32
    port map (
      CLKxCI  => CLKxCI,
      RSTxRBI => RSTxRBI,
      WADDxDI => TWADDxD,
      RADDxDI => TRADDxD,
      DxDI    => TIxD,
      WExEI   => TWExE,
      DxDO    => TOxD);

  -----------------------------------------------------------------------------
  -- CONTROLLER
  -----------------------------------------------------------------------------
  u_controller : controller
    port map (
      CLKxCI    => CLKxCI,
      RSTxRBI   => RSTxRBI,
      IExEI     => IExEI,
      OExEO     => OExEO,
      MUXselxSO => MUXselxS,
      VWADDxDO  => VWADDxD,
      VRADDxDO  => VRADDxD,
      VWExEO    => VWExE,
      MWADDxDO  => MWADDxD,
      MRADDxDO  => MRADDxD,
      MWExEO    => MWExE,
      HWADDxDO  => HWADDxD,
      HRADDxDO  => HRADDxD,
      HWExEO    => HWExE,
      SWADDxDO  => SWADDxD,
      SRADDxDO  => SRADDxD,
      SWExEO    => SWExE,
      TWADDxDO  => TWADDxD,
      TRADDxDO  => TRADDxD,
      TWExEO    => TWExE,
      CNTxDO    => CNTxD,
      GCNTxDO   => GCNTxD,
      RCNTxDO   => RCNTxD
      );

  -----------------------------------------------------------------------------
  -- G
  -----------------------------------------------------------------------------

  -- C select
  -----------------------------------------------------------------------------
  p_csel : process (CNTxD, GCNTxD, RCNTxD)
    variable ii : integer := 0;
  begin  -- process p_mcsel

    ii := (to_integer(RCNTxD))mod 10;

    if CNTxD(2) = '0' then
      CxD <= C(PMATRIX(ii, 2*to_integer(GCNTxD)+1));

    else
      CxD <= C(PMATRIX(ii, 2*to_integer(GCNTxD)));
      
    end if;
    
  end process p_csel;

  CMxorxD  <= MOxD xor CxD;
  SECaddxD <= CMxorxD when MUXselxS(6) = '1' else OUTregxD;

  -- ADDER
  -----------------------------------------------------------------------------
  INmu0xD <= std_logic_vector(unsigned(VOxD) + unsigned(SECaddxD));

  -- ROT switch
  -----------------------------------------------------------------------------
  Rot2xD <= INmu2xD(6 downto 0) & INmu2xD(31 downto 7);

  p_rot : process (MUXselxS, Rot2xD)
  begin  -- process p_rot
    
    if MUXselxS(8 downto 7) = "01" then
      INmu1xD <= Rot2xD(0) & Rot2xD(31 downto 1);

    elsif MUXselxS(8 downto 7) = "10" then
      INmu1xD <= Rot2xD(4 downto 0) & Rot2xD(31 downto 5);

    elsif MUXselxS(8 downto 7) = "11" then
      INmu1xD <= Rot2xD(8 downto 0) & Rot2xD(31 downto 9);

    else
      INmu1xD <= Rot2xD;
      
    end if;
    
  end process p_rot;

  -- Register MUX
  -----------------------------------------------------------------------------
  p_regmux : process (HsxD, INmu0xD, INmu1xD, INmu2xD, MUXselxS)
  begin  -- process p_regmux

    if MUXselxS(5 downto 4) = "10" then
      INregxD <= INmu0xD;
      
    elsif MUXselxS(5 downto 4) = "01" then
      INregxD <= INmu1xD;

    elsif MUXselxS(5 downto 4) = "11" then
      INregxD <= HsxD;
      
    else
      INregxD <= INmu2xD;

    end if;

  end process p_regmux;

  -----------------------------------------------------------------------------
  -- SINGLE REG
  -----------------------------------------------------------------------------
  p_singlereg : process (CLKxCI, RSTxRBI)
  begin  -- process p_singlereg
    if RSTxRBI = '0' then               -- asynchronous reset (active low)
      OUTregxD <= (others => '0');
      
    elsif CLKxCI'event and CLKxCI = '1' then  -- rising clock edge
      OUTregxD <= INregxD;
      
    end if;
  end process p_singlereg;

  -----------------------------------------------------------------------------
  -- INITIALIZATION
  -----------------------------------------------------------------------------

  -- VIN mux
  -----------------------------------------------------------------------------
  p_vinmux : process (HIxD, MUXselxS, OUTregxD, STCxorxD)
  begin  -- process p_vinmux

    if MUXselxS(2 downto 1) = "01" then
      VIxD <= STCxorxD;

    elsif MUXselxS(2 downto 1) = "10" then
      VIxD <= HIxD;

    else
      VIxD <= OUTregxD;
      
    end if;
    
  end process p_vinmux;

  -- ST mux
  -----------------------------------------------------------------------------
  STopxD <= SOxD when MUXselxS(0) = '1' else TOxD;

  -- ST xor C
  -----------------------------------------------------------------------------
  STCxorxD <= STopxD xor C(to_integer(CNTxD(3 downto 1)-1));

  -- IV mux
  -----------------------------------------------------------------------------
  HIxD <= IV(to_integer(CNTxD(3 downto 1))) when MUXselxS(3) = '1' else HsxD;

  -- OUT xor S 
  -----------------------------------------------------------------------------
  INXonexD <= HOxD when MUXselxS(9) = '1' else OUTregxD;

  INmu2xD <= VOxD xor INXonexD;

  HsxD <= SOxD xor INmu2xD;

  DxDO <= OUTregxD;
  
end rtl;





