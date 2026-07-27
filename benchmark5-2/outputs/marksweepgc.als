sig Node {}

sig HeapState {
  left: Node -> lone Node,
  right: Node -> lone Node,
  marked: set Node,
  freeList: lone Node
}

one sig h, hsn in HeapState {}

one sig root in Node {}

pred clearMarks[pre, post: HeapState] {
  no post.marked
  post.left = pre.left
  post.right = pre.right
}

fun reachable[state: HeapState, from: Node]: set Node {
  from.*(state.left + state.right)
}

pred mark[pre: HeapState, from: Node, post: HeapState] {
  post.marked = reachable[pre, from]
  post.left = pre.left
  post.right = pre.right
}

pred setFreeList[pre, post: HeapState] {
  post.freeList.*(post.left) in Node - pre.marked

  all node: Node - pre.marked | {
    no node.(post.right)
    node.(post.left) in post.freeList.*(post.left)
    node in post.freeList.*(post.left)
  }

  all node: pre.marked | {
    node.(post.left) = node.(pre.left)
    node.(post.right) = node.(pre.right)
  }

  post.marked = pre.marked
}

fact {
  some firstState, secondState: HeapState | {
    clearMarks[h, firstState]
    mark[firstState, root, secondState]
    setFreeList[secondState, hsn]
  }
}