// ============================================================================
// Module Name  : baud_gen
// Description  : Configurable Baud Rate Generator for UART TX and RX.
//                Generates 1x tick for TX and 16x oversampling tick for RX.
//                Supports counter synchronization on TX start and RX start bit.
// ============================================================================

module baud_gen (
    input  logic        clk,          // System clock
    input  logic        rst_n,        // Active low asynchronous reset
    input  logic [15:0] baud_div,     // Clock divisor count for bit period (CLK_FREQ / BAUD_RATE)
    input  logic        tx_reset,     // Resets TX baud counter on tx_start
    input  logic        rx_reset,     // Resets RX oversample counter on start bit edge
    output logic        tx_clk_tick,  // Tick for TX bit rate duration
    output logic        rx_clk_tick   // Tick for RX 16x oversampling clock
);

    // Internal registers
    logic [15:0] tx_count;
    logic [15:0] rx_count;
    logic [15:0] rx_div;

    // RX divisor is bit period divisor divided by 16 (baud_div >> 4)
    assign rx_div = (baud_div > 16) ? (baud_div >> 4) : 16'd1;

    // ------------------------------------------------------------------------
    // TX Baud Tick Generation
    // ------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_count    <= 16'd0;
            tx_clk_tick <= 1'b0;
        end else if (tx_reset) begin
            tx_count    <= 16'd0;
            tx_clk_tick <= 1'b0;
        end else begin
            if (tx_count >= (baud_div - 16'd1)) begin
                tx_count    <= 16'd0;
                tx_clk_tick <= 1'b1;
            end else begin
                tx_count    <= tx_count + 16'd1;
                tx_clk_tick <= 1'b0;
            end
        end
    end

    // ------------------------------------------------------------------------
    // RX 16x Oversampling Clock Tick Generation
    // ------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_count    <= 16'd0;
            rx_clk_tick <= 1'b0;
        end else if (rx_reset) begin
            rx_count    <= 16'd0;
            rx_clk_tick <= 1'b0;
        end else begin
            if (rx_count >= (rx_div - 16'd1)) begin
                rx_count    <= 16'd0;
                rx_clk_tick <= 1'b1;
            end else begin
                rx_count    <= rx_count + 16'd1;
                rx_clk_tick <= 1'b0;
            end
        end
    end

endmodule
