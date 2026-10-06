library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.mux_arr.all;

entity tb_dmem is
  generic(gCLK_HPER   : time := 50 ns;
          W_DATA  : integer := 32;
          W_ADDR  : integer := 10;
          W_BYTE   : integer := 8;
          BY_P_WD  : integer := 4);
end tb_dmem;


architecture mixed of tb_dmem is

    constant cCLK_PER  : time := gCLK_HPER * 2;


    component mem
        generic 
        (
            DATA_WIDTH : natural := W_DATA;
            ADDR_WIDTH : natural := W_ADDR;
            BYTE_WIDTH : natural := W_BYTE
        );

        port 
        (
            clk        : in std_logic;
            addr            : in std_logic_vector((ADDR_WIDTH-1) downto 0);
            data            : in std_logic_vector((DATA_WIDTH-1) downto 0);
            be              : in std_logic_vector (BY_P_WD-1 downto 0);   -- 4 bytes per word
            we        : in std_logic;
            q        : out std_logic_vector((DATA_WIDTH -1) downto 0)
        );
    end component;

    signal s_CLK  : std_logic;
    signal s_we : std_logic := '1';
    signal s_addr : std_logic_vector(W_ADDR-1 downto 0);
    signal s_data : std_logic_vector(W_DATA-1 downto 0);
    signal s_q : std_logic_vector(W_DATA-1 downto 0);
    signal s_be : std_logic_vector(BY_P_WD - 1 downto 0) := "1111";

    type data_array is array (0 to 9) of std_logic_vector(W_DATA-1 downto 0);
    signal initial_values : data_array;

begin

    dmem: mem
    port map(clk  => s_CLK,  
            addr  => s_addr, 
            data  => s_data,          
            be    => s_be,          
            we    => s_we,    
            q     => s_q);

    P_CLK: process
    begin
        s_CLK <= '0';
        wait for gCLK_HPER;
        s_CLK <= '1';
        wait for gCLK_HPER;
    end process;
            
    P_TB: process
begin

    wait for gCLK_HPER;

    s_we <= '0';  
    for i in 0 to 9 loop
        s_addr <= std_logic_vector(to_unsigned(i, W_ADDR));
        wait for cCLK_PER;
        initial_values(i) <= s_q;
    end loop;
    
    s_we <= '1'; 
    s_be <= "1111"; 
    for i in 0 to 9 loop
        s_addr <= std_logic_vector(to_unsigned(16#100# + i, W_ADDR));
        s_data <= initial_values(i);
        wait for cCLK_PER;
    end loop;
    
    
    s_we <= '0'; 
    for i in 0 to 9 loop
        s_addr <= std_logic_vector(to_unsigned(16#100# + i, W_ADDR));
        wait for cCLK_PER;
        
    end loop;
    wait;
end process;

    end mixed;