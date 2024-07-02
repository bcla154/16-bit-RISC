
from typing import List
import sys
sys.tracebacklimit = 0

INSTRUCTION_SIZE = 32

MAX_REGISTER = 16

AM_INHERENT = 0
AM_IMMEDIATE = 1
AM_DIRECT = 2
AM_REGISTER = 3

Opcodes = {
    "AND":      (0b001000, 1 << AM_IMMEDIATE | 1 << AM_REGISTER),
    "OR":       (0b001100, 1 << AM_IMMEDIATE | 1 << AM_REGISTER),
    "ADD":      (0b111000, 1 << AM_IMMEDIATE | 1 << AM_REGISTER),
    "SUB":      (0b000011, 1 << AM_IMMEDIATE | 1 << AM_REGISTER),
    "SUBV":      (0b000011, 1 << AM_IMMEDIATE | 1 << AM_REGISTER),
    "LDR":      (0b000000, 1 << AM_IMMEDIATE | 1 << AM_REGISTER | 1 << AM_DIRECT),
    "STR":      (0b000010, 1 << AM_IMMEDIATE | 1 << AM_REGISTER | 1 << AM_DIRECT),
    "JMP":      (0b011000, 1 << AM_IMMEDIATE | 1 << AM_REGISTER),
    "PRESENT":  (0b011100, 1 << AM_IMMEDIATE),
    "LSIP":     (0b110111, 1 << AM_REGISTER),
    "SSOP":     (0b111010, 1 << AM_REGISTER),
    "MAX":      (0b011110, 1 << AM_IMMEDIATE),
    "NOOP":     (0b110100, 1 << AM_INHERENT),
    "SZ":       (0b010100, 1 << AM_IMMEDIATE),
    "CLFZ":     (0b010000, 1 << AM_INHERENT),
    "STRPC":    (0b011101, 1 << AM_DIRECT),

    # "DATACALL": (0b101000, 1 << AM_IMMEDIATE | 1 << AM_REGISTER),
}


class ASMInstruction:
    def __init__(self, instruction: str, file_line: int) -> None:
        self.instruction = instruction
        self.parsed_instr = instruction
        self.file_line = file_line

    def replace_labels(self, labels: dict[str, int]):
        # Replace the labels with the address
        for label, address in labels.items():
            self.parsed_instr = self.parsed_instr.replace(label, str(address))


def parse_file(file: str) -> tuple[List[ASMInstruction], dict[str, int]]:
    # Read the file and return a list of instructions
    # Remove comments and empty lines
    instructions: List[ASMInstruction] = [ASMInstruction("JMP #MAIN", 0)]
    labels: dict[str, int] = {}
    pmem_addr = 1

    with open(file, "r") as f:
        for line_num, line in enumerate(f.readlines()):
            line = line.split(';')[0].strip().upper()
            if line:

                if line.__contains__(":"):
                    label, inst = line.split(":")
                    label = label.strip()
                    inst = inst.strip()
                    labels[label] = pmem_addr
                    if inst:
                        instructions.append(ASMInstruction(inst, line_num))
                        pmem_addr += INSTRUCTION_SIZE//8
                else:
                    instructions.append(ASMInstruction(line, line_num))
                    pmem_addr += INSTRUCTION_SIZE//8
    if "MAIN" not in labels:
        raise ValueError("Error: No MAIN label found")

    for instr in instructions:
        instr.replace_labels(labels)

    return (instructions, labels)


def generate_mif(output_file, hex_instructions, labels):
    # Generate the MIF file from 32bit hex array
    with open(output_file, "w") as f:
        f.write("DEPTH = 1024;\n")
        f.write("WIDTH = 32;\n\n")
        f.write("ADDRESS_RADIX = HEX;\n")
        f.write("DATA_RADIX = HEX;\n\n")
        f.write("CONTENT\n")
        f.write("BEGIN\n")
        for i, instr in enumerate(hex_instructions):
            for label, address in labels.items():
                if i == address//4:
                    f.write(f"-- {label}:\n")
            f.write(f"{i:02X} : {instr[0]:08X}; -- {instr[1]}\n")
        f.write("END;\n")


def get_register(register: str, line_num: int) -> int:
    # Lookup the register number from the register name
    register_map = {'R0': 0, 'R1': 1, 'R2': 2, 'R3': 3, 'R4': 4, 'R5': 5, 'R6': 6, 'R7': 7,
                    'R8': 8, 'R9': 9, 'R10': 10, 'R11': 11, 'R12': 12, 'R13': 13, 'R14': 14, 'R15': 15}
    if register in register_map:
        return register_map[register]
    else:
        raise ValueError(
            f"Error: Invalid register '{register}' on line {line_num}")


def compile(instructions: List[ASMInstruction]) -> List[tuple[int, str]]:
    # Parses the assembly compiling it to byte code
    hex_instructions: List[tuple[int, str]] = []
    for instr in instructions:
        line = instr.file_line
        parts = instr.parsed_instr.split()

        am = AM_INHERENT
        opcode = 0
        rz = 0
        rx = 0
        ry = 0
        operand = 0

        # Determine addressing mode and operands and rx
        parts_len = len(parts)

        match parts[parts_len-1][0]:
            case "$":
                am = AM_DIRECT
                try:
                    operand = int(parts[parts_len - 1][1:], 0)
                except ValueError:
                    raise ValueError(
                        f"Error: Invalid operand '{parts[parts_len - 1]}' on line {line}")
                if parts[0] == "LDR":  # Direct load instructions set RZ
                    rz = get_register(parts[1], line)
                elif parts[0] == "STR":  # Direct store instructions set RX
                    rx = get_register(parts[1], line)

            case "#":
                am = AM_IMMEDIATE
                try:
                    operand = int(parts[parts_len - 1][1:], 0)
                except ValueError:
                    raise ValueError(
                        f"Error: Invalid operand '{parts[parts_len - 1]}' on line {line}")
                match parts_len:
                    case 4:
                        rz = get_register(parts[1], line)
                        rx = get_register(parts[2], line)
                    case 3:
                        rz = get_register(parts[1], line)

            case "R":
                am = AM_REGISTER
                match parts_len:
                    case 4:
                        ry = get_register(parts[1], line)
                        rz = get_register(parts[2], line)
                        rx = get_register(parts[3], line)
                    case 3:
                        rz = get_register(parts[1], line)
                        rx = get_register(parts[2], line)
                    case 2:
                        rz = get_register(parts[1], line)
                        rx = get_register(parts[1], line)

        # Determine opcode
        if parts[0] in Opcodes:
            opcode = Opcodes[parts[0]][0]
            if (Opcodes[parts[0]][1] & (1 << am)) == 0:
                raise ValueError(
                    f"Error: Invalid addressing mode for instruction '{parts[0]}' on line {line}")
        else:
            raise ValueError(
                f"Error: Invalid opcode '{parts[0]}' on line {line}")
        if not (ry == 0) and not (operand == 0):
            raise ValueError(
                f"Error: Invalid operands for instruction '{parts[0]}' on line {line}")

        hex_instrucion = (am << 30) | (opcode << 24) | (
            rz << 20) | (rx << 16) | (ry << 12) | operand
        hex_instructions.append((hex_instrucion, instr.instruction))
    return hex_instructions


if __name__ == "__main__":
    input_file = "./program.asm"
    output_file = "./output.mif"

    instructions, labels = parse_file(input_file)
    hex_instructions = compile(instructions)
    generate_mif(output_file, hex_instructions, labels)

    print(f"MIF file '{output_file}' generated successfully.")
