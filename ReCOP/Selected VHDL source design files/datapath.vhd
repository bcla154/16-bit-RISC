library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.recop_types.all;
entity datapath is
    port (
        clk                     : in bit_1; -- from recop top level
        reset                   : in bit_1; -- from recop top level
        alu_src_flag            : in bit_1;
        pc_src                  : in bit_2;
        pc_write                : in bit_1; -- from control unit 
        alu_operation           : in bit_3;
        alu_op1_mux             : in bit_2;  -- MUX for first operand (Addressing mode)
        alu_op2_mux             : in bit_1;  -- MUX for second operand (Register Z or Register X)
        program_memory_input    : in bit_32; -- Instruction from program memory
        data_memory_input       : in bit_16;
        data_address_src        : in bit_2;
        data_mem_data_src       : in bit_2;
        data_src                : in bit_2;
        addr_src                : in bit_1;
        clr_z_flag              : in bit_1;
        reg_write               : in bit_1;
        zero_flag               : out bit_1;
        instruction             : out bit_32; -- to control unit
        prog_mem_address        : out bit_16;
        data_too_data_memory    : out bit_16;
        data_memory_address_out : out bit_16;
        pc_sz_flag              : in bit_1;
        sip                     : in bit_16;
        present_flag            : in bit_1;
        dpcr_flag               : in bit_1;
        ssop_flag               : in bit_1;
        ssop_output             : out bit_16 := X"0000";
        load_instr_flag         : in bit_1
    );
end datapath;

architecture beh of datapath is
    signal program_counter             : std_logic_vector(15 downto 0) := (others => '0');
    signal next_program_counter_signal : std_logic_vector(15 downto 0);
    signal alu_zero_signal             : std_logic;
    signal alu_carry_signal            : std_logic;
    signal alu_result_signal           : bit_16 := (others => '0');
    signal reg_write_flag_signal       : bit_1;
    signal read_data_one_signal        : bit_16;
    signal read_data_two_signal        : bit_16;
    signal rd1_signal                  : bit_4;
    signal rd2_signal                  : bit_4;
    signal write_address_signal        : bit_4;
    signal read_data_one_signal_in     : bit_16 := (others => '0');
    signal read_data_two_signal_in     : bit_16 := (others => '0');
    signal operand                     : bit_16 := (others => '0');
begin

    inst_alu : entity work.alu
        port map(
            clock                   => clk,
            reset                   => reset,
            rx                      => read_data_one_signal, -- from register file (data from Rx)
            rz                      => read_data_two_signal, -- from register file (data from Rz)
            ir_operand              => operand,
            alu_op1_mux             => alu_op1_mux, -- from control unit
            alu_op2_mux             => alu_op2_mux, -- from control unit -- 1 if immed instr, 0 if reg instr
            clr_z                   => clr_z_flag,
            ssop_flag               => ssop_flag,
            alu_operation           => alu_operation,     -- from control unit
            zero_flag               => alu_zero_signal,   -- Output zero flag
            alu_carry               => alu_carry_signal,  -- Output zero flag
            alu_out                 => alu_result_signal, -- Output of ALU
            direct_from_data_memory => data_memory_input,
            program_counter         => program_counter
        );

    inst_register_file : entity work.registerfile
        port map(
            clock     => clk,
            address_a => rd1_signal,              --? 
            address_b => rd2_signal,              --?
            data_a    => read_data_one_signal_in, -- data too write
            data_b    => read_data_two_signal_in, --?
            wren_a    => '0',                     -- Enable write 
            wren_b    => reg_write,               --? Should this be the same as wren_a?
            q_a       => read_data_one_signal,    --? Send data to ALU
            q_b       => read_data_two_signal
        );

    dc_register : entity work.registerfile
        port map(
            clock     => clk,
            address_a => X"1", -- Hardcoded to 1 since only need a single register address for this
            address_b => X"1",
            data_a    => read_data_one_signal_in, -- data too write
            data_b    => read_data_two_signal_in, -- data too write
            wren_a    => dpcr_flag,               -- Write to DC register when flag is set 
            wren_b    => dpcr_flag,               -- Write to DC register when flag is set 
            q_a       => open,                    -- Data A from DC_register
            q_b       => open                     -- Data B from DC_register
        );
    process (clk, pc_write, pc_sz_flag, present_flag, ssop_flag)
    begin
        if clk = '1' then

            if reset = '1' then
                program_counter             <= (others => '0');
                next_program_counter_signal <= std_logic_vector(unsigned(program_counter) + 1);
            elsif pc_sz_flag = '1' then
                program_counter(15 downto 0) <= program_memory_input(15 downto 0);
                next_program_counter_signal  <= std_logic_vector(unsigned(program_counter) + 1);
            elsif present_flag = '1' then
                if read_data_two_signal = X"00000000" then
                    program_counter             <= operand;
                    next_program_counter_signal <= std_logic_vector(unsigned(program_counter) + 1);
                else
                end if;

            elsif ssop_flag = '1' then
                ssop_output <= read_data_one_signal; -- tried setting to read_data_two_signal
            else
                next_program_counter_signal <= std_logic_vector(unsigned(program_counter) + 1);

                if pc_write = '1' then
                    case pc_src is
                        when "00" =>
                            program_counter  <= next_program_counter_signal;
                            prog_mem_address <= program_counter;

                        when "01" =>
                            program_counter  <= read_data_one_signal; -- Rx
                            prog_mem_address <= program_counter;
                        when "10" =>
                            program_counter  <= operand;
                            prog_mem_address <= program_counter;

                        when "11" => -- ZERO FLAG 
                            prog_mem_address <= program_counter;

                        when others =>
                            program_counter  <= next_program_counter_signal;
                            prog_mem_address <= program_counter;
                    end case;

                else
                    prog_mem_address <= program_counter;
                end if;
            end if;

        end if;
    end process;
    zero_flag               <= alu_zero_signal;
    read_data_two_signal_in <= alu_result_signal when data_src = "00" else
        data_memory_input when data_src = "01" else
        operand when data_src = "10" else
        sip when data_src = "11" else
        (others => '0');
    data_memory_address_out <= read_data_one_signal when data_address_src = "00" or alu_op1_mux = "11" else -- Rx
        read_data_two_signal when data_address_src = "01" else                                                  -- Rz
        operand when data_address_src = "10" else
        (others => '0');

    data_too_data_memory                     <= read_data_one_signal when data_mem_data_src = "00" else
        (program_counter) when data_mem_data_src <= "10" else
        operand;

    instruction <= program_memory_input;

    -- when addr_src = 1 its a register command
    rd1_signal <= program_memory_input(19 downto 16) when addr_src = '0';
    rd2_signal <= program_memory_input(23 downto 20) when addr_src = '0';

    operand(15 downto 0) <= data_memory_input(15 downto 0) when alu_op1_mux = "11" or load_instr_flag = '1' else
    program_memory_input(15 downto 0);

end beh;