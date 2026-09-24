abstract sig Color {}
one sig Red, Blue extends Color {}

sig Node {
	neighbors: set Node,
	color: one Color
}

fact {
	// The relation "neighbors" is symmetric.
	neighbors = ~neighbors

	// No "Node" is in its own "neighbors" set.
	no iden & neighbors

	// The graph formed by "neighbors" is connected and acyclic.
	all n1, n2: Node | n1 in n2.*neighbors
	all n: Node, m: n.neighbors | n not in m.*(neighbors - (n->m + m->n))
}