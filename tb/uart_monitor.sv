// ============================================================================
// Module Name  : uart_monitor
// Description  : Monitor module for tracking, capturing, logging, and checking
//                UART serial line transactions and error statistics.
// ============================================================================

`timescale 1ns/1ps

module uart_monitor (
    input logic        clk,
    input logic        rst_n,
    input logic        tx,
    input logic        tx_done,
    input logic [7:0]  tx_data,
    input logic [7:0]  rx_data,
    input logic        rx_ready,
    input logic        parity_error,
    input logic        frame_error
);

    int unsigned total_tx_count    = 0;
    int unsigned total_rx_count    = 0;
    int unsigned total_parity_errs = 0;
    int unsigned total_frame_errs  = 0;

    // Monitor TX completion
    always @(posedge clk) begin
        if (rst_n && tx_done) begin
            total_tx_count++;
            $display("[MONITOR - TX] Time: %0t ns | Transmitted Data Byte: 0x%0h ('%c')", $time, tx_data, tx_data);
        end
    end

    // Monitor RX completion
    always @(posedge clk) begin
        if (rst_n && rx_ready) begin
            total_rx_count++;
            $display("[MONITOR - RX] Time: %0t ns | Received Data Byte: 0x%0h ('%c')", $time, rx_data, rx_data);
        end
    end

    // Monitor Parity Error
    always @(posedge clk) begin
        if (rst_n && parity_error && rx_ready) begin
            total_parity_errs++;
            $display("[MONITOR - ERROR] Time: %0t ns | Parity Error Detected on RX Byte: 0x%0h!", $time, rx_data);
        end
    end

    // Monitor Framing Error
    always @(posedge clk) begin
        if (rst_n && $rose(frame_error)) begin
            total_frame_errs++;
            $display("[MONITOR - ERROR] Time: %0t ns | Framing Error Detected on RX Line!", $time);
        end
    end

    function void print_summary();
        $display("\n==================================================");
        $display("          VERIFICATION MONITOR SUMMARY           ");
        $display("==================================================");
        $display(" Total TX Packets Sent      : %0d", total_tx_count);
        $display(" Total RX Packets Received  : %0d", total_rx_count);
        $display(" Total Parity Errors Caught : %0d", total_parity_errs);
        $display(" Total Framing Errors Caught: %0d", total_frame_errs);
        $display("==================================================\n");
    endfunction

endmodule
