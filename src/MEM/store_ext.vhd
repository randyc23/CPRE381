library IEEE;
use IEEE.std_logic_1164.all;

entity store_ext is
    port(i_data  : in  std_logic_vector(31 downto 0);
         addr    : in  std_logic_vector(1 downto 0);
         funct3  : in  std_logic_vector(2 downto 0);
         o_data  : out std_logic_vector(31 downto 0);
         o_be    : out std_logic_vector(3 downto 0));
end store_ext;

architecture dataflow of store_ext is

    signal s_be_byte, s_be_half : std_logic_vector(3 downto 0);

begin

    with addr select
        s_be_byte <= "0001" when "00",
                     "0010" when "01",
                     "0100" when "10",
                     "1000" when others;

    with addr(1) select
        s_be_half <= "0011" when '0',
                     "1100" when others;

    with funct3(1 downto 0) select
        o_data <= i_data(7 downto 0) & i_data(7 downto 0) & i_data(7 downto 0) & i_data(7 downto 0) when "00",
                  i_data(15 downto 0) & i_data(15 downto 0)                                         when "01",
                  i_data                                                                            when others;

    with funct3(1 downto 0) select
        o_be <= s_be_byte when "00",
                s_be_half when "01",
                "1111"    when others;

end dataflow;
