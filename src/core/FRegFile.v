module FRegFile (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        we,

    input  wire [4:0]  raddr1,
    input  wire [4:0]  raddr2,
    input  wire [4:0]  waddr,
    input  wire [31:0] wdata,

    output wire [31:0] rdata1,
    output wire [31:0] rdata2,

    // Debug read port
    input  wire [4:0]  dbg_reg_addr,
    output wire [31:0] dbg_reg_data
);

    reg [31:0] regs [0:31];
    integer i;

    assign rdata1 = regs[raddr1];
    assign rdata2 = regs[raddr2];

    assign dbg_reg_data = regs[dbg_reg_addr];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'd0;
        end else begin
            if (we)
                regs[waddr] <= wdata;
        end
    end

endmodule