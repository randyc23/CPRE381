library IEEE;
use IEEE.std_logic_1164.all;

entity forwarding_unit is
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
end forwarding_unit;

architecture structural of forwarding_unit is

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

    signal s_eq_mem_rs1, s_eq_mem_rs2, s_eq_wb_rs1, s_eq_wb_rs2, s_eq_wb_rs2M : std_logic;
    signal s_rdM_zero, s_rdW_zero, s_rdM_nz, s_rdW_nz, s_nMemRd : std_logic;
    signal s_mem_valid, s_wb_valid : std_logic;
    signal s_fwdA_mem, s_fwdB_mem, s_nfwdA_mem, s_nfwdB_mem, s_fwdA_wb, s_fwdB_wb : std_logic;

begin

    G_EQ_MEM_RS1: cmp_eq_n generic map(N => 5) port map(i_A => i_rd_MEM, i_B => i_rs1_EX, o_EQ => s_eq_mem_rs1);
    G_EQ_MEM_RS2: cmp_eq_n generic map(N => 5) port map(i_A => i_rd_MEM, i_B => i_rs2_EX, o_EQ => s_eq_mem_rs2);
    G_EQ_WB_RS1: cmp_eq_n generic map(N => 5) port map(i_A => i_rd_WB, i_B => i_rs1_EX, o_EQ => s_eq_wb_rs1);
    G_EQ_WB_RS2: cmp_eq_n generic map(N => 5) port map(i_A => i_rd_WB, i_B => i_rs2_EX, o_EQ => s_eq_wb_rs2);
    G_EQ_WB_RS2M: cmp_eq_n generic map(N => 5) port map(i_A => i_rd_WB, i_B => i_rs2_MEM, o_EQ => s_eq_wb_rs2M);
    G_ZERO_MEM: cmp_eq_n generic map(N => 5) port map(i_A => i_rd_MEM, i_B => "00000", o_EQ => s_rdM_zero);
    G_ZERO_WB: cmp_eq_n generic map(N => 5) port map(i_A => i_rd_WB, i_B => "00000", o_EQ => s_rdW_zero);

    G_NZ_MEM: invg port map(i_A => s_rdM_zero, o_F => s_rdM_nz);
    G_NZ_WB: invg port map(i_A => s_rdW_zero, o_F => s_rdW_nz);
    G_NMEMRD: invg port map(i_A => i_MemRd_MEM, o_F => s_nMemRd);

    G_MEM_VALID: andg3 port map(i_A => i_RegWr_MEM, i_B => s_nMemRd, i_C => s_rdM_nz, o_F => s_mem_valid);
    G_WB_VALID: andg2 port map(i_A => i_RegWr_WB, i_B => s_rdW_nz, o_F => s_wb_valid);

    G_FWDA_MEM: andg2 port map(i_A => s_mem_valid, i_B => s_eq_mem_rs1, o_F => s_fwdA_mem);
    G_NFWDA_MEM: invg port map(i_A => s_fwdA_mem, o_F => s_nfwdA_mem);
    G_FWDA_WB: andg3 port map(i_A => s_wb_valid, i_B => s_eq_wb_rs1, i_C => s_nfwdA_mem, o_F => s_fwdA_wb);

    G_FWDB_MEM: andg2 port map(i_A => s_mem_valid, i_B => s_eq_mem_rs2, o_F => s_fwdB_mem);
    G_NFWDB_MEM: invg port map(i_A => s_fwdB_mem, o_F => s_nfwdB_mem);
    G_FWDB_WB: andg3 port map(i_A => s_wb_valid, i_B => s_eq_wb_rs2, i_C => s_nfwdB_mem, o_F => s_fwdB_wb);

    G_FWDM: andg3 port map(i_A => i_DMemWr_MEM, i_B => s_wb_valid, i_C => s_eq_wb_rs2M, o_F => o_ForwardM);

    o_ForwardA <= s_fwdA_mem & s_fwdA_wb;
    o_ForwardB <= s_fwdB_mem & s_fwdB_wb;

end structural;
