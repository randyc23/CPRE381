library IEEE;
use IEEE.std_logic_1164.all;

entity alu is
    generic(WIDTH : integer);
    port(i_A                : in std_logic_vector(WIDTH-1 downto 0);
         i_B                : in std_logic_vector(WIDTH-1 downto 0);
         AluCtrl            : in std_logic_vector(3 downto 0);
         zero               : out std_logic;
         AluOut             : out std_logic_vector(WIDTH-1 downto 0));
end alu;

architecture structural of alu is
    component add_sub_N is
        generic(WIDTH : integer);
        port(i_sub          : in std_logic;
             i_unsigned     : in std_logic;
             i_A            : in std_logic_vector(WIDTH-1 downto 0);
             i_B            : in std_logic_vector(WIDTH-1 downto 0);
             o_S            : out std_logic_vector(WIDTH-1 downto 0);
             less           : out std_logic_vector(WIDTH-1 downto 0));
    end component;

    component bidir_shift is
        generic(WIDTH : integer);
        port(shift            : in std_logic_vector(4 downto 0);
             arith            : in std_logic;
             direction        : in std_logic;
             Ip               : in std_logic_vector(WIDTH-1 downto 0);
             Shifted          : out std_logic_vector(WIDTH-1 downto 0));
    end component;

    component LgcCtrlr is
        generic(N : integer); -- Generic of type integer for input/output data width. Default value is 32.
        port(i_A          : in std_logic_vector(N-1 downto 0);
            i_B         : in std_logic_vector(N-1 downto 0);
            o_F          : out std_logic_vector(N-1 downto 0);
            sel         : in std_logic_vector(1 downto 0));
    end component;

    component mux4t1_n is 
        generic(N : integer);
        port(i_S             : in std_logic_vector(1 downto 0);
             i_D0            : in std_logic_vector(N-1 downto 0);
             i_D1            : in std_logic_vector(N-1 downto 0);
             i_D2            : in std_logic_vector(N-1 downto 0);
             i_D3            : in std_logic_vector(N-1 downto 0);
             o_O             : out std_logic_vector(N-1 downto 0));
    end component;
    
    component andg2 is
        port(i_A                  : in std_logic;
             i_B                 : in std_logic;
             o_F                  : out std_logic);
    end component;

    component xorg2 is
        port(i_A                  : in std_logic;
             i_B                 : in std_logic;
             o_F                  : out std_logic);
    end component;
    component org2 is
        port(i_A                  : in std_logic;
             i_B                 : in std_logic;
             o_F                  : out std_logic);
    end component;
    component invg is
        port(i_A                  : in std_logic;
             o_F                  : out std_logic);
    end component;

    
    
    signal add_sub_out : std_logic_vector(WIDTH-1 downto 0);
    signal less_out : std_logic_vector(WIDTH-1 downto 0);
    signal logic_ctrl_out : std_logic_vector(WIDTH-1 downto 0);
    signal shift_out : std_logic_vector(WIDTH-1 downto 0);
    signal shift_arith : std_logic;
    signal s_diff : std_logic_vector(WIDTH-1 downto 0);
    signal s_or : std_logic_vector(WIDTH-1 downto 0);


begin
    G_ADD_SUB: add_sub_N
        generic map(WIDTH => WIDTH)
        port map(i_sub => AluCtrl(0),
                 i_unsigned => AluCtrl(1),
                 i_A => i_A,
                 i_B => i_B,
                 o_S => add_sub_out,
                 less => less_out);

    G_LOGIC_CTRL: LgcCtrlr
        generic map(N => WIDTH)
        port map(i_A => i_A,
                 i_B => i_B,
                 sel => AluCtrl(1 downto 0),
                 o_F => logic_ctrl_out);

    G_ARITH: andg2 port map(i_A => AluCtrl(1), i_B => AluCtrl(0), o_F => shift_arith); -- ensure arith = 1 only for sra/srai and sla/slai never happens
                
    G_BIDIR_SHIFT: bidir_shift
        generic map(WIDTH => WIDTH)
        port map(shift => i_B(4 downto 0),
                 arith => shift_arith,
                 direction => AluCtrl(0),
                 Ip => i_A,
                 Shifted => shift_out);
    G_MUX: mux4t1_n
        generic map(N => WIDTH)
        port map(i_S => AluCtrl(3 downto 2),
                 i_D0 => add_sub_out,
                 i_D1 => less_out,
                 i_D2 => logic_ctrl_out,
                 i_D3 => shift_out,
                 o_O => AluOut);

    G_DIFF: for i in 0 to WIDTH-1 generate
        XORI: xorg2 port map(i_A => i_A(i), i_B => i_B(i), o_F => s_diff(i));
    end generate G_DIFF;

    s_or(0) <= s_diff(0);
    G_OR_CHAIN: for i in 1 to WIDTH-1 generate
        ORI: org2 port map(i_A => s_or(i-1), i_B => s_diff(i), o_F => s_or(i));
    end generate G_OR_CHAIN;

    G_ZERO: invg port map(i_A => s_or(WIDTH-1), o_F => zero);

end structural;