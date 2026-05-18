`timescale 1ns / 1ps

module tb_Accelerator;

    reg  [31:0] rs1_data;
    reg  [2:0]  funct3;
    wire [31:0] result;

    integer error_count;

    Accelerator u_acc (
        .rs1_data(rs1_data),
        .funct3(funct3),
        .result(result)
    );

    task check_word;
        input [31:0] actual;
        input [31:0] expected;
        input [255:0] name;
        begin
            if (actual !== expected) begin
                $display("[FAIL] %0s: actual=0x%h, expected=0x%h", name, actual, expected);
                error_count = error_count + 1;
            end else begin
                $display("[PASS] %0s = 0x%h", name, actual);
            end
        end
    endtask

    initial begin
        $dumpfile("tb_Accelerator.vcd");
        $dumpvars(0, tb_Accelerator);

        error_count = 0;

        // ============================================================
        // Popcount
        // ============================================================
        $display("=========================================");
        $display("Popcount Tests");
        $display("=========================================");

        funct3 = 3'b000;

        rs1_data = 32'hC1;  #10;
        check_word(result, 32'h03, "popcount(0xC1)");

        rs1_data = 32'hF8;  #10;
        check_word(result, 32'h05, "popcount(0xF8)");

        // ============================================================
        // FP16 Classify
        // ============================================================
        $display("=========================================");
        $display("FP16 Classify Tests");
        $display("=========================================");

        funct3 = 3'b001;

        rs1_data = 32'h8000;  #10;
        check_word(result, 32'h00, "classify 0x8000");

        rs1_data = 32'h0000;  #10;
        check_word(result, 32'h00, "classify 0x0000");

        rs1_data = 32'h7C00;  #10;
        check_word(result, 32'h01, "classify 0x7C00");

        rs1_data = 32'hFC00;  #10;
        check_word(result, 32'h01, "classify 0xFC00");

        rs1_data = 32'hFC01;  #10;
        check_word(result, 32'h02, "classify 0xFC01");

        rs1_data = 32'h2026;  #10;
        check_word(result, 32'h03, "classify 0x2026");

        rs1_data = 32'hC202;  #10;
        check_word(result, 32'h03, "classify 0xC202");

        rs1_data = 32'h0003;  #10;
        check_word(result, 32'h04, "classify 0x0003");

        rs1_data = 32'h80E1;  #10;
        check_word(result, 32'h04, "classify 0x80E1");

        // ============================================================
        // FP16 -> Q3.4
        // ============================================================
        $display("=========================================");
        $display("FP16 -> Q3.4 Tests");
        $display("=========================================");

        funct3 = 3'b010;

        rs1_data = 32'h3C00;  #10;
        check_word(result, 32'h10, "q34 0x3C00");

        rs1_data = 32'h3E00;  #10;
        check_word(result, 32'h18, "q34 0x3E00");

        rs1_data = 32'h4200;  #10;
        check_word(result, 32'h30, "q34 0x4200");

        rs1_data = 32'hC400;  #10;
        check_word(result, 32'hC0, "q34 0xC400");

        rs1_data = 32'h4240;  #10;
        check_word(result, 32'h32, "q34 0x4240");

        rs1_data = 32'hBF00;  #10;
        check_word(result, 32'hE4, "q34 0xBF00");

        rs1_data = 32'h4099;  #10;
        check_word(result, 32'h24, "q34 0x4099");

        // ============================================================
        // Fibonacci
        // ============================================================
        $display("=========================================");
        $display("Fibonacci Tests");
        $display("=========================================");

        funct3 = 3'b011;

        rs1_data = 32'h01;  #10;
        check_word(result, 32'h01, "fib(1)");

        rs1_data = 32'h02;  #10;
        check_word(result, 32'h01, "fib(2)");

        rs1_data = 32'h03;  #10;
        check_word(result, 32'h02, "fib(3)");

        rs1_data = 32'h04;  #10;
        check_word(result, 32'h03, "fib(4)");

        // ============================================================
        // Result
        // ============================================================
        $display("=========================================");
        if (error_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("TESTS FAILED: error_count = %0d", error_count);
        $display("=========================================");

        $finish;
    end

endmodule