sig Node {}

sig HeapState {
  left, right : Node -> lone Node,
  marked : set Node,
  freeList : lone Node
}

one sig h, hsn in HeapState {}
one sig root extends Node {}

pred clearMarks[hs, hsn : HeapState] {
  
  no hsn.marked
  
  hsn.left = hs.left
  hsn.right = hs.right
}

fun reachable[hs: HeapState, n: Node] : set Node {
  n + n.^(hs.left + hs.right)
}

pred mark[hs: HeapState, from : Node, hsn: HeapState] {
  hsn.marked = hs.reachable[from]
  hsn.left = hs.left
  hsn.right = hs.right
}

pred setFreeList[hs, hsn: HeapState] {
  
  hsn.freeList.*(hsn.left) in (Node - hs.marked)
  all n: Node |
  (n !in hs.marked) =>
    ( no hsn.right[n]
      && hsn.left[n] in (hsn.freeList.*(hsn.left))
      && n in hsn.freeList.*(hsn.left)
    )
  &&
  (n in hs.marked) =>
    ( hsn.left[n] = hs.left[n]
      && hsn.right[n] = hs.right[n]
    )
  hsn.marked = hs.marked
}

pred GC[hs: HeapState, root : Node, hsn: HeapState] {
  some hs1, hs2: HeapState |
    hs.clearMarks[hs1] && hs1.mark[root, hs2] && hs2.setFreeList[hsn]
}

fact GCHappened{
  GC[h,root, hsn]
}

