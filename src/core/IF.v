module IF (
    input wire clk,
    input wire rst_n,
    input wire pc_we,   // from control unit, indicates whether to update the PC
    input stop_flag,       // ecall
    input jump_flag,       // from EX stage, indicates whether the current instruction is a jump/branch instruction and should update the PC
    input [31:0] ALURes,    // jump address
    output reg [31:0] pc_out,
    output wire [31:0] inst_addr,
    output wire [31:0] inst
);
    reg [31:0] pc_next;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_out <= 32'b0;
        end else if (pc_we) begin
            pc_out <= pc_next;
        end
    end

    always @* begin
        if (stop_flag == 1) begin
            pc_next = pc_out;
        end else if (jump_flag == 1) begin
            pc_next = ALURes;
        end else begin
            pc_next = pc_out + 4;
        end
    end

endmodule