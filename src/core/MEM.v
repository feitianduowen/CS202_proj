module MEM (
    input wire mem_we,
    input wire mem_re,
    input wire [2:0] funct3,

    input wire [31:0] addr,
    input wire [31:0] store_data,
    input wire [31:0] dmem_rdata,

    output wire [31:0] dmem_addr,
    output reg [31:0] dmem_wdata,
    output reg [3:0] dmem_wstrb,
    output wire dmem_we,
    output wire dmem_re,

    output reg [31:0] load_data
);

    wire [7:0] selected_byte;
    wire [15:0] selected_half;

    assign dmem_addr = addr;
    assign dmem_we = mem_we;
    assign dmem_re = mem_re;

    assign selected_byte =
        (addr[1:0] == 2'b00) ? dmem_rdata[7:0]   :
        (addr[1:0] == 2'b01) ? dmem_rdata[15:8]  :
        (addr[1:0] == 2'b10) ? dmem_rdata[23:16] : dmem_rdata[31:24];

    assign selected_half = addr[1] ? dmem_rdata[31:16] : dmem_rdata[15:0];

    always @(*) begin
        dmem_wdata = 32'b0;
        dmem_wstrb = 4'b0000;

        if (mem_we) begin
            case (funct3)
                3'b000: begin
                    // SB
                    case (addr[1:0])
                        2'b00: begin
                            dmem_wstrb = 4'b0001;
                            dmem_wdata = {24'b0, store_data[7:0]};
                        end
                        2'b01: begin
                            dmem_wstrb = 4'b0010;
                            dmem_wdata = {16'b0, store_data[7:0], 8'b0};
                        end
                        2'b10: begin
                            dmem_wstrb = 4'b0100;
                            dmem_wdata = {8'b0, store_data[7:0], 16'b0};
                        end
                        2'b11: begin
                            dmem_wstrb = 4'b1000;
                            dmem_wdata = {store_data[7:0], 24'b0};
                        end
                    endcase
                end

                3'b001: begin
                    // SH
                    if (addr[1] == 1'b0) begin
                        dmem_wstrb = 4'b0011;
                        dmem_wdata = {16'b0, store_data[15:0]};
                    end else begin
                        dmem_wstrb = 4'b1100;
                        dmem_wdata = {store_data[15:0], 16'b0};
                    end
                end

                3'b010: begin
                    // SW
                    dmem_wstrb = 4'b1111;
                    dmem_wdata = store_data;
                end

                default: begin
                    dmem_wstrb = 4'b0000;
                    dmem_wdata = 32'b0;
                end
            endcase
        end
    end

    always @(*) begin
        case (funct3)
            3'b000: load_data = {{24{selected_byte[7]}}, selected_byte};   // LB
            3'b001: load_data = {{16{selected_half[15]}}, selected_half};  // LH
            3'b010: load_data = dmem_rdata;                                // LW
            3'b100: load_data = {24'b0, selected_byte};                    // LBU
            3'b101: load_data = {16'b0, selected_half};                    // LHU
            default: load_data = dmem_rdata;
        endcase
    end

endmodule