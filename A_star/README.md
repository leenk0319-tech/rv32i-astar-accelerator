# A* Algorithm Work

This folder contains A* pathfinding reference code for the accelerator side of the SoC project.

## Purpose

The software A* implementation is the behavioral reference for the future hardware accelerator.

Planned use:

1. Validate the algorithm in C first.
2. Decide the hardware/software boundary.
3. Convert the expensive parts of A* into an accelerator datapath.
4. Expose the accelerator to the RV32I CPU through MMIO.

## Current Files

| File | Role |
|---|---|
| `A_star.c` | Initial A* reference implementation |

## Future Hardware Direction

- Grid/map memory layout definition
- Open list / priority selection strategy
- Neighbor expansion datapath
- Cost update logic
- MMIO register map for CPU control

