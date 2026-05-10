module CPU (
    input wire clk,
    input wire rst_n,
    input wire run_en,
    input wire step_en,

    input wire [31:0] imem_rdata,
    input wire [31:0] dmem_rdata,

    output wire [31:0] pc_dbg,// program counter debug output
    output wire [31:0] wb_dbg,// write back stage debug output
    output wire [31:0] reg_dbg,// register file debug output

    output wire [31:0] imem_addr,

    output wire [31:0] dmem_addr,
    output wire [31:0] dmem_wdata,
    output wire [3:0]  dmem_wstrb,
    output wire dmem_we,
    output wire dmem_re
);

    wire cpu_en;

    wire [31:0] pc;
    wire [31:0] pc4;
    wire [31:0] pc_next;
    wire [31:0] inst;

    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    wire [31:0] imm;

    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;

    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;

    wire [3:0] alu_op;
    wire [1:0] wb_sel;

    wire reg_we_dec;
    wire mem_we_dec;
    wire mem_re_dec;
    wire alu_src;
    wire branch;
    wire jal;
    wire jalr;
    wire lui;
    wire auipc;

    wire reg_we_eff;
    wire mem_we_eff;
    wire mem_re_eff;

    wire [31:0] alu_y;
    wire [31:0] branch_target;
    wire take_branch;

    wire zero;
    wire lt;
    wire ltu;

    wire [31:0] load_data;
    wire [31:0] wb_data;

    assign cpu_en = run_en | step_en;

    assign pc4 = pc + 32'd4;
    assign pc_next = take_branch ? branch_target : pc4;

    assign reg_we_eff = reg_we_dec & cpu_en;
    assign mem_we_eff = mem_we_dec & cpu_en;
    assign mem_re_eff = mem_re_dec & cpu_en;

    IF u_if (
        .clk(clk),
        .rst_n(rst_n),
        .pc_we(cpu_en),
        .pc_next(pc_next),
        .inst_rdata(imem_rdata),
        .pc(pc),
        .inst_addr(imem_addr),
        .inst(inst)
    );

    ID u_id (
        .clk(clk),
        .rst_n(rst_n),
        .inst(inst),

        .wb_we(reg_we_eff),
        .wb_waddr(rd),
        .wb_wdata(wb_data),

        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .imm(imm),

        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),

        .alu_op(alu_op),
        .wb_sel(wb_sel),
        .reg_we(reg_we_dec),
        .mem_we(mem_we_dec),
        .mem_re(mem_re_dec),
        .alu_src(alu_src),
        .branch(branch),
        .jal(jal),
        .jalr(jalr),
        .lui(lui),
        .auipc(auipc)
    );

    EX u_ex (
        .pc(pc),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .imm(imm),
        .alu_op(alu_op),
        .alu_src(alu_src),
        .funct3(funct3),
        .branch(branch),
        .jal(jal),
        .jalr(jalr),
        .lui(lui),
        .auipc(auipc),

        .alu_y(alu_y),
        .branch_target(branch_target),
        .take_branch(take_branch),
        .zero(zero),
        .lt(lt),
        .ltu(ltu)
    );

    MEM u_mem (
        .mem_we(mem_we_eff),
        .mem_re(mem_re_eff),
        .funct3(funct3),
        .addr(alu_y),
        .store_data(rs2_data),
        .dmem_rdata(dmem_rdata),

        .dmem_addr(dmem_addr),
        .dmem_wdata(dmem_wdata),
        .dmem_wstrb(dmem_wstrb),
        .dmem_we(dmem_we),
        .dmem_re(dmem_re),
        .load_data(load_data)
    );

    WB u_wb (
        .alu_y(alu_y),
        .mem_rdata(load_data),
        .pc4(pc4),
        .wb_sel(wb_sel),
        .wb_data(wb_data)
    );

    assign pc_dbg = pc;
    assign wb_dbg = wb_data;
    assign reg_dbg = rs1_data;


endmodule