module DebugMux (
    input wire debug_en,
    input wire [31:0] cpu_addr,
    input wire [31:0] cpu_wdata,
    input wire cpu_we,
    input wire cpu_re,
    input wire [31:0] dbg_addr,
    input wire [31:0] dbg_wdata,
    input wire dbg_we,
    input wire dbg_re,
    output wire [31:0] addr,
    output wire [31:0] wdata,
    output wire we,
    output wire re
);

    assign addr = debug_en ? dbg_addr : cpu_addr;
    assign wdata = debug_en ? dbg_wdata : cpu_wdata;
    assign we = debug_en ? dbg_we : cpu_we;
    assign re = debug_en ? dbg_re : cpu_re;

endmodule