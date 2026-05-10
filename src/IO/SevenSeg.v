module SevenSeg (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] data,

    output reg  [7:0]  tube_scan,
    output reg  [7:0]  tube_signal_left,
    output reg  [7:0]  tube_signal_right
);

    // ============================================================
    // Refresh counter
    // ============================================================
    // assume clk 100MHz
    // refresh_cnt[16:14]  8
    // f:
    // 100MHz / 2^17 / 8 ≈ 95Hz
    // ============================================================

    reg [16:0] refresh_cnt;
    wire [2:0] scan_idx;

    assign scan_idx = refresh_cnt[16:14];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            refresh_cnt <= 17'b0;
        end else begin
            refresh_cnt <= refresh_cnt + 17'd1;
        end
    end

    // ============================================================
    // Select current hex digit
    // ============================================================

    reg [3:0] cur_hex;

    always @(*) begin
        case (scan_idx)
            3'd0: cur_hex = data[3:0];
            3'd1: cur_hex = data[7:4];
            3'd2: cur_hex = data[11:8];
            3'd3: cur_hex = data[15:12];
            3'd4: cur_hex = data[19:16];
            3'd5: cur_hex = data[23:20];
            3'd6: cur_hex = data[27:24];
            3'd7: cur_hex = data[31:28];
            default: cur_hex = 4'h0;
        endcase
    end

    // ============================================================
    // Hex to 7-segment decoder
    // ============================================================
    // Assume return format
    // {dp, g, f, e, d, c, b, a}
    //
    // low active:
    // 0 -> on, 1 -> off
    // ============================================================

    function [7:0] hex_to_seg;
        input [3:0] hex;
        begin
            case (hex)
                4'h0: hex_to_seg = 8'b1100_0000;
                4'h1: hex_to_seg = 8'b1111_1001;
                4'h2: hex_to_seg = 8'b1010_0100;
                4'h3: hex_to_seg = 8'b1011_0000;
                4'h4: hex_to_seg = 8'b1001_1001;
                4'h5: hex_to_seg = 8'b1001_0010;
                4'h6: hex_to_seg = 8'b1000_0010;
                4'h7: hex_to_seg = 8'b1111_1000;
                4'h8: hex_to_seg = 8'b1000_0000;
                4'h9: hex_to_seg = 8'b1001_0000;
                4'hA: hex_to_seg = 8'b1000_1000;
                4'hB: hex_to_seg = 8'b1000_0011;
                4'hC: hex_to_seg = 8'b1100_0110;
                4'hD: hex_to_seg = 8'b1010_0001;
                4'hE: hex_to_seg = 8'b1000_0110;
                4'hF: hex_to_seg = 8'b1000_1110;
                default: hex_to_seg = 8'b1111_1111;
            endcase
        end
    endfunction

    // ============================================================
    // Scan output
    // ============================================================
    // Assume:
    // scan_idx 0~3 -> right 4
    // scan_idx 4~7 -> left 4
    //
    // tube_scan low active currently scanning tube
    // ============================================================

    always @(*) begin
        tube_scan = ~(8'b0000_0001 << scan_idx);

        tube_signal_left  = 8'hFF;
        tube_signal_right = 8'hFF;

        if (scan_idx < 3'd4) begin
            tube_signal_right = hex_to_seg(cur_hex);
            tube_signal_left  = 8'hFF;
        end else begin
            tube_signal_left  = hex_to_seg(cur_hex);
            tube_signal_right = 8'hFF;
        end
    end

endmodule