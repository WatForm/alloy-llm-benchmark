sig Node {}

sig HeapState {
    left: Node -> lone Node,
    right: Node -> lone Node,
    marked: set Node,
    freeList: lone Node
}

one sig h, hsn in HeapState {}

one sig root extends Node {}

fun reachable[hs: HeapState, start: Node]: set Node {
    start.*(hs.left + hs.right)
}

pred clearMarks[beforeState, afterState: HeapState] {
    no afterState.marked
    beforeState.left = afterState.left
    beforeState.right = afterState.right
}

pred mark[beforeState: HeapState, from: Node, afterState: HeapState] {
    afterState.marked = reachable[beforeState, from]
    afterState.left = beforeState.left
    afterState.right = beforeState.right
}

pred setFreeList[beforeState, afterState: HeapState] {
    afterState.freeList.*afterState.left in Node - beforeState.marked
    all n: Node - beforeState.marked | {
        no n.(afterState.right)
        n.(afterState.left) in afterState.freeList.*afterState.left
        n in afterState.freeList.*afterState.left
    }
    all n: beforeState.marked | {
        n.(afterState.left) = n.(beforeState.left)
        n.(afterState.right) = n.(beforeState.right)
    }
    afterState.marked = beforeState.marked
}

fact {
    some first, second: HeapState |
        clearMarks[h, first] and
        mark[first, root, second] and
        setFreeList[second, hsn]
}