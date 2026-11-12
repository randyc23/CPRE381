.data
stack:      .space 256
stack_top:
results:    .word 0, 0, 0, 0, 0

.text
main:
    lui   sp, %hi(stack_top)
    lui   s2, %hi(results)
    lui   t3, %hi(double_it)
    addi  sp, sp, %lo(stack_top)
    addi  s2, s2, %lo(results)
    addi  t3, t3, %lo(double_it)
    addi  a0, zero, 5
    addi  t1, zero, -1
    addi  t2, zero, 1
    addi  t4, zero, 4
    addi  t5, zero, 0
    jal   ra, sum_to
    nop
    nop
    nop
    sw    a0, 0(s2)

    addi  s0, zero, 0
    beq   t2, t2, B1
    nop
    nop
    nop
    addi  s0, s0, 1
B1: beq   t1, t2, B2
    nop
    nop
    nop
    addi  s0, s0, 2
B2: bne   t1, t2, B3
    nop
    nop
    nop
    addi  s0, s0, 4
B3: bne   t2, t2, B4
    nop
    nop
    nop
    addi  s0, s0, 8
B4: blt   t1, t2, B5
    nop
    nop
    nop
    addi  s0, s0, 16
B5: blt   t2, t1, B6
    nop
    nop
    nop
    addi  s0, s0, 32
B6: bge   t2, t1, B7
    nop
    nop
    nop
    addi  s0, s0, 64
B7: bge   t1, t2, B8
    nop
    nop
    nop
    addi  s0, s0, 128
B8: bltu  t2, t1, B9
    nop
    nop
    nop
    addi  s0, s0, 256
B9: bltu  t1, t2, B10
    nop
    nop
    nop
    addi  s0, s0, 512
B10: bgeu t1, t2, B11
    nop
    nop
    nop
    addi  s0, s0, 1024
B11: addi s1, zero, 0
    bgeu  t2, t1, B12
    nop
    nop
    nop
    addi  s1, s1, 1
B12: bge  t2, t2, B13
    nop
    nop
    nop
    addi  s1, s1, 2
B13: sw   s0, 4(s2)
    sw    s1, 8(s2)

    addi  a0, zero, 21
    jalr  ra, 0(t3)
    nop
    nop
    nop
    sw    a0, 12(s2)

LOOP: add t5, t5, t4
    addi  t4, t4, -1
    nop
    nop
    bne   t4, zero, LOOP
    nop
    nop
    nop
    sw    t5, 16(s2)

    j     FWD
    nop
    nop
    nop
BACK: j   DONE
    nop
    nop
    nop
FWD:  j   BACK
    nop
    nop
    nop
    addi  s1, zero, 99

sum_to:
    beq   a0, zero, SUM_BASE
    nop
    nop
    nop
    sw    ra, -4(sp)
    sw    a0, -8(sp)
    addi  sp, sp, -8
    addi  a0, a0, -1
    jal   ra, sum_to
    nop
    nop
    nop
    lw    t0, 0(sp)
    lw    ra, 4(sp)
    addi  sp, sp, 8
    add   a0, a0, t0
    jalr  zero, 0(ra)
    nop
    nop
    nop
SUM_BASE:
    jalr  zero, 0(ra)
    nop
    nop
    nop

double_it:
    add   a0, a0, a0
    ret
    nop
    nop
    nop

DONE:
    wfi
