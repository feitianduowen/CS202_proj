module RegFile (
    input wire clk,
    input wire rst_n,
    input wire we,

    input wire [4:0] raddr1,
    input wire [4:0] raddr2,
    input wire [4:0] waddr,
    input wire [31:0] wdata,

    output wire [31:0] rdata1,
    output wire [31:0] rdata2
);

    reg [31:0] regs [0:31];
    integer i;

    assign rdata1 = (raddr1 == 5'b00000) ? 32'b0 : regs[raddr1];
    assign rdata2 = (raddr2 == 5'b00000) ? 32'b0 : regs[raddr2];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 32; i = i + 1) begin
                regs[i] <= 32'b0;
            end
        end else begin
            if (we && (waddr != 5'b00000)) begin
                regs[waddr] <= wdata;
            end
        end
    end

endmodule