library IEEE;
use IEEE.std_logic_1164.all;

entity pc_reg is
    generic(WIDTH   : integer;
            RST_VAL : std_logic_vector);
    port(i_CLK  : in std_logic;
         i_RST  : in std_logic;
         i_WE   : in std_logic;
         i_Din  : in std_logic_vector(WIDTH-1 downto 0);
         o_Dout : out std_logic_vector(WIDTH-1 downto 0));
end pc_reg;

architecture behavioral of pc_reg is

    signal s_Q : std_logic_vector(WIDTH-1 downto 0);

begin

    o_Dout <= s_Q;

    process (i_CLK, i_RST)
    begin
        if (i_RST = '1') then
            s_Q <= RST_VAL;
        elsif (rising_edge(i_CLK)) then
            if (i_WE = '1') then
                s_Q <= i_Din;
            end if;
        end if;
    end process;

end behavioral;
