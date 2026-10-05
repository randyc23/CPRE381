library IEEE;
use IEEE.std_logic_1164.all;

entity shift2 is
    generic(WIDTH : integer);
    port(shift            : in std_logic;
         fill             : in std_logic;
         Ip               : in std_logic_vector(WIDTH-1 downto 0);
         Shifted          : out std_logic_vector(WIDTH-1 downto 0));

end shift2;

architecture structural of shift2 is
    component mux2t1_n is
      generic(N : integer);
      port(s0               : in std_logic;
           iA               : in std_logic_vector(N-1 downto 0);
           iB               : in std_logic_vector(N-1 downto 0);
           oC               : out std_logic_vector(N-1 downto 0));
    end component;

    signal B : std_logic_vector(WIDTH-1 downto 0);
    signal fill_field : std_logic_vector(WIDTH-1 downto 0);
begin

    fill_field <= (others => fill);
    B <= Ip(WIDTH-3 downto 0) & fill_field(WIDTH-1 downto WIDTH-2);

    g1: mux2t1_n
        generic map(N => WIDTH)
        port map(s0 => shift,
                 iA => Ip,
                 iB => B,
                 oC => Shifted);
end structural;