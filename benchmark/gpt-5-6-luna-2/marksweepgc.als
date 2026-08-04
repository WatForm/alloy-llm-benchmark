sig Node {}

sig HeapState {
  left: Node -> lone Node,
  right: Node -> lone Node,
  marked: set Node,
  freeList: lone Node
}

one sig h, hsn in HeapState {}
one sig root in Node {}

fun reachable[state: HeapState, from: Node]: set Node {
  from.*(state.left + state.right)
}

pred clearMarks[before: HeapState, after: HeapState] {
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
  all n: reachable[after, after.freeList] |
    n not in before.marked

  all n: Node - before.marked {
    no n.(after.right)
    n.(after.left) in reachable[after, after.freeList]
    n in reachable[after, after.freeList]
  }

  all n: before.marked {
    n.(after.left) = n.(before.left)
    n.(after.right) = n.(before.right)
  }

  after.marked = before.marked
}

fact {
  some first, second: HeapState {
    clearMarks[h, first]
    mark[first, root, second]
    setFreeList[second, hsn]
  }
}