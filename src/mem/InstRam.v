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

    // Debug / programming write port
    input  wire [31:0] din,
    input  wire        we,
    input  wire [31:0] addr_b,
    input  wire [3:0]  byte
);

    localparam WORD_ADDR_WIDTH = ADDR_WIDTH - 2;
    localparam WORD_DEPTH = 1 << WORD_ADDR_WIDTH;

    // 当前 CPU 是异步取指，所以这里不要强制 block RAM。
    // distributed RAM 支持异步读，更适合你现在的单周期 CPU。
    (* ram_style = "distributed" *)
    reg [DATA_WIDTH-1:0] mem [0:WORD_DEPTH-1];

    wire [WORD_ADDR_WIDTH-1:0] read_addr;
    wire [WORD_ADDR_WIDTH-1:0] write_addr;

    assign read_addr  = addr[ADDR_WIDTH-1:2];
    assign write_addr = addr_b[ADDR_WIDTH-1:2];

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
    assign dout = mem[read_addr];

    // Debug / UART / testbench 写指令口
    always @(posedge clk) begin
        if (we) begin
            if (byte[0]) mem[write_addr][7:0]   <= din[7:0];
            if (byte[1]) mem[write_addr][15:8]  <= din[15:8];
            if (byte[2]) mem[write_addr][23:16] <= din[23:16];
            if (byte[3]) mem[write_addr][31:24] <= din[31:24];
        end
    end

    // 避免 rst_n 未使用 warning
    wire unused_rst_n;
    assign unused_rst_n = rst_n;

endmodule