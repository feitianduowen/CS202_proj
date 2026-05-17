module TopDebug  #(
    parameter INST_INIT_FILE = "inst.mem",
    parameter DATA_INIT_FILE = "data.mem",
    parameter DEBOUNCE_CYCLES = 1_000_000
)(
   input  wire clk_100,
   input  wire rst_n,

   input  wire rx,
   output wire tx,

   input  wire [7:0] switch,
   input  wire [7:0] small_switch,
   input  wire start_pg,

   output wire [7:0] led,
   output wire [7:0] small_led,
   output wire [7:0] tube_scan,
   output wire [7:0] tube_signal_left,
   output wire [7:0] tube_signal_right
);

   // =========================
   // UART RX/TX
   // =========================
   wire [7:0] rx_data;
   wire rx_valid;
   wire [7:0] tx_data;
   wire tx_start;
   wire tx_busy;

   UartRx #(
      .CLK_FREQ(100_000_000),
      .BAUD(115200)
   ) u_uart_rx (
      .clk    (clk_100),
      .rst_n   (rst_n),
      .rx_pin  (rx),
      .rx_data (rx_data),
      .rx_valid(rx_valid)
   );

   UartTx #(
      .CLK_FREQ(100_000_000),
      .BAUD(115200)
   ) u_uart_tx (
      .clk    (clk_100),
      .rst_n   (rst_n),
      .tx_data (tx_data),
      .tx_start(tx_start),
      .tx_busy (tx_busy),
      .tx_pin  (tx)
   );

   // =========================
   // DebugController wires
   // =========================
   wire cpu_halt;
   wire cpu_step;
   wire cpu_reset;

   wire [4:0]  dbg_reg_addr;
   wire [31:0] dbg_reg_data;
   wire [31:0] dbg_pc;

   wire      inst_dbg_en;
   wire      inst_wr_en;
   wire [31:0] inst_dbg_addr;
   wire [31:0] inst_wr_data;
   wire [31:0] inst_rd_data;

   wire      dmem_dbg_en;
   wire      dmem_wr_en;
   wire [31:0] dmem_dbg_addr;
   wire [31:0] dmem_wr_data;
   wire [31:0] dmem_rd_data;

   DebugController u_debug_ctrl (
      .clk     (clk_100),
      .rst_n   (rst_n),

      .rx_data  (rx_data),
      .rx_valid (rx_valid),
      .tx_data  (tx_data),
      .tx_start (tx_start),
      .tx_busy  (tx_busy),

      .cpu_halt (cpu_halt),
      .cpu_step (cpu_step),
      .cpu_reset(cpu_reset),

      .dbg_reg_addr(dbg_reg_addr),
      .dbg_reg_data(dbg_reg_data),

      .inst_dbg_en  (inst_dbg_en),
      .inst_wr_en   (inst_wr_en),
      .inst_dbg_addr(inst_dbg_addr),
      .inst_wr_data (inst_wr_data),
      .inst_rd_data (inst_rd_data),

      .dmem_dbg_en  (dmem_dbg_en),
      .dmem_wr_en   (dmem_wr_en),
      .dmem_dbg_addr(dmem_dbg_addr),
      .dmem_wr_data (dmem_wr_data),
      .dmem_rd_data (dmem_rd_data),

      .dbg_pc(dbg_pc)
   );

   wire cpu_rst_n;
   assign cpu_rst_n = rst_n & ~cpu_reset;

   // =========================
   // CPU + memory wires
   // =========================
   wire [31:0] imem_addr;
   wire [31:0] imem_rdata;

   wire [31:0] dmem_addr;
   wire [31:0] dmem_wdata;
   wire [31:0] dmem_rdata;
   wire [3:0]  dmem_wstrb;
   wire      dmem_we;
   wire      dmem_re;

   wire [31:0] pc_dbg;
   wire [31:0] wb_dbg;
   wire [31:0] reg_dbg;

   wire debug_mem_busy;
   wire cpu_run_en;

assign debug_mem_busy = inst_dbg_en | dmem_dbg_en;
assign cpu_run_en = cpu_step & ~debug_mem_busy;

   CPU u_cpu (
      .clk    (clk_100),
      .rst_n   (cpu_rst_n),

      .run_en  (cpu_run_en),
      .step_en (1'b0),

      .imem_rdata(imem_rdata),
      .dmem_rdata(dmem_rdata),

      .pc_dbg  (pc_dbg),
      .wb_dbg  (wb_dbg),
      .reg_dbg (reg_dbg),

      .dbg_reg_addr(dbg_reg_addr),
      .dbg_reg_data(dbg_reg_data),
      .dbg_pc     (dbg_pc),

      .imem_addr (imem_addr),
      .dmem_addr (dmem_addr),
      .dmem_wdata(dmem_wdata),
      .dmem_wstrb(dmem_wstrb),
      .dmem_we   (dmem_we),
      .dmem_re   (dmem_re)
   );

   InstRam #(
      .INIT_FILE("inst.mem")
   ) u_inst_ram (
      .clk        (clk_100),
      .rst_n      (cpu_rst_n),

      .addr       (imem_addr),
      .dout       (imem_rdata),

      .inst_dbg_en  (inst_dbg_en),
      .inst_wr_en   (inst_wr_en),
      .inst_dbg_addr(inst_dbg_addr),
      .inst_wr_data (inst_wr_data),
      .inst_rd_data (inst_rd_data)
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
   .INIT_FILE("data.mem")
) u_data_ram (
   .clk(clk_100),
   .rst_n(cpu_rst_n),

   .we(ram_we),
   .addr(ram_addr),
   .din(ram_wdata),
   .dout(ram_rdata),
   .byte(ram_wstrb),

   .we_b   (dmem_dbg_en & dmem_wr_en),
   .addr_b (dmem_dbg_addr),
   .dout_b (dmem_rd_data),
   .din_b  (dmem_wr_data),
   .byte_b (4'b1111)
);

    wire step_pulse;
    reg [31:0] display_data;
    wire [31:0] board_input;
    
    assign board_input = {24'b0, switch};


always @(*) begin
        case (small_switch[3:0])
            4'd0: display_data = pc_dbg;//current PC
            4'd1: display_data = imem_rdata;//current instruction
            4'd2: display_data = wb_dbg;//current write-back data
            4'd3: display_data = reg_dbg;//current register data
            4'd4: display_data = dmem_addr;//current data memory address
            4'd5: display_data = dmem_wdata;//current data memory write data
            4'd6: display_data = dmem_rdata;//current data memory read data
            4'd7: display_data = dmem_rd_data;//current data memory debug read data
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

   ButtonDebounce #(
        .DEBOUNCE_CYCLES(DEBOUNCE_CYCLES)
    ) u_step_debounce (
        .clk(clk_100),
        .rst_n(cpu_rst_n),
        .btn_in(start_pg),
        .btn_posedge(step_pulse)
    );

endmodule