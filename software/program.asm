# Initialization
addi x1, x0, 3      # x1 = 3 (Loop counter)
addi x2, x0, 0      # x2 = 0 (Sum tracker)
addi x3, x0, 1      # x3 = 1 (Decrement value)

# The Loop
loop:
add x2, x2, x1      # sum = sum + counter
sub x1, x1, x3      # counter = counter - 1
bne x1, x0, loop    # If counter != 0, jump back to 'loop'

# End of program padding
addi x0, x0, 0
addi x0, x0, 0
