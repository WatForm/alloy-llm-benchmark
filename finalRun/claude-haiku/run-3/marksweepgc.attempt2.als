sig Node {}

sig HeapState {
  left: lone Node,
  right: lone Node,
  marked: set Node,
  freeList: lone Node
}

one sig h, hsn extends HeapState {}
one sig root extends Node {}

fun reachable[hs: HeapState, start: Node]: set Node {
  start.*(hs.left + hs.right)
}

fun reachableLeft[hs: HeapState, start: Node]: set Node {
  start.*(hs.left)
}

pred clearMarks[before, after: HeapState] {
  no after.marked
  after.left = before.left
  after.right = before.right
}

pred mark[before: HeapState, from: Node, after: HeapState] {
  after.marked = reachable[before, from]
  after.left = before.left
  after.right = before.right
}

pred setFreeList[before: HeapState, after: HeapState] {
  all n: reachableLeft[after, after.freeList] | n in Node - before.marked
  all n: Node - before.marked {
    no n.(after.right)
    (some n.(after.left)) => n.(after.left) in reachableLeft[after, after.freeList]
    n in reachableLeft[after, after.freeList]
  }
  all n: before.marked {
    n.(after.left) = n.(before.left)
    n.(after.right) = n.(before.right)
  }
  after.marked = before.marked
}

pred main {
  some h1, h2: HeapState {
    clearMarks[h, h1]
    mark[h1, root, h2]
    setFreeList[h2, hsn]
  }
}

run main