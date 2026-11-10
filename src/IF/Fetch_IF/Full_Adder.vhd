-------------------------------------------------------------------------
-- Joseph Zambreno
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- Adder.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a behavioral 
-- signed adder operating on std_logic_vector inputs. 
--
--
-- NOTES: For simplicity, we cast to signed values before operating and cast back.
-- This design does not handle overflow.


-- 8/19/09 by JAZ::Design created.
-- 1/16/25 by CWS::Switched from integer to std_logic_vector and numeric_std.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Full_Adder is

  port(Cin               : in std_logic;
       iA               : in std_logic;
       iB               : in std_logic;
       s0               : out std_logic;
       Cout             : out std_logic);

end Full_Adder;

architecture structure of Full_Adder is

  component org2 is 
    port(i_A                  : in std_logic;
         i_B                  : in std_logic;
         o_F                  : out std_logic);
  end component;

  component andg2 is
    port(i_A                  : in std_logic;
         i_B                  : in std_logic;
         o_F                  : out std_logic);
  end component; 

  component xorg2 is 
    port(i_A                  : in std_logic;
         i_B                  : in std_logic;
         o_F                  : out std_logic);
  end component; 

  signal X       : std_logic;
  signal Y         : std_logic;
  signal Z         : std_logic;
  
begin
  g1: xorg2 port map (i_A => iA, i_B => iB, o_F => X);
  g2: xorg2 port map (i_A => X, i_B => Cin, o_F => s0);
  g3: andg2 port map(i_A => X, i_B => Cin, o_F => Y);
  g4: andg2 port map(i_A => iA, i_B => iB, o_F => Z);
  g5: org2 port map(i_A => Y, i_B => Z, o_F => Cout);
end structure;

