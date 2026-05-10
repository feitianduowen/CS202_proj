module BranchUnit (
    input wire [31:0] pc,
    input wire [31:0] rs1_data,
    input wire [31:0] rs2_data,
    input wire [31:0] imm,

    input wire [2:0] funct3,
    input wire branch,
    input wire jal,
    input wire jalr,

    output reg take_branch,
    output reg [31:0] target
);

    reg branch_cond;

    always @(*) begin
        branch_cond = 1'b0;

        case (funct3)
            3'b000: branch_cond = (rs1_data == rs2_data);                         // BEQ
            3'b001: branch_cond = (rs1_data != rs2_data);                         // BNE
            3'b100: branch_cond = ($signed(rs1_data) < $signed(rs2_data));        // BLT
            3'b101: branch_cond = ($signed(rs1_data) >= $signed(rs2_data));       // BGE
            3'b110: branch_cond = (rs1_data < rs2_data);                         // BLTU
            3'b111: branch_cond = (rs1_data >= rs2_data);                        // BGEU
            default: branch_cond = 1'b0;
        endcase
    end

    always @(*) begin
        take_branch = 1'b0;
        target = pc + 32'd4;

        if (jal) begin
            take_branch = 1'b1;
            target = pc + imm;
        end else if (jalr) begin
            take_branch = 1'b1;
            target = (rs1_data + imm) & 32'hFFFF_FFFE;
        end else if (branch && branch_cond) begin
            take_branch = 1'b1;
            target = pc + imm;
        end
    end

endmodule