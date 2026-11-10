-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- RISCV_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a RISCV_Processor
-- implementation.

-- 01/29/2019 by H3::Design created.
-- 04/10/2025 by AP::Coverted to RISC-V.
-- 02/19/2026 by H3::Renamed PC and handled OVFL
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.RISCV_types.all;

entity RISCV_Processor is
  generic(N : integer := DATA_WIDTH);
  port(iCLK            : in std_logic;
       iRST            : in std_logic;
       iInstLd         : in std_logic;
       iInstAddr       : in std_logic_vector(N-1 downto 0);
       iInstExt        : in std_logic_vector(N-1 downto 0);
       oALUOut         : out std_logic_vector(N-1 downto 0));
end  RISCV_Processor;


architecture structure of RISCV_Processor is

  signal s_DMemWr       : std_logic;
  signal s_DMemAddr     : std_logic_vector(N-1 downto 0);
  signal s_DMemData     : std_logic_vector(N-1 downto 0);
  signal s_DMemBE       : std_logic_vector(3 downto 0);
  signal s_DMemOut      : std_logic_vector(N-1 downto 0);

  signal s_RegWr        : std_logic;
  signal s_RegWrAddr    : std_logic_vector(4 downto 0);
  signal s_RegWrData    : std_logic_vector(N-1 downto 0);

  signal s_IMemAddr     : std_logic_vector(N-1 downto 0);
  signal s_PC           : std_logic_vector(N-1 downto 0);
  signal s_Inst         : std_logic_vector(N-1 downto 0);

  signal s_Halt         : std_logic;

  signal s_Ovfl         : std_logic;

  component mem is
    generic(ADDR_WIDTH : integer;
            DATA_WIDTH : integer);
    port(
          clk          : in std_logic;
          addr         : in std_logic_vector((ADDR_WIDTH-1) downto 0);
          data         : in std_logic_vector((DATA_WIDTH-1) downto 0);
          be           : in std_logic_vector(3 downto 0);
          we           : in std_logic := '1';
          q            : out std_logic_vector((DATA_WIDTH -1) downto 0));
  end component;

  component IF_Stage is
    generic(N : integer);
    port(clk                : in std_logic;
         rst                : in std_logic;
         Halt               : in std_logic;
         JumpReg            : in std_logic;
         ALU_Result         : in std_logic_vector(N-1 downto 0);
         add2out            : in std_logic_vector(N-1 downto 0);
         Jump               : in std_logic;
         PCSrc              : in std_logic;
         i_IMemOut          : in std_logic_vector(N-1 downto 0);
         o_IMemAddr         : out std_logic_vector(N-1 downto 0);
         current_PC         : out std_logic_vector(N-1 downto 0);
         PCplus4            : out std_logic_vector(N-1 downto 0);
         o_inst             : out std_logic_vector(N-1 downto 0));
  end component;

  component IF_ID is
    generic(WIDTH : integer);
    port(i_CLK     : in std_logic;
         i_RST     : in std_logic;
         i_WE      : in std_logic;
         i_PC      : in std_logic_vector(WIDTH-1 downto 0);
         i_PCplus4 : in std_logic_vector(WIDTH-1 downto 0);
         i_inst    : in std_logic_vector(WIDTH-1 downto 0);
         o_PC      : out std_logic_vector(WIDTH-1 downto 0);
         o_PCplus4 : out std_logic_vector(WIDTH-1 downto 0);
         o_inst    : out std_logic_vector(WIDTH-1 downto 0));
  end component;

  component ID is
    generic(DATAWIDTH : natural := 32);
    port(clk            : in std_logic;
         rst            : in std_logic;
         i_inst         : in std_logic_vector((DATAWIDTH-1) downto 0);
         i_PC           : in std_logic_vector((DATAWIDTH-1) downto 0);
         i_PCplus4      : in std_logic_vector((DATAWIDTH-1) downto 0);
         i_RegWr_WB     : in std_logic;
         i_RegWrAddr_WB : in std_logic_vector(4 downto 0);
         i_RegWrData_WB : in std_logic_vector(DATAWIDTH-1 downto 0);
         o_halt         : out std_logic;
         o_RegWr        : out std_logic;
         o_andlink      : out std_logic;
         o_Mem2Reg      : out std_logic;
         o_MemRd        : out std_logic;
         o_DMemWr       : out std_logic;
         o_jumpreg      : out std_logic;
         o_jump         : out std_logic;
         o_branch       : out std_logic;
         o_alusrc       : out std_logic;
         o_alusrca      : out std_logic_vector(1 downto 0);
         o_aluop        : out std_logic_vector(1 downto 0);
         o_rd1          : out std_logic_vector(DATAWIDTH-1 downto 0);
         o_rd2          : out std_logic_vector(DATAWIDTH-1 downto 0);
         o_immgen       : out std_logic_vector(DATAWIDTH-1 downto 0);
         o_PC           : out std_logic_vector(DATAWIDTH-1 downto 0);
         o_PCplus4      : out std_logic_vector(DATAWIDTH-1 downto 0);
         o_inst         : out std_logic_vector(DATAWIDTH-1 downto 0));
  end component;

  component ID_EX is
    generic(WIDTH : integer);
    port(i_CLK     : in std_logic;
         i_RST     : in std_logic;
         i_WE      : in std_logic;
         i_halt    : in std_logic;
         i_RegWr   : in std_logic;
         i_andlink : in std_logic;
         i_Mem2Reg : in std_logic;
         i_MemRd   : in std_logic;
         i_DMemWr  : in std_logic;
         i_jumpreg : in std_logic;
         i_jump    : in std_logic;
         i_branch  : in std_logic;
         i_alusrc  : in std_logic;
         i_alusrca : in std_logic_vector(1 downto 0);
         i_aluop   : in std_logic_vector(1 downto 0);
         i_rd1     : in std_logic_vector(WIDTH-1 downto 0);
         i_rd2     : in std_logic_vector(WIDTH-1 downto 0);
         i_immgen  : in std_logic_vector(WIDTH-1 downto 0);
         i_PC      : in std_logic_vector(WIDTH-1 downto 0);
         i_PCplus4 : in std_logic_vector(WIDTH-1 downto 0);
         i_inst    : in std_logic_vector(WIDTH-1 downto 0);
         o_halt    : out std_logic;
         o_RegWr   : out std_logic;
         o_andlink : out std_logic;
         o_Mem2Reg : out std_logic;
         o_MemRd   : out std_logic;
         o_DMemWr  : out std_logic;
         o_jumpreg : out std_logic;
         o_jump    : out std_logic;
         o_branch  : out std_logic;
         o_alusrc  : out std_logic;
         o_alusrca : out std_logic_vector(1 downto 0);
         o_aluop   : out std_logic_vector(1 downto 0);
         o_rd1     : out std_logic_vector(WIDTH-1 downto 0);
         o_rd2     : out std_logic_vector(WIDTH-1 downto 0);
         o_immgen  : out std_logic_vector(WIDTH-1 downto 0);
         o_PC      : out std_logic_vector(WIDTH-1 downto 0);
         o_PCplus4 : out std_logic_vector(WIDTH-1 downto 0);
         o_inst    : out std_logic_vector(WIDTH-1 downto 0));
  end component;

  component EX is
    port(clk       : in std_logic;
         rst       : in std_logic;
         i_PC      : in std_logic_vector(31 downto 0);
         i_PC_4    : in std_logic_vector(31 downto 0);
         i_Imm     : in std_logic_vector(31 downto 0);
         i_rd1     : in std_logic_vector(31 downto 0);
         i_rd2     : in std_logic_vector(31 downto 0);
         i_inst    : in std_logic_vector(31 downto 0);
         i_halt    : in std_logic;
         i_RegWr   : in std_logic;
         i_andlink : in std_logic;
         i_Mem2Reg : in std_logic;
         i_MemRd   : in std_logic;
         i_DMemWr  : in std_logic;
         i_jumpreg : in std_logic;
         i_jump    : in std_logic;
         i_branch  : in std_logic;
         i_alusrc  : in std_logic;
         i_alusrca : in std_logic_vector(1 downto 0);
         i_aluop   : in std_logic_vector(1 downto 0);
         o_halt    : out std_logic;
         o_RegWr   : out std_logic;
         o_andlink : out std_logic;
         o_Mem2Reg : out std_logic;
         o_MemRd   : out std_logic;
         o_DMemWr  : out std_logic;
         o_jumpreg : out std_logic;
         o_jump    : out std_logic;
         o_pcsrc   : out std_logic;
         o_ALUout  : out std_logic_vector(31 downto 0);
         o_add2out : out std_logic_vector(31 downto 0);
         o_rd2     : out std_logic_vector(31 downto 0);
         o_PCplus4 : out std_logic_vector(31 downto 0);
         o_inst    : out std_logic_vector(31 downto 0));
  end component;

  component EX_MEM is
    generic(WIDTH : integer);
    port(i_CLK     : in std_logic;
         i_RST     : in std_logic;
         i_WE      : in std_logic;
         i_halt    : in std_logic;
         i_RegWr   : in std_logic;
         i_andlink : in std_logic;
         i_Mem2Reg : in std_logic;
         i_MemRd   : in std_logic;
         i_DMemWr  : in std_logic;
         i_jumpreg : in std_logic;
         i_jump    : in std_logic;
         i_pcsrc   : in std_logic;
         i_ALUout  : in std_logic_vector(WIDTH-1 downto 0);
         i_add2out : in std_logic_vector(WIDTH-1 downto 0);
         i_rd2     : in std_logic_vector(WIDTH-1 downto 0);
         i_PCplus4 : in std_logic_vector(WIDTH-1 downto 0);
         i_inst    : in std_logic_vector(WIDTH-1 downto 0);
         o_halt    : out std_logic;
         o_RegWr   : out std_logic;
         o_andlink : out std_logic;
         o_Mem2Reg : out std_logic;
         o_MemRd   : out std_logic;
         o_DMemWr  : out std_logic;
         o_jumpreg : out std_logic;
         o_jump    : out std_logic;
         o_pcsrc   : out std_logic;
         o_ALUout  : out std_logic_vector(WIDTH-1 downto 0);
         o_add2out : out std_logic_vector(WIDTH-1 downto 0);
         o_rd2     : out std_logic_vector(WIDTH-1 downto 0);
         o_PCplus4 : out std_logic_vector(WIDTH-1 downto 0);
         o_inst    : out std_logic_vector(WIDTH-1 downto 0));
  end component;

  component M is
    generic(DATA_WIDTH : natural := 32);
    port(clk        : in std_logic;
         rst        : in std_logic;
         i_halt     : in std_logic;
         i_RegWr    : in std_logic;
         i_andlink  : in std_logic;
         i_Mem2Reg  : in std_logic;
         i_MemRd    : in std_logic;
         i_DMemWr   : in std_logic;
         i_jumpreg  : in std_logic;
         i_jump     : in std_logic;
         i_pcsrc    : in std_logic;
         i_PCplus4  : in std_logic_vector((DATA_WIDTH-1) downto 0);
         i_ALUout   : in std_logic_vector((DATA_WIDTH-1) downto 0);
         i_rd2      : in std_logic_vector((DATA_WIDTH-1) downto 0);
         i_inst     : in std_logic_vector((DATA_WIDTH-1) downto 0);
         i_DMemOut  : in std_logic_vector((DATA_WIDTH-1) downto 0);
         o_DMemWr   : out std_logic;
         o_DMemAddr : out std_logic_vector((DATA_WIDTH-1) downto 0);
         o_DMemData : out std_logic_vector((DATA_WIDTH-1) downto 0);
         o_DMemBE   : out std_logic_vector(3 downto 0);
         o_halt     : out std_logic;
         o_RegWr    : out std_logic;
         o_andlink  : out std_logic;
         o_Mem2Reg  : out std_logic;
         o_jumpreg  : out std_logic;
         o_jump     : out std_logic;
         o_pcsrc    : out std_logic;
         o_PCplus4  : out std_logic_vector((DATA_WIDTH-1) downto 0);
         o_ALUout   : out std_logic_vector((DATA_WIDTH-1) downto 0);
         o_inst     : out std_logic_vector((DATA_WIDTH-1) downto 0);
         o_Ld_Data  : out std_logic_vector((DATA_WIDTH-1) downto 0));
  end component;

  component MEM_WB is
    generic(WIDTH : integer);
    port(i_CLK     : in std_logic;
         i_RST     : in std_logic;
         i_WE      : in std_logic;
         i_halt    : in std_logic;
         i_RegWr   : in std_logic;
         i_andlink : in std_logic;
         i_Mem2Reg : in std_logic;
         i_ALUout  : in std_logic_vector(WIDTH-1 downto 0);
         i_inst    : in std_logic_vector(WIDTH-1 downto 0);
         i_DataLd  : in std_logic_vector(WIDTH-1 downto 0);
         i_PCplus4 : in std_logic_vector(WIDTH-1 downto 0);
         o_halt    : out std_logic;
         o_RegWr   : out std_logic;
         o_andlink : out std_logic;
         o_Mem2Reg : out std_logic;
         o_ALUout  : out std_logic_vector(WIDTH-1 downto 0);
         o_DataLd  : out std_logic_vector(WIDTH-1 downto 0);
         o_PCplus4 : out std_logic_vector(WIDTH-1 downto 0);
         o_inst    : out std_logic_vector(WIDTH-1 downto 0));
  end component;

  component WB is
    generic(DATA_WIDTH : natural := 32);
    port(clk         : in std_logic;
         rst         : in std_logic;
         i_halt      : in std_logic;
         i_RegWr     : in std_logic;
         i_andlink   : in std_logic;
         i_Mem2Reg   : in std_logic;
         i_Ld_Data   : in std_logic_vector((DATA_WIDTH-1) downto 0);
         i_ALUout    : in std_logic_vector((DATA_WIDTH-1) downto 0);
         i_PCplus4   : in std_logic_vector((DATA_WIDTH-1) downto 0);
         i_inst      : in std_logic_vector((DATA_WIDTH-1) downto 0);
         o_halt      : out std_logic;
         o_RegWr     : out std_logic;
         o_RegWrAddr : out std_logic_vector(4 downto 0);
         o_RegWrData : out std_logic_vector((DATA_WIDTH-1) downto 0));
  end component;

  signal s_PCplus4, s_PCplus4_ID, s_PCplus4_EX, s_PCplus4_MEM, s_PCplus4_WB : std_logic_vector(N-1 downto 0);
  signal s_PC_ID, s_PC_EX : std_logic_vector(N-1 downto 0);
  signal s_Inst_ID, s_Inst_EX, s_Inst_MEM, s_Inst_WB : std_logic_vector(N-1 downto 0);

  signal s_Halt_ID, s_Halt_EX, s_Halt_MEM, s_Halt_WB : std_logic;
  signal s_RegWr_ID, s_RegWr_EX, s_RegWr_MEM, s_RegWr_WB : std_logic;
  signal s_andlink, s_andlink_EX, s_andlink_MEM, s_andlink_WB : std_logic;
  signal s_memtoreg, s_memtoreg_EX, s_memtoreg_MEM, s_memtoreg_WB : std_logic;
  signal s_memread, s_memread_EX, s_memread_MEM : std_logic;
  signal s_DMemWr_ID, s_DMemWr_EX, s_DMemWr_MEM : std_logic;
  signal s_jumpreg, s_jumpreg_EX, s_jumpreg_MEM : std_logic;
  signal s_jump, s_jump_EX, s_jump_MEM : std_logic;
  signal s_branch, s_branch_EX : std_logic;
  signal s_alusrc, s_alusrc_EX : std_logic;
  signal s_alusrca, s_alusrca_EX : std_logic_vector(1 downto 0);
  signal s_aluop, s_aluop_EX : std_logic_vector(1 downto 0);

  signal s_rd1, s_rd1_EX : std_logic_vector(N-1 downto 0);
  signal s_rd2, s_rd2_EX, s_rd2_MEM : std_logic_vector(N-1 downto 0);
  signal s_immgen, s_immgen_EX : std_logic_vector(N-1 downto 0);

  signal s_pcsrc, s_pcsrc_MEM : std_logic;
  signal s_aluresult, s_aluresult_MEM, s_aluresult_WB : std_logic_vector(N-1 downto 0);
  signal s_add2out, s_add2out_MEM : std_logic_vector(N-1 downto 0);

  signal s_Ld_Data, s_Ld_Data_WB : std_logic_vector(N-1 downto 0);

begin
  s_Ovfl <= '0';

  with iInstLd select
    s_IMemAddr <= s_PC when '0',
      iInstAddr when others;

  IMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_IMemAddr(11 downto 2),
             data => iInstExt,
             be   => "1111",
             we   => iInstLd,
             q    => s_Inst);

  DMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             be   => s_DMemBE,
             we   => s_DMemWr,
             q    => s_DMemOut);

  G_IF: IF_Stage
    generic map(N => N)
    port map(clk        => iCLK,
             rst        => iRST,
             Halt       => s_Halt,
             JumpReg    => s_jumpreg_MEM,
             ALU_Result => s_aluresult_MEM,
             add2out    => s_add2out_MEM,
             Jump       => s_jump_MEM,
             PCSrc      => s_pcsrc_MEM,
             i_IMemOut  => s_Inst,
             o_IMemAddr => s_PC,
             current_PC => open,
             PCplus4    => s_PCplus4,
             o_inst     => open);

  G_IF_ID: IF_ID
    generic map(WIDTH => N)
    port map(i_CLK     => iCLK,
             i_RST     => iRST,
             i_WE      => '1',
             i_PC      => s_PC,
             i_PCplus4 => s_PCplus4,
             i_inst    => s_Inst,
             o_PC      => s_PC_ID,
             o_PCplus4 => s_PCplus4_ID,
             o_inst    => s_Inst_ID);

  G_ID: ID
    generic map(DATAWIDTH => N)
    port map(clk            => iCLK,
             rst            => iRST,
             i_inst         => s_Inst_ID,
             i_PC           => s_PC_ID,
             i_PCplus4      => s_PCplus4_ID,
             i_RegWr_WB     => s_RegWr,
             i_RegWrAddr_WB => s_RegWrAddr,
             i_RegWrData_WB => s_RegWrData,
             o_halt         => s_Halt_ID,
             o_RegWr        => s_RegWr_ID,
             o_andlink      => s_andlink,
             o_Mem2Reg      => s_memtoreg,
             o_MemRd        => s_memread,
             o_DMemWr       => s_DMemWr_ID,
             o_jumpreg      => s_jumpreg,
             o_jump         => s_jump,
             o_branch       => s_branch,
             o_alusrc       => s_alusrc,
             o_alusrca      => s_alusrca,
             o_aluop        => s_aluop,
             o_rd1          => s_rd1,
             o_rd2          => s_rd2,
             o_immgen       => s_immgen,
             o_PC           => open,
             o_PCplus4      => open,
             o_inst         => open);

  G_ID_EX: ID_EX
    generic map(WIDTH => N)
    port map(i_CLK     => iCLK,
             i_RST     => iRST,
             i_WE      => '1',
             i_halt    => s_Halt_ID,
             i_RegWr   => s_RegWr_ID,
             i_andlink => s_andlink,
             i_Mem2Reg => s_memtoreg,
             i_MemRd   => s_memread,
             i_DMemWr  => s_DMemWr_ID,
             i_jumpreg => s_jumpreg,
             i_jump    => s_jump,
             i_branch  => s_branch,
             i_alusrc  => s_alusrc,
             i_alusrca => s_alusrca,
             i_aluop   => s_aluop,
             i_rd1     => s_rd1,
             i_rd2     => s_rd2,
             i_immgen  => s_immgen,
             i_PC      => s_PC_ID,
             i_PCplus4 => s_PCplus4_ID,
             i_inst    => s_Inst_ID,
             o_halt    => s_Halt_EX,
             o_RegWr   => s_RegWr_EX,
             o_andlink => s_andlink_EX,
             o_Mem2Reg => s_memtoreg_EX,
             o_MemRd   => s_memread_EX,
             o_DMemWr  => s_DMemWr_EX,
             o_jumpreg => s_jumpreg_EX,
             o_jump    => s_jump_EX,
             o_branch  => s_branch_EX,
             o_alusrc  => s_alusrc_EX,
             o_alusrca => s_alusrca_EX,
             o_aluop   => s_aluop_EX,
             o_rd1     => s_rd1_EX,
             o_rd2     => s_rd2_EX,
             o_immgen  => s_immgen_EX,
             o_PC      => s_PC_EX,
             o_PCplus4 => s_PCplus4_EX,
             o_inst    => s_Inst_EX);

  G_EX: EX
    port map(clk       => iCLK,
             rst       => iRST,
             i_PC      => s_PC_EX,
             i_PC_4    => s_PCplus4_EX,
             i_Imm     => s_immgen_EX,
             i_rd1     => s_rd1_EX,
             i_rd2     => s_rd2_EX,
             i_inst    => s_Inst_EX,
             i_halt    => s_Halt_EX,
             i_RegWr   => s_RegWr_EX,
             i_andlink => s_andlink_EX,
             i_Mem2Reg => s_memtoreg_EX,
             i_MemRd   => s_memread_EX,
             i_DMemWr  => s_DMemWr_EX,
             i_jumpreg => s_jumpreg_EX,
             i_jump    => s_jump_EX,
             i_branch  => s_branch_EX,
             i_alusrc  => s_alusrc_EX,
             i_alusrca => s_alusrca_EX,
             i_aluop   => s_aluop_EX,
             o_halt    => open,
             o_RegWr   => open,
             o_andlink => open,
             o_Mem2Reg => open,
             o_MemRd   => open,
             o_DMemWr  => open,
             o_jumpreg => open,
             o_jump    => open,
             o_pcsrc   => s_pcsrc,
             o_ALUout  => s_aluresult,
             o_add2out => s_add2out,
             o_rd2     => open,
             o_PCplus4 => open,
             o_inst    => open);

  oALUOut <= s_aluresult;

  G_EX_MEM: EX_MEM
    generic map(WIDTH => N)
    port map(i_CLK     => iCLK,
             i_RST     => iRST,
             i_WE      => '1',
             i_halt    => s_Halt_EX,
             i_RegWr   => s_RegWr_EX,
             i_andlink => s_andlink_EX,
             i_Mem2Reg => s_memtoreg_EX,
             i_MemRd   => s_memread_EX,
             i_DMemWr  => s_DMemWr_EX,
             i_jumpreg => s_jumpreg_EX,
             i_jump    => s_jump_EX,
             i_pcsrc   => s_pcsrc,
             i_ALUout  => s_aluresult,
             i_add2out => s_add2out,
             i_rd2     => s_rd2_EX,
             i_PCplus4 => s_PCplus4_EX,
             i_inst    => s_Inst_EX,
             o_halt    => s_Halt_MEM,
             o_RegWr   => s_RegWr_MEM,
             o_andlink => s_andlink_MEM,
             o_Mem2Reg => s_memtoreg_MEM,
             o_MemRd   => s_memread_MEM,
             o_DMemWr  => s_DMemWr_MEM,
             o_jumpreg => s_jumpreg_MEM,
             o_jump    => s_jump_MEM,
             o_pcsrc   => s_pcsrc_MEM,
             o_ALUout  => s_aluresult_MEM,
             o_add2out => s_add2out_MEM,
             o_rd2     => s_rd2_MEM,
             o_PCplus4 => s_PCplus4_MEM,
             o_inst    => s_Inst_MEM);

  G_MEM: M
    generic map(DATA_WIDTH => N)
    port map(clk        => iCLK,
             rst        => iRST,
             i_halt     => s_Halt_MEM,
             i_RegWr    => s_RegWr_MEM,
             i_andlink  => s_andlink_MEM,
             i_Mem2Reg  => s_memtoreg_MEM,
             i_MemRd    => s_memread_MEM,
             i_DMemWr   => s_DMemWr_MEM,
             i_jumpreg  => s_jumpreg_MEM,
             i_jump     => s_jump_MEM,
             i_pcsrc    => s_pcsrc_MEM,
             i_PCplus4  => s_PCplus4_MEM,
             i_ALUout   => s_aluresult_MEM,
             i_rd2      => s_rd2_MEM,
             i_inst     => s_Inst_MEM,
             i_DMemOut  => s_DMemOut,
             o_DMemWr   => s_DMemWr,
             o_DMemAddr => s_DMemAddr,
             o_DMemData => s_DMemData,
             o_DMemBE   => s_DMemBE,
             o_halt     => open,
             o_RegWr    => open,
             o_andlink  => open,
             o_Mem2Reg  => open,
             o_jumpreg  => open,
             o_jump     => open,
             o_pcsrc    => open,
             o_PCplus4  => open,
             o_ALUout   => open,
             o_inst     => open,
             o_Ld_Data  => s_Ld_Data);

  G_MEM_WB: MEM_WB
    generic map(WIDTH => N)
    port map(i_CLK     => iCLK,
             i_RST     => iRST,
             i_WE      => '1',
             i_halt    => s_Halt_MEM,
             i_RegWr   => s_RegWr_MEM,
             i_andlink => s_andlink_MEM,
             i_Mem2Reg => s_memtoreg_MEM,
             i_ALUout  => s_aluresult_MEM,
             i_inst    => s_Inst_MEM,
             i_DataLd  => s_Ld_Data,
             i_PCplus4 => s_PCplus4_MEM,
             o_halt    => s_Halt_WB,
             o_RegWr   => s_RegWr_WB,
             o_andlink => s_andlink_WB,
             o_Mem2Reg => s_memtoreg_WB,
             o_ALUout  => s_aluresult_WB,
             o_DataLd  => s_Ld_Data_WB,
             o_PCplus4 => s_PCplus4_WB,
             o_inst    => s_Inst_WB);

  G_WB: WB
    generic map(DATA_WIDTH => N)
    port map(clk         => iCLK,
             rst         => iRST,
             i_halt      => s_Halt_WB,
             i_RegWr     => s_RegWr_WB,
             i_andlink   => s_andlink_WB,
             i_Mem2Reg   => s_memtoreg_WB,
             i_Ld_Data   => s_Ld_Data_WB,
             i_ALUout    => s_aluresult_WB,
             i_PCplus4   => s_PCplus4_WB,
             i_inst      => s_Inst_WB,
             o_halt      => s_Halt,
             o_RegWr     => s_RegWr,
             o_RegWrAddr => s_RegWrAddr,
             o_RegWrData => s_RegWrData);

end structure;
