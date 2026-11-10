library IEEE;
use IEEE.std_logic_1164.all;

entity IF_ID is
    generic(WIDTH : integer);
    port(i_CLK  : in std_logic;
         i_RST  : in std_logic;
         i_WE   : in std_logic;
         i_PC : in std_logic_vector(WIDTH-1 downto 0);
         i_PCplus4 : in std_logic_vector(WIDTH-1 downto 0);
         i_inst : in std_logic_vector(WIDTH-1 downto 0);
         o_PC : out std_logic_vector(WIDTH-1 downto 0);
         o_PCplus4 : out std_logic_vector(WIDTH-1 downto 0);
         o_inst : out std_logic_vector(WIDTH-1 downto 0));
end IF_ID;

architecture structural of IF_ID is
    component reg_n is
        generic(WIDTH : integer);
        port(i_CLK  : in std_logic;
             i_RST  : in std_logic;
             i_WE   : in std_logic;
             i_Din  : in std_logic_vector(WIDTH-1 downto 0);
             o_Dout : out std_logic_vector(WIDTH-1 downto 0));
    end component;

    begin
        REG_PC: reg_n generic map(WIDTH => WIDTH)
            port map(i_CLK, i_RST, i_WE, i_PC, o_PC);
        REG_PCPLUS4: reg_n generic map(WIDTH => WIDTH)
            port map(i_CLK, i_RST, i_WE, i_PCplus4, o_PCplus4);
        REG_INST: reg_n generic map(WIDTH => WIDTH)
            port map(i_CLK, i_RST, i_WE, i_inst, o_inst);
end structural;
