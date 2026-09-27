sig Node {}

sig HeapState {
  left: Node -> lone Node,
  right: Node -> lone Node,
  marked: set Node,
  freeList: lone Node
}

one sig h, hsn in HeapState {}

one sig root in Node {}

pred clearMarks[hb, ha: HeapState] {
  no ha.marked
  ha.left = hb.left
  ha.right = hb.right
}

fun reachable[hs: HeapState, n: Node]: set Node {
  n.*(hs.left + hs.right)
}

pred mark[hb: HeapState, from: Node, ha: HeapState] {
  ha.marked = reachable[hb, from]
  ha.left = hb.left
  ha.right = hb.right
}

pred setFreeList[hb, ha: HeapState] {
  ha.freeList.*(ha.left) in Node - hb.marked
  all n: Node - hb.marked {
    no n.(ha.right)
    n.(ha.left) in ha.freeList.*(ha.left)
    n in ha.freeList.*(ha.left)
  }
  all n: hb.marked {
    n.(ha.left) = n.(hb.left)
    n.(ha.right) = n.(hb.right)
  }
  ha.marked = hb.marked
}

fact {
  some hs1, hs2: HeapState |
    clearMarks[h, hs1] and mark[hs1, root, hs2] and setFreeList[hs2, hsn]
}