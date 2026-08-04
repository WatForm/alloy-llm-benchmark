sig Node {
    left, right: lone Node
}

fact {
    no iden & ^(left + right)
    all n: Node | lone n.~(left + right)
    all n: Node | no n.left & n.right
    all n: Node | (no n.left and no n.right) or (one n.left and one n.right)
    all n: Node | #(n.*left) = #(n.*right)
}