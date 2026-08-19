sig Node {}

sig HeapState {
    left: Node -> lone Node,
    right: Node -> lone Node,
    marked: set Node,
    freeList: lone Node
}

one sig h, hsn in HeapState {}

one sig root in Node {}

pred clearMarks[before, after: HeapState] {
    no after.marked
    before.left = after.left
    before.right = after.right
}

fun reachable[hs: HeapState, start: Node]: set Node {
    start.*(hs.left + hs.right)
}

pred mark[before: HeapState, from: Node, after: HeapState] {
    after.marked = reachable[before, from]
    after.left = before.left
    after.right = before.right
}

pred setFreeList[before, after: HeapState] {
    reachable[after, after.freeList] in Node - before.marked

    all n: Node - before.marked | {
        no n.(after.right)
        n.(after.left) in reachable[after, after.freeList]
        n in reachable[after, after.freeList]
    }

    all n: before.marked | {
        n.(after.left) = n.(before.left)
        n.(after.right) = n.(before.right)
    }

    after.marked = before.marked
}

fact {
    some first, second: HeapState | {
        clearMarks[h, first]
        mark[first, root, second]
        setFreeList[second, hsn]
    }
}