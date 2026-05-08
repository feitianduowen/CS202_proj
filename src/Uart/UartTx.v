module UartTx (
    input wire clk,
    input wire rst_n,
    input wire [7:0] data,
    input wire valid,
    output wire tx,
    output wire ready
);

    assign tx = 1'b1;
    assign ready = 1'b1;

endmodule