# Learn to Build an AI-Based Traffic Signal Controller using VLSI

A synthesizable Verilog RTL learning project that demonstrates density-adaptive traffic signal timing, a finite-state machine (FSM), a reusable timer, pedestrian-request handling, and a simulation testbench.

> **Important scope note:** this project implements a small rule-based/heuristic density classifier and controller. It does not contain a trained machine-learning model or camera-based vehicle detection. In a real deployment, a camera/edge-AI module would estimate the vehicle count and supply it to `traffic_system_with_count`.

## Project structure

```text
traffic_signal_ai_vlsi/
├── rtl/
│   ├── traffic_timer.v
│   ├── density_logic.v
│   ├── traffic_fsm_final.v
│   ├── traffic_system_top_final.v
│   └── traffic_system_with_count.v
├── tb/
│   ├── traffic_system_tb_final.v
│   └── density_tb.v
└── docs/
    └── PROJECT_REPORT.md
```

## Functional overview

- **Density classifier:** vehicle count `0–9` → low (`00`), `10–29` → medium (`01`), and `30+` → high (`10`).
- **Green timing:** low density = 5 clock cycles, medium = 10 cycles, high = 20 cycles.
- **Yellow timing:** 3 cycles.
- **Red timing:** 8 cycles.
- **Pedestrian phase:** 6 cycles, with the vehicle red output asserted.
- **Pedestrian request:** latched until the next red-phase decision; served before returning to green.
- **Reset:** active-high asynchronous reset.

These are simulation-friendly cycle counts, not real-world seconds. For hardware, choose timing parameters based on the FPGA clock frequency and safety requirements.

## RTL module interfaces

### `traffic_system_top_final`
Inputs: `clk`, `reset`, `vehicle_density[1:0]`, `pedestrian_request`.
Outputs: `red`, `yellow`, `green`, `pedestrian_active`.

### `traffic_system_with_count`
Inputs: `clk`, `reset`, `vehicle_count[7:0]`, `pedestrian_request`.
Outputs: `red`, `yellow`, `green`, `pedestrian_active`.

Use `traffic_system_with_count` when you want the included density classifier in the path. Use `traffic_system_top_final` if another module already provides the density class.

## Run simulation with Icarus Verilog

Install Icarus Verilog (`iverilog` and `vvp`), then run from the project root:

```bash
iverilog -g2012 -o traffic_sim \
  rtl/traffic_timer.v rtl/traffic_fsm_final.v \
  rtl/traffic_system_top_final.v tb/traffic_system_tb_final.v
vvp traffic_sim
```

To generate a waveform, the testbench writes `traffic_system.vcd`. Open it with GTKWave:

```bash
gtkwave traffic_system.vcd
```

Test the density classifier separately:

```bash
iverilog -g2012 -o density_sim rtl/density_logic.v tb/density_tb.v
vvp density_sim
```

To compile the wrapper too, include `rtl/density_logic.v` and `rtl/traffic_system_with_count.v` in your project source list.

## Suggested FPGA workflow

1. Create a project in Vivado, Quartus, or your course-required tool.
2. Add all files in `rtl/` as design sources and the relevant file in `tb/` as a simulation source.
3. Set `traffic_system_top_final` as the top module for density-class input, or `traffic_system_with_count` for raw count input.
4. Run behavioral simulation and inspect the output waveform.
5. For FPGA implementation, add a clock constraint and pin assignments for the board. Do not connect real road signals without a certified safety design, independent fault handling, and professional review.

## Verification checks included

The system testbench prints signal changes, writes a VCD waveform, and checks that green and yellow are not active simultaneously and that the pedestrian phase always asserts red. The density testbench exercises threshold values around 10 and 30.
