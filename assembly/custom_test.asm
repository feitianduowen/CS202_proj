# 硬件加速指令测试
# 机器码: 0000000_00000_rs1-5bits_funct3-3bits_rd-5bits_0001011
.text
main:
    lui gp, 4                  # gp = 0x4000
    lui t5, 0x00228            # t5 = 0x00228000

loop:
    lw t0, 0(gp)               # case id
    lw t1, 4(gp)               # A (00101)
    lw t2, 8(gp)               # B
    
    beq t0, zero, case0_fib

    addi t3, zero, 1
    beq t0, t3, case1_popcount8

    addi t3, zero, 2
    beq t0, t3, case2_fp16_type

    addi t3, zero, 3
    beq t0, t3, case3_fp16_to_q34
    
    addi t4, zero, 0           # 00100
    jal zero, store_result
    
case0_fib:
    # funct3=011
    addi t5, t5, 0x303        # 0x00228303
    jalr zero, t5, 0
    addi t5, t5, -0x303       # 恢复
    jal zero, store_result
    
case1_popcount8:
    # funct3=000
    addi t5, t5, 0x003        # 0x00228003
    jalr zero, t5, 0
    addi t5, t5, -0x003       # 恢复
    jal zero, store_result

case2_fp16_type:
    # funct3=001
    addi t5, t5, 0x103        # 0x00228103
    jalr zero, t5, 0
    addi t5, t5, -0x103       # 恢复
    jal zero, store_result

case3_fp16_to_q34:
    # funct3=010
    addi t5, t5, 0x203        # 0x00228203
    jalr zero, t5, 0
    addi t5, t5, -0x203       # 恢复
    jal zero, store_result
    
store_result:
    sw t4, 12(gp)
    jal zero, loop