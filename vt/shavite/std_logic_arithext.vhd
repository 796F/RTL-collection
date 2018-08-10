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

library IEEE;
use IEEE.std_logic_1164.all;

package std_logic_arithext is
    function LOGIC_SIGN_EXT(ARG: STD_LOGIC; SIZE: INTEGER) return STD_LOGIC_VECTOR;
    function LOGIC_ZERO_EXT(ARG: STD_LOGIC; SIZE: INTEGER) return STD_LOGIC_VECTOR;
end std_logic_arithext;

library IEEE;
use IEEE.std_logic_1164.all;

package body std_logic_arithext is
 	
  function LOGIC_SIGN_EXT(ARG: STD_LOGIC; SIZE: INTEGER) return STD_LOGIC_VECTOR is
	subtype rtype is STD_LOGIC_VECTOR (SIZE-1 downto 0);
	variable result: rtype;
	-- synopsys built_in SYN_ZERO_EXTEND

  begin
	if (ARG = '0') then
	    result := rtype'(others => '0');
	elsif (ARG = '1') then
	    result := rtype'(others => '1');	
	elsif (ARG = 'X') then
	    result := rtype'(others => 'X');
	end if;
	return result;
  end;
    

  function LOGIC_ZERO_EXT(ARG: STD_LOGIC; SIZE: INTEGER) return STD_LOGIC_VECTOR is
	subtype rtype is STD_LOGIC_VECTOR (SIZE-1 downto 0);
	variable result: rtype;

  begin
	result := rtype'(others => '0');
	result(0) := ARG;
	if (result(0) = 'X') then
	    result := rtype'(others => 'X');
	end if;
	return result;
  end;

end std_logic_arithext;
