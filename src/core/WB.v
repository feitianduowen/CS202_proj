module WB (
    input wire [31:0] alu_y,
    input wire [31:0] mem_rdata,
    input wire [31:0] pc4,
    input wire [1:0] wb_sel,

    output reg [31:0] wb_data
);

    always @(*) begin
        case (wb_sel)
            2'b00: wb_data = alu_y;
            2'b01: wb_data = mem_rdata;
            2'b10: wb_data = pc4;
            default: wb_data = alu_y;
        endcase
    end

endmodule