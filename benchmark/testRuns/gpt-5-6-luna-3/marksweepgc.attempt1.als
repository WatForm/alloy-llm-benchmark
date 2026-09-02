sig Node {}

one sig root extends Node {}

sig HeapState {
    left: Node -> lone Node,
    right: Node -> lone Node,
    marked: set Node,
    freeList: lone Node
}

one sig h, hsn extends HeapState {}

pred clearMarks[before, after: HeapState] {
    no after.marked
    after.left = before.left
    after.right = before.right
}

fun reachable[hs: HeapState, from: Node]: set Node {
    from.*(hs.left + hs.right)
}

pred mark[before: HeapState, from: Node, after: HeapState] {
    after.marked = reachable[before, from]
    after.left = before.left
    after.right = before.right
}

pred setFreeList[before, after: HeapState] {
    all n: reachable[after, after.freeList] |
        n not in before.marked

    all n: Node - before.marked {
        no n.(after.right)
        n.(after.left) in reachable[after, after.freeList]
        n in reachable[after, after.freeList]
    }

    all n: before.marked {
        n.(after.left) = n.(before.left)
        n.(after.right) = n.(before.right)
    }

    after.marked = before.marked
}

fact {
    some first, second: HeapState |
        clearMarks[h, first] and
        mark[first, root, second] and
        setFreeList[second, hsn]
}