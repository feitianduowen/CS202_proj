module FPAdd (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire sub,     // 0=加, 1=减

    output wire [31:0] result
);

    // 提取字段
    wire sign_a = a[31];
    wire sign_b = b[31] ^ sub;    // 减法时翻转 B 的符号
    wire [7:0] exp_a = a[30:23];
    wire [7:0] exp_b = b[30:23];
    wire [23:0] mant_a = {1'b1, a[22:0]};  // 加上隐含位 1
    wire [23:0] mant_b = {1'b1, b[22:0]};

    // 对齐指数：找出较大指数
    wire [7:0]  exp_diff;
    wire        a_is_bigger;
    assign a_is_bigger = (exp_a >= exp_b);
    assign exp_diff = a_is_bigger ? (exp_a - exp_b) : (exp_b - exp_a);

    // 对齐尾数
    wire [23:0] mant_a_aligned, mant_b_aligned;
    wire [7:0]  exp_aligned;

    assign exp_aligned = a_is_bigger ? exp_a : exp_b;
    assign mant_a_aligned = a_is_bigger ? mant_a : (mant_a >> exp_diff);
    assign mant_b_aligned = a_is_bigger ? (mant_b >> exp_diff) : mant_b;

    // 符号处理：同号相加，异号用大的减小的
    wire        same_sign = (sign_a == sign_b);
    wire [24:0] mant_sum;
    wire        sum_sign;

    wire mant_a_bigger = (mant_a_aligned >= mant_b_aligned);

    assign mant_sum = same_sign
        ? {1'b0, mant_a_aligned} + {1'b0, mant_b_aligned}
        : (mant_a_bigger
            ? {1'b0, mant_a_aligned} - {1'b0, mant_b_aligned}
            : {1'b0, mant_b_aligned} - {1'b0, mant_a_aligned});

    assign sum_sign = same_sign ? sign_a : (mant_a_bigger ? sign_a : sign_b);

    // 规格化
    wire [7:0]  exp_result;
    wire [22:0] mant_result;

    assign {exp_result, mant_result} = normalize(mant_sum, exp_aligned);

    // 最终结果
    assign result = {sum_sign, exp_result, mant_result};

    // 简单的规格化函数
    function [31:0] normalize;
        input [24:0] mant;
        input [7:0]  exp;
        reg [24:0]   shifted;
        reg [7:0]    new_exp;
        begin
            shifted = mant;
            new_exp = exp;
            // 左移直到最高位为 1 或指数归零
            while (shifted[24] == 1'b0 && new_exp > 0) begin
                shifted = shifted << 1;
                new_exp = new_exp - 8'd1;
            end
            normalize = {new_exp, shifted[22:0]};
        end
    endfunction

endmodule