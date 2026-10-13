library IEEE;
use IEEE.std_logic_1164.all;
use work.mux_arr.all;


entity regfile is
    generic(
        WR_SEL  : integer;
        RD_SEL  : integer;
        DATA_WIDTH   : integer;
        NUM_REG : integer
    );
    port(
        iCLK     : in std_logic;
        iRST     : in std_logic;
        iWE      : in std_logic;
        wr_sele   : in std_logic_vector(WR_SEL - 1 downto 0);
        rd_sel1  : in std_logic_vector(RD_SEL - 1 downto 0);
        rd_sel2  : in std_logic_vector(RD_SEL - 1 downto 0);
        i_Din    : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        o_Dout1  : out std_logic_vector(DATA_WIDTH - 1 downto 0);
        o_Dout2  : out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
end regfile;

architecture structural of regfile is

    component reg_n is
        generic(WIDTH : integer := DATA_WIDTH);
        port(i_CLK  : in std_logic;
            i_RST  : in std_logic;
            i_WE   : in std_logic;
            i_Din  : in std_logic_vector(WIDTH-1 downto 0);
            o_Dout : out std_logic_vector(WIDTH-1 downto 0));
    end component;

    component dcdr5t32 is
            generic(
            WIDTH_IN : integer := WR_SEL;
            WIDTH_OUT: integer := NUM_REG
        );
        port(
            i_we  : in std_logic;
            i_sel : in std_logic_vector(WIDTH_IN - 1 downto 0);
            o_out : out std_logic_vector(WIDTH_OUT - 1 downto 0)
        );
    end component;

    component mux32t1_n is
            generic(N : integer := NUM_REG;
            WIDTH: integer := DATA_WIDTH;
            SEL: integer := RD_SEL); -- Generic of type integer for input/output data width. Default value is 32.
    port(i_SEL        : in std_logic_vector(SEL - 1 downto 0);
        i_array      : in vector_array(N-1 downto 0)(WIDTH - 1 downto 0);
        o_O          : out std_logic_vector(WIDTH-1 downto 0));

    end component;

    signal s_wr_reg : std_logic_vector(NUM_REG - 1 downto 0);
    signal all_reg_out : vector_array(NUM_REG - 1 downto 0)(DATA_WIDTH - 1 downto 0);
     

begin

    G_DCDR: dcdr5t32
        generic map(
            WIDTH_IN => WR_SEL,
            WIDTH_OUT => NUM_REG)
        port map(
            i_we => iWE,
            i_sel => wr_sele,
            o_out => s_wr_reg);

    G_N_REG: for i in 0 to NUM_REG - 1 generate
        GEN_NORMAL_REG: if i /= 0 generate
            REG_Ni: reg_n
                port map(
                    i_CLK => iCLK,
                    i_RST => iRST,
                    i_WE => s_wr_reg(i),
                    i_Din => i_Din,
                    o_Dout => all_reg_out(i)
                );
        end generate GEN_NORMAL_REG;

        GEN_X0_REG: if i = 0 generate
            all_reg_out(0) <= (others => '0');
        end generate GEN_X0_REG;
    end generate G_N_REG;
    G_32bmux32t1_A: mux32t1_n
        generic map(
            N => NUM_REG,
            WIDTH => DATA_WIDTH,
            SEL => RD_SEL
        )
        port map(
            i_SEL => rd_sel1,
            i_array => all_reg_out,
            o_O => o_Dout1
        );
    G_32bmux32t1_B: mux32t1_n
        generic map(
            N => NUM_REG,
            WIDTH => DATA_WIDTH,
            SEL => RD_SEL
        )
        port map(
            i_SEL => rd_sel2,
            i_array => all_reg_out,
            o_O => o_Dout2
        );
end structural;