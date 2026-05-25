`timescale 1ns / 1ps

module ps2_rx(
    input clk,
    input rst_n,
    input ps2_clk,
    input ps2_data,
    output reg scan_valid,
    output reg [7:0] scan_code,
    output reg frame_error
);
    reg [2:0] ps2_clk_sync;
    reg [2:0] ps2_data_sync;
    reg [9:0] frame;
    reg [3:0] cnt;

    wire ps2_clk_fall = ps2_clk_sync[2] & ~ps2_clk_sync[1];
    wire data_sample = ps2_data_sync[2];
    wire [7:0] data_byte = frame[8:1];
    wire parity_ok = ((^frame[8:1]) ^ frame[9]);

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            ps2_clk_sync <= 3'b111;
            ps2_data_sync <= 3'b111;
        end else begin
            ps2_clk_sync <= {ps2_clk_sync[1:0], ps2_clk};
            ps2_data_sync <= {ps2_data_sync[1:0], ps2_data};
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            scan_valid <= 1'b0;
            scan_code <= 8'b0;
            frame_error <= 1'b0;
            frame <= 10'b0;
            cnt <= 4'b0;
        end else begin
            scan_valid <= 1'b0;
            frame_error <= 1'b0;
            if(ps2_clk_fall) begin
                if(cnt == 4'd10) begin
                    if(frame[0] == 1'b0 && data_sample == 1'b1 && parity_ok) begin
                        scan_code <= data_byte;
                        scan_valid <= 1'b1;
                    end else begin
                        frame_error <= 1'b1;
                    end
                    cnt <= 4'b0;
                end else begin
                    frame[cnt] <= data_sample;
                    cnt <= cnt + 1'b1;
                end
            end
        end
    end
endmodule
