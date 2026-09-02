sig N {
  suivant: set N
}

fact {
  no n: N | n in n.^suivant
}

fact {
  no iden & ^suivant
}

fact {
  no n1, n2: N |
    n2 in n1.suivant and
    n2 in n1.(suivant.^suivant)
}