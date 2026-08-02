There is a set called "Vertex". Each "Vertex" has at most one "left" value and at most one "right" value.

There are two non-overlapping subsets of "Vertex", named "Joint" and "End". Every vertex is a Joint or an End.

For every "End", either:
- its "left" value is absent, and the "End" is equal to the "left" value of its "right" value ; or
- its "right" value is absent, and the "End" is equal to the "right" value of its "left" value.

For every "Joint":
- following "left" and then "right" returns to that same element, and
- following "right" and then "left" returns to that same element, and
- its "left" value and its "right" value are different.

For every element of "Vertex", the other elements of "Vertex" are exactly those reachable from it either by a nonempty path of only repeated "left" steps or by a nonempty path of only repeated "right" steps; an element is not reachable from itself. 