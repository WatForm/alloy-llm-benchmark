sig Node {
  left: lone Node,
  right: lone Node
}

fact acyclic {
  no n: Node | n in n.^(left + right)
}

fact atMostOneParent {
  all n: Node | lone n.~left + n.~right
}

fact disjoint {
  all n: Node | n.left & n.right = none
}

fact perfectBinaryTrees {
  all n: Node | (some n.left iff some n.right)
}

fact balancedReachability {
  all n: Node | #{m: Node | m in n.*(left)} = #{m: Node | m in n.*(right)}
}