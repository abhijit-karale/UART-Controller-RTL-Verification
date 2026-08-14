// ============================================================================
// Module / Package : uart_sequences
// Description      : Testbench sequences and stimulus generation tasks for
//                    Happy path, Back-to-Back, Parity Error, Framing Error,
//                    Noise Injection, and Baud Mismatch scenarios.
// ============================================================================

`timescale 1ns/1ps

package uart_sequences_pkg;

    // Helper task to send raw serial frame to RX pin with flexible bit period and error injection
    task automatic drive_raw_rx_frame(
        ref logic       rx_pin,
        input logic [7:0] data,
        input logic [1:0] parity_type, // 0: None, 1: Even, 2: Odd
        input logic       stop_bits,   // 0: 1 bit, 1: 2 bits
        input realtime    bit_period,  // Time duration per bit in ns
        input logic       inject_parity_err = 1'b0,
        input logic       inject_frame_err  = 1'b0,
        input logic       inject_glitch     = 1'b0
    );
        logic parity_bit;

        // Calculate expected parity
        case (parity_type)
            2'b01:   parity_bit = ^data;
            2'b10:   parity_bit = ~(^data);
            default: parity_bit = 1'b0;
        endcase

        if (inject_parity_err) parity_bit = ~parity_bit;

        // 1. Start Bit (0)
        rx_pin = 1'b0;
        if (inject_glitch) begin
            #(bit_period / 4);
            rx_pin = 1'b1; // Short noise spike
            #(bit_period / 8);
            rx_pin = 1'b0; // Recovery
            #(5 * bit_period / 8);
        end else begin
            #bit_period;
        end

        // 2. Data Bits (8 bits, LSB first)
        for (int i = 0; i < 8; i++) begin
            rx_pin = data[i];
            #bit_period;
        end

        // 3. Parity Bit (if enabled)
        if (parity_type != 2'b00) begin
            rx_pin = parity_bit;
            #bit_period;
        end

        // 4. Stop Bit(s) (1 or 2 bits)
        rx_pin = inject_frame_err ? 1'b0 : 1'b1;
        #bit_period;
        if (stop_bits == 1'b1) begin
            #bit_period;
        end

        // Return to Idle high
        rx_pin = 1'b1;
    endtask

endpackage
