## Division
## Assume that dividend cannot -2^31, divisor will not be 0
## Remember to take the absolute value for division first, then handle the sign
## of the quotient and remainder

main: lui a2, 16  # load 65537 into a2 as the dividend
addi a2, a2, 1
lui a3, 0  # load 128 into a3 as the divisor
addi a3, a3, 128
srai s1, a3, 31  # s1 = sign bit of divisor (1 means negative, 0 means non-negative)
bgez a3, variables  # if divisor >= 0, then leave it as it is.
sub a3, zero, a3  # make the divisor positive if the original divisor was negative (subtracting two's complement of the negative divisor calculates the absolute value of the divisor)

srai s2, a2, 31  # s2 = sign bit of dividend
bgez a2, variables  # if dividend >= 0, then leave it as it is.
sub a2, zero, a2  # make dividend positive if the original divisor was negative (subtracting two's complement of the negative dividend calculates the absolute value of the dividend)

variables:
addi t3, a3, 0   # t3 stores the divisor
addi t2, a2, 0   # t2 stores the dividend
addi t4, zero, 0 # t4 stores the remainder (start at 0)
addi t5, zero, 0 # t5 stores the quotient (start at 0)
addi t6, zero, 32 # loop counter (32 bits)
jal ra, division

addi t0, a0, 0
addi t1, a1, 0

addi a7, zero, 1  # display the quotient
addi a0, t0, 0
ecall

addi a7, zero, 11
addi a0, zero, 10
ecall 

addi a7, zero, 1  # display the remainder
addi a0, t1, 0
ecall

addi a7, zero, 10 # terminate the program
ecall


## division procedure
## input: a2 - dividend (absolute value)
##        a3 - divisor  (absolute value)
## output: a0 - quotient
##         a1 - remainder
# t2 - dividend (shifting copy)
# t3 - divisor
# t4 - remainder
# t5 - quotient
# t6 - loop variable
division:
# Each iteration:
#  1) shift remainder left and bring in next dividend MSB
# Note that the remainder is shifted to bring in the dividend's value on the remainder's lower 16 bits
#  2) subtract divisor from remainder
#  3) if result >= 0 -> accept result and quotient LSB = 1
# else -> restore the remainder by adding the divisor back to the remainder, and the quotient LSB = 0
# Repeat 32 times

loop_start:
# shift remainder left to make room for the next bit
slli t4, t4, 1

# extract MSB of dividend t2 (as 0 or 1) and OR into remainder LSB
# OR is used to shift the dividend's MSB into the remainder's LSB
srai t0, t2, 31
# This line is used to check if the MSB is 1 or not using and and or logical operators
# The or operation is used to check if the remainder's bits are similar/different to the dividend's bits
andi t0, t0, 1
or t4, t4, t0

# shift dividend left so next bit becomes the dividend's next MSB for the next iteration
slli t2, t2, 1

# compute s4 = t4 - t3, store in s4.
# s4 is used to calculate the subtraction of the divisor (t3) from the remainder (t4)
xori s4, t3, -1 # These two lines are used to find 2's complement of the divisor by inverting the latter's digits and adding 1 to the divisor
addi s4, s4, 1
add s4, t4, s4    # s4 = t4 + (~t3 + 1) = t4 - t3 (Adding the divisor's 2's complement to the remainder is similar to subtracting the divisor from the remainder.

bltz s4, restore   # if the subtraction result or remainder register < 0, then jump to restore block

# if subtraction result or remainder register >= 0: accept s4 as new remainder and shift the quotient left by 1 bit
add t4, s4, zero
slli t5, t5, 1
# This logical operator (or) instruction ensures that the shifted quotient appends a 1 as its LSB for each shift
ori t5, t5, 1
j cont

restore:
# s4 is the new remainder = subtraction of divisor from remainder
# t4 is the old remainder with the divisor added to the remainder
# if the subtraction is negative, then leave the remainder unchanged because the original remainder is already the sum of itself and the divisor (restored).
# shift quotient left by 1 bit, and the LSB will remain 0
slli t5, t5, 1

# This block decrements the loop counter (t6) by 1 while making sure that it terminates the division loop when t6 == 0.
cont:
addi t6, t6, -1
beqz t6, done
j loop_start

# When the loop is finished, the quotient and remainder are loaded into their respective argument registers, a0 and a1.
done:
addi a0, t5, 0   # a0 = quotient
addi a1, t4, 0   # a1 = remainder

# s1 -> sign of divisor
# s2 -> sign of dividend
# remainder sign follows original dividend (s2)
bgez s2, check_dividend # This checks if the dividend is positive
sub a1, zero, a1 # If the original dividend < 0, then make the remainder negative by subtracting it from 0.

check_dividend:
# This checks if the dividend's sign is the same as the divisor's sign
# XOR is used to check if s1 and s2 bits' are similar or different by passing a value 0 (similar) or 1 (different)
xor t6, s1, s2   # if s1 xor s2 != 0, then the signs differ.
bgez t6, final   # if s1 xor s2 (stored in register t6) ==0, then the signs are similar -> leave quotient positive
# if the divisor is negative, then the quotient is negative by subtracting the absolute value of the divisor from 0.
sub a0, zero, a0

final:
jalr zero, 0(ra)
