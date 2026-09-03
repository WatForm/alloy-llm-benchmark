sig N {
    suivant: set N
}

fact acyclicOverN {
    all n: N | n not in n.^suivant
}

fact acyclicSuivant {
    no iden & ^suivant
}

fact noOneAndMoreSteps {
    no n: N | some m: N | m in n.suivant and m in n.(^suivant - suivant)
}