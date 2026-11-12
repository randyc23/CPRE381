library IEEE;
use IEEE.std_logic_1164.all;

entity WB is
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
end WB;

architecture structural of WB is

    component mux2t1_N is
        generic(N : integer);
        port(i_S          : in std_logic;
             i_D0         : in std_logic_vector(N-1 downto 0);
             i_D1         : in std_logic_vector(N-1 downto 0);
             o_O          : out std_logic_vector(N-1 downto 0));
    end component;

    signal s_mux2out : std_logic_vector(DATA_WIDTH-1 downto 0);

begin

    MEMTOREG_MUX: mux2t1_N
        generic map(N => DATA_WIDTH)
        port map(i_S  => i_Mem2Reg,
                 i_D0 => i_ALUout,
                 i_D1 => i_Ld_Data,
                 o_O  => s_mux2out);

    LINK_MUX: mux2t1_N
        generic map(N => DATA_WIDTH)
        port map(i_S  => i_andlink,
                 i_D0 => s_mux2out,
                 i_D1 => i_PCplus4,
                 o_O  => o_RegWrData);

    o_RegWrAddr <= i_inst(11 downto 7);
    o_RegWr     <= i_RegWr;
    o_halt      <= i_halt;

end structural;
