COMPSYS 701 A1 ReCOP Group 3

output.mif Generation instructions

This project includes an assembly compiler which generates `output.mif` files for use in the ReCOP processor. This is not a bulletproof implementation, please confirm the correctness of `output.mif` before running.

Requirements

- Python (tested int version 3.10.6)

Instructions

- Write desired assembly in the `ReCOP Assembler/program.asm` file
- In the terminal, navigate to the `ReCOP Assembler` folder
- Run the included python file, a successful generation appears as so
  > C:\Users\GGPC\Downloads\701-asm>python assembler_1.py MIF file './output.mif' generated successfully.
- Copy the `ReCOP Assembler/output.mif` file into the root project folder

Compilation Instructions

Ensure `output.mif` Contains Correct Instructions

Before proceeding, verify that the `output.mif` file contains the correct instructions to execute the program.

Change the Target Memory File

Update the target memory file in `program_mem` to point to the location of `output.mif`. Specifically, modify line 51 as shown below to reflect the correct path:

init_file => "C:\Dev\COMPSYS701\ReCOP\output.mif",

Compilation in Quartus

1. Set Memory Width: Set the memory width to 5 in Quartus.

- In 'Selected VHDL source design files/registerfile.vhd' on lines 89 & 90 the withad_a & widthad_b need to be set to five for a quartus compilation.

2. Open the Project:

- Open the Quartus project `RECoP.qpf` and start the compilation.

3. Common Errors:

- Incorrect Location: Verify the location of `output.mif` is correctly specified. Otherwise the following error will be output
  > Error (127001): Can't find Memory Initialization File or Hexadecimal (Intel-Format) File C:/FAKE_PATH/COMPSYS701/ReCOP/output.mif for ROM instance ALTSYNCRAM

- Make sure this path is corrected to the output.mif extracted from the downloaded zip.

Simulation in ModelSim

1. Open RTL Simulation:

- In Quartus, navigate to `Tools > RTL Simulation`.

2. Compile VHDL Files:

- Compile all files in the 'Selected VHDL source design files' folder.
  - In the menu bar Select Compile > Compile
  - Enter `Selected VHDL source design files`
    - Compile all `.vhd` files
  - Return to the root folder and compile `recop.vhd` and `recop_tb.vhd`.

Note: Multiple compilations may be needed.

3. Start Simulation:
   - In the library tab right click `recop_tb.vhd` and select simulate
   - The clock frequency is set to 50 MHz, with each instruction taking 60ns, simulate appropriate time spans
   - `toplevel.tb` can also be used to simulate the top level, which simulates the SSIP and SSOP instruction responses.

Simulation with FPGA

- Compile in Quartus as outlined above.
- Open the programmer, click auto detect, followed by start.
- Once board is successfully programmed, the FPGA will be able to demonstrate the ReCOP's functionality using the instructions in "output.mif"

- The seven segment displays the following:
- HEX5 & HEX4 : OUTPUT IN HEX
- HEX3 & HEX2 : FIXED NUMBER TO ADD WITH (HEX "2D" or as in output.mif)
- HEX1 & HEX0 : SWITCHES VALUE IN 2-bit HEX

LEDR(7 downto 0): shows the output in binary, that is the same as the converted HEX shown on HEX5 and HEX4.
LEDR9 = KEY0
LEDR8 = CLK

HOW TO USE:
- Using the switches select a value.
- When happy with this value HOLD down KEY3 and the value will appear on HEX5 and HEX4
- Whilst holding KEY3 press KEY0 and the addition will be performed.
- To reset the program press KEY0 alone
