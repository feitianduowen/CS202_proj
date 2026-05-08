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

    assign rdata = mem_re ? mem_rdata : 32'b0;

endmodule