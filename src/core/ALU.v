module ALU (
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [3:0] alu_op,
    output reg [31:0] y,
    output wire zero,
    output wire lt,
    output wire ltu
);

    assign zero = (y == 32'b0);
    assign lt = ($signed(a) < $signed(b));
    assign ltu = (a < b);

    always @(*) begin
        case (alu_op)
            4'b0000: y = a + b;
            4'b1000: y = a - b;
            4'b0111: y = a & b;
            4'b0110: y = a | b;
            4'b0100: y = a ^ b;
            4'b0001: y = a << b[4:0];
            4'b0101: y = a >> b[4:0];
            4'b1101: y = $signed(a) >>> b[4:0];
            4'b0010: y = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            4'b0011: y = (a < b) ? 32'd1 : 32'd0;
            default: y = a + b;
        endcase
    end

endmodule