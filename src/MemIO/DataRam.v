module DatatRam #(
    parameter ADDR_WIDTH = 14,
    parameter DATA_WIDTH = 32,
    parameter INIT_FILE  = ""
)(
    input wire clk,
    input wire rst_n,

    input wire we,
    input wire [31:0] addr,
    input wire [31:0] din,
    output wire [31:0] dout,
    input  wire [3:0]  byte,
    
    input  wire        we_b,
    input  wire [31:0] addr_b,
    output wire [31:0] dout_b,
    input  wire [31:0] din_b,
    input  wire [3:0]  byte_b

);

    (* ram_style = "block" *)reg [DATA_WIDTH-1:0] mem [0:(1<<(ADDR_WIDTH-2))-1];

    initial begin
        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, mem);
        end
    end
    
    wire [ADDR_WIDTH-3:0] add_w = addr[ADDR_WIDTH-1:2];
    wire [ADDR_WIDTH-3:0] add_w_b = addr_b[ADDR_WIDTH-1:2];

    assign dout = mem[add_w];
    assign dout_b = mem[add_w_b];

    always @(posedge clk) begin
        if (we) begin
            if(byte[0]) mem[add_w][7:0]   <= din[7:0];
            if(byte[1]) mem[add_w][15:8]  <= din[15:8];
            if(byte[2]) mem[add_w][23:16] <= din[23:16];
            if(byte[3]) mem[add_w][31:24] <= din[31:24];
        end
    end

    always @(posedge clk) begin
        if (we_b) begin
            if(byte_b[0]) mem[add_w_b][7:0]   <= din_b[7:0];
            if(byte_b[1]) mem[add_w_b][15:8]  <= din_b[15:8];
            if(byte_b[2]) mem[add_w_b][23:16] <= din_b[23:16];
            if(byte_b[3]) mem[add_w_b][31:24] <= din_b[31:24];
        end
    end

endmodule