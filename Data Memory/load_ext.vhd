library IEEE;
use IEEE.std_logic_1164.all;

entity load_ext is
    port(i_data  : in  std_logic_vector(31 downto 0);
         addr    : in  std_logic_vector(1 downto 0);
         funct3  : in  std_logic_vector(2 downto 0);
         o_data  : out std_logic_vector(31 downto 0));
end load_ext;

architecture dataflow of load_ext is

    signal s_byte : std_logic_vector(7 downto 0);
    signal s_half : std_logic_vector(15 downto 0);
    signal s_bsign : std_logic_vector(23 downto 0);
    signal s_hsign : std_logic_vector(15 downto 0);

begin

    s_bsign <= (others => s_byte(7));
    s_hsign <= (others => s_half(15));

    with addr select
        s_byte <= i_data(7 downto 0)   when "00",
                  i_data(15 downto 8)  when "01",
                  i_data(23 downto 16) when "10",
                  i_data(31 downto 24) when others;

    with addr(1) select
        s_half <= i_data(15 downto 0)  when '0',
                  i_data(31 downto 16) when others;

    with funct3 select
        o_data <= s_bsign & s_byte    when "000",
                  s_hsign & s_half    when "001",
                  x"000000" & s_byte  when "100",
                  x"0000" & s_half    when "101",
                  i_data              when others;

end dataflow;
