library IEEE;
use IEEE.std_logic_1164.all;

entity hazard_detection is
    port(i_inst_ID     : in std_logic_vector(31 downto 0);
         i_MemRd_EX    : in std_logic;
         i_rd_EX       : in std_logic_vector(4 downto 0);
         i_pcsrc_EX    : in std_logic;
         i_jump_EX     : in std_logic;
         i_jumpreg_EX  : in std_logic;
         o_PC_stall    : out std_logic;
         o_IF_ID_stall : out std_logic;
         o_IF_ID_flush : out std_logic;
         o_ID_EX_flush : out std_logic;
         o_load_use    : out std_logic;
         o_ctrl_taken  : out std_logic);
end hazard_detection;

architecture dataflow of hazard_detection is

    constant OP_RTYPE  : std_logic_vector(6 downto 0) := "0110011";
    constant OP_IALU   : std_logic_vector(6 downto 0) := "0010011";
    constant OP_LOAD   : std_logic_vector(6 downto 0) := "0000011";
    constant OP_STORE  : std_logic_vector(6 downto 0) := "0100011";
    constant OP_BRANCH : std_logic_vector(6 downto 0) := "1100011";
    constant OP_JALR   : std_logic_vector(6 downto 0) := "1100111";

    signal s_opcode   : std_logic_vector(6 downto 0);
    signal s_rs1      : std_logic_vector(4 downto 0);
    signal s_rs2      : std_logic_vector(4 downto 0);
    signal s_uses_rs1 : std_logic;
    signal s_uses_rs2 : std_logic;
    signal s_load_use : std_logic;
    signal s_ctrl     : std_logic;

begin

    s_opcode <= i_inst_ID(6 downto 0);
    s_rs1    <= i_inst_ID(19 downto 15);
    s_rs2    <= i_inst_ID(24 downto 20);

    s_uses_rs1 <= '1' when (s_opcode = OP_RTYPE or s_opcode = OP_IALU or s_opcode = OP_LOAD or
                            s_opcode = OP_STORE or s_opcode = OP_BRANCH or s_opcode = OP_JALR) else
                  '0';

    s_uses_rs2 <= '1' when (s_opcode = OP_RTYPE or s_opcode = OP_BRANCH) else
                  '0';

    s_load_use <= '1' when (i_MemRd_EX = '1' and i_rd_EX /= "00000" and
                            ((s_uses_rs1 = '1' and i_rd_EX = s_rs1) or
                             (s_uses_rs2 = '1' and i_rd_EX = s_rs2))) else
                  '0';

    s_ctrl <= i_pcsrc_EX or i_jump_EX or i_jumpreg_EX;

    o_PC_stall    <= s_load_use;
    o_IF_ID_stall <= s_load_use;
    o_IF_ID_flush <= s_ctrl;
    o_ID_EX_flush <= s_load_use or s_ctrl;
    o_load_use    <= s_load_use;
    o_ctrl_taken  <= s_ctrl;

end dataflow;
