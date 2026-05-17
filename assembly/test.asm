.text
main:
    lui gp, 4
loop:
    lw t1, 4(gp)
    lw t2, 8(gp)
    add t3, t1, t2
    sw t3, 12(gp)
    jal zero, loop