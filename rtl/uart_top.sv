// ============================================================================
// Module Name  : uart_top
// Description  : Top-level UART Controller module encapsulating Baud Rate 
//                Generator, Transmitter, and Receiver with flexible configuration.
// ============================================================================

module uart_top (
    input  logic        clk,          // System clock
    input  logic        rst_n,        // Active low asynchronous reset
    
    // Configuration
    input  logic [15:0] baud_div,     // Clock divisor (CLK_FREQ / BAUD_RATE)
    input  logic [1:0]  parity_type,  // 2'b00: None, 2'b01: Even, 2'b10: Odd
    input  logic        stop_bits,    // 1'b0: 1 stop bit, 1'b1: 2 stop bits
    
    // Transmitter Interface
    input  logic        tx_start,     // Transmit initiate trigger
    input  logic [7:0]  tx_data,      // Transmit data byte payload
    output logic        tx,           // Serial output line
    output logic        tx_busy,      // TX module busy status flag
    output logic        tx_done,      // TX complete pulse
    
    // Receiver Interface
    input  logic        rx,           // Serial input line
    output logic [7:0]  rx_data,      // Received data byte payload
    output logic        rx_ready,     // Valid RX byte received pulse
    output logic        parity_error, // RX parity error status flag
    output logic        frame_error   // RX framing error status flag
);

    // Internal Baud Rate Ticks & Resets
    logic tx_clk_tick;
    logic rx_clk_tick;
    logic rx_reset;

    // ------------------------------------------------------------------------
    // Baud Rate Generator Instance
    // ------------------------------------------------------------------------
    baud_gen u_baud_gen (
        .clk         (clk),
        .rst_n       (rst_n),
        .baud_div    (baud_div),
        .tx_reset    (tx_start),
        .rx_reset    (rx_reset),
        .tx_clk_tick (tx_clk_tick),
        .rx_clk_tick (rx_clk_tick)
    );

    // ------------------------------------------------------------------------
    // UART Transmitter Instance
    // ------------------------------------------------------------------------
    uart_tx u_uart_tx (
        .clk         (clk),
        .rst_n       (rst_n),
        .tx_clk_tick (tx_clk_tick),
        .tx_start    (tx_start),
        .tx_data     (tx_data),
        .parity_type (parity_type),
        .stop_bits   (stop_bits),
        .tx          (tx),
        .tx_busy     (tx_busy),
        .tx_done     (tx_done)
    );

    // ------------------------------------------------------------------------
    // UART Receiver Instance
    // ------------------------------------------------------------------------
    uart_rx u_uart_rx (
        .clk          (clk),
        .rst_n        (rst_n),
        .rx_clk_tick  (rx_clk_tick),
        .rx           (rx),
        .parity_type  (parity_type),
        .stop_bits    (stop_bits),
        .rx_reset     (rx_reset),
        .rx_data      (rx_data),
        .rx_ready     (rx_ready),
        .parity_error (parity_error),
        .frame_error  (frame_error)
    );

endmodule
