sig Node {
  left: set Node,
  right: set Node
}

fact {
  all n: Node | lone n.left
  all n: Node | lone n.right
}

fact {
  all n: Node | n not in n.^(left + right)
}

fact {
  all n: Node | lone (left + right).n
}

fact {
  all n: Node | no (n.left & n.right)
}

fact {
  all n: Node | (no n.left and no n.right) or (some n.left and some n.right)
}

fact {
  all n: Node | #(n.*left) = #(n.*right)
}