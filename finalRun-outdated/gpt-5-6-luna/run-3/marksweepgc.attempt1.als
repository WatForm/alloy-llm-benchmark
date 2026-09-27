sig Node {}

sig HeapState {
    left: Node -> lone Node,
    right: Node -> lone Node,
    marked: set Node,
    freeList: lone Node
}

one sig h in HeapState {}
one sig hsn in HeapState {}
one sig root in Node {}

pred clearMarks[beforeState, afterState: HeapState] {
    afterState.marked = none
    afterState.left = beforeState.left
    afterState.right = beforeState.right
}

fun reachable[hs: HeapState, from: Node]: set Node {
    from.*(hs.left + hs.right)
}

pred mark[beforeState: HeapState, from: Node, afterState: HeapState] {
    afterState.marked = reachable[beforeState, from]
    afterState.left = beforeState.left
    afterState.right = beforeState.right
}

pred setFreeList[beforeState, afterState: HeapState] {
    afterState.freeList.*(afterState.left) in Node - beforeState.marked

    all n: Node - beforeState.marked | {
        no n.(afterState.right)
        n.(afterState.left) in afterState.freeList.*(afterState.left)
        n in afterState.freeList.*(afterState.left)
    }

    all n: beforeState.marked | {
        n.(afterState.left) = n.(beforeState.left)
        n.(afterState.right) = n.(beforeState.right)
    }

    afterState.marked = beforeState.marked
}

fact {
    some firstState, secondState: HeapState |
        clearMarks[h, firstState] and
        mark[firstState, root, secondState] and
        setFreeList[secondState, hsn]
}