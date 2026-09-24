sig N {
	suivant: set N
}

fact {
	all n: N | n not in n.^suivant
	all n: N | no (n.suivant & n.suivant.^suivant)
}