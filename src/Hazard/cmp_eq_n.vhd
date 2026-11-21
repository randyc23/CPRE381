library IEEE;
use IEEE.std_logic_1164.all;

entity cmp_eq_n is
    generic(N : integer);
    port(i_A  : in std_logic_vector(N-1 downto 0);
         i_B  : in std_logic_vector(N-1 downto 0);
         o_EQ : out std_logic);
end cmp_eq_n;

architecture structural of cmp_eq_n is

    component xorg2 is
        port(i_A : in std_logic;
             i_B : in std_logic;
             o_F : out std_logic);
    end component;

    component org2 is
        port(i_A : in std_logic;
             i_B : in std_logic;
             o_F : out std_logic);
    end component;

    component invg is
        port(i_A : in std_logic;
             o_F : out std_logic);
    end component;

    signal s_x  : std_logic_vector(N-1 downto 0);
    signal s_or : std_logic_vector(N-1 downto 0);

begin

    G_X0: xorg2 port map(i_A => i_A(0), i_B => i_B(0), o_F => s_or(0));

    G_BITS: for i in 1 to N-1 generate
        G_X: xorg2 port map(i_A => i_A(i), i_B => i_B(i), o_F => s_x(i));
        G_O: org2 port map(i_A => s_or(i-1), i_B => s_x(i), o_F => s_or(i));
    end generate G_BITS;

    G_EQ: invg port map(i_A => s_or(N-1), o_F => o_EQ);

end structural;
