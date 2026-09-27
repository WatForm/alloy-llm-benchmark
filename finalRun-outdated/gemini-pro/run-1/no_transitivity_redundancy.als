sig N {
  suivant: set N
}

fact {
  no iden & ^suivant
  no ^suivant & iden
  no suivant & suivant.^suivant
}