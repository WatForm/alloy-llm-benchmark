open util/relation
open util/graph[N]

sig N {
	suivant : set N
}

fact acyclicOverN {
	relation/acyclic[suivant, N]
}

fact acyclicSuivant {
	graph/acyclic[suivant]
}

fact noShortcut {
	no n : N | some (n.suivant & n.suivant.^suivant)
}