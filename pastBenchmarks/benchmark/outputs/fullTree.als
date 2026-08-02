sig Node {
  left: set Node,
  right: set Node
}

fact {
  all n: Node |
    lone n.left and lone n.right
}

pred Acyclic {
  all n: Node | {
    n not in n.^left
    n not in n.^right
    lone (n.~left + n.~right)
    no (n.~left & n.~right)
  }
}

pred makeFull {
  all n: Node |
    #(n.^left) = #(n.^right)
}

pred FullTree {
  Acyclic
  makeFull
}

run FullTree