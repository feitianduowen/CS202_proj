module test_seg (
    input  wire clk_100,
    input  wire rst_n,

    output wire [7:0] tube_scan,
    output wire [7:0] tube_signal_left,
    output wire [7:0] tube_signal_right
);

    SevenSeg #(
        .SCAN_ACTIVE_HIGH(1),
        .SEG_ACTIVE_HIGH(1)
    ) u_seven_seg (
        .clk(clk_100),
        .rst_n(rst_n),
        .data(32'h12345678),

        .tube_scan(tube_scan),
        .tube_signal_left(tube_signal_left),
        .tube_signal_right(tube_signal_right)
    );

endmodule