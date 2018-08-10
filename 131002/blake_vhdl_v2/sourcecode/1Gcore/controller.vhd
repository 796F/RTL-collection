library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.blakePkg.all;

entity controller is
  port (
    CLKxCI      : in  std_logic;
    RSTxRBI     : in  std_logic;
    VALIDINxSI  : in  std_logic;
    VALIDOUTxSO : out std_logic;
    ICNTxSO     : out unsigned(3 downto 0);
    ROUNDxSO    : out unsigned(3 downto 0)
    );

end controller;

architecture hash of controller is

  type state is (idle, round, fin);

  signal STATExDP, STATExDN : state;

  signal ROUNDxDP, ROUNDxDN : unsigned(3 downto 0);
  signal ICNTxDP, ICNTxDN   : unsigned(3 downto 0);
  

begin  -- hash

  ROUNDxSO <= ROUNDxDP;
  ICNTxSO  <= ICNTxDP;

  fsm: process (ICNTxDP, ROUNDxDP, STATExDP, VALIDINxSI)
  begin  -- process fsm
    
    VALIDOUTxSO <= '0';
    
    ROUNDxDN    <= (others => '0');
    ICNTxDN     <= (others => '0');

    case STATExDP is

      -------------------------------------------------------------------------
      when idle => 

        if VALIDINxSI = '1' then
          STATExDN <= round;

        else
          STATExDN <= idle;
          
        end if;

      -------------------------------------------------------------------------
      when round => 

        if ROUNDxDP < NROUND-1 then
          if ICNTxDP = 7 then
            ROUNDxDN <= ROUNDxDP + 1;
            STATExDN <= round;

          else
            ROUNDxDN <= ROUNDxDP;
            ICNTxDN  <= ICNTxDP + 1;
            STATExDN <= round;
            
          end if;
          
        else
          if ICNTxDP = 7 then
            STATExDN <= fin;

          else
            ROUNDxDN <= ROUNDxDP;
            ICNTxDN  <= ICNTxDP + 1;
            STATExDN <= round;
            
          end if;
        end if;

      -------------------------------------------------------------------------
      when fin =>

        VALIDOUTxSO <= '1';
        STATExDN    <= idle;  

      -------------------------------------------------------------------------
      when others =>

        STATExDN <= idle;
      
    end case;
    
  end process fsm;
  
  
  process (CLKxCI, RSTxRBI)
  begin  -- process
    if RSTxRBI = '0' then               -- asynchronous reset (active low)
      STATExDP <= idle;
      ROUNDxDP <= (others => '0');
      ICNTxDP  <= (others => '0');
      
    elsif CLKxCI'event and CLKxCI = '1' then  -- rising clock edge
      STATExDP <= STATExDN;
      ROUNDxDP <= ROUNDxDN;
      ICNTxDP  <= ICNTxDN;
        
    end if;
  end process;
  
end hash;
