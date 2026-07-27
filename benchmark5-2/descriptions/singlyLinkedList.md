There are two disjoint sets, "List" and "Node".

Each element of "List" has a relation named "header" to no more than one "Node". 

Each element of "Node" has a relation named "link" to elements of "Node". For any element of "Node", "link" relates it to at most one element of "Node", and it may relate it to none.

For every "List", either the list has no "header", or among the nodes reachable from the "header" by zero or more steps of following "link", there is at least one node whose "link" is absent.