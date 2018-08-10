--  
-- Copyright (c) 2018 Allmine Inc
--

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
library work;
    use work.bk_globals.all;

entity bk_round is

port (  clk :   in  std_logic;
        state : in  std_logic_vector(1023 downto 0);
        msg   : in  std_logic_vector(1023 downto 0);
        chain : out std_logic_vector(1023 downto 0)
     );

end bk_round;

architecture rtl of bk_round is

    ----------------------------------------------------------------------------
    -- Internal signal declarations
    ----------------------------------------------------------------------------
    component bk_colstep
    port (  state : in  std_logic_vector(1023 downto 0);
            msg   : in  std_logic_vector(511 downto 0);
            chain : out std_logic_vector(1023 downto 0)
         );
    end component;
    
    component bk_diastep
    port (  state : in  std_logic_vector(1023 downto 0);
            msg   : in  std_logic_vector(511 downto 0);
            chain : out std_logic_vector(1023 downto 0)
         );
    end component;
    
	component bk_hreg 
	port (  clk     : in  std_logic;
			st_in   : in  std_logic_vector(511 downto 0);
			st_out  : out std_logic_vector(511 downto 0)
		 );
	end component;

	component bk_reg 
	port (  clk     : in  std_logic;
			st_in   : in  std_logic_vector(1023 downto 0);
			st_out  : out std_logic_vector(1023 downto 0)
		 );
	end component;

    signal state_i : std_logic_vector(1023 downto 0);
    signal state_r : std_logic_vector(1023 downto 0);
    signal msg_r : std_logic_vector(511 downto 0);
    
begin  -- Rtl
    
    msgr_i : bk_hreg
        port map(   clk,
                    msg(511 downto 0),
                    msg_r
                );
    stater_i : bk_reg
        port map(   clk,
                    state_i,
                    state_r
                );
    column_step : bk_colstep
        port map(   state,
                    msg(1023 downto 512),
                    state_i
                );
    diagonal_step : bk_diastep
        port map(   state_r,
                    msg_r,
                    chain
                );

end rtl;
