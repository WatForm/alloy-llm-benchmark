open util/relation

sig N {
	suivant: set N
}

fact suivantAcyclicOverN {
	acyclic[suivant, N]
}

fact suivantAcyclic {
	no n: N | n in n.^suivant
}

fact noShortcut {
	no n: N | some m: n.suivant | m in n.suivant.^suivant
}