There is a set called "Node". Each element of "Node" has two relations named "left" and "right", and each of these relates a "Node" to zero or more elements of "Node".

For every element of "Node", there is at most one left-related "Node", and at most one "right"-related Node.

"left" and "right" together form an acyclic relation.

Each "Node" has at most one incoming "left"-or-"right" relation from other "Node"s.

Every "Node"'s "left" set is disjoint from its "right" set.

The "left" and "right" relations together form a perfect tree.

For every "Node", the number of "Node"s reachable from it by zero or more "left" steps is equal to the number of "Node"s reachable from it by zero or more "right" steps. 
