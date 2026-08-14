// ============================================================================
// Module Name  : uart_driver
// Description  : Driver module providing transaction-level interfaces to drive
//                UART TX host commands and RX serial line stimulus.
// ============================================================================

`timescale 1ns/1ps

module uart_driver (
    input  logic       clk,
    input  logic       rst_n,
    output logic       tx_start,
    output logic [7:0] tx_data,
    input  logic       tx_busy,
    input  logic       tx_done,
    output logic       rx_pin
);

    import uart_sequences_pkg::*;

    initial begin
        tx_start = 1'b0;
        tx_data  = 8'h00;
        rx_pin   = 1'b1;
    end

    // Task to trigger TX transmit
    task automatic send_tx_byte(input logic [7:0] data);
        wait (!tx_busy);
        @(posedge clk);
        tx_data  <= data;
        tx_start <= 1'b1;
        @(posedge clk);
        tx_start <= 1'b0;
        wait (tx_done);
        @(posedge clk);
    endtask

    // Task to drive RX pin with a custom byte payload
    task automatic send_rx_byte(
        input logic [7:0] data,
        input logic [1:0] parity_type,
        input logic       stop_bits,
        input realtime    bit_period,
        input logic       parity_err = 1'b0,
        input logic       frame_err  = 1'b0,
        input logic       glitch     = 1'b0
    );
        drive_raw_rx_frame(rx_pin, data, parity_type, stop_bits, bit_period, parity_err, frame_err, glitch);
    endtask

endmodule
