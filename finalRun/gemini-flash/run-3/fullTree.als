sig Node {
	left: set Node,
	right: set Node
}

fact {
	all n: Node {
		lone n.left
		lone n.right
		no n.left & n.right
		some n.left iff some n.right
		#(n.*left) = #(n.*right)
	}
	all n: Node {
		lone (left + right).n
	}
	no ^(left + right) & iden
}