



library IEEE;
use IEEE.std_logic_1164.all;

entity reg_n is
    generic(WIDTH : integer);
    port(i_CLK  : in std_logic;
         i_RST  : in std_logic;
         i_WE   : in std_logic;
         i_Din  : in std_logic_vector(WIDTH-1 downto 0);
         o_Dout : out std_logic_vector(WIDTH-1 downto 0));
end reg_n;

architecture mixed of reg_n is

    component dffg is
        port(i_CLK        : in std_logic;     -- Clock input
             i_RST        : in std_logic;     -- Reset input
             i_WE         : in std_logic;     -- Write enable input
             i_D          : in std_logic;     -- Data value input
             o_Q          : out std_logic);   -- Data value output
    end component;
  
begin
    G_Nbit_DFF: for i in 0 to WIDTH - 1 generate
        DFFI: dffg
            port map(
                i_CLK => i_CLK,
                i_RST => i_RST,
                i_WE => i_WE,
                i_D => i_Din(i),
                o_Q => o_Dout(i)
            );
    end generate G_Nbit_DFF;
end mixed;

