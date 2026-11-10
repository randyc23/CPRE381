library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity rev_mux is
    generic(WIDTH : integer);
    port(dir            : in std_logic;
         d_in           : in std_logic_vector(WIDTH-1 downto 0);
         d_rev          : out std_logic_vector(WIDTH-1 downto 0));

end rev_mux;

architecture structural of rev_mux is
    component mux2t1_n is
      generic(N : integer);
      port(i_S              : in std_logic;
           i_D0             : in std_logic_vector(N-1 downto 0);
           i_D1             : in std_logic_vector(N-1 downto 0);
           o_O              : out std_logic_vector(N-1 downto 0));
    end component;

    signal s_rev : std_logic_vector(WIDTH-1 downto 0);
begin

    g_rev: for i in 0 to WIDTH-1 generate
        s_rev(i) <= d_in(WIDTH-1-i);
    end generate g_rev;

    g1: mux2t1_n
        generic map(N => WIDTH)
        port map(i_S => dir,
                 i_D0 => d_in,
                 i_D1 => s_rev,
                 o_O => d_rev);
end structural;