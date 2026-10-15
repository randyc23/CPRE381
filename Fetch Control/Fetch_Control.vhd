library IEEE;
use IEEE.std_logic_1164.all;

entity Fetch_Control is
  generic(N : integer);
  port(current_PC         : in std_logic_vector(N-1 downto 0);
       four               : in std_logic_vector(N-1 downto 0);
       immediate          : in std_logic_vector(N-1 downto 0);
       ALU_Result         : in std_logic_vector(N-1 downto 0);
       PCSrc              : in std_logic;
       Jump               : in std_logic;
       JumpReg            : in std_logic;
       PC_Plus4           : out std_logic_vector(N-1 downto 0);
       PC_New             : out std_logic_vector(N-1 downto 0));
end Fetch_Control;

architecture structural of Fetch_Control is

  component Full_Adder_N is
    generic(N : integer);
    port(i_Cin       : in std_logic;
         i_A         : in std_logic_vector(N-1 downto 0);
         i_B         : in std_logic_vector(N-1 downto 0);
         o_S         : out std_logic_vector(N-1 downto 0);
         o_Cout      : out std_logic);
  end component;

  component mux2t1_N is
    generic(N : integer);
    port(i_S          : in std_logic;
         i_D0         : in std_logic_vector(N-1 downto 0);
         i_D1         : in std_logic_vector(N-1 downto 0);
         o_O          : out std_logic_vector(N-1 downto 0));
  end component;

  component org2 is
    port(i_A                  : in std_logic;
         i_B                  : in std_logic;
         o_F                  : out std_logic);
  end component;

  signal add1out : std_logic_vector(N-1 downto 0);
  signal add2out : std_logic_vector(N-1 downto 0);
  signal mux1out : std_logic_vector(N-1 downto 0);
  signal jalr_target : std_logic_vector(N-1 downto 0);
  signal or1out : std_logic;

begin
    adder1: Full_Adder_N generic map(N => N) port map(i_Cin => '0', i_A => current_PC, i_B => four, o_S => add1out, o_Cout => open);
    adder2: Full_Adder_N generic map(N => N) port map(i_Cin => '0', i_A => current_PC, i_B => immediate, o_S => add2out, o_Cout => open);
    org1: org2 port map(i_A => PCSrc, i_B => Jump, o_F => or1out);
    mux1: mux2t1_N generic map(N => N) port map(i_S => or1out, i_D0 => add1out, i_D1 => add2out, o_O => mux1out);
    jalr_target <= ALU_Result(N-1 downto 1) & '0';
    mux2: mux2t1_N generic map(N => N) port map(i_S => JumpReg, i_D0 => mux1out, i_D1 => jalr_target, o_O => PC_New);
    PC_Plus4 <= add1out;
end structural;
