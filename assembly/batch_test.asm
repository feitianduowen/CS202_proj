.text
main:
    lui gp, 4                  # gp = 0x4000

loop:
    lw t0, 0(gp)               # case id
    lw t1, 4(gp)               # A
    lw t2, 8(gp)               # B

    beq t0, zero, case0_and

    addi t3, zero, 1
    beq t0, t3, case1_sll

    addi t3, zero, 2
    beq t0, t3, case2_sra

    addi t3, zero, 3
    beq t0, t3, case3_lui_add

    addi t3, zero, 4
    beq t0, t3, case4_jal_auipc

    addi t3, zero, 5
    beq t0, t3, case5_jal_jalr

    addi t3, zero, 6
    beq t0, t3, case6_fib

    addi t3, zero, 7
    beq t0, t3, case7_popcount8

    addi t3, zero, 8
    beq t0, t3, case8_fp16_type

    addi t3, zero, 9
    beq t0, t3, case9_fp16_to_q34

    addi t4, zero, 0
    jal zero, store_result


# case 0: A & B
case0_and:
    and t4, t1, t2
    jal zero, store_result


# case 1: A << B[4:0]
case1_sll:
    andi t3, t2, 31
    sll  t4, t1, t3
    jal zero, store_result


# case 2: arithmetic right shift
case2_sra:
    andi t3, t2, 31
    sra  t4, t1, t3
    jal zero, store_result


# case 3: 0x12345000 + A + B
case3_lui_add:
    lui t3, 0x12345
    add t3, t3, t1
    add t4, t3, t2
    jal zero, store_result


# case 4: jal + auipc, output A + B
case4_jal_auipc:
    jal ra, case4_body

    addi t4, zero, -1          # should not execute
    jal zero, store_result

case4_body:
    auipc t5, 0
    add   t4, t1, t2
    jal zero, store_result


# case 5: jal + jalr, output A - B
case5_jal_jalr:
    jal ra, case5_func
    jal zero, store_result

case5_func:
    sub  t4, t1, t2
    jalr zero, 0(ra)


# case 6: Fibonacci, fib(0)=0, fib(1)=1
case6_fib:
    beq t1, zero, case6_zero

    addi t3, zero, 1
    beq t1, t3, case6_one

    addi t3, zero, 0           # prev
    addi t4, zero, 1           # curr
    addi t5, zero, 1           # i

case6_loop:
    beq t5, t1, store_result

    add t6, t3, t4             # next
    add t3, t4, zero           # prev = curr
    add t4, t6, zero           # curr = next
    addi t5, t5, 1
    jal zero, case6_loop

case6_zero:
    addi t4, zero, 0
    jal zero, store_result

case6_one:
    addi t4, zero, 1
    jal zero, store_result


# case 7: popcount(A[7:0])
case7_popcount8:
    andi t3, t1, 255           # x = A[7:0]

    srli t4, t3, 1
    andi t4, t4, 85            # 0x55
    sub  t3, t3, t4            # x = x - ((x >> 1) & 0x55)

    andi t4, t3, 51            # x & 0x33
    srli t5, t3, 2
    andi t5, t5, 51            # (x >> 2) & 0x33
    add  t3, t4, t5

    srli t4, t3, 4
    add  t3, t3, t4
    andi t4, t3, 15
    jal zero, store_result


# case 8: FP16 type
# 0: zero, 1: inf, 2: NaN, 3: normal, 4: subnormal
case8_fp16_type:
    srli t3, t1, 10
    andi t3, t3, 31            # exp
    andi t4, t1, 1023          # frac

    beq t3, zero, case8_exp0

    addi t5, zero, 31
    beq t3, t5, case8_exp31

    addi t4, zero, 3           # normal
    jal zero, store_result

case8_exp0:
    beq t4, zero, case8_zero

    addi t4, zero, 4           # subnormal
    jal zero, store_result

case8_zero:
    addi t4, zero, 0
    jal zero, store_result

case8_exp31:
    beq t4, zero, case8_inf

    addi t4, zero, 2           # NaN
    jal zero, store_result

case8_inf:
    addi t4, zero, 1
    jal zero, store_result


# case 9: FP16 -> Q3.4
# zero/subnormal -> 0
# inf/NaN -> saturation
# normal -> trunc(value * 16)
case9_fp16_to_q34:
    srli t3, t1, 15
    andi t3, t3, 1             # sign

    srli t5, t1, 10
    andi t5, t5, 31            # exp

    andi t6, t1, 1023          # frac

    beq t5, zero, case9_ret_00

    addi s0, zero, 31
    beq t5, s0, case9_inf_nan

    addi s0, zero, 1
    slli s0, s0, 10
    add  s0, s0, t6            # mant = 1024 + frac

    addi s1, zero, 21
    blt  t5, s1, case9_shift_right

case9_shift_left:
    sub s2, t5, s1
    sll t4, s0, s2
    jal zero, case9_saturate

case9_shift_right:
    sub s2, s1, t5
    srl t4, s0, s2

case9_saturate:
    beq t3, zero, case9_sat_pos

case9_sat_neg:
    addi s3, zero, 128
    blt  t4, s3, case9_neg_no_sat

    addi t4, zero, 128
    jal zero, store_result

case9_neg_no_sat:
    sub  t4, zero, t4
    andi t4, t4, 255
    jal zero, store_result

case9_sat_pos:
    addi s3, zero, 128
    blt  t4, s3, case9_pos_no_sat

    addi t4, zero, 127
    jal zero, store_result

case9_pos_no_sat:
    andi t4, t4, 255
    jal zero, store_result

case9_inf_nan:
    beq t3, zero, case9_ret_7f

    addi t4, zero, 128
    jal zero, store_result

case9_ret_7f:
    addi t4, zero, 127
    jal zero, store_result

case9_ret_00:
    addi t4, zero, 0
    jal zero, store_result


store_result:
    sw t4, 12(gp)
    jal zero, loop