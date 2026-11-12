.data
base_data:  .word 0x11223344, 0, 0, 0

.text
main:
    addi  s0, zero, 25
    addi  s1, zero, -7
    lui   s2, 0xABCDE
    addi  t1, zero, 4
    auipc s3, 0
    addi  s2, s2, 0x123
    add   s4, s0, s1
    sub   s5, s1, s0
    addi  s3, s3, 8
    addi  t5, zero, 35

    xor   s9, s2, s1
    andi  s10, s2, 0x0FF
    sub   s6, s4, s4
    and   s7, s2, s4
    or    s8, s2, s5
    ori   s11, s4, 0x700
    xori  t0, s5, -1

    sll   t2, s2, t1
    srl   t3, s2, t1
    sra   t4, s2, t1
    sll   t6, s0, t5
    slli  a0, s1, 28
    srli  a1, s1, 28
    srai  a2, s1, 2
    slt   a4, s1, s0
    srai  a3, a0, 31

    slt   a5, s0, s1
    sltu  a6, s1, s0
    sltu  a7, s0, s1
    slti  gp, s1, -6
    sltiu ra, s0, -1
    add   t1, a4, a7
    lui   t5, %hi(base_data)
    slti  tp, s0, 25
    add   t1, t1, ra
    addi  t5, t5, %lo(base_data)
    sltiu sp, s1, 5
    sll   t1, s4, t1

    lw    s6, 0(t5)
    sw    s2, 4(t5)
    lw    s7, 4(t5)
    sw    zero, 8(t5)
    sb    s1, 8(t5)
    sh    s5, 10(t5)
    lw    s8, 8(t5)
    lb    a4, 8(t5)
    lbu   a5, 8(t5)
    add   s9, s8, s7
    lh    a6, 10(t5)
    lhu   a7, 10(t5)
    sw    s9, 12(t5)
    lb    gp, 1(t5)
    lhu   tp, 2(t5)

    wfi
