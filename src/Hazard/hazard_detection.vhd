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

architecture structural of hazard_detection is

    component cmp_eq_n is
        generic(N : integer);
        port(i_A  : in std_logic_vector(N-1 downto 0);
             i_B  : in std_logic_vector(N-1 downto 0);
             o_EQ : out std_logic);
    end component;

    component invg is
        port(i_A : in std_logic;
             o_F : out std_logic);
    end component;

    component andg2 is
        port(i_A : in std_logic;
             i_B : in std_logic;
             o_F : out std_logic);
    end component;

    component andg3 is
        port(i_A : in std_logic;
             i_B : in std_logic;
             i_C : in std_logic;
             o_F : out std_logic);
    end component;

    component org2 is
        port(i_A : in std_logic;
             i_B : in std_logic;
             o_F : out std_logic);
    end component;

    component org3 is
        port(i_A : in std_logic;
             i_B : in std_logic;
             i_C : in std_logic;
             o_F : out std_logic);
    end component;

    signal s_is_rtype, s_is_ialu, s_is_load, s_is_store, s_is_branch, s_is_jalr : std_logic;
    signal s_rs1_grp1, s_rs1_grp2, s_uses_rs1, s_uses_rs2 : std_logic;
    signal s_eq_rs1, s_eq_rs2, s_rd_zero, s_rd_nz : std_logic;
    signal s_hit_rs1, s_hit_rs2, s_hit : std_logic;
    signal s_load_use, s_ctrl : std_logic;

begin

    G_OP_RTYPE: cmp_eq_n generic map(N => 7) port map(i_A => i_inst_ID(6 downto 0), i_B => "0110011", o_EQ => s_is_rtype);
    G_OP_IALU: cmp_eq_n generic map(N => 7) port map(i_A => i_inst_ID(6 downto 0), i_B => "0010011", o_EQ => s_is_ialu);
    G_OP_LOAD: cmp_eq_n generic map(N => 7) port map(i_A => i_inst_ID(6 downto 0), i_B => "0000011", o_EQ => s_is_load);
    G_OP_STORE: cmp_eq_n generic map(N => 7) port map(i_A => i_inst_ID(6 downto 0), i_B => "0100011", o_EQ => s_is_store);
    G_OP_BRANCH: cmp_eq_n generic map(N => 7) port map(i_A => i_inst_ID(6 downto 0), i_B => "1100011", o_EQ => s_is_branch);
    G_OP_JALR: cmp_eq_n generic map(N => 7) port map(i_A => i_inst_ID(6 downto 0), i_B => "1100111", o_EQ => s_is_jalr);

    G_RS1_GRP1: org3 port map(i_A => s_is_rtype, i_B => s_is_ialu, i_C => s_is_load, o_F => s_rs1_grp1);
    G_RS1_GRP2: org3 port map(i_A => s_is_store, i_B => s_is_branch, i_C => s_is_jalr, o_F => s_rs1_grp2);
    G_USES_RS1: org2 port map(i_A => s_rs1_grp1, i_B => s_rs1_grp2, o_F => s_uses_rs1);
    G_USES_RS2: org2 port map(i_A => s_is_rtype, i_B => s_is_branch, o_F => s_uses_rs2);

    G_EQ_RS1: cmp_eq_n generic map(N => 5) port map(i_A => i_rd_EX, i_B => i_inst_ID(19 downto 15), o_EQ => s_eq_rs1);
    G_EQ_RS2: cmp_eq_n generic map(N => 5) port map(i_A => i_rd_EX, i_B => i_inst_ID(24 downto 20), o_EQ => s_eq_rs2);
    G_RD_ZERO: cmp_eq_n generic map(N => 5) port map(i_A => i_rd_EX, i_B => "00000", o_EQ => s_rd_zero);
    G_RD_NZ: invg port map(i_A => s_rd_zero, o_F => s_rd_nz);

    G_HIT_RS1: andg2 port map(i_A => s_uses_rs1, i_B => s_eq_rs1, o_F => s_hit_rs1);
    G_HIT_RS2: andg2 port map(i_A => s_uses_rs2, i_B => s_eq_rs2, o_F => s_hit_rs2);
    G_HIT: org2 port map(i_A => s_hit_rs1, i_B => s_hit_rs2, o_F => s_hit);
    G_LOAD_USE: andg3 port map(i_A => i_MemRd_EX, i_B => s_rd_nz, i_C => s_hit, o_F => s_load_use);

    G_CTRL: org3 port map(i_A => i_pcsrc_EX, i_B => i_jump_EX, i_C => i_jumpreg_EX, o_F => s_ctrl);
    G_ID_EX_FLUSH: org2 port map(i_A => s_load_use, i_B => s_ctrl, o_F => o_ID_EX_flush);

    o_PC_stall    <= s_load_use;
    o_IF_ID_stall <= s_load_use;
    o_load_use    <= s_load_use;
    o_IF_ID_flush <= s_ctrl;
    o_ctrl_taken  <= s_ctrl;

end structural;
