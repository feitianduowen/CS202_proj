module UartDebug (
    input wire clk,
    input wire rst_n,
    input wire rx,
    output wire tx,
    input wire [31:0] pc,
    input wire [31:0] reg_data,
    input wire [31:0] imem_rdata,
    input wire [31:0] dmem_rdata,
    output reg cpu_reset,
    output reg cpu_run,
    output reg cpu_step,
    output reg imem_we,
    output reg dmem_we,
    output reg [31:0] dbg_addr,
    output reg [31:0] dbg_wdata
);

    assign tx = 1'b1;

    always @(*) begin
        cpu_reset = 1'b0;
        cpu_run = 1'b0;
        cpu_step = 1'b0;
        imem_we = 1'b0;
        dmem_we = 1'b0;
        dbg_addr = 32'b0;
        dbg_wdata = 32'b0;
    end

endmodule