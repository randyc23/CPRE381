library IEEE;
use IEEE.std_logic_1164.all;

entity dffg_sf is
    generic(FLUSH_VAL : std_logic := '0');
    port(i_CLK   : in std_logic;
         i_RST   : in std_logic;
         i_stall : in std_logic;
         i_flush : in std_logic;
         i_D     : in std_logic;
         o_Q     : out std_logic);
end dffg_sf;

architecture structural of dffg_sf is

    component dffg is
        port(i_CLK : in std_logic;
             i_RST : in std_logic;
             i_WE  : in std_logic;
             i_D   : in std_logic;
             o_Q   : out std_logic);
    end component;

    component mux2t1 is
        port(s0 : in std_logic;
             iA : in std_logic;
             iB : in std_logic;
             oC : out std_logic);
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
    signal s_D      : std_logic;

begin

    G_NSTALL: invg port map(i_A => i_stall, o_F => s_nstall);
    G_WE: org2 port map(i_A => s_nstall, i_B => i_flush, o_F => s_WE);
    G_FLUSH_MUX: mux2t1 port map(s0 => i_flush, iA => i_D, iB => FLUSH_VAL, oC => s_D);
    DFF: dffg port map(i_CLK => i_CLK, i_RST => i_RST, i_WE => s_WE, i_D => s_D, o_Q => o_Q);

end structural;
