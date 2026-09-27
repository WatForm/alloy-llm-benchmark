sig Node {}

one sig root in Node {}

sig HeapState {
  left: Node -> lone Node,
  right: Node -> lone Node,
  marked: set Node,
  freeList: lone Node
}

one sig h, hsn in HeapState {}

pred clearMarks[a, b: HeapState] {
  no b.marked
  a.left = b.left
  a.right = b.right
}

fun reachable[hs: HeapState, n: Node]: set Node {
  n.*(hs.left + hs.right)
}

pred mark[a: HeapState, from: Node, b: HeapState] {
  b.marked = reachable[a, from]
  b.left = a.left
  b.right = a.right
}

pred setFreeList[a, b: HeapState] {
  b.freeList.*(b.left) in Node - a.marked
  all n: Node - a.marked {
    no n.(b.right)
    some n.(b.left) => n.(b.left) in b.freeList.*(b.left)
    n in b.freeList.*(b.left)
  }
  all n: a.marked {
    n.(b.left) = n.(a.left)
    n.(b.right) = n.(a.right)
  }
  b.marked = a.marked
}

fact {
  some hs1, hs2: HeapState {
    clearMarks[h, hs1]
    mark[hs1, root, hs2]
    setFreeList[hs2, hsn]
  }
}