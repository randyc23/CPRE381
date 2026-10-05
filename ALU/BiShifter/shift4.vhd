library IEEE;
use IEEE.std_logic_1164.all;

entity shift4 is
    generic(WIDTH : integer);
    port(shift            : in std_logic;
         fill             : in std_logic;
         Ip               : in std_logic_vector(WIDTH-1 downto 0);
         Shifted          : out std_logic_vector(WIDTH-1 downto 0));

end shift4;

architecture structural of shift4 is
    component mux2t1_n is
      generic(N : integer);
      port(i_S              : in std_logic;
           i_D0             : in std_logic_vector(N-1 downto 0);
           i_D1             : in std_logic_vector(N-1 downto 0);
           o_O              : out std_logic_vector(N-1 downto 0));
    end component;

    signal B : std_logic_vector(WIDTH-1 downto 0);
    signal fill_field : std_logic_vector(WIDTH-1 downto 0);
begin

    fill_field <= (others => fill);
    B <= Ip(WIDTH-5 downto 0) & fill_field(WIDTH-1 downto WIDTH-4);

    g1: mux2t1_n
        generic map(N => WIDTH)
        port map(i_S => shift,
                 i_D0 => Ip,
                 i_D1 => B,
                 o_O => Shifted);
end structural;