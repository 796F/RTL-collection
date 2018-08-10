-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work; 
use work.sha3_pkg.all;
use work.sha3_bmw_package.all; 	 
use work.bmw_functions.all;

entity bmw_round is
	generic ( 	h 	: integer := 256;
				b  : integer := 512 ;
				adders_type:integer:=FCCA_BASED;	
				iw : integer := 32 );
	port ( 	message : in  std_logic_vector (b-1 downto 0);
		  	h_prev : in std_logic_vector (b-1 downto 0);
		  	h_next : out  std_logic_vector (b-1 downto 0) );
end bmw_round;

architecture struct of bmw_round is
	-- /////////////////////
	-- FUNCTION DECLARATION	   
	-- /////////////////////
	type std_logic_block is array (0 to 15) of std_logic_vector(iw - 1 downto 0) ;
	type std_logic_block_dbl is array (0 to 31) of std_logic_vector(iw - 1 downto 0) ;
	
	function blk2vec  ( x : std_logic_block) return std_logic_vector is
		variable retval : std_logic_vector(b-1 downto 0);
	begin
		for i in 0 to 15 loop
			retval(iw*(i+1) - 1 downto iw*i) := x(15-i);
		end loop;
		return retval;
	end blk2vec;


	function vec2blk  ( x : std_logic_vector(b-1 downto 0) ) return std_logic_block is
		variable retval : std_logic_block;
	begin
		for i in 0 to 15 loop
		retval(15-i) := x(iw*(i+1) - 1 downto iw*i);
		end loop;
		return retval;
	end vec2blk;
	
	function blkdbl2vec  (x : in std_logic_block_dbl) return std_logic_vector is
		variable retval : std_logic_vector((2*b-1) downto 0);
	begin
		for i in 0 to 31 loop
		retval(iw*(i+1) - 1 downto iw*i) := x(31-i);
		end loop;
		return retval;
	end blkdbl2vec;

	function vec2blkdbl  (x : in std_logic_vector((2*b)-1 downto 0) ) return std_logic_block_dbl is
		variable retval : std_logic_block_dbl;
	begin
		for i in 0 to 31 loop
		retval(31-i) := x(iw*(i+1) - 1 downto iw*i);
		end loop;
		return retval;
	end vec2blkdbl;

	
	-- /////////////////////////
	-- ///// Signals 	    ////
	-- /////////////////////////
	signal msg_blk			: std_logic_block;
	signal h_blk 			: std_logic_block;
	-- /////////////////////////
	-- F0
	-- /////////////////////////
	signal w_blk 			: std_logic_block;
	signal m_xor_h_blk 		: std_logic_block;
	
	-- /////////////////////////
	-- F1
	-- /////////////////////////
	signal q_dbl_blk : std_logic_block_dbl;	  
	
	type add_element_type is array( 16 to 31 ) of std_logic_vector( iw-1 downto 0);
   	signal add_element : add_element_type;  
	   
	   
	type expand1_type is array ( 16 to 16+expand_1_rounds-1) of std_logic_vector( iw-1 downto 0);
  	signal parta, partb, partc,partd: expand1_type; 
	signal parte,partf,partg,parth: expand1_type;
	signal parti,partj,partk,partl: expand1_type;
	signal partm,partn,parto,partp: expand1_type;  
	
	type expand2_type is array ( 16+expand_1_rounds to 31) of std_logic_vector( iw-1 downto 0);
	signal partq, partr : expand2_type;
	signal parts, partt, partu, partv, partw, partx, party  : expand2_type;
	
	signal qa_sel1, qa_sel2, qa_sel4, qa_sel6, qa_sel8, qa_sel10, qa_sel12 : expand2_type;
	constant kj : std_logic_vector(b-1 downto 0) := get_kj(b, iw);
	constant kj_blk  : std_logic_block := vec2blk( kj );
	
	
	-- /////////////////////////
	-- F2
	-- /////////////////////////
	signal h_next_blk : std_logic_block;
	
	signal xl	: std_logic_vector(iw-1 downto 0);
	signal xh	: std_logic_vector(iw-1 downto 0);
	
	constant zeros : std_logic_vector(iw-1 downto 0) := (others => '0');	  
	
	
	signal msg0, msg3, msg10, msg0r, msg3r, msg10r, kj_in, h9 :  add_element_type;
begin

	h_blk  		<= vec2blk(h_prev);
	msg_blk 	<= vec2blk(message);
	
	-- ////////////////////////////////////////////////////////
	-- /////// 					F1						///////
	-- ////////////////////////////////////////////////////////
	--======populate block with message xor h_previous======--
		fill_mxorh: for i in 0 to 15 generate
			m_xor_h_blk(i) <= msg_blk(i) xor h_blk(i);
		end generate fill_mxorh;
	
	--===================bitjective_1 transform of message xor h_previous==============================--			   
		w_blk( 0) <= ((m_xor_h_blk( 5) - m_xor_h_blk( 7)) + m_xor_h_blk(10)) + (m_xor_h_blk(13)  + m_xor_h_blk(14)); -- Z = ((A - B) + C) + (D + E)
		w_blk( 1) <= ((m_xor_h_blk( 6) - m_xor_h_blk( 8)) + m_xor_h_blk(11)) + (m_xor_h_blk(14)  - m_xor_h_blk(15)); -- Z = ((A - B) + C) + (D - E)		
		w_blk( 2) <=  (m_xor_h_blk( 0) + m_xor_h_blk( 7)) + (m_xor_h_blk( 9) -  m_xor_h_blk(12)) + m_xor_h_blk(15);  -- Z = (A + B) + (C - D) + E
		w_blk( 3) <=  (m_xor_h_blk( 0) - m_xor_h_blk( 1)) + (m_xor_h_blk( 8) -  m_xor_h_blk(10)) + m_xor_h_blk(13);  -- Z = (A - B) + (C - D) + E
		w_blk( 4) <=  (m_xor_h_blk( 1) + m_xor_h_blk( 2)) + (m_xor_h_blk( 9) -  m_xor_h_blk(11)) - m_xor_h_blk(14);  -- Z = (A + B) + (C - D) - E
		w_blk( 5) <=  (m_xor_h_blk( 3) - m_xor_h_blk( 2)) + (m_xor_h_blk(10) -  m_xor_h_blk(12)) + m_xor_h_blk(15);  -- Z = (A - B) + (C - D) + E
		w_blk( 6) <= (((m_xor_h_blk( 4) - m_xor_h_blk( 0)) - m_xor_h_blk( 3)) - m_xor_h_blk(11)) + m_xor_h_blk(13);  -- Z = (((A - B) - C) - D) + E
		w_blk( 7) <= (((m_xor_h_blk( 1) - m_xor_h_blk( 4)) - m_xor_h_blk( 5)) -  m_xor_h_blk(12)) - m_xor_h_blk(14); -- Z = (((A - B) - C) - D) - E
		w_blk( 8) <= ((m_xor_h_blk( 2) - m_xor_h_blk( 5)) - m_xor_h_blk( 6)) + (m_xor_h_blk(13)  - m_xor_h_blk(15)); -- Z = ((A - B) - C) + (D - E)
		w_blk( 9) <=  (m_xor_h_blk( 0) - m_xor_h_blk( 3)) + (m_xor_h_blk( 6) - (m_xor_h_blk( 7))  + m_xor_h_blk(14)); -- Z = (A - B) + (C - D) + E)
		w_blk(10) <= (((m_xor_h_blk( 8) - m_xor_h_blk( 1)) - m_xor_h_blk( 4)) - m_xor_h_blk( 7))  + m_xor_h_blk(15); -- Z = (((A - B) - C) - D) + E
		w_blk(11) <= (((m_xor_h_blk( 8) - m_xor_h_blk( 0)) - m_xor_h_blk( 2)) - m_xor_h_blk( 5))  + m_xor_h_blk( 9); -- Z = (((A - B) - C) - D) + E
		w_blk(12) <= (m_xor_h_blk( 1) + m_xor_h_blk(10)) +((m_xor_h_blk( 3) - m_xor_h_blk( 6)) - m_xor_h_blk( 9)) ;  -- Z = (A + E) + ((B - C) - D)
		w_blk(13) <= ((m_xor_h_blk( 2) + m_xor_h_blk( 4)) + m_xor_h_blk( 7)) + (m_xor_h_blk(10)  + m_xor_h_blk(11)); -- Z = ((A + B) + C) + (D + E)
		w_blk(14) <= (m_xor_h_blk( 3) - m_xor_h_blk( 5)) + ((m_xor_h_blk( 8) - m_xor_h_blk(11))  - m_xor_h_blk(12)); -- Z = (A - B) + ((C - D) - E)
		w_blk(15) <= (((m_xor_h_blk(12) - m_xor_h_blk( 4)) - m_xor_h_blk( 6)) - m_xor_h_blk( 9)) + m_xor_h_blk(13); -- Z = (((A - B) - C) - D) + E
	
	--===================bitjective_2 transform of w==============================--   
		q_dbl_blk( 0) <= s0(w_blk( 0), h) + h_blk( 1);
		q_dbl_blk( 1) <= s1(w_blk( 1), h) + h_blk( 2);
		q_dbl_blk( 2) <= s2(w_blk( 2), h) + h_blk( 3);
		q_dbl_blk( 3) <= s3(w_blk( 3), h) + h_blk( 4);
		q_dbl_blk( 4) <= s4(w_blk( 4), h) + h_blk( 5);
		q_dbl_blk( 5) <= s0(w_blk( 5), h) + h_blk( 6);
		q_dbl_blk( 6) <= s1(w_blk( 6), h) + h_blk( 7);
		q_dbl_blk( 7) <= s2(w_blk( 7), h) + h_blk( 8);
		q_dbl_blk( 8) <= s3(w_blk( 8), h) + h_blk( 9);
		q_dbl_blk( 9) <= s4(w_blk( 9), h) + h_blk(10);
		q_dbl_blk(10) <= s0(w_blk(10), h) + h_blk(11);
		q_dbl_blk(11) <= s1(w_blk(11), h) + h_blk(12);
		q_dbl_blk(12) <= s2(w_blk(12), h) + h_blk(13);
		q_dbl_blk(13) <= s3(w_blk(13), h) + h_blk(14);
		q_dbl_blk(14) <= s4(w_blk(14), h) + h_blk(15);
		q_dbl_blk(15) <= s0(w_blk(15), h) + h_blk( 0);
	
	-- ////////////////////////////////////////////////////////
	-- /////// 					F1						///////
	-- ////////////////////////////////////////////////////////	  
	

	
	addelement: for j in 16 to 31 generate
			msg0r(j) <= rolx( msg_blk((j-16) mod 16), (((j-16) mod 16) + 1) );
			msg3r(j) <= rolx( msg_blk((j-13) mod 16), (((j-13) mod 16) + 1) ) ;
			msg10r(j) <= rolx( msg_blk((j-6) mod 16),  (((j-6) mod 16) + 1)  )	;
			msg0(j) <= msg_blk((j-16) mod 16);
			msg3(j) <= msg_blk((j-13) mod 16);
			msg10(j) <= msg_blk((j-6) mod 16);
			kj_in(j) <= kj_blk(j-16);
			h9(j) <= h_blk((j-16+7) mod 16);
			
		add_element(j) <= 	 (( rolx( msg_blk((j-16) mod 16), (((j-16) mod 16) + 1) ) + 
								rolx( msg_blk((j-13) mod 16), (((j-13) mod 16) + 1) ) - 
								rolx( msg_blk((j-6) mod 16),  (((j-6) mod 16) + 1)  ) + 
								kj_blk(j-16))
								xor h_blk((j-16+7) mod 16));
	end generate addelement;	
	
	expand1:	for j in 16 to 16+expand_1_rounds-1 generate
		parta(j) <= s1(q_dbl_blk(j-16), h );		partb(j) <= s2(q_dbl_blk(j-15), h );		partc(j) <= s3(q_dbl_blk(j-14), h );		partd(j) <= s0(q_dbl_blk(j-13), h );
		parte(j) <= s1(q_dbl_blk(j-12), h );		partf(j) <= s2(q_dbl_blk(j-11), h );		partg(j) <= s3(q_dbl_blk(j-10), h );		parth(j) <= s0(q_dbl_blk(j- 9), h );
		parti(j) <= s1(q_dbl_blk(j- 8), h );		partj(j) <= s2(q_dbl_blk(j- 7), h );		partk(j) <= s3(q_dbl_blk(j- 6), h );		partl(j) <= s0(q_dbl_blk(j- 5), h );
		partm(j) <= s1(q_dbl_blk(j- 4), h );		partn(j) <= s2(q_dbl_blk(j- 3), h );		parto(j) <= s3(q_dbl_blk(j- 2), h );		partp(j) <= s0(q_dbl_blk(j- 1), h );
		
		ba1 : entity work.bmw_adders(bmw_adders) 
			generic map (adders_type=>adders_type, n => iw)
			port map(
			ina=>parta(j),	inb=>partb(j),	inc=>partc(j),	ind=>partd(j),
			ine=>parte(j),	inf=>partf(j),	ing=>partg(j),	inh=>parth(j),
			ini=>parti(j),	inj=>partj(j),	ink=>partk(j),	inl=>partl(j),
			inm=>partm(j),	inn=>partn(j),	ino=>parto(j),	inp=>partp(j),
			inq=>add_element(j),			output=>q_dbl_blk(j)); 
	end generate expand1;

	expand2:	for j in 16+expand_1_rounds to 31 generate		
		partq(j) <= s4(q_dbl_blk(j-2), h);		
		partr(j) <= s5(q_dbl_blk(j-1), h);		parts(j) <= r1(q_dbl_blk(j-15), h);		partt(j) <= r2(q_dbl_blk(j-13), h);		partu(j) <= r3(q_dbl_blk(j-11), h);
		partv(j) <= r4(q_dbl_blk(j-9), h);		partw(j) <= r5(q_dbl_blk(j-7), h);		partx(j) <= r6(q_dbl_blk(j-5), h);		party(j) <= r7(q_dbl_blk(j-3), h);
		
		ba2 : entity work.bmw_adders(bmw_adders) 
			generic map (adders_type=>adders_type, n => iw)
			port map (
			ina=>q_dbl_blk(j-16), 	inb=>q_dbl_blk(j-14),	inc=>q_dbl_blk(j-12),	ind=>q_dbl_blk(j-10),
			ine=>q_dbl_blk(j- 8), 	inf=>q_dbl_blk(j- 6), 	ing=>q_dbl_blk(j- 4), 	inh=>partq(j),
			ini=>partr(j), 			inj=>parts(j),			ink=>partt(j),			inl=>partu(j),
			inm=>partv(j),			inn=>partw(j),			ino=>partx(j),			inp=>party(j),
			inq=>add_element(j),							output=> q_dbl_blk(j));				  
			
			
		qa_sel1(j) <= q_dbl_blk(j-16);
	qa_sel2(j) <= q_dbl_blk(j-14);
	qa_sel4(j) <= q_dbl_blk(j-12);
	qa_sel6(j) <= q_dbl_blk(j-10);
	qa_sel8(j) <= q_dbl_blk(j-8);
	qa_sel10(j) <= q_dbl_blk(j-6);
	qa_sel12(j) <= q_dbl_blk(j-4);
	end generate expand2;
	
	
	
	
	-- ////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////
	
	
	
	-- ////////////////////////////////////////////////////////
	-- /////// 					F2						///////
	-- ////////////////////////////////////////////////////////
	
	--========assign xl and xh==========
	
	xl <= 		 q_dbl_blk(16) xor q_dbl_blk(17) xor q_dbl_blk(18) xor q_dbl_blk(19) xor q_dbl_blk(20) xor q_dbl_blk(21) xor q_dbl_blk(22) xor  q_dbl_blk(23);
	xh <= xl xor q_dbl_blk(24) xor q_dbl_blk(25) xor q_dbl_blk(26) xor q_dbl_blk(27) xor q_dbl_blk(28) xor q_dbl_blk(29) xor q_dbl_blk(30) xor  q_dbl_blk(31);

	--==================assign h_next_blk(0 to 7)============================
	
	h_next_blk( 0) <= ( shlx(xh, 5) xor shrx(q_dbl_blk(16), 5) xor msg_blk(0)) + ( xl xor q_dbl_blk(24) xor q_dbl_blk(0) );
	h_next_blk( 1) <= ( shrx(xh, 7) xor shlx(q_dbl_blk(17), 8) xor msg_blk(1)) + ( xl xor q_dbl_blk(25) xor q_dbl_blk(1) );
	h_next_blk( 2) <= ( shrx(xh, 5) xor shlx(q_dbl_blk(18), 5) xor msg_blk(2)) + ( xl xor q_dbl_blk(26) xor q_dbl_blk(2) );
	h_next_blk( 3) <= ( shrx(xh, 1) xor shlx(q_dbl_blk(19), 5) xor msg_blk(3)) + ( xl xor q_dbl_blk(27) xor q_dbl_blk(3) );
	h_next_blk( 4) <= ( shrx(xh, 3) xor      q_dbl_blk(20)     xor msg_blk(4)) + ( xl xor q_dbl_blk(28) xor q_dbl_blk(4) );
	h_next_blk( 5) <= ( shlx(xh, 6) xor shrx(q_dbl_blk(21), 6) xor msg_blk(5)) + ( xl xor q_dbl_blk(29) xor q_dbl_blk(5) );
	h_next_blk( 6) <= ( shrx(xh, 4) xor shlx(q_dbl_blk(22), 6) xor msg_blk(6)) + ( xl xor q_dbl_blk(30) xor q_dbl_blk(6) );
	h_next_blk( 7) <= ( shrx(xh,11) xor shlx(q_dbl_blk(23), 2) xor msg_blk(7)) + ( xl xor q_dbl_blk(31) xor q_dbl_blk(7) );

	h_next_blk( 8) <= rolx(h_next_blk(4), 9) + ((xh xor q_dbl_blk(24) xor msg_blk( 8) ) + (shlx(xl, 8) xor q_dbl_blk(23) xor q_dbl_blk( 8) ));
	h_next_blk( 9) <= rolx(h_next_blk(5),10) + ((xh xor q_dbl_blk(25) xor msg_blk( 9) ) + (shrx(xl, 6) xor q_dbl_blk(16) xor q_dbl_blk( 9) ));
	h_next_blk(10) <= rolx(h_next_blk(6),11) + ((xh xor q_dbl_blk(26) xor msg_blk(10) ) + (shlx(xl, 6) xor q_dbl_blk(17) xor q_dbl_blk(10) ));
	h_next_blk(11) <= rolx(h_next_blk(7),12) + ((xh xor q_dbl_blk(27) xor msg_blk(11) ) + (shlx(xl, 4) xor q_dbl_blk(18) xor q_dbl_blk(11) ));
	h_next_blk(12) <= rolx(h_next_blk(0),13) + ((xh xor q_dbl_blk(28) xor msg_blk(12) ) + (shrx(xl, 3) xor q_dbl_blk(19) xor q_dbl_blk(12) ));
	h_next_blk(13) <= rolx(h_next_blk(1),14) + ((xh xor q_dbl_blk(29) xor msg_blk(13) ) + (shrx(xl, 4) xor q_dbl_blk(20) xor q_dbl_blk(13) ));
	h_next_blk(14) <= rolx(h_next_blk(2),15) + ((xh xor q_dbl_blk(30) xor msg_blk(14) ) + (shrx(xl, 7) xor q_dbl_blk(21) xor q_dbl_blk(14) ));
	h_next_blk(15) <= rolx(h_next_blk(3),16) + ((xh xor q_dbl_blk(31) xor msg_blk(15) ) + (shrx(xl, 2) xor q_dbl_blk(22) xor q_dbl_blk(15) ));

	--========translate output blocks to vector==========	
	h_next <= blk2vec( h_next_blk );

end struct;

