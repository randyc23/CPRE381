library IEEE;
use IEEE.std_logic_1164.all;

entity EX_MEM is
    generic(WIDTH : integer);
    port(i_CLK  : in std_logic;
         i_RST  : in std_logic;
         i_stall : in std_logic;
         i_flush : in std_logic;
         i_halt : in std_logic;
         i_RegWr : in std_logic;
         i_andlink : in std_logic;
         i_Mem2Reg : in std_logic;
         i_MemRd : in std_logic;
         i_DMemWr : in std_logic;
         i_jumpreg : in std_logic;
         i_jump : in std_logic;
         i_pcsrc : in std_logic;
         i_ALUout : in std_logic_vector(WIDTH-1 downto 0);
         i_add2out : in std_logic_vector(WIDTH-1 downto 0);
         i_rd2 : in std_logic_vector(WIDTH-1 downto 0);
         i_PCplus4 : in std_logic_vector(WIDTH-1 downto 0);
         i_inst : in std_logic_vector(WIDTH-1 downto 0);
         o_halt : out std_logic;
         o_RegWr : out std_logic;
         o_andlink : out std_logic;
         o_Mem2Reg : out std_logic;
         o_MemRd : out std_logic;
         o_DMemWr : out std_logic;
         o_jumpreg : out std_logic;
         o_jump : out std_logic;
         o_pcsrc : out std_logic;
         o_ALUout : out std_logic_vector(WIDTH-1 downto 0);
         o_add2out : out std_logic_vector(WIDTH-1 downto 0);
         o_rd2 : out std_logic_vector(WIDTH-1 downto 0);
         o_PCplus4 : out std_logic_vector(WIDTH-1 downto 0);
         o_inst : out std_logic_vector(WIDTH-1 downto 0));
end EX_MEM;

architecture structural of EX_MEM is
    component reg_n_sf is
        generic(WIDTH     : integer;
                FLUSH_VAL : std_logic_vector(WIDTH-1 downto 0) := (others => '0'));
        port(i_CLK   : in std_logic;
             i_RST   : in std_logic;
             i_stall : in std_logic;
             i_flush : in std_logic;
             i_Din   : in std_logic_vector(WIDTH-1 downto 0);
             o_Dout  : out std_logic_vector(WIDTH-1 downto 0));
    end component;

    component dffg_sf is
        generic(FLUSH_VAL : std_logic := '0');
        port(i_CLK   : in std_logic;
             i_RST   : in std_logic;
             i_stall : in std_logic;
             i_flush : in std_logic;
             i_D     : in std_logic;
             o_Q     : out std_logic);
    end component;

    begin
        DFF_HALT: dffg_sf port map(i_CLK, i_RST, i_stall, i_flush, i_halt, o_halt);
        DFF_REGWR: dffg_sf port map(i_CLK, i_RST, i_stall, i_flush, i_RegWr, o_RegWr);
        DFF_ANDLINK: dffg_sf port map(i_CLK, i_RST, i_stall, i_flush, i_andlink, o_andlink);
        DFF_MEM2REG: dffg_sf port map(i_CLK, i_RST, i_stall, i_flush, i_Mem2Reg, o_Mem2Reg);
        DFF_MEMRD: dffg_sf port map(i_CLK, i_RST, i_stall, i_flush, i_MemRd, o_MemRd);
        DFF_DMEMWR: dffg_sf port map(i_CLK, i_RST, i_stall, i_flush, i_DMemWr, o_DMemWr);
        DFF_JUMPREG: dffg_sf port map(i_CLK, i_RST, i_stall, i_flush, i_jumpreg, o_jumpreg);
        DFF_JUMP: dffg_sf port map(i_CLK, i_RST, i_stall, i_flush, i_jump, o_jump);
        DFF_PCSRC: dffg_sf port map(i_CLK, i_RST, i_stall, i_flush, i_pcsrc, o_pcsrc);
        REG_ALUOUT: reg_n_sf generic map(WIDTH => WIDTH)
            port map(i_CLK, i_RST, i_stall, i_flush, i_ALUout, o_ALUout);
        REG_ADD2OUT: reg_n_sf generic map(WIDTH => WIDTH)
            port map(i_CLK, i_RST, i_stall, i_flush, i_add2out, o_add2out);
        REG_RD2: reg_n_sf generic map(WIDTH => WIDTH)
            port map(i_CLK, i_RST, i_stall, i_flush, i_rd2, o_rd2);
        REG_PCPLUS4: reg_n_sf generic map(WIDTH => WIDTH)
            port map(i_CLK, i_RST, i_stall, i_flush, i_PCplus4, o_PCplus4);
        REG_INST: reg_n_sf generic map(WIDTH => WIDTH, FLUSH_VAL => x"00000013")
            port map(i_CLK, i_RST, i_stall, i_flush, i_inst, o_inst);
end structural;
