module ID (
    input wire clk,
    input wire rst_n,
    input wire [31:0] inst,
    input wire wb_we,
    input wire [4:0] wb_waddr,
    input wire [31:0] wb_wdata,
    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data,
    output wire [31:0] imm,
    output wire [4:0] rs1,
    output wire [4:0] rs2,
    output wire [4:0] rd,
    output wire [6:0] opcode,
    output wire [2:0] funct3,
    output wire [6:0] funct7,
    output wire [3:0] alu_op,
    output wire [1:0] wb_sel,
    output wire reg_we,
    output wire mem_we,
    output wire mem_re,
    output wire alu_src,
    output wire branch,
    output wire jal,
    output wire jalr,
    output wire lui,
    output wire auipc
);

    Decoder u_decoder (
        .inst(inst),
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .imm(imm)
    );


    RegFile u_reg_file (
        .clk(clk),
        .rst_n(rst_n),
        .we(wb_we),
        .raddr1(rs1),
        .raddr2(rs2),
        .waddr(wb_waddr),
        .wdata(wb_wdata),
        .rdata1(rs1_data),
        .rdata2(rs2_data)
    );

    ControlUnit u_control_unit (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .alu_op(alu_op),
        .wb_sel(wb_sel),
        .reg_we(reg_we),
        .mem_we(mem_we),
        .mem_re(mem_re),
        .alu_src(alu_src),
        .branch(branch),
        .jal(jal),
        .jalr(jalr),
        .lui(lui),
        .auipc(auipc)
    );

endmodule