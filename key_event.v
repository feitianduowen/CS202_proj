`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/05/16 20:01:50
// Design Name: 
// Module Name: key_event
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


module key_event(
    input clk,
    input rst_n,
    input scan_valid,
    input [7:0] scan_code,
    output reg key_valid,
    output reg key_release,
    output reg key_extend,
    output reg [7:0] key_code
);
    reg break_flag;
    reg extend_flag;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            break_flag <= 1'b0;
            extend_flag <= 1'b0;
            key_valid <= 1'b0;
            key_release <= 1'b0;
            key_extend <= 1'b0;
            key_code <= 8'b0;
        end else begin
            key_valid <= 1'b0;
            key_release <= 1'b0;
            key_extend <= 1'b0;
            if(scan_valid) begin
                if(scan_code == 8'hE0) begin
                    extend_flag <= 1'b1;
                end else if(scan_code == 8'hF0) begin
                    break_flag <= 1'b1;
                end else begin
                    key_valid <= 1'b1;
                    key_release <= break_flag;
                    key_extend <= extend_flag;
                    key_code <= scan_code;
                    break_flag <= 1'b0;
                    extend_flag <= 1'b0;
                end
            end
        end
    end
endmodule
