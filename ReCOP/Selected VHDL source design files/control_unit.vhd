library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.opcodes.all;
use work.various_constants.all;

entity control_unit is
	port (
		clk         : in std_logic; -- from recop top level 
		reset       : in std_logic;
		instruction : in std_logic_vector(31 downto 0); -- instruction from prog mem

		--addressing_mode 			: IN STD_LOGIC_VECTOR(1 downto 0);
		--pc_mux			 			: OUT STD_LOGIC_VECTOR(1 downto 0);
		--data_mem_wren				: OUT STD_LOGIC ;
		--reg_file_wren_a			: OUT STD_LOGIC ;
		--reg_file_wren_b			: OUT STD_LOGIC ;
		pc_write       : out std_logic := '0'; -- 0 for pc+4 1 for pc to branch target 
		REG_WRITE      : out std_logic;
		DATA_MEM_WRITE : out std_logic;
		alu_operation  : out std_logic_vector(2 downto 0);
		ALU_A_MUX      : out std_logic_vector(1 downto 0);
		ALU_B_MUX      : out std_logic;
		--alu_carry			: OUT STD_LOGIC
		--RegDst : OUT STD_LOGIC; -- destination reg is rt when 0 and rd when 1
		--RegWrite: OUT STD_LOGIC; -- when 0 NOTHING else when 1 register is writen to with data 
		ALUSrc          : out std_logic;-- 0 == Rz [INSTRUCTION(23 downto 20)] \  1== operand [INSTRUCTION(15 downto 0)] 
		PC_SRC          : out std_logic_vector(1 downto 0);
		DATA_ADDR_SRC   : out std_logic_vector(1 downto 0);
		DM_DATA_SRC     : out std_logic_vector(1 downto 0);
		DATA_SRC        : out std_logic_vector(1 downto 0);
		ADDR_SRC        : out std_logic;
		CLR_Z           : out std_logic;
		ZERO_FLAG       : in std_logic;
		PC_SZ_FLAG      : out std_logic;
		PRESENT_FLAG    : out std_logic;
		DPCR_FLAG       : out std_logic;
		SSOP_FLAG       : out std_logic;
		LOAD_INSTR_FLAG : out std_logic
		--MemRead : OUT STD_LOGIC; -- 0 Nothing, 1 causes contents of address input are copied to read data 
		--MemToReg : OUT STD_LOGIC; --  0 value of reg is write data from alu, 1 value of reg is memory read data 
	);
end control_unit;

architecture beh of control_unit is

	signal addressing_mode : std_logic_vector(1 downto 0);
	signal opcode          : std_logic_vector(5 downto 0);
	signal pc_write_signal : std_logic := '0';

	type stage is (fetch_stage, decode_stage, execute_stage);
	signal current_stage : stage := fetch_stage;
begin

	states : process (clk, reset)
	begin
		if rising_edge(clk) then 
			if reset = '1' then
				current_stage <= fetch_stage;
			else
				if current_stage = fetch_stage then
					current_stage       <= decode_stage;
				elsif current_stage <= decode_stage then
					current_stage       <= execute_stage;
				elsif current_stage = execute_stage then
					current_stage <= fetch_stage;
				else
					current_stage <= fetch_stage;
				end if;
			end if;
		end if;
	end process;

	control_unit_process : process (current_stage, opcode, addressing_mode, pc_write_signal, ZERO_FLAG)
	begin

		pc_write_signal <= '0';
		DPCR_FLAG       <= '1';
		REG_WRITE       <= '0';
		ALUSrc          <= '0';
		PC_SRC          <= "00";
		DATA_ADDR_SRC   <= "00";
		DM_DATA_SRC     <= "00";
		DATA_SRC        <= "00";
		ADDR_SRC        <= '0';
		alu_operation   <= alu_add;
		DATA_MEM_WRITE  <= '0';
		PC_SZ_FLAG      <= '0';
		SSOP_FLAG       <= '0';
		PRESENT_FLAG    <= '0';
		LOAD_INSTR_FLAG <= '0';
		case current_stage is
			when fetch_stage =>
				CLR_Z           <= '0';
				ALU_A_MUX       <= "00";
				ALU_B_MUX       <= '0';
				DATA_MEM_WRITE  <= '0';
				pc_write_signal <= '0';
			when decode_stage =>
				DATA_MEM_WRITE <= '0';
				if opcode = ldr then
					LOAD_INSTR_FLAG <= '1';
					if addressing_mode = "11" then
						ALU_A_MUX <= "11";
					end if;
					DATA_ADDR_SRC <= "10";
				end if;
				if opcode = ssop then
					ALU_A_MUX <= "00"; -- make read_data_1 read from memory
					ALU_B_MUX <= '0';  -- Rx again (which is read_data_1)  
					
				end if;
				pc_write_signal <= '0';
				alu_operation   <= alu_add;
				if addressing_mode = am_direct then
					DATA_ADDR_SRC <= "00";
					DATA_SRC      <= "01";
				elsif addressing_mode = am_register then
					DATA_ADDR_SRC <= "10";
					DATA_SRC      <= "01";
				elsif addressing_mode = am_immediate then
					DATA_SRC <= "10";
				else
					REG_WRITE <= '0';
				end if;

				if opcode = clfz then
					CLR_Z <= '1';
				end if;

				if opcode = strpc then
					-- DIRECT 
					-- op1 and op2 need to be PC and then store PC in M[PC]
					ALU_A_MUX      <= "01"; -- operand 
					DATA_ADDR_SRC  <= "10";
					DM_DATA_SRC    <= "10"; -- set data to PC
					DATA_MEM_WRITE <= '1';
				end if;
			when execute_stage =>
				pc_write_signal <= '1';
				-- if statements for alu src selection 
				if addressing_mode = am_immediate then
					ALU_A_MUX <= "01"; -- immediate
					ALU_B_MUX <= '1';  --rz
				elsif addressing_mode = am_register then
					ALU_A_MUX <= "00"; -- rx
					ALU_B_MUX <= '1';  -- rz
				else
					ALU_A_MUX <= "00"; -- rx
					ALU_B_MUX <= '0';  -- rx
				end if;

				case opcode is
					when ldr =>
						REG_WRITE <= '1';
						ADDR_SRC  <= '1';
						if addressing_mode = am_direct then
							DATA_SRC      <= "01";
							DATA_ADDR_SRC <= "10";
							DM_DATA_SRC   <= "01";

						elsif addressing_mode = am_register then
							DATA_SRC      <= "01";
							DATA_ADDR_SRC <= "10";
							DM_DATA_SRC   <= "01";
							ALU_A_MUX     <= "11";

						elsif addressing_mode = am_immediate then
							DATA_SRC      <= "10";
							DATA_ADDR_SRC <= "10";
							DM_DATA_SRC   <= "01";

						else
							REG_WRITE <= '0';
						end if;

					when str =>
						DATA_MEM_WRITE <= '1';
						if addressing_mode = am_direct then
							DATA_ADDR_SRC <= "10";
							DM_DATA_SRC   <= "00";

						elsif addressing_mode = am_register then
							DATA_ADDR_SRC <= "01";
							DM_DATA_SRC   <= "00";

						elsif addressing_mode = am_immediate then
							DATA_ADDR_SRC <= "01";
							DM_DATA_SRC   <= "01";

						else
							DATA_MEM_WRITE <= '1';
						end if;
					when jmp =>
						if addressing_mode = am_register then
							-- jump to Rx
							PC_SRC <= "01";
						elsif addressing_mode = am_immediate then
							-- jump to operand
							PC_SRC <= "10";
						else
						end if;

						-- ONLY IMMEDIATE 
					when present =>
						PRESENT_FLAG <= '1';
						ALU_A_MUX    <= "01"; -- operand 
						ALU_B_MUX    <= '1';  -- Rz 

					when andr =>
						REG_WRITE     <= '1';
						alu_operation <= alu_and;
						if addressing_mode = am_register then

						elsif addressing_mode = am_immediate then

						else
						end if;
					when orr =>
						REG_WRITE     <= '1';
						alu_operation <= alu_or;
						if addressing_mode = am_register then

						elsif addressing_mode = am_immediate then

						else
						end if;
					when addr =>
						REG_WRITE     <= '1';
						alu_operation <= alu_add;
						ADDR_SRC      <= '1';

					when subr =>
						ALU_A_MUX     <= "01"; -- operand 
						REG_WRITE     <= '1';
						ALU_B_MUX     <= '1'; -- Rz 
						ADDR_SRC      <= '1';
						alu_operation <= alu_sub;
					when subvr =>
						ALU_A_MUX     <= "01"; -- operand 
						REG_WRITE     <= '1';
						ALU_B_MUX     <= '1'; -- Rz 
						ADDR_SRC      <= '1';
						alu_operation <= alu_sub;
					when max =>
						REG_WRITE     <= '1';
						alu_operation <= alu_max;

						-- ALL ONLY INHERENT AM TYPE 
					when clfz =>
						CLR_Z <= '1';
					when cer  =>
					when ceot =>
					when seot =>
					when noop =>
						alu_operation <= alu_idle;
					when sz =>
						if ZERO_FLAG = '1' then
							-- PC_SZ_FLAG <= '1';
							PC_SRC <= "10";
						else
						end if;
						-- ALL ONLY REGISTER TYPE AM 
					when ler   =>
					when ssvop =>

					when ssop =>
						-- Load Rx then set SIP == Rx 
						DATA_SRC      <= "01";
						SSOP_FLAG <= '1';
						ALU_B_MUX     <= '1';    -- Rz 
						alu_operation <= alu_or; -- loads Rx into both registers making SOP double, therefore don't do that
					when lsip =>
						DATA_SRC  <= "11"; -- set read_data signal to SIP
						REG_WRITE <= '1';  -- Enable Write to register

					when datacall =>
						-- REGISTER TYPE 
						-- MUX_A == Rz MUX_B == Rx
						alu_operation <= alu_datacall;
						ALU_A_MUX     <= "00"; -- Rx
						ALU_B_MUX     <= '1';  -- Rz
						DPCR_FLAG     <= '1';

						-- DPCR = Rz & Rx
						-- STORE IN DPCR REG 

					when datacall2 =>
						-- IMMEDIATE TYPE 
						alu_operation <= alu_datacall;
						ALU_A_MUX     <= "01"; -- IMMEDIATE operand 
						ALU_B_MUX     <= '0';  -- Rx
						DPCR_FLAG     <= '1';
						-- DPCR == Rz & OPERAND 
						-- STORE result in DPCR 
					when strpc =>
						alu_operation <= alu_idle; -- already completed
						-- DIRECT 
						-- op1 and op2 need to be PC and then store PC in M[PC]
						-- ALU_A_MUX <= "01"; -- operand 
						-- DATA_ADDR_SRC <= "10"; -- set address to operand
						-- DATA_MEM_WRITE <= '1';
						-- DM_DATA_SRC <= "10"; -- set data to PC
					when sres =>

					when others =>
				end case;
		end case;

	end process control_unit_process;

	addressing_mode <= instruction(31 downto 30);
	opcode          <= instruction(29 downto 24);
	pc_write        <= pc_write_signal;

end beh;