module BoardOutput (
    input wire clk,
    input wire rst_n,
    input wire [31:0] pc_dbg,
    input wire [31:0] wb_dbg,
    input wire [31:0] reg_dbg,
    input wire [7:0] led_data,
    input wire [7:0] small_led_data,
    input wire [7:0] tube_scan_data,
    input wire [7:0] tube_left_data,
    input wire [7:0] tube_right_data,
    output wire [7:0] tube_scan,
    output wire [7:0] tube_signal_left,
    output wire [7:0] tube_signal_right,
    output wire [7:0] led,
    output wire [7:0] small_led
);

    assign tube_scan = tube_scan_data;
    assign tube_signal_left = tube_left_data;
    assign tube_signal_right = tube_right_data;
    assign led = led_data;
    assign small_led = small_led_data;

endmodule