sig Node {}

sig HeapState {
  left: Node -> lone Node,
  right: Node -> lone Node,
  marked: set Node,
  freeList: lone Node
}

pred clearMarks[hs, hs': HeapState] {
  hs'.left = hs.left
  hs'.right = hs.right
  no hs'.marked
}

fun reachable[hs: HeapState, n: Node]: set Node {
  n.*((hs.left) + (hs.right))
}

pred mark[hs, hs': HeapState, from: Node] {
  hs'.left = hs.left
  hs'.right = hs.right
  hs'.freeList = hs.freeList
  hs'.marked = reachable[hs, from]
}

pred setFreeList[hs, hs': HeapState] {
  hs'.left = hs.left
  hs'.right = hs.right
  hs'.marked = hs.marked
  let garbage = Node - hs.marked |
    (
      no garbage => no hs'.freeList
    ) and
    (
      some garbage => hs'.freeList in garbage
    ) and
    garbage = hs'.freeList.*(hs'.left) and
    no (garbage & hs'.freeList.^(hs'.right))
}

pred GC[hs, hs': HeapState, root: Node] {
  some mid1, mid2: HeapState |
    clearMarks[hs, mid1] and
    mark[mid1, mid2, root] and
    setFreeList[mid2, hs']
}

assert Soundness1 {
  all hs, hs': HeapState, root: Node |
    GC[hs, hs', root] implies
      all n: reachable[hs, root] |
        n.(hs'.left) = n.(hs.left) and
        n.(hs'.right) = n.(hs.right)
}

assert Soundness2 {
  all hs, hs': HeapState, root: Node |
    GC[hs, hs', root] implies
      no (reachable[hs', root] & hs'.freeList.*(hs'.left))
}

assert Completeness {
  all hs, hs': HeapState, root: Node |
    GC[hs, hs', root] implies
      (Node - reachable[hs', root]) = hs'.freeList.*(hs'.left)
}

check Soundness1 for 3 expect 0
check Soundness2 for 3 expect 0
check Completeness for 3 expect 0