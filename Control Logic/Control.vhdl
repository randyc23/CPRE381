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

architecture behavioral of control_unit is

    -- RV32I opcodes (inst(6 downto 0))
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

begin

    s_opcode <= inst(6 downto 0);

    P_DECODE: process(s_opcode)
    begin
        
        ALUOp    <= "00";
        ALUSrcA  <= "00";
        ALUSrc   <= '0';
        RegWrite <= '0';
        MemRead  <= '0';
        MemWrite <= '0';
        MemtoReg <= '0';
        AndLink  <= '0';
        Branch   <= '0';
        Jump     <= '0';
        JumpReg  <= '0';
        Halt     <= '0';

        case s_opcode is

            when OP_RTYPE =>            -- rd = rs1 op rs2
                ALUOp    <= "10";
                RegWrite <= '1';

            when OP_IALU =>             -- rd = rs1 op imm
                ALUOp    <= "11";
                ALUSrc   <= '1';
                RegWrite <= '1';

            when OP_LOAD =>             -- rd = Mem[rs1 + imm]
                ALUSrc   <= '1';
                RegWrite <= '1';
                MemRead  <= '1';
                MemtoReg <= '1';

            when OP_STORE =>            -- Mem[rs1 + imm] = rs2
                ALUSrc   <= '1';
                MemWrite <= '1';

            when OP_BRANCH =>           -- if (rs1 ? rs2) PC = PC + imm
                ALUOp    <= "01";
                Branch   <= '1';

            when OP_JAL =>              -- rd = PC + 4, PC = PC + imm
                RegWrite <= '1';
                AndLink  <= '1';
                Jump     <= '1';

            when OP_JALR =>             -- rd = PC + 4, PC = (rs1 + imm) & ~1
                ALUSrc   <= '1';
                RegWrite <= '1';
                AndLink  <= '1';
                JumpReg  <= '1';

            when OP_LUI =>              -- rd = 0 + imm
                ALUSrcA  <= "10";
                ALUSrc   <= '1';
                RegWrite <= '1';

            when OP_AUIPC =>            -- rd = PC + imm
                ALUSrcA  <= "01";
                ALUSrc   <= '1';
                RegWrite <= '1';

            when OP_SYSTEM =>           -- wfi -> stop
                Halt     <= '1';

            when others =>              -- unknown opcode: keep the safe defaults
                null;

        end case;
    end process P_DECODE;

end behavioral;