sig Node {}

sig HeapState {
  left: Node -> lone Node,
  right: Node -> lone Node,
  marked: set Node,
  freeList: lone Node
}

one sig h extends HeapState {}
one sig hsn extends HeapState {}
one sig root extends Node {}

fun reachable[hs: HeapState, start: Node]: set Node = start.*(hs.left + hs.right)
fun reachableViaLeft[hs: HeapState, start: Node]: set Node = start.*(hs.left)

pred clearMarks[before, after: HeapState] {
  no after.marked
  before.left = after.left
  before.right = after.right
}

pred mark[before: HeapState, from: Node, after: HeapState] {
  after.marked = reachable[before, from]
  after.left = before.left
  after.right = before.right
}

pred setFreeList[before: HeapState, after: HeapState] {
  reachableViaLeft[after, after.freeList] in (Node - before.marked)
  all n: (Node - before.marked) {
    no after.right[n]
    (some after.left[n]) implies (after.left[n] in reachableViaLeft[after, after.freeList])
    n in reachableViaLeft[after, after.freeList]
  }
  all n: (Node & before.marked) {
    after.left[n] = before.left[n]
    after.right[n] = before.right[n]
  }
  after.marked = before.marked
}

pred invariant {
  some firstHS, secondHS: HeapState {
    clearMarks[h, firstHS]
    mark[firstHS, root, secondHS]
    setFreeList[secondHS, hsn]
  }
}

run invariant