MAIN:
ADD R1 R2 #4; R1 = 4
JMP R1; Jump over the next instruction
ADD R2 R1 #96; R2 = 100
MAX R2 #50; 50 > 5 so R2 becomes 50
ADD R8 R8 #0; R8 = 0 Zero Flag set
SZ #8; if Zero flag is set then jump
OR R3 R3 R2; R3 = 50
OR R3 R3 R1; R3 = 4
CLFZ; Clear Z flag
LSIP R6; Load R6 with SIP
ADD R7 R6 #0; Check SIP Loaded
NOOP
STRPC $4; Store PC in R4
SSOP R6; Store R3 (50) in SOP