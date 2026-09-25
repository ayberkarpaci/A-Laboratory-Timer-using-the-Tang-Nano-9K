# Laboratory Timer on the Tang Nano 9K

[![simulation](https://github.com/ayberkarpaci/fpga-lab-timer/actions/workflows/sim.yml/badge.svg)](https://github.com/ayberkarpaci/fpga-lab-timer/actions/workflows/sim.yml)

A laboratory timer in **MM:SS** format, designed as a gate-level schematic in
[Digital](https://github.com/hneemann/Digital) and implemented on the
**Tang Nano 9K** FPGA board (Gowin GW1NR-9C). The timer counts down from a
set value and, after reaching `00:00`, keeps counting **up** to show the
overtime.

## Features

**Set mode** (`SW = 1`)
- Each digit (M10, M1, S10, S1) has its own push button and increments by one
  per press (buttons are edge-detected, so holding a button counts once).
- M10, M1 and S1 wrap after 9; S10 wraps after 5.

**Run mode** (`SW = 0`)
- Counts down once per second from the set value, with borrow between digits
  (`10:00 → 09:59`).
- At `00:00` the direction flips and the timer counts up with carry
  (`00:59 → 01:00`) to measure overtime.
- Buttons are ignored while running.
- Switching back to set mode freezes the display and resets the direction, so
  the next run counts down again.

## Interface

| Port | Dir | Width | Description |
|---|---|---|---|
| `CLK` | in | 1 | Master clock (27 MHz on the board, 100 Hz in Digital) |
| `HZ1` | in | 1 | 1 Hz time base; the design counts on its rising edge |
| `SW` | in | 1 | Mode switch: `1` = set, `0` = run |
| `B3` `B2` `B1` `B0` | in | 1 | Increment buttons for M10, M1, S10, S1 |
| `M10` `M1` `S10` `S1` | out | 4 | Current time, one BCD digit per output |

## Design

- Four 4-bit **BCD digit registers**. In set mode each register loads
  `digit + 1` (or 0 at its limit) on its button edge; in run mode it loads
  `digit ± 1` with wrap values 9 / 5 on the 1 Hz edge.
- A **borrow/carry chain** enables a digit only when all lower digits are at
  their wrap value (0 when counting down, 9 or 5 when counting up).
- A one-bit **direction register** (`count_dir`) becomes 1 when all digits are
  zero during a countdown and is cleared in set mode.
- **Edge detectors** (a D flip-flop plus an AND gate) turn the buttons and the
  1 Hz signal into single-cycle pulses in the `CLK` domain.

## Files

| File | Contents |
|---|---|
| `labtimer.dig` | Schematic, open with Digital |
| `labtimer.v` | Verilog exported from the schematic by Digital |
| `sim/labtimer_tb.v` | Self-checking testbench |

## Simulation

The testbench covers digit wrap-around in set mode, countdown, the switch to
overtime, borrow and carry across digits, and a second run after an overtime
run. It runs in CI on every push; locally:

```bash
iverilog -g2012 -o labtimer_tb sim/labtimer_tb.v labtimer.v
vvp labtimer_tb
```

## Tools

- Digital for schematic design, simulation and Verilog export
- OSS CAD Suite (Yosys, nextpnr-gowin, openFPGALoader) for synthesis and upload
- Icarus Verilog for the testbench
