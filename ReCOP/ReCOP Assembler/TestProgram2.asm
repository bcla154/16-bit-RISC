MAIN:
ADD R1 R2 #2; R1 = 2
ADD R2 R1 #3; R2 = 5
STR R2 $1; store 5 in memory location 1
STR R1 #6; store 6 in memory location 2
NOOP
LDR R4 R1; load R4 with the value in memory location 2
LDR R5 $1; load R5 with the value in memory location 1
ADD R4 R4 R5; should be 11