# ============================================================================
# File Name  : run.do
# Description: ModelSim / QuestaSim Macro Script for Compiling and Simulating
#              the Configurable UART Controller RTL & SVA Verification Suite.
# ============================================================================

# Create work library
vlib work
vmap work work

# Compile RTL source files
vlog -sv ../rtl/baud_gen.sv
vlog -sv ../rtl/uart_tx.sv
vlog -sv ../rtl/uart_rx.sv
vlog -sv ../rtl/uart_top.sv

# Compile TB source files and SVA
vlog -sv ../tb/uart_sequences.sv
vlog -sv ../tb/uart_driver.sv
vlog -sv ../tb/uart_monitor.sv
vlog -sv ../tb/uart_assertions.sv
vlog -sv ../tb/uart_tb.sv

# Elaborate top testbench with assertions enabled
vsim -c -assertdebug -voptargs="+acc" work.uart_tb

# Waveform setup
add wave -position insertpoint sim:/uart_tb/u_dut/*
add wave -position insertpoint sim:/uart_tb/u_sva/*

# Run simulation
run -all

# Exit GUI if run in batch mode
quit -f
