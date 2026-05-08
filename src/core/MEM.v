module MEM (
    input wire clk,
    input wire rst_n,
    input wire mem_we,
    input wire mem_re,
    input wire [31:0] addr,
    input wire [31:0] wdata,
    input wire [3:0] wstrb,
    output wire [31:0] rdata
);

    LoadStoreUnit u_load_store_unit (
        .clk(clk),
        .rst_n(rst_n),
        .mem_we(mem_we),
        .mem_re(mem_re),
        .addr(addr),
        .wdata(wdata),
        .wstrb(wstrb),
        .mem_rdata(32'b0),
        .rdata(rdata)
    );

endmodule