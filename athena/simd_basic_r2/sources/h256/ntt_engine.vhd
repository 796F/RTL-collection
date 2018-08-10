-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.twiddle_factor_pkg.all;
use work.sha3_pkg.all;

entity ntt_engine is  
	generic ( h : integer := 512; pts : integer := 256 );
	port
	( clk 		: in std_logic;
	  rst		: in std_logic;
	  
	  ctrl		: in std_logic_vector(6 downto 0);  
	  x : in ntt_in_type(0 to pts-1);	 
	  y : out ntt_out_type(0 to pts-1)
	);
end ntt_engine;

architecture struct of ntt_engine is		  
	
	type twiddle_type is array (0 to log2(pts/2)-1) of halfptsx8(0 to pts/2 -1 ); 
	type ptsx17 is array (natural range <>) OF std_logic_vector(16 downto 0);
	type ptsx11 is array (natural range <>) OF std_logic_vector(10 downto 0);

	-- input
	signal init_data, regout : ntt_out_type(0 to pts-1);
	
	-- ntt core circuit
	signal ntt, ntt_out : ntt_out_type(0 to pts-1);
	
	-- addition factor
	signal af : ptsx10(0 to pts-1);																													   
	
	-- counter
	signal stage : std_logic_vector(2 downto 0);	   
	signal twiddle_in :  halfptsx8( 0 to pts/2 -1 );
	signal twiddle : twiddle_type;		 
	
	-- muxes
	signal stage_1, stage_2, stage_3, stage_4, stage_5, stage_6, stage_7, stage_mux : ntt_out_type(0 to pts-1);
	signal stage_2t, stage_3t, stage_4t, stage_5t, stage_6t, stage_7t, stage_8 : ntt_out_type(0 to pts-1);
	
	
	-- final addition modulo
	signal add_out : ptsx11(0 to pts-1);
	signal final_mod_in : ptsx17(0 to pts-1);		   
	signal modout : ntt_out_type(0 to pts-1);
	
	-- Control signal assignments
	signal count : std_logic_vector(2 downto 0);
	signal start, sfinal : std_logic;
	signal en : std_logic;	 
	signal done : std_logic;	   
	
		-- twiddle constant
	constant twiddle_2pts :  halfptsx8( 0 to pts/2 -1 ) := twiddle_gen(2, pts);
	constant twiddle_4pts :  halfptsx8( 0 to pts/2 -1 ) := twiddle_gen(4, pts);
	constant twiddle_8pts :  halfptsx8( 0 to pts/2 -1 ) := twiddle_gen(8, pts);
	constant twiddle_16pts :  halfptsx8( 0 to pts/2 -1 ) := twiddle_gen(16, pts);
	constant twiddle_32pts :  halfptsx8( 0 to pts/2 -1 ) := twiddle_gen(32, pts);
	constant twiddle_64pts :  halfptsx8( 0 to pts/2 -1 ) := twiddle_gen(64, pts);
	constant twiddle_128pts :  halfptsx8( 0 to pts/2 -1 ) := twiddle_gen(128, pts);
	constant twiddle_256pts :  halfptsx8( 0 to 127 ) := twiddle_gen(256, 256);    
		-- af constant
	constant addition_factor 		: ptsx10(0 to pts-1) := af_gen(h, 0, pts);
	constant addition_factor_final 	: ptsx10(0 to pts-1) := af_gen(h, 1, pts);	  
		-- mux rearrange size
	constant pts4in : integer := pts/4;		    		-- if pts = 128, pts4in = 32
	constant pts8in : integer := pts4in/2;				-- if pts = 128, pts4in = 16
	constant pts16in : integer := pts8in/2;				-- if pts = 128, pts4in = 8
	constant pts32in : integer := pts16in/2;			-- if pts = 128, pts4in = 4
	constant pts64in : integer := pts32in/2;			-- if pts = 128, pts4in = 2
	constant pts128in : integer := pts64in/2;			-- if pts = 128, pts4in = 1
	--constant twiddle_factor_cons : halfptsx8(0 to 127 ) := twiddle_factor_gen ( 256 );
	constant twiddle_factor_cons : halfptsx8( 0 to pts/2-1 ) := twiddle_factor_gen( pts );
begin							 
	-- control signals		
	done <= ctrl(6);
	en <= ctrl(5);
	start <= ctrl(4);
	count <= ctrl(3 downto 1);
	sfinal <= ctrl(0);
	
	-- ///////////////////////////////////	
	-- Reverse bit to go into FFT
	reverse : for i in 0 to pts-1 generate
		init_data(i) <= '0' & x( conv_integer( reverse_bits( conv_std_logic_vector(i,log2(pts)), log2(pts))));
	end generate;		  
	
	-- ///////////////////////////////////
	-- Input to NTT
	ntt <= init_data when start = '1' else regout;		
	
	-- ///////////////////////////////////
	--- twiddle factor generation circuit	 
	twiddle_256 : if  (pts = 128) generate
		twiddle_gen : process( clk ) 
		begin	  
			if rising_edge( clk ) then
				if ( start = '1' or rst = '1') then
					twiddle(0) <= twiddle_4pts;
					twiddle(1) <= twiddle_8pts;
					twiddle(2) <= twiddle_16pts;
					twiddle(3) <= twiddle_32pts;
					twiddle(4) <= twiddle_64pts;
					twiddle(5) <= twiddle_128pts;
				elsif ( en = '1' ) then
					for i in 0 to 4 loop
						twiddle(i) <= twiddle(i+1);
					end loop;					
					twiddle(5) <= twiddle(0);
				end if;
			end if;
		end process twiddle_gen;			
	end generate;
	twiddle_512 : if (pts = 256) generate
		twiddle_gen : process( clk ) 
		begin	  
			if rising_edge( clk ) then
				if ( start = '1' or rst = '1') then
					twiddle(0) <= twiddle_4pts;
					twiddle(1) <= twiddle_8pts;
					twiddle(2) <= twiddle_16pts;
					twiddle(3) <= twiddle_32pts;
					twiddle(4) <= twiddle_64pts;
					twiddle(5) <= twiddle_128pts;
					twiddle(6) <= twiddle_256pts;
				elsif ( en = '1' ) then
					for i in 0 to 5 loop
						twiddle(i) <= twiddle(i+1);
					end loop;
					twiddle(6) <= twiddle(0);
				end if;
			end if;
		end process twiddle_gen;
	end generate;
	twiddle_in <= twiddle_2pts when start = '1' else twiddle(0);											
		
	-- ///////////////////////////////////
	-- the core of NTT is based on butterfly with 2 elements as input.
	--		X0 and X1 are rearrange before the input of each stages get inserted
	--		twiddle factor are preselected for each stage
	twopts : for j in 0 to pts/2-1 generate
		btf : entity work.butterfly(struct) port map ( x0 => ntt(j*2), x1 => ntt(j*2+1), tw => twiddle_in(j), y0 => ntt_out(j*2), y1 => ntt_out(j*2+1));
	end generate;
	
	-- //////////////////////////////////////
	-- MUX
	
		-- ///////////////////////////////////
		-- 4 pts in 
		stage1_gen : for i in 0 to pts4in-1 generate
			stage_1(4*i) 	<= ntt_out(4*i);
			stage_1(4*i+1) 	<= ntt_out(4*i+2);
			stage_1(4*i+2)	<= ntt_out(4*i+1);
			stage_1(4*i+3) 	<= ntt_out(4*i+3);
		end generate;		
		
		-- ///////////////////////////////////
		-- 8 pts
		--		put 4pts back into correct order
		stage2_decode : for i in 0 to pts4in-1 generate
			stage_2t(4*i) 	<= ntt_out(4*i);
			stage_2t(4*i+2) <= ntt_out(4*i+1);
			stage_2t(4*i+1)	<= ntt_out(4*i+2);
			stage_2t(4*i+3) <= ntt_out(4*i+3);
		end generate;						
		-- 		rearrange to enter butterfly circuit
		stage2_gen_1 : for i in 0 to pts8in-1 generate
			stage2_gen_2 : for j in 0 to 3 generate
				stage_2(8*i+j*2) 	<= stage_2t(8*i+j);
				stage_2(8*i+j*2+1) <= stage_2t(8*i+j+4);
			end generate;
		end generate;					   
		
		
		-- ///////////////////////////////////
		-- 16 pts
		--		put 8pts back into correct order
		stage3_decode_1 : for i in 0 to pts8in-1 generate
			stage3_decode_2 : for j in 0 to 3 generate
				stage_3t(8*i+j) 	<= ntt_out(8*i+j*2);
				stage_3t(8*i+j+4)	<= ntt_out(8*i+j*2+1);				
			end generate;
		end generate;						
		-- 		rearrange to enter butterfly circuit
		stage3_gen_1 : for i in 0 to pts16in-1 generate
			stage3_gen_2 : for j in 0 to 7 generate
				stage_3(16*i+j*2) 	 <= stage_3t(16*i+j);
				stage_3(16*i+j*2+1) <= stage_3t(16*i+j+8);	
			end generate;
		end generate;
		
		-- ///////////////////////////////////
		-- 32 pts
		--		put 16pts back into correct order
		stage4_decode_1 : for i in 0 to pts16in-1 generate
			stage4_decode_2 : for j in 0 to 7 generate	
				stage_4t(16*i+j) 	<= ntt_out(16*i+j*2);
				stage_4t(16*i+j+8) 	<= ntt_out(16*i+j*2+1);
			end generate;
		end generate;						
		-- 		rearrange to enter butterfly circuit
		stage4_gen_1 : for i in 0 to pts32in-1 generate
			stage4_gen_2 : for j in 0 to 15 generate
				stage_4(32*i+j*2) 	 <= stage_4t(32*i+j);
				stage_4(32*i+j*2+1) <= stage_4t(32*i+j+16);
			end generate;
		end generate;
	
		-- ///////////////////////////////////
		-- 64 pts in
		--		put 32pts back into correct order
		stage5_decode_1 : for i in 0 to pts32in-1 generate
			stage5_decode_2 : for j in 0 to 15 generate	
				stage_5t(32*i+j) 	<= ntt_out(32*i+j*2);
				stage_5t(32*i+j+16) <= ntt_out(32*i+j*2+1);
			end generate;
		end generate;						
		-- 		rearrange to enter butterfly circuit
		stage5_gen_1 : for i in 0 to pts64in-1 generate
			stage5_gen_2 : for j in 0 to 31 generate
				stage_5(64*i+j*2) 	 <= stage_5t(64*i+j);
				stage_5(64*i+j*2+1) <= stage_5t(64*i+j+32);
			end generate;
		end generate;	
	
		-- ///////////////////////////////////
		-- 128 pts in
		--		put 64pts back into correct order
		stage6_decode_1 : for i in 0 to  pts64in-1 generate
			stage6_decode_2 : for j in 0 to 31 generate
				stage_6t(64*i+j) 	<= ntt_out(64*i+j*2);
				stage_6t(64*i+j+32) <= ntt_out(64*i+j*2+1);
			end generate;
		end generate;						
		-- 		rearrange to enter butterfly circuit   		
		stage6_gen_1 : for i in 0 to pts128in-1 generate
			stage6_gen_2 : for j in 0 to 63 generate
				stage_6(128*i+2*j) 	<= stage_6t(128*i+j);
				stage_6(128*i+2*j+1)<= stage_6t(128*i+j+64);		
			end generate;	
		end generate;							
		
		-- ///////////////////////////////////
		-- FINAL	
		final_muxin_128 : if ( pts = 128 ) generate  
			stage7_decode_1 : for i in 0 to pts128in-1 generate			
				stage7_decode_2 : for j in 0 to 63 generate
					stage_7t(128*i+j) 	<= ntt_out(128*i+2*j);
					stage_7t(128*i+j+64) <= ntt_out(128*i+2*j+1);
				end generate;
			end generate;	
			stage_7 <= stage_7t;
			
			stage_8_gen : for i in 0 to pts/2-1 generate
				stage_8(i) <= (others => '0');
			end generate;
		end generate; 
		
		final_muxin_256 : if ( pts = 256 ) generate    
			--		put 128pts back into correct order
			stage7_decode_1 : for i in 0 to pts128in-1 generate			
				stage7_decode_2 : for j in 0 to 63 generate
					stage_7t(128*i+j) 	<= ntt_out(128*i+2*j);
					stage_7t(128*i+j+64) <= ntt_out(128*i+2*j+1);
				end generate;
			end generate;	
			stage7_gen : for i in 0 to 127 generate
				stage_7(2*i) 	<= stage_7t(i);
				stage_7(2*i+1) 	<= stage_7t(i+128);
			end generate;
			
			stage_8_decode : for i in 0 to 127 generate
				stage_8(i) 		<= ntt_out(2*i);
				stage_8(i+128) 	<= ntt_out(2*i+1);
			end generate;
		end generate;						 
	-- END MUXIN GENERATION	(Rearranging wires)
	-- //////////////////////////////////////
	
		
	stage <= "000" when start = '1' else count;
		
	with stage select 
	stage_mux <= 	stage_1 when "000",
					stage_2 when "001",
					stage_3 when "010",
					stage_4 when "011",
					stage_5 when "100",
					stage_6 when "101",
					stage_7 when "110",
					stage_8	when others;	
					

	-- ///////////////////////////////////
	-- register
	reg_gen : process( clk ) 
	begin	  
		if rising_edge( clk ) then
			if ( en = '1' ) then
				regout <= stage_mux;
			end if;	   
			if (done = '1') then
				y <= modout;
			end if;
		end if;
	end process reg_gen;

	-- ///////////////////////////////////
	--- twiddle factor generation circuit
	af <= addition_factor when sfinal = '0' else addition_factor_final;
		
	-- ///////////////////////////////////
	--- Final Addition Circuit
	modulo_add_gen : for j in 0 to pts-1 generate
		add_out(j) <= ('0' & af(j)) + ("00" & regout(j));
		final_mod_in(j) <= "000000" & add_out(j);
		finalmod: mod257 port map ( i => final_mod_in(j), o => modout(j) );
	end generate;												
	
	
end struct;

