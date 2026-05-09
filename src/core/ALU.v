module ALU (
    input wire [31:0] a,
    input wire [31:0] b,
    input [2:0] funct3,
    input [31:0] imme,
    input [31:0] pc_out,
    input ALUSrc,// 0: register, 1: immediate
    input branch,
    input jal,
    input jalr,
    input wire [3:0] alu_op,
    output reg [31:0] y,// ALU result
    output reg jump_flag
);
    reg [31:0] operand2;
    reg [31:0] Address_result;
    reg branch_result;

    always @* begin
        case(ALUSrc)
            1'b0 : operand2 = b;
            1'b1 : operand2 = imme; 
        endcase
    end

    always @* begin
        if(branch)begin
            Address_result = $signed(imme) + $signed(pc_out);
        end

        if(jal || jalr)begin
            branch_result = 1;
            if(jal)begin
                Address_result = $signed(imme)&32'hfffffffe + $signed(pc_out);
            end
            else if(jalr)begin
                Address_result = ($signed(a) + $signed(imme)&32'hfffffffe);
            end
        
        end
    end



    always @(*) begin
        case (alu_op)
            4'b0000: y = $signed(a) + $signed(operand2);
            4'b0001: y = $signed(a) - $signed(operand2);
            4'b0100: y = a & operand2;
            4'b0101: y = a | operand2;
            4'b0110: y = a ^ operand2;
            4'b1100: y = a << operand2[4:0];
            4'b1101: y = a >> operand2[4:0];
            4'b1110: y = $signed(a) >>> operand2[4:0];
            4'b1000: y = ($signed(a) < $signed(operand2)) ? {{31{1'b0}}, 1'b1} : 32'd0;
            4'b1001: y = (a < operand2) ? {{31{1'b0}}, 1'b1} : 32'h0;

            4'b0111 : y = imme; // lui
            4'b1010 : y = $signed(imme) + $signed(pc_out); // auipc

            4'b0011 ：begin
                case(funct3)
                    3'b000: branch_result = (a == b)? 1: 0; // beq
                    3'b001: branch_result = (a != b)? 1: 0; // bne
                    3'b100: branch_result = ($signed(a) < $signed(b))? 1: 0; // blt
                    3'b101: branch_result = ($signed(a) >= $signed(b))? 1: 0; // bge
                    3'b110: branch_result = (a < b)? 1: 0; // bltu
                    3'b111: branch_result = (a >= b)? 1: 0; // bgeu
                endcase
                y = Address_result
            end

            default: y = 32'h0;
        endcase
    end

    always @(*) begin
        if((branch && branch_result)||jal||jalr)begin
            jump_flag = 1;
        end
        else begin
            jump_flag = 0;
        end
    end


endmodule