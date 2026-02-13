# CNN-ACCELERATOR
# CNN Accelerator in Verilog (Work in Progress)

## Overview
This project implements a **hardware CNN (Convolutional Neural Network) accelerator** in Verilog/SystemVerilog. The goal is to build a modular, synthesizable accelerator capable of performing convolution operations efficiently using hardware primitives such as MAC arrays, line buffers, and sliding windows.

The project is currently **under active development**, and modules are being designed, tested, and optimized incrementally.

This repository tracks the development progress of the accelerator architecture.

---

## Current Development Status
✔ Basic arithmetic modules implemented  
✔ Register and buffering blocks implemented  
✔ Sliding window generation implemented  
✔ MAC units and MAC arrays implemented  
✔ Testbenches available for most modules  

🚧 Full accelerator integration in progress  
🚧 Control logic and memory interface pending  
🚧 Performance optimization pending  

---

## Implemented Modules

### Arithmetic Blocks
- `add_sub.v`
  - Parameterizable add/subtract unit.

### Register Blocks
- `reg_block.v`
  - General-purpose register storage module.

### Line Buffer
- `line_buffer.v`
  - Stores image rows required for convolution operations.

### Sliding Window Generator
- `sliding_window_3x3.v`
  - Generates 3×3 convolution windows from buffered data.

### MAC Units
- `mac_unit.v`
  - Basic multiply-accumulate unit.

- `mac_unit_pipelined.sv`
  - Pipelined MAC implementation for higher throughput.

### MAC Array
- `mac_array.v`
  - Parallel MAC structure used for convolution computation.

---

## Testbenches Included
Testbenches exist for module verification:

- `add_sub_tb.sv`
- `line_buffer_tb.sv`
- `mac_unit_tb.sv`
- `mac_array_tb.sv`
- `reg_block_test.sv`
- `sliding_window_3x3_tb.sv`

Each module is tested individually before system-level integration.



