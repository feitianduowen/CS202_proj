module Accelerator (
    input  wire [31:0] rs1_data,    // 输入操作数
    input  wire [2:0]  funct3,      // 功能选择
    output reg  [31:0] result       // 计算结果
);

    // funct3 定义
    // 3'b000: popcount (rs1[7:0])
    // 3'b001: fp16_classify (rs1[15:0])
    // 3'b010: fp16_to_q34 (rs1[15:0])
    // 3'b011: fibonacci (rs1[7:0])

    // pop_count
    wire [7:0] pop_in = rs1_data[7:0];   // 8 位输入
    wire [3:0] pop_count;                // 逐位相加
    assign pop_count = pop_in[0] + pop_in[1] + pop_in[2] + pop_in[3] + 
                        pop_in[4] + pop_in[5] + pop_in[6] + pop_in[7];

    // fp16_classify
    wire        fp16_sign  = rs1_data[15];           // 符号位
    wire [4:0]  fp16_exp   = rs1_data[14:10];        // 指数
    wire [9:0]  fp16_mant  = rs1_data[9:0];          // 尾数

    wire [3:0]  class_out;                           // 类型编码 0~4

    assign class_out = (fp16_exp == 5'd0 && fp16_mant == 10'd0)  ? 4'd0 :   // 零
                   (fp16_exp == 5'd0 && fp16_mant != 10'd0)  ? 4'd4 :   // 非规约化数
                   (fp16_exp == 5'd31 && fp16_mant == 10'd0) ? 4'd1 :   // 无穷大
                   (fp16_exp == 5'd31 && fp16_mant != 10'd0) ? 4'd2 :   // NaN
                                                                4'd3;   // 规约化数

    // fp16 -> Q3.4
    wire        q34_sign  = rs1_data[15];           // 符号位
    wire [4:0]  q34_exp   = rs1_data[14:10];        // 指数
    wire [9:0]  q34_mant  = rs1_data[9:0];          // 尾数

    // 加上隐含位 1
    wire [10:0] q34_val   = {1'b1, q34_mant};       // 1.M，共 11 位

    // 移位量 = E - 15
    wire [4:0]  q34_shift;
    assign q34_shift = q34_exp - 5'd15;

    // 移位后的结果（取 16 位足够）
    wire [15:0] q34_val_shifted;

    assign q34_val_shifted = (q34_exp >= 5'd15) ? (q34_val << q34_shift)     // 左移
                                                : (q34_val >> (-q34_shift)); // 右移

    wire [6:0] q34_abs;  // 7 位绝对值：3 位整数 + 4 位小数
    assign q34_abs = q34_val_shifted[12:6];   // bit12~6，共 7 位

    // 符号处理：正数直接输出，负数取补码
    wire [6:0] q34_neg;
    assign q34_neg = ~q34_abs + 7'd1;    // 补码

    wire [7:0] q34_out;
    assign q34_out = q34_sign ? {1'b1, q34_neg} : {1'b0, q34_abs};

    // 斐波那契查找表（预计算的 fib(0)~fib(47)）
    wire [7:0]  n = rs1_data[7:0];
    wire [31:0] fib_lut [0:47];
    assign fib_lut[0]  = 32'd0;
    assign fib_lut[1]  = 32'd1;
    assign fib_lut[2]  = 32'd1;
    assign fib_lut[3]  = 32'd2;
    assign fib_lut[4]  = 32'd3;
    assign fib_lut[5]  = 32'd5;
    assign fib_lut[6]  = 32'd8;
    assign fib_lut[7]  = 32'd13;
    assign fib_lut[8]  = 32'd21;
    assign fib_lut[9]  = 32'd34;
    assign fib_lut[10] = 32'd55;
    assign fib_lut[11] = 32'd89;
    assign fib_lut[12] = 32'd144;
    assign fib_lut[13] = 32'd233;
    assign fib_lut[14] = 32'd377;
    assign fib_lut[15] = 32'd610;
    assign fib_lut[16] = 32'd987;
    assign fib_lut[17] = 32'd1597;
    assign fib_lut[18] = 32'd2584;
    assign fib_lut[19] = 32'd4181;
    assign fib_lut[20] = 32'd6765;
    assign fib_lut[21] = 32'd10946;
    assign fib_lut[22] = 32'd17711;
    assign fib_lut[23] = 32'd28657;
    assign fib_lut[24] = 32'd46368;
    assign fib_lut[25] = 32'd75025;
    assign fib_lut[26] = 32'd121393;
    assign fib_lut[27] = 32'd196418;
    assign fib_lut[28] = 32'd317811;
    assign fib_lut[29] = 32'd514229;
    assign fib_lut[30] = 32'd832040;
    assign fib_lut[31] = 32'd1346269;
    assign fib_lut[32] = 32'd2178309;
    assign fib_lut[33] = 32'd3524578;
    assign fib_lut[34] = 32'd5702887;
    assign fib_lut[35] = 32'd9227465;
    assign fib_lut[36] = 32'd14930352;
    assign fib_lut[37] = 32'd24157817;
    assign fib_lut[38] = 32'd39088169;
    assign fib_lut[39] = 32'd63245986;
    assign fib_lut[40] = 32'd102334155;
    assign fib_lut[41] = 32'd165580141;
    assign fib_lut[42] = 32'd267914296;
    assign fib_lut[43] = 32'd433494437;
    assign fib_lut[44] = 32'd701408733;
    assign fib_lut[45] = 32'd1134903170;
    assign fib_lut[46] = 32'd1836311903;
    assign fib_lut[47] = 32'd2971215073;

    wire [31:0] fib_result;
    assign fib_result = (n <= 47) ? fib_lut[n] : 32'hFFFFFFFF; // 超出范围返回最大值

    // 输出结果
    always @(*) begin
        case (funct3)
            3'b000: result = {28'd0, pop_count};
            3'b001: result = {28'd0, class_out};
            3'b010: result = {24'd0, q34_out};
            3'b011: result = fib_result;
            default: result = 32'd0;
        endcase
    end
endmodule