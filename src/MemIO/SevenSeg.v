module SevenSeg (
    input wire [31:0] data,
    output wire [7:0] tube_scan,
    output wire [7:0] tube_signal_left,
    output wire [7:0] tube_signal_right
);

    assign tube_scan = 8'hff;
    assign tube_signal_left = data[15:8];
    assign tube_signal_right = data[7:0];

endmodule