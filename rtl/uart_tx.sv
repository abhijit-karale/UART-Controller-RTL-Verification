// ============================================================================
// Module Name  : uart_tx
// Description  : Configurable UART Transmitter supporting 8-bit data,
//                configurable parity (None, Even, Odd), and 1 or 2 stop bits.
// ============================================================================

module uart_tx (
    input  logic       clk,          // System clock
    input  logic       rst_n,        // Active low asynchronous reset
    input  logic       tx_clk_tick,  // Baud tick from baud generator
    input  logic       tx_start,     // Pulse to start transmission
    input  logic [7:0] tx_data,      // 8-bit data payload to transmit
    input  logic [1:0] parity_type,  // 2'b00: None, 2'b01: Even, 2'b10: Odd
    input  logic       stop_bits,    // 1'b0: 1 stop bit, 1'b1: 2 stop bits
    output logic       tx,           // Serial transmit line
    output logic       tx_busy,      // High during transmission
    output logic       tx_done       // Pulse on frame transmission completion
);

    typedef enum logic [2:0] {
        ST_IDLE   = 3'b000,
        ST_START  = 3'b001,
        ST_DATA   = 3'b010,
        ST_PARITY = 3'b011,
        ST_STOP   = 3'b100
    } state_t;

    state_t state, next_state;

    logic [7:0] data_reg;
    logic [2:0] bit_idx;
    logic       parity_bit;
    logic       stop_cnt;

    // Parity calculation
    always_comb begin
        case (parity_type)
            2'b01:   parity_bit = ^data_reg;       // Even Parity
            2'b10:   parity_bit = ~(^data_reg);    // Odd Parity
            default: parity_bit = 1'b0;
        endcase
    end

    // Sequential state register and data capture
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= ST_IDLE;
            data_reg <= 8'h00;
            bit_idx  <= 3'd0;
            stop_cnt <= 1'b0;
        end else begin
            state <= next_state;
            
            if (state == ST_IDLE && tx_start) begin
                data_reg <= tx_data;
                bit_idx  <= 3'd0;
                stop_cnt <= 1'b0;
            end else if (tx_clk_tick) begin
                if (state == ST_DATA) begin
                    if (bit_idx == 3'd7) begin
                        bit_idx <= 3'd0;
                    end else begin
                        bit_idx <= bit_idx + 3'd1;
                    end
                end else if (state == ST_STOP) begin
                    stop_cnt <= stop_cnt + 1'b1;
                end
            end
        end
    end

    // Combinational next state logic & control signals
    always_comb begin
        next_state = state;
        tx         = 1'b1; // Idle high
        tx_busy    = 1'b1;
        tx_done    = 1'b0;

        case (state)
            ST_IDLE: begin
                tx      = 1'b1;
                tx_busy = 1'b0;
                if (tx_start) begin
                    next_state = ST_START;
                end
            end

            ST_START: begin
                tx = 1'b0; // Start bit = 0
                if (tx_clk_tick) begin
                    next_state = ST_DATA;
                end
            end

            ST_DATA: begin
                tx = data_reg[bit_idx];
                if (tx_clk_tick && (bit_idx == 3'd7)) begin
                    if (parity_type != 2'b00) begin
                        next_state = ST_PARITY;
                    end else begin
                        next_state = ST_STOP;
                    end
                end
            end

            ST_PARITY: begin
                tx = parity_bit;
                if (tx_clk_tick) begin
                    next_state = ST_STOP;
                end
            end

            ST_STOP: begin
                tx = 1'b1; // Stop bit = 1
                if (tx_clk_tick) begin
                    if (stop_bits == 1'b1 && stop_cnt == 1'b0) begin
                        next_state = ST_STOP;
                    end else begin
                        tx_done    = 1'b1;
                        next_state = ST_IDLE;
                    end
                end
            end

            default: next_state = ST_IDLE;
        endcase
    end

endmodule
