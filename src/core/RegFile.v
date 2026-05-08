module RegFile (
    input wire clk,
    input wire rst_n,
    input wire we,
    input wire [4:0] raddr1,
    input wire [4:0] raddr2,
    input wire [4:0] waddr,
    input wire [31:0] wdata,
    output wire [31:0] rdata1,
    output wire [31:0] rdata2,
    input wire [4:0] dbg_addr,
    output wire [31:0] dbg_data
);

    reg [31:0] regs [0:31];
    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 32; i = i + 1) begin
                regs[i] <= 32'b0;
            end
        end else if (we && (waddr != 5'b0)) begin
            regs[waddr] <= wdata;
        end
    end

    assign rdata1 = (raddr1 == 5'b0) ? 32'b0 : regs[raddr1];
    assign rdata2 = (raddr2 == 5'b0) ? 32'b0 : regs[raddr2];
    assign dbg_data = (dbg_addr == 5'b0) ? 32'b0 : regs[dbg_addr];

endmodule