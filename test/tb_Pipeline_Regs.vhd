library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_Pipeline_Regs is
  generic(gCLK_HPER : time := 10 ns);
end tb_Pipeline_Regs;

architecture behavior of tb_Pipeline_Regs is

  constant N        : integer := 32;
  constant cCLK_PER : time := gCLK_HPER * 2;
  constant NOP      : std_logic_vector(31 downto 0) := x"00000013";
  constant PC_RST   : std_logic_vector(31 downto 0) := x"00400000";

  constant R_PC     : integer := 0;
  constant R_IF_ID  : integer := 1;
  constant R_ID_EX  : integer := 2;
  constant R_EX_MEM : integer := 3;
  constant R_MEM_WB : integer := 4;

  component pc_reg_sf is
    generic(WIDTH     : integer;
            RST_VAL   : std_logic_vector;
            FLUSH_VAL : std_logic_vector);
    port(i_CLK   : in std_logic;
         i_RST   : in std_logic;
         i_stall : in std_logic;
         i_flush : in std_logic;
         i_Din   : in std_logic_vector(WIDTH-1 downto 0);
         o_Dout  : out std_logic_vector(WIDTH-1 downto 0));
  end component;

  component IF_ID is
    generic(WIDTH : integer);
    port(i_CLK     : in std_logic;
         i_RST     : in std_logic;
         i_stall   : in std_logic;
         i_flush   : in std_logic;
         i_PC      : in std_logic_vector(WIDTH-1 downto 0);
         i_PCplus4 : in std_logic_vector(WIDTH-1 downto 0);
         i_inst    : in std_logic_vector(WIDTH-1 downto 0);
         o_PC      : out std_logic_vector(WIDTH-1 downto 0);
         o_PCplus4 : out std_logic_vector(WIDTH-1 downto 0);
         o_inst    : out std_logic_vector(WIDTH-1 downto 0));
  end component;

  component ID_EX is
    generic(WIDTH : integer);
    port(i_CLK     : in std_logic;
         i_RST     : in std_logic;
         i_stall   : in std_logic;
         i_flush   : in std_logic;
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

  component EX_MEM is
    generic(WIDTH : integer);
    port(i_CLK     : in std_logic;
         i_RST     : in std_logic;
         i_stall   : in std_logic;
         i_flush   : in std_logic;
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

  component MEM_WB is
    generic(WIDTH : integer);
    port(i_CLK     : in std_logic;
         i_RST     : in std_logic;
         i_stall   : in std_logic;
         i_flush   : in std_logic;
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

  type t_stage is record
    inst : std_logic_vector(31 downto 0);
    pc   : std_logic_vector(31 downto 0);
    pcp4 : std_logic_vector(31 downto 0);
    data : std_logic_vector(31 downto 0);
  end record;

  constant STAGE_ZERO  : t_stage := (others => (others => '0'));
  constant STAGE_FLUSH : t_stage := (inst => NOP, others => (others => '0'));

  function imem(pc : std_logic_vector(31 downto 0)) return std_logic_vector is
    variable k : unsigned(31 downto 0);
    variable r : std_logic_vector(31 downto 0);
  begin
    k := shift_right(unsigned(pc) - unsigned(PC_RST), 2) + 1;
    r := std_logic_vector(k(23 downto 0) & x"00");
    r(31) := '1';
    r(30) := k(0);
    r(6 downto 0) := "0110011";
    return r;
  end function;

  function hex(v : std_logic_vector) return string is
    constant digits : string(1 to 16) := "0123456789ABCDEF";
    variable s : string(1 to v'length / 4);
    variable nib : std_logic_vector(3 downto 0);
    variable vv : std_logic_vector(v'length-1 downto 0) := v;
  begin
    for i in 0 to v'length / 4 - 1 loop
      nib := vv(v'length - 1 - 4*i downto v'length - 4 - 4*i);
      if is_x(nib) then
        s(i+1) := 'X';
      else
        s(i+1) := digits(to_integer(unsigned(nib)) + 1);
      end if;
    end loop;
    return s;
  end function;

  signal CLK, RST : std_logic := '0';

  signal s_stall : std_logic_vector(4 downto 0) := (others => '0');
  signal s_flush : std_logic_vector(4 downto 0) := (others => '0');
  signal s_test  : integer := 0;
  signal s_errors : integer := 0;

  signal s_PC, s_PC_next, s_PCplus4, s_Inst : std_logic_vector(N-1 downto 0);

  signal s_PC_ID, s_PCplus4_ID, s_Inst_ID : std_logic_vector(N-1 downto 0);

  signal s_Halt_EX, s_RegWr_EX, s_andlink_EX, s_memtoreg_EX, s_memread_EX : std_logic;
  signal s_DMemWr_EX, s_jumpreg_EX, s_jump_EX, s_branch_EX, s_alusrc_EX   : std_logic;
  signal s_alusrca_EX, s_aluop_EX : std_logic_vector(1 downto 0);
  signal s_rd1_EX, s_rd2_EX, s_immgen_EX, s_PC_EX, s_PCplus4_EX, s_Inst_EX : std_logic_vector(N-1 downto 0);

  signal s_Halt_MEM, s_RegWr_MEM, s_andlink_MEM, s_memtoreg_MEM, s_memread_MEM : std_logic;
  signal s_DMemWr_MEM, s_jumpreg_MEM, s_jump_MEM, s_pcsrc_MEM : std_logic;
  signal s_ALUout_MEM, s_add2out_MEM, s_rd2_MEM, s_PCplus4_MEM, s_Inst_MEM : std_logic_vector(N-1 downto 0);

  signal s_Halt_WB, s_RegWr_WB, s_andlink_WB, s_memtoreg_WB : std_logic;
  signal s_ALUout_WB, s_DataLd_WB, s_PCplus4_WB, s_Inst_WB : std_logic_vector(N-1 downto 0);

begin

  P_CLK: process
  begin
    CLK <= '1';
    wait for gCLK_HPER;
    CLK <= '0';
    wait for gCLK_HPER;
  end process;

  s_PC_next <= std_logic_vector(unsigned(s_PC) + 4);
  s_PCplus4 <= s_PC_next;
  s_Inst    <= imem(s_PC);

  DUT_PC: pc_reg_sf
    generic map(WIDTH => N, RST_VAL => PC_RST, FLUSH_VAL => PC_RST)
    port map(i_CLK   => CLK,
             i_RST   => RST,
             i_stall => s_stall(R_PC),
             i_flush => s_flush(R_PC),
             i_Din   => s_PC_next,
             o_Dout  => s_PC);

  DUT_IF_ID: IF_ID
    generic map(WIDTH => N)
    port map(i_CLK     => CLK,
             i_RST     => RST,
             i_stall   => s_stall(R_IF_ID),
             i_flush   => s_flush(R_IF_ID),
             i_PC      => s_PC,
             i_PCplus4 => s_PCplus4,
             i_inst    => s_Inst,
             o_PC      => s_PC_ID,
             o_PCplus4 => s_PCplus4_ID,
             o_inst    => s_Inst_ID);

  DUT_ID_EX: ID_EX
    generic map(WIDTH => N)
    port map(i_CLK     => CLK,
             i_RST     => RST,
             i_stall   => s_stall(R_ID_EX),
             i_flush   => s_flush(R_ID_EX),
             i_halt    => '0',
             i_RegWr   => s_Inst_ID(31),
             i_andlink => '0',
             i_Mem2Reg => s_Inst_ID(30),
             i_MemRd   => s_Inst_ID(30),
             i_DMemWr  => '0',
             i_jumpreg => '0',
             i_jump    => '0',
             i_branch  => '0',
             i_alusrc  => s_Inst_ID(31),
             i_alusrca => s_Inst_ID(31 downto 30),
             i_aluop   => s_Inst_ID(31 downto 30),
             i_rd1     => s_Inst_ID,
             i_rd2     => s_PCplus4_ID,
             i_immgen  => s_PC_ID,
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

  DUT_EX_MEM: EX_MEM
    generic map(WIDTH => N)
    port map(i_CLK     => CLK,
             i_RST     => RST,
             i_stall   => s_stall(R_EX_MEM),
             i_flush   => s_flush(R_EX_MEM),
             i_halt    => s_Halt_EX,
             i_RegWr   => s_RegWr_EX,
             i_andlink => s_andlink_EX,
             i_Mem2Reg => s_memtoreg_EX,
             i_MemRd   => s_memread_EX,
             i_DMemWr  => s_DMemWr_EX,
             i_jumpreg => s_jumpreg_EX,
             i_jump    => s_jump_EX,
             i_pcsrc   => s_branch_EX,
             i_ALUout  => s_rd1_EX,
             i_add2out => s_PC_EX,
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
             o_ALUout  => s_ALUout_MEM,
             o_add2out => s_add2out_MEM,
             o_rd2     => s_rd2_MEM,
             o_PCplus4 => s_PCplus4_MEM,
             o_inst    => s_Inst_MEM);

  DUT_MEM_WB: MEM_WB
    generic map(WIDTH => N)
    port map(i_CLK     => CLK,
             i_RST     => RST,
             i_stall   => s_stall(R_MEM_WB),
             i_flush   => s_flush(R_MEM_WB),
             i_halt    => s_Halt_MEM,
             i_RegWr   => s_RegWr_MEM,
             i_andlink => s_andlink_MEM,
             i_Mem2Reg => s_memtoreg_MEM,
             i_ALUout  => s_ALUout_MEM,
             i_inst    => s_Inst_MEM,
             i_DataLd  => s_add2out_MEM,
             i_PCplus4 => s_PCplus4_MEM,
             o_halt    => s_Halt_WB,
             o_RegWr   => s_RegWr_WB,
             o_andlink => s_andlink_WB,
             o_Mem2Reg => s_memtoreg_WB,
             o_ALUout  => s_ALUout_WB,
             o_DataLd  => s_DataLd_WB,
             o_PCplus4 => s_PCplus4_WB,
             o_inst    => s_Inst_WB);

  P_TEST: process
    variable m_pc     : std_logic_vector(31 downto 0);
    variable m_if_id  : t_stage;
    variable m_id_ex  : t_stage;
    variable m_ex_mem : t_stage;
    variable m_mem_wb : t_stage;
    variable errs     : integer := 0;

    type t_hist is array (0 to 31) of std_logic_vector(31 downto 0);
    variable hist : t_hist;

    procedure expect(name : string; got, exp : std_logic_vector) is
    begin
      if got /= exp then
        errs := errs + 1;
        report "Test " & integer'image(s_test) & ": " & name & " = " & hex(got) &
               ", expected " & hex(exp) severity error;
      end if;
    end procedure;

    procedure expect_bit(name : string; got, exp : std_logic) is
    begin
      if got /= exp then
        errs := errs + 1;
        report "Test " & integer'image(s_test) & ": " & name & " = " & std_logic'image(got) &
               ", expected " & std_logic'image(exp) severity error;
      end if;
    end procedure;

    function step(cur, up : t_stage; stall, flush : std_logic) return t_stage is
    begin
      if flush = '1' then
        return STAGE_FLUSH;
      elsif stall = '1' then
        return cur;
      else
        return up;
      end if;
    end function;

    procedure check_all is
    begin
      expect("PC", s_PC, m_pc);

      expect("IF_ID.inst", s_Inst_ID, m_if_id.inst);
      expect("IF_ID.PC", s_PC_ID, m_if_id.pc);
      expect("IF_ID.PCplus4", s_PCplus4_ID, m_if_id.pcp4);

      expect("ID_EX.inst", s_Inst_EX, m_id_ex.inst);
      expect("ID_EX.PC", s_PC_EX, m_id_ex.pc);
      expect("ID_EX.PCplus4", s_PCplus4_EX, m_id_ex.pcp4);
      expect("ID_EX.rd1", s_rd1_EX, m_id_ex.data);
      expect("ID_EX.rd2", s_rd2_EX, m_id_ex.pcp4);
      expect("ID_EX.immgen", s_immgen_EX, m_id_ex.pc);
      expect("ID_EX.aluop", s_aluop_EX, m_id_ex.data(31 downto 30));
      expect_bit("ID_EX.RegWr", s_RegWr_EX, m_id_ex.data(31));
      expect_bit("ID_EX.MemRd", s_memread_EX, m_id_ex.data(30));
      expect_bit("ID_EX.alusrc", s_alusrc_EX, m_id_ex.data(31));

      expect("EX_MEM.inst", s_Inst_MEM, m_ex_mem.inst);
      expect("EX_MEM.ALUout", s_ALUout_MEM, m_ex_mem.data);
      expect("EX_MEM.add2out", s_add2out_MEM, m_ex_mem.pc);
      expect("EX_MEM.PCplus4", s_PCplus4_MEM, m_ex_mem.pcp4);
      expect("EX_MEM.rd2", s_rd2_MEM, m_ex_mem.pcp4);
      expect_bit("EX_MEM.RegWr", s_RegWr_MEM, m_ex_mem.data(31));
      expect_bit("EX_MEM.MemRd", s_memread_MEM, m_ex_mem.data(30));

      expect("MEM_WB.inst", s_Inst_WB, m_mem_wb.inst);
      expect("MEM_WB.ALUout", s_ALUout_WB, m_mem_wb.data);
      expect("MEM_WB.DataLd", s_DataLd_WB, m_mem_wb.pc);
      expect("MEM_WB.PCplus4", s_PCplus4_WB, m_mem_wb.pcp4);
      expect_bit("MEM_WB.RegWr", s_RegWr_WB, m_mem_wb.data(31));
      expect_bit("MEM_WB.Mem2Reg", s_memtoreg_WB, m_mem_wb.data(30));

      s_errors <= errs;
    end procedure;

    procedure cycle(stall, flush : std_logic_vector(4 downto 0)) is
      variable from_if, from_id, from_ex : t_stage;
    begin
      s_stall <= stall;
      s_flush <= flush;
      wait until rising_edge(CLK);

      from_if := (inst => imem(m_pc), pc => m_pc,
                  pcp4 => std_logic_vector(unsigned(m_pc) + 4), data => (others => '0'));
      from_id := m_if_id;
      from_id.data := m_if_id.inst;
      from_ex := m_id_ex;

      m_mem_wb := step(m_mem_wb, m_ex_mem, stall(R_MEM_WB), flush(R_MEM_WB));
      m_ex_mem := step(m_ex_mem, from_ex, stall(R_EX_MEM), flush(R_EX_MEM));
      m_id_ex  := step(m_id_ex, from_id, stall(R_ID_EX), flush(R_ID_EX));
      m_if_id  := step(m_if_id, from_if, stall(R_IF_ID), flush(R_IF_ID));

      if flush(R_PC) = '1' then
        m_pc := PC_RST;
      elsif stall(R_PC) = '0' then
        m_pc := std_logic_vector(unsigned(m_pc) + 4);
      end if;

      wait for 1 ns;
      check_all;
    end procedure;

    procedure run(count : integer) is
    begin
      for i in 1 to count loop
        cycle("00000", "00000");
      end loop;
    end procedure;

    function one_hot(r : integer) return std_logic_vector is
      variable v : std_logic_vector(4 downto 0) := (others => '0');
    begin
      v(r) := '1';
      return v;
    end function;

  begin
    s_test <= 0;
    RST <= '1';
    wait until rising_edge(CLK);
    wait for 1 ns;
    m_pc := PC_RST;
    m_if_id := STAGE_ZERO;
    m_id_ex := STAGE_ZERO;
    m_ex_mem := STAGE_ZERO;
    m_mem_wb := STAGE_ZERO;
    check_all;
    wait until falling_edge(CLK);
    RST <= '0';

    s_test <= 1;
    for c in 0 to 11 loop
      cycle("00000", "00000");
      hist(c) := s_Inst_ID;
      expect("IF_ID.inst (new value every cycle)", s_Inst_ID, imem(std_logic_vector(unsigned(PC_RST) + to_unsigned(4 * c, 32))));
      if c >= 3 then
        expect("MEM_WB.inst (IF_ID value 3 edges later)", s_Inst_WB, hist(c - 3));
      end if;
    end loop;

    s_test <= 2;
    for r in R_PC to R_MEM_WB loop
      cycle(one_hot(r), "00000");
      run(5);
    end loop;

    s_test <= 3;
    for r in R_PC to R_MEM_WB loop
      cycle("00000", one_hot(r));
      run(5);
    end loop;

    s_test <= 4;
    for r in R_PC to R_MEM_WB loop
      cycle(one_hot(r), one_hot(r));
      run(5);
    end loop;

    s_test <= 5;
    for r in R_IF_ID to R_MEM_WB loop
      cycle(one_hot(r), "00000");
      cycle(one_hot(r), "00000");
      cycle(one_hot(r), "00000");
      run(5);
    end loop;

    s_test <= 6;
    cycle("00011", "00100");
    run(5);

    s_test <= 7;
    cycle("00000", "01110");
    run(5);

    s_test <= 8;
    cycle("00011", "00010");
    run(5);

    s_test <= 9;
    cycle("11111", "00000");
    cycle("11111", "00000");
    run(5);

    s_test <= 10;
    cycle("00000", "11110");
    run(5);

    if errs = 0 then
      report "tb_Pipeline_Regs PASSED: all checks matched" severity note;
    else
      report "tb_Pipeline_Regs FAILED: " & integer'image(errs) & " mismatches" severity error;
    end if;
    s_errors <= errs;
    wait;
  end process;

end behavior;
