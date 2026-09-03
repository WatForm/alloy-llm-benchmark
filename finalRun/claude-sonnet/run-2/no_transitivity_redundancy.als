sig N {
    suivant: set N
}

fact acyclicOverN {
    all n: N | n not in n.^suivant
}

fact acyclic {
    no n: N | n in n.^suivant
}

fact noMultiplePaths {
    all n: N | no (n.suivant & n.suivant.^suivant)
}