# RISC-V CPU

This folder contains my RV32I CPU work for the A* accelerator SoC project.

## Structure

| Path | Role |
|---|---|
| `code_6_24_25/` | Current active 5-stage pipeline CPU implementation |
| `code_6_23/` | Earlier first bring-up work kept as a development checkpoint |
| `reports/` | Daily reports and portfolio PDFs/DOCX files |

The old `Ryu/` reference folder was removed because it was not my own implementation.

## Current Active Design

Use this folder for current simulation work:

```text
Risc_V/code_6_24_25/
```

Important files:

| File | Role |
|---|---|
| `cpu_core.v` | Top-level CPU datapath wiring |
| `imem.v` | Instruction memory using `$readmemh` |
| `reg_file.v` | 32-register file with x0 fixed to zero |
| `imm_gen.v` | RV32I immediate generator |
| `Control.v` | Main control signal generation |
| `alu_controller.v` | ALU operation decode |
| `alu.v` | Arithmetic/logic operations and branch compare |
| `PC.v` | Next PC selection |
| `bta.v` | Branch target address calculation |
| `IF_ID_reg.v` | IF/ID pipeline register with NOP flush |
| `ID_EX_reg.v` | ID/EX pipeline register with bubble flush |
| `EX_MEM_reg.v` | EX/MEM pipeline register |
| `MEM_WB_reg.v` | MEM/WB pipeline register |
| `dmem.v` | Simple data memory model |
| `program.hex` | Branch verification instruction image |
| `tb_branch_nohazard.v` | Questa branch flush testbench |

## Verified Test

The current branch flush test checks:

- BEQ taken flush
- BNE not-taken fall-through
- BLT taken flush
- BGE taken flush

The test intentionally avoids RAW hazards by inserting NOPs because forwarding/stall logic is not implemented yet.

Expected output:

```text
PASS: branch taken/not-taken flush test without RAW hazards
```

## Current Limitations

- No forwarding unit yet
- No load-use stall unit yet
- JAL/JALR datapath is not complete yet
- MMIO bus and A* accelerator integration are planned, not implemented
