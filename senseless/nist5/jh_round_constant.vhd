--  
-- Copyright (c) 2018 Allmine Inc
--

	
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;	


entity jh_round_constant is

port (
	
   	n_round		: in std_logic_vector(5 downto 0);
    constant_out    : out std_logic_vector(255 downto 0));

end jh_round_constant;

architecture rtl of jh_round_constant is


signal round_constant_signal:std_logic_vector(255 downto 0);
  
begin  -- Rtl

round_constants : process (n_round)
begin
	case n_round is
		when "000000" => round_constant_signal <= X"6a09e667f3bcc908b2fb1366ea957d3e3adec17512775099da2f590b0667322a";
		when "000001" => round_constant_signal <= X"bb896bf05955abcd5281828d66e7d99ac4203494f89bf12817deb43288712231";
		when "000010" => round_constant_signal <= X"1836e76b12d79c55118a1139d2417df52a2021225ff6350063d88e5f1f91631c";
		when "000011" => round_constant_signal <= X"263085a7000fa9c3317c6ca8ab65f7a7713cf4201060ce886af855a90d6a4eed";
		when "000100" => round_constant_signal <= X"1cebafd51a156aeb62a11fb3be2e14f60b7e48de85814270fd62e97614d7b441";
		when "000101" => round_constant_signal <= X"e5564cb574f7e09c75e2e244929e9549279ab224a28e445d57185e7d7a09fdc1";
		when "000110" => round_constant_signal <= X"5820f0f0d764cff3a5552a5e41a82b9eff6ee0aa615773bb07e8603424c3cf8a";
		when "000111" => round_constant_signal <= X"b126fb741733c5bfcef6f43a62e8e5706a26656028aa897ec1ea4616ce8fd510";
		when "001000" => round_constant_signal <= X"dbf0de32bca77254bb4f562581a3bc991cf94f225652c27f14eae958ae6aa616";
		when "001001" => round_constant_signal <= X"e6113be617f45f3de53cff03919a94c32c927b093ac8f23b47f7189aadb9bc67";
		when "001010" => round_constant_signal <= X"80d0d26052ca45d593ab5fb3102506390083afb5ffe107dacfcba7dbe601a12b";
		when "001011" => round_constant_signal <= X"43af1c76126714dfa950c368787c81ae3beecf956c85c962086ae16e40ebb0b4";
		when "001100" => round_constant_signal <= X"9aee8994d2d74a5cdb7b1ef294eed5c1520724dd8ed58c92d3f0e174b0c32045";
		when "001101" => round_constant_signal <= X"0b2aa58ceb3bdb9e1eef66b376e0c565d5d8fe7bacb8da866f859ac521f3d571";
		when "001110" => round_constant_signal <= X"7a1523ef3d970a3a9b0b4d610e02749d37b8d57c1885fe4206a7f338e8356866";
		when "001111" => round_constant_signal <= X"2c2db8f7876685f2cd9a2e0ddb64c9d5bf13905371fc39e0fa86e1477234a297";
		when "010000" => round_constant_signal <= X"9df085eb2544ebf62b50686a71e6e828dfed9dbe0b106c9452ceddff3d138990";
		when "010001" => round_constant_signal <= X"e6e5c42cb2d460c9d6e4791a1681bb2e222e54558eb78d5244e217d1bfcf5058";
		when "010010" => round_constant_signal <= X"8f1f57e44e126210f00763ff57da208a5093b8ff7947534a4c260a17642f72b2";
		when "010011" => round_constant_signal <= X"ae4ef4792ea148608cf116cb2bff66e8fc74811266cd641112cd17801ed38b59";
		when "010100" => round_constant_signal <= X"91a744efbf68b192d0549b608bdb3191fc12a0e83543cec5f882250b244f78e4";
		when "010101" => round_constant_signal <= X"4b5d27d3368f9c17d4b2a2b216c7e74e7714d2cc03e1e44588cd9936de74357c";
		when "010110" => round_constant_signal <= X"0ea17cafb8286131bda9e3757b3610aa3f77a6d0575053fc926eea7e237df289";
		when "010111" => round_constant_signal <= X"848af9f57eb1a616e2c342c8cea528b8a95a5d16d9d87be9bb3784d0c351c32b";
		when "011000" => round_constant_signal <= X"c0435cc3654fb85dd9335ba91ac3dbde1f85d567d7ad16f9de6e009bca3f95b5";
		when "011001" => round_constant_signal <= X"927547fe5e5e45e2fe99f1651ea1cbf097dc3a3d40ddd21cee260543c288ec6b";
		when "011010" => round_constant_signal <= X"c117a3770d3a34469d50dfa7db020300d306a365374fa828c8b780ee1b9d7a34";
		when "011011" => round_constant_signal <= X"8ff2178ae2dbe5e872fac789a34bc228debf54a882743caad14f3a550fdbe68f";
		when "011100" => round_constant_signal <= X"abd06c52ed58ff091205d0f627574c8cbc1fe7cf79210f5a2286f6e23a27efa0";
		when "011101" => round_constant_signal <= X"631f4acb8d3ca4253e301849f157571d3211b6c1045347befb7c77df3c6ca7bd";
		when "011110" => round_constant_signal <= X"ae88f2342c23344590be2014fab4f179fd4bf7c90db14fa4018fcce689d2127b";
		when "011111" => round_constant_signal <= X"93b89385546d71379fe41c39bc602e8b7c8b2f78ee914d1f0af0d437a189a8a4";
		when "100000" => round_constant_signal <= X"1d1e036abeef3f44848cd76ef6baa889fcec56cd7967eb909a464bfc23c72435";
		when "100001" => round_constant_signal <= X"a8e4ede4c5fe5e88d4fb192e0a0821e935ba145bbfc59c2508282755a5df53a5";
		when "100010" => round_constant_signal <= X"8e4e37a3b970f079ae9d22a499a714c875760273f74a9398995d32c05027d810";
		when "100011" => round_constant_signal <= X"61cfa42792f93b9fde36eb163e978709fafa7616ec3c7dad0135806c3d91a21b";
		when "100100" => round_constant_signal <= X"f037c5d91623288b7d0302c1b941b72676a943b372659dcd7d6ef408a11b40c0";
		when "100101" => round_constant_signal <= X"2a306354ca3ea90b0e97eaebcea0a6d7c6522399e885c613de824922c892c490";
		when "100110" => round_constant_signal <= X"3ca6cdd788a5bdc5ef2dceeb16bca31e0a0d2c7e9921b6f71d33e25dd2f3cf53";
		when "100111" => round_constant_signal <= X"f72578721db56bf8f49538b0ae6ea470c2fb1339dd26333f135f7def45376ec0";
		when "101000" => round_constant_signal <= X"e449a03eab359e34095f8b4b55cd7ac7c0ec6510f2c4cc79fa6b1fee6b18c59e";
		when "101001" => round_constant_signal <= X"73bd6978c59f2b219449b36770fb313fbe2da28f6b04275f071a1b193dde2072";
      
	    when others => round_constant_signal <=(others => '0');
        end case;
		
end process round_constants;

constant_out <= round_constant_signal;


end rtl;