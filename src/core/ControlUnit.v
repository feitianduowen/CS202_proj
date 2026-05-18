module ControlUnit (
    input wire [6:0] opcode,
    input wire [2:0] funct3,
    input wire [6:0] funct7,

    output reg [3:0] alu_op,
    output reg [1:0] wb_sel,

    output reg reg_we,
    output reg mem_we,
    output reg mem_re,
    output reg alu_src,

    output reg branch,
    output reg jal,
    output reg jalr,
    output reg lui,
    output reg auipc,
    output reg custom_en // 硬件加速指令标记
);

    localparam WB_ALU = 2'b00;
    localparam WB_MEM = 2'b01;
    localparam WB_PC4 = 2'b10;

    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_AND  = 4'b0100;
    localparam ALU_OR   = 4'b0101;
    localparam ALU_XOR  = 4'b0110;
    localparam ALU_LUI  = 4'b0111;
    localparam ALU_SLT  = 4'b1000;
    localparam ALU_SLTU = 4'b1001;
    localparam ALU_AUIPC = 4'b1010;
    localparam ALU_SLL  = 4'b1100;
    localparam ALU_SRL  = 4'b1101;
    localparam ALU_SRA  = 4'b1110;

    always @(*) begin
        alu_op = ALU_ADD;
        wb_sel = WB_ALU;

        reg_we = 1'b0;
        mem_we = 1'b0;
        mem_re = 1'b0;
        alu_src = 1'b0;

        branch = 1'b0;
        jal = 1'b0;
        jalr = 1'b0;
        lui = 1'b0;
        auipc = 1'b0;
        custom_en = 1'b0;

        case (opcode)
            7'b0110011: begin
                // R-type
                reg_we = 1'b1;
                alu_src = 1'b0;
                wb_sel = WB_ALU;

                case (funct3)
                    3'b000: alu_op = (funct7 == 7'b0100000) ? ALU_SUB : ALU_ADD;
                    3'b001: alu_op = ALU_SLL;
                    3'b010: alu_op = ALU_SLT;
                    3'b011: alu_op = ALU_SLTU;
                    3'b100: alu_op = ALU_XOR;
                    3'b101: alu_op = (funct7 == 7'b0100000) ? ALU_SRA : ALU_SRL;
                    3'b110: alu_op = ALU_OR;
                    3'b111: alu_op = ALU_AND;
                    default: alu_op = ALU_ADD;
                endcase
            end

            7'b0010011: begin
                // I-type ALU
                reg_we = 1'b1;
                alu_src = 1'b1;
                wb_sel = WB_ALU;

                case (funct3)
                    3'b000: alu_op = ALU_ADD;   // ADDI
                    3'b001: alu_op = ALU_SLL;   // SLLI
                    3'b010: alu_op = ALU_SLT;   // SLTI
                    3'b011: alu_op = ALU_SLTU;  // SLTIU
                    3'b100: alu_op = ALU_XOR;   // XORI
                    3'b101: alu_op = (funct7 == 7'b0100000) ? ALU_SRA : ALU_SRL;
                    3'b110: alu_op = ALU_OR;    // ORI
                    3'b111: alu_op = ALU_AND;   // ANDI
                    default: alu_op = ALU_ADD;
                endcase
            end

            7'b0000011: begin
                // Load
                reg_we = 1'b1;
                mem_re = 1'b1;
                alu_src = 1'b1;
                alu_op = ALU_ADD;
                wb_sel = WB_MEM;
            end

            7'b0100011: begin
                // Store
                mem_we = 1'b1;
                alu_src = 1'b1;
                alu_op = ALU_ADD;
            end

            7'b1100011: begin
                // Branch
                branch = 1'b1;
                alu_src = 1'b0;
                alu_op = ALU_SUB;
            end

            7'b1101111: begin
                // JAL
                reg_we = 1'b1;
                jal = 1'b1;
                wb_sel = WB_PC4;
            end

            7'b1100111: begin
                // JALR
                reg_we = 1'b1;
                jalr = 1'b1;
                alu_src = 1'b1;
                wb_sel = WB_PC4;
            end

            7'b0110111: begin
                // LUI
                reg_we = 1'b1;
                lui = 1'b1;
                alu_src = 1'b1;
                alu_op = ALU_LUI;
                wb_sel = WB_ALU;
            end

            7'b0010111: begin
                // AUIPC
                reg_we = 1'b1;
                auipc = 1'b1;
                alu_src = 1'b1;
                alu_op = ALU_AUIPC;
                wb_sel = WB_ALU;
            end

            7'b1110011: begin
                // ECALL/EBREAK 暂时先不写寄存器
                reg_we = 1'b0;
            end

            7'b0001011: begin
                // 硬件加速指令
                reg_we = 1'b1;      // 要写寄存器
                alu_src = 1'b0;     // 用 rs2_data，不用立即数（实际只用 rs1）
                wb_sel = WB_ALU;    // 写回走 ALU 通路（实际上会被 EX 阶段 MUX 替换）
                custom_en = 1'b1;   // 标记为自定义指令
            end

            default: begin
                reg_we = 1'b0;
            end
        endcase
    end

endmodule