.text 
main:
    lui gp, 4

loop:
    lw t0, 0(gp)
    lw t1, 4(gp)
    lw t2, 8(gp)
    
    beq t0, zero, case0_fadd
    
    addi t3, zero, 1
    beq t0, t3, case1_fsub
    
    addi t3, zero, 2
    beq t0, t3, case2_flw_fsw
    
    addi t4, zero, 0
    jal zero, store_result
    
case0_fadd:
    sw t1, 16(gp)
    sw t2, 20(gp)
    flw f1, 16(gp)
    flw f2, 20(gp)
    fadd.s f3, f1, f2
    fsw f3, 16(gp)
    lw t4, 16(gp)
    jal zero, store_result
    
case1_fsub:
    sw t1, 16(gp)
    sw t2, 20(gp)
    flw f1, 16(gp)
    flw f2, 20(gp)
    fsub.s f3, f1, f2
    fsw f3, 16(gp)
    lw t4, 16(gp)
    jal zero, store_result
    
case2_flw_fsw:
    sw   t1, 16(gp)
    flw  f1, 16(gp)
    fsw  f1, 16(gp)
    lw   t4, 16(gp)
    jal  zero, store_result

store_result:
    sw t4, 12(gp)
    jal zero, loop