library IEEE;
use IEEE.std_logic_1164.all;

entity EX is
    port(clk        : in std_logic;
         rst        : in std_logic;
         i_PC        : in std_logic_vector(31 downto 0);
         i_PC_4      : in std_logic_vector(31 downto 0);
         i_Imm       : in std_logic_vector(31 downto 0);
         i_rd1      : in std_logic_vector(31 downto 0);
         i_rd2      : in std_logic_vector(31 downto 0);
         i_inst     : in std_logic_vector(31 downto 0);
         i_halt      : in std_logic;
         i_RegWr    : in std_logic;
         i_andlink  : in std_logic;
         i_Mem2Reg  : in std_logic;
         i_MemRd     : in std_logic;
         i_DMemWr    : in std_logic;
         i_jumpreg   : in std_logic;
         i_jump     : in std_logic;
         i_branch   : in std_logic;
         i_alusrc   : in std_logic;
         i_alusrca  : in std_logic_vector(1 downto 0);
         i_aluop    : in std_logic_vector(1 downto 0);
         o_halt : out std_logic;
         o_RegWr : out std_logic;
         o_andlink : out std_logic;
         o_Mem2Reg : out std_logic;
         o_MemRd : out std_logic;
         o_DMemWr : out std_logic;
         o_jumpreg : out std_logic;
         o_jump : out std_logic;
         o_pcsrc : out std_logic;
         o_ALUout : out std_logic_vector(31 downto 0);
         o_add2out : out std_logic_vector(31 downto 0);
         o_rd2 : out std_logic_vector(31 downto 0);
         o_PCplus4 : out std_logic_vector(31 downto 0);
         o_inst : out std_logic_vector(31 downto 0));
end EX;

architecture structural of EX is
    component alu is
        generic(WIDTH : integer);
        port(i_A                : in std_logic_vector(WIDTH-1 downto 0);
            i_B                : in std_logic_vector(WIDTH-1 downto 0);
            AluCtrl            : in std_logic_vector(3 downto 0);
            zero               : out std_logic;
            AluOut             : out std_logic_vector(WIDTH-1 downto 0));
    end component;

    component aluctrlr is
        generic(WIDTH : integer);
        port(inst                : in std_logic_vector(WIDTH-1 downto 0);
            aluop                : in std_logic_vector(1 downto 0);
            Aluctrl             : out std_logic_vector(3 downto 0));
    end component;

    component mux2t1_n is
        generic(N : integer);
        port(i_S             : in std_logic;
            i_D0            : in std_logic_vector(N-1 downto 0);
            i_D1            : in std_logic_vector(N-1 downto 0);
            o_O             : out std_logic_vector(N-1 downto 0));
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

    component branch_logic is
        generic(WIDTH : integer := 32);
        port(i_A     : in  std_logic_vector(WIDTH-1 downto 0);
            i_B     : in  std_logic_vector(WIDTH-1 downto 0);
            funct3  : in  std_logic_vector(2 downto 0);
            Branch  : in  std_logic;
            Taken   : out std_logic);
    end component;

    component PC_Adder_N is
        generic(N : integer);
        port(i_Cin       : in std_logic;
            i_A         : in std_logic_vector(N-1 downto 0);
            i_B         : in std_logic_vector(N-1 downto 0);
            o_S         : out std_logic_vector(N-1 downto 0);
            o_Cout      : out std_logic);
    end component;

    signal s_AluCtrl : std_logic_vector(3 downto 0);
    signal s_aluA, s_aluB : std_logic_vector(31 downto 0);

begin
    G_ALUCTRL : aluctrlr
        generic map(WIDTH => 32)
        port map(inst => i_inst,
                 aluop => i_aluop,
                 Aluctrl => s_AluCtrl);
    G_MUX4T1_ALUA : mux4t1_n
        generic map(N => 32)
        port map(i_S => i_alusrca,
                 i_D0 => i_rd1,
                 i_D1 => i_PC,
                 i_D2 => (others => '0'),
                 i_D3 => (others => '0'),
                 o_O => s_aluA);
    G_MUX2T1_ALUB : mux2t1_n
        generic map(N => 32)
        port map(i_S => i_alusrc,
                 i_D0 => i_rd2,
                 i_D1 => i_Imm,
                 o_O => s_aluB);
    G_ALU : alu
        generic map(WIDTH => 32)
        port map(i_A => s_aluA,
                 i_B => s_aluB,
                 AluCtrl => s_AluCtrl,
                 zero => open,
                 AluOut => o_ALUout);
    G_ADDER2 : PC_Adder_N
        generic map(N => 32)
        port map(i_Cin => '0',
                 i_A => i_PC,
                 i_B => i_Imm,
                 o_S => o_add2out,
                 o_Cout => open);
    o_halt <= i_halt;
    o_RegWr <= i_RegWr;
    o_andlink <= i_andlink;
    o_Mem2Reg <= i_Mem2Reg;
    o_MemRd <= i_MemRd;
    o_DMemWr <= i_DMemWr;
    o_jumpreg <= i_jumpreg;
    o_jump <= i_jump;
    o_rd2 <= i_rd2;
    o_PCplus4 <= i_PC_4;
    o_inst <= i_inst;
    G_BRANCH_LOGIC : branch_logic
        generic map(WIDTH => 32)
        port map(i_A => i_rd1,
                 i_B => i_rd2,
                 funct3 => i_inst(14 downto 12),
                 Branch => i_branch,
                 Taken => o_pcsrc);
end structural;