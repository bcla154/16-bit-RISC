library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.recop_types.all;

entity recop is
	port (
		clock : in std_logic;
		reset : in std_logic;
		SOP   : out std_logic_vector(15 downto 0) := (others => '0');
		SIP   : in std_logic_vector(15 downto 0)
	);
end recop;

architecture cpu of recop is
	signal not_clock                   : std_logic;
	signal pc_write_signal             : std_logic;
	signal instruction_signal          : std_logic_vector(31 downto 0);
	signal prog_memory_address_signal  : std_logic_vector(15 downto 0); -- The address for the program memory
	signal program_memory_input_signal : std_logic_vector(31 downto 0); -- The instruction from the program memory
	signal alu_operation_signal        : std_logic_vector(2 downto 0);
	signal data_too_data_memory_signal : std_logic_vector(15 downto 0);
	signal data_memory_output_signal   : std_logic_vector(15 downto 0);
	signal data_memory_address_signal  : std_logic_vector(15 downto 0);
	signal write_enable                : std_logic;
	signal ALUSrc_signal               : std_logic;
	signal pc_src_signal               : std_logic_vector(1 downto 0);
	signal data_address_src_signal     : std_logic_vector(1 downto 0);
	signal data_mem_data_src_signal    : std_logic_vector(1 downto 0);
	signal data_src_signal             : std_logic_vector(1 downto 0);
	signal addr_src_signal             : std_logic;
	signal alu_a_mux_signal            : std_logic_vector(1 downto 0);
	signal alu_b_mux_signal            : std_logic;
	signal data_mem_write_signal       : std_logic;
	signal CLR_Z_SIGNAL                : std_logic;
	signal REG_WRITE_SIGNAL            : std_logic;
	signal ZERO_FLAG_SIGNAL            : std_logic;
	signal PC_SZ_FLAG_SIGNAL           : std_logic;
	signal PRESENT_FLAG_SIGNAL         : std_logic;
	signal DPCR_FLAG_SIGNAL            : std_logic;
	signal SSOP_FLAG                   : std_logic;
	signal LOAD_INSTR_FLAG_SIGNAL      : std_logic;
	signal SOP_SIGNAL : STD_LOGIC_VECTOR(15 downto 0);

begin

	datapath_inst : entity work.datapath
		port map(
			clk                     => clock, -- from recop top level
			reset                   => reset, -- from recop top level
			alu_src_flag            => ALUSrc_signal,
			pc_src                  => pc_src_signal,
			alu_op1_mux             => alu_a_mux_signal,
			alu_op2_mux             => alu_b_mux_signal,
			alu_operation           => alu_operation_signal,
			pc_write                => pc_write_signal, -- from control unit 
			clr_z_flag              => CLR_Z_SIGNAL,
			program_memory_input    => program_memory_input_signal,
			data_memory_input       => data_memory_output_signal,
			data_address_src        => data_address_src_signal,
			data_mem_data_src       => data_mem_data_src_signal,
			data_src                => data_src_signal,
			addr_src                => addr_src_signal,
			instruction             => instruction_signal, -- too control unit
			zero_flag               => ZERO_FLAG_SIGNAL,
			prog_mem_address        => prog_memory_address_signal,
			data_too_data_memory    => data_too_data_memory_signal,
			data_memory_address_out => data_memory_address_signal,
			reg_write               => REG_WRITE_SIGNAL,
			pc_sz_flag              => PC_SZ_FLAG_SIGNAL,
			sip                     => SIP,
			dpcr_flag               => DPCR_FLAG_SIGNAL,
			present_flag            => PRESENT_FLAG_SIGNAL,
			ssop_flag               => SSOP_FLAG,
			ssop_output             => SOP_SIGNAL,
			load_instr_flag         => LOAD_INSTR_FLAG_SIGNAL
		);

	control_unit_inst : entity work.control_unit
		port map(
			clk             => clock, -- from recop top level 
			reset           => reset,
			instruction     => instruction_signal, -- instruction from prog mem
			pc_write        => pc_write_signal,    -- too datapath
			DATA_MEM_WRITE  => data_mem_write_signal,
			alu_operation   => alu_operation_signal, -- from control to datapath
			ALU_A_MUX       => alu_a_mux_signal,
			ALU_B_MUX       => alu_b_mux_signal,
			ALUSrc          => ALUSrc_signal, -- from control to datapath (goes high on immed instr)
			PC_SRC          => pc_src_signal, -- from control unit to set PC value (input for pc_src mux)
			DM_DATA_SRC     => data_mem_data_src_signal,
			DATA_ADDR_SRC   => data_address_src_signal,
			DATA_SRC        => data_src_signal,
			ADDR_SRC        => addr_src_signal,
			CLR_Z           => CLR_Z_SIGNAL,
			REG_WRITE       => REG_WRITE_SIGNAL,
			ZERO_FLAG       => ZERO_FLAG_SIGNAL,
			PC_SZ_FLAG      => PC_SZ_FLAG_SIGNAL,
			DPCR_FLAG       => DPCR_FLAG_SIGNAL,
			PRESENT_FLAG    => PRESENT_FLAG_SIGNAL,
			SSOP_FLAG       => SSOP_FLAG,
			LOAD_INSTR_FLAG => LOAD_INSTR_FLAG_SIGNAL
		);

	prog_mem_inst : entity work.prog_mem
		port map(
			clock       => clock,
			address     => prog_memory_address_signal(13 downto 0),
			instruction => program_memory_input_signal
		);

	data_mem_inst : entity work.data_mem
		port map(
			address => data_memory_address_signal(15 downto 0),
			clock   => clock,
			data    => data_too_data_memory_signal,
			wren    => data_mem_write_signal,
			q       => data_memory_output_signal
		);


	process(clock)
	begin 
		if rising_edge(clock) then 
			SOP <= SOP_SIGNAL;
		end if;
	end process;


end architecture cpu;