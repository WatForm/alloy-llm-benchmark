```alloy
sig Node {}

sig HeapState {
    left: Node -> lone Node,
    right: Node -> lone Node,
    marked: set Node,
    freeList: lone Node
}

one sig h, hsn extends HeapState {}

one sig root extends Node {}

pred clearMarks [before: HeapState, after: HeapState] {
    no after.marked
    after.left = before.left
    after.right = before.right
}

fun reachable [s: HeapState, from: Node]: set Node {
    from.*(s.left + s.right)
}

pred mark [before: HeapState, from: Node, after: HeapState] {
    after.marked = reachable[before, from]
    after.left = before.left
    after.right = before.right
}

pred setFreeList [before: HeapState, after: HeapState] {
    after.freeList.*(after.left) in (Node - before.marked)
    all n: Node - before.marked {
        no n.(after.right)
        n.(after.left) in after.freeList.*(after.left)
        n in after.freeList.*(after.left)
    }
    all n: before.marked {
        n.(after.left) = n.(before.left)
        n.(after.right) = n.(before.right)
    }
    after.marked = before.marked
}

fact {
    some s1, s2: HeapState {
        clearMarks[h, s1]
        mark[s1, root, s2]
        setFreeList[s2, hsn]
    }
}
```