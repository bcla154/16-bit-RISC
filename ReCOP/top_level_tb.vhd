library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity top_level_tb is
    port (
        SW   : in std_logic_vector(9 downto 0);
        KEY  : in std_logic_vector(3 downto 0);
        LEDR : out std_logic_vector(9 downto 0);
        HEX0 : out std_logic_vector(6 downto 0);
        HEX1 : out std_logic_vector(6 downto 0);
        HEX2 : out std_logic_vector(6 downto 0);
        HEX3 : out std_logic_vector(6 downto 0);
        HEX4 : out std_logic_vector(6 downto 0);
        HEX5 : out std_logic_vector(6 downto 0)
    );
end top_level_tb;

architecture tb of top_level_tb is

    constant clk_hz     : integer := 10e6;
    constant clk_period : time    := 1 sec / clk_hz;

    signal clk           : std_logic                    := '1';
    signal reset         : std_logic                    := '0';
    signal fixed_number  : std_logic_vector(7 downto 0) := X"2d";
    signal sum           : std_logic_vector(8 downto 0);
    signal inverted_hex0 : std_logic_vector(6 downto 0);
    signal inverted_hex1 : std_logic_vector(6 downto 0);
    signal inverted_hex4 : std_logic_vector(6 downto 0);
    signal inverted_hex5 : std_logic_vector(6 downto 0);
    signal fixed_hex2    : std_logic_vector(6 downto 0);
    signal fixed_hex3    : std_logic_vector(6 downto 0);
    signal SWITCHES      : std_logic_vector(15 downto 0) := (others => '0');
    signal SOP_SIGNAL    : std_logic_vector(15 downto 0);
    signal SEND_INPUT    : std_logic := '0';
begin
    clk <= not clk after clk_period / 2;

    reset <= '0';
    LEDR  <= SWITCHES(9 downto 0);
    -- Instantiate InvertedSevenSegment components for HEX0 and HEX1
    InvertedSevenSegment_HEX0 : entity work.InvertedSevenSegment
        port map(
            input  => SWITCHES(3 downto 0),
            output => inverted_hex0
        );
    InvertedSevenSegment_HEX1 : entity work.InvertedSevenSegment
        port map(
            input  => SWITCHES(7 downto 4),
            output => inverted_hex1
        );

    -- Instantiate InvertedSevenSegment components for fixed HEX2 and HEX3
    InvertedSevenSegment_HEX2 : entity work.InvertedSevenSegment
        port map(
            input  => fixed_number(3 downto 0),
            output => fixed_hex2
        );
    InvertedSevenSegment_HEX3 : entity work.InvertedSevenSegment
        port map(
            input  => fixed_number(7 downto 4),
            output => fixed_hex3
        );

    -- Connect the RECoP processor
    recop : entity work.RECoP
        port map(
            clock => clk,
            reset => reset,
            SIP   => SWITCHES,
            SOP   => SOP_SIGNAL
        );

    -- When button pressed update switches
    process (clk)
        variable temp : integer := 0;
    begin
        if rising_edge(clk) then
            SEND_INPUT <= '0';
            temp := temp + 1;
            if temp > 10 then
                SWITCHES(7 downto 0) <= std_logic_vector(unsigned(SWITCHES(7 downto 0)) + 3);
                SEND_INPUT           <= '1';
                temp := 0;
            end if;
        end if;
    end process;

    -- Instantiate InvertedSevenSegment components for HEX4 and HEX5
    InvertedSevenSegment_HEX4 : entity work.InvertedSevenSegment
        port map(
            input  => SOP_SIGNAL(3 downto 0),
            output => inverted_hex4
        );
    InvertedSevenSegment_HEX5 : entity work.InvertedSevenSegment
        port map(
            input  => SOP_SIGNAL(7 downto 4),
            output => inverted_hex5
        );

    -- Connect the output of the InvertedSevenSegment to HEX0, HEX1, HEX4, and HEX5
    HEX0 <= inverted_hex0;
    HEX1 <= inverted_hex1;
    HEX2 <= fixed_hex2;
    HEX3 <= fixed_hex3;
    HEX4 <= inverted_hex4;
    HEX5 <= inverted_hex5;

end tb;