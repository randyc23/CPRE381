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

architecture dataflow of forwarding_unit is

    signal s_mem_valid : std_logic;
    signal s_wb_valid  : std_logic;

begin

    s_mem_valid <= i_RegWr_MEM and (not i_MemRd_MEM) when i_rd_MEM /= "00000" else '0';
    s_wb_valid  <= i_RegWr_WB when i_rd_WB /= "00000" else '0';

    o_ForwardA <= "10" when (s_mem_valid = '1' and i_rd_MEM = i_rs1_EX) else
                  "01" when (s_wb_valid = '1' and i_rd_WB = i_rs1_EX) else
                  "00";

    o_ForwardB <= "10" when (s_mem_valid = '1' and i_rd_MEM = i_rs2_EX) else
                  "01" when (s_wb_valid = '1' and i_rd_WB = i_rs2_EX) else
                  "00";

    o_ForwardM <= '1' when (i_DMemWr_MEM = '1' and s_wb_valid = '1' and i_rd_WB = i_rs2_MEM) else
                  '0';

end dataflow;
