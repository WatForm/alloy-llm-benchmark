sig Node {}

sig HeapState {
  left: Node -> lone Node,
  right: Node -> lone Node,
  marked: set Node,
  freeList: lone Node
}

one sig h, hsn in HeapState {}

one sig root in Node {}

pred clearMarks[before, after: HeapState] {
  no after.marked
  after.left = before.left
  after.right = before.right
}

fun reachable[state: HeapState, from: Node]: set Node {
  from.*(state.left + state.right)
}

pred mark[before: HeapState, from: Node, after: HeapState] {
  after.marked = reachable[before, from]
  after.left = before.left
  after.right = before.right
}

pred setFreeList[before, after: HeapState] {
  after.freeList.*(after.left) in Node - before.marked

  all node: Node - before.marked {
    no node.(after.right)
    node.(after.left) in after.freeList.*(after.left)
    node in after.freeList.*(after.left)
  }

  all node: before.marked {
    node.(after.left) = node.(before.left)
    node.(after.right) = node.(before.right)
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