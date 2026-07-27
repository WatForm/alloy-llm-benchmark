There is a set of atoms called "Node".

There is a set of atoms called "HeapState". Each "HeapState" is connected to at most one "Node" in a relation called "left". Each "HeapState" is connected to at most one "Node" in a relation called "right".
Each "HeapState" is connected to set of "Nodes" in the relation "marked".


Each "HeapState" matches to at most one "Node" by the relation "freeList".

There are two subsets of "HeapState", named "h" and "hsn".

There is exactly one distinguished element named "root".

A condition named clearMarks relates two elements of "HeapState"s, called the before-state and after-state.  This condition 
ensures there are no nodes in the "marked" set of the second "HeapState" and that "left" and "right" fields of the two "HeapState"s are the same.

A derived set named reachable is determined from a "HeapState" and a starting "Node". It is the set containing the starting node together with every "Node" reachable from that starting node by following zero or more steps, where each step may use either the "left" relation or the "right" relation of that "HeapState".

A condition named mark relates a before-state, a starting "Node" called "from", and an after-state, with all of the following requirements:
- the marked set of the after-state is exactly the derived reachable set from "from" in the before-state;
- the after-state has the same "left" relation as the before-state;
- the after-state has the same "right" relation as the before-state.

A condition named setFreeList relates a before-state and an after-state, with all of the following requirements:
- every node reachable from the after-state’s "freeList" by following zero or more "left" steps is an element of "Node" that is not in the marked set of the before-state;
- for every "Node" not in the marked set of the before-state:
  - that node has no outgoing "right" element in the after-state;
  - its "left" successor of the node in the after-state, if any, is reachable from the after-state’s "freeList" by following zero or more "left" steps;
  - the node itself is reachable from the after-state’s "freeList" by following zero or more "left" steps;
- for every "Node" that is in the marked set of the before-state:
  - its "left" successor in the after-state is exactly the same as in the before-state;
  - its "right" successor in the after-state is exactly the same as in the before-state;
- the marked set of the after-state is exactly the same as the marked set of the before-state.

For "h" and "hsn"  and "root", there must be two "HeapState"s such that "h" and the first "HeapState" satisfy the clearMarks condition and the first "HeapState" and "root" and the second "HeapState" satisfy the mark condition and the second "HeapState" and "hsn" satisfy the setFreeList condition.
