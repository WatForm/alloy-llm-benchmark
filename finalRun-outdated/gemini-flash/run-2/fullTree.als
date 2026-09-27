sig Node {
    left: set Node,
    right: set Node
}

fact {
    all n: Node {
        lone n.left
        lone n.right
        no n.left & n.right
        lone (left + right).n
        #n.*left = #n.*right
    }
    no ^(left + right) & iden
}