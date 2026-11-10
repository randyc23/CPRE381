library IEEE;
use IEEE.std_logic_1164.all;
 
entity immgen is
    port (
        inst      : in  std_logic_vector(31 downto 0);
        immediate : out std_logic_vector(31 downto 0)
    );
end immgen;
 
architecture dataflow of immgen is
 
    signal sign_ext : std_logic_vector(31 downto 0);
 
begin
 
    sign_ext <= (others => inst(31));
 
    with inst(6 downto 0) select
        immediate <=
            sign_ext(31 downto 12) & inst(31 downto 20) -- sign extends the bits 31 to 12, and sets bits 11 to 0 as instruction bits 31 to 20 (I-Type)
                when "0010011" | "0000011" | "1100111",
            sign_ext(31 downto 12) & inst(31 downto 25) & inst(11 downto 7) -- sign extends the bits 31 to 12, and sets bits 11 to 0 as instruction bits 31 to 25 and 11 to 7 (S-Type)
                when "0100011",
            sign_ext(31 downto 12) & inst(7) & inst(30 downto 25) & inst(11 downto 8) & '0' -- sign extends bits 31 to 12, sets inst bit 7 as imm bit 11, inst bits 30 to 25 as imm bits 10 to 5, inst bits 11 to 8 as imm bits 4 to 1, and 0 as imm bit 0 (B-Type)
                when "1100011",
            inst(31 downto 12) & x"000" -- loads upper 20 bits of instruction into immmediate upper 20 bits, sets rest of bits as 0 (U-Type)
                when "0110111" | "0010111",
            sign_ext(31 downto 20) & inst(19 downto 12) & inst(20) & inst(30 downto 21) & '0' -- sign extends upper 12 bits (imm bit 20 included), sets inst bits  19 to 12 as imm bits 19 to 12, sets inst bit 20 as imm bit 11, sets inst bits 30 to 21 as imm bits 10 to 1, sets zero as imm bit 0 (J-Type)
                when "1101111",
            (others => '0') -- R-Type has no immediate
                when others;
 
end dataflow;
