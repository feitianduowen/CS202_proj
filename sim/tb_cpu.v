`timescale 1ns / 1ps

module tb_cpu;

    reg clk;
    reg rst_n;
    reg run_en;
    reg step_en;
    reg [31:0] board_input;

    wire [31:0] imem_rdata;
    wire [31:0] dmem_rdata;

    wire [31:0] pc_dbg;
    wire [31:0] wb_dbg;
    wire [31:0] reg_dbg;

    wire [31:0] imem_addr;
    wire [31:0] dmem_addr;
    wire [31:0] dmem_wdata;
    wire [3:0]  dmem_wstrb;
    wire dmem_we;
    wire dmem_re;

    reg [31:0] imem [0:255];
    reg [31:0] dmem [0:255];

    integer i;
    integer error_count;

    localparam [6:0] OPC_R      = 7'b0110011;
    localparam [6:0] OPC_I      = 7'b0010011;
    localparam [6:0] OPC_LOAD   = 7'b0000011;
    localparam [6:0] OPC_STORE  = 7'b0100011;
    localparam [6:0] OPC_BRANCH = 7'b1100011;
    localparam [6:0] OPC_LUI    = 7'b0110111;
    localparam [6:0] OPC_AUIPC  = 7'b0010111;
    localparam [6:0] OPC_JAL    = 7'b1101111;
    localparam [6:0] OPC_JALR   = 7'b1100111;

    // Program counter labels
    localparam integer PC_FAIL        = 128;
    localparam integer PC_AFTER_JAL   = 84;
    localparam integer PC_TARGET_JALR = 108;

    CPU dut (
        .clk(clk),
        .rst_n(rst_n),
        .run_en(run_en),
        .step_en(step_en),
        .board_input(board_input),

        .imem_rdata(imem_rdata),
        .dmem_rdata(dmem_rdata),

        .pc_dbg(pc_dbg),
        .wb_dbg(wb_dbg),
        .reg_dbg(reg_dbg),

        .imem_addr(imem_addr),
        .dmem_addr(dmem_addr),
        .dmem_wdata(dmem_wdata),
        .dmem_wstrb(dmem_wstrb),
        .dmem_we(dmem_we),
        .dmem_re(dmem_re)
    );

    // 100 MHz clock
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // Combinational instruction memory read
    assign imem_rdata = imem[imem_addr[9:2]];

    // Combinational data memory read
    assign dmem_rdata = dmem[dmem_addr[9:2]];

    // Data memory write with byte strobe
    always @(posedge clk) begin
        if (dmem_we) begin
            if (dmem_wstrb[0]) dmem[dmem_addr[9:2]][7:0]   <= dmem_wdata[7:0];
            if (dmem_wstrb[1]) dmem[dmem_addr[9:2]][15:8]  <= dmem_wdata[15:8];
            if (dmem_wstrb[2]) dmem[dmem_addr[9:2]][23:16] <= dmem_wdata[23:16];
            if (dmem_wstrb[3]) dmem[dmem_addr[9:2]][31:24] <= dmem_wdata[31:24];
        end
    end

    // -------------------------
    // RISC-V encoding helpers
    // -------------------------

    function [31:0] enc_r;
        input [6:0] funct7;
        input [4:0] rs2;
        input [4:0] rs1;
        input [2:0] funct3;
        input [4:0] rd;
        begin
            enc_r = {funct7, rs2, rs1, funct3, rd, OPC_R};
        end
    endfunction

    function [31:0] enc_i;
        input integer imm;
        input [4:0] rs1;
        input [2:0] funct3;
        input [4:0] rd;
        input [6:0] opcode;
        reg [11:0] imm12;
        begin
            imm12 = imm[11:0];
            enc_i = {imm12, rs1, funct3, rd, opcode};
        end
    endfunction

    function [31:0] enc_s;
        input integer imm;
        input [4:0] rs2;
        input [4:0] rs1;
        input [2:0] funct3;
        reg [11:0] imm12;
        begin
            imm12 = imm[11:0];
            enc_s = {imm12[11:5], rs2, rs1, funct3, imm12[4:0], OPC_STORE};
        end
    endfunction

    function [31:0] enc_b;
        input integer imm;
        input [4:0] rs2;
        input [4:0] rs1;
        input [2:0] funct3;
        reg [12:0] imm13;
        begin
            imm13 = imm[12:0];
            enc_b = {
                imm13[12],
                imm13[10:5],
                rs2,
                rs1,
                funct3,
                imm13[4:1],
                imm13[11],
                OPC_BRANCH
            };
        end
    endfunction

    function [31:0] enc_u;
        input [19:0] imm20;
        input [4:0] rd;
        input [6:0] opcode;
        begin
            enc_u = {imm20, rd, opcode};
        end
    endfunction

    function [31:0] enc_j;
        input integer imm;
        input [4:0] rd;
        reg [20:0] imm21;
        begin
            imm21 = imm[20:0];
            enc_j = {
                imm21[20],
                imm21[10:1],
                imm21[11],
                imm21[19:12],
                rd,
                OPC_JAL
            };
        end
    endfunction

    // -------------------------
    // Test program
    // -------------------------

    task load_program;
        begin
            // clear imem
            for (i = 0; i < 256; i = i + 1) begin
                imem[i] = 32'h00000013; // nop = addi x0, x0, 0
            end

            // 0:  lui x14, 0x12345
            imem[0]  = enc_u(20'h12345, 5'd14, OPC_LUI);

            // 4:  addi x14, x14, 0x678
            // x14 = 0x12345678
            imem[1]  = enc_i(12'h678, 5'd14, 3'b000, 5'd14, OPC_I);

            // 8:  sw x14, 8(x0)
            // dmem[2] should become 0x12345678
            imem[2]  = enc_s(8, 5'd14, 5'd0, 3'b010);

            // 12: addi x15, x0, 240
            imem[3]  = enc_i(240, 5'd0, 3'b000, 5'd15, OPC_I);

            // 16: addi x16, x0, 204
            imem[4]  = enc_i(204, 5'd0, 3'b000, 5'd16, OPC_I);

            // 20: and x17, x15, x16
            // 0xF0 & 0xCC = 0xC0 = 192
            imem[5]  = enc_r(7'b0000000, 5'd16, 5'd15, 3'b111, 5'd17);

            // 24: addi x18, x0, 192
            imem[6]  = enc_i(192, 5'd0, 3'b000, 5'd18, OPC_I);

            // 28: bne x17, x18, fail
            imem[7]  = enc_b(PC_FAIL - 28, 5'd18, 5'd17, 3'b001);

            // 32: addi x1, x0, -1
            imem[8]  = enc_i(-1, 5'd0, 3'b000, 5'd1, OPC_I);

            // 36: addi x2, x0, 4
            imem[9]  = enc_i(4, 5'd0, 3'b000, 5'd2, OPC_I);

            // 40: sra x3, x1, x2
            // -1 >>> 4 = -1
            imem[10] = enc_r(7'b0100000, 5'd2, 5'd1, 3'b101, 5'd3);

            // 44: bne x3, x1, fail
            imem[11] = enc_b(PC_FAIL - 44, 5'd1, 5'd3, 3'b001);

            // 48: addi x4, x0, 1
            imem[12] = enc_i(1, 5'd0, 3'b000, 5'd4, OPC_I);

            // 52: sll x5, x4, x2
            // 1 << 4 = 16
            imem[13] = enc_r(7'b0000000, 5'd2, 5'd4, 3'b001, 5'd5);

            // 56: addi x6, x0, 16
            imem[14] = enc_i(16, 5'd0, 3'b000, 5'd6, OPC_I);

            // 60: bne x5, x6, fail
            imem[15] = enc_b(PC_FAIL - 60, 5'd6, 5'd5, 3'b001);

            // 64: sw x5, 0(x0)
            // dmem[0] should become 16
            imem[16] = enc_s(0, 5'd5, 5'd0, 3'b010);

            // 68: lw x7, 0(x0)
            imem[17] = enc_i(0, 5'd0, 3'b010, 5'd7, OPC_LOAD);

            // 72: bne x7, x6, fail
            imem[18] = enc_b(PC_FAIL - 72, 5'd6, 5'd7, 3'b001);

            // 76: jal x8, after_jal
            // x8 should become 80
            imem[19] = enc_j(PC_AFTER_JAL - 76, 5'd8);

            // 80: should be skipped
            imem[20] = enc_i(33, 5'd0, 3'b000, 5'd31, OPC_I);

            // 84: addi x12, x8, -80
            // if jal writeback is correct, x12 = 0
            imem[21] = enc_i(-80, 5'd8, 3'b000, 5'd12, OPC_I);

            // 88: bne x12, x0, fail
            imem[22] = enc_b(PC_FAIL - 88, 5'd0, 5'd12, 3'b001);

            // 92: addi x10, x0, target_jalr
            imem[23] = enc_i(PC_TARGET_JALR, 5'd0, 3'b000, 5'd10, OPC_I);

            // 96: jalr x11, 0(x10)
            // x11 should become 100, PC should jump to 108
            imem[24] = enc_i(0, 5'd10, 3'b000, 5'd11, OPC_JALR);

            // 100: should be skipped
            imem[25] = enc_i(44, 5'd0, 3'b000, 5'd31, OPC_I);

            // 104: if jalr failed, branch to fail
            imem[26] = enc_b(PC_FAIL - 104, 5'd0, 5'd0, 3'b000);

            // 108: addi x13, x11, -100
            // if jalr writeback is correct, x13 = 0
            imem[27] = enc_i(-100, 5'd11, 3'b000, 5'd13, OPC_I);

            // 112: bne x13, x0, fail
            imem[28] = enc_b(PC_FAIL - 112, 5'd0, 5'd13, 3'b001);

            // 116: addi x30, x0, 85
            // pass code = 0x55
            imem[29] = enc_i(85, 5'd0, 3'b000, 5'd30, OPC_I);

            // 120: sw x30, 4(x0)
            // dmem[1] = 0x55 means PASS
            imem[30] = enc_s(4, 5'd30, 5'd0, 3'b010);

            // 124: pass loop
            imem[31] = enc_b(0, 5'd0, 5'd0, 3'b000);

            // 128: fail: addi x30, x0, 51
            // fail code = 0x33
            imem[32] = enc_i(51, 5'd0, 3'b000, 5'd30, OPC_I);

            // 132: sw x30, 4(x0)
            // dmem[1] = 0x33 means FAIL
            imem[33] = enc_s(4, 5'd30, 5'd0, 3'b010);

            // 136: fail loop
            imem[34] = enc_b(0, 5'd0, 5'd0, 3'b000);
        end
    endtask

    task run_cycles;
        input integer n;
        begin
            repeat (n) begin
                @(posedge clk);
                #1;
                $display(
                    "cycle pc=%h inst=%h wb=%h dmem_we=%b addr=%h wdata=%h wstrb=%b",
                    pc_dbg,
                    imem_rdata,
                    wb_dbg,
                    dmem_we,
                    dmem_addr,
                    dmem_wdata,
                    dmem_wstrb
                );
            end
        end
    endtask

    task check_word;
        input [31:0] actual;
        input [31:0] expected;
        input [255:0] name;
        begin
            if (actual !== expected) begin
                $display("[FAIL] %0s actual=%h expected=%h", name, actual, expected);
                error_count = error_count + 1;
            end else begin
                $display("[PASS] %0s = %h", name, actual);
            end
        end
    endtask

    initial begin
        $dumpfile("tb_cpu.vcd");
        $dumpvars(0, tb_cpu);

        error_count = 0;

        for (i = 0; i < 256; i = i + 1) begin
            dmem[i] = 32'b0;
        end

        load_program();

        rst_n = 1'b0;
        run_en = 1'b0;
        step_en = 1'b0;
        board_input = 32'b0;

        repeat (5) @(posedge clk);
        rst_n = 1'b1;

        repeat (2) @(posedge clk);

        run_en = 1'b1;
        run_cycles(60);
        run_en = 1'b0;

        $display("======================================");
        $display("Final check");
        $display("dmem[0] = %h", dmem[0]);
        $display("dmem[1] = %h", dmem[1]);
        $display("dmem[2] = %h", dmem[2]);
        $display("pc_dbg  = %h", pc_dbg);
        $display("======================================");

        check_word(dmem[0], 32'h00000010, "sll/sw/lw result dmem[0]");
        check_word(dmem[1], 32'h00000055, "final pass code dmem[1]");
        check_word(dmem[2], 32'h12345678, "lui/addi/sw result dmem[2]");

        if (error_count == 0) begin
            $display("======================================");
            $display("CPU TEST PASSED");
            $display("======================================");
        end else begin
            $display("======================================");
            $display("CPU TEST FAILED, error_count=%0d", error_count);
            $display("======================================");
        end

        $finish;
    end

endmodule