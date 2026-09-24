module marksweepgc

sig Node {}

sig HeapState {
  left, right: Node -> lone Node,
  marked: set Node,
  freeList: lone Node
}

one sig h, hsn in HeapState {}

one sig root in Node {}

pred clearMarks[hs, hs': HeapState] {
  no hs'.marked
  hs'.left = hs.left
  hs'.right = hs.right
}

fun reachable[hs: HeapState, n: Node]: set Node {
  n + n.^(hs.left + hs.right)
}

pred mark[hs: HeapState, from: Node, hs': HeapState] {
  hs'.marked = hs.reachable[from]
  hs'.left = hs.left
  hs'.right = hs.right
}

pred setFreeList[hs, hs': HeapState] {
  hs'.freeList.*(hs'.left) in Node - hs.marked
  all n: Node - hs.marked {
    no hs'.right[n]
    hs'.left[n] in hs'.freeList.*(hs'.left)
    n in hs'.freeList.*(hs'.left)
  }
  all n: hs.marked {
    hs'.left[n] = hs.left[n]
    hs'.right[n] = hs.right[n]
  }
  hs'.marked = hs.marked
}

fact {
  some h1, h2: HeapState {
    clearMarks[h, h1]
    mark[h1, root, h2]
    setFreeList[h2, hsn]
  }
}