How would that look without Djikstra?

Assumption: a graph is an array of edges, where an edge is a tuple of (node, node)

To find the shortest valid paths in a graph `g` from node `a` to `b`:

1. separate the graph into three:
 * `startig` - all edges where `edge.0 == a`
 * `ending` - all edges where `edge.1 == b`
 * `remaining` - all other edges
2. find all edges in `starting` that are also contained in `ending`
2. - if not empty, return that array
3. find all edges in `remaining` that connect (`remaining.a - starting.a`) to any edges in starting as `nextStart` and remove it from `remaining`
4. find all edges in `remaining` that connect (`remaining.b - ending.a`) th ending as `nextEnd` and remove it from `remaining`
5. restart the search from Point 2 with the nex `starting`, `remaining` and `ending` arrays

