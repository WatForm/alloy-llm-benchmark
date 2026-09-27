sig Node {
  left, right: set Node
}

fact AtMostOneChild {
  all n: Node {
    lone n.left
    lone n.right
  }
}

fact Acyclic {
  all n: Node | n not in n.^(left + right)
}

fact AtMostOneParent {
  all n: Node | lone (left + right).n
}

fact DisjointChildren {
  all n: Node | no (n.left & n.right)
}

fact PerfectBinaryTrees {
  all n: Node | (some n.left iff some n.right)
}

fact EqualReachableCounts {
  all n: Node | #n.*left = #n.*right
}