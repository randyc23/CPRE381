library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity tb_forwarding_unit is
end tb_forwarding_unit;

architecture behavior of tb_forwarding_unit is

  component forwarding_unit is
    port(i_rs1_EX     : in std_logic_vector(4 downto 0);
         i_rs2_EX     : in std_logic_vector(4 downto 0);
         i_rd_MEM     : in std_logic_vector(4 downto 0);
         i_RegWr_MEM  : in std_logic;
         i_MemRd_MEM  : in std_logic;
         i_rs2_MEM    : in std_logic_vector(4 downto 0);
         i_DMemWr_MEM : in std_logic;
         i_rd_WB      : in std_logic_vector(4 downto 0);
         i_RegWr_WB   : in std_logic;
         o_ForwardA   : out std_logic_vector(1 downto 0);
         o_ForwardB   : out std_logic_vector(1 downto 0);
         o_ForwardM   : out std_logic);
  end component;

  signal s_rs1_EX, s_rs2_EX, s_rd_MEM, s_rs2_MEM, s_rd_WB : std_logic_vector(4 downto 0) := (others => '0');
  signal s_RegWr_MEM, s_MemRd_MEM, s_DMemWr_MEM, s_RegWr_WB : std_logic := '0';
  signal s_ForwardA, s_ForwardB : std_logic_vector(1 downto 0);
  signal s_ForwardM : std_logic;
  signal s_case : integer := 0;

  function r(n : integer) return std_logic_vector is
  begin
    return std_logic_vector(to_unsigned(n, 5));
  end function;

  function ref_fwd(rs, rd_mem : std_logic_vector; regwr_mem, memrd_mem : std_logic;
                   rd_wb : std_logic_vector; regwr_wb : std_logic) return std_logic_vector is
  begin
    if regwr_mem = '1' and memrd_mem = '0' and unsigned(rd_mem) /= 0 and rd_mem = rs then
      return "10";
    elsif regwr_wb = '1' and unsigned(rd_wb) /= 0 and rd_wb = rs then
      return "01";
    else
      return "00";
    end if;
  end function;

  function ref_fwdm(rs2_mem : std_logic_vector; dmemwr_mem : std_logic;
                    rd_wb : std_logic_vector; regwr_wb : std_logic) return std_logic is
  begin
    if dmemwr_mem = '1' and regwr_wb = '1' and unsigned(rd_wb) /= 0 and rd_wb = rs2_mem then
      return '1';
    else
      return '0';
    end if;
  end function;

begin

  DUT: forwarding_unit
    port map(i_rs1_EX     => s_rs1_EX,
             i_rs2_EX     => s_rs2_EX,
             i_rd_MEM     => s_rd_MEM,
             i_RegWr_MEM  => s_RegWr_MEM,
             i_MemRd_MEM  => s_MemRd_MEM,
             i_rs2_MEM    => s_rs2_MEM,
             i_DMemWr_MEM => s_DMemWr_MEM,
             i_rd_WB      => s_rd_WB,
             i_RegWr_WB   => s_RegWr_WB,
             o_ForwardA   => s_ForwardA,
             o_ForwardB   => s_ForwardB,
             o_ForwardM   => s_ForwardM);

  P_TEST: process
    variable errs : integer := 0;
    variable seed1, seed2 : positive := 7;
    variable rnd : real;

    impure function rint(hi : integer) return integer is
    begin
      uniform(seed1, seed2, rnd);
      return integer(floor(rnd * real(hi + 1)));
    end function;

    impure function rbit return std_logic is
    begin
      if rint(1) = 1 then return '1'; else return '0'; end if;
    end function;

    type t_regs is array (0 to 5) of integer;
    constant REGS : t_regs := (0, 1, 16, 17, 30, 31);

    impure function rreg return std_logic_vector is
    begin
      return r(REGS(rint(5)));
    end function;

    procedure apply(name : string;
                    rs1_ex, rs2_ex, rd_mem : integer; regwr_mem, memrd_mem : std_logic;
                    rs2_mem : integer; dmemwr_mem : std_logic;
                    rd_wb : integer; regwr_wb : std_logic;
                    expA, expB : std_logic_vector(1 downto 0); expM : std_logic) is
    begin
      s_case <= s_case + 1;
      s_rs1_EX <= r(rs1_ex);
      s_rs2_EX <= r(rs2_ex);
      s_rd_MEM <= r(rd_mem);
      s_RegWr_MEM <= regwr_mem;
      s_MemRd_MEM <= memrd_mem;
      s_rs2_MEM <= r(rs2_mem);
      s_DMemWr_MEM <= dmemwr_mem;
      s_rd_WB <= r(rd_wb);
      s_RegWr_WB <= regwr_wb;
      wait for 10 ns;
      if s_ForwardA /= expA or s_ForwardB /= expB or s_ForwardM /= expM then
        errs := errs + 1;
        report name & ": got A=" & to_string(s_ForwardA) & " B=" & to_string(s_ForwardB) &
               " M=" & to_string(s_ForwardM) & ", expected A=" & to_string(expA) &
               " B=" & to_string(expB) & " M=" & to_string(expM) severity error;
      end if;
    end procedure;

  begin
    apply("no dependence",                       1, 2,   5,'1','0',  0,'0',   6,'1',  "00","00",'0');
    apply("EX/MEM -> rs1 (add; add)",            5, 2,   5,'1','0',  0,'0',   6,'1',  "10","00",'0');
    apply("EX/MEM -> rs2 (add; add)",            1, 5,   5,'1','0',  0,'0',   6,'1',  "00","10",'0');
    apply("EX/MEM -> rs1 and rs2",               5, 5,   5,'1','0',  0,'0',   6,'1',  "10","10",'0');
    apply("MEM/WB -> rs1 (add; x; add)",         6, 2,   5,'1','0',  0,'0',   6,'1',  "01","00",'0');
    apply("MEM/WB -> rs2 (add; x; add)",         1, 6,   5,'1','0',  0,'0',   6,'1',  "00","01",'0');
    apply("EX/MEM wins over MEM/WB",             7, 7,   7,'1','0',  0,'0',   7,'1',  "10","10",'0');
    apply("never forward x0 from EX/MEM",        0, 0,   0,'1','0',  0,'0',   6,'1',  "00","00",'0');
    apply("never forward x0 from MEM/WB",        0, 0,   5,'1','0',  0,'0',   0,'1',  "00","00",'0');
    apply("EX/MEM RegWr=0 (store/branch)",       5, 5,   5,'0','0',  0,'0',   6,'1',  "00","00",'0');
    apply("MEM/WB RegWr=0 (store/branch)",       6, 6,   5,'1','0',  0,'0',   6,'0',  "00","00",'0');
    apply("load in EX/MEM is not forwarded",     5, 5,   5,'1','1',  0,'0',   6,'1',  "00","00",'0');
    apply("load in EX/MEM, older match in WB",   5, 5,   5,'1','1',  0,'0',   5,'1',  "01","01",'0');
    apply("load in MEM/WB -> rs1 (lw; x; add)",  6, 2,   5,'1','0',  0,'0',   6,'1',  "01","00",'0');
    apply("jal link in EX/MEM -> rs1",           1, 2,   1,'1','0',  0,'0',   6,'1',  "10","00",'0');
    apply("ForwardM: lw x5; sw x5 (data)",       0, 0,   0,'0','0',  5,'1',   5,'1',  "00","00",'1');
    apply("ForwardM off: not a store",           0, 0,   0,'0','0',  5,'0',   5,'1',  "00","00",'0');
    apply("ForwardM off: rs2 differs",           0, 0,   0,'0','0',  4,'1',   5,'1',  "00","00",'0');
    apply("ForwardM off: rd x0",                 0, 0,   0,'0','0',  0,'1',   0,'1',  "00","00",'0');
    apply("ForwardM off: WB RegWr=0",            0, 0,   0,'0','0',  5,'1',   5,'0',  "00","00",'0');
    apply("rd_MEM x17 vs rs1 x1 (bit 4 differs)",  1, 2,  17,'1','0',  0,'0',   6,'1',  "00","00",'0');
    apply("rd_WB x21 vs rs2 x5 (bit 4 differs)",   1, 5,   9,'1','0',  0,'0',  21,'1',  "00","00",'0');
    apply("ForwardM rd x20 vs rs2 x4 (bit 4)",     0, 0,   0,'0','0',  4,'1',  20,'1',  "00","00",'0');
    apply("EX/MEM -> rs1 with x31",               31, 2,  31,'1','0',  0,'0',   6,'1',  "10","00",'0');

    for i in 1 to 2000 loop
      s_rs1_EX <= rreg;
      s_rs2_EX <= rreg;
      s_rd_MEM <= rreg;
      s_RegWr_MEM <= rbit;
      s_MemRd_MEM <= rbit;
      s_rs2_MEM <= rreg;
      s_DMemWr_MEM <= rbit;
      s_rd_WB <= rreg;
      s_RegWr_WB <= rbit;
      wait for 10 ns;
      if s_ForwardA /= ref_fwd(s_rs1_EX, s_rd_MEM, s_RegWr_MEM, s_MemRd_MEM, s_rd_WB, s_RegWr_WB) or
         s_ForwardB /= ref_fwd(s_rs2_EX, s_rd_MEM, s_RegWr_MEM, s_MemRd_MEM, s_rd_WB, s_RegWr_WB) or
         s_ForwardM /= ref_fwdm(s_rs2_MEM, s_DMemWr_MEM, s_rd_WB, s_RegWr_WB) then
        errs := errs + 1;
        report "random case " & integer'image(i) & " mismatch" severity error;
      end if;
    end loop;

    if errs = 0 then
      report "tb_forwarding_unit PASSED: all checks matched" severity note;
    else
      report "tb_forwarding_unit FAILED: " & integer'image(errs) & " mismatches" severity error;
    end if;
    wait;
  end process;

end behavior;
