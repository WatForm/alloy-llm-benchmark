abstract sig Color {}
one sig Red extends Color {}
one sig Blue extends Color {}

sig Node {
	neighbors: set Node,
	color: one Color
}

fact {
	neighbors = ~neighbors
	no iden & neighbors
	all n1, n2: Node | n1 in n2.*neighbors
	all u, v: Node | v in u.neighbors implies v not in u.^(neighbors - (u->v + v->u))
}