# ============================================================================
# File Name  : Makefile
# Description: Makefile for UART Controller Simulation and Verification Suite
# ============================================================================

# Directory paths
RTL_DIR = ../rtl
TB_DIR  = ../tb
SIM_DIR = .

# Source files
RTL_SRCS = $(RTL_DIR)/baud_gen.sv \
           $(RTL_DIR)/uart_tx.sv \
           $(RTL_DIR)/uart_rx.sv \
           $(RTL_DIR)/uart_top.sv

TB_SRCS  = $(TB_DIR)/uart_sequences.sv \
           $(TB_DIR)/uart_driver.sv \
           $(TB_DIR)/uart_monitor.sv \
           $(TB_DIR)/uart_assertions.sv \
           $(TB_DIR)/uart_tb.sv

# Default Simulator Engine (ModelSim vsim or Icarus iverilog fallback)
SIM ?= iverilog

.PHONY: all compile run_uart_tb cov_report clean

all: run_uart_tb

compile:
	@echo "Compiling UART Controller RTL & Testbench files..."
	$(SIM) -g2012 -o uart_sim.out $(RTL_SRCS) $(TB_SRCS)

run_uart_tb: compile
	@echo "Executing SystemVerilog Simulation..."
	vvp uart_sim.out

cov_report:
	@echo "Displaying Verification Coverage Report:"
	@cat cov_report.txt || echo "cov_report.txt not found. Run simulation first."

clean:
	@echo "Cleaning simulation build artifacts..."
	rm -f *.out *.vcd *.wlf *.log cov_report.txt
	rm -rf work transcript
