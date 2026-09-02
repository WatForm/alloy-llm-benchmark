sig Node {
    left, right: set Node
}

fact {
    all n: Node | lone n.left
    all n: Node | lone n.right
    no iden & ^(left + right)
    all n: Node | lone n.~(left + right)
    all n: Node | no (n.left & n.right)
    all n: Node |
        (#n.left = 0 and #n.right = 0) or
        (#n.left = 1 and #n.right = 1)
    all n: Node | #(n.*left) = #(n.*right)
}