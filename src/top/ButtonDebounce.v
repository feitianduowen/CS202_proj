module ButtonDebounce (
    input  wire clk,
    input  wire btn_in,
    output reg  btn_posedge // 输出一个周期的脉冲
);
    reg [19:0] cnt;
    reg btn_d1, btn_d2, btn_stable;
    
    always @(posedge clk) begin
        btn_d1 <= btn_in;
        btn_d2 <= btn_d1;
        
        // 只有当按键状态稳定变化时才处理
        if (btn_d2 != btn_stable) begin
            cnt <= cnt + 1;
            if (cnt == 20'd1_000_000) begin // 10ms 消抖
                btn_stable <= btn_d2;
                if (btn_d2 == 1) btn_posedge <= 1; // 只有按下瞬间产生高电平
                cnt <= 0;
            end else begin
                btn_posedge <= 0;
            end
        end else begin
            cnt <= 0;
            btn_posedge <= 0;
        end
    end
endmodule