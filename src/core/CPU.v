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

    input  wire [5:0]  dbg_reg_addr,
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
    wire vpu_en;

    wire reg_we_eff;
    wire fp_we_eff;
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

    wire [31:0] fp_rs1_data;
    wire [31:0] fp_rs2_data;
    wire fp_we;
    wire fp_sub;
    wire fp_wb_sel;
    wire [31:0] fp_result;
    wire [31:0] fp_wb_data;

    reg load_is_fp_r;

        // ============================================================
    // Load state machine for synchronous DataRam
    // ============================================================
    localparam WB_ALU = 2'b00;
    localparam WB_MEM = 2'b01;
    localparam WB_PC4 = 2'b10;

    localparam LD_IDLE    = 2'd0;
    localparam LD_WAITRAM = 2'd1;
    localparam LD_WB      = 2'd2;

    reg [1:0] load_state;

    reg [4:0]  load_rd_r;
    reg [2:0]  load_funct3_r;
    reg [31:0] load_addr_r;

    wire is_load_inst;
    wire load_start;
    wire load_active;
    wire load_wb_cycle;

    wire cpu_pc_we;

    wire [31:0] mem_addr_eff;
    wire [2:0]  mem_funct3_eff;
    wire [4:0]  wb_waddr_eff;
    wire [1:0]  wb_sel_eff;

    assign is_load_inst  = mem_re_dec;
    assign load_active   = (load_state != LD_IDLE);
    assign load_wb_cycle = (load_state == LD_WB);
    assign load_start    = cpu_en & (load_state == LD_IDLE) & is_load_inst;


    assign cpu_en = run_en | step_en;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            load_state    <= LD_IDLE;
            load_rd_r     <= 5'd0;
            load_funct3_r <= 3'd0;
            load_addr_r   <= 32'd0;
        end else if (cpu_en) begin
            case (load_state)
                LD_IDLE: begin
                    if (is_load_inst) begin
                        load_state    <= LD_WAITRAM;

                        // 锁存这条 lw 的上下文
                        load_rd_r     <= rd;
                        load_funct3_r <= funct3;
                        load_addr_r   <= alu_y;
                    end else begin
                        load_state <= LD_IDLE;
                    end
                end

                LD_WAITRAM: begin
                    // DataRam 在这个阶段把 dout 更新出来
                    load_state <= LD_WB;
                end

                LD_WB: begin
                    // 下一拍允许 PC 前进
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

    // load 第一拍/等待拍不写寄存器；只有 LD_WB 写回
    // 非 load 指令仍然单周期写回

    // wire is_fp_load = (opcode == 7'b0000111);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            load_is_fp_r <= 1'b0;
        end else if (cpu_en) begin
            case (load_state)
                LD_IDLE: begin
                    if (is_load_inst) begin
                        load_is_fp_r <= (opcode == 7'b0000111);
                    end
                end

                LD_WB: begin
                    load_is_fp_r <= 1'b0;
                end
            endcase
        end
    end

    assign reg_we_eff =
        cpu_en & (
            ((load_state == LD_IDLE) & reg_we_dec & ~is_load_inst) |
            (load_state == LD_WB & ~load_is_fp_r)
        );

    assign fp_we_eff =
        cpu_en & (
            ((load_state == LD_IDLE) & fp_we & ~is_load_inst) |
            (load_state == LD_WB & load_is_fp_r)
        );

    // store 只在空闲状态执行，避免 load stall 期间重复写
    assign mem_we_eff = cpu_en & (load_state == LD_IDLE) & mem_we_dec;

    // load 期间保持读使能
    assign mem_re_eff = cpu_en & (
        ((load_state == LD_IDLE) & mem_re_dec) |
        load_active
    );

    // load 期间，DataRam 地址和 funct3 使用锁存值
    assign mem_addr_eff   = load_active ? load_addr_r   : alu_y;
    assign mem_funct3_eff = load_active ? load_funct3_r : funct3;

    // load 写回时，写回目标寄存器必须使用锁存的 rd
    assign wb_waddr_eff = load_wb_cycle ? load_rd_r : rd;

    // load 写回时，强制选择 MEM 数据
    assign wb_sel_eff = load_wb_cycle ? WB_MEM : wb_sel;

    // load 的前两拍不更新 PC；LD_WB 写回这一拍才更新 PC
    assign cpu_pc_we = cpu_en & (
        ((load_state == LD_IDLE) & ~is_load_inst) |
        (load_state == LD_WB)
    );

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
        .wb_waddr(wb_waddr_eff),
        .wb_wdata(wb_data),

        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .imm(imm),

        .fp_wb_we(fp_we_eff),
        .fp_wb_waddr(wb_waddr_eff),
        .fp_wb_wdata(fp_wb_data),
        .fp_rs1_data(fp_rs1_data),
        .fp_rs2_data(fp_rs2_data),
        .fp_we(fp_we),
        .fp_wb_sel(fp_wb_sel),
        .fp_sub(fp_sub),

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
        .auipc(auipc),
        .vpu_en(vpu_en),
        .dbg_reg_addr(dbg_reg_addr),
        .dbg_reg_data(dbg_reg_data)
    );

    EX u_ex (
        .pc(pc),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .imm(imm),
        .alu_op(alu_op),
        .alu_src(alu_src),
        .funct3(funct3),
        .funct7_0(funct7[0]),
        .branch(branch),
        .jal(jal),
        .jalr(jalr),
        .lui(lui),
        .auipc(auipc),
        .vpu_en(vpu_en),

        .fp_rs1_data(fp_rs1_data),
        .fp_rs2_data(fp_rs2_data),
        .fp_sub(fp_sub),
        .fp_result(fp_result),

        .ex_result(alu_y),
        .branch_target(branch_target),
        .take_branch(take_branch),
        .zero(zero),
        .lt(lt),
        .ltu(ltu)
    );

    wire is_fp_store = mem_we_dec & (opcode == 7'b0100111); // fsw
    wire [31:0] mem_store_data = is_fp_store ? fp_rs2_data : rs2_data;

    MEM u_mem (
    .mem_we(mem_we_eff),
    .mem_re(mem_re_eff),
    .funct3(mem_funct3_eff),
    .addr(mem_addr_eff),
    .store_data(mem_store_data),

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
    .wb_sel(wb_sel_eff),
    .wb_data(wb_data),

    .fp_result(fp_result),
    .fp_wb_sel(fp_wb_sel),
    .fp_we(fp_we_eff),
    .fp_wb_data(fp_wb_data)
    );

    assign pc_dbg = pc;
    assign wb_dbg = wb_data;
    assign reg_dbg = rs1_data;

endmodule