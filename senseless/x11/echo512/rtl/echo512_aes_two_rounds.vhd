--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity echo512_aes_two_rounds is
port (
  x_in                                  : in std_logic_vector(127 downto 0);
  k_in                                  : in std_logic_vector(127 downto 0);
  x_out                                 : out std_logic_vector(127 downto 0)
);
end entity echo512_aes_two_rounds;

architecture echo512_aes_two_rounds_rtl of echo512_aes_two_rounds is
  
  alias slv is std_logic_vector;
  
  subtype word64 is slv(63 downto 0);
  subtype word32 is slv(31 downto 0);
  subtype natural_0_3 is natural range 0 to 3;

  constant zeros64 : word64 := (others => '0');
  constant zeros32 : word32 := (others => '0');
  
  function byte_sel(x: word32; n: natural_0_3) return unsigned is
  begin
    return unsigned(x((n+1)*8-1 downto n*8));
  end byte_sel;
  
  function endian_swap64(x: word64) return word64 is
  begin
    return word64(x(7 downto 0)   & x(15 downto 8)  & x(23 downto 16) & x(31 downto 24) &
                  x(39 downto 32) & x(47 downto 40) & x(55 downto 48) & x(63 downto 56));
  end endian_swap64;

  function endian_swap32(x: word32) return word32 is
  begin
    return word32(x(7 downto 0)   & x(15 downto 8)  & x(23 downto 16) & x(31 downto 24));
  end endian_swap32;
  
  function shr64(x: word64; n: natural) return word64 is
  begin
    return word64(zeros64(n-1 downto 0) & x(x'high downto n));
  end shr64;
  
  function shr32(x: word32; n: natural) return word32 is
  begin
    return word32(zeros32(n-1 downto 0) & x(x'high downto n));
  end shr32;
  
  function shl64(x: word64; n: natural) return word64 is
  begin
    return word64(x(x'high-n downto 0) & zeros64(x'high downto x'length-n));
  end shl64;

  function shl32(x: word32; n: natural) return word32 is
  begin
    return word32(x(x'high-n downto 0) & zeros32(x'high downto x'length-n));
  end shl32;
  
  function rotr64(x: word64; n: natural) return word64 is
  begin
    return word64(x(n-1 downto 0) & x(x'high downto n));
  end rotr64;
  
  function rotr32(x: word32; n: natural) return word32 is
  begin
    return word32(x(n-1 downto 0) & x(x'high downto n));
  end rotr32;
  
  function rotl64(x: word64; n: natural) return word64 is
  begin
    return word64(x(x'high-n downto 0) & x(x'high downto x'length-n));
  end rotl64;
  
  function rotl32(x: word32; n: natural) return word32 is
  begin
    return word32(x(x'high-n downto 0) & x(x'high downto x'length-n));
  end rotl32;
  
  type word32_array256 is array(0 to 255) of word32;
  type word32_array4 is array(0 to 3) of word32;
  
  constant ZEROS_WORD32_ARRAY4          : word32_array4 := (others => zeros32);
  constant AES0                         : word32_array256 := (X"A56363C6", X"847C7CF8", X"997777EE", X"8D7B7BF6",
                                                              X"0DF2F2FF", X"BD6B6BD6", X"B16F6FDE", X"54C5C591",
                                                              X"50303060", X"03010102", X"A96767CE", X"7D2B2B56",
                                                              X"19FEFEE7", X"62D7D7B5", X"E6ABAB4D", X"9A7676EC",
                                                              X"45CACA8F", X"9D82821F", X"40C9C989", X"877D7DFA",
                                                              X"15FAFAEF", X"EB5959B2", X"C947478E", X"0BF0F0FB",
                                                              X"ECADAD41", X"67D4D4B3", X"FDA2A25F", X"EAAFAF45",
                                                              X"BF9C9C23", X"F7A4A453", X"967272E4", X"5BC0C09B",
                                                              X"C2B7B775", X"1CFDFDE1", X"AE93933D", X"6A26264C",
                                                              X"5A36366C", X"413F3F7E", X"02F7F7F5", X"4FCCCC83",
                                                              X"5C343468", X"F4A5A551", X"34E5E5D1", X"08F1F1F9",
                                                              X"937171E2", X"73D8D8AB", X"53313162", X"3F15152A",
                                                              X"0C040408", X"52C7C795", X"65232346", X"5EC3C39D",
                                                              X"28181830", X"A1969637", X"0F05050A", X"B59A9A2F",
                                                              X"0907070E", X"36121224", X"9B80801B", X"3DE2E2DF",
                                                              X"26EBEBCD", X"6927274E", X"CDB2B27F", X"9F7575EA",
                                                              X"1B090912", X"9E83831D", X"742C2C58", X"2E1A1A34",
                                                              X"2D1B1B36", X"B26E6EDC", X"EE5A5AB4", X"FBA0A05B",
                                                              X"F65252A4", X"4D3B3B76", X"61D6D6B7", X"CEB3B37D",
                                                              X"7B292952", X"3EE3E3DD", X"712F2F5E", X"97848413",
                                                              X"F55353A6", X"68D1D1B9", X"00000000", X"2CEDEDC1",
                                                              X"60202040", X"1FFCFCE3", X"C8B1B179", X"ED5B5BB6",
                                                              X"BE6A6AD4", X"46CBCB8D", X"D9BEBE67", X"4B393972",
                                                              X"DE4A4A94", X"D44C4C98", X"E85858B0", X"4ACFCF85",
                                                              X"6BD0D0BB", X"2AEFEFC5", X"E5AAAA4F", X"16FBFBED",
                                                              X"C5434386", X"D74D4D9A", X"55333366", X"94858511",
                                                              X"CF45458A", X"10F9F9E9", X"06020204", X"817F7FFE",
                                                              X"F05050A0", X"443C3C78", X"BA9F9F25", X"E3A8A84B",
                                                              X"F35151A2", X"FEA3A35D", X"C0404080", X"8A8F8F05",
                                                              X"AD92923F", X"BC9D9D21", X"48383870", X"04F5F5F1",
                                                              X"DFBCBC63", X"C1B6B677", X"75DADAAF", X"63212142",
                                                              X"30101020", X"1AFFFFE5", X"0EF3F3FD", X"6DD2D2BF",
                                                              X"4CCDCD81", X"140C0C18", X"35131326", X"2FECECC3",
                                                              X"E15F5FBE", X"A2979735", X"CC444488", X"3917172E",
                                                              X"57C4C493", X"F2A7A755", X"827E7EFC", X"473D3D7A",
                                                              X"AC6464C8", X"E75D5DBA", X"2B191932", X"957373E6",
                                                              X"A06060C0", X"98818119", X"D14F4F9E", X"7FDCDCA3",
                                                              X"66222244", X"7E2A2A54", X"AB90903B", X"8388880B",
                                                              X"CA46468C", X"29EEEEC7", X"D3B8B86B", X"3C141428",
                                                              X"79DEDEA7", X"E25E5EBC", X"1D0B0B16", X"76DBDBAD",
                                                              X"3BE0E0DB", X"56323264", X"4E3A3A74", X"1E0A0A14",
                                                              X"DB494992", X"0A06060C", X"6C242448", X"E45C5CB8",
                                                              X"5DC2C29F", X"6ED3D3BD", X"EFACAC43", X"A66262C4",
                                                              X"A8919139", X"A4959531", X"37E4E4D3", X"8B7979F2",
                                                              X"32E7E7D5", X"43C8C88B", X"5937376E", X"B76D6DDA",
                                                              X"8C8D8D01", X"64D5D5B1", X"D24E4E9C", X"E0A9A949",
                                                              X"B46C6CD8", X"FA5656AC", X"07F4F4F3", X"25EAEACF",
                                                              X"AF6565CA", X"8E7A7AF4", X"E9AEAE47", X"18080810",
                                                              X"D5BABA6F", X"887878F0", X"6F25254A", X"722E2E5C",
                                                              X"241C1C38", X"F1A6A657", X"C7B4B473", X"51C6C697",
                                                              X"23E8E8CB", X"7CDDDDA1", X"9C7474E8", X"211F1F3E",
                                                              X"DD4B4B96", X"DCBDBD61", X"868B8B0D", X"858A8A0F",
                                                              X"907070E0", X"423E3E7C", X"C4B5B571", X"AA6666CC",
                                                              X"D8484890", X"05030306", X"01F6F6F7", X"120E0E1C",
                                                              X"A36161C2", X"5F35356A", X"F95757AE", X"D0B9B969",
                                                              X"91868617", X"58C1C199", X"271D1D3A", X"B99E9E27",
                                                              X"38E1E1D9", X"13F8F8EB", X"B398982B", X"33111122",
                                                              X"BB6969D2", X"70D9D9A9", X"898E8E07", X"A7949433",
                                                              X"B69B9B2D", X"221E1E3C", X"92878715", X"20E9E9C9",
                                                              X"49CECE87", X"FF5555AA", X"78282850", X"7ADFDFA5",
                                                              X"8F8C8C03", X"F8A1A159", X"80898909", X"170D0D1A",
                                                              X"DABFBF65", X"31E6E6D7", X"C6424284", X"B86868D0",
                                                              X"C3414182", X"B0999929", X"772D2D5A", X"110F0F1E",
                                                              X"CBB0B07B", X"FC5454A8", X"D6BBBB6D", X"3A16162C");

  constant AES1                         : word32_array256 := (X"6363C6A5", X"7C7CF884", X"7777EE99", X"7B7BF68D",
                                                              X"F2F2FF0D", X"6B6BD6BD", X"6F6FDEB1", X"C5C59154",
                                                              X"30306050", X"01010203", X"6767CEA9", X"2B2B567D",
                                                              X"FEFEE719", X"D7D7B562", X"ABAB4DE6", X"7676EC9A",
                                                              X"CACA8F45", X"82821F9D", X"C9C98940", X"7D7DFA87",
                                                              X"FAFAEF15", X"5959B2EB", X"47478EC9", X"F0F0FB0B",
                                                              X"ADAD41EC", X"D4D4B367", X"A2A25FFD", X"AFAF45EA",
                                                              X"9C9C23BF", X"A4A453F7", X"7272E496", X"C0C09B5B",
                                                              X"B7B775C2", X"FDFDE11C", X"93933DAE", X"26264C6A",
                                                              X"36366C5A", X"3F3F7E41", X"F7F7F502", X"CCCC834F",
                                                              X"3434685C", X"A5A551F4", X"E5E5D134", X"F1F1F908",
                                                              X"7171E293", X"D8D8AB73", X"31316253", X"15152A3F",
                                                              X"0404080C", X"C7C79552", X"23234665", X"C3C39D5E",
                                                              X"18183028", X"969637A1", X"05050A0F", X"9A9A2FB5",
                                                              X"07070E09", X"12122436", X"80801B9B", X"E2E2DF3D",
                                                              X"EBEBCD26", X"27274E69", X"B2B27FCD", X"7575EA9F",
                                                              X"0909121B", X"83831D9E", X"2C2C5874", X"1A1A342E",
                                                              X"1B1B362D", X"6E6EDCB2", X"5A5AB4EE", X"A0A05BFB",
                                                              X"5252A4F6", X"3B3B764D", X"D6D6B761", X"B3B37DCE",
                                                              X"2929527B", X"E3E3DD3E", X"2F2F5E71", X"84841397",
                                                              X"5353A6F5", X"D1D1B968", X"00000000", X"EDEDC12C",
                                                              X"20204060", X"FCFCE31F", X"B1B179C8", X"5B5BB6ED",
                                                              X"6A6AD4BE", X"CBCB8D46", X"BEBE67D9", X"3939724B",
                                                              X"4A4A94DE", X"4C4C98D4", X"5858B0E8", X"CFCF854A",
                                                              X"D0D0BB6B", X"EFEFC52A", X"AAAA4FE5", X"FBFBED16",
                                                              X"434386C5", X"4D4D9AD7", X"33336655", X"85851194",
                                                              X"45458ACF", X"F9F9E910", X"02020406", X"7F7FFE81",
                                                              X"5050A0F0", X"3C3C7844", X"9F9F25BA", X"A8A84BE3",
                                                              X"5151A2F3", X"A3A35DFE", X"404080C0", X"8F8F058A",
                                                              X"92923FAD", X"9D9D21BC", X"38387048", X"F5F5F104",
                                                              X"BCBC63DF", X"B6B677C1", X"DADAAF75", X"21214263",
                                                              X"10102030", X"FFFFE51A", X"F3F3FD0E", X"D2D2BF6D",
                                                              X"CDCD814C", X"0C0C1814", X"13132635", X"ECECC32F",
                                                              X"5F5FBEE1", X"979735A2", X"444488CC", X"17172E39",
                                                              X"C4C49357", X"A7A755F2", X"7E7EFC82", X"3D3D7A47",
                                                              X"6464C8AC", X"5D5DBAE7", X"1919322B", X"7373E695",
                                                              X"6060C0A0", X"81811998", X"4F4F9ED1", X"DCDCA37F",
                                                              X"22224466", X"2A2A547E", X"90903BAB", X"88880B83",
                                                              X"46468CCA", X"EEEEC729", X"B8B86BD3", X"1414283C",
                                                              X"DEDEA779", X"5E5EBCE2", X"0B0B161D", X"DBDBAD76",
                                                              X"E0E0DB3B", X"32326456", X"3A3A744E", X"0A0A141E",
                                                              X"494992DB", X"06060C0A", X"2424486C", X"5C5CB8E4",
                                                              X"C2C29F5D", X"D3D3BD6E", X"ACAC43EF", X"6262C4A6",
                                                              X"919139A8", X"959531A4", X"E4E4D337", X"7979F28B",
                                                              X"E7E7D532", X"C8C88B43", X"37376E59", X"6D6DDAB7",
                                                              X"8D8D018C", X"D5D5B164", X"4E4E9CD2", X"A9A949E0",
                                                              X"6C6CD8B4", X"5656ACFA", X"F4F4F307", X"EAEACF25",
                                                              X"6565CAAF", X"7A7AF48E", X"AEAE47E9", X"08081018",
                                                              X"BABA6FD5", X"7878F088", X"25254A6F", X"2E2E5C72",
                                                              X"1C1C3824", X"A6A657F1", X"B4B473C7", X"C6C69751",
                                                              X"E8E8CB23", X"DDDDA17C", X"7474E89C", X"1F1F3E21",
                                                              X"4B4B96DD", X"BDBD61DC", X"8B8B0D86", X"8A8A0F85",
                                                              X"7070E090", X"3E3E7C42", X"B5B571C4", X"6666CCAA",
                                                              X"484890D8", X"03030605", X"F6F6F701", X"0E0E1C12",
                                                              X"6161C2A3", X"35356A5F", X"5757AEF9", X"B9B969D0",
                                                              X"86861791", X"C1C19958", X"1D1D3A27", X"9E9E27B9",
                                                              X"E1E1D938", X"F8F8EB13", X"98982BB3", X"11112233",
                                                              X"6969D2BB", X"D9D9A970", X"8E8E0789", X"949433A7",
                                                              X"9B9B2DB6", X"1E1E3C22", X"87871592", X"E9E9C920",
                                                              X"CECE8749", X"5555AAFF", X"28285078", X"DFDFA57A",
                                                              X"8C8C038F", X"A1A159F8", X"89890980", X"0D0D1A17",
                                                              X"BFBF65DA", X"E6E6D731", X"424284C6", X"6868D0B8",
                                                              X"414182C3", X"999929B0", X"2D2D5A77", X"0F0F1E11",
                                                              X"B0B07BCB", X"5454A8FC", X"BBBB6DD6", X"16162C3A");

  constant AES2                         : word32_array256 := (X"63C6A563", X"7CF8847C", X"77EE9977", X"7BF68D7B",
                                                              X"F2FF0DF2", X"6BD6BD6B", X"6FDEB16F", X"C59154C5",
                                                              X"30605030", X"01020301", X"67CEA967", X"2B567D2B",
                                                              X"FEE719FE", X"D7B562D7", X"AB4DE6AB", X"76EC9A76",
                                                              X"CA8F45CA", X"821F9D82", X"C98940C9", X"7DFA877D",
                                                              X"FAEF15FA", X"59B2EB59", X"478EC947", X"F0FB0BF0",
                                                              X"AD41ECAD", X"D4B367D4", X"A25FFDA2", X"AF45EAAF",
                                                              X"9C23BF9C", X"A453F7A4", X"72E49672", X"C09B5BC0",
                                                              X"B775C2B7", X"FDE11CFD", X"933DAE93", X"264C6A26",
                                                              X"366C5A36", X"3F7E413F", X"F7F502F7", X"CC834FCC",
                                                              X"34685C34", X"A551F4A5", X"E5D134E5", X"F1F908F1",
                                                              X"71E29371", X"D8AB73D8", X"31625331", X"152A3F15",
                                                              X"04080C04", X"C79552C7", X"23466523", X"C39D5EC3",
                                                              X"18302818", X"9637A196", X"050A0F05", X"9A2FB59A",
                                                              X"070E0907", X"12243612", X"801B9B80", X"E2DF3DE2",
                                                              X"EBCD26EB", X"274E6927", X"B27FCDB2", X"75EA9F75",
                                                              X"09121B09", X"831D9E83", X"2C58742C", X"1A342E1A",
                                                              X"1B362D1B", X"6EDCB26E", X"5AB4EE5A", X"A05BFBA0",
                                                              X"52A4F652", X"3B764D3B", X"D6B761D6", X"B37DCEB3",
                                                              X"29527B29", X"E3DD3EE3", X"2F5E712F", X"84139784",
                                                              X"53A6F553", X"D1B968D1", X"00000000", X"EDC12CED",
                                                              X"20406020", X"FCE31FFC", X"B179C8B1", X"5BB6ED5B",
                                                              X"6AD4BE6A", X"CB8D46CB", X"BE67D9BE", X"39724B39",
                                                              X"4A94DE4A", X"4C98D44C", X"58B0E858", X"CF854ACF",
                                                              X"D0BB6BD0", X"EFC52AEF", X"AA4FE5AA", X"FBED16FB",
                                                              X"4386C543", X"4D9AD74D", X"33665533", X"85119485",
                                                              X"458ACF45", X"F9E910F9", X"02040602", X"7FFE817F",
                                                              X"50A0F050", X"3C78443C", X"9F25BA9F", X"A84BE3A8",
                                                              X"51A2F351", X"A35DFEA3", X"4080C040", X"8F058A8F",
                                                              X"923FAD92", X"9D21BC9D", X"38704838", X"F5F104F5",
                                                              X"BC63DFBC", X"B677C1B6", X"DAAF75DA", X"21426321",
                                                              X"10203010", X"FFE51AFF", X"F3FD0EF3", X"D2BF6DD2",
                                                              X"CD814CCD", X"0C18140C", X"13263513", X"ECC32FEC",
                                                              X"5FBEE15F", X"9735A297", X"4488CC44", X"172E3917",
                                                              X"C49357C4", X"A755F2A7", X"7EFC827E", X"3D7A473D",
                                                              X"64C8AC64", X"5DBAE75D", X"19322B19", X"73E69573",
                                                              X"60C0A060", X"81199881", X"4F9ED14F", X"DCA37FDC",
                                                              X"22446622", X"2A547E2A", X"903BAB90", X"880B8388",
                                                              X"468CCA46", X"EEC729EE", X"B86BD3B8", X"14283C14",
                                                              X"DEA779DE", X"5EBCE25E", X"0B161D0B", X"DBAD76DB",
                                                              X"E0DB3BE0", X"32645632", X"3A744E3A", X"0A141E0A",
                                                              X"4992DB49", X"060C0A06", X"24486C24", X"5CB8E45C",
                                                              X"C29F5DC2", X"D3BD6ED3", X"AC43EFAC", X"62C4A662",
                                                              X"9139A891", X"9531A495", X"E4D337E4", X"79F28B79",
                                                              X"E7D532E7", X"C88B43C8", X"376E5937", X"6DDAB76D",
                                                              X"8D018C8D", X"D5B164D5", X"4E9CD24E", X"A949E0A9",
                                                              X"6CD8B46C", X"56ACFA56", X"F4F307F4", X"EACF25EA",
                                                              X"65CAAF65", X"7AF48E7A", X"AE47E9AE", X"08101808",
                                                              X"BA6FD5BA", X"78F08878", X"254A6F25", X"2E5C722E",
                                                              X"1C38241C", X"A657F1A6", X"B473C7B4", X"C69751C6",
                                                              X"E8CB23E8", X"DDA17CDD", X"74E89C74", X"1F3E211F",
                                                              X"4B96DD4B", X"BD61DCBD", X"8B0D868B", X"8A0F858A",
                                                              X"70E09070", X"3E7C423E", X"B571C4B5", X"66CCAA66",
                                                              X"4890D848", X"03060503", X"F6F701F6", X"0E1C120E",
                                                              X"61C2A361", X"356A5F35", X"57AEF957", X"B969D0B9",
                                                              X"86179186", X"C19958C1", X"1D3A271D", X"9E27B99E",
                                                              X"E1D938E1", X"F8EB13F8", X"982BB398", X"11223311",
                                                              X"69D2BB69", X"D9A970D9", X"8E07898E", X"9433A794",
                                                              X"9B2DB69B", X"1E3C221E", X"87159287", X"E9C920E9",
                                                              X"CE8749CE", X"55AAFF55", X"28507828", X"DFA57ADF",
                                                              X"8C038F8C", X"A159F8A1", X"89098089", X"0D1A170D",
                                                              X"BF65DABF", X"E6D731E6", X"4284C642", X"68D0B868",
                                                              X"4182C341", X"9929B099", X"2D5A772D", X"0F1E110F",
                                                              X"B07BCBB0", X"54A8FC54", X"BB6DD6BB", X"162C3A16");

  constant AES3                         : word32_array256 := (X"C6A56363", X"F8847C7C", X"EE997777", X"F68D7B7B",
                                                              X"FF0DF2F2", X"D6BD6B6B", X"DEB16F6F", X"9154C5C5",
                                                              X"60503030", X"02030101", X"CEA96767", X"567D2B2B",
                                                              X"E719FEFE", X"B562D7D7", X"4DE6ABAB", X"EC9A7676",
                                                              X"8F45CACA", X"1F9D8282", X"8940C9C9", X"FA877D7D",
                                                              X"EF15FAFA", X"B2EB5959", X"8EC94747", X"FB0BF0F0",
                                                              X"41ECADAD", X"B367D4D4", X"5FFDA2A2", X"45EAAFAF",
                                                              X"23BF9C9C", X"53F7A4A4", X"E4967272", X"9B5BC0C0",
                                                              X"75C2B7B7", X"E11CFDFD", X"3DAE9393", X"4C6A2626",
                                                              X"6C5A3636", X"7E413F3F", X"F502F7F7", X"834FCCCC",
                                                              X"685C3434", X"51F4A5A5", X"D134E5E5", X"F908F1F1",
                                                              X"E2937171", X"AB73D8D8", X"62533131", X"2A3F1515",
                                                              X"080C0404", X"9552C7C7", X"46652323", X"9D5EC3C3",
                                                              X"30281818", X"37A19696", X"0A0F0505", X"2FB59A9A",
                                                              X"0E090707", X"24361212", X"1B9B8080", X"DF3DE2E2",
                                                              X"CD26EBEB", X"4E692727", X"7FCDB2B2", X"EA9F7575",
                                                              X"121B0909", X"1D9E8383", X"58742C2C", X"342E1A1A",
                                                              X"362D1B1B", X"DCB26E6E", X"B4EE5A5A", X"5BFBA0A0",
                                                              X"A4F65252", X"764D3B3B", X"B761D6D6", X"7DCEB3B3",
                                                              X"527B2929", X"DD3EE3E3", X"5E712F2F", X"13978484",
                                                              X"A6F55353", X"B968D1D1", X"00000000", X"C12CEDED",
                                                              X"40602020", X"E31FFCFC", X"79C8B1B1", X"B6ED5B5B",
                                                              X"D4BE6A6A", X"8D46CBCB", X"67D9BEBE", X"724B3939",
                                                              X"94DE4A4A", X"98D44C4C", X"B0E85858", X"854ACFCF",
                                                              X"BB6BD0D0", X"C52AEFEF", X"4FE5AAAA", X"ED16FBFB",
                                                              X"86C54343", X"9AD74D4D", X"66553333", X"11948585",
                                                              X"8ACF4545", X"E910F9F9", X"04060202", X"FE817F7F",
                                                              X"A0F05050", X"78443C3C", X"25BA9F9F", X"4BE3A8A8",
                                                              X"A2F35151", X"5DFEA3A3", X"80C04040", X"058A8F8F",
                                                              X"3FAD9292", X"21BC9D9D", X"70483838", X"F104F5F5",
                                                              X"63DFBCBC", X"77C1B6B6", X"AF75DADA", X"42632121",
                                                              X"20301010", X"E51AFFFF", X"FD0EF3F3", X"BF6DD2D2",
                                                              X"814CCDCD", X"18140C0C", X"26351313", X"C32FECEC",
                                                              X"BEE15F5F", X"35A29797", X"88CC4444", X"2E391717",
                                                              X"9357C4C4", X"55F2A7A7", X"FC827E7E", X"7A473D3D",
                                                              X"C8AC6464", X"BAE75D5D", X"322B1919", X"E6957373",
                                                              X"C0A06060", X"19988181", X"9ED14F4F", X"A37FDCDC",
                                                              X"44662222", X"547E2A2A", X"3BAB9090", X"0B838888",
                                                              X"8CCA4646", X"C729EEEE", X"6BD3B8B8", X"283C1414",
                                                              X"A779DEDE", X"BCE25E5E", X"161D0B0B", X"AD76DBDB",
                                                              X"DB3BE0E0", X"64563232", X"744E3A3A", X"141E0A0A",
                                                              X"92DB4949", X"0C0A0606", X"486C2424", X"B8E45C5C",
                                                              X"9F5DC2C2", X"BD6ED3D3", X"43EFACAC", X"C4A66262",
                                                              X"39A89191", X"31A49595", X"D337E4E4", X"F28B7979",
                                                              X"D532E7E7", X"8B43C8C8", X"6E593737", X"DAB76D6D",
                                                              X"018C8D8D", X"B164D5D5", X"9CD24E4E", X"49E0A9A9",
                                                              X"D8B46C6C", X"ACFA5656", X"F307F4F4", X"CF25EAEA",
                                                              X"CAAF6565", X"F48E7A7A", X"47E9AEAE", X"10180808",
                                                              X"6FD5BABA", X"F0887878", X"4A6F2525", X"5C722E2E",
                                                              X"38241C1C", X"57F1A6A6", X"73C7B4B4", X"9751C6C6",
                                                              X"CB23E8E8", X"A17CDDDD", X"E89C7474", X"3E211F1F",
                                                              X"96DD4B4B", X"61DCBDBD", X"0D868B8B", X"0F858A8A",
                                                              X"E0907070", X"7C423E3E", X"71C4B5B5", X"CCAA6666",
                                                              X"90D84848", X"06050303", X"F701F6F6", X"1C120E0E",
                                                              X"C2A36161", X"6A5F3535", X"AEF95757", X"69D0B9B9",
                                                              X"17918686", X"9958C1C1", X"3A271D1D", X"27B99E9E",
                                                              X"D938E1E1", X"EB13F8F8", X"2BB39898", X"22331111",
                                                              X"D2BB6969", X"A970D9D9", X"07898E8E", X"33A79494",
                                                              X"2DB69B9B", X"3C221E1E", X"15928787", X"C920E9E9",
                                                              X"8749CECE", X"AAFF5555", X"50782828", X"A57ADFDF",
                                                              X"038F8C8C", X"59F8A1A1", X"09808989", X"1A170D0D",
                                                              X"65DABFBF", X"D731E6E6", X"84C64242", X"D0B86868",
                                                              X"82C34141", X"29B09999", X"5A772D2D", X"1E110F0F",
                                                              X"7BCBB0B0", X"A8FC5454", X"6DD6BBBB", X"2C3A1616");
  
  function aes_round_le(x: word32_array4; k: word32_array4) return word32_array4 is
    variable y                          : word32_array4;
  begin
    y(0)                                := AES0(to_integer(byte_sel(x(0),0))) xor
                                           AES1(to_integer(byte_sel(x(1),1))) xor
                                           AES2(to_integer(byte_sel(x(2),2))) xor
                                           AES3(to_integer(byte_sel(x(3),3))) xor k(0);
    y(1)                                := AES0(to_integer(byte_sel(x(1),0))) xor
                                           AES1(to_integer(byte_sel(x(2),1))) xor
                                           AES2(to_integer(byte_sel(x(3),2))) xor
                                           AES3(to_integer(byte_sel(x(0),3))) xor k(1);
    y(2)                                := AES0(to_integer(byte_sel(x(2),0))) xor
                                           AES1(to_integer(byte_sel(x(3),1))) xor
                                           AES2(to_integer(byte_sel(x(0),2))) xor
                                           AES3(to_integer(byte_sel(x(1),3))) xor k(2);
    y(3)                                := AES0(to_integer(byte_sel(x(3),0))) xor
                                           AES1(to_integer(byte_sel(x(0),1))) xor
                                           AES2(to_integer(byte_sel(x(1),2))) xor
                                           AES3(to_integer(byte_sel(x(2),3))) xor k(3);
    return y;
  end aes_round_le;
  
  function aes_two_rounds(x: word32_array4; k: word32_array4) return word32_array4 is
    variable x2                         : word32_array4;
  begin
    x2                                  := aes_round_le(x, k);
    x2                                  := aes_round_le(x2, ZEROS_WORD32_ARRAY4);
    return x2;
  end aes_two_rounds;
  
  signal x_in_array                     : word32_array4;
  signal k_in_array                     : word32_array4;
  signal x_out_array                    : word32_array4;
  
begin
  
  output_mapping : for i in 0 to 3 generate
    x_out((i+1)*32-1 downto i*32)       <= x_out_array(i);
  end generate output_mapping;
   
  input_mapping : for i in 0 to 3 generate
    x_in_array(i)                       <= x_in((i+1)*32-1 downto i*32);
    k_in_array(i)                       <= k_in((i+1)*32-1 downto i*32);
  end generate input_mapping;
  
  x_out_array                           <= aes_two_rounds(x_in_array, k_in_array);
  
end architecture echo512_aes_two_rounds_rtl;