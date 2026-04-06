sig Node {}

sig HeapState {
  left: Node -> lone Node,
  right: Node -> lone Node,
  marked: set Node,
  freeList: lone Node
}

pred clearMarks[hs, hs': HeapState] {
  no hs'.marked
  hs'.left = hs.left
  hs'.right = hs.right
}

fun reachable[hs: HeapState, n: Node]: set Node {
  n.*(hs.left + hs.right)
}

pred mark[hs: HeapState, from: Node, hs': HeapState] {
  hs'.marked = reachable[hs, from]
  hs'.left = hs.left
  hs'.right = hs.right
}

pred setFreeList[hs, hs': HeapState] {
  hs'.left = hs.left
  hs'.right = hs.right
  hs'.marked = hs.marked
  reachable[hs', hs'.freeList] in (Node - hs'.marked)
}

pred GC[h, h': HeapState, root: Node] {
  some h1, h2: HeapState |
    clearMarks[h, h1] and
    mark[h1, root, h2] and
    setFreeList[h2, h']
}

assert Soundness1 {
  all h, h': HeapState, root: Node |
    GC[h, h', root] =>
      all n: reachable[h, root] |
        n.(h'.left) = n.(h.left) and
        n.(h'.right) = n.(h.right)
}

assert Soundness2 {
  all h, h': HeapState, root: Node |
    GC[h, h', root] =>
      no (reachable[h', root] & reachable[h', h'.freeList])
}

assert Completeness {
  all h, h': HeapState, root: Node |
    GC[h, h', root] =>
      (Node - reachable[h', root]) in reachable[h', h'.freeList]
}

check Soundness1 for 3 expect 0
check Soundness2 for 3 expect 0
check Completeness for 3 expect 0