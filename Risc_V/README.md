# RISC-V CPU Work

This folder contains the RV32I CPU implementation history for the FPGA SoC project.

## Folder Map

| Folder | Description |
|---|---|
| `6_23/` | Initial single-cycle style CPU experiment and basic register writeback simulation |
| `6_24_25/` | Current 5-stage pipeline implementation with branch flush verification |
| `Ryu/` | Reference/study materials and external pipeline examples |

## Current Main Design

Use `Risc_V/6_24_25/` as the current working design.

Important files:

- `cpu_core.v`: top-level CPU datapath wiring
- `imem.v`: instruction memory using `$readmemh`
- `reg_file.v`: 32-register file with x0 fixed to zero
- `imm_gen.v`: RV32I immediate generator
- `Control.v`: main control signal generation
- `alu_controller.v`: ALU operation decode
- `alu.v`: arithmetic, logic, and branch compare logic
- `PC.v`: next PC selection
- `bta.v`: branch target address calculation
- `IF_ID_reg.v`, `ID_EX_reg.v`, `EX_MEM_reg.v`, `MEM_WB_reg.v`: pipeline registers
- `program.hex`: branch verification program
- `tb_branch_nohazard.v`: Questa testbench

## Verified Behavior

The current branch test checks:

- BEQ taken flush
- BNE not taken fall-through
- BLT taken flush
- BGE taken flush

The test intentionally avoids RAW hazards by inserting NOP instructions.

