module Ram (
    input wire clk,
    input wire we,
    input wire [3:0] wstrb,
    input wire [31:0] addr,
    input wire [31:0] wdata,
    output reg [31:0] rdata,
    input wire dbg_we,
    input wire [31:0] dbg_addr,
    input wire [31:0] dbg_wdata,
    output reg [31:0] dbg_rdata
);

    reg [31:0] mem [0:8191];
    integer i;
    wire [12:0] word_addr;
    wire [12:0] dbg_word_addr;

    assign word_addr = addr[14:2];
    assign dbg_word_addr = dbg_addr[14:2];

    always @(posedge clk) begin
        if (we) begin
            if (wstrb[0]) mem[word_addr][7:0] <= wdata[7:0];
            if (wstrb[1]) mem[word_addr][15:8] <= wdata[15:8];
            if (wstrb[2]) mem[word_addr][23:16] <= wdata[23:16];
            if (wstrb[3]) mem[word_addr][31:24] <= wdata[31:24];
        end

        if (dbg_we) begin
            mem[dbg_word_addr] <= dbg_wdata;
        end
    end

    always @(*) begin
        rdata = mem[word_addr];
        dbg_rdata = mem[dbg_word_addr];
    end

    initial begin
        for (i = 0; i < 8192; i = i + 1) begin
            mem[i] = 32'b0;
        end
    end

endmodule