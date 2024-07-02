-- Zoran Salcic

library ieee;
use ieee.std_logic_1164.all;
-- use ieee.std_logic_unsigned.all;
-- use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use work.various_constants.all;
use work.recop_types.all;
use work.opcodes.all;
entity alu is
	port (
		clock                   : in bit_1 := '0'; -- Clock signal
		reset                   : in bit_1 := '1';
		rx                      : in bit_16; -- Data from Register X
		rz                      : in bit_16; -- Data from Register Z
		ir_operand              : in bit_16; -- Immediate operand from instruction
		alu_op1_mux             : in bit_2;  -- MUX for first operand (Addressing mode)
		alu_op2_mux             : in bit_1;  -- MUX for second operand (Register Z or Register X)
		alu_operation           : in bit_3;  -- OP code, default to add register operation -- TODO check if default wanted
		clr_z                   : in bit_1;
		ssop_flag               : in bit_1;
		zero_flag               : buffer bit_1; -- Zero Flag, 1 if result is zero
		alu_carry               : out bit_1;    -- Carry Flag, 1 if carry out
		alu_out                 : out bit_16;   -- ALU result
		direct_from_data_memory : in bit_16;    -- Data from data memory
		program_counter         : in bit_16     -- Program counter
	);
end alu;

architecture op of alu is
	signal rx_16     : bit_16;
	signal rz_16     : bit_16;
	signal operand_1 : std_logic_vector(15 downto 0) := (others => '0');
	signal operand_2 : std_logic_vector(15 downto 0) := (others => '0');
	signal result    : std_logic_vector(16 downto 0) := (others => '0');
begin
	rx_16 <= rz(15 downto 0);
	rz_16 <= rx(15 downto 0);

	--MUX selecting first operand
	op1_select : process (clock,alu_op1_mux, rx_16, ir_operand)
	begin
		
			case alu_op1_mux is
				when "00" => -- Register X
					operand_1(15 downto 0) <= rx_16;
				when "01" => -- Immediate operand
					operand_1(15 downto 0) <= ir_operand(15 downto 0);
				when "10" => -- "Direct" addressing mode
					operand_1(15 downto 0) <= X"0001";
				when "11" =>
					operand_1(15 downto 0) <= direct_from_data_memory(15 downto 0);
				when others =>
					operand_1(15 downto 0) <= X"0000";
				end case;
		
	end process op1_select;
	--MUX selecting second operand
	op2_select : process (clock,alu_op2_mux, rx_16, rz_16)
	begin
		
			case alu_op2_mux is
				when '0' =>
					operand_2(15 downto 0) <= rx_16;
				when '1' =>
					operand_2(15 downto 0) <= rz_16;
				when others =>
					operand_2(15 downto 0) <= X"0000";
			end case;
		
	end process op2_select;
	-- perform ALU operation
	alu : process (clock,alu_operation, operand_1, operand_2)
	begin
		
			result(16) <= '0';
			case alu_operation is
				when alu_add =>
					result <= std_logic_vector(unsigned('0' & operand_2) + unsigned(operand_1));
				when alu_sub =>
					result <= std_logic_vector(unsigned('0' & operand_2) - unsigned(operand_1));
				when alu_and =>
					result <= '0' & (operand_2 and operand_1);
				when alu_or =>
					result <= '0' & (operand_2 or operand_1);
				when alu_idle =>
					result <= '0' & X"0000";
				when alu_max =>
					if (operand_2 >= operand_1) then
						result <= '0' & operand_2;
					else
						result <= '0' & operand_1;
					end if;
				when alu_datacall =>
					result <= '0' & (operand_2 and operand_1);
				when others =>
					result <= '0' & X"0000"; -- default to zero
			end case;
			alu_carry <= result(16); -- Carry flag is the 17th bit
		
	end process alu;

	z1gen : process (clock)
	begin
		if reset = '1' then
			zero_flag <= '0';
		elsif rising_edge(clock) then
			if clr_z = '1' then
				zero_flag <= '0';
				-- if alu is working (operation is valid)
			elsif alu_operation(2) = '0' then
				if result = X"0000" or zero_flag = '1' then
					zero_flag <= '1';
				else
					zero_flag <= '0';
				end if;
			end if;
		end if;
	end process z1gen;

	alu_out <= result(15 downto 0); -- trim result
end op;