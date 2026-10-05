library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fill_logic is
  port(arith             : in std_logic;
       sign_bit          : in std_logic;
       bit_fill           : out std_logic);

end fill_logic;

architecture dataflow of fill_logic is

begin

  bit_fill <= (arith and sign_bit);
end dataflow;