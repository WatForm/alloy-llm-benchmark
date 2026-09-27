sig Node {}

sig HeapState {
  left: Node -> lone Node,
  right: Node -> lone Node,
  marked: set Node,
  freeList: lone Node
}

one sig h in HeapState {}
one sig hsn in HeapState {}

one sig root extends Node {}

fun reachable[hs: HeapState, start: Node]: set Node {
  {start}.*(hs.left + hs.right)
}

pred clearMarks[before: HeapState, after: HeapState] {
  no after.marked
  before.left = after.left
  before.right = after.right
}

pred mark[before: HeapState, from: Node, after: HeapState] {
  after.marked = reachable[before, from]
  before.left = after.left
  before.right = after.right
}

fun freeListReachable[hs: HeapState]: set Node {
  hs.freeList.*(hs.left)
}

pred setFreeList[before: HeapState, after: HeapState] {
  freeListReachable[after] in (Node - before.marked)
  
  all n: Node - before.marked {
    no after.right[n]
    (some after.left[n]) implies (after.left[n] in freeListReachable[after])
    n in freeListReachable[after]
  }
  
  all n: before.marked {
    after.left[n] = before.left[n]
    after.right[n] = before.right[n]
  }
  
  before.marked = after.marked
}

pred constraints {
  some first: HeapState, second: HeapState {
    clearMarks[h, first]
    mark[first, root, second]
    setFreeList[second, hsn]
  }
}

run constraints