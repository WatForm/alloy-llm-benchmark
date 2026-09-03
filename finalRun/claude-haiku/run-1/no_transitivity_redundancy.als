sig N {
  suivant: set N
}

fact {
  no n: N | n in n.^suivant
}

fact {
  no n: N | (n.suivant & n.suivant.^suivant) != none
}