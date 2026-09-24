sig Node {
	left : set Node,
	right : set Node
}

fact {
	all n : Node | lone n.left
	all n : Node | lone n.right
}

fact {
	no n : Node | n in n.^(left + right)
}

fact {
	all n : Node | lone (left + right).n
}

fact {
	all n : Node | no (n.left & n.right)
}

// The "left" and "right" relations together form a forest of perfect binary trees
fact {
	all n : Node | #(n.*left) = #(n.*right)
}