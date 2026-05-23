module FPAdd (
    input wire [31:0] a,
    input wire [31:0] b,
    input wire sub,     // 0加1减

    output wire [31:0] result
);

    wire sign_a = a[31];
    wire sign_b = b[31] ^ sub;    // 减法时翻转 B 的符号
    wire [7:0] exp_a = a[30:23];
    wire [7:0] exp_b = b[30:23];
    wire [23:0] mant_a = {1'b1, a[22:0]};
    wire [23:0] mant_b = {1'b1, b[22:0]};

    wire [7:0] exp_diff;
    wire a_is_bigger;
    assign a_is_bigger = (exp_a >= exp_b);
    assign exp_diff = a_is_bigger ? (exp_a - exp_b) : (exp_b - exp_a);

    wire [23:0] mant_a_aligned, mant_b_aligned;
    wire [7:0] exp_aligned;

    assign exp_aligned = a_is_bigger ? exp_a : exp_b;
    assign mant_a_aligned = a_is_bigger ? mant_a : (mant_a >> exp_diff);
    assign mant_b_aligned = a_is_bigger ? (mant_b >> exp_diff) : mant_b;

    // 符号处理：同号相加，异号用大的减小的
    wire same_sign = (sign_a == sign_b);
    wire [24:0] mant_sum;
    wire sum_sign;

    wire mant_a_bigger = (mant_a_aligned >= mant_b_aligned);

    assign mant_sum = same_sign
        ? {1'b0, mant_a_aligned} + {1'b0, mant_b_aligned}
        : (mant_a_bigger
            ? {1'b0, mant_a_aligned} - {1'b0, mant_b_aligned}
            : {1'b0, mant_b_aligned} - {1'b0, mant_a_aligned});

    assign sum_sign = same_sign ? sign_a : (mant_a_bigger ? sign_a : sign_b);

    wire has_carry = mant_sum[24];
    wire [24:0] mant_after_carry = has_carry ? (mant_sum >> 1) : mant_sum;
    wire [7:0] exp_after_carry = has_carry ? (exp_aligned + 8'd1) : exp_aligned;

    wire [22:0] mant_result;
    wire [7:0] exp_result;

    Normalize u_norm (
        .mant(mant_after_carry),
        .exp(exp_after_carry),
        .mant_out(mant_result),
        .exp_out(exp_result)
    );

    assign result = {sum_sign, exp_result, mant_result};
    
endmodule