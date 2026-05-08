module PC (
    input wire clk,
    input wire rst_n,
    input wire we,
    input wire [31:0] pc_next,
    output reg [31:0] pc
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 32'b0;
        end else if (we) begin
            pc <= pc_next;
        end
    end

endmodule