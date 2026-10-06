library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O

-- Usually name your testbench similar to below for clarity tb_<name>
-- TODO: change all instances of tb_TPU_MV_Element to reflect the new testbench.
entity tb_alu is
  generic(gCLK_HPER   : time := 10 ns;
          DATA_WIDTH  : integer := 32);   -- Generic for half of the clock cycle period
end tb_alu;

architecture mixed of tb_alu is

-- Define the total clock period time
constant cCLK_PER  : time := gCLK_HPER * 2;

-- We will be instantiating our design under test (DUT), so we need to specify its
-- component interface.
-- TODO: change component declaration as needed.
  component alu is
    generic(WIDTH : integer := DATA_WIDTH);
    port(i_A                : in std_logic_vector(WIDTH-1 downto 0);
         i_B                : in std_logic_vector(WIDTH-1 downto 0);
         AluCtrl            : in std_logic_vector(3 downto 0);
         zero               : out std_logic;
         AluOut             : out std_logic_vector(WIDTH-1 downto 0));
  end component;

-- Create signals for all of the inputs and outputs of the file that you are testing
-- := '0' or := (others => '0') just make all the signals start at an initial value of zero
signal CLK, reset    : std_logic := '0';

-- TODO: change input and output signals as needed.
signal s_A      : std_logic_vector(DATA_WIDTH-1 downto 0) := x"00000000";
signal s_B      : std_logic_vector(DATA_WIDTH-1 downto 0) := x"00000000";
signal s_AluCtrl : std_logic_vector(3 downto 0) := "0000";
signal s_AluOut   : std_logic_vector(DATA_WIDTH-1 downto 0);
signal s_zero     : std_logic;

begin

  -- TODO: Actually instantiate the component to test and wire all signals to the corresponding
  -- input or output. Note that DUT0 is just the name of the instance that can be seen 
  -- during simulation. What follows DUT0 is the entity name that will be used to find
  -- the appropriate library component during simulation loading.


  DUT0: alu
    generic map (WIDTH => DATA_WIDTH)
    port map(i_A => s_A,
             i_B => s_B,
             AluCtrl => s_AluCtrl,
             zero => s_zero,
             AluOut => s_AluOut);


  
  -- Assign inputs for each test case.
  -- TODO: add test cases as needed.
  P_TEST_CASES: process
  begin
    wait for gCLK_HPER/2; 

    -- add/addi
    s_A       <= x"00000005";
    s_B       <= x"00000003";
    s_AluCtrl <= "0000";
    wait for gCLK_HPER*2;
    assert s_AluOut = x"00000008" report "Test 1 (add): AluOut mismatch" severity error;
    assert s_zero = '0' report "Test 1 (add): zero mismatch" severity error;

    -- add/addi
    s_A       <= x"7FFFFFFF";
    s_B       <= x"00000001";
    s_AluCtrl <= "0000";
    wait for gCLK_HPER*2;
    assert s_AluOut = x"80000000" report "Test 2 (add): AluOut mismatch" severity error;
    assert s_zero = '0' report "Test 2 (add): zero mismatch" severity error;

    -- add/addi    
    s_A       <= x"FFFFFFFF";
    s_B       <= x"00000001";
    s_AluCtrl <= "0000";
    wait for gCLK_HPER*2;
    assert s_AluOut = x"00000000" report "Test 3 (add): AluOut mismatch" severity error;
    assert s_zero = '0' report "Test 3 (add): zero mismatch" severity error;

    -- sub
    s_A       <= x"00000005";
    s_B       <= x"00000003";
    s_AluCtrl <= "0001";
    wait for gCLK_HPER*2;
    assert s_AluOut = x"00000002" report "Test 4 (sub): AluOut mismatch" severity error;
    assert s_zero = '0' report "Test 4 (sub): zero mismatch" severity error;

    -- sub
    s_A       <= x"00000003";
    s_B       <= x"00000005";
    s_AluCtrl <= "0001";
    wait for gCLK_HPER*2;
    assert s_AluOut = x"FFFFFFFE" report "Test 5 (sub): AluOut mismatch" severity error;
    assert s_zero = '0' report "Test 5 (sub): zero mismatch" severity error;

    -- sub
    s_A       <= x"80000000";
    s_B       <= x"00000001";
    s_AluCtrl <= "0001";
    wait for gCLK_HPER*2;
    assert s_AluOut = x"7FFFFFFF" report "Test 6 (sub): AluOut mismatch" severity error;
    assert s_zero = '0' report "Test 6 (sub): zero mismatch" severity error;

    -- sub
    s_A       <= x"12345678";
    s_B       <= x"12345678";
    s_AluCtrl <= "0001";
    wait for gCLK_HPER*2;
    assert s_AluOut = x"00000000" report "Test 7 (sub): AluOut mismatch" severity error;
    assert s_zero = '1' report "Test 7 (sub): zero mismatch" severity error;

    -- slt/slti
    s_A       <= x"00000003";
    s_B       <= x"00000005";
    s_AluCtrl <= "0101";
    wait for gCLK_HPER*2;
    assert s_AluOut = x"00000001" report "Test 8 (slt): AluOut mismatch" severity error;
    assert s_zero = '0' report "Test 8 (slt): zero mismatch" severity error;

    -- slt/slti
    s_A       <= x"00000005";
    s_B       <= x"00000003";
    s_AluCtrl <= "0101";
    wait for gCLK_HPER*2;
    assert s_AluOut = x"00000000" report "Test 9 (slt): AluOut mismatch" severity error;
    assert s_zero = '0' report "Test 9 (slt): zero mismatch" severity error;

    -- slt/slti
    s_A       <= x"00000005";
    s_B       <= x"00000005";
    s_AluCtrl <= "0101";
    wait for gCLK_HPER*2;
    assert s_AluOut = x"00000000" report "Test 10 (slt): AluOut mismatch" severity error;
    assert s_zero = '1' report "Test 10 (slt): zero mismatch" severity error;

    -- slt/slti
    s_A       <= x"FFFFFFFF";
    s_B       <= x"00000001";
    s_AluCtrl <= "0101";
    wait for gCLK_HPER*2;
    assert s_AluOut = x"00000001" report "Test 11 (slt): AluOut mismatch" severity error;
    assert s_zero = '0' report "Test 11 (slt): zero mismatch" severity error;

    -- slt/slti
    s_A       <= x"00000001";
    s_B       <= x"FFFFFFFF";
    s_AluCtrl <= "0101";
    wait for gCLK_HPER*2;
    assert s_AluOut = x"00000000" report "Test 12 (slt): AluOut mismatch" severity error;
    assert s_zero = '0' report "Test 12 (slt): zero mismatch" severity error;

    -- slt/slti
    s_A       <= x"7FFFFFFF";
    s_B       <= x"FFFFFFFF";
    s_AluCtrl <= "0101";
    wait for gCLK_HPER*2;
    assert s_AluOut = x"00000000" report "Test 13 (slt): AluOut mismatch" severity error;
    assert s_zero = '0' report "Test 13 (slt): zero mismatch" severity error;

    -- slt/slti
    s_A       <= x"80000000";
    s_B       <= x"00000001";
    s_AluCtrl <= "0101";
    wait for gCLK_HPER*2;
    assert s_AluOut = x"00000001" report "Test 14 (slt): AluOut mismatch" severity error;
    assert s_zero = '0' report "Test 14 (slt): zero mismatch" severity error;

    -- sltu/sltiu
    s_A       <= x"00000003";
    s_B       <= x"00000005";
    s_AluCtrl <= "0111";
    wait for gCLK_HPER*2;
    assert s_AluOut = x"00000001" report "Test 30 (sltu): AluOut mismatch" severity error;
    assert s_zero = '0' report "Test 30 (sltu): zero mismatch" severity error;

    -- sltu/sltiu
    s_A       <= x"00000005";
    s_B       <= x"00000005";
    s_AluCtrl <= "0111";
    wait for gCLK_HPER*2;
    assert s_AluOut = x"00000000" report "Test 31 (sltu): AluOut mismatch" severity error;
    assert s_zero = '1' report "Test 31 (sltu): zero mismatch" severity error;

    -- sltu/sltiu
    s_A       <= x"FFFFFFFF";
    s_B       <= x"00000001";
    s_AluCtrl <= "0111";
    wait for gCLK_HPER*2;
    assert s_AluOut = x"00000000" report "Test 32 (sltu): AluOut mismatch" severity error;
    assert s_zero = '0' report "Test 32 (sltu): zero mismatch" severity error;

    -- sltu/sltiu
    s_A       <= x"00000001";
    s_B       <= x"FFFFFFFF";
    s_AluCtrl <= "0111";
    wait for gCLK_HPER*2;
    assert s_AluOut = x"00000001" report "Test 33 (sltu): AluOut mismatch" severity error;
    assert s_zero = '0' report "Test 33 (sltu): zero mismatch" severity error;

    -- sltu/sltiu
    s_A       <= x"7FFFFFFF";
    s_B       <= x"FFFFFFFF";
    s_AluCtrl <= "0111";
    wait for gCLK_HPER*2;
    assert s_AluOut = x"00000001" report "Test 34 (sltu): AluOut mismatch" severity error;
    assert s_zero = '0' report "Test 34 (sltu): zero mismatch" severity error;

    -- sltu/sltiu
    s_A       <= x"80000000";
    s_B       <= x"00000001";
    s_AluCtrl <= "0111";
    wait for gCLK_HPER*2;
    assert s_AluOut = x"00000000" report "Test 35 (sltu): AluOut mismatch" severity error;
    assert s_zero = '0' report "Test 35 (sltu): zero mismatch" severity error;

    -- and
    s_A       <= x"F0F0F0F0";
    s_B       <= x"FF00FF00";
    s_AluCtrl <= "1000";
    wait for gCLK_HPER*2;
    assert s_AluOut = x"F000F000" report "Test 15 (and): AluOut mismatch" severity error;
    assert s_zero = '0' report "Test 15 (and): zero mismatch" severity error;

    -- or
    s_A       <= x"F0F0F0F0";
    s_B       <= x"FF00FF00";
    s_AluCtrl <= "1001";
    wait for gCLK_HPER*2;
    assert s_AluOut = x"FFF0FFF0" report "Test 16 (or): AluOut mismatch" severity error;
    assert s_zero = '0' report "Test 16 (or): zero mismatch" severity error;

    -- xor
    s_A       <= x"F0F0F0F0";
    s_B       <= x"FF00FF00";
    s_AluCtrl <= "1010";
    wait for gCLK_HPER*2;
    assert s_AluOut = x"0FF00FF0" report "Test 17 (xor): AluOut mismatch" severity error;
    assert s_zero = '0' report "Test 17 (xor): zero mismatch" severity error;

    -- sll/slli
    s_A       <= x"00000001";
    s_B       <= x"0000001F";
    s_AluCtrl <= "1100";
    wait for gCLK_HPER*2;
    assert s_AluOut = x"80000000" report "Test 19 (sll): AluOut mismatch" severity error;
    assert s_zero = '0' report "Test 19 (sll): zero mismatch" severity error;

    -- sll/slli
    s_A       <= x"DEADBEEF";
    s_B       <= x"00000004";
    s_AluCtrl <= "1100";
    wait for gCLK_HPER*2;
    assert s_AluOut = x"EADBEEF0" report "Test 20 (sll): AluOut mismatch" severity error;
    assert s_zero = '0' report "Test 20 (sll): zero mismatch" severity error;

    -- sll/slli
    s_A       <= x"DEADBEEF";
    s_B       <= x"00000000";
    s_AluCtrl <= "1100";
    wait for gCLK_HPER*2;
    assert s_AluOut = x"DEADBEEF" report "Test 21 (sll): AluOut mismatch" severity error;
    assert s_zero = '0' report "Test 21 (sll): zero mismatch" severity error;

    -- sll/slli
    s_A       <= x"00000001";
    s_B       <= x"00000021";
    s_AluCtrl <= "1100";
    wait for gCLK_HPER*2;
    assert s_AluOut = x"00000002" report "Test 22 (sll): AluOut mismatch" severity error;
    assert s_zero = '0' report "Test 22 (sll): zero mismatch" severity error;

    -- srl/srli
    s_A       <= x"80000000";
    s_B       <= x"0000001F";
    s_AluCtrl <= "1101";
    wait for gCLK_HPER*2;
    assert s_AluOut = x"00000001" report "Test 23 (srl): AluOut mismatch" severity error;
    assert s_zero = '0' report "Test 23 (srl): zero mismatch" severity error;

    -- srl/srli
    s_A       <= x"DEADBEEF";
    s_B       <= x"00000004";
    s_AluCtrl <= "1101";
    wait for gCLK_HPER*2;
    assert s_AluOut = x"0DEADBEE" report "Test 24 (srl): AluOut mismatch" severity error;
    assert s_zero = '0' report "Test 24 (srl): zero mismatch" severity error;

    -- sra/srai
    s_A       <= x"80000000";
    s_B       <= x"0000001F";
    s_AluCtrl <= "1111";
    wait for gCLK_HPER*2;
    assert s_AluOut = x"FFFFFFFF" report "Test 25 (sra): AluOut mismatch" severity error;
    assert s_zero = '0' report "Test 25 (sra): zero mismatch" severity error;

    -- sra/srai
    s_A       <= x"DEADBEEF";
    s_B       <= x"00000004";
    s_AluCtrl <= "1111";
    wait for gCLK_HPER*2;
    assert s_AluOut = x"FDEADBEE" report "Test 26 (sra): AluOut mismatch" severity error;
    assert s_zero = '0' report "Test 26 (sra): zero mismatch" severity error;

    -- sra/srai
    s_A       <= x"7FFFFFFF";
    s_B       <= x"00000004";
    s_AluCtrl <= "1111";
    wait for gCLK_HPER*2;
    assert s_AluOut = x"07FFFFFF" report "Test 27 (sra): AluOut mismatch" severity error;
    assert s_zero = '0' report "Test 27 (sra): zero mismatch" severity error;

    -- xor
    s_A       <= x"80000000";
    s_B       <= x"00000000";
    s_AluCtrl <= "1010";
    wait for gCLK_HPER*2;
    assert s_AluOut = x"80000000" report "Test 28 (xor): AluOut mismatch" severity error;
    assert s_zero = '0' report "Test 28 (xor): zero mismatch" severity error;

    -- xor
    s_A       <= x"00000001";
    s_B       <= x"00000000";
    s_AluCtrl <= "1010";
    wait for gCLK_HPER*2;
    assert s_AluOut = x"00000001" report "Test 29 (xor): AluOut mismatch" severity error;
    assert s_zero = '0' report "Test 29 (xor): zero mismatch" severity error;

    report "All test cases complete" severity note;
    wait;
  end process;

end mixed;