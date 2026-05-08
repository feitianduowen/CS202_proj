module IF (
    input wire clk,
    input wire rst_n,
    input wire pc_we,
    input wire [31:0] pc_next,
    input wire [31:0] inst_rdata,
    output wire [31:0] pc,
    output wire [31:0] inst_addr,
    output wire [31:0] inst
);

    PC u_pc (
        .clk(clk),
        .rst_n(rst_n),
        .we(pc_we),
        .pc_next(pc_next),
        .pc(pc)
    );

    assign inst_addr = pc;
    assign inst = inst_rdata;

endmodule