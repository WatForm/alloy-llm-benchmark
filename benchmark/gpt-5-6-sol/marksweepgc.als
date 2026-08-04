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
    no afterState.marked
    beforeState.left = afterState.left
    beforeState.right = afterState.right
}

fun reachable[state: HeapState, from: Node]: set Node {
    from.*(state.left + state.right)
}

pred mark[beforeState: HeapState, from: Node, afterState: HeapState] {
    afterState.marked = reachable[beforeState, from]
    afterState.left = beforeState.left
    afterState.right = beforeState.right
}

pred setFreeList[beforeState, afterState: HeapState] {
    afterState.freeList.*(afterState.left) in Node - beforeState.marked

    all node: Node - beforeState.marked {
        no node.(afterState.right)
        node.(afterState.left) in afterState.freeList.*(afterState.left)
        node in afterState.freeList.*(afterState.left)
    }

    all node: beforeState.marked {
        node.(afterState.left) = node.(beforeState.left)
        node.(afterState.right) = node.(beforeState.right)
    }

    afterState.marked = beforeState.marked
}

fact {
    some firstState, secondState: HeapState {
        clearMarks[h, firstState]
        mark[firstState, root, secondState]
        setFreeList[secondState, hsn]
    }
}