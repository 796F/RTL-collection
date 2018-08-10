-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- ======================================================================

library ieee;
use ieee.std_logic_1164.all;   
use ieee.std_logic_unsigned.all;
use work.sha3_pkg.all;

entity adder is 
	generic (
		adder_type : integer:= SCCA_BASED; -- standard carry chain adder by default
		n : integer := 64);
	port(
		a : in std_logic_vector(n-1 downto 0);
		b : in std_logic_vector(n-1 downto 0);
		s : out std_logic_vector(n-1 downto 0)
	);		
end adder;

architecture struct of adder is 

begin
	FCC_GEN : if adder_type = SCCA_BASED generate
		s <= a + b;
	end generate;
	CLA_GEN64 : if ((adder_type = CLA_BASED) and (n = 64)) generate
		cla_call : entity work.cla_64(struct) port map ( a => a, b => b, s => s );
	end generate;
	CLA_GEN32 : if ((adder_type = CLA_BASED) and (n = 32)) generate
		cla_call : entity work.cla_32(struct) port map ( a => a, b => b, s => s );
	end generate;
	CLA_GEN16 : if ((adder_type = CLA_BASED) and (n = 16)) generate
		cla_call : entity work.cla_16(struct) port map ( a => a, b => b, s => s );
	end generate;
	FCCA_GEN1 : if (adder_type = FCCA_BASED) generate
		fcca_call : entity work.fcca(struct) generic map ( n => n )  port map ( a => a, b => b, s => s );
	end generate;
	
end struct;