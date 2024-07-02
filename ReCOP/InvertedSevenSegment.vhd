LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY InvertedSevenSegment IS
    PORT (
        input : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        output : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
END InvertedSevenSegment;

ARCHITECTURE Behavioral OF InvertedSevenSegment IS
BEGIN
    PROCESS (input)
    BEGIN
        CASE input IS
            WHEN "0000" => output <= "1000000"; -- 0
            WHEN "0001" => output <= "1111001"; -- 1
            WHEN "0010" => output <= "0100100"; -- 2
            WHEN "0011" => output <= "0110000"; -- 3
            WHEN "0100" => output <= "0011001"; -- 4
            WHEN "0101" => output <= "0010010"; -- 5
            WHEN "0110" => output <= "0000010"; -- 6
            WHEN "0111" => output <= "1111000"; -- 7
            WHEN "1000" => output <= "0000000"; -- 8
            WHEN "1001" => output <= "0010000"; -- 9
            WHEN "1010" => output <= "0001000"; -- A
            WHEN "1011" => output <= "0000011"; -- b
            WHEN "1100" => output <= "1000110"; -- C
            WHEN "1101" => output <= "0100001"; -- d
            WHEN "1110" => output <= "0000110"; -- E
            WHEN "1111" => output <= "0001110"; -- F
            WHEN OTHERS => output <= "1111111"; -- default case (all segments off)
        END CASE;
    END PROCESS;
END Behavioral;