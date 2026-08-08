# 5-Stage Pipelined RISC-V CPU with Dynamic Branch Prediction

## Overview
This repository contains a fully functional, 32-bit RISC-V processor designed from scratch in Verilog HDL. The architecture implements a classic 5-stage pipeline (Fetch, Decode, Execute, Memory, Write-Back) and focuses on maximizing Instructions Per Cycle (IPC) through hardware-level hazard resolution and dynamic control flow prediction.

The design was synthesized and verified using Xilinx Vivado. A custom two-pass Python assembler is included to translate human-readable RISC-V assembly programs into machine code executable by the core.

## Architectural Features

*   **5-Stage Microarchitecture:** Fully pipelined datapath isolated by barrier registers (`if_id`, `id_ex`, `ex_mem`, `mem_wb`).
*   **Dynamic Branch Prediction:** Implements a Branch Target Buffer (BTB) and a Branch History Table (BHT) using a 2-bit saturating counter. This allows the Fetch stage to predict loop branches instantly, minimizing pipeline flushes and cycle penalties.
*   **Hardware Hazard Unit:** Detects data collisions in real-time. Implements data forwarding (bypassing) to route ALU results directly to dependent instructions, and automatic pipeline stalling for load-use hazards.
*   **Custom Toolchain:** A lightweight Python assembler (`assembler.py`) that converts custom `.asm` files into `.hex` files for instruction memory initialization.

## Repository Structure
*   `/src`: Verilog RTL source files (Modules, Pipeline Registers, Hazard Unit, Branch Predictor).
*   `/tb`: Verilog testbench for behavioral simulation.
*   `/software`: Python assembler and example RISC-V assembly programs (e.g., looping structures to stress-test branch prediction).
*   `/docs`: Waveform analysis and simulation verification.

## Getting Started: How to Run

### 1. Generate Machine Code
Write your custom RISC-V assembly in `software/program.asm`. Then, use the provided Python assembler to generate the hex file for the CPU's instruction memory:

```bash
cd software
py assembler.py
```

This outputs instr.hex, which the Verilog imem module reads upon reset.

### 2. Hardware Simulation
Create a new project in Xilinx Vivado.

Add all Verilog files from the /src directory as Design Sources.

Add tb_cpu_core.v from the /tb directory as a Simulation Source.

Ensure instr.hex is located in the simulation working directory.

Run Behavioral Simulation for 1 us.

### 3. Simulation & Waveform Analysis
The following waveform demonstrates the CPU successfully executing a conditional bne loop, highlighting the dynamic branch predictor and data forwarding logic in action.

![Simulation Waveform](waveform.png)

Execution Breakdown:

[1][31:0] (x1 / Loop Counter): Initializes at 3 and accurately decrements across loop iterations.

[2][31:0] (x2 / Accumulator): Accumulates the sum dynamically as the pipeline continuously feeds data through the ALU.

[3][31:0] (x3 / Constant): Holds the decrement value 1.

Branch Prediction: After the initial loop iteration, the 2-bit saturating counter learns the branch behavior, predicting Taken for subsequent iterations and eliminating pipeline stalls.
