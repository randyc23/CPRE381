library IEEE;
use IEEE.std_logic_1164.all;

entity add_sub_N is
  generic(WIDTH : integer := 32);
  port(i_sub          : in std_logic;
       i_A            : in std_logic_vector(WIDTH-1 downto 0);
       i_B            : in std_logic_vector(WIDTH-1 downto 0);
       o_S            : out std_logic_vector(WIDTH-1 downto 0);
       less           : out std_logic_vector(WIDTH-1 downto 0));
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
         o_Cout : out std_logic;
         o_Cin_last : out std_logic);
  end component;

  signal i_Bxor : std_logic_vector(WIDTH-1 downto 0);
  signal as_out : std_logic_vector(WIDTH-1 downto 0);
  signal cin_last : std_logic;
  signal carry_out : std_logic;
  signal ovf : std_logic;
  signal less_bit : std_logic;
  

begin
  G_NBit_XOR: for i in 0 to WIDTH-1 generate
    XORI: xorg2 port map (i_A => i_B(i), i_B => i_sub, o_F => i_Bxor(i));
  end generate G_NBit_XOR;

  G_Nbit_FADD: Full_Adder_N 
    generic map(N => WIDTH)
    port map(i_Cin => i_sub, 
             i_A => i_A, 
             i_B => i_Bxor, 
             o_S => as_out, 
             o_Cout => carry_out,
             o_Cin_last => cin_last);
  G_OVF: xorg2 port map(i_A => cin_last, i_B => carry_out, o_F => ovf);
  G_Less: xorg2 port map(i_A => as_out(WIDTH-1), i_B => ovf, o_F => less_bit);

  o_S <= as_out;
  less(0)                <= less_bit;
  less(WIDTH-1 downto 1) <= (others => '0');
    
end mixed;
