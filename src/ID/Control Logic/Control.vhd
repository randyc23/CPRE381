-- Signal encodings
--   ALUOp    "00" = add (address calc, jalr, lui, auipc)
--            "01" = branch compare (see note in aluctrlr)
--            "10" = R-type, decode funct3/funct7
--            "11" = I-type ALU, decode funct3 (ignore bit 30 except srai)
--   ALUSrcA  "00" = rs1   "01" = PC   "10" = zero   (ALU top input)
--   ALUSrc   '0'  = rs2   '1'  = immediate          (ALU bottom input)
--   MemtoReg '0'  = ALU result  '1' = memory data   (writeback)
--   AndLink  '1'  = write PC+4 to rd (jal, jalr)
--   Branch   '1'  = conditional branch (taken decided by branch logic)
--   Jump     '1'  = jal   (next PC = PC + imm)
--   JumpReg  '1'  = jalr  (next PC = ALU result with bit 0 cleared)
--   Halt     '1'  = wfi / SYSTEM opcode, stop the processor


library IEEE;
use IEEE.std_logic_1164.all;

entity control_unit is
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
end control_unit;

architecture dataflow of control_unit is

    -- RV32I opcodes
    constant OP_RTYPE  : std_logic_vector(6 downto 0) := "0110011"; -- add, sub, and, or, xor, sll, srl, sra, slt
    constant OP_IALU   : std_logic_vector(6 downto 0) := "0010011"; -- addi, andi, ori, xori, slti, sltiu, slli, srli, srai
    constant OP_LOAD   : std_logic_vector(6 downto 0) := "0000011"; -- lb, lh, lw, lbu, lhu
    constant OP_STORE  : std_logic_vector(6 downto 0) := "0100011"; -- sb, sh, sw
    constant OP_BRANCH : std_logic_vector(6 downto 0) := "1100011"; -- beq, bne, blt, bge, bltu, bgeu
    constant OP_JAL    : std_logic_vector(6 downto 0) := "1101111"; -- jal
    constant OP_JALR   : std_logic_vector(6 downto 0) := "1100111"; -- jalr
    constant OP_LUI    : std_logic_vector(6 downto 0) := "0110111"; -- lui
    constant OP_AUIPC  : std_logic_vector(6 downto 0) := "0010111"; -- auipc
    constant OP_SYSTEM : std_logic_vector(6 downto 0) := "1110011"; -- wfi (used as HALT)

    signal s_opcode : std_logic_vector(6 downto 0);

    signal s_rtype, s_ialu, s_load, s_store, s_branch : std_logic;
    signal s_jal, s_jalr, s_lui, s_auipc, s_system   : std_logic;

begin

    s_opcode <= inst(6 downto 0);

    s_rtype  <= '1' when s_opcode = OP_RTYPE  else '0';   -- rd = rs1 op rs2
    s_ialu   <= '1' when s_opcode = OP_IALU   else '0';   -- rd = rs1 op imm
    s_load   <= '1' when s_opcode = OP_LOAD   else '0';   -- rd = Mem[rs1 + imm]
    s_store  <= '1' when s_opcode = OP_STORE  else '0';   -- Mem[rs1 + imm] = rs2
    s_branch <= '1' when s_opcode = OP_BRANCH else '0';   -- if (rs1 ? rs2) PC = PC + imm
    s_jal    <= '1' when s_opcode = OP_JAL    else '0';   -- rd = PC + 4, PC = PC + imm
    s_jalr   <= '1' when s_opcode = OP_JALR   else '0';   -- rd = PC + 4, PC = (rs1 + imm) & ~1
    s_lui    <= '1' when s_opcode = OP_LUI    else '0';   -- rd = 0 + imm
    s_auipc  <= '1' when s_opcode = OP_AUIPC  else '0';   -- rd = PC + imm
    s_system <= '1' when s_opcode = OP_SYSTEM else '0';   -- wfi -> stop

    ALUOp(1)   <= s_rtype or s_ialu;
    ALUOp(0)   <= s_ialu  or s_branch;

    ALUSrcA(1) <= s_lui;
    ALUSrcA(0) <= s_auipc;

    ALUSrc     <= s_ialu or s_load or s_store or s_jalr or s_lui or s_auipc;
    RegWrite   <= s_rtype or s_ialu or s_load or s_jal or s_jalr or s_lui or s_auipc;
    MemRead    <= s_load;
    MemWrite   <= s_store;
    MemtoReg   <= s_load;
    AndLink    <= s_jal or s_jalr;
    Branch     <= s_branch;
    Jump       <= s_jal;
    JumpReg    <= s_jalr;
    Halt       <= s_system;

end dataflow;
