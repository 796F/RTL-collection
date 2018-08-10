--  
-- Copyright (c) 2018 Allmine Inc
--

library work;
	use work.keccak_globals.all;
	
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;	


entity keccak_iota is

port (
	
    state_in     : in  k_state_type;
	n_round		: in std_logic_vector(4 downto 0);
    state_out    : out k_state_type);

end keccak_iota;

architecture rtl of keccak_iota is


  ----------------------------------------------------------------------------
  -- Internal signal declarations
  ----------------------------------------------------------------------------
signal round_constant_signal:std_logic_vector(63 downto 0);
  
begin  -- Rtl

round_constants : process (n_round)
begin
	case n_round is
            when "00000" => round_constant_signal <= X"0000000000000001" ;
	    when "00001" => round_constant_signal <= X"0000000000008082" ;
	    when "00010" => round_constant_signal <= X"800000000000808A" ;
	    when "00011" => round_constant_signal <= X"8000000080008000" ;
	    when "00100" => round_constant_signal <= X"000000000000808B" ;
	    when "00101" => round_constant_signal <= X"0000000080000001" ;
	    when "00110" => round_constant_signal <= X"8000000080008081" ;
	    when "00111" => round_constant_signal <= X"8000000000008009" ;
	    when "01000" => round_constant_signal <= X"000000000000008A" ;
	    when "01001" => round_constant_signal <= X"0000000000000088" ;
	    when "01010" => round_constant_signal <= X"0000000080008009" ;
	    when "01011" => round_constant_signal <= X"000000008000000A" ;
	    when "01100" => round_constant_signal <= X"000000008000808B" ;
	    when "01101" => round_constant_signal <= X"800000000000008B" ;
	    when "01110" => round_constant_signal <= X"8000000000008089" ;
	    when "01111" => round_constant_signal <= X"8000000000008003" ;
	    when "10000" => round_constant_signal <= X"8000000000008002" ;
	    when "10001" => round_constant_signal <= X"8000000000000080" ;
	    when "10010" => round_constant_signal <= X"000000000000800A" ;
	    when "10011" => round_constant_signal <= X"800000008000000A" ;
	    when "10100" => round_constant_signal <= X"8000000080008081" ;
	    when "10101" => round_constant_signal <= X"8000000000008080" ;
	    when "10110" => round_constant_signal <= X"0000000080000001" ;
	    when "10111" => round_constant_signal <= X"8000000080008008" ;	    	    
	    when others => round_constant_signal <=(others => '0');
        end case;
end process round_constants;



--iota
i5001: for y in 1 to 4 generate
	i5002: for x in 0 to 4 generate
		i5003: for i in 0 to 63 generate
			state_out(y)(x)(i)<=state_in(y)(x)(i);
		end generate;	
	end generate;
end generate;


i5012: for x in 1 to 4 generate
	i5013: for i in 0 to 63 generate
		state_out(0)(x)(i)<=state_in(0)(x)(i);
	end generate;	
end generate;



i5103: for i in 0 to 63 generate
	state_out(0)(0)(i)<=state_in(0)(0)(i) xor round_constant_signal(i);
end generate;

end rtl;
