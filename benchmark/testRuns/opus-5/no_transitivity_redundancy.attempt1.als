open util/relation

sig N {
	suivant : set N
}

fact acyclicOverN {
	acyclic[suivant, N]
}

fact acyclicSuivant {
	no ^suivant & iden
}

fact noShortcut {
	all n : N | no n.suivant & n.suivant.^suivant
}