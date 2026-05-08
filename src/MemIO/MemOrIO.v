module MemOrIO (
    input wire [31:0] addr,
    input wire [31:0] mem_rdata,
    input wire [31:0] io_rdata,
    input wire mem_sel,
    output wire [31:0] rdata
);

    assign rdata = mem_sel ? mem_rdata : io_rdata;

endmodule