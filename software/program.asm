# COMPREHENSIVE RV32I-SUBSET CPU TEST
# Tests:
#   - ADDI
#   - ADD
#   - SUB
#   - AND
#   - OR
#   - XOR
#   - SLL
#   - SRL
#   - SW
#   - LW
#   - Load-use hazard / stall
#   - EX/MEM forwarding
#   - MEM/WB forwarding
#   - BEQ taken
#   - BEQ not taken
#   - BNE taken
#   - BNE not taken
#   - Negative immediates
#   - Backward branch
#   - Repeated branch prediction
#   - x0 protection

# TEST 1: BASIC ALU OPERATIONS

addi x1, x0, 10
addi x2, x0, 5

# Basic arithmetic
add x3, x1, x2          # x3 = 15
sub x4, x3, x2          # x4 = 10

# Logic
and x5, x1, x2          # x5 = 0
or  x6, x1, x2          # x6 = 15
xor x7, x1, x2          # x7 = 15

# Shifts
sll x8, x2, x1          # 5 << 10 = 5120
srl x9, x1, x2          # 10 >> 5 = 0

# TEST 2: EX/MEM FORWARDING

# x3 is produced immediately before it is consumed.
# This requires EX/MEM -> EX forwarding.

add x10, x3, x2         # x10 = 15 + 5 = 20
sub x11, x10, x2        # x11 = 20 - 5 = 15

# TEST 3: MEM/WB FORWARDING

add  x13, x1, x1        # x13 = 20

# Independent instruction creates a one-cycle separation.
addi x12, x0, 1         # x12 = 1

# x13 should now come through MEM/WB forwarding.
add x14, x13, x2        # x14 = 20 + 5 = 25

# TEST 4: STORE + LOAD + LOAD-USE HAZARD

# Store 10 to address 0.
sw x1, 0(x0)

# Load it back.
lw x15, 0(x0)

# Immediately consume the loaded value.
# This must trigger the load-use stall.
add x16, x15, x1         # x16 = 10 + 10 = 20

# TEST 5: STORE-DATA FORWARDING

addi x30, x0, 77

# x30 was just produced and is immediately used
# as store data.
sw x30, 4(x0)

# Load it back.
lw x31, 4(x0)

# TEST 6: BEQ TAKEN

addi x17, x0, 5
addi x18, x0, 5

beq x17, x18, beq_taken

# This instruction must be flushed/skipped.
addi x19, x0, 99

beq_taken:
addi x19, x0, 10         # Expected x19 = 10

# TEST 7: BEQ NOT TAKEN

# x17 = 5, x1 = 10, therefore branch must NOT be taken.
beq x17, x1, beq_wrong

# This must execute.
addi x20, x0, 20

beq_wrong:
# Marker instruction. If branch was incorrectly taken,
# x20 would remain 0.
addi x20, x20, 0

# TEST 8: BNE TAKEN

# 5 != 10, so branch must be taken.
bne x17, x1, bne_taken

# Must be skipped.
addi x21, x0, 99

bne_taken:
addi x21, x0, 30         # Expected x21 = 30

# TEST 9: BNE NOT TAKEN

# x17 == x17, so BNE must NOT be taken.
bne x17, x17, bne_wrong

# Must execute.
addi x22, x0, 40

bne_wrong:
# Marker.
addi x22, x22, 0

# TEST 10: NEGATIVE IMMEDIATES

addi x24, x0, -10        # x24 = -10
addi x25, x0, 5          # x25 = 5

addi x26, x24, -5        # x26 = -15
addi x27, x25, -10       # x27 = -5

# TEST 11: BACKWARD BNE + BRANCH PREDICTION

# This loop executes several times.
# First encounter should initially be predicted not-taken.
# The predictor should then learn that the branch is taken.

addi x28, x0, 3

prediction_loop:
addi x28, x28, -1
bne x28, x0, prediction_loop

# Expected:
# x28 = 0

# TEST 12: x0 MUST REMAIN ZERO

# Attempt to write to x0.
addi x0, x1, 100

# If x0 is implemented correctly, it is still zero.
add x29, x0, x1         # Expected x29 = 10