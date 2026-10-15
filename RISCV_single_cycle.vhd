library ieee;
use ieee.std_logic_1164.all;

entity RISCV_single_cycle is
    generic(DATA_WIDTH : integer := 32);
    port(
        iCLK     : in std_logic;
        iRST     : in std_logic;
        oHalt    : out std_logic
    );
end RISCV_single_cycle;

architecture structural of RISCV_single_cycle is

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

    component Fetch_Control is
        generic(N : integer);
        port(current_PC        : in std_logic_vector(N-1 downto 0);
            four               : in std_logic_vector(N-1 downto 0);
            immediate          : in std_logic_vector(N-1 downto 0);
            ALU_Result         : in std_logic_vector(N-1 downto 0);
            PCSrc              : in std_logic;
            Jump               : in std_logic;
            JumpReg            : in std_logic;
            PC_Plus4           : out std_logic_vector(N-1 downto 0);
            PC_New             : out std_logic_vector(N-1 downto 0));
    end component;

    component pc_reg is
        generic(WIDTH : integer);
        port(i_CLK  : in std_logic;
            i_RST  : in std_logic;
            i_WE   : in std_logic;
            i_Din  : in std_logic_vector(WIDTH-1 downto 0);
            o_Dout : out std_logic_vector(WIDTH-1 downto 0));
    end component;

    component regfile is
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
            wraddr   : in std_logic_vector(WR_SEL - 1 downto 0);
            rs1  : in std_logic_vector(RD_SEL - 1 downto 0);
            rs2  : in std_logic_vector(RD_SEL - 1 downto 0);
            i_Din    : in std_logic_vector(DATA_WIDTH - 1 downto 0);
            read1  : out std_logic_vector(DATA_WIDTH - 1 downto 0);
            read2  : out std_logic_vector(DATA_WIDTH - 1 downto 0)
        );
    end component;

    component mem is
        generic (
            DATA_WIDTH : natural := 32;
            ADDR_WIDTH : natural := 10;
            BYTE_WIDTH : natural := 8
        );
        port (
            clk        : in std_logic;
            addr            : in std_logic_vector((ADDR_WIDTH-1) downto 0);
            data            : in std_logic_vector((DATA_WIDTH-1) downto 0);
            be              : in std_logic_vector (3 downto 0);
            we        : in std_logic := '1';
            q        : out std_logic_vector((DATA_WIDTH -1) downto 0)
        );
    end component;

    component imem is
        generic(
            ADDR_WIDTH : natural := 10;
            INSTR_WIDTH : natural := 32;
            BYTE_WIDTH : natural := 8
        );
        port(
            clk        : in std_logic;
            addr            : in std_logic_vector((ADDR_WIDTH-1) downto 0);
            data            : in std_logic_vector((INSTR_WIDTH-1) downto 0);
            be              : in std_logic_vector (3 downto 0);
            we        : in std_logic := '0';
            q        : out std_logic_vector((INSTR_WIDTH -1) downto 0)
        );
    end component;

    component immgen is
        port (inst      : in  std_logic_vector(31 downto 0);
              immediate : out std_logic_vector(31 downto 0));
    end component;

    component mux2t1_N is
        generic(N : integer);
        port(i_S          : in std_logic;
             i_D0         : in std_logic_vector(N-1 downto 0);
             i_D1         : in std_logic_vector(N-1 downto 0);
             o_O          : out std_logic_vector(N-1 downto 0));
    end component;

    component mux4t1_N is
        generic(N : integer);
        port(i_S          : in std_logic_vector(1 downto 0);
             i_D0         : in std_logic_vector(N-1 downto 0);
             i_D1         : in std_logic_vector(N-1 downto 0);
             i_D2         : in std_logic_vector(N-1 downto 0);
             i_D3         : in std_logic_vector(N-1 downto 0);
             o_O          : out std_logic_vector(N-1 downto 0));
    end component;

    component invg is
        port(i_A          : in std_logic;
             o_F          : out std_logic);
    end component;

    component branch_logic is
        generic(WIDTH : integer := 32);
        port(i_A     : in  std_logic_vector(WIDTH-1 downto 0);
             i_B     : in  std_logic_vector(WIDTH-1 downto 0);
             funct3  : in  std_logic_vector(2 downto 0);
             Branch  : in  std_logic;
             Taken   : out std_logic);
    end component;

    component load_ext is
        port(i_data  : in  std_logic_vector(31 downto 0);
             addr    : in  std_logic_vector(1 downto 0);
             funct3  : in  std_logic_vector(2 downto 0);
             o_data  : out std_logic_vector(31 downto 0));
    end component;

    component store_ext is
        port(i_data  : in  std_logic_vector(31 downto 0);
             addr    : in  std_logic_vector(1 downto 0);
             funct3  : in  std_logic_vector(2 downto 0);
             o_data  : out std_logic_vector(31 downto 0);
             o_be    : out std_logic_vector(3 downto 0));
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

    constant ADDR_WIDTH : integer := 10;

    signal s_branch, s_memread, s_memtoreg, s_memwrite, s_alusrc, s_regwrite : std_logic;
    signal s_andlink, s_jump, s_jumpreg, s_halt : std_logic;
    signal s_aluop, s_alusrca : std_logic_vector(1 downto 0);
    signal s_aluctrl  : std_logic_vector(3 downto 0);
    signal s_be       : std_logic_vector(3 downto 0);

    signal s_zero, s_pcsrc, s_pc_we : std_logic;
    signal s_PCfetch, s_pc_out, s_pc_plus4, s_instr, s_read1, s_read2, s_immgen,
           s_aluA, s_aluB, s_aluresult, s_dmemrd, s_loaddata, s_storedata,
           s_mux2out, s_wrdata : std_logic_vector(DATA_WIDTH-1 downto 0);

begin

    G_PC_WE: invg
        port map(
            i_A => s_halt,
            o_F => s_pc_we);

    PC: pc_reg
        generic map(WIDTH => DATA_WIDTH)
        port map(
            i_CLK  => iCLK,
            i_RST  => iRST,
            i_WE   => s_pc_we,
            i_Din  => s_PCfetch,
            o_Dout => s_pc_out);

    IMEM_U: imem
        generic map(ADDR_WIDTH => ADDR_WIDTH, INSTR_WIDTH => DATA_WIDTH)
        port map(
            clk  => iCLK,
            addr => s_pc_out(ADDR_WIDTH+1 downto 2),
            data => (others => '0'),
            be   => "1111",
            we   => '0',
            q    => s_instr);

    FETCH: Fetch_Control
        generic map(N => DATA_WIDTH)
        port map(
            current_PC => s_pc_out,
            four       => x"00000004",
            immediate  => s_immgen,
            ALU_Result => s_aluresult,
            PCSrc      => s_pcsrc,
            Jump       => s_jump,
            JumpReg    => s_jumpreg,
            PC_Plus4   => s_pc_plus4,
            PC_New     => s_PCfetch);

    CONTROL: control_unit
        port map(
            inst     => s_instr,
            ALUOp    => s_aluop,
            ALUSrcA  => s_alusrca,
            ALUSrc   => s_alusrc,
            RegWrite => s_regwrite,
            MemRead  => s_memread,
            MemWrite => s_memwrite,
            MemtoReg => s_memtoreg,
            AndLink  => s_andlink,
            Branch   => s_branch,
            Jump     => s_jump,
            JumpReg  => s_jumpreg,
            Halt     => s_halt);

    oHalt <= s_halt;

    REGS: regfile
        generic map(
            WR_SEL     => 5,
            RD_SEL     => 5,
            DATA_WIDTH => DATA_WIDTH,
            NUM_REG    => 32)
        port map(
            iCLK   => iCLK,
            iRST   => iRST,
            iWE    => s_regwrite,
            wraddr => s_instr(11 downto 7),
            rs1    => s_instr(19 downto 15),
            rs2    => s_instr(24 downto 20),
            i_Din  => s_wrdata,
            read1  => s_read1,
            read2  => s_read2);

    IMM: immgen
        port map(
            inst      => s_instr,
            immediate => s_immgen);

    BRANCH_U: branch_logic
        generic map(WIDTH => DATA_WIDTH)
        port map(
            i_A    => s_read1,
            i_B    => s_read2,
            funct3 => s_instr(14 downto 12),
            Branch => s_branch,
            Taken  => s_pcsrc);

    ALU_CTRL: aluctrlr
        generic map(WIDTH => DATA_WIDTH)
        port map(
            inst    => s_instr,
            aluop   => s_aluop,
            Aluctrl => s_aluctrl);

    ALUSRCA_MUX: mux4t1_N
        generic map(N => DATA_WIDTH)
        port map(
            i_S  => s_alusrca,
            i_D0 => s_read1,
            i_D1 => s_pc_out,
            i_D2 => (others => '0'),
            i_D3 => (others => '0'),
            o_O  => s_aluA);

    ALUSRC_MUX: mux2t1_N
        generic map(N => DATA_WIDTH)
        port map(
            i_S  => s_alusrc,
            i_D0 => s_read2,
            i_D1 => s_immgen,
            o_O  => s_aluB);

    ALU_U: alu
        generic map(WIDTH => DATA_WIDTH)
        port map(
            i_A     => s_aluA,
            i_B     => s_aluB,
            AluCtrl => s_aluctrl,
            zero    => s_zero,
            AluOut  => s_aluresult);

    STORE_U: store_ext
        port map(
            i_data => s_read2,
            addr   => s_aluresult(1 downto 0),
            funct3 => s_instr(14 downto 12),
            o_data => s_storedata,
            o_be   => s_be);

    DMEM: mem
        generic map(DATA_WIDTH => DATA_WIDTH, ADDR_WIDTH => ADDR_WIDTH)
        port map(
            clk  => iCLK,
            addr => s_aluresult(ADDR_WIDTH+1 downto 2),
            data => s_storedata,
            be   => s_be,
            we   => s_memwrite,
            q    => s_dmemrd);

    LOAD_U: load_ext
        port map(
            i_data => s_dmemrd,
            addr   => s_aluresult(1 downto 0),
            funct3 => s_instr(14 downto 12),
            o_data => s_loaddata);

    MEMTOREG_MUX: mux2t1_N
        generic map(N => DATA_WIDTH)
        port map(
            i_S  => s_memtoreg,
            i_D0 => s_aluresult,
            i_D1 => s_loaddata,
            o_O  => s_mux2out);

    LINK_MUX: mux2t1_N
        generic map(N => DATA_WIDTH)
        port map(
            i_S  => s_andlink,
            i_D0 => s_mux2out,
            i_D1 => s_pc_plus4,
            o_O  => s_wrdata);

end structural;
