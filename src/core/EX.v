module EX (
    input wire [31:0] pc,
    input wire [31:0] rs1_data,
    input wire [31:0] rs2_data,
    input wire [31:0] imm,

    input wire [3:0] alu_op,
    input wire alu_src,
    input wire [2:0] funct3,
    input wire funct7_0,

    input wire branch,
    input wire jal,
    input wire jalr,
    input wire lui,
    input wire auipc,
    input wire vpu_en,

    output wire [31:0] ex_result,
    output wire [31:0] branch_target,
    output wire take_branch,

    output wire zero,// for BEQ/BNE
    output wire lt,// for BLT/BGE
    output wire ltu// for BLTU/BGEU
);

    wire [31:0] alu_a;
    wire [31:0] alu_b;

    // AUIPC = PC + imm
    assign alu_a = auipc ? pc : rs1_data;

    // LUI / AUIPC / I-type / Load / Store all need imm
    assign alu_b = (alu_src | lui | auipc) ? imm : rs2_data;

    wire [31:0] alu_y;

    ALU u_alu (
        .a(alu_a),
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
        .rs2_data(rs2_data),
        .imm(imm),
        .funct3(funct3),
        .branch(branch),
        .jal(jal),
        .jalr(jalr),
        .take_branch(take_branch),
        .target(branch_target)
    );

    wire [3:0] vp_op;
    assign vp_op = {funct7_0, funct3};
    wire [31:0] vpu_result;
    
    VPU u_VPU(
        .a(rs1_data),
        .b(rs2_data),
        .vp_op(vp_op),
        .result(vpu_result)
    );
    
    assign ex_result = vpu_en ? vpu_result : alu_y;

endmodule