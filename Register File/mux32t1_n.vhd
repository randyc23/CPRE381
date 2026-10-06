-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- mux2t1_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide 2:1
-- mux using structural VHDL, generics, and generate statements.
--
--
-- NOTES:
-- 1/6/20 by H3::Created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.mux_arr.all;

entity mux32t1_n is
  generic(N : integer;
          WIDTH: integer;
          SEL: integer); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_SEL        : in std_logic_vector;
       i_array      : in vector_array(N-1 downto 0)(WIDTH - 1 downto 0);
       o_O          : out std_logic_vector(WIDTH-1 downto 0));

end mux32t1_N;

architecture dataflow of mux32t1_N is

    component mux32t1 is
        generic(
            WIDTH_SEL   : integer := SEL;
            NUM_INPUTS  : integer := N);
        port(
            i_sel       : in std_logic_vector(WIDTH_SEL-1 downto 0);
            i_inputs    : in std_logic_vector(NUM_INPUTS - 1 downto 0);
            o_out       : out std_logic
        );
    end component;
begin

  -- Instantiate N mux instances.
  G_NBit_MUX: for i in 0 to WIDTH-1 generate
    signal bits_for_mux :   std_logic_vector(N-1 downto 0);
begin
    BIT_GATHER: for j in 0 to N-1 generate
       bits_for_mux(j) <= i_array(j)(i);
    end generate BIT_GATHER;
    MUXI: mux32t1 port map(
              i_sel      => i_SEL,      -- All instances share the same select input.
              i_inputs   => bits_for_mux,  -- iterate the next bit with all 32 register's i'th feeding into the i'th mux instance
              o_out      => o_O(i));  -- ith instance's data output hooked up to ith data output.
  end generate G_NBit_MUX;
  
end dataflow;
-- if i_S == 0, D0 if de through, if i_S == 1, D1 is fed through