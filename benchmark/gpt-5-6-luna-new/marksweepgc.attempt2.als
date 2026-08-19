sig Node {}

sig HeapState {
    left: Node -> lone Node,
    right: Node -> lone Node,
    marked: set Node,
    freeList: lone Node
}

one sig h, hsn in HeapState {}

one sig root in Node {}

pred clearMarks[b, a: HeapState] {
    no a.marked
    b.left = a.left
    b.right = a.right
}

fun reachable[hs: HeapState, source: Node]: set Node {
    source.*(hs.left + hs.right)
}

pred mark[b: HeapState, source: Node, a: HeapState] {
    a.marked = reachable[b, source]
    a.left = b.left
    a.right = b.right
}

pred setFreeList[b, a: HeapState] {
    reachable[a, a.freeList] in Node - b.marked

    all n: Node - b.marked | {
        no n.(a.right)
        n.(a.left) in reachable[a, a.freeList]
        n in reachable[a, a.freeList]
    }

    all n: b.marked | {
        n.(a.left) = n.(b.left)
        n.(a.right) = n.(b.right)
    }

    a.marked = b.marked
}

fact {
    some s1, s2: HeapState | {
        clearMarks[h, s1]
        mark[s1, root, s2]
        setFreeList[s2, hsn]
    }
}