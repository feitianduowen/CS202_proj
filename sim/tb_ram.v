`timescale 1ns / 1ps

module tb_ram;

    reg clk;
    reg rst_n;
    reg run_en;
    reg step_en;
    reg [31:0] board_input;

    wire [31:0] imem_addr;
    wire [31:0] imem_rdata;

    wire [31:0] dmem_addr;
    wire [31:0] dmem_rdata;
    wire [31:0] dmem_wdata;
    wire [3:0]  dmem_wstrb;
    wire        dmem_we;
    wire        dmem_re;

    wire [31:0] pc_dbg;
    wire [31:0] wb_dbg;
    wire [31:0] reg_dbg;

    // InstRam programming port
    reg [31:0] imem_prog_addr;
    reg [31:0] imem_prog_data;
    reg        imem_prog_we;
    reg [3:0]  imem_prog_byte;

    // DataRam debug port
    reg        dmem_dbg_we;
    reg [31:0] dmem_dbg_addr;
    wire [31:0] dmem_dbg_rdata;
    reg [31:0] dmem_dbg_wdata;
    reg [3:0]  dmem_dbg_byte;

    integer error_count;
    integer cycle_count;

    localparam [6:0] OPC_R      = 7'b0110011;
    localparam [6:0] OPC_I      = 7'b0010011;
    localparam [6:0] OPC_LOAD   = 7'b0000011;
    localparam [6:0] OPC_STORE  = 7'b0100011;
    localparam [6:0] OPC_BRANCH = 7'b1100011;
    localparam [6:0] OPC_LUI    = 7'b0110111;
    localparam [6:0] OPC_JAL    = 7'b1101111;
    localparam [6:0] OPC_JALR   = 7'b1100111;

    localparam integer PC_FAIL = 128;

    // ============================================================
    // Clock
    // ============================================================

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // ============================================================
    // CPU
    // ============================================================

    CPU u_cpu (
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

    // ============================================================
    // InstRam
    // ============================================================

    InstRam #(
        .ADDR_WIDTH(14),
        .DATA_WIDTH(32),
        .INIT_FILE("")
    ) u_inst_ram (
        .clk(clk),
        .rst_n(rst_n),

        .addr(imem_addr),
        .dout(imem_rdata),

        .din(imem_prog_data),
        .we(imem_prog_we),

        .addr_b(imem_prog_addr),
        .byte(imem_prog_byte)
    );

    // ============================================================
    // DataRam
    // ============================================================

    DatatRam #(
        .ADDR_WIDTH(14),
        .DATA_WIDTH(32),
        .INIT_FILE("")
    ) u_data_ram (
        .clk(clk),
        .rst_n(rst_n),

        .we(dmem_we),
        .addr(dmem_addr),
        .dout(dmem_rdata),
        .din(dmem_wdata),
        .byte(dmem_wstrb),

        .we_b(dmem_dbg_we),
        .addr_b(dmem_dbg_addr),
        .dout_b(dmem_dbg_rdata),
        .din_b(dmem_dbg_wdata),
        .byte_b(dmem_dbg_byte)
    );

    // ============================================================
    // RISC-V instruction encoders
    // ============================================================

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

    // ============================================================
    // RAM helper tasks
    // ============================================================

    task write_inst;
        input [31:0] addr;
        input [31:0] inst;
        begin
            @(negedge clk);
            imem_prog_addr = addr;
            imem_prog_data = inst;
            imem_prog_byte = 4'b1111;
            imem_prog_we   = 1'b1;

            @(negedge clk);
            imem_prog_we   = 1'b0;
            imem_prog_addr = 32'b0;
            imem_prog_data = 32'b0;
            imem_prog_byte = 4'b0000;
        end
    endtask

    task write_dmem_word;
        input [31:0] addr;
        input [31:0] data;
        begin
            @(negedge clk);
            dmem_dbg_addr  = addr;
            dmem_dbg_wdata = data;
            dmem_dbg_byte  = 4'b1111;
            dmem_dbg_we    = 1'b1;

            @(negedge clk);
            dmem_dbg_we    = 1'b0;
            dmem_dbg_addr  = 32'b0;
            dmem_dbg_wdata = 32'b0;
            dmem_dbg_byte  = 4'b0000;
        end
    endtask

    task read_dmem_word;
        input [31:0] addr;
        output [31:0] data;
        begin
            @(negedge clk);
            dmem_dbg_addr = addr;
            dmem_dbg_we = 1'b0;
            #1;
            data = dmem_dbg_rdata;
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

    // ============================================================
    // Program
    // ============================================================
    //
    // Data preload:
    // addr 0: 0x12345678
    //   byte addr 0 = 0x78
    //   byte addr 1 = 0x56
    //   byte addr 2 = 0x34
    //   byte addr 3 = 0x12
    //
    // addr 4: 0x80FF7F00
    //   byte addr 4 = 0x00
    //   byte addr 5 = 0x7F
    //   byte addr 6 = 0xFF
    //   byte addr 7 = 0x80
    //
    // Tests:
    // lh 2(x0)  -> 0x00001234
    // lb 6(x0)  -> 0xFFFFFFFF
    // lb 7(x0)  -> 0xFFFFFF80
    // lh 6(x0)  -> 0xFFFF80FF
    // sb -1,9(x0)  -> dmem[8]  = 0x0000FF00
    // sh -1,14(x0) -> dmem[12] = 0xFFFF0000
    // ============================================================

    task load_program;
        begin
            // 0: lh x1, 2(x0)
            // expect x1 = 0x00001234
            write_inst(32'd0, enc_i(2, 5'd0, 3'b001, 5'd1, OPC_LOAD));

            // 4: lui x2, 0x1
            write_inst(32'd4, enc_u(20'h00001, 5'd2, OPC_LUI));

            // 8: addi x2, x2, 0x234
            // x2 = 0x1234
            write_inst(32'd8, enc_i(12'h234, 5'd2, 3'b000, 5'd2, OPC_I));

            // 12: bne x1, x2, fail
            write_inst(32'd12, enc_b(PC_FAIL - 12, 5'd2, 5'd1, 3'b001));

            // 16: lb x3, 6(x0)
            // byte at addr 6 = 0xFF, expect sign-extended -1
            write_inst(32'd16, enc_i(6, 5'd0, 3'b000, 5'd3, OPC_LOAD));

            // 20: addi x4, x0, -1
            write_inst(32'd20, enc_i(-1, 5'd0, 3'b000, 5'd4, OPC_I));

            // 24: bne x3, x4, fail
            write_inst(32'd24, enc_b(PC_FAIL - 24, 5'd4, 5'd3, 3'b001));

            // 28: lb x5, 7(x0)
            // byte at addr 7 = 0x80, expect 0xFFFFFF80
            write_inst(32'd28, enc_i(7, 5'd0, 3'b000, 5'd5, OPC_LOAD));

            // 32: addi x6, x0, -128
            write_inst(32'd32, enc_i(-128, 5'd0, 3'b000, 5'd6, OPC_I));

            // 36: bne x5, x6, fail
            write_inst(32'd36, enc_b(PC_FAIL - 36, 5'd6, 5'd5, 3'b001));

            // 40: lh x7, 6(x0)
            // halfword at addr 6 = 0x80FF, expect 0xFFFF80FF
            write_inst(32'd40, enc_i(6, 5'd0, 3'b001, 5'd7, OPC_LOAD));

            // 44: lui x8, 0xFFFF8
            // x8 = 0xFFFF8000
            write_inst(32'd44, enc_u(20'hFFFF8, 5'd8, OPC_LUI));

            // 48: addi x8, x8, 0x0FF
            // x8 = 0xFFFF80FF
            write_inst(32'd48, enc_i(12'h0FF, 5'd8, 3'b000, 5'd8, OPC_I));

            // 52: bne x7, x8, fail
            write_inst(32'd52, enc_b(PC_FAIL - 52, 5'd8, 5'd7, 3'b001));

            // 56: addi x9, x0, -1
            // x9 = 0xFFFFFFFF
            write_inst(32'd56, enc_i(-1, 5'd0, 3'b000, 5'd9, OPC_I));

            // 60: sb x9, 9(x0)
            // addr 9 = word addr 8 + byte offset 1
            // expect dmem[8] = 0x0000FF00
            write_inst(32'd60, enc_s(9, 5'd9, 5'd0, 3'b000));

            // 64: lb x10, 9(x0)
            // expect x10 = 0xFFFFFFFF
            write_inst(32'd64, enc_i(9, 5'd0, 3'b000, 5'd10, OPC_LOAD));

            // 68: bne x10, x9, fail
            write_inst(32'd68, enc_b(PC_FAIL - 68, 5'd9, 5'd10, 3'b001));

            // 72: sh x9, 14(x0)
            // addr 14 = word addr 12 + byte offset 2
            // expect dmem[12] = 0xFFFF0000
            write_inst(32'd72, enc_s(14, 5'd9, 5'd0, 3'b001));

            // 76: lh x11, 14(x0)
            // expect x11 = 0xFFFFFFFF
            write_inst(32'd76, enc_i(14, 5'd0, 3'b001, 5'd11, OPC_LOAD));

            // 80: bne x11, x9, fail
            write_inst(32'd80, enc_b(PC_FAIL - 80, 5'd9, 5'd11, 3'b001));

            // 84: lbu x12, 9(x0)
            // expect x12 = 0x000000FF
            write_inst(32'd84, enc_i(9, 5'd0, 3'b100, 5'd12, OPC_LOAD));

            // 88: addi x13, x0, 255
            write_inst(32'd88, enc_i(255, 5'd0, 3'b000, 5'd13, OPC_I));

            // 92: bne x12, x13, fail
            write_inst(32'd92, enc_b(PC_FAIL - 92, 5'd13, 5'd12, 3'b001));

            // 96: addi x30, x0, 85
            // pass code = 0x55
            write_inst(32'd96, enc_i(85, 5'd0, 3'b000, 5'd30, OPC_I));

            // 100: sw x30, 16(x0)
            // dmem[16] = 0x55 means PASS
            write_inst(32'd100, enc_s(16, 5'd30, 5'd0, 3'b010));

            // 104: pass loop
            write_inst(32'd104, enc_b(0, 5'd0, 5'd0, 3'b000));

            // 128: fail: addi x30, x0, 51
            // fail code = 0x33
            write_inst(32'd128, enc_i(51, 5'd0, 3'b000, 5'd30, OPC_I));

            // 132: sw x30, 16(x0)
            write_inst(32'd132, enc_s(16, 5'd30, 5'd0, 3'b010));

            // 136: fail loop
            write_inst(32'd136, enc_b(0, 5'd0, 5'd0, 3'b000));
        end
    endtask

    // ============================================================
    // Main test
    // ============================================================

    reg [31:0] data0;
    reg [31:0] data4;
    reg [31:0] data8;
    reg [31:0] data12;
    reg [31:0] data16;

    initial begin
        $dumpfile("tb_ram.vcd");
        $dumpvars(0, tb_ram);

        error_count = 0;
        cycle_count = 0;

        rst_n = 1'b0;
        run_en = 1'b0;
        step_en = 1'b0;
        board_input = 32'b0;

        imem_prog_addr = 32'b0;
        imem_prog_data = 32'b0;
        imem_prog_we = 1'b0;
        imem_prog_byte = 4'b0000;

        dmem_dbg_we = 1'b0;
        dmem_dbg_addr = 32'b0;
        dmem_dbg_wdata = 32'b0;
        dmem_dbg_byte = 4'b0000;

        repeat (3) @(posedge clk);

        $display("======================================");
        $display("Preload DataRam...");
        $display("======================================");

        write_dmem_word(32'd0,  32'h12345678);
        write_dmem_word(32'd4,  32'h80FF7F00);
        write_dmem_word(32'd8,  32'h00000000);
        write_dmem_word(32'd12, 32'h00000000);
        write_dmem_word(32'd16, 32'h00000000);

        read_dmem_word(32'd0, data0);
        read_dmem_word(32'd4, data4);

        check_word(data0, 32'h12345678, "preload dmem[0]");
        check_word(data4, 32'h80FF7F00, "preload dmem[4]");

        $display("======================================");
        $display("Loading program into InstRam...");
        $display("======================================");

        load_program();

        repeat (2) @(posedge clk);

        $display("======================================");
        $display("Start CPU...");
        $display("======================================");

        $display("======================================");
        $display("Check InstRam preload");
        $display("imem[0] = %h", u_inst_ram.mem[0]);
        $display("imem[1] = %h", u_inst_ram.mem[1]);
        $display("imem[2] = %h", u_inst_ram.mem[2]);
        $display("imem[3] = %h", u_inst_ram.mem[3]);
        $display("======================================");

        if (u_inst_ram.mem[0][31:16] === 16'hxxxx) begin
            $display("[FAIL] InstRam high 16 bits are still X. Check byte width and write logic.");
            $finish;
        end
        
        rst_n = 1'b1;
        repeat (2) @(posedge clk);

        run_en = 1'b1;

        repeat (80) begin
            @(posedge clk);
            #1;
            cycle_count = cycle_count + 1;

            $display(
                "cycle=%0d pc=%h inst=%h wb=%h dmem_we=%b dmem_addr=%h dmem_wdata=%h wstrb=%b",
                cycle_count,
                pc_dbg,
                imem_rdata,
                wb_dbg,
                dmem_we,
                dmem_addr,
                dmem_wdata,
                dmem_wstrb
            );
        end

        run_en = 1'b0;

        read_dmem_word(32'd0, data0);
        read_dmem_word(32'd4, data4);
        read_dmem_word(32'd8, data8);
        read_dmem_word(32'd12, data12);
        read_dmem_word(32'd16, data16);

        $display("======================================");
        $display("Final DataRam check");
        $display("dmem[0]  = %h", data0);
        $display("dmem[4]  = %h", data4);
        $display("dmem[8]  = %h", data8);
        $display("dmem[12] = %h", data12);
        $display("dmem[16] = %h", data16);
        $display("pc_dbg   = %h", pc_dbg);
        $display("======================================");

        check_word(data0,  32'h12345678, "dmem[0] unchanged");
        check_word(data4,  32'h80FF7F00, "dmem[4] unchanged");
        check_word(data8,  32'h0000FF00, "sb non-low byte write at addr 9");
        check_word(data12, 32'hFFFF0000, "sh non-low half write at addr 14");
        check_word(data16, 32'h00000055, "final pass code");

        if (error_count == 0) begin
            $display("======================================");
            $display("CPU + InstRam + DatatRam BYTE TEST PASSED");
            $display("======================================");
        end else begin
            $display("======================================");
            $display("CPU + InstRam + DatatRam BYTE TEST FAILED, error_count=%0d", error_count);
            $display("======================================");
        end

        $finish;
    end

endmodule