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
  port(s0               : in std_logic;
       iA               : in std_logic;
       iB               : in std_logic;
       oC               : out std_logic);

end mux2t1;

architecture structure of mux2t1 is

  component invg is 
    port(i_A                  : in std_logic;
         o_F                : out std_logic);
  end component;

  component andg2 is
    port(i_A                  : in std_logic;
         i_B                  : in std_logic;
         o_F                  : out std_logic);
  end component; 

  component org2 is 
    port(i_A                  : in std_logic;
         i_B                  : in std_logic;
         o_F                  : out std_logic);
  end component; 

  signal invS       : std_logic;
  signal w1         : std_Logic;
  signal w2         : std_logic;
  
begin
  g1: invg port map (i_A => s0, o_F => invS);
  g2: andg2 port map(i_A => iA, i_B => invS, o_F => w2);
  g3: andg2 port map(i_A => iB, i_B => s0, o_F => w1);
  g4: org2 port map(i_A => w1, i_B => w2, o_F => oC);
end structure;

