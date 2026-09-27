sig Node {
  left: set Node,
  right: set Node
}

fact AtMostOneLeftAndRight {
  all n: Node | lone n.left
  all n: Node | lone n.right
}

fact Acyclic {
  all n: Node | n not in n.^(left + right)
}

fact AtMostOneParent {
  all n: Node | lone (left + right).n
}

fact DisjointLeftRight {
  all n: Node | no (n.left & n.right)
}

fact PerfectBinaryForest {
  all n: Node | #(n.*left) = #(n.*right)
}