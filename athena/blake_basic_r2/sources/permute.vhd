-- =========================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =========================================================================

library ieee;
use ieee.std_logic_1164.all;	   
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.sha3_blake_package.all;
            
entity permute4xor is
	generic (
	h : integer := 256;
	b : integer := 512;	
	iw : integer := 32 );
	port(		
		clk 		: in std_logic;		
		m			:	in std_logic_vector(b-1 downto 0);
		em			: in std_logic;
		round		:	in std_logic_vector(4 downto 0);
		cons : out std_logic_vector(b-1 downto 0);
		consout		:	out std_logic_vector(b/2-1 downto 0)
	);
end permute4xor;	
	 
architecture muxbased of permute4xor is	 
	type std_logic_matrix is array (15 downto 0) of std_logic_vector(iw - 1 downto 0) ;
	type std_logic_half_matrix is array (7 downto 0) of std_logic_vector(iw - 1 downto 0) ;
	--------------------------
	function wordmatrix2halfblk  	(x : std_logic_half_matrix) return std_logic_vector is
		variable retval : std_logic_vector(b/2-1 downto 0);
	begin
		for i in 0 to 7 loop
			retval(iw*(i+1) - 1 downto iw*i) := x(7-i);
		end loop;
		return retval;
	end wordmatrix2halfblk;
	--------------------------
	function blk2wordmatrix  	(x : std_logic_vector ) return std_logic_matrix is
		variable retval : std_logic_matrix;
	begin
		for i in 0 to 15 loop
			retval(15-i) := x(iw*(i+1) - 1 downto iw*i);
		end loop;
		return retval;
	end blk2wordmatrix;
	-------------------------- 
	
	signal mblk : std_logic_matrix;	

	type block_array is array(0 to 19) of std_logic_half_matrix;
	signal mblkprime : block_array; 
	
	signal round_sel : std_logic_vector(4 downto 0);   
	
	signal mprime_tmp, consprime_tmp, consout_tmp : std_logic_half_matrix;	
	
	function get_halfmatrixzero return std_logic_half_matrix is
		variable ret : std_logic_half_matrix;
	begin
		for i in 0 to 7 loop
			ret(0) := (others => '0');
		end loop;
		return ret;
	end function get_halfmatrixzero;  
	constant zero : std_logic_half_matrix := get_halfmatrixzero;
	--------------------------			
	constant consin : std_logic_vector(b-1 downto 0) := get_cons( h, b, iw );
	function get_cp ( gsize : integer; iw : integer ) return block_array is
		variable cblk : std_logic_matrix;   									   		
		variable cpblk : block_array;	   
								  
	begin							   
		for i in 0 to 15 loop
			cblk(15-i) := consin(iw*(i+1) - 1 downto iw*i);
		end loop;
		for i in 0 to 9 loop
			for j in 0 to 16/(8/gsize)-1 loop
				cpblk(2*i)(j) 	:= cblk( permute_array( i, j ) );
				cpblk(2*i+1)(j) := cblk( permute_array( i, j+8 ) );
			end loop;
		end loop;		
		return cpblk;
	end function get_cp;		
	------------------------------
	
	constant consblkprime : block_array := get_cp( 4, iw );	  
begin		
	cons <= consin;
	mblk <= blk2wordmatrix( m );
	
	ret1_gen : for i in 0 to 9 generate
		ret2_gen : for j in 0 to 7 generate	 	
			mblkprime(2*i)(j) 		<= mblk( permute_array( i, j ) );
			mblkprime(2*i+1)(j) 	<= mblk( permute_array( i, j+8 ) );
		end generate;
	end generate; 

	round_sel <= "10011" when em = '1' else round;	
	with round_sel select 
	mprime_tmp	 <= 	mblkprime(1) 	when "00000",
						mblkprime(2)  	when "00001",
						mblkprime(3)  	when "00010",
						mblkprime(4)  	when "00011",
						mblkprime(5)  	when "00100",
						mblkprime(6)  	when "00101",
						mblkprime(7)  	when "00110",
						mblkprime(8)  	when "00111",
						mblkprime(9)  	when "01000",
						mblkprime(10)  when "01001",
						mblkprime(11)  when "01010",
						mblkprime(12)  when "01011",
						mblkprime(13)  when "01100",	
						mblkprime(14)  when "01101",	
						mblkprime(15)  when "01110",	
						mblkprime(16)  when "01111",	
						mblkprime(17)  when "10000",	
						mblkprime(18)  when "10001",	
						mblkprime(19)  when "10010",	
						mblkprime(0)   when "10011",	
						mblkprime(1)   when "10100",	
						mblkprime(2)   when "10101",	
						mblkprime(3)   when "10110",	
						mblkprime(4)   when "10111",	
						mblkprime(5)   when "11000",	
						mblkprime(6)   when "11001",	
						mblkprime(7)   when "11010",							
						zero when  others ;
	
	with round_sel select 
	consprime_tmp	 <= consblkprime(1) 	when "00000",
						consblkprime(2)  	when "00001",
						consblkprime(3)  	when "00010",
						consblkprime(4)  	when "00011",
						consblkprime(5)  	when "00100",
						consblkprime(6) 	when "00101",
						consblkprime(7)  	when "00110",
						consblkprime(8)  	when "00111",
						consblkprime(9)  	when "01000",
						consblkprime(10)  	when "01001",
						consblkprime(11)  	when "01010",
						consblkprime(12)  	when "01011",
						consblkprime(13)  	when "01100",	
						consblkprime(14)  	when "01101",	
						consblkprime(15)  	when "01110",	
						consblkprime(16)  	when "01111",	
						consblkprime(17)  	when "10000",	
						consblkprime(18)  	when "10001",	
						consblkprime(19)  	when "10010",	
						consblkprime(0)   	when "10011",	
						consblkprime(1)   	when "10100",	
						consblkprime(2)  	when "10101",	
						consblkprime(3)   	when "10110",	
						consblkprime(4) 	when "10111",	
						consblkprime(5)   	when "11000",	
						consblkprime(6) 	when "11001",	
						consblkprime(7) 	when "11010",	
						consblkprime(0)  	when "11011",	
						zero	when  others ;
				
	output_gen : for i in 0 to 3 generate
		consout_tmp(i*2) 	<= mprime_tmp(i*2) xor consprime_tmp(i*2+1);
		consout_tmp(i*2+1) 	<= mprime_tmp(i*2+1) xor consprime_tmp(i*2);
	end generate;
	
	anotherinreg : process ( clk )
	begin
		if rising_edge( clk ) then	 
			consout <= wordmatrix2halfblk( consout_tmp );
		end if;
	end process;  
end muxbased;