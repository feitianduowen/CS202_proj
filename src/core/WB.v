module WB (
    input wire [31:0] alu_y,
    input wire [31:0] mem_rdata,
    input wire [31:0] fp_result,
    input wire [31:0] pc4,
    input wire [1:0] wb_sel,

    input wire fp_wb_sel,
    input wire fp_we,

    output reg [31:0] wb_data,
    output reg [31:0] fp_wb_data
);

    always @(*) begin
        case (wb_sel)
            2'b00: wb_data = alu_y;
            2'b01: wb_data = mem_rdata;
            2'b10: wb_data = pc4;
            default: wb_data = alu_y;
        endcase
    end

    always @(*) begin
        if (fp_we) begin
            case (fp_wb_sel)
                1'b0: fp_wb_data = fp_result;
                1'b1: fp_wb_data = mem_rdata;
            endcase
        end else begin
            fp_wb_data = 32'd0;
        end
    end

endmodule