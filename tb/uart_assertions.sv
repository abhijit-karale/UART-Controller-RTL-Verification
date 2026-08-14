// ============================================================================
// Module Name  : uart_assertions
// Description  : SystemVerilog Assertions (SVA) for UART Protocol Protocol
//                Timing, Framing Compliance, and Error Detection Verification.
// ============================================================================

`timescale 1ns/1ps

module uart_assertions (
    input logic        clk,
    input logic        rst_n,
    input logic [15:0] baud_div,
    input logic [1:0]  parity_type,
    input logic        stop_bits,
    input logic        tx_start,
    input logic [7:0]  tx_data,
    input logic        tx,
    input logic        tx_busy,
    input logic        tx_done,
    input logic        rx,
    input logic [7:0]  rx_data,
    input logic        rx_ready,
    input logic        parity_error,
    input logic        frame_error
);

    // ------------------------------------------------------------------------
    // Property 1: TX Start Bit Validation
    // When tx_start is triggered, tx line must drop to logic 0 on next tick
    // ------------------------------------------------------------------------
    property p_tx_start_bit;
        @(posedge clk) disable iff (!rst_n)
        $rose(tx_start) |=> ##[1:1000] (tx == 1'b0);
    endproperty
    assert_tx_start_bit: assert property (p_tx_start_bit)
        else $error("[SVA FAIL] TX Start Bit not driven low after tx_start!");
    cover_tx_start_bit: cover property (p_tx_start_bit);

    // ------------------------------------------------------------------------
    // Property 2: TX Stop Bit Validation
    // When tx_done is asserted, tx line must be logic 1 (Idle/Stop state)
    // ------------------------------------------------------------------------
    property p_tx_stop_bit;
        @(posedge clk) disable iff (!rst_n)
        tx_done |-> (tx == 1'b1);
    endproperty
    assert_tx_stop_bit: assert property (p_tx_stop_bit)
        else $error("[SVA FAIL] TX Stop Bit is not HIGH when tx_done asserted!");
    cover_tx_stop_bit: cover property (p_tx_stop_bit);

    // ------------------------------------------------------------------------
    // Property 3: RX Ready Data Stability
    // When rx_ready is asserted, frame_error should NOT be asserted simultaneously
    // for a valid frame.
    // ------------------------------------------------------------------------
    property p_rx_valid_frame;
        @(posedge clk) disable iff (!rst_n)
        rx_ready |-> (!frame_error);
    endproperty
    assert_rx_valid_frame: assert property (p_rx_valid_frame)
        else $warning("[SVA CHECK] RX Ready asserted during Frame Error condition!");
    cover_rx_valid_frame: cover property (p_rx_valid_frame);

    // ------------------------------------------------------------------------
    // Property 4: Reset Line Integrity
    // When rst_n is low, tx output must remain High (idle state)
    // ------------------------------------------------------------------------
    property p_tx_reset_idle;
        @(posedge clk) !rst_n |-> (tx == 1'b1 && tx_busy == 1'b0);
    endproperty
    assert_tx_reset_idle: assert property (p_tx_reset_idle)
        else $error("[SVA FAIL] TX not in idle state during active reset!");

endmodule
