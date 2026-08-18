// ============================================================================
// Module Name  : uart_rx
// Description  : Configurable UART Receiver with 16x oversampling, 
//                metastability synchronizer, glitch filtering,
//                parity check, framing error check, and rx_ready flag.
// ============================================================================

module uart_rx (
    input  logic       clk,          // System clock
    input  logic       rst_n,        // Active low asynchronous reset
    input  logic       rx_clk_tick,  // 16x oversampling clock tick from baud generator
    input  logic       rx,           // Serial receive input line
    input  logic [1:0] parity_type,  // 2'b00: None, 2'b01: Even, 2'b10: Odd
    input  logic       stop_bits,    // 1'b0: 1 stop bit, 1'b1: 2 stop bits
    output logic       rx_reset,     // Oversampling clock tick reset trigger
    output logic [7:0] rx_data,      // Received 8-bit data payload
    output logic       rx_ready,     // Valid data received pulse
    output logic       parity_error, // Parity error flag
    output logic       frame_error   // Framing error flag (invalid stop bit)
);

    // 2-stage synchronizer to prevent metastability
    logic rx_sync_0, rx_sync_1;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_sync_0 <= 1'b1;
            rx_sync_1 <= 1'b1;
        end else begin
            rx_sync_0 <= rx;
            rx_sync_1 <= rx_sync_0;
        end
    end

    typedef enum logic [2:0] {
        ST_IDLE   = 3'b000,
        ST_START  = 3'b001,
        ST_DATA   = 3'b010,
        ST_PARITY = 3'b011,
        ST_STOP   = 3'b100
    } state_t;

    state_t state;

    logic [3:0] sample_cnt;
    logic [2:0] bit_idx;
    logic [7:0] shift_reg;
    logic       rx_parity_calc;
    logic       rx_parity_sampled;
    logic       stop_cnt;

    // Expected parity calculation on shift_reg
    always_comb begin
        case (parity_type)
            2'b01:   rx_parity_calc = ^shift_reg;       // Even Parity
            2'b10:   rx_parity_calc = ~(^shift_reg);    // Odd Parity
            default: rx_parity_calc = 1'b0;
        endcase
    end

    // Sequential state and sampling logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state             <= ST_IDLE;
            sample_cnt        <= 4'd0;
            bit_idx           <= 3'd0;
            shift_reg         <= 8'h00;
            rx_data           <= 8'h00;
            rx_ready          <= 1'b0;
            parity_error      <= 1'b0;
            frame_error       <= 1'b0;
            rx_parity_sampled <= 1'b0;
            stop_cnt          <= 1'b0;
            rx_reset          <= 1'b0;
        end else begin
            rx_ready <= 1'b0; // Default pulse low
            rx_reset <= 1'b0;

            if (state == ST_IDLE) begin
                sample_cnt <= 4'd0;
                bit_idx    <= 3'd0;
                stop_cnt   <= 1'b0;
                if (rx_sync_1 == 1'b0) begin // Immediate falling edge detection
                    state        <= ST_START;
                    sample_cnt   <= 4'd0;
                    parity_error <= 1'b0;
                    frame_error  <= 1'b0;
                    rx_reset     <= 1'b1; // Sync oversample clock
                end
            end else if (rx_clk_tick) begin
                case (state)
                    ST_START: begin
                        if (sample_cnt == 4'd7) begin // Mid-bit start glitch check
                            if (rx_sync_1 != 1'b0) begin
                                // False start bit (glitch), return to IDLE
                                state <= ST_IDLE;
                            end
                        end
                        
                        if (sample_cnt == 4'd15) begin
                            sample_cnt <= 4'd0;
                            state      <= ST_DATA;
                            bit_idx    <= 3'd0;
                        end else begin
                            sample_cnt <= sample_cnt + 4'd1;
                        end
                    end

                    ST_DATA: begin
                        if (sample_cnt == 4'd7) begin
                            shift_reg[bit_idx] <= rx_sync_1;
                        end

                        if (sample_cnt == 4'd15) begin
                            sample_cnt <= 4'd0;
                            if (bit_idx == 3'd7) begin
                                if (parity_type != 2'b00) begin
                                    state <= ST_PARITY;
                                end else begin
                                    state <= ST_STOP;
                                end
                            end else begin
                                bit_idx <= bit_idx + 3'd1;
                            end
                        end else begin
                            sample_cnt <= sample_cnt + 4'd1;
                        end
                    end

                    ST_PARITY: begin
                        if (sample_cnt == 4'd7) begin
                            rx_parity_sampled <= rx_sync_1;
                        end

                        if (sample_cnt == 4'd15) begin
                            sample_cnt <= 4'd0;
                            state      <= ST_STOP;
                        end else begin
                            sample_cnt <= sample_cnt + 4'd1;
                        end
                    end

                    ST_STOP: begin
                        if (sample_cnt == 4'd7) begin
                            // Sample stop bit
                            if (rx_sync_1 == 1'b0) begin
                                frame_error <= 1'b1; // Framing Error (stop bit not high)
                            end else begin
                                frame_error <= 1'b0;
                            end

                            // Check parity
                            if (parity_type != 2'b00) begin
                                if (rx_parity_sampled != rx_parity_calc) begin
                                    parity_error <= 1'b1;
                                end else begin
                                    parity_error <= 1'b0;
                                end
                            end else begin
                                parity_error <= 1'b0;
                            end
                        end

                        if (sample_cnt == 4'd15) begin
                            sample_cnt <= 4'd0;
                            if (stop_bits == 1'b1 && stop_cnt == 1'b0) begin
                                stop_cnt <= 1'b1;
                            end else begin
                                rx_data  <= shift_reg;
                                rx_ready <= 1'b1;
                                state    <= ST_IDLE;
                            end
                        end else begin
                            sample_cnt <= sample_cnt + 4'd1;
                        end
                    end

                    default: state <= ST_IDLE;
                endcase
            end
        end
    end

endmodule

