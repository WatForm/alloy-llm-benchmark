sig Node {
    left: set Node,
    right: set Node
}

fact LeftRightFunctional {
    all n: Node | lone n.left
    all n: Node | lone n.right
}

fact Acyclic {
    no n: Node | n in n.^(left + right)
}

fact SingleIncoming {
    all n: Node | lone (left + right).n
}

fact DisjointLeftRight {
    all n: Node | no (n.left & n.right)
}

fact PerfectBinaryForest {
    all n: Node | #(n.*left) = #(n.*right)
}