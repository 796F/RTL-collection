--  
-- Copyright (c) 2018 Allmine Inc
--

library work;
	use work.keccak_globals.all;
	
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;	


entity keccak_register is

port (

	clk : in std_logic;
    state_in     : in  k_state_type;
    state_out    : out k_state_type);

end keccak_register;

architecture rtl of keccak_register is


  ----------------------------------------------------------------------------
  -- Internal signal declarations
  ----------------------------------------------------------------------------

  
begin  -- Rtl

	begReg: process( clk )
	begin
		if rising_edge( clk ) then
			state_out <= state_in;			
		end if;
	end process;


end rtl;
