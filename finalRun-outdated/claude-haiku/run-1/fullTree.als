sig Node {
  left: lone Node,
  right: lone Node
}

fact acyclic {
  no n: Node | n in n.^(left + right)
}

fact singleIncoming {
  all n: Node | lone p: Node | p.left = n or p.right = n
}

fact leftRightDisjoint {
  all n: Node | n.left != n.right
}

fact perfectBinaryTrees {
  all n: Node | 
    (n.left = none and n.right = none) or
    (n.left != none and n.right != none)
}

fact balancedReachability {
  all n: Node | #(n.*left) = #(n.*right)
}