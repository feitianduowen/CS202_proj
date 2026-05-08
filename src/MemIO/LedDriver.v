module LedDriver (
    input wire [31:0] data,
    output wire [7:0] led_data,
    output wire [7:0] small_led_data
);

    assign led_data = data[7:0];
    assign small_led_data = data[15:8];

endmodule