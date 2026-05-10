module MMIO (
    input wire clk,
    input wire rst_n,

    // ============================================================
    // CPU memory bus
    // ============================================================
    input  wire        cpu_we,
    input  wire        cpu_re,
    input  wire [31:0] cpu_addr,
    input  wire [31:0] cpu_wdata,
    input  wire [3:0]  cpu_wstrb,
    output wire [31:0] cpu_rdata,

    // ============================================================
    // DataRam side
    // ============================================================
    output wire        ram_we,
    output wire        ram_re,
    output wire [31:0] ram_addr,
    output wire [31:0] ram_wdata,
    output wire [3:0]  ram_wstrb,
    input  wire [31:0] ram_rdata,

    // ============================================================
    // Board IO
    // ============================================================
    input  wire [7:0]  switch,
    output wire [7:0]  LED
);

    // MMIO base address = 0xFFFF0000
    // 0xFFFF0000: switch, read only
    // 0xFFFF0008: LED, write/read
    localparam [31:0] MMIO_SWITCH_ADDR = 32'hFFFF_0000;
    localparam [31:0] MMIO_LED_ADDR    = 32'hFFFF_0008;

    reg [7:0] led_reg;

    wire is_switch_addr;
    wire is_led_addr;
    wire is_mmio_addr;

    assign is_switch_addr = (cpu_addr == MMIO_SWITCH_ADDR);
    assign is_led_addr    = (cpu_addr == MMIO_LED_ADDR);
    assign is_mmio_addr   = is_switch_addr | is_led_addr;

    // LED always show 0xFFFF0008's value
    assign LED = led_reg;

    // ============================================================
    // RAM side
    // ============================================================
    // if visit MMIO address, shoudn't visit normal DataRam.
    // only visit normal Dataram, send the visit to DataRam.
    // ============================================================

    assign ram_we    = cpu_we & ~is_mmio_addr;
    assign ram_re    = cpu_re & ~is_mmio_addr;
    assign ram_addr  = cpu_addr;
    assign ram_wdata = cpu_wdata;
    assign ram_wstrb = cpu_wstrb;

    // ============================================================
    // CPU read data
    // ============================================================
    // lw x1, 0(x31), x31 = 0xFFFF0000
    // => cpu_rdata = {24'b0, switch}
    //
    // lw x1, 8(x31)
    // => cpu_rdata = {24'b0, led_reg}
    //
    // other addresses
    // => cpu_rdata = ram_rdata
    // ============================================================

    assign cpu_rdata =
        is_switch_addr ? {24'b0, switch}  :
        is_led_addr    ? {24'b0, led_reg} :
                         ram_rdata;

    // ============================================================
    // CPU write MMIO
    // ============================================================
    // sw x1, 8(x31), x31 = 0xFFFF0000
    // => led_reg <= cpu_wdata[7:0]
    //
    // write 0xFFFF0000 is ineffective, switch is output, read only
    // ============================================================

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            led_reg <= 8'b0;
        end else begin
            if (cpu_we && is_led_addr) begin
                if (cpu_wstrb[0]) begin
                    led_reg <= cpu_wdata[7:0];
                end
            end
        end
    end

endmodule