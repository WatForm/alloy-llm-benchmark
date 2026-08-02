sig Node {}

sig HeapState {
  left: Node -> lone Node,
  right: Node -> lone Node,
  marked: set Node,
  freeList: lone Node
}

one sig h, hsn in HeapState {}

one sig root in Node {}

pred clearMarks[pre: HeapState, post: HeapState] {
  no post.marked
  post.left = pre.left
  post.right = pre.right
}

fun reachable[hs: HeapState, start: Node]: set Node {
  start.*(hs.left + hs.right)
}

pred mark[pre: HeapState, from: Node, post: HeapState] {
  post.marked = reachable[pre, from]
  post.left = pre.left
  post.right = pre.right
}

pred setFreeList[pre: HeapState, post: HeapState] {
  post.freeList.*(post.left) in Node - pre.marked

  all n: Node - pre.marked {
    no n.(post.right)
    n.(post.left) in post.freeList.*(post.left)
    n in post.freeList.*(post.left)
  }

  all n: pre.marked {
    n.(post.left) = n.(pre.left)
    n.(post.right) = n.(pre.right)
  }

  post.marked = pre.marked
}

fact {
  some hs1, hs2: HeapState {
    clearMarks[h, hs1]
    mark[hs1, root, hs2]
    setFreeList[hs2, hsn]
  }
}