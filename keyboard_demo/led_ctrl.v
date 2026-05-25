`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/05/16 20:01:50
// Design Name: 
// Module Name: led_ctrl
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


module led_ctrl(
    input clk,
    input rst_n,
    input key_valid,
    input key_release,
    input key_extend,
    input [7:0] key_code,
    output reg [15:0] led
);
    reg [17:0] held;
    reg [4:0] cmd;

    always @(*) begin
        if(key_extend) begin
            cmd = 5'd31;
        end else begin
            case(key_code)
                8'h16: cmd = 5'd0;   // 1 -> LED0
                8'h1E: cmd = 5'd1;   // 2 -> LED1
                8'h26: cmd = 5'd2;   // 3 -> LED2
                8'h25: cmd = 5'd3;   // 4 -> LED3
                8'h2E: cmd = 5'd4;   // 5 -> LED4
                8'h36: cmd = 5'd5;   // 6 -> LED5
                8'h3D: cmd = 5'd6;   // 7 -> LED6
                8'h3E: cmd = 5'd7;   // 8 -> LED7
                8'h15: cmd = 5'd8;   // Q -> LED8
                8'h1D: cmd = 5'd9;   // W -> LED9
                8'h24: cmd = 5'd10;  // E -> LED10
                8'h2D: cmd = 5'd11;  // R -> LED11
                8'h2C: cmd = 5'd12;  // T -> LED12
                8'h35: cmd = 5'd13;  // Y -> LED13
                8'h3C: cmd = 5'd14;  // U -> LED14
                8'h43: cmd = 5'd15;  // I -> LED15
                8'h1C: cmd = 5'd16;  // A -> all on
                8'h1B: cmd = 5'd17;  // S -> all off
                default: cmd = 5'd31;
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            led <= 16'h0000;
            held <= 18'b0;
        end else if(key_valid && cmd < 5'd18) begin
            if(key_release) begin
                held[cmd] <= 1'b0;
            end else if(!held[cmd]) begin
                held[cmd] <= 1'b1;
                if(cmd < 5'd16) begin
                    led[cmd] <= ~led[cmd];
                end else if(cmd == 5'd16) begin
                    led <= 16'hFFFF;
                end else if(cmd == 5'd17) begin
                    led <= 16'h0000;
                end
            end
        end
    end
endmodule
