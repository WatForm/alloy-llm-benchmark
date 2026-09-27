` or `reachable[h, n]`?
In `mark`:
"the marked set of the after-state is exactly the derived reachable set from "from" in the before-state;"
So:
`after.marked = reachable[before, from]`

Now let's check `clearMarks`:
"A condition named clearMarks relates two elements of "HeapState"s, called the before-state and after-state. This condition 
ensures there are no nodes in the "marked" set of the second "HeapState" and that "left" and "right" fields of the two "HeapState"s are the same."

Let's write `clearMarks`:
```alloy
pred clearMarks [before, after: HeapState] {
    no after.marked
    after.left = before.left
    after.right = before.right
}
```
Wait, could it be:
`pred clearMarks [before: HeapState, after: HeapState]`?
`before, after: HeapState` and `before: HeapState, after: HeapState` are identical in Alloy.

Now let's check `mark`:
"A condition named mark relates a before-state, a starting "Node" called "from", and an after-state, with all of the following requirements:
- the marked set of the after-state is exactly the derived reachable set from "from" in the before-state;
- the after-state has the same "left" relation as the before-state;
- the after-state has the same "right" relation as the before-state."

Let's write `mark`:
```alloy
pred mark [before: HeapState, from: Node, after: HeapState] {
    after.marked = reachable[before, from]
    after.left = before.left
    after.right = before.right
}
```

Now let's check `setFreeList`:
"A condition named setFreeList relates a before-state and an after-state, with all of the following requirements:
- every node reachable from the after-state’s "freeList" by following zero or more "left" steps is an element of "Node" that is not in the marked set of the before-state;
- for every "Node" not in the marked set of the before-state:
  - that node has no outgoing "right" element in the after-state;
  - its "left" successor of the node in the after-state, if any, is reachable from the after-state’s "freeList" by following zero or more "left" steps;
  - the node itself is reachable from the after-state’s "freeList" by following zero or more "left" steps;
- for every "Node" that is in the marked set of the before-state:
  - its "left" successor in the after-state is exactly the same as in the before-state;
  - its "right" successor in the after