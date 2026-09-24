sig N {
	suivant : set N
}

fact acyclicOverN {
	no n : N | n in n.^suivant
}

fact acyclicSuivant {
	no n : N | n in n.^suivant
}

fact noShortcut {
	no n : N | some (n.suivant & n.suivant.^suivant)
}