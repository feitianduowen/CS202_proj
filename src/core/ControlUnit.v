module ControlUnit (
    input wire [6:0] opcode,
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    output reg [3:0] alu_op,// 0: ADD, 1: SUB, 2: AND, 3: OR, 4: XOR, 5: SLL, 6: SRL, 7: SRA, 8: SLT, 9: SLTU
    output reg [1:0] wb_sel,// 0: ALU result, 1: Memory data, 2: PC+4, 3: Immediate
    output reg reg_we,
    output reg mem_we,
    output reg mem_re,
    output reg alu_src,
    output reg branch,
    output reg jal,
    output reg jalr,
    output reg lui,
    output reg auipc,
    output reg [2:0] imm_type// 0: I-type, 1: S-type, 2: B-type, 3: U-type, 4: J-type
);

    always @(*) begin
        alu_op = 4'b0000;
        wb_sel = 2'b00;
        reg_we = 1'b0;
        mem_we = 1'b0;
        mem_re = 1'b0;
        alu_src = 1'b0;
        branch = 1'b0;
        jal = 1'b0;
        jalr = 1'b0;
        lui = 1'b0;
        auipc = 1'b0;
        imm_type = 3'b000;

        case (opcode)
            7'b0110011: begin// R-type ALU
                reg_we = 1'b1;
                wb_sel = 2'b00;
                alu_op = {funct7[5], funct3};
            end
            7'b0010011: begin// I-type ALU
                reg_we = 1'b1;
                alu_src = 1'b1;
                wb_sel = 2'b00;
                imm_type = 3'b000;
                alu_op = {1'b0, funct3};
            end
            7'b0000011: begin// Load
                reg_we = 1'b1;
                mem_re = 1'b1;
                alu_src = 1'b1;
                wb_sel = 2'b01;
                imm_type = 3'b000;
                alu_op = 4'b0000;
            end
            7'b0100011: begin// Store
                mem_we = 1'b1;
                alu_src = 1'b1;
                imm_type = 3'b001;
                alu_op = 4'b0000;
            end
            7'b1100011: begin// Branch
                branch = 1'b1;
                imm_type = 3'b010;
                alu_op = 4'b1000;
            end
            7'b1101111: begin// JAL
                reg_we = 1'b1;
                jal = 1'b1;
                wb_sel = 2'b10;
                imm_type = 3'b100;
            end
            7'b1100111: begin// JALR
                reg_we = 1'b1;
                jalr = 1'b1;
                alu_src = 1'b1;
                wb_sel = 2'b10;
                imm_type = 3'b000;
            end
            7'b0110111: begin// LUI
                reg_we = 1'b1;
                lui = 1'b1;
                wb_sel = 2'b11;
                imm_type = 3'b011;
            end
            7'b0010111: begin// AUIPC
                reg_we = 1'b1;
                auipc = 1'b1;
                wb_sel = 2'b11;
                imm_type = 3'b011;
            end
            default: begin
            end
        endcase
    end

endmodule