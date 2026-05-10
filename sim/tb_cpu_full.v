`timescale 1ns / 1ps

module tb_cpu_full;

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

    reg [31:0] imem_prog_addr;
    reg [31:0] imem_prog_data;
    reg        imem_prog_we;
    reg [3:0]  imem_prog_byte;

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
    localparam [6:0] OPC_AUIPC  = 7'b0010111;
    localparam [6:0] OPC_JAL    = 7'b1101111;
    localparam [6:0] OPC_JALR   = 7'b1100111;

    localparam integer PC_FAIL        = 512;
    localparam integer PC_JAL_TARGET  = 416;
    localparam integer PC_JALR_TARGET = 440;

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

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

    task load_program;
        begin
            // ----------------------------------------------------
            // R-type and I-type arithmetic
            // ----------------------------------------------------

            write_inst(32'd0,   enc_i(10, 5'd0, 3'b000, 5'd1, OPC_I));  // x1 = 10
            write_inst(32'd4,   enc_i(3,  5'd0, 3'b000, 5'd2, OPC_I));  // x2 = 3

            write_inst(32'd8,   enc_r(7'b0000000, 5'd2, 5'd1, 3'b000, 5'd3)); // add x3=13
            write_inst(32'd12,  enc_i(13, 5'd0, 3'b000, 5'd4, OPC_I));
            write_inst(32'd16,  enc_b(PC_FAIL - 16, 5'd4, 5'd3, 3'b001));

            write_inst(32'd20,  enc_r(7'b0100000, 5'd2, 5'd1, 3'b000, 5'd3)); // sub x3=7
            write_inst(32'd24,  enc_i(7, 5'd0, 3'b000, 5'd4, OPC_I));
            write_inst(32'd28,  enc_b(PC_FAIL - 28, 5'd4, 5'd3, 3'b001));

            write_inst(32'd32,  enc_r(7'b0000000, 5'd2, 5'd1, 3'b111, 5'd3)); // and = 2
            write_inst(32'd36,  enc_i(2, 5'd0, 3'b000, 5'd4, OPC_I));
            write_inst(32'd40,  enc_b(PC_FAIL - 40, 5'd4, 5'd3, 3'b001));

            write_inst(32'd44,  enc_r(7'b0000000, 5'd2, 5'd1, 3'b110, 5'd3)); // or = 11
            write_inst(32'd48,  enc_i(11, 5'd0, 3'b000, 5'd4, OPC_I));
            write_inst(32'd52,  enc_b(PC_FAIL - 52, 5'd4, 5'd3, 3'b001));

            write_inst(32'd56,  enc_r(7'b0000000, 5'd2, 5'd1, 3'b100, 5'd3)); // xor = 9
            write_inst(32'd60,  enc_i(9, 5'd0, 3'b000, 5'd4, OPC_I));
            write_inst(32'd64,  enc_b(PC_FAIL - 64, 5'd4, 5'd3, 3'b001));

            write_inst(32'd68,  enc_r(7'b0000000, 5'd2, 5'd2, 3'b001, 5'd3)); // sll 3<<3=24
            write_inst(32'd72,  enc_i(24, 5'd0, 3'b000, 5'd4, OPC_I));
            write_inst(32'd76,  enc_b(PC_FAIL - 76, 5'd4, 5'd3, 3'b001));

            write_inst(32'd80,  enc_i(-16, 5'd0, 3'b000, 5'd5, OPC_I)); // x5=-16
            write_inst(32'd84,  enc_i(2,   5'd0, 3'b000, 5'd6, OPC_I)); // x6=2

            write_inst(32'd88,  enc_r(7'b0000000, 5'd6, 5'd5, 3'b101, 5'd3)); // srl
            write_inst(32'd92,  enc_u(20'h40000, 5'd4, OPC_LUI));
            write_inst(32'd96,  enc_i(-4, 5'd4, 3'b000, 5'd4, OPC_I));
            write_inst(32'd100, enc_b(PC_FAIL - 100, 5'd4, 5'd3, 3'b001));

            write_inst(32'd104, enc_r(7'b0100000, 5'd6, 5'd5, 3'b101, 5'd3)); // sra
            write_inst(32'd108, enc_i(-4, 5'd0, 3'b000, 5'd4, OPC_I));
            write_inst(32'd112, enc_b(PC_FAIL - 112, 5'd4, 5'd3, 3'b001));

            write_inst(32'd116, enc_r(7'b0000000, 5'd2, 5'd5, 3'b010, 5'd3)); // slt -16 < 3
            write_inst(32'd120, enc_i(1, 5'd0, 3'b000, 5'd4, OPC_I));
            write_inst(32'd124, enc_b(PC_FAIL - 124, 5'd4, 5'd3, 3'b001));

            write_inst(32'd128, enc_r(7'b0000000, 5'd2, 5'd5, 3'b011, 5'd3)); // sltu unsigned false
            write_inst(32'd132, enc_b(PC_FAIL - 132, 5'd0, 5'd3, 3'b001));

            write_inst(32'd136, enc_i(10, 5'd0, 3'b000, 5'd7, OPC_I));
            write_inst(32'd140, enc_i(6,  5'd7, 3'b111, 5'd3, OPC_I)); // andi 10&6=2
            write_inst(32'd144, enc_i(2,  5'd0, 3'b000, 5'd4, OPC_I));
            write_inst(32'd148, enc_b(PC_FAIL - 148, 5'd4, 5'd3, 3'b001));

            write_inst(32'd152, enc_i(5,  5'd7, 3'b110, 5'd3, OPC_I)); // ori 10|5=15
            write_inst(32'd156, enc_i(15, 5'd0, 3'b000, 5'd4, OPC_I));
            write_inst(32'd160, enc_b(PC_FAIL - 160, 5'd4, 5'd3, 3'b001));

            write_inst(32'd164, enc_i(15, 5'd7, 3'b100, 5'd3, OPC_I)); // xori 10^15=5
            write_inst(32'd168, enc_i(5,  5'd0, 3'b000, 5'd4, OPC_I));
            write_inst(32'd172, enc_b(PC_FAIL - 172, 5'd4, 5'd3, 3'b001));

            write_inst(32'd176, enc_i(-4, 5'd5, 3'b010, 5'd3, OPC_I)); // slti -16 < -4
            write_inst(32'd180, enc_i(1,  5'd0, 3'b000, 5'd4, OPC_I));
            write_inst(32'd184, enc_b(PC_FAIL - 184, 5'd4, 5'd3, 3'b001));

            write_inst(32'd188, enc_i(5,  5'd5, 3'b011, 5'd3, OPC_I)); // sltiu unsigned false
            write_inst(32'd192, enc_b(PC_FAIL - 192, 5'd0, 5'd3, 3'b001));

            write_inst(32'd196, enc_i(1, 5'd0, 3'b000, 5'd3, OPC_I));
            write_inst(32'd200, enc_i(5, 5'd3, 3'b001, 5'd3, OPC_I)); // slli 1<<5=32
            write_inst(32'd204, enc_i(32, 5'd0, 3'b000, 5'd4, OPC_I));
            write_inst(32'd208, enc_b(PC_FAIL - 208, 5'd4, 5'd3, 3'b001));

            write_inst(32'd212, enc_i(2, 5'd5, 3'b101, 5'd3, OPC_I)); // srli -16>>2
            write_inst(32'd216, enc_u(20'h40000, 5'd4, OPC_LUI));
            write_inst(32'd220, enc_i(-4, 5'd4, 3'b000, 5'd4, OPC_I));
            write_inst(32'd224, enc_b(PC_FAIL - 224, 5'd4, 5'd3, 3'b001));

            write_inst(32'd228, enc_i(12'h402, 5'd5, 3'b101, 5'd3, OPC_I)); // srai -16>>>2=-4
            write_inst(32'd232, enc_i(-4, 5'd0, 3'b000, 5'd4, OPC_I));
            write_inst(32'd236, enc_b(PC_FAIL - 236, 5'd4, 5'd3, 3'b001));

            // ----------------------------------------------------
            // Branch taken tests
            // ----------------------------------------------------

            write_inst(32'd240, enc_b(248 - 240, 5'd1, 5'd2, 3'b100)); // blt x2,x1
            write_inst(32'd244, enc_j(PC_FAIL - 244, 5'd0));

            write_inst(32'd248, enc_b(256 - 248, 5'd2, 5'd1, 3'b101)); // bge x1,x2
            write_inst(32'd252, enc_j(PC_FAIL - 252, 5'd0));

            write_inst(32'd256, enc_b(264 - 256, 5'd1, 5'd2, 3'b110)); // bltu x2,x1
            write_inst(32'd260, enc_j(PC_FAIL - 260, 5'd0));

            write_inst(32'd264, enc_b(272 - 264, 5'd2, 5'd1, 3'b111)); // bgeu x1,x2
            write_inst(32'd268, enc_j(PC_FAIL - 268, 5'd0));

            write_inst(32'd272, enc_b(280 - 272, 5'd1, 5'd1, 3'b000)); // beq
            write_inst(32'd276, enc_j(PC_FAIL - 276, 5'd0));

            write_inst(32'd280, enc_b(288 - 280, 5'd2, 5'd1, 3'b001)); // bne
            write_inst(32'd284, enc_j(PC_FAIL - 284, 5'd0));

            // ----------------------------------------------------
            // AUIPC, LUI, LW/SW
            // ----------------------------------------------------

            write_inst(32'd288, enc_u(20'h00000, 5'd3, OPC_AUIPC)); // x3 = pc = 288
            write_inst(32'd292, enc_i(-288, 5'd3, 3'b000, 5'd3, OPC_I));
            write_inst(32'd296, enc_b(PC_FAIL - 296, 5'd0, 5'd3, 3'b001));

            write_inst(32'd300, enc_u(20'h12345, 5'd3, OPC_LUI));
            write_inst(32'd304, enc_i(12'h678, 5'd3, 3'b000, 5'd3, OPC_I));
            write_inst(32'd308, enc_s(32, 5'd3, 5'd0, 3'b010)); // sw x3,32(x0)
            write_inst(32'd312, enc_i(32, 5'd0, 3'b010, 5'd4, OPC_LOAD)); // lw
            write_inst(32'd316, enc_b(PC_FAIL - 316, 5'd4, 5'd3, 3'b001));

            // ----------------------------------------------------
            // Load/store byte/half tests
            // Data preload:
            // dmem[0] = 0x12345678
            // dmem[4] = 0x80FF7F00
            // ----------------------------------------------------

            write_inst(32'd320, enc_i(2, 5'd0, 3'b001, 5'd3, OPC_LOAD)); // lh 2 = 0x1234
            write_inst(32'd324, enc_u(20'h00001, 5'd4, OPC_LUI));
            write_inst(32'd328, enc_i(12'h234, 5'd4, 3'b000, 5'd4, OPC_I));
            write_inst(32'd332, enc_b(PC_FAIL - 332, 5'd4, 5'd3, 3'b001));

            write_inst(32'd336, enc_i(6, 5'd0, 3'b000, 5'd3, OPC_LOAD)); // lb 6 = -1
            write_inst(32'd340, enc_i(-1, 5'd0, 3'b000, 5'd4, OPC_I));
            write_inst(32'd344, enc_b(PC_FAIL - 344, 5'd4, 5'd3, 3'b001));

            write_inst(32'd348, enc_i(6, 5'd0, 3'b101, 5'd3, OPC_LOAD)); // lhu 6 = 0x80ff
            write_inst(32'd352, enc_u(20'h00008, 5'd4, OPC_LUI));
            write_inst(32'd356, enc_i(12'h0ff, 5'd4, 3'b000, 5'd4, OPC_I));
            write_inst(32'd360, enc_b(PC_FAIL - 360, 5'd4, 5'd3, 3'b001));

            write_inst(32'd364, enc_i(-1, 5'd0, 3'b000, 5'd5, OPC_I));

            write_inst(32'd368, enc_s(41, 5'd5, 5'd0, 3'b000)); // sb -1, 41(x0)
            write_inst(32'd372, enc_i(41, 5'd0, 3'b000, 5'd6, OPC_LOAD)); // lb 41 = -1
            write_inst(32'd376, enc_b(PC_FAIL - 376, 5'd5, 5'd6, 3'b001));

            write_inst(32'd380, enc_s(46, 5'd5, 5'd0, 3'b001)); // sh -1, 46(x0)
            write_inst(32'd384, enc_i(46, 5'd0, 3'b001, 5'd6, OPC_LOAD)); // lh 46 = -1
            write_inst(32'd388, enc_b(PC_FAIL - 388, 5'd5, 5'd6, 3'b001));

            write_inst(32'd392, enc_i(41, 5'd0, 3'b100, 5'd6, OPC_LOAD)); // lbu 41 = 255
            write_inst(32'd396, enc_i(255, 5'd0, 3'b000, 5'd7, OPC_I));
            write_inst(32'd400, enc_b(PC_FAIL - 400, 5'd7, 5'd6, 3'b001));

            // ----------------------------------------------------
            // JAL / JALR
            // ----------------------------------------------------

            write_inst(32'd404, enc_j(PC_JAL_TARGET - 404, 5'd8)); // x8 = 408
            write_inst(32'd408, enc_j(PC_FAIL - 408, 5'd0));
            write_inst(32'd412, enc_i(0, 5'd0, 3'b000, 5'd0, OPC_I));

            write_inst(32'd416, enc_i(-408, 5'd8, 3'b000, 5'd9, OPC_I));
            write_inst(32'd420, enc_b(PC_FAIL - 420, 5'd0, 5'd9, 3'b001));

            write_inst(32'd424, enc_i(PC_JALR_TARGET, 5'd0, 3'b000, 5'd10, OPC_I));
            write_inst(32'd428, enc_i(0, 5'd10, 3'b000, 5'd11, OPC_JALR)); // x11 = 432
            write_inst(32'd432, enc_j(PC_FAIL - 432, 5'd0));
            write_inst(32'd436, enc_i(0, 5'd0, 3'b000, 5'd0, OPC_I));

            write_inst(32'd440, enc_i(-432, 5'd11, 3'b000, 5'd12, OPC_I));
            write_inst(32'd444, enc_b(PC_FAIL - 444, 5'd0, 5'd12, 3'b001));

            // ----------------------------------------------------
            // PASS
            // ----------------------------------------------------

            write_inst(32'd448, enc_i(85, 5'd0, 3'b000, 5'd30, OPC_I)); // 0x55
            write_inst(32'd452, enc_s(64, 5'd30, 5'd0, 3'b010));        // dmem[64] = 0x55
            write_inst(32'd456, enc_b(0, 5'd0, 5'd0, 3'b000));          // loop

            // ----------------------------------------------------
            // FAIL
            // ----------------------------------------------------

            write_inst(32'd512, enc_i(51, 5'd0, 3'b000, 5'd30, OPC_I)); // 0x33
            write_inst(32'd516, enc_s(64, 5'd30, 5'd0, 3'b010));        // dmem[64] = 0x33
            write_inst(32'd520, enc_b(0, 5'd0, 5'd0, 3'b000));          // loop
        end
    endtask

    reg [31:0] data32;
    reg [31:0] data40;
    reg [31:0] data44;
    reg [31:0] data64;

    initial begin
        $dumpfile("tb_cpu_full.vcd");
        $dumpvars(0, tb_cpu_full);

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
        $display("Preload DataRam");
        $display("======================================");

        write_dmem_word(32'd0,  32'h12345678);
        write_dmem_word(32'd4,  32'h80FF7F00);
        write_dmem_word(32'd32, 32'h00000000);
        write_dmem_word(32'd40, 32'h00000000);
        write_dmem_word(32'd44, 32'h00000000);
        write_dmem_word(32'd64, 32'h00000000);

        $display("======================================");
        $display("Load instruction program");
        $display("======================================");

        load_program();

        $display("imem[0]   = %h", u_inst_ram.mem[0]);
        $display("imem[1]   = %h", u_inst_ram.mem[1]);
        $display("imem[112] = %h", u_inst_ram.mem[112]);
        $display("imem[128] = %h", u_inst_ram.mem[128]);

        repeat (2) @(posedge clk);

        rst_n = 1'b1;
        repeat (2) @(posedge clk);

        $display("======================================");
        $display("Start CPU full instruction test");
        $display("======================================");

        run_en = 1'b1;

        repeat (150) begin
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

        read_dmem_word(32'd32, data32);
        read_dmem_word(32'd40, data40);
        read_dmem_word(32'd44, data44);
        read_dmem_word(32'd64, data64);

        $display("======================================");
        $display("Final check");
        $display("dmem[32] = %h", data32);
        $display("dmem[40] = %h", data40);
        $display("dmem[44] = %h", data44);
        $display("dmem[64] = %h", data64);
        $display("pc_dbg   = %h", pc_dbg);
        $display("======================================");

        check_word(data32, 32'h12345678, "lw/sw/lui/addi result at dmem[32]");
        check_word(data40, 32'h0000FF00, "sb non-low byte write at dmem[40]");
        check_word(data44, 32'hFFFF0000, "sh non-low half write at dmem[44]");
        check_word(data64, 32'h00000055, "final pass code");

        if (error_count == 0) begin
            $display("======================================");
            $display("CPU FULL TEST PASSED");
            $display("======================================");
        end else begin
            $display("======================================");
            $display("CPU FULL TEST FAILED, error_count=%0d", error_count);
            $display("======================================");
        end

        $finish;
    end

endmodule