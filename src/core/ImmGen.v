module ImmGen (
    input wire [31:0] inst,
    output reg [31:0] imm
);  
    
    always @(inst) begin
        case (inst[6:0])
            7'b0000011: imm = {{20{inst[31]}}, inst[31:20]};// I-type load
            7'b0010011: begin // I-type ALU
                if (inst[14:12] == 3'b001 || inst[14:12] == 3'b101) begin
                    imm = {27'b0, inst[24:20]};// shift amount for SLLI, SRLI, SRAI
                end 
                else begin
                    imm = {{20{inst[31]}}, inst[31:20]}; // sign-extended immediate for other I-type instructions
                end
            end
            7'b0100011: imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};//S-type
            7'b1100011: imm = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};//B-type
            7'b0110111,7'b0010111: imm = {inst[31:12], 12'b0};//U-type
            7'b1101111: imm = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};//J-type
            default: imm = 32'b0;//R-type and other types
        endcase
    end

endmodule