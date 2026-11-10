library IEEE;
use IEEE.std_logic_1164.all;

entity ID is
    generic(DATAWIDTH : natural := 32);
    port(
        clk : in std_logic;
        rst : in std_logic;
        i_inst : in std_logic_vector((DATAWIDTH-1) downto 0);
        i_PC : in std_logic_vector((DATAWIDTH-1) downto 0);
        i_PCplus4 : in std_logic_vector((DATAWIDTH-1) downto 0);
        i_RegWr_WB : in std_logic;
        i_RegWrAddr_WB : in std_logic_vector(4 downto 0);
        i_RegWrData_WB : in std_logic_vector(DATAWIDTH-1 downto 0);
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
        o_rd1 : out std_logic_vector(DATAWIDTH-1 downto 0);
        o_rd2 : out std_logic_vector(DATAWIDTH-1 downto 0);
        o_immgen : out std_logic_vector(DATAWIDTH-1 downto 0);
        o_PC : out std_logic_vector(DATAWIDTH-1 downto 0);
        o_PCplus4 : out std_logic_vector(DATAWIDTH-1 downto 0);
        o_inst : out std_logic_vector(DATAWIDTH-1 downto 0));
end ID;

architecture structural of ID is
    component regfile is
        generic(WR_SEL     : integer;
                RD_SEL     : integer;
                DATA_WIDTH : integer;
                NUM_REG    : integer);
        port(iCLK     : in std_logic;
             iRST     : in std_logic;
             iWE      : in std_logic;
             wraddr   : in std_logic_vector(WR_SEL - 1 downto 0);
             rs1      : in std_logic_vector(RD_SEL - 1 downto 0);
             rs2      : in std_logic_vector(RD_SEL - 1 downto 0);
             i_Din    : in std_logic_vector(DATA_WIDTH - 1 downto 0);
             read1    : out std_logic_vector(DATA_WIDTH - 1 downto 0);
             read2    : out std_logic_vector(DATA_WIDTH - 1 downto 0));
    end component;

    component immgen is
        port (
            inst      : in  std_logic_vector(31 downto 0);
            immediate : out std_logic_vector(31 downto 0)
        );
    end component;

    component control_unit is
    port(inst       : in  std_logic_vector(31 downto 0);
         ALUOp      : out std_logic_vector(1 downto 0);
         ALUSrcA    : out std_logic_vector(1 downto 0);
         ALUSrc     : out std_logic;
         RegWrite   : out std_logic;
         MemRead    : out std_logic;
         MemWrite   : out std_logic;
         MemtoReg   : out std_logic;
         AndLink    : out std_logic;
         Branch     : out std_logic;
         Jump       : out std_logic;
         JumpReg    : out std_logic;
         Halt       : out std_logic);
    end component;

    component invg is
        port(i_A : in std_logic;
             o_F : out std_logic);
    end component;

    signal s_RegClk : std_logic;

begin

    G_REG_CLK : invg port map(i_A => clk, o_F => s_RegClk);

    G_REG_FILE : regfile
        generic map(WR_SEL => 5,
                    RD_SEL => 5,
                    DATA_WIDTH => DATAWIDTH,
                    NUM_REG => 32)
        port map(iCLK => s_RegClk,
                  iRST => rst,
                  iWE => i_RegWr_WB,
                  wraddr => i_RegWrAddr_WB(4 downto 0),
                  i_Din => i_RegWrData_WB,
                  rs1 => i_inst(19 downto 15),
                  rs2 => i_inst(24 downto 20),
                  read1 => o_rd1,
                  read2 => o_rd2);
    G_IMM_GEN : immgen port map(inst => i_inst, immediate => o_immgen);

    G_CONTROL_UNIT : control_unit port map(inst => i_inst,
                                           ALUOp => o_aluop,
                                           ALUSrcA => o_alusrca,
                                           ALUSrc => o_alusrc,
                                           RegWrite => o_RegWr,
                                           MemRead => o_MemRd,
                                           MemWrite => o_DMemWr,
                                           MemtoReg => o_Mem2Reg,
                                           AndLink => o_andlink,
                                           Branch => o_branch,
                                           Jump => o_jump,
                                           JumpReg => o_jumpreg,
                                           Halt => o_halt);
    o_inst <= i_inst;
    o_PC <= i_PC;
    o_PCplus4 <= i_PCplus4;

end structural;




