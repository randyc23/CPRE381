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

entity mux4t1_N is
  generic(N : integer); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_S          : in std_logic_vector(1 downto 0);
       i_D0         : in std_logic_vector(N-1 downto 0);
       i_D1         : in std_logic_vector(N-1 downto 0);
       i_D2         : in std_logic_vector(N-1 downto 0);
       i_D3         : in std_logic_vector(N-1 downto 0);
       o_O          : out std_logic_vector(N-1 downto 0));

end mux4t1_N;

architecture structural of mux4t1_N is

  component mux4t1 is
    port(s               : in std_logic_vector(1 downto 0);
         i0               : in std_logic;
         i1               : in std_logic;
         i2               : in std_logic;
         i3               : in std_logic;
         oC               : out std_logic);
  end component;

begin

  -- Instantiate N mux instances.
  G_NBit_MUX: for i in 0 to N-1 generate
    MUXI: mux4t1 port map(
              s       => i_S,      
              i0      => i_D0(i), 
              i1      => i_D1(i), 
              i2      => i_D2(i), 
              i3      => i_D3(i), 
              oC      => o_O(i));  
  end generate G_NBit_MUX;
  
end structural;
