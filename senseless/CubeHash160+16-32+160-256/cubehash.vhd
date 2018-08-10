--  
-- Copyright (c) 2018 Allmine Inc
--

library work;
    use work.ch_globals.all;
    
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity cubehash is
port(   clk         : in  std_logic;
        start       : in  std_logic;
        state_in    : in  std_logic_vector(255 downto 0);
        dout        : out std_logic_vector(255 downto 0)
    );
end cubehash;

architecture rtl of cubehash is

--components

component ch_round
port(   state_in     : in  std_logic_vector(1023 downto 0);
        state_out    : out std_logic_vector(1023 downto 0)
    );
end component;

component ch_register
port(   clk : in std_logic;
        state_in     : in  std_logic_vector(1023 downto 0);
        state_out    : out std_logic_vector(1023 downto 0)
    );
end component;

  ----------------------------------------------------------------------------
  -- Internal signal declarations
  ----------------------------------------------------------------------------

signal rcnt, fcnt : std_logic_vector(3 downto 0);

signal din, mr00 : std_logic_vector(1023 downto 0);

signal mr01,mr02,mr03,mr04,mr05,mr06,mr07,mr08,mr09,mr10 : std_logic_vector(1023 downto 0);
signal mr11,mr12,mr13,mr14,mr15,mr16                     : std_logic_vector(1023 downto 0);

signal mc01,mc02,mc03,mc04,mc05,mc06,mc07,mc08,mc09,mc10 : std_logic_vector(1023 downto 0);
signal mc11,mc12,mc13,mc14,mc15,mc16                     : std_logic_vector(1023 downto 0);

-- signal r001,r002,r003,r004,r005,r006,r007,r008,r009,r010 : std_logic_vector(1023 downto 0);
-- signal r011,r012,r013,r014,r015,r016,r017,r018,r019,r020 : std_logic_vector(1023 downto 0);
-- signal r021,r022,r023,r024,r025,r026,r027,r028,r029,r030 : std_logic_vector(1023 downto 0);
-- signal r031,r032,r033,r034,r035,r036,r037,r038,r039,r040 : std_logic_vector(1023 downto 0);
-- signal r041,r042,r043,r044,r045,r046,r047,r048,r049,r050 : std_logic_vector(1023 downto 0);
-- signal r051,r052,r053,r054,r055,r056,r057,r058,r059,r060 : std_logic_vector(1023 downto 0);
-- signal r061,r062,r063,r064,r065,r066,r067,r068,r069,r070 : std_logic_vector(1023 downto 0);
-- signal r071,r072,r073,r074,r075,r076,r077,r078,r079,r080 : std_logic_vector(1023 downto 0);
-- signal r081,r082,r083,r084,r085,r086,r087,r088,r089,r090 : std_logic_vector(1023 downto 0);
-- signal r091,r092,r093,r094,r095,r096,r097,r098,r099,r100 : std_logic_vector(1023 downto 0);
-- signal r101,r102,r103,r104,r105,r106,r107,r108,r109,r110 : std_logic_vector(1023 downto 0);
-- signal r111,r112,r113,r114,r115,r116,r117,r118,r119,r120 : std_logic_vector(1023 downto 0);
-- signal r121,r122,r123,r124,r125,r126,r127,r128,r129,r130 : std_logic_vector(1023 downto 0);
-- signal r131,r132,r133,r134,r135,r136,r137,r138,r139,r140 : std_logic_vector(1023 downto 0);
-- signal r141,r142,r143,r144,r145,r146,r147,r148,r149,r150 : std_logic_vector(1023 downto 0);
-- signal r151,r152,r153,r154,r155,r156,r157,r158,r159,r160 : std_logic_vector(1023 downto 0);

-- signal c001,c002,c003,c004,c005,c006,c007,c008,c009,c010 : std_logic_vector(1023 downto 0);
-- signal c011,c012,c013,c014,c015,c016,c017,c018,c019,c020 : std_logic_vector(1023 downto 0);
-- signal c021,c022,c023,c024,c025,c026,c027,c028,c029,c030 : std_logic_vector(1023 downto 0);
-- signal c031,c032,c033,c034,c035,c036,c037,c038,c039,c040 : std_logic_vector(1023 downto 0);
-- signal c041,c042,c043,c044,c045,c046,c047,c048,c049,c050 : std_logic_vector(1023 downto 0);
-- signal c051,c052,c053,c054,c055,c056,c057,c058,c059,c060 : std_logic_vector(1023 downto 0);
-- signal c061,c062,c063,c064,c065,c066,c067,c068,c069,c070 : std_logic_vector(1023 downto 0);
-- signal c071,c072,c073,c074,c075,c076,c077,c078,c079,c080 : std_logic_vector(1023 downto 0);
-- signal c081,c082,c083,c084,c085,c086,c087,c088,c089,c090 : std_logic_vector(1023 downto 0);
-- signal c091,c092,c093,c094,c095,c096,c097,c098,c099,c100 : std_logic_vector(1023 downto 0);
-- signal c101,c102,c103,c104,c105,c106,c107,c108,c109,c110 : std_logic_vector(1023 downto 0);
-- signal c111,c112,c113,c114,c115,c116,c117,c118,c119,c120 : std_logic_vector(1023 downto 0);
-- signal c121,c122,c123,c124,c125,c126,c127,c128,c129,c130 : std_logic_vector(1023 downto 0);
-- signal c131,c132,c133,c134,c135,c136,c137,c138,c139,c140 : std_logic_vector(1023 downto 0);
-- signal c141,c142,c143,c144,c145,c146,c147,c148,c149,c150 : std_logic_vector(1023 downto 0);
-- signal c151,c152,c153,c154,c155,c156,c157,c158,c159,c160 : std_logic_vector(1023 downto 0);

signal din_tmp, dout_tmp: std_logic_vector (255 downto 0);

begin  -- Rtl

    fsm : process( clk )
    begin
        if rising_edge( clk ) then
            if (start = '1' ) then
                rcnt <= "0000";
                fcnt <= "0000";
            else
                if(fcnt < "1011") then
                    if(rcnt = "1111") then
                        rcnt <= "0000";
                        fcnt <= std_logic_vector(unsigned(fcnt) + 1);
                    else
                        rcnt <= std_logic_vector(unsigned(rcnt) + 1);
                    end if;
                end if;
            end if;
        end if;
    end process;

    --swap endinaess
    i0: for w in 0 to 7 generate
        i1: for b in 0 to 3 generate
            din_tmp(32*w+8*b+7 downto 32*w+8*b) <= state_in(32*w+8*(3-b)+7 downto 32*w+8*(3-b));
        end generate;    
    end generate;

            
    din(1023 downto 768) <= (others=>'0') when fcnt = "1011" else
                            init_state(1023 downto 768) xor din_tmp when fcnt = "0000" else
                            mc16(1023 downto 768);
    din( 767 downto   1) <= (others=>'0') when fcnt = "1011" else
                            init_state(767 downto 1) when fcnt = "0000" else
                            mc16(767 downto 1);
    din(              0) <= '0' when fcnt = "1011" else
                            init_state(0) when fcnt = "0000" else
                            mc16(0) xor '1' when fcnt = "0001" else
                            mc16(0);

    -- fully unrolled 16 middle rounds
    mr00_map : ch_register port map(clk,din,mr00);
    mc01_map : ch_round port map(mr00,mc01);
    mr01_map : ch_register port map(clk,mc01,mr01);
    mc02_map : ch_round port map(mr01,mc02);
    mr02_map : ch_register port map(clk,mc02,mr02);
    mc03_map : ch_round port map(mr02,mc03);
    mr03_map : ch_register port map(clk,mc03,mr03);
    mc04_map : ch_round port map(mr03,mc04);
    mr04_map : ch_register port map(clk,mc04,mr04);
    mc05_map : ch_round port map(mr04,mc05);
    mr05_map : ch_register port map(clk,mc05,mr05);
    mc06_map : ch_round port map(mr05,mc06);
    mr06_map : ch_register port map(clk,mc06,mr06);
    mc07_map : ch_round port map(mr06,mc07);
    mr07_map : ch_register port map(clk,mc07,mr07);
    mc08_map : ch_round port map(mr07,mc08);
    mr08_map : ch_register port map(clk,mc08,mr08);
    mc09_map : ch_round port map(mr08,mc09);
    mr09_map : ch_register port map(clk,mc09,mr09);
    mc10_map : ch_round port map(mr09,mc10);
    mr10_map : ch_register port map(clk,mc10,mr10);
    mc11_map : ch_round port map(mr10,mc11);
    mr11_map : ch_register port map(clk,mc11,mr11);
    mc12_map : ch_round port map(mr11,mc12);
    mr12_map : ch_register port map(clk,mc12,mr12);
    mc13_map : ch_round port map(mr12,mc13);
    mr13_map : ch_register port map(clk,mc13,mr13);
    mc14_map : ch_round port map(mr13,mc14);
    mr14_map : ch_register port map(clk,mc14,mr14);
    mc15_map : ch_round port map(mr14,mc15);
    mr15_map : ch_register port map(clk,mc15,mr15);
    mc16_map : ch_round port map(mr15,mc16);
    mr16_map : ch_register port map(clk,mc16,mr16);
        
    dout_tmp <= mr16(1023 downto 768);

    --swap endinaess
    o0: for w in 0 to 7 generate
        o1: for b in 0 to 3 generate
            dout(32*w+8*b+7 downto 32*w+8*b) <= dout_tmp(32*w+8*(3-b)+7 downto 32*w+8*(3-b));
        end generate;    
    end generate;

end rtl;
