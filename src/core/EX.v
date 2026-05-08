module EX (
    input wire [31:0] pc,
    input wire [31:0] rs1_data,
    input wire [31:0] rs2_data,
    input wire [31:0] imm,
    input wire [3:0] alu_op,
    input wire alu_src,
    input wire [2:0] funct3,
    input wire branch,
    input wire jal,
    input wire jalr,
    input wire lui,
    input wire auipc,
    output wire [31:0] alu_y,
    output wire [31:0] branch_target,
    output wire zero,
    output wire lt,
    output wire ltu
);

    wire [31:0] alu_b;

    assign alu_b = alu_src ? imm : rs2_data;

    ALU u_alu (
        .a(rs1_data),
        .b(alu_b),
        .alu_op(alu_op),
        .y(alu_y),
        .zero(zero),
        .lt(lt),
        .ltu(ltu)
    );

    BranchUnit u_branch_unit (
        .pc(pc),
        .rs1_data(rs1_data),
        .imm(imm),
        .funct3(funct3),
        .branch(branch),
        .jal(jal),
        .jalr(jalr),
        .zero(zero),
        .lt(lt),
        .ltu(ltu),
        .take_branch(),
        .target(branch_target)
    );

endmodule