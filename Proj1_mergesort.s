.data
N:          .word 12
array:      .word 34, -5, 17, 0, 99, -42, 17, 8, 3, -1, 56, 21
temp:       .space 128
stack:      .space 512
stack_top:

.text
main:
    la    sp, stack_top
    la    a0, array
    la    t0, N
    lw    a2, 0(t0)
    addi  a1, zero, 0
    jal   ra, mergesort

    la    t0, N
    lw    t1, 0(t0)
    la    t2, array
    addi  s0, zero, 1
    addi  t3, zero, 1
CHECK:
    bge   t3, t1, CHECK_DONE
    slli  t4, t3, 2
    add   t4, t2, t4
    lw    t5, -4(t4)
    lw    t6, 0(t4)
    bge   t6, t5, CHECK_NEXT
    addi  s0, zero, 0
CHECK_NEXT:
    addi  t3, t3, 1
    j     CHECK
CHECK_DONE:
    lw    s1, 0(t2)
    slli  t4, t1, 2
    add   t4, t2, t4
    lw    s2, -4(t4)
    j     DONE

mergesort:
    sub   t0, a2, a1
    addi  t1, zero, 2
    blt   t0, t1, MS_RET
    addi  sp, sp, -16
    sw    ra, 12(sp)
    sw    a1, 8(sp)
    sw    a2, 4(sp)
    add   t2, a1, a2
    srli  t2, t2, 1
    sw    t2, 0(sp)
    mv    a2, t2
    jal   ra, mergesort
    lw    a1, 0(sp)
    lw    a2, 4(sp)
    jal   ra, mergesort
    lw    a1, 8(sp)
    lw    a2, 0(sp)
    lw    a3, 4(sp)
    jal   ra, merge
    lw    ra, 12(sp)
    addi  sp, sp, 16
MS_RET:
    ret

merge:
    la    t6, temp
    mv    t0, a1
    mv    t1, a2
    mv    t2, a1
M_LOOP:
    bge   t0, a2, M_COPY_BACK
    bge   t1, a3, M_LEFT_TAIL
    slli  t3, t0, 2
    add   t3, a0, t3
    lw    t4, 0(t3)
    slli  t3, t1, 2
    add   t3, a0, t3
    lw    t5, 0(t3)
    slli  t3, t2, 2
    add   t3, t6, t3
    blt   t5, t4, M_TAKE_RIGHT
    sw    t4, 0(t3)
    addi  t0, t0, 1
    j     M_NEXT
M_TAKE_RIGHT:
    sw    t5, 0(t3)
    addi  t1, t1, 1
M_NEXT:
    addi  t2, t2, 1
    j     M_LOOP
M_LEFT_TAIL:
    bge   t0, a2, M_COPY_BACK
    slli  t3, t0, 2
    add   t3, a0, t3
    lw    t4, 0(t3)
    slli  t3, t2, 2
    add   t3, t6, t3
    sw    t4, 0(t3)
    addi  t0, t0, 1
    addi  t2, t2, 1
    j     M_LEFT_TAIL
M_COPY_BACK:
    mv    t0, a1
M_CB_LOOP:
    bge   t0, t2, M_DONE
    slli  t3, t0, 2
    add   t4, t6, t3
    lw    t5, 0(t4)
    add   t4, a0, t3
    sw    t5, 0(t4)
    addi  t0, t0, 1
    j     M_CB_LOOP
M_DONE:
    ret

DONE:
    wfi
