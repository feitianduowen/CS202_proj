module DatatRam #(
    parameter ADDR_WIDTH = 14,
    parameter DATA_WIDTH = 32,
    parameter INIT_FILE  = "data.mem"
)(
    input wire clk,
    input wire rst_n,

    // CPU port
    input  wire        we,
    input  wire [31:0] addr,
    input  wire [31:0] din,
    output wire [31:0] dout,
    input  wire [3:0]  byte,

    // Debug / programming port
    input  wire        we_b,
    input  wire [31:0] addr_b,
    output wire [31:0] dout_b,
    input  wire [31:0] din_b,
    input  wire [3:0]  byte_b
);

    localparam WORD_ADDR_WIDTH = ADDR_WIDTH - 2;
    localparam WORD_DEPTH = 1 << WORD_ADDR_WIDTH;

    // 当前 CPU 是异步读，因此这里不要用 block。
    // distributed 更适合异步读模板。
    (* ram_style = "distributed" *)
    reg [DATA_WIDTH-1:0] mem [0:WORD_DEPTH-1];

    wire [WORD_ADDR_WIDTH-1:0] add_w;
    wire [WORD_ADDR_WIDTH-1:0] add_w_b;

    assign add_w   = addr[ADDR_WIDTH-1:2];
    assign add_w_b = addr_b[ADDR_WIDTH-1:2];

    integer i;

    initial begin
        for (i = 0; i < WORD_DEPTH; i = i + 1) begin
            mem[i] = {DATA_WIDTH{1'b0}};
        end

        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, mem);
        end
    end

    // 异步读：与你当前单周期 CPU 兼容
    assign dout   = mem[add_w];
    assign dout_b = mem[add_w_b];

    // 合并写口，避免同一个 mem 被两个 always 写。
    // Debug 端优先。后面 UART 写内存时，请暂停 CPU。
    always @(posedge clk) begin
        if (we_b) begin
            if (byte_b[0]) mem[add_w_b][7:0]   <= din_b[7:0];
            if (byte_b[1]) mem[add_w_b][15:8]  <= din_b[15:8];
            if (byte_b[2]) mem[add_w_b][23:16] <= din_b[23:16];
            if (byte_b[3]) mem[add_w_b][31:24] <= din_b[31:24];
        end else if (we) begin
            if (byte[0]) mem[add_w][7:0]   <= din[7:0];
            if (byte[1]) mem[add_w][15:8]  <= din[15:8];
            if (byte[2]) mem[add_w][23:16] <= din[23:16];
            if (byte[3]) mem[add_w][31:24] <= din[31:24];
        end
    end

    // wire unused_rst_n;
    // assign unused_rst_n = rst_n;

endmodule