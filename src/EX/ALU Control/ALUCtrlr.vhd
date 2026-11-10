library IEEE;
use IEEE.std_logic_1164.all;

entity aluctrlr is
    generic(WIDTH : integer);
    port(inst                : in std_logic_vector(WIDTH-1 downto 0);
         aluop                : in std_logic_vector(1 downto 0);
         Aluctrl             : out std_logic_vector(3 downto 0));
end aluctrlr;

architecture structural of aluctrlr is

component andg5 is
    port(i_A          : in std_logic;
         i_B          : in std_logic;
         i_C          : in std_logic;
         i_D          : in std_logic;
         i_E          : in std_logic;
         o_F          : out std_logic);
end component;
component invg is
    port(i_A          : in std_logic;
         o_F          : out std_logic);
end component;
component org2 is
    port(i_A          : in std_logic;
         i_B          : in std_logic;
         o_F          : out std_logic);
end component;
component andg2 is
    port(i_A          : in std_logic;
         i_B          : in std_logic;
         o_F          : out std_logic);
end component;
component andg3 is
    port(i_A          : in std_logic;
         i_B          : in std_logic;
         i_C          : in std_logic;
         o_F          : out std_logic);
end component;
component andg4 is
    port(i_A          : in std_logic;
         i_B          : in std_logic;
         i_C          : in std_logic;
         i_D          : in std_logic;
         o_F          : out std_logic);
end component;
component org3 is 
    port(i_A          : in std_logic;
         i_B          : in std_logic;
         i_C          : in std_logic;
         o_F          : out std_logic);
end component;
component org4 is
    port(i_A          : in std_logic;
         i_B          : in std_logic;
         i_C          : in std_logic;
         i_D          : in std_logic;
         o_F          : out std_logic);
end component;

signal nOP0, n14, n13, n12 : std_logic;
signal and1, and2, and3, and4, and5, and6, and7, and8, and9, and10, and11: std_logic;
signal or1, or2, or3, or4 : std_logic;
begin
    G_INV1: invg port map(i_A => aluop(0), o_F => nOP0);
    G_INV2: invg port map(i_A => inst(14), o_F => n14);
    G_INV3: invg port map(i_A => inst(13), o_F => n13);
    G_INV4: invg port map(i_A => inst(12), o_F => n12); 
    -- C3
    G_AND1: andg2 port map(i_A => n13, i_B => inst(12), o_F => and1);
    G_OR1: org2 port map(i_A => inst(14), i_B => and1, o_F => or1);
    G_AND2: andg2 port map(i_A => aluop(1), i_B => or1, o_F => and2);
    Aluctrl(3) <= and2;
    -- c2
    G_AND3: andg2 port map(i_A => n14, i_B => inst(13), o_F => and3);
    G_OR2: org2 port map(i_A => and3, i_B => and1, o_F => or2);
    G_AND4: andg2 port map(i_A => aluop(1), i_B => or2, o_F => and4);
    Aluctrl(2) <= and4;
    -- C1
    G_AND5: andg3 port map(i_A => n14, i_B => inst(13), i_C => inst(12), o_F => and5);
    G_AND6: andg3 port map(i_A => inst(14), i_B => n13, i_C => n12, o_F => and6);
    G_AND7: andg4 port map(i_A => inst(14), i_B => n13, i_C => inst(12), i_D => inst(30), o_F => and7);
    G_OR3: org3 port map(i_A => and5, i_B => and6, i_C => and7, o_F => or3);
    Aluctrl(1) <= or3;
    -- C0
    G_AND8: andg2 port map(i_A => inst(13), i_B => n12, o_F => and8);
    G_AND9: andg5 port map(i_A => n14, i_B => n13, i_C => n12, i_D => inst(30), i_E => nOP0, o_F => and9);
    G_AND10: andg3 port map(i_A => inst(14), i_B => n13, i_C => inst(12), o_F => and10);
    G_OR4: org4 port map(i_A => and3, i_B => and8, i_C => and9, i_D => and10, o_F => or4);
    G_AND11: andg2 port map(i_A => aluop(1), i_B => or4, o_F => and11);
    Aluctrl(0) <= and11;
end structural; 