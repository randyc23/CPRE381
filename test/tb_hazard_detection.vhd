library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_hazard_detection is
end tb_hazard_detection;

architecture behavior of tb_hazard_detection is

  component hazard_detection is
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
  end component;

  signal s_inst_ID : std_logic_vector(31 downto 0) := x"00000013";
  signal s_MemRd_EX : std_logic := '0';
  signal s_rd_EX : std_logic_vector(4 downto 0) := (others => '0');
  signal s_pcsrc_EX, s_jump_EX, s_jumpreg_EX : std_logic := '0';
  signal s_PC_stall, s_IF_ID_stall, s_IF_ID_flush, s_ID_EX_flush, s_load_use, s_ctrl_taken : std_logic;

  function r(n : integer) return std_logic_vector is
  begin
    return std_logic_vector(to_unsigned(n, 5));
  end function;

  function r_type(rd, rs1, rs2 : integer) return std_logic_vector is
  begin
    return "0000000" & r(rs2) & r(rs1) & "000" & r(rd) & "0110011";
  end function;

  function i_type(op : std_logic_vector(6 downto 0); rd, rs1, imm : integer) return std_logic_vector is
  begin
    return std_logic_vector(to_signed(imm, 12)) & r(rs1) & "010" & r(rd) & op;
  end function;

  function s_type(rs2, rs1 : integer) return std_logic_vector is
  begin
    return "0000000" & r(rs2) & r(rs1) & "010" & "00000" & "0100011";
  end function;

  function b_type(rs1, rs2 : integer) return std_logic_vector is
  begin
    return "0000000" & r(rs2) & r(rs1) & "000" & "01000" & "1100011";
  end function;

  function u_type(op : std_logic_vector(6 downto 0); rd, imm20 : integer) return std_logic_vector is
  begin
    return std_logic_vector(to_unsigned(imm20, 20)) & r(rd) & op;
  end function;

  constant OP_IALU : std_logic_vector(6 downto 0) := "0010011";
  constant OP_LOAD : std_logic_vector(6 downto 0) := "0000011";
  constant OP_JALR : std_logic_vector(6 downto 0) := "1100111";
  constant OP_LUI  : std_logic_vector(6 downto 0) := "0110111";
  constant OP_AUIPC: std_logic_vector(6 downto 0) := "0010111";
  constant OP_JAL  : std_logic_vector(6 downto 0) := "1101111";
  constant WFI     : std_logic_vector(31 downto 0) := x"10500073";

begin

  DUT: hazard_detection
    port map(i_inst_ID     => s_inst_ID,
             i_MemRd_EX    => s_MemRd_EX,
             i_rd_EX       => s_rd_EX,
             i_pcsrc_EX    => s_pcsrc_EX,
             i_jump_EX     => s_jump_EX,
             i_jumpreg_EX  => s_jumpreg_EX,
             o_PC_stall    => s_PC_stall,
             o_IF_ID_stall => s_IF_ID_stall,
             o_IF_ID_flush => s_IF_ID_flush,
             o_ID_EX_flush => s_ID_EX_flush,
             o_load_use    => s_load_use,
             o_ctrl_taken  => s_ctrl_taken);

  P_TEST: process
    variable errs : integer := 0;

    procedure apply(name : string; memrd_ex : std_logic; rd_ex : integer;
                    inst_id : std_logic_vector(31 downto 0);
                    pcsrc, jump, jumpreg : std_logic;
                    exp_lu, exp_ctrl : std_logic) is
    begin
      s_MemRd_EX <= memrd_ex;
      s_rd_EX <= r(rd_ex);
      s_inst_ID <= inst_id;
      s_pcsrc_EX <= pcsrc;
      s_jump_EX <= jump;
      s_jumpreg_EX <= jumpreg;
      wait for 10 ns;
      if s_load_use /= exp_lu or s_PC_stall /= exp_lu or s_IF_ID_stall /= exp_lu or
         s_ctrl_taken /= exp_ctrl or s_IF_ID_flush /= exp_ctrl or
         s_ID_EX_flush /= (exp_lu or exp_ctrl) then
        errs := errs + 1;
        report name & ": got load_use=" & std_logic'image(s_load_use) &
               " ctrl=" & std_logic'image(s_ctrl_taken) &
               " IF_ID_flush=" & std_logic'image(s_IF_ID_flush) &
               " ID_EX_flush=" & std_logic'image(s_ID_EX_flush) &
               ", expected load_use=" & std_logic'image(exp_lu) &
               " ctrl=" & std_logic'image(exp_ctrl) severity error;
      end if;
    end procedure;

  begin
    -- load-use (part b), no control instruction in EX
    apply("lw x5; add x6,x5,x7   (rs1)",            '1', 5, r_type(6, 5, 7),            '0','0','0', '1','0');
    apply("lw x5; add x6,x7,x5   (rs2)",            '1', 5, r_type(6, 7, 5),            '0','0','0', '1','0');
    apply("lw x5; add x6,x7,x8   (independent)",    '1', 5, r_type(6, 7, 8),            '0','0','0', '0','0');
    apply("lw x5; addi x6,x5,1",                    '1', 5, i_type(OP_IALU, 6, 5, 1),   '0','0','0', '1','0');
    apply("lw x5; addi x6,x7,5   (imm = 5)",        '1', 5, i_type(OP_IALU, 6, 7, 5),   '0','0','0', '0','0');
    apply("lw x5; lw x6,0(x5)    (address)",        '1', 5, i_type(OP_LOAD, 6, 5, 0),   '0','0','0', '1','0');
    apply("lw x5; sw x6,0(x5)    (address)",        '1', 5, s_type(6, 5),               '0','0','0', '1','0');
    apply("lw x5; sw x5,0(x6)    (data: ForwardM)", '1', 5, s_type(5, 6),               '0','0','0', '0','0');
    apply("lw x5; beq x5,x0",                       '1', 5, b_type(5, 0),               '0','0','0', '1','0');
    apply("lw x5; bne x0,x5",                       '1', 5, b_type(0, 5),               '0','0','0', '1','0');
    apply("lw x5; jalr x1,0(x5)",                   '1', 5, i_type(OP_JALR, 1, 5, 0),   '0','0','0', '1','0');
    apply("lw x5; jal x1         (no rs)",          '1', 5, u_type(OP_JAL, 1, 16#05000#),   '0','0','0', '0','0');
    apply("lw x5; lui x6         (no rs)",          '1', 5, u_type(OP_LUI, 6, 16#28500#),   '0','0','0', '0','0');
    apply("lw x5; auipc x6       (no rs)",          '1', 5, u_type(OP_AUIPC, 6, 16#28500#), '0','0','0', '0','0');
    apply("lw x5; wfi",                             '1', 5, WFI,                        '0','0','0', '0','0');
    apply("lw x0; add x6,x0,x0   (x0)",             '1', 0, r_type(6, 0, 0),            '0','0','0', '0','0');
    apply("add x5 (not load); add x6,x5,x7",        '0', 5, r_type(6, 5, 7),            '0','0','0', '0','0');
    apply("bubble in EX; nop in ID",                '0', 0, x"00000013",                '0','0','0', '0','0');
    apply("lw x21; add x6,x5,x7  (bit 4 differs)",  '1', 21, r_type(6, 5, 7),           '0','0','0', '0','0');
    apply("lw x20; add x6,x7,x4  (bit 4 differs)",  '1', 20, r_type(6, 7, 4),           '0','0','0', '0','0');
    apply("lw x31; add x6,x31,x7",                  '1', 31, r_type(6, 31, 7),          '0','0','0', '1','0');
    apply("lw x16; sub x6,x7,x16",                  '1', 16, r_type(6, 7, 16),          '0','0','0', '1','0');

    -- control hazards (part c): control instruction in EX
    apply("beq taken in EX",                        '0', 0, r_type(6, 7, 8),            '1','0','0', '0','1');
    apply("branch not taken in EX",                 '0', 0, r_type(6, 7, 8),            '0','0','0', '0','0');
    apply("jal in EX",                              '0', 1, r_type(6, 7, 8),            '0','1','0', '0','1');
    apply("jalr in EX",                             '0', 1, r_type(6, 7, 8),            '0','0','1', '0','1');
    apply("taken branch, ID reads its rs (no load)",'0', 0, r_type(6, 5, 7),            '1','0','0', '0','1');
    apply("jal in EX, wfi on wrong path in ID",     '0', 1, WFI,                        '0','1','0', '0','1');
    apply("load-use and ctrl together (OR check)",  '1', 5, r_type(6, 5, 7),            '1','0','0', '1','1');

    if errs = 0 then
      report "tb_hazard_detection PASSED: all checks matched" severity note;
    else
      report "tb_hazard_detection FAILED: " & integer'image(errs) & " mismatches" severity error;
    end if;
    wait;
  end process;

end behavior;
