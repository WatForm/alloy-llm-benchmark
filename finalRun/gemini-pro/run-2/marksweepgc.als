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

pred clearMarks[before_state, after_state: HeapState] {
  no after_state.marked
  after_state.left = before_state.left
  after_state.right = before_state.right
}

fun reachable[h: HeapState, start: Node]: set Node {
  start.*(h.left + h.right)
}

pred mark[before_state: HeapState, from: Node, after_state: HeapState] {
  after_state.marked = reachable[before_state, from]
  after_state.left = before_state.left
  after_state.right = before_state.right
}

pred setFreeList[before_state, after_state: HeapState] {
  after_state.freeList.*(after_state.left) in Node - before_state.marked
  
  all n: Node - before_state.marked | {
    no n.(after_state.right)
    n.(after_state.left) in after_state.freeList.*(after_state.left)
    n in after_state.freeList.*(after_state.left)
  }
  
  all n: before_state.marked | {
    n.(after_state.left) = n.(before_state.left)
    n.(after_state.right) = n.(before_state.right)
  }
  
  after_state.marked = before_state.marked
}

fact {
  some hs1, hs2: HeapState {
    clearMarks[h, hs1]
    mark[hs1, root, hs2]
    setFreeList[hs2, hsn]
  }
}