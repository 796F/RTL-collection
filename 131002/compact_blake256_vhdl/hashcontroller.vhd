library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.blakePkg.all;

entity controller is
  port (
    CLKxCI  : in  std_logic;
    RSTxRBI : in  std_logic;
    IExEI   : in  std_logic;
    OExEO   : out std_logic;

    -- MUX selector
    MUXselxSO : out std_logic_vector(9 downto 0);

    -- V mem
    VWADDxDO : out unsigned(3 downto 0);
    VRADDxDO : out unsigned(3 downto 0);
    VWExEO   : out std_logic;

    -- M mem
    MWADDxDO : out unsigned(3 downto 0);
    MRADDxDO : out unsigned(3 downto 0);
    MWExEO   : out std_logic;

    -- H mem
    HWADDxDO : out unsigned(2 downto 0);
    HRADDxDO : out unsigned(2 downto 0);
    HWExEO   : out std_logic;

    -- S mem
    SWADDxDO : out unsigned(1 downto 0);
    SRADDxDO : out unsigned(1 downto 0);
    SWExEO   : out std_logic;

    -- T mem
    TWADDxDO : out std_logic;
    TRADDxDO : out std_logic;
    TWExEO   : out std_logic;

    CNTxDO  : out unsigned(3 downto 0);
    GCNTxDO : out unsigned(2 downto 0);
    RCNTxDO : out unsigned(3 downto 0)
    );

end controller;

architecture rtl of controller is

  type   state is (idle, storeST, storeM, round, output);
  signal STATExDN, STATExDP : state;

  signal CNTxDN, CNTxDP   : unsigned(3 downto 0);
  signal GCNTxDN, GCNTxDP : unsigned(2 downto 0);
  signal RCNTxDN, RCNTxDP : unsigned(3 downto 0);

  signal IVinitxSN, IVinitxSP, OExEN : std_logic;

  signal CNTMOD5xD : integer;

  type Qtype is array (0 to 7, 0 to 3) of integer;
  constant QUART : Qtype := ((0, 4, 8, 12), (1, 5, 9, 13), (2, 6, 10, 14), (3, 7, 11, 15),
                             (0, 5, 10, 15), (1, 6, 11, 12), (2, 7, 8, 13), (3, 4, 9, 14));

  type     Ttype is array (0 to 4) of integer;
  constant WTUPLE : Ttype := (1, 0, 0, 3, 2);
  constant RTUPLE : Ttype := (0, 1, 3, 2, 1);
  
begin  -- rtl

  GCNTxDO <= GCNTxDP;
  RCNTxDO <= RCNTxDP;
  CNTxDO  <= CNTxDP;

  CNTMOD5xD <= to_integer(CNTxDP) mod 5;

  p_fsm : process (CNTxDP, GCNTxDP, IExEI, RCNTxDP, STATExDP)
  begin  -- process p_fsm
    
    CNTxDN   <= (others => '0');
    GCNTxDN  <= (others => '0');
    RCNTxDN  <= (others => '0');
    STATExDN <= idle;

    case STATExDP is

      -------------------------------------------------------------------------
      when idle =>

        if IExEI = '1' then
          CNTxDN   <= CNTxDP + 1;
          STATExDN <= storeST;
          
        end if;

        -------------------------------------------------------------------------
      when storeST =>

        if CNTxDP < 5 then
          CNTxDN   <= CNTxDP + 1;
          STATExDN <= storeST;

        else
          STATExDN <= storeM;
          
        end if;

        -------------------------------------------------------------------------
      when storeM =>
        
        if CNTxDP = 15 then
          STATExDN <= round;
          
        else
          CNTxDN   <= CNTxDP + 1;
          STATExDN <= storeM;
          
        end if;

        -------------------------------------------------------------------------
      when round =>

        if RCNTxDP = 13 then
          if GCNTxDP = 7 then
            if CNTxDP = 9 then
              STATExDN <= output;

            else
              RCNTxDN  <= RCNTxDP;
              GCNTxDN  <= GCNTxDP;
              CNTxDN   <= CNTxDP + 1;
              STATExDN <= round;
              
            end if;

          else
            RCNTxDN  <= RCNTxDP;
            STATExDN <= round;

            if CNTxDP = 9 then
              GCNTxDN <= GCNTxDP+1;

            else
              GCNTxDN <= GCNTxDP;
              CNTxDN  <= CNTxDP + 1;
              
            end if;
          end if;

        else
          STATExDN <= round;

          if GCNTxDP = 7 then
            if CNTxDP = 9 then
              RCNTxDN <= RCNTxDP + 1;

            else
              RCNTxDN <= RCNTxDP;
              GCNTxDN <= GCNTxDP;
              CNTxDN  <= CNTxDP + 1;
              
            end if;

          else
            RCNTxDN  <= RCNTxDP;
            STATExDN <= round;

            if CNTxDP = 9 then
              GCNTxDN <= GCNTxDP+1;

            else
              GCNTxDN <= GCNTxDP;
              CNTxDN  <= CNTxDP + 1;
              
            end if;
          end if;

        end if;

        -------------------------------------------------------------------------
      when output =>

        if CNTxDP = 15 then
          if IExEI = '1' then
            STATExDN <= round;

          else
            STATExDN <= idle;
            
          end if;

        else
          CNTxDN   <= CNTxDP + 1;
          STATExDN <= output;
          
        end if;

        -------------------------------------------------------------------------
      when others =>

        STATExDN <= idle;
        
    end case;
  end process p_fsm;

  -----------------------------------------------------------------------------
  -- WRITE ENABLE and ADDRESS, READ ADDRESS
  -----------------------------------------------------------------------------
  p_memwrite : process (CNTMOD5xD, CNTxDP, GCNTxDP, IExEI, RCNTxDP, STATExDP)

    variable RADD, WADD, CNTM6, ii : integer := 0;
    
  begin  -- process p_memwrite

    ii := (to_integer(RCNTxDP))mod 10;

    SWExEO <= '0';
    TWExEO <= '0';
    HWExEO <= '0';
    MWExEO <= '0';
    VWExEO <= '0';

    SWADDxDO <= (others => '0');
    TWADDxDO <= '0';
    HWADDxDO <= (others => '0');
    MWADDxDO <= (others => '0');
    VWADDxDO <= (others => '0');

    SRADDxDO <= (others => '0');
    TRADDxDO <= '1';
    HRADDxDO <= (others => '0');
    MRADDxDO <= (others => '0');
    VRADDxDO <= (others => '0');

    -- S WE WADD
    ---------------------------------------------------------------------------
    if STATExDP = idle or (STATExDP = storeST and CNTxDP < 4) then
      SWExEO   <= IExEI;
      SWADDxDO <= CNTxDP(1 downto 0);
      
    end if;

    -- S RADD
    ---------------------------------------------------------------------------
    if STATExDP = storeM or (STATExDP = output and CNTxDP(0) = '0') then
      SRADDxDO <= CNTxDP(2 downto 1) - 1;

    elsif STATExDP = output and CNTxDP(0) = '1' then
      SRADDxDO <= CNTxDP(2 downto 1);
      
    end if;

    -- T WE WADD
    ---------------------------------------------------------------------------
    if (STATExDP = storeST and CNTxDP > 3) or (STATExDP = round and CNTxDP > 7) then
      TWExEO   <= IExEI;
      TWADDxDO <= CNTxDP(0);
      
    end if;

    -- T RADD
    ---------------------------------------------------------------------------
    if STATExDP = storeM or STATExDP = output then
      if CNTxDP = 10 or CNTxDP = 12 then
        TRADDxDO <= '0';
        
      end if;
    end if;

    -- H WE WADD RADD
    ---------------------------------------------------------------------------
    if STATExDP = output then
      HWExEO   <= IExEI and CNTxDP(0);
      HWADDxDO <= CNTxDP(3 downto 1);
      HRADDxDO <= CNTxDP(3 downto 1);

    elsif STATExDP = storeM then
      HWExEO   <= IExEI and CNTxDP(0);
      HWADDxDO <= CNTxDP(3 downto 1);
      HRADDxDO <= CNTxDP(3 downto 1)+1;
      
    end if;

    -- M WE WADD
    ---------------------------------------------------------------------------
    if STATExDP = storeM or STATExDP = output then
      MWExEO   <= IExEI;
      MWADDxDO <= CNTxDP;
      
    end if;

    -- M RADD
    ---------------------------------------------------------------------------
    if STATExDP = round then
      if CNTxDP(2) = '1' then
        MRADDxDO <= to_unsigned(PMATRIX(ii, 2*to_integer(GCNTxDP)+1), 4);

      else
        MRADDxDO <= to_unsigned(PMATRIX(ii, 2*to_integer(GCNTxDP)), 4);
        
      end if;
    end if;

    -- V WE WADD
    ---------------------------------------------------------------------------
    if (STATExDP = storeM or STATExDP = output) then
      if CNTxDP = 0 then
        VWExEO   <= '1';
        VWADDxDO <= "0100";

      else
        VWExEO <= IExEI;

        if CNTxDP(0) = '1' then
          VWADDxDO <= '0' & CNTxDP(3 downto 1);
          
        else
          VWADDxDO <= ('1' & CNTxDP(3 downto 1))-1;
          
        end if;
      end if;
      

    elsif STATExDP = round then
      if CNTxDP = 0 then
        VWExEO <= '1';

        if GCNTxDP = 0 and RCNTxDP = 0 then
          VWADDxDO <= "1111";

        else
          WADD     := QUART(to_integer(GCNTxDP-1), WTUPLE(CNTMOD5xD));
          VWADDxDO <= to_unsigned(WADD, 4);
          
        end if;
        
      else
        WADD     := QUART(to_integer(GCNTxDP), WTUPLE(CNTMOD5xD));
        VWADDxDO <= to_unsigned(WADD, 4);

        if CNTMOD5xD /= 1 then
          VWExEO <= '1';

        end if;
      end if;
    end if;

    -- V RADD
    ---------------------------------------------------------------------------
    if STATExDP = round then
      RADD     := QUART(to_integer(GCNTxDP), RTUPLE(CNTMOD5xD));
      VRADDxDO <= to_unsigned(RADD, 4);

    elsif STATExDP = output then
      if CNTxDP(0) = '0' then
        VRADDxDO <= '0' & CNTxDP(3 downto 1);

      else
        VRADDxDO <= '1' & CNTxDP(3 downto 1);
        
      end if;
    end if;
    
  end process p_memwrite;

  -----------------------------------------------------------------------------
  -- MUX Select
  -----------------------------------------------------------------------------
  p_muxsel : process (CNTxDP, GCNTxDP, IVinitxSP, RCNTxDP, STATExDP)
  begin  -- process p_muxsel

    MUXselxSO <= (others => '0');

    -- ST 0
    ---------------------------------------------------------------------------
    if CNTxDP < 9 and CNTxDP > 1 then
      MUXselxSO(0) <= '1';
      
    end if;

    -- VIN 2-1
    ---------------------------------------------------------------------------
    if STATExDP = storeM or (STATExDP = output and CNTxDP > 0) then
      MUXselxSO(2) <= CNTxDP(0);
      MUXselxSO(1) <= not CNTxDP(0);
      
    elsif STATExDP = round and CNTxDP = 0 and GCNTxDP = 0 and RCNTxDP = 0 then
      MUXselxSO(2 downto 1) <= "01";
      
    end if;

    -- IV 3
    ---------------------------------------------------------------------------
    MUXselxSO(3) <= IVinitxSP;

    -- REG 5-4
    ---------------------------------------------------------------------------
    if STATExDP = round then
      MUXselxSO(5 downto 4) <= "10";

      if CNTxDP = 2 or CNTxDP = 4 or CNTxDP = 7 or CNTxDP = 9 then
        MUXselxSO(5 downto 4) <= "01";
        
      end if;

    elsif STATExDP = output and CNTxDP(0) = '1' then
      MUXselxSO(5 downto 4) <= "11";
      
    end if;

    -- MC 6
    ---------------------------------------------------------------------------
    if STATExDP = round then
      if CNTxDP = 0 or CNTxDP = 5 then
        MUXselxSO(6) <= '1';
        
      end if;
    end if;

    -- ROT 8-7
    ---------------------------------------------------------------------------
    if STATExDP = round then
      if CNTxDP = 7 then
        MUXselxSO(8 downto 7) <= "01";

      elsif CNTxDP = 4 then
        MUXselxSO(8 downto 7) <= "10";

      elsif CNTxDP = 2 then
        MUXselxSO(8 downto 7) <= "11";
        
      end if;
    end if;

    -- IN XOR ONE 9
    ---------------------------------------------------------------------------
    if STATExDP = output then
      MUXselxSO(9) <= not CNTxDP(0);
      
    end if;
    
  end process p_muxsel;

  -----------------------------------------------------------------------------
  -- IV STATE INIT
  -----------------------------------------------------------------------------
  p_ivinit : process (IVinitxSP, STATExDP)
  begin  -- process p_ivinit

    IVinitxSN <= IVinitxSP;
    if STATExDP = idle then
      IVinitxSN <= '1';

    elsif STATExDP = round then
      IVinitxSN <= '0';
      
    end if;
    
  end process p_ivinit;

  -----------------------------------------------------------------------------
  -- OUTPUT ENABLE
  -----------------------------------------------------------------------------
  p_validout : process (CNTxDP, IExEI, STATExDP)
  begin  -- process p_validout

    OExEN <= '0';

    if STATExDP = output then
      OExEN <= (not IExEI) and CNTxDP(0);
      
    end if;
    
  end process p_validout;


  -----------------------------------------------------------------------------
  -- MEMORY
  -----------------------------------------------------------------------------
  p_mem : process (CLKxCI, RSTxRBI)
  begin  -- process p_mem
    if RSTxRBI = '0' then               -- asynchronous reset (active low)
      STATExDP  <= idle;
      CNTxDP    <= (others => '0');
      GCNTxDP   <= (others => '0');
      RCNTxDP   <= (others => '0');
      IVinitxSP <= '0';
      OExEO     <= '0';
      
    elsif CLKxCI'event and CLKxCI = '1' then  -- rising clock edge
      STATExDP  <= STATExDN;
      CNTxDP    <= CNTxDN;
      GCNTxDP   <= GCNTxDN;
      RCNTxDP   <= RCNTxDN;
      IVinitxSP <= IVinitxSN;
      OExEO     <= OExEN;
      
    end if;
  end process p_mem;
  

end rtl;
