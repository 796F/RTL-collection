-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.ALL;
use ieee.std_logic_unsigned.ALL;
use work.sha3_pkg.all;
use work.sha3_bmw_package.all;	


entity bmw_adders is
	generic (adders_type: integer:=SCCA_BASED; n : integer := 32);
	port 
	(
		ina 	: in std_logic_vector(n-1 downto 0);				 
		inb 	: in std_logic_vector(n-1 downto 0);				 
		inc 	: in std_logic_vector(n-1 downto 0);				 
		ind 	: in std_logic_vector(n-1 downto 0);				 
		ine 	: in std_logic_vector(n-1 downto 0);				 
		inf 	: in std_logic_vector(n-1 downto 0);				 
		ing 	: in std_logic_vector(n-1 downto 0);				 
		inh 	: in std_logic_vector(n-1 downto 0);				 
		ini 	: in std_logic_vector(n-1 downto 0);				 
		inj 	: in std_logic_vector(n-1 downto 0);				 
		ink 	: in std_logic_vector(n-1 downto 0);				 
		inl 	: in std_logic_vector(n-1 downto 0);				 
		inm 	: in std_logic_vector(n-1 downto 0);				 
		inn 	: in std_logic_vector(n-1 downto 0);				 
		ino 	: in std_logic_vector(n-1 downto 0);				 
		inp 	: in std_logic_vector(n-1 downto 0);				 
		inq 	: in std_logic_vector(n-1 downto 0);				 
		output 	: out std_logic_vector(n-1 downto 0));
end bmw_adders;	   


architecture bmw_adders of bmw_adders is
begin	 

	a1_gen : if adders_type=SCCA_BASED generate
	a1:	entity work.bmw_adders(scca_based) generic map ( n => n ) port map (ina=>ina, inb=>inb, inc=>inc, ind=>ind, 
													ine=>ine, inf=>inf, ing=>ing, inh=>inh,
													ini=>ini, inj=>inj, ink=>ink, inl=>inl,
													inm=>inm, inn=>inn, ino=>ino, inp=>inp,
													inq=>inq, output=>output);
	end generate; 

	a2_gen : if adders_type=SCCA_TREE_BASED generate
	a2:	entity work.bmw_adders(scca_tree_based) generic map ( n => n ) port map (ina=>ina, inb=>inb, inc=>inc, ind=>ind, 
													ine=>ine, inf=>inf, ing=>ing, inh=>inh,
													ini=>ini, inj=>inj, ink=>ink, inl=>inl,
													inm=>inm, inn=>inn, ino=>ino, inp=>inp,
													inq=>inq, output=>output);
	end generate; 

	a3_gen : if adders_type=CSA_BASED generate
	a3:	entity work.bmw_adders(csa_based) generic map ( n => n ) port map (ina=>ina, inb=>inb, inc=>inc, ind=>ind, 
													ine=>ine, inf=>inf, ing=>ing, inh=>inh,
													ini=>ini, inj=>inj, ink=>ink, inl=>inl,
													inm=>inm, inn=>inn, ino=>ino, inp=>inp,
													inq=>inq, output=>output);
	end generate;

	a4_gen : if adders_type=PC_BASED generate
	a4:	entity work.bmw_adders(pc_based) generic map ( n => n ) port map (ina=>ina, inb=>inb, inc=>inc, ind=>ind, 
													ine=>ine, inf=>inf, ing=>ing, inh=>inh,
													ini=>ini, inj=>inj, ink=>ink, inl=>inl,
													inm=>inm, inn=>inn, ino=>ino, inp=>inp,
													inq=>inq, output=>output);
	end generate;

	a5_gen : if adders_type=FCCA_TREE_BASED generate
	a5:	entity work.bmw_adders(FCCA_TREE_BASED) generic map ( n => n ) port map (ina=>ina, inb=>inb, inc=>inc, ind=>ind, 
													ine=>ine, inf=>inf, ing=>ing, inh=>inh,
													ini=>ini, inj=>inj, ink=>ink, inl=>inl,
													inm=>inm, inn=>inn, ino=>ino, inp=>inp,
													inq=>inq, output=>output);
	end generate;	
	
end bmw_adders;	

architecture scca_tree_based of bmw_adders is
	signal ab, cd, ef, gh, ij, kl, mn, op, abcd, efgh, ijkl, mnop, abcdefgh, ijklmnop, abcdefghijklmnop : std_logic_vector(n-1 downto 0);	
begin
			
			ab <= ina + inb; 
			cd <= inc + ind; 
			ef <= ine + inf;
			gh <= ing + inh;
			ij <= ini + inj; 
			kl <= ink + inl; 
			mn <= inm + inn;
			op <= ino + inp; 
			abcd <= ab + cd;
			efgh <= ef + gh;
			ijkl <= ij + kl;
			mnop <= mn + op;
			abcdefgh <= abcd + efgh;
			ijklmnop <= ijkl + mnop;
			abcdefghijklmnop <= abcdefgh + ijklmnop;
			output <= abcdefghijklmnop + inq;
			
			
end scca_tree_based;


architecture scca_based of bmw_adders is
	
begin
	output<= 	ina + inb + inc + ind +
			ine + inf + ing + inh +
			ini + inj + ink + inl +
			inm + inn + ino + inp +	inq;		 

end scca_based;

architecture csa_based of bmw_adders is
	signal c10a,c11a,c12a,c13a,c14a		:std_logic_vector(n-1 downto 0); 	
	signal c10b,c11b,c12b,c13b,c14b		:std_logic_vector(n-1 downto 0); 
	signal c10bb,c11bb,c12bb,c13bb,c14bb		:std_logic_vector(n-1 downto 0); 
	signal c20a,c21a,c22a,c23a		:std_logic_vector(n-1 downto 0); 	
	signal c20b,c21b,c22b,c23b		:std_logic_vector(n-1 downto 0); 
	signal c20bb,c21bb,c22bb,c23bb		:std_logic_vector(n-1 downto 0); 
	signal c30a,c31a		:std_logic_vector(n-1 downto 0); 	
	signal c30b,c31b, c30bb,c31bb	:std_logic_vector(n-1 downto 0); 
	signal c40a,c41a		:std_logic_vector(n-1 downto 0); 	
	signal c40b,c41b, c40bb,c41bb		:std_logic_vector(n-1 downto 0); 
	signal c50a, c50b,c60a, c60b,c50bb, c60bb   :std_logic_vector(n-1 downto 0); 		

begin

	c10bb <= c10b(n-2 downto 0) & '0';
	c11bb <= c11b(n-2 downto 0) & '0';
	c12bb <= c12b(n-2 downto 0) & '0';
	c13bb <= c13b(n-2 downto 0) & '0';
	c14bb <= c14b(n-2 downto 0) & '0';
	c20bb <= c20b(n-2 downto 0) & '0';
	c21bb <= c21b(n-2 downto 0) & '0';
	c22bb <= c22b(n-2 downto 0) & '0';
	c23bb <= c23b(n-2 downto 0) & '0';
	c30bb <= c30b(n-2 downto 0) & '0';
	c31bb <= c31b(n-2 downto 0) & '0';
	c40bb <= c40b(n-2 downto 0) & '0';
	c41bb <= c41b(n-2 downto 0) & '0';
	c50bb <= c50b(n-2 downto 0) & '0';
	c60bb <= c60b(n-2 downto 0) & '0';

	c10: csa generic map (n=>n) port map (a=>ina, b=>inb, cin=>inc, s=>c10a, cout=>c10b);
	c11: csa generic map (n=>n) port map (a=>ind, b=>ine, cin=>inf, s=>c11a, cout=>c11b);
	c12: csa generic map (n=>n) port map (a=>ing, b=>inh, cin=>ini, s=>c12a, cout=>c12b);
	c13: csa generic map (n=>n) port map (a=>inj, b=>ink, cin=>inl, s=>c13a, cout=>c13b);
	c14: csa generic map (n=>n) port map (a=>inm, b=>inn, cin=>ino, s=>c14a, cout=>c14b);

	c20: csa generic map (n=>n) port map (a=>c10a, b=>c10bb, cin=>c11a, s=>c20a, cout=>c20b);
	c21: csa generic map (n=>n) port map (a=>c11bb, b=>c12a, cin=>c12bb, s=>c21a, cout=>c21b);
	c22: csa generic map (n=>n) port map (a=>c13a, b=>c13bb, cin=>c14a, s=>c22a, cout=>c22b);
	c23: csa generic map (n=>n) port map (a=>c14bb, b=>inp, cin=>inq, s=>c23a, cout=>c23b);

	c30: csa generic map (n=>n) port map (a=>c20a, b=>c20bb, cin=>c21a, s=>c30a, cout=>c30b);
	c31: csa generic map (n=>n) port map (a=>c21bb, b=>c22a, cin=>c22bb, s=>c31a, cout=>c31b);
	
	c40: csa generic map (n=>n) port map (a=>c30a, b=>c30bb, cin=>c31a, s=>c40a, cout=>c40b);
	c41: csa generic map (n=>n) port map (a=>c31bb, b=>c23a, cin=>c23bb, s=>c41a, cout=>c41b);
	
	c50: csa generic map (n=>n) port map (a=>c40a, b=>c40bb, cin=>c41a, s=>c50a, cout=>c50b);

	c60: csa generic map (n=>n) port map (a=>c50a, b=>c50bb, cin=>c41bb, s=>c60a, cout=>c60b); 

	output <=  c60a + c60bb;

end csa_based;	

architecture pc_based of bmw_adders is 	 
	signal p10a, p10b, p10c, p11a, p11b, p11c : std_logic_vector(n-1 downto 0);	 
	signal p10bb, p10cc, p11bb, p11cc : std_logic_vector(n-1 downto 0);	 
	signal p12a, p12b, p12c, p20a, p20b, p20c : std_logic_vector(n-1 downto 0);
	signal p12bb, p12cc, p20bb, p20cc : std_logic_vector(n-1 downto 0);
	signal p21a, p21b, p21c, p30a, p30b, p30c : std_logic_vector(n-1 downto 0);
	signal p21bb, p21cc, p30bb, p30cc : std_logic_vector(n-1 downto 0);
	signal p40a, p40b, p40c, c50a, c50b : std_logic_vector(n-1 downto 0);
	signal p40bb, p40cc, c50bb : std_logic_vector(n-1 downto 0);
begin	  
	
	p10bb <= p10b(n-2 downto 0) & '0';
	p11bb <= p11b(n-2 downto 0) & '0';
	p12bb <= p12b(n-2 downto 0) & '0';
	p20bb <= p20b(n-2 downto 0) & '0';
	p21bb <= p21b(n-2 downto 0) & '0';
	p30bb <= p30b(n-2 downto 0) & '0';
	p40bb <= p40b(n-2 downto 0) & '0';
	c50bb <= c50b(n-2 downto 0) & '0';

	p10cc <= p10c(n-3 downto 0) & "00";
	p11cc <= p11c(n-3 downto 0) & "00";
	p12cc <= p12c(n-3 downto 0) & "00";
	p20cc <= p20c(n-3 downto 0) & "00";
	p21cc <= p21c(n-3 downto 0) & "00";
	p30cc <= p30c(n-3 downto 0) & "00";
	p40cc <= p40c(n-3 downto 0) & "00";

	
	p10 : pc generic map (n=>n) port map (a=>ina, b=>inb, c=>inc, d=>ind, e=>ine, s0=>p10a, s1=>p10b, s2=>p10c);
	p11 : pc generic map (n=>n) port map (a=>inf, b=>ing, c=>inh, d=>ini, e=>inj, s0=>p11a, s1=>p11b, s2=>p11c);
	p12 : pc generic map (n=>n) port map (a=>ink, b=>inl, c=>inm, d=>inn, e=>ino, s0=>p12a, s1=>p12b, s2=>p12c);

	p20 : pc generic map (n=>n) port map (a=>p10a, b=>p10bb, c=>p10cc, d=>p11a, e=>p11bb, s0=>p20a, s1=>p20b, s2=>p20c);
	p21 : pc generic map (n=>n) port map (a=>p11cc, b=>p12a, c=>p12bb, d=>p12cc, e=>inp, s0=>p21a, s1=>p21b, s2=>p21c);  

	p30 : pc generic map (n=>n) port map (a=>p20a, b=>p20bb, c=>p20cc, d=>p21a, e=>p21bb, s0=>p30a, s1=>p30b, s2=>p30c);

	p40 : pc generic map (n=>n) port map (a=>p30a, b=>p30bb, c=>p30cc, d=>p21cc, e=>inq, s0=>p40a, s1=>p40b, s2=>p40c);

	c50 : csa generic map (n=>n) port map (a=>p40a, b=>p40bb, cin=>p40cc, s=>c50a, cout=>c50b);

	output <= c50a + c50bb;	
end pc_based; 	

architecture fcca_tree_based of bmw_adders is
	signal ab, cd, ef, gh, ij, kl, mn, op, abcd, efgh, ijkl, mnop, abcdefgh, ijklmnop, abcdefghijklmnop : std_logic_vector(n-1 downto 0);	
begin
		
	f10 : fcca generic map (n=>n) port map ( a => ina, b => inb, s => ab );		
	f11 : fcca generic map (n=>n) port map ( a => inc, b => ind, s => cd );		
	f12 : fcca generic map (n=>n) port map ( a => ine, b => inf, s => ef );		
	f13 : fcca generic map (n=>n) port map ( a => ing, b => inh, s => gh );		
	f14 : fcca generic map (n=>n) port map ( a => ini, b => inj, s => ij );		
	f15 : fcca generic map (n=>n) port map ( a => ink, b => inl, s => kl );		
	f16 : fcca generic map (n=>n) port map ( a => inm, b => inn, s => mn );		
	f17 : fcca generic map (n=>n) port map ( a => ino, b => inp, s => op );		
	
	f20 : fcca generic map (n=>n) port map ( a => ab, b => cd, s => abcd);		
	f21 : fcca generic map (n=>n) port map ( a => ef, b => gh, s => efgh);
	f22 : fcca generic map (n=>n) port map ( a => ij, b => kl, s => ijkl);
	f23 : fcca generic map (n=>n) port map ( a => mn, b => op, s => mnop);
	
	f30 : fcca generic map (n=>n) port map ( a => abcd, b => efgh, s => abcdefgh);
	f31 : fcca generic map (n=>n) port map ( a => ijkl, b => mnop, s => ijklmnop);
	
	f40 : fcca generic map (n=>n) port map ( a => abcdefgh, b => ijklmnop, s => abcdefghijklmnop);
	
	fin : fcca generic map (n=>n) port map ( a => abcdefghijklmnop, b => inq, s => output);
			
end fcca_tree_based;
