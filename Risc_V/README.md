# RISC-V CPU

This folder contains my RV32I CPU work for the A* accelerator SoC project.

## Structure

| Path | Role |
|---|---|
| `code_6_27-7_01/` | Final RV32I 5-stage pipelined CPU implementation and proof tests |
| `code_6_26/` | Data hazard and forwarding development checkpoint |
| `code_6_24_25/` | Earlier branch/flush pipeline checkpoint |
| `code_6_23/` | Earlier first bring-up work kept as a development checkpoint |
| `reports/` | Daily reports and portfolio PDFs/DOCX files |

The old `Ryu/` reference folder was removed because it was not my own implementation.

## Current Active Design

Use this folder for current simulation work:

```text
Risc_V/code_6_27-7_01/
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
| `bta_jta.v` | Branch and jump target address calculation |
| `IF_ID_reg.v` | IF/ID pipeline register with NOP flush |
| `ID_EX_reg.v` | ID/EX pipeline register with bubble flush |
| `EX_MEM_reg.v` | EX/MEM pipeline register |
| `MEM_WB_reg.v` | MEM/WB pipeline register |
| `dmem.v` | Simple data memory model |
| `hazard_detect.v` | Load-use stall detection |
| `EX_forwarding_unit.v` | EX-stage data forwarding control |
| `ID_fowarding_unit.v` | ID-stage branch/JALR forwarding and stall control |
| `branch_detect.v` | ID-stage branch/jump redirect and flush decision |
| `program_final_pipeline_proof.hex` | Final integrated verification program |
| `tb_final_pipeline_proof.v` | Final Questa integrated proof testbench |

## Verified Test

The final integrated test checks:

- R-type and I-type ALU instructions
- LUI upper immediate writeback
- JAL and JALR PC redirect with PC+4 link writeback
- LW/SW data memory behavior
- EX-stage forwarding
- Load-use stall
- ID-stage branch decision and flush

Expected output:

```text
PASS: final integrated pipeline proof - ALU, LUI, jumps, branches, load-use, forwarding, LW/SW
```

Run it in Questa:

```tcl
cd D:/Programs/vscode_workspace/Soc_Project
vlib work
vlog Risc_V/code_6_27-7_01/*.v
vsim work.tb_final_pipeline_proof
run -all
```

## Remaining System Work

The standalone CPU core is complete enough to freeze as the baseline for this project. The next project step is not more CPU datapath work, but connecting the CPU to the A* accelerator through an MMIO-style interface.
