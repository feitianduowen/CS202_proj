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
    output wire dmem_re,

    input  wire [4:0]  dbg_reg_addr,
    output wire [31:0] dbg_reg_data,
    output wire [31:0] dbg_pc

);
    assign dbg_pc = pc_dbg;
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


        // ============================================================
    // Load state machine for synchronous DataRam
    // load needs 3 phases in this CPU:
    //   IDLE      : detect lw, send address
    //   WAIT_RAM  : DataRam updates dout at this posedge
    //   WB_LOAD   : write stable dmem_rdata into RegFile
    // ============================================================
    localparam LD_IDLE    = 2'd0;
    localparam LD_WAITRAM = 2'd1;
    localparam LD_WB      = 2'd2;

    reg [1:0] load_state;

    wire is_load_inst;
    wire load_wb_cycle;
    wire cpu_pc_we;

    assign is_load_inst  = mem_re_dec;
    assign load_wb_cycle = (load_state == LD_WB);

    assign cpu_en = run_en | step_en;

        always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            load_state <= LD_IDLE;
        end else if (cpu_en) begin
            case (load_state)
                LD_IDLE: begin
                    if (is_load_inst) begin
                        load_state <= LD_WAITRAM;
                    end else begin
                        load_state <= LD_IDLE;
                    end
                end

                LD_WAITRAM: begin
                    load_state <= LD_WB;
                end

                LD_WB: begin
                    load_state <= LD_IDLE;
                end

                default: begin
                    load_state <= LD_IDLE;
                end
            endcase
        end
    end

    assign pc4 = pc + 32'd4;
    assign pc_next = take_branch ? branch_target : pc4;
    // 非 load 指令：正常一个周期写回
    // load 指令：只在 LD_WB 周期写回
    assign reg_we_eff = reg_we_dec & cpu_en & (~is_load_inst | load_wb_cycle);

    // store 只执行一次，避免 PC 被 hold 时重复写
    assign mem_we_eff = mem_we_dec & cpu_en & (load_state == LD_IDLE);

    // load 期间保持读使能，PC 不动，所以 dmem_addr 也保持不动
    assign mem_re_eff = mem_re_dec & cpu_en;

        // load 的前两拍不更新 PC，第三拍写回后才更新 PC
    assign cpu_pc_we = cpu_en & (~is_load_inst | load_wb_cycle);

    IF u_if (
        .clk(clk),
        .rst_n(rst_n),
        .pc_we(cpu_pc_we),
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