--  
-- Copyright (c) 2018 Allmine Inc
--

library ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
library work;


entity jh_permutation is
   port(
      idata:in std_logic_vector(1023 downto 0);
      odata:out std_logic_vector(1023 downto 0)

   );
end jh_permutation;

--signal declaration
architecture rtl of jh_permutation is

signal ppo,po,phi: std_logic_vector(1023 downto 0);

begin
--	/*initial swap Pi_8*/
--	for (i = 0; i < 256; i = i + 4) {
--		t = tem[i + 2];
--		tem[i + 2] = tem[i + 3];
--		tem[i + 3] = t;
--	}

-- four blocks of 4 bit each
		is_gen : for i in 63 downto 0 generate
			is2_gen: for j in 3 downto 0 generate
				po(i*(4*4)+j) <= idata(i*(4*4)+j);
				po(i*(4*4)+j+4) <= idata(i*(4*4)+j+4);
				po(i*(4*4)+j+8) <= idata(i*(4*4)+j+12);
				po(i*(4*4)+j+12) <= idata(i*(4*4)+j+8);
				
			end generate;
		end generate;

--	/*permutation P'_8*/
--	for (i = 0; i < 128; i = i + 1) {
--		state->A[i] = tem[i << 1];
--		state->A[i + 128] = tem[(i << 1) + 1];
--	}
		
		pp_gen : for i in 127 downto 0 generate
			pp2_gen: for j in 3 downto 0 generate
				ppo(i*4+j)  		<= po(i*4*2+j);
				ppo(i*4 + 128*4 +j)	<= po(i*4*2 + 4 +j);
			end generate;
		end generate;


--
--	/*final swap Phi_8*/
--	for (i = 128; i < 256; i = i + 2) {
--		t = state->A[i];
--		state->A[i] = state->A[i + 1];
--		state->A[i + 1] = t;
--	}
		-- phi	
		phi_gen1 : for i in 511 downto 0 generate
			phi(i) <= ppo(i);
		end generate;
		phi_gen2 : for i in 127 downto 64 generate
			phi_gen3 : for j in 3 downto 0 generate
				phi(i*8+j+4) <= ppo(i*8+j);
				phi(i*8 +j)	<= ppo(i*8+j+4);
			end generate;
				
		end generate;

odata <= phi;

end rtl;

		
		
