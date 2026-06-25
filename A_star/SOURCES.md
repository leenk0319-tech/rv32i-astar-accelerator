# A* References And Attribution

This project's `astar.c` is a project-specific implementation written for the RV32I + MMIO accelerator flow.

No third-party source code is copied into this repository.

## Algorithm References

1. Peter E. Hart, Nils J. Nilsson, and Bertram Raphael, "A Formal Basis for the Heuristic Determination of Minimum Cost Paths", IEEE Transactions on Systems Science and Cybernetics, 1968.

2. Amit J. Patel, "Introduction to the A* Algorithm", Red Blob Games, 2014.
   - https://www.redblobgames.com/pathfinding/a-star/introduction.html

3. General A* search concept:
   - https://en.wikipedia.org/wiki/A*_search_algorithm

## Implementation Notes

The C reference uses the common A* idea:

```text
f(n) = g(n) + h(n)
```

For this FPGA project:

- `g(n)` is the path cost from the start node.
- `h(n)` is Manhattan distance to the goal.
- the grid uses 4-direction movement only.
- arrays use 32-bit words to stay friendly to the current RV32I subset.

The implementation is intentionally not a generic PC-optimized A* library. It is shaped as a future hardware/software co-design reference.

