library IEEE;
use IEEE.std_logic_1164.all;

entity reg_n_sf is
    generic(WIDTH     : integer;
            FLUSH_VAL : std_logic_vector(WIDTH-1 downto 0) := (others => '0'));
    port(i_CLK   : in std_logic;
         i_RST   : in std_logic;
         i_stall : in std_logic;
         i_flush : in std_logic;
         i_Din   : in std_logic_vector(WIDTH-1 downto 0);
         o_Dout  : out std_logic_vector(WIDTH-1 downto 0));
end reg_n_sf;

architecture structural of reg_n_sf is

    component reg_n is
        generic(WIDTH : integer);
        port(i_CLK  : in std_logic;
             i_RST  : in std_logic;
             i_WE   : in std_logic;
             i_Din  : in std_logic_vector(WIDTH-1 downto 0);
             o_Dout : out std_logic_vector(WIDTH-1 downto 0));
    end component;

    component mux2t1_N is
        generic(N : integer);
        port(i_S  : in std_logic;
             i_D0 : in std_logic_vector(N-1 downto 0);
             i_D1 : in std_logic_vector(N-1 downto 0);
             o_O  : out std_logic_vector(N-1 downto 0));
    end component;

    component invg is
        port(i_A : in std_logic;
             o_F : out std_logic);
    end component;

    component org2 is
        port(i_A : in std_logic;
             i_B : in std_logic;
             o_F : out std_logic);
    end component;

    signal s_nstall : std_logic;
    signal s_WE     : std_logic;
    signal s_D      : std_logic_vector(WIDTH-1 downto 0);

begin

    G_NSTALL: invg port map(i_A => i_stall, o_F => s_nstall);
    G_WE: org2 port map(i_A => s_nstall, i_B => i_flush, o_F => s_WE);
    G_FLUSH_MUX: mux2t1_N generic map(N => WIDTH)
        port map(i_S => i_flush, i_D0 => i_Din, i_D1 => FLUSH_VAL, o_O => s_D);
    REG: reg_n generic map(WIDTH => WIDTH)
        port map(i_CLK => i_CLK, i_RST => i_RST, i_WE => s_WE, i_Din => s_D, o_Dout => o_Dout);

end structural;
