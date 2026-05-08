module WB (
    input wire [31:0] alu_y,
    input wire [31:0] mem_rdata,
    input wire [31:0] pc4,
    input wire [31:0] u_res,
    input wire [1:0] wb_sel,
    output wire [31:0] wb_data
);

    WriteBackMux u_write_back_mux (
        .alu_y(alu_y),
        .mem_rdata(mem_rdata),
        .pc4(pc4),
        .u_res(u_res),
        .wb_sel(wb_sel),
        .wb_data(wb_data)
    );

endmodule