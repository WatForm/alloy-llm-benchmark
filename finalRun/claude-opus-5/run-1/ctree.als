abstract sig Color {}
one sig Red, Blue extends Color {}

sig Node {
	neighbors : set Node,
	color : one Color
}

fact Symmetric {
	neighbors = ~neighbors
}

fact Irreflexive {
	no n : Node | n in n.neighbors
}

fact Connected {
	all n : Node | Node in n.*neighbors
}

fact Acyclic {
	#neighbors = mul[2, minus[#Node, 1]]
}