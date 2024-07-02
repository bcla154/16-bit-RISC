library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity recop_tb is
end recop_tb;

architecture sim of recop_tb is

    constant clk_hz     : integer := 50e6;
    constant clk_period : time    := 1 sec / clk_hz;

    signal clk    : std_logic                     := '1';
    signal rst    : std_logic                     := '1';
    signal SIP_IN : std_logic_vector(15 downto 0) := X"0016";

begin

    clk <= not clk after clk_period / 2;

    DUT : entity work.recop
        port map(
            clock => clk,
            reset => rst,
            SIP   => SIP_IN
        );

    pro : process
    begin
        rst <= '1';

        wait for clk_period * 1;

        rst <= '0';

        wait for clk_period * 100;
    end process;

end architecture;