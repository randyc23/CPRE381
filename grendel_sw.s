#
# Topological sort using an adjacency matrix. Maximum 4 nodes.
#
# The expected output of this program is that the 1st 4 addresses of the data segment
# are [4,0,3,2]. should take ~2000 cycles in a single cycle procesor.
#

# Adapted to RISC-V by Connor J. Link (3.1.2025)
# Per testing [3, 0, 2, 1] is the expected output (matches the original grendel.s in MARS)

.data
res:
	.word -1-1-1-1
nodes:
        .byte   97 # a
        .byte   98 # b
        .byte   99 # c
        .byte   100 # d
adjacencymatrix:
        .word   6
        .word   0
        .word   0
        .word   3
visited:
	.byte 0 0 0 0
res_idx:
        .word   3
.text
        lui  ra, %hi(end)
        lui  sp, 0x10011
        li   fp, 0
        addi ra, ra, %lo(end)
        j    main
    nop
    nop
    nop

main:
        sw   fp, -8(sp)
        sw   ra, -4(sp)
        sw   x0, -16(sp)
        addi fp, sp, -40
        addi sp, sp, -40
        j    main_loop_control
    nop
    nop
    nop

main_loop_body:
        lw   t4, 24(fp)
        jal  ra, is_visited
    nop
    nop
    nop
trucks:
        xori t2, t2, 1
        lw   t4, 24(fp)
    nop
        andi t2, t2, 0xff
    nop
    nop
        beq  t2, x0, kick
    nop
    nop
    nop
        jal  ra, topsort
    nop
    nop
    nop
kick:
        lw   t2, 24(fp)
    nop
    nop
        addi t2, t2, 1
    nop
    nop
        sw   t2, 24(fp)
main_loop_control:
        lw   t2, 24(fp)
    nop
    nop
        slti t2, t2, 4
    nop
    nop
        bne  t2, x0, main_loop_body
    nop
    nop
    nop
hew:
        sw   x0, 28(fp)
        j    welcome
    nop
    nop
    nop

wave:
        lw   t2, 28(fp)
    nop
    nop
        addi t2, t2, 1
    nop
    nop
        sw   t2, 28(fp)
welcome:
        lw   t2, 28(fp)
    nop
    nop
        slti t2, t2, 4
    nop
    nop
        xori t2, t2, 1
    nop
    nop
        beq  t2, x0, wave
    nop
    nop
    nop
        mv   sp, fp
        mv   t2, x0
        lw   ra, 36(fp)
        lw   fp, 32(fp)
        addi sp, sp, 40
        jr   ra
    nop
    nop
    nop

interest:
        lw   t4, 24(fp)
        jal  ra, is_visited
    nop
    nop
    nop
new:
        xori t2, t2, 1
        lw   t4, 24(fp)
    nop
        andi t2, t2, 0x0ff
    nop
    nop
        beq  t2, x0, tasteful
    nop
    nop
    nop
        jal  ra, topsort
    nop
    nop
    nop
tasteful:
        addi t2, fp, 28
    nop
    nop
        mv   t4, t2
        jal  ra, next_edge
    nop
    nop
    nop
turkey:
        sw   t2, 24(fp)
        lw   t3, 24(fp)
        li   t2, -1
    nop
    nop
        bne  t3, t2, interest
    nop
    nop
    nop
telling:
        lui  t2, %hi(res_idx)
        lui  t3, %hi(res_idx)
        lui  a1, 0x10
        addi t2, t2, %lo(res_idx)
        addi t3, t3, %lo(res_idx)
        addi a1, a1, -1
        lw   t2, 0(t2)
        mv   sp, fp
    nop
        addi t4, t2, -1
        xor  t6, ra, t2
        or   t6, ra, t2
        sw   t4, 0(t3)
        slli t3, t2, 2
        neg  t6, t6
        lui  t4, %hi(res)
        srli t3, t3, 1
        lui  t2, %hi(res)
        addi t4, t4, %lo(res)
        srai t3, t3, 1
        addi t2, t2, %lo(res)
        lw   ra, 44(fp)
        slli t3, t3, 2
        and  t6, t2, a1
        addi sp, sp, 48
    nop
        add  t2, t4, t6
    nop
    nop
        add  t2, t3, t2
        lw   t3, 48(fp)
        lw   fp, 40(fp)
    nop
        sw   t3, 0(t2)
        jr   ra
    nop
    nop
    nop

topsort:
        sw   ra, -4(sp)
        sw   fp, -8(sp)
        sw   t4, 0(sp)
        lw   t4, 0(sp)
        addi fp, sp, -48
        addi sp, sp, -48
        jal  ra, mark_visited
    nop
    nop
    nop
verse:
        addi t2, fp, 28
        lw   t5, 48(fp)
    nop
        mv   t4, t2
        jal  ra, iterate_edges
    nop
    nop
    nop
joyous:
        addi t2, fp, 28
    nop
    nop
        mv   t4, t2
        jal  ra, next_edge
    nop
    nop
    nop
whispering:
        j    turkey
    nop
    nop
    nop

iterate_edges:
        sw   fp, -4(sp)
        sw   t4, 0(sp)
        sw   t5, 4(sp)
        addi fp, sp, -24
        lw   t2, 4(sp)
        sw   x0, -12(sp)
        addi sp, sp, -24
        sw   t2, 8(fp)
        lw   t2, 24(fp)
        sub  t6, fp, sp
        lw   t4, 8(fp)
        lw   t3, 12(fp)
        mv   sp, fp
        sw   t4, 0(t2)
        sw   t3, 4(t2)
        lw   t2, 24(fp)
        addi sp, sp, 24
        lw   fp, 20(fp)
        jr   ra
    nop
    nop
    nop

next_edge:
        sw   ra, -4(sp)
        sw   fp, -8(sp)
        sw   t4, 0(sp)
        addi fp, sp, -32
        lw   t2, 4(t4)
        addi sp, sp, -32
    nop
        slti t2, t2, 4
    nop
    nop
        bne  t2, x0, snail
    nop
    nop
    nop
mark:
        li   t2, -1
cynical:
        mv   sp, fp
        lw   ra, 28(fp)
        lw   fp, 24(fp)
        addi sp, sp, 32
        jr   ra
    nop
    nop
    nop

snail:
        lw   t2, 32(fp)
    nop
    nop
        lw   t3, 0(t2)
        lw   t2, 4(t2)
    nop
        mv   t4, t3
        mv   t5, t2
        jal  ra, has_edge
    nop
    nop
    nop
induce:
        lw   t3, 32(fp)
        beq  t2, x0, quarter
    nop
    nop
    nop
        lw   t2, 4(t3)
        mv   sp, fp
        lw   ra, 28(fp)
        addi t4, t2, 1
        addi sp, sp, 32
    nop
        sw   t4, 4(t3)
        lw   fp, 24(fp)
        jr   ra
    nop
    nop
    nop

quarter:
        lw   t2, 4(t3)
    nop
    nop
        addi t4, t2, 1
    nop
    nop
        slti t2, t4, 4
        sw   t4, 4(t3)
    nop
        bne  t2, x0, snail
    nop
    nop
    nop
        j    mark
    nop
    nop
    nop

has_edge:
        sw   fp, -4(sp)
        sw   t4, 0(sp)
        lui  t2, %hi(adjacencymatrix)
        lw   t3, 0(sp)
        sw   t5, 4(sp)
        addi fp, sp, -32
        addi t2, t2, %lo(adjacencymatrix)
        slli t3, t3, 2
        li   t6, 1
    nop
        add  t2, t3, t2
        sw   x0, -20(sp)
        sw   t6, -24(sp)
        lw   t2, 0(t2)
        lw   t3, 12(fp)
        lw   t6, 36(fp)
        sw   t2, 16(fp)
        addi sp, sp, -32
        slt  t2, t3, t6
    nop
    nop
        beq  t2, x0, experience
    nop
    nop
    nop
look:
        lw   t2, 8(fp)
        lw   t3, 12(fp)
        lw   t6, 36(fp)
        slli t2, t2, 1
        addi t3, t3, 1
    nop
        sw   t2, 8(fp)
        sw   t3, 12(fp)
        slt  t2, t3, t6
    nop
    nop
        bne  t2, x0, look
    nop
    nop
    nop
experience:
        lw   t3, 8(fp)
        lw   t2, 16(fp)
        mv   sp, fp
    nop
        and  t2, t3, t2
        lw   fp, 28(fp)
        addi sp, sp, 32
        slt  t2, x0, t2
    nop
    nop
        andi t2, t2, 0xff
        jr   ra
    nop
    nop
    nop

mark_visited:
        sw   fp, -4(sp)
        sw   t4, 0(sp)
        li   t2, 1
        addi fp, sp, -32
        sw   x0, -20(sp)
        sw   t2, -24(sp)
        addi sp, sp, -32
        lw   t3, 12(fp)
        lw   t2, 32(fp)
    nop
    nop
        slt  t2, t3, t2
    nop
    nop
        beq  t2, x0, pat
    nop
    nop
    nop
example:
        lw   t2, 8(fp)
        lw   t3, 12(fp)
        lw   t6, 32(fp)
        slli t2, t2, 8
        addi t3, t3, 1
    nop
        sw   t2, 8(fp)
        sw   t3, 12(fp)
        slt  t2, t3, t6
    nop
    nop
        bne  t2, x0, example
    nop
    nop
    nop
pat:
        lui  t2, %hi(visited)
        lw   t5, 8(fp)
        mv   sp, fp
        addi t2, t2, %lo(visited)
    nop
        addi sp, sp, 32
        sw   t2, 16(fp)
        lw   t2, 16(fp)
    nop
    nop
        lw   t3, 0(t2)
    nop
    nop
        or   t3, t3, t5
        lw   t2, 16(fp)
    nop
    nop
        sw   t3, 0(t2)
        lw   fp, 28(fp)
        jr   ra
    nop
    nop
    nop

is_visited:
        sw   fp, -4(sp)
        sw   t4, 0(sp)
        ori  t2, x0, 1
        addi fp, sp, -32
        sw   x0, -20(sp)
        sw   t2, -24(sp)
        addi sp, sp, -32
        lw   t3, 12(fp)
        lw   t2, 32(fp)
    nop
    nop
        slt  t2, t3, t2
    nop
    nop
        beq  t2, x0, representative
    nop
    nop
    nop
justify:
        lw   t2, 8(fp)
        lw   t3, 12(fp)
        lw   t6, 32(fp)
        slli t2, t2, 8
        addi t3, t3, 1
    nop
        sw   t2, 8(fp)
        sw   t3, 12(fp)
        slt  t2, t3, t6
    nop
    nop
        bne  t2, x0, justify
    nop
    nop
    nop
representative:
        lui  t2, %hi(visited)
        lw   t3, 8(fp)
        mv   sp, fp
        addi t2, t2, %lo(visited)
    nop
        addi sp, sp, 32
        lw   t2, 0(t2)
    nop
    nop
        sw   t2, 16(fp)
        and  t2, t2, t3
        lw   fp, 28(fp)
    nop
        slt  t2, x0, t2
    nop
    nop
        andi t2, t2, 0xff
        jr   ra
    nop
    nop
    nop

end:
        wfi
