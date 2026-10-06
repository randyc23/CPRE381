-------------------------------------------------------------------------
-- Joseph Zambreno
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- andg5.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a 5-input AND 
-- gate.
--
--
-- NOTES:
-- 8/19/16 by JAZ::Design created.
-- 1/16/19 by H3::Changed name to avoid name conflict with Quartus 
--         primitives.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity andg5 is

  port(i_A          : in std_logic;
       i_B          : in std_logic;
       i_C          : in std_logic;
       i_D          : in std_logic;
       i_E          : in std_logic;
       o_F          : out std_logic);

end andg5;

architecture dataflow of andg5 is
begin

  o_F <= i_A and i_B and i_C and i_D and i_E;
  
end dataflow;
