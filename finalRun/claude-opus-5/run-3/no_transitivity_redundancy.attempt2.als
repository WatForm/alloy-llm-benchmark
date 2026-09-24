open util/relation as rel
open util/graph[N] as gr

sig N {
	suivant : set N
}

fact acyclicOverN {
	rel/acyclic[suivant, N]
}

fact acyclicSuivant {
	gr/acyclic[suivant]
}

fact noShortcut {
	no n : N | some (n.suivant & n.suivant.^suivant)
}