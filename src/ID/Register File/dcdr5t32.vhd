library IEEE;
use IEEE.std_logic_1164.all;

entity dcdr5t32 is
    generic(
        WIDTH_IN : integer := 5;
        WIDTH_OUT: integer := 32
    );
    port(
        i_we  : in std_logic;
        i_sel : in std_logic_vector(WIDTH_IN - 1 downto 0);
        o_out : out std_logic_vector(WIDTH_OUT - 1 downto 0)
    );
end dcdr5t32;

architecture dataflow of dcdr5t32 is
    begin
        process(i_sel, i_we)
        begin
            if (i_we = '1') then
                case i_sel is
                    when b"00000" =>
                        o_out <= x"00000000";
                    when b"00001" =>
                        o_out <= x"00000002";
                    when b"00010" =>
                        o_out <= x"00000004";
                    when b"00011" =>
                        o_out <= x"00000008";
                    when b"00100" =>
                        o_out <= x"00000010";
                    when b"00101" =>
                        o_out <= x"00000020";
                    when b"00110" =>
                        o_out <= x"00000040";
                    when b"00111" =>
                        o_out <= x"00000080";
                    when b"01000" =>
                        o_out <= x"00000100";
                    when b"01001" =>
                        o_out <= x"00000200";
                    when b"01010" =>
                        o_out <= x"00000400";
                    when b"01011" =>
                        o_out <= x"00000800";
                    when b"01100" =>
                        o_out <= x"00001000";
                    when b"01101" =>
                        o_out <= x"00002000";
                    when b"01110" =>
                        o_out <= x"00004000";
                    when b"01111" =>
                        o_out <= x"00008000";
                    when b"10000" =>
                        o_out <= x"00010000";
                    when b"10001" =>
                        o_out <= x"00020000";
                    when b"10010" =>
                        o_out <= x"00040000";
                    when b"10011" =>
                        o_out <= x"00080000";
                    when b"10100" =>
                        o_out <= x"00100000";
                    when b"10101" =>
                        o_out <= x"00200000";
                    when b"10110" =>
                        o_out <= x"00400000";
                    when b"10111" =>
                        o_out <= x"00800000";
                    when b"11000" =>
                        o_out <= x"01000000";
                    when b"11001" =>
                        o_out <= x"02000000";
                    when b"11010" =>
                        o_out <= x"04000000";
                    when b"11011" =>
                        o_out <= x"08000000";
                    when b"11100" =>
                        o_out <= x"10000000";
                    when b"11101" =>
                        o_out <= x"20000000";
                    when b"11110" =>
                        o_out <= x"40000000";
                    when b"11111" =>
                        o_out <= x"80000000";
                    when others =>
                        o_out <= (others => '0');
                end case;
            else 
                o_out <= x"00000000";
            end if;
        end process;
end dataflow;
