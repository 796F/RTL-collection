-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all ;  
use ieee.numeric_std.all;
use work.sha3_pkg.all;

entity hamsi_diffusion is
	-- generic declarations
	generic (w: integer := 32);
	
	port ( 	ai : in 	std_logic_vector(w - 1 downto 0); 
	        bi : in 	std_logic_vector(w - 1 downto 0);
	        ci : in 	std_logic_vector(w - 1 downto 0); 
	        di : in 	std_logic_vector(w - 1 downto 0); 
			ao : out 	std_logic_vector(w - 1 downto 0); 
	        bo : out 	std_logic_vector(w - 1 downto 0);
	        co : out 	std_logic_vector(w - 1 downto 0); 
	        do: out 	std_logic_vector(w - 1 downto 0) 
	);
end hamsi_diffusion ;

architecture struct of hamsi_diffusion is 
  
	signal ap, bp, cp, dp : std_logic_vector(w - 1 downto 0);  
	signal app, bpp, cpp, dpp : std_logic_vector(w - 1 downto 0);  

begin 

	
	ap <= rolx(ai, 13);      --ai:=ai<<<13
	cp <= rolx(ci, 3);		--ci:=ci<<<3
	bp <= bi xor ap xor cp;								--bi:=bi xor ai xor ci
	dp <= di xor cp xor (shlx(ap, 3));	 	--di:=di xor ci xor (ai<<3) [left shift not rotation] 
	bpp <= rolx(bp,1);						 	--bi:=bi <<<1
	bo <= bpp;
	dpp <= rolx(dp,7);	 	--di:=di<<<7
	do <= dpp;
	app <= ap xor bpp xor dpp;						 	--ai:=ai xor bi xor di
	cpp <= cp xor dpp xor (shlx(bpp, 7));		 --ci:=ci xor di xor (bi<<7)[left shift not rotation]
	ao <= rolx(app, 5);
	co <= rolx(cpp, 22);
	
	
	
	
end struct ;