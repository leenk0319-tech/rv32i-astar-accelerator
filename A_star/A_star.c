/*
 * Compatibility wrapper.
 *
 * The canonical A* reference model now lives in sw/astar_ref/astar.c.
 * Keeping this file lets old commands such as
 *   gcc -DASTAR_DEMO A_star/A_star.c
 * continue to work.
 */

#include "../sw/astar_ref/astar.c"
