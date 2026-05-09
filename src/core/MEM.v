module MEM (
    input wire clk,
    input wire rst_n,
    input wire mem_we,
    input wire mem_re,
    input wire [31:0] addr,// Address from CPU
    input wire [31:0] wdata,// Data to write to memory
    input wire [3:0] wstrb,// Write strobe for byte-enable
    output wire [31:0] rdata// Data read from memory
);

    assign rdata = mem_re ? wdata : 32'b0;

endmodule