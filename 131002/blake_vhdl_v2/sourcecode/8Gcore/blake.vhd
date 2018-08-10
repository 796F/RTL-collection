library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.blakePkg.all;

entity blake is
  port (
    CLKxCI   : in  std_logic;
    RSTxRBI  : in  std_logic;
    MxDI     : in  std_logic_vector(WWIDTH*16-1 downto 0);
    HxDI     : in  std_logic_vector(WWIDTH*8-1 downto 0);
    SxDI     : in  std_logic_vector(WWIDTH*4-1 downto 0);
    TxDI     : in  std_logic_vector(WWIDTH*2-1 downto 0);
    HxDO     : out std_logic_vector(WWIDTH*8-1 downto 0);
    InENxSI  : in  std_logic;
    OutENxSO : out std_logic
    );

end blake;

architecture hash of blake is

  component controller
    port (
      CLKxCI      : in  std_logic;
      RSTxRBI     : in  std_logic;
      VALIDINxSI  : in  std_logic;
      VALIDOUTxSO : out std_logic;
      ROUNDxSO    : out unsigned(3 downto 0)
      );
  end component;

  component initialization
    port (
      HxDI : in  std_logic_vector(WWIDTH*8-1 downto 0);
      SxDI : in  std_logic_vector(WWIDTH*4-1 downto 0);
      TxDI : in  std_logic_vector(WWIDTH*2-1 downto 0);
      VxDO : out std_logic_vector(WWIDTH*16-1 downto 0)
      );
  end component;

  component roundreg
    port (
      CLKxCI   : in  std_logic;
      RSTxRBI  : in  std_logic;
      WEIxSI   : in  std_logic;
      ROUNDxSI : in  unsigned(3 downto 0);
      VxDI     : in  std_logic_vector(WWIDTH*16-1 downto 0);
      MxDI     : in  std_logic_vector(WWIDTH*16-1 downto 0);
      VxDO     : out std_logic_vector(WWIDTH*16-1 downto 0)
      );
  end component;

  component finalization
    port (
      VxDI : in  std_logic_vector(WWIDTH*16-1 downto 0);
      HxDI : in  std_logic_vector(WWIDTH*8-1 downto 0);
      SxDI : in  std_logic_vector(WWIDTH*4-1 downto 0);
      HxDO : out std_logic_vector(WWIDTH*8-1 downto 0)
      );
  end component;

  signal VxD, VFINALxD : std_logic_vector(WWIDTH*16-1 downto 0);
  signal ROUNDxS       : unsigned(3 downto 0);

begin  -- hash

  -----------------------------------------------------------------------------
  -- CONTROLLER
  -----------------------------------------------------------------------------
  u_controller: controller
    port map (
      CLKxCI      => CLKxCI,
      RSTxRBI     => RSTxRBI,
      VALIDINxSI  => InENxSI,
      VALIDOUTxSO => OutENxSO,
      ROUNDxSO    => ROUNDxS
      );
  
  -----------------------------------------------------------------------------
  -- INITIALIZATION
  -----------------------------------------------------------------------------
  u_initialization: initialization
    port map (
      HxDI => HxDI,
      SxDI => SxDI,
      TxDI => TxDI,
      VxDO => VxD
      );

  -----------------------------------------------------------------------------
  -- ROUND
  -----------------------------------------------------------------------------
  u_roundreg: roundreg
    port map (
      CLKxCI   => CLKxCI,
      RSTxRBI  => RSTxRBI,
      WEIxSI   => InENxSI,
      ROUNDxSI => ROUNDxS,
      VxDI     => VxD,
      MxDI     => MxDI,
      VxDO     => VFINALxD
      );


  -----------------------------------------------------------------------------
  -- FINALIZATION
  -----------------------------------------------------------------------------
  u_finalization: finalization
    port map (
      VxDI  => VFINALxD,
      HxDI  => HxDI,
      SxDI  => SxDI,
      HxDO  => HxDO
      );

end hash;
