sig N {
  suivant: set N
}

fact {
  no n: N | n in n.^suivant
  no n: univ | n in n.^suivant
  no n: N | some (n.suivant & n.(suivant.^suivant))
}