module BoardInput (
    input wire clk,
    input wire rst_n,
    input wire finish,
    input wire start_pg,
    input wire [7:0] switch,
    input wire [7:0] small_switch,
    output reg [31:0] input_data,
    output reg cpu_reset,
    output reg cpu_run,
    output reg cpu_step
);

    always @(*) begin
        input_data = {small_switch, switch, 16'b0};
        cpu_reset = ~rst_n;
        cpu_run = start_pg;
        cpu_step = finish;
    end

endmodule