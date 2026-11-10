library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity shift1 is
    generic(WIDTH : integer);
    port(shift            : in std_logic;
         fill             : in std_logic;
         Ip               : in std_logic_vector(WIDTH-1 downto 0);
         Shifted          : out std_logic_vector(WIDTH-1 downto 0));

end shift1;

architecture structural of shift1 is
    component mux2t1_n is
      generic(N : integer);
      port(i_S              : in std_logic;
           i_D0             : in std_logic_vector(N-1 downto 0);
           i_D1             : in std_logic_vector(N-1 downto 0);
           o_O              : out std_logic_vector(N-1 downto 0));
    end component;

    signal B : std_logic_vector(WIDTH-1 downto 0);
begin

    B <= Ip(WIDTH-2 downto 0) & fill;

    g1: mux2t1_n
        generic map(N => WIDTH)
        port map(i_S => shift,
                 i_D0 => Ip,
                 i_D1 => B,
                 o_O => Shifted);
end structural;