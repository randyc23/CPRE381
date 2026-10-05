library IEEE;
use IEEE.std_logic_1164.all;

entity org_n is
  generic(N : integer); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_A          : in std_logic_vector(N-1 downto 0);
       i_B         : in std_logic_vector(N-1 downto 0);
       o_F          : out std_logic_vector(N-1 downto 0));

end org_n;

architecture structural of org_n is

  component org2 is
    port(i_A                  : in std_logic;
         i_B                 : in std_logic;
         o_F                  : out std_logic);
  end component;

begin

  -- Instantiate N mux instances.
  G_NBit_OR: for i in 0 to N-1 generate
    ORI: org2 port map(
              i_A      => i_A(i),      -- All instances share the same select input.
              i_B     => i_B(i),  -- ith instance's data 0 input hooked up to ith data 0 input.
              o_F      => o_F(i));  -- ith instance's data output hooked up to ith data output.
  end generate G_NBit_OR;
  
end structural;