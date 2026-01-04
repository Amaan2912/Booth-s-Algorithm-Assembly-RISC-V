## Booth's algorithm
.text
main:
lui a2, 0
addi a2, a2, 250 
lui a3, 0
addi a3, a3, 400
addi t2, zero, 0 # t2 is A for Booth's
addi t3, a3, 0 # t3 takes the multiplier as Q
addi t4, zero, 0 # t4 takes Q-1 as 0
addi t5, zero, 32 # This (t5) is a loop variable for 32 bit multiplicand and multiplier
jal ra, booth # call the Booth procedure

addi t0, a0, 0
addi t1, a1, 0

addi a7, zero, 1 # display the higher 32 bits of the product
addi a0, t0, 0
ecall

addi a7, zero, 11
addi a0, zero, 10
ecall 

addi a7, zero, 1 # display the lower 32 bits of the product
addi a0, t1, 0
ecall

addi a7, zero, 10 # terminate the program
ecall


#####################
### Booth's procedure
#####################
### input: a2 - multiplicand
### input: a3 - multiplier
### output: a0 - higher 32bit of the product
### output: a1 - lower 32bit of the product
# t2 - A (accumulator)
# t3 - Q (multiplier)
# t4 - Q-1 
booth: #This block is used as loop for Booth's algorithm
## insert your code here 
andi s1, t3, 1 # This code is used to extract the least significant bit of the mulitplier (Q0)
andi s2, t4, 1 # This code extracts the least significant bit of Q-1
# Format: (Q0, Q-1)
beq s1, s2, arit_shift #If Q0 = Q-1 (0,0) or (1,1), then A remains unchanged
blt s1, s2, add_multiplier #If Q0 < Q-1 (0,1), then A = A plus the multiplicand
bgt s1, s2, subtract_multiplier #If Q0 > Q-1 (1,0), then A = A minus the multiplicand
add_multiplier:
add t2, t2, a2
j arit_shift
subtract_multiplier:
# This code inverts the bits of the multipler and add's 1 for two's complement
# Adding two's complement of the multiplier is like subtracting the multiplier from A
xori t6, a2, -1
addi t6, t6, 1
add t2, t2, t6
j arit_shift
arit_shift:
andi t4, t3, 1 # This operation takes the least significant bit of Q (multiplier) into Q-1
andi t6, t2, 1 # This operation takes the least significant bit of A
slli t6, t6, 31 # This operation shifts A's LSB into Q's MSB since Q has 32 bits
srai t2, t2, 1 # This operation shifts A right by 1 bit
srli t3, t3, 1 # This operation shifts Q right by 1 bit
or t3, t3, t6 # This operation checks for least significant bit (0 or 1) of A in Q
addi t5, t5, -1
beqz t5, done # If the loop variable equals zero, the booth loop ends.
j booth

done:
addi a0, t2, 0
addi a1, t3, 0

jalr zero, 0(ra)
