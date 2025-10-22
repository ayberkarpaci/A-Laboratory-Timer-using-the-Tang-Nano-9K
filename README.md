# A-Laboratory-Timer-using-the-Tang-Nano-9K
A fully schematic laboratory timer in MM:SS format designed on Digital and implemented on the Tang Nano 9K FPGA board.

## 📘 Project Overview

This project implements a **Laboratory Timer** on the **Tang Nano 9K FPGA board**, designed fully in **Digital** without using Verilog modules.  
The timer measures and displays elapsed time in **MM:SS** format and supports both **countdown** and **overtime** counting.

---

### 🎯 Key Features

#### 🧭 Set Mode
- Each digit (**M10**, **M1**, **S10**, **S1**) can be incremented individually using push buttons.  
- **M10**, **M1**, and **S1** roll over after **9**; **S10** rolls over after **5**.

#### ⏱️ Run Mode
- Starts countdown from the set time value.  
- After reaching **00:00**, automatically counts **upward** to measure overtime.

#### 🔁 Mode Switching
- **Toggle switch** selects between `SET` and `RUN` modes.  
- Switching back to **SET** stops counting and allows adjusting the digits.

#### ⏰ Clock Source
- **Master clock:** 100 Hz in simulation (Digital)  
- **Real hardware:** 27 MHz on Tang Nano 9K  
- **Time base signal:** `HZ1` – 1 Hz pulse used for actual counting

---

## ⚙️ Design Implementation

### 🧩 Tools Used
- **Digital** – schematic design and simulation  
- **OSS CAD Suite / VS Code / Makefile** – FPGA synthesis and upload  
- **Tang Nano 9K FPGA board** (Gowin GW1NR-9C device)

---

### 🧠 Design Structure
- **Top-level file:** `testbench.dig`  
- **Main design block:** `labtimer.dig`  
- **Verilog export:** `labtimer.v` (auto-generated from Digital)

#### 🔹 Inputs
- `M10`, `M1`, `S10`, `S1` — digit increment buttons  
- `SW_MODE` — toggle switch (`SET` / `RUN`)  
- `CLK` — master clock  
- `HZ1` — 1 Hz pulse

#### 🔸 Outputs
- 4-digit **7-segment display** signals for `MM:SS`

---

### 🧱 Internal Modules (schematic level)
- 4 × **BCD counters** (`MM10`, `MM1`, `SS10`, `SS1`)  
- **Multiplexed display decoder**  
- **Mode controller FSM**  
- **Up/Down control logic**  
- **Borrow/Carry propagation** between digits

