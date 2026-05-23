module ImmGen (
    input wire [31:0] inst,
    output reg [31:0] imm
);

    always @(*) begin
        case (inst[6:0])
            7'b0000011: begin
                // I-type load
                imm = {{20{inst[31]}}, inst[31:20]};
            end

            7'b0000111: begin // flw (I-type load)
                imm = {{20{inst[31]}}, inst[31:20]};
            end

            7'b0010011: begin
                // I-type ALU
                if (inst[14:12] == 3'b001 || inst[14:12] == 3'b101) begin
                    imm = {27'b0, inst[24:20]};
                end else begin
                    imm = {{20{inst[31]}}, inst[31:20]};
                end
            end

            7'b1100111: begin
                // JALR, I-type
                imm = {{20{inst[31]}}, inst[31:20]};
            end

            7'b0100011: begin
                // S-type
                imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
            end

            7'b0100111: begin // fsw (S-type)
                imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
            end

            7'b1100011: begin
                // B-type
                imm = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
            end

            7'b0110111,
            7'b0010111: begin
                // LUI / AUIPC, U-type
                imm = {inst[31:12], 12'b0};
            end

            7'b1101111: begin
                // JAL, J-type
                imm = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
            end

            default: begin
                imm = 32'b0;
            end
        endcase
    end

endmodule