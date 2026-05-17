`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/05/16 20:01:50
// Design Name: 
// Module Name: keyboard_led_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module keyboard_led_top(
    input clk,
    input rst_n,
    input ps2_clk,
    input ps2_data,
    output [15:0] led
);
    wire scan_valid;
    wire [7:0] scan_code;
    wire frame_error;
    wire key_valid;
    wire key_release;
    wire key_extend;
    wire [7:0] key_code;

    ps2_rx u_ps2_rx(
        .clk(clk),
        .rst_n(rst_n),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .scan_valid(scan_valid),
        .scan_code(scan_code),
        .frame_error(frame_error)
    );

    key_event u_key_event(
        .clk(clk),
        .rst_n(rst_n),
        .scan_valid(scan_valid),
        .scan_code(scan_code),
        .key_valid(key_valid),
        .key_release(key_release),
        .key_extend(key_extend),
        .key_code(key_code)
    );

    led_ctrl u_led_ctrl(
        .clk(clk),
        .rst_n(rst_n),
        .key_valid(key_valid),
        .key_release(key_release),
        .key_extend(key_extend),
        .key_code(key_code),
        .led(led)
    );
endmodule
