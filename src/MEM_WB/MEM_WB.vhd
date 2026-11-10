library IEEE;
use IEEE.std_logic_1164.all;

entity MEM_WB is
    generic(WIDTH : integer);
    port(i_CLK  : in std_logic;
         i_RST  : in std_logic;
         i_WE   : in std_logic;
         i_halt : in std_logic;
         i_RegWr : in std_logic;
         i_andlink : in std_logic;
         i_Mem2Reg : in std_logic;
         i_ALUout : in std_logic_vector(WIDTH-1 downto 0);
         i_inst : in std_logic_vector(WIDTH-1 downto 0);
         i_DataLd : in std_logic_vector(WIDTH-1 downto 0);
         i_PCplus4 : in std_logic_vector(WIDTH-1 downto 0);
         o_halt : out std_logic;
         o_RegWr : out std_logic;
         o_andlink : out std_logic;
         o_Mem2Reg : out std_logic;
         o_ALUout : out std_logic_vector(WIDTH-1 downto 0);
         o_DataLd : out std_logic_vector(WIDTH-1 downto 0);
         o_PCplus4 : out std_logic_vector(WIDTH-1 downto 0);
         o_inst : out std_logic_vector(WIDTH-1 downto 0));
end MEM_WB;

architecture structural of MEM_WB is
    component reg_n is
        generic(WIDTH : integer);
        port(i_CLK  : in std_logic;
             i_RST  : in std_logic;
             i_WE   : in std_logic;
             i_Din  : in std_logic_vector(WIDTH-1 downto 0);
             o_Dout : out std_logic_vector(WIDTH-1 downto 0));
    end component;

    component dffg is
        port(i_CLK  : in std_logic;
             i_RST  : in std_logic;
             i_WE   : in std_logic;
             i_D    : in std_logic;
             o_Q    : out std_logic);
    end component;

    begin
        DFF_HALT: dffg port map(i_CLK => i_CLK, i_RST => i_RST, i_WE => i_WE, i_D => i_halt, o_Q => o_halt);
        DFF_REGWR: dffg port map(i_CLK, i_RST, i_WE, i_RegWr, o_RegWr);
        DFF_ANDLINK: dffg port map(i_CLK, i_RST, i_WE, i_andlink, o_andlink);
        DFF_MEM2REG: dffg port map(i_CLK, i_RST, i_WE, i_Mem2Reg, o_Mem2Reg);
        REG_ALUOUT: reg_n generic map(WIDTH => WIDTH)
            port map(i_CLK, i_RST, i_WE, i_ALUout, o_ALUout);
        REG_DATA_LD: reg_n generic map(WIDTH => WIDTH)
            port map(i_CLK, i_RST, i_WE, i_DataLd, o_DataLd);
        REG_PCPLUS4: reg_n generic map(WIDTH => WIDTH)
            port map(i_CLK, i_RST, i_WE, i_PCplus4, o_PCplus4);
        REG_INST: reg_n generic map(WIDTH => WIDTH)
            port map(i_CLK, i_RST, i_WE, i_inst, o_inst);
end structural;