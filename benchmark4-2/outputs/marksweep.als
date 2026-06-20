sig Node {}

sig HeapState {
  left: Node -> lone Node,
  right: Node -> lone Node,
  marked: set Node,
  freeList: lone Node
}

sig h, hsn in HeapState {}

one sig root in Node {}

pred clearMarks[b, a: one HeapState] {
  no a.marked
  a.left = b.left
  a.right = b.right
}

fun reachable[s: one HeapState, from: one Node]: set Node {
  from.*(s.left + s.right)
}

pred mark[b: one HeapState, from: one Node, a: one HeapState] {
  a.marked = reachable[b, from]
  a.left = b.left
  a.right = b.right
}

pred setFreeList[b, a: one HeapState] {
  a.freeList.*(a.left) in Node - b.marked

  all n: Node - b.marked {
    no n.(a.right)
    n.(a.left) in a.freeList.*(a.left)
    n in a.freeList.*(a.left)
  }

  all n: b.marked {
    n.(a.left) = n.(b.left)
    n.(a.right) = n.(b.right)
  }

  a.marked = b.marked
}

fact {
  some s1, s2: HeapState {
    clearMarks[h, s1]
    mark[s1, root, s2]
    setFreeList[s2, hsn]
  }
}