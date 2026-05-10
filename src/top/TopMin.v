module TopMin #(
    parameter INST_INIT_FILE = "inst.mem",
    parameter DATA_INIT_FILE = "data.mem",
    parameter DEBOUNCE_CYCLES = 1_000_000
)(
    input wire clk_100,
    input wire rst_n,

    input wire start_pg,

    input wire [7:0] switch,
    input wire [7:0] small_switch,

    output wire [7:0] led,
    output wire [7:0] small_led,

    output wire [7:0] tube_scan,
    output wire [7:0] tube_signal_left,
    output wire [7:0] tube_signal_right
);

    wire cpu_rst_n;
    wire run_en;
    wire step_pulse;

    wire [31:0] board_input;

    wire [31:0] imem_addr;
    wire [31:0] imem_rdata;

    wire [31:0] dmem_addr;
    wire [31:0] dmem_rdata;
    wire [31:0] dmem_wdata;
    wire [3:0]  dmem_wstrb;
    wire        dmem_we;
    wire        dmem_re;

    wire [31:0] dmem_dbg_addr;
    wire [31:0] dmem_dbg_rdata;

    wire [31:0] pc_dbg;
    wire [31:0] wb_dbg;
    wire [31:0] reg_dbg;

    reg [31:0] display_data;

    assign cpu_rst_n = rst_n;
    assign run_en = small_switch[7];

    assign board_input = {24'b0, switch};

    assign dmem_dbg_addr = {24'b0, switch};// use switch as debug address

    ButtonDebounce #(
        .DEBOUNCE_CYCLES(DEBOUNCE_CYCLES)
    ) u_step_debounce (
        .clk(clk_100),
        .rst_n(cpu_rst_n),
        .btn_in(start_pg),
        .btn_posedge(step_pulse)
    );

    CPU u_cpu (
        .clk(clk_100),
        .rst_n(cpu_rst_n),

        .run_en(run_en),
        .step_en(step_pulse & ~run_en),

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
        .INIT_FILE(INST_INIT_FILE)
    ) u_inst_ram (
        .clk(clk_100),
        .rst_n(cpu_rst_n),

        .addr(imem_addr),
        .dout(imem_rdata),

        .din(32'b0),
        .we(1'b0),
        .addr_b(32'b0),
        .byte(4'b0000)
    );

    wire [31:0] ram_addr;
    wire [31:0] ram_wdata;
    wire [31:0] ram_rdata;
    wire [3:0]  ram_wstrb;
    wire        ram_we;
    wire        ram_re;

MMIO u_mmio (
    .clk(clk_100),
    .rst_n(cpu_rst_n),

    // CPU memory bus
    .cpu_we(dmem_we),
    .cpu_re(dmem_re),
    .cpu_addr(dmem_addr),
    .cpu_wdata(dmem_wdata),
    .cpu_wstrb(dmem_wstrb),
    .cpu_rdata(dmem_rdata),

    // DataRam side
    .ram_we(ram_we),
    .ram_re(ram_re),
    .ram_addr(ram_addr),
    .ram_wdata(ram_wdata),
    .ram_wstrb(ram_wstrb),
    .ram_rdata(ram_rdata),

    // Board IO
    .switch(switch),
    .LED(led)
);

DatatRam #(
    .ADDR_WIDTH(14),
    .DATA_WIDTH(32),
    .INIT_FILE(DATA_INIT_FILE)
) u_data_ram (
    .clk(clk_100),
    .rst_n(cpu_rst_n),

    .we(ram_we),
    .addr(ram_addr),
    .din(ram_wdata),
    .dout(ram_rdata),
    .byte(ram_wstrb),

    .we_b(1'b0),
    .addr_b(dmem_dbg_addr),
    .dout_b(dmem_dbg_rdata),
    .din_b(32'b0),
    .byte_b(4'b0000)
);


    always @(*) begin
        case (small_switch[3:0])
            4'd0: display_data = pc_dbg;//current PC
            4'd1: display_data = imem_rdata;//current instruction
            4'd2: display_data = wb_dbg;//current write-back data
            4'd3: display_data = reg_dbg;//current register data
            4'd4: display_data = dmem_addr;//current data memory address
            4'd5: display_data = dmem_wdata;//current data memory write data
            4'd6: display_data = dmem_rdata;//current data memory read data
            4'd7: display_data = dmem_dbg_rdata;//current data memory debug read data
            4'd8: display_data = {28'b0, dmem_wstrb};//current data memory write strobe
            4'd9: display_data = {30'b0, dmem_we, dmem_re};//current data memory write enable and read enable
            4'd10: display_data = board_input;//current board input
            default: display_data = 32'hDEAD_BEEF;
        endcase
    end

    assign small_led = small_switch;

    SevenSeg u_seven_seg (
        .clk(clk_100),
        .rst_n(cpu_rst_n),
        .data(display_data),
        .tube_scan(tube_scan),
        .tube_signal_left(tube_signal_left),
        .tube_signal_right(tube_signal_right)
    );

endmodule