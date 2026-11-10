library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mux32t1 is
generic(
    WIDTH_SEL   : integer := 5;
    NUM_INPUTS  : integer := 32);
port(
    i_sel       : in std_logic_vector(WIDTH_SEL-1 downto 0);
    i_inputs    : in std_logic_vector(NUM_INPUTS - 1 downto 0);
    o_out       : out std_logic
);
end mux32t1;

architecture dataflow of mux32t1 is
begin
    o_out <= i_inputs(to_integer(unsigned(i_sel)));
end dataflow;

    

