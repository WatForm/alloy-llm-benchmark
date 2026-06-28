sig Node {
  left: set Node,
  right: set Node
}

fact {
  all n: Node | lone n.left
  all n: Node | lone n.right

  no iden & ^(left + right)

  all n: Node | lone (((left + right).n) - n)

  all n: Node | no (n.left & n.right)

  all n: Node | (some n.left) <=> (some n.right)

  all n: Node | #(n.*left) = #(n.*right)
}