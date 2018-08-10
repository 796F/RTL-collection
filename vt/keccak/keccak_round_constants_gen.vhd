--------------------------------------------------------------------------
--2010 CESCA @ Virginia Tech
--------------------------------------------------------------------------
--This program is free software: you can redistribute it and/or modify
--it under the terms of the GNU General Public License as published by
--the Free Software Foundation, either version 3 of the License, or
--(at your option) any later version.
--
--This program is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--GNU General Public License for more details.
--
--You should have received a copy of the GNU General Public License
--along with this program.  If not, see <http://www.gnu.org/licenses/>.
--------------------------------------------------------------------------
--Algorithm Name: Keccak
--Authors: Guido Bertoni, Joan Daemen, Michael Peeters and Gilles Van Assche
--Date: August 29, 2009

--This code, originally by Guido Bertoni, Joan Daemen, Michael Peeters and
--Gilles Van Assche as a part of the SHA-3 submission, is hereby put in the
--public domain. It is given as is, without any guarantee.

--For more information, feedback or questions, please refer to our website:
--http://keccak.noekeon.org/
--------------------------------------------------------------------------

library work;
	use work.keccak_globals.all;
	
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;	


entity keccak_round_constants_gen is
port(

    round_number: in unsigned(4 downto 0);
    round_constant_signal_out    : out std_logic_vector(63 downto 0));

end keccak_round_constants_gen;

architecture rtl of keccak_round_constants_gen is

----------------------------------------------------------------------------
-- Internal signal declarations
----------------------------------------------------------------------------
signal round_constant_signal: std_logic_vector(63 downto 0);
 
begin  -- Rtl
round_constants : process (round_number)
begin
	case round_number is
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

round_constant_signal_out<=round_constant_signal;
end rtl;
