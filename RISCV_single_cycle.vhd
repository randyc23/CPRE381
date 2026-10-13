library ieee;
use ieee.std_logic_1164.all;

entity RISCV_single_cycle is
    generic DATA_WIDTH : integer := 32;
    port(
        iCLK     : in std_logic;
        iRST     : in std_logic
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
        port(current_PC         : in std_logic_vector(N-1 downto 0);
            four         : in std_logic_vector(N-1 downto 0);
            immediate          : out std_logic_vector(N-1 downto 0);
            MemRead           : in std_logic;
            Zero              : in std_logic;
            PC_New          : out std_logic_vector(N-1 downto 0));
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
            be              : in std_logic_vector (3 downto 0);   -- 4 bytes per word
            we        : in std_logic := '1';
            q        : out std_logic_vector((DATA_WIDTH -1) downto 0)
        );
    end component;

    component imem is
        generic(
            ADDR_WIDTH : natural := 32;
            INSTR_WIDTH : natural := 32;
            BYTE_WIDTH : natural := 8
        );

        port(
            clk        : in std_logic;
            addr            : in std_logic_vector((ADDR_WIDTH-1) downto 0);
            data            : in std_logic_vector((INSTR_WIDTH-1) downto 0);
            be              : in std_logic_vector (3 downto 0);   -- 4 bytes per word
            q        : out std_logic_vector((INSTR_WIDTH -1) downto 0)
        );
    end component;

    component immgen is 
        generic(WIDTH : integer := 32);
        port (inst : std_logic_vector(WIDTH-1 downto 0);
              immediate : std_logic_vector(WIDTH-1 downto 0));
    end component;

    


