module BranchUnit (
    input wire [31:0] pc,
    input wire [31:0] rs1_data,
    input wire [31:0] imm,
    input wire [2:0] funct3,
    input wire branch,
    input wire jal,
    input wire jalr,
    input wire zero,
    input wire lt,
    input wire ltu,
    output reg take_branch,
    output reg [31:0] target
);

    always @(*) begin
        take_branch = 1'b0;
        target = pc + 32'd4;

        if (jal) begin
            take_branch = 1'b1;
            target = pc + imm;
        end else if (jalr) begin
            take_branch = 1'b1;
            target = (rs1_data + imm) & 32'hffff_fffe;
        end else if (branch) begin
            case (funct3)
                3'b000: take_branch = zero;
                3'b001: take_branch = ~zero;
                3'b100: take_branch = lt;
                3'b101: take_branch = ~lt;
                3'b110: take_branch = ltu;
                3'b111: take_branch = ~ltu;
                default: take_branch = 1'b0;
            endcase
            if (take_branch) begin
                target = pc + imm;
            end
        end
    end

endmodule