/*
 * Static-array A* reference model for a RISC-V + MMIO accelerator project.
 *
 * References:
 * - Hart, Nilsson, Raphael, "A Formal Basis for the Heuristic
 *   Determination of Minimum Cost Paths", 1968.
 * - Amit J. Patel, "Introduction to the A* Algorithm", Red Blob Games.
 *
 * This file is a project-specific implementation. No third-party source code
 * is copied into this repository.
 *
 * Design goals:
 * - 2D grid only
 * - 4-direction movement only
 * - Manhattan heuristic only
 * - no malloc, no recursion, no floating point
 * - explicit find_min_node() boundary for a later MMIO accelerator
 *
 * Grid rule:
 * - grid[y * width + x] == 0: passable
 * - grid[y * width + x] != 0: blocked
 *
 * RV32I subset note:
 * - The project CPU currently has a lw/sw-centered memory path.
 * - Therefore all persistent arrays use 32-bit words instead of uint8_t or
 *   uint16_t, avoiding compiler-generated lb/lbu/sb/lh/lhu/sh instructions.
 * - Address helpers avoid runtime multiply, divide, and modulo so the core
 *   algorithm stays friendly to a small RV32I subset without the M extension.
 *
 * Classification:
 * - Use this first as a PC-side golden model and accelerator reference.
 * - Do not assume that generic RISC-V GCC output will run on the current
 *   small instruction subset without inspecting the generated assembly.
 */

#include <stdint.h>

#ifndef ASTAR_MAX_WIDTH
#define ASTAR_MAX_WIDTH 8
#endif

#ifndef ASTAR_MAX_HEIGHT
#define ASTAR_MAX_HEIGHT 8
#endif

#define ASTAR_MAX_NODES (ASTAR_MAX_WIDTH * ASTAR_MAX_HEIGHT)
#define ASTAR_INF       0x3fffffffU
#define ASTAR_FREE      0U

#ifndef ASTAR_USE_MMIO
#define ASTAR_USE_MMIO 0
#endif

#if ASTAR_USE_MMIO
#ifndef ASTAR_ACC_BASE
#define ASTAR_ACC_BASE 0x10000000U
#endif

#define ASTAR_ACC_CTRL       (*(volatile uint32_t *)(ASTAR_ACC_BASE + 0x00U))
#define ASTAR_ACC_STATUS     (*(volatile uint32_t *)(ASTAR_ACC_BASE + 0x04U))
#define ASTAR_ACC_NODE_BASE  (*(volatile uint32_t *)(ASTAR_ACC_BASE + 0x08U))
#define ASTAR_ACC_OPEN_COUNT (*(volatile uint32_t *)(ASTAR_ACC_BASE + 0x0CU))
#define ASTAR_ACC_STRIDE     (*(volatile uint32_t *)(ASTAR_ACC_BASE + 0x10U))
#define ASTAR_ACC_MIN_INDEX  (*(volatile uint32_t *)(ASTAR_ACC_BASE + 0x14U))

#define ASTAR_ACC_CTRL_START      0x00000001U
#define ASTAR_ACC_CTRL_CLEAR_DONE 0x00000002U
#define ASTAR_ACC_STATUS_DONE     0x00000001U
#endif

typedef struct {
    int x;
    int y;
} AStarPoint;

typedef enum {
    ASTAR_OK = 0,
    ASTAR_NO_PATH = 1,
    ASTAR_BAD_INPUT = 2,
    ASTAR_PATH_TOO_SMALL = 3,
    ASTAR_ACCEL_ERROR = 4
} AStarStatus;

/*
 * The accelerator-friendly open-list record.
 *
 * Keep this layout stable if hardware reads the array directly:
 * word 0: node id
 * word 1: f score
 * word 2: h score, used only for deterministic tie-breaking
 */
typedef struct {
    uint32_t node;
    uint32_t f;
    uint32_t h;
} AStarOpenRec;

typedef struct {
    uint32_t g_score[ASTAR_MAX_NODES];
    int32_t parent[ASTAR_MAX_NODES];
    int32_t open_pos[ASTAR_MAX_NODES];
    uint32_t closed[ASTAR_MAX_NODES];
    AStarOpenRec open_set[ASTAR_MAX_NODES];
} AStarWorkspace;

static AStarWorkspace g_astar_ws;

static int astar_abs(int value)
{
    return (value < 0) ? -value : value;
}

static int astar_in_bounds(int x, int y, int width, int height)
{
    return x >= 0 && x < width && y >= 0 && y < height;
}

static uint32_t astar_node_id(int x, int y, int width)
{
    uint32_t node;
    int row;

    node = (uint32_t)x;
    for (row = 0; row < y; ++row) {
        node += (uint32_t)width;
    }

    return node;
}

static AStarPoint astar_point_from_node(uint32_t node, int width)
{
    AStarPoint p;

    p.y = 0;
    while (node >= (uint32_t)width) {
        node -= (uint32_t)width;
        ++p.y;
    }

    p.x = (int)node;
    return p;
}

static int astar_area(int width, int height)
{
    int total;
    int row;

    total = 0;
    for (row = 0; row < height; ++row) {
        total += width;
    }

    return total;
}

static uint32_t astar_manhattan(AStarPoint a, AStarPoint b)
{
    return (uint32_t)(astar_abs(a.x - b.x) + astar_abs(a.y - b.y));
}

static void astar_workspace_init(AStarWorkspace *ws, int total_nodes)
{
    int i;

    for (i = 0; i < total_nodes; ++i) {
        ws->g_score[i] = ASTAR_INF;
        ws->parent[i] = -1;
        ws->open_pos[i] = -1;
        ws->closed[i] = 0U;
        ws->open_set[i].node = 0U;
        ws->open_set[i].f = ASTAR_INF;
        ws->open_set[i].h = ASTAR_INF;
    }
}

static int find_min_node_sw(const AStarOpenRec *open_set, int open_count)
{
    int best;
    int i;

    if (open_count <= 0) {
        return -1;
    }

    best = 0;
    for (i = 1; i < open_count; ++i) {
        if (open_set[i].f < open_set[best].f) {
            best = i;
        } else if (open_set[i].f == open_set[best].f &&
                   open_set[i].h < open_set[best].h) {
            best = i;
        } else if (open_set[i].f == open_set[best].f &&
                   open_set[i].h == open_set[best].h &&
                   open_set[i].node < open_set[best].node) {
            best = i;
        }
    }

    return best;
}

int astar_find_min_node_ref(const AStarOpenRec *open_set, int open_count)
{
    return find_min_node_sw(open_set, open_count);
}

#if ASTAR_USE_MMIO
static void acc_clear_done(void)
{
    ASTAR_ACC_CTRL = ASTAR_ACC_CTRL_CLEAR_DONE;
    ASTAR_ACC_CTRL = 0U;
}

/*
 * MMIO mode assumes the accelerator can read the CPU data memory address
 * written to ASTAR_ACC_NODE_BASE. That usually means dual-port DMEM or a
 * shared-memory bus. For a slave-only accelerator, keep ASTAR_USE_MMIO at 0
 * here and feed the accelerator's internal open RAM from assembly/MMIO writes.
 */
static int acc_find_min_node(const AStarOpenRec *open_set, int open_count)
{
    acc_clear_done();

    ASTAR_ACC_NODE_BASE = (uint32_t)(uintptr_t)open_set;
    ASTAR_ACC_OPEN_COUNT = (uint32_t)open_count;
    ASTAR_ACC_STRIDE = (uint32_t)sizeof(AStarOpenRec);
    ASTAR_ACC_CTRL = ASTAR_ACC_CTRL_START;

    while ((ASTAR_ACC_STATUS & ASTAR_ACC_STATUS_DONE) == 0U) {
    }

    {
        int min_index;

        min_index = (int)ASTAR_ACC_MIN_INDEX;
        acc_clear_done();
        return min_index;
    }
}
#endif

static int find_min_node(const AStarOpenRec *open_set, int open_count)
{
#if ASTAR_USE_MMIO
    return acc_find_min_node(open_set, open_count);
#else
    return find_min_node_sw(open_set, open_count);
#endif
}

static void open_remove_at(AStarWorkspace *ws, int *open_count, int index)
{
    uint32_t removed_node;
    int last;

    removed_node = ws->open_set[index].node;
    last = *open_count - 1;

    if (index != last) {
        ws->open_set[index] = ws->open_set[last];
        ws->open_pos[ws->open_set[index].node] = index;
    }

    ws->open_pos[removed_node] = -1;
    *open_count = last;
}

static void open_add_or_update(AStarWorkspace *ws,
                               int *open_count,
                               uint32_t node,
                               uint32_t f,
                               uint32_t h)
{
    int pos;

    pos = ws->open_pos[node];
    if (pos >= 0) {
        ws->open_set[pos].f = f;
        ws->open_set[pos].h = h;
        return;
    }

    pos = *open_count;
    ws->open_set[pos].node = node;
    ws->open_set[pos].f = f;
    ws->open_set[pos].h = h;
    ws->open_pos[node] = pos;
    *open_count = pos + 1;
}

static AStarStatus astar_reconstruct_path(const AStarWorkspace *ws,
                                          uint32_t goal_node,
                                          int width,
                                          int total_nodes,
                                          AStarPoint *path,
                                          int path_capacity,
                                          int *path_length)
{
    uint32_t node;
    int length;
    int guard;
    int write_index;

    length = 0;
    guard = 0;
    node = goal_node;

    while (1) {
        ++length;
        ++guard;

        if (ws->parent[node] < 0) {
            break;
        }

        if (guard > total_nodes) {
            return ASTAR_BAD_INPUT;
        }

        node = (uint32_t)ws->parent[node];
    }

    *path_length = length;

    if (path_capacity < length) {
        return ASTAR_PATH_TOO_SMALL;
    }

    node = goal_node;
    write_index = length - 1;
    while (write_index >= 0) {
        path[write_index] = astar_point_from_node(node, width);

        if (ws->parent[node] < 0) {
            break;
        }

        node = (uint32_t)ws->parent[node];
        --write_index;
    }

    return ASTAR_OK;
}

AStarStatus astar_search(const uint32_t *grid,
                         int width,
                         int height,
                         AStarPoint start,
                         AStarPoint goal,
                         AStarPoint *path,
                         int path_capacity,
                         int *path_length)
{
    static const int dx[4] = { 1, -1, 0, 0 };
    static const int dy[4] = { 0, 0, 1, -1 };

    AStarWorkspace *ws;
    uint32_t start_node;
    uint32_t goal_node;
    int total_nodes;
    int open_count;
    int dir;

    if (path_length == 0) {
        return ASTAR_BAD_INPUT;
    }

    *path_length = 0;

    if (grid == 0 || path == 0 || path_capacity <= 0) {
        return ASTAR_BAD_INPUT;
    }

    if (width <= 0 || height <= 0 ||
        width > ASTAR_MAX_WIDTH || height > ASTAR_MAX_HEIGHT) {
        return ASTAR_BAD_INPUT;
    }

    if (!astar_in_bounds(start.x, start.y, width, height) ||
        !astar_in_bounds(goal.x, goal.y, width, height)) {
        return ASTAR_BAD_INPUT;
    }

    total_nodes = astar_area(width, height);
    start_node = astar_node_id(start.x, start.y, width);
    goal_node = astar_node_id(goal.x, goal.y, width);

    if (grid[start_node] != ASTAR_FREE || grid[goal_node] != ASTAR_FREE) {
        return ASTAR_NO_PATH;
    }

    ws = &g_astar_ws;
    astar_workspace_init(ws, total_nodes);

    open_count = 0;
    ws->g_score[start_node] = 0U;
    open_add_or_update(ws,
                       &open_count,
                       start_node,
                       astar_manhattan(start, goal),
                       astar_manhattan(start, goal));

    while (open_count > 0) {
        int current_open_index;
        uint32_t current_node;
        AStarPoint current_point;

        current_open_index = find_min_node(ws->open_set, open_count);
        if (current_open_index < 0 || current_open_index >= open_count) {
            return ASTAR_ACCEL_ERROR;
        }

        current_node = ws->open_set[current_open_index].node;

        if (current_node == goal_node) {
            return astar_reconstruct_path(ws,
                                          goal_node,
                                          width,
                                          total_nodes,
                                          path,
                                          path_capacity,
                                          path_length);
        }

        open_remove_at(ws, &open_count, current_open_index);
        ws->closed[current_node] = 1U;
        current_point = astar_point_from_node(current_node, width);

        for (dir = 0; dir < 4; ++dir) {
            AStarPoint next_point;
            uint32_t next_node;
            uint32_t tentative_g;
            uint32_t h;

            next_point.x = current_point.x + dx[dir];
            next_point.y = current_point.y + dy[dir];

            if (!astar_in_bounds(next_point.x, next_point.y, width, height)) {
                continue;
            }

            next_node = astar_node_id(next_point.x, next_point.y, width);

            if (grid[next_node] != ASTAR_FREE || ws->closed[next_node] != 0U) {
                continue;
            }

            tentative_g = ws->g_score[current_node] + 1U;
            if (ws->open_pos[next_node] < 0 ||
                tentative_g < ws->g_score[next_node]) {
                ws->parent[next_node] = (int32_t)current_node;
                ws->g_score[next_node] = tentative_g;
                h = astar_manhattan(next_point, goal);
                open_add_or_update(ws,
                                   &open_count,
                                   next_node,
                                   tentative_g + h,
                                   h);
            }
        }
    }

    return ASTAR_NO_PATH;
}

#ifdef ASTAR_DEMO
#include <stdio.h>

static void print_result(AStarStatus status,
                         const AStarPoint *path,
                         int path_length)
{
    int i;

    printf("status=%d path_length=%d\n", (int)status, path_length);
    for (i = 0; i < path_length; ++i) {
        printf("(%d,%d)%s",
               path[i].x,
               path[i].y,
               (i + 1 == path_length) ? "\n" : " -> ");
    }
}

int main(void)
{
    uint32_t grid[ASTAR_MAX_WIDTH * ASTAR_MAX_HEIGHT] = { 0 };
    AStarPoint path[ASTAR_MAX_NODES];
    AStarPoint start = { 0, 0 };
    AStarPoint goal = { 7, 7 };
    AStarStatus status;
    int path_length;
    int width = 8;
    int height = 8;

    grid[1 * width + 2] = 1;
    grid[2 * width + 2] = 1;
    grid[3 * width + 2] = 1;
    grid[4 * width + 2] = 1;
    grid[5 * width + 2] = 1;
    grid[5 * width + 3] = 1;
    grid[5 * width + 4] = 1;

    status = astar_search(grid,
                          width,
                          height,
                          start,
                          goal,
                          path,
                          ASTAR_MAX_NODES,
                          &path_length);

    print_result(status, path, path_length);
    return (status == ASTAR_OK) ? 0 : 1;
}
#endif
