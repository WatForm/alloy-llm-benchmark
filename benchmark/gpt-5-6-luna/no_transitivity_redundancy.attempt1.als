sig N {
    suivant: set N
}

fact {
    no iden & ^suivant
}

fact {
    no iden & ^suivant
}

fact {
    no suivant & (^suivant - suivant)
}