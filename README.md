
 <img width="741" height="405" alt="image" src="https://github.com/user-attachments/assets/868184ce-2c02-4a97-b2f9-b2adae80f8cb" />

 # 🚀 RISC-V RV32I Single-Cycle CPU 

This project explores computer architecture fundamentals and Verilog HDL implementation. It covers building a **RISC-V (RV32I) Single-Cycle CPU** from scratch (starting from an ALU), alongside **Hardware/Software Co-Design** on the PYNQ-Z2 FPGA platform (featuring a Music Box audio controller and VRAM/HDMI display interface experiments).

---

## 📌 Table of Contents
- [Project Highlights](#-project-highlights)
- [System Architecture](#-system-architecture)
- [RV32I CPU Implementation](#-rv32i-cpu-implementation)
  - [Supported Instruction Set](#supported-instruction-set)
  - [Datapath Stages & Waveform Verification](#datapath-stages--waveform-verification)
- [Peripheral Extensions: VRAM & HDMI](#-peripheral-extensions-vram--hdmi)
- [Key Takeaways & Reflections](#-key-takeaways--reflections)
- [Development Environment](#-development-environment)

---

## 💡 Project Highlights

* **Complete RV32I Datapath**: Designed Program Counter (PC), Instruction/Data Memory, Register File, Immediate Generator, and ALU.
* **Full Instruction Set Support**: Supports standard RV32I types (R-type, I-type, S-type, B-type, U-type, J-type).
* **FPGA HW/SW Co-Design**: Integrated Xilinx Vitis with PYNQ-Z2 for CPU/RAM logic control and hardware DAC audio output.
* **Hardware Display Exploration**: Integrated Clock Wizard, VGA Timing, and TMDS/DVI encoders for VRAM-driven HDMI output.

---

## 🏗 System Architecture

The top-level module (`top`) integrates the CPU Datapath, memory arrays, and peripheral controllers (HDMI Display & Audio DAC).

```text
top
├── clk_wiz_0 u_pll                       // Clock Generator (PLL)
├── CPU datapath (Integrated directly in top)
│   ├── PC u_pc                           // Program Counter
│   ├── IMEM u_imem                       // Instruction Memory (256x32 ROM)
│   ├── decoder_rv32 u_dec                // Instruction Decoder (Opcode/Funct3/Funct7)
│   ├── ImmGen u_immgen                   // Immediate Generator (I/S/B/U/J)
│   ├── RegFile u_rf                      // 32x32-bit Register File
│   ├── ALU_32 u_alu                      // 32-bit Arithmetic Logic Unit
│   ├── data_mem u_dmem                   // Data Memory (64x32 RAM)
│   ├── branch / jump PC select           // Combinational logic: Branch/Jump PC selection
│   └── write-back mux                    // Combinational logic: Write-back MUX
├── inline VRAM array                     // Inline Video RAM Array
├── vga_timing u_vga                      // VGA Timing Controller
├── dvi_generator u_hdmi                  // HDMI / DVI Generator
│   ├── tmds_encoder_dvi x 3              // TMDS Encoders (RGB Channels)
│   ├── async_reset                       // Asynchronous Reset
│   └── serializer_10to1 x 4              // 10:1 Serializers
└── OBUFDS x 4                            // Differential Output Buffers

```

---

##  RV32I CPU Implementation

### 1. Core Datapath Architecture

The CPU operates on a single-cycle architecture covering five standard logic phases:

1. **Instruction Fetch (IF)**: Fetches instructions from IMEM based on PC while computing `PC + 4`.
2. **Instruction Decode (ID)**: Decodes Opcode, Funct3, and Funct7, extracts immediates via ImmGen, and reads source registers from RegFile.
3. **Execute (EX)**: Performs operations via ALU and computes Branch/Jump target addresses.
4. **Memory Access (MEM)**: Performs `LW` (Read) or `SW` (Write) operations on Data Memory.
5. **Write-Back (WB)**: Writes ALU results or loaded memory data back to RegFile.

---

### 2. Supported Instruction Set

The core supports most standard RV32I instructions:

| Instruction Type | Supported Instructions | Description |
| --- | --- | --- |
| **R-type** | `ADD`, `SUB`, `SLL`, `SLT`, `SLTU`, `XOR`, `SRL`, `SRA`, `OR`, `AND` | Register-register arithmetic & logic |
| **I-type Arithmetic** | `ADDI`, `SLTI`, `XORI`, `ORI`, `ANDI`, `SLLI`, `SRLI`, `SRAI` | Immediate arithmetic & logic |
| **I-type Load** | `LW` | Memory load |
| **I-type Jump** | `JALR` | Indirect jump |
| **S-type** | `SW` | Memory store |
| **B-type** | `BEQ`, `BNE` | Conditional branch |
| **U-type** | `LUI`, `AUIPC` | Upper immediate / PC-relative |
| **J-type** | `JAL` | Unconditional jump |

---

### 3. Waveform Verification & Execution Flow

Verification was conducted via Testbench simulation to track state transitions across stages:

* **① Instruction Fetch (IF)**: Upon reset (`PC = 0`), fetches instruction `0x00500093` (`ADDI x1, x0, 5`).
* **② Register Write-back**: Operands written to registers (e.g., `x1 = 5`, `x2 = 7`).
* **③ ALU Execution**: `ADD x3, x1, x2` -> ALU computes `5 + 7 = 12` (`0x0C`) and writes back to `x3`.
* **④ Memory Access**: Triggers `MemWrite` for stores (`SW`) or `MemRead` for loads.
* **⑤ Load Write-back**: `LW` instruction reads data from memory and writes back to `x4`.
* **⑥ Control Flow**: `JAL` instruction updates control signals and calculates `next_pc` for target jump.

---



---

##  Peripheral Extensions: VRAM & HDMI

An experiment to connect the CPU with MMIO/VRAM for display control:

* **Architecture**: Combined Clock Wizard (generating Pixel and Serializer clocks), VGA timing logic, TMDS encoders, `serializer_10to1`, and `OBUFDS` differential buffers.
* **Challenges & Lessons**: HDMI requires precise pixel clocking, TMDS encoding, and strict XDC constraints. While an initial prototype was built using AI assistance and open-source decoders, achieving stable output highlighted the necessity of mastering hardware timing constraints rather than relying solely on assembled modules.

---

##  Key Takeaways & Reflections

> "Complex FPGA system integration must be built on small, understandable, verifiable, and controllable sub-systems. Relying solely on quick AI-generated setups makes long-term maintenance and debugging impossible."

1. **Foundational Hardware Understanding**: Building a complete CPU from an ALU provided deep insight into how hardware coordinates fetch, decode, execute, memory, and write-back cycles under clock signals.
2. **Value of HW/SW Partitioning**: The Music Box lab demonstrated the synergy between software flexibility (high-level decisions/memory management) and hardware determinism (real-time I/O & precise timing).
3. **Rigorous FPGA Debugging**: Overcoming timing issues in HDMI and verifying the audio pipeline reinforced the vital importance of understanding clock domains, memory access patterns, and timing constraints.

---

##  Development Environment

* **Hardware Design Language**: Verilog HDL
* **FPGA Board**: PYNQ-Z2 (Zynq-7000 SoC)
* **EDA & Software Tools**: Xilinx Vivado / Xilinx Vitis
* **Simulation**: Vivado Simulator / ModelSim

---

*Created with by [JIA-RUEI HO/rayho6240-arch]*

```

