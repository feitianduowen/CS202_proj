module ALU (
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [3:0] alu_op,

    output reg [31:0] y,
    output wire zero,
    output wire lt,
    output wire ltu
);

    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_AND  = 4'b0100;
    localparam ALU_OR   = 4'b0101;
    localparam ALU_XOR  = 4'b0110;
    localparam ALU_LUI  = 4'b0111;
    localparam ALU_SLT  = 4'b1000;
    localparam ALU_SLTU = 4'b1001;
    localparam ALU_AUIPC = 4'b1010;
    localparam ALU_SLL  = 4'b1100;
    localparam ALU_SRL  = 4'b1101;
    localparam ALU_SRA  = 4'b1110;

    always @(*) begin
        case (alu_op)
            ALU_ADD:   y = a + b;
            ALU_SUB:   y = a - b;
            ALU_AND:   y = a & b;
            ALU_OR:    y = a | b;
            ALU_XOR:   y = a ^ b;
            ALU_SLL:   y = a << b[4:0];
            ALU_SRL:   y = a >> b[4:0];
            ALU_SRA:   y = $signed(a) >>> b[4:0];
            ALU_SLT:   y = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            ALU_SLTU:  y = (a < b) ? 32'd1 : 32'd0;
            ALU_LUI:   y = b;
            ALU_AUIPC: y = a + b;
            default:   y = 32'b0;
        endcase
    end

    assign zero = (y == 32'b0);
    assign lt = ($signed(a) < $signed(b));
    assign ltu = (a < b);

endmodule