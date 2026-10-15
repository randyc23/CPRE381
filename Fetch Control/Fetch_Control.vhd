library IEEE;
use IEEE.std_logic_1164.all;

entity Fetch_Control is
  generic(N : integer);
  port(current_PC         : in std_logic_vector(N-1 downto 0);
       four         : in std_logic_vector(N-1 downto 0);
       immediate          : out std_logic_vector(N-1 downto 0)
       MemRead           : in std_logic;
       Zero              : in std_logic;
       PC_New          : out std_logic_vector(N-1 downto 0));
end Fetch_Control;

architecture structural of Fetch_Control is

  component Full_Adder_N is 
    port(Cin            : in std_logic;
       iA               : in std_logic;
       iB               : in std_logic;
       s0               : out std_logic;
       Cout             : out std_logic);
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
  signal or1out : std_logic;

begin
    adder1: Full_Adder_N port map(i_Cin => '0', i_A => current_PC, i_B => four, o_S => add1out, o_Cout => open);
    adder2: Full_Adder_N port map(i_Cin => '0', i_A => current_PC, i_B => immediate, o_S => add2out, o_Cout => open);
    org1: org2 port map(i_A => MemRead, i_B => Zero, o_F => or1out);
    mux1: mux2t1_N generic map(N => N) port map(i_S => or1out, i_D0 => add1out, i_D1 => add2out, o_O => PC_New);
end structural;