module KeyboardInput(
    input wire clk,
    input wire rst_n,

    input wire ps2_clk,
    input wire ps2_data,

    input wire dmem_ready,
    input wire [31:0] dmem_rdata,
    output reg dmem_en,
    output reg dmem_we,
    output reg [31:0] dmem_addr,
    output reg [31:0] dmem_wdata,
    output reg update_busy,

    output reg [31:0] current_value,
    output reg [31:0] case_value,
    output reg [31:0] op_a_value,
    output reg [31:0] op_b_value,
    output reg [31:0] result_value,
    output reg [1:0] input_field,
    output reg [3:0] digit_count,
    output reg [7:0] last_key,
    output reg frame_error,
    output reg commit_done
);

localparam [1:0] FIELD_CASE = 2'd0;
localparam [1:0] FIELD_A    = 2'd1;
localparam [1:0] FIELD_B    = 2'd2;

localparam [2:0] ST_INPUT      = 3'd0;
localparam [2:0] ST_WRITE_CASE = 3'd1;
localparam [2:0] ST_WRITE_A    = 3'd2;
localparam [2:0] ST_WRITE_B    = 3'd3;
localparam [2:0] ST_READ_RES   = 3'd4;

localparam [31:0] CASE_ADDR   = 32'h0000_4000;
localparam [31:0] OP_A_ADDR   = 32'h0000_4004;
localparam [31:0] OP_B_ADDR   = 32'h0000_4008;
localparam [31:0] RESULT_ADDR = 32'h0000_400C;

wire scan_valid;
wire [7:0] scan_code;
wire ps2_frame_error;
wire key_valid;
wire key_release;
wire key_extend;
wire [7:0] key_code;

wire key_is_hex;
wire [3:0] key_hex;
wire key_enter;
wire key_backspace;
wire key_escape;
wire key_press;

reg [2:0] state;

ps2_rx u_ps2_rx(
    .clk(clk),
    .rst_n(rst_n),
    .ps2_clk(ps2_clk),
    .ps2_data(ps2_data),
    .scan_valid(scan_valid),
    .scan_code(scan_code),
    .frame_error(ps2_frame_error)
);

key_event u_key_event(
    .clk(clk),
    .rst_n(rst_n),
    .scan_valid(scan_valid),
    .scan_code(scan_code),
    .key_valid(key_valid),
    .key_release(key_release),
    .key_extend(key_extend),
    .key_code(key_code)
);

KeyDecode u_key_decode(
    .key_code(key_code),
    .is_hex(key_is_hex),
    .hex_value(key_hex),
    .is_enter(key_enter),
    .is_backspace(key_backspace),
    .is_escape(key_escape)
);

assign key_press = key_valid & ~key_release;

always @(*) begin
    dmem_en = 1'b1;
    dmem_we = 1'b0;
    dmem_addr = RESULT_ADDR;
    dmem_wdata = 32'b0;

    case (state)
        ST_WRITE_CASE: begin
            dmem_we = dmem_ready;
            dmem_addr = CASE_ADDR;
            dmem_wdata = case_value;
        end
        ST_WRITE_A: begin
            dmem_we = dmem_ready;
            dmem_addr = OP_A_ADDR;
            dmem_wdata = op_a_value;
        end
        ST_WRITE_B: begin
            dmem_we = dmem_ready;
            dmem_addr = OP_B_ADDR;
            dmem_wdata = op_b_value;
        end
        default: begin
            dmem_we = 1'b0;
            dmem_addr = RESULT_ADDR;
            dmem_wdata = 32'b0;
        end
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state <= ST_INPUT;
        update_busy <= 1'b0;
        current_value <= 32'b0;
        case_value <= 32'b0;
        op_a_value <= 32'b0;
        op_b_value <= 32'b0;
        result_value <= 32'b0;
        input_field <= FIELD_CASE;
        digit_count <= 4'b0;
        last_key <= 8'b0;
        frame_error <= 1'b0;
        commit_done <= 1'b0;
    end else begin
        if(ps2_frame_error) begin
            frame_error <= 1'b1;
        end

        if(state == ST_INPUT || state == ST_READ_RES) begin
            result_value <= dmem_rdata;
        end

        case (state)
            ST_INPUT: begin
                update_busy <= 1'b0;

                if(key_press) begin
                    last_key <= key_code;

                    commit_done <= 1'b0;

                    if(key_escape) begin
                        current_value <= 32'b0;
                        case_value <= 32'b0;
                        op_a_value <= 32'b0;
                        op_b_value <= 32'b0;
                        frame_error <= 1'b0;
                        input_field <= FIELD_CASE;
                        digit_count <= 4'b0;
                    end else if(key_backspace) begin
                        if(digit_count != 4'b0) begin
                            current_value <= {4'b0, current_value[31:4]};
                            digit_count <= digit_count - 1'b1;
                        end
                    end else if(key_enter) begin
                        case (input_field)
                            FIELD_CASE: begin
                                case_value <= current_value;
                                current_value <= 32'b0;
                                digit_count <= 4'b0;
                                input_field <= FIELD_A;
                            end
                            FIELD_A: begin
                                op_a_value <= current_value;
                                current_value <= 32'b0;
                                digit_count <= 4'b0;
                                input_field <= FIELD_B;
                            end
                            default: begin
                                op_b_value <= current_value;
                                current_value <= 32'b0;
                                digit_count <= 4'b0;
                                input_field <= FIELD_CASE;
                                update_busy <= 1'b1;
                                state <= ST_WRITE_CASE;
                            end
                        endcase
                    end else if(key_is_hex && digit_count < 4'd8) begin
                        current_value <= {current_value[27:0], key_hex};
                        digit_count <= digit_count + 1'b1;
                    end
                end
            end

            ST_WRITE_CASE: begin
                update_busy <= 1'b1;
                if(dmem_ready) begin
                    state <= ST_WRITE_A;
                end
            end

            ST_WRITE_A: begin
                update_busy <= 1'b1;
                if(dmem_ready) begin
                    state <= ST_WRITE_B;
                end
            end

            ST_WRITE_B: begin
                update_busy <= 1'b1;
                if(dmem_ready) begin
                    state <= ST_READ_RES;
                end
            end

            ST_READ_RES: begin
                update_busy <= 1'b0;
                commit_done <= 1'b1;
                state <= ST_INPUT;
            end

            default: begin
                state <= ST_INPUT;
                update_busy <= 1'b0;
            end
        endcase
    end
end

wire unused_key_extend;
assign unused_key_extend = key_extend;

endmodule

module KeyDecode(
    input wire [7:0] key_code,
    output reg is_hex,
    output reg [3:0] hex_value,
    output reg is_enter,
    output reg is_backspace,
    output reg is_escape
);

always @(*) begin
    is_hex = 1'b0;
    hex_value = 4'h0;
    is_enter = 1'b0;
    is_backspace = 1'b0;
    is_escape = 1'b0;

    case (key_code)
        8'h45, 8'h70: begin is_hex = 1'b1; hex_value = 4'h0; end
        8'h16, 8'h69: begin is_hex = 1'b1; hex_value = 4'h1; end
        8'h1E, 8'h72: begin is_hex = 1'b1; hex_value = 4'h2; end
        8'h26, 8'h7A: begin is_hex = 1'b1; hex_value = 4'h3; end
        8'h25, 8'h6B: begin is_hex = 1'b1; hex_value = 4'h4; end
        8'h2E, 8'h73: begin is_hex = 1'b1; hex_value = 4'h5; end
        8'h36, 8'h74: begin is_hex = 1'b1; hex_value = 4'h6; end
        8'h3D, 8'h6C: begin is_hex = 1'b1; hex_value = 4'h7; end
        8'h3E, 8'h75: begin is_hex = 1'b1; hex_value = 4'h8; end
        8'h46, 8'h7D: begin is_hex = 1'b1; hex_value = 4'h9; end
        8'h1C: begin is_hex = 1'b1; hex_value = 4'hA; end
        8'h32: begin is_hex = 1'b1; hex_value = 4'hB; end
        8'h21: begin is_hex = 1'b1; hex_value = 4'hC; end
        8'h23: begin is_hex = 1'b1; hex_value = 4'hD; end
        8'h24: begin is_hex = 1'b1; hex_value = 4'hE; end
        8'h2B: begin is_hex = 1'b1; hex_value = 4'hF; end
        8'h5A: is_enter = 1'b1;
        8'h66: is_backspace = 1'b1;
        8'h76: is_escape = 1'b1;
        default: begin
            is_hex = 1'b0;
            hex_value = 4'h0;
        end
    endcase
end

endmodule
