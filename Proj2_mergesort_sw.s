.data
N:          .word 12
array:      .word 34, -5, 17, 0, 99, -42, 17, 8, 3, -1, 56, 21
temp:       .space 128
stack:      .space 512
stack_top:

.text
main:
    lui   t0, %hi(N)
    lui   sp, %hi(stack_top)
    lui   a0, %hi(array)
    addi  t0, t0, %lo(N)
    addi  sp, sp, %lo(stack_top)
    addi  a0, a0, %lo(array)
    lui   ra, %hi(MAIN_CHECK)
    lw    a2, 0(t0)
    addi  a1, zero, 0
    addi  ra, ra, %lo(MAIN_CHECK)
    j     mergesort
    nop
    nop
    nop

mergesort:
    addi  t0, a2, -2
    add   t2, a1, a2
    sw    ra, -4(sp)
    blt   t0, a1, MS_RET
    nop
    nop
    nop
    srli  t2, t2, 1
    sw    a1, -8(sp)
    sw    a2, -12(sp)
    sw    t2, -16(sp)
    addi  a2, t2, 0
    addi  sp, sp, -16
    jal   ra, mergesort
    nop
    nop
    nop
    lw    a1, 0(sp)
    lw    a2, 4(sp)
    jal   ra, mergesort
    nop
    nop
    nop
    lw    a1, 8(sp)
    lw    a2, 0(sp)
    lw    a3, 4(sp)
    lw    ra, 12(sp)
    addi  sp, sp, 16
    j     merge
    nop
    nop
    nop
MS_RET:
    ret
    nop
    nop
    nop

merge:
    lui   t6, %hi(temp)
    slli  t3, a1, 2
    slli  t1, a2, 2
    addi  t6, t6, %lo(temp)
    slli  t2, a3, 2
    add   a5, a0, t1
    add   a4, a0, t3
    add   a7, a0, t3
    lw    t5, 0(a5)
    add   t1, a0, t1
    lw    t4, 0(a4)
    add   a6, t6, t3
    add   t3, t6, t3
    add   t2, a0, t2
M_CMP:
    blt   t5, t4, M_TAKE_RIGHT
    nop
    nop
    nop
    addi  a4, a4, 4
    sw    t4, 0(a6)
    addi  a6, a6, 4
    lw    t4, 0(a4)
    blt   a4, t1, M_CMP
    nop
    nop
    nop
M_COPY_BACK:
    lw    t0, 0(t3)
    nop
M_CB_LOOP:
    addi  t3, t3, 4
    sw    t0, 0(a7)
    addi  a7, a7, 4
    lw    t0, 0(t3)
    blt   t3, a6, M_CB_LOOP
    nop
    nop
    nop
    ret
    nop
    nop
    nop
M_TAKE_RIGHT:
    addi  a5, a5, 4
    sw    t5, 0(a6)
    addi  a6, a6, 4
    lw    t5, 0(a5)
    blt   a5, t2, M_CMP
    nop
    nop
    nop
M_LEFT_TAIL:
    addi  a4, a4, 4
    sw    t4, 0(a6)
    addi  a6, a6, 4
    lw    t4, 0(a4)
    blt   a4, t1, M_LEFT_TAIL
    nop
    nop
    nop
    j     M_COPY_BACK
    nop
    nop
    nop

MAIN_CHECK:
    lui   t0, %hi(N)
    lui   t2, %hi(array)
    addi  t3, zero, 1
    addi  t0, t0, %lo(N)
    addi  t2, t2, %lo(array)
    addi  s0, zero, 1
    lw    t1, 0(t0)
    lw    t5, 0(t2)
    addi  t4, t2, 4
CHECK:
    bge   t3, t1, CHECK_DONE
    nop
    nop
    nop
CHECK_LOOP:
    lw    t6, 0(t4)
    addi  t4, t4, 4
    addi  t3, t3, 1
    bge   t6, t5, CHECK_NEXT
    nop
    nop
    nop
    addi  s0, zero, 0
CHECK_NEXT:
    addi  t5, t6, 0
    blt   t3, t1, CHECK_LOOP
    nop
    nop
    nop
CHECK_DONE:
    lw    s1, 0(t2)
    lw    s2, -4(t4)
    wfi
