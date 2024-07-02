library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity top_level is
    port (
        CLOCK_50 : in std_logic;
        SW       : in std_logic_vector(9 downto 0);
        KEY      : in std_logic_vector(3 downto 0);
        LEDR     : buffer std_logic_vector(9 downto 0);
        HEX0     : out std_logic_vector(6 downto 0);
        HEX1     : out std_logic_vector(6 downto 0);
        HEX2     : out std_logic_vector(6 downto 0);
        HEX3     : out std_logic_vector(6 downto 0);
        HEX4     : out std_logic_vector(6 downto 0);
        HEX5     : out std_logic_vector(6 downto 0)
    );
end top_level;

architecture tb of top_level is
    signal clk_div_counter : integer                      := 0;
    signal clk             : std_logic                    := '0';
    signal reset           : std_logic                    := '0';
    signal zero    : std_logic_vector(7 downto 0) := X"2D";
    signal sum             : std_logic_vector(8 downto 0);
    signal inverted_hex0   : std_logic_vector(6 downto 0);
    signal inverted_hex1   : std_logic_vector(6 downto 0);
    signal inverted_hex4   : std_logic_vector(6 downto 0);
    signal inverted_hex5   : std_logic_vector(6 downto 0);
    signal fixed_hex2      : std_logic_vector(6 downto 0);
    signal fixed_hex3      : std_logic_vector(6 downto 0);
    signal SWITCHES        : std_logic_vector(15 downto 0) := (others => '0');
    signal SOP_SIGNAL      : std_logic_vector(15 downto 0) := (others => '0');
    signal SEND_INPUT      : std_logic                     := '0';
    signal OUTPUT          : std_logic_vector(7 downto 0)  := X"00";
	 signal sop_out : std_logic_vector(16 downto 0) := (others => '0');
	

begin 



  process (CLOCK_50)
    begin
        if rising_edge(CLOCK_50) then
            if clk_div_counter = 3 then
                clk             <= not clk;
                clk_div_counter <= 0;
            else
                clk_div_counter <= clk_div_counter + 1;
            end if;
        end if;
    end process;
	 
	 
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
            input  => zero(3 downto 0),
            output => fixed_hex2
        );
    InvertedSevenSegment_HEX3 : entity work.InvertedSevenSegment
        port map(
            input  => zero(7 downto 4),
            output => fixed_hex3
        );

    -- When button pressed update switches
    process (clk,SOP_SIGNAL)
    begin
        if rising_edge(clk) then
				if reset = '1' then 
					SWITCHES <= (others => '0');
					sop_out <= (others => '0');
					OUTPUT <= (others => '0');
				end if;
            
            if KEY(3) = '0' then
                SWITCHES(7 downto 0) <= SW(7 downto 0);
					 sop_out <= ((zero) + ('0' & SWITCHES));
					 SWITCHES(15 downto 8) <= (others => '0'); 
				end if;
				if KEY(2) = '0' then 
						OUTPUT <= SOP_SIGNAL(7 downto 0);
						
				end if;
					
        end if;
    end process;

    -- Instantiate InvertedSevenSegment components for HEX4 and HEX5
    InvertedSevenSegment_HEX4 : entity work.InvertedSevenSegment
        port map(
            input  => LEDR(3 downto 0),
            output => inverted_hex4
        );
    InvertedSevenSegment_HEX5 : entity work.InvertedSevenSegment
        port map(
            input  => LEDR(7 downto 4),
            output => inverted_hex5
        );
		  
		  
    -- Connect the RECoP processor
    recop : entity work.RECoP
        port map(
            clock => clk,
            reset => reset,
            SIP   => SWITCHES,
            SOP   => SOP_SIGNAL
        );
		  

    -- Connect the output of the InvertedSevenSegment to HEX0, HEX1, HEX4, and HEX5
    HEX0 <= inverted_hex0;
    HEX1 <= inverted_hex1;
    HEX2 <= fixed_hex2;
    HEX3 <= fixed_hex3;
    HEX4 <= inverted_hex4;
    HEX5 <= inverted_hex5;
	 LEDR(7 downto 0)  <= SOP_SIGNAL(7 downto 0);
	 LEDR(9) <= reset;
	 LEDR(8) <= clk;
	 
	 reset <= not KEY(0);
   
	 

end tb;