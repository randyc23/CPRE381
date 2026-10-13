library IEEE;
use IEEE.std_logic_1164.all;

entity Full_Adder_N is
  generic(N : integer);
  port(i_Cin       : in std_logic;
       i_A         : in std_logic_vector(N-1 downto 0);
       i_B         : in std_logic_vector(N-1 downto 0);
       o_S         : out std_logic_vector(N-1 downto 0);
       o_Cout      : out std_logic);
end Full_Adder_N;

architecture mixed of Full_Adder_N is

  component Full_Adder is 
    port(Cin            : in std_logic;
       iA               : in std_logic;
       iB               : in std_logic;
       s0               : out std_logic;
       Cout             : out std_logic);
  end component;

  -- Signal to transport carry weights through adder
  signal s_Cout     : std_logic_Vector(N-2 downto 0);

  signal s_temp_sum : std_logic_vector(N-1 downto 0);
  signal s_temp_cout : std_logic;

begin
  g1: Full_Adder port map (Cin => i_Cin, iA => i_A(0), iB => i_B(0), s0 => s_temp_sum(0), Cout => s_Cout(0));
  
  G_NBit_FADD: for i in 1 to N-2 generate
    FADDI: Full_Adder port map(Cin => s_Cout(i-1), iA => i_A(i), iB => i_B(i), s0 => s_temp_sum(i), Cout => s_Cout(i));
  end generate G_NBit_FADD;
  
  g2: Full_Adder 
    port map(Cin => s_Cout(N-2), 
             iA => i_A(N-1), 
             iB => i_B(N-1), 
             s0 => s_temp_sum(N-1), 
             Cout => s_temp_cout);

  o_S <= s_temp_sum;
  o_Cout <= s_temp_cout;
  
end mixed;