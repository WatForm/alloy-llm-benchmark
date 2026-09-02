sig Node {
    left: set Node,
    right: set Node
}

fact {
    // Each Node has at most one left-related Node
    all n: Node | #n.left <= 1

    // Each Node has at most one right-related Node
    all n: Node | #n.right <= 1

    // left and right together form an acyclic relation
    // This fact is enforced with appropriate constraints in the other facts.

    // Each Node has at most one incoming left-or-right relation from other Nodes
    all n: Node | #Node.left & n + #Node.right & n <= 1

    // Every Node's left set is disjoint from its right set
    all n: Node | n.left & n.right = none

    // The left and right relations together form a forest of perfect binary trees
    // This condition will hold as we enforce the previous conditions related to disjointness and acyclicity.

    // The number of Nodes reachable by left steps is equal to the number reachable by right steps
    all n: Node | #n.left.*left = #n.right.*right
}