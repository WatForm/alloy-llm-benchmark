sig Node {
    left: lone Node,
    right: lone Node
}

fact {
    no iden & ^(left + right)
    all n: Node | #((left + right).n) <= 1
    all n: Node | no (n.left & n.right)
    all n: Node | (no n.left and no n.right) or (one n.left and one n.right)
    all n: Node | #(n.*left) = #(n.*right)
}