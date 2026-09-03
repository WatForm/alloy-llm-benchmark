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

pred clearMarks[hs1, hs2: HeapState] {
  no hs2.marked
  hs1.left = hs2.left
  hs1.right = hs2.right
}

fun reachable[hs: HeapState, n: Node]: set Node {
  n.*(hs.left + hs.right)
}

pred mark[hs1: HeapState, from: Node, hs2: HeapState] {
  hs2.marked = reachable[hs1, from]
  hs2.left = hs1.left
  hs2.right = hs1.right
}

pred setFreeList[hs1, hs2: HeapState] {
  hs2.freeList.*(hs2.left) in Node - hs1.marked
  all n: Node - hs1.marked {
    no n.(hs2.right)
    n.(hs2.left) in hs2.freeList.*(hs2.left)
    n in hs2.freeList.*(hs2.left)
  }
  all n: hs1.marked {
    n.(hs2.left) = n.(hs1.left)
    n.(hs2.right) = n.(hs1.right)
  }
  hs2.marked = hs1.marked
}

fact {
  some hs1, hs2: HeapState |
    clearMarks[h, hs1] and mark[hs1, root, hs2] and setFreeList[hs2, hsn]
}