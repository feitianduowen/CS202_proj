# 硬件加速指令测试
.text
main:
    lui gp, 4                  # gp = 0x4000

loop:
    lw t0, 0(gp)               # case id
    lw t1, 4(gp)               # A
    lw t2, 8(gp)               # B
    
    beq t0, zero, case0_vpnot

    addi t3, zero, 1
    beq t0, t3, case1_vpneg

    addi t3, zero, 2
    beq t0, t3, case2_vpabs
    
    addi t3, zero, 3
    beq t0, t3, case3_vpadd

    addi t3, zero, 4
    beq t0, t3, case4_vpsub

    addi t3, zero, 5
    beq t0, t3, case5_vpand

    addi t3, zero, 6
    beq t0, t3, case6_vpor

    addi t3, zero, 7
    beq t0, t3, case7_vpxor

    addi t3, zero, 8
    beq t0, t3, case8_vpsll

    addi t3, zero, 9
    beq t0, t3, case9_vpsrl
    
    addi t3, zero, 10
    beq t0, t3, case10_vpmin
    
    addi t3, zero, 11
    beq t0, t3, case11_vpmax

    addi t4, zero, 0
    jal zero, store_result
    
# funct7[6:0] | rs2[4:0] | rs1[4:0] | funct3[2:0] | rd[4:0] | opcode[6:0]
#             |  00111   |  00110   |             |  11101  | 0001011
    
# vp.not t4, t1  →  funct7=0x00, funct3=000  →  0x00730E8B
case0_vpnot:
    lui  t5, 0x00731
    addi t5, t5, -0x175
    jalr zero, t5, 0
    jal  zero, store_result
    
# vp.neg t4, t1  →  funct7=0x00, funct3=001  →  0x00731E8B
case1_vpneg:
    lui  t5, 0x00732
    addi t5, t5, -0x175
    jalr zero, t5, 0
    jal  zero, store_result

# vp.abs t4, t1  →  funct7=0x00, funct3=010  →  0x00732E8B
case2_vpabs:
    lui  t5, 0x00733
    addi t5, t5, -0x175
    jalr zero, t5, 0
    jal  zero, store_result

# vp.add t4, t1, t2  →  funct7=0x00, funct3=011  →  0x00733E8B
case3_vpadd:
    lui  t5, 0x00734
    addi t5, t5, -0x175
    jalr zero, t5, 0
    jal  zero, store_result
    
# vp.sub t4, t1, t2  →  funct7=0x00, funct3=100  →  0x00734E8B
case4_vpsub:
    lui  t5, 0x00735
    addi t5, t5, -0x175
    jalr zero, t5, 0
    jal  zero, store_result
    
# vp.and t4, t1, t2  →  funct7=0x00, funct3=101  →  0x00735E8B
case5_vpand:
    lui  t5, 0x00736
    addi t5, t5, -0x175
    jalr zero, t5, 0
    jal  zero, store_result
    
# vp.or t4, t1, t2  →  funct7=0x00, funct3=110  →  0x00736E8B
case6_vpor:
    lui  t5, 0x00737
    addi t5, t5, -0x175
    jalr zero, t5, 0
    jal  zero, store_result
    
# vp.xor t4, t1, t2  →  funct7=0x00, funct3=111  →  0x00737E8B
case7_vpxor:
    lui  t5, 0x00738
    addi t5, t5, -0x175
    jalr zero, t5, 0
    jal  zero, store_result
      
# vp.sll t4, t1, t2  →  funct7=0x01, funct3=000  →  0x02730E8B
case8_vpsll:
    lui  t5, 0x02731
    addi t5, t5, -0x175
    jalr zero, t5, 0
    jal  zero, store_result
    
# vp.srl t4, t1, t2  →  funct7=0x01, funct3=001  →  0x02731E8B
case9_vpsrl:
    lui  t5, 0x02732
    addi t5, t5, -0x175
    jalr zero, t5, 0
    jal  zero, store_result

# vp.min t4, t1, t2  →  funct7=0x01, funct3=010  →  0x02732E8B
case10_vpmin:
    lui  t5, 0x02733
    addi t5, t5, -0x175
    jalr zero, t5, 0
    jal  zero, store_result

# vp.max t4, t1, t2  →  funct7=0x01, funct3=011  →  0x02733E8B
case11_vpmax:
    lui  t5, 0x02734
    addi t5, t5, -0x175
    jalr zero, t5, 0
    jal  zero, store_result
    
store_result:
    sw t4, 12(gp)
    jal zero, loop
