# UART Controller — RTL & Verification

## 📝 Project Summary
Designed a configurable UART transmitter and receiver supporting variable baud rates and parity modes, then built a SystemVerilog verification environment using assertions to check protocol timing and framing compliance. Stress-tested the design against noise, baud-rate mismatch, and back-to-back frame scenarios to confirm robustness beyond the happy path.

## 🏗️ Architecture & Waveforms

### Block Diagram
![Block Diagram](./images/uart_block.png)
*Figure 1: UART TX/RX Architecture*

### Frame Transmission
![Waveform](./images/uart_waveform.png)
*Figure 2: UART Frame transmission and assertion checks*

## 🚀 How to Run the Simulation

### Prerequisites
- SystemVerilog simulator (Cadence Xcelium, QuestaSim, ModelSim)
- SVA (SystemVerilog Assertions) support

### Run Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/abhijit-karale/uart-controller-sv.git
   cd uart-controller-sv
   ```

2. Navigate to simulation directory:
   ```bash
   cd sim/
   ```

3. Run the SystemVerilog testbench with assertion tracking:
   ```bash
   make run_uart_tb
   ```

4. View coverage report:
   ```bash
   cat cov_report.txt
   ```

## 📊 Coverage & Results
* **Verification Focus:** Protocol timing, framing compliance, and SVA (SystemVerilog Assertions)
* **Robustness Testing:** Successfully verified under stress-test scenarios including:
  - Noise injection
  - Baud-rate mismatch (±10% deviation)
  - Back-to-back frame transmissions
  - Parity error detection
  - Synchronization glitches

## 📂 Project Structure
```
uart-controller-sv/
├── README.md
├── rtl/
│   ├── uart_top.sv
│   ├── uart_tx.sv
│   ├── uart_rx.sv
│   └── baud_gen.sv
├── tb/
│   ├── uart_tb.sv
│   ├── uart_driver.sv
│   ├── uart_monitor.sv
│   ├── uart_assertions.sv
│   └── uart_sequences.sv
├── sim/
│   ├── Makefile
│   ├── run.do
│   └── assertions.sva
└── images/
    ├── uart_block.png
    └── uart_waveform.png
```

## 🛠️ Tools & Technologies
- **RTL Design:** Verilog, SystemVerilog
- **Verification:** SystemVerilog, SVA (Assertions)
- **Simulator:** Cadence Xcelium / QuestaSim / ModelSim
- **Protocol:** UART (Universal Asynchronous Receiver/Transmitter)

## 📌 UART Configuration
- **Baud Rates:** Configurable (9600, 19200, 38400, 115200 bps)
- **Data Bits:** 8 bits
- **Stop Bits:** 1 or 2 (configurable)
- **Parity:** None, Even, Odd (configurable)
- **Flow Control:** Optional handshake signals

## ✅ Verification Coverage
- [x] Transmission of single frames
- [x] Reception with correct framing
- [x] Parity checking (even/odd/none)
- [x] Baud rate configuration
- [x] Asynchronous clock domains
- [x] Error detection (frame error, parity error)
- [x] Back-to-back frame handling
- [x] Noise immunity

## 🎯 Key Assertions
- Frame integrity: `start_bit == 1'b0`
- Stop bit validation: `stop_bit == 1'b1`
- Parity correctness: `parity_calc == rx_parity`
- Timing: `bit_duration == (clock_period * divider)`

## 📧 Contact
For questions about this project, feel free to reach out:
- GitHub: [abhijit-karale](https://github.com/abhijit-karale)
- LinkedIn: [abhijit-karale-rtl-dv](https://linkedin.com/in/abhijit-karale-rtl-dv)
- Email: abhijitkarale8@gmail.com
