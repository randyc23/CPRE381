library IEEE;
use IEEE.std_logic_1164.all;

entity IF_Stage is
  generic(N : integer);
  port(clk                : in std_logic;
       rst                : in std_logic;
       Halt               : in std_logic;
       JumpReg            : in std_logic;
       ALU_Result         : in std_logic_vector(N-1 downto 0);
       add2out            : in std_logic_vector(N-1 downto 0);
       Jump               : in std_logic;
       PCSrc              : in std_logic;
       i_IMemOut          : in std_logic_vector(N-1 downto 0);
       o_IMemAddr         : out std_logic_vector(N-1 downto 0);
       current_PC         : out std_logic_vector(N-1 downto 0);
       PCplus4            : out std_logic_vector(N-1 downto 0);
       o_inst             : out std_logic_vector(N-1 downto 0));
end IF_Stage;

architecture structural of IF_Stage is

    component Fetch_Ctrl_IF is
        generic(N : integer);
        port(current_PC         : in std_logic_vector(N-1 downto 0);
                four               : in std_logic_vector(N-1 downto 0);
                ALU_Result         : in std_logic_vector(N-1 downto 0);
                PCSrc              : in std_logic;
                Jump               : in std_logic;
                JumpReg            : in std_logic;
                add2out            : in std_logic_vector(N-1 downto 0);
                PC_Plus4           : out std_logic_vector(N-1 downto 0);
                PC_New             : out std_logic_vector(N-1 downto 0));
    end component;

    component pc_reg is
        generic(WIDTH   : integer;
                RST_VAL : std_logic_vector);
        port(i_CLK  : in std_logic;
                i_RST  : in std_logic;
                i_WE   : in std_logic;
                i_Din  : in std_logic_vector(WIDTH-1 downto 0);
                o_Dout : out std_logic_vector(WIDTH-1 downto 0));
    end component;

    component invg is
        port(i_A : in std_logic;
             o_F : out std_logic);
    end component;

    signal s_PC_Fetch : std_logic_vector(N-1 downto 0);
    signal s_PC       : std_logic_vector(N-1 downto 0);
    signal s_PC_WE    : std_logic;

begin

    FETCH: Fetch_Ctrl_IF generic map(N => N) port map(current_PC => s_PC, four => x"00000004", ALU_Result => ALU_Result, PCSrc => PCSrc, Jump => Jump, JumpReg => JumpReg, add2out => add2out, PC_Plus4 => PCplus4, PC_New => s_PC_Fetch);
    PC: pc_reg generic map(WIDTH => N, RST_VAL => x"00400000") port map(i_CLK => clk, i_RST => rst, i_WE => s_PC_WE, i_Din => s_PC_Fetch, o_Dout => s_PC);
    G_PC_WE: invg port map(i_A => Halt, o_F => s_PC_WE);

    o_IMemAddr <= s_PC;
    current_PC <= s_PC;
    o_inst <= i_IMemOut;

end structural;
