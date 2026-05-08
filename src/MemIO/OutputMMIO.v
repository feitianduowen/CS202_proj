module OutputMMIO (
    input wire clk,
    input wire rst_n,
    input wire we,
    input wire [31:0] addr,
    input wire [31:0] wdata,
    output reg [7:0] led_data,
    output reg [7:0] small_led_data,
    output reg [7:0] tube_left_data,
    output reg [7:0] tube_right_data
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            led_data <= 8'b0;
            small_led_data <= 8'b0;
            tube_left_data <= 8'b0;
            tube_right_data <= 8'b0;
        end else if (we) begin
            case (addr[3:0])
                4'h0: led_data <= wdata[7:0];
                4'h4: small_led_data <= wdata[7:0];
                4'h8: tube_left_data <= wdata[7:0];
                4'hc: tube_right_data <= wdata[7:0];
                default: begin
                end
            endcase
        end
    end

endmodule