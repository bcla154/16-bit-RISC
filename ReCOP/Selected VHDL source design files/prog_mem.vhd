
library ieee;
use ieee.std_logic_1164.all;

library altera_mf;
use altera_mf.all;

entity prog_mem is
	port (
		clock       : in std_logic := '1';
		address     : in std_logic_vector (13 downto 0);
		instruction : out std_logic_vector (31 downto 0)
	);
end prog_mem;
architecture SYN of prog_mem is
	-- Signal to store the instruction
	signal instr_sub_wire : std_logic_vector (31 downto 0);

	component altsyncram
		generic (
			clock_enable_input_a   : string;
			clock_enable_output_a  : string;
			init_file              : string;
			intended_device_family : string;
			lpm_hint               : string;
			lpm_type               : string;
			maximum_depth          : natural;
			--numwords_a		: NATURAL;
			operation_mode  : string;
			outdata_aclr_a  : string;
			outdata_reg_a   : string;
			ram_block_type  : string;
			widthad_a       : natural;
			width_a         : natural;
			width_byteena_a : natural
		);
		port (
			address_a : in std_logic_vector (13 downto 0);
			clock0    : in std_logic;
			q_a       : out std_logic_vector (31 downto 0)
		);
	end component;

begin
	instruction <= instr_sub_wire(31 downto 0);

	altsyncram_component : altsyncram
	generic map(
		clock_enable_input_a   => "BYPASS",
		clock_enable_output_a  => "BYPASS",
		init_file              => "H:\Documents\701\COMPSYS701\ReCOP\output.mif",
		intended_device_family => "Cyclone II",
		lpm_hint               => "ENABLE_RUNTIME_MOD=NO",
		lpm_type               => "altsyncram",
		maximum_depth          => 4096,
		--numwords_a => 32768,
		operation_mode  => "ROM",
		outdata_aclr_a  => "NONE",
		outdata_reg_a   => "UNREGISTERED",
		ram_block_type  => "M4K",
		widthad_a       => 14,
		width_a         => 32,
		width_byteena_a => 1
	)
	port map(
		address_a => address,       -- Input address
		clock0    => clock,         -- Input clock
		q_a       => instr_sub_wire -- Output instruction
	);

end SYN;