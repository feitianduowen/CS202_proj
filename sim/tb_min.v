`timescale 1ns / 1ps

module tb_min;

    reg clk_100;
    reg rst_n;
    reg start_pg;

    reg [7:0] switch;
    reg [7:0] small_switch;

    wire [7:0] led;
    wire [7:0] small_led;

    wire [7:0] tube_scan;
    wire [7:0] tube_signal_left;
    wire [7:0] tube_signal_right;

    integer error_count;

    TopMin #(
        .INST_INIT_FILE("inst.mem"),
        .DATA_INIT_FILE("data.mem"),
        .DEBOUNCE_CYCLES(4)
    ) u_top (
        .clk_100(clk_100),
        .rst_n(rst_n),

        .start_pg(start_pg),

        .switch(switch),
        .small_switch(small_switch),

        .led(led),
        .small_led(small_led),

        .tube_scan(tube_scan),
        .tube_signal_left(tube_signal_left),
        .tube_signal_right(tube_signal_right)
    );

    initial begin
        clk_100 = 1'b0;
        forever #5 clk_100 = ~clk_100;
    end

    task press_step;
        begin
            @(negedge clk_100);
            start_pg = 1'b1;
            repeat (8) @(negedge clk_100);
            start_pg = 1'b0;
            repeat (8) @(negedge clk_100);
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
        $dumpfile("tb_min.vcd");
        $dumpvars(0, tb_min);

        error_count = 0;

        rst_n = 1'b0;
        start_pg = 1'b0;
        switch = 8'h00;
        small_switch = 8'h00;

        repeat (5) @(posedge clk_100);

        $display("======================================");
        $display("Check instruction memory preload");
        $display("imem[0] = %h", u_top.u_inst_ram.mem[0]);
        $display("imem[1] = %h", u_top.u_inst_ram.mem[1]);
        $display("======================================");

        rst_n = 1'b1;
        repeat (5) @(posedge clk_100);

        $display("======================================");
        $display("Step mode test");
        $display("======================================");

        small_switch[7] = 1'b0;   // pause
        small_switch[3:0] = 4'd0; // display PC

        check_word(u_top.pc_dbg, 32'h00000000, "PC after reset");

        press_step();
        check_word(u_top.pc_dbg, 32'h00000004, "PC after one step");

        press_step();
        check_word(u_top.pc_dbg, 32'h00000008, "PC after two steps");

        $display("======================================");
        $display("Run mode test");
        $display("======================================");

        rst_n = 1'b0;
        repeat (5) @(posedge clk_100);
        rst_n = 1'b1;
        repeat (5) @(posedge clk_100);

        small_switch[7] = 1'b1;   // run
        small_switch[3:0] = 4'd7; // display DataRam debug read
        switch = 8'h40;           // read byte address 0x40, dmem[64]

        repeat (250) @(posedge clk_100);

        small_switch[7] = 1'b0;   // halt

        $display("======================================");
        $display("Final memory check");
        $display("dmem[32] = %h", u_top.u_data_ram.mem[8]);
        $display("dmem[40] = %h", u_top.u_data_ram.mem[10]);
        $display("dmem[44] = %h", u_top.u_data_ram.mem[11]);
        $display("dmem[64] = %h", u_top.u_data_ram.mem[16]);
        $display("led      = %h", led);
        $display("small_led= %h", small_led);
        $display("======================================");

        check_word(u_top.u_data_ram.mem[8],  32'h12345678, "dmem[32] lui/addi/sw/lw");
        check_word(u_top.u_data_ram.mem[10], 32'h0000ff00, "dmem[40] sb non-low byte");
        check_word(u_top.u_data_ram.mem[11], 32'hffff0000, "dmem[44] sh non-low half");
        check_word(u_top.u_data_ram.mem[16], 32'h00000055, "dmem[64] PASS code");

        if (error_count == 0) begin
            $display("======================================");
            $display("TOPMIN TEST PASSED");
            $display("======================================");
        end else begin
            $display("======================================");
            $display("TOPMIN TEST FAILED, error_count=%0d", error_count);
            $display("======================================");
        end

        $finish;
    end

endmodule