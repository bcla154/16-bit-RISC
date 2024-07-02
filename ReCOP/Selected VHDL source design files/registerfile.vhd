library ieee;
use ieee.std_logic_1164.all;

library altera_mf;
use altera_mf.all;
entity registerfile is
    port (
        address_a : in std_logic_vector (3 downto 0); --write a address
        address_b : in std_logic_vector (3 downto 0); -- write b address
        clock     : in std_logic := '1';
        data_a    : in std_logic_vector (15 downto 0);  -- write data_a 
        data_b    : in std_logic_vector (15 downto 0);  -- write data_b 
        wren_a    : in std_logic;                       -- write a flag
        wren_b    : in std_logic;                       -- write b flag 
        q_a       : out std_logic_vector (15 downto 0); -- data too ALU 
        q_b       : out std_logic_vector (15 downto 0)  -- data too ALU 
    );
end registerfile;
architecture SYN of registerfile is

    signal sub_wire0 : std_logic_vector (15 downto 0);
    signal sub_wire1 : std_logic_vector (15 downto 0);

    component altsyncram
        generic (
            address_reg_b                      : string;
            clock_enable_input_a               : string;
            clock_enable_input_b               : string;
            clock_enable_output_a              : string;
            clock_enable_output_b              : string;
            indata_reg_b                       : string;
            intended_device_family             : string;
            lpm_type                           : string;
            numwords_a                         : natural;
            numwords_b                         : natural;
            operation_mode                     : string;
            outdata_aclr_a                     : string;
            outdata_aclr_b                     : string;
            outdata_reg_a                      : string;
            outdata_reg_b                      : string;
            power_up_uninitialized             : string;
            ram_block_type                     : string;
            read_during_write_mode_mixed_ports : string;
            widthad_a                          : natural;
            widthad_b                          : natural;
            width_a                            : natural;
            width_b                            : natural;
            width_byteena_a                    : natural;
            width_byteena_b                    : natural;
            wrcontrol_wraddress_reg_b          : string
        );
        port (
            clock0    : in std_logic;
            wren_a    : in std_logic;
            address_b : in std_logic_vector (3 downto 0);
            data_b    : in std_logic_vector (15 downto 0);
            q_a       : out std_logic_vector (15 downto 0);
            wren_b    : in std_logic;
            address_a : in std_logic_vector (3 downto 0);
            data_a    : in std_logic_vector (15 downto 0);
            q_b       : out std_logic_vector (15 downto 0)
        );
    end component;

begin
    q_a <= sub_wire0(15 downto 0);
    q_b <= sub_wire1(15 downto 0);

    altsyncram_component : altsyncram
    generic map(
        address_reg_b                      => "CLOCK0",
        clock_enable_input_a               => "BYPASS",
        clock_enable_input_b               => "BYPASS",
        clock_enable_output_a              => "BYPASS",
        clock_enable_output_b              => "BYPASS",
        indata_reg_b                       => "CLOCK0",
        intended_device_family             => "Cyclone II",
        lpm_type                           => "altsyncram",
        numwords_a                         => 16,
        numwords_b                         => 16,
        operation_mode                     => "BIDIR_DUAL_PORT",
        outdata_aclr_a                     => "NONE",
        outdata_aclr_b                     => "NONE",
        outdata_reg_a                      => "UNREGISTERED",
        outdata_reg_b                      => "UNREGISTERED",
        power_up_uninitialized             => "FALSE",
        ram_block_type                     => "M4K",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        widthad_a                          => 4, -- 5 for quartus sim then back to 4 for model sim
        widthad_b                          => 4, -- 5 for quartus sim then back to 4 for model sim
        width_a                            => 16,
        width_b                            => 16,
        width_byteena_a                    => 1,
        width_byteena_b                    => 1,
        wrcontrol_wraddress_reg_b          => "CLOCK0"
    )
    port map(
        clock0    => clock,
        wren_a    => wren_a,
        address_b => address_b,
        data_b    => data_b,
        wren_b    => wren_b,
        address_a => address_a,
        data_a    => data_a,
        q_a       => sub_wire0,
        q_b       => sub_wire1
    );

end SYN;