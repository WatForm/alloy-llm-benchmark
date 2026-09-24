sig Node {
    left: lone Node,
    right: lone Node
}

fact {
    all n: Node | lone n.left and lone n.right
    no ^(left + right) & iden
    all n: Node | lone (left + right).n
    all n: Node | no (n.left & n.right)
    all n: Node | some n.left <=> some n.right
    all n: Node | #(n.*left) = #(n.*right)
}