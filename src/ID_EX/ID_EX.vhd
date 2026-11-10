library IEEE;
use IEEE.std_logic_1164.all;

entity ID_EX is
    generic(WIDTH : integer);
    port(i_CLK  : in std_logic;
         i_RST  : in std_logic;
         i_WE   : in std_logic;
         i_halt : in std_logic;
         i_RegWr : in std_logic;
         i_andlink : in std_logic;
         i_Mem2Reg : in std_logic;
         i_MemRd : in std_logic;
         i_DMemWr : in std_logic;
         i_jumpreg : in std_logic;
         i_jump : in std_logic;
         i_branch : in std_logic;
         i_alusrc : in std_logic;
         i_alusrca : in std_logic_vector(1 downto 0);
         i_aluop : in std_logic_vector(1 downto 0);
         i_rd1 : in std_logic_vector(WIDTH-1 downto 0);
         i_rd2 : in std_logic_vector(WIDTH-1 downto 0);
         i_immgen : in std_logic_vector(WIDTH-1 downto 0);
         i_PC : in std_logic_vector(WIDTH-1 downto 0);
         i_PCplus4 : in std_logic_vector(WIDTH-1 downto 0);
         i_inst : in std_logic_vector(WIDTH-1 downto 0);
         o_halt : out std_logic;
         o_RegWr : out std_logic;
         o_andlink : out std_logic;
         o_Mem2Reg : out std_logic;
         o_MemRd : out std_logic;
         o_DMemWr : out std_logic;
         o_jumpreg : out std_logic;
         o_jump : out std_logic;
         o_branch : out std_logic;
         o_alusrc : out std_logic;
         o_alusrca : out std_logic_vector(1 downto 0);
         o_aluop : out std_logic_vector(1 downto 0);
         o_rd1 : out std_logic_vector(WIDTH-1 downto 0);
         o_rd2 : out std_logic_vector(WIDTH-1 downto 0);
         o_immgen : out std_logic_vector(WIDTH-1 downto 0);
         o_PC : out std_logic_vector(WIDTH-1 downto 0);
         o_PCplus4 : out std_logic_vector(WIDTH-1 downto 0);
         o_inst : out std_logic_vector(WIDTH-1 downto 0));
end ID_EX;

architecture structural of ID_EX is
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
        DFF_MEMRD: dffg port map(i_CLK, i_RST, i_WE, i_MemRd, o_MemRd);
        DFF_DMEMWR: dffg port map(i_CLK, i_RST, i_WE, i_DMemWr, o_DMemWr);
        DFF_JUMPREG: dffg port map(i_CLK, i_RST, i_WE, i_jumpreg, o_jumpreg);
        DFF_JUMP: dffg port map(i_CLK, i_RST, i_WE, i_jump, o_jump);
        DFF_BRANCH: dffg port map(i_CLK, i_RST, i_WE, i_branch, o_branch);
        DFF_ALUSRC: dffg port map(i_CLK, i_RST, i_WE, i_alusrc, o_alusrc);
        REG_ALUSRCA: reg_n generic map(WIDTH => 2)
            port map(i_CLK, i_RST, i_WE, i_alusrca, o_alusrca);
        REG_ALUOP: reg_n generic map(WIDTH => 2)
            port map(i_CLK, i_RST, i_WE, i_aluop, o_aluop);
        REG_RD1: reg_n generic map(WIDTH => WIDTH)
            port map(i_CLK, i_RST, i_WE, i_rd1, o_rd1);
        REG_RD2: reg_n generic map(WIDTH => WIDTH)
            port map(i_CLK, i_RST, i_WE, i_rd2, o_rd2);
        REG_IMMGEN: reg_n generic map(WIDTH => WIDTH)
            port map(i_CLK, i_RST, i_WE, i_immgen, o_immgen);
        REG_PC: reg_n generic map(WIDTH => WIDTH)
            port map(i_CLK, i_RST, i_WE, i_PC, o_PC);
        REG_PCPLUS4: reg_n generic map(WIDTH => WIDTH)
            port map(i_CLK, i_RST, i_WE, i_PCplus4, o_PCplus4);
        REG_INST: reg_n generic map(WIDTH => WIDTH)
            port map(i_CLK, i_RST, i_WE, i_inst, o_inst);
end structural;