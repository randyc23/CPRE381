-------------------------------------------------------------------------
-- Joseph Zambreno
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- org4.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a 4-input OR 
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

entity org4 is

  port(i_A          : in std_logic;
       i_B          : in std_logic;
       i_C          : in std_logic;
       i_D          : in std_logic;
       o_F          : out std_logic);

end org4;

architecture dataflow of org4 is
begin

  o_F <= i_A or i_B or i_C or i_D;
  
end dataflow;
