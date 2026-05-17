`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/05/16 20:04:56
// Design Name: 
// Module Name: tb_keyboard_led_top
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


module tb_keyboard_led_top;
    reg clk;
    reg rst_n;
    reg ps2_clk;
    reg ps2_data;
    wire [15:0] led;

    keyboard_led_top dut(
        .clk(clk),
        .rst_n(rst_n),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .led(led)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task send_bit;
        input bit_value;
        begin
            ps2_data = bit_value;
            #2000;
            ps2_clk = 1'b0;
            #2000;
            ps2_clk = 1'b1;
            #2000;
        end
    endtask

    task send_byte;
        input [7:0] code;
        integer i;
        reg parity;
        begin
            parity = ~(^code);
            send_bit(1'b0);
            for(i = 0; i < 8; i = i + 1) begin
                send_bit(code[i]);
            end
            send_bit(parity);
            send_bit(1'b1);
            ps2_data = 1'b1;
            #20000;
        end
    endtask

    task key_press;
        input [7:0] code;
        begin
            send_byte(code);
        end
    endtask

    task key_release;
        input [7:0] code;
        begin
            send_byte(8'hF0);
            send_byte(code);
        end
    endtask

    initial begin
        rst_n = 1'b0;
        ps2_clk = 1'b1;
        ps2_data = 1'b1;
        #100;
        rst_n = 1'b1;
        #20000;

        key_press(8'h16);   // 1, LED0 toggle
        key_release(8'h16);
        #50000;

        key_press(8'h1E);   // 2, LED1 toggle
        key_release(8'h1E);
        #50000;

        key_press(8'h1C);   // A, all on
        key_release(8'h1C);
        #50000;

        key_press(8'h1B);   // S, all off
        key_release(8'h1B);
        #50000;

        key_press(8'h15);   // Q, LED8 toggle
        key_release(8'h15);
        #50000;

        $finish;
    end
endmodule
