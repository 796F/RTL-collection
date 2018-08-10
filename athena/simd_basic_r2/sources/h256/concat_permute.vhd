-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all; 
use ieee.std_logic_arith.all;  
use ieee.std_logic_unsigned.all;
use work.twiddle_factor_pkg.all;

entity concat_permute is  
	generic ( 	h : integer := 256;
				pts : integer := 128;
				feistels : integer := 4);
    port (  ii : in ntt_out_type(0 to pts-1);
			clk : in std_logic;
			ctrl : in std_logic_vector(2 downto 0);			
            ww : out array_w(0 to 3, 0 to feistels-1));
end concat_permute;

--/////////////////////////////////////////////////////
--/////////////////////////////////////////////////////
-- TYPE 1 (Half calculation, variable multiplier)
--/////////////////////////////////////////////////////
--/////////////////////////////////////////////////////
--
--architecture type1 of concat_permute is  
--	type array_64x9 is array(63 downto 0) of std_logic_vector(8 downto 0);
--	type array_64x16 is array(63 downto 0) of std_logic_vector(15 downto 0);
--	type array_64x24 is array(63 downto 0) of std_logic_vector(23 downto 0);  
--	type array_64x32 is array(63 downto 0) of std_logic_vector(31 downto 0);
--	
--	signal mux_a, mux_b : array_64x9;	
--	signal lift_a, lift_b : array_64x16;
--	signal mult_a, mult_b : array_64x24;
--	signal z : array_64x32;   
--	signal z16 : array_16x4x32;
--	signal permute_top, permute_bot, permute_mux : array_16x4x32;
--	
--	constant x185 : std_logic_vector(7 downto 0) := conv_std_logic_vector(185, 8);
--	constant x233 : std_logic_vector(7 downto 0) := conv_std_logic_vector(233, 8);
--	signal mult_var : std_logic_vector(7 downto 0);	 
--	
--	type reg_type is array( 0 to 3 ) of array_4x4x32;
--	signal regin, regmux, regout : reg_type;
--	
--	-- control sig
--	signal s_botw, load, en : std_logic;
--begin				
--	s_botw <= ctrl(2);
--	load <= ctrl(1);
--	en <= ctrl(0);
--	
--	-- lift to z
--	mux_gen_lvl1 : for i in 7 downto 0 generate
--		mux_gen_lvl2 : for j in 3 downto 0 generate
--			mux_a(4*i+j) 		<= ii(8*i+2*j+1) 		when s_botw = '0' else ii(8*i+2*j+64);
--			mux_a(4*(i+8)+j) 	<= ii(8*(i+8)+2*j+1) 	when s_botw = '0' else ii(8*i+2*j+65);
--				
--			mux_b(4*i+j) 		<= ii(8*i+2*j) 			when s_botw = '0' else ii(8*i+2*j);
--			mux_b(4*(i+8)+j) 	<= ii(8*(i+8)+2*j) 		when s_botw = '0' else ii(8*i+2*j+1);
--		end generate;
--	end generate;																		 
--	
--	-- lift
--	lift_gen : for j in 0 to 63 generate
--		lift_blocka : entity work.lift(struct) port map ( i => mux_a(j), o => lift_a(j) );
--		lift_blockb : entity work.lift(struct) port map ( i => mux_b(j), o => lift_b(j) );
--	end generate;	
--	
--	-- mult
--	mult_var <= x185 when s_botw = '0' else x233;	
--	mult_gen : for i in 0 to 63 generate
--		mult_a(i) <= lift_a(i) * mult_var;
--		mult_b(i) <= lift_b(i) * mult_var;
--		z(i) <= mult_a(i)(15 downto 0) & mult_b(i)(15 downto 0);
--	end generate;
--	
--	-- convert to different format
--	comb_gen_1 : for i in 0 to 15 generate
--		comb_gen_2 : for j in 0 to 3 generate	 
--			z16(i)(j) <= z(4*i+j);	  
--		end generate;
--	end generate;
--	
--	-- permute
--	permute_gen : for i in 0 to 15 generate
--		permute_top(i) <= z16(permute_rom(i));
--		permute_bot(i) <= z16(permute_rom(i+16) mod 16);
--	end generate;
--	
--	permute_mux <= permute_bot when s_botw = '1' else permute_top;
--		
--	--- OUTPUT		
--	out_gen_1 : for i in 0 to 3 generate
--		out_gen_2 : for j in 0 to 3 generate
--			regin(i)(j) <= permute_mux(i*4+j);
--		end generate;		
--	end generate;	
--	
--	regmux(0) <= regin(0) when load = '1' else regout(1);
--	regmux(1) <= regin(1) when load = '1' else regout(2);
--	regmux(2) <= regin(2) when load = '1' else regout(3);
--	regmux(3) <= regin(3) when load = '1' else regout(0);
--		
--	
--	process( clk ) 
--	begin
--		if rising_edge( clk ) then	  
--			if (en = '1') then
--				regout <= regmux;
--			end if;
--		end if;
--	end process;
--	
--	ww <= regout(0);
--		
--end type1;

--/////////////////////////////////////////////////////
--/////////////////////////////////////////////////////
-- TYPE 2 (Half calculation, constant multiplier)
--/////////////////////////////////////////////////////
--/////////////////////////////////////////////////////

--architecture type2 of concat_permute is  
--	type array_64x9 is array(63 downto 0) of std_logic_vector(8 downto 0);
--	type array_64x16 is array(63 downto 0) of std_logic_vector(15 downto 0);
--	type array_64x24 is array(63 downto 0) of std_logic_vector(23 downto 0);  
--	type array_64x32 is array(63 downto 0) of std_logic_vector(31 downto 0);
--	
--	signal mux_a, mux_b : array_64x9;	
--	signal lift_a, lift_b : array_64x16;
--	signal mult_a, mult_b : array_64x24;
--	signal mult_a185, mult_b185, mult_a233, mult_b233 : array_64x24;
--	signal z : array_64x32;   
--	signal z16 : array_16x4x32;
--	signal permute_top, permute_bot, permute_mux : array_16x4x32;
--	
--	constant x185 : std_logic_vector(7 downto 0) := conv_std_logic_vector(185, 8);
--	constant x233 : std_logic_vector(7 downto 0) := conv_std_logic_vector(233, 8);
--	
--	type reg_type is array( 0 to 3 ) of array_4x4x32;
--	signal regin, regmux, regout : reg_type;
--	
--	-- control sig
--	signal s_botw, load, en : std_logic;
--begin				
--	s_botw <= ctrl(2);
--	load <= ctrl(1);
--	en <= ctrl(0);
--	
--	-- lift to z
--	mux_gen_lvl1 : for i in 7 downto 0 generate
--		mux_gen_lvl2 : for j in 3 downto 0 generate
--			mux_a(4*i+j) 		<= ii(8*i+2*j+1) 		when s_botw = '0' else ii(8*i+2*j+64);
--			mux_a(4*(i+8)+j) 	<= ii(8*(i+8)+2*j+1) 	when s_botw = '0' else ii(8*i+2*j+65);
--				
--			mux_b(4*i+j) 		<= ii(8*i+2*j) 			when s_botw = '0' else ii(8*i+2*j);
--			mux_b(4*(i+8)+j) 	<= ii(8*(i+8)+2*j) 		when s_botw = '0' else ii(8*i+2*j+1);
--		end generate;
--	end generate;																		 
--	
--	-- lift
--	lift_gen : for j in 0 to 63 generate
--		lift_blocka : entity work.lift(struct) port map ( i => mux_a(j), o => lift_a(j) );
--		lift_blockb : entity work.lift(struct) port map ( i => mux_b(j), o => lift_b(j) );
--	end generate;	
--	
--	-- mult
--	mult_gen : for i in 0 to 63 generate
--		mult_a185(i) <= lift_a(i) * x185;
--		mult_a233(i) <= lift_a(i) * x233;
--		mult_a(i) <= mult_a185(i) when s_botw = '0' else mult_a233(i);
--		mult_b185(i) <= lift_b(i) * x185;
--		mult_b233(i) <= lift_b(i) * x233;
--		mult_b(i) <= mult_b185(i) when s_botw = '0' else mult_b233(i);
--		z(i) <= mult_a(i)(15 downto 0) & mult_b(i)(15 downto 0);
--	end generate;
--	
--	-- convert to different format
--	comb_gen_1 : for i in 0 to 15 generate
--		comb_gen_2 : for j in 0 to 3 generate	 
--			z16(i)(j) <= z(4*i+j);	  
--		end generate;
--	end generate;
--	
--	-- permute
--	permute_gen : for i in 0 to 15 generate
--		permute_top(i) <= z16(permute_rom(i));
--		permute_bot(i) <= z16(permute_rom(i+16) mod 16);
--	end generate;
--	
--	permute_mux <= permute_bot when s_botw = '1' else permute_top;
--		
--	--- OUTPUT		
--	out_gen_1 : for i in 0 to 3 generate
--		out_gen_2 : for j in 0 to 3 generate
--			regin(i)(j) <= permute_mux(i*4+j);
--		end generate;		
--	end generate;	
--	
--	regmux(0) <= regin(0) when load = '1' else regout(1);
--	regmux(1) <= regin(1) when load = '1' else regout(2);
--	regmux(2) <= regin(2) when load = '1' else regout(3);
--	regmux(3) <= regin(3) when load = '1' else regout(0);
--		
--	
--	process( clk ) 
--	begin
--		if rising_edge( clk ) then	  
--			if (en = '1') then
--				regout <= regmux;
--			end if;
--		end if;
--	end process;
--	
--	ww <= regout(0);
--		
--end type2;					   
--				  

--/////////////////////////////////////////////////////
--/////////////////////////////////////////////////////
-- TYPE 3 Full calculation
--/////////////////////////////////////////////////////
--/////////////////////////////////////////////////////
                       --                            
--architecture type3 of concat_permute is  
--	type array_128x16 is array(127 downto 0) of std_logic_vector(15 downto 0);
--	type array_64x24 is array(63 downto 0) of std_logic_vector(23 downto 0);  
--	type array_128x32 is array(127 downto 0) of std_logic_vector(31 downto 0);
--		
--	signal lift : array_128x16;
--	signal mult185a,mult185b, mult233a,mult233b : array_64x24;
--	 
--	signal z, permute : array_32x4x32;
--	
--	
--	constant x185 : std_logic_vector(7 downto 0) := conv_std_logic_vector(185, 8);
--	constant x233 : std_logic_vector(7 downto 0) := conv_std_logic_vector(233, 8);
--	
--	
--	type reg_type is array( 0 to 7 ) of array_4x4x32;
--	signal regin, regmux, regout : reg_type;
--	
--	-- control sig
--	signal s_botw, load, en : std_logic;
--begin				
--	s_botw <= ctrl(2);
--	load <= ctrl(1);
--	en <= ctrl(0);
--	
--	-- lift
--	lift_gen : for j in 0 to 127 generate
--		lift_block : entity work.lift(struct) port map ( i => ii(j), o => lift(j) );		
--	end generate;	
--	
--	-- concat 
--	zgen : for i in 0 to 31 generate
--		top_16 : if ( i >= 0 and i <= 15 ) generate
--			gen : for j in 0 to 3 generate
--				mult185a(4*i+j) <= lift(8*i+2*j) * x185;
--				mult185b(4*i+j) <= lift(8*i+2*j+1) * x185;
--				z(i)(j) <= mult185b(4*i+j)(15 downto 0) & mult185a(4*i+j)(15 downto 0);
--			end generate;			
--		end generate;
--		next7 : if ( i >= 16 and i <= 23 ) generate
--			gen : for j in 0 to 3 generate
--				mult233a(4*i+j-64) <= lift(8*i+2*j-128) * x233;
--				mult233b(4*i+j-64) <= lift(8*i+2*j-64)* x233;
--				z(i)(j) <= mult233b(4*i+j-64)(15 downto 0) & mult233a(4*i+j-64)(15 downto 0);
--			end generate;
--		end generate;
--		last7 : if ( i >= 24 and i <= 31 ) generate
--			gen : for j in 0 to 3 generate
--				mult233a(4*i+j-64) <= lift(8*i+2*j-191)* x233;
--				mult233b(4*i+j-64) <= lift(8*i+2*j-127)* x233;
--				z(i)(j) <= mult233b(4*i+j-64)(15 downto 0) & mult233a(4*i+j-64)(15 downto 0);
--			end generate;
--		end generate;
--	end generate;
--	
--	-- permute
--	permute_gen : for i in 0 to 31 generate
--		permute(i) <= z(permute_rom(i));
--	end generate;	
--		
--	--- OUTPUT		
--	out_gen_1 : for i in 0 to 7 generate
--		out_gen_2 : for j in 0 to 3 generate
--			regin(i)(j) <= permute(i*4+j);
--		end generate;		
--	end generate;	
--	
--	regmux(0) <= regin(0) when load = '1' else regout(1);
--	regmux(1) <= regin(1) when load = '1' else regout(2);
--	regmux(2) <= regin(2) when load = '1' else regout(3);
--	regmux(3) <= regin(3) when load = '1' else regout(4);
--	regmux(4) <= regin(4) when load = '1' else regout(5);
--	regmux(5) <= regin(5) when load = '1' else regout(6);
--	regmux(6) <= regin(6) when load = '1' else regout(7);
--	regmux(7) <= regin(7) when load = '1' else regout(0);
--		
--		
--	
--	process( clk ) 
--	begin
--		if rising_edge( clk ) then	  
--			if (en = '1') then
--				regout <= regmux;
--			end if;
--		end if;
--	end process;
--	
--	ww <= regout(0);
--		
--end type3;
--
--/////////////////////////////////////////////////////
--/////////////////////////////////////////////////////
-- TYPE 4 (quarter calculation, variable multiplier)
--/////////////////////////////////////////////////////
--/////////////////////////////////////////////////////
--                                
--architecture type4 of concat_permute is  
--	type array_32x9 is array ( 0 to 31 ) of std_logic_vector(8 downto 0);
--	type array_32x16 is array( 0 to 31 ) of std_logic_vector(15 downto 0);
--	type array_32x24 is array( 0 to 31 ) of std_logic_vector(23 downto 0);  
--	type array_32x32 is array( 0 to 31 ) of std_logic_vector(31 downto 0);
--	
--	signal mux_a, mux_b : array_32x9;	
--	signal lift_a, lift_b : array_32x16;
--	signal mult_a, mult_b : array_32x24;
--	signal z : array_32x32;   
--	signal z8 : array_8x4x32;
--	signal permute_topl, permute_botr,permute_topr, permute_botl, permute_mux : array_8x4x32;
--	
--	constant x185 : std_logic_vector(7 downto 0) := conv_std_logic_vector(185, 8);
--	constant x233 : std_logic_vector(7 downto 0) := conv_std_logic_vector(233, 8);
--	signal mult_var : std_logic_vector(7 downto 0);	 
--	
--	type reg_type is array( 0 to 1 ) of array_4x4x32;
--	signal regin, regmux, regout : reg_type;
--	signal zero4x4x32 : array_4x4x32;
--	
--	-- control sig
--	signal sw : std_logic_vector(1 downto 0);
--	signal load, en : std_logic;
--begin				
--	sw <= ctrl(3 downto 2);
--	load <= ctrl(1);
--	en <= ctrl(0);
--	
--	-- lift to z
--	mux_gen_lvl1 : for i in 7 downto 0 generate
--		mux_gen_lvl2 : for j in 3 downto 0 generate
--			with sw select
--			mux_a(4*i+j) <= ii(8*i+2*j+1) 		when "00",
--							ii(8*(i+8)+2*j+1) 	when "01",
--							ii(8*i+2*j+64) 		when "10",
--							ii(8*i+2*j+65)	 	when others;
--			
--			with sw select
--			mux_b(4*i+j) <= ii(8*i+2*j) 		when "00",
--							ii(8*(i+8)+2*j) 	when "01",
--							ii(8*i+2*j) 		when "10",
--							ii(8*i+2*j+1) 		when others;
--		end generate;
--	end generate;																		 
--	
--	-- lift
--	lift_gen : for j in 0 to 31 generate
--		lift_blocka : entity work.lift(struct) port map ( i => mux_a(j), o => lift_a(j) );
--		lift_blockb : entity work.lift(struct) port map ( i => mux_b(j), o => lift_b(j) );
--	end generate;	
--	
--	-- mult
--	mult_var <= x185 when sw(1) = '0' else x233;	
--	mult_gen : for i in 0 to 31 generate
--		mult_a(i) <= lift_a(i) * mult_var;
--		mult_b(i) <= lift_b(i) * mult_var;
--		z(i) <= mult_a(i)(15 downto 0) & mult_b(i)(15 downto 0);
--	end generate;
--	
--	-- convert to different format
--	comb_gen_1 : for i in 0 to 7 generate
--		comb_gen_2 : for j in 0 to 3 generate	 
--			z8(i)(j) <= z(4*i+j);	  
--		end generate;
--	end generate;
--	
--	-- permute
--	permute_gen : for i in 0 to 7 generate
--		permute_topl(i) <= z8(permute_rom(i));
--		permute_topr(i) <= z8(permute_rom(i+8) mod 8);
--		permute_botl(i) <= z8(permute_rom(i+16) mod 8);
--		permute_botr(i) <= z8(permute_rom(i+24) mod 8);
--	end generate;
--	
--	with sw select	
--	permute_mux <= 	permute_topl when "00",
--					permute_topr when "01",
--					permute_botl when "10",
--					permute_botr when others;
--		
--	--- OUTPUT		
--	out_gen_1 : for i in 0 to 1 generate
--		out_gen_2 : for j in 0 to 3 generate
--			regin(i)(j) <= permute_mux(i*4+j);
--		end generate;		
--	end generate;	
--	
--	zerogen : for i in 0 to 3 generate
--		zerogen : for j in 0 to 3 generate 
--			zero4x4x32(i)(j) <= (others => '0');	   
--		end generate;
--	end generate;
--	
--	regmux(0) <= regin(0) when load = '1' else regout(1);
--	regmux(1) <= regin(1) when load = '1' else zero4x4x32;	
--		
--	
--	process( clk ) 
--	begin
--		if rising_edge( clk ) then	  
--			if (en = '1') then
--				regout <= regmux;
--			end if;
--		end if;
--	end process;
--	
--	ww <= regout(0);
--		
--end type4;

--/////////////////////////////////////////////////////
--/////////////////////////////////////////////////////
-- TYPE 5 (1/8th calculation, variable multiplier)
--/////////////////////////////////////////////////////
--/////////////////////////////////////////////////////

architecture type5 of concat_permute is
	signal input : ntt_out_type(0 to pts-1);
	-- perm
	type array_perm_base is array(0 to feistels-1) of std_logic_vector(17 downto 0);
	type array_perm is array(0 to 31) of array_perm_base;
	signal perm1, perm2 : array_perm;
	
	-- lift
	type array_lift_base is array(0 to feistels-1) of std_logic_vector(15 downto 0);
	type array_lift is array( 0 to 3) of array_lift_base;
	signal lift_a, lift_b : array_lift;
	
	-- mult
	type array_mult_base is array( 0 to feistels-1 ) of std_logic_vector(23 downto 0); 
	type array_mult is array( 0 to 3 ) of array_mult_base;
	signal mult_a, mult_b : array_mult;
	
	-- mux				
	type array_mux_base is array(0 to 3) of array_perm_base;
	type array_mux  is array(0 to 7) of array_mux_base;
	signal muxin : array_mux;
	signal muxout : array_mux_base;
			
	constant x185 : std_logic_vector(7 downto 0) := conv_std_logic_vector(185, 8);
	constant x233 : std_logic_vector(7 downto 0) := conv_std_logic_vector(233, 8);
	signal mult_var : std_logic_vector(7 downto 0);	 
	
	signal wwpre : array_w(0 to 3,0 to feistels-1);   
	-- control sig		   
	signal sw : std_logic_vector(2 downto 0);
begin				
	input <= ii;
	
	sw <= ctrl(2 downto 0);
	
	-- perm1	
	perm_feistels4 : if (feistels = 4) generate
		perm1_i : for i in 0 to 31 generate
			perm1_j : for j in 0 to 3 generate
				case1 : if (i >= 0 and i <= 15) generate
					perm1(i)(j) <= input(8*i+2*j) & input(8*i+2*j+1);
				end generate;
				case2 : if (i >= 16 and i <= 23) generate
					perm1(i)(j) <= input(8*i+2*j-128) & input(8*i+2*j-64);				
				end generate;
				case3 : if (i >= 24 and i <= 31) generate
					perm1(i)(j) <= input(8*i+2*j-191) & input(8*i+2*j-127);
				end generate;
			end generate;
		end generate;
	end generate;  
	perm_feistels8 : if (feistels = 8) generate
		perm1_i : for i in 0 to 31 generate
			perm1_j : for j in 0 to 7 generate
				case1 : if (i >= 0 and i <= 15) generate
					perm1(i)(j) <= input(16*i+2*j) & input(16*i+2*j+1);
				end generate;
				case2 : if (i >= 16 and i <= 23) generate
					perm1(i)(j) <= input(16*i+2*j-256) & input(16*i+2*j-128);				
				end generate;
				case3 : if (i >= 24 and i <= 31) generate
					perm1(i)(j) <= input(16*i+2*j-383) & input(16*i+2*j-255);
				end generate;
			end generate;
		end generate;
	end generate;
	
	
	--perm2
	perm2_gen : for i in 0 to 31 generate
		perm2(i) <= perm1(permute_rom(i));
	end generate;
	
	mux_geni : for i in 0 to 7 generate
		mux_genj : for j in 0 to 3 generate
			muxin(i)(j) <= perm2(4*i+j);
		end generate;
	end generate;	
	
	with sw select
	muxout <= 	muxin(0) when "000",
				muxin(1) when "001",
				muxin(2) when "010",
				muxin(3) when "011",
				muxin(4) when "100",
				muxin(5) when "101",
				muxin(6) when "110",
				muxin(7) when others; 

	---- lift
	lift_gen1 : for i in 0 to 3 generate
		lift_gen2 : for j in 0 to feistels-1 generate
			lift_blocka : entity work.lift(struct) port map ( i => muxout(i)(j)(8 downto 0), o => lift_a(i)(j) );
			lift_blockb : entity work.lift(struct) port map ( i => muxout(i)(j)(17 downto 9), o =>lift_b(i)(j) );
		end generate;
	end generate;	

	-- mult
	mult_var <= x185 when sw(2) = '0' else x233;	
	mult_gen1 : for i in 0 to 3 generate
		mult_gen2 : for j in 0 to feistels-1 generate
			mult_a(i)(j) <= lift_a(i)(j) * mult_var;
			mult_b(i)(j) <= lift_b(i)(j) * mult_var;
				-- be careful the order of j and i is differ ( need to make it this way for generic)
			wwpre(i,j) <= mult_a(i)(j)(15 downto 0) & mult_b(i)(j)(15 downto 0);		
		end generate;
	end generate;
	
	--- OUTPUT			
	process( clk ) 
	begin
		if rising_edge( clk ) then	  
			ww <= wwpre;
		end if;
	end process;	
		
end type5;