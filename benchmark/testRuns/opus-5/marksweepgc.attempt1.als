module marksweepgc

sig Node {}

sig HeapState {
  left, right: Node -> lone Node,
  marked: set Node,
  freeList: lone Node
}

one sig h, hsn extends HeapState {}

one sig root extends Node {}

pred clearMarks[hs, hsp: HeapState] {
  no hsp.marked
  hsp.left = hs.left
  hsp.right = hs.right
}

fun reachable[hs: HeapState, n: Node]: set Node {
  n.*(hs.left + hs.right)
}

pred mark[hs: HeapState, from: Node, hsp: HeapState] {
  hsp.marked = reachable[hs, from]
  hsp.left = hs.left
  hsp.right = hs.right
}

pred setFreeList[hs, hsp: HeapState] {
  all n: hsp.freeList.*(hsp.left) | n in Node - hs.marked
  all n: Node - hs.marked {
    no n.(hsp.right)
    n.(hsp.left) in hsp.freeList.*(hsp.left)
    n in hsp.freeList.*(hsp.left)
  }
  all n: hs.marked {
    n.(hsp.left) = n.(hs.left)
    n.(hsp.right) = n.(hs.right)
  }
  hsp.marked = hs.marked
}

fact {
  some hs1, hs2: HeapState |
    clearMarks[h, hs1] and mark[hs1, root, hs2] and setFreeList[hs2, hsn]
}