library IEEE;
use IEEE.std_logic_1164.all;

entity norg_n is
  generic(N : integer); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_A          : in std_logic_vector(N-1 downto 0);
       i_B         : in std_logic_vector(N-1 downto 0);
       o_F          : out std_logic_vector(N-1 downto 0));

end norg_n;

architecture structural of norg_n is

  component org_n is
    generic(N : integer); -- Generic of type integer for input/output data width. Default value is 32.
    port(i_A                  : in std_logic_vector(N-1 downto 0);
         i_B                 : in std_logic_vector(N-1 downto 0);
         o_F                  : out std_logic_vector(N-1 downto 0));
  end component;

  component invg_n is
    generic(N : integer);
    port(i_A                  : in std_logic_vector(N-1 downto 0);
         o_F                  : out std_logic_vector(N-1 downto 0));
  end component;

  signal s_or : std_logic_vector(N-1 downto 0);

begin

    -- Instantiate N mux instances.
    g_orgn: org_n generic map(N => N) port map(
              i_A      => i_A,      -- All instances share the same select input.
              i_B     => i_B,  -- ith instance's data 0 input hooked up to ith data 0 input.
              o_F      => s_or);  -- ith instance's data output hooked up to ith data output.
    g_nor: invg_n generic map(N => N) port map(
              i_A      => s_or,      -- All instances share the same select input.
              o_F      => o_F);  -- ith instance's data output hooked up to ith data output.
end structural;
