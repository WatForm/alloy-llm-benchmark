sig Node {
  left: lone Node,
  right: lone Node
}

fact Acyclic {
  no n: Node | n in n.^(left + right)
}

fact DisjointChildren {
  no n: Node | some n.left and n.left = n.right
}

fact AtMostOneParent {
  all n: Node | lone (left + right).n
}

fact FullBinaryTree {
  all n: Node | (no n.left and no n.right) or (one n.left and one n.right)
}

fact BalancedSubtrees {
  all n: Node | #(n.left.*(left + right)) = #(n.right.*(left + right))
}