-------------------------------------------------------------------------
-- Justin Adrowski
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- TPU_MV_Element.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a 2:1 Mux
--
-- 1/16/25 by CWS::Switched from integer to std_logic_vector and numeric_std.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mux2t1 is
  port(s               : in std_logic_vector(1 downto 0);
       i0               : in std_logic;
       i1               : in std_logic;
       i2               : in std_logic;
       i3               : in std_logic;
       oC               : out std_logic);

end mux2t1;

architecture structure of mux2t1 is

  component mux2t1 is 
    port(s0               : in std_logic;
         iA               : in std_logic;
         iB               : in std_logic;
         oC               : out std_logic);
  end component; 

  signal m0       : std_logic;
  signal m1         : std_Logic;
  
begin
  g1: mux2t1 port map (s0 => s[0], iA => i0, iB => i1, oC => m0);
  g2: mux2t1 port map(s0 => s[0], iA => i2, iB => i3, oC => m1);
  g3: mux2t1 port map(s0 => s[1], iA => m0, iB => m1, oC => oC);
end structure;

