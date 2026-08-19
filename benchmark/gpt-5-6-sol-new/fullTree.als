sig Node {
  left: set Node,
  right: set Node
}

fact {
  no iden & ^(left + right)

  all n: Node {
    lone n.left
    lone n.right
    lone n.~(left + right)
    no n.left & n.right

    (no n.left and no n.right) or
    (one n.left and one n.right)

    #(n.*left) = #(n.*right)
  }
}