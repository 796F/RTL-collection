-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;

entity srlreg is
	generic ( 		
		depth : integer := 16 );
	port (
		clk : in std_logic;
		en : in std_logic;
		i : in std_logic;
		o : out std_logic);
end entity;

architecture struct of srlreg is
	signal reg : std_logic_vector(depth-1 downto 0);
begin
	uut : process ( clk )
	begin
		if  rising_edge( clk ) then
			if ( en = '1' ) then 
				reg <= reg(depth-2 downto 0) & i;
			end if;
		end if;
	end process;
	o <= reg(depth-1);
end struct;

----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
	

library ieee;
use ieee.std_logic_1164.all;

entity shfreg is
	generic ( 
		width : integer := 32; 
		depth : integer := 16 );
	port (
		clk : in std_logic;
		en : in std_logic;
		i : in std_logic_vector(width-1 downto 0);
		o : out std_logic_vector(width-1 downto 0) );
end entity;

---------------------------------
---------------------------------
-- USE THIS ARCH FOR DEBUGGING --
---------------------------------
---------------------------------
architecture debug of shfreg is
	type shfreg_type is array(0 to depth-1) of std_logic_vector(width-1 downto 0);
	signal reg : shfreg_type;
begin
	uut : process ( clk )
	begin
		if  rising_edge( clk ) then
			if ( en = '1' ) then 
				reg(depth-1) <= i;
				for j in depth-1 downto 1 loop
					reg(j-1) <= reg(j);
				end loop;
			end if;
		end if;
	end process;
	o <= reg(0);
end debug;
 
--------------------------------------------
--------------------------------------------
-- USE THIS ARCH FOR ACTUAL INSTANTIATION --						  
--------------------------------------------
--------------------------------------------
architecture struct of shfreg is
		
begin		 	  	
	width_gen: for j in 0 to width-1 generate
		reggen : entity work.srlreg(struct) generic map ( depth => depth ) port map ( clk => clk, en => en, i => i(j), o => o(j) );
	end generate;
end struct;						

  	