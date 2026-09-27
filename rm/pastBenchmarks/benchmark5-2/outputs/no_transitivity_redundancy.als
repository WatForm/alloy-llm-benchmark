sig N {
  suivant: set N
}

fact {
  no n: N | n in n.^suivant
  no iden & ^suivant
  no suivant & suivant.^suivant
}