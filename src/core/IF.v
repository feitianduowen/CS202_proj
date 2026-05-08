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

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 32'b0;
        end else if (we) begin
            pc <= pc_next;
        end
    end

    assign inst_addr = pc;
    assign inst = inst_rdata;

endmodule