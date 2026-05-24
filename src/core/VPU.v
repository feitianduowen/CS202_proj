module VPU (
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [3:0] vp_op,
    output wire [31:0] result
);

    wire [7:0] a0 = a[7:0];
    wire [7:0] a1 = a[15:8];
    wire [7:0] a2 = a[23:16];
    wire [7:0] a3 = a[31:24];

    wire [7:0] b0 = b[7:0];
    wire [7:0] b1 = b[15:8];
    wire [7:0] b2 = b[23:16];
    wire [7:0] b3 = b[31:24];

    localparam VPU_NOT = 4'b0000; // 按位取反
    localparam VPU_NEG = 4'b0001; // 取负
    localparam VPU_ABS = 4'b0010; // 取绝对值
    localparam VPU_ADD = 4'b0011; // 加法
    localparam VPU_SUB = 4'b0100; // 减法
    localparam VPU_AND = 4'b0101; // 按位与
    localparam VPU_OR = 4'b0110;  // 按位或
    localparam VPU_XOR = 4'b0111; // 异或
    localparam VPU_SLL = 4'b1000; // 左移
    localparam VPU_SRL = 4'b1001; // 右移
    localparam VPU_MIN = 4'b1010; // 取最小值
    localparam VPU_MAX = 4'b1011; // 取最大值

    reg [7:0] r0, r1, r2, r3;

    always @(*) begin
        case (vp_op)
            VPU_NOT: begin r0 = ~a0;  r1 = ~a1;  r2 = ~a2;  r3 = ~a3;  end
            VPU_NEG: begin {r3, r2, r1, r0} = -a + 32'd1; end
            VPU_ABS: begin {r3, r2, r1, r0} = a[31] ? (~a + 32'd1) : a; end
            VPU_ADD: begin r0 = a0 + b0; r1 = a1 + b1; r2 = a2 + b2; r3 = a3 + b3; end
            VPU_SUB: begin r0 = a0 - b0; r1 = a1 - b1; r2 = a2 - b2; r3 = a3 - b3; end
            VPU_AND: begin r0 = a0 & b0; r1 = a1 & b1; r2 = a2 & b2; r3 = a3 & b3; end
            VPU_OR: begin r0 = a0 | b0; r1 = a1 | b1; r2 = a2 | b2; r3 = a3 | b3; end
            VPU_XOR: begin r0 = a0 ^ b0;  r1 = a1 ^ b1;  r2 = a2 ^ b2;  r3 = a3 ^ b3; end
            VPU_SLL: begin r0 = a0 << b0[2:0]; r1 = a1 << b1[2:0]; r2 = a2 << b2[2:0]; r3 = a3 << b3[2:0]; end
            VPU_SRL: begin r0 = a0 >> b0[2:0]; r1 = a1 >> b1[2:0]; r2 = a2 >> b2[2:0]; r3 = a3 >> b3[2:0]; end
            VPU_MIN: begin 
                r0 = (a0 < b0) ? a0 : b0; 
                r1 = (a1 < b1) ? a1 : b1;
                r2 = (a2 < b2) ? a2 : b2; 
                r3 = (a3 < b3) ? a3 : b3; 
            end
            VPU_MAX: begin 
                r0 = (a0 > b0) ? a0 : b0; 
                r1 = (a1 > b1) ? a1 : b1;
                r2 = (a2 > b2) ? a2 : b2; 
                r3 = (a3 > b3) ? a3 : b3; 
            end
            default: begin r0 = 8'd0; r1 = 8'd0; r2 = 8'd0; r3 = 8'd0; end
        endcase
    end

    assign result = {r3, r2, r1, r0};

endmodule