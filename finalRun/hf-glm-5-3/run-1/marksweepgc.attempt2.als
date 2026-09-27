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

pred clearMarks[pre, post: HeapState] {
  post.marked = none
  post.left = pre.left
  post.right = pre.right
}

pred mark[pre: HeapState, from: Node, post: HeapState] {
  post.marked = reachable[pre, from]
  post.left = pre.left
  post.right = pre.right
}

pred setFreeList[pre, post: HeapState] {
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
  some disj h1, h2: HeapState {
    clearMarks[h, h1]
    mark[h1, root, h2]
    setFreeList[h2, hsn]
  }
}