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

library STD;
 use STD.textio.all;
  library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_misc.all;
    use IEEE.std_logic_arith.all;
library work;

package keccak_globals is
constant num_plane : integer := 5;
constant num_sheet : integer := 5;
constant logD : integer :=4;
constant N : integer := 64;
--types
 type k_lane        is  array ((N-1) downto 0)  of std_logic;    
 type k_plane        is array ((num_sheet-1) downto 0)  of k_lane;    
 type k_state        is array ((num_plane-1) downto 0)  of k_plane;  

end package;