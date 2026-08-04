sig Node {}

sig HeapState {
    left: lone Node,
    right: lone Node,
    marked: set Node,
    freeList: lone Node
}

one sig root {}

some sig h, hsn {}

pred clearMarks(before: HeapState, after: HeapState) {
    after.marked = none &&
    before.left = after.left &&
    before.right = after.right
}

pred reachable(hs: HeapState, start: Node, r: set Node) {
    start in r or
    some p: Node | 
        (p in r &&
        (p.left in nodes(hs, r) or p.right in nodes(hs, r))) &&
        reachable(hs, p, r)
}

pred nodes(hs: HeapState, s: set Node): set Node {
    s + {n: Node | 
        n.left in s || n.right in s
    }
}

pred mark(before: HeapState, from: Node, after: HeapState) {
    after.marked = reachable(before, from, none) &&
    after.left = before.left &&
    after.right = before.right
}

pred setFreeList(before: HeapState, after: HeapState) {
    all n: Node | 
        (n !in before.marked implies 
            (n.right = none &&
            some l: Node | 
                after.freeList in reachable(after, l, none) &&
            n in reachable(after, after.freeList, none)) &&
        (n in before.marked implies 
            (n.left = before.left[n] && 
             n.right = before.right[n]))
             
    after.marked = before.marked
}

fact {
    some hs1, hs2: HeapState |
        clearMarks(h, hs1) &&
        mark(hs1, root, hs2) &&
        setFreeList(hs2, hsn)
}