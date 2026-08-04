sig N {
  suivant: set N
}

fact {
  no n: N | n in n.^suivant
  no iden & ^suivant
  all n: N | no (n.suivant & n.suivant.^suivant)
}