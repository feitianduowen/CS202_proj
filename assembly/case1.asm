.text
_start:
    addi x1, x0, 10
    addi x2, x0, 3

    add x3, x1, x2
    addi x4, x0, 13
    bne x3, x4, fail

    sub x3, x1, x2
    addi x4, x0, 7
    bne x3, x4, fail

    and x3, x1, x2
    addi x4, x0, 2
    bne x3, x4, fail

    or x3, x1, x2
    addi x4, x0, 11
    bne x3, x4, fail

    xor x3, x1, x2
    addi x4, x0, 9
    bne x3, x4, fail

    sll x3, x2, x2
    addi x4, x0, 24
    bne x3, x4, fail

    addi x5, x0, -16
    addi x6, x0, 2

    srl x3, x5, x6
    lui x4, 0x40000
    addi x4, x4, -4
    bne x3, x4, fail

    sra x3, x5, x6
    addi x4, x0, -4
    bne x3, x4, fail

    slt x3, x5, x2
    addi x4, x0, 1
    bne x3, x4, fail

    sltu x3, x5, x2
    bne x3, x0, fail

    addi x7, x0, 10

    andi x3, x7, 6
    addi x4, x0, 2
    bne x3, x4, fail

    ori x3, x7, 5
    addi x4, x0, 15
    bne x3, x4, fail

    xori x3, x7, 15
    addi x4, x0, 5
    bne x3, x4, fail

    slti x3, x5, -4
    addi x4, x0, 1
    bne x3, x4, fail

    sltiu x3, x5, 5
    bne x3, x0, fail

    addi x3, x0, 1
    slli x3, x3, 5
    addi x4, x0, 32
    bne x3, x4, fail

    srli x3, x5, 2
    lui x4, 0x40000
    addi x4, x4, -4
    bne x3, x4, fail

    srai x3, x5, 2
    addi x4, x0, -4
    bne x3, x4, fail

    blt x2, x1, br1
    jal x0, fail

br1:
    bge x1, x2, br2
    jal x0, fail

br2:
    bltu x2, x1, br3
    jal x0, fail

br3:
    bgeu x1, x2, br4
    jal x0, fail

br4:
    beq x1, x1, br5
    jal x0, fail

br5:
    bne x1, x2, br6
    jal x0, fail

br6:
    auipc x3, 0x0
    addi x3, x3, -288
    bne x3, x0, fail

    lui x3, 0x12345
    addi x3, x3, 0x678
    sw x3, 32(x0)
    lw x4, 32(x0)
    bne x4, x3, fail

    lui x20, 0x80ff8
    addi x20, x20, -256
    sw x20, 36(x0)

    lh x3, 34(x0)
    lui x4, 0x00001
    addi x4, x4, 0x234
    bne x3, x4, fail

    lb x3, 38(x0)
    addi x4, x0, -1
    bne x3, x4, fail

    lb x3, 39(x0)
    addi x4, x0, -128
    bne x3, x4, fail

    lh x3, 38(x0)
    lui x4, 0xffff8
    addi x4, x4, 0x0ff
    bne x3, x4, fail

    lbu x3, 38(x0)
    addi x4, x0, 255
    bne x3, x4, fail

    lhu x3, 38(x0)
    lui x4, 0x00008
    addi x4, x4, 0x0ff
    bne x3, x4, fail

    addi x5, x0, -1

    sb x5, 41(x0)
    lb x6, 41(x0)
    bne x6, x5, fail

    sh x5, 46(x0)
    lh x6, 46(x0)
    bne x6, x5, fail

    jal x8, jal_target
    jal x0, fail

jal_target:
    addi x9, x8, -448
    bne x9, x0, fail

    addi x10, x0, 472
    jalr x11, 0(x10)
    jal x0, fail

jalr_target:
    addi x12, x11, -468
    bne x12, x0, fail

pass:
    addi x30, x0, 85
    sw x30, 64(x0)

pass_loop:
    beq x0, x0, pass_loop #最后应该停在这里，指令是0x00000063

fail:
    addi x30, x0, 51
    sw x30, 64(x0)

fail_loop:
    beq x0, x0, fail_loop