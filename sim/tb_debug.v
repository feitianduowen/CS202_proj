`timescale 1ns / 1ps

module tb_debug;

    // ============================================================
    // Clock / Reset
    // ============================================================
    reg clk_100;
    reg rst_n;

    initial begin
        clk_100 = 1'b0;
        forever #5 clk_100 = ~clk_100;   // 100MHz
    end

    // ============================================================
    // UART lines
    // rx: PC -> FPGA, driven by TB
    // tx: FPGA -> PC, sampled by TB
    // ============================================================
    reg  rx;
    wire tx;

    // Board IO
    reg  [7:0] switch;
    reg  [7:0] small_switch;
    reg        start_pg;

    wire [7:0] led;
    wire [7:0] small_led;
    wire [7:0] tube_scan;
    wire [7:0] tube_signal_left;
    wire [7:0] tube_signal_right;

    // ============================================================
    // DUT
    // If your local TopDebug does not have these parameters,
    // remove the #(...) part.
    // ============================================================
    TopDebug #(
        .INST_INIT_FILE("inst.mem"),
        .DATA_INIT_FILE("data.mem"),
        .DEBOUNCE_CYCLES(100)
    ) dut (
        .clk_100(clk_100),
        .rst_n(rst_n),

        .rx(rx),
        .tx(tx),

        .switch(switch),
        .small_switch(small_switch),
        .start_pg(start_pg),

        .led(led),
        .small_led(small_led),
        .tube_scan(tube_scan),
        .tube_signal_left(tube_signal_left),
        .tube_signal_right(tube_signal_right)
    );

    // ============================================================
    // UART protocol constants
    // ============================================================
    localparam integer BAUD     = 115200;
    localparam integer BIT_TIME = 1000000000 / BAUD;  // ns, about 8680ns

    // DebugController command codes
    localparam [7:0] CMD_PING       = 8'h00;
    localparam [7:0] CMD_RESET      = 8'h01;
    localparam [7:0] CMD_RUN        = 8'h02;
    localparam [7:0] CMD_HALT       = 8'h03;
    localparam [7:0] CMD_STEP       = 8'h04;
    localparam [7:0] CMD_READ_REG   = 8'h21;
    localparam [7:0] CMD_READ_PC    = 8'h22;
    localparam [7:0] CMD_READ_INST  = 8'h23;
    localparam [7:0] CMD_READ_DMEM  = 8'h24;
    localparam [7:0] CMD_WRITE_INST = 8'h40;
    localparam [7:0] CMD_WRITE_DMEM = 8'h41;

    // Response codes
    localparam [7:0] RESP_PONG   = 8'h80;
    localparam [7:0] RESP_ACK    = 8'h81;
    localparam [7:0] RESP_DATA32 = 8'h82;
    localparam [7:0] RESP_ERR    = 8'hFF;

    integer i;
    reg [7:0]  tmp_byte;
    reg [31:0] tmp_word;

    // ============================================================
    // UART send byte: 1 start bit, 8 data bits, 1 stop bit
    // LSB first
    // ============================================================
    task uart_send_byte;
        input [7:0] data;
        integer k;
        begin
            rx = 1'b0;                 // start bit
            #(BIT_TIME);

            for (k = 0; k < 8; k = k + 1) begin
                rx = data[k];
                #(BIT_TIME);
            end

            rx = 1'b1;                 // stop bit
            #(BIT_TIME);
        end
    endtask

    // ============================================================
    // UART receive byte from tx
    // ============================================================
    task uart_recv_byte;
        output [7:0] data;
        integer k;
        begin
            data = 8'h00;

            // wait for start bit
            wait (tx == 1'b0);

            // sample in the middle of bit 0
            #(BIT_TIME + BIT_TIME / 2);

            for (k = 0; k < 8; k = k + 1) begin
                data[k] = tx;
                #(BIT_TIME);
            end

            // stop bit
            #(BIT_TIME / 2);
        end
    endtask

    task send_word_be;
        input [31:0] data;
        begin
            uart_send_byte(data[31:24]);
            uart_send_byte(data[23:16]);
            uart_send_byte(data[15:8]);
            uart_send_byte(data[7:0]);
        end
    endtask

    task recv_word_be;
        output [31:0] data;
        reg [7:0] b0;
        reg [7:0] b1;
        reg [7:0] b2;
        reg [7:0] b3;
        begin
            uart_recv_byte(b0);
            uart_recv_byte(b1);
            uart_recv_byte(b2);
            uart_recv_byte(b3);
            data = {b0, b1, b2, b3};
        end
    endtask

    task expect_ack;
        begin
            uart_recv_byte(tmp_byte);
            if (tmp_byte !== RESP_ACK) begin
                $display("[ERROR] expect ACK 0x81, got 0x%02h at time %0t", tmp_byte, $time);
                $stop;
            end
        end
    endtask

    task cmd_ping;
        begin
            uart_send_byte(CMD_PING);
            uart_recv_byte(tmp_byte);
            if (tmp_byte !== RESP_PONG) begin
                $display("[ERROR] expect PONG 0x80, got 0x%02h at time %0t", tmp_byte, $time);
                $stop;
            end else begin
                $display("[OK] ping");
            end
        end
    endtask

    task cmd_reset;
        begin
            uart_send_byte(CMD_RESET);
            expect_ack;
            $display("[OK] reset");
        end
    endtask

    task cmd_run;
        begin
            uart_send_byte(CMD_RUN);
            expect_ack;
            $display("[OK] run");
        end
    endtask

    task cmd_halt;
        begin
            uart_send_byte(CMD_HALT);
            expect_ack;
            $display("[OK] halt");
        end
    endtask

    task cmd_step;
        begin
            uart_send_byte(CMD_STEP);
            expect_ack;
            $display("[OK] step");
        end
    endtask

    task write_inst;
        input [31:0] addr;
        input [31:0] data;
        begin
            uart_send_byte(CMD_WRITE_INST);
            send_word_be(addr);
            send_word_be(data);
            expect_ack;
            $display("[OK] IMEM[0x%08h] <= 0x%08h", addr, data);
        end
    endtask

    task read_inst;
        input  [31:0] addr;
        output [31:0] data;
        begin
            uart_send_byte(CMD_READ_INST);
            send_word_be(addr);

            uart_recv_byte(tmp_byte);
            if (tmp_byte !== RESP_DATA32) begin
                $display("[ERROR] read_inst expect DATA32, got 0x%02h", tmp_byte);
                $stop;
            end

            recv_word_be(data);
            $display("[RI] IMEM[0x%08h] = 0x%08h", addr, data);
        end
    endtask

    task write_dmem;
        input [31:0] addr;
        input [31:0] data;
        begin
            uart_send_byte(CMD_WRITE_DMEM);
            send_word_be(addr);
            send_word_be(data);
            expect_ack;
            $display("[OK] DMEM[0x%08h] <= 0x%08h", addr, data);
        end
    endtask

    task read_dmem;
        input  [31:0] addr;
        output [31:0] data;
        begin
            uart_send_byte(CMD_READ_DMEM);
            send_word_be(addr);

            uart_recv_byte(tmp_byte);
            if (tmp_byte !== RESP_DATA32) begin
                $display("[ERROR] read_dmem expect DATA32, got 0x%02h", tmp_byte);
                $stop;
            end

            recv_word_be(data);
            $display("[RD] DMEM[0x%08h] = 0x%08h", addr, data);
        end
    endtask

    task read_pc;
        output [31:0] data;
        begin
            uart_send_byte(CMD_READ_PC);

            uart_recv_byte(tmp_byte);
            if (tmp_byte !== RESP_DATA32) begin
                $display("[ERROR] read_pc expect DATA32, got 0x%02h", tmp_byte);
                $stop;
            end

            recv_word_be(data);
            $display("[PC] 0x%08h", data);
        end
    endtask

    task read_reg;
        input  [4:0]  reg_addr;
        output [31:0] data;
        begin
            uart_send_byte(CMD_READ_REG);
            uart_send_byte({3'b000, reg_addr});

            uart_recv_byte(tmp_byte);
            if (tmp_byte !== RESP_DATA32) begin
                $display("[ERROR] read_reg expect DATA32, got 0x%02h", tmp_byte);
                $stop;
            end

            recv_word_be(data);
            $display("[REG] x%0d = 0x%08h", reg_addr, data);
        end
    endtask

    // ============================================================
    // Load test program into IMEM
    //
    // Assembly:
    //   lui gp,4
    // loop:
    //   lw t0,0(gp)
    //   lw t1,4(gp)
    //   lw t2,8(gp)
    //   beq t0,zero,case0_add
    //   addi t3,zero,1
    //   beq t0,t3,case1_sub
    //   sw zero,12(gp)
    //   jal zero,loop
    // case0_add:
    //   add t4,t1,t2
    //   sw t4,12(gp)
    //   jal zero,loop
    // case1_sub:
    //   sub t4,t1,t2
    //   sw t4,12(gp)
    //   jal zero,loop
    // ============================================================
    task load_program;
        begin
            write_inst(32'h0000_0000, 32'h000041B7); // lui gp,4
            write_inst(32'h0000_0004, 32'h0001A283); // lw t0,0(gp)
            write_inst(32'h0000_0008, 32'h0041A303); // lw t1,4(gp)
            write_inst(32'h0000_000C, 32'h0081A383); // lw t2,8(gp)
            write_inst(32'h0000_0010, 32'h00028A63); // beq t0,zero,case0_add
            write_inst(32'h0000_0014, 32'h00100E13); // addi t3,zero,1
            write_inst(32'h0000_0018, 32'h01C28C63); // beq t0,t3,case1_sub
            write_inst(32'h0000_001C, 32'h0001A623); // sw zero,12(gp)
            write_inst(32'h0000_0020, 32'hFE5FF06F); // jal zero,loop
            write_inst(32'h0000_0024, 32'h00730EB3); // add t4,t1,t2
            write_inst(32'h0000_0028, 32'h01D1A623); // sw t4,12(gp)
            write_inst(32'h0000_002C, 32'hFD9FF06F); // jal zero,loop
            write_inst(32'h0000_0030, 32'h40730EB3); // sub t4,t1,t2
            write_inst(32'h0000_0034, 32'h01D1A623); // sw t4,12(gp)
            write_inst(32'h0000_0038, 32'hFCDFF06F); // jal zero,loop
        end
    endtask

    task run_one_case;
        input [31:0] case_id;
        input [31:0] op_a;
        input [31:0] op_b;
        input [31:0] expect;
        reg   [31:0] result;
        begin
            $display("");
            $display("========== CASE %0d: A=0x%08h B=0x%08h expect=0x%08h ==========",
                     case_id, op_a, op_b, expect);

            // Reset CPU PC/registers. CPU should be halted after reset command.
            cmd_reset;

            // Base = 0x4000
            write_dmem(32'h0000_4000, case_id);
            write_dmem(32'h0000_4004, op_a);
            write_dmem(32'h0000_4008, op_b);
            write_dmem(32'h0000_400C, 32'hDEAD_BEEF);

            cmd_run;

            // Enough for several loop iterations.
            // 100MHz: 20000ns = 2000 cycles.
            #20000;

            cmd_halt;

            read_dmem(32'h0000_400C, result);

            if (result === expect) begin
                $display("[PASS] result = 0x%08h", result);
            end else begin
                $display("[FAIL] result = 0x%08h, expect = 0x%08h", result, expect);
                read_pc(tmp_word);
                read_reg(5'd3,  tmp_word);  // gp
                read_reg(5'd5,  tmp_word);  // t0
                read_reg(5'd6,  tmp_word);  // t1
                read_reg(5'd7,  tmp_word);  // t2
                read_reg(5'd29, tmp_word);  // t4
                $stop;
            end
        end
    endtask

    // ============================================================
    // Main test flow
    // ============================================================
    initial begin
        rx = 1'b1;       // UART idle high
        rst_n = 1'b0;
        switch = 8'h00;
        small_switch = 8'h00;
        start_pg = 1'b0;

        #1000;
        rst_n = 1'b1;
        #10000;

        $display("========== tb_debug start ==========");

        cmd_ping;
        cmd_halt;
        cmd_reset;

        load_program;

        // Optional: read back several instructions
        read_inst(32'h0000_0000, tmp_word);
        read_inst(32'h0000_0004, tmp_word);
        read_inst(32'h0000_0008, tmp_word);
        read_inst(32'h0000_000C, tmp_word);

        run_one_case(32'h0000_0000, 32'h0000_000B, 32'h0000_0001, 32'h0000_000C);
        run_one_case(32'h0000_0000, 32'h0000_000B, 32'h0000_0018, 32'h0000_0023);
        run_one_case(32'h0000_0001, 32'h0000_0032, 32'h0000_0014, 32'h0000_001E);

        $display("");
        $display("========== ALL TESTS PASSED ==========");
        #10000;
        $finish;
    end

endmodule