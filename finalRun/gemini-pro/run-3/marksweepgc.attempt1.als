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

pred clearMarks[before, after: HeapState] {
    no after.marked
    after.left = before.left
    after.right = before.right
}

fun reachable[s: HeapState, n: Node]: set Node {
    n.*(s.left + s.right)
}

pred mark[before: HeapState, from: Node, after: HeapState] {
    after.marked = reachable[before, from]
    after.left = before.left
    after.right = before.right
}

pred setFreeList[before, after: HeapState] {
    after.freeList.*(after.left) in Node - before.marked
    all n: Node - before.marked | {
        no n.(after.right)
        n.(after.left) in after.freeList.*(after.left)
        n in after.freeList.*(after.left)
    }
    all n: before.marked | {
        n.(after.left) = n.(before.left)
        n.(after.right) = n.(before.right)
    }
    after.marked = before.marked
}

fact {
    some hs1, hs2: HeapState |
        clearMarks[h, hs1] and
        mark[hs1, root, hs2] and
        setFreeList[hs2, hsn]
}