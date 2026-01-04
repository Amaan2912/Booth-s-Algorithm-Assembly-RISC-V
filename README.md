# Booth-s Algorithm and Restoring Division Assembly Program (RISC-V)
This project demonstrates how multiplication and division are accurately calculated in assembly language programs. I applied 32-bit Booth’s multiplication and restoring division algorithms, producing 64-bit products and signed-correct results. I also implemented sign-handling logic for division by applying absolute-value preprocessing and post-operation correction. The restoring division algorithm is dependent on the dividend and the divisor signs. I validated arithmetic across varied positive and negative inputs using custom register-level test cases in RARS.

To clarify how each of these two algorithms work, the following section explains.

Booth's algorithm uses the multiplicand (M) and the multiplier (Q) in 32-bit binary form while the accumulator register starts off as 0. If the least significant bit of the multiplier is equal to the register (Q_-1), then an arithmetic right shift is performed in which the most significant bit of the registers A, Q, and Q_-1 is maintained while the rest of the bits are shifted right. If Q's LSB is 0 or 1, and it is not equal to Q_-1 (1 or 0), then the accumulator is either added or subtracted by the multiplier before the arithmetic right shift. Note that adding 2's complement of the multiplier's binary value to the accumulator is similar to subtracting A by M.
Restoring division algorithm 
If you want to check out this program, please take a look at the "asm" file, and install RARS system to test the program.
