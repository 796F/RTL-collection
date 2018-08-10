-- =====================================================================
-- Copyright © 2010 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;	 
use work.sha3_pkg.all;

package sha3_jh_package is		   

	
	-- ===================
	-- Depending parameter values, use the following :
	-- ===================
	-- for r/b-h = 16/32-256 
	-- roundnr = r = 16
	-- mw = b*8 = 32*8 = 256
	-- h = h = 256
	-- ===================		  
	constant d		: integer := 8;
	constant b		: integer := 2**(d+2);
	constant mw		: integer := 2**(d+1);		-- message width
	
	constant crw	: integer := 2**d;			-- cr width
	constant crkw	: integer := 2**(d-2);		-- cr key width
	
	constant w		: integer := 64;		-- message interface	

	
	constant roundnr 		: integer := 5*(d-1)+1;
	constant log2roundnr	: integer := log2( roundnr );
	
	constant bseg			: integer := b/w;  
		
	constant mwseg			: integer := mw/w;	
	constant log2mw 		: integer := log2( mw );
	constant log2mwseg 		: integer := log2( mwseg );
	
 	constant log2mwsegzeros	: std_logic_vector(log2mwseg-1 downto 0) := (others => '0');
	constant bzeros			: std_logic_vector(b-1 downto 0) := (others => '0');
	constant wzeros			: std_logic_vector(w-1 downto 0) := (others => '0');
	constant mwzeros		: std_logic_vector(mw-1 downto 0) := (others => '0');
	constant crkwzeros 		: std_logic_vector(crkw-1 downto 0) := (others => '0');
	constant log2roundnrzeros : std_logic_vector(log2roundnr-1 downto 0) := (others => '0');
	
	type sbox_type is array (0 to 1, 0 to 15) of std_logic_vector(3 downto 0);
	constant sbox_rom : sbox_type := ((	"1001", "0000", "0100", "1011", "1101", "1100", "0011", "1111",
										"0001", "1010", "0010", "0110", "0111", "0101", "1000", "1110"),
									  (	"0011", "1100", "0110", "1101", "0101", "0111", "0001", "1001",
										"1111", "0010", "0000", "0100", "1011", "1010", "1110", "1000"));
										
	type std_logic_matrix is array (31 downto 0) of std_logic_vector(31 downto 0) ;
	function blk2wordmatrix_inv	(signal x : in std_logic_vector(b-1 downto 0) ) return std_logic_matrix;
	function form_group  (hm : in std_logic_vector; b : integer; cw : integer ) return std_logic_vector;
	function degroup  (rd : in std_logic_vector; b : integer; cw : integer ) return std_logic_vector;
	function get_iv ( h : integer ) return std_logic_vector;
	function permute ( ii : std_logic_vector; bw : integer; cw : integer ) return std_logic_vector;
	-- iv		 
   	constant cr8_iv	: std_logic_vector(crw-1 downto 0) := x"6A09E667F3BCC908B2FB1366EA957D3E3ADEC17512775099DA2F590B0667322A";
	constant iv512 : std_logic_vector(b-1 downto 0) := x"50AB6058C60942CC4CE7A54CBDB9DC1BAF2E7AFBD1A15E24E5F44EABC4D5C0A14CF243660C562073999381EA9A8B3D18CF65D9FCA940B6C79E831273BEFE3B660F9A2F7E0A32D8E017D491558E0B134005B5E4DEC44E5F3F8CBC5AEE98FD1D3214081C25E46CE6C41B4B95BCE1BD43DB7F229EC243B680140A33B909333C0303";
	constant iv256 : std_logic_vector(b-1 downto 0) := x"C968B8E2C53A596E427E45EF1D7AE6E56145B7D906711F7A2FC7617806A922017B2991C1B91929E2C42B4CE18CC5A2D66220BECA901B5DDFD3B205638EA7AC5F143E8CBA6D313104B0E70054905272714CCE321E075DE5101BA800ECE20251789F5772795FD104A5F0B8B63425F5B2381670FA3E5F907F17E28FC064E769AC90";
end sha3_jh_package;

package body sha3_jh_package is
	function blk2wordmatrix_inv  (signal x : in std_logic_vector(b-1 downto 0) ) return std_logic_matrix is
		variable retval : std_logic_matrix;
	begin
		for i in 0 to 31 loop
			retval(32-1-i) := x(32*(i+1) - 1 downto 32*i);
		end loop;
		return retval;
	end blk2wordmatrix_inv;	
	
	function form_group  (hm : in std_logic_vector; b : integer; cw : integer ) return std_logic_vector is   
		variable g : std_logic_vector(b-1 downto 0);
	begin
		for i in 0 to cw/2-1 loop
			g(b-i*8-1 downto b-i*8-4)   := hm(b-1 - i) & hm(b-1 - (i+cw)) & hm(b-1 - (i+2*cw)) & hm(b-1 - (i+3*cw));
			g(b-i*8-5 downto b-i*8-8)	:= hm(b-1 - (i + cw/2)) & hm(b-1 - ((i+cw) + (cw/2))) & hm(b-1 - (i+2*cw + cw/2)) & hm(b-1 - (i+3*cw + cw/2));			
		end loop; 
		return g;
	end form_group;	 
	
	function degroup  (rd : in std_logic_vector; b : integer; cw : integer ) return std_logic_vector is   
		variable dg : std_logic_vector(b-1 downto 0);
	begin
		for i in 0 to cw/2-1 loop
			dg(b-1 - i) 	   := rd(b-i*8-1);
			dg(b-1 - (i+cw))   := rd(b-i*8-2);
			dg(b-1 - (i+2*cw)) := rd(b-i*8-3);
			dg(b-1 - (i+3*cw)) := rd(b-i*8-4);
			dg(b-1 - (i + cw/2)) 		:= rd(b-i*8-5);
			dg(b-1 - (i+cw + cw/2))		:= rd(b-i*8-6);
			dg(b-1 - (i+2*cw + cw/2))	:= rd(b-i*8-7);
			dg(b-1 - (i+3*cw + cw/2))	:= rd(b-i*8-8);
		end loop; 
		return dg;
	end degroup;	
	
	function get_iv ( h : integer ) return std_logic_vector is
	begin
		if ( h = 256 ) then
			return iv256;
		else
			return iv512;
		end if;	
	end get_iv;		   
	
	function permute ( ii : std_logic_vector; bw : integer; cw : integer ) return std_logic_vector is
		type array_type is array (0 to cw-1) of std_logic_vector(3 downto 0);
		variable ww, pi, pp, phi : array_type;		   
		variable oo : std_logic_vector(bw-1 downto 0);
	begin		
		inout_gen : for i in bw/4-1 downto 0 loop
			ww(bw/4-1 - i) := ii(i*4+3 downto i*4);  		
		end loop;
	
		pi_gen : for  i in cw/4-1 downto 0 loop
			pi(i*4 + 0) := ww(i*4 + 0);
			pi(i*4 + 1) := ww(i*4 + 1);
			pi(i*4 + 2) := ww(i*4 + 3);
			pi(i*4 + 3) := ww(i*4 + 2);
		end loop;
		
		--pp
		pp_gen : for i in cw/2-1 downto 0 loop
			pp(i)  			:= pi(i*2);
			pp(i + cw/2)	:= pi(i*2 + 1);
		end loop;
		
		-- phi	
		phi_gen1 : for i in cw/2-1 downto 0 loop
			phi(i) := pp(i);
		end loop;
		phi_gen : for i in cw/4-1 downto 0 loop
			phi(i*2 + cw/2)  	:= pp(i*2 + 1 + cw/2);
			phi(i*2 + 1 + cw/2) := pp(i*2 + cw/2);	
		end loop;	   
		
		out_gen : for i in bw/4-1 downto 0 loop
			oo(i*4+3 downto i*4) := phi(bw/4-1 - i);
		end loop;
	
		return oo;
	end permute;
end package body;
