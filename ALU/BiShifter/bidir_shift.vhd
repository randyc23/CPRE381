library IEEE;
use IEEE.std_logic_1164.all;

entity bidir_shift is
    generic(WIDTH : integer);
    port(shift            : in std_logic_vector(4 downto 0);
         arith            : in std_logic;
         direction        : in std_logic;
         Ip               : in std_logic_vector(WIDTH-1 downto 0);
         Shifted          : out std_logic_vector(WIDTH-1 downto 0));

end bidir_shift;

architecture structural of bidir_shift is
    component shift16 is
        generic(WIDTH : integer);
        port(shift            : in std_logic;
             fill             : in std_logic;
             Ip               : in std_logic_vector(WIDTH-1 downto 0);
             Shifted          : out std_logic_vector(WIDTH-1 downto 0));
    end component;

    component shift8 is
        generic(WIDTH : integer);
        port(shift            : in std_logic;
             fill             : in std_logic;
             Ip               : in std_logic_vector(WIDTH-1 downto 0);
             Shifted          : out std_logic_vector(WIDTH-1 downto 0));
    end component;

    component shift4 is
        generic(WIDTH : integer);
        port(shift            : in std_logic;
             fill             : in std_logic;
             Ip               : in std_logic_vector(WIDTH-1 downto 0);
             Shifted          : out std_logic_vector(WIDTH-1 downto 0));
    end component;

    component shift2 is
        generic(WIDTH : integer);
        port(shift            : in std_logic;
             fill             : in std_logic;
             Ip               : in std_logic_vector(WIDTH-1 downto 0);
             Shifted          : out std_logic_vector(WIDTH-1 downto 0));
    end component;

    component shift1 is
        generic(WIDTH : integer);
        port(shift            : in std_logic;
             fill             : in std_logic;
             Ip               : in std_logic_vector(WIDTH-1 downto 0);
             Shifted          : out std_logic_vector(WIDTH-1 downto 0));
    end component;

    component fill_logic is
        port(arith             : in std_logic;
             sign_bit          : in std_logic;
             bit_fill           : out std_logic);
    end component;
    
    component rev_mux is
        generic(WIDTH : integer);
        port(dir            : in std_logic;
             d_in           : in std_logic_vector(WIDTH-1 downto 0);
             d_rev          : out std_logic_vector(WIDTH-1 downto 0));
    end component;


    signal rev1, shifted1, shifted2, shifted3, shifted4, rev_shift : std_logic_vector(WIDTH-1 downto 0);
    signal fill_bit                    : std_logic;

    begin

    g_fill: fill_logic
        port map(arith => arith,
                 sign_bit => Ip(WIDTH-1),
                 bit_fill => fill_bit);
    
    g_rev: rev_mux
        generic map(WIDTH => WIDTH)
        port map(dir => direction,
                 d_in => Ip,
                 d_rev => rev1);

    g_shift1: shift1
        generic map(WIDTH => WIDTH)
        port map(shift => shift(0),
                 fill => fill_bit,
                 Ip => rev1,
                 Shifted => shifted1);
    g_shift2: shift2
        generic map(WIDTH => WIDTH)
        port map(shift => shift(1),
                 fill => fill_bit,
                 Ip => shifted1,
                 Shifted => shifted2);
    g_shift3: shift4
        generic map(WIDTH => WIDTH)
        port map(shift => shift(2),
                 fill => fill_bit,
                 Ip => shifted2,
                 Shifted => shifted3);
    g_shift4: shift8
        generic map(WIDTH => WIDTH)
        port map(shift => shift(3),
                 fill => fill_bit,
                 Ip => shifted3,
                 Shifted => shifted4);
    g_shift5: shift16
        generic map(WIDTH => WIDTH)
        port map(shift => shift(4),
                 fill => fill_bit,
                 Ip => shifted4,
                 Shifted => rev_shift);
    g_rev2: rev_mux
        generic map(WIDTH => WIDTH)
        port map(dir => direction,
                 d_in => rev_shift,
                 d_rev => Shifted);
end structural;