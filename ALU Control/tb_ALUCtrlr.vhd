library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O

-- Usually name your testbench similar to below for clarity tb_<name>
-- TODO: change all instances of tb_TPU_MV_Element to reflect the new testbench.
entity tb_aluctrlr is
  generic(gCLK_HPER   : time := 10 ns;
          DATA_WIDTH  : integer := 32);   -- Generic for half of the clock cycle period
end tb_aluctrlr;

architecture mixed of tb_aluctrlr is

-- Define the total clock period time
constant cCLK_PER  : time := gCLK_HPER * 2;

-- We will be instantiating our design under test (DUT), so we need to specify its
-- component interface.
-- TODO: change component declaration as needed.
  component aluctrlr is
    generic(WIDTH : integer);
    port(inst                : in std_logic_vector(WIDTH-1 downto 0);
         aluop                : in std_logic_vector(1 downto 0);
         Aluctrl             : out std_logic_vector(3 downto 0));
  end component;

-- Create signals for all of the inputs and outputs of the file that you are testing
-- := '0' or := (others => '0') just make all the signals start at an initial value of zero
signal CLK, reset    : std_logic := '0';

-- TODO: change input and output signals as needed.
signal s_inst      : std_logic_vector(DATA_WIDTH-1 downto 0) := x"00000000";
signal s_aluop      : std_logic_vector(1 downto 0) := "00";
signal s_AluCtrl : std_logic_vector(3 downto 0) := "0000";

begin

    DUT0: aluctrlr
    generic map(WIDTH => DATA_WIDTH)
    port map(inst => s_inst,
             aluop => s_aluop,
             Aluctrl => s_AluCtrl);

    -- inst(30)    -> x"40000000"
    -- inst(14:12) -> x"0000F000" (funct3 is the 4th hex digit from the right)
    P_TEST_CASES: process
    begin
        wait for gCLK_HPER/2;


        s_inst <= x"00000000"; s_aluop <= "00"; wait for cCLK_PER;
        s_inst <= x"00000000"; s_aluop <= "01"; wait for cCLK_PER;
        s_inst <= x"00000000"; s_aluop <= "10"; wait for cCLK_PER;
        s_inst <= x"00000000"; s_aluop <= "11"; wait for cCLK_PER;

        ------------------------------------------------------------------
        -- I-type (aluop = "11"). Rows with inst30 = x are tested with both 0 and 1.
        ------------------------------------------------------------------
        -- x 000 -> 0000 (addi)
        s_inst <= x"00000000"; s_aluop <= "11"; wait for cCLK_PER;
        assert s_AluCtrl = "0000" report "I: 0 000 expected 0000" severity error;
        s_inst <= x"40000000"; s_aluop <= "11"; wait for cCLK_PER;
        assert s_AluCtrl = "0000" report "I: 1 000 expected 0000" severity error;

        -- 0 001 -> 1100 (slli)
        s_inst <= x"00001000"; s_aluop <= "11"; wait for cCLK_PER;
        assert s_AluCtrl = "1100" report "I: 0 001 expected 1100" severity error;

        -- x 010 -> 0101 (slti)
        s_inst <= x"00002000"; s_aluop <= "11"; wait for cCLK_PER;
        assert s_AluCtrl = "0101" report "I: 0 010 expected 0101" severity error;
        s_inst <= x"40002000"; s_aluop <= "11"; wait for cCLK_PER;
        assert s_AluCtrl = "0101" report "I: 1 010 expected 0101" severity error;

        -- x 011 -> 0111 (sltiu)
        s_inst <= x"00003000"; s_aluop <= "11"; wait for cCLK_PER;
        assert s_AluCtrl = "0111" report "I: 0 011 expected 0111" severity error;
        s_inst <= x"40003000"; s_aluop <= "11"; wait for cCLK_PER;
        assert s_AluCtrl = "0111" report "I: 1 011 expected 0111" severity error;

        -- x 100 -> 1010 (xori)
        s_inst <= x"00004000"; s_aluop <= "11"; wait for cCLK_PER;
        assert s_AluCtrl = "1010" report "I: 0 100 expected 1010" severity error;
        s_inst <= x"40004000"; s_aluop <= "11"; wait for cCLK_PER;
        assert s_AluCtrl = "1010" report "I: 1 100 expected 1010" severity error;

        -- 0 101 -> 1101 (srli)
        s_inst <= x"00005000"; s_aluop <= "11"; wait for cCLK_PER;
        assert s_AluCtrl = "1101" report "I: 0 101 expected 1101" severity error;

        -- 1 101 -> 1111 (srai)
        s_inst <= x"40005000"; s_aluop <= "11"; wait for cCLK_PER;
        assert s_AluCtrl = "1111" report "I: 1 101 expected 1111" severity error;

        -- x 110 -> 1001 (ori)
        s_inst <= x"00006000"; s_aluop <= "11"; wait for cCLK_PER;
        assert s_AluCtrl = "1001" report "I: 0 110 expected 1001" severity error;
        s_inst <= x"40006000"; s_aluop <= "11"; wait for cCLK_PER;
        assert s_AluCtrl = "1001" report "I: 1 110 expected 1001" severity error;

        -- x 111 -> 1000 (andi)
        s_inst <= x"00007000"; s_aluop <= "11"; wait for cCLK_PER;
        assert s_AluCtrl = "1000" report "I: 0 111 expected 1000" severity error;
        s_inst <= x"40007000"; s_aluop <= "11"; wait for cCLK_PER;
        assert s_AluCtrl = "1000" report "I: 1 111 expected 1000" severity error;

        ------------------------------------------------------------------
        -- R-type (aluop = "10")
        ------------------------------------------------------------------
        -- 0 000 -> 0000 (add)
        s_inst <= x"00000000"; s_aluop <= "10"; wait for cCLK_PER;
        assert s_AluCtrl = "0000" report "R: 0 000 expected 0000" severity error;

        -- 1 000 -> 0001 (sub)
        s_inst <= x"40000000"; s_aluop <= "10"; wait for cCLK_PER;
        assert s_AluCtrl = "0001" report "R: 1 000 expected 0001" severity error;

        -- 0 001 -> 1100 (sll)
        s_inst <= x"00001000"; s_aluop <= "10"; wait for cCLK_PER;
        assert s_AluCtrl = "1100" report "R: 0 001 expected 1100" severity error;

        -- 0 010 -> 0101 (slt)
        s_inst <= x"00002000"; s_aluop <= "10"; wait for cCLK_PER;
        assert s_AluCtrl = "0101" report "R: 0 010 expected 0101" severity error;

        -- 0 011 -> 0111 (sltu)
        s_inst <= x"00003000"; s_aluop <= "10"; wait for cCLK_PER;
        assert s_AluCtrl = "0111" report "R: 0 011 expected 0111" severity error;

        -- 0 100 -> 1010 (xor)
        s_inst <= x"00004000"; s_aluop <= "10"; wait for cCLK_PER;
        assert s_AluCtrl = "1010" report "R: 0 100 expected 1010" severity error;

        -- 0 101 -> 1101 (srl)
        s_inst <= x"00005000"; s_aluop <= "10"; wait for cCLK_PER;
        assert s_AluCtrl = "1101" report "R: 0 101 expected 1101" severity error;

        -- 1 101 -> 1111 (sra)
        s_inst <= x"40005000"; s_aluop <= "10"; wait for cCLK_PER;
        assert s_AluCtrl = "1111" report "R: 1 101 expected 1111" severity error;

        -- 0 110 -> 1001 (or)
        s_inst <= x"00006000"; s_aluop <= "10"; wait for cCLK_PER;
        assert s_AluCtrl = "1001" report "R: 0 110 expected 1001" severity error;

        -- 0 111 -> 1000 (and)
        s_inst <= x"00007000"; s_aluop <= "10"; wait for cCLK_PER;
        assert s_AluCtrl = "1000" report "R: 0 111 expected 1000" severity error;

        wait;
    end process;

end mixed;
