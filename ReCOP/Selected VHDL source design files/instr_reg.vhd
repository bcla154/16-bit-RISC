library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity instruction_reg is
	port (
		clk             : in std_logic;
		instruction_in  : in std_logic_vector(31 downto 0);
		addressing_mode : out std_logic_vector(1 downto 0);
		op_code         : out std_logic_vector(5 downto 0);
		Rx              : out std_logic_vector(3 downto 0);
		Rz              : out std_logic_vector(3 downto 0);
		other_data      : out std_logic_vector(31 downto 0)
	);
end instruction_reg;

architecture instr_decode of instruction_reg is
begin
	process (clk)
	begin
		if rising_edge(clk) then
			addressing_mode <= instruction_in(31 downto 30);
			op_code         <= instruction_in(29 downto 24);
			Rz              <= instruction_in(23 downto 20);
			Rx              <= instruction_in(19 downto 16);
			other_data      <= instruction_in(15 downto 0);
		end if;
	end process;

end instr_decode;