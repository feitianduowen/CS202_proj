module UartRx (
    input wire clk,
    input wire rst_n,
    input wire rx,
    output wire [7:0] data,
    output wire valid
);

    assign data = 8'b0;
    assign valid = 1'b0;

endmodule