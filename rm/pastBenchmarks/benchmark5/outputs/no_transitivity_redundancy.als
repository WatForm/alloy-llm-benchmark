sig N {
  suivant: set N
}

fact {
  no n: N | n in n.^suivant
}

fact {
  no n: N | n in n.^suivant
}

fact {
  all n: N | no n.suivant & n.suivant.^suivant
}