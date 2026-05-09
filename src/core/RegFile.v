module RegFile (
    input wire clk,
    input wire rst_n,
    input wire we,
    input wire [4:0] raddr1,
    input wire [4:0] raddr2,
    input wire [4:0] waddr,
    input wire [31:0] wdata,
    input [31:0] RamDout,// Data read from memory used for load instructions
    input wire [6:0] opcode,
    input wire [2:0] func3,
    input MemtoReg,
    output reg [31:0] rdata1,
    output reg [31:0] rdata2
);

    reg [31:0] register [0:31];
    integer i;

    always @(*) begin
        //sb
        if (opcode == 7'b0100011 && func3 == 3'b000) begin
            rdata2 = {{24{register[raddr2][7]}},register[raddr2][7:0]};
        end
        //sh
        else if (opcode == 7'b0100011 && func3 == 3'b001) begin
            rdata2 = {{16{register[raddr2][15]}},register[raddr2][15:0]};
        end
        //sw
        else begin
            rdata1 = register[raddr1];
            rdata2 = register[raddr2];
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 32; i = i + 1) begin
                register[i] <= 32'b0;
            end
        end else if (we && (waddr != 5'b0)) begin
            if (MemtoReg) begin
                    //lb
                    if (opcode == 7'b0000011 && func3 == 3'b000) begin
                        register[waddr] <= {{24{RamDout[7]}}, RamDout[7:0]};
                    end
                    //lh
                    else if (opcode == 7'b0000011 && func3 == 3'b001) begin
                        register[waddr] <= {{16{RamDout[15]}}, RamDout[15:0]};
                    end
                    //lbu
                    else if (opcode == 7'b0000011 && func3 == 3'b100) begin
                        register[waddr] <= {{24{1'b0}}, RamDout[7:0]};
                    end
                    //lhu
                    else if (opcode == 7'b0000011 && func3 == 3'b101) begin
                        register[waddr] <= {{16{1'b0}}, RamDout[15:0]};
                    end
                    else begin
                        register[waddr] <= RamDout;
                    end    
                end
                else begin
                    //lb
                    if (opcode == 7'b0000011 && func3 == 3'b000) begin
                        register[waddr] <= {{24{wdata[7]}}, wdata[7:0]};
                    end
                    //lh
                    else if (opcode == 7'b0000011 && func3 == 3'b001) begin
                        register[waddr] <= {{16{wdata[15]}}, wdata[15:0]};
                    end
                    //lbu
                    else if (opcode == 7'b0000011 && func3 == 3'b100) begin
                        register[waddr] <= {{24{1'b0}}, wdata[7:0]};
                    end
                    //lhu
                    else if (opcode == 7'b0000011 && func3 == 3'b101) begin
                        register[waddr] <= {{16{1'b0}}, wdata[15:0]};
                    end
                    else begin
                        register[waddr] <= wdata;
                    end
                end
        end
    end

endmodule