library IEEE;
use IEEE.std_logic_1164.all;

entity M is
    generic (
        DATA_WIDTH : natural := 32
    );
    port (clk : in std_logic;
          rst : in std_logic;
          i_halt : in std_logic;
          i_RegWr : in std_logic;
          i_andlink : in std_logic;
          i_Mem2Reg : in std_logic;
          i_MemRd : in std_logic;
          i_DMemWr : in std_logic;
          i_jumpreg : in std_logic;
          i_jump : in std_logic;
          i_pcsrc : in std_logic;
          i_PCplus4 : in std_logic_vector((DATA_WIDTH-1) downto 0);
          i_ALUout : in std_logic_vector((DATA_WIDTH-1) downto 0);
          i_rd2 : in std_logic_vector((DATA_WIDTH-1) downto 0);
          i_inst : in std_logic_vector((DATA_WIDTH-1) downto 0);
          i_DMemOut : in std_logic_vector((DATA_WIDTH-1) downto 0);
          o_DMemWr : out std_logic;
          o_DMemAddr : out std_logic_vector((DATA_WIDTH-1) downto 0);
          o_DMemData : out std_logic_vector((DATA_WIDTH-1) downto 0);
          o_DMemBE : out std_logic_vector(3 downto 0);
          o_halt : out std_logic;
          o_RegWr : out std_logic;
          o_andlink : out std_logic;
          o_Mem2Reg : out std_logic;
          o_jumpreg : out std_logic;
          o_jump : out std_logic;
          o_pcsrc : out std_logic;
          o_PCplus4 : out std_logic_vector((DATA_WIDTH-1) downto 0);
          o_ALUout : out std_logic_vector((DATA_WIDTH-1) downto 0);
          o_inst : out std_logic_vector((DATA_WIDTH-1) downto 0);
          o_Ld_Data : out std_logic_vector((DATA_WIDTH-1) downto 0));
end M;

architecture structural of M is
    component store_ext is
        port(i_data  : in  std_logic_vector(31 downto 0);
            addr    : in  std_logic_vector(1 downto 0);
            funct3  : in  std_logic_vector(2 downto 0);
            o_data  : out std_logic_vector(31 downto 0);
            o_be    : out std_logic_vector(3 downto 0));
    end component;

    component load_ext is
        port(i_data  : in  std_logic_vector(31 downto 0);
            addr    : in  std_logic_vector(1 downto 0);
            funct3  : in  std_logic_vector(2 downto 0);
            o_data  : out std_logic_vector(31 downto 0));
    end component;

begin
    GSTORE : store_ext
        port map (
            i_data => i_rd2,
            addr => i_ALUout(1 downto 0),
            funct3 => i_inst(14 downto 12),
            o_data => o_DMemData,
            o_be => o_DMemBE
        );

    GLOAD : load_ext
        port map (
            i_data => i_DMemOut,
            addr => i_ALUout(1 downto 0),
            funct3 => i_inst(14 downto 12),
            o_data => o_Ld_Data
        );
    o_DMemWr <= i_DMemWr;
    o_DMemAddr <= i_ALUout;
    o_halt <= i_halt;
    o_RegWr <= i_RegWr;
    o_andlink <= i_andlink;
    o_Mem2Reg <= i_Mem2Reg;
    o_ALUout <= i_ALUout;
    o_jumpreg <= i_jumpreg;
    o_jump <= i_jump;
    o_pcsrc <= i_pcsrc;
    o_PCplus4 <= i_PCplus4;
    o_inst <= i_inst;
end structural;
