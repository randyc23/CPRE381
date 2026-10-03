library IEEE;
use IEEE.std_logic_1164.all;

entity add_sub_N is
  generic(WIDTH : integer := 32);
  port(i_Cin       : in std_logic;
       i_A         : in std_logic_vector(WIDTH-1 downto 0);
       i_B         : in std_logic_vector(WIDTH-1 downto 0);
       o_S         : out std_logic_vector(WIDTH-1 downto 0);
       o_Cout      : out std_logic);
end add_sub_N;

architecture mixed of add_sub_N is
  component xorg2 is 
    port(i_A : in std_logic;
         i_B : in std_logic;
         o_F : out std_logic);
  end component; 
  
  component Full_Adder_N is 
    generic(N : integer := WIDTH);
    port(i_Cin  : in std_logic;
         i_A    : in std_logic_vector(N-1 downto 0);
         i_B    : in std_logic_vector(N-1 downto 0);
         o_S    : out std_logic_vector(N-1 downto 0);
         o_Cout : out std_logic);
  end component;

  signal i_Bxor : std_logic_vector(WIDTH-1 downto 0);

begin
  G_NBit_XOR: for i in 0 to WIDTH-1 generate
    XORI: xorg2 port map (i_A => i_B(i), i_B => i_Cin, o_F => i_Bxor(i));
  end generate G_NBit_XOR;

  G_Nbit_FADD: Full_Adder_N 
    generic map(N => WIDTH)
    port map(i_Cin => i_Cin, 
             i_A => i_A, 
             i_B => i_Bxor, 
             o_S => o_S, 
             o_Cout => o_Cout);
    
end mixed;
