module SevenSeg #(
    parameter SCAN_ACTIVE_HIGH = 1,
    parameter SEG_ACTIVE_HIGH  = 1
)(
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

    reg [17:0] refresh_cnt;
    wire [2:0] scan_idx;

    assign scan_idx = refresh_cnt[17:15];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            refresh_cnt <= 18'b0;
        end else begin
            refresh_cnt <= refresh_cnt + 18'd1;
        end
    end

    // ============================================================
    // Select current hex digit
    // scan_idx = 0 shows data[3:0], normally rightmost digit
    // scan_idx = 7 shows data[31:28], normally leftmost digit
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
    // Hex to segment
    //
    // Bit order:
    // {a, b, c, d, e, f, g, dp}
    //
    // raw pattern is high-active:
    // 1 = segment on
    // 0 = segment off
    // ============================================================

    function [7:0] hex_to_seg_raw;
        input [3:0] hex;
        begin
            case (hex)
                4'h0: hex_to_seg_raw = 8'b11111100;
                4'h1: hex_to_seg_raw = 8'b01100000;
                4'h2: hex_to_seg_raw = 8'b11011010;
                4'h3: hex_to_seg_raw = 8'b11110010;
                4'h4: hex_to_seg_raw = 8'b01100110;
                4'h5: hex_to_seg_raw = 8'b10110110;
                4'h6: hex_to_seg_raw = 8'b10111110;
                4'h7: hex_to_seg_raw = 8'b11100000;
                4'h8: hex_to_seg_raw = 8'b11111110;
                4'h9: hex_to_seg_raw = 8'b11110110;
                4'hA: hex_to_seg_raw = 8'b11101110;
                4'hB: hex_to_seg_raw = 8'b00111110;
                4'hC: hex_to_seg_raw = 8'b10011100;
                4'hD: hex_to_seg_raw = 8'b01111010;
                4'hE: hex_to_seg_raw = 8'b10011110;
                4'hF: hex_to_seg_raw = 8'b10001110;
                default: hex_to_seg_raw = 8'b00000000;
            endcase
        end
    endfunction

    wire [7:0] seg_raw;
    wire [7:0] seg_on;
    wire [7:0] seg_off;

    assign seg_raw = hex_to_seg_raw(cur_hex);
    assign seg_on  = SEG_ACTIVE_HIGH ? seg_raw : ~seg_raw;
    assign seg_off = SEG_ACTIVE_HIGH ? 8'h00 : 8'hFF;

    // ============================================================
    // Digit scan
    // raw one-hot:
    // scan_idx 0 -> tube_scan[0]
    // scan_idx 7 -> tube_scan[7]
    // ============================================================

    wire [7:0] scan_raw;
    wire [7:0] scan_on;

    assign scan_raw = 8'b0000_0001 << scan_idx;
    assign scan_on  = SCAN_ACTIVE_HIGH ? scan_raw : ~scan_raw;

    // ============================================================
    // Output
    //
    // scan_idx 0~3: right 4 digits
    // scan_idx 4~7: left 4 digits
    // ============================================================

    always @(*) begin
        tube_scan = scan_on;

        tube_signal_left  = seg_off;
        tube_signal_right = seg_off;

        if (scan_idx < 3'd4) begin
            tube_signal_right = seg_on;
            tube_signal_left  = seg_off;
        end else begin
            tube_signal_left  = seg_on;
            tube_signal_right = seg_off;
        end
    end

endmodule