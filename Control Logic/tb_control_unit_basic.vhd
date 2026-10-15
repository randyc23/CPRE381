-------------------------------------------------------------------------
-- tb_control_unit_basic.vhd
-- Basic testbench for control_unit: one instruction from each opcode
-- class, every output checked with its own assert so a failure tells you
-- exactly which signal is wrong.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_control_unit_basic is
    generic(gCLK_HPER : time := 10 ns);
end tb_control_unit_basic;

architecture mixed of tb_control_unit_basic is

    constant cCLK_PER : time := gCLK_HPER * 2;

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

    -- Inputs
    signal s_inst     : std_logic_vector(31 downto 0) := x"00000000";

    -- Outputs
    signal s_ALUOp    : std_logic_vector(1 downto 0);
    signal s_ALUSrcA  : std_logic_vector(1 downto 0);
    signal s_ALUSrc   : std_logic;
    signal s_RegWrite : std_logic;
    signal s_MemRead  : std_logic;
    signal s_MemWrite : std_logic;
    signal s_MemtoReg : std_logic;
    signal s_AndLink  : std_logic;
    signal s_Branch   : std_logic;
    signal s_Jump     : std_logic;
    signal s_JumpReg  : std_logic;
    signal s_Halt     : std_logic;

begin

    DUT0: control_unit
        port map(inst     => s_inst,
                 ALUOp    => s_ALUOp,
                 ALUSrcA  => s_ALUSrcA,
                 ALUSrc   => s_ALUSrc,
                 RegWrite => s_RegWrite,
                 MemRead  => s_MemRead,
                 MemWrite => s_MemWrite,
                 MemtoReg => s_MemtoReg,
                 AndLink  => s_AndLink,
                 Branch   => s_Branch,
                 Jump     => s_Jump,
                 JumpReg  => s_JumpReg,
                 Halt     => s_Halt);

    P_TEST_CASES: process
    begin
        wait for gCLK_HPER/2;

        ------------------------------------------------------------------
        -- R-type: add x1, x2, x3
        ------------------------------------------------------------------
        s_inst <= x"003100B3"; wait for cCLK_PER;
        assert s_ALUOp    = "10" report "add: ALUOp"    severity error;
        assert s_ALUSrcA  = "00" report "add: ALUSrcA"  severity error;
        assert s_ALUSrc   = '0'  report "add: ALUSrc"   severity error;
        assert s_RegWrite = '1'  report "add: RegWrite" severity error;
        assert s_MemRead  = '0'  report "add: MemRead"  severity error;
        assert s_MemWrite = '0'  report "add: MemWrite" severity error;
        assert s_MemtoReg = '0'  report "add: MemtoReg" severity error;
        assert s_AndLink  = '0'  report "add: AndLink"  severity error;
        assert s_Branch   = '0'  report "add: Branch"   severity error;
        assert s_Jump     = '0'  report "add: Jump"     severity error;
        assert s_JumpReg  = '0'  report "add: JumpReg"  severity error;
        assert s_Halt     = '0'  report "add: Halt"     severity error;

        ------------------------------------------------------------------
        -- I-type ALU: addi x1, x2, -5
        ------------------------------------------------------------------
        s_inst <= x"FFB10093"; wait for cCLK_PER;
        assert s_ALUOp    = "11" report "addi: ALUOp"    severity error;
        assert s_ALUSrcA  = "00" report "addi: ALUSrcA"  severity error;
        assert s_ALUSrc   = '1'  report "addi: ALUSrc"   severity error;
        assert s_RegWrite = '1'  report "addi: RegWrite" severity error;
        assert s_MemRead  = '0'  report "addi: MemRead"  severity error;
        assert s_MemWrite = '0'  report "addi: MemWrite" severity error;
        assert s_MemtoReg = '0'  report "addi: MemtoReg" severity error;
        assert s_AndLink  = '0'  report "addi: AndLink"  severity error;
        assert s_Branch   = '0'  report "addi: Branch"   severity error;
        assert s_Jump     = '0'  report "addi: Jump"     severity error;
        assert s_JumpReg  = '0'  report "addi: JumpReg"  severity error;
        assert s_Halt     = '0'  report "addi: Halt"     severity error;

        ------------------------------------------------------------------
        -- Load: lw x1, -4(x2)
        ------------------------------------------------------------------
        s_inst <= x"FFC12083"; wait for cCLK_PER;
        assert s_ALUOp    = "00" report "lw: ALUOp"    severity error;
        assert s_ALUSrcA  = "00" report "lw: ALUSrcA"  severity error;
        assert s_ALUSrc   = '1'  report "lw: ALUSrc"   severity error;
        assert s_RegWrite = '1'  report "lw: RegWrite" severity error;
        assert s_MemRead  = '1'  report "lw: MemRead"  severity error;
        assert s_MemWrite = '0'  report "lw: MemWrite" severity error;
        assert s_MemtoReg = '1'  report "lw: MemtoReg" severity error;
        assert s_AndLink  = '0'  report "lw: AndLink"  severity error;
        assert s_Branch   = '0'  report "lw: Branch"   severity error;
        assert s_Jump     = '0'  report "lw: Jump"     severity error;
        assert s_JumpReg  = '0'  report "lw: JumpReg"  severity error;
        assert s_Halt     = '0'  report "lw: Halt"     severity error;

        ------------------------------------------------------------------
        -- Store: sw x3, -4(x2)
        ------------------------------------------------------------------
        s_inst <= x"FE312E23"; wait for cCLK_PER;
        assert s_ALUOp    = "00" report "sw: ALUOp"    severity error;
        assert s_ALUSrcA  = "00" report "sw: ALUSrcA"  severity error;
        assert s_ALUSrc   = '1'  report "sw: ALUSrc"   severity error;
        assert s_RegWrite = '0'  report "sw: RegWrite" severity error;
        assert s_MemRead  = '0'  report "sw: MemRead"  severity error;
        assert s_MemWrite = '1'  report "sw: MemWrite" severity error;
        assert s_MemtoReg = '0'  report "sw: MemtoReg" severity error;
        assert s_AndLink  = '0'  report "sw: AndLink"  severity error;
        assert s_Branch   = '0'  report "sw: Branch"   severity error;
        assert s_Jump     = '0'  report "sw: Jump"     severity error;
        assert s_JumpReg  = '0'  report "sw: JumpReg"  severity error;
        assert s_Halt     = '0'  report "sw: Halt"     severity error;

        ------------------------------------------------------------------
        -- Branch: beq x2, x3, -8
        ------------------------------------------------------------------
        s_inst <= x"FE310CE3"; wait for cCLK_PER;
        assert s_ALUOp    = "01" report "beq: ALUOp"    severity error;
        assert s_ALUSrcA  = "00" report "beq: ALUSrcA"  severity error;
        assert s_ALUSrc   = '0'  report "beq: ALUSrc"   severity error;
        assert s_RegWrite = '0'  report "beq: RegWrite" severity error;
        assert s_MemRead  = '0'  report "beq: MemRead"  severity error;
        assert s_MemWrite = '0'  report "beq: MemWrite" severity error;
        assert s_MemtoReg = '0'  report "beq: MemtoReg" severity error;
        assert s_AndLink  = '0'  report "beq: AndLink"  severity error;
        assert s_Branch   = '1'  report "beq: Branch"   severity error;
        assert s_Jump     = '0'  report "beq: Jump"     severity error;
        assert s_JumpReg  = '0'  report "beq: JumpReg"  severity error;
        assert s_Halt     = '0'  report "beq: Halt"     severity error;

        ------------------------------------------------------------------
        -- jal x1, -16
        ------------------------------------------------------------------
        s_inst <= x"FF1FF0EF"; wait for cCLK_PER;
        assert s_ALUOp    = "00" report "jal: ALUOp"    severity error;
        assert s_ALUSrcA  = "00" report "jal: ALUSrcA"  severity error;
        assert s_ALUSrc   = '0'  report "jal: ALUSrc"   severity error;
        assert s_RegWrite = '1'  report "jal: RegWrite" severity error;
        assert s_MemRead  = '0'  report "jal: MemRead"  severity error;
        assert s_MemWrite = '0'  report "jal: MemWrite" severity error;
        assert s_MemtoReg = '0'  report "jal: MemtoReg" severity error;
        assert s_AndLink  = '1'  report "jal: AndLink"  severity error;
        assert s_Branch   = '0'  report "jal: Branch"   severity error;
        assert s_Jump     = '1'  report "jal: Jump"     severity error;
        assert s_JumpReg  = '0'  report "jal: JumpReg"  severity error;
        assert s_Halt     = '0'  report "jal: Halt"     severity error;

        ------------------------------------------------------------------
        -- jalr x1, -4(x2)
        ------------------------------------------------------------------
        s_inst <= x"FFC100E7"; wait for cCLK_PER;
        assert s_ALUOp    = "00" report "jalr: ALUOp"    severity error;
        assert s_ALUSrcA  = "00" report "jalr: ALUSrcA"  severity error;
        assert s_ALUSrc   = '1'  report "jalr: ALUSrc"   severity error;
        assert s_RegWrite = '1'  report "jalr: RegWrite" severity error;
        assert s_MemRead  = '0'  report "jalr: MemRead"  severity error;
        assert s_MemWrite = '0'  report "jalr: MemWrite" severity error;
        assert s_MemtoReg = '0'  report "jalr: MemtoReg" severity error;
        assert s_AndLink  = '1'  report "jalr: AndLink"  severity error;
        assert s_Branch   = '0'  report "jalr: Branch"   severity error;
        assert s_Jump     = '0'  report "jalr: Jump"     severity error;
        assert s_JumpReg  = '1'  report "jalr: JumpReg"  severity error;
        assert s_Halt     = '0'  report "jalr: Halt"     severity error;

        ------------------------------------------------------------------
        -- lui x1, 0xFFFFF
        ------------------------------------------------------------------
        s_inst <= x"FFFFF0B7"; wait for cCLK_PER;
        assert s_ALUOp    = "00" report "lui: ALUOp"    severity error;
        assert s_ALUSrcA  = "10" report "lui: ALUSrcA"  severity error;
        assert s_ALUSrc   = '1'  report "lui: ALUSrc"   severity error;
        assert s_RegWrite = '1'  report "lui: RegWrite" severity error;
        assert s_MemRead  = '0'  report "lui: MemRead"  severity error;
        assert s_MemWrite = '0'  report "lui: MemWrite" severity error;
        assert s_MemtoReg = '0'  report "lui: MemtoReg" severity error;
        assert s_AndLink  = '0'  report "lui: AndLink"  severity error;
        assert s_Branch   = '0'  report "lui: Branch"   severity error;
        assert s_Jump     = '0'  report "lui: Jump"     severity error;
        assert s_JumpReg  = '0'  report "lui: JumpReg"  severity error;
        assert s_Halt     = '0'  report "lui: Halt"     severity error;

        ------------------------------------------------------------------
        -- auipc x1, 0xFFFFF
        ------------------------------------------------------------------
        s_inst <= x"FFFFF097"; wait for cCLK_PER;
        assert s_ALUOp    = "00" report "auipc: ALUOp"    severity error;
        assert s_ALUSrcA  = "01" report "auipc: ALUSrcA"  severity error;
        assert s_ALUSrc   = '1'  report "auipc: ALUSrc"   severity error;
        assert s_RegWrite = '1'  report "auipc: RegWrite" severity error;
        assert s_MemRead  = '0'  report "auipc: MemRead"  severity error;
        assert s_MemWrite = '0'  report "auipc: MemWrite" severity error;
        assert s_MemtoReg = '0'  report "auipc: MemtoReg" severity error;
        assert s_AndLink  = '0'  report "auipc: AndLink"  severity error;
        assert s_Branch   = '0'  report "auipc: Branch"   severity error;
        assert s_Jump     = '0'  report "auipc: Jump"     severity error;
        assert s_JumpReg  = '0'  report "auipc: JumpReg"  severity error;
        assert s_Halt     = '0'  report "auipc: Halt"     severity error;

        ------------------------------------------------------------------
        -- wfi (HALT)
        ------------------------------------------------------------------
        s_inst <= x"10500073"; wait for cCLK_PER;
        assert s_ALUOp    = "00" report "wfi: ALUOp"    severity error;
        assert s_ALUSrcA  = "00" report "wfi: ALUSrcA"  severity error;
        assert s_ALUSrc   = '0'  report "wfi: ALUSrc"   severity error;
        assert s_RegWrite = '0'  report "wfi: RegWrite" severity error;
        assert s_MemRead  = '0'  report "wfi: MemRead"  severity error;
        assert s_MemWrite = '0'  report "wfi: MemWrite" severity error;
        assert s_MemtoReg = '0'  report "wfi: MemtoReg" severity error;
        assert s_AndLink  = '0'  report "wfi: AndLink"  severity error;
        assert s_Branch   = '0'  report "wfi: Branch"   severity error;
        assert s_Jump     = '0'  report "wfi: Jump"     severity error;
        assert s_JumpReg  = '0'  report "wfi: JumpReg"  severity error;
        assert s_Halt     = '1'  report "wfi: Halt"     severity error;

        ------------------------------------------------------------------
        -- Illegal opcode (all zeros): must not write a register or memory
        ------------------------------------------------------------------
        s_inst <= x"00000000"; wait for cCLK_PER;
        assert s_RegWrite = '0'  report "illegal: RegWrite" severity error;
        assert s_MemWrite = '0'  report "illegal: MemWrite" severity error;
        assert s_Branch   = '0'  report "illegal: Branch"   severity error;
        assert s_Jump     = '0'  report "illegal: Jump"     severity error;
        assert s_JumpReg  = '0'  report "illegal: JumpReg"  severity error;
        assert s_Halt     = '0'  report "illegal: Halt"     severity error;

        report "tb_control_unit_basic finished" severity note;
        wait;
    end process;

end mixed;