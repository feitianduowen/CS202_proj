module VPU (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  vp_op,
    output reg  [31:0] result
);

    wire [7:0] a0 = a[7:0];
    wire [7:0] a1 = a[15:8];
    wire [7:0] a2 = a[23:16];
    wire [7:0] a3 = a[31:24];

    wire [7:0] b0 = b[7:0];
    wire [7:0] b1 = b[15:8];
    wire [7:0] b2 = b[23:16];
    wire [7:0] b3 = b[31:24];

    localparam VPU_NOT = 4'b0000;
    localparam VPU_NEG = 4'b0001;
    localparam VPU_ABS = 4'b0010;
    localparam VPU_ADD = 4'b0011;
    localparam VPU_SUB = 4'b0100;
    localparam VPU_AND = 4'b0101;
    localparam VPU_OR  = 4'b0110;
    localparam VPU_XOR = 4'b0111;
    localparam VPU_SLL = 4'b1000;
    localparam VPU_SRL = 4'b1001;
    localparam VPU_MIN = 4'b1010;
    localparam VPU_MAX = 4'b1011;

    always @(*) begin
        result = 32'h0000_0000;

        case (vp_op)
            VPU_NOT: begin
                result = ~a;
            end

            VPU_NEG: begin
                result = ~a + 32'd1;
            end

            VPU_ABS: begin
                result = a[31] ? (~a + 32'd1) : a;
            end

            VPU_ADD: begin
                result = {
                    a3 + b3,
                    a2 + b2,
                    a1 + b1,
                    a0 + b0
                };
            end

            VPU_SUB: begin
                result = {
                    a3 - b3,
                    a2 - b2,
                    a1 - b1,
                    a0 - b0
                };
            end

            VPU_AND: begin
                result = a & b;
            end

            VPU_OR: begin
                result = a | b;
            end

            VPU_XOR: begin
                result = a ^ b;
            end

            VPU_SLL: begin
                result = {
                    a3 << b3[2:0],
                    a2 << b2[2:0],
                    a1 << b1[2:0],
                    a0 << b0[2:0]
                };
            end

            VPU_SRL: begin
                result = {
                    a3 >> b3[2:0],
                    a2 >> b2[2:0],
                    a1 >> b1[2:0],
                    a0 >> b0[2:0]
                };
            end

            VPU_MIN: begin
                result = {
                    (a3 < b3) ? a3 : b3,
                    (a2 < b2) ? a2 : b2,
                    (a1 < b1) ? a1 : b1,
                    (a0 < b0) ? a0 : b0
                };
            end

            VPU_MAX: begin
                result = {
                    (a3 > b3) ? a3 : b3,
                    (a2 > b2) ? a2 : b2,
                    (a1 > b1) ? a1 : b1,
                    (a0 > b0) ? a0 : b0
                };
            end

            default: begin
                result = 32'h0000_0000;
            end
        endcase
    end

endmodule