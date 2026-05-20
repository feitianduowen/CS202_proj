module DatatRam #(
    parameter ADDR_WIDTH = 14,
    parameter DATA_WIDTH = 32,
    parameter INIT_FILE = "data.mem"
)(
    input  wire clk,
    input  wire rst_n,
    // CPU port
    input  wire we,
    input  wire [ADDR_WIDTH-1:0] addr,
    input  wire [31:0] din,
    input  wire [3:0] byte,
    output reg  [31:0] dout,

    // Debug port
    input  wire we_b,
    input  wire [ADDR_WIDTH-1:0] addr_b,
    input  wire [31:0] din_b,
    input  wire [3:0] byte_b,
    output reg  [31:0] dout_b
);

localparam WORD_ADDR_WIDTH = ADDR_WIDTH - 2;
localparam WORD_DEPTH = 1 << WORD_ADDR_WIDTH;

(* ram_style = "block" *)
reg [31:0] mem [0:WORD_DEPTH-1];

wire [WORD_ADDR_WIDTH-1:0] add_w   = addr[ADDR_WIDTH-1:2];
wire [WORD_ADDR_WIDTH-1:0] add_w_b = addr_b[ADDR_WIDTH-1:2];

integer i;
initial begin
    for (i = 0; i < WORD_DEPTH; i = i + 1)
        mem[i] = 32'b0;

    if (INIT_FILE != "")
        $readmemh(INIT_FILE, mem);
end

// Port A: CPU
always @(posedge clk) begin
    if (we) begin
        if (byte[0]) mem[add_w][7:0]   <= din[7:0];
        if (byte[1]) mem[add_w][15:8]  <= din[15:8];
        if (byte[2]) mem[add_w][23:16] <= din[23:16];
        if (byte[3]) mem[add_w][31:24] <= din[31:24];
    end

    dout <= mem[add_w];
end

// Port B: Debug
always @(posedge clk) begin
    if (we_b) begin
        if (byte_b[0]) mem[add_w_b][7:0]   <= din_b[7:0];
        if (byte_b[1]) mem[add_w_b][15:8]  <= din_b[15:8];
        if (byte_b[2]) mem[add_w_b][23:16] <= din_b[23:16];
        if (byte_b[3]) mem[add_w_b][31:24] <= din_b[31:24];
    end

    dout_b <= mem[add_w_b];
end

wire unused_rst_n;
assign unused_rst_n = rst_n;

endmodule