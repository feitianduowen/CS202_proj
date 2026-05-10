module ButtonDebounce #(
    parameter DEBOUNCE_CYCLES = 1_000_000
)(
    input  wire clk,
    input  wire rst_n,
    input  wire btn_in,
    output reg  btn_posedge
);

    reg [31:0] cnt;
    reg btn_d1;
    reg btn_d2;
    reg btn_stable;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 32'd0;
            btn_d1 <= 1'b0;
            btn_d2 <= 1'b0;
            btn_stable <= 1'b0;
            btn_posedge <= 1'b0;
        end else begin
            btn_d1 <= btn_in;
            btn_d2 <= btn_d1;

            btn_posedge <= 1'b0;

            if (btn_d2 != btn_stable) begin
                if (cnt >= DEBOUNCE_CYCLES - 1) begin
                    cnt <= 32'd0;
                    btn_stable <= btn_d2;

                    if (btn_d2 == 1'b1) begin
                        btn_posedge <= 1'b1;
                    end
                end else begin
                    cnt <= cnt + 32'd1;
                end
            end else begin
                cnt <= 32'd0;
            end
        end
    end

endmodule