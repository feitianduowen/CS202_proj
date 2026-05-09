module ControlUnit (
    input wire [6:0] opcode,
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    output reg [3:0] alu_op,// 0: ADD, 1: SUB, 2: AND, 3: OR, 4: XOR, 5: SLL, 6: SRL, 7: SRA, 8: SLT, 9: SLTU
    output reg reg_we,
    output reg mem_we,
    output reg mem_re,
    output reg MemtoReg,
    output reg alu_src,
    output reg jal,
    output reg jalr,
    output reg lui,
    output reg auipc,

    output reg branch
);

    always @(*) begin
        alu_op = 4'b0000;
        reg_we = 1'b0;
        mem_we = 1'b0;
        mem_re = 1'b0;
        MemtoReg = 1'b0;
        alu_src = 1'b0;
        jal = 1'b0;
        jalr = 1'b0;
        lui = 1'b0;
        auipc = 1'b0;
        branch = 1'b0;

        case (opcode)
            7'b0110011: begin// R-type ALU
                reg_we = 1'b1;
                case(funct3)
                    3'b000 : alu_op = (funct7 == 7'b0000000) ? 4'b0000 : 4'b0001; //add or sub
                    3'b100 : alu_op = 4'b0110; //xor
                    3'b110 : alu_op = 4'b0101; //or
                    3'b111 : alu_op = 4'b0100; //and
                    3'b001 : alu_op = 4'b1100; //sll
                    3'b101 : alu_op = (funct7 == 7'b0000000) ? 4'b1101 : 4'b1110; //srl or sra
                    3'b010 : alu_op = 4'b1000; //slt
                    3'b011 : alu_op = 4'b1001; //sltu
                    default: ;
                endcase
            end
            7'b0010011: begin// I-type ALU
                reg_we = 1'b1;
                alu_src = 1'b1;
                case(funct3)
                3'b000 : alu_op = 4'b0000; //addi
                3'b100 : alu_op = 4'b0110; //xori
                3'b110 : alu_op = 4'b0101; //ori
                3'b111 : alu_op = 4'b0100; //andi
                3'b001 : alu_op = 4'b1100; //slli
                3'b101 : alu_op = (funct7 == 7'b0000000) ? 4'b1101 : 4'b1110; //srli or srai
                3'b010 : alu_op = 4'b1000; //slti
                3'b011 : alu_op = 4'b1001; //sltiu
                default: ;
                endcase
            end
            7'b0000011: begin// Load
                reg_we = 1'b1;
                mem_re = 1'b1;
                alu_src = 1'b1;
                MemtoReg = 1'b1;
            end
            7'b0100011: begin// Store
                mem_we = 1'b1;
                alu_src = 1'b1;
            end
            7'b1100011: begin// Branch
                branch = 1'b1;
                alu_op=4'b0011;
            end
            7'b1101111: begin// JAL
                reg_we = 1'b1;
                jal = 1'b1;
                alu_op= 4'b0011;
            end
            7'b1100111: begin// JALR
                reg_we = 1'b1;
                jalr = 1'b1;
                alu_op = 4'b0011;
            end
            7'b0110111: begin// LUI
                reg_we = 1'b1;
                alu_op = 4'b0111;
                lui=1;
            end
            7'b0010111: begin// AUIPC
                reg_we = 1'b1;
                auipc = 1;
                alu_op=4'b1010;
            end
            7'b1110011: begin//ECALL
                reg_we = 1'b1;
            end
            default: begin
            end
        endcase
    end

endmodule