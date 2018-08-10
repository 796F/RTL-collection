library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--library fsa0a_c_sc;
--use fsa0a_c_sc.vcomponents.all;

library fsa0a_c_generic_core;
use fsa0a_c_generic_core.vcomponents.all;

entity latchmem4x32 is
  port (
    ClkxCI  : in  std_logic;
    RstxRBI : in  std_logic;
    WADDxDI : in  unsigned(1 downto 0);
    RADDxDI : in  unsigned(1 downto 0);
    DxDI    : in  std_logic_vector(31 downto 0);
    WExEI   : in  std_logic;
    DxDO    : out std_logic_vector(31 downto 0)
    );
end latchmem4x32;

architecture rtl of latchmem4x32 is

  component latchblockfinal
    generic (
      SIZE : integer := 32);
    port (
      ClkxCI  : in  std_logic;
      DxDI    : in  std_logic_vector(SIZE-1 downto 0);
      DxDO    : out std_logic_vector(SIZE-1 downto 0));
  end component;

  constant WIDTH    : integer := 32;
  constant ADDWIDTH : integer := 2;

  type MEMARR is array (0 to 2**ADDWIDTH-1) of std_logic_vector(WIDTH-1 downto 0);

  signal MEMxDP                 : MEMARR;
  signal OneHotxEN, OneHotxEP   : std_logic_vector(2**ADDWIDTH-1 downto 0);
  signal CLKgatedxC             : std_logic_vector(2**ADDWIDTH-1 downto 0);
  signal DIxD                   : std_logic_vector(WIDTH-1 downto 0);
  signal InClkGatedxC, InHotxEP : std_logic;

begin  -- rtl
  
  -- Input Register (active low)
  -----------------------------------------------------------------------------
  p_inreg: process (InClkGatedxC, RstxRBI)
  begin  -- process p_inreg
    if RstxRBI = '0' then               -- asynchronous reset (active low)
      DIxD <= (others => '0');
      
    elsif InClkGatedxC'event and InClkGatedxC = '1' then  -- rising clock edge
      DIxD <= DxDI;
      
    end if;
  end process p_inreg;

  -- Input Gating
  -----------------------------------------------------------------------------
  u_ingating : GCKETP
    port map (
      E  => WExEI,
      TE => '0',
      CK => ClkxCI,
      Q  => InHotxEP);

  InClkGatedxC <= ClkxCI and InHotxEP;
  
  -- Decoder
  -----------------------------------------------------------------------------
  p_decoder: process (WExEI, WADDxDI)
  begin  -- process p_decoder

    OneHotxEN <= (others => '0');

    if WExEI = '1' then                 -- active high
      OneHotxEN(to_integer(WADDxDI)) <= '1';
      
    end if;
    
  end process p_decoder;

  -- CLK gating
  ---------------------------------------------------------------------------
  p_cgelement: for i in 0 to 2**ADDWIDTH-1 generate
    u_cglatch : GCKETP
      port map (
        E  => OneHotxEN(i),
        TE => '0',
        CK => ClkxCI,
        Q  => OneHotxEP(i));    
  end generate p_cgelement;


  -- Memory Blocks
  -----------------------------------------------------------------------------
  p_memgen: for i in 0 to 2**ADDWIDTH-1 generate

    CLKgatedxC(i) <= ClkxCI and OneHotxEP(i);
    
    u_latchblock : latchblockfinal
      generic map (
        SIZE => WIDTH)
      port map (
        ClkxCI  => CLKgatedxC(i),
        DxDI    => DIxD,
        DxDO    => MEMxDP(i));

  end generate p_memgen;

  DxDO <= MEMxDP(to_integer(RADDxDI));
  
end rtl;
