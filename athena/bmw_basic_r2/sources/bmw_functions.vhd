-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.ALL;
use work.sha3_pkg.all;

package bmw_functions is
	function s0 ( i : std_logic_vector; h : integer ) return std_logic_vector;
	function s1 ( i : std_logic_vector; h : integer ) return std_logic_vector; 
	function s2 ( i : std_logic_vector; h : integer ) return std_logic_vector; 
	function s3 ( i : std_logic_vector; h : integer ) return std_logic_vector; 
	function s4 ( i : std_logic_vector; h : integer ) return std_logic_vector; 
	function s5 ( i : std_logic_vector; h : integer ) return std_logic_vector; 
	function r1 ( i : std_logic_vector; h : integer ) return std_logic_vector; 
	function r2 ( i : std_logic_vector; h : integer ) return std_logic_vector; 
	function r3 ( i : std_logic_vector; h : integer ) return std_logic_vector; 
	function r4 ( i : std_logic_vector; h : integer ) return std_logic_vector; 
	function r5 ( i : std_logic_vector; h : integer ) return std_logic_vector; 
	function r6 ( i : std_logic_vector; h : integer ) return std_logic_vector; 
	function r7 ( i : std_logic_vector; h : integer ) return std_logic_vector; 	  
end bmw_functions;

package body bmw_functions is
	function s0 ( i : std_logic_vector; h : integer ) return std_logic_vector is		
	begin
		if ( h = 256 or h = 224 ) then
			return ( shrx(i,1) xor shlx(i,3) xor rolx(i,4) xor rolx(i,19) );
		elsif ( h = 512 or h = 384 ) then
			return ( shrx(i,1) xor shlx(i,3) xor rolx(i,4) xor rolx(i,37) );	
		else	-- error
			return "00";
		end if;
	end function s0;
	function s1 ( i : std_logic_vector; h : integer ) return std_logic_vector is
	begin
		if ( h = 256 or h = 224 ) then
			return ( shrx(i,1) xor shlx(i,2) xor rolx(i, 8) xor rolx(i,23) );
		elsif ( h = 512 or h = 384 ) then
			return ( shrx(i,1) xor shlx(i,2) xor rolx(i,13) xor rolx(i,43) );
		else	-- error
			return "00";
		end if;
	end function s1;
	function s2 ( i : std_logic_vector; h : integer ) return std_logic_vector is
	begin
		if ( h = 256 or h = 224 ) then
			return ( shrx(i,2) xor shlx(i,1) xor rolx(i,12) xor rolx(i,25) );
		elsif ( h = 512 or h = 384 ) then
			return ( shrx(i,2) xor shlx(i,1) xor rolx(i,19) xor rolx(i,53) );
		else	-- error
			return "00";
		end if;
	end function s2;
	function s3 ( i : std_logic_vector; h : integer ) return std_logic_vector is
	begin
		if ( h = 256 or h = 224 ) then
			return ( shrx(i,2) xor shlx(i,2) xor rolx(i,15) xor rolx(i,29) );
		elsif ( h = 512 or h = 384 ) then
			return ( shrx(i,2) xor shlx(i,2) xor rolx(i,28) xor rolx(i,59) );
		else	-- error
			return "00";
		end if;
	end function s3;
	function s4 ( i : std_logic_vector; h : integer ) return std_logic_vector is
	begin
		return ( shrx(i,1) xor i );		
	end function s4;
	function s5 ( i : std_logic_vector; h : integer ) return std_logic_vector is
	begin
		return ( shrx(i,2) xor i );
	end function s5;
	function r1 ( i : std_logic_vector; h : integer ) return std_logic_vector is
	begin
		if ( h = 256 or h = 224 ) then
			return rolx(i,3);
		elsif ( h = 512 or h = 384 ) then
			return rolx(i,5);
		else	-- error
			return "00";
		end if;
	end function r1;
	function r2 ( i : std_logic_vector; h : integer ) return std_logic_vector is
	begin
		if ( h = 256 or h = 224 ) then
			return rolx(i, 7);
		elsif ( h = 512 or h = 384 ) then
			return rolx(i,11);
		else	-- error
			return "00";
		end if;
	end function r2;
	function r3 ( i : std_logic_vector; h : integer ) return std_logic_vector is
	begin
		if ( h = 256 or h = 224 ) then
			return rolx(i,13);
		elsif ( h = 512 or h = 384 ) then
			return rolx(i,27);
		else	-- error
			return "00";
		end if;
	end function r3;
	function r4 ( i : std_logic_vector; h : integer ) return std_logic_vector is
	begin
		if ( h = 256 or h = 224 ) then
			return rolx(i,16);
		elsif ( h = 512 or h = 384 ) then
			return rolx(i,32);
		else	-- error
			return "00";
		end if;
	end function r4;
	function r5 ( i : std_logic_vector; h : integer ) return std_logic_vector is
	begin
		if ( h = 256 or h = 224 ) then
			return rolx(i,19);
		elsif ( h = 512 or h = 384 ) then
			return rolx(i,37);
		else	-- error
			return "00";
		end if;
	end function r5;
	function r6 ( i : std_logic_vector; h : integer ) return std_logic_vector is
	begin
		if ( h = 256 or h = 224 ) then
			return rolx(i,23);
		elsif ( h = 512 or h = 384 ) then
			return rolx(i,43);
		else	-- error
			return "00";
		end if;
	end function r6;
	function r7 ( i : std_logic_vector; h : integer ) return std_logic_vector is
	begin
		if ( h = 256 or h = 224 ) then
			return rolx(i,27);
		elsif ( h = 512 or h = 384 ) then
			return rolx(i,53);
		else	-- error
			return "00";
		end if;
	end function r7;
	
end package body;
