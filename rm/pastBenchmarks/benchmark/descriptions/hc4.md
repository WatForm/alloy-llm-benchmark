This model represents a system of nodes or "Vertices". There are two types of vertices: "Joint" and "End". All "Vertices" are either a "Joint" or an "End". Each vertex may have a left and right connection to other vertices.

There are several constraints in this system:

- "End" vertices may only have one connection, either to the left or the right. If the connection is to the left, then this "End" vertex is also the left-connected vertex of the right-connected vertex of the "End", and vice versa.

- "Joint" vertices must have two connections, one to the left and one to the right. Furthermore, the "Joint" vertex is the left-connected vertex of the right-connected vertex of the joint and the right-connected vertex of the left-connected vertex of the joint. The left-connected and right-connected vertices for a joint cannot be the same.

- All vertices, except for the current vertex, can be reached by following a series of left or right connections from the current vertex.

The model includes a helper function, "neighbors", which returns the set of vertices directly connected to a given vertex.

Lastly, the model includes a predicate called "show", which specifies a condition that the total number of vertices is greater than zero. An Alloy command is provided to execute the "show" predicate with a scope of 5 vertices.