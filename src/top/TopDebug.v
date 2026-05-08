module TopDebug (
    input wire clk_100,
    input wire rst_n,
    input wire finish,
    input wire [7:0] switch,
    input wire [7:0] small_switch,
    input wire start_pg,
    input wire rx,
    output wire tx,
    output wire [7:0] tube_scan,
    output wire [7:0] tube_signal_left,
    output wire [7:0] tube_signal_right,
    output wire [7:0] led,
    output wire [7:0] small_led
);

    wire [31:0] board_input_data;
    wire cpu_run;
    wire cpu_step;
    wire cpu_reset;
    wire [31:0] pc_dbg;
    wire [31:0] wb_dbg;
    wire [31:0] reg_dbg;
    wire [31:0] imem_addr;
    wire [31:0] dmem_addr;
    wire [31:0] dmem_wdata;
    wire [31:0] dmem_rdata;
    wire [3:0] dmem_wstrb;
    wire dmem_we;
    wire dmem_re;
    wire [7:0] board_led;
    wire [7:0] board_small_led;
    wire [7:0] board_tube_scan;
    wire [7:0] board_tube_left;
    wire [7:0] board_tube_right;

    BoardInput u_board_input (
        .clk(clk_100),
        .rst_n(rst_n),
        .finish(finish),
        .start_pg(start_pg),
        .switch(switch),
        .small_switch(small_switch),
        .input_data(board_input_data),
        .cpu_reset(cpu_reset),
        .cpu_run(cpu_run),
        .cpu_step(cpu_step)
    );

    CPU u_cpu (
        .clk(clk_100),
        .rst_n(rst_n & ~cpu_reset),
        .run_en(cpu_run),
        .step_en(cpu_step),
        .board_input(board_input_data),
        .imem_rdata(32'b0),
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

    Ram u_ram (
        .clk(clk_100),
        .we(dmem_we),
        .wstrb(dmem_wstrb),
        .addr(dmem_addr),
        .wdata(dmem_wdata),
        .rdata(dmem_rdata),
        .dbg_we(1'b0),
        .dbg_addr(32'b0),
        .dbg_wdata(32'b0),
        .dbg_rdata()
    );

    UartDebug u_uart_debug (
        .clk(clk_100),
        .rst_n(rst_n),
        .rx(rx),
        .tx(tx),
        .pc(pc_dbg),
        .reg_data(reg_dbg),
        .imem_rdata(32'b0),
        .dmem_rdata(dmem_rdata),
        .cpu_reset(),
        .cpu_run(),
        .cpu_step(),
        .imem_we(),
        .dmem_we(),
        .dbg_addr(),
        .dbg_wdata()
    );

    BoardOutput u_board_output (
        .clk(clk_100),
        .rst_n(rst_n),
        .pc_dbg(pc_dbg),
        .wb_dbg(wb_dbg),
        .reg_dbg(reg_dbg),
        .led_data(board_led),
        .small_led_data(board_small_led),
        .tube_scan_data(board_tube_scan),
        .tube_left_data(board_tube_left),
        .tube_right_data(board_tube_right),
        .tube_scan(tube_scan),
        .tube_signal_left(tube_signal_left),
        .tube_signal_right(tube_signal_right),
        .led(led),
        .small_led(small_led)
    );

    assign board_led = pc_dbg[7:0];
    assign board_small_led = wb_dbg[7:0];
    assign board_tube_scan = 8'hff;
    assign board_tube_left = reg_dbg[7:0];
    assign board_tube_right = reg_dbg[15:8];

endmodule