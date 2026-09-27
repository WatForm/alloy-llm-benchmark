sig Node {
  left, right: set Node
}

fact {
  all n: Node | lone n.left
  all n: Node | lone n.right

  no iden & ^(left + right)

  all n: Node | lone (left + right).n

  all n: Node | no n.left & n.right

  one root: Node | Node = root.*(left + right)

  all n: Node | #(n.*left) = #(n.*right)
}