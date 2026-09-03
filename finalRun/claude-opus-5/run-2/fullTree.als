sig Node {
  left: set Node,
  right: set Node
}

// For every element of Node, there is at most one left-related Node,
// and at most one right-related Node.
fact multiplicities {
  all n: Node | lone n.left and lone n.right
}

// left and right together form an acyclic relation.
fact acyclic {
  no n: Node | n in n.^(left + right)
}

// Each Node has at most one incoming left-or-right relation from other Nodes.
fact atMostOneParent {
  all n: Node | lone (left + right).n
}

// Every Node's left set is disjoint from its right set.
fact leftRightDisjoint {
  all n: Node | no (n.left & n.right)
}

// The left and right relations together form a forest of perfect binary trees:
// for every Node, the number of Nodes reachable by zero or more left steps
// equals the number of Nodes reachable by zero or more right steps.
fact perfectBinaryTrees {
  all n: Node | #(n.*left) = #(n.*right)
}