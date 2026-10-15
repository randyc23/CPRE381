library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity branch_logic is
    generic(WIDTH : integer := 32);
    port(i_A     : in  std_logic_vector(WIDTH-1 downto 0);
         i_B     : in  std_logic_vector(WIDTH-1 downto 0);
         funct3  : in  std_logic_vector(2 downto 0);
         Branch  : in  std_logic;
         Taken   : out std_logic);
end branch_logic;

architecture dataflow of branch_logic is

    signal s_equal, s_less_signed, s_less_unsigned, s_cond : std_logic;

begin

    s_equal         <= '1' when i_A = i_B else '0';
    s_less_signed   <= '1' when signed(i_A) < signed(i_B) else '0';
    s_less_unsigned <= '1' when unsigned(i_A) < unsigned(i_B) else '0';

    with funct3 select
        s_cond <= s_equal             when "000",
                  not s_equal         when "001",
                  s_less_signed       when "100",
                  not s_less_signed   when "101",
                  s_less_unsigned     when "110",
                  not s_less_unsigned when "111",
                  '0'                 when others;

    Taken <= Branch and s_cond;

end dataflow;
