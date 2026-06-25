# A* Reference Model

This folder contains my software reference model for the future A* pathfinding accelerator.

## Files

| File | Role |
|---|---|
| `astar.c` | Hardware-friendly A* reference model |
| `SOURCES.md` | Algorithm references and attribution notes |

## Design Direction

The reference model is intentionally simple and hardware-aware:

- 2D grid
- 4-direction movement
- Manhattan heuristic
- static arrays only
- no malloc
- no recursion
- no floating point
- stable `find_min_node()` boundary for future accelerator replacement

The goal is to use this C model as the golden reference before implementing the accelerator datapath.

## Future Accelerator Split

Likely hardware acceleration target:

```text
find_min_node(open_set, open_count)
```

This step is repeatedly used to select the next node with the smallest `f = g + h` score, making it a natural first accelerator candidate.

