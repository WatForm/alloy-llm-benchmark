sig Node {}

sig HeapState {
  left, right: Node -> lone Node,
  marked: set Node,
  freeList: lone Node
}

one sig h, hsn extends HeapState {}

one sig root extends Node {}

fun reachable[s: HeapState, from: Node]: set Node {
  from.*(s.left + s.right)
}

pred clearMarks[before, after: HeapState] {
  after.marked = none
  after.left = before.left
  after.right = before.right
}

pred mark[before: HeapState, from: Node, after: HeapState] {
  after.marked = reachable[before, from]
  after.left = before.left
  after.right = before.right
}

pred setFreeList[before, after: HeapState] {
  after.freeList.*(after.left) in Node - before.marked

  all n: Node - before.marked {
    no n.(after.right)
    n.(after.left) in after.freeList.*(after.left)
    n in after.freeList.*(after.left)
  }

  all n: before.marked {
    n.(after.left) = n.(before.left)
    n.(after.right) = n.(before.right)
  }

  after.marked = before.marked
}

fact {
  some disj h1, h2: HeapState {
    clearMarks[h, h1]
    mark[h1, root, h2]
    setFreeList[h2, hsn]
  }
}