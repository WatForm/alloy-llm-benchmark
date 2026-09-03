sig Node {
  left: set Node,
  right: set Node
}

fact atMostOneLeftAndRight {
  all n: Node | lone n.left and lone n.right
}

fact acyclic {
  all n: Node | n not in n.^(left + right)
}

fact atMostOneParent {
  all n: Node | lone (left + right).n
}

fact leftDisjointRight {
  all n: Node | no (n.left & n.right)
}

fact perfectBinaryTrees {
  all n: Node | #(n.*left) = #(n.*right)
}