library IEEE;
use IEEE.std_logic_1164.all;

entity LgcCtrlr is
  generic(N : integer); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_A          : in std_logic_vector(N-1 downto 0);
       i_B         : in std_logic_vector(N-1 downto 0);
       o_F          : out std_logic_vector(N-1 downto 0);
       sel         : in std_logic_vector(1 downto 0));

end LgcCtrlr;

architecture structural of LgcCtrlr is

    component andg_n is
        generic(N : integer); -- Generic of type integer for input/output data width. Default value is 32.
        port(i_A                  : in std_logic_vector(N-1 downto 0);
            i_B                 : in std_logic_vector(N-1 downto 0);
            o_F                  : out std_logic_vector(N-1 downto 0));
    end component;

    component org_n is
        generic(N : integer); -- Generic of type integer for input/output data width. Default value is 32.
        port(i_A                  : in std_logic_vector(N-1 downto 0);
            i_B                 : in std_logic_vector(N-1 downto 0);
            o_F                  : out std_logic_vector(N-1 downto 0));
    end component;

    component xorg_n is
        generic(N : integer); -- Generic of type integer for input/output data width. Default value is 32.
        port(i_A                  : in std_logic_vector(N-1 downto 0);
            i_B                 : in std_logic_vector(N-1 downto 0);
            o_F                  : out std_logic_vector(N-1 downto 0));
    end component;

    component norg_n is
        generic(N : integer); -- Generic of type integer for input/output data width. Default value is 32.
        port(i_A                  : in std_logic_vector(N-1 downto 0);
            i_B                 : in std_logic_vector(N-1 downto 0);
            o_F                  : out std_logic_vector(N-1 downto 0));
    end component;

    component mux4t1_n is
        generic(N : integer); -- Generic of type integer for input/output data width. Default value is 32.
        port(i_S          : in std_logic_vector(1 downto 0);
            i_D0         : in std_logic_vector(N-1 downto 0);
            i_D1         : in std_logic_vector(N-1 downto 0);
            i_D2         : in std_logic_vector(N-1 downto 0);
            i_D3         : in std_logic_vector(N-1 downto 0);
            o_O          : out std_logic_vector(N-1 downto 0));
    end component;

    signal s_and, s_or, s_xor, s_nor : std_logic_vector(N-1 downto 0);  

    begin
        g_and: andg_n generic map(N => N) port map(
            i_A      => i_A,      
            i_B     => i_B,  
            o_F      => s_and);
        g_or: org_n generic map(N => N) port map(
            i_A      => i_A,
            i_B     => i_B,  
            o_F      => s_or);
        g_xor: xorg_n generic map(N => N) port map(
            i_A      => i_A,
            i_B     => i_B,  
            o_F      => s_xor);
        g_nor: norg_n generic map(N => N) port map(
            i_A      => i_A,
            i_B     => i_B,
            o_F      => s_nor);
        g_mux: mux4t1_n generic map(N => N) port map(
            i_S      => sel,
            i_D0     => s_and,
            i_D1     => s_or,
            i_D2     => s_xor,
            i_D3     => s_nor,
            o_O      => o_F);

end structural;