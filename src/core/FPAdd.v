module FPAdd (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire        sub,     // 0: a + b, 1: a - b
    output wire [31:0] result
);

    // -----------------------------
    // 1. 拆分字段 + 基本分类
    // -----------------------------
    wire        sign_a_w = a[31];
    wire        sign_b_w = b[31] ^ sub;   // 做减法时，等价于把 b 的符号翻转
    wire [7:0]  exp_a_w  = a[30:23];
    wire [7:0]  exp_b_w  = b[30:23];
    wire [22:0] frac_a_w = a[22:0];
    wire [22:0] frac_b_w = b[22:0];

    wire a_is_nan  = (exp_a_w == 8'hff) && (frac_a_w != 23'd0);
    wire b_is_nan  = (exp_b_w == 8'hff) && (frac_b_w != 23'd0);
    wire a_is_inf  = (exp_a_w == 8'hff) && (frac_a_w == 23'd0);
    wire b_is_inf  = (exp_b_w == 8'hff) && (frac_b_w == 23'd0);
    wire a_is_zero = (exp_a_w == 8'd0)  && (frac_a_w == 23'd0);
    wire b_is_zero = (exp_b_w == 8'd0)  && (frac_b_w == 23'd0);

    // 带 sticky bit 的右移：用于尾数对齐，避免移出去的 1 完全丢失
    function [26:0] shift_right_sticky;
        input [26:0] value;
        input [7:0]  shamt;
        reg          sticky;
        begin
            if (shamt == 8'd0) begin
                shift_right_sticky = value;
            end else if (shamt >= 8'd27) begin
                shift_right_sticky = {26'd0, |value};
            end else begin
                sticky = |(value & ((27'd1 << shamt) - 27'd1));
                shift_right_sticky = value >> shamt;
                shift_right_sticky[0] = shift_right_sticky[0] | sticky;
            end
        end
    endfunction

    reg [31:0] result_r;
    assign result = result_r;

    // 中间变量
    reg [7:0]  exp_a_eff, exp_b_eff;
    reg [23:0] mant_a, mant_b;

    reg        sign_big, sign_res;
    reg [7:0]  exp_big, exp_small, exp_res;
    reg [23:0] mant_big24, mant_small24;
    reg [7:0]  exp_diff;

    reg [26:0] mant_big_ext;
    reg [26:0] mant_small_ext;
    reg [26:0] mant_small_aligned;
    reg [27:0] mant_added;
    reg [26:0] mant_work;

    reg [23:0] mant_main;
    reg        guard_bit, round_bit, sticky_bit, round_up;
    reg [24:0] rounded_ext;
    reg [23:0] mant_rounded;

    integer i;

    always @(*) begin
        // 默认值，避免锁存器
        result_r           = 32'h0000_0000;
        exp_a_eff          = 8'd0;
        exp_b_eff          = 8'd0;
        mant_a             = 24'd0;
        mant_b             = 24'd0;
        sign_big           = 1'b0;
        sign_res           = 1'b0;
        exp_big            = 8'd0;
        exp_small          = 8'd0;
        exp_res            = 8'd0;
        mant_big24         = 24'd0;
        mant_small24       = 24'd0;
        exp_diff           = 8'd0;
        mant_big_ext       = 27'd0;
        mant_small_ext     = 27'd0;
        mant_small_aligned = 27'd0;
        mant_added         = 28'd0;
        mant_work          = 27'd0;
        mant_main          = 24'd0;
        guard_bit          = 1'b0;
        round_bit          = 1'b0;
        sticky_bit         = 1'b0;
        round_up           = 1'b0;
        rounded_ext        = 25'd0;
        mant_rounded       = 24'd0;

        // -----------------------------
        // 2. 特殊值处理：NaN / Inf / Zero
        // -----------------------------
        if (a_is_nan || b_is_nan) begin
            result_r = 32'h7fc0_0000;  // quiet NaN
        end else if (a_is_inf && b_is_inf && (sign_a_w != sign_b_w)) begin
            result_r = 32'h7fc0_0000;  // +Inf + -Inf = NaN
        end else if (a_is_inf) begin
            result_r = {sign_a_w, 8'hff, 23'd0};
        end else if (b_is_inf) begin
            result_r = {sign_b_w, 8'hff, 23'd0};
        end else if (a_is_zero && b_is_zero) begin
            // 符号相同时保留符号；符号不同则返回 +0
            result_r = {((sign_a_w == sign_b_w) ? sign_a_w : 1'b0), 31'd0};
        end else if (a_is_zero) begin
            result_r = {sign_b_w, exp_b_w, frac_b_w};
        end else if (b_is_zero) begin
            result_r = a;
        end else begin
            // -----------------------------
            // 3. 普通数 / 非规格化数处理
            // -----------------------------
            // 非规格化数没有隐藏位 1；它的有效指数按 1 参与对齐
            exp_a_eff = (exp_a_w == 8'd0) ? 8'd1 : exp_a_w;
            exp_b_eff = (exp_b_w == 8'd0) ? 8'd1 : exp_b_w;

            mant_a = (exp_a_w == 8'd0) ? {1'b0, frac_a_w}
                                        : {1'b1, frac_a_w};

            mant_b = (exp_b_w == 8'd0) ? {1'b0, frac_b_w}
                                        : {1'b1, frac_b_w};

            // 先按绝对值大小排序，异号相减时用大数减小数
            if ({exp_a_eff, mant_a} >= {exp_b_eff, mant_b}) begin
                sign_big     = sign_a_w;
                exp_big      = exp_a_eff;
                exp_small    = exp_b_eff;
                mant_big24   = mant_a;
                mant_small24 = mant_b;
            end else begin
                sign_big     = sign_b_w;
                exp_big      = exp_b_eff;
                exp_small    = exp_a_eff;
                mant_big24   = mant_b;
                mant_small24 = mant_a;
            end

            exp_diff           = exp_big - exp_small;
            mant_big_ext       = {mant_big24,   3'b000};
            mant_small_ext     = {mant_small24, 3'b000};
            mant_small_aligned = shift_right_sticky(mant_small_ext, exp_diff);
            exp_res            = exp_big;

            if (sign_a_w == sign_b_w) begin
                // 同号：尾数相加
                sign_res   = sign_a_w;
                mant_added = {1'b0, mant_big_ext} + {1'b0, mant_small_aligned};

                // 加法可能产生进位，需要右移一位，指数 +1
                if (mant_added[27]) begin
                    mant_work    = mant_added[27:1];
                    mant_work[0] = mant_work[0] | mant_added[0];
                    exp_res      = exp_big + 8'd1;
                end else begin
                    mant_work = mant_added[26:0];
                end
            end else begin
                // 异号：绝对值大的尾数减绝对值小的尾数
                sign_res  = sign_big;
                mant_work = mant_big_ext - mant_small_aligned;

                // 减法后可能需要左规。最多移动 24 次即可。
                for (i = 0; i < 24; i = i + 1) begin
                    if ((mant_work[26] == 1'b0) &&
                        (exp_res > 8'd1) &&
                        (mant_work != 27'd0)) begin
                        mant_work = mant_work << 1;
                        exp_res   = exp_res - 8'd1;
                    end
                end
            end

            // -----------------------------
            // 4. Round to nearest, ties to even
            // -----------------------------
            if (mant_work == 27'd0) begin
                result_r = 32'h0000_0000;
            end else begin
                mant_main  = mant_work[26:3];
                guard_bit  = mant_work[2];
                round_bit  = mant_work[1];
                sticky_bit = mant_work[0];

                // round to nearest, ties to even
                round_up = guard_bit & (round_bit | sticky_bit | mant_main[0]);

                rounded_ext = {1'b0, mant_main} +
                              (round_up ? 25'd1 : 25'd0);

                // 舍入后可能再次进位，例如 1.111... 舍入成 10.000...
                if (rounded_ext[24]) begin
                    mant_rounded = rounded_ext[24:1];
                    exp_res      = exp_res + 8'd1;
                end else begin
                    mant_rounded = rounded_ext[23:0];
                end

                if (mant_rounded == 24'd0) begin
                    result_r = 32'h0000_0000;
                end else if (exp_res >= 8'hff) begin
                    // overflow -> Inf
                    result_r = {sign_res, 8'hff, 23'd0};
                end else if ((exp_res == 8'd1) &&
                             (mant_rounded[23] == 1'b0)) begin
                    // 非规格化结果：指数域为 0，没有隐藏位
                    result_r = {sign_res, 8'd0, mant_rounded[22:0]};
                end else begin
                    // 规格化结果：丢掉隐藏位
                    result_r = {sign_res, exp_res, mant_rounded[22:0]};
                end
            end
        end
    end

endmodule