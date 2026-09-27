sig Node {
  left, right: set Node
}

fact {
  all n: Node | lone n.left
  all n: Node | lone n.right

  no n: Node | n in n.^(left + right)

  all n: Node | lone (n.~(left + right))

  all n: Node | no (n.left & n.right)

  all n: Node | (no n.left and no n.right) or (one n.left and one n.right)

  all n: Node | #(n.*left) = #(n.*right)
}