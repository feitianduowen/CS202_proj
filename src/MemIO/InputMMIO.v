module InputMMIO (
    input wire [31:0] addr,
    input wire [7:0] switch,
    input wire [7:0] small_switch,
    input wire finish,
    input wire start_pg,
    output reg [31:0] rdata
);

    always @(*) begin
        case (addr[3:0])
            4'h0: rdata = {16'b0, small_switch, switch};
            4'h4: rdata = {30'b0, start_pg, finish};
            default: rdata = 32'b0;
        endcase
    end

endmodule