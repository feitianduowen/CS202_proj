module InstRam #(
    parameter ADDR_WIDTH = 14,
    parameter DATA_WIDTH = 32,
    parameter INIT_FILE  = "inst.mem"
)(
    input wire clk,
    input wire rst_n,

    // CPU read port
    input  wire [31:0] addr,
    output wire [31:0] dout,

        // Debug port
    input  wire        inst_dbg_en,
    input  wire        inst_wr_en,
    input  wire [31:0] inst_dbg_addr,
    input  wire [31:0] inst_wr_data,
    output wire [31:0] inst_rd_data
);

    localparam WORD_ADDR_WIDTH = ADDR_WIDTH - 2;
    localparam WORD_DEPTH = 1 << WORD_ADDR_WIDTH;

    // 当前 CPU 是异步取指，所以这里不要强制 block RAM。
    // distributed RAM 支持异步读，更适合你现在的单周期 CPU。
    (* ram_style = "distributed" *)
    reg [DATA_WIDTH-1:0] mem [0:WORD_DEPTH-1];

    wire [31:0] addr_mux = inst_dbg_en ? inst_dbg_addr : addr;
    wire [WORD_ADDR_WIDTH-1:0] word_addr = addr_mux[ADDR_WIDTH-1:2];
    integer i;

    initial begin
        // 先全部清零，避免没有被 inst.mem 覆盖的地址变成 X
        for (i = 0; i < WORD_DEPTH; i = i + 1) begin
            mem[i] = {DATA_WIDTH{1'b0}};
        end

        // 再加载指令文件
        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, mem);
        end
    end

    // 异步读：PC 变化后，dout 立即跟着变化
    // 这和你现在的单周期 CPU 兼容
    assign dout = mem[word_addr];

    always @(posedge clk) begin
        if (inst_dbg_en && inst_wr_en) begin
            mem[inst_dbg_addr[ADDR_WIDTH-1:2]] <= inst_wr_data;
        end
    end

    assign inst_rd_data = dout;

    // 避免 rst_n 未使用 warning
    wire unused_rst_n;
    assign unused_rst_n = rst_n;

endmodule